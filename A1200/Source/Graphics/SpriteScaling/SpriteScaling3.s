	section	SpriteScaling,code
	opt	c+


; This version combines the four planex_definition, _data and _fill_source areas into one so that
; plot_fill_dots only has to be called once and therefore only needs to calculate each x once
; (still does four blitter fills though because only writing to portion of screen)


HORIZ_SCALE_ONLY	equ	1	; only do horizontal sprite scaling

; Only uncomment one of the following lines
;TEST_CHUNKY_METHOD	equ	1
TEST_TRODDLERS_METHOD	equ	1	; Real A500 28-29 fps


; Based on Txwalls(020+)7.s
;
; possible optimisations:
;	remove vblank wait by using triple planar buffers
;	clear second chunky buffer at same time as drawing to first
;	or only clear parts of buffer that haven't been draw to
;
; try FASTER_CHUNKY_TO_PLANAR (if compatible)


;FASTER_CHUNKY_TO_PLANAR	equ	1

;DEBUG	equ	1

;	IFND	DEBUG
;	opt	o+
;	ENDC


;""""""""""""""""""""""
;" SCREEN DEFINITIONS "
;"		      "
;""""""""""""""""""""""

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


;"""""""""""""""""""""""""""""
;" SOURCE BITMAP DEFINITIONS "
;"			     "
;"""""""""""""""""""""""""""""

BITMAP_WIDTH	equ	64	;320
BITMAP_HEIGHT	equ	64	;256
BITMAP_DEPTH	equ	4

BITMAP_SIZE	equ	BITMAP_WIDTH/8*BITMAP_HEIGHT*BITMAP_DEPTH

SOURCE_WIDTH	equ	64		* Size within bitmap
SOURCE_HEIGHT	equ	64


;"""""""""""""""""
;" START OF CODE "
;"		 "
;"""""""""""""""""

start	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		turn multitasking off
	ENDC

	IFD	TEST_CHUNKY_METHOD
* Allocate chunky screen memory

	move.l	#CHUNKY_MEMORY_SIZE,d0
	moveq	#1,d1			public
	jsr	-198(a6)		AllocMem
	move.l	d0,chunky.memory
	beq	exit_now
	ENDC

* Allocate planar screen memory

	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	#$10002,d1		clear chip
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

	IFD	TEST_CHUNKY_METHOD
	bsr	init.auto.move
	bsr	initialise.data
	st.b	frames.requested

main.loop
	bsr	render.frame

	bsr	auto.move.object

	IFND	DEBUG
	jsr	keyboard.requests

; limit to 50fps (ensure at least one vertical blank has occured)
	move.w	last.vblank.count(pc),d7
wait.vblank
	cmp.w	vblank.count(pc),d7
	beq.s	wait.vblank

	move.w	vblank.count(pc),last.vblank.count
	bsr	update.screens
	ENDC

	btst	#6,$bfe001
	bne.s	main.loop
	ENDC




	IFD	TEST_TRODDLERS_METHOD
	bsr	init.auto.move
	bsr	initialise
	st.b	frames.requested

main.loop
	bsr	render_frame

	bsr	auto.move.object

	IFND	DEBUG
	jsr	keyboard.requests

; limit to 50fps (ensure at least one vertical blank has occured)
	move.w	last.vblank.count(pc),d7
wait.vblank
	cmp.w	vblank.count(pc),d7
	beq.s	wait.vblank

	move.w	vblank.count(pc),last.vblank.count
	ENDC

	btst	#6,$bfe001
	bne.s	main.loop
	ENDC


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
	IFD	TEST_CHUNKY_METHOD
	move.l	#CHUNKY_MEMORY_SIZE,d0
	move.l	chunky.memory(pc),a1
	jsr	-210(a6)		FreeMem
	ENDC

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

;	st.b	vblank.occured
	addq.w	#1,vblank.count

	IFD	NOT_USED
	lea	mouse.data,a0

	move.b	$dff00b,d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x(pc),d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$dff00a,d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y(pc),d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y
	ENDC

;	tst.b	auto.move
;	bne.s	end.level3

;	bsr.s	set.x.y.z.angles

end.level3
	movem.l	(sp)+,d0-d1/a0
	rte


vblank.count	dc.w	0
last.vblank.count	dc.w	0


	IFD	NOT_USED
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
	ENDC


	IFD	TEST_CHUNKY_METHOD
SPRITE_WORLD_SIZE	equ	$4000

MAX_Z	equ	(SPRITE_WORLD_SIZE/16)<<16	; should be $4000000
MIN_Z	equ	(SPRITE_WORLD_SIZE/320)<<16
Z_STEP	equ	-$40000


init.auto.move
	st.b	auto.move
	move.w	#0,sequence.no

	move.l	#0,x.offset
	move.l	#0,y.offset
	move.l	#MAX_Z,z.offset
	move.l	#Z_STEP,zstep

;	move.w	#0,base.x.angle
;	move.w	#0,base.y.angle
;	move.w	#0,base.z.angle
;	move.w	#0,xastep
;	move.w	#0,yastep
;	move.w	#0,zastep
	rts


auto.move.object
	tst.b	auto.move
	beq.s	end.auto.move
	move.w	sequence.no(pc),d0
	cmp.w	#0,d0
	beq.s	auto1
	cmp.w	#1,d0
	beq.s	auto2
	cmp.w	#2,d0
	beq.s	auto3
