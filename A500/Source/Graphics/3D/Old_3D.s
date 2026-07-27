	section	3D,code_c
	opt	o+,o3-


ZINC	equ	6
YINC	equ	3
XINC	equ	4

ENDFRAME	equ	244


start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	move.l	#64000,d0	allocate screen memory
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)	AllocMem
	tst.l	d0
	beq	end
	move.l	d0,screen1
	add.l	#32000,d0
	move.l	d0,screen2

	lea	$dff000,a5

	move.w	intenar(a5),ints	save system interrupt status
	move.w	#$7fff,intena(a5)	disable all interrupts
	move.b	#%01111111,$bfed01	disable keyboard

	move.w	#$01e0,dmacon(a5)	DMA off

	move.l	screen1,d0		set up screen1 bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp2l
	swap	d0
	move.w	d0,bp2h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp3l
	swap	d0
	move.w	d0,bp3h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp4l
	swap	d0
	move.w	d0,bp4h

	lea	coltab,a0	initialise colours
	lea	colours(pc),a1
	move.w	#color0,d1
	moveq	#15,d0
nextc	move.w	d1,(a1)+
	addq.w	#2,d1
	move.w	(a0)+,(a1)+
	dbra	d0,nextc


	move.l	screen2,d0		set up screen2 bitplanes
	move.w	d0,bp1l2
	swap	d0
	move.w	d0,bp1h2
	swap	d0
	add.l	#40,d0

	move.w	d0,bp2l2
	swap	d0
	move.w	d0,bp2h2
	swap	d0
	add.l	#40,d0

	move.w	d0,bp3l2
	swap	d0
	move.w	d0,bp3h2
	swap	d0
	add.l	#40,d0

	move.w	d0,bp4l2
	swap	d0
	move.w	d0,bp4h2

	lea	coltab,a0	initialise colours
	lea	colours2(pc),a1
	move.w	#color0,d1
	moveq	#15,d0
nextc2	move.w	d1,(a1)+
	addq.w	#2,d1
	move.w	(a0)+,(a1)+
	dbra	d0,nextc2


	move.w	#$4200,bplcon0(a5)	set up screen
	move.w	#$2c81,diwstrt(a5)
	move.w	#$f4c1,diwstop(a5)
	move.w	#$38,ddfstrt(a5)
	move.w	#$d0,ddfstop(a5)
	move.w	#0,bplcon1(a5)
	move.w	#0,bplcon2(a5)
	move.w	#120,bpl1mod(a5)
	move.w	#120,bpl2mod(a5)


