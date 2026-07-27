	section	3D_68000,code_c
	opt	o+,o3-
;;	opt	c+,a+

;TEST	equ	1

;; got to clear.chunky.screen

;; display is now sequential - line routine will not work
;; probably don't need chunky.screen.ptrs or chunky.y.offset.ptrs, as polygon is just drawn from top to bottom
;; may need to change y table values when not using chunky to planar
;; re-insert original save routine if need to view palette

*""""""""""""""""""""""
*" SCREEN DEFINITIONS "
*"		      "
*""""""""""""""""""""""

SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4
;;SCREEN_Y_OFFSET	equ	$48

;;PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH
CHUNKY_SCREEN_SIZE	equ	SCREEN_WIDTH*SCREEN_HEIGHT

;;PLANAR_MEMORY_SIZE	equ	PLANAR_SCREEN_SIZE*2
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
	jsr	-132(a6)		turn multitasking off

* Allocate chunky screen memory

	move.l	#CHUNKY_MEMORY_SIZE,d0
	moveq	#1,d1			public
	jsr	-198(a6)		AllocMem
	move.l	d0,chunky.memory
	beq	exit_now

* Allocate planar screen memory

	move.l	#3*4*40*200,d0
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
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_free_mem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

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


	bsr	make.copper.lists	initialise copper

	move.l	copper1(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#40,d2			width of one bitplane
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

	bsr	init.auto.move
	bsr	initialise.data
	st.b	frames.requested
	move.w	#100,test.count

loop	bsr	clear.chunky.screen

	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	bsr	calc.sin.cos.values

	lea	cube(pc),a0
	bsr	draw.3d.object
	IFND	TEST
	bsr	new.chunky.convert.long
	ENDC

	bsr	auto.move.object

	bsr	keyboard.requests

	bsr	update.screens
	IFD	TEST
	bsr	clear
	ENDC

	btst	#6,$bfe001
;	subq.w	#1,test.count
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""
	lea	$dff000,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	old.level2(pc),$68.w

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_free_mem
	move.l	#3*4*40*200,d0
	move.l	screen.memory(pc),a1
	jsr	-210(a6)		FreeMem

exit_free_chunky_mem
	move.l	#CHUNKY_MEMORY_SIZE,d0
	move.l	chunky.memory(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

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

	move.b	raw.key.code(pc),d0

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

	lea	mouse.data(pc),a0

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

	tst.b	auto.move
;	bne.s	end.level3

;	bsr.s	set.x.y.z.angles

end.level3
	movem.l	(sp)+,d0-d1/a0
	rte




set.x.y.z.angles
	lea	mouse.data(pc),a0
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




MAX_Z	equ	$2000000
MIN_Z	equ	$800000
Z_STEP	equ	-$40000


init.auto.move
	st.b	auto.move
	move.w	#0,sequence.no

	move.l	#0,x.offset
	move.l	#0,y.offset
	move.l	#MAX_Z,z.offset
	move.l	#Z_STEP,zstep

	move.w	#0,base.x.angle
	move.w	#0,base.y.angle
	move.w	#0,base.z.angle
	move.w	#0,xastep
	move.w	#0,yastep
	move.w	#0,zastep
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
	cmp.w	#3,d0
	beq	auto4
	bra	auto.update
end.auto.move
	rts

* zoom in, no rotation
auto1	move.l	z.offset(pc),d1
	cmp.l	#MIN_Z,d1
	bgt	auto.update
	addq.w	#1,sequence.no
	move.l	#0,zstep
	move.w	#8,zastep
	bra	auto.update

* z rotate, no zoom
auto2	move.w	base.z.angle(pc),d1
	cmp.w	#$400,d1
	blt.s	auto.update
	addq.w	#1,sequence.no
	move.l	#-Z_STEP,zstep
	move.w	#12,zastep
	bra.s	auto.update

* continue z rotate and zoom out
auto3	move.l	z.offset(pc),d1
	cmp.l	#MAX_Z,d1
	blt.s	auto.update
	addq.w	#1,sequence.no
	move.l	#Z_STEP,zstep
	move.w	#9,xastep
	move.w	#18,yastep
	move.w	#15,zastep
	bra.s	auto.update

* zoom in and rotate about all three axes
auto4	move.l	z.offset(pc),d1
	cmp.l	#MIN_Z,d1
	bgt.s	auto.update
	addq.w	#1,sequence.no
	move.l	#0,zstep
	bra.s	auto.update

* finally, no zoom but continue rotation


sequence.no	dc.w	0

zstep	dc.l	0

xastep	dc.w	0
yastep	dc.w	0
zastep	dc.w	0


auto.update
	move.l	zstep(pc),d1
	add.l	d1,z.offset

auto.rotate.x.y.z.angles
	move.w	xastep(pc),d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.x.angle		update x angle
	and.w	#$7fe,base.x.angle

	move.w	yastep(pc),d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.y.angle		update y angle
	and.w	#$7fe,base.y.angle

	move.w	zastep(pc),d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.z.angle		update z angle
	and.w	#$7fe,base.z.angle
	rts




;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""

initialise.data
;;	bsr	calc.y.table
;;	bsr	calc.chunky.screen.ptrs
;;	bsr	calc.chunky.y.offsets
	bsr.s	planar.to.chunky
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
	move.l	screen1(pc),bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)
	rts




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
;	move.l	(a0)+,d0		.A.B.C.D	*
;	move.l	(a0)+,d1		.E.F.G.H
;	move.l	(a0)+,d2		.I.J.K.L	*
;	move.l	(a0)+,d3		.M.N.O.P
;	move.l	(a0)+,d4		.Q.R.S.T	*
;	move.l	(a0)+,d5		.U.V.W.X
;	move.l	(a0)+,d6		.Y.Z.a.b	*
;	move.l	(a0)+,d7		.c.d.e.f
	movem.l	(a0)+,d0-d6

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




rotate.coords
	lea	sin.cos.values(pc),a1
	lea	new.coords(pc),a2
	lea	transformed.coords(pc),a5
	move.w	(a0)+,d0
	add.w	d0,a2		point to correct coordinates
	add.w	d0,a5
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
	bmi.s	end.rotate		quit if z is negative

* addition - save transformed coords, for texture mapping
	move.l	d0,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a5)+	X

	move.l	d1,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a5)+	Y

	move.l	d2,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a5)+	Z
