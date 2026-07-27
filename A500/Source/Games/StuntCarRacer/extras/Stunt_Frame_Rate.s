*""""""""""""""""""""""
*" FRAME RATE ROUTINE "
*"		      "
*""""""""""""""""""""""

frames.per.sec
	move.b	$bfda00.l,d1
	move.b	$bfd900.l,d1
	lsl.w	#8,d1
	move.b	$bfd800.l,d1

	move.w	d1,d0
	sub.w	old.pulses(pc),d0
	move.w	d1,old.pulses

	move.l	#156250,d1
	divu	d0,d1
	and.l	#$ffff,d1

	move.b	#31,d0
	jsr	print.character
	move.b	#21,d0			column
	jsr	print.character
	move.b	#18,d0			row
	jsr	print.character

	move.b	#0,print.fine.x
	move.b	#0,print.fine.y
	move.b	#'0',d2

	moveq	#100,d4
	move.l	d1,d3
	divu	d4,d3
	move.b	d3,d0
	add.b	d2,d0
	jsr	print.character
	mulu	d4,d3
	sub.l	d3,d1

	moveq	#10,d4
	move.l	d1,d3
	divu	d4,d3
	move.b	d3,d0
	add.b	d2,d0
	jsr	print.character
	mulu	d4,d3
	sub.l	d3,d1

	move.b	#'.',d0
	jsr	print.character

	move.b	d1,d0
	add.b	d2,d0
	jmp	print.character


old.pulses
	dc.w	0


