	section	TxWalls,code_c
	opt	c+


;USE_ROTATE_METHOD	equ	1
USE_OUTPUT_METHOD2	equ	1

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

CHUNKY_SCREEN_WIDTH	equ	SCREEN_WIDTH/2

PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH
CHUNKY_SCREEN_SIZE	equ	CHUNKY_SCREEN_WIDTH*SCREEN_HEIGHT

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
;	move.l	d0,a6
;	IFND	DEBUG
;	jsr	-456(a6)		OwnBlitter
;	ENDC




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	IFND	DEBUG
	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.b	#%00010111,$bfed01	set CIA-A ICR

;	move.l	$68.w,old.level2
;	move.l	#new.level2,$68.w

;	move.l	$6c.w,old.level3
;	move.l	#new.level3,$6c.w

;	move.w	#$c018,intena(a6)	enable copper and level2 interrupts


;	move.l	$14.w,old.dbz		division-by-zero exception handler
;	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

;vp.wait	move.l	vposr(a6),d0		get vertical beam position
;	and.l	#$1ff00,d0
;	lsr.l	#8,d0
;	cmp.w	#312,d0			wait for bottom line
;	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


;;	lea	colour.table(pc),a0	initialise colours
;	move.l	#bitmap+BITMAP_SIZE,a0
;	lea	color0(a6),a1
;	moveq	#(1<<(SCREEN_DEPTH-1))-1,d0
;
;set.colours
;	move.l	(a0)+,(a1)+
;	dbra	d0,set.colours


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

	bsr	clear.chunky.screen
;	st.b	frames.requested

	move.w	#100,test.count
test.loop
	bsr	c2p.double
;	bsr	c2p.double.st
;	bsr	c2p.alive
	subq.w	#1,test.count
	bne.s	test.loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""
	IFND	DEBUG
	lea	$dff000,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.b	#%10011010,$bfed01	restore CIA-A ICR

;	move.l	old.level2,$68.w

;	move.l	old.level3,$6c.w

	move.w	old.ints,d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


;	move.l	old.dbz,$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase,a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on
	ENDC

	move.l	a0,a6
;	IFND	DEBUG
;	jsr	-462(a6)		DisownBlitter
;	ENDC

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
	move.w	#19-1,d7
.loop
	REPT	30
	movem.l	d0-d6/a0-a6,-(a7)
	ENDR
	dbra	d7,.loop

	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d5,-(a7)

	move.l	saved.a7(pc),a7
	rts


	cnop	0,4

old.clear.chunky.screen
	move.l	chunky.memory(pc),a2
	move.w	#SCREEN_HEIGHT-1,d2
	moveq	#0,d3
.loop
	REPT	CHUNKY_SCREEN_WIDTH/4
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


