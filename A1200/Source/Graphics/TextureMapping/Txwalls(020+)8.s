	section	TxWalls,code_c
	opt	c+


FASTER_CHUNKY_TO_PLANAR	equ	1

;DEBUG	equ	1

;	IFND	DEBUG
;	opt	o+
;	ENDC


; optimisations:
;	remove vblank wait by using triple planar buffers
;	clear second chunky buffer at same time as drawing to first
;	or only clear parts of buffer that haven't been draw to

*""""""""""""""""""""""
*" SCREEN DEFINITIONS "
*"		      "
*""""""""""""""""""""""

SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4
;;SCREEN_Y_OFFSET	equ	$48

PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH
CHUNKY_SCREEN_SIZE	equ	SCREEN_WIDTH*SCREEN_HEIGHT

PLANAR_MEMORY_SIZE	equ	PLANAR_SCREEN_SIZE*3
CHUNKY_MEMORY_SIZE	equ	CHUNKY_SCREEN_SIZE

XMAX	equ	SCREEN_WIDTH
YMAX	equ	SCREEN_HEIGHT
XMID	equ	XMAX/2
YMID	equ	YMAX/2


*"""""""""""""""""""""""""""""
*" SOURCE BITMAP DEFINITIONS "
*"			     "
*"""""""""""""""""""""""""""""

BITMAP_WIDTH	equ	64	;320
BITMAP_HEIGHT	equ	64	;256
BITMAP_DEPTH	equ	4

BITMAP_SIZE	equ	BITMAP_WIDTH/8*BITMAP_HEIGHT*BITMAP_DEPTH

SOURCE_WIDTH	equ	64		* Size within bitmap
SOURCE_HEIGHT	equ	64


*"""""""""""""""""
*" START OF CODE "
*"		 "
*"""""""""""""""""

start	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		turn multitasking off
	ENDC

* Allocate chunky screen memory

	move.l	#CHUNKY_MEMORY_SIZE,d0
	moveq	#1,d1			public
	jsr	-198(a6)		AllocMem
	move.l	d0,chunky.memory
	beq	exit_now

* Allocate planar screen memory

	move.l	#PLANAR_MEMORY_SIZE,d0
	moveq	#2,d1			chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.memory
	beq	exit_free_chunky_mem

	move.l	d0,screen1
	move.l	#4*40*200,d1
	add.l	d1,d0
	move.l	d0,screen2
	add.l	d1,d0
	move.l	d0,screen3


	moveq	#0,d0
	lea	graf.name,a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_free_mem

	move.l	d0,gfxbase
	move.l	d0,a6
	IFND	DEBUG
	jsr	-456(a6)		OwnBlitter
	ENDC




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	IFND	DEBUG
	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	$68.w,old.level2
	move.l	#new.level2,$68.w

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c018,intena(a6)	enable copper and level2 interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


;;	lea	colour.table(pc),a0	initialise colours
	move.l	#bitmap+BITMAP_SIZE,a0
	lea	color0(a6),a1
	moveq	#(1<<(SCREEN_DEPTH-1))-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
;;	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	jsr	make.copper.lists	initialise copper

	move.l	copper1,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on
	ENDC



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

	bsr	initialise.data
	st.b	frames.requested

main.loop
;	IFND	DEBUG
;	bsr	clear
;	ENDC

	bsr	read.joystick
	bsr	player.position
	bsr	texture.map.wall
;	bsr	print.player.pos
;	bsr	print.raster.count

	IFND	DEBUG
	jsr	keyboard.requests

	jsr	update.screens
	ENDC

	sf	vblank.occured
wait.vblank
	tst.b	vblank.occured
	beq.s	wait.vblank

	btst	#6,$bfe001
	bne.s	main.loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""
	IFND	DEBUG
	lea	$dff000,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	old.level2,$68.w

	move.l	old.level3,$6c.w

	move.w	old.ints,d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz,$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase,a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on
	ENDC

	move.l	a0,a6
	IFND	DEBUG
	jsr	-462(a6)		DisownBlitter
	ENDC

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_free_mem
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	screen.memory,a1
	jsr	-210(a6)		FreeMem

