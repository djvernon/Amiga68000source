	section	ScreenDoubleBuffer,code
	opt	c+,a+


	include	DH0:Devpac/System2.gs


SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4
SCREEN_Y_OFFSET	equ	$48


	CALLEXEC Forbid

* Open the intuition library

	moveq	#0,d0
	lea	intuition.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit.false

* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.close.int

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Allocate screen memory

	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH*2,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.close.dos

	move.l	d0,screen1
	add.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	move.l	d0,screen2

* Save current View to restore later

	move.l	_GfxBase(pc),a0
	move.l	gb_ActiView(a0),old.view

* Initialise View

	lea	v(pc),a1
	CALLGRAF InitView

	lea	v(pc),a1
	move.l	#vp,v_ViewPort(a1)
	move.w	#SCREEN_Y_OFFSET,v_DyOffset(a1)

* Initialise ColorMap

	moveq	#1<<SCREEN_DEPTH,d0	number of colour entries
	CALLGRAF GetColorMap
	move.l	d0,cm
	beq	exit.free.mem

	lea	colour.table(pc),a0
	move.l	d0,a1
	move.l	cm_ColorTable(a1),a1
	REPT	(1<<SCREEN_DEPTH)-1
	move.w	(a0)+,(a1)+
	ENDR
	move.w	(a0),(a1)

* Initialise ViewPort

	lea	vp(pc),a0
	CALLGRAF InitVPort

	lea	vp(pc),a1
	move.l	cm(pc),vp_ColorMap(a1)
	move.w	#SCREEN_WIDTH,vp_DWidth(a1)
	move.w	#SCREEN_HEIGHT,vp_DHeight(a1)
	move.l	#ri,vp_RasInfo(a1)

* Initialise RasInfo with pointer to first BitMap

	lea	ri(pc),a1
	move.l	#bm1,ri_BitMap(a1)