*""""""""""""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER		"
*" (4 bitplane double-pixel version)	"
*"					"
*""""""""""""""""""""""""""""""""""""""""

* For logical shift method:-
*	68000 CPU cycles required: 100 + 450 per loop (outputting 32 pixels) + 16
*	= (100 + ((320*200)/32 * 450) + 16) = 900116 cycles for 320*200 display
*	approx. 14 CPU cycles per output pixel
*
* Result for test.count 500: 64 seconds

* For rotate method:-
*	68000 CPU cycles required: 100 + 432 per loop (outputting 32 pixels) + 16
*	= (100 + ((320*200)/32 * 432) + 16) = 864116 cycles for 320*200 display
*	approx. 13.5 CPU cycles per output pixel
*
* Result for test.count 500: 62 seconds

	cnop	0,4

c2p.double
	move.l	chunky.memory(pc),a0			16
	move.l	screen1(pc),a4				16
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a4),a3	8
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a3),a2	8
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a2),a1	8
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7	8

	move.l	#$00ff00ff,d4				12
	move.l	#$33333333,d5				12
	move.l	#$55555555,d6				12

;	nop		longword align to improve performance on 68020+

* read 16 chunky pixels per loop to give 32 output pixels
.next.32.pixels
	move.w	(a0)+,d0	.A.B		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	ACBD		8
	swap	d0				4

	move.w	(a0)+,d2	.E.F		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	EGFH		8
	swap	d2				4

	move.w	(a0)+,d0	.I.J		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	IKJL		8

	move.w	(a0)+,d2	.M.N		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	MONP		8 = total 128 cycles

* d0 = ACBDIKJL
* d2 = EGFHMONP

	IFND	USE_ROTATE_METHOD
* Use logical shift method

* 8-bit transpose ACBDIKJL and EGFHMONP
	move.l	d2,d1					4
	lsr.l	#8,d1	..EGFHMO			24
	eor.l	d0,d1					8
	and.l	d4,d1	(d1 ^ d0) & $00ff00ff = mask	8
	eor.l	d1,d0	ACEGIKMO			8
	lsl.l	#8,d1	mask << 8			24
	eor.l	d1,d2	BDFHJLNP			8 = total 84 cycles

* 2-bit transpose ACEGIKMO and BDFHJLNP
*			d0 = A3A2A1A0C3C2C1C0E3E2E1E0G3G2G1G0I3I2I1I0K3K2K1K0M3M2M1M0O3O2O1O0
*			d2 = B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2P1P0
	move.l	d2,d1										4
	lsr.l	#2,d1	....B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2	12
	eor.l	d0,d1										8
	and.l	d5,d1	(d1 ^ d0) & $33333333 = mask						8
	eor.l	d1,d0	A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2	8
	lsl.l	#2,d1	mask << 2								12
	eor.l	d1,d2	A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0	8 = total 60 cycles

* 1-bit transpose and output bits 0 and 1
*			d2 = A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0
	move.l	d2,d3										4
	move.l	d2,d1										4
	lsr.l	#1,d1	..A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1	10
	eor.l	d2,d1										8
	and.l	d6,d1	(d1 ^ d2) & $55555555 = mask						8
	eor.l	d1,d2	A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	8
	move.l	d2,(a3)+		plane 1							12
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	8
	move.l	d3,(a4)+		plane 0							12 = total 82 cycles

* 1-bit transpose and output bits 2 and 3
*			d0 = A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2
	move.l	d0,d3
	move.l	d0,d1
	lsr.l	#1,d1	..A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3
	eor.l	d0,d1
	and.l	d6,d1	(d1 ^ d0) & $55555555 = mask
	eor.l	d1,d0	A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	move.l	d0,(a1)+		plane 3
	add.l	d1,d1	mask << 1
	eor.l	d1,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	move.l	d3,(a2)+		plane 2							total 82 cycles

	ELSE
* Use rotate method

* 8-bit transpose ACBDIKJL and EGFHMONP
	move.l	d0,d1					4
	ror.l	#8,d2	NPEGFHMO			24
	eor.l	d2,d1					8
	and.l	d4,d1	(d1 ^ d2) & $00ff00ff = mask	8
	eor.l	d1,d0	ACEGIKMO			8
	eor.l	d1,d2	NPBDFHJL			8 = total 60 cycles

* 2-bit transpose ACEGIKMO and NPBDFHJL
*			d0 = A3A2A1A0C3C2C1C0E3E2E1E0G3G2G1G0I3I2I1I0K3K2K1K0M3M2M1M0O3O2O1O0
*			d2 = N3N2N1N0P3P2P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0
	move.l	d0,d1										4
	rol.l	#6,d2	P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2	20
	eor.l	d2,d1										8
	and.l	d5,d1	(d1 ^ d2) & $33333333 = mask						8
	eor.l	d1,d0	A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2	8
	eor.l	d1,d2	P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0	8 = total 56 cycles

* 1-bit transpose and output bits 0 and 1
*			d2 = P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0
	rol.l	#1,d2										10
	move.l	d2,d1	P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1	4
	rol.l	#1,d2	A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0	10
	move.l	d2,d3										4
	eor.l	d2,d1										8
	and.l	d6,d1	(d1 ^ d2) & $55555555 = mask						8
	eor.l	d1,d2	A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	8
	move.l	d2,(a3)+		plane 1							12
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	8
	move.l	d3,(a4)+		plane 0							12 = total 92 cycles

* 1-bit transpose and output bits 2 and 3
*			d0 = A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2
	move.l	d0,d3
	move.l	d0,d1
	ror.l	#1,d1	P2A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3
	eor.l	d0,d1
	and.l	d6,d1	(d1 ^ d0) & $55555555 = mask
	eor.l	d1,d0	A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	move.l	d0,(a1)+		plane 3
	add.l	d1,d1	mask << 1
	eor.l	d1,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	move.l	d3,(a2)+		plane 2							total 82 cycles
	ENDC

* TO DO: Try to further separate the plane 1/0 and plane 3/2 memory writes above, to improve performance on 68020+
* (e.g. by using registers which are spare after plane 1 and 0 are written)

	dbra	d7,.next.32.pixels	14 (when branch taken)
	rts				16


saved.a7	dc.l	0


*"""""""""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER	     "
*" (4 bitplane double-pixel version) "
*" ATARI ST VERSION		     "
*"				     "
*"""""""""""""""""""""""""""""""""""""

