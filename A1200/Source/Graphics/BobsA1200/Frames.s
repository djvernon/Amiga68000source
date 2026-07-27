frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter,d1		get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a2
	move.b	(a0),(a2)
	move.b	#".",-(a2)		insert decimal point
	move.w	-(a0),-(a2)
	rts

old.counter
	dc.w	0


frames.text
	dc.b	"F/S     ",0
	even

