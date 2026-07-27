	org	$400




XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2




	move.w	#$01ff,dmacon(a6)	disable all DMA

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)

	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0
set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours




;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	copper1(pc),cop1lc(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)




;"""""""""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 2 AND 3 INTERRUPTS "
;"				       "
;"""""""""""""""""""""""""""""""""""""""

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	#rte.ins,$14.w		set zero-division to rte instruction

	move.l	#new.level2,$68.w

	move.l	#new.level3,$6c.w

	lea	$68900,sp
	move.w	#$2000,sr		supervisor mode, all interrupts
	move.w	#$c018,intena(a6)	enable copper and level2 interrupt




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0		count
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			bytes per line
	lea	y.table(pc),a0
y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

main.loop
	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	bsr	calc.sin.cos.values

	lea	king.tiger.base(pc),a0
	bsr	draw.3d.object

	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	add.w	turret.y.angle(pc),d1
	and.w	#$7fe,d1
	bsr	calc.sin.cos.values

	lea	king.tiger.top(pc),a0
	bsr	draw.3d.object

	bsr	keyboard.requests

	bsr	update.screens
	bsr	clear

	bra.s	main.loop




;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level2
	movem.l	d0/a0,-(sp)
	move.w	#$8,intreq(a6)

	lea	$bfe001,a0

	btst	#3,$d00(a0)		read CIA-A ICR
	beq.s	end.level2		if key not pressed

	move.b	$c00(a0),d0		get raw key code
	not.b	d0
	ror.b	#1,d0
	move.b	d0,raw.key.code

	bset	#6,$e00(a0)		set SP to output

	moveq	#54,d0
hand.shake
	dbra	d0,hand.shake		output handshake pulse

	bclr	#6,$e00(a0)		set SP back to input


; now check for special key presses

	move.b	raw.key.code(pc),d0

	cmp.b	#$46,d0			DELETE
	bne.s	check.help
	not.b	frames.requested
	bra.s	end.level2

check.help
	cmp.b	#$5f,d0			HELP
	bne.s	end.level2
	not.b	palette.requested

end.level2
	movem.l	(sp)+,d0/a0
rte.ins	rte




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d1/a0,-(sp)
	move.w	#$10,intreq(a6)

	lea	mouse.data(pc),a0

	move.b	$b(a6),d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x(pc),d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$a(a6),d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y(pc),d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y

	bsr.s	set.x.y.z.angles

	movem.l	(sp)+,d0-d1/a0
	rte



set.x.y.z.angles
	lea	mouse.data(pc),a0
	btst	#2,potgor(a6)		right mouse button
	beq.s	right.pressed

	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.z.angle		update z angle
	and.w	#$7fe,base.z.angle

	move.b	(a0),d0			mouse y
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.x.angle		update x angle
	and.w	#$7fe,base.x.angle
	rts



right.pressed
	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.y.angle		update y angle
	and.w	#$7fe,base.y.angle

	move.b	(a0),d0			mousey
	ext.w	d0
	add.w	d0,z.offset		update z distance
	rts




