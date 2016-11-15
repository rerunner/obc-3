/*
 * codebuf.c
 * 
 * This file is part of the Oxford Oberon-2 compiler
 * Copyright (c) 2006--2016 J. M. Spivey
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

#include "vm.h"
#include "vminternal.h"
#include "config.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef USE_MPROTECT
#include <sys/mman.h>
#endif

#define MARGIN 32	        /* Safety margin for swiching buffers */
#define MIN 128                 /* Min space at beginning of routine */

code_addr pc;                   /* Current assembly location */
static const char *proc_name;
static code_addr proc_beg, codebuf, limit;

/* byte -- contribute a byte to the object code */
void byte(int x) {
     *pc++ = x & 0xff;
}

/* word -- contribute a whole word */
void word(int x) {
     * (int *) pc = x;
     pc += 4;
}

/* vm_getpc -- fetch current pc value */
code_addr vm_getpc(void) {
     vm_space(0);
     return pc;
}

/* vm_jtable -- allocate space for jump table */
code_addr vm_jtable(int n) {
     vm_space(n * sizeof(code_addr));
     limit -= n * sizeof(code_addr);
     return limit;
}

#ifdef USE_FLUSH
#define FRAGS 16
static code_addr fragbeg[FRAGS], fragend[FRAGS];
static int nfrags;
#endif

/* vm_begin -- begin new procedure */
code_addr vm_begin(const char *name, int n) {
     proc_name = name;
     vm_space(MIN);
     proc_beg = pc;

#ifdef USE_FLUSH
     nfrags = 0; fragbeg[0] = pc;
#endif

     return vm_prelude(n);
}

/* vm_space -- ensure space in code buffer */
void vm_space(int space) {
     if (codebuf == NULL || pc + space > limit - MARGIN) {
	  code_addr p = (code_addr) vm_alloc(PAGESIZE);
#ifdef USE_MPROTECT
	  if (mprotect(p, PAGESIZE, PROT_READ|PROT_WRITE|PROT_EXEC) < 0) {
	       perror("mprotect failed");
	       exit(2);
	  }
#endif

	  if (codebuf != NULL) vm_chain(p);

#if USE_FLUSH
	  fragend[nfrags++] = pc;
	  if (nfrags >= FRAGS) vm_panic("too many frags");
	  fragbeg[nfrags] = p;
#endif

	  codebuf = p; limit = p + PAGESIZE;
	  pc = codebuf;
     }
}

#ifdef USE_FLUSH
/* vm_flush -- clear code from data cache */
static void vm_flush(void) {
     int i;

     // This is probably ARM-specific
     for (i = 0; i < nfrags; i++)
	  __clear_cache(fragbeg[i], fragend[i]);
}
#endif

/* vm_end -- finish a procedure */
void vm_end(void) {
     vm_postlude();

     if (vm_debug > 3) {
	  // This is broken if we switched pages in mid-stream.
          char buf[128];
          strcpy(buf, proc_name);
          strcat(buf, ".vmdump");
          FILE *fp = fopen(buf, "wb");
          printf("Dumping\n");
          if (fp == NULL) return;
          fwrite(proc_beg, 1, pc-proc_beg, fp);
          fclose(fp);
     }

#ifdef USE_FLUSH
     fragend[nfrags++] = pc;
     vm_flush();
#endif
}

