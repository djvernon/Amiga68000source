	section	TextureWalls,code
	opt	c+,a+


	include	DH0:Devpac/System2.gs


*""""""""""""""""""""""
*" SCREEN DEFINITIONS "
*"		      "
*""""""""""""""""""""""

SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4
SCREEN_Y_OFFSET	equ	$48

PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH
CHUNKY_SCREEN_SIZE	equ	SCREEN_WIDTH*SCREEN_HEIGHT

PLANAR_MEMORY_SIZE	equ	PLANAR_SCREEN_SIZE*2
CHUNKY_MEMORY_SIZE	equ	CHUNKY_SCREEN_SIZE


*"""""""""""""""""""""""""""""
*" SOURCE BITMAP DEFINITIONS "
*"			     "
*"""""""""""""""""""""""""""""

BITMAP_WIDTH	equ	320
BITMAP_HEIGHT	equ	256
BITMAP_DEPTH	equ	4

BITMAP_SIZE	equ	BITMAP_WIDTH/8*BITMAP_HEIGHT*BITMAP_DEPTH

SOURCE_WIDTH	equ	64		* Size within bitmap
SOURCE_HEIGHT	equ	64


*"""""""""""""""""
*" START OF CODE "
*"		 "
*"""""""""""""""""

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

* Allocate chunky screen memory

	move.l	#CHUNKY_MEMORY_SIZE,d0
	move.l	#MEMF_PUBLIC,d1
	CALLEXEC AllocMem
	move.l	d0,chunky.memory
	beq	exit.close.dos

* Allocate planar screen memory

	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.free.chunky.mem

	move.l	d0,screen1
	add.l	#PLANAR_SCREEN_SIZE,d0
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

	move.l	#bitmap+BITMAP_SIZE,a0
;	lea	colour.table(pc),a0
	move.l	d0,a1
	move.l	cm_ColorTable(a1),a2
	moveq	#(1<<SCREEN_DEPTH)-1,d2
set.high.color.bits
	move.w	(a0)+,(a2)+		copy high colour bits
	dbra	d2,set.high.color.bits

	move.l	cm_LowColorBits(a1),a2
	moveq	#(1<<SCREEN_DEPTH)-1,d2
	moveq	#0,d3
set.low.color.bits
	move.w	d3,(a2)+		clear low colour bits
	dbra	d2,set.low.color.bits

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
	moveq	#SCREEN_DEPTH-1,d2
set.plane.ptrs1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	dbra	d2,set.plane.ptrs1

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
	moveq	#SCREEN_DEPTH-1,d2
set.plane.ptrs2
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	dbra	d2,set.plane.ptrs2

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


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

	bsr	initialise.data

main.loop
	bsr	read.joystick
	bsr	player.position
	bsr	texture.map.wall

	bsr	plot.wall.lines
	movem.w	line.x1(pc),d0-d3
	bsr	clip.line

	bsr	print.player.pos
	bsr	print.raster.count

	bsr	update.visible.screen

	sf	vblank.occured
wait.vblank
	tst.b	vblank.occured
	beq.s	wait.vblank

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
	move.l	#PLANAR_MEMORY_SIZE,d0
	CALLEXEC FreeMem

exit.free.chunky.mem
	move.l	chunky.memory(pc),a1
	move.l	#CHUNKY_MEMORY_SIZE,d0
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
;	movem.l	d0-d1/a0,-(sp)
	st	vblank.occured
;	movem.l	(sp)+,d0-d1/a0
	rts


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
	even


*""""""""""""""""""""""""""""""""
*" SUBROUTINES TO PRODUCE WALLS	"
*"				"
*""""""""""""""""""""""""""""""""

initialise.data
	bsr	calc.y.table
	bsr	planar.to.chunky

	move.l	#0,player.x
	move.l	#0,player.y
	move.l	#0,player.z

;	move.w	#11*8,current.line.colour
	rts


*"""""""""""""""""""""
*" CALCULATE Y-TABLE "
*"		     "
*"""""""""""""""""""""

calc.y.table
	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane
	lea	y.table,a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop
	rts


*""""""""""""""""""""""""""""""
*" PLANAR TO CHUNKY CONVERTER "
*"			      "
*""""""""""""""""""""""""""""""

planar.to.chunky
	lea	bitmap,a0
	lea	chunky.data,a5