* For logical shift method (with USE_OUTPUT_METHOD2):-
*	68000 CPU cycles required: 76 + 490 per loop (outputting 32 pixels) + 16
*	= (76 + ((320*200)/32 * 490) + 16) = 980092 cycles for 320*200 display
*	approx. 15 CPU cycles per output pixel
*
* Result for test.count 500: 71 seconds (without USE_OUTPUT_METHOD2)
* Result for test.count 500: 70 seconds (with USE_OUTPUT_METHOD2)

* For rotate method (with USE_OUTPUT_METHOD2):-
*	68000 CPU cycles required: 76 + 472 per loop (outputting 32 pixels) + 16
*	= (76 + ((320*200)/32 * 472) + 16) = 944092 cycles for 320*200 display
*	approx. 15 CPU cycles per output pixel
*
* Result for test.count 500: 69 seconds (without USE_OUTPUT_METHOD2)
* Result for test.count 500: 68 seconds (with USE_OUTPUT_METHOD2)

	cnop	0,4

c2p.double.st
	move.l	chunky.memory(pc),a0			16
	move.l	screen1(pc),a1				16
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7	8

	move.l	#$00ff00ff,d4				12
	move.l	#$33333333,d5				12
	move.l	#$55555555,d6				12

;	nop		longword align to improve performance on 68020+

* read 16 chunky pixels per loop to give 32 output pixels
.next.32.pixels
	move.w	(a0)+,d0	.A.B		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	ACBD		8
	swap	d0				4

	move.w	(a0)+,d2	.E.F		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	EGFH		8
	swap	d2				4

	move.w	(a0)+,d0	.I.J		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	IKJL		8

	move.w	(a0)+,d2	.M.N		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	MONP		8 = total 128 cycles

* d0 = ACBDIKJL
* d2 = EGFHMONP

	IFND	USE_ROTATE_METHOD
* Use logical shift method

* 8-bit transpose ACBDIKJL and EGFHMONP
	move.l	d2,d1					4
	lsr.l	#8,d1	..EGFHMO			24
	eor.l	d0,d1					8
	and.l	d4,d1	(d1 ^ d0) & $00ff00ff = mask	8
	eor.l	d1,d0	ACEGIKMO			8
	lsl.l	#8,d1	mask << 8			24
	eor.l	d1,d2	BDFHJLNP			8 = total 84 cycles

* 2-bit transpose ACEGIKMO and BDFHJLNP
*			d0 = A3A2A1A0C3C2C1C0E3E2E1E0G3G2G1G0I3I2I1I0K3K2K1K0M3M2M1M0O3O2O1O0
*			d2 = B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2P1P0
	move.l	d2,d1										4
	lsr.l	#2,d1	....B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2	12
	eor.l	d0,d1										8
	and.l	d5,d1	(d1 ^ d0) & $33333333 = mask						8
	eor.l	d1,d0	A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2	8
	lsl.l	#2,d1	mask << 2								12
	eor.l	d1,d2	A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0	8 = total 60 cycles