;"""""""""""""""""""""""""""""""""""""""""""""
;	SET UP SPRITE POINTERS
;
	move.l	#sprite0,d0
	move.w	d0,sp0l
	move.w	d0,sp0l2
	swap	d0
	move.w	d0,sp0h
	move.w	d0,sp0h2
	move.l	#sprite1,d0
	move.w	d0,sp1l
	move.w	d0,sp1l2
	swap	d0
	move.w	d0,sp1h
	move.w	d0,sp1h2
	move.l	#sprite2,d0
	move.w	d0,sp2l
	move.w	d0,sp2l2
	swap	d0
	move.w	d0,sp2h
	move.w	d0,sp2h2
	move.l	#sprite3,d0
	move.w	d0,sp3l
	move.w	d0,sp3l2
	swap	d0
	move.w	d0,sp3h
	move.w	d0,sp3h2
	move.l	#sprite4,d0
	move.w	d0,sp4l
	move.w	d0,sp4l2
	swap	d0
	move.w	d0,sp4h
	move.w	d0,sp4h2
	move.l	#sprite5,d0
	move.w	d0,sp5l
	move.w	d0,sp5l2
	swap	d0
	move.w	d0,sp5h
	move.w	d0,sp5h2
	move.l	#sprite6,d0
	move.w	d0,sp6l
	move.w	d0,sp6l2
	swap	d0
	move.w	d0,sp6h
	move.w	d0,sp6h2
	move.l	#sprite7,d0
	move.w	d0,sp7l
	move.w	d0,sp7l2
	swap	d0
	move.w	d0,sp7h
	move.w	d0,sp7h2


;""""""""""""""""""""""""""""""""""""""""""""
;	SET THE NEW COPPER LOCATION


	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,a1
	move.l	38(a1),oldcopper
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$81e0,dmacon(a5)	DMA on (bitplane, copper,
;						blitter, sprite)

;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.l	#199,d0		count
	moveq	#0,d1		offset starts at zero
	move.w	#160,d2		bytes per line = 160
	lea	ytable,a0
ytab	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,ytab


;""""""""""""""""""
;" ANIMATION LOOP "
;"		  "
;""""""""""""""""""

	bsr	rotpers		set up first screen
	move.l	screen1,SCREEN
	bsr	sdraw

	addq.w	#ZINC,ZANGLE	set up second screen
	addq.w	#YINC,YANGLE
	addq.w	#XINC,XANGLE
	bsr	rotpers
	move.l	screen2,SCREEN
	bsr	sdraw

wait	cmp.b	#ENDFRAME,vhposr(a5)
	bne.s	wait
	move.l	#new2,cop1lc(a5)
	clr.w	copjmp1(a5)

animloop
	move.l	screen1,SCREEN	animation loop starts here
	bsr	clear
	addq.w	#ZINC,ZANGLE
	cmp.w	#360,ZANGLE
	ble.s	zok
	sub.w	#360,ZANGLE
zok	addq.w	#YINC,YANGLE
	cmp.w	#360,YANGLE
	ble.s	yok
	sub.w	#360,YANGLE
yok	addq.w	#XINC,XANGLE
	cmp.w	#360,XANGLE
	ble.s	xok
	sub.w	#360,XANGLE
xok	bsr	rotpers
	bsr	sdraw

wait2	cmp.b	#ENDFRAME,vhposr(a5)
	bne.s	wait2
	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.l	screen2,SCREEN
	bsr	clear
 	addq.w	#ZINC,ZANGLE
	cmp.w	#360,ZANGLE
	ble.s	zok2
	sub.w	#360,ZANGLE
zok2	addq.w	#YINC,YANGLE
	cmp.w	#360,YANGLE
	ble.s	yok2
	sub.w	#360,YANGLE
yok2	addq.w	#XINC,XANGLE
	cmp.w	#360,XANGLE
	ble.s	xok2
	sub.w	#360,XANGLE
xok2	bsr	rotpers
	bsr	sdraw

wait3	cmp.b	#ENDFRAME,vhposr(a5)
	bne.s	wait3
	move.l	#new2,cop1lc(a5)
	clr.w	copjmp1(a5)
	btst	#6,$bfe001
	bne	animloop


	move.l	oldcopper,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.w	ints,d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a5)		restore system interrupt status
	move.b	#%10011011,$bfed01	enable keyboard

	move.l	screen1,a1
	move.l	#64000,d0
	move.l	4.w,a6
	jsr	-210(a6)	FreeMem

end	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.w	#$f,dmacon(a5)	sound off
	clr.w	aud0vol(a5)
	clr.w	aud1vol(a5)
	clr.w	aud2vol(a5)
	clr.w	aud3vol(a5)
	bclr	#1,$bfe001	low pass filter on
	clr.l	d0
	rts


;""""""""""""""""""""""""""""""""""""""""
;" Maths routines - rotate point about	"
;" X, Y, Z axes by XANGLE, YANGLE and	"
;" ZANGLE respectively.  Rotations are	"
;" anti-clockwise.			"
;"					"
;" The formulae used are:-		"
;"					"
;" X rotation:	X = X			"
;"		Y2 = Ycos - Zsin	"
;"		Z2 = Ysin + Zcos	"
;"					"
;" Y rotation:	X2 = Xcos + Z2sin	"
;"		Y2 = Y2			"
;"		Z3 = Z2cos - Xsin	"
;"					"
;" Z rotation:	X3 = X2cos - Y2sin	"
;"		Y3 = X2sin + Y2cos	"
;"		Z3 = Z3			"
;"					"
;" Also calculate perspective - from X, "
;" Y, Z world co-ords to X, Y screen	"
;" co-ords.				"
;"					"
;""""""""""""""""""""""""""""""""""""""""

rotpers	movem.l	d0-d7/a0-a4,-(sp)
	moveq	#0,d0
	lea	sintab,a0
	lea	costab,a1
	move.w	XANGLE,d0	get sine and cosine of XANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),XSIN	sine
	move.w	(a1,d0.w),XCOS	cosine

	move.w	YANGLE,d0	get sine and cosine of YANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),YSIN	sine
	move.w	(a1,d0.w),YCOS	cosine

	move.w	ZANGLE,d0	get sine and cosine of ZANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),ZSIN	sine
	move.w	(a1,d0.w),ZCOS	cosine

	lea	worldX,a0
	lea	worldY,a1
	lea	worldZ,a2
	lea	scrX,a3
	lea	scrY,a4
	move.w	numpoints,d0
	moveq	#14,d4

rploop	move.w	XSIN,d1		x rotation
	move.w	XCOS,d2
	move.w	(a1),d3	y
	muls	d3,d2	y cos
	move.w	(a2),d3 z
	muls	d3,d1	z sin
	sub.l	d1,d2	y cos-z sin
	lsr.l	d4,d2
	move.w	d2,d6	y2

	move.w	XSIN,d1
	move.w	XCOS,d2
	move.w	(a1)+,d3 y
	muls	d3,d1	y sin
	move.w	(a2)+,d3 z
	muls	d3,d2	z cos
	add.l	d1,d2	y sin+z cos
	lsr.l	d4,d2
	move.w	d2,d7	z2

	move.w	YSIN,d1		y rotation
	move.w	YCOS,d2
	move.w	(a0),d3	x
	muls	d3,d2	x cos
	muls	d7,d1	z2 sin
	add.l	d1,d2	x cos+z2 sin
	lsr.l	d4,d2
	move.w	d2,d5	x2

	move.w	YSIN,d1
	move.w	YCOS,d2
	move.w	(a0)+,d3 x
	muls	d3,d1	x sin
	muls	d7,d2	z2 cos
	sub.l	d1,d2	z2 cos-x sin
	lsr.l	d4,d2	z3

	move.w	ZSIN,d1		z rotation
	move.w	ZCOS,d3
	muls	d6,d1	y2 sin
	muls	d5,d3	x2 cos
	sub.l	d1,d3	x2 cos-y2 sin
	lsr.l	d4,d3	x3

	move.w	ZSIN,d1
	move.w	ZCOS,d7
	muls	d5,d1	x2 sin
	muls	d6,d7	y2 cos
	add.l	d1,d7	x2 sin+y2 cos
	lsr.l	d4,d7	y3


	move.w	d2,d1		now calculate perpective

	muls	d3,d1		xz
	lsr.l	#8,d1		xz/256
	add.w	d1,d3		x + xz/256
	move.w	d3,(a3)+	x value

	muls	d7,d2		yz
	lsr.l	#8,d2		yz/256
	add.w	d2,d7		y + yz/256
	move.w	d7,(a4)+	y value

	dbra	d0,rploop
	movem.l	(sp)+,d0-d7/a0-a4
	rts


;"""""""""""""""""""""""""
;" Screen clear routine. "
;"			 "
;"""""""""""""""""""""""""

clear	btst	#6,dmaconr(a5)		wait until blitter finished
	bne.s	clear
	move.l	SCREEN,bltdpth(a5)	destination D
	move.w	#$100,bltcon0(a5)	enable channel D only
	moveq	#0,d0
	move.w	d0,bltcon1(a5)
	move.w	d0,bltdmod(a5)		no modulo
	move.w	#$c814,bltsize(a5)	800 high, 20 words wide
	rts


;""""""""""""""""""""""""""""""""""""""
;" Routine to draw wireframe objects. "
;"				      "
;""""""""""""""""""""""""""""""""""""""

wdraw	move.l	SCREEN,a0
	lea	lines,a1
	move.w	numlines,d7
	move.l	#scrX,a2	list of screen x co-ords
	move.l	#scrY,a3	list of screen y co-ords

wdrawloop
	moveq	#0,d4
	move.b	(a1)+,d4	next point
	lsl.w	#1,d4		multiply by 2

	move.w	(a2,d4.w),d0
	add.w	Xorg,d0		x start
	move.w	(a3,d4.w),d4		
	move.w	Yorg,d1
	sub.w	d4,d1	Yorg-y start  (quicker than:- 200-(y start+100)

	moveq	#0,d5
	move.b	(a1)+,d5	next point
	lsl.w	#1,d5		multiply by 2

	move.w	(a2,d5.w),d2
	add.w	Xorg,d2		x end
	move.w	(a3,d5.w),d4
	move.w	Yorg,d3
	sub.w	d4,d3	Yorg-y end  (quicker than:- 200-(y end+100)

	bsr.s	drawline
	dbra	d7,wdrawloop
	rts


* Drawline routine *

drawline
	moveq	#0,d6	clear this for later
	move.w	#160,d4	width of screen in bytes
	mulu	d1,d4
	moveq	#-16,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4

	clr.l	d5
	sub.w	d1,d3
	bne.s	netz1	Addition to check for dx & dy both being
;			equal to zero.  If this is not done then
;			a line 1024 pixels high will be produced
;			instead of a single pixel.
	moveq	#1,d6
netz1	roxl.b	#1,d5
	tst.w	d3
	bge.s	y2gy1
	neg.w	d3
y2gy1
	sub.w	d0,d2
	bne.s	netz2	Check for dx being equal to zero.
	cmpi.b	#1,d6	equal to zero also?
	bne.s	netz2
	moveq	#1,d2	if both equal to zero then set dx to 1
netz2	roxl.b	#1,d5
	tst.w	d2
	bge.s	x2gx1
	neg.w	d2
x2gx1
	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx	roxl.b	#1,d5
	lea	octant_table,a4
	move.b	(a4,d5),d5
	add.w	d2,d2

bltfin	btst	#6,dmaconr(a5)
	bne.s	bltfin

	move.w	d2,bltbmod(a5)
	sub.w	d3,d2
	bge.s	signal

	or.b	#$40,d5
signal	move.w	d2,bltaptl(a5)

	sub.w	d3,d2
	move.w	d2,bltamod(a5)

	move.w	#$8000,bltadat(a5)
	move.w	#$ffff,bltbdat(a5)
	move.w	#$ffff,bltafwm(a5)
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,bltcon0(a5)
	move.w	d5,bltcon1(a5)
	move.l	d4,bltcpth(a5)
	move.l	d4,bltdpth(a5)
	move.w	#160,d0
	move.w	d0,bltcmod(a5)
	move.w	d0,bltdmod(a5)

	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a5)
	rts

octant_table
	dc.b	0*4+1
	dc.b	4*4+1
	dc.b	2*4+1
	dc.b	5*4+1
	dc.b	1*4+1
	dc.b	6*4+1
	dc.b	3*4+1
	dc.b	7*4+1


;""""""""""""""""""""""""""""""""""
;" Routine to draw solid objects. "
;"				  "
;""""""""""""""""""""""""""""""""""

sdraw	lea	scrX,a0
	lea	scrY,a1
	lea	trilist,a2	list of triangle pointers
	move.l	numtris,d7

sloop	move.l	d7,number
	move.l	(a2),a3		get pointer to triangle
	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d0	get x1
	move.w	(a1,d6.w),d1	get y1

	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d2	get x2
	move.w	(a1,d6.w),d3	get y2

	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d4	get x3
	move.w	(a1,d6.w),d5	get y3

	sub.w	d2,d4		calculate orientation of triangle
	sub.w	d3,d5		i.e. anti-clockwise or clockwise
	sub.w	d0,d2
	sub.w	d1,d3
	muls	d2,d5
	muls	d4,d3
	sub.l	d3,d5		only draw if triangle is anticlockwise
	ble.s	nodraw		i.e. result is greater than zero

	move.l	(a2),a3		get pointer to triangle
	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d0
	add.w	Xorg,d0		get x1
	move.w	(a1,d6.w),d7
	move.w	Yorg,d1
	sub.w	d7,d1		get y1	(quicker than:- 200-(y1+100)

	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d2
	add.w	Xorg,d2		get x2
	move.w	(a1,d6.w),d7
	move.w	Yorg,d3
	sub.w	d7,d3		get y2	(quicker than:- 200-(y1+100)

	move.w	(a3)+,d6
	lsl.w	#1,d6
	move.w	(a0,d6.w),d4
	add.w	Xorg,d4		get x3
	move.w	(a1,d6.w),d7
	move.w	Yorg,d5
	sub.w	d7,d5		get y3	(quicker than:- 200-(y1+100)

	move.w	(a3)+,tricolour
	bsr.s	triangle

nodraw	lea	4(a2),a2	update pointer to next triangle
	move.l	number,d7
	dbf	d7,sloop
bltfin2	btst	#6,dmaconr(a5)
	bne.s	bltfin2
	rts

number	dc.l	0


;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
;"	  THIS ROUTINE DRAWS A TRIANGLE OF ANY SHAPE OR SIZE.	     "
;"								     "
;" d0 = x1, d1 = y1    ;    d2 = x2, d3 = y2    ;   d4 = x3, d5 = y3 "
;"								     "
;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

triangle
	movem.l	d0-d7/a0-a3,-(sp)
	bsr	sorty
	lea	coords,a0
	cmp.w	d1,d3
	beq	y1eqy2
	cmp.w	d3,d5
	beq	y2eqy3
	move.w	d0,(a0)+	pixel from x1
	move.w	d0,(a0)+	to x1
	bsr	calcgrads
	move.l	d7,G2
	cmp.l	d6,d7
	bgt.s	incsok
	exg	d6,d7
incsok	move.w	Y2Y1,d5
	subq.w	#1,d5
	ext.l	d5		count1
	swap	d0		x1*65536 - start value
	move.l	d0,d1		x1*65536 - also end value
triloop	add.l	d6,d0		update start value
	add.l	d7,d1		update end value
	move.l	d0,d2
	move.l	d1,d3
	swap	d0		x start
	swap	d1		x end
	move.w	d0,(a0)+	into list
	move.w	d1,(a0)+	into list
	move.l	d2,d0
	move.l	d3,d1
	dbra	d5,triloop

	move.l	G3,d6
	move.l	G2,d7
	cmp.l	d6,d7
	blt.s	incsok2
	exg	d6,d7
incsok2	move.w	Y3Y2,d5
	subq.w	#1,d5
	ext.l	d5		count2
triloop2
	add.l	d6,d0		update start value
	add.l	d7,d1		update end value
	move.l	d0,d2
	move.l	d1,d3
	swap	d0		x start
	swap	d1		x end
	move.w	d0,(a0)+	into list
	move.w	d1,(a0)+	into list
	move.l	d2,d0
	move.l	d3,d1
	dbra	d5,triloop2

	move.w	Y3Y1,d0
	ext.l	d0		count
	move.w	Y1,d1		start y
	move.w	tricolour,d2	colour
	lea	coords,a0
	bsr	fill
	bra	trirts


sorty	cmp.w	d3,d1
	blt.s	sorty1
	exg	d3,d1
	exg	d2,d0
sorty1	cmp.w	d5,d3
	blt.s	sortyok
	cmp.w	d5,d1
	blt.s	sortymid
	exg	d5,d1
	exg	d4,d0
	exg	d5,d3
	exg	d4,d2
	rts
sortymid
	exg	d5,d3
	exg	d4,d2
sortyok	rts


sortx	cmp.w	d2,d0
	blt.s	sortx1
	exg	d2,d0
sortx1	cmp.w	d4,d2
	blt.s	sortxok
	cmp.w	d4,d0
	blt.s	sortxmid
	exg	d4,d0
	exg	d4,d2
	rts
sortxmid
	exg	d4,d2
sortxok	rts


y1eqy2	cmp.w	d3,d5
	beq	triline
	cmp.w	d0,d2
	bge.s	trixok
	exg	d0,d2
trixok	bsr	calcgrads2
	move.w	Y3Y1,d5
	subq.w	#1,d5
	ext.l	d5		count
	move.w	d0,(a0)+	into list
	move.w	d2,(a0)+	into list
	swap	d0		x1*65536 - start value
	swap	d2		x2*65536 - end value
triloop3
	add.l	d6,d0		update start value
	add.l	d7,d2		update end value
	move.l	d0,d1
	move.l	d2,d3
	swap	d0		x start
	swap	d2		x end
	move.w	d0,(a0)+	into list
	move.w	d2,(a0)+	into list
	move.l	d1,d0
	move.l	d3,d2
	dbra	d5,triloop3

	move.w	Y3Y1,d0
	ext.l	d0	count
	move.w	Y1,d1	start y
	move.w	tricolour,d2	colour
	lea	coords,a0
	bsr	fill
	bra.s	trirts


y2eqy3	move.w	d0,(a0)+	pixel from x1
	move.w	d0,(a0)+	to x1
	cmp.w	d2,d4
	bge.s	trixok2
	exg	d2,d4
trixok2	bsr	calcgrads3
	move.w	Y2Y1,d5
	subq.w	#1,d5
	ext.l	d5		count
	swap	d0		x1*65536 - start value
	move.l	d0,d1		x1*65536 - also end value
triloop4
	add.l	d6,d0		update start value
	add.l	d7,d1		update end value
	move.l	d0,d2
	move.l	d1,d3
	swap	d0		x start
	swap	d1		x end
	move.w	d0,(a0)+	into list
	move.w	d1,(a0)+	into list
	move.l	d2,d0
	move.l	d3,d1
	dbra	d5,triloop4

	move.w	Y2Y1,d0
	ext.l	d0	count
	move.w	Y1,d1	start y
	move.w	tricolour,d2	colour
	lea	coords,a0
	bsr	fill
	bra.s	trirts


triline	bsr	sortx
	move.w	d0,(a0)+	start of line
	move.w	d4,(a0)+	end of line
	moveq	#0,d0	count
	move.w	tricolour,d2	colour
	lea	coords,a0
	bsr	fill


trirts	movem.l	(sp)+,d0-d7/a0-a3
	rts

tricolour	dc.w	0


;""""""""""""""""""""""""""""""""""""""""""""
;" THIS ROUTINE CALCULATES THE GRADIENTS OF "
;" THE THREE SIDES THAT MAKE THE TRIANGLE.  "
;"					    "
;" A TABLE IS USED TO AVOID THE SLOW DIVIDE "
;" INSTRUCTION.				    "
;"					    "
;""""""""""""""""""""""""""""""""""""""""""""

calcgrads
	lea	gradtable,a1		;d0 = x1, d1 = y1
	move.w	d1,Y1			;d2 = x2, d3 = y2
	move.w	d2,X2			;d4 = x3, d5 = y3
	move.w	d3,Y2
	move.w	d4,X3
	move.w	d5,Y3
	sub.w	d0,d2		x2-x1
	sub.w	d1,d3		y2-y1
	move.w	d3,Y2Y1		save for later
	cmpi.w	#1,d3		check for dy = 1
	beq.s	dy1eq1
	lsl.w	#1,d3		words into table
	move.w	(a1,d3.w),d6	value from table
	muls	d2,d6		gradient G1
	bra.s	grad2
dy1eq1	move.w	d2,d6
	swap	d6
	move.w	#0,d6		(x2-x1)*65536 - gradient G1

grad2	sub.w	d0,d4		x3-x1
	sub.w	d1,d5		y3-y1
	move.w	d5,Y3Y1		save for later
	cmpi.w	#1,d5		check for dy = 1
	beq.s	dy2eq1
	lsl.w	#1,d5		words into table
	move.w	(a1,d5.w),d7	value from table
	muls	d4,d7		gradient G2
	bra.s	grad3
dy2eq1	move.w	d4,d7
	swap	d7
	move.w	#0,d7		(x3-x1)*65536 - gradient G2

grad3	move.w	X3,d4
	sub.w	X2,d4		x3-x2
	move.w	Y3,d5
	sub.w	Y2,d5		y3-y2
	move.w	d5,Y3Y2		save for later
	cmpi.w	#1,d5		check for dy = 1
	beq.s	dy3eq1
	lsl.w	#1,d5		words into table
	move.w	(a1,d5.w),d5	value from table
	muls	d4,d5		gradient G3
	bra.s	endgrad
dy3eq1	move.w	d4,d5
	swap	d5
	move.w	#0,d5		(x3-x2)*65536 - gradient G3
endgrad	move.l	d5,G3		save for later
	rts


calcgrads2
	lea	gradtable,a1		;d0 = x1, d1 = y1
	move.w	d1,Y1			;d2 = x2, d3 = y2
	move.w	d4,X3			;d4 = x3, d5 = y3
	move.w	d5,Y3
	sub.w	d0,d4		x3-x1
	sub.w	d1,d5		y3-y1
	move.w	d5,Y3Y1		save for later
	cmpi.w	#1,d5		check for dy = 1
	beq.s	dy4eq1
	lsl.w	#1,d5		words into table
	move.w	(a1,d5.w),d6	value from table
	muls	d4,d6		gradient G2
	bra.s	grad4
dy4eq1	move.w	d4,d6
	swap	d6
	move.w	#0,d6		(x3-x1)*65536 - gradient G2

grad4	move.w	X3,d4
	sub.w	d2,d4		x3-x2
	move.w	Y3,d5
	sub.w	d3,d5		y3-y2
	cmpi.w	#1,d5		check for dy = 1
	beq.s	dy5eq1
	lsl.w	#1,d5		words into table
	move.w	(a1,d5.w),d7	value from table
	muls	d4,d7		gradient G3
	rts
dy5eq1	move.w	d4,d7
	swap	d7
	move.w	#0,d7		(x3-x2)*65536 - gradient G3
	rts


calcgrads3				;d0 = x1, d1 = y1
	lea	gradtable,a1		;d2 = x2, d3 = y2
	move.w	d1,Y1			;d4 = x3, d5 = y3
	sub.w	d0,d2		x2-x1
	sub.w	d1,d3		y2-y1
	move.w	d3,Y2Y1		save for later
	cmpi.w	#1,d3		check for dy = 1
	beq.s	dy6eq1
	lsl.w	#1,d3		words into table
	move.w	(a1,d3.w),d6	value from table
	muls	d2,d6		gradient G1
	bra.s	grad5
dy6eq1	move.w	d2,d6
	swap	d6
	move.w	#0,d6		(x2-x1)*65536 - gradient G1

grad5	sub.w	d0,d4		x3-x1
	sub.w	d1,d5		y3-y1
	cmpi.w	#1,d5		check for dy = 1
	beq.s	dy7eq1
	lsl.w	#1,d5		words into table
	move.w	(a1,d5.w),d7	value from table
	muls	d4,d7		gradient G2
	rts
dy7eq1	move.w	d4,d7
	swap	d7
	move.w	#0,d7		(x3-x1)*65536 - gradient G2
	rts


Y1	dc.w	0
X2	dc.w	0
Y2	dc.w	0
X3	dc.w	0
Y3	dc.w	0
Y2Y1	dc.w	0
Y3Y1	dc.w	0
Y3Y2	dc.w	0
G2	dc.l	0
G3	dc.l	0


;""""""""""""""""""""""""""""""""""""""""""""""""""""
;" THE TABLE USED FOR THE ABOVE GRADIENT ROUTINES.  "
;"						    "
;" THE TABLE CONSISTS OF 256 VALUES, ONE FOR EACH   "
;" POSSIBLE VALUE OF Y DELTA (CHANGE IN Y).	    "
;" THE VALUES ARE 65536/Y WHERE Y IS FROM 0 TO 255  "
;" THE GRADIENT ROUTINE THEN MULTIPLIES THIS	    "
;" VALUE BY THE X DELTA (CHANGE IN X) TO GIVE THE   "
;" GRADIENT*65536.				    "
;" THE REASON WHY THE GRADIENT IS MULTIPLIED BY	    "
;" 65536 IS BECAUSE THE 68000 CANNOT WORK WITH	    "
;" FRACTIONS OF WHOLE NUMBERS SO THIS MAINTAINS	    "
;" THE ACCURACY WE NEED.			    "
;"						    "
;" NOTE THAT FOR Y=1 THE TABULATED VALUE IS 0 AND   "
;" THIS VALUE IS NOT USED BECAUSE 65536 CANNOT BE   "
;" STORED AS A WORD VALUE AND THE CLOSEST NUMBER TO "
;" THIS IS 65535 WHICH IS TAKEN TO BE NEGATIVE (-1) "
;" BY THE PROCESSOR.				    "
;" ALSO THE VALUE FOR Y=2 IS 32767 INSTEAD OF 32768 "
;" BECAUSE THE PROCESSOR TAKES 32768 ($8000) AS	    "
;" NEGATIVE WHEN IT PERFORMS A SIGNED MULTIPLY.	    "
;"						    "
;""""""""""""""""""""""""""""""""""""""""""""""""""""

gradtable
	dc.w	0	this value is here to correctly align the gradient
;			table, it is not used by these routines and would
;			contain the value for a delta y of 0, which is
;			infinite, and is therefore handled by other routines
	dc.w	0,32767,21845,16384,13107,10923,9362,8192,7282
	dc.w	6554,5958,5461,5041,4681,4369,4096,3855,3641,3449
	dc.w	3277,3121,2979,2849,2731,2621,2521,2427,2341,2260
	dc.w	2185,2114,2048,1986,1928,1872,1820,1771,1725,1680
	dc.w	1638,1598,1560,1524,1489,1456,1425,1394,1365,1337
	dc.w	1311,1285,1260,1237,1214,1192,1170,1150,1130,1130
	dc.w	1092,1074,1057,1040,1024,1008,993,978,964,950
	dc.w	936,923,910,898,886,874,862,851,840,830
	dc.w	819,809,799,790,780,771,762,753,745,736
	dc.w	728,720,712,705,697,690,683,676,669,662
	dc.w	655,649,643,636,630,624,618,612,607,601
	dc.w	596,590,585,580,575,570,565,560,555,551
	dc.w	546,542,537,533,529,524,520,516,512,508
	dc.w	504,500,496,493,489,485,482,478,475,471
	dc.w	468,465,462,458,455,452,449,446,443,440
	dc.w	437,434,431,428,426,423,420,417,415,412
	dc.w	410,407,405,402,400,397,395,392,390,388
	dc.w	386,383,381,379,377,374,372,370,368,366
	dc.w	364,362,360,358,356,354,352,350,349,347
	dc.w	345,343,341,340,338,336,334,333,331,329
	dc.w	328,326,324,323,321,320,318,317,315,314
	dc.w	312,311,309,308,306,305,303,302,301,299
	dc.w	298,297,295,294,293,291,290,289,287,286
	dc.w	285,284,282,281,280,279,278,277,275,274
	dc.w	273,272,271,270,269,267,266,265,264,263
	dc.w	262,261,260,259,258,257


;""""""""""""""""""""""""""""""""""""""""
;	" THE FILL ROUTINE "	d0 = count-1 ;  d1 = ystart
;	"		   "	d2 = colour ;  a0 = address of coord list
;	""""""""""""""""""""

