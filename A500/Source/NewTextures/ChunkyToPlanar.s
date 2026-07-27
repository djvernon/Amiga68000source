	section	c2p,code
	opt	c+


SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4


*""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER "
*"			      "
*""""""""""""""""""""""""""""""

*	4 bitplane version
*
*	68000 CPU cycles reqd: 128 + ((width*height)/32 * 800) + 32
*	(1600160 cycles for 320*200 screen)
*	(about 0.22 seconds on an A500)
*
*	approx. 25 CPU cycles (6.25 CPU memory cycles) per screen pixel


;	cnop	0,4

new.chunky.convert.long
	move.l	chunky.memory,a0	20
	move.l	screen1,a4		20
	lea	8000(a4),a3		8
	lea	16000(a4),a2		8
	lea	24000(a4),a1		8
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7	8

	move.l	a7,saved.a7		20
	move.l	#$00ff00ff,a5		12
	move.l	#$33333333,a6		12
	move.l	#$55555555,a7		12

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
	movem.l	(a0)+,d0-d6		68

	lsl.l	#4,d0			A.B.C.D.	16
	lsl.l	#4,d2			I.J.K.L.	16
	lsl.l	#4,d4			Q.R.S.T.	16
	lsl.l	#4,d6			Y.Z.a.b.	16
	or.l	d1,d0			AEBFCGDH	8
	or.l	d3,d2			IMJNKOLP	8
	or.l	d5,d4			QURVSWTX	8
	or.l	(a0)+,d6		YcZdaebf	14

	swap	d4			SWTXQURV	4
	move.w	d0,d1			....CGDH	4
	move.w	d4,d0			AEBFQURV	4
	move.w	d1,d4			SWTXCGDH	4
	swap	d4			CGDHSWTX	4

	swap	d6			aebfYcZd	4
	move.w	d2,d3			....KOLP	4
	move.w	d6,d2			IMJNYcZd	4
	move.w	d3,d6			aebfKOLP	4
	swap	d6			KOLPaebf	4

	move.l	a5,d5					4

	move.l	d0,d1					4
	and.l	d5,d1			..BF..RV	8
	eor.l	d1,d0			AE..QU..	8
	move.l	d2,d3					4
	and.l	d5,d3			..JN..Zd	8
	eor.l	d3,d2			IM..Yc..	8
	lsl.l	#8,d1			BF..RV..	24
	lsr.l	#8,d2			..IM..Yc	24
	or.l	d2,d0			AEIMQUYc	8
	or.l	d3,d1			BFJNRVZd	8

	move.l	d4,d2					4
	and.l	d5,d4			..DH..TX	8
	eor.l	d4,d2			CG..SW..	8
	move.l	d6,d3					4
	and.l	d5,d3			..LP..bf	8
	eor.l	d3,d6			KO..ae..	8
	lsl.l	#8,d4			DH..TX..	24
	lsr.l	#8,d6			..KO..ae	24
	or.l	d6,d2			CGKOSWae	8
	or.l	d4,d3			DHLPTXbf	8

	move.l	a6,d6					4

	move.l	d0,d4	4
	and.l	d6,d0	8		.A.E.I.M.Q.U.Y.c	bits 10
	eor.l	d0,d4	8		A.E.I.M.Q.U.Y.c.	bits 32
	move.l	d2,d5	4
	and.l	d6,d5	8		.C.G.K.O.S.W.a.e	bits 10
	eor.l	d5,d2	8		C.G.K.O.S.W.a.e.	bits 32
	lsl.l	#2,d0	12		A.E.I.M.Q.U.Y.c.	bits 10
	lsr.l	#2,d2	12		.C.G.K.O.S.W.a.e	bits 32
	or.l	d5,d0	8		ACEGIKMOQSUWYace	bits 10
	or.l	d4,d2	8		ACEGIKMOQSUWYace	bits 32

	move.l	d1,d4	4
	and.l	d6,d1	8		.B.F.J.N.R.V.Z.d	bits 10
	eor.l	d1,d4	8		B.F.J.N.R.V.Z.d.	bits 32
	move.l	d3,d5	4
	and.l	d6,d5	8		.D.H.L.P.T.X.b.f	bits 10
	eor.l	d5,d3	8		D.H.L.P.T.X.b.f.	bits 32
	lsl.l	#2,d1	12		B.F.J.N.R.V.Z.d.	bits 10
	lsr.l	#2,d3	12		.D.H.L.P.T.X.b.f	bits 32
	or.l	d5,d1	8		BDFHJLNPRTVXZbdf	bits 10
	or.l	d4,d3	8		BDFHJLNPRTVXZbdf	bits 32

	move.l	a7,d6	4

	move.l	d0,d4	4
	and.l	d6,d0	8	.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 0
	eor.l	d0,d4	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 1
	add.l	d0,d0	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 0
	move.l	d1,d5	4
	and.l	d6,d5	8	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 0
	or.l	d5,d0	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 0
	move.l	d0,(a4)+	12	plane 0
	eor.l	d5,d1	8	B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 1
	lsr.l	#1,d1	10	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 1
	or.l	d4,d1	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 1
	move.l	d1,(a3)+	12	plane 1

	move.l	d2,d4	4
	and.l	d6,d2	8	.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 2
	eor.l	d2,d4	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 3
	add.l	d2,d2	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 2
	move.l	d3,d5	4
	and.l	d6,d5	8	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 2
	or.l	d5,d2	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 2
	move.l	d2,(a2)+	12	plane 2
	eor.l	d5,d3	8	B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 3
	lsr.l	#1,d3	10	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 3
	or.l	d4,d3	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 3
	move.l	d3,(a1)+	12	plane 3

;	move.l	d3,(a1)+		plane 3
;	move.l	d2,(a2)+		plane 2
;	move.l	d1,(a3)+		plane 1
;	move.l	d0,(a4)+		plane 0
	dbra	d7,.next.32.pixels	14

	move.l	saved.a7(pc),a7		16
	rts				16


saved.a7	dc.l	0
chunky.memory	dc.l	0
screen1		dc.l	0