* Initialise first BitMap

	lea	bm1(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen1(pc),a0
	lea	bm1(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Construct intermediate Copper list for ViewPort, first BitMap

	lea	v(pc),a0
	lea	vp(pc),a1
	CALLGRAF MakeVPort

* Merge all Copper lists together into a single list, first BitMap

	lea	v(pc),a1
	CALLGRAF MrgCop

* Save LOFCprList for first BitMap, then reset to zero

	lea	v(pc),a1
	lea	v_LOFCprList(a1),a1
	move.l	(a1),copper1
	clr.l	(a1)

* Initialise RasInfo with pointer to second BitMap

	lea	ri(pc),a1
	move.l	#bm2,ri_BitMap(a1)

* Initialise second BitMap

	lea	bm2(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen2(pc),a0
	lea	bm2(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Construct intermediate Copper list for ViewPort, second BitMap

	lea	v(pc),a0
	lea	vp(pc),a1
	CALLGRAF MakeVPort

* Merge all Copper lists together into a single list, second BitMap

	lea	v(pc),a1
	CALLGRAF MrgCop

* Save LOFCprList for second BitMap

	lea	v(pc),a1
	lea	v_LOFCprList(a1),a1
	move.l	(a1),copper2

* Load the new View, second BitMap

	lea	v(pc),a1
	CALLGRAF LoadView

* Add Vertical Blank interrupt server

	moveq	#5,d0
	lea	vblank(pc),a1
	move.b	#NT_INTERRUPT,LN_TYPE(a1)
	move.b	#0,LN_PRI(a1)
	move.l	#vblank.name,LN_NAME(a1)
	move.l	#vblank.code,IS_CODE(a1)
	CALLEXEC AddIntServer

* Own the Blitter

	CALLGRAF OwnBlitter

	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

main.loop
	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	bsr	calc.sin.cos.values

	lea	object(pc),a0
	bsr	draw.3D.object

	bsr	update.visible.screen

	sf	vblank.occured
wait.vblank
	tst.b	vblank.occured
	beq.s	wait.vblank

	bsr	clear.current.screen

	btst	#6,$bfe001.l
	bne.s	main.loop


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler

	CALLGRAF DisownBlitter

	moveq	#5,d0
	lea	vblank(pc),a1
	CALLEXEC RemIntServer

	move.l	old.view(pc),a1
	CALLGRAF LoadView

	move.l	cm(pc),a0
	CALLGRAF FreeColorMap

	lea	vp(pc),a0
	CALLGRAF FreeVPortCopLists

	move.l	copper1(pc),a0
	CALLGRAF FreeCprList

	move.l	copper2(pc),a0
	CALLGRAF FreeCprList

exit.free.mem
	move.l	screen.memory(pc),a1
	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH*2,d0
	CALLEXEC FreeMem

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.int
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	CALLEXEC Permit
	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

rte.ins	rte


vblank.code
	movem.l	d0-d1/a0,-(sp)
	st	vblank.occured

	lea	mouse.data(pc),a0

	move.b	$dff00b.l,d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x(pc),d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$dff00a.l,d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y(pc),d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y

	bsr.s	set.x.y.z.angles

	movem.l	(sp)+,d0-d1/a0
	rts


set.x.y.z.angles
	lea	mouse.data(pc),a0
	btst	#2,potgor+$dff000.l	right mouse button
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


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0

old.dbz		dc.l	0
old.view	dc.l	0
screen.memory	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
cm		dc.l	0
copper1		dc.l	0
copper2		dc.l	0

vblank.occured	dc.b	0,0

mouse.data	dc.b	0,0
old.mouse.x	dc.b	0
old.mouse.y	dc.b	0

base.x.angle	dc.w	0
base.y.angle	dc.w	0
base.z.angle	dc.w	0

sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$4000000

new.coords	ds.w	100*3		space for 100 coordinates


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME

vblank.name	dc.b	'Custom VBlank',0
	even


*""""""""""""""
*" STRUCTURES "
*"	      "
*""""""""""""""

v	ds.b	v_SIZEOF
vp	ds.b	vp_SIZEOF
ri	ds.b	ri_SIZEOF
bm1	ds.b	bm_SIZEOF
bm2	ds.b	bm_SIZEOF

vblank	ds.b	IS_SIZE


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab


;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""

XMAX	equ	SCREEN_WIDTH
YMAX	equ	SCREEN_HEIGHT
XMID	equ	XMAX/2
YMID	equ	YMAX/2


clear.current.screen
	move.l	screen1(pc),a2
	move.w	#(YMAX*4)-1,d2
	moveq	#0,d3
.loop
	REPT	XMAX/32
	move.l	d3,(a2)+
	ENDR
	dbra	d2,.loop
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




rotate.coords
	lea	sin.cos.values(pc),a1
	lea	new.coords(pc),a2
	add.w	(a0)+,a2		point to correct coordinates
	move.w	(a0)+,d7		count-1
	move.w	#XMID,a3
	move.w	#YMID,a4

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
	bmi.s	end.draw.3D.object	quit if z is negative

	lea	-26(a1),a1		18+2*4 - reset to start of values
	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0			X/Z - perspective for X
	divs	d2,d1			Y/Z - perspective for Y

	add.w	a3,d0			centre on screen
	add.w	a4,d1

	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y
	move.w	d2,(a2)+		save z

	dbra	d7,rotate.loop

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




polygon.draw
	lea	new.coords(pc),a1
	bsr	polygon

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




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

	bsr	polygon

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

skip.polygon
	add.w	d3,a0			miss out polygon data




draw.3D.object
	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

sub.object
	pea	2(a0)
	add.w	(a0),a0
	bsr.s	draw.3D.object
	move.l	(sp)+,a0

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

end.draw.3D.object
	rts




set.fill.colour				* set colour for subsequent fills
	move.w	(a0)+,current.fill.colour

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




set.line.colour				* set colour for subsequent lines
	move.w	(a0)+,current.line.colour

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




line	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get start offset
	move.w	(a0)+,d2		get end offset
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr.s	clip.line

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




circle	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get offset
	movem.w	(a1,d0.w),d0-d2		get centre coordinates
	move.l	(a0)+,d3
	divs	d2,d3			calculate radius
	bsr	calc.circle

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




component.priority
	lea	new.coords(pc),a1
	movem.w	(a0)+,d0-d2		get two offsets and skip value
	move.w	(a1,d0.w),d0		get z value
	cmp.w	(a1,d1.w),d0		subtract other z value
	bge.s	correct.order
	add.w	d2,a0			add skip value

correct.order
	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




skip.data
	add.w	(a0),a0

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




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
	sub.w	d1,d5			y2-y1
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




draw.line				; draw line using blitter
;	CALLGRAF OwnBlitter

	lea	$dff000.l,a6
	cmp.w	d2,d0
	ble.s	x1.less.than.x2

	exg	d0,d2			ensure line is going left-to-right
	exg	d1,d3

x1.less.than.x2
	sub.w	d0,d2			x2-x1
	sub.w	d1,d3			y2-y1

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x-start

	sub.w	d4,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes

	add.w	d1,d1			word offset
	lea	y.table(pc),a1
	add.w	(a1,d1.w),d0		add y offset

	move.l	screen1(pc),a1
	add.w	d0,a1			start address of line

	ror.w	#4,d4			low four bits from x-start
	or.w	#$bca,d4		USE A,C,D	D = A.B + notA.C
	swap	d4

	tst.w	d3			delta-y
	bmi.s	y2.less.than.y1

	cmp.w	d2,d3
	blt.s	dy.less.than.dx

	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	dl.size

dy.less.than.dx
	move.w	#%10001,d4
	bra.s	dl.size


y2.less.than.y1
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	dy.less.than.dx2

	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	dl.size

dy.less.than.dx2
	move.w	#%11001,d4


dl.size	move.w	d2,d1			larger delta is line length
	addq.w	#1,d1			+ 1 to prevent length of zero
	lsl.w	#6,d1			into correct position
	addq.w	#2,d1			+ width of two

	add.w	d3,d3			2 Sdelta
	move.w	d3,d0
	sub.w	d2,d0			2 Sdelta - Ldelta
	bge.s	no.sign

	or.w	#%1000000,d4		set SIGN flag

no.sign	add.w	d2,d2			2 Ldelta

	lea	line.colour.masks(pc),a2
	add.w	current.line.colour(pc),a2

	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT,d5	size of one bitplane

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	d3,bltbmod(a6)		2 Sdelta
	sub.w	d2,d3			2 Sdelta - 2 Ldelta
	move.w	d3,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	moveq	#SCREEN_WIDTH/8,d3	width of one bitplane
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	moveq	#4-1,d2
	move.w	(a2)+,d3		get first line mask
	bra.s	dl.start


dl.loop	add.l	d5,a1
	move.w	(a2)+,d3		get next line mask

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

dl.start
	move.l	a1,bltcpth(a6)		start address of line
	move.l	a1,bltdpth(a6)		start address of line
	move.w	d0,bltapth+2(a6)	2 Sdelta - Ldelta
	move.l	d4,bltcon0(a6)
	move.w	d3,bltbdat(a6)		set line mask
	move.w	d1,bltsize(a6)		start blitter

	dbra	d2,dl.loop		do all bitplanes

;	CALLGRAF DisownBlitter
	rts



current.line.colour	dc.w	0



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




;""""""""""""""""""""""
;" THE CIRCLE ROUTINE "
;"		      "
;""""""""""""""""""""""

return	rts


calc.circle
	move.w	#XMAX-1,d6

	move.w	d0,d5			x centre
	sub.w	d3,d5			- radius
	cmp.w	d6,d5
	bgt.s	return			quit if off right of screen

	move.w	d0,d5			x centre
	add.w	d3,d5			+ radius
	bmi.s	return			quit if off left of screen

	move.w	#YMAX-1,d2

	move.w	d1,d5			y centre
	sub.w	d3,d5			- radius
	cmp.w	d2,d5
	bgt.s	return			quit if off bottom of screen

	move.w	d1,d5			y centre
	add.w	d3,d5			+ radius
	bmi.s	return			quit if off top of screen

	cmp.w	d2,d5
	ble.s	circ1			if not off bottom at all

	move.w	d2,d5			set to bottom of screen


circ1	lea	fill.coords(pc),a1
	tst.w	d1			y centre
	bpl.s	circ2

					; some of bottom half to be done
	move.w	d3,d2			radius
	move.w	d1,d3			y centre

	muls	d2,d2			R*R
	muls	d1,d1			Y*Y
	sub.l	d1,d2			R*R - Y*Y
	bsr	circ10			calculate X

	add.w	d3,d1

	neg.w	d1
	add.w	d3,d3
	subq.w	#1,d3

	clr.w	(a1)+			set y-start to top of screen
	bra.s	circA



					; all of bottom half to be done
circ2	sub.w	d3,d1			- radius
	bpl.s	circ3

					; some of top half to be done
	move.w	d3,d2			radius
	add.w	d3,d1			y centre
	move.w	d1,d3			y centre

	muls	d2,d2			R*R
	muls	d1,d1			Y*Y
	sub.l	d1,d2			R*R - Y*Y
	bsr	circ10			calculate X

	add.w	d3,d1

	clr.w	(a1)+			set y-start to top of screen
	bra.s	circ4



					; all of top half to be done
circ3	move.w	d1,(a1)+		save y-start
	sub.w	d1,d5			number of lines high
	moveq	#0,d7
	move.w	d3,d1			radius


circ4	neg.w	d1			- radius
	add.w	d3,d3			2R
	subq.w	#1,d3			2R - 1




circ5	move.w	d7,d2			do top half of circle
	add.w	d2,d2
	addq.w	#1,d2
	add.w	d2,d1
	bgt.s	circ7

circ6	addq.w	#1,d7
	addq.w	#2,d2
	add.w	d2,d1
	ble.s	circ6

circ7	sub.w	d2,d1

	move.w	d0,d4
	sub.w	d7,d4			starting x
	bpl.s	circ8
	moveq	#0,d4			if off screen then set to 0

circ8	swap	d4

	move.w	d0,d4
	add.w	d7,d4			ending x
	cmp.w	d6,d4
	ble.s	circ9
	move.w	d6,d4			if off screen then set to maximum

circ9	move.l	d4,(a1)+		save starting and ending x

	sub.w	d3,d1
	subq.w	#2,d3
	dbmi	d5,circ5




	subq.w	#1,d5
	bmi.s	circF




circA	tst.w	d1			do bottom half of circle
	ble.s	circC

	moveq	#-1,d2
	sub.w	d7,d2
	sub.w	d7,d2

circB	addq.w	#2,d2
	add.w	d2,d1
	dble	d7,circB

	subq.w	#1,d7

circC	move.w	d0,d4
	sub.w	d7,d4			starting x
	bpl.s	circD
	moveq	#0,d4			if off screen then set to 0

circD	swap	d4

	move.w	d0,d4
	add.w	d7,d4			ending x
	cmp.w	d6,d4
	ble.s	circE
	move.w	d6,d4			if off screen then set to maximum

circE	move.l	d4,(a1)+		save starting and ending x

	sub.w	d3,d1
	subq.w	#2,d3
	dbra	d5,circA




circF	bra	fill




circ10	moveq	#16-1,d4		calculate square root of d2
	move.l	#$40000000,d7
	move.l	d2,d1
	clr.w	d1
	swap	d1

circ11	swap	d7
	sub.l	d7,d1
	bcc.s	circ12

	add.l	d7,d1
	swap	d7

	add.w	d7,d7

	add.w	d2,d2
	addx.l	d1,d1
	add.w	d2,d2
	addx.l	d1,d1

	dbra	d4,circ11

	swap	d1			/ 65536 to give result in d1
	rts




circ12	swap	d7

	add.w	d7,d7
	addq.w	#1,d7

	add.w	d2,d2
	addx.l	d1,d1
	add.w	d2,d2
	addx.l	d1,d1

	dbra	d4,circ11

	swap	d1			/ 65536 to give result in d1
	rts




;"""""""""""""""""""""""
;" THE POLYGON ROUTINE "
;"		       "
;"""""""""""""""""""""""

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




return2	rts




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
	bmi.s	return2			quit if largest x off left

	cmp.w	d6,d2
	bgt.s	return2			quit if smallest x off right

	tst.w	d5
	bmi.s	return2			quit if bottom y off top

	cmp.w	d7,d4
	bgt.s	return2			quit if top y off bottom

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

edge.loop4
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen8
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen8
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen8
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen8
	move.l	d5,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d7,edge.loop4

	bra.s	fill




bottom.of.polygon
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	adjust.last.x.values

	subq.w	#1,d5			count

edge.loop5
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen9
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen9
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen9
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen9
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop5

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
	bpl.s	start.x.on.screenA
	moveq	#0,d5			if off screen then set to 0

start.x.on.screenA
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screenA
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screenA
	move.l	d5,(a1)+		save starting and ending x

;	bra.s	fill




*""""""""""""""""""""
*" THE FILL ROUTINE "
*"		    "
*""""""""""""""""""""

fill	move.l	a0,-(sp)
	st	(a1)			end-of-fill marker
	move.l	screen1(pc),a0
	lea	fill.coords(pc),a1
	move.w	(a1)+,d0		get y-start
	add.w	d0,d0			word offset
	lea	y.table(pc),a2
	add.w	(a2,d0.w),a0		add y offset

	move.w	(a1)+,d0		first x-start
	bpl.s	fill.colour
	move.l	(sp)+,a0
	rts


fill.colour
	move.w	current.fill.colour(pc),d1
	move.l	fill.colour.table(pc,d1.w),a2
	jmp	(a2)



fill.colour.table
	dc.l	fill.colour0,fill.colour1,fill.colour2,fill.colour3
	dc.l	fill.colour4,fill.colour5,fill.colour6,fill.colour7
	dc.l	fill.colour8,fill.colour9,fill.colour10,fill.colour11
	dc.l	fill.colour12,fill.colour13,fill.colour14,fill.colour15



fill.colour0
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fill.colour0.first(pc),a2
	lea	fill.colour0.last(pc),a3
	bra	fill.set.ptrs

fill.colour1
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fill.colour1.first(pc),a2
	lea	fill.colour1.last(pc),a3
	bra	fill.set.ptrs

fill.colour2
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fill.colour2.first(pc),a2
	lea	fill.colour2.last(pc),a3
	bra	fill.set.ptrs

fill.colour3
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fill.colour3.first(pc),a2
	lea	fill.colour3.last(pc),a3
	bra	fill.set.ptrs

fill.colour4
	moveq	#0,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fill.colour4.first(pc),a2
	lea	fill.colour4.last(pc),a3
	bra	fill.set.ptrs

fill.colour5
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fill.colour5.first(pc),a2
	lea	fill.colour5.last(pc),a3
	bra	fill.set.ptrs

fill.colour6
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fill.colour6.first(pc),a2
	lea	fill.colour6.last(pc),a3
	bra	fill.set.ptrs

fill.colour7
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fill.colour7.first(pc),a2
	lea	fill.colour7.last(pc),a3
	bra	fill.set.ptrs

fill.colour8
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fill.colour8.first(pc),a2
	lea	fill.colour8.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour9
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fill.colour9.first(pc),a2
	lea	fill.colour9.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour10
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fill.colour10.first(pc),a2
	lea	fill.colour10.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour11
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fill.colour11.first(pc),a2
	lea	fill.colour11.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour12
	moveq	#0,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fill.colour12.first(pc),a2
	lea	fill.colour12.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour13
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fill.colour13.first(pc),a2
	lea	fill.colour13.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour14
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fill.colour14.first(pc),a2
	lea	fill.colour14.last(pc),a3
	bra.s	fill.set.ptrs

fill.colour15
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fill.colour15.first(pc),a2
	lea	fill.colour15.last(pc),a3

fill.set.ptrs
	btst	#6,dmaconr+$dff000.l
	bne.s	fill.set.ptrs

	move.l	a2,first.words.ptr
	move.l	a3,last.words.ptr
	bra.s	fill.loop



start.masks
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001

end.masks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



fill.loop
	move.w	(a1)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line		if x-end is less than x-start

	moveq	#$f,d2
	and.w	d0,d2			low four bits from x-start
	sub.w	d2,d0

	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a0,d0.w),a2		start address of fill -	bitplane 1
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a2),a3		bitplane 2
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a3),a4		bitplane 3
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a4),a5		bitplane 4

	add.w	d2,d1			correct bit position for x-end

	add.w	d2,d2
	move.w	start.masks(pc,d2.w),d0	get positive start mask

	moveq	#$f,d2
	and.w	d1,d2			low four bits from x-end
	sub.w	d2,d1

	add.w	d2,d2
	move.w	end.masks(pc,d2.w),d2	get positive end mask

	lsr.w	#2,d1			width of fill - 1, in words * 4
	beq.s	one.word.fill

