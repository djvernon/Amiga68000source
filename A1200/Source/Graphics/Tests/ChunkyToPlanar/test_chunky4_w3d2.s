	section	chunky4,code


; Press right mouse button to run test


*	For new.chunky.convert.long :-
*
* A1200 NF		-	0:22	-	22/sec
* A1200 VIPER 28Mhz '30 -	0:11	-	45/sec


*	For new.chunky.convert.word :-
*
* A1200 NF		-	0:27	-	18/sec
* A1200 VIPER 28Mhz '30 -	0:15	-	33/sec


*	For _AsmChunky2Planar :-
*
* A1200 NF		-	0:32	-	15/sec
* A1200 VIPER 28Mhz '30 -	0:19	-	26/sec


*	For _c2p4 :-
*
* A1200 NF		-	0:30	-	16/sec
* A1200 VIPER 28Mhz '30 -	0:22	-	22/sec


*	For chunky.convert :-
*
* A1200 NF		-	0:53	-	9/sec
* A1200 VIPER 28Mhz '30 -	0:27	-	18/sec


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2


	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#320*200,d0
	moveq	#1,d1			Public
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.source
	beq	exit.now


	move.l	#4*40*200,d0
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


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4201,bplcon0(a6)	initialise screen
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


	move.w	#$87c0,dmacon(a6)	DMA on


	bsr	make.source.data


wait.start
	btst	#2,potgor(a6)
	bne.s	wait.start


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""


test.loop
	bsr	new.chunky.convert.long

;	bsr	new.chunky.convert.word

;	bsr	chunky.convert

;	bsr	_AsmChunky2Planar

;	bsr	_c2p4

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
	move.l	#4*40*200,d0
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
	moveq	#4-1,d1
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


make.source.data
	move.l	screen.source(pc),a0
	move.l	#$00010203,d0
	move.l	#$04050607,d1
	move.l	#$08090a0b,d2
	move.l	#$0c0d0e0f,d3
	move.w	#YMAX*4-1,d4

.loop
	REPT	5
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	ENDR
	dbra	d4,.loop
	rts


	cnop	0,4


new.chunky.convert.long
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a4
	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	move.w	#(XMAX*YMAX)/32-1,d7

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


	cnop	0,4


new.chunky.convert.word
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a4
	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	move.w	#(XMAX*YMAX)/16-1,d7

	move.l	#$00ff00ff,d4
	move.l	#$33333333,d5
	move.l	#$55555555,d6
	nop				to longword align the loop


;	cnop	0,4


.next.16.pixels
;	move.l	(a0)+,d0		.A.B.C.D
;	move.l	(a0)+,d1		.E.F.G.H
;	move.l	(a0)+,d2		.I.J.K.L
;	move.l	(a0)+,d3		.M.N.O.P
	movem.l	(a0)+,d0-d3

	lsl.l	#4,d0			A.B.C.D.
	lsl.l	#4,d2			I.J.K.L.
	or.l	d1,d0			AEBFCGDH
	or.l	d3,d2			IMJNKOLP

	move.l	d0,d1
	and.l	d4,d0			..BF..DH
	eor.l	d0,d1			AE..CG..
	move.l	d2,d3
	and.l	d4,d2			..JN..LP
	eor.l	d2,d3			IM..KO..
	lsl.l	#8,d0			BF..DH..
	lsr.l	#8,d3			..IM..KO
	or.l	d3,d1			AEIMCGKO
	or.l	d0,d2			BFJNDHLP

	swap	d2			DHLPBFJN
	move.w	d1,d0			....CGKO
	move.w	d2,d1			AEIMBFJN
	move.w	d0,d2			DHLPCGKO
	swap	d2			CGKODHLP

	move.l	d1,d0
	and.l	d5,d1
	eor.l	d1,d0
	move.l	d2,d3
	and.l	d5,d2
	eor.l	d2,d3
	lsl.l	#2,d1
	lsr.l	#2,d3
	or.l	d2,d1
	or.l	d3,d0

	swap	d0
	move.w	d1,d2
	move.w	d0,d1
	move.w	d2,d0
	swap	d0

	move.l	d1,d2
	and.l	d6,d1
	eor.l	d1,d2
	move.l	d0,d3
	and.l	d6,d0
	eor.l	d0,d3
;	lsl.l	#1,d1
	add.l	d1,d1
	lsr.l	#1,d3
	or.l	d0,d1
	or.l	d3,d2

	move.w	d2,(a1)+		plane 3
	swap	d2
	move.w	d1,(a2)+		plane 2
	swap	d1
	move.w	d2,(a3)+		plane 1
	move.w	d1,(a4)+		plane 0
	dbra	d7,.next.16.pixels
	rts


	cnop	0,4


; ------------------  G L O B A L   D E F I N E S  ------------------

DISPLAY_WIDTH	equ	320
DISPLAY_HEIGHT	equ	200 

PlaneSize	equ	(DISPLAY_WIDTH*DISPLAY_HEIGHT)/8  ; 

