	section	chunky4,code


; Press right mouse button to run test


*	For _chunky2planar :-
*
* A1200 NF		-      	0:51	-	9/sec
* A1200 VIPER 28Mhz '30 -	0:25	-	20/sec


*	For ChunkyConvert :-
*
* A1200 NF		-      	1:50	-	4/sec
* A1200 VIPER 28Mhz '30 -	0:56	-	9/sec


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2


	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#320*200*2,d0
	moveq	#1,d1			Public
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.source
	add.l	#320*200,d0
	move.l	d0,screen.intermediate
	beq	exit.now


	move.l	#8*40*200,d0
	move.l	#$10002,d1		Chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.dest
	beq	exit.freemem


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit.freemem2


*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts


*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#310,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	move.w	#$0210,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$b0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)
	move.w	#3,$1fc(a6)

	move.l	screen.dest(pc),d0	initialise copper
	lea	copper.list,a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$8380,dmacon(a6)	DMA on


	move.w	#$100,d7
	lea	Red.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$111,d7
	lea	Grey.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$001,d7
	lea	Blue.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$010,d7
	lea	Green.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$011,d7
	lea	Cyan.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$110,d7
	lea	Gold.256.Colours,a0
	bsr	Initialize.Colours

	move.w	#$101,d7
	lea	Purple.256.Colours,a0
	bsr	Initialize.Colours


	moveq	#0,d0
	lea	Purple.256.Colours,a1
	bsr	Set.Colours



	bsr	make.source.data


wait.start
	btst	#2,potgor(a6)
	bne.s	wait.start


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""


test.loop
;	bsr	_chunky2planar

	bsr	ChunkyConvert

	subq.w	#1,number
	bne.s	test.loop

	bra.s	exit


number	dc.w	500


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit	lea	$dff000,a6
	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a1
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit.freemem2
	move.l	#8*40*200,d0
	move.l	screen.dest(pc),a1
	jsr	-210(a6)		FreeMem

exit.freemem
	move.l	#320*200,d0
	move.l	screen.source(pc),a1
	jsr	-210(a6)		FreeMem

exit.now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

init.copper
	moveq	#8-1,d1
	move.l	#40*200,d2		size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts


*************************************************


; a0 = ColourList Pointers
; d0 = Which Set of 32 To Affect

Set.Colours
	moveq	#8-1,d7
Next.32.Set
	move.w	#$0c40,d1
	or.w	d0,d1
	move.w	d1,$106(a6)
	lea	$dff180,a2
	moveq	#16-1,d2
Next.Colour.C40
	move.l	(a1)+,(a2)+
	dbra	d2,Next.Colour.C40

	move.w	#$0e40,d1
	or.w	d0,d1
	move.w	d1,$106(a6)
	lea	$dff180,a2
	moveq	#16-1,d2

Next.Colour.E40
	move.l	(a1)+,(a2)+
	dbra	d2,Next.Colour.E40

	add.w	#$2000,d0
	dbra	d7,Next.32.Set

	rts


*************************************************


; a0 - Memory Address To Store Colours
; d7 - Increment Value

Initialize.Colours
	moveq	#0,d0
	move.l	d0,d1
	moveq	#8-1,d4
Lop1
	moveq	#2-1,d5	
	moveq	#16-1,d6
Lop2
	move.w	d0,(a0)+
	dbra	d6,Lop2
	add.w	d7,d0
	moveq	#16-1,d6
	dbra	d5,Lop2
	moveq	#16-1,d6
	moveq	#2-1,d5
Lop3
	move.w	d1,(a0)+
	add.w	d7,d1
	dbra	d6,Lop3
	moveq	#16-1,d6
	moveq	#0,d1
	dbra	d5,Lop3

	dbra	d4,Lop1

	rts


*************************************************


make.source.data
	move.l	screen.source(pc),a0
	moveq	#0,d0
	move.w	#YMAX*4-1,d2

.loop
	REPT	20
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	ENDR
	dbra	d2,.loop
	rts


	cnop	0,4


ChunkyConvert
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a2
	lea	4*40*200(a2),a3

	move.l	a0,a4
	add.l	#320*200,a4