set.first.words
	move.l	first.words.ptr(pc),a6
	jmp	(a6)

set.middle.words
	move.l	fill.width.table-4(pc,d1.w),a6
	jmp	(a6)

one.word.fill
	and.w	d0,d2			combine start and end masks

set.last.words
words2	move.l	last.words.ptr(pc),a6
	jmp	(a6)

next.line
	lea	SCREEN_WIDTH/8(a0),a0	next line
	move.w	(a1)+,d0		next x-start
	bpl.s	fill.loop
	move.l	(sp)+,a0
	rts



fill.width.table

* one word fill is handled above

	dc.l	words2,words3,words4,words5,words6,words7,words8
	dc.l	words9,words10,words11,words12,words13,words14
	dc.l	words15,words16,words17,words18,words19,words20



words19	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words17	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words15	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words13	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words11	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words9	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words7	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words5	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words3	move.w	d4,(a2)+
	move.w	d5,(a3)+
	move.w	d6,(a4)+
	move.w	d7,(a5)+

	bra	set.last.words



words20	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words18	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words16	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words14	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words12	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words10	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words8	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words6	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words4	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

	bra	set.last.words



first.words.ptr	dc.l	0
last.words.ptr	dc.l	0



fill.colour0.first
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour0.last
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	next.line



fill.colour1.first
	or.w	d0,(a2)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour1.last
	or.w	d2,(a2)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	next.line



