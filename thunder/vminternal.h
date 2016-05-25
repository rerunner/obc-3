/*
 * vminternal.h
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

#define pc vm_pc
#define byte vm_byte
#define word vm_word
#define fmt_val vm_fmt_val
#define fmt_lab vm_fmt_lab

struct _vmreg {
     const char *vr_name;
     int vr_reg;
};

#define BRANCH 1
#define CASELAB 2

extern code_addr pc;

void vm_space(int space);
void byte(int x);
void word(int x);
code_addr vm_prelude(int n);
void vm_postlude(void);
void vm_chain(code_addr p);
void vm_reset(void);
code_addr vm_getpc(void);
void vm_patch(code_addr loc, code_addr lab);
void vm_branch(int kind, code_addr loc, vmlabel lab);
code_addr vm_jtable(int n);
void vm_panic(const char *fmt, ...);
void vm_unknown(const char *where, operation op);

#ifdef DEBUG
void vm_debug1(int op, int nrands, ...);
void vm_debug2(const char *fmt, ...);
char *fmt_val(int v);
char *fmt_lab(vmlabel lab);
#else
#define vm_debug1(op, nrands, ...)
#define vm_debug2(fmt, ...)
#endif