* end of addition

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

end.rotate
	rts



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




draw.3d.object
	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

sub.object
	pea	2(a0)
	add.w	(a0),a0
	bsr.s	draw.3d.object
	move.l	(sp)+,a0

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

end.draw.3d.object
	rts




;;set.fill.colour
;;	move.w	(a0)+,fill.colour+2	set colour for subsequent fills

;;	move.w	(a0)+,d0
;;	jmp	line(pc,d0.w)




set.line.colour
	lea	line.colour.masks(pc),a1
	add.w	(a0)+,a1		add offset for correct colour
	move.l	a1,dl.col+2		set colour for subsequent lines

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




draw.line				; draw line using blitter
	lea	$dff000,a6
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

dl.col	move.l	#line.colour.masks,a2
	moveq	#40,d5			width of one bitplane

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	d3,bltbmod(a6)		2 Sdelta
	sub.w	d2,d3			2 Sdelta - 2 Ldelta
	move.w	d3,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#4*40,d3		total width of bitplanes
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
return	rts




;""""""""""""""""""""""
;" THE CIRCLE ROUTINE "
;"		      "
;""""""""""""""""""""""

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

	bra	texture.fill




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
	bgt	texture.fill			if bottom is off screen

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

	bra.s	texture.fill




bottom.is.off.screen
	sub.w	d4,d7			end y - current y = count
	blt.s	texture.fill

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

	bra.s	texture.fill




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

;	bra.s	texture.fill




*""""""""""""""""""""
*" THE FILL ROUTINE "
*"		    "
*""""""""""""""""""""

LOG_TEXTURE_WIDTH	equ	6
LOG_TEXTURE_HEIGHT	equ	6

COEFF_SHIFT	equ	2

LINEAR_SIZE	equ	32
LOG_LINEAR_SIZE	equ	5

LOG_TX_PREC	equ	6		precision

* Log_Texture_Scale = (Log_Texture_Scale + LOG_TX_PRECISION)
LOG_TEXTURE_SCALE	equ	(6+LOG_TX_PREC)