fill.colour2.first
	or.w	d0,(a3)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour2.last
	or.w	d2,(a3)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	next.line



fill.colour3.first
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	not.w	d0
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour3.last
	or.w	d2,(a2)
	or.w	d2,(a3)
	not.w	d2
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	next.line



fill.colour4.first
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour4.last
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a5)
	bra	next.line



fill.colour5.first
	or.w	d0,(a2)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour5.last
	or.w	d2,(a2)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a5)
	bra	next.line



fill.colour6.first
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour6.last
	or.w	d2,(a3)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a5)
	bra	next.line



fill.colour7.first
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a5)+
	bra	set.middle.words

fill.colour7.last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a5)
	bra	next.line



fill.colour8.first
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	bra	set.middle.words

fill.colour8.last
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a4)
	bra	next.line



fill.colour9.first
	or.w	d0,(a2)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	bra	set.middle.words

fill.colour9.last
	or.w	d2,(a2)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a4)
	bra	next.line



fill.colour10.first
	or.w	d0,(a3)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a4)+
	bra	set.middle.words

fill.colour10.last
	or.w	d2,(a3)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a4)
	bra	next.line



fill.colour11.first
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a4)+
	bra	set.middle.words

fill.colour11.last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a4)
	bra	next.line



fill.colour12.first
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	bra	set.middle.words