to.chunky
	lea	BITMAP_WIDTH/8*BITMAP_HEIGHT(a0),a1
	lea	BITMAP_WIDTH/8*BITMAP_HEIGHT(a1),a2
	lea	BITMAP_WIDTH/8*BITMAP_HEIGHT(a2),a3
	move.w	#SOURCE_HEIGHT-1,d7

.next.line
	move.w	#SOURCE_WIDTH/32-1,d6

.next.32.pixels
	move.l	(a0)+,d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	move.l	(a3)+,d3
	moveq	#32-1,d5

.next.pixel
	moveq	#0,d4

.plane1	add.l	d0,d0
	bcc.s	.plane2			plane 1
	addq.w	#1,d4

.plane2	add.l	d1,d1
	bcc.s	.plane3			plane 2
	addq.w	#2,d4

.plane3	add.l	d2,d2
	bcc.s	.plane4			plane 3
	addq.w	#4,d4

.plane4	add.l	d3,d3
	bcc.s	.store			plane 4
	addq.w	#8,d4

.store	move.b	d4,(a5)+
	dbra	d5,.next.pixel

	dbra	d6,.next.32.pixels

	lea	(BITMAP_WIDTH-SOURCE_WIDTH)/8(a0),a0
	lea	(BITMAP_WIDTH-SOURCE_WIDTH)/8(a1),a1
	lea	(BITMAP_WIDTH-SOURCE_WIDTH)/8(a2),a2
	lea	(BITMAP_WIDTH-SOURCE_WIDTH)/8(a3),a3
	dbra	d7,.next.line
	rts


JOY_SPEED	equ	4


read.joystick
	move.w	joy1dat+$dff000.l,d0
	moveq	#0,d2
	moveq	#0,d3
	sf	fire.pressed

.left	btst	#9,d0
	beq.s	.right
	moveq	#-JOY_SPEED,d2
	bra.s	.up

.right	btst	#1,d0
	beq.s	.up
	moveq	#JOY_SPEED,d2

.up	move.w	d0,d1
	asr.w	#1,d1
	eor.w	d0,d1

	btst	#8,d1
	beq.s	.down
	moveq	#JOY_SPEED,d3
	bra.s	.store

.down	btst	#0,d1
	beq.s	.store
	moveq	#-JOY_SPEED,d3

.store	move.w	d2,joystick.x
	move.w	d3,joystick.y

	andi.b	#$7f,$bfe201.l
	btst	#7,$bfe001.l
	bne.s	.done
	st	fire.pressed

.done	rts


joystick.x	dc.w	0
joystick.y	dc.w	0
fire.pressed	dc.b	0,0


player.position
	bsr	calc.sin.cos.values
	lea	sin.cos.values(pc),a2

	moveq	#0,d0
	move.b	fire.pressed(pc),d0
	bne.s	.x.pos

* Fire button not pressed

.y.ang	move.w	joystick.x(pc),d0	update player's y angle
	asl.w	#2,d0
	add.w	d0,player.y.angle
	and.w	#$7fe,player.y.angle
	bra.s	.z.pos

* Fire button pressed

.x.pos	move.w	joystick.x(pc),d0	update player's x position
	asl.w	#4,d0
	move.w	d0,d1
	muls	COS_Y(a2),d0
	muls	SIN_Y(a2),d1
	add.l	d0,player.x
	add.l	d1,player.z

* Movement that is always done, regardless of fire button state

.z.pos	move.w	joystick.y(pc),d0	update player's z position
	asl.w	#4,d0
	move.w	d0,d1
	muls	SIN_Y(a2),d0
	muls	COS_Y(a2),d1
	sub.l	d0,player.x
	add.l	d1,player.z
	rts


SIN_Y	equ	0
COS_Y	equ	2


calc.sin.cos.values
	lea	sin.cos.values(pc),a1
	move.w	player.y.angle(pc),d2

	lea	sine(pc),a2
	move.w	(a2,d2.w),(a1)+

	lea	cosine(pc),a2
	move.w	(a2,d2.w),(a1)
	rts


sin.cos.values	ds.w	2


*""""""""""""""""""""""""""""""
*" DRAW A TEXTURE MAPPED WALL "
*"			      "
*""""""""""""""""""""""""""""""

texture.map.wall
	bsr	old.clear.chunky.screen

	sf	plot.lines
;;	bsr	rotate.wall.coords
;;	bmi.s	.done
;;	st	plot.lines
;;	bsr	calc.wall.edges
;;	bsr	plot.wall.edges
	bsr	rotate.line