;	cmp.w	#3,d0
;	beq	auto4
end.auto.move
	rts

* zoom in
auto1	move.l	z.offset(pc),d1
	add.l	zstep(pc),d1
	cmp.l	#MIN_Z,d1
	bgt.s	.update
	move.l	#MIN_Z,d1

.next	addq.w	#1,sequence.no
	move.w	#18,sequence.count
	move.l	#0,zstep
;	move.w	#8,zastep

.update	move.l	d1,z.offset
	rts

* no zoom
auto2	subq.w	#1,sequence.count
	bne.s	.done
	addq.w	#1,sequence.no
	move.l	#-Z_STEP,zstep
;	move.w	#12,zastep
.done	rts

* zoom out
auto3	move.l	z.offset(pc),d1
	add.l	zstep(pc),d1
	cmp.l	#MAX_Z,d1
	blt.s	.update
	move.l	#MAX_Z,d1

;	addq.w	#1,sequence.no
.next	move.w	#0,sequence.no
	move.l	#Z_STEP,zstep
;	move.w	#9,xastep
;	move.w	#18,yastep
;	move.w	#15,zastep
.update	move.l	d1,z.offset
	rts

;* zoom in and rotate about all three axes
;auto4	move.l	z.offset(pc),d1
;	cmp.l	#MIN_Z,d1
;	bgt.s	auto.update
;	addq.w	#1,sequence.no
;	move.l	#0,zstep
;	bra.s	auto.update
;
;* finally, no zoom but continue rotation


sequence.no	dc.w	0
sequence.count	dc.w	0

zstep	dc.l	0

;xastep	dc.w	0
;yastep	dc.w	0
;zastep	dc.w	0


;auto.update
;	move.l	zstep(pc),d1
;	add.l	d1,z.offset

;auto.rotate.x.y.z.angles
;	move.w	xastep(pc),d0
;	add.w	d0,d0			word offset for tables
;	add.w	d0,base.x.angle		update x angle
;	and.w	#$7fe,base.x.angle
;
;	move.w	yastep(pc),d0
;	add.w	d0,d0			word offset for tables
;	add.w	d0,base.y.angle		update y angle
;	and.w	#$7fe,base.y.angle
;
;	move.w	zastep(pc),d0
;	add.w	d0,d0			word offset for tables
;	add.w	d0,base.z.angle		update z angle
;	and.w	#$7fe,base.z.angle
;	rts
	ENDC


	IFD	TEST_TRODDLERS_METHOD
MAX_ZOOM	equ	160

init.auto.move
	st.b	auto.move
	move.w	#0,sequence.no
	clr.w	zoom_value
	rts


auto.move.object
	tst.b	auto.move
	beq.s	end.auto.move
	move.w	sequence.no(pc),d0
	cmp.w	#0,d0
	beq.s	auto1
	cmp.w	#1,d0
	beq.s	auto2
	cmp.w	#2,d0
	beq.s	auto3
end.auto.move
	rts


* zoom in
auto1	move.w	zoom_value(pc),d1
	addq.w	#1,d1
	cmp.w	#MAX_ZOOM,d1
	blt.s	.update
	move.w	#MAX_ZOOM,d1

.next	addq.w	#1,sequence.no
	move.w	#100,sequence.count

.update	move.w	d1,zoom_value
	rts

* no zoom
auto2	subq.w	#1,sequence.count
	bne.s	.done
	addq.w	#1,sequence.no
.done	rts

* zoom out
auto3	move.w	zoom_value(pc),d1
	subq.w	#1,d1
	bpl.s	.update
	moveq	#0,d1

.next	move.w	#0,sequence.no
.update	move.w	d1,zoom_value
	rts

sequence.no	dc.w	0
sequence.count	dc.w	0
	ENDC


;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""
	IFD	TEST_CHUNKY_METHOD
initialise.data
	bsr.s	calc.y.table
	bsr.s	calc.chunky.screen.ptrs
	bsr.s	planar.to.chunky
	rts


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

calc.y.table
	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane
	lea	y.table(pc),a0

.loop	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,.loop
	rts


;""""""""""""""""""""""""""""""""
;" CALCULATE CHUNKY SCREEN PTRS	"
;"				"
;""""""""""""""""""""""""""""""""

calc.chunky.screen.ptrs
	move.w	#SCREEN_HEIGHT-1,d0
	lea	chunky.screen.ptrs(pc),a0
	move.l	chunky.memory(pc),a1

.loop	move.l	a1,(a0)+
	lea	SCREEN_WIDTH(a1),a1
	dbra	d0,.loop
	rts


;""""""""""""""""""""""""""""""
;" PLANAR TO CHUNKY CONVERTER "
;"			      "
;""""""""""""""""""""""""""""""

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
	ENDC


	IFD	NOT_USED
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
	ENDC


;""""""""""""""""""""""
;" DRAW SCALED SPRITE "
;"                    "
;""""""""""""""""""""""
	IFD	TEST_CHUNKY_METHOD
render.frame
	bsr	clear.chunky.screen
	bsr.s	draw.scaled.sprite
	bsr	new.chunky.convert.long
	bsr.s	print.sprite.size
	rts


print.sprite.size
	move.w	size(pc),d0
	bsr	make.decimal
	lea	decimal.text(pc),a0
	moveq	#0,d0			x
	moveq	#0,d1			y
	bra	print


	IFD NOT_USED