fill.colour12.last
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	bra	next.line



fill.colour13.first
	or.w	d0,(a2)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a3)+
	bra	set.middle.words

fill.colour13.last
	or.w	d2,(a2)
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a3)
	bra	next.line



fill.colour14.first
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	bra	set.middle.words

fill.colour14.last
	or.w	d2,(a3)
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	bra	next.line



fill.colour15.first
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	bra	set.middle.words

fill.colour15.last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a4)
	or.w	d2,(a5)
	bra	next.line



current.fill.colour	dc.w	0



y.table	ds.w	SCREEN_HEIGHT



fill.coords
	ds.w	SCREEN_HEIGHT*2+2



poly.coords	ds.w	64		space for 16 sided polygon




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

update.visible.screen
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.l	copper1(pc),a0
	move.l	copper2(pc),copper1
	move.l	a0,copper2

;	lea	v(pc),a1
;	move.l	a0,v_LOFCprList(a1)

	move.l	_GfxBase(pc),a1
	move.l	4(a0),gb_LOFlist(a1)
	rts




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

P1	equ	0			coordinate offsets
P2	equ	6
P3	equ	12
P4	equ	18
P5	equ	24
P6	equ	30
P7	equ	36
P8	equ	42
P9	equ	48
P10	equ	54
P11	equ	60
P12	equ	66
P13	equ	72
P14	equ	78
P15	equ	84
P16	equ	90
P17	equ	96
P18	equ	102
P19	equ	108
P20	equ	114
P21	equ	120
P22	equ	126
P23	equ	132
P24	equ	138
P25	equ	144
P26	equ	150
P27	equ	156
P28	equ	162
P29	equ	168
P30	equ	174
P31	equ	180
P32	equ	186
P33	equ	192
P34	equ	198
P35	equ	204
P36	equ	210
P37	equ	216
P38	equ	222
P39	equ	228
P40	equ	234
P41	equ	240
P42	equ	246
P43	equ	252
P44	equ	258
P45	equ	264
P46	equ	270
P47	equ	276
P48	equ	282
P49	equ	288
P50	equ	294
P51	equ	300
P52	equ	306
P53	equ	312
P54	equ	318
P55	equ	324
P56	equ	330
P57	equ	336
P58	equ	342
P59	equ	348
P60	equ	354
P61	equ	360
P62	equ	366
P63	equ	372
P64	equ	378
P65	equ	384
P66	equ	390
P67	equ	396
P68	equ	402
P69	equ	408
P70	equ	414
P71	equ	420
P72	equ	426
P73	equ	432
P74	equ	438
P75	equ	444
P76	equ	450
P77	equ	456
P78	equ	462
P79	equ	468
P80	equ	474
P81	equ	480
P82	equ	486
P83	equ	492
P84	equ	498
P85	equ	504
P86	equ	510
P87	equ	516
P88	equ	522
P89	equ	528
P90	equ	534
P91	equ	540
P92	equ	546
P93	equ	552
P94	equ	558
P95	equ	564
P96	equ	570
P97	equ	576
P98	equ	582
P99	equ	588
P100	equ	594



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