.done	bsr	new.chunky.convert.long
	rts

plot.lines	dc.w	0


*""""""""""""""""""""""""""""""
*" CLEAR CHUNKY SCREEN MEMORY "
*"			      "
*""""""""""""""""""""""""""""""

	cnop	0,4

clear.chunky.screen
	bsr	raster.count.start

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	sub.l	a0,a0
	sub.l	a1,a1
	sub.l	a2,a2
	sub.l	a3,a3
	sub.l	a4,a4
	sub.l	a5,a5
	sub.l	a6,a6
	move.l	a7,saved.a7

	move.l	chunky.memory(pc),a7
	add.l	#CHUNKY_SCREEN_SIZE,a7
	move.w	#38-1,d7
.loop
	REPT	30
	movem.l	d0-d6/a0-a6,-(a7)
	ENDR
	dbra	d7,.loop

	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a4,-(a7)

	move.l	saved.a7(pc),a7

	bsr	raster.count.stop
	rts


	cnop	0,4

old.clear.chunky.screen
	bsr	raster.count.start

	move.l	chunky.memory(pc),a2
	move.w	#SCREEN_HEIGHT-1,d2
	moveq	#0,d3
.loop
	REPT	SCREEN_WIDTH/4
	move.l	d3,(a2)+
	ENDR
	dbra	d2,.loop

	bsr	raster.count.stop
	rts


*"""""""""""""""""""""""""""""""""""""
*" ROTATE WALL CO-ORDS AROUND PLAYER "
*"				     "
*"""""""""""""""""""""""""""""""""""""

WALL_COORDS	equ	2

WALL_Y1		equ	$fe000000/2	divide by two for correct scale
WALL_Y2		equ	$02000000/2


	cnop	0,4

rotate.wall.coords
	lea	sin.cos.values(pc),a2

* work out wall position relative to the player

	lea	wall.coords(pc),a5
	lea	rotated.wall.coords(pc),a4
	moveq	#WALL_COORDS-1,d7

.loop	movem.l	(a5)+,d0/d2		co-ord position in world
	sub.l	player.x(pc),d0
	sub.l	player.z(pc),d2
	swap	d0			X
	swap	d2			Z

	move.w	d0,d3
	move.w	d2,d5
	muls	SIN_Y(a2),d3		X(siny)
	muls	COS_Y(a2),d2		Z(cosy)
	sub.l	d3,d2			rotated Z
	bgt.s	.in.front

.hidden	moveq	#-1,d0
	rts

.in.front
	muls	COS_Y(a2),d0		X(cosy)
	muls	SIN_Y(a2),d5		Z(siny)
	add.l	d5,d0			rotated X

* Check visibility of vertical

	cmp.l	d2,d0
	bgt.s	.hidden			if object off right

	move.l	d0,d1
	add.l	d2,d1
	blt.s	.hidden			if object off left

;	cmp.l	#VISION_LIMIT,d2
;	bgt.s	.hidden			if object too far away

* Save vertical's rotated co-ords

	asr.l	#8,d0
	swap	d2
	divs	d2,d0			X/Z - perspective for X
	add.w	#SCREEN_WIDTH/2,d0	centre on screen


	move.l	#WALL_Y1,d1
	sub.l	player.y(pc),d1
	asr.l	#8,d1
	divs	d2,d1			Y/Z - perspective for Y1
	add.w	#SCREEN_HEIGHT/2,d1	centre on screen

	move.w	d0,(a4)+		save screen x
	move.w	d1,(a4)+		save screen y1
	move.w	d2,(a4)+		save z


	move.l	#WALL_Y2,d1
	sub.l	player.y(pc),d1
	asr.l	#8,d1
	divs	d2,d1			Y/Z - perspective for Y2
	add.w	#SCREEN_HEIGHT/2,d1	centre on screen

	move.w	d0,(a4)+		save screen x
	move.w	d1,(a4)+		save screen y1
	move.w	d2,(a4)+		save z

	dbra	d7,.loop

	moveq	#0,d0
	rts


wall.coords				* X, Z
	dc.l	$fe000000,$18000000	left co-ord
	dc.l	$02000000,$18000000	right co-ord

COORD_1	equ	0*6
COORD_2	equ	1*6
COORD_3	equ	2*6
COORD_4	equ	3*6

