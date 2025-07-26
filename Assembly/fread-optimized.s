	.arch armv7-a
	.arch_extension virt
	.arch_extension idiv
	.arch_extension sec
	.arch_extension mp
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 2
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"main.c"
	.text
	.align	2
	.global	ulaw_compress
	.arch armv7ve
	.syntax unified
	.arm
	.fpu vfpv3-d16
	.type	ulaw_compress, %function
ulaw_compress:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	eor	r2, r0, r0, asr #31
	sub	r2, r2, r0, asr #31
	add	r2, r2, #33
	uxth	r2, r2
	clz	r3, r2
	mvn	r1, r0
	rsb	r3, r3, #26
	uxtb	r3, r3
	add	ip, r3, #3
	lsr	r1, r1, #31
	lsl	r0, r3, #4
	asr	r2, r2, ip
	orr	r0, r0, r1, lsl #7
	and	r2, r2, #15
	orr	r0, r0, r2
	mvn	r0, r0
	uxtb	r0, r0
	bx	lr
	.size	ulaw_compress, .-ulaw_compress
	.align	2
	.global	ulaw_decompress
	.syntax unified
	.arm
	.fpu vfpv3-d16
	.type	ulaw_decompress, %function
ulaw_decompress:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mvn	r0, r0
	uxtb	r3, r0
	and	r0, r3, #15
	ubfx	r2, r3, #4, #3
	add	r2, r2, #3
	orr	r0, r0, #16
	lsl	r0, r0, r2
	lsrs	r3, r3, #7
	uxth	r0, r0
	rsbeq	r0, r0, #33
	subne	r0, r0, #33
	sxth	r0, r0
	bx	lr
	.size	ulaw_decompress, .-ulaw_decompress
	.section	.text.startup,"ax",%progbits
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfpv3-d16
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 20480
	@ frame_needed = 0, uses_anonymous_args = 0
	movw	r1, #:lower16:.LC0
	movw	r0, #:lower16:.LC1
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	sub	sp, sp, #20480
	sub	sp, sp, #4
	movt	r1, #:upper16:.LC0
	movt	r0, #:upper16:.LC1
	bl	fopen
	movw	r1, #:lower16:.LC2
	mov	r5, r0
	movw	r0, #:lower16:.LC3
	movt	r1, #:upper16:.LC2
	movt	r0, #:upper16:.LC3
	bl	fopen
	movw	r1, #:lower16:.LC2
	mov	r6, r0
	movw	r0, #:lower16:.LC4
	movt	r1, #:upper16:.LC2
	movt	r0, #:upper16:.LC4
	bl	fopen
	clz	r3, r6
	cmp	r5, #0
	lsr	r3, r3, #5
	moveq	r3, #1
	cmp	r0, #0
	movne	r2, r3
	moveq	r2, #1
	cmp	r2, #0
	bne	.L16
	mov	r1, #44
	mov	r8, r0
	mov	r0, r5
	bl	fseek
	bl	clock
	movw	r7, #:lower16:.LC6
	mov	r9, r0
	movt	r7, #:upper16:.LC6
.L9:
	mov	r2, #4096
	mov	r3, r5
	mov	r1, #2
	add	r0, sp, r2
	bl	fread
	subs	r4, r0, #0
	beq	.L17
	mov	r0, r7
	bl	puts
	mov	lr, sp
	add	r0, sp, #4096
	add	ip, sp, #12288
	add	r10, r0, r4, lsl #1
.L10:
	ldrsh	fp, [r0], #2
	eor	r1, fp, fp, asr #31
	sub	r1, r1, fp, asr #31
	add	r1, r1, #33
	uxth	r1, r1
	clz	r2, r1
	mvn	fp, fp
	rsb	r2, r2, #26
	uxtb	r2, r2
	add	r3, r2, #3
	lsr	fp, fp, #31
	asr	r1, r1, r3
	lsl	r2, r2, #4
	orr	r2, r2, fp, lsl #7
	and	r1, r1, #15
	orr	r1, r2, r1
	uxtb	r3, r1
	mvn	r2, r3
	and	r1, r3, #15
	ubfx	fp, r3, #4, #3
	orr	r1, r1, #16
	add	fp, fp, #3
	lsrs	r3, r3, #7
	lsl	r3, r1, fp
	uxth	r3, r3
	rsb	r1, r3, #33
	strb	r2, [lr], #1
	sub	r3, r3, #33
	bne	.L11
	cmp	r10, r0
	strh	r1, [ip], #2	@ movhi
	bne	.L10
.L13:
	mov	r3, r6
	mov	r2, r4
	mov	r0, sp
	mov	r1, #1
	bl	fwrite
	mov	r3, r8
	mov	r2, r4
	add	r0, sp, #12288
	mov	r1, #2
	bl	fwrite
	b	.L9
.L11:
	cmp	r10, r0
	strh	r3, [ip], #2	@ movhi
	bne	.L10
	b	.L13
.L17:
	bl	clock
	mov	r7, r0
	mov	r0, r5
	bl	fclose
	mov	r0, r6
	bl	fclose
	mov	r0, r8
	bl	fclose
	movw	r0, #:lower16:.LC7
	sub	r7, r7, r9
	movt	r0, #:upper16:.LC7
	bl	puts
	vmov	s15, r7	@ int
	vldr.64	d6, .L18
	vcvt.f64.s32	d7, s15
	movw	r0, #:lower16:.LC8
	vdiv.f64	d7, d7, d6
	movt	r0, #:upper16:.LC8
	vmov	r2, r3, d7
	bl	printf
	mov	r0, r4
.L6:
	add	sp, sp, #20480
	add	sp, sp, #4
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}
.L16:
	movw	r0, #:lower16:.LC5
	movt	r0, #:upper16:.LC5
	bl	perror
	mov	r0, #1
	b	.L6
.L19:
	.align	3
.L18:
	.word	0
	.word	1093567616
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",%progbits,1
	.align	2
.LC0:
	.ascii	"rb\000"
	.space	1
.LC1:
	.ascii	"audio_sample.wav\000"
	.space	3
.LC2:
	.ascii	"wb\000"
	.space	1
.LC3:
	.ascii	"compressed_output.ulaw\000"
	.space	1
.LC4:
	.ascii	"decompressed.pcm\000"
	.space	3
.LC5:
	.ascii	"File error\000"
	.space	1
.LC6:
	.ascii	"iter\000"
	.space	3
.LC7:
	.ascii	"Done compressing and decompressing\000"
	.space	1
.LC8:
	.ascii	"Elapsed time: %.6f seconds\012\000"
	.ident	"GCC: (GNU) 8.2.1 20180801 (Red Hat 8.2.1-2)"
	.section	.note.GNU-stack,"",%progbits