rotate.coords.offset	equ	rotate.coords-line

polygon.draw.offset	equ	polygon.draw-line

polygon.orientation.offset	equ	polygon.orientation-line

sub.object.offset	equ	sub.object-line

end.offset	equ	end.draw.3D.object-line

set.fill.colour.offset	equ	set.fill.colour-line

set.line.colour.offset	equ	set.line.colour-line

line.offset	equ	0

circle.offset	equ	circle-line

component.priority.offset	equ	component.priority-line

skip.data.offset	equ	skip.data-line


object	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	20-1

	dc.w	180,0,420
	dc.w	75,-180,-300
	dc.w	180,0,-420
	dc.w	180,60,-420
	dc.w	75,120,-300
	dc.w	180,60,420
	dc.w	-180,0,420
	dc.w	-75,-180,-300
	dc.w	-180,0,-420
	dc.w	-180,60,-420
	dc.w	-75,120,-300
	dc.w	-180,60,420

	dc.w	30,-180,-300
	dc.w	30,-165,-240
	dc.w	-30,-165,-240
	dc.w	-30,-180,-300

	dc.w	30,-240,-300
	dc.w	30,-240,-240
	dc.w	-30,-240,-240
	dc.w	-30,-240,-300


	dc.w	set.fill.colour.offset
	dc.w	brown2

	dc.w	polygon.orientation.offset
	dc.w	P2,P8,P7
	dc.w	378
	dc.w	4
	dc.w	P2,P8,P7,P1


	dc.w	rotate.coords.offset

	dc.w	20*6

	dc.w	23-1

	dc.w	150,-9,390
	dc.w	150,-39,270
	dc.w	102,-30,306
	dc.w	150,-21,342

	dc.w	90,-39,270
	dc.w	42,-39,270
	dc.w	42,-9,390
	dc.w	90,-9,390

	dc.w	30,-39,270
	dc.w	30,-9,390
	dc.w	-18,-9,390

	dc.w	-30,-39,270
	dc.w	-30,-9,390

	dc.w	-90,-39,270
	dc.w	-42,-39,270
	dc.w	-42,-9,390
	dc.w	-90,-9,390

	dc.w	-150,-39,270
	dc.w	-102,-39,270
	dc.w	-102,-24,330
	dc.w	-126,-24,330
	dc.w	-102,-9,390
	dc.w	-150,-9,390


	dc.w	set.line.colour.offset
	dc.w	black*2

	dc.w	line.offset
	dc.w	P21,P22

	dc.w	line.offset
	dc.w	P22,P23

	dc.w	line.offset
	dc.w	P23,P24


	dc.w	line.offset
	dc.w	P25,P26

	dc.w	line.offset
	dc.w	P26,P27

	dc.w	line.offset
	dc.w	P27,P28

	dc.w	line.offset
	dc.w	P28,P25


	dc.w	line.offset
	dc.w	P29,P30

	dc.w	line.offset
	dc.w	P30,P31


	dc.w	line.offset
	dc.w	P32,P33


	dc.w	line.offset
	dc.w	P34,P35

	dc.w	line.offset
	dc.w	P35,P36

	dc.w	line.offset
	dc.w	P36,P37


	dc.w	line.offset
	dc.w	P38,P39

	dc.w	line.offset
	dc.w	P39,P42

	dc.w	line.offset
	dc.w	P42,P43

	dc.w	line.offset
	dc.w	P40,P41


	dc.w	sub.object.offset
	dc.w	120


