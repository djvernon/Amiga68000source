

	move.l	#123456,d0
	bsr	sqrt
	rts


* Disassembly of $6540 - $67f2
*
* d0.l = number
* returns with d0.w = square root of number
*
* doesn't appear to be used by program
* slightly quicker than the other routine (sqrt1.s)

sqrt	tst.l	d0
	beq.s	sqrt3

	cmp.l	#$10000,d0
	bge	sqrt.long

	cmp.w	#625,d0
	bhi.s	sqrt.word

	move.l	d2,-(sp)
	moveq	#-1,d2

sqrt1	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bmi.s	sqrt2
	addq.w	#2,d2
	sub.w	d2,d0
	bpl.s	sqrt1

sqrt2	asr.w	#1,d2
	move.w	d2,d0
	move.l	(sp)+,d2
sqrt3	rts


sqrt.word
	movem.l	d1-d3,-(sp)
	clr.w	d1
	clr.w	d2
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt4
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt4	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt5
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt5	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt6
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt6	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt7
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt7	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt8
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt8	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt9
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt9	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtA
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtA	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtB
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtB	move.w	d2,d0
	movem.l	(sp)+,d1-d3
	rts


sqrt.long
	movem.l	d1-d3,-(sp)
	moveq	#0,d1
	moveq	#0,d2
	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtC
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtC	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtD
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtD	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtE
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtE	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrtF
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrtF	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt10
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt10	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt11
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt11	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt12
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt12	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt13
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt13	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt14
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt14	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt15
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt15	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt16
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt16	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt17
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt17	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt18
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt18	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt19
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1

sqrt19	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.l	d1,d1
	add.w	d2,d2
	move.l	d2,d3
	add.w	d3,d3
	cmp.l	d3,d1
	bls.s	sqrt1A
	addq.w	#1,d2
	addq.w	#1,d3
	sub.l	d3,d1

sqrt1A	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d1,d1
	add.w	d2,d2
	move.l	d2,d3
	add.l	d3,d3
	cmp.l	d3,d1
	bls.s	sqrt1B
	addq.w	#1,d2

sqrt1B	move.l	d2,d0
	movem.l	(sp)+,d1-d3
	rts