* 1-bit transpose bits 0 and 1
*			d2 = A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0
	move.l	d2,d3										4
	move.l	d2,d1										4
	lsr.l	#1,d1	..A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1	10
	eor.l	d2,d1										8
	and.l	d6,d1	(d1 ^ d2) & $55555555 = mask						8
	eor.l	d1,d2	A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	8
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	8 = total 58 cycles

	IFND	USE_OUTPUT_METHOD2
* output bits 0 and 1
	lea	8(a1),a2									8
	move.w	d3,(a2)+		plane 0							8
	swap	d3										4
	move.w	d3,(a1)+		plane 0							8
	move.w	d2,(a2)+		plane 1							8
	swap	d2										4
	move.w	d2,(a1)+		plane 1							8 = total 48 cycles
	ELSE
* 16-bit transpose bits 0 and 1
	swap	d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1	4
	move.w	d3,d1					I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	4
	move.w	d2,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1	4
	move.w	d1,d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	4
	swap	d2	I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	4
	move.l	d3,(a1)+		plane 0 and 1 first word				12 = total 32 cycles
	ENDC

* 1-bit transpose bits 2 and 3
*			d0 = A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2
	move.l	d0,d3
	move.l	d0,d1
	lsr.l	#1,d1	..A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3
	eor.l	d0,d1
	and.l	d6,d1	(d1 ^ d0) & $55555555 = mask
	eor.l	d1,d0	A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	add.l	d1,d1	mask << 1
	eor.l	d1,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2	total 58 cycles

	IFND	USE_OUTPUT_METHOD2
* output bits 2 and 3
	move.w	d3,(a2)+		plane 2
	swap	d3
	move.w	d3,(a1)+		plane 2
	move.w	d0,(a2)+		plane 3
	swap	d0
	move.w	d0,(a1)+		plane 3
	lea	8(a1),a1									total 48 cycles
	ELSE
* 16-bit transpose bits 2 and 3
	swap	d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d3,d1					I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	move.w	d0,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d1,d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	swap	d0	I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	move.l	d3,(a1)+		plane 2 and 3 first word				total 32 cycles

	move.l	d2,(a1)+		plane 0 and 1 second word				12
	move.l	d0,(a1)+		plane 2 and 3 second word				12 = total 24 cycles
	ENDC

	ELSE
* Use rotate method

* 8-bit transpose ACBDIKJL and EGFHMONP
	move.l	d0,d1					4
	ror.l	#8,d2	NPEGFHMO			24
	eor.l	d2,d1					8
	and.l	d4,d1	(d1 ^ d2) & $00ff00ff = mask	8
	eor.l	d1,d0	ACEGIKMO			8
	eor.l	d1,d2	NPBDFHJL			8 = total 60 cycles

* 2-bit transpose ACEGIKMO and NPBDFHJL
*			d0 = A3A2A1A0C3C2C1C0E3E2E1E0G3G2G1G0I3I2I1I0K3K2K1K0M3M2M1M0O3O2O1O0
*			d2 = N3N2N1N0P3P2P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0
	move.l	d0,d1										4
	rol.l	#6,d2	P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2	20
	eor.l	d2,d1										8
	and.l	d5,d1	(d1 ^ d2) & $33333333 = mask						8
	eor.l	d1,d0	A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2	8
	eor.l	d1,d2	P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0	8 = total 56 cycles

* 1-bit transpose bits 0 and 1
*			d2 = P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0
	rol.l	#1,d2										10
	move.l	d2,d1	P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1	4
	rol.l	#1,d2	A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0	10
	move.l	d2,d3										4
	eor.l	d2,d1										8
	and.l	d6,d1	(d1 ^ d2) & $55555555 = mask						8
	eor.l	d1,d2	A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	8
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	8 = total 68 cycles

	IFND	USE_OUTPUT_METHOD2