; top - small box

	dc.w	set.fill.colour.offset
	dc.w	green1

	dc.w	polygon.orientation.offset
	dc.w	P14,P18,P19
	dc.w	2+4*2
	dc.w	4
	dc.w	P14,P18,P19,P15

	dc.w	polygon.orientation.offset
	dc.w	P13,P16,P20
	dc.w	2+4*2
	dc.w	4
	dc.w	P13,P16,P20,P17


	dc.w	set.fill.colour.offset
	dc.w	green2

	dc.w	polygon.orientation.offset
	dc.w	P14,P13,P17
	dc.w	2+4*2
	dc.w	4
	dc.w	P14,P13,P17,P18

	dc.w	polygon.orientation.offset
	dc.w	P16,P15,P19
	dc.w	2+4*2
	dc.w	4
	dc.w	P16,P15,P19,P20


	dc.w	set.fill.colour.offset
	dc.w	green3

	dc.w	polygon.orientation.offset
	dc.w	P20,P19,P18
	dc.w	2+4*2
	dc.w	4
	dc.w	P20,P19,P18,P17

	dc.w	end.offset


	dc.w	sub.object.offset
	dc.w	-116


; bottom - main body

	dc.w	set.fill.colour.offset
	dc.w	brown3

	dc.w	polygon.orientation.offset
	dc.w	P3,P2,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P3,P2,P1

	dc.w	polygon.orientation.offset
	dc.w	P4,P6,P5
	dc.w	2+3*2
	dc.w	3
	dc.w	P4,P6,P5

	dc.w	polygon.orientation.offset
	dc.w	P7,P8,P9
	dc.w	2+3*2
	dc.w	3
	dc.w	P7,P8,P9

	dc.w	polygon.orientation.offset
	dc.w	P10,P11,P12
	dc.w	2+3*2
	dc.w	3
	dc.w	P10,P11,P12


	dc.w	set.fill.colour.offset
	dc.w	brown4

	dc.w	polygon.orientation.offset
	dc.w	P3,P1,P6
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P1,P6,P4

	dc.w	polygon.orientation.offset
	dc.w	P7,P9,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P7,P9,P10,P12

	dc.w	polygon.orientation.offset
	dc.w	P3,P4,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P4,P10,P9

	dc.w	polygon.orientation.offset
	dc.w	P1,P7,P12
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P7,P12,P6


	dc.w	set.fill.colour.offset
	dc.w	red1

	dc.w	polygon.orientation.offset
	dc.w	P2,P3,P9
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P3,P9,P8


	dc.w	set.fill.colour.offset
	dc.w	red2

	dc.w	polygon.orientation.offset
	dc.w	P5,P11,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P5,P11,P10,P4


	dc.w	set.fill.colour.offset
	dc.w	yellow

	dc.w	polygon.orientation.offset
	dc.w	P6,P12,P11
	dc.w	2+4*2
	dc.w	4
	dc.w	P6,P12,P11,P5

	dc.w	end.offset