rotated.wall.coords
	ds.w	WALL_COORDS*6		X, Y, Z - twice per vertical


*"""""""""""""""""""""""""""""""""""""""
*" CALCULATE WALL TOP AND BOTTOM EDGES "
*"				       "
*"""""""""""""""""""""""""""""""""""""""

	cnop	0,4

LINE_X1	equ	120
LINE_Y1	equ	120
LINE_X2	equ	-120
LINE_Y2	equ	-120


rotate.line
	btst	#2,$dff016.l
	bne.s	.points
	addq.w	#4,line.z.angle
	and.w	#$7fe,line.z.angle

.points	move.w	line.z.angle(pc),d2
	lea	sine(pc),a2
	move.w	(a2,d2.w),d4
	lea	cosine(pc),a2
	move.w	(a2,d2.w),d5

	move.w	#LINE_X1,d0
	move.w	#LINE_Y1,d2
	bsr	.rotate
	move.w	d0,line.x1
	move.w	d1,line.y1

	move.w	#LINE_X2,d0
	move.w	#LINE_Y2,d2
	bsr	.rotate
	move.w	d0,line.x2
	move.w	d1,line.y2

	movem.w	line.x1(pc),d0-d3
	lea	edge1.coords(pc),a1
	bsr	calc.line
	bsr	plot.wall.edges
	rts


.rotate	move.w	d0,d1
	move.w	d2,d3
	muls	d5,d0			X(cosz)
	muls	d4,d2			Y(sinz)
	sub.l	d2,d0			rotated X
	muls	d4,d1			X(sinz)
	muls	d5,d3			Y(cosz)
	add.l	d3,d1			rotated Y
	swap	d0
	swap	d1
	add.w	#SCREEN_WIDTH/2,d0	centre on screen
	add.w	#SCREEN_HEIGHT/2,d1	centre on screen
	rts


line.z.angle	dc.w	0

line.x1	dc.w	0
line.y1	dc.w	0
line.x2	dc.w	0
line.y2	dc.w	0


calc.wall.edges
	move.w	#COORD_1,d0
	move.w	#COORD_3,d2
	lea	rotated.wall.coords(pc),a1
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	lea	edge1.coords(pc),a1
	bsr	calc.line

	move.w	#COORD_2,d0
	move.w	#COORD_4,d2
	lea	rotated.wall.coords(pc),a1
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	lea	edge2.coords(pc),a1
	bsr	calc.line
	rts


plot.wall.edges
	lea	edge1.coords(pc),a0
	move.l	chunky.memory(pc),a1
	move.w	(a0)+,d7
	subq.w	#1,d7
	ble.s	.once

.loop	movem.w	(a0)+,d0-d1		x, y
	mulu	#SCREEN_WIDTH,d1
	lea	(a1,d1.l),a2
	add.w	d0,a2
	move.b	#3,(a2)
	dbra	d7,.loop
	rts

.once	movem.w	(a0)+,d0-d1		x, y
	mulu	#SCREEN_WIDTH,d1
	lea	(a1,d1.l),a2
	add.w	d0,a2
	move.b	#7,(a2)
	rts


edge1.coords
	dc.w	0			count
	ds.l	512			x, y pairs

edge2.coords
	dc.w	0			count
	ds.l	512			x, y pairs


calc.line
	lea	BL58(pc),a2
	move.w	#0,d4
	moveq	#16,d7

	movem.w	d2-d3,-(sp)		x2, y2
	cmp.w	d1,d3
	bge.s	BJ4C
	addq.w	#6,d4

BJ4C	sub.l	d1,d3
	bpl.s	BJ52
	neg.l	d3

BJ52	sub.l	d0,d2
	bpl.s	BJ5A
	neg.l	d2
	addq.w	#1,d4

BJ5A	move.w	d2,d5
	cmp.w	d2,d3
	bmi.s	BJ68
	bne.s	BJ64
	addq.w	#2,d4

BJ64	move.w	d3,d5
	addq.w	#2,d4

BJ68	move.w	d5,(a1)+		count

	move.w	d0,(a1)+		x1
	move.w	d1,(a1)+		y1
	asl.w	#6,d4
	jsr	(a2,d4.w)
	move.l	(sp)+,-4(a1)		x2, y2
	rts


* Routines to create line co-ordinates
*
* There are 12 routines :-
*
*  First, the line can go up or down - gives 2 routines
*  Then, the line can go left or right - gives 2*2 = 4 routines
*  Then, the line width and height vary - gives 4*3 = 12 routines
*    (xdelta > ydelta OR xdelta = ydelta OR xdelta < ydelta)