;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT "
;"					"
;""""""""""""""""""""""""""""""""""""""""

clear	btst	#6,dmaconr(a6)
	bne.s	clear
	clr.w	bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1(pc),bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)	width = 20 words
	rts




calc.sin.cos.values
	lea	sin.cos.values(pc),a0

	lea	cosine(pc),a1
	move.w	(a1,d0.w),d3		cosx
	move.w	(a1,d1.w),d4		cosy
	move.w	(a1,d2.w),d5		cosz

	lea	sine(pc),a1
	move.w	(a1,d0.w),d0		sinx
	move.w	(a1,d1.w),d1		siny
	move.w	(a1,d2.w),d2		sinz

	move.w	d4,d6			cosy
	muls	d5,d6			cosy.cosz
	move.w	d0,d7			sinx
	muls	d1,d7			sinx.siny
	add.l	d7,d7
	swap	d7
	move.w	d7,a1			sinx.siny - save for later
	muls	d2,d7			sinx.siny.sinz
	sub.l	d7,d6			cosy.cosz - sinx.siny.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.COSZ - SINX.SINY.SINZ

	move.w	d3,d6			cosx
	muls	d2,d6			cosx.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSX.SINZ (but subtracted)

	move.w	d1,d6			siny
	muls	d5,d6			siny.cosz
	move.w	d0,d7			sinx
	muls	d4,d7			sinx.cosy
	add.l	d7,d7
	swap	d7
	move.w	d7,a2			sinx.cosy - save for later
	muls	d2,d7			sinx.cosy.sinz
	add.l	d7,d6			siny.cosz + sinx.cosy.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		SINY.COSZ + SINX.COSY.SINZ

	move.w	d4,d6			cosy
	muls	d2,d6			cosy.sinz
	move.w	a1,d7			sinx.siny
	muls	d5,d7			sinx.siny.cosz
	add.l	d7,d6			cosy.sinz + sinx.siny.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.SINZ + SINX.SINY.COSZ

	move.w	d3,d6			cosx
	muls	d5,d6			cosx.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSX.COSZ

	muls	d1,d2			siny.sinz
	move.w	a2,d6			sinx.cosy
	muls	d5,d6			sinx.cosy.cosz
	sub.l	d6,d2			siny.sinz - sinx.cosy.cosz
	add.l	d2,d2
	swap	d2
	move.w	d2,(a0)+		SINY.SINZ - SINX.COSY.COSZ

	muls	d3,d1			cosx.siny
	add.l	d1,d1
	swap	d1
	move.w	d1,(a0)+		COSX.SINY (but subtracted)

	move.w	d0,(a0)+		SINX

	muls	d3,d4			cosx.cosy
	add.l	d4,d4
	swap	d4
	move.w	d4,(a0)			COSX.COSY

	rts




line.colour.masks
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000
	dc.w	$0000,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000
	dc.w	$0000,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000
	dc.w	$0000,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$0000
	dc.w	$0000,$0000,$0000,$ffff
	dc.w	$ffff,$0000,$0000,$ffff
	dc.w	$0000,$ffff,$0000,$ffff
	dc.w	$ffff,$ffff,$0000,$ffff
	dc.w	$0000,$0000,$ffff,$ffff
	dc.w	$ffff,$0000,$ffff,$ffff
	dc.w	$0000,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff



component.priority
	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get coordinate offsets
	move.w	(a0)+,d1
	move.l	(a0)+,d2		get component addresses
	move.l	(a0)+,d3
	move.w	(a1,d0.w),d0		get z value
	cmp.w	(a1,d1.w),d0		subtract other z value
	bge.s	correct.order
	exg	d2,d3

correct.order
	move.l	d2,a0
	move.l	d3,-(sp)
	bsr.s	draw.3d.object

	move.l	(sp)+,a0
	bsr.s	draw.3d.object
	rts



vector.colour
	lea	line.colour.masks(pc),a1
	add.w	(a0)+,a1		add offset for correct colour
	move.l	a1,line.colour		set colour for subsequent lines

vector	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get start offset
	move.w	(a0)+,d2		get end offset
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr	clip.line

	move.w	(a0)+,d0
	jmp	rotate.coords(pc,d0.w)



polygon.orientation
	lea	new.coords(pc),a1
	movem.w	(a0)+,d0-d3		get three offsets and skip value

	movem.w	(a1,d0.w),d0/d4		x1, y1
	movem.w	(a1,d1.w),d1/d5		x2, y2
	movem.w	(a1,d2.w),d2/d6		x3, y3

	sub.w	d1,d0			x1-x2
	sub.w	d5,d6			y3-y2
	sub.w	d1,d2			x3-x2
	sub.w	d5,d4			y1-y2
	muls	d0,d6			(x1-x2)*(y3-y2)
	muls	d2,d4			(x3-x2)*(y1-y2)
	sub.l	d4,d6			(x1-x2)*(y3-y2) - (x3-x2)*(y1-y2)
	bpl.s	skip.polygon		if polygon is anti-clockwise

	move.w	(a0)+,colour.times.4	get colour
	bsr	polygon

	move.w	(a0)+,d0
	jmp	rotate.coords(pc,d0.w)

skip.polygon
	add.w	d3,a0			miss out polygon data



draw.3d.object
	move.w	(a0)+,d0
	jmp	rotate.coords(pc,d0.w)
end.draw.3d.object
	rts



rotate.coords
	lea	sin.cos.values(pc),a1
	lea	new.coords(pc),a2
	add.w	(a0)+,a2		point to correct coordinates
	move.w	(a0)+,d7		count-1

rotate.loop
	movem.w	(a0)+,d0-d2		get current X, Y, Z
	move.w	d0,d3			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d0		X(cosy.cosz - sinx.siny.sinz)
	muls	(a1)+,d4		Y(cosx.sinz)
	muls	(a1)+,d5		Z(siny.cosz + sinx.cosy.sinz)
	sub.l	d4,d0
	add.l	d5,d0			rotated X

	move.w	d3,d6			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d3		X(cosy.sinz + sinx.siny.cosz)
	muls	(a1)+,d1		Y(cosx.cosz)
	muls	(a1)+,d5		Z(siny.sinz - sinx.cosy.cosz)
	add.l	d3,d1
	add.l	d5,d1			rotated Y

	muls	(a1)+,d6		X(cosx.siny)
	muls	(a1)+,d4		Y(sinx)
	muls	(a1)+,d2		Z(cosx.cosy)
	sub.l	d6,d2
	add.l	d4,d2			rotated Z

	add.l	(a1)+,d0		add X offset
	add.l	(a1)+,d1		add Y offset
	add.l	(a1),d2			add Z offset
	bmi.s	end.draw.3d.object	quit if z is negative

	lea	-26(a1),a1		18+2*4 - reset to start of values
	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0			X/Z - perspective for X
	divs	d2,d1			Y/Z - perspective for Y

	add.w	#XMID,d0		centre on screen
	add.w	#YMID,d1

	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y
	move.w	d2,(a2)+		save z

	dbra	d7,rotate.loop

	move.w	(a0)+,d0
	jmp	rotate.coords(pc,d0.w)




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
	ble.s	draw.line		if new x1 is not off right of screen

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



draw.line
	cmp.w	d2,d0			draw line using blitter
	bcs.s	x2gx1
	exg	d0,d2
	exg	d1,d3

x2gx1	sub.w	d0,d2
	sub.w	d1,d3
	add.w	d1,d1
	lea	y.table(pc),a1
	move.w	(a1,d1.w),d1
	moveq	#$f,d4
	and.w	d0,d4
	sub.w	d4,d0
	lsr.w	#3,d0
	add.w	d0,d1
	move.l	screen1(pc),a1
	add.w	d1,a1
	ror.w	#4,d4
	or.w	#$bca,d4
	swap	d4
	tst.w	d3
	bmi.s	y1gy2
	cmp.w	d2,d3
	blt.s	dxgdy
	exg	d2,d3
	move.w	#1,d4
	bra.s	dlsize

dxgdy	move.w	#$11,d4
	bra.s	dlsize

y1gy2	neg.w	d3
	cmp.w	d2,d3
	blt.s	dxgdy2
	exg	d2,d3
	move.w	#5,d4
	bra.s	dlsize

dxgdy2	move.w	#$19,d4

dlsize	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#6,d1
	addq.w	#2,d1

	add.w	d3,d3
	move.w	d3,d0
	sub.w	d2,d0
	bpl.s	nosign
	or.w	#$40,d4

nosign	add.w	d2,d2

	move.l	line.colour(pc),a2
	moveq	#40,d5

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	d3,bltbmod(a6)
	sub.w	d2,d3
	move.w	d3,bltamod(a6)
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#160,d3
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	moveq	#4-1,d2
	move.w	(a2)+,d3
	bra.s	dlstart

dlloop	add.w	d5,a1
	move.w	(a2)+,d3

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

dlstart	move.l	a1,bltcpth(a6)
	move.l	a1,bltdpth(a6)
	move.w	d0,bltaptl(a6)
	move.l	d4,bltcon0(a6)
	move.w	d3,bltbdat(a6)
	move.w	d1,bltsize(a6)
	dbra	d2,dlloop

	rts



line.colour
	dc.l	0




;""""""""""""""""""""""""""""""""""""""""
;	" THE POLYGON ROUTINE "
;	"		      "
;	"""""""""""""""""""""""

poly.line
	move.w	d4,(a1)+		save starting y

	tst.w	d2			smallest x
	bpl.s	poly.line1
	moveq	#0,d2			if off screen then set to 0

poly.line1
	move.w	d2,(a1)+		save starting x

	cmp.w	d6,d3			largest x
	ble.s	poly.line2
	move.w	d6,d3			if off screen then set to maximum

poly.line2
	move.w	d3,(a1)+		save ending x

	bra	fill



return	rts



polygon	move.w	(a0)+,d0		get number of sides
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1			4 bytes per side
	subq.w	#2,d0			count
	lea	poly.coords(pc),a2	temporary space for coords
	lea	(a2,d1.w),a4
	move.w	(a0)+,d4		get offset for first coords
	move.l	(a1,d4.w),d4		get first coords
	move.w	d4,d5			y
	move.l	d4,d2
	swap	d2			x
	move.w	d2,d3			x
	move.l	a2,a3
	move.l	d4,(a2)+
	move.l	d4,(a4)+
poly.sort
	move.w	(a0)+,d6		get offset for next coords
	move.l	(a1,d6.w),d6		get next coords

	cmp.w	d6,d4
	ble.s	poly.sort1
	move.w	d6,d4			top y
	move.l	a2,a3			address of top coords
	bra.s	poly.sort2

poly.sort1
	cmp.w	d6,d5
	bge.s	poly.sort2
	move.w	d6,d5			bottom y

poly.sort2
	move.l	d6,(a2)+
	move.l	d6,(a4)+

	swap	d6
	cmp.w	d6,d2
	ble.s	poly.sort3
	move.w	d6,d2			smallest x
	bra.s	poly.sort4

poly.sort3
	cmp.w	d6,d3			largest x
	bge.s	poly.sort4
	move.w	d6,d3

poly.sort4
	dbra	d0,poly.sort

	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d3
	bmi.s	return			quit if largest x off left

	cmp.w	d6,d2
	bgt.s	return			quit if smallest x off right

	tst.w	d5
	bmi.s	return			quit if bottom y off top

	cmp.w	d7,d4
	bgt.s	return			quit if top y off bottom

	lea	fill.coords(pc),a1

	cmp.w	d4,d5
	beq	poly.line		if smallest y = largest y

	lea	(a3,d1.w),a2		address of top coords
	move.l	#65536,a4
	move.l	#-65536,a5

	tst.w	d4
	bpl	top.y.on.screen

top.y.off.screen
	move.l	-(a2),d2		get previous coords
	tst.w	d2			y
	bmi.s	top.y.off.screen	get first coords that are on screen

	move.l	4(a2),d0		get last coords that were off screen

	move.w	d0,d4			y off
	move.w	d2,d5			y on
	sub.w	d0,d5			y on - y off
	swap	d2			x on
	swap	d0			x off
	sub.w	d0,d2			x on - x off
	muls	d2,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d0	  x off - (((x on - x off) * y off) / (y on - y off))
	swap	d0
	clr.w	d0			new starting x * 65536

	ext.l	d2			x on - x off
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (y on - y off)
	bvs.s	gradient.overflow1
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x

gradient.overflow1
	asr.l	#8,d2			x on - x off
	divs	d5,d2			/ (y on - y off)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive1
	neg.l	d5			make positive

grad.positive1
	cmp.l	a4,d5
	bge.s	grad.greater1
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater1
	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

top.y.off.screen2
	move.l	(a3)+,d1		get current coords
	tst.w	2(a3)			y
	bmi.s	top.y.off.screen2	until first coords are on screen

	move.l	(a3),d3			get first coords that are on screen

	move.w	d1,d4			y off
	move.w	d3,d5			y on
	sub.w	d1,d5			y on - y off
	swap	d3			x on
	swap	d1			x off
	sub.w	d1,d3			x on - x off
	muls	d3,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d1	  x off - (((x on -  x off) * y off) / (y on - yoff))
	swap	d1
	clr.w	d1			new ending x * 65536

	ext.l	d3			x on - x off
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (y on - y off)
	bvs.s	gradient.overflow2
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x

gradient.overflow2
	asr.l	#8,d3			x on - x off
	divs	d5,d3			/ (y on - y off)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x
	move.l	d3,d5			gradient
	bpl.s	grad.positive2
	neg.l	d5			make positive

grad.positive2
	cmp.l	a4,d5
	bge.s	grad.greater2
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater2
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	moveq	#0,d4			set starting y to 0
	move.w	d4,(a1)+		save starting y

	bra	do.poly.edges



next.y.smaller1
	cmp.l	a2,a3
	beq	bottom.of.polygon.flat	if pointers have overlapped

	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient2



next.y.smaller2
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient2



top.y.on.screen
	move.w	d4,(a1)+		save starting y

calc.end.gradient
	move.l	(a3)+,d4		get current coords

calc.end.gradient2
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller1

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow3
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	calc.start.gradient

gradient.overflow3
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

calc.start.gradient
	move.l	(a2),d4			get current coords

calc.start.gradient2
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous coords
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller2

	move.w	(a2),d2			get previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow4
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.ending.x

gradient.overflow4
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.ending.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive3

	cmp.l	a5,d5
	ble.s	grad.greater3
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater3
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

grad.positive3
	move.l	d3,d5			gradient
	bmi.s	grad.negative1

	cmp.l	a4,d5
	bge.s	grad.greater4
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater4
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

grad.negative1
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen1
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen1
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen1
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen1
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

adjust.starting.ending.x2
	move.l	d2,d5			gradient
	bmi.s	grad.negative2		if -ve than add it on

	cmp.l	a4,d5
	bge.s	grad.greater5
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater5
	asr.l	#1,d5
grad.negative2
	add.l	d5,d0			adjust starting x

	move.l	d3,d5			gradient
	bpl.s	grad.positive4		if +ve then add it on

	cmp.l	a5,d5
	ble.s	grad.greater6
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater6
	asr.l	#1,d5
	add.l	a4,d1			+ 1
grad.positive4
	add.l	d5,d1			adjust ending x



do.poly.edges
	move.w	2(a2),d5		get y value for end of starting edge

	cmp.l	a2,a3
	beq	bottom.of.polygon	if pointers have overlapped

	cmp.w	2(a3),d5
	bgt	starting.edge.longer

	beq	both.edges.equal.length

ending.edge.longer
	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges1

	subq.w	#1,d5			count

edge.loop1
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen2
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen2
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen2
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen2
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop1

skip.edges1
	move.l	(a2),d4			get current coords

calc.start.gradient3
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous y
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller3

	move.w	(a2),d2			previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow5
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x2

gradient.overflow5
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x2
	move.l	d2,d5			gradient
	bpl.s	grad.positive5

	cmp.l	a5,d5
	ble.s	grad.greater7
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater7
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

	bra.s	do.poly.edges



next.y.smaller3
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient3



grad.positive5
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen3
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen3
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen3
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen3
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d3,d1			add gradient to get next x value

	move.l	d2,d5			gradient

	cmp.l	a4,d5
	bge.s	grad.greater8
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater8
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x

	bra	do.poly.edges



starting.edge.longer
	move.w	2(a3),d5		get y value for end of ending edge

	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges2

	subq.w	#1,d5			count

edge.loop2
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen4
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen4
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen4
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen4
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop2

skip.edges2
	move.l	(a3)+,d4		get current coords

calc.end.gradient3
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller4

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x
	swap	d4			current y

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow6
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x2

gradient.overflow6
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x2
	move.l	d3,d5			gradient
	bmi.s	grad.negative3

	cmp.l	a4,d5
	bgt.s	grad.greater9
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater9
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	bra	do.poly.edges



next.y.smaller4
	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient3



grad.negative3
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen5
	moveq	#0,d5

start.x.on.screen5
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen5
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen5
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d2,d0			add gradient to get next x value

	move.l	d3,d5			gradient

	cmp.l	a5,d5
	blt.s	grad.greaterA
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greaterA
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x
	add.l	a4,d1			+ 1

	bra	do.poly.edges



both.edges.equal.length
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble	calc.end.gradient

	subq.w	#1,d5			count

edge.loop3
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen6
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen6
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen6
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen6
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop3

	bra	calc.end.gradient



bottom.of.polygon.flat
	move.l	(a2),d0			get current coords

	cmp.w	d7,d0
	bgt	fill			if bottom is off screen

	clr.w	d0			starting x * 65536

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x3

	cmp.l	a4,d5
	ble.s	adjust.ending.x3

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x3
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen7
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen7
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screen7
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen7
	move.l	d5,(a1)+		save starting and ending x

	bra.s	fill



bottom.is.off.screen
	sub.w	d4,d7			end y - current y = count
	blt.s	fill

edge.loop5
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screenA
	moveq	#0,d5			if off screen then set to 0

start.x.on.screenA
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screenA
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screenA
	move.l	d5,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d7,edge.loop5

	bra.s	fill



bottom.of.polygon
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	adjust.last.x.values

	subq.w	#1,d5			count

edge.loop4
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen8
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen8
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen8
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen8
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop4

adjust.last.x.values
	move.l	(a2),d0			get current coords
	move.l	d0,d1			both coords are the same

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x4

	cmp.l	a4,d5
	ble.s	adjust.ending.x4

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x4
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values2

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values2
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen9
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen9
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screen9
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen9
	move.l	d5,(a1)+		save starting and ending x

;	bra.s	fill




;""""""""""""""""""""""""""""""""""""""""
;	" THE FILL ROUTINE "
;	"		   "
;	""""""""""""""""""""