fill	lea	table,a2
	lsl.w	#2,d2
	move.l	(a2,d2.w),a2	set source B for colour
	move.l	SCREEN,a3
	lea	ytable,a1
	lsl.w	#1,d1
	move.w	(a1,d1.w),d1	bytes into plane
	lea	(a3,d1.w),a3	correct starting row
bltfin3	btst	#6,dmaconr(a5)
	bne.s	bltfin3
	move.w	#$7ca,bltcon0(a5)	Use B,C,D
	move.w	#0,bltcon1(a5)		nothing active
	move.w	#$ffff,bltadat(a5)	mask for fill
	moveq	#$f,d1
	move.w	#40,d7		width of one plane

floop	movem.w	(a0)+,d2-d3	get x1 and x2
	move.w	d2,d4
	lsr.w	#4,d2		number of words for x1
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	first,a1
	move.w	(a1,d4.w),d5	get first word mask
	swap	d5
	move.w	d3,d4
	lsr.w	#4,d3		number of words for x2
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	last,a1
	move.w	(a1,d4.w),d5	get last word mask
	sub.w	d2,d3		(x2 words) - (x1 words)
	blt.s	next		if negative then miss it out
	lsl.w	#1,d2		start offset in bytes
	lea	(a3,d2.w),a1	start address of fill
	addq.w	#1,d3		width of fill in words
	move.w	d3,d4
	addi.w	#$100,d4	width + (height of 4)
	lsl.w	#1,d3		width in bytes
	neg.w	d3
	add.w	d7,d3		modulo value