; draw at original size
draw.sprite
	move.l	a7,saved.a7			NOTE: Don't use a7 for byte operations

	move.l	chunky.memory(pc),a6
	lea	chunky.data(pc),a5
	move.w	#SOURCE_HEIGHT-1,d7

.next.row
	move.w	#SOURCE_WIDTH-1,d6

.next.col
	move.b	(a5)+,(a6)+
	dbra	d6,.next.col

	lea	SCREEN_WIDTH-SOURCE_WIDTH(a6),a6
	dbra	d7,.next.row

	move.l	saved.a7(pc),a7
	rts
	ENDC


	IFD NOT_USED
; test - draw sprite double sized
old.draw.scaled.sprite
	move.l	a7,saved.a7			NOTE: Don't use a7 for byte operations

	move.l	chunky.memory(pc),a6
	lea	chunky.data(pc),a5
	move.w	#SOURCE_HEIGHT-1,d7

.next.row
	move.w	#SOURCE_WIDTH-1,d6

.next.col
	move.b	(a5)+,d5
	move.b	d5,SCREEN_WIDTH(a6)
	move.b	d5,(a6)+
	move.b	d5,SCREEN_WIDTH(a6)
	move.b	d5,(a6)+
	dbra	d6,.next.col

	lea	(SCREEN_WIDTH*2)-(SOURCE_WIDTH*2)(a6),a6
	dbra	d7,.next.row

	move.l	saved.a7(pc),a7
	rts
	ENDC


* NOTE: Byte pre-decrement and post-increment update a7 by 2 bytes
* Can be abused to quickly shift a word by 8 bits?

draw.scaled.sprite
	move.l	#SPRITE_WORLD_SIZE,d7
	move.w	z.offset(pc),d6
	divs	d6,d7
	cmp.w	#SCREEN_WIDTH,d7
	ble.s	.size_ok
	move.w	#SCREEN_WIDTH,d7
.size_ok
	move.w	d7,size			sprite width and height on screen

	move.l	a7,saved.a7		NOTE: Don't use a7 for byte operations

* centre sprite on screen
	lea	chunky.screen.ptrs(pc),a7
	IFD	HORIZ_SCALE_ONLY
	move.w	#SCREEN_HEIGHT-SOURCE_HEIGHT,d5
	ELSE
	move.w	#SCREEN_HEIGHT,d5
	sub.w	d7,d5
	ENDC
*	asr.w	#1,d5	8		SCREEN_HEIGHT/2 - sprite_height/2
*	add.w	d5,d5	4
*	add.w	d5,d5	4

	add.w	d5,d5	4		optimised version
	and.w	#$fffc,d5	8
	move.l	(a7,d5.w),a6

	move.w	#SCREEN_WIDTH,d6
	sub.w	d7,d6

	move.w	d6,d5
	asr.w	#1,d5			SCREEN_WIDTH/2 - sprite_width/2
	add.w	d5,a6			destination start address

	lea	chunky.data(pc),a5

	move.w	d7,d5
	subq.w	#1,d5			1 less for dbra loop

	cmp.w	#SOURCE_WIDTH,d7
	blt.s	reduce

* draw sprite enlarged (or standard size)
	IFD	HORIZ_SCALE_ONLY
	moveq	#SOURCE_HEIGHT-1,d4	row counter
	ELSE
	move.w	d7,d0			vertical ratio value (sprite height)
	move.w	d5,d4			row counter
	ENDC

.next.row
	move.w	d5,d3			column counter

	move.w	d7,d2
	moveq	#SOURCE_WIDTH,d1
	move.l	a5,a4
.next.col
	move.b	(a4),(a6)+
	sub.w	d1,d2
;	bgt.s	.col.ok
	dble	d3,.next.col
	addq.w	#1,a4
	add.w	d7,d2
.col.ok
	dbra	d3,.next.col

* update values ready for next row
	add.w	d6,a6

	IFD	HORIZ_SCALE_ONLY
	lea	SOURCE_WIDTH(a5),a5
	ELSE
	sub.w	#SOURCE_HEIGHT,d0
	bgt.s	.row.ok
	lea	SOURCE_WIDTH(a5),a5
	add.w	d7,d0
	ENDC
.row.ok
	dbra	d4,.next.row

	move.l	saved.a7(pc),a7
	rts


* draw sprite reduced
reduce
	IFD	HORIZ_SCALE_ONLY
	moveq	#SOURCE_HEIGHT-1,d4	row counter
	move.l	a5,a4
	ELSE
	moveq	#0,d0			source row number (*64 for accuracy)
	move.w	d5,d4			row counter
	ENDC

	move.l	#SOURCE_WIDTH*64,d1
	divu	d7,d1

.next.row
	moveq	#0,d2			source column number (*64 for accuracy)
	move.w	d5,d3			column counter

	IFND	HORIZ_SCALE_ONLY
	move.w	d0,d7
	and.w	#$ffc0,d7		quicker than shift right 6 then shift left 6
	lea		(a5,d7.w),a4
	ENDC

.next.col
	move.w	d2,d7
	asr.w	#6,d7
	move.b	(a4,d7.w),(a6)+
	add.w	d1,d2
.col.ok
	dbra	d3,.next.col

* update values ready for next row
	add.w	d6,a6

	IFD	HORIZ_SCALE_ONLY
	lea	SOURCE_WIDTH(a4),a4
	ELSE
	add.w	d1,d0
	ENDC