fill	st	(a1)			end-of-fill marker
	move.l	screen1(pc),a1
	lea	fill.coords(pc),a4
	move.w	(a4)+,d0		get y-start
	add.w	d0,d0			word offset
	lea	y.table(pc),a2
	add.w	(a2,d0.w),a1		add y offset

	move.w	colour.times.4(pc),d1
	cmp.w	#15*4,d1
	bgt	stipple.fill

	move.l	fill.table(pc,d1.w),a3	set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl.s	fill.it

	rts



fill.table
	dc.l	mask2,mask1,mask16,mask8,mask10,mask15,mask13,mask7
	dc.l	mask3,mask9,mask11,mask14,mask4,mask12,mask5,mask6



first.masks
	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1



fill.it	move.w	#160,d2			bytes per line
	move.w	#4*64,d3		height = 4

bltfin3	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin3

	move.l	#$7ca0000,bltcon0(a6)	USE B,C,D ; LFx: $CA
	move.w	#$ffff,bltadat(a6)	mask for all planes

fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line		if start x is greater than end x

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x start

	sub.w	d4,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	add.w	d4,d1			correct bit position for end x

	add.w	d4,d4
	move.w	first.masks(pc,d4.w),d0	get start mask
	swap	d0

	moveq	#$f,d4
	and.w	d1,d4			low four bits from x end

	add.w	d4,d4
	move.w	last.masks(pc,d4.w),d0	get end mask

	lsr.w	#4,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d4			width of one bitplane
	sub.w	d1,d4
	sub.w	d1,d4			modulo value

	or.w	d3,d1			bltsize value, with height = 4

bltfin4	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin4

	movem.l	d0/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d4,bltbmod(a6)		set modulos
	move.w	d4,bltcmod(a6)
	move.w	d4,bltdmod(a6)
	move.w	d1,bltsize(a6)		start blitter
next.line
	add.w	d2,a1			next line
	move.w	(a4)+,d0		next x-start
	bpl.s	fill.it.loop

	rts



last.masks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



stipple.fill
	move.l	#$1000,d5		value for bltcon1
	btst	#1,d0
	beq.s	even.scan.line
	swap	d5

even.scan.line
	sub.w	#16*4,d1
	move.l	stipple.fill.table(pc,d1.w),a3
;					set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl	stipple.fill.it

	rts



stipple.fill.table
	dc.l	mask41,mask17,mask31,mask23,mask25,mask30,mask28,mask22
	dc.l	mask18,mask24,mask26,mask29,mask19,mask27,mask20,mask21
	dc.l	mask59,mask53,mask38,mask54,mask35,mask62,mask52,mask34
	dc.l	mask49,mask39,mask60,mask48,mask37,mask43,mask56,mask50
	dc.l	mask58,mask61,mask51,mask64,mask36,mask57,mask32,mask55
	dc.l	mask47,mask44,mask33,mask46,mask40,mask63,mask42,mask45



first.masks2
	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1



stipple.fill.it
	move.w	#160,d2			bytes per line
	move.w	#4*64,d3		height = 4
	moveq	#16,d6

bltfin5	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin5

	move.w	#$7ca,bltcon0(a6)	USE B,C,D ; LFx: $CA
	move.w	#$ffff,bltadat(a6)	mask for all planes

stipple.fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line2		if start x is greater than end x

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x start
	bne.s	not.word.boundary

	sub.w	d6,d0			start one word earlier
	add.w	d6,d1			one word extra width
	bra.s	no.start.mask

not.word.boundary
	sub.w	d4,d0			x-start offset in multiples of 16
	add.w	d4,d1			correct bit position for end x

	add.w	d4,d4
	move.w	first.masks2(pc,d4.w),d4