* output bits 0 and 1
	lea	8(a1),a2									8
	move.w	d3,(a2)+		plane 0							8
	swap	d3										4
	move.w	d3,(a1)+		plane 0							8
	move.w	d2,(a2)+		plane 1							8
	swap	d2										4
	move.w	d2,(a1)+		plane 1							8 = total 48 cycles
	ELSE
* 16-bit transpose bits 0 and 1
	swap	d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1
	move.w	d3,d1					I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0
	move.w	d2,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1
	move.w	d1,d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0
	swap	d2	I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1
	move.l	d3,(a1)+		plane 0 and 1 first word				total 32 cycles
	ENDC

* 1-bit transpose bits 2 and 3
*			d0 = A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2
	move.l	d0,d3										4
	move.l	d0,d1										4
	ror.l	#1,d1	P2A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3	10
	eor.l	d0,d1										8
	and.l	d6,d1	(d1 ^ d0) & $55555555 = mask						8
	eor.l	d1,d0	A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3	8
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2	8 = total 58 cycles

	IFND	USE_OUTPUT_METHOD2
* output bits 2 and 3
	move.w	d3,(a2)+		plane 2
	swap	d3
	move.w	d3,(a1)+		plane 2
	move.w	d0,(a2)+		plane 3
	swap	d0
	move.w	d0,(a1)+		plane 3
	lea	8(a1),a1									total 48 cycles
	ELSE
* 16-bit transpose bits 2 and 3
	swap	d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d3,d1					I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	move.w	d0,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d1,d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	swap	d0	I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	move.l	d3,(a1)+		plane 2 and 3 first word				total 32 cycles

	move.l	d2,(a1)+		plane 0 and 1 second word
	move.l	d0,(a1)+		plane 2 and 3 second word				total 24 cycles
	ENDC

	ENDC

	dbra	d7,.next.32.pixels	14 (when branch taken)
	rts				16


*""""""""""""""""""""""""""""""""""""""""""""""""
*" Chunky to planar double-to-double pixel	"
*" by The Paranoid 2012				"
*" (For ATARI ST)				"
*" (New version in reply to my email)		"
*"						"
*""""""""""""""""""""""""""""""""""""""""""""""""

c2pdp
;    lea source_buffer,A0
;    lea target_buffer,A6
	move.l	chunky.memory(pc),a0
	move.l	screen1(pc),a6

    lea        cd2dp_01,A3
    lea        cd2dp_23,A4
;    move.w     #scr_h-1,D6
    move.w  #(SCREEN_HEIGHT*CHUNKY_SCREEN_WIDTH)/32-1,D7

xy_loop:
    movem.w       (A0)+,D0-D5/A1-A2    ;  44 cycles
    move.l   0(A3,D0.w),D0             ;  18 cycles
    or.l     0(A4,D1.w),D0             ;  20 cycles
    movep.l          D0,0(A6)      ;  24 cycles
    move.l   0(A3,D2.w),D0             ;  18 cycles
    or.l     0(A4,D3.w),D0             ;  20 cycles
    movep.l          D0,1(A6)      ;  24 cycles
    move.l   0(A3,D4.w),D0             ;  18 cycles
    or.l     0(A4,D5.w),D0             ;  20 cycles
    movep.l          D0,8(A6)      ;  24 cycles
    move.l   0(A3,A1.w),D0             ;  18 cycles
    or.l     0(A4,A2.w),D0             ;  20 cycles
    movep.l          D0,9(A6)      ;  24 cycles = 292 cycles

    movem.w       (A0)+,D0-D5/A1-A2    ;  44 cycles
    move.l   0(A3,D0.w),D0             ;  18 cycles
    or.l     0(A4,D1.w),D0             ;  20 cycles
    movep.l          D0,16(A6)     ;  24 cycles
    move.l   0(A3,D2.w),D0             ;  18 cycles
    or.l     0(A4,D3.w),D0             ;  20 cycles
    movep.l          D0,17(A6)     ;  24 cycles
    move.l   0(A3,D4.w),D0             ;  18 cycles
    or.l     0(A4,D5.w),D0             ;  20 cycles
    movep.l          D0,24(A6)     ;  24 cycles
    move.l   0(A3,A1.w),D0             ;  18 cycles
    or.l     0(A4,A2.w),D0             ;  20 cycles
    movep.l          D0,25(A6)     ;  24 cycles = 584 cycles
    lea          32(A6),A6             ;   8 cycles
    dbra             D7,xy_loop        ;  14 cycles = 606 cycles for 64 planar pixels
    rts