.row.ok
	dbra	d4,.next.row

	move.l	saved.a7(pc),a7
	rts


size	dc.w	0
	ENDC


;""""""""""""""""""""""""""""""
;" CLEAR CHUNKY SCREEN MEMORY "
;"			      "
;""""""""""""""""""""""""""""""
	IFD	TEST_CHUNKY_METHOD

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
	IFD	HORIZ_SCALE_ONLY
	; only clear area that was drawn to - SCREEN_WIDTH*SOURCE_HEIGHT = 20480 bytes
	add.l	#SCREEN_WIDTH*(((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)+SOURCE_HEIGHT),a7	; ptr to end of memory to clear
	move.w	#12-1,d7
	ELSE
	; clear whole area
	add.l	#CHUNKY_SCREEN_SIZE,a7
	move.w	#38-1,d7
	ENDC
.loop
	REPT	30
	movem.l	d0-d6/a0-a6,-(a7)
	ENDR
	dbra	d7,.loop

	movem.l	d0-d6/a0-a6,-(a7)	;56
	movem.l	d0-d6/a0-a6,-(a7)	;56

	IFD	HORIZ_SCALE_ONLY
	movem.l	d0-d6/a0-a6,-(a7)	;56
	movem.l	d0-d6/a0-a6,-(a7)	;56
	movem.l	d0-d6/a0-a6,-(a7)	;56
	movem.l	d0-d6/a0-a2,-(a7)	;40
	ELSE
	movem.l	d0-d6/a0-a4,-(a7)	;48
	ENDC

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
	ENDC


	IFD	NOT_USED
clear	lea	$dff000,a6
.loop	btst	#6,dmaconr(a6)
	bne.s	.loop

	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1,bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)
	rts
	ENDC


;"""""""""""""""""""""""""""""""""""""""
;" CALCULATE WALL TOP AND BOTTOM EDGES "
;"				       "
;"""""""""""""""""""""""""""""""""""""""

	IFD	NOT_USED
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
	ENDC


	IFD	TEST_CHUNKY_METHOD
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


*""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER "
*" (4 bitplane version)	      "
*"			      "
*""""""""""""""""""""""""""""""

* FASTER_CHUNKY_TO_PLANAR version:
*	68000 CPU cycles reqd: 108 + ((width*height)/32 * 548) + 32
*	(1096140 cycles for 320*200 screen)
*	(about 0.15 seconds on an A500)
*	approx. 17 CPU cycles (4.28 CPU memory cycles) per screen pixel

* original version:
*	68000 CPU cycles reqd: 120 + ((width*height)/32 * 800) + 32
*	(1600152 cycles for 320*200 screen)
*	(about 0.22 seconds on an A500)
*	approx. 25 CPU cycles (6.25 CPU memory cycles) per screen pixel

	cnop	0,4