;					get start mask
no.start.mask
	swap	d4
	asr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	moveq	#$f,d0
	and.w	d1,d0			low four bits from x end

	add.w	d0,d0
	move.w	last.masks2(pc,d0.w),d4	get end mask

	lsr.w	#4,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d0			width of one bitplane
	sub.w	d1,d0
	sub.w	d1,d0			modulo value

	or.w	d3,d1			bltsize value, with height = 4

bltfin6	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin6

	movem.l	d4/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d0,bltbmod(a6)		set modulos
	move.w	d0,bltcmod(a6)
	move.w	d0,bltdmod(a6)
	move.w	d5,bltcon1(a6)
	move.w	d1,bltsize(a6)		start blitter
next.line2
	swap	d5
	add.w	d2,a1			next line
	move.w	(a4)+,d0		next x-start
	bpl.s	stipple.fill.it.loop

	rts



last.masks2
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



y.table	ds.w	200



fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker



mask1	dcb.w	20,$ffff
mask2	dcb.w	20,0
mask3	dcb.w	20,0
mask4	dcb.w	20,0
mask5	dcb.w	20,0
mask6	dcb.w	20,$ffff
mask7	dcb.w	20,$ffff
mask8	dcb.w	20,$ffff
mask9	dcb.w	20,$ffff
mask10	dcb.w	20,0
mask11	dcb.w	20,0
mask12	dcb.w	20,$ffff
mask13	dcb.w	20,0
mask14	dcb.w	20,$ffff
mask15	dcb.w	20,$ffff
mask16	dcb.w	20,0
	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0
mask17	dcb.w	20,$5555
mask18	dcb.w	20,0
mask19	dcb.w	20,0
mask20	dcb.w	20,0
mask21	dcb.w	20,$5555
mask22	dcb.w	20,$5555
mask23	dcb.w	20,$5555
mask24	dcb.w	20,$5555
mask25	dcb.w	20,0
mask26	dcb.w	20,0
mask27	dcb.w	20,$5555
mask28	dcb.w	20,0
mask29	dcb.w	20,$5555
mask30	dcb.w	20,$5555
mask31	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,0
mask32	dcb.w	20,0
mask33	dcb.w	20,$ffff
	dcb.w	20,$5555
mask34	dcb.w	20,0
mask35	dcb.w	20,$5555
	dcb.w	20,$aaaa
mask36	dcb.w	20,$5555
mask37	dcb.w	20,0
	dcb.w	20,$aaaa
mask38	dcb.w	20,$5555
	dcb.w	20,$ffff
mask39	dcb.w	20,0
mask40	dcb.w	20,0
mask41	dcb.w	20,$ffff
	dcb.w	20,$5555
mask42	dcb.w	20,$5555
mask43	dcb.w	20,$5555
	dcb.w	20,$ffff
	dcb.w	20,0
mask44	dcb.w	20,$ffff
	dcb.w	20,$5555
mask45	dcb.w	20,$ffff
	dcb.w	20,$5555
mask46	dcb.w	20,$ffff
	dcb.w	20,0
mask47	dcb.w	20,$5555
	dcb.w	20,$5555
mask48	dcb.w	20,$ffff
	dcb.w	20,$5555
mask49	dcb.w	20,$aaaa
	dcb.w	20,$5555
	dcb.w	20,$aaaa
mask50	dcb.w	20,$5555
	dcb.w	20,$5555
mask51	dcb.w	20,$ffff
	dcb.w	20,$ffff
	dcb.w	20,$ffff
	dcb.w	20,$5555
mask52	dcb.w	20,$aaaa
	dcb.w	20,$ffff
mask53	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,$ffff
	dcb.w	20,$5555
mask54	dcb.w	20,0
	dcb.w	20,$aaaa
	dcb.w	20,$5555
mask55	dcb.w	20,0
mask56	dcb.w	20,$aaaa
	dcb.w	20,$aaaa
	dcb.w	20,$5555
mask57	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,$aaaa
	dcb.w	20,$5555
mask58	dcb.w	20,$aaaa
mask59	dcb.w	20,$aaaa
	dcb.w	20,$ffff
mask60	dcb.w	20,$5555
	dcb.w	20,$5555
	dcb.w	20,$aaaa
	dcb.w	20,$5555
mask61	dcb.w	20,$aaaa
mask62	dcb.w	20,$ffff
	dcb.w	20,$aaaa
	dcb.w	20,$5555
	dcb.w	20,0
mask63	dcb.w	20,$ffff
	dcb.w	20,$ffff
	dcb.w	20,$5555
	dcb.w	20,0
mask64	dcb.w	20,$aaaa
	dcb.w	20,$aaaa
	dcb.w	20,0
	dcb.w	20,$5555



poly.coords	ds.w	64		space for 16 sided polygon
colour.times.4	dc.w	0




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

keyboard.requests
	tst.b	frames.requested
	beq.s	no.request1
	bsr	frames.per.sec

no.request1
	tst.b	palette.requested
	beq.s	no.request2
	bsr.s	display.palette
	bsr	update.screens
palette.wait
	tst.b	palette.requested
	bne.s	palette.wait

no.request2
	rts




display.palette
	moveq	#2,d0			start y
	moveq	#8-1,d1			8 rows
	clr.w	colour.times.4		start colour at 0

next.row
	moveq	#4,d2			start x
	moveq	#8-1,d3			8 columns
next.column
	bsr.s	fill.box

	addq.w	#4,colour.times.4	next colour
	add.w	#40,d2			next start x
	dbra	d3,next.column

	add.w	#25,d0			next start y
	dbra	d1,next.row

	rts




fill.box
	movem.w	d0-d3,-(sp)

	move.w	d2,d3
	add.w	#30,d3			31 pixels wide
	moveq	#20-1,d1		20 pixels tall

	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

	bsr	fill

	movem.w	(sp)+,d0-d3
	rts




print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),a1
	add.w	d0,a1			screen start address
	move.w	#160,d2			bytes per line
print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2
copy.loop
	move.b	(a3)+,(a2)		copy byte of character, bitplane 1
	clr.b	40(a2)			bitplane 2
	clr.b	80(a2)			bitplane 3
	clr.b	120(a2)			bitplane 4
	add.w	d2,a2			next screen line
	dbra	d0,copy.loop

	addq.w	#1,a1			next column
	bra.s	print.loop
end.print
	rts




; Spectrum font, characters 32-126, each 8*8 pixels

font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$00,$04,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00




make.hex
	lea	hex.text(pc),a0		d0.l = number
	lea	hex.digits(pc),a1
	moveq	#0,d1
make.hex.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	make.hex.loop
	rts



hex.digits
	dc.b	'0123456789ABCDEF'



hex.text
	ds.b	9
	even




make.decimal
	and.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros
make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	add.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)			save units
	rts



decimal.text
	ds.b	6




frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter(pc),d1	get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#'.',-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#15,d0			x
	moveq	#0,d1			y
	bsr	print
	rts



old.counter
	dc.w	0



frames.text
	dc.b	'F/S     ',0
	even




update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	screen3(pc),screen2
	move.l	d0,screen3

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	copper3(pc),copper2
	move.l	d0,copper3

	move.l	d0,cop1lc(a6)		set new copper list address
	rts




;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list.1
	dc.w	bpl1pth,6		4 bitplane display
	dc.w	bpl1ptl,$8900
	dc.w	bpl2pth,6
	dc.w	bpl2ptl,$8928
	dc.w	bpl3pth,6
	dc.w	bpl3ptl,$8950
	dc.w	bpl4pth,6
	dc.w	bpl4ptl,$8978

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list.2
	dc.w	bpl1pth,7		4 bitplane display
	dc.w	bpl1ptl,$0600
	dc.w	bpl2pth,7
	dc.w	bpl2ptl,$0628
	dc.w	bpl3pth,7
	dc.w	bpl3ptl,$0650
	dc.w	bpl4pth,7
	dc.w	bpl4ptl,$0678

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list.3
	dc.w	bpl1pth,7		4 bitplane display
	dc.w	bpl1ptl,$8300
	dc.w	bpl2pth,7
	dc.w	bpl2ptl,$8328
	dc.w	bpl3pth,7
	dc.w	bpl3ptl,$8350
	dc.w	bpl4pth,7
	dc.w	bpl4ptl,$8378

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
joy0dat	equ	$00A
joy1dat	equ	$00C
clxdat	equ	$00E
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01A
intenar	equ	$01C
intreqr	equ	$01E
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02A
vhposw	equ	$02C
copcon	equ	$02E
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03A
strhor	equ	$03C
strlong	equ	$03E
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08A
copins	equ	$08C
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
aud0vol	equ	$0A8
aud1vol	equ	$0B8
aud2vol	equ	$0C8
aud3vol	equ	$0D8
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bpl5pth	equ	$0F0
bpl5ptl	equ	$0F2
bpl6pth	equ	$0F4
bpl6ptl	equ	$0F6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
bpldat	equ	$110
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12A
spr3pth	equ	$12C
spr3ptl	equ	$12E
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13A
spr7pth	equ	$13C
spr7ptl	equ	$13E
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14A
spr2ctl	equ	$152
spr3ctl	equ	$15A
spr4ctl	equ	$162
spr5ctl	equ	$16A
spr6ctl	equ	$172
spr7ctl	equ	$17A
spr0data equ	$144
spr1data equ	$14c
spr2data equ	$154
spr3data equ	$15c
spr4data equ	$164
spr5data equ	$16c
spr6data equ	$174
spr7data equ	$17c
spr0datb equ	$146
spr1datb equ	$14e
spr2datb equ	$156
spr3datb equ	$15e
spr4datb equ	$166
spr5datb equ	$16e
spr6datb equ	$176
spr7datb equ	$17e
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1A0




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen1		dc.l	$68900
screen2		dc.l	$70600
screen3		dc.l	$78300