Next32Pixels
	move.w	#0,a5

Next4Pixels
	move.l	(a0)+,d0

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	addq.w	#1,a5
	cmp.w	#8,a5
	bne	Next4Pixels

	move.l	d1,24000(a3)
	move.l	d2,16000(a3)
	move.l	d3,8000(a3)
	move.l	d4,(a3)+

	move.l	d5,24000(a2)
	move.l	d6,16000(a2)
	move.l	d7,8000(a2)
	move.l	a1,(a2)+

	cmp.l	a0,a4
	bne	Next32Pixels
	rts


	cnop	0,4


; Thanks to Chris Olson for providing me with this source.
; chris@ITD.Sterling.COM (Chris Olson)
; I'm unsure as to who produced this code though.


; Chunky2Planar algorithm. [writes pipelined a little]
;
; 	Cpu only solution
;	Optimised for 020+fastram
;	Aim for less than 90ms for 320x200x256 on 14MHz 020

;  a0 -> chunky pixels
;  a1 -> plane0

width		equ	320		; must be multiple of 32
height		equ	200
plsiz		equ	(width/8)*height

_chunky2planar:
	move.l	a7,saved.a7
	move.l	screen.source(pc),a0
	move.l	screen.intermediate(pc),a7
	move.l	screen.dest(pc),a1

	move.l	a0,a2
	add.l	#plsiz*8,a2	;a2 = end of chunky buffer
	
	;; Sweep thru the whole chunky data once,
	;; Performing 3 merge operations on it.
	
	move.l	#$00ff00ff,a3	; load byte merge mask
	move.l	#$0f0f0f0f,a4	; load nibble merge mask
	
firstsweep
	movem.l (a0)+,d0-d7      ;8+4n   40      cycles
	move.l  d4,a6    ;       a6 = CD
	move.w  d0,d4    ;       d4 = CB
	swap    d4       ;       d4 = BC
	move.w  d4,d0    ;       d0 = AC
	move.w  a6,d4    ;       d4 = BD
	move.l  d5,a6    ;       a6 = CD
	move.w  d1,d5    ;       d5 = CB
	swap    d5       ;       d5 = BC
	move.w  d5,d1    ;       d1 = AC
	move.w  a6,d5    ;       d5 = BD
	move.l  d6,a6    ;       a6 = CD
	move.w  d2,d6    ;       d6 = CB
	swap    d6       ;      d6 = BC
	move.w  d6,d2    ;       d2 = AC
	move.w  a6,d6    ;      d6 = BD
	move.l  d7,a6 ;          a6 = CD
	move.w  d3,d7    ;       d7 = CB
	swap    d7       ;       d7 = BC
	move.w  d7,d3    ;       d3 = AC
	move.w  a6,d7    ;       d7 = BD
	move.l  d7,a6 
	move.l  d6,a5
	move.l  a3,d6   ; d6 = 0x0x
	move.l  a3,d7   ; d7 = 0x0x
	and.l   d0,d6   ; d6 = 0b0r
	and.l   d2,d7   ; d7 = 0j0z
	eor.l   d6,d0   ; d0 = a0q0
	eor.l   d7,d2   ; d2 = i0y0
	lsl.l   #8,d6   ; d6 = b0r0
	lsr.l   #8,d2   ; d2 = 0i0y
	or.l    d2,d0           ; d0 = aiqy
	or.l    d7,d6           ; d2 = bjrz
	move.l  a3,d7   ; d7 = 0x0x
	move.l  a3,d2   ; d2 = 0x0x
	and.l   d1,d7   ; d7 = 0b0r
	and.l   d3,d2   ; d2 = 0j0z
	eor.l   d7,d1   ; d1 = a0q0
	eor.l   d2,d3   ; d3 = i0y0
	lsl.l   #8,d7   ; d7 = b0r0
	lsr.l   #8,d3   ; d3 = 0i0y
	or.l    d3,d1           ; d1 = aiqy
	or.l    d2,d7           ; d3 = bjrz

	move.l  a4,d2   ; d2 = 0x0x
	move.l  a4,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #4,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,(a7)+
	lsl.l	#4,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l	d2,(a7)+

	move.l  a4,d3   ; d3 = 0x0x
	move.l  a4,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #4,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l	d6,(a7)+
	lsl.l	#4,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l	d3,(a7)+

