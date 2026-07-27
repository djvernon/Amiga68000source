make.decimal
	andi.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros
make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#" ",(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	addi.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmpi.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	addi.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	clr.b	(a0)			end with zero
	rts



decimal.text
	ds.b	6
	dc.b	0,0


powers.of.ten
	dc.l	1000000000,100000000,10000000,1000000
	dc.l	100000,10000,1000,100,10,1



make.decimal.long			; d0.l = signed number
	lea	powers.of.ten(pc),a0
	lea	decimal.text.long(pc),a1
	moveq	#10-1,d3		do 10 digits
	moveq	#0,d4			replace leading zeros with spaces
	moveq	#'0',d5

next.decimal.digit
	moveq	#'0',d1
	move.l	(a0)+,d2		get next power of ten

calculate.digit
	sub.l	d2,d0
	bcs.s	digit.done
	addq.b	#1,d1			next digit up
	bra.s	calculate.digit

digit.done
	add.l	d2,d0

	tst.b	d4			if flag is set
	bne.s	save.digit.long		then save all digits

	cmp.b	d5,d1
	bne.s	digit.not.zero

	moveq	#' ',d1			replace zero digit with a space
	bra.s	save.digit.long

digit.not.zero
	st	d4			don't miss off any more zeros

save.digit.long
	move.b	d1,(a1)+
	dbra	d3,next.decimal.digit
	rts



decimal.text.long
	ds.b	11
	dc.b	0,0
	even