LOG_FOCUS	equ	8	cannot be more than 8


LENGTH	equr	d7


* texture mapped fill

texture.fill
	st	(a1)			end-of-fill marker

* set texture vectors

	lea	transformed.coords(pc),a2
	movem.w	(a0)+,d0/d3/d6		get three offsets
	move.l	a0,-(sp)

	movem.w	(a2,d0.w),d0-d2		Ox, Oy, Oz
	move.w	d0,Ox
	move.w	d1,Oy
	move.w	d2,Oz

	movem.w	(a2,d3.w),d3-d5		Ux, Uy, Uz
	sub.w	d0,d3
	sub.w	d1,d4
	sub.w	d2,d5
	move.w	d3,Ux
	move.w	d4,Uy
	move.w	d5,Uz

	movem.w	(a2,d6.w),d3-d5		Vx, Vy, Vz
	sub.w	d0,d3
	sub.w	d1,d4
	sub.w	d2,d5
	move.w	d3,Vx
	move.w	d4,Vy
	move.w	d5,Vz

	move.l	chunky.memory(pc),a0
	lea	chunky.data(pc),a3
	lea	fill.coords(pc),a1
	move.w	(a1)+,d0		get y-start
	move.w	d0,Y

* point to start scan-line

;;	add.w	d0,d0			word offset
;;	lea	y.table(pc),a2
;;	add.w	(a2,d0.w),a0		add y offset
	mulu	#SCREEN_WIDTH,d0
	add.l	d0,a0

* remove origin translation
	sub.w	#SCREEN_HEIGHT/2,Y

* calculate co-efficients for texture mapping

	move.w	Vz,d6
	move.w	Oy,d7
	muls	d6,d7
	move.w	Vy,d5
	move.w	Oz,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,UI		ui = (Vz*Oy) - (Vy*Oz)

	move.w	Vx,d6
	move.w	Oz,d7
	muls	d6,d7
	move.w	Vz,d5
	move.w	Ox,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,UJ		uj = (Vx*Oz) - (Vz*Ox)

	move.w	Vy,d6
	move.w	Ox,d7
	muls	d6,d7
	move.w	Vx,d5
	move.w	Oy,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.l	d7,UC		uc = (Vy*Ox) - (Vx*Oy)

	move.w	Uy,d6
	move.w	Oz,d7
	muls	d6,d7
	move.w	Uz,d5
	move.w	Oy,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,VI		vi = (Uy*Oz) - (Uz*Oy)

	move.w	Uz,d6
	move.w	Ox,d7
	muls	d6,d7
	move.w	Ux,d5
	move.w	Oz,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,VJ		vj = (Uz*Ox) - (Ux*Oz)

	move.w	Ux,d6
	move.w	Oy,d7
	muls	d6,d7
	move.w	Uy,d5
	move.w	Ox,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.l	d7,VC		vc = (Ux*Oy) - (Uy*Ox)

	move.w	Vy,d6
	move.w	Uz,d7
	muls	d6,d7
	move.w	Vz,d5
	move.w	Uy,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,ZI		zi = (Vy*Uz) - (Vz*Uy)

	move.w	Vz,d6
	move.w	Ux,d7
	muls	d6,d7
	move.w	Vx,d5
	move.w	Uz,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.w	d7,ZJ		zj = (Vz*Ux) - (Vx*Uz)

	move.w	Vx,d6
	move.w	Uy,d7
	muls	d6,d7
	move.w	Vy,d5
	move.w	Ux,d6
	muls	d5,d6
	sub.l	d6,d7
	asr.l	#COEFF_SHIFT,d7
	move.l	d7,ZC		zc = (Vx*Uy) - (Vy*Ux)

	move.w	(a1)+,d0		first x-start
	bpl.s	fill.loop

	move.l	(sp)+,a0
	rts


* loop, drawing each scan-line

fill.loop
	move.w	(a1)+,d1		next x-end
	cmp.w	d0,d1
	blt	next.line		if x-end is less than x-start
* x-start and x-end are already limited to screen boundaries

	lea	(a0,d0.w),a2		start address of fill