exit_free_chunky_mem
	move.l	#CHUNKY_MEMORY_SIZE,d0
	move.l	chunky.memory(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	IFND	DEBUG
	jsr	-138(a6)		turn multitasking on
	ENDC

	moveq	#0,d0
	rts


test.count	dc.w	0


;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level2
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$8,intreq+$dff000

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

	move.b	raw.key.code,d0

	cmp.b	#$46,d0			DELETE
	bne.s	check.help
	not.b	frames.requested
	bra.s	end.level2

check.help
	cmp.b	#$5f,d0			HELP
	bne.s	check.auto
	not.b	palette.requested
	bra.s	end.level2

check.auto
	cmp.b	#$20,d0			A
	bne.s	end.level2
	not.b	auto.move

end.level2
	move.l	(sp)+,a0
	move.l	(sp)+,d0
rte.ins	rte




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d1/a0,-(sp)
	move.w	#$10,intreq+$dff000

	st.b	vblank.occured
	addq.w	#1,vblank.count

	lea	mouse.data,a0

	move.b	$dff00b,d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x,d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$dff00a,d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y,d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y

	tst.b	auto.move
;	bne.s	end.level3

;	bsr.s	set.x.y.z.angles

end.level3
	movem.l	(sp)+,d0-d1/a0
	rte


vblank.count	dc.w	0


set.x.y.z.angles
	lea	mouse.data,a0
	btst	#2,potgor+$dff000	right mouse button
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
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""

*""""""""""""""""""""""""""""""""
*" SUBROUTINES TO PRODUCE WALLS	"
*"				"
*""""""""""""""""""""""""""""""""

initialise.data
	bsr.s	calc.y.table
	bsr.s	calc.chunky.screen.ptrs
	bsr	calc.chunky.y.offsets
	bsr.s	planar.to.chunky

	move.l	#0,player.x
	move.l	#0,player.y

* position graphic in top left corner, for testing purposes
;	move.l	#$1720000,player.x
;	move.l	#$132000,player.y

	move.l	#$12800000,player.z

	move.w	#11*8,current.line.colour
	rts


*"""""""""""""""""""""
*" CALCULATE Y-TABLE "
*"		     "
*"""""""""""""""""""""

calc.y.table
	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane
	lea	y.table(pc),a0

.loop	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,.loop
	rts


*""""""""""""""""""""""""""""""""
*" CALCULATE CHUNKY SCREEN PTRS	"
*"				"
*""""""""""""""""""""""""""""""""

calc.chunky.screen.ptrs
	move.w	#SCREEN_HEIGHT-1,d0
	lea	chunky.screen.ptrs(pc),a0
	move.l	chunky.memory(pc),a1

.loop	move.l	a1,(a0)+
	lea	SCREEN_WIDTH(a1),a1
	dbra	d0,.loop
	rts


*""""""""""""""""""""""""""""""
*" PLANAR TO CHUNKY CONVERTER "
*"			      "
*""""""""""""""""""""""""""""""

planar.to.chunky
	lea	bitmap,a0		* Interleaved
	lea	chunky.data,a5

to.chunky
	lea	BITMAP_WIDTH/8(a0),a1
	lea	BITMAP_WIDTH/8(a1),a2
	lea	BITMAP_WIDTH/8(a2),a3
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

	lea	((BITMAP_WIDTH-SOURCE_WIDTH)+(BITMAP_WIDTH*(BITMAP_DEPTH-1)))/8(a0),a0
	lea	((BITMAP_WIDTH-SOURCE_WIDTH)+(BITMAP_WIDTH*(BITMAP_DEPTH-1)))/8(a1),a1
	lea	((BITMAP_WIDTH-SOURCE_WIDTH)+(BITMAP_WIDTH*(BITMAP_DEPTH-1)))/8(a2),a2
	lea	((BITMAP_WIDTH-SOURCE_WIDTH)+(BITMAP_WIDTH*(BITMAP_DEPTH-1)))/8(a3),a3
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
	bsr.s	calc.sin.cos.values
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
;	asl.w	#6,d0
	move.w	d0,d1
	muls	COS_Y(a2),d0
	muls	SIN_Y(a2),d1
	add.l	d0,player.x
	add.l	d1,player.z

* Movement that is always done, regardless of fire button state

.z.pos	move.w	joystick.y(pc),d0	update player's z position
	asl.w	#6,d0
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
	bsr.s	clear.chunky.screen

;	sf	plot.lines
	bsr	rotate.wall.coords
	bmi.s	.done
;	st	plot.lines
	bsr	calc.wall.edges

	bsr	calc.wall.strip.offsets
;	bsr	raster.count.start
	bsr	draw.wall.strips
;	bsr	raster.count.stop

.done
;	bsr	raster.count.start
	bsr	new.chunky.convert.long
;	bsr	raster.count.stop
	rts

plot.lines	dc.w	0


*""""""""""""""""""""""""""""""
*" CLEAR CHUNKY SCREEN MEMORY "
*"			      "
*""""""""""""""""""""""""""""""

	cnop	0,4

clear.chunky.screen
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
	rts


	cnop	0,4

old.clear.chunky.screen
	move.l	chunky.memory(pc),a2
	move.w	#SCREEN_HEIGHT-1,d2
	moveq	#0,d3
.loop
	REPT	SCREEN_WIDTH/4
	move.l	d3,(a2)+
	ENDR
	dbra	d2,.loop
	rts


clear	lea	$dff000,a6
.loop	btst	#6,dmaconr(a6)
	bne.s	.loop

	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1,bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)
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

	move.l	d0,d3
	swap	d3			x

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
	move.w	d3,(a4)+		save x
	move.w	d2,(a4)+		save z


	move.l	#WALL_Y2,d1
	sub.l	player.y(pc),d1
	asr.l	#8,d1
	divs	d2,d1			Y/Z - perspective for Y2
	add.w	#SCREEN_HEIGHT/2,d1	centre on screen

	move.w	d0,(a4)+		save screen x
	move.w	d1,(a4)+		save screen y1
	move.w	d3,(a4)+		save x
	move.w	d2,(a4)+		save z

	dbra	d7,.loop

	moveq	#0,d0
	rts


wall.coords				* X, Z
	dc.l	$fe000000,$18000000	left co-ord
	dc.l	$02000000,$18000000	right co-ord

COORD_1	equ	0*8
COORD_2	equ	1*8
COORD_3	equ	2*8
COORD_4	equ	3*8

rotated.wall.coords
	ds.w	WALL_COORDS*8		PX, PY, X, Z - twice per vertical


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
	bsr.s	.rotate
	move.w	d0,line.x1
	move.w	d1,line.y1

	move.w	#LINE_X2,d0
	move.w	#LINE_Y2,d2
	bsr.s	.rotate
	move.w	d0,line.x2
	move.w	d1,line.y2

	movem.w	line.x1(pc),d0-d3
	lea	edge1.coords(pc),a1
	bsr	calc.line
	bsr.s	plot.wall.edges
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
	bsr.s	plot.edge
	lea	edge2.coords(pc),a0
