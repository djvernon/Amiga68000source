* ORIGINAL PLANAR METHOD
; source long in d0
	move.b	d0,(a1)+			8
	move.b	(a5,d0.w),(a2)+		18
	swap	d0					4
	move.b	d0,(a3)+			8
	move.b	(a5,d0.w),(a4)+		18

; source long in d0
	move.b	d0,(a1)+			8
	move.b	(a5,d0.w),(a2)+		18
	swap	d0					4
	move.b	d0,(a3)+			8
	move.b	(a5,d0.w),(a4)+		18
; total 112


* OR ARTE METHOD
; source long in d0
	move.w	d0,d1		4
	move.b	d0,d2		4
	move.w	d2,(a0)+	8
	swap	d0			4
	move.b	d0,d3		4
	move.w	d3,(a2)+	8

; source long in d0
	move.w	d3,d2		4
	move.b	d3,d1		4
	move.w	d1,(a1)+	8
	swap	d3			4
	move.b	d3,d0		4
	move.w	d0,(a3)+	8
; total 64
; advantages:
;   almost twice as fast as original method
; disadvantages:
;   odd/even planes must be offset by 8 pixels
;   garbage bytes at start/end of rows


OTHER SPRITE SCALING IDEAS
--------------------------
only need to create horizontal steps once (or could create for each width at start of program)

plot 8 pixels (long per pixel):
	move.l	(an),d0		12
	add.w	(am)+,an	12?	-|
	add.l	d0,d0		8	 |- all * 7
	or.l	(an),d0		14	-|

	move.b	d0,(a1)+			8
	move.b	(a5,d0.w),(a2)+		18
	swap	d0					4
	move.b	d0,(a3)+			8
	move.b	(a5,d0.w),(a4)+		18