; move.l  d0,(a7)+
; move.l  d2,(a7)+
; move.l  d6,(a7)+
; move.l  d3,(a7)+
	move.l  a6,d7
	move.l  a5,d6
	move.l  a3,d0   ; d0 = 0x0x
	move.l  a3,d1   ; d1 = 0x0x
	and.l   d4,d0   ; d0 = 0b0r
	and.l   d6,d1   ; d1 = 0j0z
	eor.l   d0,d4   ; d4 = a0q0
	eor.l   d1,d6   ; d6 = i0y0
	lsl.l   #8,d0   ; d0 = b0r0
	lsr.l   #8,d6   ; d6 = 0i0y
	or.l    d6,d4           ; d4 = aiqy
	or.l    d1,d0           ; d6 = bjrz
	move.l  a3,d1   ; d1 = 0x0x
	move.l  a3,d6   ; d6 = 0x0x
	and.l   d5,d1   ; d1 = 0b0r
	and.l   d7,d6   ; d6 = 0j0z
	eor.l   d1,d5   ; d5 = a0q0
	eor.l   d6,d7   ; d7 = i0y0
	lsl.l   #8,d1   ; d1 = b0r0
	lsr.l   #8,d7   ; d7 = 0i0y
	or.l    d7,d5           ; d5 = aiqy
	or.l    d6,d1           ; d7 = bjrz
	move.l  a4,d6   ; d6 = 0x0x
	move.l  a4,d7   ; d7 = 0x0x
	and.l   d4,d6   ; d6 = 0b0r
	and.l   d5,d7   ; d7 = 0j0z
	eor.l   d6,d4   ; d4 = a0q0
	eor.l   d7,d5   ; d5 = i0y0
	lsr.l   #4,d5   ; d5 = 0i0y
	or.l    d5,d4           ; d4 = aiqy
	move.l  d4,(a7)+
	lsl.l   #4,d6   ; d6 = b0r0
	or.l    d7,d6           ; d5 = bjrz
	move.l  d6,(a7)+

	move.l  a4,d7   ; d7 = 0x0x
	move.l  a4,d5   ; d5 = 0x0x
	and.l   d0,d7   ; d7 = 0b0r
	and.l   d1,d5   ; d5 = 0j0z
	eor.l   d7,d0   ; d0 = a0q0
	eor.l   d5,d1   ; d1 = i0y0
	lsr.l   #4,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,(a7)+
	lsl.l   #4,d7   ; d7 = b0r0
	or.l    d5,d7           ; d1 = bjrz
	move.l  d7,(a7)+
	cmp.l   a0,a2           ;; 4c
	bne.w   firstsweep      ;; 6c

;	sub.l   #plsiz*8,a0
	move.l	screen.intermediate(pc),a0
	move.l  #$33333333,a5
	move.l  #$55555555,a6
	lea     plsiz*4(a1),a1  ;a2 = plane4

	move.l	a0,a2
	add.l	#plsiz*8,a2	;a2 = end of intermediate buffer