*""""""""""""""""""""""""""""""""""""""""""""""""
*" Comparison routine from Tutorial:		"
*"  "Chunky-to-Planar for Dummies"		"
*"  (http://alive.atari.org/alive8/c2p.php)	"
*" (For ATARI ST)				"
*"						"
*""""""""""""""""""""""""""""""""""""""""""""""""

* Note that the chunky pixels in the source picture MUST be multiplied by 4, to prevent address errors
* on 68000 systems, because they are used to index into the longword c2p_pixeln tables below
*
* Result for test.count 500: 86 seconds

c2p.alive
	lea c2p_pixel0(pc),a0      ;c2p table for pixel 0 to a0		8
	lea c2p_pixel1(pc),a1      ;c2p table for pixel 1 to a1		8
	lea c2p_pixel2(pc),a2      ;c2p table for pixel 2 to a2		8
	lea c2p_pixel3(pc),a3      ;c2p table for pixel 3 to a3		8
	move.l	chunky.memory(pc),a4      ;the source picture	16
	move.l	screen1(pc),a5       ;the target		16

	moveq #0,d0            ;clear work register

	move.w #SCREEN_HEIGHT-1,d6    ;number of lines
.outloop
;.next.line
	move.w #CHUNKY_SCREEN_WIDTH/8-1,d7   ;number of 8 pixel blocks per line
.inloop
* read 8 chunky pixels per loop to give 16 output pixels
;.next.8.pixels
	move.b (a4)+,d0        ;fetch chunky pixel 0
	move.l 0(a0,d0.w),d5   ;convert to planar
	move.b (a4)+,d0        ;fetch chunky pixel 1
	or.l   0(a1,d0.w),d5   ;convert to planar, combine with above
	move.b (a4)+,d0        ;fetch chunky pixel 2
	or.l   0(a2,d0.w),d5   ;convert and combine
	move.b (a4)+,d0        ;fetch chunky pixel 3
	or.l   0(a3,d0.w),d5   ;convert and combine
	movep.l d5,0(a5)       ;put to screen

	move.b (a4)+,d0        ;fetch chunky pixel 4
	move.l 0(a0,d0.w),d5   ;convert to planar
	move.b (a4)+,d0        ;fetch chunky pixel 5
	or.l   0(a1,d0.w),d5   ;convert to planar, combine with above
	move.b (a4)+,d0        ;fetch chunky pixel 6
	or.l   0(a2,d0.w),d5   ;convert and combine
	move.b (a4)+,d0        ;fetch chunky pixel 7
	or.l   0(a3,d0.w),d5   ;convert and combine
	movep.l d5,1(a5)       ;put to screen

	addq.l #8,a5           ;increase target pointer
	dbra d7,.inloop        ;loop through line

;	...                    ;add offsets to source and target
	dbra d6,.outloop       ;loop over lines			14 (when branch taken)
	rts				16


c2p_pixel0
	dc.b %00000000,%00000000,%00000000,%00000000 ;Colour 0
	dc.b %11000000,%00000000,%00000000,%00000000 ;Colour 1
	dc.b %00000000,%11000000,%00000000,%00000000 ;Colour 2
	dc.b %11000000,%11000000,%00000000,%00000000 ;Colour 3
	dc.b %00000000,%00000000,%11000000,%00000000 ;Colour 4
	dc.b %11000000,%00000000,%11000000,%00000000 ;Colour 5
	dc.b %00000000,%11000000,%11000000,%00000000 ;Colour 6
	dc.b %11000000,%11000000,%11000000,%00000000 ;Colour 7
	dc.b %00000000,%00000000,%00000000,%11000000 ;Colour 8
	dc.b %11000000,%00000000,%00000000,%11000000 ;Colour 9
	dc.b %00000000,%11000000,%00000000,%11000000 ;Colour 10
	dc.b %11000000,%11000000,%00000000,%11000000 ;Colour 11
	dc.b %00000000,%00000000,%11000000,%11000000 ;Colour 12
	dc.b %11000000,%00000000,%11000000,%11000000 ;Colour 13
	dc.b %00000000,%11000000,%11000000,%11000000 ;Colour 14
	dc.b %11000000,%11000000,%11000000,%11000000 ;Colour 15

