/*
 * jitregs.c
 * 
 * This file is part of the Oxford Oberon-2 compiler
 * Copyright (c) 2006 J. M. Spivey
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "obx.h"
#include "jit.h"
#include <assert.h>

struct _reg *regs = NULL;
int nregs;
reg rBP, rSP, rI0, rI1, rI2, rZERO;

static reg def_reg(vmreg r, int c) {
     reg p = &regs[nregs++];
     p->r_reg = r;
     p->r_class = c;
     p->r_refct = 0;
     p->r_value.v_op = 0;
     return p;
}

void setup_regs(void) {
     int totregs = nvreg + nireg + nfreg + 1;
     int nwregs = nvreg + nireg;
     int i;

     assert(nwregs >= 5);

     regs = (struct _reg *) scratch_alloc(totregs * sizeof(struct _reg), TRUE);

     nregs = 0;
     for (i = 0; i < nireg; i++)
          def_reg(ireg[i], INT);
     for (i = 0; i < nvreg; i++)
          def_reg(vreg[i], INT);
     for (i = 0; i < nfreg; i++)
          def_reg(freg[i], FLO);
     rZERO = def_reg(zero, 0);

     rI0 = &regs[0]; rI1 = &regs[1]; rI2 = &regs[2];
     rSP = &regs[nwregs-2]; rBP = &regs[nwregs-1]; 
     rBP->r_class = 0;
}

/* Each register has a reference count, and may also be locked -- this
   is signified by increasing the reference count by OMEGA.  Normally, a
   register is unlocked and has a reference count equal to the number of
   times it appears in the stack.
   
   A typical allocation phase for an operation looks like this:
   
   move_to_reg(sp-2); move_to_reg(sp-1);
   // Now the two top items on the stack are in registers that are locked.
   r1 = ralloc(INT);
   // r1 is guaranteed to be different from the input registers holding the 
   // two stack items
   pop(2);
   // The two registers are still locked, but their reference counts
   // have been decremented
   r2 = ralloc_avoid(INT, r1);
   // r2 is different from r1, but one of the two input registers may be reused.
   // However, the input registers will not be spilled.
   unlock(2);
   // The input registers are now unlocked.
   
   The ralloc function does not increment the reference count of the
   register that it allocates; that is done later when a value is pushed
   onto the stack. */

/* n_reserved -- count reserved integer registers */
int n_reserved(void) {
     int res = 0;
     reg r;

     for_regs (r) {
	  if (member(r, INT) && r->r_refct > 0)
	       res++;
     }

     return res;
}

/* incref -- increment or decrement reference count */
reg incref(reg r, int inc) {
     if (r->r_class != 0) r->r_refct += inc;
     return r;
}

/* ralloc_avoid -- allocate register, avoiding one previously allocated */
reg ralloc_avoid(int s, reg r2) {
     reg r, best = rZERO;
     int min = 2, cost;

     static mybool spilling = FALSE;

     /* See if there is an unused register */
     for_regs (r) {
	  /* Locked registers are OK if their refcount is otherwise 0 */
	  if (member(r, s) && r->r_refct % OMEGA == 0 && r != r2) {
	       cost = (cached(r));
	       if (cost < min) {
		    best = r; min = cost;
		    if (min == 0) break;
	       }
	  }
     }

     if (best != rZERO)
	  return kill(best);

     /* Now try spilling: ignore locked registers */
     if (! spilling) {
	  min = OMEGA; 
	  spilling = TRUE;

	  for_regs (r) {
	       if (member(r, s) && r->r_refct < min && r != r2) {
		    best = r; min = r->r_refct;
	       }
	  }

	  if (best != rZERO) {
#ifdef DEBUG
	       if (dflag > 1) 
		    printf("Spilling %s (refct=%d)\n", 
			   vm_regname(best->r_reg), best->r_refct);
#endif
	       spill(best);
#ifdef DEBUG
	       if (dflag > 1)
		    printf("Refct now %d\n", best->r_refct);
#endif

	       spilling = FALSE;
	       return kill(best);
	  }

     }

     panic("out of registers");
     return rZERO;
}

/* ralloc_suggest -- allocate a preferred register, or choose another */
reg ralloc_suggest(int s, reg r) {
     if (r != rZERO && member(r, s) && r->r_refct % OMEGA == 0)
	  return kill(r);
     else
	  return ralloc(s);
}

/* killregs -- forget all cached values */
void killregs(void) {
     reg r;

#ifdef DEBUG
     if (dflag > 2) printf("\tKillregs\n");
#endif

     for_regs (r)
	  uncache(r);
}

/* kill -- forget a register and all others related to it */
reg kill(reg r) {
     reg r1;

#ifdef DEBUG
     if (dflag > 2) printf("\tKill %s\n", vm_regname(r->r_reg));
#endif

     uncache(r);

     for_regs (r1) {
	  if (cached(r1) && r1->r_value.v_reg == r)
	       uncache(r1);
     }

     return r;
}

/* init_regs -- reset registers for new procedure */
void init_regs(void) {
     reg r;

     if (regs == NULL) setup_regs();

     for_regs (r) {
	  r->r_refct = 0;
	  uncache(r);
     }
}