object2	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	13-1

	dc.w	-300,0,450
	dc.w	-300,0,-300
	dc.w	300,0,-300
	dc.w	300,0,450

	dc.w	-240,-600,240
	dc.w	-240,-600,-240
	dc.w	240,-600,-240
	dc.w	240,-600,240

	dc.w	0,-840,0

	dc.w	-240,-840,0
	dc.w	240,-840,0

	dc.w	-300,-1140,0
	dc.w	300,-1140,0


	dc.w	set.fill.colour.offset
	dc.w	brown2

	dc.w	polygon.orientation.offset
	dc.w	P8,P7,P6
	dc.w	74
	dc.w	4
	dc.w	P8,P7,P6,P5


	dc.w	sub.object.offset
	dc.w	66


; head

	dc.w	set.line.colour.offset
	dc.w	yellow*2

	dc.w	set.fill.colour.offset
	dc.w	grey1

	dc.w	component.priority.offset
	dc.w	P10+4,P11+4
	dc.w	6+8+6+2


	dc.w	line.offset
	dc.w	P10,P12

	dc.w	circle.offset
	dc.w	P9
	dc.l	30*1024

	dc.w	line.offset
	dc.w	P11,P13

	dc.w	end.offset


	dc.w	line.offset
	dc.w	P11,P13

	dc.w	circle.offset
	dc.w	P9
	dc.l	30*1024

	dc.w	line.offset
	dc.w	P10,P12

	dc.w	end.offset


	dc.w	sub.object.offset
	dc.w	-62


; body

	dc.w	set.fill.colour.offset
	dc.w	brown4

	dc.w	polygon.orientation.offset
	dc.w	P2,P6,P7
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P6,P7,P3

	dc.w	polygon.orientation.offset
	dc.w	P4,P8,P5
	dc.w	2+4*2
	dc.w	4
	dc.w	P4,P8,P5,P1


	dc.w	set.fill.colour.offset
	dc.w	brown3

	dc.w	polygon.orientation.offset
	dc.w	P1,P5,P6
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P5,P6,P2

	dc.w	polygon.orientation.offset
	dc.w	P3,P7,P8
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P7,P8,P4


	dc.w	set.fill.colour.offset
	dc.w	brown1

	dc.w	polygon.orientation.offset
	dc.w	P1,P2,P3
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P2,P3,P4

	dc.w	end.offset


;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""

dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
joy0dat	equ	$00a
joy1dat	equ	$00c
clxdat	equ	$00e
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01a
intenar	equ	$01c
intreqr	equ	$01e
dskpth	equ	$020
dsklen	equ	$024
copcon	equ	$02e
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltbpth	equ	$04c
bltapth	equ	$050
bltdpth	equ	$054
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07e
cop1lch	equ	$080
cop2lch	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08a
diwstrt	equ	$08e
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09a
intreq	equ	$09c
adkcon	equ	$09e
aud0vol	equ	$0a8
aud1vol	equ	$0b8
aud2vol	equ	$0c8
aud3vol	equ	$0d8
bpl1pth	equ	$0e0
bpl1ptl	equ	$0e2
bpl2pth	equ	$0e4
bpl2ptl	equ	$0e6
bpl3pth	equ	$0e8
bpl3ptl	equ	$0ea
bpl4pth	equ	$0ec
bpl4ptl	equ	$0ee
bpl5pth	equ	$0f0
bpl5ptl	equ	$0f2
bpl6pth	equ	$0f4
bpl6ptl	equ	$0f6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10a
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12a
spr3pth	equ	$12c
spr3ptl	equ	$12e
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13a
spr7pth	equ	$13c
spr7ptl	equ	$13e
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14a
spr2ctl	equ	$152
spr3ctl	equ	$15a
spr4ctl	equ	$162
spr5ctl	equ	$16a
spr6ctl	equ	$172
spr7ctl	equ	$17a
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
color16	equ	$1a0