;	bra	plot.edge


plot.edge
	move.l	chunky.memory(pc),a1
	move.w	(a0)+,d7

.loop	movem.w	(a0)+,d0-d1		x, y
	mulu	#SCREEN_WIDTH,d1
	lea	(a1,d1.l),a2
	add.w	d0,a2
	move.b	#3,(a2)
	dbra	d7,.loop
	rts


edge1.coords
	dc.w	0			count
	ds.l	512			x, y pairs

edge2.coords
	dc.w	0			count
	ds.l	512			x, y pairs


;"""""""""""""""""""""""""""""""""""""""""""""""""
;" CALCULATE SOURCE DATA OFFSETS FOR WALL STRIPS "
;"						 "
;"""""""""""""""""""""""""""""""""""""""""""""""""

	cnop	0,4

calc.wall.strip.offsets
	lea	edge1.coords(pc),a0
	move.w	(a0),d7			count

	move.w	#COORD_1,d0
	move.w	#COORD_3,d2
	lea	rotated.wall.coords(pc),a1

	move.w	(a1,d0.w),d6		px (screen x)
	move.w	d6,wall.x.start
	sub.w	#SCREEN_WIDTH/2,d6
	ext.l	d6

	movem.w	4(a1,d0.w),d0-d1	get start coordinates
	movem.w	4(a1,d2.w),d2-d3	get end coordinates

* d0 = x1, d1 = z1, d2 = x2, d3 = z2

	sub.w	d1,d3			z2-z1
	sub.w	d0,d2			x2-x1

	move.w	d0,a2			x1
	move.w	d2,a3			x2-x1

	muls	d3,d0			x1(z2-z1)
	muls	d2,d1			z1(x2-x1)
	sub.l	d0,d1			z1(x2-x1) - x1(z2-z1)

	ext.l	d2
	asl.l	#8,d2			256(x2-x1)

	lea	strip.data(pc),a1

.next.strip
	move.w	d6,d5
	muls	d3,d5			px(z2-z1)
	move.l	d2,d4
	sub.l	d5,d4			256(x2-x1) - px(z2-z1)

	move.l	d1,d0
	muls.l	d6,d0			(z1(x2-x1) - x1(z2-z1))px
	divs.l	d4,d0			divu ???

* now have x position along line

	move.w	#SOURCE_WIDTH-1,d5
	sub.w	a2,d0			x-x1
	bpl.s	.ok
	moveq	#0,d0
.ok	mulu	d0,d5			(x-x1)SOURCE_WIDTH
	move.w	a3,d4
	divu	d4,d5			(x-x1)SOURCE_WIDTH/(x2-x1)
	move.w	d5,(a1)+

	addq.l	#1,d6
	dbra	d7,.next.strip
	rts


strip.data
	ds.w	SCREEN_WIDTH		source offset

wall.x.start
	dc.w	0


;"""""""""""""""""""""""""""""""""""""""
;" DRAW THE WALL USING THE SOURCE DATA "
;"				       "
;"""""""""""""""""""""""""""""""""""""""

* V1.0 took $A05 raster lines
* V1.1 took $5A9 raster lines

	cnop	0,4

draw.wall.strips
	move.l	a7,saved.a7

	lea	edge1.coords(pc),a0
	move.w	(a0)+,d0		count
	lea	edge2.coords+2(pc),a1

	move.w	wall.x.start(pc),d1

	lea	strip.data(pc),a2
	lea	chunky.screen.ptrs(pc),a4

	IFD	FASTER_CHUNKY_TO_PLANAR
	lea	column.offsets(pc),a3
	add.w	d1,d1
	add.w	d1,a3
	ENDC

.next.strip
	lea	chunky.data(pc),a5
	add.w	(a2)+,a5		chunky data address

	move.w	(a1)+,d7		y2
	move.w	d7,d5
	move.w	(a0)+,d6		y1
	sub.w	d6,d5

	lea	chunky.y.offset.ptrs(pc),a7
	move.l	(a7,d5.w*4),a7		chunky y offsets

	tst.w	d6
	bpl.s	.y1.on.screen
	neg.w	d6
	subq.w	#1,d6

.skip.data
	add.w	(a7)+,a5		skip chunky data if off screen
	dbra	d6,.skip.data
	moveq	#0,d6

.y1.on.screen
	cmp.w	#SCREEN_HEIGHT-1,d7
	ble.s	.y2.on.screen
	move.w	#SCREEN_HEIGHT-1,d7

.y2.on.screen

* draw.strip
*
* d1 = x, d6 = y1, d7 = y2
* a5 = chunky data address
* uses d4-d7, a6

	move.l	(a4,d6.w*4),a6
	IFD	FASTER_CHUNKY_TO_PLANAR
	add.w	(a3)+,a6		chunky screen address
	ELSE
	add.w	d1,a6			chunky screen address
	ENDC

	sub.w	d6,d7
	addq.w	#1,d7			pixel count

	move.w	d7,d6
	and.w	#7,d6
	beq.s	.8.pixel.multiples
	subq.w	#1,d6

.next.pixel
	move.b	(a5),(a6)
	lea	SCREEN_WIDTH(a6),a6
	add.w	(a7)+,a5
	dbra	d6,.next.pixel

.8.pixel.multiples
	lsr.w	#3,d7
	beq.s	.done.strip
	subq.w	#1,d7

.next.8.pixels
	REPT	8
	move.b	(a5),(a6)
	lea	SCREEN_WIDTH(a6),a6
	add.w	(a7)+,a5
	ENDR
	dbra	d7,.next.8.pixels