bltfin4	btst	#6,dmaconr(a5)
	bne.s	bltfin4
	movem.l	d5/a1-a2,bltafwm(a5)	set mask, source C, source B
	move.w	d3,bltcmod(a5)		modulo for C
	move.w	d3,bltbmod(a5)		modulo for B
	move.w	d3,bltdmod(a5)		modulo for D
	move.l	a1,bltdpth(a5)		set source D
	move.w	d4,bltsize(a5)		start blitter
next	add.l	#160,a3		next row
	dbf	d0,floop
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LISTS "
;	"		   "
;	""""""""""""""""""""

new	dc.w	bpl1pth		4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0,spr0pth	set up sprite pointers now
sp0h	dc.w	0,spr0ptl
sp0l	dc.w	0,spr1pth
sp1h	dc.w	0,spr1ptl
sp1l	dc.w	0,spr2pth
sp2h	dc.w	0,spr2ptl
sp2l	dc.w	0,spr3pth
sp3h	dc.w	0,spr3ptl
sp3l	dc.w	0,spr4pth
sp4h	dc.w	0,spr4ptl
sp4l	dc.w	0,spr5pth
sp5h	dc.w	0,spr5ptl
sp5l	dc.w	0,spr6pth
sp6h	dc.w	0,spr6ptl
sp6l	dc.w	0,spr7pth
sp7h	dc.w	0,spr7ptl
sp7l	dc.w	0