BL58	moveq	#0,d4
	subq.w	#1,d2
	ble.s	BL78
	swap	d3
	clr.w	d3
	divsl.l	d2,d3:d3
BL66	add.l	d3,d4
	bclr	d7,d4
	beq.s	BL6E
	addq.w	#1,d1
BL6E	addq.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BL66
BL78	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d2
	ble.s	BLB8
	swap	d3
	clr.w	d3
	divsl.l	d2,d3:d3
BLA6	add.l	d3,d4
	bclr	d7,d4
	beq.s	BLAE
	addq.w	#1,d1
BLAE	subq.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BLA6
BLB8	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d3
	ble.s	BLF8
	swap	d2
	clr.w	d2
	divsl.l	d3,d2:d2
BLE6	add.l	d2,d4
	bclr	d7,d4
	beq.s	BLEE
	addq.w	#1,d0
BLEE	addq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d3,BLE6
BLF8	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d3
	ble.s	BM38
	swap	d2
	clr.w	d2
	divsl.l	d3,d2:d2
BM26	add.l	d2,d4
	bclr	d7,d4
	beq.s	BM2E
	subq.w	#1,d0
BM2E	addq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d3,BM26
BM38	rts

	ds.w	15

	subq.w	#1,d2
	ble.s	BM68
BM5C	addq.w	#1,d0
	addq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BM5C
BM68	rts

	ds.w	23

	subq.w	#1,d2
	ble.s	BMA8
BM9C	subq.w	#1,d0
	addq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BM9C
BMA8	rts

	ds.w	23

	moveq	#0,d4
	subq.w	#1,d2
	ble.s	BMF8
	swap	d3
	clr.w	d3
	divsl.l	d2,d3:d3
BME6	add.l	d3,d4
	bclr	d7,d4
	beq.s	BMEE
	subq.w	#1,d1
BMEE	addq.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BME6
BMF8	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d2
	ble.s	BN38
	swap	d3
	clr.w	d3
	divsl.l	d2,d3:d3
BN26	add.l	d3,d4
	bclr	d7,d4
	beq.s	BN2E
	subq.w	#1,d1
BN2E	subq.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BN26
BN38	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d3
	ble.s	BN78
	swap	d2
	clr.w	d2
	divsl.l	d3,d2:d2
BN66	add.l	d2,d4
	bclr	d7,d4
	beq.s	BN6E
	addq.w	#1,d0
BN6E	subq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d3,BN66
BN78	rts

	ds.w	15

	moveq	#0,d4
	subq.w	#1,d3
	ble.s	BNB8
	swap	d2
	clr.w	d2
	divsl.l	d3,d2:d2
BNA6	add.l	d2,d4
	bclr	d7,d4
	beq.s	BNAE
	subq.w	#1,d0
BNAE	subq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d3,BNA6
BNB8	rts

	ds.w	15

	subq.w	#1,d2
	ble.s	BNE8
BNDC	addq.w	#1,d0
	subq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BNDC
BNE8	rts

	ds.w	23

	subq.w	#1,d2
	ble.s	BO28
BO1C	subq.w	#1,d0
	subq.w	#1,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d2,BO1C
BO28	rts


*""""""""""""""""""""""""""""""""""
*" PLOT WALL TOP AND BOTTOM LINES "
*"				  "
*""""""""""""""""""""""""""""""""""

	cnop	0,4

plot.wall.lines
	move.b	plot.lines(pc),d0
	beq.s	.done

	move.w	#COORD_1,d0
	move.w	#COORD_3,d2
	lea	rotated.wall.coords(pc),a1
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr	clip.line

	move.w	#COORD_2,d0
	move.w	#COORD_4,d2
	lea	rotated.wall.coords(pc),a1
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr	clip.line

.done	rts


*""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER "
*"			      "
*""""""""""""""""""""""""""""""

	cnop	0,4

new.chunky.convert.long
	move.l	chunky.memory(pc),a0
	move.l	screen1(pc),a4
	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7

	move.l	a7,saved.a7
	move.l	#$00ff00ff,a5
	move.l	#$33333333,a6
	move.l	#$55555555,a7

;	cnop	0,4