.done.strip
	IFND	FASTER_CHUNKY_TO_PLANAR
	addq.w	#1,d1			px + 1
	ENDC
	dbra	d0,.next.strip

	move.l	saved.a7(pc),a7
	rts


	IFD	FASTER_CHUNKY_TO_PLANAR
column.offsets
* to put sets of 32 bytes:-
*	.A.B.C.D	.E.F.G.H	.I.J.K.L	.M.N.O.P	.Q.R.S.T	.U.V.W.X	.Y.Z.a.b	.c.d.e.f
* into this order in chunky memory:-
*	.A.I.Q.Y	.B.J.R.Z	.C.K.S.a	.D.L.T.b	.E.M.U.c	.F.N.V.d	.G.O.W.e	.H.P.X.f
*
* contains 320 values, enough for SCREEN_WIDTH of 320
*
	dc.w	0,4,8,12,16,20,24,28	set 1
	dc.w	1,5,9,13,17,21,25,29
	dc.w	2,6,10,14,18,22,26,30
	dc.w	3,7,11,15,19,23,27,31

	dc.w	32+0,32+4,32+8,32+12,32+16,32+20,32+24,32+28	set 2
	dc.w	32+1,32+5,32+9,32+13,32+17,32+21,32+25,32+29
	dc.w	32+2,32+6,32+10,32+14,32+18,32+22,32+26,32+30
	dc.w	32+3,32+7,32+11,32+15,32+19,32+23,32+27,32+31

	dc.w	64+0,64+4,64+8,64+12,64+16,64+20,64+24,64+28	set 3
	dc.w	64+1,64+5,64+9,64+13,64+17,64+21,64+25,64+29
	dc.w	64+2,64+6,64+10,64+14,64+18,64+22,64+26,64+30
	dc.w	64+3,64+7,64+11,64+15,64+19,64+23,64+27,64+31

	dc.w	96+0,96+4,96+8,96+12,96+16,96+20,96+24,96+28	set 4
	dc.w	96+1,96+5,96+9,96+13,96+17,96+21,96+25,96+29
	dc.w	96+2,96+6,96+10,96+14,96+18,96+22,96+26,96+30
	dc.w	96+3,96+7,96+11,96+15,96+19,96+23,96+27,96+31

	dc.w	128+0,128+4,128+8,128+12,128+16,128+20,128+24,128+28	set 5
	dc.w	128+1,128+5,128+9,128+13,128+17,128+21,128+25,128+29
	dc.w	128+2,128+6,128+10,128+14,128+18,128+22,128+26,128+30
	dc.w	128+3,128+7,128+11,128+15,128+19,128+23,128+27,128+31

	dc.w	160+0,160+4,160+8,160+12,160+16,160+20,160+24,160+28	set 6
	dc.w	160+1,160+5,160+9,160+13,160+17,160+21,160+25,160+29
	dc.w	160+2,160+6,160+10,160+14,160+18,160+22,160+26,160+30
	dc.w	160+3,160+7,160+11,160+15,160+19,160+23,160+27,160+31

	dc.w	192+0,192+4,192+8,192+12,192+16,192+20,192+24,192+28	set 7
	dc.w	192+1,192+5,192+9,192+13,192+17,192+21,192+25,192+29
	dc.w	192+2,192+6,192+10,192+14,192+18,192+22,192+26,192+30
	dc.w	192+3,192+7,192+11,192+15,192+19,192+23,192+27,192+31

	dc.w	224+0,224+4,224+8,224+12,224+16,224+20,224+24,224+28	set 8
	dc.w	224+1,224+5,224+9,224+13,224+17,224+21,224+25,224+29
	dc.w	224+2,224+6,224+10,224+14,224+18,224+22,224+26,224+30
	dc.w	224+3,224+7,224+11,224+15,224+19,224+23,224+27,224+31

	dc.w	256+0,256+4,256+8,256+12,256+16,256+20,256+24,256+28	set 9
	dc.w	256+1,256+5,256+9,256+13,256+17,256+21,256+25,256+29
	dc.w	256+2,256+6,256+10,256+14,256+18,256+22,256+26,256+30
	dc.w	256+3,256+7,256+11,256+15,256+19,256+23,256+27,256+31

	dc.w	288+0,288+4,288+8,288+12,288+16,288+20,288+24,288+28	set 10
	dc.w	288+1,288+5,288+9,288+13,288+17,288+21,288+25,288+29
	dc.w	288+2,288+6,288+10,288+14,288+18,288+22,288+26,288+30
	dc.w	288+3,288+7,288+11,288+15,288+19,288+23,288+27,288+31
	ENDC


chunky.screen.ptrs
	ds.l	SCREEN_HEIGHT


;""""""""""""""""""""""""""""""""""""""""""""""
;" CALCULATE CO-ORDS OF EACH POINT ALONG LINE "
;"					      "
;""""""""""""""""""""""""""""""""""""""""""""""

STORE_X_COORDS	equ	0


STORE_X	MACRO
	IFNE	STORE_X_COORDS
	move.w	d0,(a1)+
	ENDC
	ENDM


* d0 = x1, d1 = y1, d2 = x2, d3 = y2

calc.line
	sub.w	d0,d2			x2-x1
	bmi.s	.line.left

.line.right
	sub.w	d1,d3			y2-y1
	bmi.s	.line.up

.line.down
	cmp.w	d2,d3
	blt	calc.octant7
	bra	calc.octant6

.line.up
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	calc.octant0
	bra.s	calc.octant1

.line.left
	neg.w	d2			make delta-x positive

	sub.w	d1,d3			y2-y1
	bmi.s	.line.up2