colours	ds.w	32

	dc.w	$ffff,$fffe	END


new2	dc.w	bpl1pth		4 bitplane display
bp1h2	dc.w	0,bpl1ptl
bp1l2	dc.w	0,bpl2pth
bp2h2	dc.w	0,bpl2ptl
bp2l2	dc.w	0,bpl3pth
bp3h2	dc.w	0,bpl3ptl
bp3l2	dc.w	0,bpl4pth
bp4h2	dc.w	0,bpl4ptl
bp4l2	dc.w	0,spr0pth	set up sprite pointers now
sp0h2	dc.w	0,spr0ptl
sp0l2	dc.w	0,spr1pth
sp1h2	dc.w	0,spr1ptl
sp1l2	dc.w	0,spr2pth
sp2h2	dc.w	0,spr2ptl
sp2l2	dc.w	0,spr3pth
sp3h2	dc.w	0,spr3ptl
sp3l2	dc.w	0,spr4pth
sp4h2	dc.w	0,spr4ptl
sp4l2	dc.w	0,spr5pth
sp5h2	dc.w	0,spr5ptl
sp5l2	dc.w	0,spr6pth
sp6h2	dc.w	0,spr6ptl
sp6l2	dc.w	0,spr7pth
sp7h2	dc.w	0,spr7ptl
sp7l2	dc.w	0