new.chunky.convert.long
	move.l	chunky.memory(pc),a0
	move.l	screen1(pc),a4

	IFD	HORIZ_SCALE_ONLY
	; only convert area that was drawn to - SCREEN_WIDTH*SOURCE_HEIGHT = 20480 bytes
	lea	SCREEN_WIDTH*((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)(a0),a0
	lea	(SCREEN_WIDTH/8)*((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)(a4),a4
	ENDC

	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	IFD	HORIZ_SCALE_ONLY
	; only convert area that was drawn to - SCREEN_WIDTH*SOURCE_HEIGHT = 20480 bytes
	move.w	#(SCREEN_WIDTH*SOURCE_HEIGHT)/32-1,d7
	ELSE
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7
	ENDC

	move.l	a7,saved.a7
	IFND	FASTER_CHUNKY_TO_PLANAR
	move.l	#$00ff00ff,a5
	ENDC
	move.l	#$33333333,a6
	move.l	#$55555555,a7

;	cnop	0,4

.next.32.pixels
	IFD	FASTER_CHUNKY_TO_PLANAR
	movem.l	(a0)+,d0-d6
* d0	.A.I.Q.Y	*
* d1	.B.J.R.Z	*
* d2	.C.K.S.a	*
* d3	.D.L.T.b	*
* d4	.E.M.U.c
* d5	.F.N.V.d
* d6	.G.O.W.e
* (a0)	.H.P.X.f
*
* could also remove the four logical shifts below,
* if half of the columns had the pixel information stored to the high nibble
	lsl.l	#4,d0			A.I.Q.Y.
	lsl.l	#4,d1			B.J.R.Z.
	lsl.l	#4,d2			C.K.S.a.
	lsl.l	#4,d3			D.L.T.b.
* could possibly also remove following four or's if plot routine or'ed every other pixel
* (I think this would make the chunky buffer half the size so would also reduce number of moves above
*  and also speed up the clear routine)
	or.l	d4,d0			AEIMQUYc
	or.l	d5,d1			BFJNRVZd
	or.l	d6,d2			CGKOSWae
	or.l	(a0)+,d3		DHLPTXbf

; also, speed test this method on real A500 (it's slower under WinUAE)
; i.e. with the last 4 or's done from memory rather than registers
;	movem.l	(a0)+,d0-d3
;	lsl.l	#4,d0			A.I.Q.Y.
;	lsl.l	#4,d1			B.J.R.Z.
;	lsl.l	#4,d2			C.K.S.a.
;	lsl.l	#4,d3			D.L.T.b.
;	or.l	(a0)+,d0		AEIMQUYc
;	or.l	(a0)+,d1		BFJNRVZd
;	or.l	(a0)+,d2		CGKOSWae
;	or.l	(a0)+,d3		DHLPTXbf

	ELSE

	movem.l	(a0)+,d0-d6
* d0	.A.B.C.D	*
* d1	.E.F.G.H
* d2	.I.J.K.L	*
* d3	.M.N.O.P
* d4	.Q.R.S.T	*
* d5	.U.V.W.X
* d6	.Y.Z.a.b	*
* (a0)	.c.d.e.f
	lsl.l	#4,d0			A.B.C.D.
	lsl.l	#4,d2			I.J.K.L.
	lsl.l	#4,d4			Q.R.S.T.
	lsl.l	#4,d6			Y.Z.a.b.
	or.l	d1,d0			AEBFCGDH
	or.l	d3,d2			IMJNKOLP
	or.l	d5,d4			QURVSWTX
	or.l	(a0)+,d6		YcZdaebf

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
	ENDC


* section common to both methods
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
	add.l	d0,d0		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 0
	move.l	d1,d5
	and.l	d6,d5		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 0
	or.l	d5,d0		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 0
	move.l	d0,(a4)+		plane 0
	eor.l	d5,d1		B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 1
	lsr.l	#1,d1		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 1
	or.l	d4,d1		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 1
	move.l	d1,(a3)+		plane 1

	move.l	d2,d4
	and.l	d6,d2		.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 2
	eor.l	d2,d4		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 3
	add.l	d2,d2		A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 2
	move.l	d3,d5
	and.l	d6,d5		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 2
	or.l	d5,d2		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 2
	move.l	d2,(a2)+		plane 2
	eor.l	d5,d3		B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 3
	lsr.l	#1,d3		.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 3
	or.l	d4,d3		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 3
	move.l	d3,(a1)+		plane 3

;	move.l	d3,(a1)+		plane 3
;	move.l	d2,(a2)+		plane 2
;	move.l	d1,(a3)+		plane 1
;	move.l	d0,(a4)+		plane 0
	dbra	d7,.next.32.pixels

	move.l	saved.a7(pc),a7
	rts


saved.a7	dc.l	0
	ENDC


;""""""""""""""""""""
;" TRODDLERS METHOD "
;"		    "
;""""""""""""""""""""

	IFD	TEST_TRODDLERS_METHOD
BYTES_PER_LINE	equ	40
WORDS_PER_LINE	equ	20

initialise
	bsr	create_graphic_definition
	bsr	make_dots_table			; must be before convert_graphic_data
	bsr	convert_graphic_data
	bsr	create_division_lookup
;	bsr	make_copper_list
;	bsr	set_copper_and_dma

;	move.w	#$000,$dff000+color0
;	move.w	#$fff,$dff000+color1
;	move.w	#$00c,$dff000+color2
;	move.w	#$c00,$dff000+color3

;	bsr	clear_buffers
;	move.l	#$fffffffe,copper2A_mem
;	move.l	#$fffffffe,copper2B_mem
	rts


;clear_buffers
;	lea	screen1_mem,a0		; destination address
;	clr.w	d0			; destination modulo
;	move.w	#83*64+22,d1		; blit size
;	bsr	clear
;
;	lea	screen2_mem,a0
;	bsr	clear
;
; fill_source is now double buffered, to allow blitter clearing while plot_fill_dots is running (optimisation)
clear_fill_source			; clear fill source (all planes)
	move.l	plane1to4_fill_source1(pc),a0
	move.l	plane1to4_fill_source2(pc),plane1to4_fill_source1
	move.l	a0,plane1to4_fill_source2

;	move.l	plane1to4_fill_source2(pc),a0
	clr.w	d0
	move.w	#BITMAP_DEPTH*SOURCE_HEIGHT*64+WORDS_PER_LINE,d1
	bsr	clear
	rts


plane1to4_fill_source1	dc.l	plane1to4_fill_source1_mem
plane1to4_fill_source2	dc.l	plane1to4_fill_source2_mem


render_frame
render_sprite
	bsr	update.screens
;	bsr	update_copper_list1	; update copper to show current image
;	bsr	set_display_ptrs	; update pointers for use when drawing next image
	bsr	clear_fill_source	; clear the areas used as sources of the blitter fill operations
	; fill_plane1 will wait for blitter to finish clearing other fill source, before starting blitter fill

;	bsr	scale_vertically	; create copper list to set bitplane ptrs on required raster lines

	lea	plane1to4_data,a1
	move.l	plane1to4_fill_source1(pc),a2
	bsr	plot_fill_dots

	bsr	fill_plane1
	bsr	fill_plane2
	bsr	fill_plane3
	bra	fill_plane4


; create division lookup table
;
; pseudo code:-
;short division_lookup[201];
;
;	i = 0;
;	for (d0 = 0; d0 >= -200; d0--)
;		{
;		d1 = -200 - d0;
;		val = 0;
;		if (d1 != 0)
;			{
;			val = (d0 * 128) / d1;
;			}
;		division_lookup[i++] = val;
;		}
;
;gives table contents:
;0:	   (0 * 128) / -200 = 0
;1:	  (-1 * 128) / -199 = 0
;2:	  (-2 * 128) / -198 = 1
;...
;198:	(-198 * 128) / -2   = 12672
;199:	(-199 * 128) / -1   = 25472
;200:	(-200 * 128) / 0    = 0 (division by zero prevented)
;
create_division_lookup
	lea	division_lookup,a0
	move.w	#0,d0

.next	move.w	#-200,d1
	clr.w	d2
	sub.w	d0,d1
	beq.s	.store
	move.w	d0,d2
	muls	#128,d2
	divs	d1,d2

.store	move.w	d2,(a0)+
	sub.w	#1,d0
	cmp.w	#-200,d0
	bge.s	.next
	rts


; create definitions for each plane, which will then be input to convert_graphic_data
create_graphic_definition
	lea	plane1to4_definition,a1
	move.w	#BITMAP_DEPTH*SOURCE_HEIGHT,(a1)+	; store number of rows

	lea	bitmap(pc),a2
;	lea	temp_counts(pc),a6	;temp
	bsr	.create_plane_definition

	lea	bitmap+(BITMAP_WIDTH/8)(pc),a2
	bsr	.create_plane_definition

	lea	bitmap+(BITMAP_WIDTH/8)*2(pc),a2
	bsr	.create_plane_definition

	lea	bitmap+(BITMAP_WIDTH/8)*3(pc),a2
;	bsr	.create_plane_definition

.create_plane_definition
	moveq	#SOURCE_HEIGHT,d0
	subq.w	#1,d0

.next_row
	move.l	a2,a5
	bsr.s	convert_row_bits
	lea	BITMAP_WIDTH/8*BITMAP_DEPTH(a2),a2	; point to next bitplane row
	lea	end_row_bytes(pc),a3

; processes row from right to left (same direction as blitter fill)
	moveq	#(SOURCE_WIDTH+1)-1,d7
	move.l	a1,a0		; store address of current row count for later
	addq.w	#2,a1
	moveq	#0,d3		; initialise current row count

	move.w	#(SOURCE_WIDTH/2),d6	; start at rightmost x, e.g. 32
	moveq	#0,d4		; initial fill status byte
.next_x	move.b	-(a3),d5
	cmp.b	d4,d5
	beq.s	.no_change
; record bitstream changed state (from 0 to 1 or 1 to 0)
	move.w	d6,(a1)+	; store x (start or end)
	move.b	d5,d4
	addq.w	#1,d3		; increment current row count
.no_change
	subq.w	#1,d6
	dbra	d7,.next_x

	move.w	d3,(a0)		; store count for current row
;	move.w  d3,(a6)+	;temp
;	add.w	d3,total_count	;temp
	dbra	d0,.next_row
	rts


;temp_counts	ds.w	4*SOURCE_HEIGHT
;total_count	dc.w	0


; convert each row bit to a byte, for easier processing
; routine works from left to right and first outputs a zero byte to mark the left edge
; a5 = start of bitplane row
convert_row_bits
	moveq	#SOURCE_WIDTH-1,d7
	moveq	#0,d6			; initialise bit number to 0 to force loop to read first byte
	lea	row_bytes(pc),a3
	sf	(a3)+			; output zero byte = left edge marker

.next_bit
	subq.w	#1,d6
	bpl.s	.got_byte
	moveq	#7,d6			; reset to bit 7 = leftmost
	move.b	(a5)+,d5		; read next input byte
.got_byte
	btst	d6,d5
	sne	(a3)+
	dbra	d7,.next_bit
	rts

row_bytes	ds.b	SOURCE_WIDTH+1
end_row_bytes
	even


; convert graphic definition for all bitplanes into more efficient runtime format
;
; this basically sorts the data by x position ascending (i.e. left to right)
; so that each x only has to be calculated once by the scaling routine
;
; for each x position the routine stores the bitplane offset of each row requiring a set pixel at that x position
; 06/08/2006 - offsets are now relative to the last line, not absolute (allows use of faster plot instructions)
; e.g.
; -50,dots3,0,40,40		x pos -50, plot 3 dots, bitplane offset 0,40 and 80 (i.e. lines 0,1 and 2)
; -49,dots4,40,40,80,120	x pos -49, plot 4 dots, bitplane offset 40,80,120 and 160 (i.e. lines 1,2,4 and 7)
; $4000				end marker
;
; all bitplanes now done together:
; each bitplane's offsets start after the previous bitplane (SOURCE_HEIGHT*BYTES_PER_LINE from the previous)
; e.g. bitplane offset 2560, 2600 and 2640 for lines 0,1 and 2 of bitplane 2
convert_graphic_data
	lea	dots_table,a3
	lea	plane1to4_data,a2
	lea	plane1to4_definition,a1

.convert_plane_data
	move.w	#-50,d0		; start at minimum allowable x position

.next_x	move.l	a1,-(sp)	; save definition start address
	move.w	d0,(a2)+	; store x position
	move.l	a2,a4		; store address of current column's jump table vector for later
	addq.w	#4,a2		; four bytes for jump table vector
	moveq	#0,d4		; initialise current column count

	move.w	(a1)+,d1	; number of rows
	subq.w	#1,d1
	moveq	#0,d3		; start bitplane offset
	move.w	d3,d7		; remember last bitplane offset

.next_row
	move.w	(a1)+,d2	; number of x values for this row
	beq.s	.row_done	; additonal check - Troddlers code didn't do this
	subq.w	#1,d2

.compare
	cmp.w	(a1)+,d0
	beq.s	.store_row	; store row if x value matches
.next_val
	dbra	d2,.compare

.row_done
	add.w	#BYTES_PER_LINE,d3		; next row offset
	dbra	d1,.next_row

	tst.w	d4
	bne.s	.mark_end
	subq.w	#2+4,a2		; no need to store any data for unused x position
	bra.s	.marked

.mark_end
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a3,d4.w),(a4)	; store jump table vector for current column (we no longer use an end marker)

.marked	addq.w	#1,d0		; next x position
	cmp.w	#50,d0		; maximum x position
	move.l	(sp)+,a1	; restore definition start address
	blt.s	.next_x
	move.w	#$4000,(a2)+	; data end marker
	rts

.store_row
;	move.w	d3,(a2)+
	move.w	d3,d6
	sub.w	d7,d6
	move.w	d6,(a2)+	; just store difference (i.e. relative to last line requiring a plot)
	move.w	d3,d7		; remember last bitplane offset

	addq.w	#1,d4		; increment current column count
	bra.s	.next_val


DOTS_INSTRUCTIONS_SIZE	equ	4	; 4 bytes for each pair of move and eor instructions
; make jump table for use by plot_fill_dots
; dots_table currently hard-coded for 300 dots maximum (enough for a SOURCE_HEIGHT of 300/4 = 75)
make_dots_table
	move.w	#(300+1)-1,d6
	lea	dots_table(pc),a6
	lea	dots0(pc),a5
.next	move.l	a5,(a6)+
	subq.w	#DOTS_INSTRUCTIONS_SIZE,a5
	dbra	d6,.next
	rts


; plot dots that will be used as input to blitter fill operation
; a1 = data to plot
; a2 = start address of destination bitplanes
plot_fill_dots
	lea	division_lookup,a0
	lea	pixel_plot_lookup,a4
	move.l	#SCREEN_WIDTH/2,d2		; sprite x centre
	move.w	zoom_value,d0
	IFD	TEST_VERT_SCALE
	moveq	#0,d0
	ENDC
	add.w	d0,d0
	move.w	(a0,d0.w),d4

next_x	move.w	(a1)+,d1		; get next x position
	cmp.w	#$4000,d1		; check for end marker
	beq.s	.done
; calculate screen x
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	.plus			; limit to screen edges
	clr.w	d3
.plus	cmp.w	#SCREEN_WIDTH,d3
	blt.s	.on_screen
	move.w	#SCREEN_WIDTH-1,d3
.on_screen
	move.l	a2,a3			; bitplane start address
	move.b	(a4,d3.w),d6		; get pixel mask
	asr.w	#3,d3
	add.w	d3,a3			; address of column requiring pixel (first line of bitplane)

	move.l	(a1)+,a5		; get jump table vector
	jmp	(a5)			; plot required dots

.done	rts


dots_table
	ds.l	300+1


dots300	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots299	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots298	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots297	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots296	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots295	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots294	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots293	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots292	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots291	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots290	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots289	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots288	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots287	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots286	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots285	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots284	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots283	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots282	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots281	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots280	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots279	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots278	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots277	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots276	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots275	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots274	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots273	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots272	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots271	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots270	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots269	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots268	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots267	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots266	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots265	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots264	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots263	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots262	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots261	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots260	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots259	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots258	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots257	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots256	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots255	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots254	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots253	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots252	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots251	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots250	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots249	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots248	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots247	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots246	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots245	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots244	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots243	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots242	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots241	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots240	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots239	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots238	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots237	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots236	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots235	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots234	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots233	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots232	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots231	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots230	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots229	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots228	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots227	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots226	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots225	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots224	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots223	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots222	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots221	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots220	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots219	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots218	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots217	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots216	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots215	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots214	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots213	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots212	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots211	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots210	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots209	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots208	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots207	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots206	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots205	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots204	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots203	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots202	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots201	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots200	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots199	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots198	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots197	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots196	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots195	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots194	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots193	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots192	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots191	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots190	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots189	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots188	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots187	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots186	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots185	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots184	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots183	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots182	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots181	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots180	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots179	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots178	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots177	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots176	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots175	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots174	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots173	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots172	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots171	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots170	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots169	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots168	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots167	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots166	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots165	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots164	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots163	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots162	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots161	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots160	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots159	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots158	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots157	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots156	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots155	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots154	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots153	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots152	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots151	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots150	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots149	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots148	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots147	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots146	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots145	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots144	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots143	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots142	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots141	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots140	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots139	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots138	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots137	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots136	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots135	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots134	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots133	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots132	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots131	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots130	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots129	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots128	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots127	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots126	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots125	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots124	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots123	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots122	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots121	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots120	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots119	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots118	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots117	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots116	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots115	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots114	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots113	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots112	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots111	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots110	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots109	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots108	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots107	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots106	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots105	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots104	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots103	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots102	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots101	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots100	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots99	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots98	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots97	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots96	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots95	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots94	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots93	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots92	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots91	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots90	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots89	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots88	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots87	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots86	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots85	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots84	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots83	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots82	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots81	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots80	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots79	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots78	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots77	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots76	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots75	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots74	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots73	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots72	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots71	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots70	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots69	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots68	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots67	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots66	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots65	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots64	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots63	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots62	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots61	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots60	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots59	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots58	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots57	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots56	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots55	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots54	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots53	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots52	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots51	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots50	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots49	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots48	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots47	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots46	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots45	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots44	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots43	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots42	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots41	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots40	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots39	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots38	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots37	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots36	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots35	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots34	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots33	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots32	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots31	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots30	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots29	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots28	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots27	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots26	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots25	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots24	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots23	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots22	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots21	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots20	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots19	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots18	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots17	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots16	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots15	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots14	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots13	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots12	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots11	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots10	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots9	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots8	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots7	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots6	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots5	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots4	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots3	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots2	add.w	(a1)+,a3
	eor.b	d6,(a3)
dots1	add.w	(a1)+,a3	; get next bitplane offset (i.e. offset to required line)
	eor.b	d6,(a3)		; plot pixel
dots0	bra	next_x


fill_plane1
	move.l	plane1to4_fill_source1(pc),a0
	lea	(SOURCE_HEIGHT*BYTES_PER_LINE)-2(a0),a0
	move.l	screen1,a1
; point to last word of bitplane 1's target area
	add.l	#(((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)+SOURCE_HEIGHT)*BYTES_PER_LINE-2,a1
	bra.s	fill_plane

fill_plane2
	move.l	plane1to4_fill_source1(pc),a0
	lea	(2*SOURCE_HEIGHT*BYTES_PER_LINE)-2(a0),a0
	move.l	screen1,a1
; point to last word of bitplane 2's target area
	add.l	#(((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)+SOURCE_HEIGHT+SCREEN_HEIGHT)*BYTES_PER_LINE-2,a1
	bra.s	fill_plane

fill_plane3
	move.l	plane1to4_fill_source1(pc),a0
	lea	(3*SOURCE_HEIGHT*BYTES_PER_LINE)-2(a0),a0
	move.l	screen1,a1
; point to last word of bitplane 3's target area
	add.l	#(((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)+SOURCE_HEIGHT+(2*SCREEN_HEIGHT))*BYTES_PER_LINE-2,a1
	bra.s	fill_plane

fill_plane4
	move.l	plane1to4_fill_source1(pc),a0
	lea	(4*SOURCE_HEIGHT*BYTES_PER_LINE)-2(a0),a0
	move.l	screen1,a1
; point to last word of bitplane 4's target area
	add.l	#(((SCREEN_HEIGHT-SOURCE_HEIGHT)/2)+SOURCE_HEIGHT+(3*SCREEN_HEIGHT))*BYTES_PER_LINE-2,a1

fill_plane
	clr.w	d0
	move.w	#SOURCE_HEIGHT*64+WORDS_PER_LINE,d2
	bsr	blit_wait
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d0,$dff000+bltamod
	move.w	d0,$dff000+bltdmod
	move.l	a0,$dff000+bltapth
	move.l	a1,$dff000+bltdpth
	move.w	#$9f0,$dff000+bltcon0
	move.w	#$12,$dff000+bltcon1
	move.w	d2,$dff000+bltsize
	rts


blit_wait
	btst	#6,$dff000+dmaconr
	bne.s	blit_wait
	rts


clear	btst	#6,$dff000+dmaconr
	bne.s	clear

	move.w	d0,$dff000+bltdmod
	move.l	a0,$dff000+bltdpth
	move.w	#$100,$dff000+bltcon0
	move.w	#0,$dff000+bltcon1
	move.w	d1,$dff000+bltsize
	rts


zoom_value
	dc.w	0
	ENDC


;"""""""""""""""""""""""""""""""""""""""
;" PRINT PLAYER POSITION AND DIRECTION "
;"				       "
;"""""""""""""""""""""""""""""""""""""""

	IFD	NOT_USED
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
	ENDC


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

	IFD	NOT_USED
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
	ENDC

;sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$0400000

;vblank.occured	dc.b	0,0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




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




	IFD	TEST_TRODDLERS_METHOD
pixel_plot_lookup	; 352 values
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	ENDC


;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""
	section	copper,code_c

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




	IFD	TEST_TRODDLERS_METHOD
	section	chip_data,bss_c

plane1to4_fill_source1_mem
	ds.w	BITMAP_DEPTH*SOURCE_HEIGHT*WORDS_PER_LINE
plane1to4_fill_source2_mem
	ds.w	BITMAP_DEPTH*SOURCE_HEIGHT*WORDS_PER_LINE




	section	data,bss

; graphic definition (all bitplanes)
; this is lists of x start/end pairs which represent horizontal spans to be filled
plane1to4_definition
	ds.w	1	; number of rows
	ds.w	BITMAP_DEPTH*(SOURCE_WIDTH+1)*SOURCE_HEIGHT	; worst case


; graphic definition in runtime format
plane1to4_data
	ds.w	BITMAP_DEPTH*(((1+2+SOURCE_HEIGHT)*(SOURCE_WIDTH+1))+1)	; worst case


division_lookup
	ds.w	201
	ENDC


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
color3	equ	$186
color4	equ	$188
color8	equ	$190
color16	equ	$1a0