.line.down2
	cmp.w	d2,d3
	blt	calc.octant4
	bra	calc.octant5

.line.up2
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt	calc.octant3
	bra.s	calc.octant2


calc.octant0
	move.w	d2,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d3,d3			2 Sdelta
	move.w	d3,d7
	sub.w	d2,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d2,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d2
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	addq.w	#1,d0
	subq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
	rts

.move1	addq.w	#1,d0
	add.w	d3,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
.done	rts


calc.octant1
	move.w	d3,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d2,d2			2 Sdelta
	move.w	d2,d7
	sub.w	d3,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d3,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d3
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	addq.w	#1,d0
	subq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
	rts

.move1	subq.w	#1,d1
	add.w	d2,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
.done	rts


calc.octant2
	move.w	d3,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d2,d2			2 Sdelta
	move.w	d2,d7
	sub.w	d3,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d3,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d3
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	subq.w	#1,d0
	subq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
	rts

.move1	subq.w	#1,d1
	add.w	d2,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
.done	rts


calc.octant3
	move.w	d2,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d3,d3			2 Sdelta
	move.w	d3,d7
	sub.w	d2,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d2,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d2
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	subq.w	#1,d0
	subq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
	rts

.move1	subq.w	#1,d0
	add.w	d3,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
.done	rts


calc.octant4
	move.w	d2,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d3,d3			2 Sdelta
	move.w	d3,d7
	sub.w	d2,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d2,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d2
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	subq.w	#1,d0
	addq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
	rts

.move1	subq.w	#1,d0
	add.w	d3,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
.done	rts


calc.octant5
	move.w	d3,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d2,d2			2 Sdelta
	move.w	d2,d7
	sub.w	d3,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d3,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d3
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	subq.w	#1,d0
	addq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
	rts

.move1	addq.w	#1,d1
	add.w	d2,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
.done	rts


calc.octant6
	move.w	d3,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d2,d2			2 Sdelta
	move.w	d2,d7
	sub.w	d3,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d3,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d3
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	addq.w	#1,d0
	addq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
	rts

.move1	addq.w	#1,d1
	add.w	d2,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d3,.loop
.done	rts


calc.octant7
	move.w	d2,(a1)+		count

	STORE_X				x1
	move.w	d1,(a1)+		y1

	add.w	d3,d3			2 Sdelta
	move.w	d3,d7
	sub.w	d2,d7			2 Sdelta - Ldelta
	move.w	d7,d4
	sub.w	d2,d4			2 Sdelta - 2 Ldelta

	subq.w	#1,d2
	bmi.s	.done

.loop	tst.w	d7
	bmi.s	.move1

.move2	addq.w	#1,d0
	addq.w	#1,d1
	add.w	d4,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
	rts

.move1	addq.w	#1,d0
	add.w	d3,d7
	STORE_X
	move.w	d1,(a1)+
	dbra	d2,.loop
.done	rts


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
	bsr.s	clip.line

	move.w	#COORD_2,d0
	move.w	#COORD_4,d2
	lea	rotated.wall.coords(pc),a1
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr.s	clip.line

.done	rts


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

	tst.w	d2			delta-x
	bmi.s	.line.left

.line.right
	tst.w	d3			delta-y
	bmi.s	.line.up

.line.down
	cmp.w	d2,d3
	blt.s	.octant7

.octant6
	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	dl.size

.octant7
	move.w	#%10001,d4
	bra.s	dl.size


.line.up
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	.octant0

.octant1
	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	dl.size

.octant0
	move.w	#%11001,d4
	bra.s	dl.size


.line.left
	neg.w	d2			make delta-x positive

	tst.w	d3			delta-y
	bmi.s	.line.up2

.line.down2
	cmp.w	d2,d3
	blt.s	.octant4

.octant5
	exg	d2,d3			larger delta into d2
	move.w	#%01001,d4
	bra.s	dl.size

.octant4
	move.w	#%10101,d4
	bra.s	dl.size


.line.up2
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	.octant3

.octant2
	exg	d2,d3			larger delta into d2
	move.w	#%01101,d4
	bra.s	dl.size

.octant3
	move.w	#%11101,d4


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


*""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER "
*" (4 bitplane version)	      "
*"			      "
*""""""""""""""""""""""""""""""

* 03/03/2012 optimised FASTER_CHUNKY_TO_PLANAR version:-
* (Note that the optimisations also work without FASTER_CHUNKY_TO_PLANAR defined)
*	68000 CPU cycles reqd: 88 + ((width*height)/32 * 454) + 16
*	(908104 cycles for 320*200 screen)
*	(about 0.13 seconds on an A500)
*	approx. 14 CPU cycles per screen pixel

* 01/03/2012 optimised version:-
* (When FASTER_CHUNKY_TO_PLANAR not defined)
*	68000 CPU cycles reqd: 120 + ((width*height)/32 * 680) + 32
*	(1360152 cycles for 320*200 screen)
*	(about 0.19 seconds on an A500)
*	approx. 21 CPU cycles per screen pixel

* Original FASTER_CHUNKY_TO_PLANAR version:-
*	68000 CPU cycles reqd: 108 + ((width*height)/32 * 548) + 32
*	(1096140 cycles for 320*200 screen)
*	(about 0.15 seconds on an A500)
*	approx. 17 CPU cycles per screen pixel

	cnop	0,4

new.chunky.convert.long
	move.l	chunky.memory(pc),a0			16
	move.l	screen1(pc),a4				16
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a4),a3	8
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a3),a2	8
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a2),a1	8
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7	8

	IFND	FASTER_CHUNKY_TO_PLANAR
	move.l	a7,saved.a7				20
	move.l	#$00ff00ff,a7				12
	move.l	#$33333333,a6				12
	move.l	#$55555555,a5				12
	ELSE
	move.l	#$33333333,d3
	move.l	#$55555555,d5
	ENDC