copper1		dc.l	copper.list.1
copper2		dc.l	copper.list.2
copper3		dc.l	copper.list.3

raw.key.code	dc.b	0
palette.requested	dc.b	0
frames.requested	dc.b	0,0

mouse.data	dc.b	0,0
old.mouse.x	dc.b	0
old.mouse.y	dc.b	0

base.x.angle	dc.w	0
base.y.angle	dc.w	0
base.z.angle	dc.w	0

turret.y.angle	dc.w	0

sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$4000000

new.coords	ds.w	128*3		space for 128 coordinates




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

sine	dc.w	$0000,$00c9,$0192,$025b,$0324,$03ed,$04b6,$057e,$0647
	dc.w	$0710,$07d9,$08a1,$096a,$0a32,$0afb,$0bc3,$0c8b,$0d53
	dc.w	$0e1b,$0ee3,$0fab,$1072,$1139,$1200,$12c7,$138e,$1455
	dc.w	$151b,$15e1,$16a7,$176d,$1833,$18f8,$19bd,$1a82,$1b46
	dc.w	$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc,$209f,$2161,$2223
	dc.w	$22e4,$23a6,$2467,$2527,$25e7,$26a7,$2767,$2826,$28e5
	dc.w	$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54,$2e10,$2ecc,$2f86
	dc.w	$3041,$30fb,$31b4,$326d,$3326,$33de,$3496,$354d,$3603
	dc.w	$36b9,$376f,$3824,$38d8,$398c,$3a3f,$3af2,$3ba4,$3c56
	dc.w	$3d07,$3db7,$3e67,$3f16,$3fc5,$4073,$4120,$41cd,$4279
	dc.w	$4325,$43d0,$447a,$4523,$45cc,$4674,$471c,$47c3,$4869
	dc.w	$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f,$4ce0,$4d80,$4e20
	dc.w	$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce,$5268,$5301,$539a
	dc.w	$5432,$54c9,$555f,$55f4,$5689,$571d,$57b0,$5842,$58d3
	dc.w	$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28,$5cb3,$5d3d,$5dc6
	dc.w	$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb,$616e,$61f0,$6271
	dc.w	$62f1,$6370,$63ee,$646b,$64e7,$6562,$65dd,$6656,$66ce
	dc.w	$6745,$67bc,$6831,$68a5,$6919,$698b,$69fc,$6a6c,$6adb
	dc.w	$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61,$6dc9,$6e30,$6e95
	dc.w	$6efa,$6f5e,$6fc0,$7022,$7082,$70e1,$7140,$719d,$71f9
	dc.w	$7254,$72ae,$7306,$735e,$73b5,$740a,$745e,$74b1,$7503
	dc.w	$7554,$75a4,$75f3,$7640,$768d,$76d8,$7722,$776b,$77b3
	dc.w	$77f9,$783f,$7883,$78c6,$7908,$7949,$7989,$79c7,$7a04
	dc.w	$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c,$7b91,$7bc4,$7bf7
	dc.w	$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e,$7d38,$7d61,$7d89
	dc.w	$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e,$7e7e,$7e9c,$7eb9
	dc.w	$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c,$7f61,$7f74,$7f86
	dc.w	$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7,$7fe0,$7fe8,$7fef
	dc.w	$7ff5,$7ff9,$7ffc,$7ffe