;--------------------------------------------------------------------
;AsmChunky2Planar
;
;FUNCTION:
;   Convert a chunky graphics bitmap into 4 planar bitmap planes
;
;PARAMETERS:
;   a0 -> chunky pixel buffer
;   a1 -> plane0 (assume other 3 planes are allocated contiguously)
;
;RETURNS:
;   none
;
;NOTE:
;   This is a modified version of the c2p routine: peterm/chunky4.s
;   by Peter McGavin (peterm@ker
;--------------------------------------------------------------------

; ------------------------  D E F I N E S  --------------------------

buffer		equr	a0
plane0		equr	a1
plane1		equr	a2
plane2		equr	a3
plane3		equr	a4
count		equr	d0
const1		equr	d5
const2		equr	d6

; ----------------------------  M A I N  ----------------------------

Psize	equ	(DISPLAY_WIDTH*DISPLAY_HEIGHT)/8


_AsmChunky2Planar:
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a1
	
	move.l	#$55555555,const1 ; d5 = constant $55555555
	move.l	#$3333cccc,const2 ; d6 = constant $3333cccc
	
	move.w	#PlaneSize,d0
	movea.l	plane0,plane1
	adda.w	d0,plane1
	movea.l	plane1,plane2
	adda.w	d0,plane2
	movea.l	plane2,plane3
	adda.w	d0,plane3
		
	move.w	#Psize-1,count ; Working on 4 planes at a time

				; processes 8 chunky pixels at a time
C2Pmain	move.l	(a0)+,d2	; 12 get next 4 chunky pixels in d2
	move.l	(a0)+,d3	; 12 get next 4 chunky pixels in d3

	lsl.l	#4,d2		; 16
	or.l	d3,d2		;  8
	move.l	d2,d3		;  4
	and.l	const2,d3	;  8
	move.w	d3,d1		;  4
	clr.w	d3		;  4
	lsl.l	#2,d3		; 12
	lsr.w	#2,d1		; 10
	or.w	d1,d3		;  4
	swap	d2		;  4
	and.l	const2,d2	;  8
	or.l	d2,d3		;  8
	move.l	d3,d2		;  4
	lsr.l	#7,d2		; 22
	move.l	d3,d1		;  4
	and.l	const1,d1	;  8
	eor.l	d1,d3		;  8
	move.l	d2,d4		;  4
	and.l	const1,d4	;  8
	eor.l	d4,d2		;  8
	or.l	d4,d3		;  8
	lsr.l	#1,d3		; 10
	or.l	d1,d2		;  8  inner loop thus far is 220

	move.b	d3,(plane3)+	; Write 8 pixels to the 4 bitplanes
	swap	d3
	move.b	d3,(plane1)+
	move.b	d2,(plane2)+
	swap	d2
	move.b	d2,(plane0)+
				
	dbra	count,C2Pmain	;   check if end of buffer is reached
				;   no continue as usual
FINC2P:
	rts


;--------------------------------------------------------------------
;--------------------------------------------------------------------


width		equ	320	; must be a multiple of 32
height		equ	200

plsiz	 	equ	width/8*height
pixels		equ	width*height

_c2p4:		move.l	screen.source(pc),a2
		move.l	#buff2,a4	; a4 -> buff2 (in Chip)
		move.l	#$00ff00ff,d7	; constant
		move.w	#pixels/32-1,d6	; loop counter
;		bra.s	go_c2p


		cnop	0,4


go_c2p:		movem.l	(a2)+,d0-d3/a0/a1/a5/a6	; ABCD EFGH IJKL MNOP QRST UVWX YZ01 2345

		lsl.l	#4,d0		; A.B.C.D.
		move.l	d0,d4		; A.B.C.D.
		and.l	d7,d4		; ..B...D.
		eor.l	d4,d0		; A...C...

		move.l	d1,d5		; .E.F.G.H
		and.l	d7,d5		; ...F...H
		eor.l	d5,d1		; .E...G..

		or.l	d1,d0		; AE..CG..
		or.l	d5,d4		; ..BF..DH

		move.l	d2,d1		; .I.J.K.L
		and.l	d7,d1		; ...J...L

		move.l	d3,d5		; .M.N.O.P
		and.l	d7,d5		; ...N...P

		lsl.l	#4,d4		; .BF..DH.
		or.l	d1,d4		; .BFJ.DHL
		lsl.l	#4,d4		; BFJ.DHL.
		or.l	d5,d4		; BFJNDHLP

		move.l	d4,pixels/4(a4)

		eor.l	d5,d3		; .M...O..
		lsr.l	#4,d3		; ..M...O.
		eor.l	d1,d2		; .I...K..
		or.l	d3,d2		; .IM..KO.
		lsr.l	#4,d2		; ..IM..KO
		or.l	d2,d0		; AEIMCGKO

		move.l	a6,d3
		move.l	a5,d2
		move.l	a1,d1

		move.l	d0,(a4)+

		move.l	a0,d0

		lsl.l	#4,d0		; Q.R.S.T.
		move.l	d0,d4		; Q.R.S.T.
		and.l	d7,d4		; ..R...T.
		eor.l	d4,d0		; Q...S...

		move.l	d1,d5		; .U.V.W.X
		and.l	d7,d5		; ...V...X
		eor.l	d5,d1		; .U...W..

		or.l	d1,d0		; QU..SW..
		or.l	d5,d4		; ..RV..TX

		move.l	d2,d1		; .Y.Z.0.1
		and.l	d7,d1		; ...Z...1

		move.l	d3,d5		; .2.3.4.5
		and.l	d7,d5		; ...3...5

		lsl.l	#4,d4		; .RV..TX.
		or.l	d1,d4		; .RVZ.TX1
		lsl.l	#4,d4		; RVZ.TX1.
		or.l	d5,d4		; RVZ3TX15

		move.l	d4,pixels/4(a4)

		eor.l	d5,d3		; .2...4..
		lsr.l	#4,d3		; ..2...4.
		eor.l	d1,d2		; .Y...0..
		or.l	d3,d2		; .Y2..04.
		lsr.l	#4,d2		; ..Y2..04
		or.l	d2,d0		; QUY2SW04

		move.l	d0,(a4)+

		dbra	d6,go_c2p


		lea	$dff000,a0

		btst	#6,dmaconr(a0)
blit31:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit31

		moveq	#-1,d0
		move.l	d0,bltafwm(a0)
		move.w	#0,bltdmod(a0)
		move.l	#buff2,bltapth(a0)
		move.l	#buff2+2,bltbpth(a0)
		move.l	#buff3,bltdpth(a0)
		move.w	#2,bltamod(a0)
		move.w	#2,bltbmod(a0)
		move.w	#pixels/8,bltsizv(a0)
		move.w	#$cccc,bltcdat(a0)
		move.l	#$0DE42000,bltcon0(a0)	; D=AC+(B>>2)~C
		move.w	#1,bltsizh(a0)		;do blit


		btst	#6,dmaconr(a0)
blit32:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit32

		move.l	#buff2+pixels/2-2-2,bltapth(a0)
		move.l	#buff2+pixels/2-2,bltbpth(a0)
		move.l	#buff3+pixels/2-2,bltdpth(a0)
		move.l	#$2DE40002,bltcon0(a0)	; D=(A<<2)C+B~C, desc.
		move.w	#1,bltsizh(a0)		;do blit


		move.l	screen.dest(pc),a2
		lea	24000(a2),a2

		btst	#6,dmaconr(a0)
blit43:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit43

		move.l	#buff3+0*pixels/8,bltapth(a0)
		move.l	#buff3+1*pixels/8,bltbpth(a0)
		move.l	a2,bltdpth(a0)		; Plane3
		move.w	#0,bltamod(a0)
		move.w	#0,bltbmod(a0)
		move.w	#pixels/16,bltsizv(a0)	;/8???
		move.w	#$aaaa,bltcdat(a0)
		move.l	#$0DE41000,bltcon0(a0)	; D=AC+(B>>1)~C
		move.w	#1,bltsizh(a0)		;plane 3


		lea	-16000(a2),a2

		btst	#6,dmaconr(a0)
blit41:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit41

		move.l	#buff3+2*pixels/8,bltapth(a0)
		move.l	#buff3+3*pixels/8,bltbpth(a0)
		move.l	a2,bltdpth(a0)		; Plane1
		move.w	#1,bltsizh(a0)		;plane 1


		lea	8000(a2),a2

		btst	#6,dmaconr(a0)
blit42:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit42

		move.l	#buff3+1*pixels/8-2,bltapth(a0)
		move.l	#buff3+2*pixels/8-2,bltbpth(a0)
		move.l	a2,d0
		add.l	#plsiz-2,d0
		move.l	d0,bltdpth(a0)		; Plane2+plsiz-2
		move.l	#$1DE40002,bltcon0(a0)	; D=(A<<1)C+B~C, desc.
		move.w	#1,bltsizh(a0)		;plane 2


		lea	-16000(a2),a2

		btst	#6,dmaconr(a0)
blit40:		btst	#6,dmaconr(a0)		wait for blitter to finish
		bne.s	blit40

		move.l	#buff3+3*pixels/8-2,bltapth(a0)
		move.l	#buff3+4*pixels/8-2,bltbpth(a0)
		move.l	a2,d0
		add.l	#plsiz-2,d0
		move.l	d0,bltdpth(a0)		; Plane0+plsiz-2
		move.w	#1,bltsizh(a0)		;plane 0
		rts

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------


chunky.convert
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a4
	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	move.w	#YMAX*10-1,d7

.next.32.pixels
	moveq	#8-1,d6

.next.long.word.chunky
	move.l	(a0)+,d0
	lsl.l	#5,d0

;	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	lsl.l	#5,d0

;	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	lsl.l	#5,d0

;	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	lsl.l	#5,d0

;	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	dbra	d6,.next.long.word.chunky

	move.l	d1,(a1)+
	move.l	d2,(a2)+
	move.l	d3,(a3)+
	move.l	d4,(a4)+
	dbra	d7,.next.32.pixels
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.source	dc.l	0
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

	dc.w	$ffff,$fffe


buff2		ds.w pixels	;Intermediate buffer 2
buff3		ds.w pixels	;Intermediate buffer 3


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
bltsizv	equ	$05C
bltsizh	equ	$05E
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