;	nop		longword align to improve performance on 68020+

.next.32.pixels
	IFD	FASTER_CHUNKY_TO_PLANAR
	movem.l	(a0)+,d0/d2/d4/d6	44
* d0	.A.I.Q.Y
* d2	.B.J.R.Z
* d4	.C.K.S.a
* d6	.D.L.T.b
* (a0)+	.E.M.U.c
* (a0)+	.F.N.V.d
* (a0)+	.G.O.W.e
* (a0)+	.H.P.X.f

* could also remove the four logical shifts below,
* if half of the columns had the pixel information stored to the high nibble
	lsl.l	#4,d0			A.I.Q.Y.
	lsl.l	#4,d2			B.J.R.Z.
	lsl.l	#4,d4			C.K.S.a.
	lsl.l	#4,d6			D.L.T.b.
* could possibly also remove following four or's if plot routine or'ed every other pixel
* (I think this would make the chunky buffer half the size so would also reduce number of moves above
*  and also speed up the clear routine)
	or.l	(a0)+,d0		AEIMQUYc
	or.l	(a0)+,d2		BFJNRVZd
	or.l	(a0)+,d4		CGKOSWae
	or.l	(a0)+,d6		DHLPTXbf

	ELSE

	movem.l	(a0)+,d0-d6		68
* d0	.A.B.C.D
* d1	.E.F.G.H
* d2	.I.J.K.L
* d3	.M.N.O.P
* d4	.Q.R.S.T
* d5	.U.V.W.X
* d6	.Y.Z.a.b
* (a0)	.c.d.e.f
	lsl.l	#4,d0			A.B.C.D.	16
	lsl.l	#4,d2			I.J.K.L.	16
	lsl.l	#4,d4			Q.R.S.T.	16
	lsl.l	#4,d6			Y.Z.a.b.	16
	or.l	d1,d0			AEBFCGDH	8
	or.l	d3,d2			IMJNKOLP	8
	or.l	d5,d4			QURVSWTX	8
	or.l	(a0)+,d6		YcZdaebf	14

* d0 = AEBFCGDH
* d2 = IMJNKOLP
* d4 = QURVSWTX
* d6 = YcZdaebf

* 16-bit transpose AEBFCGDH and QURVSWTX
	swap	d4			SWTXQURV	4
	move.w	d0,d1			....CGDH	4
	move.w	d4,d0			AEBFQURV	4
	move.w	d1,d4			SWTXCGDH	4
	swap	d4			CGDHSWTX	4 = total 20 cycles

* 16-bit transpose IMJNKOLP and YcZdaebf
	swap	d6			aebfYcZd
	move.w	d2,d3			....KOLP
	move.w	d6,d2			IMJNYcZd
	move.w	d3,d6			aebfKOLP
	swap	d6			KOLPaebf	total 20 cycles

* d0 = AEBFQURV
* d2 = IMJNYcZd
* d4 = CGDHSWTX
* d6 = KOLPaebf

	move.l	a7,d5			4

* 8-bit transpose AEBFQURV and IMJNYcZd
*			d0 = AEBFQURV
*			d2 = IMJNYcZd
	move.l	d2,d1						4
	lsr.l	#8,d1	d1 = ..IMJNYc				24
	eor.l	d0,d1						8
	and.l	d5,d1	d1 = (d1 ^ d0) & $00ff00ff = mask	8
	eor.l	d1,d0	d0 = AEIMQUYc				8
	lsl.l	#8,d1	d1 = mask << 8				24
	eor.l	d1,d2	d2 = BFJNRVZd				8 = total 84 cycles

* 8-bit transpose CGDHSWTX and KOLPaebf
*			d4 = CGDHSWTX
*			d6 = KOLPaebf
	move.l	d6,d1						4
	lsr.l	#8,d1	d1 = ..KOLPae				24
	eor.l	d4,d1						8
	and.l	d5,d1	d1 = (d1 ^ d4) & $00ff00ff = mask	8
	eor.l	d1,d4	d4 = CGKOSWae				8
	lsl.l	#8,d1	d1 = mask << 8				24
	eor.l	d1,d6	d6 = DHLPTXbf				8 = total 84 cycles
	ENDC

* d0 = AEIMQUYc
* d2 = BFJNRVZd
* d4 = CGKOSWae
* d6 = DHLPTXbf

* section common to both methods
	IFND	FASTER_CHUNKY_TO_PLANAR
	move.l	a6,d3			4
	ENDC

* 2-bit transpose AEIMQUYc and CGKOSWae
*			d0 = A3A2A1A0E3E2E1E0I3I2I1I0M3M2M1M0Q3Q2Q1Q0U3U2U1U0Y3Y2Y1Y0c3c2c1c0
*			d4 = C3C2C1C0G3G2G1G0K3K2K1K0O3O2O1O0S3S2S1S0W3W2W1W0a3a2a1a0e3e2e1e0
	move.l	d4,d1										4
	lsr.l	#2,d1	d1 = ....C3C2C1C0G3G2G1G0K3K2K1K0O3O2O1O0S3S2S1S0W3W2W1W0a3a2a1a0e3e2	12
	eor.l	d0,d1										8
	and.l	d3,d1	d1 = (d1 ^ d0) & $33333333 = mask					8
	eor.l	d1,d0	d0 = A3A2C3C2E3E2G3G2I3I2K3K2M3M2O3O2Q3Q2S3S2U3U2W3W2Y3Y2a3a2c3c2e3e2	8
	lsl.l	#2,d1	d1 = mask << 2								12
	eor.l	d1,d4	d4 = A1A0C1C0E1E0G1G0I1I0K1K0M1M0O1O0Q1Q0S1S0U1U0W1W0Y1Y0a1a0c1c0e1e0	8 = total 60 cycles