colours2	ds.w	32

	dc.w	$ffff,$fffe	END


;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ   $000
dmaconr	equ   $002
vposr	equ   $004
vhposr	equ   $006
dskdatr	equ   $008
joy0dat	equ   $00A
joy1dat	equ   $00C
clxdat	equ   $00E
adkconr	equ   $010
pot0dat	equ   $012
pot1dat	equ   $014
potinp	equ   $016
serdatr	equ   $018
dskbytr	equ   $01A
intenar	equ   $01C
intreqr	equ   $01E
dskpt	equ   $020
dsklen	equ   $024
dskdat	equ   $026
refptr	equ   $028
vposw	equ   $02A
vhposw	equ   $02C
copcon	equ   $02E
serdat	equ   $030
serper	equ   $032
potgo	equ   $034
joytest	equ   $036
strequ	equ   $038
strvbl	equ   $03A
strhor	equ   $03C
strlong	equ   $03E
bltcon0	equ   $040
bltcon1	equ   $042
bltafwm	equ   $044
bltalwm	equ   $046
bltcpth	equ   $048
bltcptl equ   $04A
bltbpth	equ   $04C
bltbptl equ   $04E
bltapth	equ   $050
bltaptl equ   $052
bltdpth	equ   $054
bltdptl equ   $056
bltsize	equ   $058
bltcmod	equ   $060
bltbmod	equ   $062
bltamod	equ   $064
bltdmod	equ   $066
bltcdat	equ   $070
bltbdat	equ   $072
bltadat	equ   $074
dsksync	equ   $07E
cop1lc	equ   $080
cop2lc	equ   $084
copjmp1	equ   $088
copjmp2	equ   $08A
copins	equ   $08C
diwstrt	equ   $08E
diwstop	equ   $090
ddfstrt	equ   $092
ddfstop	equ   $094
dmacon	equ   $096
clxcon	equ   $098
intena	equ   $09A
intreq	equ   $09C
adkcon	equ   $09E
aud0vol	equ   $0A8
aud1vol equ   $0B8
aud2vol	equ   $0C8
aud3vol	equ   $0D8
bpl1pth	equ   $0E0
bpl1ptl	equ   $0E2
bpl2pth	equ   $0E4
bpl2ptl	equ   $0E6
bpl3pth	equ   $0E8
bpl3ptl	equ   $0EA
bpl4pth	equ   $0EC
bpl4ptl	equ   $0EE
bpl5pth	equ   $0F0
bpl5ptl	equ   $0F2
bpl6pth	equ   $0F4
bpl6ptl	equ   $0F6
bplcon0	equ   $100
bplcon1	equ   $102
bplcon2	equ   $104
bpl1mod	equ   $108
bpl2mod	equ   $10A
bpldat	equ   $110
spr0pth	equ   $120
spr0ptl equ   $122
spr1pth equ   $124
spr1ptl equ   $126
spr2pth	equ   $128
spr2ptl equ   $12A
spr3pth equ   $12C
spr3ptl equ   $12E
spr4pth	equ   $130
spr4ptl equ   $132
spr5pth equ   $134
spr5ptl equ   $136
spr6pth	equ   $138
spr6ptl equ   $13A
spr7pth equ   $13C
spr7ptl equ   $13E
spr0pos	equ   $140
spr1pos	equ   $148
spr2pos equ   $150
spr3pos equ   $158
spr4pos equ   $160
spr5pos equ   $168
spr6pos equ   $170
spr7pos equ   $178
spr0ctl	equ   $142
spr1ctl	equ   $14A
spr2ctl equ   $152
spr3ctl equ   $15A
spr4ctl equ   $162
spr5ctl equ   $16A
spr6ctl equ   $172
spr7ctl equ   $17A
spr0data equ  $144
spr1data equ  $14c
spr2data equ  $154
spr3data equ  $15c
spr4data equ  $164
spr5data equ  $16c
spr6data equ  $174
spr7data equ  $17c
spr0datb equ  $146
spr1datb equ  $14e
spr2datb equ  $156
spr3datb equ  $15e
spr4datb equ  $166
spr5datb equ  $16e
spr6datb equ  $176
spr7datb equ  $17e
color0	equ   $180
color1 	equ   $182
color2	equ   $184
color4  equ   $188
color8	equ   $190
color16 equ   $1A0