cosine	dc.w	$7fff,$7ffe,$7ffc,$7ff9,$7ff5,$7fef,$7fe8,$7fe0,$7fd7
	dc.w	$7fcd,$7fc1,$7fb4,$7fa6,$7f96,$7f86,$7f74,$7f61,$7f4c
	dc.w	$7f37,$7f20,$7f08,$7eef,$7ed4,$7eb9,$7e9c,$7e7e,$7e5e
	dc.w	$7e3e,$7e1c,$7df9,$7dd5,$7db0,$7d89,$7d61,$7d38,$7d0e
	dc.w	$7ce2,$7cb6,$7c88,$7c59,$7c29,$7bf7,$7bc4,$7b91,$7b5c
	dc.w	$7b25,$7aee,$7ab5,$7a7c,$7a41,$7a04,$79c7,$7989,$7949
	dc.w	$7908,$78c6,$7883,$783f,$77f9,$77b3,$776b,$7722,$76d8
	dc.w	$768d,$7640,$75f3,$75a4,$7554,$7503,$74b1,$745e,$740a
	dc.w	$73b5,$735e,$7306,$72ae,$7254,$71f9,$719d,$7140,$70e1
	dc.w	$7082,$7022,$6fc0,$6f5e,$6efa,$6e95,$6e30,$6dc9,$6d61
	dc.w	$6cf8,$6c8e,$6c23,$6bb7,$6b4a,$6adb,$6a6c,$69fc,$698b
	dc.w	$6919,$68a5,$6831,$67bc,$6745,$66ce,$6656,$65dd,$6562
	dc.w	$64e7,$646b,$63ee,$6370,$62f1,$6271,$61f0,$616e,$60eb
	dc.w	$6067,$5fe2,$5f5d,$5ed6,$5e4f,$5dc6,$5d3d,$5cb3,$5c28
	dc.w	$5b9c,$5b0f,$5a81,$59f3,$5963,$58d3,$5842,$57b0,$571d
	dc.w	$5689,$55f4,$555f,$54c9,$5432,$539a,$5301,$5268,$51ce
	dc.w	$5133,$5097,$4ffa,$4f5d,$4ebf,$4e20,$4d80,$4ce0,$4c3f
	dc.w	$4b9d,$4afa,$4a57,$49b3,$490e,$4869,$47c3,$471c,$4674
	dc.w	$45cc,$4523,$447a,$43d0,$4325,$4279,$41cd,$4120,$4073
	dc.w	$3fc5,$3f16,$3e67,$3db7,$3d07,$3c56,$3ba4,$3af2,$3a3f
	dc.w	$398c,$38d8,$3824,$376f,$36b9,$3603,$354d,$3496,$33de
	dc.w	$3326,$326d,$31b4,$30fb,$3041,$2f86,$2ecc,$2e10,$2d54
	dc.w	$2c98,$2bdb,$2b1e,$2a61,$29a3,$28e5,$2826,$2767,$26a7
	dc.w	$25e7,$2527,$2467,$23a6,$22e4,$2223,$2161,$209f,$1fdc
	dc.w	$1f19,$1e56,$1d93,$1ccf,$1c0b,$1b46,$1a82,$19bd,$18f8
	dc.w	$1833,$176d,$16a7,$15e1,$151b,$1455,$138e,$12c7,$1200
	dc.w	$1139,$1072,$0fab,$0ee3,$0e1b,$0d53,$0c8b,$0bc3,$0afb
	dc.w	$0a32,$096a,$08a1,$07d9,$0710,$0647,$057e,$04b6,$03ed
	dc.w	$0324,$025b,$0192,$00c9,$0000,$ff37,$fe6e,$fda5,$fcdc
	dc.w	$fc13,$fb4a,$fa82,$f9b9,$f8f0,$f827,$f75f,$f696,$f5ce
	dc.w	$f505,$f43d,$f375,$f2ad,$f1e5,$f11d,$f055,$ef8e,$eec7
	dc.w	$ee00,$ed39,$ec72,$ebab,$eae5,$ea1f,$e959,$e893,$e7cd
	dc.w	$e708,$e643,$e57e,$e4ba,$e3f5,$e331,$e26d,$e1aa,$e0e7
	dc.w	$e024,$df61,$de9f,$dddd,$dd1c,$dc5a,$db99,$dad9,$da19
	dc.w	$d959,$d899,$d7da,$d71b,$d65d,$d59f,$d4e2,$d425,$d368
	dc.w	$d2ac,$d1f0,$d134,$d07a,$cfbf,$cf05,$ce4c,$cd93,$ccda
	dc.w	$cc22,$cb6a,$cab3,$c9fd,$c947,$c891,$c7dc,$c728,$c674
	dc.w	$c5c1,$c50e,$c45c,$c3aa,$c2f9,$c249,$c199,$c0ea,$c03b
	dc.w	$bf8d,$bee0,$be33,$bd87,$bcdb,$bc30,$bb86,$badd,$ba34
	dc.w	$b98c,$b8e4,$b83d,$b797,$b6f2,$b64d,$b5a9,$b506,$b463
	dc.w	$b3c1,$b320,$b280,$b1e0,$b141,$b0a3,$b006,$af69,$aecd
	dc.w	$ae32,$ad98,$acff,$ac66,$abce,$ab37,$aaa1,$aa0c,$a977
	dc.w	$a8e3,$a850,$a7be,$a72d,$a69d,$a60d,$a57f,$a4f1,$a464
	dc.w	$a3d8,$a34d,$a2c3,$a23a,$a1b1,$a12a,$a0a3,$a01e,$9f99
	dc.w	$9f15,$9e92,$9e10,$9d8f,$9d0f,$9c90,$9c12,$9b95,$9b19
	dc.w	$9a9e,$9a23,$99aa,$9932,$98bb,$9844,$97cf,$975b,$96e7
	dc.w	$9675,$9604,$9594,$9525,$94b6,$9449,$93dd,$9372,$9308
	dc.w	$929f,$9237,$91d0,$916b,$9106,$90a2,$9040,$8fde,$8f7e
	dc.w	$8f1f,$8ec0,$8e63,$8e07,$8dac,$8d52,$8cfa,$8ca2,$8c4b
	dc.w	$8bf6,$8ba2,$8b4f,$8afd,$8aac,$8a5c,$8a0d,$89c0,$8973
	dc.w	$8928,$88de,$8895,$884d,$8807,$87c1,$877d,$873a,$86f8
	dc.w	$86b7,$8677,$8639,$85fc,$85bf,$8584,$854b,$8512,$84db
	dc.w	$84a4,$846f,$843c,$8409,$83d7,$83a7,$8378,$834a,$831e
	dc.w	$82f2,$82c8,$829f,$8277,$8250,$822b,$8207,$81e4,$81c2
	dc.w	$81a2,$8182,$8164,$8147,$812c,$8111,$80f8,$80e0,$80c9
	dc.w	$80b4,$809f,$808c,$807a,$806a,$805a,$804c,$803f,$8033
	dc.w	$8029,$8020,$8018,$8011,$800b,$8007,$8004,$8002,$8001
	dc.w	$8002,$8004,$8007,$800b,$8011,$8018,$8020,$8029,$8033
	dc.w	$803f,$804c,$805a,$806a,$807a,$808c,$809f,$80b4,$80c9
	dc.w	$80e0,$80f8,$8111,$812c,$8147,$8164,$8182,$81a2,$81c2
	dc.w	$81e4,$8207,$822b,$8250,$8277,$829f,$82c8,$82f2,$831e
	dc.w	$834a,$8378,$83a7,$83d7,$8409,$843c,$846f,$84a4,$84db
	dc.w	$8512,$854b,$8584,$85bf,$85fc,$8639,$8677,$86b7,$86f8
	dc.w	$873a,$877d,$87c1,$8807,$884d,$8895,$88de,$8928,$8973
	dc.w	$89c0,$8a0d,$8a5c,$8aac,$8afd,$8b4f,$8ba2,$8bf6,$8c4b
	dc.w	$8ca2,$8cfa,$8d52,$8dac,$8e07,$8e63,$8ec0,$8f1f,$8f7e
	dc.w	$8fde,$9040,$90a2,$9106,$916b,$91d0,$9237,$929f,$9308
	dc.w	$9372,$93dd,$9449,$94b6,$9525,$9594,$9604,$9675,$96e7
	dc.w	$975b,$97cf,$9844,$98bb,$9932,$99aa,$9a23,$9a9e,$9b19
	dc.w	$9b95,$9c12,$9c90,$9d0f,$9d8f,$9e10,$9e92,$9f15,$9f99
	dc.w	$a01e,$a0a3,$a12a,$a1b1,$a23a,$a2c3,$a34d,$a3d8,$a464
	dc.w	$a4f1,$a57f,$a60d,$a69d,$a72d,$a7be,$a850,$a8e3,$a977
	dc.w	$aa0c,$aaa1,$ab37,$abce,$ac66,$acff,$ad98,$ae32,$aecd
	dc.w	$af69,$b006,$b0a3,$b141,$b1e0,$b280,$b320,$b3c1,$b463
	dc.w	$b506,$b5a9,$b64d,$b6f2,$b797,$b83d,$b8e4,$b98c,$ba34
	dc.w	$badd,$bb86,$bc30,$bcdb,$bd87,$be33,$bee0,$bf8d,$c03b
	dc.w	$c0ea,$c199,$c249,$c2f9,$c3aa,$c45c,$c50e,$c5c1,$c674
	dc.w	$c728,$c7dc,$c891,$c947,$c9fd,$cab3,$cb6a,$cc22,$ccda
	dc.w	$cd93,$ce4c,$cf05,$cfbf,$d07a,$d134,$d1f0,$d2ac,$d368
	dc.w	$d425,$d4e2,$d59f,$d65d,$d71b,$d7da,$d899,$d959,$da19
	dc.w	$dad9,$db99,$dc5a,$dd1c,$dddd,$de9f,$df61,$e024,$e0e7
	dc.w	$e1aa,$e26d,$e331,$e3f5,$e4ba,$e57e,$e643,$e708,$e7cd
	dc.w	$e893,$e959,$ea1f,$eae5,$ebab,$ec72,$ed39,$ee00,$eec7
	dc.w	$ef8e,$f055,$f11d,$f1e5,$f2ad,$f375,$f43d,$f505,$f5ce
	dc.w	$f696,$f75f,$f827,$f8f0,$f9b9,$fa82,$fb4a,$fc13,$fcdc
	dc.w	$fda5,$fe6e,$ff37,$0000,$00c9,$0192,$025b,$0324,$03ed
	dc.w	$04b6,$057e,$0647,$0710,$07d9,$08a1,$096a,$0a32,$0afb
	dc.w	$0bc3,$0c8b,$0d53,$0e1b,$0ee3,$0fab,$1072,$1139,$1200
	dc.w	$12c7,$138e,$1455,$151b,$15e1,$16a7,$176d,$1833,$18f8
	dc.w	$19bd,$1a82,$1b46,$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc
	dc.w	$209f,$2161,$2223,$22e4,$23a6,$2467,$2527,$25e7,$26a7
	dc.w	$2767,$2826,$28e5,$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54
	dc.w	$2e10,$2ecc,$2f86,$3041,$30fb,$31b4,$326d,$3326,$33de
	dc.w	$3496,$354d,$3603,$36b9,$376f,$3824,$38d8,$398c,$3a3f
	dc.w	$3af2,$3ba4,$3c56,$3d07,$3db7,$3e67,$3f16,$3fc5,$4073
	dc.w	$4120,$41cd,$4279,$4325,$43d0,$447a,$4523,$45cc,$4674
	dc.w	$471c,$47c3,$4869,$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f
	dc.w	$4ce0,$4d80,$4e20,$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce
	dc.w	$5268,$5301,$539a,$5432,$54c9,$555f,$55f4,$5689,$571d
	dc.w	$57b0,$5842,$58d3,$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28
	dc.w	$5cb3,$5d3d,$5dc6,$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb
	dc.w	$616e,$61f0,$6271,$62f1,$6370,$63ee,$646b,$64e7,$6562
	dc.w	$65dd,$6656,$66ce,$6745,$67bc,$6831,$68a5,$6919,$698b
	dc.w	$69fc,$6a6c,$6adb,$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61
	dc.w	$6dc9,$6e30,$6e95,$6efa,$6f5e,$6fc0,$7022,$7082,$70e1
	dc.w	$7140,$719d,$71f9,$7254,$72ae,$7306,$735e,$73b5,$740a
	dc.w	$745e,$74b1,$7503,$7554,$75a4,$75f3,$7640,$768d,$76d8
	dc.w	$7722,$776b,$77b3,$77f9,$783f,$7883,$78c6,$7908,$7949
	dc.w	$7989,$79c7,$7a04,$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c
	dc.w	$7b91,$7bc4,$7bf7,$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e
	dc.w	$7d38,$7d61,$7d89,$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e
	dc.w	$7e7e,$7e9c,$7eb9,$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c
	dc.w	$7f61,$7f74,$7f86,$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7
	dc.w	$7fe0,$7fe8,$7fef,$7ff5,$7ff9,$7ffc,$7ffe




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