c2p_pixel1
	dc.b %000000,%000000,%000000,%000000 ;Colour 0
	dc.b %110000,%000000,%000000,%000000 ;Colour 1
	dc.b %000000,%110000,%000000,%000000 ;Colour 2
	dc.b %110000,%110000,%000000,%000000 ;Colour 3
	dc.b %000000,%000000,%110000,%000000 ;Colour 4
	dc.b %110000,%000000,%110000,%000000 ;Colour 5
	dc.b %000000,%110000,%110000,%000000 ;Colour 6
	dc.b %110000,%110000,%110000,%000000 ;Colour 7
	dc.b %000000,%000000,%000000,%110000 ;Colour 8
	dc.b %110000,%000000,%000000,%110000 ;Colour 9
	dc.b %000000,%110000,%000000,%110000 ;Colour 10
	dc.b %110000,%110000,%000000,%110000 ;Colour 11
	dc.b %000000,%000000,%110000,%110000 ;Colour 12
	dc.b %110000,%000000,%110000,%110000 ;Colour 13
	dc.b %000000,%110000,%110000,%110000 ;Colour 14
	dc.b %110000,%110000,%110000,%110000 ;Colour 15

c2p_pixel2
	dc.b %0000,%0000,%0000,%0000 ;Colour 0
	dc.b %1100,%0000,%0000,%0000 ;Colour 1
	dc.b %0000,%1100,%0000,%0000 ;Colour 2
	dc.b %1100,%1100,%0000,%0000 ;Colour 3
	dc.b %0000,%0000,%1100,%0000 ;Colour 4
	dc.b %1100,%0000,%1100,%0000 ;Colour 5
	dc.b %0000,%1100,%1100,%0000 ;Colour 6
	dc.b %1100,%1100,%1100,%0000 ;Colour 7
	dc.b %0000,%0000,%0000,%1100 ;Colour 8
	dc.b %1100,%0000,%0000,%1100 ;Colour 9
	dc.b %0000,%1100,%0000,%1100 ;Colour 10
	dc.b %1100,%1100,%0000,%1100 ;Colour 11
	dc.b %0000,%0000,%1100,%1100 ;Colour 12
	dc.b %1100,%0000,%1100,%1100 ;Colour 13
	dc.b %0000,%1100,%1100,%1100 ;Colour 14
	dc.b %1100,%1100,%1100,%1100 ;Colour 15

c2p_pixel3
	dc.b %00,%00,%00,%00 ;Colour 0
	dc.b %11,%00,%00,%00 ;Colour 1
	dc.b %00,%11,%00,%00 ;Colour 2
	dc.b %11,%11,%00,%00 ;Colour 3
	dc.b %00,%00,%11,%00 ;Colour 4
	dc.b %11,%00,%11,%00 ;Colour 5
	dc.b %00,%11,%11,%00 ;Colour 6
	dc.b %11,%11,%11,%00 ;Colour 7
	dc.b %00,%00,%00,%11 ;Colour 8
	dc.b %11,%00,%00,%11 ;Colour 9
	dc.b %00,%11,%00,%11 ;Colour 10
	dc.b %11,%11,%00,%11 ;Colour 11
	dc.b %00,%00,%11,%11 ;Colour 12
	dc.b %11,%00,%11,%11 ;Colour 13
	dc.b %00,%11,%11,%11 ;Colour 14
	dc.b %11,%11,%11,%11 ;Colour 15


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

;	dc.w	intreq,$8010

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

;	dc.w	intreq,$8010

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

;	dc.w	intreq,$8010

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