.next.32.pixels
;	move.l	(a0)+,d0		.A.B.C.D
;	move.l	(a0)+,d1		.E.F.G.H
;	move.l	(a0)+,d2		.I.J.K.L
;	move.l	(a0)+,d3		.M.N.O.P
;	move.l	(a0)+,d4		.Q.R.S.T
;	move.l	(a0)+,d5		.U.V.W.X
;	move.l	(a0)+,d6		.Y.Z.a.b
;	move.l	(a0)+,d7		.c.d.e.f
	movem.l	(a0)+,d0-d6

	lsl.l	#4,d0			A.B.C.D.
	lsl.l	#4,d2			I.J.K.L.
	lsl.l	#4,d4			Q.R.S.T.
	lsl.l	#4,d6			Y.Z.a.b.
	or.l	d1,d0			AEBFCGDH
	or.l	d3,d2			IMJNKOLP
	or.l	d5,d4			QURVSWTX
	move.l	(a0)+,d5
	or.l	d5,d6			YcZdaebf

	swap	d4			SWTXQURV
	move.w	d0,d1			....CGDH
	move.w	d4,d0			AEBFQURV
	move.w	d1,d4			SWTXCGDH
	swap	d4			CGDHSWTX

	swap	d6			aebfYcZd
	move.w	d2,d3			....KOLP
	move.w	d6,d2			IMJNYcZd
	move.w	d3,d6			aebfKOLP
	swap	d6			KOLPaebf

	move.l	a5,d5

	move.l	d0,d1
	and.l	d5,d1			..BF..RV
	eor.l	d1,d0			AE..QU..
	move.l	d2,d3
	and.l	d5,d3			..JN..Zd
	eor.l	d3,d2			IM..Yc..
	lsl.l	#8,d1			BF..RV..
	lsr.l	#8,d2			..IM..Yc
	or.l	d2,d0			AEIMQUYc
	or.l	d3,d1			BFJNRVZd

	move.l	d4,d2
	and.l	d5,d4			..DH..TX
	eor.l	d4,d2			CG..SW..
	move.l	d6,d3
	and.l	d5,d3			..LP..bf
	eor.l	d3,d6			KO..ae..
	lsl.l	#8,d4			DH..TX..
	lsr.l	#8,d6			..KO..ae
	or.l	d6,d2			CGKOSWae
	or.l	d4,d3			DHLPTXbf

	move.l	a6,d6

	move.l	d0,d4
	and.l	d6,d0			.A.E.I.M.Q.U.Y.c	bits 10
	eor.l	d0,d4			A.E.I.M.Q.U.Y.c.	bits 32
	move.l	d2,d5
	and.l	d6,d5			.C.G.K.O.S.W.a.e	bits 10
	eor.l	d5,d2			C.G.K.O.S.W.a.e.	bits 32
	lsl.l	#2,d0			A.E.I.M.Q.U.Y.c.	bits 10
	lsr.l	#2,d2			.C.G.K.O.S.W.a.e	bits 32
	or.l	d5,d0			ACEGIKMOQSUWYace	bits 10
	or.l	d4,d2			ACEGIKMOQSUWYace	bits 32

	move.l	d1,d4
	and.l	d6,d1			.B.F.J.N.R.V.Z.d	bits 10
	eor.l	d1,d4			B.F.J.N.R.V.Z.d.	bits 32
	move.l	d3,d5
	and.l	d6,d5			.D.H.L.P.T.X.b.f	bits 10
	eor.l	d5,d3			D.H.L.P.T.X.b.f.	bits 32
	lsl.l	#2,d1			B.F.J.N.R.V.Z.d.	bits 10
	lsr.l	#2,d3			.D.H.L.P.T.X.b.f	bits 32
	or.l	d5,d1			BDFHJLNPRTVXZbdf	bits 10
	or.l	d4,d3			BDFHJLNPRTVXZbdf	bits 32

	move.l	a7,d6

	move.l	d0,d4
	and.l	d6,d0		.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 0
	eor.l	d0,d4		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 1
	move.l	d1,d5
	and.l	d6,d5		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 0
	eor.l	d5,d1		B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 1
	add.l	d0,d0		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 0
	lsr.l	#1,d1		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 1
	or.l	d5,d0		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 0
	or.l	d4,d1		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 1

	move.l	d2,d4
	and.l	d6,d2		.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 2
	eor.l	d2,d4		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 3
	move.l	d3,d5
	and.l	d6,d5		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 2
	eor.l	d5,d3		B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 3
	add.l	d2,d2		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 2
	lsr.l	#1,d3		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 3
	or.l	d5,d2		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 2
	or.l	d4,d3		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 3

	move.l	d3,(a1)+		plane 3
	move.l	d2,(a2)+		plane 2
	move.l	d1,(a3)+		plane 1
	move.l	d0,(a4)+		plane 0
	dbra	d7,.next.32.pixels

	move.l	saved.a7(pc),a7
	rts