;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

ints		dc.w	0
oldcopper	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
SCREEN		dc.l	0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even


;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sprite0
sprite1
sprite2
sprite3
sprite4
sprite5
sprite6
sprite7	dc.w	0,0,0,0

coltab	dc.w	$000,$f00,$00e,$b00,$00a,$700,$0a0,$999
	dc.w	$888,$777,$666,$555,$444,$333,$222,$111


;"""""""""""""""""""""""""
;" DATA FOR FILL ROUTINE "
;"			 "
;"""""""""""""""""""""""""

ytable	ds.w	200

coords	ds.w	400

table	dc.l	b7,b6,b15,b5,b9,b14,b11,b4
	dc.l	b8,b16,b13,b12,b1,b10,b2,b3

first	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1

last	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

b1	dcb.w	20,0
b2	dcb.w	20,0
b3	dcb.w	20,$ffff
b4	dcb.w	20,$ffff
b5	dcb.w	20,$ffff
b6	dcb.w	20,$ffff
b7	dcb.w	20,0
b8	dcb.w	20,0
b9	dcb.w	20,0
	dcb.w	20,0
b10	dcb.w	20,$ffff
b11	dcb.w	20,0
b12	dcb.w	20,$ffff
	dcb.w	20,$ffff
b13	dcb.w	20,0
b14	dcb.w	20,$ffff
b15	dcb.w	20,0
b16	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0
	dcb.w	20,$ffff


