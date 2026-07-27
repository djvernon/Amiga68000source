

	move.l	#123456,d0
	bsr	sqrt
	rts


* Disassembly of $6b32 - $6be2
*
* d0.l = number
* returns with d0.w = square root of number

sqrt	tst.l	d0
	beq.s	sqrt2

	cmp.l	#$10000,d0
	bhi.s	sqrt.long

	cmp.w	#1573,d0
	bhi.s	sqrt.word

	move.w	d1,-(sp)
	move.w	#-1,d1

sqrt1	addq.w	#2,d1
	sub.w	d1,d0
	bpl.s	sqrt1

	asr.w	#1,d1
	move.w	d1,d0
	move.w	(sp)+,d1
sqrt2	rts


sqrt.word
	movem.w	d1-d4,-(sp)
	move.w	#8-1,d4
	clr.w	d1
	clr.w	d2

sqrt3	add.w	d0,d0
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
sqrt4	dbra	d4,sqrt3

	move.w	d2,d0
	movem.w	(sp)+,d1-d4
	rts


sqrt.long
	movem.l	d1-d4,-(sp)
	moveq	#14-1,d4
	moveq	#0,d1
	moveq	#0,d2

sqrt5	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.w	d1,d1
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	cmp.w	d3,d1
	bls.s	sqrt6
	addq.w	#1,d2
	addq.w	#1,d3
	sub.w	d3,d1
sqrt6	dbra	d4,sqrt5

	add.l	d0,d0
	addx.w	d1,d1
	add.l	d0,d0
	addx.l	d1,d1
	add.w	d2,d2
	move.l	d2,d3
	add.w	d3,d3
	cmp.l	d3,d1
	bls.s	sqrt7
	addq.w	#1,d2
	addq.w	#1,d3
	sub.l	d3,d1

sqrt7	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d1,d1
	add.w	d2,d2
	move.l	d2,d3
	add.l	d3,d3
	cmp.l	d3,d1
	bls.s	sqrt8
	addq.w	#1,d2

sqrt8	move.w	d2,d0
	movem.l	(sp)+,d1-d4
	rts

