/*
  Copyright 2002, 2015 Yoshinori Sato <ysato@users.sourceforge.jp>
*/

#include <sys/syscall.h>

#ifdef __H8300S__
	.h8300s
#else
	.h8300h
#endif
	.text
	.align 2
	.globl	__vfork
	.hidden	__vfork
	.type	__vfork,@function
__vfork:
#ifdef __NR_vfork
	mov.l	@sp+, er1
	sub.l	er0,er0
	mov.b	#__NR_vfork,r0l
	trapa	#0

	mov.l	#-4096, er2
	cmp.l 	er0,er2
	bcs     fix_errno
	jmp	@er1		/* don't return, just jmp directly */
fix_errno:
	neg.l	er0
# if !defined(__PIC__)
	mov.l	er0,@_errno
# else
	mov.l	@(_errno@GOTOFF,er5),er2
	mov.l	er0,@er2
# endif
	sub.l	er0,er0
	dec.l	#1,er0
	jmp	@er1		/* don't return, just jmp directly */
#else
	mov.l	@sp+,er2		/* er2 = return address */
	mov.l	#vfork_args,er1
	sub.l	er0,er0
	mov.b	#__NR_clone,r0l
	trapa	#0
	mov.l	#-4096,er1
	cmp.l	er0,er1
	bcc	done
	neg.l	er0
# if !defined(__PIC__)
	mov.l	er0,@errno
# else
	mov.l	@(errno@GOTOFF,er5),er1
	mov.l	er0,@er1
# endif
	sub.l	er0,er0
	dec.l	#1,er0
done:
	jmp	@er2

vfork_args:
	.long	0x00004111	/* CLONE_VFORK | CLONE_VM | SIGCHLD */
	.long	0
	.long	0
	.long	0
	.long	0
#endif

weak_alias(__vfork,vfork)
libc_hidden_def(vfork)
	.end
