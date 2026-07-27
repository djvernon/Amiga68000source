;"""""""""""""""""
;" LINE ROUTINES "
;"		 "
;"""""""""""""""""

; d0 = x1, d1 = y1, d2 = x2, d3 = y2

clip.line
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.not.off.left

; x1 is off left of screen

	tst.w	d2			x2
	bmi.s	end.clip.line		if line is off left of screen

; clip line to left edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	muls	d0,d5			x1 * (y2-y1)
	divs	d4,d5			(x1 * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - ((x1 * (y2-y1)) / (x2-x1))
	moveq	#0,d0			x1 = 0
	bra.s	x1.clipped

end.clip.line
	rts




x1.not.off.left
	cmp.w	d6,d0			x1
	ble.s	x1.clipped

; x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	end.clip.line		if line is off right of screen

; clip line to right edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d6,d0			x1-max
	muls	d0,d5			(x1-max) * (y2-y1)
	divs	d4,d5			((x1-max) * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - (((x1-max) * (y2-y1)) / (x2-x1))
	move.w	d6,d0			x1 = max




x1.clipped
	tst.w	d1			y1
	bpl.s	y1.not.off.top

; y1 is off top of screen

	tst.w	d3			y2
	bmi.s	end.clip.line		if line is off top of screen

; clip line to top edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y2
	muls	d1,d4			y1 * (x2-x1)
	divs	d5,d4			(y1 * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - ((y1 * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	moveq	#0,d1			y1 = 0

	cmp.w	d6,d0
	ble.s	y1.clipped		if new x1 is not off right of screen

end.clip.line2
	rts




y1.not.off.top
	cmp.w	d7,d1			y1
	ble.s	y1.clipped

; y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	end.clip.line2		if line is off bottom of screen

; clip line to bottom edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d7,d1			y1-max
	muls	d1,d4			(y1-max) * (x2-x1)
	divs	d5,d4			((y1-max) * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - (((y1-max) * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	cmp.w	d6,d0
	bgt.s	end.clip.line2		if new x1 is off right of screen

	move.w	d7,d1			y1 = max




y1.clipped
	tst.w	d2			x2
	bpl.s	x2.not.off.left

; x2 is off left of screen

; clip line to left edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d2,d5			x2 * (y1-y2)
	divs	d4,d5			(x2 * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - ((x2 * (y1-y2)) / (x1-x2))
	moveq	#0,d2			x2 = 0
	bra.s	x2.clipped




x2.not.off.left
	cmp.w	d6,d2			x2
	ble.s	x2.clipped

; x2 is off right of screen

; clip line to right edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d6,d2			x2-max
	muls	d2,d5			(x2-max) * (y1-y2)
	divs	d4,d5			((x2-max) * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - (((x2-max) * (y1-y2)) / (x1-x2))
	move.w	d6,d2			x2 = max




x2.clipped
	tst.w	d3			y2
	bpl.s	y2.not.off.top

; y2 is off top of screen

; clip line to top edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d3,d4			y2 * (x1-x2)
	divs	d5,d4			(y2 * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - ((y2 * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	moveq	#0,d3			y2 = 0

	cmp.w	d6,d2
	ble.s	draw.line		if new x2 is not off right of screen

end.clip.line3
	rts




y2.not.off.top
	cmp.w	d7,d3			y2
	ble.s	draw.line

; y2 is off bottom of screen

; clip line to bottom edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d7,d3			y2-max
	muls	d3,d4			(y2-max) * (x1-x2)
	divs	d5,d4			((y2-max) * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - (((y2-max) * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	cmp.w	d6,d2
	bgt.s	end.clip.line3		if new x2 is off right of screen

	move.w	d7,d3			y2 = max




(Taken from 3D.s, then line number 184 corrected)

Notes about Blitter lines
-------------------------
Start address doesn't have to be in even bytes
bltdmod doesn't need to be set
bltalwm doesn't need to be set
Blitter is no faster when only drawing one point per raster line