O1	equ	0			coordinate offsets
O2	equ	6
O3	equ	12
O4	equ	18
O5	equ	24
O6	equ	30
O7	equ	36
O8	equ	42
O9	equ	48
O10	equ	54
O11	equ	60
O12	equ	66
O13	equ	72
O14	equ	78
O15	equ	84
O16	equ	90
O17	equ	96
O18	equ	102
O19	equ	108
O20	equ	114
O21	equ	120
O22	equ	126
O23	equ	132
O24	equ	138
O25	equ	144
O26	equ	150
O27	equ	156
O28	equ	162
O29	equ	168
O30	equ	174
O31	equ	180
O32	equ	186
O33	equ	192
O34	equ	198
O35	equ	204
O36	equ	210
O37	equ	216
O38	equ	222
O39	equ	228
O40	equ	234
O41	equ	240
O42	equ	246
O43	equ	252
O44	equ	258
O45	equ	264
O46	equ	270
O47	equ	276
O48	equ	282
O49	equ	288
O50	equ	294
O51	equ	300
O52	equ	306
O53	equ	312
O54	equ	318
O55	equ	324
O56	equ	330
O57	equ	336
O58	equ	342
O59	equ	348
O60	equ	354
O61	equ	360
O62	equ	366
O63	equ	372
O64	equ	378
O65	equ	384
O66	equ	390
O67	equ	396
O68	equ	402
O69	equ	408
O70	equ	414
O71	equ	420
O72	equ	426
O73	equ	432
O74	equ	438
O75	equ	444
O76	equ	450
O77	equ	456
O78	equ	462
O79	equ	468
O80	equ	474
O81	equ	480
O82	equ	486



colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$d82,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab



black	equ	0*4			colour * 4
white	equ	1*4
brown1	equ	2*4
brown2	equ	3*4
brown3	equ	4*4
brown4	equ	5*4
blue1	equ	6*4
blue2	equ	7*4
red1	equ	8*4
red2	equ	9*4
green1	equ	10*4
green2	equ	11*4
green3	equ	12*4
yellow	equ	13*4
grey1	equ	14*4
grey2	equ	15*4

cs.grey5	equ	16*4

s.white	equ	17*4
s.brown1	equ	18*4
s.brown2	equ	19*4
s.brown3	equ	20*4
s.brown4	equ	21*4
s.blue1	equ	22*4
s.blue2	equ	23*4
s.red1	equ	24*4
s.red2	equ	25*4
s.green1	equ	26*4
s.green2	equ	27*4
s.green3	equ	28*4
s.yellow	equ	29*4
s.grey1	equ	30*4
s.grey2	equ	31*4

cs.brown1	equ	32*4
cs.brown2	equ	33*4
cs.brown3	equ	34*4
cs.brown4	equ	35*4
cs.brown5	equ	36*4
cs.brown6	equ	37*4
cs.brown7	equ	38*4
cs.brown8	equ	39*4
cs.brown9	equ	40*4

cs.green1	equ	41*4
cs.green2	equ	42*4
cs.green3	equ	43*4
cs.green4	equ	44*4
cs.green5	equ	45*4
cs.green6	equ	46*4
cs.green7	equ	47*4

cs.blue1	equ	48*4
cs.blue2	equ	49*4
cs.blue3	equ	50*4

cs.orange1	equ	51*4
cs.orange2	equ	52*4
cs.orange3	equ	53*4

cs.purple1	equ	54*4
cs.purple2	equ	55*4

cs.skin1	equ	56*4
cs.skin2	equ	57*4

cs.cream1	equ	58*4
cs.cream2	equ	59*4

cs.grey1	equ	60*4
cs.grey2	equ	61*4
cs.grey3	equ	62*4
cs.grey4	equ	63*4



component.priority.offset	equ	component.priority-rotate.coords

vector.colour.offset	equ	vector.colour-rotate.coords

vector.offset	equ	vector-rotate.coords

polygon.orientation.offset	equ	polygon.orientation-rotate.coords

end.offset	equ	end.draw.3d.object-rotate.coords

rotate.coords.offset	equ	0



king.tiger.base
	dc.w	rotate.coords.offset

	dc.w	0			offset into coord list

	dc.w	32+26-1			number of coords


; track coordinates

	dc.w	206,0,-279		the coordinates - X, Y ,Z
	dc.w	206,-36,-376
	dc.w	206,-61,-400
	dc.w	206,-85,-400
	dc.w	206,-85,400
	dc.w	206,-61,400
	dc.w	206,-36,376
	dc.w	206,0,267

	dc.w	109,0,-279
	dc.w	109,-36,-376
	dc.w	109,-61,-400
	dc.w	109,-85,-400
	dc.w	109,-85,400
	dc.w	109,-61,400
	dc.w	109,-36,376
	dc.w	109,0,267

	dc.w	-109,0,-279
	dc.w	-109,-36,-376
	dc.w	-109,-61,-400
	dc.w	-109,-85,-400
	dc.w	-109,-85,400
	dc.w	-109,-61,400
	dc.w	-109,-36,376
	dc.w	-109,0,267

	dc.w	-206,0,-279
	dc.w	-206,-36,-376
	dc.w	-206,-61,-400
	dc.w	-206,-85,-400
	dc.w	-206,-85,400
	dc.w	-206,-61,400
	dc.w	-206,-36,376
	dc.w	-206,0,267


; body coordinates

	dc.w	218,-85,-412
	dc.w	97,-85,-412
	dc.w	97,-85,-370
	dc.w	-97,-85,-370
	dc.w	-97,-85,-412
	dc.w	-218,-85,-412
	dc.w	-218,-85,412
	dc.w	218,-85,412

	dc.w	218,-121,-376
	dc.w	97,-121,-376
	dc.w	-97,-121,-376
	dc.w	-218,-121,-376
	dc.w	-218,-109,424
	dc.w	218,-109,424

	dc.w	218,-132,-339
	dc.w	170,-132,-339
	dc.w	97,-132,-339
	dc.w	-97,-132,-339
	dc.w	-170,-132,-339
	dc.w	-218,-132,-339
	dc.w	-170,-109,424
	dc.w	170,-109,424

	dc.w	158,-170,-315
	dc.w	-158,-170,-315
	dc.w	-158,-170,448
	dc.w	158,-170,448


; inner track sides

	dc.w	polygon.orientation.offset
	dc.w	O9,O15,O12		offsets for three coordinates
	dc.w	2+2+8*2			skip value if polygon not visible
	dc.w	s.brown1		colour * 4
	dc.w	8			number of sides for polygon
	dc.w	O9,O16,O15,O14,O13,O12,O11,O10
;					offsets for coordinates


	dc.w	polygon.orientation.offset
	dc.w	O17,O20,O23
	dc.w	2+2+8*2
	dc.w	s.brown1
	dc.w	8
	dc.w	O17,O18,O19,O20,O21,O22,O23,O24


; two inner track covers

	dc.w	polygon.orientation.offset
	dc.w	O34,O35,O49
	dc.w	2+2+4*2
	dc.w	s.brown3
	dc.w	4
	dc.w	O34,O35,O49,O42


	dc.w	polygon.orientation.offset
	dc.w	O37,O43,O50
	dc.w	2+2+4*2
	dc.w	s.brown3
	dc.w	4
	dc.w	O37,O43,O50,O36


; left track surfaces

	dc.w	polygon.orientation.offset
	dc.w	O1,O9,O10
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O1,O9,O10,O2


	dc.w	polygon.orientation.offset
	dc.w	O2,O10,O11
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O2,O10,O11,O3


	dc.w	polygon.orientation.offset
	dc.w	O3,O11,O12
	dc.w	2+2+4*2
	dc.w	s.grey2
	dc.w	4
	dc.w	O3,O11,O12,O4


	dc.w	polygon.orientation.offset
	dc.w	O5,O13,O14
	dc.w	2+2+4*2
	dc.w	s.grey2
	dc.w	4
	dc.w	O5,O13,O14,O6


	dc.w	polygon.orientation.offset
	dc.w	O6,O14,O15
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O6,O14,O15,O7


	dc.w	polygon.orientation.offset
	dc.w	O7,O15,O16
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O7,O15,O16,O8