secondsweep
	move.l  (a0),d0
	move.l  8(a0),d1
	move.l  16(a0),d2
	move.l  24(a0),d3

	move.l  a5,d6   ; d6 = 0x0x
	move.l  a5,d7   ; d7 = 0x0x
	and.l   d0,d6   ; d6 = 0b0r
	and.l   d2,d7   ; d7 = 0j0z
	eor.l   d6,d0   ; d0 = a0q0
	eor.l   d7,d2   ; d2 = i0y0
	lsl.l   #2,d6   ; d6 = b0r0
	lsr.l   #2,d2   ; d2 = 0i0y
	or.l    d2,d0           ; d0 = aiqy
	or.l    d7,d6           ; d2 = bjrz
	move.l  a5,d7   ; d7 = 0x0x
	move.l  a5,d2   ; d2 = 0x0x
	and.l   d1,d7   ; d7 = 0b0r
	and.l   d3,d2   ; d2 = 0j0z
	eor.l   d7,d1   ; d1 = a0q0
	eor.l   d2,d3   ; d3 = i0y0
	lsl.l   #2,d7   ; d7 = b0r0
	lsr.l   #2,d3   ; d3 = 0i0y
	or.l    d3,d1           ; d1 = aiqy
	or.l    d2,d7           ; d3 = bjrz
	move.l  a6,d2   ; d2 = 0x0x
	move.l  a6,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #1,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,plsiz*3(a1)
	add.l   d2,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l  d2,plsiz*2(a1)

	move.l  a6,d3   ; d3 = 0x0x
	move.l  a6,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #1,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l  d6,plsiz*1(a1)
	add.l   d3,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l  d3,(a1)+
 
	move.l  4(a0),d0
	move.l  12(a0),d1
	move.l  20(a0),d2
	move.l  28(a0),d3

	move.l  a5,d6   ; d6 = 0x0x
	move.l  a5,d7   ; d7 = 0x0x
	and.l   d0,d6   ; d6 = 0b0r
	and.l   d2,d7   ; d7 = 0j0z
	eor.l   d6,d0   ; d0 = a0q0
	eor.l   d7,d2   ; d2 = i0y0
	lsl.l   #2,d6   ; d6 = b0r0
	lsr.l   #2,d2   ; d2 = 0i0y
	or.l    d2,d0           ; d0 = aiqy
	or.l    d7,d6           ; d2 = bjrz
	move.l  a5,d7   ; d7 = 0x0x
	move.l  a5,d2   ; d2 = 0x0x
	and.l   d1,d7   ; d7 = 0b0r
	and.l   d3,d2   ; d2 = 0j0z
	eor.l   d7,d1   ; d1 = a0q0
	eor.l   d2,d3   ; d3 = i0y0
	lsl.l   #2,d7   ; d7 = b0r0
	lsr.l   #2,d3   ; d3 = 0i0y
	or.l    d3,d1           ; d1 = aiqy
	or.l    d2,d7           ; d3 = bjrz
	move.l  a6,d2   ; d2 = 0x0x
	move.l  a6,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #1,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,-4-plsiz*1(a1)
	add.l   d2,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l  d2,-4-plsiz*2(a1)

	move.l  a6,d3   ; d3 = 0x0x
	move.l  a6,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #1,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l  d6,-4-plsiz*3(a1)
	add.l   d3,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l  d3,-4-plsiz*4(a1)
	lea     32(a0),a0  ;4c
	cmp.l   a0,a2   ;4c
	bne.w   secondsweep     ;;6c

	;300
	
	move.l	saved.a7(pc),a7
	rts


saved.a7	dc.l	0


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.source	dc.l	0
screen.intermediate	dc.l	0
screen.dest	dc.l	0
gfxbase		dc.l	0
old.ints	dc.w	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
		even


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$011,$022,$033,$044,$055,$066,$077
	dc.w	$088,$099,$0aa,$0bb,$0cc,$0dd,$0ee,$0ff


*"""""""""""""""""""
*" THE COPPER LIST "
*"		   "
*"""""""""""""""""""
	section	copper,code_c


copper.list
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl5pth,0
	dc.w	bpl5ptl,0
	dc.w	bpl6pth,0
	dc.w	bpl6ptl,0
	dc.w	bpl7pth,0
	dc.w	bpl7ptl,0
	dc.w	bpl8pth,0
	dc.w	bpl8ptl,0

	dc.w	$ffff,$fffe


Red.256.Colours
	ds.w	32*2*8

Grey.256.Colours
	ds.w	32*2*8

Blue.256.Colours
	ds.w	32*2*8

Green.256.Colours
	ds.w	32*2*8

Cyan.256.Colours
	ds.w	32*2*8

Gold.256.Colours
	ds.w	32*2*8

Purple.256.Colours
	ds.w	32*2*8


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
bpl7pth	equ	$0f8
bpl7ptl	equ	$0fa
bpl8pth	equ	$0fc
bpl8ptl	equ	$0fe
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
