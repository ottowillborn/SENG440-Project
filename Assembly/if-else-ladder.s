	.arch armv7-a
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
	.arch armv7-a
	.syntax unified
	.arm
	.fpu vfpv3-d16
	.type	ulaw_compress, %function
ulaw_compress:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mvn	r1, r0
	eor	r3, r0, r0, asr #31
	sub	r3, r3, r0, asr #31
	add	r3, r3, #33
	uxth	r3, r3
	tst	r3, #4096
	lsr	r1, r1, #31
	ubfxne	r3, r3, #8, #4
	movne	r0, #112
	bne	.L3
	tst	r3, #2048
	ubfxne	r3, r3, #7, #4
	movne	r0, #96
	bne	.L3
	tst	r3, #1024
	ubfxne	r3, r3, #6, #4
	movne	r0, #80
	bne	.L3
	tst	r3, #512
	ubfxne	r3, r3, #5, #4
	movne	r0, #64
	bne	.L3
	tst	r3, #256
	ubfxne	r3, r3, #4, #4
	movne	r0, #48
	bne	.L3
	tst	r3, #128
	ubfxne	r3, r3, #3, #4
	movne	r0, #32
	bne	.L3
	ands	r2, r3, #64
	movne	r0, #16
	moveq	r0, r2
	ubfxne	r3, r3, #2, #4
	ubfxeq	r3, r3, #1, #4
.L3:
	orr	r0, r0, r1, lsl #7
	orr	r3, r0, r3
	mvn	r0, r3
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
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	movw	r1, #:lower16:.LC0
	movw	r0, #:lower16:.LC1
	push	{r4, r5, r6, r7, r8, lr}
	movt	r1, #:upper16:.LC0
	sub	sp, sp, #8
	movt	r0, #:upper16:.LC1
	bl	fopen
	movw	r1, #:lower16:.LC2
	mov	r4, r0
	movw	r0, #:lower16:.LC3
	movt	r1, #:upper16:.LC2
	movt	r0, #:upper16:.LC3
	bl	fopen
	movw	r1, #:lower16:.LC2
	mov	r5, r0
	movw	r0, #:lower16:.LC4
	movt	r1, #:upper16:.LC2
	movt	r0, #:upper16:.LC4
	bl	fopen
	clz	r2, r5
	cmp	r4, #0
	lsr	r2, r2, #5
	moveq	r2, #1
	cmp	r0, #0
	moveq	r2, #1
	cmp	r2, #0
	bne	.L22
	mov	r1, #44
	mov	r6, r0
	mov	r0, r4
	bl	fseek
	bl	clock
	mov	r7, r0
	b	.L17
.L20:
	ldrsh	r0, [sp, #4]
	bl	ulaw_compress
	mov	r3, r5
	strb	r0, [sp, #3]
	mov	r2, r8
	mov	r1, r8
	add	r0, sp, #3
	bl	fwrite
	ldrb	r2, [sp, #3]	@ zero_extendqisi2
	add	r0, sp, #6
	mvn	r2, r2
	uxtb	r2, r2
	and	r3, r2, #15
	ubfx	r1, r2, #4, #3
	add	r1, r1, #3
	orr	r3, r3, #16
	lsl	r3, r3, r1
	lsrs	r2, r2, #7
	uxth	r3, r3
	rsb	ip, r3, #33
	subne	r3, r3, #33
	sxthne	ip, r3
	sxtheq	ip, ip
	mov	r2, #1
	mov	r3, r6
	mov	r1, #2
	strh	ip, [sp, #6]	@ movhi
	bl	fwrite
.L17:
	mov	r3, r4
	mov	r2, #1
	mov	r1, #2
	add	r0, sp, #4
	bl	fread
	cmp	r0, #1
	mov	r8, r0
	beq	.L20
	bl	clock
	mov	r8, r0
	mov	r0, r4
	bl	fclose
	mov	r0, r5
	bl	fclose
	mov	r0, r6
	bl	fclose
	movw	r0, #:lower16:.LC6
	sub	r7, r8, r7
	movt	r0, #:upper16:.LC6
	bl	puts
	vmov	s15, r7	@ int
	vldr.64	d6, .L23
	vcvt.f64.s32	d7, s15
	movw	r0, #:lower16:.LC7
	vdiv.f64	d7, d7, d6
	movt	r0, #:upper16:.LC7
	vmov	r2, r3, d7
	bl	printf
	mov	r0, #0
.L14:
	add	sp, sp, #8
	@ sp needed
	pop	{r4, r5, r6, r7, r8, pc}
.L22:
	movw	r0, #:lower16:.LC5
	movt	r0, #:upper16:.LC5
	bl	perror
	mov	r0, #1
	b	.L14
.L24:
	.align	3
.L23:
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
	.ascii	"Done compressing and decompressing\000"
	.space	1
.LC7:
	.ascii	"Elapsed time: %.6f seconds\012\000"
	.ident	"GCC: (GNU) 8.2.1 20180801 (Red Hat 8.2.1-2)"
	.section	.note.GNU-stack,"",%progbits