* 2-bit transpose BFJNRVZd and DHLPTXbf
*			d2 = B3B2B1B0F3F2F1F0J3J2J1J0N3N2N1N0R3R2R1R0V3V2V1V0Z3Z2Z1Z0d3d2d1d0
*			d6 = D3D2D1D0H3H2H1H0L3L2L1L0P3P2P1P0T3T2T1T0X3X2X1X0b3b2b1b0f3f2f1f0
	move.l	d6,d1
	lsr.l	#2,d1	d1 = ....D3D2D1D0H3H2H1H0L3L2L1L0P3P2P1P0T3T2T1T0X3X2X1X0b3b2b1b0f3f2
	eor.l	d2,d1
	and.l	d3,d1	d1 = (d1 ^ d2) & $33333333 = mask
	eor.l	d1,d2	d2 = B3B2D3D2F3F2H3H2J3J2L3L2N3N2P3P2R3R2T3T2V3V2X3X2Z3Z2b3b2d3d2f3f2
	lsl.l	#2,d1	d1 = mask << 2
	eor.l	d1,d6	d6 = B1B0D1D0F1F0H1H0J1J0L1L0N1N0P1P0R1R0T1T0V1V0X1X0Z1Z0b1b0d1d0f1f0	total 60 cycles

	IFND	FASTER_CHUNKY_TO_PLANAR
	move.l	a5,d5			4
	ENDC

* 1-bit transpose and output bits 0 and 1
*			d4 = A1A0C1C0E1E0G1G0I1I0K1K0M1M0O1O0Q1Q0S1S0U1U0W1W0Y1Y0a1a0c1c0e1e0
*			d6 = B1B0D1D0F1F0H1H0J1J0L1L0N1N0P1P0R1R0T1T0V1V0X1X0Z1Z0b1b0d1d0f1f0
	move.l	d6,d1										4
	lsr.l	#1,d1	d1 = ..B1B0D1D0F1F0H1H0J1J0L1L0N1N0P1P0R1R0T1T0V1V0X1X0Z1Z0b1b0d1d0f1	10
	eor.l	d4,d1										8
	and.l	d5,d1	d1 = (d1 ^ d4) & $55555555 = mask					8
	eor.l	d1,d4	d4 = A1B1C1D1E1F1G1H1I1J1K1L1M1N1O1P1Q1R1S1T1U1V1W1X1Y1Z1a1b1c1d1e1f1	8
	move.l	d4,(a3)+		plane 1							12
	add.l	d1,d1	d1 = mask << 1								8
	eor.l	d1,d6	d6 = A0B0C0D0E0F0G0H0I0J0K0L0M0N0O0P0Q0R0S0T0U0V0W0X0Y0Z0a0b0c0d0e0f0	8
	move.l	d6,(a4)+		plane 0							12 = total 78 cycles

* 1-bit transpose and output bits 2 and 3
*			d0 = A3A2C3C2E3E2G3G2I3I2K3K2M3M2O3O2Q3Q2S3S2U3U2W3W2Y3Y2a3a2c3c2e3e2
*			d2 = B3B2D3D2F3F2H3H2J3J2L3L2N3N2P3P2R3R2T3T2V3V2X3X2Z3Z2b3b2d3d2f3f2
	move.l	d2,d1
	lsr.l	#1,d1	d1 = ..B3B2D3D2F3F2H3H2J3J2L3L2N3N2P3P2R3R2T3T2V3V2X3X2Z3Z2b3b2d3d2f3
	eor.l	d0,d1
	and.l	d5,d1	d1 = (d1 ^ d0) & $55555555 = mask
	eor.l	d1,d0	d0 = A3B3C3D3E3F3G3H3I3J3K3L3M3N3O3P3Q3R3S3T3U3V3W3X3Y3Z3a3b3c3d3e3f3
	move.l	d0,(a1)+		plane 3
	add.l	d1,d1	d1 = mask << 1
	eor.l	d1,d2	d2 = A2B2C2D2E2F2G2H2I2J2K2L2M2N2O2P2Q2R2S2T2U2V2W2X2Y2Z2a2b2c2d2e2f2
	move.l	d2,(a2)+		plane 2							total 78 cycles

* TO DO: Try to further separate the plane 1/0 and plane 3/2 memory writes above, to improve performance on 68020+
* (e.g. by using d4 and d6 which are spare after plane 1 and 0 are written)

	dbra	d7,.next.32.pixels	14 (when branch taken)

	IFND	FASTER_CHUNKY_TO_PLANAR
	move.l	saved.a7(pc),a7		16
	ENDC
	rts				16


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

;	move.w	wall.x.start(pc),d0
;	lea	.pos.text+31(pc),a0
;	bsr	make.hex.word2

	lea	.pos.text(pc),a0
	moveq	#0,d0
	move.w	#200-8,d1
	bra	print


.pos.text	dc.b	'X 00000000 Z 00000000 A 0000 V 0000',0
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

	move.w	d1,old.vpos
	move.w	vblank.count(pc),old.vblank
	rts


raster.count.stop
	move.l	$dff004.l,d1
	lsr.l	#8,d1
	andi.w	#$1FF,d1		vertical position

	sub.w	old.vpos(pc),d1

	move.w	vblank.count(pc),d2
	sub.w	old.vblank(pc),d2
	beq.s	.done
	subq.w	#1,d2