saved.a7	dc.l	0


*"""""""""""""""""""""""""""""""""""""""
*" PRINT PLAYER POSITION AND DIRECTION "
*"				       "
*"""""""""""""""""""""""""""""""""""""""

print.player.pos
	move.l	player.x(pc),d0
	lea	.pos.text+2(pc),a0
	bsr	make.hex.long2

	move.l	player.z(pc),d0
	lea	.pos.text+13(pc),a0
	bsr	make.hex.long2

	move.w	player.y.angle(pc),d0
	lea	.pos.text+24(pc),a0
	bsr	make.hex.word2

	lea	.pos.text(pc),a0
	moveq	#6,d0
	moveq	#0,d1
	bsr	print
	rts


.pos.text	dc.b	'X 00000000 Z 00000000 A 0000',0
	even


*"""""""""""""""""""""""""""
*" PRINT RASTER LINES USED "
*"			   "
*"""""""""""""""""""""""""""

	cnop	0,4

raster.count.start
	move.l	$dff004.l,d1
	lsr.l	#8,d1
	andi.w	#$1FF,d1		vertical position

;	move.b	$bfda00.l,d1
;	move.b	$bfd900.l,d1
;	lsl.w	#8,d1
;	move.b	$bfd800.l,d1

	move.w	d1,old.pulses
	rts


raster.count.stop
	move.l	$dff004.l,d1
	lsr.l	#8,d1
	andi.w	#$1FF,d1		vertical position

;	move.b	$bfda00.l,d1
;	move.b	$bfd900.l,d1
;	lsl.w	#8,d1
;	move.b	$bfd800.l,d1

	sub.w	old.pulses(pc),d1
	move.w	d1,raster.count
	rts


print.raster.count
	move.w	raster.count(pc),d0
	lea	.count.text+2(pc),a0
	bsr	make.hex.word2

	lea	.count.text(pc),a0
	moveq	#6,d0
	move.w	#SCREEN_HEIGHT-8,d1
	bsr	print
	rts


.count.text	dc.b	'R 0000',0
	even

old.pulses	dc.w	0
raster.count	dc.w	0


*"""""""""""""""""
*" PRINT ROUTINE "
*"		 "
*"""""""""""""""""

	cnop	0,4

print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address

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
	move.b	(a3)+,d1
	move.b	d1,(a2)			copy byte of character, bitplane 1
	move.b	d1,8000(a2)		bitplane 2
	move.b	d1,16000(a2)		bitplane 3
	move.b	d1,24000(a2)		bitplane 4

	lea	SCREEN_WIDTH/8(a2),a2	next screen line
	dbra	d0,char.loop

	addq.l	#1,a1			next column
	bra.s	print.loop

end.print
	rts


* Spectrum font, characters 32-126, each 8*8 pixels

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


make.hex.word			; d0.w = number
	lea	hex.text(pc),a0
make.hex.word2
	moveq	#4-1,d1
	bra.s	make.hex

make.hex.long			; d0.l = number
	lea	hex.text(pc),a0
make.hex.long2
	moveq	#8-1,d1

make.hex
	lea	hex.digits(pc),a1

.loop	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	ror.l	#4,d0
	dbra	d1,.loop
	rts


hex.digits
	dc.b	'0123456789ABCDEF'


hex.text
	ds.b	9
	even


draw.line.one.plane

* draw line using blitter
* d0 = x1, d1 = y1, d2 = x2, d3 = y2
* a1 = bitplane address

;	CALLGRAF OwnBlitter

	lea	$dff000.l,a6
	cmp.w	d2,d0
	ble.s	.x1.less.than.x2

	exg	d0,d2			ensure line is going left-to-right
	exg	d1,d3