sintab	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682	
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374,16382
costab	dc.w 16384,16382
	dc.w 16374,16362,16344,16322,16294,16262,16225,16182
	dc.w 16135,16083,16026,15964,15897,15826,15749,15668	
	dc.w 15582,15491,15396,15296,15191,15082,14967,14849
	dc.w 14726,14598,14466,14330,14189,14044,13894,13741	
	dc.w 13583,13421,13255,13085,12911,12733,12551,12365
	dc.w 12176,11982,11786,11585,11381,11174,10963,10749
	dc.w 10531,10311,10087,9860,9630,9397,9162,8923
	dc.w 8682,8438,8192,7943,7692,7438,7182,6924
	dc.w 6664,6402,6138,5872,5604,5334,5063,4790
	dc.w 4516,4240,3964,3686,3406,3126,2845,2563
	dc.w 2280,1997,1713,1428,1143,857,572,286,0
	dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682	
	dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w -16382,-16384
	dc.w -16382
	dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668	
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741	
	dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0
	dc.w 286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682	
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374,16382
	dc.w 16384,16382


;""""""""""""""""""""""""""""""
;" Data for wireframe objects "
;"			      "
;""""""""""""""""""""""""""""""

lines	dc.b	0,1,1,2,2,3,3,4,4,0,0,5,1,5,2,5,3,5,4,5
endlines

nlines equ (endlines-lines)/2
numlines	dc.w nlines-1


;""""""""""""""""""""""""""
;" Data for solid objects "
;"			  "
;""""""""""""""""""""""""""

trilist	dc.l	tri1,tri2,tri3,tri4,tri5,tri6,tri7,tri8

tri1	dc.w	0,5,1
	dc.w	1

tri2	dc.w	1,5,2
	dc.w	2

tri3	dc.w	2,5,3
	dc.w	3

tri4	dc.w	3,5,4
	dc.w	4

tri5	dc.w	4,5,0
	dc.w	5

tri6	dc.w	0,1,2
	dc.w	6

tri7	dc.w	0,2,3
	dc.w	6

tri8	dc.w	0,3,4
	dc.w	6

numtris	dc.l	7	(8-1)


;"""""""""""""""""""""""""""""""
;" Data common to both objects "
;"			       "
;"""""""""""""""""""""""""""""""

XANGLE		dc.w	0
YANGLE		dc.w	0
ZANGLE		dc.w	0
XSIN		dc.w	0
XCOS		dc.w	0
YSIN		dc.w	0
YCOS		dc.w	0
ZSIN		dc.w	0
ZCOS		dc.w	0

worldX	dc.w	0,48,30,-30,-48,0

worldY	dc.w	-50,-50,-50,-50,-50,50

worldZ	dc.w	-51,-16,41,41,-16,0

npoints	equ	(worldY-worldX)/2
numpoints	dc.w npoints-1

Xorg	dc.w 160
Yorg	dc.w 100
newX	ds.w npoints
newY	ds.w npoints
newZ	ds.w npoints
scrX	ds.w npoints
scrY	ds.w npoints