.loop	add.w	#312,d1
	dbra	d2,.loop

.done	move.w	d1,raster.count
	rts


print.raster.count
	move.w	raster.count(pc),d0
	lea	.count.text+2(pc),a0
	bsr	make.hex.word2

	lea	.count.text(pc),a0
	moveq	#6,d0
	move.w	#SCREEN_HEIGHT-8,d1
	bra.s	print


.count.text	dc.b	'R 0000',0
	even

old.vblank	dc.w	0
old.vpos	dc.w	0
raster.count	dc.w	0


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
	moveq	#2-1,d1			2 rows
;;	clr.w	fill.colour+2		start colour at 0

next.row
	moveq	#4,d2			start x
	moveq	#8-1,d3			8 columns

next.column
;;	bsr.s	fill.box

;;	addq.w	#4,fill.colour+2	next colour
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

;;	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

;;	bsr	fill

	movem.w	(sp)+,d0-d3
	rts




print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address
	moveq	#0,d1
	move.w	#40,d2			bytes per line

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
;;	move.b	d1,40(a2)		bitplane 2
;;	move.b	d1,80(a2)		bitplane 3
;;	move.b	d1,120(a2)		bitplane 4

	add.w	d2,a2			next screen line
	dbra	d0,char.loop

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




*""""""""""""""""""""
*" PRINT FRAME RATE "
*"		    "
*""""""""""""""""""""

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
	moveq	#32,d0			x
	moveq	#0,d1			y
	bra	print



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

	move.l	d0,cop1lch+$dff000	set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
	bsr.s	init.copper

	move.l	screen3(pc),d0
	move.l	copper3(pc),a0
;	bra.s	init.copper




init.copper
	moveq	#4-1,d1
;	moveq	#40,d2			width of one bitplane
	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT,d2	size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""

copper.list1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list3
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.memory	dc.l	0
chunky.memory	dc.l	0

screen1		dc.l	0
screen2		dc.l	0
screen3		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2
copper3		dc.l	copper.list3

gfxbase		dc.l	0
old.ints	dc.w	0
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0

raw.key.code	dc.b	0
palette.requested	dc.b	0
frames.requested	dc.b	0
auto.move	dc.b	0

mouse.data	dc.b	0,0
old.mouse.x	dc.b	0
old.mouse.y	dc.b	0

player.x	dc.l	0
player.y	dc.l	0
player.z	dc.l	0

player.x.angle	dc.w	0
player.y.angle	dc.w	0
player.z.angle	dc.w	0

base.x.angle	dc.w	0
base.y.angle	dc.w	0
base.z.angle	dc.w	0

;sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$0400000

vblank.occured	dc.b	0,0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




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


;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

y.table	ds.w	SCREEN_HEIGHT


chunky.data	ds.b	SOURCE_WIDTH*SOURCE_HEIGHT
* blank line after
		ds.b	SOURCE_WIDTH


bitmap	;incbin	brush/beach.bin
;	incbin	brush/blocks1.bin
;	incbin	brush/blocks2.bin
;	incbin	brush/ed209.bin
;	incbin	brush/eddie.bin
;	incbin	brush/gods1.bin
;;	incbin	brush/gods2.bin
;	incbin	brush/gods3.bin
	incbin	brush/gods4.bin
;	incbin	brush/paint.bin
;;	incbin	brush/speed1.bin
;	incbin	brush/speed2.bin
;	incbin	brush/speed3.bin
;	incbin	brush/speed4.bin
;	incbin	brush/speed5.bin
;;	incbin	brush/speed6.bin
;	incbin	brush/speed7.bin
;	incbin	brush/speed8.bin
;	incbin	brush/speed9.bin
;	incbin	brush/speed10.bin




*""""""""""""""""""""""""""""""
*" CALCULATE CHUNKY Y OFFSETS "
*"			      "
*""""""""""""""""""""""""""""""

START_HEIGHT	equ	2
END_HEIGHT	equ	255

TOTAL_HEIGHTS	equ	END_HEIGHT-START_HEIGHT+1


chunky.y.offset.ptrs
	ds.l	END_HEIGHT		for heights from 1 to END_HEIGHT
	ds.l	1			for last ptr


calc.chunky.y.offsets
	lea	chunky.y.offsets(pc),a0
	lea	chunky.y.offset.ptrs(pc),a1
	moveq	#6,d7			depends upon SOURCE_WIDTH
	move.l	#(SOURCE_HEIGHT-1)<<16,d0
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	moveq	#START_HEIGHT,d3
	move.w	#TOTAL_HEIGHTS-1,d6	count for dbra

.next.width
	move.l	d3,d2			current height
	subq.w	#1,d2			number of values required (height-1)
	move.l	d0,d1
	divsl.l	d2,d1:d1
	moveq	#0,d4
	moveq	#0,d5

	subq.w	#1,d2			count for dbra

.next.value
	move.w	d4,d5
	swap	d4
	add.l	d1,d4
	swap	d4
	sub.w	d4,d5
	neg.w	d5
	asl.w	d7,d5			64 bytes per chunky line
	move.w	d5,(a0)+
	dbra	d2,.next.value

	move.l	a0,(a1)+
	addq.w	#1,d3
	dbra	d6,.next.width
	rts


START_VALUES	equ	START_HEIGHT-1
END_VALUES	equ	END_HEIGHT-1


chunky.y.offsets
*
* (average height * total heights)
*
	ds.w	((START_VALUES+END_VALUES)*(TOTAL_HEIGHTS))/2




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