; right track surfaces

	dc.w	polygon.orientation.offset
	dc.w	O17,O25,O26
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O17,O25,O26,O18


	dc.w	polygon.orientation.offset
	dc.w	O18,O26,O27
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O18,O26,O27,O19


	dc.w	polygon.orientation.offset
	dc.w	O19,O27,O28
	dc.w	2+2+4*2
	dc.w	s.grey2
	dc.w	4
	dc.w	O19,O27,O28,O20


	dc.w	polygon.orientation.offset
	dc.w	O21,O29,O30
	dc.w	2+2+4*2
	dc.w	s.grey2
	dc.w	4
	dc.w	O21,O29,O30,O22


	dc.w	polygon.orientation.offset
	dc.w	O22,O30,O31
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O22,O30,O31,O23


	dc.w	polygon.orientation.offset
	dc.w	O23,O31,O32
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O23,O31,O32,O24


; outer track sides

	dc.w	polygon.orientation.offset
	dc.w	O1,O4,O7
	dc.w	2+2+8*2
	dc.w	brown1
	dc.w	8
	dc.w	O1,O2,O3,O4,O5,O6,O7,O8


	dc.w	polygon.orientation.offset
	dc.w	O25,O31,O28
	dc.w	2+2+8*2
	dc.w	brown1
	dc.w	8
	dc.w	O25,O32,O31,O30,O29,O28,O27,O26


; two top track covers

	dc.w	polygon.orientation.offset
	dc.w	O47,O48,O54
	dc.w	2+2+4*2
	dc.w	brown4
	dc.w	4
	dc.w	O47,O48,O54,O46


	dc.w	polygon.orientation.offset
	dc.w	O51,O52,O45
	dc.w	2+2+4*2
	dc.w	brown4
	dc.w	4
	dc.w	O51,O52,O45,O53


; two body sides

	dc.w	polygon.orientation.offset
	dc.w	O48,O55,O58
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O48,O55,O58,O54


	dc.w	polygon.orientation.offset
	dc.w	O51,O53,O57
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O51,O53,O57,O56


; lower front panel

	dc.w	polygon.orientation.offset
	dc.w	O35,O36,O50
	dc.w	2+2+4*2
	dc.w	brown3
	dc.w	4
	dc.w	O35,O36,O50,O49


; upper front panel

	dc.w	polygon.orientation.offset
	dc.w	O48,O51,O56
	dc.w	2+2+4*2
	dc.w	brown3
	dc.w	4
	dc.w	O48,O51,O56,O55


; two outer track covers

	dc.w	polygon.orientation.offset
	dc.w	O33,O41,O47
	dc.w	2+2+5*2
	dc.w	cs.brown4
	dc.w	5
	dc.w	O33,O41,O47,O46,O40


	dc.w	polygon.orientation.offset
	dc.w	O52,O44,O38
	dc.w	2+2+5*2
	dc.w	cs.brown4
	dc.w	5
	dc.w	O38,O39,O45,O52,O44


; two upper front track covers

	dc.w	polygon.orientation.offset
	dc.w	O41,O42,O49
	dc.w	2+2+4*2
	dc.w	cs.brown6
	dc.w	4
	dc.w	O41,O42,O49,O47


	dc.w	polygon.orientation.offset
	dc.w	O43,O44,O52
	dc.w	2+2+4*2
	dc.w	cs.brown6
	dc.w	4
	dc.w	O43,O44,O52,O50


; two lower front track covers

	dc.w	polygon.orientation.offset
	dc.w	O33,O34,O42
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O33,O34,O42,O41


	dc.w	polygon.orientation.offset
	dc.w	O37,O38,O44
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O37,O38,O44,O43


; upper rear panel

	dc.w	polygon.orientation.offset
	dc.w	O54,O58,O57
	dc.w	2+2+4*2
	dc.w	s.brown2
	dc.w	4
	dc.w	O54,O58,O57,O53


; lower rear panel

	dc.w	polygon.orientation.offset
	dc.w	O40,O46,O45
	dc.w	2+2+4*2
	dc.w	s.brown1
	dc.w	4
	dc.w	O40,O46,O45,O39


; body top panel

	dc.w	polygon.orientation.offset
	dc.w	O55,O56,O57
	dc.w	2+2+4*2
	dc.w	brown4
	dc.w	4
	dc.w	O55,O56,O57,O58


	dc.w	end.offset




king.tiger.top
	dc.w	rotate.coords.offset

	dc.w	0			offset into coord list

	dc.w	16+8-1			number of coords


; turret coordinates

	dc.w	73,-170,-170
	dc.w	-73,-170,-170
	dc.w	-97,-170,-30
	dc.w	-97,-170,103
	dc.w	-73,-170,242
	dc.w	73,-170,242
	dc.w	97,-170,103
	dc.w	97,-170,-30

	dc.w	48,-255,-133
	dc.w	-48,-255,-133
	dc.w	-73,-267,-12
	dc.w	-73,-267,85
	dc.w	-48,-255,206
	dc.w	48,-255,206
	dc.w	73,-267,85
	dc.w	73,-267,-12


; gun coordinates

	dc.w	8,-214,-558
	dc.w	-8,-214,-558
	dc.w	-18,-198,-162
	dc.w	18,-198,-162

	dc.w	8,-230,-556
	dc.w	-8,-230,-556
	dc.w	-18,-226,-143
	dc.w	18,-226,-143


	dc.w	component.priority.offset
	dc.w	O6+4,O17+4
	dc.l	king.tiger.turret,king.tiger.gun


; turret

king.tiger.turret
	dc.w	polygon.orientation.offset
	dc.w	O1,O2,O10
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O1,O2,O10,O9


	dc.w	polygon.orientation.offset
	dc.w	O2,O3,O11
	dc.w	2+2+4*2
	dc.w	cs.brown4
	dc.w	4
	dc.w	O2,O3,O11,O10


	dc.w	polygon.orientation.offset
	dc.w	O3,O4,O12
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O3,O4,O12,O11


	dc.w	polygon.orientation.offset
	dc.w	O4,O5,O13
	dc.w	2+2+4*2
	dc.w	cs.brown4
	dc.w	4
	dc.w	O4,O5,O13,O12


	dc.w	polygon.orientation.offset
	dc.w	O5,O6,O14
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O5,O6,O14,O13


	dc.w	polygon.orientation.offset
	dc.w	O6,O7,O15
	dc.w	2+2+4*2
	dc.w	cs.brown4
	dc.w	4
	dc.w	O6,O7,O15,O14


	dc.w	polygon.orientation.offset
	dc.w	O7,O8,O16
	dc.w	2+2+4*2
	dc.w	cs.brown5
	dc.w	4
	dc.w	O7,O8,O16,O15


	dc.w	polygon.orientation.offset
	dc.w	O8,O1,O9
	dc.w	2+2+4*2
	dc.w	cs.brown4
	dc.w	4
	dc.w	O8,O1,O9,O16


	dc.w	polygon.orientation.offset
	dc.w	O9,O10,O11
	dc.w	2+2+4*2
	dc.w	brown3
	dc.w	4
	dc.w	O9,O10,O11,O16


	dc.w	polygon.orientation.offset
	dc.w	O15,O12,O13
	dc.w	2+2+4*2
	dc.w	brown3
	dc.w	4
	dc.w	O15,O12,O13,O14


	dc.w	polygon.orientation.offset
	dc.w	O16,O11,O12
	dc.w	2+2+4*2
	dc.w	brown4
	dc.w	4
	dc.w	O16,O11,O12,O15


	dc.w	end.offset


; gun

king.tiger.gun
	dc.w	polygon.orientation.offset
	dc.w	O17,O20,O19
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O17,O20,O19,O18


	dc.w	polygon.orientation.offset
	dc.w	O17,O21,O24
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O17,O21,O24,O20


	dc.w	polygon.orientation.offset
	dc.w	O18,O19,O23
	dc.w	2+2+4*2
	dc.w	s.grey1
	dc.w	4
	dc.w	O18,O19,O23,O22


	dc.w	polygon.orientation.offset
	dc.w	O21,O22,O23
	dc.w	2+2+4*2
	dc.w	grey1
	dc.w	4
	dc.w	O21,O22,O23,O24


	dc.w	polygon.orientation.offset
	dc.w	O17,O18,O22
	dc.w	2+2+4*2
	dc.w	black
	dc.w	4
	dc.w	O17,O18,O22,O21


	dc.w	end.offset