* remove origin translation
	move.w	#SCREEN_WIDTH/2,d2
	sub.w	d2,d0
	move.w	d0,X0
	sub.w	d2,d1
	move.w	d1,X1

* calculate y and constant part of equations
* i.e. these values are constant for a whole scan-line
	move.w	Y(pc),d2
	move.w	d2,d3
	muls	UJ(pc),d2
	asr.l	#LOG_FOCUS,d2
	add.l	UC(pc),d2
	move.l	d2,ULINE	uline = ((y*uj)>>Log_Focus) + uc

	move.w	d3,d2
	muls	VJ(pc),d2
	asr.l	#LOG_FOCUS,d2
	add.l	VC(pc),d2
	move.l	d2,VLINE	vline = ((y*vj)>>Log_Focus) + vc

	muls	ZJ(pc),d3
	asr.l	#LOG_FOCUS,d3
	add.l	ZC(pc),d3
	move.l	d3,ZLINE	zline = ((y*zj)>>Log_Focus) + zc

initial
* calculate initial position within texture
*	if ((zpixel = zline + ((x0*zi)>>Log_Focus)) != 0)
*		{
*		txend = ((uline + ((x0*ui)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
*		tyend = ((vline + ((x0*vi)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
*		}
	move.w	X0(pc),d0
	move.w	d0,d1
	muls	ZI(pc),d0
	asr.l	#LOG_FOCUS,d0
	add.l	ZLINE(pc),d0
	move.w	d0,d2		zpixel
	beq.s	undefined.tx.ty.end1

	move.w	d1,d0
	muls	UI(pc),d0
	asr.l	#LOG_FOCUS,d0
	add.l	ULINE(pc),d0
	asr.l	#(16-LOG_TEXTURE_SCALE),d0
	swap	d0		gives left shift of LOG_TEXTURE_SCALE
	clr.w	d0
	divs	d2,d0		txend
* limit txend to texture size
	bpl.s	txend.plus1
	moveq	#0,d0
	bra.s	txend.ok1
txend.plus1
	cmp.w	txmax(pc),d0
	ble.s	txend.ok1
	move.w	txmax(pc),d0
txend.ok1

	muls	VI(pc),d1
	asr.l	#LOG_FOCUS,d1
	add.l	VLINE(pc),d1
	asr.l	#(16-LOG_TEXTURE_SCALE),d1
	swap	d1		gives left shift of LOG_TEXTURE_SCALE
	clr.w	d1
	divs	d2,d1		tyend
* limit tyend to texture size
	bpl.s	tyend.plus1
	moveq	#0,d1
*	bra.s	tyend.ok1
	bra.s	do.scan.line
tyend.plus1
	cmp.w	tymax(pc),d1
	ble.s	do.scan.line
*	ble.s	tyend.ok1
	move.w	tymax(pc),d1
tyend.ok1
	bra.s	do.scan.line

undefined.tx.ty.end1
	moveq	#0,d0
	moveq	#0,d1

* d0 = txend, d1 = tyend
* loop, drawing each pixel on current scan-line
do.scan.line
	move.w	d0,d4	txstart = txend
	move.w	d1,d5	tystart = tyend

* d4 = txstart, d5 = tystart
	moveq	#LINEAR_SIZE,LENGTH
	add.w	LENGTH,X0
	move.w	X0(pc),d1
	cmp.w	X1(pc),d1
	blt.s	length.set
	sub.w	d1,LENGTH
	add.w	X1(pc),LENGTH
	addq.w	#1,LENGTH
	move.w	X1(pc),d1

* d1 = X0
length.set
* calculate next position within texture
*	if ((zpixel = zline + ((x0*zi)>>Log_Focus)) != 0)
*		{
*		txend = ((uline + ((x0*ui)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
*		tyend = ((vline + ((x0*vi)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
*		}
;	move.w	X0(pc),d1
	move.w	d1,d0
	muls	ZI(pc),d0
	asr.l	#LOG_FOCUS,d0
	add.l	ZLINE(pc),d0
	move.w	d0,d2		zpixel
	beq.s	undefined.tx.ty.end2

	move.w	d1,d0
	muls	UI(pc),d0
	asr.l	#LOG_FOCUS,d0
	add.l	ULINE(pc),d0
	asr.l	#(16-LOG_TEXTURE_SCALE),d0
	swap	d0		gives left shift of LOG_TEXTURE_SCALE
	clr.w	d0
	divs	d2,d0		txend
* limit txend to texture size
	bpl.s	txend.plus2
	moveq	#0,d0
	bra.s	txend.ok2
txend.plus2
	cmp.w	txmax(pc),d0
	ble.s	txend.ok2
	move.w	txmax(pc),d0
txend.ok2

	muls	VI(pc),d1
	asr.l	#LOG_FOCUS,d1
	add.l	VLINE(pc),d1
	asr.l	#(16-LOG_TEXTURE_SCALE),d1
	swap	d1		gives left shift of LOG_TEXTURE_SCALE
	clr.w	d1
	divs	d2,d1		tyend
* limit tyend to texture size
	bpl.s	tyend.plus2
	moveq	#0,d1
*	bra.s	tyend.ok2
	bra.s	calc.increments
tyend.plus2
	cmp.w	tymax(pc),d1
	ble.s	calc.increments
*	ble.s	tyend.ok2
	move.w	tymax(pc),d1
tyend.ok2
	bra.s	calc.increments

undefined.tx.ty.end2
	moveq	#0,d0
	moveq	#0,d1

* d4 = txstart, d5 = tystart
* d0 = txend, d1 = tyend
* d7 = length (always greater than zero)
calc.increments
* calculate texture position increments
*	if (length != 0)
*		{
*		txinc = (txend - txstart) / length;
*		tyinc = (tyend - tystart) / length;
*		}
	move.w	d0,d2
	sub.w	d4,d2		txend - txstart
	move.w	d1,d3
	sub.w	d5,d3		tyend - tystart

	cmp.w	#LINEAR_SIZE,LENGTH
	beq.s	standard.length
	ext.l	d2
	ext.l	d3
	divs	LENGTH,d2
	divs	LENGTH,d3
	bra.s	start.linear.run

standard.length
	asr.w	#LOG_LINEAR_SIZE,d2	txinc
	asr.w	#LOG_LINEAR_SIZE,d3	tyinc

* d2 = txinc, d3 = tyinc
* d4 = txstart, d5 = tystart
* do a linear run of pixels
* save d1, giving d1 and d6 free
start.linear.run
	move.w	d1,a6
	subq.w	#1,LENGTH
do.linear.run
	move.w	d5,d1
*zero	lsr.w	#LOG_TX_PREC-LOG_TEXTURE_WIDTH,d1
	and.w	#%111111000000,d1
	move.w	d4,d6
	lsr.w	#LOG_TX_PREC,d6
	add.w	d6,d1
	move.b	(a3,d1.w),(a2)+
	add.w	d2,d4
	add.w	d3,d5
	dbra	LENGTH,do.linear.run

	move.w	a6,d1		restore tyend

	move.w	X0(pc),d6
	cmp.w	X1(pc),d6
	blt	do.scan.line

next.line
	addq.w	#1,Y
	lea	SCREEN_WIDTH(a0),a0	next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.loop
	move.l	(sp)+,a0
	rts


Ox	dc.w	0	origin vector (absolute)
Oy	dc.w	0
Oz	dc.w	0
Ux	dc.w	0	u vector (i.e. x) (relative to origin)
Uy	dc.w	0
Uz	dc.w	0
Vx	dc.w	0	v vector (i.e. y) (relative to origin)
Vy	dc.w	0
Vz	dc.w	0

Y	dc.w	0
X0	dc.w	0
X1	dc.w	0

UI	dc.w	0
UJ	dc.w	0
UC	dc.l	0

VI	dc.w	0
VJ	dc.w	0
VC	dc.l	0

ZI	dc.w	0
ZJ	dc.w	0
ZC	dc.l	0

ULINE	dc.l	0
VLINE	dc.l	0
ZLINE	dc.l	0	could possibly use a word for this one

* ZPIXEL - register

txstart	dc.w	0	or long with fastest method
tystart	dc.w	0
txend	dc.w	0	or maybe long with fastest method
tyend	dc.w	0
txinc	dc.w	0	or long with fastest method
tyinc	dc.w	0

* texture limits
txmax	dc.w	(1<<(LOG_TEXTURE_WIDTH+LOG_TX_PREC))-1
tymax	dc.w	(1<<(LOG_TEXTURE_HEIGHT+LOG_TX_PREC))-1



fill	rts



y.table	ds.w	SCREEN_HEIGHT



fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker



poly.coords	ds.w	64		space for 16 sided polygon




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
	bsr.s	fill.box

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

	lea	fill.coords(pc),a1
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
	moveq	#16,d0			x
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

base.x.angle	dc.w	0
base.y.angle	dc.w	0
base.z.angle	dc.w	0

sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$0400000

new.coords	ds.w	100*3		space for 100 coordinates
transformed.coords	ds.w	100*3		space for 100 coordinates



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even



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

chunky.data	ds.b	SOURCE_WIDTH*SOURCE_HEIGHT
* blank line after
		ds.b	SOURCE_WIDTH


bitmap	;incbin	brush/beach.bin
;	incbin	brush/blocks1.bin
;	incbin	brush/blocks2.bin
;	incbin	brush/ed209.bin
;	incbin	brush/eddie.bin
;	incbin	brush/gods1.bin
;	incbin	brush/gods2.bin
;	incbin	brush/gods3.bin
;	incbin	brush/gods4.bin
;	incbin	brush/paint.bin
	incbin	brush/speed1.bin
;	incbin	brush/speed2.bin
;	incbin	brush/speed3.bin
;	incbin	brush/speed4.bin
;	incbin	brush/speed5.bin
;	incbin	brush/speed6.bin
;	incbin	brush/speed7.bin
;	incbin	brush/speed8.bin
;	incbin	brush/speed9.bin
;	incbin	brush/speed10.bin


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



;;colour.table
;;	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
;;	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab



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



rotate.coords.offset	equ	rotate.coords-line

polygon.orientation.offset	equ	polygon.orientation-line

sub.object.offset	equ	sub.object-line

end.offset	equ	end.draw.3d.object-line

;;set.fill.colour.offset	equ	set.fill.colour-line

set.line.colour.offset	equ	set.line.colour-line

line.offset	equ	0

circle.offset	equ	circle-line

component.priority.offset	equ	component.priority-line



cube	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	8-1

;	dc.w	-300,300,300
;	dc.w	-300,300,-300
;	dc.w	300,300,-300
;	dc.w	300,300,300
;	dc.w	-300,-300,300
;	dc.w	-300,-300,-300
;	dc.w	300,-300,-300
;	dc.w	300,-300,300

	dc.w	-50,50,50
	dc.w	-50,50,-50
	dc.w	50,50,-50
	dc.w	50,50,50
	dc.w	-50,-50,50
	dc.w	-50,-50,-50
	dc.w	50,-50,-50
	dc.w	50,-50,50

;;	dc.w	set.fill.colour.offset
;;	dc.w	blue1

	dc.w	polygon.orientation.offset
	dc.w	P1,P2,P3
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P1,P2,P3,P4
	dc.w	P2,P3,P1

;;	dc.w	set.fill.colour.offset
;;	dc.w	green3

	dc.w	polygon.orientation.offset
	dc.w	P8,P7,P6
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P8,P7,P6,P5
	dc.w	P7,P6,P8

;;	dc.w	set.fill.colour.offset
;;	dc.w	red1

	dc.w	polygon.orientation.offset
	dc.w	P3,P7,P8
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P3,P7,P8,P4
	dc.w	P7,P8,P3

;;	dc.w	set.fill.colour.offset
;;	dc.w	blue2

	dc.w	polygon.orientation.offset
	dc.w	P1,P4,P8
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P1,P4,P8,P5
	dc.w	P4,P8,P1

;;	dc.w	set.fill.colour.offset
;;	dc.w	green2

	dc.w	polygon.orientation.offset
	dc.w	P2,P1,P5
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P2,P1,P5,P6
	dc.w	P1,P5,P2

;;	dc.w	set.fill.colour.offset
;;	dc.w	red2

	dc.w	polygon.orientation.offset
	dc.w	P2,P6,P7
	dc.w	2+4*2+3*2
	dc.w	4
	dc.w	P2,P6,P7,P3
	dc.w	P6,P7,P2

	dc.w	end.offset