.x1.less.than.x2
	sub.w	d0,d2			x2-x1
	sub.w	d1,d3			y2-y1

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x-start

	sub.w	d4,d0			x-start offset in multiples of 16
	asr.w	#3,d0			x-start offset in even bytes

	add.w	d1,d1			word offset
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0		add y offset
	add.w	d0,a1

	ror.w	#4,d4			low four bits from x-start
	or.w	#$bca,d4		USE A,C,D	D = A.B + notA.C
	swap	d4

	tst.w	d3			delta-y
	bmi.s	.y2.less.than.y1

	cmp.w	d2,d3
	blt.s	.dy.less.than.dx

	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	.dl.size

.dy.less.than.dx
	move.w	#%10001,d4
	bra.s	.dl.size


.y2.less.than.y1
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	.dy.less.than.dx2

	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	.dl.size

.dy.less.than.dx2
	move.w	#%11001,d4


.dl.size
	move.w	d2,d1			larger delta is line length
	addq.w	#1,d1			+ 1 to prevent length of zero
	lsl.w	#6,d1			into correct position
	addq.w	#2,d1			+ width of two

	add.w	d3,d3			2 Sdelta
	move.w	d3,d0
	sub.w	d2,d0			2 Sdelta - Ldelta
	bge.s	.no.sign

	or.w	#%1000000,d4		set SIGN flag

.no.sign
	add.w	d2,d2			2 Ldelta

.bltfin	btst	#6,dmaconr(a6)
	bne.s	.bltfin

	move.w	d3,bltbmod(a6)		2 Sdelta
	sub.w	d2,d3			2 Sdelta - 2 Ldelta
	move.w	d3,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.w	d3,bltbdat(a6)		set line mask
	move.l	d3,bltafwm(a6)
	moveq	#SCREEN_WIDTH/8,d3	width of one bitplane
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	move.l	a1,bltcpth(a6)		start address of line
	move.l	a1,bltdpth(a6)		start address of line
	move.w	d0,bltapth+2(a6)	2 Sdelta - Ldelta
	move.l	d4,bltcon0(a6)
	move.w	d1,bltsize(a6)		start blitter

;	CALLGRAF DisownBlitter
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
chunky.memory	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
overhead.screen	dc.l	0
cm		dc.l	0
copper1		dc.l	0
copper2		dc.l	0

vblank.occured	dc.b	0,0

player.x	dc.l	0
player.y	dc.l	0
player.z	dc.l	0

player.x.angle	dc.w	0
player.y.angle	dc.w	0
player.z.angle	dc.w	0

;x.offset	dc.l	0
;y.offset	dc.l	0
;z.offset	dc.l	$4000000


*""""""""""""""""""""""""""""""""""""""""
*" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
*"					"
*""""""""""""""""""""""""""""""""""""""""

XMAX	equ	SCREEN_WIDTH
YMAX	equ	SCREEN_HEIGHT
XMID	equ	XMAX/2
YMID	equ	YMAX/2


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


*"""""""""""""""""
*" LINE ROUTINES "
*"		 "
*"""""""""""""""""

* d0 = x1, d1 = y1, d2 = x2, d3 = y2

clip.line
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.not.off.left

* x1 is off left of screen

	tst.w	d2			x2
	bmi.s	end.clip.line		if line is off left of screen

* clip line to left edge, giving a new value for y1

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

* x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	end.clip.line		if line is off right of screen

* clip line to right edge, giving a new value for y1

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

* y1 is off top of screen

	tst.w	d3			y2
	bmi.s	end.clip.line		if line is off top of screen

* clip line to top edge, giving a new value for x1

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

* y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	end.clip.line2		if line is off bottom of screen

* clip line to bottom edge, giving a new value for x1

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

* x2 is off left of screen

* clip line to left edge, giving a new value for y2

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

* x2 is off right of screen

* clip line to right edge, giving a new value for y2

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

* y2 is off top of screen

* clip line to top edge, giving a new value for x2

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

* y2 is off bottom of screen

* clip line to bottom edge, giving a new value for x2

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




draw.line				* draw line using blitter
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
	asr.w	#3,d0			x-start offset in even bytes

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
;;	addq.w	#1,d1			+ 1 to prevent length of zero
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


*"""""""""""""""""""""
*" SINE/COSINE TABLE "
*"		     "
*"""""""""""""""""""""

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


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$aaa,$fff,$fff,$000,$0cc,$fff,$fff
	dc.w	$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0


y.table	ds.w	SCREEN_HEIGHT


chunky.data	ds.b	SOURCE_WIDTH*SOURCE_HEIGHT


bitmap	incbin	Guys.bin


*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

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
