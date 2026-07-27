print
	move.w	d2,d4
	mulu	d3,d4

	mulu	d4,d1

	add.l	d1,d0
	add.l	d0,a1			screen start address
	moveq	#0,d1

	move.w	d2,d6
	mulu	d3,d6

	subq.w	#1,d3
	move.w	d3,d4
	move.w	d2,d7

	moveq	#0,d0
print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2

char.loop
	move.b	(a3)+,(a2)		copy byte of character, bitplane 1
	tst.w	d3
	beq.s	Next.Line

Number.Of.Planes
	move.b	d1,(a2,d7)
	add.w	d2,d7
	dbra	d3,Number.Of.Planes
	move.w	d4,d3
	move.w	d2,d7

Next.Line
	lea	(a2,d6),a2		next screen line
	dbra	d0,char.loop

	addq.l	#1,a1			next column
	bra.s	print.loop

end.print
	rts



; Spectrum font, characters 32-126, each 8*8 pixels

font	incbin	demo.font8by8

;	incbin	genam:misc/binary/Speccy.Font
