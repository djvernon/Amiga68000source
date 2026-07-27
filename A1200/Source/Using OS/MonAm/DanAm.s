	section	DanAm,code


FILE_DSM_BUF_SIZE	equ	256*1024

MAX_DATA_AREAS	equ	200


	bra	AD4


	dc.l	$4D4F4E20,A64
	dc.l	$54
A50	dc.l	0
A54	dc.l	0
A58	dc.l	0,0
A60	dc.l	0
A64	dc.b	0
A65	dc.b	$FF
	dc.b	$FF
A67	dc.b	$01
	dc.w	$0020
A6A	dc.w	$0800
	dc.l	0
	dc.w	0
A72	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0
AB2	dc.w	$FFFF
	dc.l	$FF000001,$24564552
	dc.l	$3A204D6F,$6E416D20
	dc.l	$332E3034,$20283230
	dc.l	$2E312E39,$33290000

AD4	movem.l	d0/a0,NE02
	move.l	#$DFA,d0
	move.l	#$10001,d1
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	d0,a6
	tst.l	d0
;	bne.s	AFA
	bne.s	got.work.mem

	moveq	#$67,d0
	rts

file.dsm.mem	dc.l	0

got.work.mem
	move.l	#FILE_DSM_BUF_SIZE,d0
	move.l	#$10001,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	move.l	d0,file.dsm.mem
	beq	free.work.mem

AFA	cmpi.l	#$44455620,A50
	seq	$162(a6)
	bne.s	B10
	move.l	A54(pc),$15E(a6)
B10	move.l	a7,$B6(a6)
	move.l	4(a7),$B2(a6)
	moveq	#$21,d0
	lea	FEE3,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$228(a6)
	movea.l	(a7)+,a6
	move.l	d0,$BE(a6)
	beq.s	B68
	moveq	#$1D,d0
	lea	GE01,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$228(a6)
	movea.l	(a7)+,a6
	move.l	d0,$C6(a6)
	beq.s	B68
	moveq	#$1D,d0
	lea	FEF5,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$228(a6)
	movea.l	(a7)+,a6
	move.l	d0,$C2(a6)
	bne.s	B6E
B68	moveq	#$7A,d4
	bra	EAC
B6E	lea	GE12,a0
	moveq	#-1,d0
	lea	$7F8(a6),a1
	moveq	#0,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$1BC(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	bne	EAA
	suba.l	a1,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$126(a6)
	movea.l	(a7)+,a6
	move.l	d0,NE6C
	move.l	d0,$122(a6)
	moveq	#-1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$14A(a6)
	movea.l	(a7)+,a6
	move.b	d0,$121(a6)
	moveq	#-1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$14A(a6)
	movea.l	(a7)+,a6
	move.b	d0,NE74
	lea	$112(a6),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$162(a6)
	movea.l	(a7)+,a6
	movea.l	4.w,a0
	move.w	$128(a0),d0
	btst	#4,d0
	sne	NE1C
	andi.b	#3,d0
	beq.s	C14
	lea	WC0(pc),a1
	lea	W58+2(pc),a0
	move.l	a1,(a0)
	cmp.b	#1,d0
	beq.s	C0C
	moveq	#4,d0
	bsr	OBA8
	bra.s	C14
C0C	move.w	#$4E71,WD6
C14	bsr	CCE6
	clr.l	F20
	clr.l	F24
	move.w	#$8000,d2
	tst.b	A67
	beq.s	C36
	bpl.s	C40
C32	ori.w	#4,d2
C36	move.w	d2,EF4
	bra	CC2
C40	movea.l	$BE(a6),a0
	cmpi.w	#$24,$14(a0)
	bcc.s	C74
C4C	moveq	#$54,d0
	suba.l	d0,a7
	movea.l	a7,a0
	moveq	#1,d1
	suba.l	a1,a1
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$1AA(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	beq.s	C36
	btst	#2,$4D(a7)
	lea	$54(a7),a7
	bne.s	C32
	bra.s	C36
C74	lea	GE21,a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$1FE(a6)
	movea.l	(a7)+,a6
	move.l	d0,d2
	beq.s	C4C
	movea.w	#$2C,a0
	adda.l	d0,a0
	move.l	a6,-(a7)
	movea.l	$C6(a6),a6
	jsr	-$318(a6)
	movea.l	(a7)+,a6
	cmp.l	#$FFFFFFFF,d0
	beq.s	C4C
	lea	F20(pc),a0
	addq.l	#1,(a0)+
	move.l	#$80000032,(a0)+
	move.l	d0,(a0)
	suba.l	a0,a0
	movea.l	d2,a1
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$204(a6)
	movea.l	(a7)+,a6
CC2	lea	EE8(pc),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	move.l	d0,$CE(a6)
	beq	E64
	movea.l	d0,a1
	lea	F30(pc),a0
	move.l	a1,$1E(a0)
	moveq	#1,d1
	add.b	$1E(a1),d1
	move.l	$C(a1),4(a0)
	move.w	d1,2(a0)
	sub.w	d1,6(a0)
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$CC(a6)
	movea.l	(a7)+,a6
	move.l	d0,$5B4(a6)
	beq	E54
	movea.l	#PE08,a0
	jsr	FE50
	bsr	F8C
	bsr	PB12
	bsr	UC7E
	move.b	#$78,$149(a6)
	st	$14B(a6)
	sf	$E4(a6)
	sf	$146(a6)
	move.l	#$FFFFFFFF,$13E(a6)
	clr.l	NE0C
	clr.b	NE0B
	lea	$10(a6),a0
	moveq	#$F,d0
D50	clr.l	(a0)+
	dbf	d0,D50
	clr.l	$50(a6)
	clr.w	$5A(a6)
	clr.w	$58(a6)
	movea.l	4.w,a0
	move.l	a0,$BA(a6)
	move.l	a0,$5C(a6)
	move.l	a0,$54(a6)
	bsr	NB60
	bsr	PBD2
	lea	$5B8(a6),a3
	jsr	DEC2
	bsr	OC34
	bsr	K24
	lea	A72(pc),a0
	tst.b	(a0)
	beq.s	D98
	bsr	SDEE
D98	pea	FBA(pc)
	move.l	$15E(a6),d0
	beq.s	DB8
	lea	DB0(pc),a3
	movea.l	NE06,a4
	bra	MC62
DB0	dc.w	$4D45
	dc.w	$4D54
	dc.w	$4153
	chk.l	d0,d5
DB8	movem.l	NE02,d0/a0
	lea	0(a0,d0.l),a1
DC4	cmpi.b	#$20,-(a1)
	dbhi	d0,DC4
	clr.b	1(a1)
	cmpa.l	a0,a1
	bcs	MC02
	st	d0
DD8	cmpi.b	#$20,(a0)+
	beq.s	DD8
	cmpi.b	#$22,-1(a0)
	beq.s	DEA
	subq.l	#1,a0
	sf	d0
DEA	movea.l	a0,a3
DEC	move.b	(a0)+,d1
	beq.s	E10
	tst.b	d0
	beq.s	DFC
	cmp.b	#$22,d1
	bne.s	DEC
	bra.s	E02
DFC	cmp.b	#$20,d1
	bne.s	DEC
E02	clr.b	-1(a0)
E06	move.b	(a0)+,d1
	beq.s	E10
	cmp.b	#$20,d1
	beq.s	E06
E10	lea	-1(a0),a4
	bra	MC46
E18	bsr	TD2E
	movea.l	$B6(a6),a7
	move.l	$13A(a6),d0
	beq.s	E36
	movea.l	$136(a6),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D2(a6)
	movea.l	(a7)+,a6
E36	bsr	VD42
	jsr	FEC0
	bsr	F8E
	movea.l	$5B4(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$48(a6)
	movea.l	(a7)+,a6
E54	movea.l	$CE(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$42(a6)
	movea.l	(a7)+,a6
E64	lea	$112(a6),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$168(a6)
	movea.l	(a7)+,a6
	moveq	#0,d0
	move.b	$121(a6),d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$150(a6)
	movea.l	(a7)+,a6
	moveq	#0,d0
	move.b	NE74,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$150(a6)
	movea.l	(a7)+,a6
	lea	$7F8(a6),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$1C2(a6)
	movea.l	(a7)+,a6
EAA	moveq	#0,d4
EAC	move.l	$C2(a6),d0
	bsr.s	ED6
	move.l	$C6(a6),d0
	bsr.s	ED6
	move.l	$BE(a6),d0
	bsr.s	ED6

free.file.dsm.mem
	move.l	#FILE_DSM_BUF_SIZE,d0
	move.l	file.dsm.mem(pc),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D2(a6)
	movea.l	(a7)+,a6

free.work.mem
	move.l	#$DFA,d0
	movea.l	a6,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D2(a6)
	movea.l	(a7)+,a6
	move.l	d4,d0
	rts

ED6	beq.s	EE6
	movea.l	d0,a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$19E(a6)
	movea.l	(a7)+,a6
EE6	rts

EE8	dc.l	0,$280FFFF
	dc.l	$10001
EF4	dc.l	$8000100F,0
	dc.l	F60,0
	dc.l	0,F0C
F0C	dc.l	$80000023,$FFFFFFFF
	dc.l	$80000039,1
	dc.l	$8000002C
F20	dc.l	0
F24	dc.l	0,0
	dc.l	0
F30	dc.l	0,$28000C8
	dc.l	$10000,$4000002
	dc.l	$19400000,0
	dc.l	0,0
	dc.l	0,0
	dc.l	0,$F
F60	dc.b	'DanAm version 3.00'
	dc.b	'  Copyright ',$a9,' 1995 DVSoft',0

F8C	rts
F8E	rts

F90	lea	$5B8(a6),a3
	move.w	#1,6(a3)
	move.w	$EE(a6),8(a3)
	bra	PCD0
FA4	tst.b	$E5(a6)
	beq.s	FB8
FAA	movem.l	d1/a3,-(a7)
	bsr.s	F90
	sf	$E5(a6)
	movem.l	(a7)+,d1/a3
FB8	rts
FBA	bsr	RB9E
	bmi.s	FF6
	bsr.s	FA4
FC2	cmp.b	#9,d1
	beq.s	FEA
	cmp.b	#$88,d1
	beq.s	FF0
	cmp.b	#$87,d1
	beq	FCFE
	bra	G26
FDA	move.l	$DE(a6),d0
	beq.s	FBA
	movea.l	d0,a3
	bsr	H12
	beq.s	FBA
	bra.s	FC2
FEA	bsr	LC0
	bra.s	FBA
FF0	bsr	LF0
	bra.s	FBA
FF6	bsr.s	FA4
	move.l	$DE(a6),d0
	beq.s	FBA
	movea.l	d0,a3
	cmp.b	#$5A,d1
	beq	G9C
	cmp.b	#$3A,d1
	bcs.s	G1C
	cmp.b	#$48,d1
	beq	FCFE
	bsr	H86
	bra.s	FBA
G1C	subi.b	#$30,d1
	bsr	L68
	bra.s	FBA
G26	move.b	d1,d0
	cmp.b	#$41,d0
	bcs.s	G32
	andi.b	#$DF,d0
G32	lea	TBEC(pc),a0
G36	move.b	(a0)+,d3
	move.b	(a0)+,d2
	beq.s	FDA
	cmp.b	d0,d2
	beq.s	G44
	addq.w	#2,a0
	bra.s	G36
G44	tst.b	d3
	beq.s	G90
	subq.b	#1,d3
	beq.s	G74
	subq.b	#1,d3
	beq.s	G6A
	subq.b	#1,d3
	beq.s	G60
	cmpi.b	#1,$134(a6)
	beq.s	G90
	moveq	#$21,d1
	bra.s	G7C
G60	tst.b	$134(a6)
	beq.s	G90
	moveq	#$22,d1
	bra.s	G7C
G6A	tst.b	$134(a6)
	bne.s	G90
	moveq	#$23,d1
	bra.s	G7C
G74	moveq	#$24,d1
	tst.b	$134(a6)
	bmi.s	G90
G7C	move.w	d1,-(a7)
	bsr	F90
	move.w	(a7)+,d1
	bsr	ID60
	st	$E5(a6)
	bra	FBA
G90	adda.w	(a0),a0
	movea.l	$DE(a6),a3
	jsr	(a0)
	bra	FBA
G9C	move.l	a3,-(a7)
	lea	$5B8(a6),a3
	bsr	OC34
	lea	$728(a6),a3
	movem.w	$84A(a6),d0-d4
	bsr	OC2E
	st	$10(a3)
	movea.l	(a7)+,a2
	lea	$12(a3),a0
	lea	$12(a2),a1
	moveq	#$19,d0
GC4	move.w	(a1)+,(a0)+
	dbf	d0,GC4
	st	d7
	st	d4
	bsr	SCEA
	move.b	$31(a3),-(a7)
	bsr	VC5C
	move.b	(a7)+,d0
	cmpi.b	#4,$30(a3)
	bne.s	GE8
	move.b	d0,$31(a3)
GE8	bsr	WCA8
GEC	bsr	RB9A
	bmi.s	H06
GF2	cmp.b	#$1B,d1
	beq.s	GFE
	bsr.s	H12
	beq.s	GEC
	bra.s	GF2
GFE	bsr	VC2A
	bra	FBA
H06	cmp.b	#$5A,d1
	beq.s	GFE
	bsr	H86
	bra.s	GEC
H12	pea	H74(pc)
	movea.l	$3A(a3),a0
	cmp.b	#$80,d1
	beq.s	H60
	cmp.b	#$82,d1
	beq.s	H64
	cmp.b	#$83,d1
	beq.s	H68
	cmp.b	#$81,d1
	beq.s	H5C
	cmp.b	#$84,d1
	beq.s	H6C
	cmp.b	#$85,d1
	beq.s	H70
	cmp.b	#$89,d1
	beq.s	H6C
	cmp.b	#$8A,d1
	beq.s	H70
	tst.w	$728(a6)
	beq.s	H56
	cmp.b	#$20,d1
	beq.s	H5C
H56	addq.l	#4,a7
	moveq	#0,d1
	rts
H5C	jmp	6(a0)
H60	jmp	4(a0)
H64	jmp	8(a0)
H68	jmp	$A(a0)
H6C	jmp	$C(a0)
H70	jmp	$E(a0)
H74	bmi.s	H78
	rts
H78	clr.l	6(a3)
	movea.l	$3A(a3),a0
	jsr	(a0)
	moveq	#0,d1
	rts
H86	cmp.b	#$41,d1
	beq	LF2
	cmp.b	#$42,d1
	beq	I90
	cmp.b	#$45,d1
	beq	I5E
	cmp.b	#$47,d1
	beq	M3A
	cmp.b	#$4C,d1
	beq	N8E
	cmp.b	#$50,d1
	beq	J58
	cmp.b	#$52,d1
	beq.s	HDE
	cmp.b	#$53,d1
	beq	M78
	cmp.b	#$54,d1
	beq	R3A
	cmp.b	#$57,d1
	beq	M7C
	cmp.b	#$51,d1
	beq	UBCA
	rts
HDE	move.l	a3,-(a7)
	moveq	#4,d3
	lea	JEC8,a0
	bsr	BAD8
HEC	bsr	RC56
	bne.s	I3A
	tst.b	(a4)
	beq.s	I3A
	movea.l	a4,a2
HF8	move.b	(a2)+,d1
	beq.s	HEC
	cmp.b	#$3D,d1
	bne.s	HF8
	lea	$AB4(a6),a1
	move.l	a2,d2
	sub.l	a1,d2
	subq.w	#1,d2
	bsr	PDF8
	bne.s	HEC
	movem.l	a0/a4,-(a7)
	movea.l	a2,a4
	bsr	JD62
	movem.l	(a7)+,a0/a4
	bne.s	HEC
	move.l	d2,(a0)
	move.l	a0,-(a7)
	bsr	VC2A
	move.l	(a7)+,d2
	tst.w	$728(a6)
	bne.s	I36
	bsr	WC68
I36	movea.l	(a7)+,a3
	rts
I3A	bsr	VC2A
	movea.l	(a7)+,a3
	rts
I42	move.l	a3,-(a7)
	lea	$728(a6),a3
	tst.w	0(a3)
	bne.s	I56
	bsr	WC68
	movea.l	(a7)+,a3
	rts
I56	bsr	WCA8
	movea.l	(a7)+,a3
	rts
I5E	move.b	$30(a3),d0
	cmp.b	#2,d0
	beq	HDE
	cmp.b	#1,d0
	beq	XCDE
	cmp.b	#4,d0
	beq.s	I7A
	rts
I7A	eori.b	#$C,$31(a3)
	move.b	$31(a3),A6A
	bsr	OC34
	bra	WCA8
I90	lea	KE53,a0
	bsr	I9E
	bne.s	I42
	rts
I9E	move.l	a3,-(a7)
	moveq	#4,d3
	bsr	BAD8
IA6	bsr	RC56
	bne.s	J0E
	tst.b	(a4)
	beq.s	J0E
	bsr	JD76
	beq.s	IC0
IB6	bsr	VCDE
	lea	$AB4(a6),a4
	bra.s	IA6
IC0	move.l	d2,d5
	moveq	#1,d2
	tst.b	d1
	beq.s	IF6
	cmp.b	#$2C,d1
	bne.s	IB6
	move.b	(a4)+,d1
	cmp.b	#$3F,d1
	beq.s	J18
	cmp.b	#$2A,d1
	beq.s	J2A
	cmp.b	#$3D,d1
	beq.s	J36
	cmp.b	#$2D,d1
	bne.s	IEC
	tst.b	(a4)
	beq.s	J46
IEC	bsr	JD78
	bne.s	IB6
	tst.b	d1
	bne.s	IB6
IF6	move.l	d2,d6
	bsr	VC2A
	move.l	d6,d2
	moveq	#1,d3
J00	movea.l	d5,a1
	bsr	NB9A
	bne.s	J12
J08	movea.l	(a7)+,a3
	moveq	#1,d0
	rts
J0E	bsr	VC2A
J12	movea.l	(a7)+,a3
	moveq	#0,d0
	rts
J18	bsr	JD3E
	bne.s	IB6
	move.l	a4,-(a7)
	bsr	VC2A
	movea.l	(a7)+,a4
	moveq	#4,d3
	bra.s	J00
J2A	tst.b	(a4)+
	bne.s	IB6
	bsr	VC2A
	moveq	#3,d3
	bra.s	J00
J36	tst.b	(a4)+
	bne	IB6
	bsr	VC2A
	moveq	#2,d3
	moveq	#0,d2
	bra.s	J00
J46	bsr	VC2A
	movea.l	d5,a1
	bsr	OB3A
	bne.s	J12
	bsr	OB6C
	bra.s	J08
J58	bsr	TDAE
	bne.s	J68
	lea	KE93,a0
	bra	CA30
J68	st	$E4(a6)
	bsr	WCA8
	sf	$E4(a6)
	rts

J76	dc.l	JCA
	dc.w	$E905
	dc.l	JD0
	dc.w	$ED00
	dc.l	JD6
	dc.w	$E00D
	dc.l	JDC
	dc.w	$9E5
	dc.l	JE2
	dc.w	$DE0
	dc.l	JE8
	dc.w	$ED
	dc.l	JEE
	dc.w	$A965
	dc.l	JF5
	dc.w	$AD60
	dc.l	JFC
	dc.w	$A06D
	dc.l	K03
	dc.w	$B065
	dc.l	K0A
	dc.w	$A970
	dc.l	K11
	dc.w	$B070
	dc.l	K18
	dc.w	$F000
	dc.l	K1E
	dc.w	$F0

JCA	dc.w	$8C46,$51E6,$7200

JD0	dc.w	$8C47,$50E7,$F000

JD6	dc.w	$8C48,$D0E8

JDA	dc.w	$7000

JDC	dc.w	$C654,$AD66,$7500

JE2	dc.w	$C753,$AD67,$F300

JE8	dc.w	$C8D3,$AD68,$7300

JEE	dc.w	$8940,$57AA,$6378
	dc.b	0

JF5	dc.b	$89
	dc.w	$4156,$AA64,$F600

JFC	dc.w	$8942,$D6AA,$6576
	dc.b	0

K03	dc.b	$86
	dc.w	$4CD6,$AB63,$7800

K0A	dc.w	$8B40,$57A6,$6DF6
	dc.b	0

K11	dc.b	$8A
	dc.w	$4CDA,$A96D,$F900

K18	dc.w	$814B,$D1EB,$F200

K1E	dc.w	$CBD4,$A56B,$F500

K24	lea	$610(a6),a3
	move.l	a3,$DE(a6)
	lea	$5CA(a6),a3
	moveq	#1,d0
	move.w	d0,$F2(a6)
	move.w	$DC(a6),d1
	move.w	$EC(a6),d2
	subq.w	#2,d2
	move.w	d2,$FE(a6)
	move.w	#$A,d3
	bsr	NCFE
	moveq	#$19,d1
	move.w	$EC(a6),d0
	subi.w	#$58,d0
	bls.s	K62
	divu.w	#$1C,d0
	mulu.w	#$E,d0
	add.w	d0,d1
K62	move.w	d1,$FA(a6)
	move.w	$EC(a6),d0
	sub.w	d1,d0
	subq.w	#1,d0
	move.w	d0,$F4(a6)
	move.w	4(a3),d0
	add.w	8(a3),d0
	add.w	$DC(a6),d0
	add.w	$DC(a6),d0
	addq.w	#1,d0
	move.w	d0,$F6(a6)
	neg.w	d0
	add.w	$EA(a6),d0
	sub.w	$DC(a6),d0
	ext.l	d0
	divu.w	$D8(a6),d0
	move.w	d0,$104(a6)
	subq.w	#2,d0
	lsr.w	#1,d0
	move.w	d0,$102(a6)
	move.w	$F4(a6),d0
	subq.w	#3,d0
	move.w	d0,$FC(a6)
	move.w	$102(a6),d0
	mulu.w	$D8(a6),d0
	add.w	$F6(a6),d0
	add.w	$DC(a6),d0
	addq.w	#1,d0
	move.w	d0,$F8(a6)
	neg.w	d0
	add.w	$EA(a6),d0
	sub.w	$DC(a6),d0
	subq.w	#1,d0
	ext.l	d0
	divu.w	$D8(a6),d0
	move.w	d0,$100(a6)
	addq.b	#2,$5FA(a6)
	addq.b	#3,$640(a6)
	addq.b	#3,$6CC(a6)
	addq.b	#1,$686(a6)
	addq.b	#1,$712(a6)
	move.w	$F0(a6),d0
	bsr	N7C
	moveq	#4,d1
KF8	movem.w	d0-d1,-(a7)
	moveq	#5,d0
	sub.b	d1,d0
	move.b	d0,$38(a3)
	suba.l	a0,a0
	bsr	RFE
	move.l	a0,$40(a3)
	cmpi.b	#1,$38(a3)
	beq.s	L4A
	cmpi.b	#2,$38(a3)
	bne.s	L30
	st	$3E(a3)
	move.l	#$70630000,$44(a0)
	move.l	$54(a6),$34(a3)
L30	move.w	(a7),d0
	rol.w	#4,d0
	move.w	d0,(a7)
	andi.w	#$F,d0
	bne.s	L42
	bsr	VC5C
	bra.s	L52
L42	bsr	N10
	bsr	NCFE
L4A	bsr	VC5C
	bsr	N04
L52	lea	$46(a3),a3
	movem.w	(a7)+,d0-d1
	dbf	d1,KF8
	rts
	bsr	O66
	bra	WC68
L68	lea	$5CA(a6),a3
	moveq	#6,d2
L6E	cmp.b	$38(a3),d1
	beq.s	L7E
	lea	$46(a3),a3
	dbf	d2,L6E
	rts
L7E	move.l	$DE(a6),d0
	beq.s	L9E
	cmp.l	a3,d0
	bne.s	L8A
	rts
L8A	move.l	a3,-(a7)
	movea.l	d0,a3
	tst.w	0(a3)
	beq.s	L9C
	sf	d7
	st	d4
	bsr	SCEA
L9C	movea.l	(a7)+,a3
L9E	movea.l	$40(a3),a0
	bsr	SF2
	move.l	a3,$DE(a6)
	tst.w	0(a3)
	bne.s	LB8
	move.b	#$C0,d1
	bra	M80
LB8	st	d7
	st	d4
	bra	SCEA
LC0	move.w	#$76E,d3
	move.l	$DE(a6),d0
	beq.s	LCE
	move.l	d0,d3
	sub.l	a6,d3
LCE	moveq	#6,d2
LD0	cmp.w	#$76E,d3
	bne.s	LDA
	move.w	#$584,d3
LDA	addi.w	#$46,d3
	tst.w	0(a6,d3.w)
	bne.s	LEA
	dbf	d2,LD0
	rts
LEA	lea	0(a6,d3.w),a3
	bra.s	L7E
LF0	rts
LF2	cmpi.b	#2,$30(a3)
	beq.s	M0C
	cmpi.b	#4,$30(a3)
	bne.s	M0E
	movea.l	$40(a3),a0
	bsr	SF2
	bne.s	M0E
M0C	rts
M0E	lea	JE4A(pc),a0
	bsr	BA3E
	bne.s	M0C
	cmpi.b	#4,$30(a3)
	bne.s	M32
	movea.l	$40(a3),a0
	bsr	RC6
	bsr	P16
	bsr	R86
	bra.s	M36
M32	move.l	d2,$34(a3)
M36	bra	WCA8
M3A	cmpi.b	#4,$30(a3)
	bne.s	M4C
	lea	JE60(pc),a0
	bsr	BA3E
	beq.s	M4E
M4C	rts
M4E	move.l	d2,-(a7)
	movea.l	$40(a3),a0
	bsr	RC6
	bsr	P1A
	move.l	(a7)+,d2
	addq.l	#1,d2
	bne.s	M70
	move.w	$22(a0),d2
	sub.w	2(a3),d2
	addq.w	#2,d2
	bsr	P1A
M70	bsr	R86
	bra	WCA8
M78	moveq	#$40,d1
	bra.s	M80
M7C	move.b	#$80,d1
M80	tst.w	$728(a6)
	bne.s	M9A
	move.b	$38(a3),d2
	cmp.b	#1,d2
	beq.s	M9A
	move.w	$F0(a6),d0
	bsr	N54
	bpl.s	M9C
M9A	rts
M9C	move.w	d0,$F0(a6)
	bsr	N7C
	lea	ME2(pc),a0
	bsr	MB0
	lea	MF8(pc),a0
MB0	lea	$610(a6),a3
	moveq	#3,d2
MB6	rol.w	#4,d0
	rol.w	#4,d1
	movem.w	d0-d1,-(a7)
	andi.w	#$F,d0
	andi.w	#$F,d1
	cmp.w	d0,d1
	beq.s	MD4
	movem.l	d2/a0,-(a7)
	jsr	(a0)
	movem.l	(a7)+,d2/a0
MD4	lea	$46(a3),a3
	movem.w	(a7)+,d0-d1
	dbf	d2,MB6
ME0	rts
ME2	tst.b	d1
	beq.s	ME0
	bsr	OC34
	sf	d4
	sf	d7
	bsr	SCEA
	clr.w	0(a3)
	rts
MF8	tst.b	d0
	beq.s	ME0
	bsr	N10
	bsr	NCFE
N04	movea.l	$40(a3),a0
	bsr	Q20
	bra	WCA8
N10	move.w	$F6(a6),d1
	btst	#3,d0
	bne.s	N1E
	move.w	$F8(a6),d1
N1E	move.w	d1,-(a7)
	move.w	$F2(a6),d1
	btst	#1,d0
	bne.s	N2E
	move.w	$F4(a6),d1
N2E	movem.w	d0-d1,-(a7)
	andi.w	#3,d0
	asl.w	#1,d0
	addi.w	#$FA,d0
	move.w	-2(a6,d0.w),d2
	moveq	#$C,d0
	and.w	(a7)+,d0
	asr.w	#1,d0
	addi.w	#$100,d0
	move.w	-2(a6,d0.w),d3
	movem.w	(a7)+,d0-d1
	rts
N54	move.l	d2,-(a7)
	bsr	N7C
	subq.b	#2,d2
	asl.b	#4,d2
	or.b	d1,d2
	move.w	d0,d1
N62	move.w	#$F0,d0
	and.b	(a0)+,d0
	beq.s	N74
	cmp.b	d2,d0
	bne.s	N62
	moveq	#$F,d0
	and.b	-(a0),d0
	bra.s	N76
N74	moveq	#-1,d0
N76	movem.l	(a7)+,d2
	rts
N7C	mulu.w	#6,d0
	addi.l	#J76,d0
	movea.l	d0,a1
	movea.l	(a1)+,a0
	move.w	(a1),d0
	rts
N8E	tst.w	$728(a6)
	bne	O18
	move.b	$30(a3),d0
	cmp.b	#2,d0
	beq.s	O18
	cmp.b	#4,d0
	bne.s	NB0
	movea.l	$40(a3),a0
	tst.l	$1E(a0)
	beq.s	O18
NB0	move.l	a3,-(a7)
	moveq	#4,d3
	lea	KEAE(pc),a0
	bsr	BAD8
	movea.l	(a7),a0
	clr.b	(a4)
	tst.b	$3E(a0)
	beq.s	ND4
	movea.l	$40(a0),a0
	lea	$44(a0),a0
	movea.l	a4,a1
ND0	move.b	(a0)+,(a1)+
	bne.s	ND0
ND4	bsr	RC56
	beq.s	NE0
	bsr	VC2A
	bra.s	O16
NE0	moveq	#0,d0
	tst.b	(a4)
	beq.s	NFC
	movea.l	a4,a0
	movem.l	a3/a5,-(a7)
	bsr	JD3E
	movem.l	(a7)+,a3/a5
	beq.s	NFC
	bsr	VCDE
	bra.s	ND4
NFC	bsr	VC2A
	movea.l	(a7),a3
	st	d7
	bsr	O1A
	tst.b	$3E(a3)
	beq.s	O16
	bsr	O66
	bsr	WC68
O16	movea.l	(a7)+,a3
O18	rts
O1A	move.w	d7,-(a7)
	sf	d4
	sf	d7
	bsr	SCEA
	move.w	(a7)+,d7
	sf	$3E(a3)
	tst.b	(a4)
	beq.s	O60
	move.b	#1,$3E(a3)
	movea.l	$40(a3),a1
	lea	$44(a1),a0
	moveq	#$3F,d0
O3E	move.b	(a4)+,(a0)+
	dbeq	d0,O3E
	clr.b	-(a0)
	move.l	$44(a1),d0
	andi.l	#$DFDFFF00,d0
	cmp.l	#$70630000,d0
	bne.s	O60
	move.l	d0,$44(a1)
	st	$3E(a3)
O60	st	d4
	bra	SCEA
O66	move.l	a3,-(a7)
	lea	$6E2(a6),a3
	moveq	#4,d0
O6E	move.l	d0,-(a7)
	bsr	RC6
	move.l	$40(a3),d0
O78	movea.l	d0,a0
	move.l	(a0),d0
	bne.s	O78
O7E	tst.b	9(a0)
	beq.s	OB8
	bpl.s	O8E
	cmpi.b	#3,8(a0)
	beq.s	OD6
O8E	bsr	SF2
	movem.l	d3/a0-a5,-(a7)
	lea	$44(a0),a4
	bsr	JD76
	movem.l	(a7)+,d3/a0-a5
	bne.s	OB8
	move.l	d2,d1
	cmpi.b	#4,8(a0)
	bne.s	OB4
	bsr	P16
	bra.s	OB8
OB4	move.l	d1,$A(a0)
OB8	movea.l	4(a0),a0
	move.l	a0,d0
	bne.s	O7E
	movea.l	$40(a3),a0
	bsr	R86
	lea	-$46(a3),a3
	move.l	(a7)+,d0
	dbf	d0,O6E
	movea.l	(a7)+,a3
	rts
OD6	movem.l	d0/d3/d6/a0-a2,-(a7)
	movea.l	$54(a6),a1
	move.l	$A(a0),d0
	addq.l	#1,d0
	andi.b	#$FE,d0
	movea.l	d0,a2
	cmpa.l	a2,a1
	blt.s	P06
	move.w	2(a3),d6
	subq.w	#3,d6
	bcs.s	P06
	move.l	a1,-(a7)
OF8	bsr	HD6A
	cmpa.l	(a7),a2
	beq.s	P0E
	dbf	d6,OF8
	movea.l	(a7)+,a1
P06	move.l	a1,d1
	movem.l	(a7)+,d0/d3/d6/a0-a2
	bra.s	OB4
P0E	movea.l	(a7)+,a1
	movem.l	(a7)+,d0/d3/d6/a0-a2
	bra.s	OB8
P16	bsr	MDAC
P1A	move.l	d2,d1
	beq.s	P4C
	movem.l	a0-a2,-(a7)
	cmp.l	#$FFFF,d1
	bls.s	P2C
	moveq	#-1,d1
P2C	movem.l	$12(a0),a1-a2
	move.w	$22(a0),d0
	movea.l	$E(a0),a0
	bsr	P4E
	move.l	a0,d2
	movem.l	(a7)+,a0-a2
	move.w	d1,$22(a0)
	move.l	d2,$E(a0)
P4C	rts
P4E	cmp.w	#1,d1
	bhi.s	P5A
P54	moveq	#1,d1
	movea.l	a1,a0
	rts
P5A	sub.w	d1,d0
	bcs.s	P76
	beq.s	P74
	subq.w	#1,d0
P62	cmpi.b	#$A,-(a0)
	bne.s	P62
	dbf	d0,P62
P6C	cmpi.b	#$A,-(a0)
	bne.s	P6C
	addq.l	#1,a0
P74	rts
P76	neg.w	d0
	subq.w	#1,d0
P7A	cmpi.b	#$A,(a0)+
	bne.s	P7A
	cmpa.l	a2,a0
	dbcc	d0,P7A
	bcs.s	P74
	sub.w	d0,d1
	subq.w	#1,d1
	cmp.w	#1,d1
	bls.s	P54
	subq.l	#1,a0
	bra.s	P6C
	bsr	RC6
	movea.l	$40(a3),a0
	bsr	RFE
	bne	Q24
	bra	VCDE
	cmpi.b	#4,$30(a3)
	bne.s	PBA
	sf	d4
	sf	d7
	bsr	SCEA
PBA	movea.l	$40(a3),a0
	bsr	S66
	bne	Q30
	cmpi.b	#4,$30(a3)
	beq.s	PD0
	rts
PD0	movea.l	$40(a3),a0
	bsr	SCC
	moveq	#3,d1
	cmpi.b	#1,$38(a3)
	bne.s	PE4
	moveq	#2,d1
PE4	bra	R7E
	movea.l	$40(a3),a0
	move.l	4(a0),d0
	beq.s	PF6
	movea.l	d0,a0
	bra.s	Q20
PF6	move.l	(a0),d0
	bne.s	PFC
	rts
PFC	movea.l	d0,a0
	move.l	(a0),d0
	bne.s	PFC
	bra.s	Q20
	movea.l	$40(a3),a0
	move.l	(a0),d0
	beq.s	Q10
	movea.l	d0,a0
	bra.s	Q20
Q10	move.l	4(a0),d0
	bne.s	Q18
	rts
Q18	movea.l	d0,a0
	move.l	4(a0),d0
	bne.s	Q18
Q20	bsr	RC6
Q24	move.l	a0,-(a7)
	sf	d4
	sf	d7
	bsr	SCEA
	movea.l	(a7)+,a0
Q30	move.l	a0,-(a7)
	cmpi.b	#3,8(a0)
	bcc.s	Q3E
	bsr	OC34
Q3E	movea.l	(a7)+,a0
	moveq	#-1,d0
	movea.l	a0,a1
Q44	addq.l	#1,d0
	move.l	(a1),d1
	movea.l	d1,a1
	bne.s	Q44
	move.w	d0,$44(a3)
	bsr	R86
	st	d4
	cmpa.l	$DE(a6),a3
	seq	d7
	bsr	SCEA
	bra	WCA8
	move.b	$38(a3),d0
	bsr	T28
	beq.s	Q78
	lea	JE8F(pc),a0
	bsr	ZB86
	beq.s	Q7A
Q78	rts
Q7A	lea	$AB4(a6),a0
	bsr	R14
	movea.l	$DE(a6),a3
	lea	$AB4(a6),a0
	bsr	Q90
	bra.s	Q24
Q90	move.l	a0,-(a7)
	bsr	RC6
	movea.l	$40(a3),a0
	tst.l	$12(a0)
	beq.s	QAA
	bsr	RFE
	bne.s	QAA
	bsr	SCC
QAA	movea.l	(a7)+,a1
	bsr	S8C
	tst.l	$1E(a0)
	beq.s	QCA
	st	9(a0)
	move.l	#$70630000,$44(a0)
	move.l	$54(a6),d2
	bsr	P16
QCA	rts
QCC	tst.b	$585(a6)
	beq.s	QD8
	move.l	$578(a6),d0
	bne.s	QDA
QD8	rts
QDA	movea.l	d0,a0
	lea	4(a0),a0
	move.l	a0,-(a7)
	bsr	R04
	movea.l	(a7)+,a0
	bne.s	QD8
	lea	$69C(a6),a3
	bsr.s	Q90
	tst.w	0(a3)
	bne	Q24
	bsr	R86
	move.b	#$C0,d1
	bra	M80
R04	move.l	a0,-(a7)
	movea.l	a0,a5
	moveq	#0,d2
	bsr	ZBA4
	movea.l	(a7)+,a0
	beq.s	R14
	rts
R14	move.l	a3,$156(a6)
	adda.l	d4,a3
	move.l	a3,$15A(a6)
	bsr	AE36
	beq.s	R30
	move.l	d0,$57C(a6)
	move.l	a0,$580(a6)
	moveq	#0,d0
	rts
R30	clr.l	$57C(a6)
	clr.l	$580(a6)
	rts
R3A	tst.w	$728(a6)
	bne.s	R50
	move.b	$30(a3),d1
	move.b	$38(a3),d0
	bsr	T28
	bne	R52
R50	rts
R52	movea.l	$40(a3),a0
R56	addq.b	#1,d1
	cmp.b	#4,d1
	bls.s	R60
	moveq	#1,d1
R60	cmp.b	#2,d1
	bne.s	R6E
	cmp.b	#1,d0
	bne.s	R56
	beq.s	R7A
R6E	cmp.b	#4,d1
	bne.s	R7A
	tst.l	$12(a0)
	beq.s	R56
R7A	bsr	RC6
R7E	move.b	d1,8(a0)
	bra	Q24
R86	move.l	a0,$40(a3)
	move.b	8(a0),$30(a3)
	bsr	VC5C
	movea.l	$40(a3),a0
	bsr	SF2
	move.l	$A(a0),$34(a3)
	move.b	9(a0),$3E(a3)
	move.b	8(a0),d0
	cmp.b	#4,d0
	bne.s	RC4
	move.l	$E(a0),$34(a3)
	move.w	$22(a0),$32(a3)
	move.b	$24(a0),$31(a3)
RC4	rts
RC6	move.l	a0,-(a7)
	movea.l	$40(a3),a0
	move.b	$3E(a3),9(a0)
	move.b	$30(a3),d0
	move.b	d0,8(a0)
	cmp.b	#4,d0
	beq.s	RE8
	move.l	$34(a3),$A(a0)
	bra.s	RFA
RE8	move.l	$34(a3),$E(a0)
	move.w	$32(a3),$22(a0)
	move.b	$31(a3),$24(a0)
RFA	movea.l	(a7)+,a0
	rts
RFE	move.l	a0,-(a7)
	move.l	#$84,d0
	bsr	FE6A
	movea.l	(a7)+,a1
	beq.s	S64
	movea.l	a0,a2
	move.l	#$83,d0
S16	clr.b	(a2)+
	dbf	d0,S16
	move.b	A6A,d0
	move.l	a1,(a0)
	beq.s	S5A
	movea.l	4(a1),a2
	move.l	a0,4(a1)
	move.l	a2,4(a0)
	beq.s	S36
	move.l	a0,(a2)
S36	move.b	8(a1),d1
	moveq	#3,d0
	cmp.b	#4,d1
	beq.s	S4C
	moveq	#1,d0
	cmp.b	#2,d1
	beq.s	S4C
	move.b	d1,d0
S4C	move.b	d0,8(a0)
	move.l	$A(a1),$A(a0)
	move.b	$24(a1),d0
S5A	move.b	d0,$24(a0)
	move.w	#1,$22(a0)
S64	rts
S66	movem.l	(a0),a1-a2
	move.l	a1,d0
	beq.s	S76
	move.l	a2,4(a1)
	bne.s	S7A
	bra.s	S7C
S76	move.l	a2,d0
	beq.s	S8A
S7A	move.l	a1,(a2)
S7C	move.l	d0,-(a7)
	bsr	SCC
	bsr	FE94
	movea.l	(a7)+,a0
	moveq	#1,d1
S8A	rts
S8C	move.l	a0,-(a7)
	movea.l	a1,a0
	bsr	T10
	movea.l	(a7),a1
	lea	$25(a1),a1
	moveq	#$1E,d0
S9C	move.b	(a0)+,(a1)+
	dbeq	d0,S9C
	clr.b	-(a1)
	movea.l	(a7)+,a0
	movea.l	$156(a6),a1
	move.l	a1,$12(a0)
	move.l	a1,$E(a0)
	move.l	$15A(a6),$16(a0)
	move.l	$580(a6),$1A(a0)
	move.l	$57C(a6),$1E(a0)
	move.b	#4,8(a0)
	rts
SCC	move.l	a0,-(a7)
	move.l	$12(a0),-(a7)
	movea.l	$1A(a0),a0
	bsr	FE94
	movea.l	(a7)+,a0
	bsr	FE94
	movea.l	(a7)+,a0
	clr.l	$12(a0)
	clr.l	$1E(a0)
	move.w	#1,$22(a0)
	rts
SF2	move.l	$12(a0),d0
	beq.s	T0E
	move.l	d0,$156(a6)
	move.l	$16(a0),$15A(a6)
	move.l	$1A(a0),$580(a6)
	move.l	$1E(a0),$57C(a6)
T0E	rts
T10	movea.l	a0,a1
T12	move.b	(a1)+,d0
	beq.s	T26
	cmp.b	#$3A,d0
	beq.s	T22
	cmp.b	#$2F,d0
	bne.s	T12
T22	movea.l	a1,a0
	bra.s	T12
T26	rts
T28	cmp.b	#3,d0
	beq.s	T32
	cmp.b	#5,d0
T32	rts
	move.l	a3,-(a7)
T36	moveq	#6,d3
	lea	KEC1(pc),a0
	bsr	BAD8
T40	bsr	RC56
	bne.s	TAC
	move.b	(a4)+,d1
	beq.s	TAC
	bsr	JD72
	beq.s	T56
	lea	$AB4(a6),a4
	bra.s	T40
T56	move.l	d2,d7
	bsr	BA2E
	bsr	BA2E
	moveq	#$3D,d1
	bsr	QC52
	moveq	#$24,d1
	bsr	QC52
	move.l	d7,d2
	bsr	IDA0
	moveq	#$12,d1
	bsr	ID60
	move.l	d7,d1
	bsr	IDE2
	move.l	d7,d0
	bsr	DE02
	beq.s	T96
	move.l	d0,-(a7)
	moveq	#$12,d1
	bsr	ID60
	move.l	(a7)+,d0
	moveq	#$20,d2
	bsr	ZDE2
T96	move.w	6(a3),d2
	moveq	#4,d3
	bsr	PC0A
	bsr	RB9A
	bmi.s	TAC
	cmp.b	#$20,d1
	beq.s	T36
TAC	bsr	VC2A
	movea.l	(a7)+,a3
	rts

TB4	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0

TF8	move.l	(a7),NE76
	move.l	#VEC,(a7)
	suba.l	a1,a1
	movea.l	4.w,a6
	jsr	-$126(a6)
	movea.l	d0,a4
	move.l	d0,NE70
	tst.l	$AC(a4)
	bne.s	U46
	move.l	#UAC,d1
	lsr.l	#2,d1
	move.l	d1,$AC(a4)
	movea.l	NE6C(pc),a0
	move.l	$98(a0),$98(a4)
	move.l	$9C(a0),$9C(a4)
	move.l	$A0(a0),$A0(a4)
	lea	4(a7),a1
	move.l	a1,$B0(a4)
U46	move.l	#VF4,$32(a4)
	moveq	#-1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$14A(a6)
	movea.l	(a7)+,a6
	move.b	d0,NE0A
	move.l	NE0C(pc),d0
	lsl.l	#2,d0
	addq.l	#4,d0
	move.l	d0,-(a7)
	movea.l	d0,a0
	move.l	NE10,(a0)
	move.w	NE14,4(a0)
	moveq	#6,d0
	bsr	OBA8
	lea	UEC(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	#$ABCDABCD,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	movea.l	d1,a1
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6
	rts

	dc.w	0
UAC	ds.w	8
UBC	ds.w	22
UE8	ds.w	2
UEC	ds.w	128

VEC	st	NE0B

VF2	illegal
VF4	move.l	d0,NE2C
	move.l	(a7)+,d0
	cmp.b	#9,d0
	bne.s	W16
	cmpi.l	#VEC,2(a7)
	bne.s	W16
	move.l	NE2C(pc),d0
	bclr	#7,(a7)
	rte
W16	cmp.l	#4,d0
	bne.s	W52
	cmpi.l	#Y94,2(a7)
	beq.s	W36
	cmpi.l	#VF2,2(a7)
	bne.s	W52
	moveq	#$1D,d0
	bra.s	W52
W36	tst.b	NE1C
	beq.s	W42
	dc.w	$f37a,$7976		; frestore NEB6(pc)

W42	move.l	NE2C(pc),d0
	move.w	NE26(pc),(a7)
	move.l	NE22(pc),2(a7)
	rte

W52	move.l	d0,NE1E
W58	jmp	W5E

W5E	cmp.l	#3,d0
	bgt.s	W9E
	bne.s	W9C
	btst	#0,$D(a7)
	bne.s	W9C
	move.w	6(a7),d0
	move.l	a0,-(a7)
	movea.l	$E(a7),a0
	addq.l	#2,a0
	cmp.w	-(a0),d0
	beq.s	W94
	cmp.w	-(a0),d0
	beq.s	W94
	cmp.w	-(a0),d0
	beq.s	W94
	cmp.w	-(a0),d0
	beq.s	W94
	cmp.w	-(a0),d0
	beq.s	W94
	movea.l	$E(a7),a0
W94	move.l	a0,$E(a7)
	movea.l	(a7)+,a0
	moveq	#3,d0
W9C	addq.l	#8,a7
W9E	move.w	(a7),NE26
	bclr	#7,(a7)
	move.l	2(a7),NE22
	move.l	a7,NE28
	move.l	#Y24,2(a7)
	rte
WC0	move.w	(a7)+,NE26
	move.l	(a7)+,NE22
	cmp.l	#9,d0
	movem.w	(a7)+,d0
WD6	beq	Y1E
	andi.w	#$F000,d0
	beq.s	X1C
	cmp.w	#$1000,d0
	beq.s	X1C
	cmp.w	#$2000,d0
	beq.s	X16
	cmp.w	#$8000,d0
	beq.s	X0A
	cmp.w	#$9000,d0
	beq.s	X16
	cmp.w	#$A000,d0
	beq.s	X10
	cmp.w	#$B000,d0
	bne.s	X1C
	lea	$54(a7),a7
	bra.s	X1C
X0A	lea	$32(a7),a7
	bra.s	X1C
X10	lea	$18(a7),a7
	bra.s	X1C
X16	move.l	(a7)+,NE22
X1C	move.l	a0,-(a7)
	tst.b	NE1C
	beq.s	X58
	lea	NEB6(pc),a0
	dc.w	$f328,$0000		; fsave	0(a0)
	tst.b	0(a0)
	beq.s	X58
	moveq	#0,d0
	move.b	1(a0),d0
	cmp.b	#$18,d0
	beq.s	X46
	cmp.b	#$38,d0
	bne.s	X4C
X46	bset	#3,0(a0,d0.w)

X4C	dc.w	$f228,$f0ff,$00e4	; fmovem.x fp0-fp7,$E4(a0)
	dc.w	$f228,$bc00,$00d8	; fmovem.l fpcr/fpsr/fpiar,$D8(a0)

X58	move.l	d1,-(a7)
	movea.l	4.w,a0
	move.w	$128(a0),d1
	lea	NE7A(pc),a0
	movec	sfc,d0
	move.l	d0,(a0)+
	movec	dfc,d0
	move.l	d0,(a0)+
	movec	vbr,d0
	move.l	d0,(a0)+
	btst	#1,d1
	beq.s	XFA
	movec	msp,d0
	move.l	d0,(a0)+
	movec	isp,d0
	move.l	d0,(a0)+
	movec	cacr,d0
	move.l	d0,(a0)+
	btst	#3,d1
	bne.s	XC6
	movec	caar,d0
	move.l	d0,(a0)+
	btst	#2,d1
	beq.s	XFA
	dc.w	$f010,$6200		; pmove.w	psr,(a0)
	dc.w	$f028,$4200,$0002	; pmove.l	tc,2(a0)
	dc.w	$f028,$0a00,$0006	; pmove.l	tt0,6(a0)
	dc.w	$f028,$0e00,$000a	; pmove.l	tt1,$A(a0)
	dc.w	$f028,$4e00,$000e	; pmove.d	crp,$E(a0)
	dc.w	$f028,$4a00,$0016	; pmove.d	srp,$16(a0)
	bra.s	XFA

XC6	lea	NE96(pc),a0

	dc.w	$4e7a,$0805		; movec	mmusr,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0003		; movec	tc,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0004		; movec	itt0,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0005		; movec	itt1,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0006		; movec	dtt0,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0007		; movec	dtt1,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0807		; movec	srp,d0
	move.l	d0,(a0)+

	dc.w	$4e7a,$0806		; movec	urp,d0
	move.l	d0,(a0)+

XFA	movem.l	(a7)+,d1/a0
	move.w	#$10,-(a7)
	move.l	#Y24,-(a7)
	move.w	NE26(pc),d0
	bclr	#$F,d0
	move.w	d0,-(a7)
	move.l	a7,d0
	addq.l	#8,d0
	move.l	d0,NE28
	rte
Y1E	addq.l	#4,a7
	bra	X1C
Y24	movem.l	d1-d7/a0-a7,NE30
	cmpi.l	#$1D,NE1E
	bne.s	Y40
	move.l	NE76(pc),NE22
Y40	movea.l	NE6C(pc),a1
	moveq	#0,d0
	move.b	NE74(pc),d1
	bset	d1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$144(a6)
	movea.l	(a7)+,a6
	cmpi.l	#$1D,NE1E
	beq.s	Y8E
	moveq	#0,d0
	move.b	NE0A(pc),d1
	bset	d1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$13E(a6)
	movea.l	(a7)+,a6
	moveq	#0,d0
	moveq	#0,d1
	move.b	NE0A(pc),d2
	bset	d2,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
Y8E	movem.l	NE2C(pc),d0-d7/a0-a7
Y94	dc.w	$4AFC
Y96	dc.w	$1002,$F03,$A04,$305
	dc.w	$406,$507,$608,$709
	dc.w	$1F0A,$200B,$330D,$340E
	dc.w	$818,$1D1D,$2C30,$2D31
	dc.w	$2E32,$2F33,$3034,$3135
	dc.w	$3236,$3538,0
YC4	movem.l	NE2C(pc),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,$10(a6)
	movem.l	NE64(pc),d0-d1
	movem.l	d0-d1,$48(a6)
	movea.l	NE22(pc),a1
	move.l	a1,$54(a6)
	move.l	NE28(pc),$50(a6)
	move.w	NE26,$5A(a6)
	move.l	NE1E(pc),d1
	st	$134(a6)
	cmp.b	#4,d1
	beq	ZC0
	cmp.b	#9,d1
	beq	Z6A
	cmp.b	#$1D,d1
	bne.s	Z1A
	sf	$134(a6)
	clr.b	NE0B
Z1A	lea	Y96(pc),a0
	moveq	#0,d0
Z20	move.b	(a0)+,d0
	beq.s	Z2C
	cmp.b	(a0)+,d1
	bne.s	Z20
	move.l	d0,d1
	bra.s	Z2E
Z2C	moveq	#$1E,d1
Z2E	clr.l	$3D8(a6)
	clr.b	$14A(a6)
	move.l	$DE(a6),-(a7)
	move.w	d1,-(a7)
	bsr	O66
	bsr	VCF8
	bsr	WC68
	bsr	F90
	move.w	(a7)+,d1
	cmp.w	#$1D,d1
	bne.s	Z5C
	tst.b	$162(a6)
	bne	UBDC
Z5C	bsr	ID60
	st	$E5(a6)
	move.l	(a7)+,$DE(a6)
	rts
Z6A	bsr	PBEA
	moveq	#7,d1
	tst.l	$3D8(a6)
	bne	Z8E
Z78	move.b	$14A(a6),d0
	beq.s	Z2E
	bra.s	Z84
Z80	moveq	#$B,d1
	bra.s	Z2E
Z84	subq.l	#1,$194(a6)
	beq.s	Z80
	bra	AAA6
Z8E	moveq	#0,d3
	movea.l	$3D8(a6),a0
	clr.l	$3D8(a6)
	movea.l	(a0),a1
	move.w	#$4AFC,(a1)
	bsr	OB9E
	move.w	$5A(a6),d0
	andi.w	#$7FFF,d0
	or.w	$3DC(a6),d0
	move.w	d0,$5A(a6)
	bpl	AA90
	tst.b	$14A(a6)
	beq	Z2E
	bra.s	Z78
ZC0	pea	$55E(a6)
	cmpa.l	(a7)+,a1
	beq.s	AA3C
	cmpa.l	$564(a6),a1
	beq	AA50
	st	$567(a6)
	bsr	OB3A
	bne.s	AA36
	movem.l	a0-a1,-(a7)
	bsr	PBEA
	movem.l	(a7)+,a0-a1
	move.w	6(a0),d0
	cmp.w	#3,d0
	beq.s	AA30
	cmp.w	#1,d0
	beq.s	AA1E
	cmp.w	#2,d0
	beq.s	AA18
	lea	$C(a0),a4
	movem.l	a0-a1,-(a7)
	bsr	JD76
	movem.l	(a7)+,a0-a1
	bne.s	AA4C
	tst.b	d1
	bne.s	AA4C
	tst.l	d2
	beq.s	AA4C
	bra.s	AA24
AA18	addq.l	#1,8(a0)
	bra.s	AA4C
AA1E	subq.l	#1,8(a0)
	bne.s	AA4C
AA24	move.w	4(a0),(a1)
	bsr	OB9E
	clr.w	6(a0)
AA30	moveq	#$B,d1
	bra	Z2E
AA36	moveq	#$A,d1
	bra	Z2E
AA3C	move.l	$560(a6),$54(a6)
	bsr	PBEA
	moveq	#7,d1
	bra	Z2E
AA4C	moveq	#0,d3
	bra.s	AA74
AA50	move.w	$568(a6),(a1)
	bsr	OB9E
	moveq	#-$2A,d0
	move.l	d0,$564(a6)
	movea.l	$56C(a6),a0
	movea.l	0(a0),a1
	move.w	#$4AFC,(a1)
	bsr	OB9E
	bsr	PBEA
	st	d3
AA74	btst	#0,$57(a6)
	bne.s	AA90
	movea.l	$54(a6),a2
	bsr	RD6C
	bne.s	AA90
	movea.l	a2,a1
	bsr	OB3A
	beq	BA08
AA90	tst.b	d3
	beq.s	AAA6
	move.l	a3,-(a7)
	bsr	F90
	moveq	#$25,d1
	bsr	ID60
	st	$E5(a6)
	movea.l	(a7)+,a3
AAA6	movem.l	$10(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,NE2C
	movem.l	$48(a6),d0-d1
	movem.l	d0-d1,NE64
	move.l	$54(a6),NE22
	move.w	$5A(a6),NE26
	moveq	#0,d0
	moveq	#0,d1
	move.b	NE74(pc),d2
	bset	d2,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
	movea.l	NE70(pc),a1
	moveq	#0,d0
	move.b	NE0A(pc),d1
	bset	d1,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$144(a6)
	movea.l	(a7)+,a6
	move.b	#1,$134(a6)
	rts
BA08	move.w	$5A(a6),d0
	andi.w	#$8000,d0
	move.w	d0,$3DC(a6)
	move.l	a0,$3D8(a6)
	move.w	4(a0),(a1)
	bsr	OB9E
	bset	#7,$5A(a6)
	bra	AA90
BA2A	pea	BA2E(pc)
BA2E	move.w	#4,6(a3)
	move.w	$D8(a6),d0
	add.w	d0,8(a3)
	rts
BA3E	move.l	a3,-(a7)
	move.l	a0,-(a7)
	moveq	#4,d3
	bsr.s	BA98
	movea.l	(a7)+,a0
	bsr	ID70
	move.w	#4,6(a3)
	move.w	$D8(a6),d0
	add.w	d0,8(a3)
	lea	$AB4(a6),a4
	clr.b	(a4)
	moveq	#0,d4
BA62	bsr	RC56
	bne.s	BA8E
	tst.b	(a4)
	beq.s	BA8E
	bsr	JD76
	bne.s	BA76
	tst.b	d1
	beq.s	BA80
BA76	bsr	VCDE
	lea	$AB4(a6),a4
	bra.s	BA62
BA80	move.l	d2,-(a7)
	bsr	VC2A
	move.l	(a7)+,d2
	movea.l	(a7)+,a3
	moveq	#0,d0
	rts
BA8E	bsr	VC2A
	movea.l	(a7)+,a3
	moveq	#-1,d2
	rts
BA98	moveq	#8,d2
	add.w	$E2(a6),d2
	lea	JE38(pc),a2
BAA2	movem.w	$84E(a6),d0-d1/d4
	add.w	$84A(a6),d0
	add.w	$84A(a6),d0
	sub.w	d2,d0
	lsr.w	#1,d0
	sub.w	d3,d1
	mulu.w	$D8(a6),d1
	lea	$76E(a6),a3
	clr.b	$38(a3)
	bsr	SCB2
	sf	$10(a3)
	move.w	#4,6(a3)
	move.w	$D8(a6),8(a3)
	rts
BAD8	move.l	a0,-(a7)
	bsr.s	BA98
	movea.l	(a7)+,a0
	bsr	ID70
	bsr	BA2E
	lea	$AB4(a6),a4
	clr.b	(a4)
	moveq	#0,d4
	rts
BAF0	move.l	a1,-(a7)
	move.l	a0,-(a7)
	movem.w	$84E(a6),d0-d1/d4
	moveq	#$1E,d2
	moveq	#5,d3
	lea	JE7C(pc),a2
	bsr.s	BAA2
	movea.l	(a7)+,a0
	bsr.s	CA14
	move.w	$D8(a6),d0
	add.w	d0,d0
	add.w	d0,8(a3)
	movea.l	(a7)+,a0
CA14	move.l	a0,-(a7)
	movea.l	a0,a1
CA18	tst.b	(a0)+
	bne.s	CA18
	lea	$1E(a1),a1
	suba.l	a0,a1
	move.w	a1,d0
	lsr.w	#1,d0
	move.w	d0,6(a3)
	movea.l	(a7)+,a0
	bra	ID70
CA30	move.l	a3,-(a7)
	lea	JE73(pc),a1
	bsr.s	BAF0
CA38	bsr	RB9A
	bmi.s	CA38
	cmp.b	#$1B,d1
	beq.s	CA4A
	cmp.b	#$A,d1
	bne.s	CA38
CA4A	bsr	VC2A
	movea.l	(a7)+,a3
	rts
CA52	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
CA5E	move.l	a4,-(a7)
	lea	ME0E(pc),a4
	moveq	#0,d1
	move.w	d0,d1
	lea	CA7E(pc),a2
	bsr	IDE6
	clr.b	(a4)+
	movea.l	(a7)+,a4
	bsr	VCF8
	lea	LEFF(pc),a0
	bra.s	CA30
CA7E	move.b	d1,(a4)+
	rts
CA82	lea	KE4D(pc),a1
	bsr	BAF0
CA8A	bsr	RB9A
	bmi.s	CA8A
	andi.b	#$DF,d1
	cmp.b	#$59,d1
	beq.s	CAA4
	cmp.b	#$4E,d1
	beq.s	CAA4
	cmp.b	#$1B,d1
CAA4	move.w	d1,-(a7)
	bsr	VC2A
	move.w	(a7)+,d1
	cmp.b	#$59,d1
	rts
CAB2	tst.l	d1
	bpl.s	CAFA
	neg.l	d1
	move.b	#$2D,(a4)+
	bra.s	CAFA
CABE	tst.b	d1
	bpl.s	CAC8
	move.b	#$2D,(a4)+
	neg.b	d1
CAC8	andi.l	#$FF,d1
	bra.s	CAFA
CAD0	tst.w	d1
	bpl.s	CADA
	move.b	#$2D,(a4)+
	neg.w	d1
CADA	andi.l	#$FFFF,d1
	bra.s	CAFA
CAE2	move.l	d1,d0
	bsr	DE84
	beq.s	CAFA
	tst.b	$592(a6)
	beq	ZDFA
	move.b	#$7B,(a4)+
	bra	ZDFA
CAFA	cmp.l	#$A,d1
	bcc.s	DA14
	addi.b	#$30,d1
	move.b	d1,(a4)+
	rts
DA0A	move.l	d2,-(a7)
	st	d2
	swap	d1
	moveq	#3,d0
	bra.s	DA1E
DA14	move.b	#$24,(a4)+
DA18	move.l	d2,-(a7)
	moveq	#0,d2
	moveq	#7,d0
DA1E	rol.l	#4,d1
	move.w	d1,-(a7)
	andi.b	#$F,d1
	bne.s	DA2C
	tst.b	d2
	beq.s	DA3C
DA2C	st	d2
	cmp.b	#9,d1
	ble.s	DA36
	addq.b	#7,d1
DA36	addi.b	#$30,d1
	move.b	d1,(a4)+
DA3C	move.w	(a7)+,d1
	dbf	d0,DA1E
	move.l	(a7)+,d2
	rts
DA46	lea	DA60(pc),a0
	rol.l	#1,d1
	move.b	0(a0,d1.w),(a4)+
	move.b	1(a0,d1.w),d0
	beq.s	DA58
	move.b	d0,(a4)+
DA58	ror.l	#1,d1
	move.b	#$20,(a4)+
	rts

DA60	dc.b	't',0,'f',0,'hilscccsneeq'
	dc.b	'vcvsplmigeltgtle'

DA80	lea	DA94(pc),a0
	ext.w	d5
	move.b	#$2E,(a4)+
	move.b	0(a0,d5.w),(a4)+
	move.b	#$20,(a4)+
	rts

DA94	dc.b	'bwl?d',0

DA9A	lea	DAB6(pc),a0
	ext.w	d1
	rol.l	#2,d1
	move.b	0(a0,d1.w),(a4)+
	move.b	1(a0,d1.w),(a4)+
	move.b	2(a0,d1.w),(a4)+
	move.b	#$20,(a4)+
	ror.l	#2,d1
	rts

DAB6	dc.b	'tst chg clr set '

DAC6	andi.b	#7,d1
DACA	addi.b	#$30,d1
	move.b	d1,(a4)+
	rts

DAD2	move.w	(a5)+,d7
	clr.b	$14C(a6)
DAD8	lea	GBF8(pc),a0
	clr.l	d0
DADE	addq.l	#1,d0
	move.w	d7,d2
	and.w	(a0)+,d2
	cmp.w	(a0)+,d2
	bne.s	DADE
	moveq	#0,d1
	lea	IBB8(pc),a0
DAEE	move.b	(a0)+,d1
DAF0	subq.b	#1,d0
DAF2	beq.s	DAF8
	adda.l	d1,a0
	bra.s	DAEE
DAF8	move.b	(a0)+,d2
	lea	$988(a6),a4
	subq.b	#2,d1
	bcs.s	EA08
EA02	move.b	(a0)+,(a4)+
	dbf	d1,EA02
EA08	move.b	d2,d6
	bsr.s	EA2E
	move.b	#$A,(a4)+
	clr.l	d0
	rts
EA14	ext.w	d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	jmp	0(a0,d0.w)
EA20	clr.l	d0
	move.b	(a0)+,d0
EA24	subq.b	#1,d0
EA26	move.b	(a0)+,(a4)+
	dbf	d0,EA26
EA2C	rts
EA2E	lea	EA40(pc),a0
	move.b	d6,d0
	move.w	d7,d5
	andi.w	#$C0,d5
	lsr.w	#6,d5
	bsr.s	EA14
	rts
EA40	dc.w	$FFFE,$16EA,$7A,$D4
	dc.w	$128,$152,$176,$1E6
	dc.w	$1EC,$1F8,$208,$218
	dc.w	$232,$260,$270,$280
	dc.w	$348,$382,$3B0,$3CC
	dc.w	$3FA,$40E,$432,$496
	dc.w	$50E,$526,$16EA,$16EA
	dc.w	$582,$5C2,$662,$652
	dc.w	$6F4,$774,$77A,$93A
	dc.w	$994,$1EC,$99C,$9AC
	dc.w	$9BE,$14BE,$152A,$157E
	dc.w	$158E,$15BC,$15D2,$15E2
	dc.w	$15F4,$1606,$BC0,$A58
	dc.w	$ABC,$A48
	move.b	$1662(a2),d1
	move.b	(a2)+,(a3)
	move.b	d0,(a3)+
	move.b	d6,(a3)
	bset	d3,$8BA(a4)
	bsr	DA80
	move.b	#$23,(a4)+
	tst.b	d5
	bne.s	EACE
	move.w	(a5)+,d1
	bsr	CAC8
	bra.s	EAE2
EACE	cmp.b	#1,d5
	beq.s	EADC
	move.l	(a5)+,d1
	bsr	CAE2
	bra.s	EAE2
EADC	move.w	(a5)+,d1
	bsr	CADA
EAE2	move.b	#$2C,(a4)+
	move.b	d7,d0
	andi.b	#$3F,d0
	cmp.b	#$3C,d0
	bne.s	FA0E
	tst.b	d5
	bne.s	FA02
EAF6	lea	EAFE(pc),a0
	bra	EA20
EAFE	bchg	d1,-(a3)
	bls.s	FA74
FA02	lea	FA0A(pc),a0
	bra	EA20

FA0A	dc.b	2,'sr',0
FA0E	moveq	#$3d,d4
	bra	BB2C

	moveq	#$6C,d0
	btst	#6,d7
	bne.s	FA1E
	moveq	#$77,d0
FA1E	move.b	d0,(a4)+
	move.b	#$20,(a4)+
	move.b	d7,d2
	move.w	d7,d3
	lsr.w	#8,d3
	lsr.w	#1,d3
	lea	FA44(pc),a0
	lea	FA5E(pc),a1
	btst	#7,d7
	beq.s	FA3C
	exg	a0,a1
FA3C	jsr	(a0)
	move.b	#$2C,(a4)+
	jmp	(a1)
FA44	move.w	(a5)+,d1
	bsr	CAD0
FA4A	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	move.b	d2,d1
	bsr	DAC6
	move.b	#$29,(a4)+
	rts

FA5E	move.b	#$64,(a4)+
	move.b	d3,d1
	bra	DAC6
	move.b	d5,d1
	bsr	DA9A
	clr.b	d5
	move.b	#$64,(a4)+
FA74	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	bsr	DAC6
	move.b	#$2C,(a4)+
	moveq	#$3D,d4
	move.w	d7,d0
	andi.b	#$C0,d0
	bne.s	FA8E
	moveq	#-3,d4
FA8E	bra	BB2C
	move.b	d5,d1
	bsr	DA9A
	clr.b	d5
	move.b	#$23,(a4)+
	move.w	(a5)+,d1
	bsr	CAC8
	move.b	#$2C,(a4)+
	moveq	#$3D,d4
	move.w	d7,d0
	andi.b	#$C0,d0
	bne.s	FA8E
	moveq	#$7D,d4
	bra.s	FA8E
FAB6	move.w	d7,d5
	moveq	#$C,d0
	lsr.w	d0,d5
	andi.w	#3,d5
	move.b	GA22(pc,d5.w),d5
	move.w	d7,-(a7)
	moveq	#-1,d4
	bsr	BB2C
	move.w	(a7)+,d7
	move.b	$14B(a6),d0
	move.l	$14E(a6),$152(a6)
	sf	$14B(a6)
	move.w	d0,-(a7)
	move.b	#$2C,(a4)+
	move.w	d7,d1
	move.b	#9,d0
	lsr.w	d0,d1
	andi.w	#7,d1
	move.w	d7,d2
	lsr.w	#6,d2
	andi.w	#7,d2
	moveq	#$3F,d4
	bsr	BB3E
	move.w	(a7)+,d0
	tst.b	$14B(a6)
	beq.s	GA1C
	tst.b	d0
	beq.s	GA20
	st	$14C(a6)
	movem.l	$14E(a6),d0-d1
	exg	d0,d1
	movem.l	d0-d1,$14E(a6)
	rts
GA1C	move.b	d0,$14B(a6)
GA20	rts

GA22	dc.w	$0300,$0201
	move.w	(a5)+,d1
	bra	CADA

GA2C	andi.b	#7,d7
	addi.b	#$30,d7
	move.b	d7,(a4)+
	rts

	bsr.s	GA2C
	move.b	#$2C,(a4)+
	move.b	#$23,(a4)+
	move.w	(a5)+,d1
	bra	CAD0
	bsr.s	GA2C
	lea	GA52(pc),a0
	bra	EA20

GA52	dc.b	4,',usp '

	andi.w	#$F,d7
	cmp.b	#$A,d7
	bcs.s	GA6A
	move.b	#$31,(a4)+
	subi.b	#$A,d7
GA6A	addi.b	#$30,d7
	move.b	d7,(a4)+
	rts
	move.b	-(a4),d0
	cmp.b	#$2E,d0
	beq.s	GA82
	addq.l	#1,a4
	bsr	DA80
	bra.s	GA84
GA82	moveq	#2,d5
GA84	move.b	$988(a6),d0
	moveq	#$64,d4
	cmp.b	#$6A,d0
	beq	BB2C
	cmp.b	#$70,d0
	beq	BB2C
	moveq	#$3D,d4
	bra	BB2C
	moveq	#1,d5
	moveq	#-3,d4
	bsr	BB2C
	move.b	#$2C,(a4)+
	bra	EAF6
	moveq	#1,d5
	moveq	#-3,d4
	bsr	BB2C
	move.b	#$2C,(a4)+
	bra	FA02
	move.b	d7,d5
	lsr.b	#6,d5
	andi.b	#1,d5
	addq.b	#1,d5
	bsr	DA80
	move.w	(a5)+,-(a7)
	moveq	#$6C,d4
	bsr	BB2C
	move.b	#3,$14D(a6)
	move.w	(a7)+,d6
	move.b	#$2C,(a4)+
GAE2	moveq	#$F,d0
GAE4	roxl.w	#1,d6
	roxr.w	#1,d1
	dbf	d0,GAE4
GAEC	move.w	d1,d3
	ror.w	#8,d3
	move.b	#$64,d4
	bsr.s	HA08
	tst.b	d3
	beq.s	HA02
	tst.b	d1
	beq.s	HA02
	move.b	#$2F,(a4)+
HA02	move.w	d1,d3
	move.b	#$61,d4
HA08	tst.b	d3
	beq.s	HA4C
	moveq	#7,d0
HA0E	btst	d0,d3
	beq.s	HA80
	move.b	d4,(a4)+
	cmp.b	#$66,d4
	bne.s	HA1E
	move.b	#$70,(a4)+
HA1E	moveq	#$37,d6
	sub.b	d0,d6
	move.b	d6,(a4)+
	tst.b	d0
	beq.s	HA4C
	subq.b	#1,d0
	btst	d0,d3
	beq.s	HA7C
	tst.b	d0
	bne.s	HA4E
HA32	move.b	#$2D,(a4)+
	tst.b	$591(a6)
	beq.s	HA48
	move.b	d4,(a4)+
	cmp.b	#$66,d4
	bne.s	HA48
	move.b	#$70,(a4)+
HA48	move.b	#$37,(a4)+
HA4C	rts
HA4E	subq.b	#1,d0
	btst	d0,d3
	bne.s	HA76
	move.b	#$2D,(a4)+
	tst.b	$591(a6)
	beq.s	HA6A
	move.b	d4,(a4)+
	cmp.b	#$66,d4
	bne.s	HA6A
	move.b	#$70,(a4)+
HA6A	moveq	#$36,d6
	sub.b	d0,d6
	move.b	d6,(a4)+
	move.b	#$2F,(a4)+
	bra.s	HA80
HA76	tst.b	d0
	beq.s	HA32
	bra.s	HA4E
HA7C	move.b	#$2F,(a4)+
HA80	subq.b	#1,d0
	bcc.s	HA0E
	subq.l	#1,a4
	rts
	move.b	d7,d5
	lsr.b	#6,d5
	andi.b	#1,d5
	addq.b	#1,d5
	bsr	DA80
	move.w	(a5)+,d6
	move.w	d7,d2
	andi.b	#$38,d2
	cmp.b	#$20,d2
	bne.s	HABC
	move.w	d6,d1
	bsr	GAEC
HAAA	move.b	#$2C,(a4)+
	moveq	#$34,d4
	bsr	BB2C
	move.b	#3,$14D(a6)
	rts
HABC	bsr	GAE2
	bra.s	HAAA
	moveq	#1,d5
	btst	#7,d7
	bne.s	HACC
	moveq	#2,d5
HACC	bsr	DA80
	moveq	#1,d5
	moveq	#-3,d4
	bsr	BB2C
	lsr.w	#1,d7
	lsr.w	#8,d7
	andi.b	#7,d7
	addi.b	#$30,d7
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	move.b	d7,(a4)+
	rts
	moveq	#2,d5
	moveq	#$64,d4
	bsr	BB2C
	move.b	#9,d0
	move.w	d7,d1
	lsr.w	d0,d1
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
	bra	DAC6
	move.w	d7,d1
	lsr.w	#8,d1
	andi.b	#$F,d1
	bsr	DA46
	move.b	#$64,(a4)+
	andi.b	#7,d7
	addi.b	#$30,d7
	move.b	d7,(a4)+
IA26	move.b	#$2C,(a4)+
	move.l	a5,d1
	move.w	(a5)+,d2
	ext.l	d2
	add.l	d2,d1
	add.l	4(a6),d1
	bra	CAE2
	move.w	d7,d1
	lsr.w	#8,d1
	andi.w	#$F,d1
	bsr	DA46
	clr.b	d5
	moveq	#$3D,d4
	bra	BB2C
	bsr	DA80
	move.b	#$23,(a4)+
	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	andi.w	#7,d1
	bne.s	IA64
	moveq	#8,d1
IA64	bsr	DACA
	move.b	#$2C,(a4)+
	moveq	#$3F,d4
	bra	BB2C
IA72	move.w	d7,d0
	andi.w	#$F8,d0
	move.b	d7,d2
	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	cmp.b	#$40,d0
	beq.s	IA9C
	cmp.b	#$48,d0
	beq.s	IAB2
	cmp.b	#$88,d0
	beq.s	IAC4
	move.b	#$3F,(a4)+
	move.b	#$3F,(a4)+
	rts
IA9C	move.b	#$64,(a4)+
	bsr	DAC6
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
IAAC	move.b	d2,d1
	bra	DAC6
IAB2	move.b	#$61,(a4)+
	bsr	DAC6
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
	bra.s	IAAC
IAC4	move.b	#$64,(a4)+
	bsr	DAC6
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
	bra.s	IAAC
	move.w	d7,d1
	lsr.w	#8,d1
	andi.b	#$F,d1
	beq.s	IAEC
	cmp.b	#1,d1
	beq.s	IAF6
	bsr	DA46
	bra.s	IAFE
IAEC	subq.l	#1,a4
	move.l	#$62726120,(a4)+
	bra.s	IAFE
IAF6	subq.l	#1,a4
	move.l	#$62737220,(a4)+
IAFE	move.b	d7,d1
	beq.s	JA46
	cmp.b	#$FF,d1
	bne.s	JA1E
	move.b	#$2E,-1(a4)
	move.b	#$6C,(a4)+
	move.b	#$20,(a4)+
	move.l	(a5),d1
	add.l	a5,d1
	addq.w	#4,a5
	bra.s	JA32
JA1E	move.b	#$2E,-1(a4)
	move.b	#$73,(a4)+
	move.b	#$20,(a4)+
	ext.w	d1
	ext.l	d1
JA30	add.l	a5,d1
JA32	add.l	4(a6),d1
	bsr	CAE2
	tst.b	$592(a6)
	beq.s	JA44
	move.b	#$7D,(a4)+
JA44	rts
JA46	move.w	(a5)+,d1
	ext.l	d1
	subq.l	#2,d1
	bra.s	JA30
	move.b	d7,d1
	bsr	CABE
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	bra	DAC6
	moveq	#-1,d0
	cmpi.b	#$78,0(a4,d0.w)
	bne.s	JA74
	bsr	DA80
JA74	move.b	d7,d1
	move.w	d7,d2
	lsr.w	#8,d2
	lsr.w	#1,d2
	btst	#3,d7
	beq.s	JAA6
	move.b	#$2D,(a4)+
	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	bsr	DAC6
	lea	JABC(pc),a0
	bsr	EA20
	move.b	d2,d1
	bsr	DAC6
	move.b	#$29,(a4)+
	rts
JAA6	move.b	#$64,(a4)+
	bsr	DAC6
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	move.b	d2,d1
	bra	DAC6
JABC	btst	d2,$2C2D(a1)
	movea.l	-(a1),a4
	bsr	DA80
	cmp.b	#3,d5
	bne.s	JAD2
	lea	$988(a6),a4
	bra.s	KA02
JAD2	move.w	d7,d1
	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	bsr	DAC6
	lea	JAFC(pc),a0
	bsr	EA20
	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	bsr	DAC6
	move.b	#$29,(a4)+
	move.b	#$2B,(a4)+
	rts
JAFC	btst	d2,$2B2C(a1)
	movea.l	-(a1),a4
KA02	lea	KA14(pc),a0
	move.w	d7,d5
	lsr.w	#6,d5
	andi.b	#7,d5
	move.b	d5,d0
	bra	EA14
KA14	dc.w	$3A,$3A,$3A,$10
	dc.w	$5A,$5A,$5A,$10
	lsr.b	#2,d5
	andi.b	#1,d5
	addq.b	#1,d5
	move.l	#$636D7061,(a4)+
	bsr	DA80
	moveq	#-1,d4
	bsr	BB2C
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
KA44	move.w	d7,d1
	lsr.w	#1,d1
	lsr.w	#8,d1
	bra	DAC6
	lea	KA6A(pc),a0
	bsr	EA20
	bsr	DA80
	moveq	#-1,d4
	bsr	BB2C
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	bra.s	KA44

KA6A	dc.b	3,'cmp'

	andi.b	#3,d5
	lea	KA8E(pc),a0
	bsr	EA20
	bsr	DA80
	move.b	#$64,(a4)+
	bsr.s	KA44
	move.b	#$2C,(a4)+
	moveq	#$3D,d4
	bra	BB2C
KA8E	bchg	d1,-(a5)
	ble.s	LA04
	bsr	DA80
	move.w	d7,d0
	andi.w	#$100,d0
	bne.s	KAF2
	moveq	#-3,d4
	bra.s	KADC
	move.w	d7,d0
	andi.w	#$F1F8,d0
	cmp.w	#$C140,d0
	beq.s	KABA
	cmp.w	#$C148,d0
	beq.s	KABA
	cmp.w	#$C188,d0
	bne.s	KAC8
KABA	lea	$988(a6),a4
	move.l	#$65786720,(a4)+
	bra	IA72
KAC8	cmp.b	#3,d5
	beq.s	LA0E
	bsr	DA80
	move.w	d7,d0
	andi.w	#$100,d0
	bne.s	KAF2
	moveq	#-1,d4
KADC	bsr	BB2C
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	move.w	d7,d1
	lsr.w	#1,d1
	lsr.w	#8,d1
	bra	DAC6
KAF2	move.b	#$64,(a4)+
	move.w	d7,d1
	lsr.w	#1,d1
	lsr.w	#8,d1
	bsr	DAC6
	move.b	#$2C,(a4)+
LA04	move.w	d7,d0
	move.w	#$3C,d4
	bra	BB2C
LA0E	move.w	d7,d5
	lsr.w	#8,d5
	andi.b	#1,d5
	addq.b	#1,d5
	bsr	DA80
	moveq	#-1,d4
	bsr	BB2C
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
	move.w	d7,d1
	lsr.w	#1,d1
	lsr.w	#8,d1
	bra	DAC6
	move.w	d7,d1
	cmp.b	#3,d5
	beq.s	LA78
	lsr.b	#2,d1
	bsr.s	LA88
	bsr	DA80
	move.w	d7,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	btst	#5,d7
	bne.s	LA6E
	move.b	#$23,(a4)+
	andi.w	#7,d1
	bne.s	LA5C
	moveq	#8,d1
LA5C	bsr	DACA
	move.b	#$2C,(a4)+
	move.b	#$64,(a4)+
	move.b	d7,d1
	bra	DAC6
LA6E	move.b	#$64,(a4)+
	andi.b	#7,d1
	bra.s	LA5C
LA78	lsr.w	#8,d1
	bsr.s	LA88
	move.b	#$20,(a4)+
	moveq	#2,d5
	moveq	#$3C,d4
	bra	BB2C
LA88	andi.w	#6,d1
	lea	LAAC(pc,d1.w),a0
	move.b	(a0)+,(a4)+
	move.b	(a0),(a4)+
	cmp.b	#4,d1
	bne.s	LA9E
	move.b	#$78,(a4)+
LA9E	moveq	#$6C,d1
	moveq	#8,d0
	btst	d0,d7
	bne.s	LAA8
	moveq	#$72,d1
LAA8	move.b	d1,(a4)+
	rts

LAAC	dc.b	'aslsroro'
	move.w	d7,d1
	bra	CADA

	lea	-2(a5),a1
	bsr	OB3A
	beq.s	LAC6
	rts

LAC6	lea	$988(a6),a4
	move.w	4(a0),d7
	move.l	a0,-(a7)
	bsr	DAD8
	move.b	#$20,-1(a4)
	move.b	#$5B,(a4)+
	movea.l	(a7)+,a0
	move.l	8(a0),d1
	move.w	6(a0),d0
	cmp.w	#1,d0
	beq.s	MA22
	cmp.w	#2,d0
	beq.s	MA1E
	cmp.w	#3,d0
	beq.s	MA18
	move.b	#$3F,(a4)+
	lea	$C(a0),a1
	moveq	#7,d0
MA04	move.b	(a1)+,d1
	beq.s	MA26
	move.b	d1,(a4)+
	dbf	d0,MA04
	move.b	#$2E,(a4)+
	move.b	#$2E,(a4)+
	bra.s	MA26
MA18	move.b	#$2A,(a4)+
	bra.s	MA26
MA1E	move.b	#$3D,(a4)+
MA22	bsr	CAFA
MA26	move.b	#$5D,(a4)+
	rts
	move.w	d7,d0
	andi.w	#$3F,d0
	cmp.w	#$2E,d0
	bne.s	MA96
	move.l	$54(a6),d0
	addq.l	#2,d0
	cmp.l	a5,d0
	bne.s	MA4A
	movea.l	$48(a6),a0
	adda.w	(a5),a0
	bra.s	MA68
MA4A	tst.b	$146(a6)
	beq.s	MA96
	move.l	$142(a6),d0
	beq.s	MA96
	btst	#0,d0
	bne.s	MA96
	movea.l	d0,a2
	bsr	RD6C
	bne.s	MA96
	movea.l	(a2),a0
	adda.w	(a5),a0
MA68	bsr	EEB6
	beq.s	MA96
	move.b	#$5F,(a4)+
	move.b	#$4C,(a4)+
	move.b	#$56,(a4)+
	move.b	#$4F,(a4)+
	bsr	ZDFA
	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	move.b	#$36,(a4)+
	move.b	#$29,(a4)+
	addq.w	#2,a5
	rts
MA96	moveq	#2,d5
	moveq	#$64,d4
	bsr	BB2C
	lea	$98C(a6),a0
	lea	MAE4(pc),a1
	moveq	#$B,d0
MAA8	cmpm.b	(a0)+,(a1)+
	dbne	d0,MAA8
	bne.s	MAE2
	lea	MAF0(pc),a0
	lea	$988(a6),a4
MAB8	move.b	(a0)+,(a4)+
	bne.s	MAB8
	subq.w	#1,a4
	move.w	(a5)+,d0
	beq.s	MADE
	subq.w	#1,d0
MAC4	move.b	(a5)+,d1
	cmp.b	#$22,d1
	bne.s	MACE
	move.b	d1,(a4)+
MACE	move.b	d1,(a4)+
	dbf	d0,MAC4
	move.l	a5,d0
	btst	#0,d0
	beq.s	MADE
	addq.w	#1,a5
MADE	move.b	#$22,(a4)+
MAE2	rts
MAE4	dc.w	$7374,$725F,$636F,$6E73
	dc.w	$7461,$6E74
MAF0	dc.w	$7374,$7269,$6E67,$2022
	dc.w	0
	tst.l	$136(a6)
	beq.s	NA2E
	move.w	d7,d0
	andi.w	#$E00,d0
	cmp.w	#$C00,d0
	bne.s	NA2E
	move.w	d7,d0
	andi.w	#$3F,d0
	cmp.w	#$38,d0
	beq.s	NA32
	cmp.w	#$39,d0
	beq.s	NA3C
	cmp.w	#$3A,d0
	beq.s	NA42
	andi.w	#$38,d0
	cmp.w	#$28,d0
	beq.s	NA5A
NA2E	bra	FAB6
NA32	moveq	#4,d2
	cmp.w	(a5),d2
	bne.s	NA2E
	moveq	#2,d0
	bra.s	NA4A
NA3C	move.l	(a5),d2
	moveq	#4,d0
	bra.s	NA4A
NA42	move.w	(a5),d2
	ext.l	d2
	add.l	a5,d2
	moveq	#2,d0
NA4A	move.l	d2,$142(a6)
	add.l	a5,d0
	addq.l	#2,d0
	move.l	d0,$13E(a6)
	bra	FAB6
NA5A	move.w	d7,d0
	andi.w	#7,d0
	btst	d0,$149(a6)
	beq.s	NA2E
	add.w	d0,d0
	add.w	d0,d0
	lea	$30(a6),a0
	movea.l	0(a0,d0.w),a0
	adda.w	(a5),a0
	move.l	a0,d2
	moveq	#2,d0
	bra.s	NA4A
	move.w	(a5)+,d2
	move.w	d2,d1
	andi.w	#$FFF,d2
	rol.w	#4,d1
	lea	VAE6(pc),a0
	btst	#0,d7
	bne.s	NA98
	bsr.s	NA9E
	move.b	#$2C,(a4)+
	bra	NABC
NA98	bsr.s	NABC
	move.b	#$2C,(a4)+
NA9E	cmp.w	(a0)+,d2
	beq.s	NAAC
	move.b	(a0),d0
	beq.s	NAB6
	ext.w	d0
	adda.w	d0,a0
	bra.s	NA9E
NAAC	addq.l	#1,a0
NAAE	move.b	(a0)+,(a4)+
	bne.s	NAAE
	subq.l	#1,a4
	rts
NAB6	move.b	#$3F,(a4)+
	rts
NABC	andi.b	#$F,d1
	moveq	#$61,d0
	subq.b	#8,d1
	bcc.s	NACA
	addq.b	#8,d1
	moveq	#$64,d0
NACA	move.b	d0,(a4)+
	addi.b	#$30,d1
	move.b	d1,(a4)+
	rts
	moveq	#2,d5
	moveq	#$3D,d4
	bra	BB2C
	moveq	#$25,d4
	bsr.s	OA08
	cmp.w	#$1000,d7
	bcs.s	NAEA
	move.b	#$3F,(a4)+
NAEA	rts
	moveq	#$65,d4
	bsr.s	OA08
	move.b	#$2C,(a4)+
	move.w	d7,d1
NAF6	lsr.w	#8,d1
	lsr.w	#4,d1
	bra	OA76
	move.w	(a5),d1
	bsr.s	NAF6
	move.b	#$2C,(a4)+
	moveq	#$25,d4
OA08	moveq	#2,d5
	move.w	(a5),-(a7)
	addq.w	#2,a5
	bsr	BB2C
	move.b	#$7B,(a4)+
	move.w	(a7)+,d7
	move.w	d7,d1
	lsr.w	#6,d1
	btst	#$B,d7
	bne.s	OA2E
	andi.l	#$1F,d1
	bsr	OA5E
	bra.s	OA36
OA2E	andi.b	#$1F,d1
	bsr	OA76
OA36	move.b	#$3A,(a4)+
	move.w	d7,d1
	andi.l	#$1F,d1
	btst	#5,d7
	bne.s	OA54
	tst.b	d1
	bne.s	OA4E
	moveq	#$20,d1
OA4E	bsr	OA5E
	bra.s	OA58
OA54	bsr	OA76
OA58	move.b	#$7D,(a4)+
	rts
OA5E	divu.w	#$A,d1
	tst.w	d1
	beq.s	OA6C
	addi.b	#$30,d1
	move.b	d1,(a4)+
OA6C	swap	d1
	addi.b	#$30,d1
	move.b	d1,(a4)+
	rts
OA76	move.b	#$64,(a4)+
	cmp.b	#8,d1
	bcs.s	OA84
	move.b	#$3F,(a4)+
OA84	bra	DAC6
	moveq	#$34,d4
	btst	#6,d7
	beq.s	OA92
	moveq	#$6C,d4
OA92	moveq	#2,d5
	bra	BB2C
	move.w	d7,d1
	andi.w	#7,d1
	move.w	d7,d2
	lsr.w	#3,d2
	andi.b	#7,d2
	cmp.b	#1,d2
	beq.s	OAC6
	cmp.b	#7,d2
	beq.s	OADE
OAB2	move.b	#$53,(a4)+
	bsr	PA4A
	move.b	#$20,(a4)+
	moveq	#$3D,d4
	moveq	#0,d5
	bra	BB3E
OAC6	move.b	#$44,(a4)+
	move.b	#$42,(a4)+
	bsr	PA4A
	move.b	#$20,(a4)+
	bsr	BB62
	bra	IA26
OADE	cmp.b	#2,d1
	bcs.s	OAB2
	move.b	#$74,(a4)+
	move.b	#$72,(a4)+
	move.b	#$61,(a4)+
	move.b	#$70,(a4)+
	bsr	PA4A
	bra	AB5A
	andi.w	#$7F,d7
	beq.s	PA34
PA02	move.b	#$62,(a4)+
	bsr.s	PA54
	btst	#6,d7
	beq.s	PA24
	move.b	#$2E,(a4)+
	move.b	#$6C,(a4)+
	move.b	#$20,(a4)+
	move.l	(a5),d1
	add.l	a5,d1
	addq.w	#4,a5
	bra	JA32
PA24	move.b	#$20,(a4)+
	move.w	(a5),d1
	ext.l	d1
	add.l	a5,d1
	addq.w	#2,a5
	bra	JA32
PA34	move.w	(a5),d1
	tst.w	d1
	bne.s	PA02
	addq.w	#2,a5
	move.b	#$6E,(a4)+
	move.b	#$6F,(a4)+
	move.b	#$70,(a4)+
	rts
PA4A	move.w	(a5)+,d7
	cmp.w	#$20,d7
	bcc	FBD6
PA54	lea	PA7C(pc),a0
	move.w	d7,d0
	btst	#5,d0
	bne.s	PA6C
	andi.w	#$1F,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	PA80(pc,d0.w),a0
PA6C	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	beq.s	PA78
	move.b	(a0)+,(a4)+
	beq.s	PA78
	move.b	(a0)+,(a4)+
PA78	subq.w	#1,a4
	rts
PA7C	dc.w	$3F3F,0
PA80	dc.w	$6600,0,$6571,0
	dc.w	$6F67,$7400,$6F67,$6500
	dc.w	$6F6C,$7400,$6F6C,$6500
	dc.w	$6F67,$6C00,$6F72,0
	dc.w	$756E,0,$7565,$7100
	dc.w	$7567,$7400,$7567,$6500
	dc.w	$756C,$7400,$756C,$6500
	dc.w	$6E65,0,$7400,0
	dc.w	$7366,0,$7365,$7100
	dc.w	$6774,0,$6765,0
	dc.w	$6C74,0,$6C65,0
	dc.w	$676C,0,$676C,$6500
	dc.w	$6E67,$6C65,$6E67,$6C00
	dc.w	$6E6C,$6500,$6E6C,$7400
	dc.w	$6E67,$6500,$6E67,$7400
	dc.w	$736E,$6500,$7374,0
	dc.w	$41FA,6,$6000,$A8C
	dc.w	$24C,$5DA,$27E,$3B8
	dc.w	$4B4,$484,$578,$544
QA18	move.w	d6,d0
	andi.w	#$7F,d0
	add.w	d0,d0
	move.w	QA36(pc,d0.w),d0
	lea	RA36(pc),a0
	adda.w	d0,a0
QA2A	move.b	(a0)+,(a4)+
	bne.s	QA2A
	move.b	#$2E,-1(a4)
	rts
QA36	dc.w	$A,$F,$13,$18
	dc.w	$1E,0,$23,0
	dc.w	$2A,$31,$36,0
	dc.w	$3B,$40,$46,$4A
	dc.w	$4E,$53,$5A,0
	dc.w	$61,$66,$6C,0
	dc.w	$71,$75,$7A,0
	dc.w	$7E,$83,$87,$8E
	dc.w	$95,$99,$9D,$A1
	dc.w	$A5,$AC,$B0,$B6
	dc.w	$BD,0,0,0
	dc.w	0,0,0,0
	dc.w	3,3,3,3
	dc.w	3,3,3,3
	dc.w	$C1,0,$C5,0
	dc.w	0,0,0,0
	dc.w	$C9,$CF,0,0
	dc.w	$D5,$DB,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	$E1,0,$E6,0
	dc.w	$EB,0,$F0,0
	dc.w	$F5,0,$FA,$FF
	dc.w	$104,0,$109,$10E
	dc.w	$113,0,0,0
	dc.w	$118,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
RA36	dc.b	'??',0
	dc.b	'sincos',0
	dc.b	'move',0
	dc.b	'int',0
	dc.b	'sinh',0
	dc.b	'intrz',0
	dc.b	'sqrt',0
	dc.b	'lognp1',0
	dc.b	'etoxm1',0
	dc.b	'tanh',0
	dc.b	'atan',0
	dc.b	'asin',0
	dc.b	'atanh',0
	dc.b	'sin',0
	dc.b	'tan',0
	dc.b	'etox',0
	dc.b	'twotox',0
	dc.b	'tentox',0
	dc.b	'logn',0
	dc.b	'log10',0
	dc.b	'log2',0
	dc.b	'abs',0
	dc.b	'cosh',0
	dc.b	'neg',0
	dc.b	'acos',0
	dc.b	'cos',0
	dc.b	'getexp',0
	dc.b	'getman',0
	dc.b	'div',0
	dc.b	'mod',0
	dc.b	'add',0
	dc.b	'mul',0
	dc.b	'sgldiv',0
	dc.b	'rem',0
	dc.b	'scale',0
	dc.b	'sglmul',0
	dc.b	'sub',0
	dc.b	'cmp',0
	dc.b	'tst',0
	dc.b	'smove',0
	dc.b	'ssqrt',0
	dc.b	'dmove',0
	dc.b	'dsqrt',0
	dc.b	'sabs',0
	dc.b	'sneg',0
	dc.b	'dabs',0
	dc.b	'dneg',0
	dc.b	'sdiv',0
	dc.b	'sadd',0
	dc.b	'smul',0
	dc.b	'ddiv',0
	dc.b	'dadd',0
	dc.b	'dmul',0
	dc.b	'ssub',0
	dc.b	'dsub',0,0

	bsr	QA18
	andi.w	#$3F,d7
	beq.s	SA62
	move.b	#$3F,(a4)+
SA62	move.b	#$78,(a4)+
	move.b	#$20,(a4)+
	move.w	d6,d1
	rol.w	#6,d1
	bsr	SAD6
	btst	#5,d6
	bne.s	SAAE
	move.w	d6,d0
	ror.w	#7,d0
	sub.b	d1,d0
	andi.b	#7,d0
	bne.s	SAAE
SA84	rts
	move.w	d6,d1
	rol.w	#6,d1
	andi.w	#7,d1
	cmp.b	#7,d1
	beq	TA1E
	bsr	QA18
	move.b	SAE2(pc,d1.w),(a4)+
	move.b	#$20,(a4)+
	cmp.b	#$3C,d7
	beq.s	SAEA
	moveq	#-3,d4
	bsr	UA66
SAAE	move.w	d6,d1
	andi.w	#$7F,d1
	cmp.b	#$3A,d1
	beq.s	SA84
	move.b	#$2C,(a4)+
	andi.w	#$38,d1
	cmp.b	#$30,d1
	bne.s	SAD2
	move.w	d6,d1
	bsr	SAD6
	move.b	#$3A,(a4)+
SAD2	move.w	d6,d1
	ror.w	#7,d1
SAD6	move.b	#$66,(a4)+
	move.b	#$70,(a4)+
	bra	DAC6

SAE2	dc.b	'lsxpwdb?'

SAEA	move.b	#$23,(a4)+
	moveq	#0,d2
	move.b	TA0E(pc,d1.w),d2
	beq.s	TA06
	move.b	#$24,(a4)+
SAFA	move.w	(a5)+,d1
	bsr	DA0A
	dbf	d2,SAFA
	bra.s	SAAE
TA06	move.w	(a5)+,d1
	bsr	CAD0
	bra.s	SAAE
TA0E	btst	d0,d1
	btst	d2,d5
	ori.b	#0,d3
TA16	move.b	(a0)+,(a4)+
	bne.s	TA16
	subq.w	#1,a4
	rts
TA1E	lea	TA76(pc),a0
	bsr.s	TA16
	move.w	d6,d1
	andi.w	#$3F,d1
	bsr	CADA
	move.b	#$2C,(a4)+
	bsr.s	SAD2
	move.b	#$20,(a4)+
	move.b	#$3B,(a4)+
	move.w	d6,d1
	andi.b	#$3F,d1
	cmp.b	#$34,d1
	bcc.s	TA60
	lea	TA82(pc),a0
TA4C	move.b	(a0)+,d0
	bmi.s	TA5C
	cmp.b	d1,d0
	beq.s	TA5A
TA54	tst.b	(a0)+
	bne.s	TA54
	bra.s	TA4C
TA5A	bra.s	TA16
TA5C	bra	FBD6
TA60	move.b	#$31,(a4)+
	move.b	#$65,(a4)+
	move.b	d1,d0
	subi.b	#$33,d0
	moveq	#1,d1
	asl.w	d0,d1
	bra	CADA

TA76	dc.w	$6d6f,$7665
	dc.w	$6372,$2e78
	dc.w	$2023,$0000

TA82	dc.w	$0070,$6900
	dc.w	$0b6c,$6f67
	dc.w	$3130,$2832
	dc.w	$2900,$0c65
	dc.w	$000d,$6c6f
	dc.w	$6732,$2865
	dc.w	$2900,$0e6c
	dc.w	$6f67,$3130
	dc.w	$2865,$2900
	dc.w	$0f30,$0030
	dc.w	$6c6e,$2832
	dc.w	$2900,$316c
	dc.w	$6e28,$3130
	dc.w	$2900,$3231
	dc.w	$0033,$3130
	dc.w	$00ff

	move.b	#$6D,(a4)+
	move.b	#$6F,(a4)+
	move.b	#$76,(a4)+
	move.b	#$65,(a4)+
	move.b	#$2E,(a4)+
	move.w	d6,d1
	rol.w	#6,d1
	andi.w	#7,d1
	move.b	TAE4(pc,d1.w),(a4)+
	bra	TAEC

TAE4	dc.b	'lsxpwdbp'

TAEC	move.b	#$20,(a4)+
	bsr	SAD2
	move.b	#$2C,(a4)+
	move.w	d6,d1
	rol.w	#6,d1
	andi.w	#7,d1
	moveq	#$3D,d4
	bsr	UA66
	move.w	d6,d1
	rol.w	#6,d1
	andi.w	#7,d1
	cmp.b	#3,d1
	beq.s	UA44
	cmp.b	#7,d1
	bne.s	UA36
UA1A	move.b	#$7B,(a4)+
	move.b	#$64,(a4)+
	move.b	d6,d1
	ror.b	#4,d1
	cmp.b	#$10,d1
	bcs.s	UA30
	move.b	#$3F,(a4)+
UA30	bsr	DAC6
	bra.s	UA60
UA36	move.b	d6,d1
	andi.b	#$7F,d1
	beq.s	UA42
	move.b	#$3F,(a4)+
UA42	rts
UA44	move.b	#$7B,(a4)+
	move.b	d6,d1
	btst	#6,d1
	beq.s	UA56
	ori.b	#$80,d1
	bra.s	UA5A
UA56	andi.b	#$7F,d1
UA5A	ext.w	d1
UA5C	bsr	CABE
UA60	move.b	#$7D,(a4)+
	rts
UA66	moveq	#$53,d0
	btst	d1,d0
	bne.s	UA78
	move.b	d7,d1
	andi.b	#$38,d1
	bne.s	UA78
	move.b	#$3F,(a4)+
UA78	moveq	#1,d5
UA7A	move.w	d6,-(a7)
	bsr	BB2C
	move.w	(a7)+,d6
	rts
UA84	moveq	#$7D,d4
	bra.s	UA7A
UA88	moveq	#-3,d4
	bra.s	UA7A
	bsr	VA1E
	bsr	UAC8
	move.b	#$2C,(a4)+
	bsr	UAAA
	andi.b	#$3F,d4
UAA0	move.w	d3,-(a7)
	bsr	BB2C
	move.w	(a7)+,d3
	rts
UAAA	lea	UAB4(pc),a0
	move.b	0(a0,d3.w),d4
	rts
UAB4	dc.w	$FCFF
	dc.w	$FDFC
	dc.w	$FDFC
	dc.w	$FCFC
	bsr	VA1E
	bsr.s	UAAA
	bsr.s	UAA0
	move.b	#$2C,(a4)+
UAC8	moveq	#2,d0
	andi.b	#7,d3
	lea	VA0E(pc),a0
	beq	FBD6
	cmp.b	#3,d3
	bcs.s	UAFC
	cmp.b	#4,d3
	beq.s	UAFC
UAE2	btst	d0,d3
	beq.s	UAF0
	bsr	TA16
	move.b	#$2F,(a4)+
	bra.s	UAF4
UAF0	tst.b	(a0)+
	bne.s	UAF0
UAF4	subq.b	#1,d0
	bcc.s	UAE2
	subq.w	#1,a4
	rts
UAFC	btst	d0,d3
	bne.s	VA08
VA00	tst.b	(a0)+
	bne.s	VA00
	subq.b	#1,d0
	bra.s	UAFC
VA08	bsr	TA16
	rts

VA0E	dc.b	'fpcr',0,'fpsr',0,'fpiar',0

VA1E	move.b	#$6D,(a4)+
	move.b	#$6F,(a4)+
	move.b	#$76,(a4)+
	move.b	#$65,(a4)+
	move.l	d6,d3
	rol.w	#6,d3
	andi.b	#7,d3
	cmp.b	#3,d3
	bcs.s	VA46
	cmp.b	#4,d3
	beq.s	VA46
	move.b	#$6D,(a4)+
VA46	moveq	#2,d5
	bra	DA80
	bsr	VAC4
	move.b	d6,d3
	btst	#$C,d6
	bne.s	VA6A
	btst	#$B,d6
	bne.s	VA6A
	move.b	d6,d1
	moveq	#7,d0
VA62	roxl.b	#1,d1
	roxr.b	#1,d3
	dbf	d0,VA62
VA6A	bsr.s	VA9C
	move.b	#$2C,(a4)+
	moveq	#1,d5
	moveq	#$34,d4
	btst	#$C,d6
	bne.s	VA7C
	moveq	#$10,d4
VA7C	bra	BB2C
VA80	bsr	VAC4
VA84	moveq	#1,d5
	moveq	#$6C,d4
	bsr	UA7A
	move.b	#$2C,(a4)+
	move.b	d6,d3
	btst	#$C,d6
	bne.s	VA9C
	move.b	#$3F,(a4)+
VA9C	btst	#$B,d6
	bne.s	VAAE
	moveq	#$66,d4
	move.w	d6,-(a7)
	bsr	HA08
	move.w	(a7)+,d6
	rts
VAAE	move.b	#$64,(a4)+
	move.b	d6,d1
	ror.b	#4,d1
	cmp.b	#8,d1
	bcs.s	VAC0
	move.b	#$3F,(a4)+
VAC0	bra	DAC6
VAC4	moveq	#$78,d0
VAC6	lea	VADA(pc),a0
	bsr	TA16
	move.b	d0,(a4)+
	move.b	#$20,(a4)+
	rts

	moveq	#$6C,d0
	bra.s	VAC6

VADA	dc.b	'movem.',0,0,'`',0,9,242
VAE6	dc.b	0,0,6,'sfc',0,0
	dc.b	0,1,6,'dfc',0,0
	dc.b	0,2,6,'cacr',0
	dc.b	0,3,4,'tc',0
	dc.b	0,4,6,'itt0',0
	dc.b	0,5,6,'itt1',0
	dc.b	0,6,6,'dtt0',0
	dc.b	0,7,6,'dtt1',0
	dc.b	8,0,6,'usp',0,0
	dc.b	8,1,6,'vbr',0,0
	dc.b	8,2,6,'caar',0
	dc.b	8,3,6,'msp',0,0
	dc.b	8,4,6,'isp',0,0
	dc.b	8,5,8,'mmusr',0,0
	dc.b	8,6,6,'urp',0,0
	dc.b	8,7,6,'srp',0,0
	dc.b	8,7,0,0

	lea	WA72(pc),a0
	bra	AB92

WA72	dc.w	$00b8,$0132,$0042,$0010,$0216,$0964,$0964,$0964

	bsr	XA84
	moveq	#1,d5
	bsr	DA80
	cmp.w	#$6000,d6
	bne.s	WAA6
	bsr	XA7E
	move.b	#$2C,(a4)+

WA9A	lea	WAA2(pc),a0
	bra	TA16
WAA2	moveq	#$73,d0
	moveq	#0,d1
WAA6	cmp.w	#$6200,d6
	bne	FBD6
	bsr.s	WA9A
	bra	XA7A
	bsr	XA84
	moveq	#2,d5
	btst	#$B,d6
	beq.s	WAC2
	moveq	#4,d5
WAC2	bsr	DA80
	move.w	d6,d1
	andi.w	#$F0FF,d1
	cmp.w	#$4000,d1
	beq.s	WAD6
	move.b	#$3F,(a4)+
WAD6	move.w	d6,d1
	andi.w	#$300,d1
	cmp.w	#$300,d1
	bne.s	WAE6
	move.b	#$3F,(a4)+
WAE6	btst	#9,d6
	bne.s	XA26
	bsr	XA7E
	move.b	#$2C,(a4)+
WAF4	btst	#$B,d6
	beq.s	XA14
	btst	#$A,d6
	bne.s	XA06
	move.b	#$73,(a4)+
	bra.s	XA0A
XA06	move.b	#$63,(a4)+
XA0A	move.b	#$72,(a4)+
	move.b	#$70,(a4)+
	rts
XA14	btst	#$A,d6
	bne	FBD6
	move.b	#$74,(a4)+
	move.b	#$63,(a4)+
	rts
XA26	bsr.s	WAF4
	bra.s	XA7A
	bsr.s	XA84
	moveq	#2,d5
	bsr	DA80
	move.w	d6,d1
	andi.w	#$F8FF,d1
	cmp.w	#$800,d1
	beq.s	XA42
	move.b	#$3F,(a4)+
XA42	move.w	d6,d1
	andi.w	#$300,d1
	cmp.w	#$300,d1
	bne.s	XA52
	move.b	#$3F,(a4)+
XA52	btst	#9,d6
	bne.s	XA78
	bsr.s	XA7E
	move.b	#$2C,(a4)+
XA5E	move.b	#$74,(a4)+
	move.b	#$74,(a4)+
	btst	#$A,d6
	beq.s	XA72
	move.b	#$31,(a4)+
	rts
XA72	move.b	#$30,(a4)+
	rts
XA78	bsr.s	XA5E
XA7A	move.b	#$2C,(a4)+
XA7E	moveq	#$24,d4
	bra	UA7A

XA84	move.b	#$6D,(a4)+
	move.b	#$6F,(a4)+
	move.b	#$76,(a4)+
	move.b	#$65,(a4)+
	btst	#8,d6
	beq.s	XAA2
	move.b	#$66,(a4)+
	move.b	#$64,(a4)+
XAA2	rts

	move.w	d6,d1
	rol.w	#6,d1
	andi.b	#7,d1
	beq.s	YA04
	lea	XAF0(pc),a0
	bsr	TA16
	cmp.b	#1,d1
	beq.s	XAF6
	cmp.b	#4,d1
	beq.s	XACA
	cmp.b	#6,d1
	bne	FBD6
XACA	move.b	#$20,(a4)+
	bsr.s	YA3A
	move.b	#$2C,(a4)+
	move.b	#$23,(a4)+
	move.w	d6,d1
	andi.w	#7,d1
	bsr	CADA
	btst	#$B,d6
	beq	YA02
	move.b	#$2C,(a4)+
	bra.s	XA7E

XAF0	dc.b	'flush',0

XAF6	move.b	#$61,(a4)+
	cmp.w	#$2400,d6
	bne	FBD6
YA02	rts

YA04	lea	YA34(pc),a0
	bsr	TA16
	btst	#9,d6
	bne.s	YA18
	move.b	#$77,(a4)+
	bra.s	YA1C
YA18	move.b	#$72,(a4)+
YA1C	move.b	#$20,(a4)+
	bsr.s	YA3A
	move.w	d6,d1
	andi.w	#$FDE0,d1
	cmp.w	#$2000,d1
	bne	FBD6
	bra	XA7A

YA34	dc.b	'load',0,0

YA3A	move.b	d6,d1
	andi.b	#$18,d1
	beq.s	YA66
	cmp.b	#8,d1
	beq.s	YA60
	cmp.b	#$10,d1
	beq.s	YA52
	bra	FBD6

YA52	move.b	#$23,(a4)+
	move.w	d6,d1
	andi.w	#7,d1
	bra	CADA
YA60	move.b	d6,d1
	bra	BB62
YA66	move.b	d6,d1
	andi.w	#7,d1
	subq.b	#1,d1
	bmi.s	YA7A
	bne	FBD6
	move.b	#$64,(a4)+
	bra.s	YA7E
YA7A	move.b	#$73,(a4)+
YA7E	move.b	#$66,(a4)+
	move.b	#$63,(a4)+
	rts
	lea	YACA(pc),a0
	bsr	TA16
	btst	#9,d6
	bne.s	YA9C
	move.b	#$77,(a4)+
	bra.s	YAA0
YA9C	move.b	#$72,(a4)+
YAA0	move.b	#$20,(a4)+
	bsr.s	YA3A
	bsr	XA7A
	move.b	#$2C,(a4)+
	move.b	#$23,(a4)+
	move.w	d6,d1
	rol.w	#6,d1
	bsr	DAC6
	btst	#8,d6
	bne.s	YAD0
	cmp.b	#$20,d6
	bcc	FBD6
	rts

YACA	dc.b	'test',0,0

YAD0	move.w	d6,d1
	andi.w	#$1C00,d1
	beq	FBD6
	move.b	d6,d1
	rol.b	#3,d1
	move.b	#$2C,(a4)+
	move.b	#$61,(a4)+
	bra	DAC6

YAEA	move.w	d7,d5
	rol.w	#7,d5
	andi.b	#3,d5
	subq.b	#1,d5
	bra	DA80
YAF8	lsr.w	#6,d1
	bra	BB62
	move.w	d7,d1
	move.w	(a5)+,d6
	andi.w	#$3F,d1
	cmp.w	#$3C,d1
	beq.s	ZA24
	bsr.s	YAEA
	bsr	BB60
	move.b	#$2C,(a4)+
	move.w	d6,d1
	bsr.s	YAF8
	move.b	#$2C,(a4)+
	moveq	#$3C,d4
	bra	BB2C
ZA24	move.b	#$32,(a4)+
	cmp.w	#$AFC,d7
	beq	FBD6
	bsr.s	YAEA
	bsr	BB60
	move.b	#$3A,(a4)+
	move.w	(a5),d1
	bsr	BB62
	move.b	#$2C,(a4)+
	move.w	d6,d1
	bsr.s	YAF8
	move.b	#$3A,(a4)+
	move.w	(a5),d1
	bsr.s	YAF8
	move.b	#$2C,(a4)+
	move.w	d6,d1
	bsr.s	ZA5E
	move.b	#$3A,(a4)+
	move.w	(a5)+,d1
ZA5E	move.b	#$28,(a4)+
	bsr.s	ZAAA
	move.b	#$29,(a4)+
	rts
	move.w	(a5)+,d6
	btst	#$B,d6
	bne.s	ZA7C
	move.b	#$6D,(a4)+
	move.b	#$70,(a4)+
	bra.s	ZA84
ZA7C	move.b	#$68,(a4)+
	move.b	#$6B,(a4)+
ZA84	move.b	#$32,(a4)+
	move.w	d7,d5
	rol.w	#7,d5
	andi.b	#3,d5
	bsr	DA80
	move.w	d6,d1
	andi.w	#$3FF,d1
	bne	FBD6
	moveq	#$64,d4
	bsr	UA7A
	move.b	#$2C,(a4)+
	move.w	d6,d1
ZAAA	tst.w	d1
	bmi.s	ZAB4
	move.b	#$64,(a4)+
	bra.s	ZAB8
ZAB4	move.b	#$61,(a4)+
ZAB8	rol.w	#4,d1
	bra	DAC6
	bsr	DA80
	bsr	GBD2
	move.b	#$2C,(a4)+
	bra	UA84
	bsr	DA80
	moveq	#-1,d4
	bra	BB2C
ZAD8	move.w	(a5)+,d6
	btst	#$B,d6
	beq.s	ZAE6
	move.b	#$73,(a4)+
	rts
ZAE6	move.b	#$75,(a4)+
	rts
ZAEC	moveq	#2,d5
	bsr	DA80
	bsr	UA88
	move.b	#$2C,(a4)+
	rts
	bsr.s	ZAD8
	bsr.s	ZAEC
	btst	#$A,d6
	beq.s	AB0E
AB06	bsr	BB60
	move.b	#$3A,(a4)+
AB0E	move.w	d6,d1
	bra.s	ZAAA
	bsr.s	ZAD8
	btst	#$A,d6
	bne.s	AB1E
	move.b	#$6C,(a4)+
AB1E	bsr.s	ZAEC
	bra.s	AB06
	bsr	GA2C
	move.b	#$2C,(a4)+
	move.b	#$23,(a4)+
	move.l	(a5)+,d1
	bra	CAB2
	bsr	JA74
	move.b	#$2C,(a4)+
	move.b	#$23,(a4)+
	move.w	(a5)+,d1
	bra	CADA
	move.w	d7,d1
	lsr.w	#8,d1
	andi.b	#$F,d1
	bsr	DA46
	subq.w	#1,a4
	move.w	d7,d1
	andi.b	#7,d1
AB5A	cmp.b	#4,d1
	beq.s	AB90
	move.b	#$2E,(a4)+
	cmp.b	#2,d1
	beq.s	AB7C
	cmp.b	#3,d1
	bne	FBD6
	move.b	#$6C,(a4)+
	move.l	(a5)+,d1
	bra	AB84
AB7C	move.b	#$77,(a4)+
	move.w	(a5)+,d1
	ext.l	d1
AB84	move.b	#$20,(a4)+
	move.b	#$23,(a4)+
	bra	CAE2
AB90	rts

AB92	move.w	(a5)+,d6
	move.w	d6,d1
	rol.w	#3,d1
	andi.w	#7,d1
	move.b	d1,d0
	bra	EA14
	move.b	d7,d0
	lsr.b	#3,d0
	andi.w	#3,d0
	move.b	ABD2(pc,d0.w),(a4)+
	move.b	#$20,(a4)+
	ext.w	d5
	move.b	ABD6(pc,d5.w),(a4)+
	move.b	#$63,(a4)+
	cmp.b	#3,d0
	beq.s	ABD0
	move.b	#$2C,(a4)+
ABC6	move.b	d7,d2
	andi.b	#7,d2
	bra	FA4A
ABD0	rts

ABD2	dc.b	'?lpa'
ABD6	dc.b	'ndib'

	bsr.s	ABC6
	move.b	#$2B,(a4)+
	move.b	#$2C,(a4)+
	move.w	(a5)+,d7
	move.w	d7,d0
	andi.w	#$8FFF,d0
	cmp.w	#$8000,d0
	beq.s	ABF6
	move.b	#$3F,(a4)+
ABF6	rol.w	#4,d7
	bsr.s	ABC6
	move.b	#$2B,(a4)+
	rts
	btst	#3,d7
	bne.s	BB16
	bsr	BB1C
	move.b	#$2C,(a4)+
BB0E	move.l	(a5)+,d1
	bra	CAE2
	rts
BB16	bsr.s	BB0E
	move.b	#$2C,(a4)+
BB1C	bsr.s	ABC6
	btst	#4,d7
	bne.s	BB28
	move.b	#$2B,(a4)+
BB28	rts
	rts
BB2C	move.l	a5,$594(a6)
	move.w	d7,d1
	andi.w	#7,d1
	move.w	d7,d2
	lsr.w	#3,d2
	andi.b	#7,d2
BB3E	move.b	d2,d0
	move.w	d1,d6
	lea	BB4A(pc),a0
	bra	EA14

BB4A	dc.w	$10,$20,$34,$76,$84,$ac,$192,$472,$504
	beq	FBD6

BB60	move.b	d6,d1
BB62	move.b	#$64,(a4)+
	bra	DAC6
	btst	d2,d4
	beq	FBD6
	tst.b	d5
	beq	FBD6
BB76	move.b	#$61,(a4)+
	bra	DAC6
	btst	d2,d4
	beq	FBD6
BB84	bset	#0,$14B(a6)
	bne.s	BBB4
	bsr.s	BB98
	move.l	d0,$14E(a6)
	move.b	d5,$14D(a6)
	bra.s	BBB4
BB98	move.w	d6,d0
	add.w	d0,d0
	add.w	d0,d0
	cmp.w	#$1C,d0
	bne.s	BBAE
	btst	#5,$5A(a6)
	beq.s	BBAE
	moveq	#$20,d0
BBAE	move.l	$30(a6,d0.w),d0
	rts
BBB4	move.b	#$28,(a4)+
	bsr.s	BB76
	move.b	#$29,(a4)+
	rts
	btst	d2,d4
	beq	FBD6
	bsr.s	BB84
	move.b	#$2B,(a4)+
	rts
	btst	d2,d4
	beq	FBD6
	move.b	#$2D,(a4)+
	btst	#0,$14B(a6)
	bne.s	BBB4
	bsr.s	BB84
	andi.w	#3,d5
	moveq	#0,d0
	move.b	BBF2(pc,d5.w),d0
	sub.l	d0,$14E(a6)
	rts

BBF2	dc.b	1,2,4,0,5,4

	beq	FBD6
	move.w	(a5)+,d1
	ext.l	d1
	bset	#0,$14B(a6)
	bne.s	CB14
	bsr.s	BB98
	add.l	d1,d0
	move.l	d0,$14E(a6)
	move.b	d5,$14D(a6)
CB14	tst.l	$AE(a6)
	beq.s	CB64
	btst	d6,$590(a6)
	beq.s	CB3A
	move.w	d1,d0
	ext.l	d0
	move.l	d2,-(a7)
	move.b	d6,d2
	addq.b	#1,d2
	bsr	AE32
	movem.l	(a7)+,d2
	beq.s	CB3A
	bsr	ZDFA
	bra.s	CB68
CB3A	tst.b	$148(a6)
	beq.s	CB64
	cmp.b	#7,d6
	beq.s	CB64
	move.w	d1,d0
	ext.l	d0
	move.l	d2,-(a7)
	moveq	#0,d2
	move.b	d6,d2
	lsl.w	#2,d2
	add.l	$30(a6,d2.w),d0
	move.l	(a7)+,d2
	bsr	DE02
	beq.s	CB64
	bsr	ZDFA
	bra.s	CB68
CB64	bsr	CAD0
CB68	move.b	d6,d1
	bra	BBB4
CB6E	move.b	d4,d0
	ext.w	d0
	adda.w	d0,a0
	move.w	d4,d0
	rol.w	#6,d0
	andi.w	#$3C,d0
	cmp.w	#$3C,d0
	bne.s	CB8C
	btst	#5,$5A(a6)
	beq.s	CB8C
	moveq	#$40,d0
CB8C	move.l	$10(a6,d0.w),d0
	btst	#$B,d4
	bne.s	CB98
	ext.l	d0
CB98	adda.l	d0,a0
	move.l	a0,$14E(a6)
	move.b	d5,$14D(a6)
	rts
CBA4	st	d3
	move.w	(a5)+,d4
	btst	#8,d4
	bne	DB72
	move.b	d4,d1
	ext.w	d1
	ext.l	d1
	add.l	$594(a6),d1
	add.l	4(a6),d1
	bsr	CAE2
	move.b	#$28,(a4)+
	move.b	#$70,(a4)+
	move.b	#$63,(a4)+
	move.b	#$2C,(a4)+
	bsr	DB1A
	move.b	#$29,(a4)+
	rts
	btst	#5,d4
	beq	FBD6
	move.w	(a5)+,d4
	sf	d3
	btst	#8,d4
	bne	DB72
	move.w	#$600,d0
	and.w	d4,d0
	beq	FB64
	move.b	d4,d1
	bsr	CABE
	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	moveq	#$30,d1
	add.b	d6,d1
	move.b	d1,(a4)+
	move.b	#$2C,(a4)+
	bsr.s	DB1A
	move.b	#$29,(a4)+
	rts
DB1A	move.w	d4,d0
	rol.w	#5,d0
	andi.w	#$1E,d0
	move.b	DB4E(pc,d0.w),(a4)+
	move.b	DB4F(pc,d0.w),(a4)+
	move.b	#$2E,(a4)+
	moveq	#$77,d0
	btst	#$B,d4
	beq.s	DB38
	moveq	#$6C,d0
DB38	move.b	d0,(a4)+
	move.w	#$600,d0
	and.w	d4,d0
	beq.s	DB4C
	move.b	#$2A,(a4)+
	rol.w	#7,d0
	move.b	DB6D(pc,d0.w),(a4)+
DB4C	rts

DB4E	dc.b	'd'
DB4F	dc.b	'0d1d2d3d4d5d6d7'
	dc.b	'a0a1a2a3a4a5a6a'

DB6D	dc.b	'7248',0

DB72	move.b	#$28,(a4)+
	moveq	#7,d0
	and.w	d4,d0
	btst	#6,d4
	beq.s	DB84
	bset	#3,d0
DB84	lea	DB92(pc),a0
	bsr	EA14
	move.b	#$29,(a4)+
	rts
DB92	dc.w	$20,$30,$4A,$4A
	dc.w	$E8,$6A,$8A,$8A
	dc.w	$AA,$B6,$CC,$CC
	dc.w	$E8,$E8,$E8,$E8
	bsr	EB80
	bsr	EBE4
	bsr	FB1C
	bra	FB5A
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB1C
	bsr	FB5A
	move.b	#$5D,(a4)+
	rts
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB1C
	bsr	FB5A
	move.b	#$5D,(a4)+
	move.b	#$2C,(a4)+
	bra	FB3E
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB5A
	move.b	#$5D,(a4)+
	move.b	#$2C,(a4)+
	bsr	FB1C
	bra	FB5A
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB5A
	move.b	#$5D,(a4)+
	move.b	#$2C,(a4)+
	bsr	FB1C
	bra	FB3E
	bsr	EB80
	bsr	EBE4
	bra	FB5A
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB5A
	move.b	#$5D,(a4)+
	rts
	move.b	#$5B,(a4)+
	bsr	EB80
	bsr	EBE4
	bsr	FB5A
	move.b	#$5D,(a4)+
	move.b	#$2C,(a4)+
	bra	FB3E
	move.b	#$3F,(a4)+
	rts
EB80	moveq	#$30,d0
	and.w	d4,d0
	beq.s	EBB0
	lsr.w	#4,d0
	subq.b	#1,d0
	beq.s	EBE2
	subq.w	#1,d0
	bne.s	EBB6
	move.w	(a5)+,d1
	tst.b	d3
	bne.s	EB9C
	bsr	CAD0
	bra.s	EBD4
EB9C	ext.l	d1
	add.l	4(a6),d1
	tst.b	d4
	bmi.s	EBAA
	add.l	$594(a6),d1
EBAA	bsr	CAE2
	bra.s	EBD4
EBB0	move.b	#$3F,(a4)+
	bra.s	EBD4
EBB6	move.l	(a5)+,d1
	tst.b	d3
	beq.s	EBC8
	add.l	4(a6),d1
	tst.b	d4
	bmi.s	EBC8
	add.l	$594(a6),d1
EBC8	bsr	CAE2
	move.b	#$2E,(a4)+
	move.b	#$6C,(a4)+
EBD4	tst.b	$592(a6)
	beq.s	EBDE
	move.b	#$7D,(a4)+
EBDE	move.b	#$2C,(a4)+
EBE2	rts
EBE4	tst.b	d4
	bpl.s	FB0A
	move.b	#$7A,(a4)+
	tst.b	d3
	bne.s	FB0E
	tst.b	$587(a6)
	beq.s	FB06
EBF6	move.b	#$61,(a4)+
	moveq	#$30,d0
	add.b	d6,d0
	move.b	d0,(a4)+
	move.b	#$2C,(a4)+
	rts
FB06	subq.w	#1,a4
	rts
FB0A	tst.b	d3
	beq.s	EBF6
FB0E	move.b	#$70,(a4)+
	move.b	#$63,(a4)+
	move.b	#$2C,(a4)+
	rts
FB1C	btst	#6,d4
	beq.s	FB34
	move.b	#$7A,(a4)+
	move.b	#$64,(a4)+
	move.b	#$3F,(a4)+
	move.b	#$2C,(a4)+
	rts
FB34	bsr	DB1A
	move.b	#$2C,(a4)+
	rts
FB3E	btst	#0,d4
	beq.s	FB54
	move.l	(a5)+,d1
	bsr	CAE2
	move.b	#$2E,(a4)+
	move.b	#$6C,(a4)+
	rts
FB54	move.w	(a5)+,d1
	bra	CAD0
FB5A	cmpi.b	#$2C,-(a4)
	beq.s	FB62
	addq.l	#1,a4
FB62	rts
FB64	bset	#0,$14B(a6)
	bne.s	FB76
	bsr	BB98
	movea.l	d0,a0
	bsr	CB6E
FB76	move.b	d4,d1
	bsr	CABE
	move.b	#$28,(a4)+
	move.b	#$61,(a4)+
	move.b	d6,d1
	bsr	DAC6
	move.b	#$2C,(a4)+
	tst.w	d4
	bmi.s	FB98
	move.b	#$64,(a4)+
	bra.s	FB9C
FB98	move.b	#$61,(a4)+
FB9C	move.w	d4,d1
	moveq	#$C,d0
	lsr.w	d0,d1
	bsr	DAC6
	moveq	#$77,d0
	andi.w	#$800,d4
	beq.s	FBB0
	moveq	#$6C,d0
FBB0	move.b	#$2E,(a4)+
	move.b	d0,(a4)+
	move.b	#$29,(a4)+
	rts

	lea	FBC6(pc),a0
	move.b	d1,d0
	bra	EA14

FBC6	dc.w	$001a,$0046,$005c,$008c,$0104,$012c,$012c,$012c

FBD6	move.b	#'?',(a4)+
	move.b	#'?',(a4)+
	rts

	btst	#5,d4
	beq.s	FBD6
	move.w	(a5)+,d1
	ext.l	d1
	bsr.s	FBFA
	bsr	CAE2
	move.b	#$2E,(a4)+
	move.b	#$77,(a4)+
	rts

FBFA	bset	#0,$14B(a6)
	bne.s	GB0A
	move.l	d1,$14E(a6)
	move.b	d5,$14D(a6)
GB0A	rts

	btst	#5,d4
	beq.s	FBD6
	move.l	(a5)+,d1
	bsr.s	FBFA
	bra	CAE2
GB1A	dc.w	$528,$7063,$297D,$2000
	btst	#6,d4
	beq.s	FBD6
	move.w	(a5),d1
	ext.l	d1
	add.l	a5,d1
	addq.l	#2,a5
	add.l	4(a6),d1
	bsr.s	FBFA
	bsr	CAE2
	lea	GB4C(pc),a0
	tst.b	$592(a6)
	beq.s	GB48
	lea	GB1A(pc),a0
GB48	bra	EA20

GB4C	dc.b	4,'(pc) '
	btst	#6,d4
	beq	FBD6
	move.w	(a5),d6
	move.w	d6,d4
	move.w	#$700,d0
	and.w	d4,d0
	bne	CBA4
	move.b	d6,d1
	ext.w	d1
	ext.l	d1
	add.l	a5,d1
	addq.l	#2,a5
	add.l	4(a6),d1
	bsr	CAE2
	lea	GB8C(pc),a0
	bsr	EA20
	tst.w	d6
	bmi.s	GB92
	move.b	#$64,(a4)+
	bra.s	GB96

GB8C	dc.b	4,'(pc, '

GB92	move.b	#$61,(a4)+
GB96	move.w	d6,d1
	moveq	#$C,d0
	lsr.w	d0,d1
	bsr	DAC6
	move.b	#$2E,(a4)+
	andi.w	#$800,d6
	beq.s	GBB0
	move.b	#$6C,(a4)+
	bra.s	GBB4
GBB0	move.b	#$77,(a4)+
GBB4	move.b	#$29,(a4)+
	bset	#0,$14B(a6)
	beq.s	GBC2
	rts
GBC2	lea	-2(a5),a0
	bra	CB6E
	btst	#7,d4
	beq	FBD6
GBD2	move.b	#$23,(a4)+
	tst.b	d5
	bne.s	GBE0
	move.w	(a5)+,d1
	bra	CAC8
GBE0	cmp.b	#2,d5
	bne.s	GBEC
	move.l	(a5)+,d1
	bra	CAE2
GBEC	move.w	(a5)+,d1
	bra	CADA
	move.b	#$3F,(a4)+
	rts
GBF8	dc.w	$F138,$108,$F9C0,$C0
	dc.w	$FF00,0,$FF00,$200
	dc.w	$FF00,$400,$FF00,$600
	dc.w	$FFC0,$AC0,$FDC0,$CC0
	dc.w	$FF00,$800,$FF00,$A00
	dc.w	$FF00,$C00,$F100,$100
	dc.w	$F000,$1000,$F1C0,$2040
	dc.w	$F000,$2000,$F1C0,$3040
	dc.w	$F000,$3000,$FFFF,$4AFB
	dc.w	$FFFF,$4AFC,$FFFF,$4E70
	dc.w	$FFFF,$4E71,$FFFF,$4E72
	dc.w	$FFFF,$4E73,$FFFF,$4E74
	dc.w	$FFFF,$4E75,$FFFF,$4E76
	dc.w	$FFFF,$4E77,$FFFE,$4E7A
	dc.w	$FFF8,$4840,$FFF8,$4880
	dc.w	$FFF8,$48C0,$FFF8,$4E50
	dc.w	$FFF8,$4E58,$FFF8,$4E60
	dc.w	$FFF8,$4E68,$FFF8,$49C0
	dc.w	$FFF0,$4E40,$FFC0,$40C0
	dc.w	$FFC0,$42C0,$FFF8,$4848
	dc.w	$FFC0,$44C0,$FFC0,$46C0
	dc.w	$FFF8,$4808,$FFC0,$4800
	dc.w	$FFC0,$4AC0,$FFC0,$4E80
	dc.w	$FFC0,$4EC0,$FFC0,$4C00
	dc.w	$FFC0,$4C40,$FF80,$4880
	dc.w	$FF80,$4C80,$FF40,$4840
	dc.w	$FF00,$4000,$FF00,$4200
	dc.w	$FF00,$4400,$FF00,$4600
	dc.w	$FF00,$4A00,$F140,$4100
	dc.w	$F1C0,$41C0,$F0FE,$50F8
	dc.w	$F0F8,$50F8,$F0F8,$50C8
	dc.w	$F0C0,$50C0,$F100,$5000
	dc.w	$F100,$5100,$F000,$6000
	dc.w	$F100,$7000,$F1F0,$8100
	dc.w	$F1F0,$8140,$F1F0,$8180
	dc.w	$F1C0,$80C0,$F1C0,$81C0
	dc.w	$F000,$8000,$F0C0,$90C0
	dc.w	$F130,$9100,$F000,$9000
	dc.w	$F138,$B108,$F000,$B000
	dc.w	$F1F0,$C100,$F1C0,$C0C0
	dc.w	$F1C0,$C1C0,$F130,$C100
	dc.w	$F000,$C000,$F0C0,$D0C0
	dc.w	$F130,$D100,$F000,$D000
	dc.w	$FFC0,$E8C0,$FFC0,$E9C0
	dc.w	$FFC0,$EAC0,$FFC0,$EBC0
	dc.w	$FFC0,$ECC0,$FFC0,$EDC0
	dc.w	$FFC0,$EEC0,$FFC0,$EFC0
	dc.w	$F000,$E000,$FFC0,$F000
	dc.w	$FFC0,$F200,$FFC0,$F240
	dc.w	$FF80,$F280,$FFC0,$F300
	dc.w	$FFC0,$F340,$FF20,$F400
	dc.w	$FF20,$F420,$FFF8,$F500
	dc.w	$FFF8,$F508,$FFFF,$F510
	dc.w	$FFFF,$F518,$FFF8,$F548
	dc.w	$FFF8,$F568,$FFF8,$F620
	dc.w	$FFE0,$F600,0,0

IBB8	dc.b	7,3,'movep.'
	dc.b	2,42,'c'
	dc.b	4,2,'ori'
	dc.b	5,2,'andi'
	dc.b	5,2,'subi'
	dc.b	5,2,'addi'
	dc.b	4,41,'cas'
	dc.b	4,41,'cas'
	dc.b	2,5,'b'
	dc.b	5,2,'eori'
	dc.b	5,43,'cmpi'
	dc.b	2,4,'b'
	dc.b	8,6,'move.b '
	dc.b	9,60,'movea.l '
	dc.b	8,6,'move.l '
	dc.b	9,6,'movea.w '
	dc.b	8,6,'move.w '
	dc.b	6,33,'dc.w '
	dc.b	8,34,'illegal'
	dc.b	6,0,'reset'
	dc.b	4,0,'nop'
	dc.b	7,7,'stop #'
	dc.b	4,0,'rte'
	dc.b	6,7,'rtd #'
	dc.b	4,0,'rts'
	dc.b	6,0,'trapv'
	dc.b	4,0,'rtr'
	dc.b	7,35,'movec '
	dc.b	7,8,'swap d'
	dc.b	8,8,'ext.w d'
	dc.b	8,8,'ext.l d'
	dc.b	7,9,'link a'
	dc.b	7,8,'unlk a'
	dc.b	9,10,'move.l a'
	dc.b	13,8,'move.l usp,a'
	dc.b	9,37,'extb.l d'
	dc.b	7,11,'trap #'
	dc.b	10,12,'move sr,.'
	dc.b	10,36,'move ccr,'
	dc.b	7,8,'bkpt #'
	dc.b	8,13,'move.b '
	dc.b	8,14,'move.w '
	dc.b	9,47,'link.l a'
	dc.b	7,12,'nbcd .'
	dc.b	6,12,'tas .'
	dc.b	5,59,'jsr '
	dc.b	5,59,'jmp '
	dc.b	4,45,'mul'
	dc.b	4,46,'div'
	dc.b	6,16,'movem'
	dc.b	6,15,'movem'
	dc.b	6,12,'pea .'
	dc.b	5,12,'negx'
	dc.b	4,12,'clr'
	dc.b	4,12,'neg'
	dc.b	4,12,'not'
	dc.b	4,44,'tst'
	dc.b	4,17,'chk'
	dc.b	5,18,'lea '
	dc.b	2,20,'s'
	dc.b	5,49,'trap'
	dc.b	3,19,'db'
	dc.b	2,20,'s'
	dc.b	5,21,'addq'
	dc.b	5,21,'subq'
	dc.b	2,23,'b'
	dc.b	8,24,'moveq #'
	dc.b	6,25,'sbcd '
	dc.b	6,48,'pack '
	dc.b	6,48,'unpk '
	dc.b	5,17,'divu'
	dc.b	5,17,'divs'
	dc.b	3,31,'or'
	dc.b	5,30,'suba'
	dc.b	5,25,'subx'
	dc.b	4,30,'sub'
	dc.b	5,28,'cmpm'
	dc.b	1,29
	dc.b	6,25,'abcd '
	dc.b	5,17,'mulu'
	dc.b	5,17,'muls'
	dc.b	5,22,'exg '
	dc.b	4,31,'and'
	dc.b	5,30,'adda'
	dc.b	5,25,'addx'
	dc.b	4,30,'add'
	dc.b	7,38,'bftst '
	dc.b	8,39,'bfextu '
	dc.b	7,38,'bfchg '
	dc.b	8,39,'bfexts '
	dc.b	7,38,'bfclr '
	dc.b	7,39,'bfffo '
	dc.b	7,38,'bfset '
	dc.b	7,40,'bfins '
	dc.b	1,32
	dc.b	2,54,'p'
	dc.b	2,50,'f'
	dc.b	2,51,'f'
	dc.b	2,52,'f'
	dc.b	7,53,'fsave '
	dc.b	10,53,'frestore '
	dc.b	5,55,'cinv'
	dc.b	6,55,'cpush'
	dc.b	9,58,'pflushn '
	dc.b	8,58,'pflush '
	dc.b	9,0,'pflushan'
	dc.b	8,0,'pflusha'
	dc.b	8,58,'ptestw '
	dc.b	8,58,'ptestr '
	dc.b	8,56,'move16 '
	dc.b	8,57,'move16 '
	dc.b	6,33,'dc.w ',0

LBB2	movem.l	d3-d7/a3-a5,-(a7)
	move.l	$AE(a6),-(a7)
	move.l	$136(a6),-(a7)
	clr.l	$AE(a6)
	clr.l	$136(a6)
	move.l	a2,-(a7)
	moveq	#3,d4
	lea	-$C(a2),a5
	movea.l	a5,a2
	bsr	RD6C
	bne.s	MB1C
LBD6	addq.w	#2,a5
	movem.l	d4/a5,-(a7)
	bsr	DAD2
	cmpa.l	8(a7),a5
	movem.l	(a7)+,d4/a5
	bne.s	MB18
	lea	$988(a6),a1
LBEE	move.b	(a1)+,d1
	cmp.b	#$5B,d1
	beq.s	MB02
	cmp.b	#$3F,d1
	beq.s	MB18
	cmp.b	#$A,d1
	bne.s	LBEE
MB02	addq.l	#4,a7
	moveq	#0,d0
MB06	move.l	(a7)+,$136(a6)
	move.l	(a7)+,$AE(a6)
	movea.l	a5,a2
	movem.l	(a7)+,d3-d7/a3-a5
	tst.b	d0
	rts
MB18	dbf	d4,LBD6
MB1C	movea.l	(a7)+,a5
	subq.w	#2,a5
	moveq	#-1,d0
	bra.s	MB06
MB24	move.l	a2,$54(a6)
	bra	VB74
MB2C	move.l	a2,$54(a6)
	bset	#7,$5A(a6)
	st	d3
	bra	AA90
MB3C	lea	$554(a6),a0
	move.l	#$4E714E71,d0
	move.l	d0,(a0)
	move.l	d0,4(a0)
	move.w	d0,8(a0)
	move.w	#$4AFC,$A(a0)
	moveq	#$C,d0
	bsr	OBA8
	move.w	(a2),d0
	cmp.w	#$4AFC,d0
	beq.s	MB24
	andi.w	#$FFF0,d0
	cmp.w	#$4E40,d0
	beq.s	MB8E
	andi.w	#$FFC0,d0
	cmp.w	#$4E80,d0
	beq.s	MB94
	andi.w	#$FF00,d0
	cmp.w	#$6100,d0
	beq	NB16
	andi.w	#$F000,d0
	cmp.w	#$A000,d0
	bne.s	MB2C
MB8E	move.w	(a2)+,(a0)
	bra	NB44
MB94	move.w	(a2)+,d0
	move.w	d0,(a0)
	move.b	d0,d1
	andi.b	#$38,d1
	cmp.b	#$10,d1
	beq	NB44
	cmp.b	#$28,d1
	beq.s	MBDC
	cmp.b	#$30,d1
	beq.s	MBDC
	cmp.b	#$38,d1
	bne.s	MBD2
	move.b	d0,d1
	andi.b	#7,d1
	beq.s	MBDC
	cmp.b	#4,d1
	bcc.s	MBD2
	cmp.b	#1,d1
	bne.s	MBE2
	move.l	(a2)+,2(a0)
	bra.s	NB44
MBD2	moveq	#2,d0
	bsr	OBA8
	bra	MB2C
MBDC	move.w	(a2)+,2(a0)
	bra.s	NB44
MBE2	cmp.b	#2,d1
	bne.s	MBF2
	move.l	a2,d0
	move.w	(a2)+,d1
	ext.l	d1
	add.l	d1,d0
	bra.s	NB30
MBF2	move.w	(a2)+,d1
	move.b	d1,d0
	ext.w	d0
	ext.l	d0
	add.l	a2,d0
	subq.l	#2,d0
	move.w	d1,d2
	rol.w	#6,d2
	andi.w	#$3C,d2
	move.l	$10(a6,d2.w),d2
	btst	#$B,d1
	bne.s	NB12
	ext.l	d2
NB12	add.l	d2,d0
	bra.s	NB30
NB16	move.w	(a2)+,d0
	tst.b	d0
	beq.s	NB3A
	cmp.b	#$FF,d0
	bne.s	NB2A
	move.l	(a2),d0
	add.l	a2,d0
	addq.w	#4,a2
	bra.s	NB30
NB2A	ext.w	d0
	ext.l	d0
	add.l	a2,d0
NB30	move.w	#$4EB9,(a0)
	move.l	d0,2(a0)
	bra.s	NB44
NB3A	move.w	(a2)+,d0
	lea	-2(a2,d0.w),a1
	move.l	a1,d0
	bra.s	NB30
NB44	moveq	#6,d0
	bsr	OBA8
	move.l	a2,$560(a6)
	move.l	a0,-(a7)
	move.l	(a7)+,$54(a6)
	bclr	#7,$5A(a6)
	st	d3
	bra	AA90
NB60	moveq	#7,d0
	lea	$19E(a6),a0
NB66	clr.w	(a0)
	lea	$48(a0),a0
	dbf	d0,NB66
	rts
NB72	moveq	#7,d0
	lea	$198(a6),a0
NB78	tst.w	6(a0)
	beq.s	NB98
	movea.l	(a0),a1
	cmpi.w	#$4AFC,(a1)
	beq.s	NB8E
	clr.w	6(a0)
	clr.l	(a0)
	bra.s	NB98
NB8E	lea	$48(a0),a0
	dbf	d0,NB78
	moveq	#-1,d0
NB98	rts
NB9A	move.l	a1,-(a7)
	bsr	OB3A
	bne.s	NBA6
	bsr	OB6C
NBA6	bsr.s	NB72
	movea.l	(a7)+,a1
	lea	KE02(pc),a2
	bne.s	OB04
	move.l	a1,d0
	btst	#0,d0
	lea	JEEA(pc),a2
	bne.s	OB04
	cmp.b	#4,d3
	bne.s	NBD0
	move.l	a0,-(a7)
	lea	$C(a0),a0
NBC8	move.b	(a4)+,(a0)+
	bne.s	NBC8
	movea.l	(a7)+,a0
	bra.s	NBDA
NBD0	bsr	RDA6
	lea	JEE2(pc),a2
	bne.s	OB04
NBDA	bsr.s	OB0E
	move.w	(a1),4(a0)
	move.w	#$4AFC,(a1)
	bsr	OB9E
	cmpi.w	#$4AFC,(a1)
	lea	JEF4(pc),a2
	bne.s	OB02
	bsr.s	OB24
	move.l	a1,(a0)
	move.l	d2,8(a0)
	move.w	d3,6(a0)
	moveq	#0,d0
	rts
OB02	bsr.s	OB24
OB04	movea.l	a2,a0
	bsr	CA30
	moveq	#-1,d0
	rts
OB0E	movem.l	d0-d1/a0-a1,-(a7)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	movem.l	(a7)+,d0-d1/a0-a1
	rts
OB24	movem.l	d0-d1/a0-a1,-(a7)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$8A(a6)
	movea.l	(a7)+,a6
	movem.l	(a7)+,d0-d1/a0-a1
	rts
OB3A	moveq	#7,d0
	lea	$198(a6),a0
OB40	cmpa.l	(a0),a1
	bne.s	OB4E
	tst.w	6(a0)
	beq.s	OB4E
	moveq	#0,d0
	rts
OB4E	lea	$48(a0),a0
	dbf	d0,OB40
	moveq	#-1,d0
	rts
OB5A	moveq	#7,d0
	lea	$198(a6),a0
OB60	bsr.s	OB6C
	lea	$48(a0),a0
	dbf	d0,OB60
	rts
OB6C	bsr.s	OB0E
	tst.w	6(a0)
	beq.s	OB88
	clr.w	6(a0)
	movea.l	(a0),a1
	cmpi.w	#$4AFC,(a1)
	bne.s	OB88
	move.w	4(a0),(a1)
	bsr	OB9E
OB88	bra.s	OB24
	bsr.s	OB0E
	move.l	a1,$564(a6)
	move.w	(a1),$568(a6)
	move.w	#$4AFC,(a1)
	bsr	OB9E
	bra.s	OB24
OB9E	movem.l	d0-d1/a0-a1/a5-a6,-(a7)
	movea.l	a1,a0
	moveq	#2,d0
	bra.s	OBAC
OBA8	movem.l	d0-d1/a0-a1/a5-a6,-(a7)
OBAC	movea.l	4.w,a6
	move.w	$14(a6),d1
	cmp.w	#$25,d1
	bcs.s	OBC6
	move.l	#$808,d1
	jsr	-$282(a6)
	bra.s	OBD8
OBC6	move.w	$128(a6),d1
	btst	#1,d1
	beq.s	OBD8
	lea	OBDE(pc),a5
	jsr	-$1E(a6)
OBD8	movem.l	(a7)+,d0-d1/a0-a1/a5-a6
	rts
OBDE	btst	#3,d1
	bne.s	OBF2
	movec	cacr,d0
	ori.w	#$328,d0
	movec	d0,cacr
	rte
OBF2	addi.l	#$F,d0
	lsr.l	#4,d0
	cmp.l	#$43,d0
	bcs.s	PB06
	dc.w	$f4f8			; cpusha	bc
	rte


PB06	moveq	#$10,d1
PB08	dc.w	$f4e8			; cpushl	bc,(a0)
	adda.w	d1,a0
	dbf	d0,PB08
	rte


PB12	movea.l	4.w,a0
	move.l	$3E(a0),8(a6)
	lea	$142(a0),a1
	move.l	a1,$C(a6)
	rts
PB26	cmpa.l	8(a6),a2
	bcs.s	PB42
	cmpa.l	#$F80000,a2
	bcs.s	PB48
	cmpa.l	#$1000000,a2
	bcc.s	PB48
	lea	PB82(pc),a5
	rts
PB42	lea	PB6A(pc),a5
	rts
PB48	movea.l	$C(a6),a4
PB4C	move.l	(a4),d0
	beq.s	PB66
	movea.l	d0,a4
	tst.l	(a4)
	beq.s	PB66
	cmpa.l	a4,a2
	bcs.s	PB4C
	cmpa.l	$18(a4),a2
	bcc.s	PB4C
	lea	PBAC(pc),a5
	rts
PB66	suba.l	a2,a2
	bra.s	PB42
PB6A	addq.l	#1,a2
	cmpa.l	8(a6),a2
	bcc.s	PB74
	rts
PB74	lea	PB82(pc),a5
	movea.l	#$F80000,a2
	cmp.b	d1,d1
	rts
PB82	addq.l	#1,a2
	cmpa.l	#$1000000,a2
	bcc.s	PB8E
	rts
PB8E	movea.l	$C(a6),a4
	tst.l	(a4)
	beq.s	PBC8
PB96	movea.l	(a4),a4
	tst.l	(a4)
	beq.s	PBC8
	cmpa.l	8(a6),a4
	bcs.s	PB96
	movea.l	a4,a2
	lea	PBAC(pc),a5
	cmp.b	d1,d1
	rts
PBAC	addq.l	#1,a2
	cmpa.l	$18(a4),a2
	bcc.s	PBB6
	rts
PBB6	movea.l	(a4),a4
	tst.l	(a4)
	beq.s	PBC8
	cmpa.l	8(a6),a4
	bcs.s	PBB6
	cmp.b	d1,d1
	movea.l	a4,a2
	rts
PBC8	suba.l	a2,a2
	lea	PB6A(pc),a5
	cmp.b	d1,d1
	rts
PBD2	lea	$3DE(a6),a0
	move.l	a0,$550(a6)
	moveq	#4,d0
PBDC	clr.l	$46(a0)
	lea	$4A(a0),a0
	dbf	d0,PBDC
	rts
PBEA	movea.l	$550(a6),a0
	lea	$10(a6),a1
	moveq	#$F,d0
PBF4	move.l	(a1)+,(a0)+
	dbf	d0,PBF4
	move.l	$50(a6),(a0)+
	move.w	$5A(a6),(a0)+
	move.l	$54(a6),(a0)+
	lea	$550(a6),a1
	cmpa.l	a0,a1
	bne.s	QB12
	lea	$3DE(a6),a0
QB12	move.l	a0,$550(a6)
	rts
	lea	KE74(pc),a2
	bsr	WC36
	move.b	#$10,$31(a3)
	tst.l	$424(a6)
	beq	RB1E
	moveq	#$30,d4
	moveq	#7,d5
	moveq	#6,d2
	bra.s	QB38
QB36	moveq	#8,d2
QB38	bsr	ID7C
	move.b	d4,d1
	bsr	QC52
	addq.b	#1,d4
	dbf	d5,QB36
	bsr	ID9A
	lea	$3DE(a6),a0
	movea.l	a0,a4
	lea	$550(a6),a2
	tst.l	$90(a0)
	beq.s	QB72
	tst.l	$DA(a0)
	beq.s	QB72
	tst.l	$124(a0)
	beq.s	QB72
	tst.l	$16E(a0)
	beq.s	QB72
	movea.l	$550(a6),a4
QB72	moveq	#$C,d1
	bsr	ID60
	moveq	#7,d3
QB7A	bsr	ID88
	move.l	(a4)+,d2
	bsr	IDA0
	dbf	d3,QB7A
	bsr	HC68
	moveq	#$D,d1
	bsr	ID60
	moveq	#7,d3
QB94	bsr	ID88
	move.l	(a4)+,d2
	bsr	IDA0
	dbf	d3,QB94
	bsr	HC68
	moveq	#2,d1
	bsr	ID60
	move.l	(a4)+,d2
	bsr	IDA0
	bsr	ID88
	moveq	#1,d1
	bsr	ID60
	move.w	(a4),d2
	bsr	IDA8
	bsr	ID88
	move.w	(a4)+,d4
	bsr	EDA8
	bsr	HC68
	moveq	#0,d1
	bsr	ID60
	move.l	(a4),d2
	bsr	IDA0
	bsr	ID88
	move.b	$31(a3),d2
	move.l	(a4),d0
	bsr	DE02
	beq.s	QBF0
	bsr	ZDE2
QBF0	addq.b	#1,d2
	bsr	ID7C
	move.l	a2,-(a7)
	movea.l	(a4)+,a2
	bsr	HDAC
	bsr	PCD0
	movea.l	(a7)+,a2
	bsr	HC68
	cmpa.l	a4,a2
	bne.s	RB10
	lea	$3DE(a6),a4
RB10	cmpa.l	$550(a6),a4
	beq.s	RB1E
	tst.l	$46(a4)
	bne	QB72
RB1E	bsr	HC78
	bra	VC2A

RB26	movem.l	d0-d2/a0-a2,-(a7)
	movea.l	$5B4(a6),a0
	movea.l	$56(a0),a0
	bsr	TB50
	beq.s	RB6C
	move.l	$14(a1),d1
	cmp.l	#$400,d1
	bne.s	RB60
	bsr	SB6E
	bmi.s	RB60
	cmp.w	#$1B,d1
	bne.s	RB60
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
	moveq	#0,d0
	bra.s	RB6E
RB60	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
RB6C	moveq	#-1,d0
RB6E	movem.l	(a7)+,d0-d2/a0-a2
	rts

RB74	movem.l	d0/d2/a0-a2,-(a7)
RB78	movea.l	$5B4(a6),a0
	movea.l	$56(a0),a0
	bsr	TB50
	beq.s	RB94
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
	bra.s	RB78
RB94	movem.l	(a7)+,d0/d2/a0-a2
	rts
RB9A	bsr.s	RB74
	bra.s	RBA6
RB9E	movem.l	d0/d2-d3/d7/a0-a3,-(a7)
	st	d7
	bra.s	RBAC
RBA6	movem.l	d0/d2-d3/d7/a0-a3,-(a7)
	sf	d7
RBAC	tst.l	$570(a6)
	beq.s	RBB6
	bsr	QCD6
RBB6	tst.b	d7
	beq.s	RBD8
	moveq	#0,d1
	move.b	NE74(pc),d0
	bset	d0,d1
	moveq	#0,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
	move.b	NE74(pc),d1
	btst	d1,d0
	bne.s	SB14
RBD8	movea.l	$5B4(a6),a0
	movea.l	$56(a0),a0
	bsr	TB50
	bne.s	SB2E
	moveq	#0,d0
	movea.l	$5B4(a6),a0
	movea.l	$56(a0),a0
	move.b	$F(a0),d1
	bset	d1,d0
	tst.b	d7
	beq.s	SB00
	move.b	NE74(pc),d1
	bset	d1,d0
SB00	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$13E(a6)
	movea.l	(a7)+,a6
	move.b	NE74(pc),d1
	btst	d1,d0
	beq.s	SB20
SB14	movem.l	d4-d7/a0-a5,-(a7)
	bsr	YC4
	movem.l	(a7)+,d4-d7/a0-a5
SB20	movea.l	$5B4(a6),a0
	movea.l	$56(a0),a0
	bsr	TB50
	beq.s	RBB6
SB2E	move.l	$14(a1),d1
	cmp.l	#$400,d1
	bne.s	SB5E
	bsr.s	SB6E
	smi	-(a7)
	move.w	d1,-(a7)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
	move.w	(a7)+,d1
	move.b	(a7)+,d0
	tst.w	d1
	beq	RBB6
	tst.b	d0
	movem.l	(a7)+,d0/d2-d3/d7/a0-a3
	rts
SB5E	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
	bra	RBB6
SB6E	move.l	a1,-(a7)
	lea	$828(a6),a0
	move.l	a0,-(a7)
	clr.l	(a0)+
	move.b	#1,(a0)+
	clr.b	(a0)+
	move.w	$18(a1),(a0)+
	move.w	$1A(a1),(a0)+
	movea.l	$1C(a1),a1
	move.l	(a1),(a0)
	movea.l	(a7)+,a0
	lea	$846(a6),a1
	clr.l	(a1)
	moveq	#4,d1
	suba.l	a2,a2
	move.l	a6,-(a7)
	movea.l	$80C(a6),a6
	jsr	-$30(a6)
	movea.l	(a7)+,a6
	movea.l	(a7)+,a1
	tst.l	d0
	ble.s	TB08
	move.w	$1A(a1),d3
	lea	$846(a6),a0
	move.b	(a0)+,d1
	subq.l	#1,d0
	beq.s	TB10
	cmp.b	#$9B,d1
	bne.s	TB0C
	move.b	(a0)+,d2
	lea	TB3A(pc),a2
	subq.l	#1,d0
	beq.s	SBF0
	lea	TB49(pc),a2
	subq.l	#1,d0
	beq.s	SBDE
	lea	TB4E(pc),a2
	move.b	(a0)+,d2
	cmpi.b	#$7E,(a0)
	beq.s	SBF0
	bra.s	TB0C
SBDE	move.w	#$87,d1
	cmp.b	#$3F,d2
	beq.s	SBFA
	cmp.b	#$20,d2
	bne.s	TB0C
	move.b	(a0)+,d2
SBF0	move.b	(a2)+,d0
	beq.s	TB0C
	move.b	(a2)+,d1
	cmp.b	d2,d0
	bne.s	SBF0
SBFA	cmp.b	#$D,d1
	bne.s	TB02
	moveq	#$A,d1
TB02	andi.w	#$FF,d1
	rts
TB08	moveq	#0,d1
	rts
TB0C	moveq	#$3F,d1
	rts
TB10	btst	#7,d3
	beq.s	SBFA
	cmp.b	#$61,d1
	bcs.s	TB32
	cmp.b	#$7B,d1
	bcc.s	TB32
	andi.b	#$DF,d1
	cmp.b	#$58,d1
	bne.s	TB32
	move.w	#$86,d1
	rts
TB32	andi.w	#$FF,d1
	moveq	#-1,d0
	rts

TB3A	dc.w	$4182,$4283,$4385,$4484,$5480,$5381,$5a88
	dc.b	0
TB49	dc.b	$40
	dc.w	$8a41,$8900

TB4E	dc.w	0

TB50	movem.l	d2/a2,-(a7)
	movea.l	a0,a2
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$174(a6)
	movea.l	(a7)+,a6
	move.l	d0,d2
	beq.s	TBE4
	movea.l	d0,a1
	cmpi.l	#$400,$14(a1)
	bne.s	TBE4
	btst	#1,$1A(a1)
	beq.s	TBE4
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	movea.l	$14(a2),a1
	movea.l	d2,a2
	bra.s	TBD0
TB8E	cmpi.l	#$400,$14(a1)
	bne.s	TBCE
	btst	#1,$1A(a1)
	beq.s	TBCE
	move.w	$18(a1),d0
	cmp.w	$18(a2),d0
	bne.s	TBCE
	movem.l	a0-a1,-(a7)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$FC(a6)
	movea.l	(a7)+,a6
	movea.l	4(a7),a1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$17A(a6)
	movea.l	(a7)+,a6
	movem.l	(a7)+,a0-a1
TBCE	movea.l	a0,a1
TBD0	movea.l	(a1),a0
	move.l	a0,d0
	bne.s	TB8E
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$8A(a6)
	movea.l	(a7)+,a6
	movea.l	d2,a1
TBE4	move.l	d2,d0
	movem.l	(a7)+,d2/a2
	rts
TBEC	dc.w	$3E,$C7A8,$3C,$C7B8
	dc.w	$2E,$C7F2,$2C,$C80A
	dc.w	$1B,$C362,$41,$C862
	dc.w	$42,$522,$44,$A26
	dc.w	$47,$1A6,$48,$FC06
	dc.w	$49,$9A8,$4C,$3EC2
	dc.w	$4D,$C3D4,$4E,$2D8
	dc.w	$4F,$CB0E,$50,$D7E
	dc.w	$152,$B2A,$53,$A9E
	dc.w	$155,$172,$56,$74
	dc.w	$57,$9CA,$101,$132
	dc.w	$202,$34,3,$80
	dc.w	$B,$4E,$30C,$11B0
	dc.w	$10,$5A6,$211,$10F8
	dc.w	$112,$E2,$113,$132
	dc.w	$114,$AA,$15,$117E
	dc.w	$418,$1142,$119,$DE
	dc.w	$11A,$DA,0
	cmpi.b	#3,$30(a3)
	bne.s	UB9A
	movea.l	$34(a3),a1
	pea	WC68(pc)
	bsr	OB3A
	beq	OB6C
	moveq	#1,d2
	moveq	#1,d3
	bra	NB9A
UB9A	rts

	lea	KE38(pc),a0
	bsr	CA82
	bne.s	UB9A
	bsr	OB5A
	bra	WC68

	bsr	WC24
	lea	ME3F(pc),a0
	lea	ME4C(pc),a1
	bsr	BAF0
	bsr	RB9A
	bsr	VCF8
	bra	VC2A

UBCA	tst.b	$134(a6)
	beq.s	UBDC
	lea	ME14(pc),a0
	bsr	CA82
	beq.s	UBDC
	rts
UBDC	bsr	OB5A
	bsr.s	UBE6
	bra	E18
UBE6	move.l	NE0C(pc),d1
	beq.s	VB0E
	clr.l	NE0C
	clr.l	$AA(a6)
	tst.b	$134(a6)
	bne.s	VB0E
	tst.l	$15E(a6)
	bne.s	VB0E
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$9C(a6)
	movea.l	(a7)+,a6
VB0E	rts
	bsr.s	VB1C
	bsr	RD6C
	beq	MB3C
	rts
VB1C	tst.l	$50(a6)
	beq.s	VB36
	btst	#0,$57(a6)
	bne.s	VB36
	movea.l	$54(a6),a2
	bsr	RD6C
	bne.s	VB36
	rts

VB36	addq.l	#4,a7
	lea	JED7(pc),a0
	bra	CA30

VB40	bsr.s	VB1C
	move.w	(a2),d1
	bclr	#7,$5A(a6)
	st	d3
	bra	AA74
	bsr.s	VB1C
	st	d3
	bset	#7,$5A(a6)
	movea.l	$54(a6),a1
	bsr	OB3A
	bne	AA90
	cmpi.w	#3,6(a0)
	bne	AA90
	bra	AA74
VB74	bsr.s	VB1C
	bclr	#7,$5A(a6)
	bsr	HD6A
	movea.l	a2,a1
	moveq	#1,d3
	moveq	#1,d2
	bsr	NB9A
	bne.s	VB92
	st	d3
	bra	AA74
VB92	rts
	bsr.s	VB1C
	bsr	HD6A
	move.l	a2,$54(a6)
	moveq	#$54,d2
	bsr	O66
	bra	WC68
	lea	KE18(pc),a0
	bsr	I9E
	bne.s	VB40
	rts
	cmpi.b	#2,$30(a3)
	bne.s	VBBE
	rts
VBBE	moveq	#5,d3
	bsr	BA98
	lea	KE7C(pc),a0
	bsr	ID70
	movea.l	$DE(a6),a0
	moveq	#$54,d1
	cmpi.b	#4,$30(a0)
	beq.s	WB1A
	moveq	#0,d3
	movem.w	6(a3),d2-d3
	divu.w	$D8(a6),d3
	bsr	PC0A
VBEA	bsr	RB9A
	bmi.s	VBEA
	cmp.b	#$1B,d1
	beq	WBF2
	andi.b	#$DF,d1
	cmp.b	#$42,d1
	beq.s	WB1A
	cmp.b	#$57,d1
	beq.s	WB1A
	cmp.b	#$4C,d1
	beq.s	WB1A
	cmp.b	#$54,d1
	beq.s	WB1A
	cmp.b	#$49,d1
	bne.s	VBEA
WB1A	move.b	d1,$B6F(a6)
	bsr	QC52
	bsr	BA2E
	lea	$AB4(a6),a4
	clr.b	(a4)
	moveq	#0,d4
	moveq	#1,d6
WB30	bsr	RC56
	bne	WBF2
	tst.b	(a4)
	beq	WBF2
	lea	$B6F(a6),a5
	move.b	(a5)+,d5
	cmp.b	#$49,d5
	beq.s	WBAE
	cmp.b	#$54,d5
	beq.s	WBAE
	clr.b	-4(a5)
WB54	move.b	(a4)+,d1
	tst.b	(a4)
	bne.s	WB72
	andi.b	#$DF,d1
	cmp.b	#$4C,d1
	beq.s	WB6E
	cmp.b	#$57,d1
	bne.s	WB72
	moveq	#2,d6
	bra.s	WBA4
WB6E	moveq	#4,d6
	bra.s	WBA4
WB72	subq.w	#1,a4
	bsr	JD76
	bne.s	WB9A
	cmp.b	#$42,d5
	beq.s	WB8E
	cmp.b	#$57,d5
	beq.s	WB8A
	move.l	d2,(a5)+
	bra.s	WB90
WB8A	move.w	d2,(a5)+
	bra.s	WB90
WB8E	move.b	d2,(a5)+
WB90	tst.b	d1
	beq.s	WBA4
	cmp.b	#$2C,d1
	beq.s	WB54
WB9A	bsr	VCDE
	lea	$AB4(a6),a4
	bra.s	WB30
WBA4	lea	$B70(a6),a0
	move.l	a5,d0
	sub.l	a0,d0
	bra.s	WBE2
WBAE	tst.b	$B6D(a6)
	lea	LE28(pc),a0
	bsr	CC78
	beq.s	WBC0
	spl	$B6D(a6)
WBC0	movea.l	a4,a0
	tst.b	$B6D(a6)
	beq.s	WBD4
WBC8	move.b	(a4)+,d1
	bsr	VD30
	move.b	d1,(a5)+
	bne.s	WBC8
	bra.s	WBD8
WBD4	move.b	(a4)+,(a5)+
	bne.s	WBD4
WBD8	move.l	a4,d0
	sub.l	a0,d0
	subq.l	#1,d0
	clr.b	$AB4(a6)
WBE2	move.b	d0,$B6C(a6)
	subq.b	#1,d6
	move.b	d6,$B6E(a6)
	bsr	VC2A
	bra.s	WBFA
WBF2	clr.w	$B6C(a6)
	bra	VC2A
WBFA	bsr	F90
	st	$E5(a6)
	moveq	#$E,d1
	bsr	ID60
	movea.l	$DE(a6),a0
	movea.l	$34(a0),a2
	move.b	$30(a0),d0
	move.w	$32(a0),d4
	cmp.b	#2,d0
	beq.s	XB4E
	move.b	d0,-(a7)
	bsr	PB26
	move.b	(a7)+,d0
	lea	$B6C(a6),a3
	moveq	#0,d3
	move.b	(a3)+,d3
	beq.s	XB4E
	addq.w	#1,a3
	moveq	#0,d6
	move.b	(a3)+,d6
	cmp.b	#4,d0
	beq	XBF6
	bsr	XB52
	move.b	(a3)+,d0
	cmp.b	#$49,d0
	bne.s	XB56
	bra	YB6C
XB4E	bra	F90
XB52	adda.l	d6,a2
XB54	jmp	(a5)
XB56	move.l	d6,d4
	not.l	d4
	move.l	a2,d1
	and.l	d1,d4
	movea.l	d4,a2
	move.b	(a3)+,d4
	subq.b	#1,d3
	moveq	#0,d5
	tst.b	$B6D(a6)
	beq.s	XB78
	bra.s	XBA4
XB6E	bsr	RB26
	bne.s	XB78
	move.l	a2,d7
	bra.s	XBE2
XB78	addq.w	#1,d5
	beq.s	XB6E
	bsr.s	XB52
	cmp.b	(a2),d4
	bne.s	XB78
	move.l	a2,d7
	tst.b	d3
	beq.s	XBE2
	movea.l	a3,a0
	move.b	d3,d0
XB8C	jsr	XB54
	beq.s	XBA0
	move.b	(a2),d1
	cmp.b	(a0)+,d1
	bne.s	XBA0
	subq.b	#1,d0
	bne.s	XB8C
	bra.s	XBE2
XBA0	movea.l	d7,a2
	bra.s	XB78
XBA4	bra.s	XBB0
XBA6	bsr	RB26
	bne.s	XBB0
	move.l	a2,d7
	bra.s	XBE2
XBB0	addq.w	#1,d5
	beq.s	XBA6
	bsr.s	XB52
	move.b	(a2),d1
	bsr	VD30
	cmp.b	d1,d4
	bne.s	XBB0
	move.l	a2,d7
	tst.b	d3
	beq.s	XBE2
	movea.l	a3,a0
	move.b	d3,d0
XBCA	bsr.s	XB54
	beq.s	XBDE
	move.b	(a2),d1
	bsr	VD30
	cmp.b	(a0)+,d1
	bne.s	XBDE
	subq.b	#1,d0
	bne.s	XBCA
	bra.s	XBE2
XBDE	movea.l	d7,a2
	bra.s	XBB0
XBE2	movea.l	$DE(a6),a0
	move.l	d7,$34(a0)
XBEA	bsr	FAA
	bra	WC68
XBF2	bra	FAA
XBF6	cmpi.b	#$54,(a3)+
	bne.s	XBF2
XBFC	bsr	GDDE
	beq.s	XBF2
	movea.l	a2,a0
	tst.b	$B6D(a6)
	bne.s	YB3C
YB0A	move.b	(a0)+,d1
	cmp.b	#$A,d1
	beq.s	XBFC
	cmp.b	(a3),d1
	bne.s	YB0A
	movem.l	d3/a0/a3,-(a7)
	addq.l	#1,a3
YB1C	subq.w	#1,d3
	beq.s	YB2A
	cmpm.b	(a0)+,(a3)+
	beq.s	YB1C
	movem.l	(a7)+,d3/a0/a3
	bra.s	YB0A
YB2A	movem.l	(a7)+,d3/a0/a3
	movea.l	$DE(a6),a3
	move.l	a2,$34(a3)
	move.w	d4,$32(a3)
	bra.s	XBEA
YB3C	move.b	(a0)+,d1
	cmp.b	#$A,d1
	beq.s	XBFC
	bsr	VD30
	cmp.b	(a3),d1
	bne.s	YB3C
	movem.l	d3/a0/a3,-(a7)
	addq.l	#1,a3
YB52	subq.w	#1,d3
	beq.s	YB2A
	move.b	(a0)+,d1
	bsr	VD30
	cmp.b	(a3)+,d1
	beq.s	YB52
	movem.l	(a7)+,d3/a0/a3
	bra.s	YB3C
YB66	move.l	a2,d7
	bra	XBE2
YB6C	move.l	a2,d0
	btst	#0,d0
	beq.s	YB78
	bsr	XB52

YB78	movea.l	a2,a1
	lea	9(a2),a2
	bsr	XB52
	exg	a1,a2
	suba.l	a2,a1
	cmpa.l	#$A,a1
	beq.s	YB96
	lea	9(a2),a2
	bsr	XB52
YB96	bsr	RB26
	beq.s	YB66
	movem.l	a4-a5,-(a7)
	movea.l	a2,a5
	movem.l	d6/a2,-(a7)
	bsr	DAD2
	move.l	(a7)+,d6
	moveq	#0,d0
	move.b	$B6C(a6),d0
	subq.b	#1,d0
	lea	$988(a6),a1
	lea	$B70(a6),a0
	move.b	(a0)+,d2
	tst.b	$B6D(a6)
	bne.s	YBFE
YBC4	move.b	(a1)+,d1
	cmp.b	d1,d2
	beq.s	YBD2
	cmp.b	#$A,d1
	bne.s	YBC4
	bra.s	YBE8
YBD2	tst.b	d0
	beq.s	YBF6
	movem.l	d0/a0-a1,-(a7)
	subq.w	#1,d0
YBDC	cmpm.b	(a0)+,(a1)+
	dbne	d0,YBDC
YBE2	movem.l	(a7)+,d0/a0-a1
	beq.s	YBF6
YBE8	movem.l	(a7)+,a2/a4-a5
	bsr	XB52
	bsr	XB52
	bra.s	YB78
YBF6	move.l	(a7)+,d7
	addq.l	#8,a7
	bra	XBE2
YBFE	move.b	(a1)+,d1
	bsr	VD30
	cmp.b	d1,d2
	beq.s	ZB10
	cmp.b	#$A,d1
	bne.s	YBFE
	bra.s	YBE8
ZB10	tst.b	d0
	beq.s	YBF6
	movem.l	d0/a0-a1,-(a7)
	subq.w	#1,d0
ZB1A	move.b	(a1)+,d1
	bsr	VD30
	cmp.b	(a0)+,d1
	dbne	d0,ZB1A
	bra.s	YBE2
	lea	JE7E(pc),a0
	moveq	#4,d3
	bsr	BAD8
	bsr	RC54
ZB36	bne	VC2A
	tst.b	(a4)
	beq	VC2A
	lea	$AB4(a6),a0
	moveq	#0,d2
ZB46	move.b	(a0)+,d1
	beq.s	ZB68
	cmp.b	#$2C,d1
	bne.s	ZB46
	movea.l	a0,a4
	move.l	a0,-(a7)
	bsr	JD62
	movea.l	(a7)+,a0
	beq.s	ZB66
	lea	$AB4(a6),a4
	bsr	RC56
	bra.s	ZB36
ZB66	clr.b	-(a0)
ZB68	bsr.s	ZB98
	bne.s	ZB84
	move.l	a3,$7C0(a6)
	move.l	a3,$644(a6)
	move.l	a3,$68A(a6)
	adda.l	d4,a3
	subq.l	#1,a3
	move.l	a3,$7C4(a6)
	bra	WC68
ZB84	rts
ZB86	moveq	#4,d3
	bsr	BAD8
	bsr	RC54
	bne.s	ZBF4
	tst.b	(a4)
	beq.s	ZBF4
	moveq	#0,d2
ZB98	move.l	d2,-(a7)
	bsr	VC2A
	lea	$AB4(a6),a5
	move.l	(a7)+,d2
ZBA4	move.l	d2,-(a7)
	bsr	RDE4
	movea.l	(a7)+,a0
	bne.s	ZBEC
	move.l	a0,-(a7)
	bsr	RDEE
	move.l	(a7)+,d0
	bne.s	ZBCA
	move.l	d4,d0
	addq.l	#1,d0
	bsr	FE6A
	beq.s	ZBE2
	move.b	#$A,0(a0,d4.l)
	move.l	a0,d0
ZBCA	movea.l	d0,a3
	movea.l	d0,a0
	bsr	SD2C
	bsr	SD76
	movea.l	a3,a0
	move.l	d4,d0
	bsr	OBA8
	moveq	#0,d0
	rts
ZBE2	moveq	#$67,d0
	move.w	d0,-(a7)
	bsr	SD76
	move.w	(a7)+,d0
ZBEC	bsr	CA5E
	moveq	#-1,d0
	rts
ZBF4	bsr	VC2A
	moveq	#-1,d0
	rts

	moveq	#$10,d3
	lea	KEDA(pc),a0
	bsr	BAD8
	lea	MEA5(pc),a0
	tst.b	$585(a6)
	bsr	CC78
	beq	AC1A
	spl	$585(a6)
AC1A	lea	ME82(pc),a0
	bsr	ID70
	moveq	#$4E,d1
	tst.b	$584(a6)
	beq.s	AC34
	moveq	#$44,d1
	tst.b	$584(a6)
	bpl.s	AC34
	moveq	#$48,d1
AC34	bsr	QC52
	subq.w	#1,6(a3)
	bsr	CCC4
AC40	bsr	RBA6
	bmi.s	AC40
	cmp.b	#$1B,d1
	beq	CC74
	cmp.b	#$A,d1
	beq.s	AC7E
	andi.b	#$DF,d1
	moveq	#1,d0
	cmp.b	#$44,d1
	beq.s	AC70
	moveq	#0,d0
	cmp.b	#$4E,d1
	beq.s	AC70
	moveq	#-1,d0
	cmp.b	#$48,d1
	bne.s	AC40
AC70	move.b	d0,$584(a6)
	bsr	QC52
	bsr	BA2E
	bra.s	AC86
AC7E	bsr	CCC4
	bsr	BA2E
AC86	lea	MEC1(pc),a0
	tst.b	$586(a6)
	bsr	CC78
	beq	AC9A
	spl	$586(a6)
AC9A	lea	LE09(pc),a0
	tst.b	$E6(a6)
	bsr	CC78
	beq	ACAE
	spl	$E6(a6)
ACAE	lea	LE3A(pc),a0
	bsr	ID70
	bsr	BA2E
	lea	$AB4(a6),a4
	move.b	#$5C,(a4)+
	moveq	#0,d1
	move.w	$7F6(a6),d1
	lea	CA7E(pc),a2
	bsr	IDE6
	clr.b	(a4)
	lea	$AB4(a6),a4
	bsr	FCF0
ACDA	lea	$AB4(a6),a4
	bsr	RC56
	bne	CC74
	bsr	JD62
	bne.s	ACDA
	cmp.l	#8,d2
	bcs.s	ACDA
	cmp.l	#$78,d2
	bcc.s	ACDA
	move.w	d2,$7F6(a6)
	bsr	BA2E
	lea	KEE6(pc),a0
	tst.b	$148(a6)
	bsr	CC78
	beq.s	BC16
	spl	$148(a6)
BC16	lea	MEE3(pc),a0
	tst.b	$587(a6)
	bsr	CC78
	beq.s	BC28
	spl	$587(a6)
BC28	lea	ME70(pc),a0
	bsr	ID70
	moveq	#$59,d1
	tst.b	A67
	bmi.s	BC46
	moveq	#$4E,d1
	tst.b	A67
	beq.s	BC46
	moveq	#$44,d1
BC46	bsr	QC52
	subq.w	#1,6(a3)
	bsr	CCC4
BC52	bsr	RBA6
	bmi.s	BC52
	cmp.b	#$1B,d1
	beq	CC74
	cmp.b	#$A,d1
	beq.s	BC92
	andi.b	#$DF,d1
	moveq	#-1,d0
	cmp.b	#$59,d1
	beq.s	BC82
	moveq	#0,d0
	cmp.b	#$4E,d1
	beq.s	BC82
	moveq	#1,d0
	cmp.b	#$44,d1
	bne.s	BC52
BC82	move.b	d0,A67
	bsr	QC52
	bsr	BA2E
	bra.s	BC9A
BC92	bsr	CCC4
	bsr	BA2E
BC9A	lea	ME2B(pc),a0
	bsr	ID70
	bsr	BA2E
	lea	$AB4(a6),a4
	lea	$864(a6),a0
	movea.l	a4,a1
BCB0	move.b	(a0)+,(a1)+
	bne.s	BCB0
	bsr	FCF0
BCB8	bsr	RC56
	bne	CC74
	lea	$AB4(a6),a4
	tst.b	(a4)
	beq.s	BCEA
	lea	$864(a6),a1
	movea.l	a4,a0
BCCE	cmpm.b	(a0)+,(a1)+
	bne.s	BCDA
	tst.b	-1(a0)
	bne.s	BCCE
	bra.s	BCF2
BCDA	lea	$AB4(a6),a0
	bsr	SDEE
	beq.s	BCF2
	bsr	VCDE
	bra.s	BCB8
BCEA	bsr	TD2E
	clr.b	$864(a6)
BCF2	bsr	BA2E
	bsr	BA2E
	lea	LEE8(pc),a0
	bsr	ID70
	bsr	CCC4
CC06	bsr	RB9A
	bmi.s	CC06
	andi.b	#$DF,d1
	cmp.b	#$59,d1
	bne.s	CC74
	lea	DC6A+11(pc),a0
	bsr	RDB8
	bne.s	CC6A
	lea	A64(pc),a0
	st	(a0)+
	move.b	$148(a6),(a0)+
	move.b	$E6(a6),(a0)+
	addq.l	#1,a0
	move.w	$7F6(a6),(a0)+
	lea	AB2(pc),a0
	move.b	$584(a6),(a0)+
	move.b	$585(a6),(a0)+
	move.b	$586(a6),(a0)+
	move.b	$587(a6),(a0)+
	move.w	$F0(a6),(a0)+
	lea	A72(pc),a0
	lea	$864(a6),a1
CC54	move.b	(a1)+,(a0)+
	bne.s	CC54
	lea	A64(pc),a0
	moveq	#$54,d4
	bsr	SD44
	bne.s	CC6A
	bsr	SD76
	bra.s	CC74
CC6A	move.l	d0,-(a7)
	bsr.s	CC74
	move.l	(a7)+,d0
	bra	CA5E
CC74	bra	VC2A
CC78	sne	-(a7)
	bsr	ID70
	moveq	#$4E,d1
	tst.b	(a7)+
	beq.s	CC86
	moveq	#$59,d1
CC86	bsr	QC52
	subq.w	#1,6(a3)
	bsr.s	CCC4
CC90	bsr	RB9A
	bmi.s	CC90
	cmp.b	#$1B,d1
	beq.s	CCE0
	cmp.b	#$A,d1
	beq.s	CCD8
	andi.b	#$DF,d1
	cmp.b	#$59,d1
	beq.s	CCB2
	cmp.b	#$4E,d1
	bne.s	CC90
CCB2	move.w	d1,-(a7)
	bsr	QC52
	bsr	BA2E
	move.w	(a7)+,d1
	cmp.b	#$4F,d1
	rts
CCC4	moveq	#0,d3
	movem.w	6(a3),d2-d3
	divu.w	$D8(a6),d3
	bsr	PC0A
CCD4	moveq	#0,d1
	rts
CCD8	bsr.s	CCC4
	bsr	BA2E
	bra.s	CCD4
CCE0	addq.l	#4,a7
	bra	VC2A
CCE6	st	$591(a6)
	tst.b	$162(a6)
	bne.s	DC24
	lea	DC6A+11(pc),a5
	bsr	RDE4
	beq.s	DC10
	movea.l	NE6C,a0
	moveq	#-1,d0
	move.l	d0,$B8(a0)
	lea	DC6A(pc),a5
	bsr	RDE4
	bne.s	DC24
DC10	lea	A64(pc),a0
	moveq	#$54,d4
	bsr	SD2C
	bsr	SD76
	move.b	A64(pc),d0
	beq.s	DC68
DC24	movea.l	NE6C,a0
	clr.l	$B8(a0)
	lea	A65(pc),a0
	move.b	(a0)+,$148(a6)
	move.b	(a0)+,$E6(a6)
	tst.b	(a0)+
	move.w	(a0)+,$7F6(a6)
	lea	AB2(pc),a0
	move.b	(a0)+,$584(a6)
	move.b	(a0)+,$585(a6)
	move.b	(a0)+,$586(a6)
	move.b	(a0)+,$587(a6)
	move.w	(a0)+,$F0(a6)
	tst.b	A6A
	bne.s	DC68
	move.b	#8,A6A
DC68	rts

DC6A	dc.b	'ENV:Devpac/MonAm.prefs',0,0

DC82	bsr	RC56
	bne.s	DCB2
	tst.b	(a4)
	beq.s	DCB2
	bsr	JD76
	bne.s	DCB4
	cmp.b	#$2C,d1
	bne.s	DCB4
	move.l	d2,d5
	bsr	JD76
	bne.s	DCB4
	cmp.b	#$2C,d1
	bne.s	DCB4
	move.l	d2,d6
	bsr	JD76
	bne.s	DCB4
	tst.b	d1
	bne.s	DCB4
DCB2	rts

DCB4	bsr	VCDE
	lea	$AB4(a6),a4
	bra.s	DC82

	moveq	#4,d3
	lea	LE4E(pc),a0
	bsr	BAD8
DCC8	lea	$AB4(a6),a4
	bsr.s	DC82
	bne.s	EC04
	cmp.l	d5,d6
	blt.s	DCC8
	movea.l	d2,a2
	movea.l	d6,a1
	movea.l	d5,a0
	sub.l	a0,d6
	beq.s	EC04
	movem.l	d6/a2,-(a7)
	addq.l	#1,d6
	cmpa.l	a0,a2
	bcc.s	DCF0
DCE8	move.b	(a0)+,(a2)+
	subq.l	#1,d6
	bne.s	DCE8
	bra.s	DCFC
DCF0	addq.l	#1,a1
	lea	0(a2,d6.l),a2
DCF6	move.b	-(a1),-(a2)
	subq.l	#1,d6
	bne.s	DCF6
DCFC	movem.l	(a7)+,d0/a0
	bsr	OBA8
EC04	bra	VC2A
	moveq	#4,d3
	lea	LE60(pc),a0
	bsr	BAD8
EC12	lea	$AB4(a6),a4
	bsr	DC82
	bne.s	EC04
	sub.l	d5,d6
	blt.s	EC12
	movea.l	d5,a0
	movem.l	d6/a0,-(a7)
EC26	move.b	d2,(a0)+
	subq.l	#1,d6
	bcc.s	EC26
	movea.l	d5,a0
	bra.s	DCFC
	moveq	#4,d3
	lea	LE74(pc),a0
	bsr	BAD8
	bsr	RC54
	bne	ECCC
	tst.b	(a4)
	beq	ECCC
	bsr	VC2A
	lea	$AB4(a6),a0
	tst.b	(a0)
	beq.s	ECCA
	move.l	a0,d1
	moveq	#-2,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$54(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	beq	CA52
	lea	$990(a6),a0
	move.l	a0,d2
	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$66(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	bne.s	ECA2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
EC8E	bsr	CA5E
	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$5A(a6)
	movea.l	(a7)+,a6
	rts
ECA2	move.l	#$D4,d0
	tst.l	$994(a6)
	ble.s	EC8E
	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$7E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$5A(a6)
	movea.l	(a7)+,a6
ECCA	rts
ECCC	bra	VC2A
	moveq	#7,d3
	lea	LE90(pc),a0
	bsr	BAD8
	bsr	RC56
	bne.s	FC54
	tst.b	(a4)
	beq.s	FC54
	bsr	BA2A
	lea	LEA6(pc),a0
	bsr	ID70
	bsr	BA2E
	clr.b	$AF0(a6)
	moveq	#0,d4
	bra.s	FC00
ECFC	bsr	VCDE
FC00	lea	$AF0(a6),a4
	bsr	RC56
	bne.s	FC54
	bsr	JD76
	bne.s	ECFC
	cmp.b	#$2C,d1
	bne.s	ECFC
	move.l	d2,d5
	bsr	JD76
	bne.s	ECFC
	tst.b	d1
	bne.s	ECFC
	move.l	d2,d4
	sub.l	d5,d4
	blt.s	ECFC
	addq.l	#1,d4
	lea	$AB4(a6),a0
	bsr	RDB8
	bne.s	FC46
	movea.l	d5,a0
	bsr	SD44
	bne.s	FC46
	bsr	SD76
	bsr	VCF8
	bra.s	FC54
FC46	move.w	d0,-(a7)
	bsr	VCF8
	bsr.s	FC54
	move.w	(a7)+,d0
	bra	CA5E
FC54	bra	VC2A
	moveq	#7,d3
	bsr	BA98
	lea	LEB8(pc),a0
	bsr	ID70
	bsr	CCC4
FC6A	bsr	RBA6
	cmp.b	#$1B,d1
	beq	FCEC
	andi.b	#$DF,d1
	cmp.b	#$47,d1
	beq.s	FC86
	cmp.b	#$49,d1
	bne.s	FC6A
FC86	move.w	d1,-(a7)
	bsr	QC52
	bsr	BA2A
	move.w	(a7)+,d1
	cmp.b	#$47,d1
	beq.s	FCE6
	lea	$AB4(a6),a4
	move.l	$194(a6),d1
	beq.s	FCA6
	bsr	DA18
FCA6	clr.b	(a4)
	lea	$AB4(a6),a4
	bsr.s	FCF0
FCAE	lea	$AB4(a6),a4
	bsr	RC56
	bne.s	FCEC
	tst.b	(a4)
	beq.s	FCEC
	bsr	JD62
	bne.s	FCAE
	move.l	d2,$194(a6)
	moveq	#3,d7
	bsr	BA2A
	move.w	d7,-(a7)
	bsr.s	FCEC
	move.w	(a7)+,d3
	bsr	VB1C
	move.b	d3,$14A(a6)
	bset	#7,$5A(a6)
	st	d3
	bra	AA90
FCE6	bsr.s	FCEC
	bra	VB40
FCEC	bra	VC2A
FCF0	move.l	a4,d4
FCF2	tst.b	(a4)+
	bne.s	FCF2
	exg	d4,a4
	sub.l	a4,d4
	subq.w	#1,d4
	rts

FCFE	pea	FBA(pc)
	lea	LECD(pc),a2
	bsr	WC36
	moveq	#$16,d1
	bsr	ID60
	moveq	#7,d7
	lea	$198(a6),a4
GC16	move.w	6(a4),d1
	beq.s	GC70
	move.l	(a4),d2
	bsr	IDA0
	bsr	ID88
	moveq	#-1,d2
	moveq	#$16,d2
	move.l	(a4),d0
	bsr	DE02
	beq.s	GC36
	bsr	ZDE2
GC36	addq.b	#1,d2
	bsr	ID7C
	movea.l	(a4),a2
	bsr	HDAC
	cmpi.w	#4,6(a4)
	bne.s	GC68
	bsr	HC68
	moveq	#9,d2
	bsr	ID7C
	moveq	#$3F,d1
	bsr	QC52
	lea	$C(a4),a2
GC5E	move.b	(a2)+,d1
	beq.s	GC68
	bsr	QC52
	bra.s	GC5E
GC68	bsr	HC68
	bsr	HC68
GC70	lea	$48(a4),a4
	dbf	d7,GC16
	moveq	#$29,d1
	bsr	ID60
	moveq	#$26,d1
	move.b	$134(a6),d0
	beq.s	GC8E
	moveq	#$25,d1
	tst.b	d0
	bpl.s	GC8E
	moveq	#$27,d1
GC8E	bsr	ID60
	bsr	HC68
	moveq	#$2A,d1
	bsr	ID60
	bsr	HC68
	tst.b	$134(a6)
	beq.s	GCE6
	movea.l	NE0C(pc),a2
GCAA	adda.l	a2,a2
	adda.l	a2,a2
	moveq	#4,d2
	add.l	a2,d2
	move.l	d2,-(a7)
	bsr	IDA0
	moveq	#$2D,d1
	bsr	QC52
	move.l	(a7),d2
	add.l	-4(a2),d2
	subq.l	#8,d2
	bsr	IDA0
	bsr	ID88
	move.l	(a7)+,d0
	bsr	DE02
	beq.s	GCDC
	moveq	#$20,d2
	bsr	ZDE2
GCDC	bsr	HC68
	movea.l	(a2),a2
	move.l	a2,d0
	bne.s	GCAA
GCE6	moveq	#$28,d1
	bsr	ID60
	moveq	#2,d1
	bsr.s	HC08
	moveq	#$2C,d1
	bsr	QC52
	moveq	#4,d1
	bsr.s	HC08
	moveq	#$2C,d1
	bsr	QC52
	moveq	#0,d1
	bsr.s	HC08
	bsr.s	HC68
	bra.s	HC1E
HC08	bset	#0,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D8(a6)
	movea.l	(a7)+,a6
	move.l	d0,d1
	bra	IDE2
HC1E	moveq	#$2B,d1
	bsr	ID60
	bsr.s	HC68
	movea.l	4.w,a0
	movea.l	$142(a0),a2
HC2E	tst.l	(a2)
	beq.s	HC62
	move.l	a2,d2
	cmp.l	#$40000,d2
	bcc.s	HC3E
	moveq	#0,d2
HC3E	bsr	IDA0
	moveq	#$2D,d1
	bsr	QC52
	move.l	$18(a2),d2
	bsr	IDA0
	bsr	ID88
	movea.l	$A(a2),a0
	bsr	ID70
	bsr.s	HC68
	movea.l	(a2),a2
	bra.s	HC2E
HC62	bsr.s	HC78
HC64	bra	VC2A
HC68	bsr	ID9A
	move.w	8(a3),d0
	cmp.w	4(a3),d0
	bge.s	HC78
	rts
HC78	movem.l	d2-d7/a2-a5,-(a7)
HC7C	bsr	RBA6
	bmi.s	HC9E
	cmp.b	#$1B,d1
	beq.s	HC96
	bsr	OC34
	movem.l	(a7)+,d2-d7/a2-a5
	clr.l	6(a3)
	rts

HC96	movem.l	(a7)+,d2-d7/a2-a5
	addq.l	#4,a7
	bra.s	HC64

HC9E	move.l	a3,-(a7)
	bsr	H86
	movea.l	(a7)+,a3
	bra.s	HC7C

	lea	LED2(pc),a0		; start of disassembly
	moveq	#$A,d3
	bsr	BAD8			; draw box, print start,end text
	clr.l	$174(a6)
	bra.s	HCBC

HCB8	bsr	VCDE

HCBC	lea	$AB4(a6),a4		; dest area for input
	bsr	RC56			; get start,end from user
	bne	JCC2
	tst.b	(a4)
	beq	JCC2
	bsr	JD76			; get start into d2
	bne.s	HCB8

	cmp.b	#',',d1
	bne.s	HCB8
	addq.l	#1,d2
	andi.b	#$FE,d2
	move.l	d2,$16C(a6)		; save even start address

	bsr	JD76			; get end into d2
	bne.s	HCB8
	cmp.l	$16C(a6),d2
	ble.s	HCB8			; check greater than start
	move.l	d2,$170(a6)		; save end address

	movea.l	d2,a2
	bsr	RD6C			; check end memory area is valid
	bne.s	HCB8

	movea.l	$16C(a6),a2
	bsr	RD6C			; check start memory area is valid
	bne.s	HCB8

	bsr	BA2E			; set some values

	moveq	#$18,d1
	bsr	ID60			; display cross-reference text

	bsr	BA2E			; set some values

	clr.b	$AB4(a6)
	moveq	#0,d4
	bra.s	IC20

IC1C	bsr	VCDE

IC20	lea	$AB4(a6),a4		; dest area for input
	bsr	RC56			; get start,end from user
	bne	JCC2
	sf	$163(a6)
	tst.b	(a4)
	beq.s	IC7A
	bsr	JD76			; get start into d2
	bne.s	IC1C

	move.l	d2,$164(a6)		; save cross-reference start address
	clr.l	$168(a6)
	tst.b	d1
	beq.s	IC60
	cmp.b	#',',d1
	bne.s	IC1C

	bsr	JD76			; get end into d2
	bne.s	IC1C
	tst.b	d1
	bne.s	IC1C
	cmp.l	$164(a6),d2
	bcs.s	IC1C
	move.l	d2,$168(a6)		; save cross-reference end address

IC60	move.l	$164(a6),d2
	btst	#0,d2
	bne.s	IC1C			; check cross-reference start is even

	move.l	d2,d0
	bsr	RDA6			; check something about start
	bne.s	IC1C

	addq.b	#1,$163(a6)		; flag cross-reference entered
	movea.l	d2,a0
	clr.l	(a0)			; clear first cross-reference long

IC7A	bsr	BA2E			; set some values

	moveq	#$17,d1
	bsr	ID60			; display data area text

	bsr	BA2E			; set some values

;	lea	$AF0(a6),a5		; start address of data areas
	lea	file.dsm.data.areas(pc),a5

IC8C	moveq	#0,d4
	clr.b	$AB4(a6)
	bra.s	IC98

IC94	bsr	VCDE

IC98	lea	$AB4(a6),a4
	bsr	RC56			; get start,end,type from user
	bne	JCC2
	tst.b	(a4)
	beq.s	JC08
	bsr	JD76			; get start into d2
	bne.s	IC94

	cmp.b	#',',d1
	bne.s	IC94
	move.l	d2,(a5)			; save data start address

	bsr	JD76			; get end into d2
	bne.s	IC94

	cmp.l	(a5),d2
	ble.s	IC94

	moveq	#0,d0
	tst.b	d1
	beq.s	ICE8
	cmp.b	#',',d1
	bne.s	IC94

	move.b	(a4)+,d1
	andi.b	#$DF,d1			; capitalize data size
	cmp.b	#'B',d1
	beq.s	ICE8

	moveq	#1,d0
	cmp.b	#'W',d1
	beq.s	ICE8

	moveq	#2,d0
	cmp.b	#'L',d1
	bne.s	IC94

ICE8	move.l	(a5),d1
	addq.l	#1,d1
	andi.b	#$FE,d1
	move.l	d1,(a5)+		; save even start address

	addq.l	#1,d2
	andi.b	#$FE,d2
	move.l	d2,(a5)+		; save even end address

	move.w	d0,(a5)+		; save data size

	move.w	#4,6(a3)
	bsr	PCD0			; clear entered text
	bra.s	IC8C

* all data areas now input

JC08	clr.l	(a5)			; terminate data areas

	bsr	BA2E			; set some values

	moveq	#$19,d1
	bsr	ID60			; display filename text

	bsr	BA2E			; set some values

	clr.b	$AB4(a6)
	moveq	#0,d4

JC1E	lea	$AB4(a6),a4
	bsr	RC56			; get filename from user
	bne	JCC2
	tst.b	(a4)
	beq.s	JC44

	movea.l	a4,a0
	bsr	RDB8			; attempt to open file
	beq.s	JC3C
	bsr	VCF8			; screen to front
	bra.s	JC1E

JC3C	bsr	VCF8			; screen to front
	bsr	SD86

JC44	movea.l	$16C(a6),a5		; disassembly start address
	tst.b	$163(a6)
	beq.s	JC96			; if no cross-reference list needed

* create cross-reference list
* - this is just a list of addresses that require labels

JC4E	cmpa.l	$170(a6),a5		; disassembly end address
	bgt.s	JC8E

	bsr	JCD8			; test if data area
	bne.s	JC88

	move.b	9(a2),d0
	beq.s	JC7E
	subq.b	#1,d0
	beq.s	JC74

JC64	move.l	(a5),d0			; long data
	bsr	DE02			; store in cross-reference list
	addq.l	#4,a5			; (if within program space)
	cmpa.l	4(a2),a5
	blt.s	JC64
	bra.s	JC4E

JC74	addq.l	#2,a5			; word data
	cmpa.l	4(a2),a5
	blt.s	JC74
	bra.s	JC4E

JC7E	addq.l	#1,a5			; byte data
	cmpa.l	4(a2),a5
	blt.s	JC7E
	bra.s	JC4E

* disassemble instruction as normal, but relevant addresses
* will be stored in cross-reference list at the same time

JC88	bsr	DAD2			; disassemble
	bra.s	JC4E

JC8E	st	$163(a6)
	movea.l	$16C(a6),a5

JC96	tst.l	$174(a6)
	bne.s	JCB8
	bsr	TDAE
	bne.s	JCB8
	sf	$E4(a6)
	sf	$163(a6)
	bsr	VC2A
	lea	KE93(pc),a0
	bsr	CA30
	bra.s	JCCE

JCB8	st	$E4(a6)
	bsr	ID9A

* disassemble instructions one at a time
* process each one (spaces to tabs, etc.)
* append instructions to buffer
* write buffer to file once it is full

	bsr.s	JCF8

JCC2	sf	$E4(a6)
	sf	$163(a6)
	bsr	VC2A			; restore screen contents

JCCE	tst.l	$174(a6)
	bne	SD94			; write last part to file, then close
	rts

JCD8	;lea	$AF0(a6),a2		; start address of data areas
	lea	file.dsm.data.areas(pc),a2

JCDC	move.l	(a2),d0
	beq.s	JCF4
	cmpa.l	d0,a5
	blt.s	JCEE
	cmpa.l	4(a2),a5
	bge.s	JCEE

	moveq	#0,d0			; a5 is within a data area
	rts

JCEE	lea	$A(a2),a2
	bra.s	JCDC

JCF4	moveq	#-1,d0			; a5 is not within a data area
	rts

JCF8	cmpa.l	$170(a6),a5
	ble.s	KC00
JCFE	rts

KC00	tst.b	$E4(a6)
	bpl.s	JCFE
	bsr.s	JCD8			; test if data area
	bne	KC9E

* disassemble data areas

	move.l	a5,-(a7)
	lea	$988(a6),a4
	move.l	#$64632E62,(a4)+	; 'dc.b'
	subq.l	#1,a4
	move.b	9(a2),d0
	beq.s	KC70
	subq.w	#1,d0
	beq.s	KC4A

	move.b	#$6C,(a4)+		; convert long data
	move.b	#$20,(a4)+

;	moveq	#2-1,d4
	moveq	#6-1,d4

KC2E	move.l	(a5)+,d1
	bsr	CAE2			; convert long
	move.b	#$2C,(a4)+
	move.l	a5,d0
	bsr	DE02			; test if in cross-reference list
	bne.s	KC94
	cmpa.l	4(a2),a5
	dbge	d4,KC2E
	bra.s	KC94

KC4A	move.b	#$77,(a4)+		; convert word data
	move.b	#$20,(a4)+

;	moveq	#4-1,d4
	moveq	#10-1,d4

KC54	move.w	(a5)+,d1
	bsr	CADA			; convert word
	move.b	#$2C,(a4)+
	move.l	a5,d0
	bsr	DE02			; test if in cross-reference list
	bne.s	KC94
	cmpa.l	4(a2),a5
	dbge	d4,KC54
	bra.s	KC94

KC70	move.b	#$62,(a4)+		; convert byte data
	move.b	#$20,(a4)+

;	moveq	#8-1,d4
	moveq	#16-1,d4

KC7A	move.b	(a5)+,d1
	bsr	CAC8			; convert byte
	move.b	#$2C,(a4)+
	move.l	a5,d0
	bsr	DE02			; test if in cross-reference list
	bne.s	KC94
	cmpa.l	4(a2),a5
	dbge	d4,KC7A

KC94	move.b	#$A,-1(a4)
	movea.l	(a7)+,a4
	bra.s	KCAA

* disassemble code areas

KC9E	movem.l	d3-d7/a5,-(a7)
	bsr	DAD2
	movem.l	(a7)+,d3-d7/a4

KCAA	move.l	a5,d4
	sub.l	a4,d4
	bsr.s	KCEC
	lea	$988(a6),a4
	moveq	#-1,d2
KCB6	addq.b	#1,d2
	move.b	(a4)+,d1
	cmp.b	#$A,d1
	beq.s	KCE4
	cmp.b	#$20,d1
	bne.s	KCDE
	moveq	#7,d0
	sub.b	d2,d0
	bcs.s	KCDE
	moveq	#9,d1
	tst.l	$174(a6)
	bne.s	KCDC
	move.b	d0,d2
	bsr	ID7C
	moveq	#$20,d1
KCDC	moveq	#8,d2
KCDE	bsr	QC52
	bra.s	KCB6

KCE4	bsr	ID9A
	bra	JCF8

KCEC	tst.l	$174(a6)
	bne.s	LC36
	move.l	a4,d2
	bsr	IDA0
	bsr	ID88
	moveq	#0,d3
KCFE	cmp.w	d4,d3
	bge.s	LC14
	move.b	0(a4,d3.w),d2
	bsr	IDB0
LC0A	addq.w	#1,d3
	cmp.w	#$A,d3
	bne.s	KCFE
	bra.s	LC1E

LC14	bsr	ID88
	bsr	ID88
	bra.s	LC0A
LC1E	bsr	ID88
	moveq	#$C,d2
	move.l	a4,d0
	bsr	DE02
	beq.s	LC30
	bsr	ZDE2
LC30	addq.b	#1,d2
	bra	ID7C
LC36	move.l	a4,d0
	bsr	DE02
	beq.s	LC4C
	movea.l	d0,a4
	move.l	d4,-(a7)
	move.l	(a4)+,d4
	asl.l	#2,d4
	bsr	AE1E
	move.l	(a7)+,d4
LC4C	moveq	#9,d1
	bra	QC52
	lea	ME57(pc),a0
	bsr	CA82
	bne.s	LC9A
	lea	VEC(pc),a4
	moveq	#$14,d4
	move.b	NE0B(pc),d0
	bne.s	LC9A
	tst.b	$134(a6)
	bmi.s	LC9C
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	movea.l	NE70(pc),a0
	movea.l	$36(a0),a0
	move.l	a4,(a0)
	bclr	#7,4(a0)
	move.l	d4,8(a0)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$8A(a6)
	movea.l	(a7)+,a6
LC9A	rts
LC9C	move.l	a4,$54(a6)
	bclr	#7,$5A(a6)
	move.l	d4,$10(a6)
	st	d3
	bra	AA90

	lea	ME4D(pc),a0
	bsr	CA82
	bne.s	LC9A
	move.b	NE0B(pc),d0
	bne.s	LC9A
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	movea.l	NE70(pc),a0
	movea.l	$36(a0),a0
	bset	#7,4(a0)
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$8A(a6)
	movea.l	(a7)+,a6
	rts
	tst.l	$15E(a6)
	bne.s	MC00
	tst.l	$AE(a6)
	beq.s	MC00
	lea	ME61(pc),a0
	bsr	CA82
	beq	VD46
MC00	rts
MC02	clr.b	$162(a6)
	moveq	#7,d3
	lea	JEA3(pc),a0
	bsr	BAD8
	bsr	RC54
	bne.s	MC42
	tst.b	(a4)
	beq.s	MC42
	bsr	BA2A
	lea	JEBB(pc),a0
	bsr	ID70
	bsr	BA2E
	lea	$AF0(a6),a4
	clr.b	(a4)
	bsr	RC54
	bne.s	MC42
	move.l	a4,-(a7)
	bsr.s	MC42
	movea.l	(a7)+,a4
	lea	$AB4(a6),a3
	bra.s	MC46
MC42	bra	VC2A
MC46	bsr	UBE6
	bsr	VD42
	move.l	a3,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$96(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	beq	CA52
MC62	move.l	d0,NE0C
	add.l	d0,d0
	add.l	d0,d0
	addq.l	#4,d0
	move.l	d0,$AA(a6)
	lea	TB4+1(pc),a0
	movea.l	a3,a1
	lea	TB4(pc),a2
	st	(a2)
MC7E	addq.b	#1,(a2)
	move.b	(a1)+,(a0)+
	bne.s	MC7E
	clr.b	-(a0)
	movem.l	d4-d7/a3-a5,-(a7)
	move.l	a3,-(a7)
	bsr	F90
	movea.l	(a7)+,a0
	bsr	VD82
	bsr	CE1A
	bsr	F90
	movem.l	(a7)+,d4-d7/a3-a5
	movea.l	a4,a0
	lea	UEC(pc),a1
	clr.b	(a1)+
MCAA	move.b	(a0)+,(a1)+
	bne.s	MCAA
	cmpi.b	#$A,-2(a1)
	beq.s	MCBE
	move.b	#$A,-1(a1)
	clr.b	(a1)
MCBE	move.l	a1,d0
	lea	UEC+1(pc),a0
	sub.l	a0,d0
	move.b	d0,-(a0)
	movea.l	$AA(a6),a1
	move.l	a1,$68A(a6)
	moveq	#1,d3
	moveq	#1,d2
	bsr	NB9A
	movea.l	$AA(a6),a1
	movea.l	a1,a0
	move.w	(a1),NE10
	move.w	#$4EF9,(a1)+
	move.l	(a1),NE12
	move.l	#TF8,(a1)
	moveq	#6,d0
	bsr	OBA8
	movea.l	NE6C(pc),a0
	movea.l	$BA(a6),a1
	cmpi.w	#$25,$14(a1)
	bcs	NC9E
	move.l	a7,d2
	clr.l	-(a7)
	move.l	NE0C(pc),-(a7)
	move.l	#$800003E9,-(a7)
	clr.l	-(a7)
	move.l	#$800003EA,-(a7)
	pea	1.w
	move.l	#$800003FA,-(a7)
	pea	UEC+1(pc)
	move.l	#$800003FD,-(a7)
	move.l	$B2(a6),-(a7)
	addi.l	#$50,(a7)
	move.l	#$800003F3,-(a7)
	pea	TB4(pc)
	move.l	#$800003FC,-(a7)
	move.l	$9C(a0),-(a7)
	move.l	#$800003EC,-(a7)
	move.l	$A0(a0),-(a7)
	move.l	#$800003ED,-(a7)
	move.l	$E0(a0),-(a7)
	bne.s	NC6E
	move.l	$A0(a0),(a7)
NC6E	move.l	#$800003F0,-(a7)
	clr.l	-(a7)
	move.l	#$800003EE,-(a7)
	clr.l	-(a7)
	move.l	#$800003EF,-(a7)
	clr.l	-(a7)
	move.l	#$800003F1,-(a7)
	move.l	a7,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1F2(a6)
	movea.l	(a7)+,a6
	movea.l	d2,a7
	bra.s	NCEC
NC9E	move.l	$AC(a0),d0
	add.l	d0,d0
	add.l	d0,d0
	movea.l	d0,a0
	moveq	#$F,d0
	lea	UAC(pc),a1
NCAE	move.l	(a0)+,(a1)+
	dbf	d0,NCAE
	move.l	#TB4,d1
	lsr.l	#2,d1
	move.l	d1,UBC
	move.l	NE0C(pc),UE8
	move.l	a3,d1
	moveq	#0,d2
	movea.l	NE6C(pc),a0
	move.b	9(a0),d2
	move.l	NE0C(pc),d3
	moveq	#$50,d4
	add.l	$B2(a6),d4
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$8A(a6)
	movea.l	(a7)+,a6
NCEC	move.l	d0,$10A(a6)
	beq.s	NCFC
	move.b	#1,$134(a6)
	bsr	QCC
NCFC	rts
NCFE	movem.w	d2-d3,(a3)
	movem.w	d0-d1,$A(a3)
	clr.l	6(a3)
	move.w	$A(a3),d0
	move.w	d0,$E(a3)
	mulu.w	$D6(a6),d0
	move.w	d0,$A(a3)
	st	$10(a3)
	move.w	2(a3),d0
	mulu.w	$D8(a6),d0
	move.w	d0,4(a3)
	rts
OC2E	bsr.s	NCFE
	sf	$10(a3)
OC34	move.w	4(a3),d3
	move.l	a2,-(a7)
	moveq	#0,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	movem.w	$A(a3),d0-d1
	move.w	(a3),d2
	mulu.w	$D6(a6),d2
	add.w	d0,d2
	subq.w	#1,d2
	add.w	d1,d3
	subq.w	#1,d3
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
	moveq	#1,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	movea.l	(a7)+,a2
	rts
OC86	move.b	d1,-(a7)
	mulu.w	$D6(a6),d2
	add.w	$A(a3),d2
	add.w	$C(a3),d3
	add.w	$DA(a6),d3
	move.w	d2,d0
	move.w	d3,d1
	movea.l	a5,a1
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$F0(a6)
	movea.l	(a7)+,a6
	movea.l	a5,a1
	tst.b	d7
	bne.s	OCCC
	movea.l	a7,a0
	moveq	#1,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$3C(a6)
	movea.l	(a7)+,a6
OCC8	addq.l	#2,a7
	rts
OCCC	moveq	#5,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$162(a6)
	movea.l	(a7)+,a6
	movea.l	a7,a0
	moveq	#1,d0
	movea.l	a5,a1
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$3C(a6)
	movea.l	(a7)+,a6
	moveq	#1,d0
	movea.l	a5,a1
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$162(a6)
	movea.l	(a7)+,a6
	bra.s	OCC8
PC0A	mulu.w	$D8(a6),d3
PC0E	movem.w	d2-d3,-(a7)
	moveq	#3,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$162(a6)
	movea.l	(a7)+,a6
	movem.w	(a7)+,d0-d1
	mulu.w	$D6(a6),d0
	add.w	$A(a3),d0
	add.w	$C(a3),d1
	move.w	d0,d2
	add.w	$D6(a6),d2
	subq.w	#1,d2
	move.w	d1,d3
	add.w	$D8(a6),d3
	subq.w	#1,d3
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
	moveq	#1,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$162(a6)
	movea.l	(a7)+,a6
	rts
PC68	movem.l	d3-d5,-(a7)
	tst.b	d0
	spl	d1
	ori.b	#1,d1
	ext.w	d1
	muls.w	$D8(a6),d1
	moveq	#0,d0
	movem.w	$A(a3),d2-d3
	move.w	$D6(a6),d4
	mulu.w	(a3),d4
	add.w	d2,d4
	subq.w	#1,d4
	move.w	2(a3),d5
	mulu.w	$D8(a6),d5
	add.w	d3,d5
	subq.w	#1,d5
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$18C(a6)
	movea.l	(a7)+,a6
	movem.l	(a7)+,d3-d5
	rts
PCAE	moveq	#-1,d0
	bsr.s	PC68
	move.w	2(a3),d0
	subq.w	#1,d0
	mulu.w	$D8(a6),d0
	move.w	d0,8(a3)
	clr.w	6(a3)
	rts
PCC6	moveq	#0,d0
	bsr.s	PC68
	clr.l	6(a3)
PCCE	rts
PCD0	tst.b	$E4(a6)
	bne.s	PCCE
	tst.l	$570(a6)
	beq.s	PCE0
	bsr	QCD6
PCE0	moveq	#0,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	move.w	6(a3),d0
	mulu.w	$D6(a6),d0
	add.w	$A(a3),d0
	move.w	8(a3),d1
	add.w	$C(a3),d1
	move.w	(a3),d2
	mulu.w	$D6(a6),d2
	add.w	$A(a3),d2
	cmp.w	d0,d2
	ble.s	QC2E
	subq.w	#1,d2
	move.w	d1,d3
	add.w	$D8(a6),d3
	subq.w	#1,d3
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$132(a6)
	movea.l	(a7)+,a6
QC2E	moveq	#1,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	rts
QC42	addi.b	#$30,d1
	bra	QC52
QC4A	movem.l	d0-d3/d7/a0-a2,-(a7)
	st	d3
	bra.s	QC58

QC52	movem.l	d0-d3/d7/a0-a2,-(a7)
	sf	d3
QC58	tst.b	$E4(a6)
	bne	TD46
	cmpa.l	$570(a6),a3
	beq.s	QC7E
	move.w	d1,-(a7)
	bsr.s	QCD6
	move.w	(a7)+,d1
	tst.b	$10(a3)
	beq.s	QCA0
	move.l	a3,$570(a6)
	lea	$924(a6),a0
	move.l	a0,$574(a6)
QC7E	tst.b	d3
	bne.s	QC88
	cmp.b	#$A,d1
	beq.s	QC98
QC88	movea.l	$574(a6),a0
	move.b	d1,(a0)+
	move.l	a0,$574(a6)
	movem.l	(a7)+,d0-d3/d7/a0-a2
	rts

QC98	bsr.s	QCD6
	move.l	a3,$570(a6)
	bra.s	QCC8
QCA0	tst.b	d3
	bne.s	QCAA
	cmp.b	#$A,d1
	beq.s	QCC8
QCAA	move.w	6(a3),d0
	cmp.w	(a3),d0
	beq.s	QCC2
	movem.w	6(a3),d2-d3
	addq.w	#1,6(a3)
	moveq	#0,d7
	bsr	OC86
QCC2	movem.l	(a7)+,d0-d3/d7/a0-a2
	rts
QCC8	clr.w	6(a3)
	move.w	$D8(a6),d0
	add.w	d0,8(a3)
	bra.s	QCC2
QCD6	tst.l	$570(a6)
	beq.s	RC4E
	movem.l	d3/a3,-(a7)
	movea.l	$570(a6),a3
	movem.w	6(a3),d2-d3
	cmp.w	4(a3),d3
	bge.s	RC42
	mulu.w	$D6(a6),d2
	add.w	$A(a3),d2
	add.w	$C(a3),d3
	add.w	$DA(a6),d3
	move.w	d2,d0
	move.w	d3,d1
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$F0(a6)
	movea.l	(a7)+,a6
	move.l	$574(a6),d0
	lea	$924(a6),a0
	sub.l	a0,d0
	beq.s	RC42
	move.w	(a3),d1
	sub.w	6(a3),d1
	cmp.w	d1,d0
	blt.s	RC2C
	move.w	d1,d0
RC2C	add.w	d0,6(a3)
	ext.l	d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$3C(a6)
	movea.l	(a7)+,a6
RC42	lea	$924(a6),a0
	move.l	a0,$574(a6)
	movem.l	(a7)+,d3/a3
RC4E	clr.l	$570(a6)
	rts
RC54	moveq	#0,d4
RC56	movea.l	a4,a0
RC58	tst.b	(a0)+
	bne.s	RC58
	move.l	a0,d5
	sub.l	a4,d5
	subq.w	#1,d5
	bsr	SCA0
	bsr	SC8A
RC6A	move.w	8(a3),d3
	moveq	#4,d2
	add.w	d4,d2
	bsr	PC0E
RC76	bsr	RBA6
	bmi.s	RC76
	cmp.b	#$A,d1
	beq	SC64
	cmp.b	#$1B,d1
	beq	SC64
	cmp.b	#8,d1
	beq	SC2C
RC94	cmp.b	#$7F,d1
	beq	SC4C
	cmp.w	#$86,d1
	beq	SC6C
	cmp.w	#$84,d1
	beq.s	RCFC
	cmp.w	#$85,d1
	beq.s	SC08
	cmp.w	#$89,d1
	beq.s	SC14
	cmp.w	#$8A,d1
	beq.s	SC20
	tst.b	d1
	beq.s	RC76
	cmp.b	#$80,d1
	bcs.s	RCCC
	cmp.b	#$A0,d1
	bcs.s	RC76
RCCC	cmp.w	$E2(a6),d5
	beq.s	RC76
	move.w	d5,d0
	addq.w	#1,d5
	sub.w	d4,d0
	beq.s	RCE6
	lea	-1(a4,d5.w),a0
RCDE	move.b	-(a0),1(a0)
	subq.w	#1,d0
	bne.s	RCDE
RCE6	bsr	SC78
	move.b	d1,0(a4,d4.w)
	addq.w	#1,d4
RCF0	clr.b	0(a4,d5.w)
RCF4	bsr	SC8A
	bra	RC6A
RCFC	tst.w	d4
	beq	RC76
	bsr.s	SC78
	subq.w	#1,d4
	bra.s	RCF4
SC08	cmp.w	d4,d5
	beq	RC76
	bsr.s	SC78
	addq.w	#1,d4
	bra.s	RCF4
SC14	tst.w	d4
	beq	RC76
	bsr.s	SC78
	moveq	#0,d4
	bra.s	RCF4
SC20	cmp.w	d4,d5
	beq	RC76
	bsr.s	SC78
	move.w	d5,d4
	bra.s	RCF4
SC2C	tst.w	d4
	beq	RC76
	bsr.s	SC78
	move.w	d5,d0
	sub.w	d4,d0
	beq.s	SC46
	lea	0(a4,d4.w),a0
SC3E	move.b	(a0)+,-2(a0)
	subq.w	#1,d0
	bne.s	SC3E
SC46	subq.w	#1,d4
	subq.w	#1,d5
	bra.s	RCF0
SC4C	move.w	d5,d0
	sub.w	d4,d0
	beq	RC76
	lea	1(a4,d4.w),a0
SC58	move.b	(a0)+,-2(a0)
	subq.w	#1,d0
	bne.s	SC58
	subq.w	#1,d5
	bra.s	RCF0
SC64	bsr.s	SC78
	cmp.b	#$A,d1
	rts
SC6C	bsr.s	SCA0
	clr.b	(a4)
	moveq	#0,d4
	moveq	#0,d5
	bra	RC6A
SC78	move.w	d1,-(a7)
	moveq	#4,d2
	add.w	d4,d2
	move.w	8(a3),d3
	bsr	PC0E
	move.w	(a7)+,d1
	rts
SC8A	move.w	6(a3),-(a7)
	movea.l	a4,a0
	bsr	ID70
	moveq	#$20,d1
	bsr	QC52
	move.w	(a7)+,6(a3)
	rts
SCA0	move.w	6(a3),-(a7)
	move.w	$E2(a6),d2
	bsr	ID7C
	move.w	(a7)+,6(a3)
	rts
SCB2	move.l	a2,-(a7)
	add.w	$DC(a6),d1
	bsr	OC2E
	movea.l	(a7)+,a2
	lea	$12(a3),a0
	moveq	#$1A,d0
	move.b	#$20,(a0)+
SCC8	move.b	(a2)+,(a0)+
	dbeq	d0,SCC8
	move.b	#$20,-1(a0)
	clr.b	(a0)
	lea	WCB8(pc),a0
	move.l	a0,$3A(a3)
	clr.w	$3E(a3)
	moveq	#0,d7
	st	d4
	st	$10(a3)
SCEA	move.l	a4,-(a7)
	movea.l	a3,a4
	lea	$5B8(a6),a3
	move.w	$E(a4),d2
	move.w	$C(a4),d3
	sub.w	$DC(a6),d3
	tst.b	$38(a4)
	beq.s	TC34
	moveq	#$30,d1
	add.b	$38(a4),d1
	bsr	TCC0
	move.l	$40(a4),d0
	beq.s	TC34
	movea.l	d0,a0
	tst.l	4(a0)
	bne.s	TC20
	tst.l	(a0)
	beq.s	TC34
TC20	moveq	#0,d1
	move.w	$44(a4),d1
	divu.w	#$1A,d1
	swap	d1
	addi.b	#$61,d1
	bsr	TCC0
TC34	moveq	#$20,d1
	bsr	TCC0
	lea	TCE0(pc),a0
	lea	$12(a4),a1
	move.l	a1,(a0)
	moveq	#0,d0
	move.b	$30(a4),d0
	asl.w	#2,d0
	movea.l	0(a0,d0.w),a0
	bsr	TCB0
	cmpi.b	#4,$30(a4)
	bne.s	TC78
	movea.l	$40(a4),a0
	lea	$25(a0),a0
	bsr	TCB0
	moveq	#$29,d1
	bsr	TCC0
	movea.l	$40(a4),a0
	tst.l	$1E(a0)
	beq.s	TC9A
TC78	tst.b	$3E(a4)
	beq.s	TC9A
	cmpi.b	#2,$30(a4)
	beq.s	TC9A
	move.w	#$20,d1
	bsr	TCC0
	movea.l	$40(a4),a0
	lea	$44(a0),a0
	bsr	TCB0
TC9A	move.w	#$20,d1
	bsr	TCC0
	tst.b	d4
	beq	UC54
	bsr.s	TCF4
TCAA	movea.l	a4,a3
	movea.l	(a7)+,a4
	rts
TCB0	move.b	(a0)+,d1
	beq.s	TCBE
	move.l	a0,-(a7)
	bsr	TCC0
	movea.l	(a7)+,a0
	bra.s	TCB0
TCBE	rts
TCC0	move.w	$E(a4),d0
	add.w	(a4),d0
	cmp.w	d0,d2
	bcc.s	TCDC
	tst.b	d4
	bne.s	TCD0
	moveq	#$20,d1
TCD0	movem.w	d2-d3,-(a7)
	bsr	OC86
	movem.w	(a7)+,d2-d3
TCDC	addq.w	#1,d2
	rts

TCE0	dc.l	0,JE1E,JE25,JE12,JE2F

TCF4	move.w	$A(a4),d0
	subq.w	#1,d0
	move.w	$C(a4),d1
	subq.w	#1,d1
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$F0(a6)
	movea.l	(a7)+,a6
	movea.l	$D2(a6),a1
	lea	$854(a6),a0
	move.w	(a4),d0
	mulu.w	$D6(a6),d0
	add.w	$A(a4),d0
	addq.w	#1,d0
	move.w	d0,(a0)+
	move.w	$26(a1),d1
	move.w	d1,(a0)+
	add.w	4(a4),d1
	addq.w	#1,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	$24(a1),(a0)+
	move.w	d1,(a0)+
	move.l	$24(a1),(a0)+
	moveq	#4,d0
	lea	$854(a6),a0
	move.l	a6,-(a7)
	movea.l	$C6(a6),a6
	jsr	-$150(a6)
	movea.l	(a7)+,a6
	rts
UC54	moveq	#0,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	bsr.s	TCF4
	moveq	#1,d0
	move.l	a6,-(a7)
	movea.l	$D2(a6),a1
	movea.l	$C6(a6),a6
	jsr	-$156(a6)
	movea.l	(a7)+,a6
	bra	TCAA
UC7E	movea.l	$5B4(a6),a0
	movea.l	$32(a0),a2
	move.l	a2,$D2(a6)
	move.w	$3C(a2),$D6(a6)
	move.w	$3A(a2),$D8(a6)
	move.w	$3E(a2),$DA(a6)
	move.w	$A(a0),$EA(a6)
	move.w	8(a0),d0
	move.w	d0,$E8(a6)
	ext.l	d0
	divu.w	$D6(a6),d0
	move.w	d0,$EC(a6)
	move.w	d0,d2
	move.w	$EA(a6),d3
	ext.l	d3
	divu.w	$D8(a6),d3
	moveq	#0,d4
	moveq	#0,d0
	moveq	#0,d1
	lea	$5B8(a6),a3
	bset	#$F,d4
	bsr	OC2E
	move.w	$D8(a6),d0
	addq.w	#1,d0
	move.w	d0,$DC(a6)
	moveq	#6,d0
	lea	$5CA(a6),a0
UCE2	clr.w	(a0)
	lea	$46(a0),a0
	dbf	d0,UCE2
	clr.l	$DE(a6)
	lea	$84A(a6),a0
	move.w	#1,(a0)+
	move.w	$DC(a6),(a0)+
	move.w	$EC(a6),d0
	subq.w	#2,d0
	move.w	d0,(a0)+
	move.w	$EA(a6),d0
	ext.l	d0
	divu.w	$D8(a6),d0
	subq.w	#2,d0
	move.w	d0,(a0)+
	move.w	#$32,$E2(a6)
	move.w	$EA(a6),d0
	sub.w	$D8(a6),d0
	move.w	d0,$EE(a6)
	clr.l	$570(a6)
	rts
VC2A	movem.l	d4-d7,-(a7)
	pea	VC56(pc)
	bsr	OC34
	sf	d7
	sf	d4
	bsr	SCEA
	clr.w	(a3)
	lea	$728(a6),a3
	tst.w	(a3)
	beq	WC82
	st	d7
	st	d4
	bsr	SCEA
	bra	WCA8
VC56	movem.l	(a7)+,d4-d7
	rts
VC5C	moveq	#0,d1
	move.w	(a3),d1
	moveq	#0,d0
	move.b	$30(a3),d0
	add.w	d0,d0
	jmp	VC6C(pc,d0.w)
VC6C	rts
	bra.s	VC76
	bra.s	VC84
	bra.s	VCA6
	bra.s	VCCC
VC76	lea	XC6C(pc),a0
	move.l	a0,$3A(a3)
	subi.w	#$A,d1
	bra.s	VC90
VC84	lea	EDFC(pc),a0
	move.l	a0,$3A(a3)
	subi.w	#$26,d1
VC90	divu.w	#7,d1
	cmp.w	#8,d1
	bls.s	VC9E
	bclr	#0,d1
VC9E	add.w	d1,d1
	move.b	d1,$31(a3)
	rts
VCA6	subi.w	#$26,d1
	bcc.s	VCAE
	moveq	#0,d1
VCAE	cmp.b	#6,d1
	bcc.s	VCB6
	moveq	#0,d1
VCB6	cmp.b	#$10,d1
	bcs.s	VCBE
	moveq	#$10,d1
VCBE	move.b	d1,$31(a3)
	lea	FD88(pc),a0
	move.l	a0,$3A(a3)
	rts
VCCC	move.b	A6A,$31(a3)
	lea	GD34(pc),a0
	move.l	a0,$3A(a3)
	rts
VCDE	movem.l	d0-d1/a0-a1,-(a7)
	movea.l	$CE(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$60(a6)
	movea.l	(a7)+,a6
	movem.l	(a7)+,d0-d1/a0-a1
	rts
VCF8	movea.l	$BE(a6),a1
	movea.l	$CE(a6),a0
	cmpa.l	$3C(a1),a0
	beq.s	WC12
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$FC(a6)
	movea.l	(a7)+,a6
WC12	movea.l	$5B4(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$1C2(a6)
	movea.l	(a7)+,a6
	rts
WC24	movea.l	$CE(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$F6(a6)
	movea.l	(a7)+,a6
	rts
WC36	move.l	a2,-(a7)
	lea	$5B8(a6),a3
	bsr	OC34
	lea	$728(a6),a3
	lea	$12(a3),a0
	moveq	#$19,d0
WC4A	clr.w	(a0)+
	dbf	d0,WC4A
	movem.w	$84A(a6),d0-d4
	sub.w	$DC(a6),d1
	movea.l	(a7)+,a2
	bsr	SCB2
	st	d7
	st	d4
	bra	SCEA
WC68	lea	$5CA(a6),a3
	moveq	#6,d2
WC6E	tst.w	(a3)
	beq.s	WC78
	move.w	d2,-(a7)
	bsr.s	WCA8
	move.w	(a7)+,d2
WC78	lea	$46(a3),a3
	dbf	d2,WC6E
	rts
WC82	lea	$5CA(a6),a3
	moveq	#6,d2
WC88	tst.w	(a3)
	beq.s	WC9E
	move.w	d2,-(a7)
	cmpa.l	$DE(a6),a3
	seq	d7
	st	d4
	bsr	SCEA
	bsr.s	WCA8
	move.w	(a7)+,d2
WC9E	lea	$46(a3),a3
	dbf	d2,WC88
	rts
WCA8	clr.l	6(a3)
	movea.l	$3A(a3),a0
	jsr	0(a0)
	bra	QCD6
WCB8	bra	WCCA
	bra.s	WCCA
	bra.s	WCCA
	bra.s	WCCA
	bra.s	WCCA
	bra.s	WCCA
	bra.s	WCCA
	nop
WCCA	moveq	#0,d1
	rts
WCCE	move.w	2(a3),d7
	movea.l	$34(a3),a2
WCD6	bsr.s	WCE2
	bsr	ID9A
	subq.b	#1,d7
	bne.s	WCD6
	rts
WCE2	move.l	a2,d2
	bsr	IDA0
	bsr	ID88
	move.b	$31(a3),d6
	bsr.s	XC2E
	moveq	#0,d6
	move.b	$31(a3),d6
	subq.l	#1,a2
	bsr	RD6C
	addq.l	#1,a2
	suba.w	d6,a2
	bne.s	XC20
	bsr	RD6C
	bne.s	XC20
	bsr	ID88
XC0E	move.b	(a2)+,d1
	bne.s	XC16
	move.b	#$B7,d1
XC16	bsr	QC4A
	subq.b	#1,d6
	bne.s	XC0E
	rts
XC20	move.b	$31(a3),d2
	addq.b	#1,d2
	bsr	ID7C
	adda.w	d6,a2
	rts
XC2E	tst.b	d6
	beq.s	XC5A
	bsr	ID88
XC36	bsr	RD6C
	beq.s	XC44
	addq.l	#1,a2
	bsr	ID8E
	bra.s	XC4A
XC44	move.b	(a2)+,d2
	bsr	IDB0
XC4A	move.w	a2,d0
	btst	#0,d0
	bne.s	XC56
	bsr	ID88
XC56	subq.b	#1,d6
	bne.s	XC36
XC5A	rts
XC5C	subq.l	#1,$34(a3)
	moveq	#-1,d0
	rts
XC64	addq.l	#1,$34(a3)
	moveq	#-1,d0
	rts
XC6C	bra	WCCE
	bra.s	XC7C
	bra.s	XC86
	bra.s	XC98
	bra.s	XCB6
	bra.s	XC5C
	bra.s	XC64
XC7C	moveq	#0,d0
	move.b	$31(a3),d0
	neg.w	d0
	bra.s	XC8C
XC86	moveq	#0,d0
	move.b	$31(a3),d0
XC8C	muls.w	2(a3),d0
	add.l	d0,$34(a3)
	moveq	#-1,d1
	rts
XC98	bsr	PCC6
	moveq	#0,d0
	move.b	$31(a3),d0
	sub.l	d0,$34(a3)
	movea.l	$34(a3),a2
	bsr	WCE2
	bsr	QCD6
	moveq	#0,d1
	rts
XCB6	bsr	PCAE
	moveq	#0,d0
	move.b	$31(a3),d0
	add.l	d0,$34(a3)
	move.w	2(a3),d1
	subq.w	#1,d1
	mulu.w	d0,d1
	movea.l	$34(a3),a2
	adda.l	d1,a2
	bsr	WCE2
	bsr	QCD6
	moveq	#0,d1
	rts
XCDE	movea.l	$34(a3),a4
	moveq	#0,d6
	moveq	#0,d7
	moveq	#0,d5
	moveq	#0,d4
	move.b	$31(a3),d4
	mulu.w	#5,d4
	lsr.w	#1,d4
	move.w	d4,d3
	bra.s	YC58
XCF8	move.w	d3,-(a7)
	moveq	#$A,d2
	tst.b	d5
	beq.s	YC04
	add.w	d4,d2
	addq.w	#1,d2
YC04	add.w	d6,d2
	move.w	d7,d3
	bsr	PC0A
	move.w	(a7)+,d3
	rts
YC10	dc.w	0,$101,$102,$203
	dc.w	$303,$404,$505,$506
	dc.w	$607,$707,$808,$909
	dc.w	$90A,$A0B,$B0B,$C0C
	dc.w	$D0D,$D0E,$E0F,$F0F
YC38	move.b	YC10(pc,d6.w),d0
	ext.w	d0
	rts
YC40	not.b	d5
	bne.s	YC4E
	mulu.w	#5,d6
	lsr.w	#1,d6
	move.w	d4,d3
	bra.s	YC58
YC4E	bsr.s	YC38
	move.w	d0,d6
	moveq	#0,d3
	move.b	$31(a3),d3
YC58	bsr.s	XCF8
	bsr	RBA6
	bmi	ZC32
	move.w	d1,-(a7)
	bsr.s	XCF8
	move.w	(a7)+,d1
	cmp.b	#$1B,d1
	beq	I42
	cmp.b	#9,d1
	beq.s	YC40
	cmp.b	#$88,d1
	beq.s	YC40
	cmp.w	#$82,d1
	beq	ZC4E
	cmp.w	#$83,d1
	beq	ZC70
	cmp.w	#$85,d1
	beq	ZC94
	cmp.w	#$84,d1
	beq	ZCC4
	cmp.b	#8,d1
	beq	ZCC4
	tst.b	d5
	bne.s	YCF8
	moveq	#$30,d0
	cmp.b	d0,d1
	bcs.s	YC58
	cmp.b	#$3A,d1
	bcs.s	YCC6
	andi.b	#$DF,d1
	cmp.b	#$41,d1
	bcs.s	YC58
	cmp.b	#$47,d1
	bcc.s	YC58
	moveq	#$37,d0
YCC6	sub.b	d0,d1
	move.b	d1,d2
	bsr	YC38
	lea	0(a4,d0.w),a0
	move.l	a0,d0
	bsr	RDA6
	bne	ZC94
	bsr	ZCA4
	andi.b	#1,d0
	bne.s	YCEE
	andi.b	#$F0,(a0)
	or.b	d2,(a0)
	bra.s	ZC0C
YCEE	andi.b	#$F,(a0)
	lsl.b	#4,d2
	or.b	d2,(a0)
	bra.s	ZC0C
YCF8	tst.b	d1
	beq	YC58
	lea	0(a4,d6.w),a0
	move.l	a0,d0
	bsr	RDA6
	bne.s	ZC0C
	move.b	d1,(a0)
ZC0C	moveq	#1,d0
	bsr	OBA8
	clr.w	6(a3)
	movem.l	d3-d7/a4,-(a7)
	mulu.w	$D8(a6),d7
	move.w	d7,8(a3)
	movea.l	a4,a2
	bsr	WCE2
	bsr	QCD6
	movem.l	(a7)+,d3-d7/a4
	bra.s	ZC94
ZC32	move.w	d1,-(a7)
	bsr	XCF8
	move.w	(a7)+,d1
	cmp.b	#$45,d1
	beq	I42
	move.w	d1,-(a7)
	bsr	I42
	move.w	(a7)+,d1
	bra	H86
ZC4E	moveq	#0,d0
	move.b	$31(a3),d0
	suba.l	d0,a4
	subq.w	#1,d7
	bcc	ZCE0
	movem.l	d3-d7/a4,-(a7)
	bsr	XC98
	movem.l	(a7)+,d3-d7/a4
	moveq	#0,d7
	bsr	RB74
	bra.s	ZCE0
ZC70	moveq	#0,d0
	move.b	$31(a3),d0
	adda.l	d0,a4
	addq.w	#1,d7
	cmp.w	2(a3),d7
	bne.s	ZCE0
	subq.w	#1,d7
	movem.l	d3-d7/a4,-(a7)
	bsr	XCB6
	movem.l	(a7)+,d3-d7/a4
	bsr	RB74
	bra.s	ZCE0
ZC94	addq.w	#1,d6
	bsr.s	ZCA4
	bne.s	ZC9C
	addq.w	#1,d6
ZC9C	cmp.w	d3,d6
	bne.s	ZCE0
	moveq	#0,d6
	bra.s	ZC70
ZCA4	tst.b	d5
	bne.s	ZCC2
	moveq	#0,d0
	move.w	d6,d0
	moveq	#1,d1
	btst	#0,$37(a3)
	beq.s	ZCB8
	moveq	#3,d1
ZCB8	add.w	d1,d0
	divu.w	#5,d0
	swap	d0
	tst.w	d0
ZCC2	rts
ZCC4	subq.w	#1,d6
	bcs.s	ZCD0
	bsr.s	ZCA4
	bne.s	ZCE0
	subq.w	#1,d6
	bcc.s	ZCE0
ZCD0	move.w	d3,d6
	subq.w	#1,d6
	bsr.s	ZCA4
	bne	ZC4E
	subq.w	#1,d6
	bra	ZC4E
ZCE0	bra	YC58
ZCE4	bsr	ID88
	moveq	#$3D,d1
	bsr	QC52
	bra	ID88
ZCF2	lea	$10(a6),a1
	moveq	#$30,d7
ZCF8	moveq	#$64,d1
	bsr	QC52
	move.b	d7,d1
	bsr	QC52
	bsr.s	ZCE4
	movea.l	(a1),a2
	move.l	a2,d2
	bsr	IDA0
	bsr	ID88
	bsr	ID88
	moveq	#3,d6
AD18	move.b	(a1)+,d1
	bne.s	AD20
	move.b	#$B7,d1
AD20	bsr	QC4A
	dbf	d6,AD18
	bsr	ID88
	bsr	ID88
	bsr	ID88
	bsr	ID88
	moveq	#$61,d1
	bsr	QC52
	move.b	d7,d1
	bsr	QC52
	bsr.s	ZCE4
	movea.l	$1C(a1),a2
	bsr	WCE2
	bsr	ID9A
	addq.b	#1,d7
	cmp.b	#$38,d7
	bne.s	ZCF8
	moveq	#1,d1
	bsr	ID60
	move.w	$5A(a6),d2
	bsr	IDA8
	moveq	#5,d7
AD6A	bsr	ID88
	dbf	d7,AD6A
	move.w	$5A(a6),d4
	bsr	EDA8
	bsr	ID9A
	moveq	#0,d1
	bsr	ID60
	move.l	$54(a6),d2
	bsr	IDA0
	bsr	ID88
	bsr	ID88
	movea.l	$54(a6),a2
	sf	$14B(a6)
	bsr	HDAC
	bset	#0,$14B(a6)
	beq.s	ADF6
	moveq	#$11,d1
	bsr	ID60
	move.l	$14E(a6),d2
	move.l	d2,$7B4(a6)
	bsr	IDA0
	movea.l	$14E(a6),a2
	moveq	#0,d0
	move.b	$14D(a6),d0
	move.b	BD04(pc,d0.w),d6
	bsr	XC2E
	tst.b	$14C(a6)
	beq.s	ADF6
	moveq	#$3E,d1
	bsr	QC52
	move.l	$152(a6),d2
	move.l	d2,$7B4(a6)
	bsr	IDA0
	movea.l	$152(a6),a2
	moveq	#0,d0
	move.b	$14D(a6),d0
	move.b	BD04(pc,d0.w),d6
	bsr	XC2E
ADF6	st	$14B(a6)
	bsr	PCD0
	bsr	ID9A
	bra.s	BD08

BD04	dc.w	$0102,$0408
BD08	dc.w	$0c6b,$000a,$0002

	bls	CD94
	movea.l	4.w,a0
	move.w	$128(a0),d0
	lea	DD4C(pc),a1
	btst	#0,d0
	beq.s	BD46
	lea	DD54(pc),a1
	btst	#1,d0
	beq.s	BD46
	lea	DD6E(pc),a1
	btst	#2,d0
	beq.s	BD46
	lea	DDA0(pc),a1
	btst	#3,d0
	beq.s	BD46
	lea	DDF6(pc),a1
BD46	bsr	CDA8
	tst.b	NE1C
	beq	CD54
	lea	ED52(pc),a1
	bsr	CDA8
	lea	OE9A(pc),a1
	moveq	#0,d7
BD62	moveq	#$66,d1
	bsr	QC52
	moveq	#$70,d1
	bsr	QC52
	move.b	d7,d1
	bsr	QC42
	bsr	ZCE4
	dc.w	$f211,$4800		; fmove.x	(a1),fp0
	move.w	(a1)+,d2
	bsr	IDA8
	moveq	#$20,d1
	bsr	QC52
	addq.w	#2,a1
	move.l	(a1)+,d2
	bsr	IDA0
	moveq	#$20,d1
	bsr	QC52
	move.l	(a1)+,d2
	bsr	IDA0
	moveq	#$20,d1
	bsr	QC52
	move.l	a1,-(a7)
	lea	$59C(a6),a1
	dc.w	$f211,$6c11		; fmove.p	fp0,(a1){$11}
	moveq	#$20,d1
	btst	#7,(a1)
	beq.s	BDB6
	moveq	#$2D,d1
BDB6	bsr	QC52
	move.w	(a1)+,d1
	ori.w	#$8000,d1
	addq.w	#1,d1
	bne.s	BDE4
	addq.w	#2,a1
	lea	ED67(pc),a0
	btst	#6,(a1)
	bne.s	BDDE
	move.l	(a1)+,d1
	lea	ED6B(pc),a0
	or.l	(a1),d1
	beq.s	BDDE
	lea	ED66(pc),a0
BDDE	bsr	ID70
	bra.s	CD44
BDE4	addq.w	#1,a1
	move.b	(a1)+,d1
	andi.b	#$F,d1
	bsr	QC42
	moveq	#$2E,d1
	bsr	QC52
	move.w	d7,-(a7)
	moveq	#7,d7
BDFA	move.b	(a1)+,d0
	bsr	CD96
	dbf	d7,BDFA
	move.w	(a7)+,d7
	moveq	#$65,d1
	bsr	QC52
	lea	$59C(a6),a1
	moveq	#$2B,d1
	btst	#6,(a1)
	beq.s	CD1A
	moveq	#$2D,d1
CD1A	bsr	QC52
	dc.w	$f200,$a800		; fmove.l	fpsr,d0
	moveq	#0,d1
	btst	#$D,d0
	beq.s	CD30
	bfextu	2(a1){0:4},d1
CD30	bsr	QC42
	move.b	(a1)+,d1
	andi.b	#$F,d1
	bsr	QC42
	move.b	(a1),d0
	bsr	CD96
CD44	movea.l	(a7)+,a1
	bsr	ID9A
	addq.b	#1,d7
	cmp.b	#8,d7
	bne	BD62
CD54	bsr	ID9A
	move.b	$31(a3),-(a7)
	move.b	#$10,$31(a3)
	moveq	#0,d7
	lea	RD58(pc),a1
CD68	moveq	#$6D,d1
	bsr	QC52
	moveq	#$30,d1
	add.b	d7,d1
	bsr	QC52
	bsr	ZCE4
	move.w	(a1)+,d2
	movea.l	0(a6,d2.w),a2
	bsr	WCE2
	bsr	ID9A
	addq.w	#1,d7
	cmp.w	#$A,d7
	bne.s	CD68
	move.b	(a7)+,$31(a3)
CD94	rts
CD96	unpk	d0,d2,#$3030
	bfextu	d2{16:8},d1
	bsr	QC52
	move.b	d2,d1
	bra	QC52
CDA8	tst.b	(a1)
	bmi	ID9A
	bsr.s	CDB2
	bra.s	CDA8
CDB2	moveq	#0,d2
	move.b	(a1)+,d2
	bne.s	CDBE
	bsr	ID9A
	bra.s	CDC2
CDBE	bsr	ID7C
CDC2	lea	CDE8(pc),a0
	move.b	(a1)+,d1
	bsr	ID64
	bsr	ZCE4
	move.w	d7,-(a7)
	move.w	(a1)+,d7
	lea	NE1E(pc),a2
	adda.w	(a1)+,a2
CDDA	move.b	(a2)+,d2
	bsr	IDB0
	dbf	d7,CDDA
	move.w	(a7)+,d7
	rts

CDE8	dc.b	'ssp',0
	dc.b	'sfc',0
	dc.b	'dfc',0
	dc.b	'vbr',0
	dc.b	'msp',0
	dc.b	'isp',0
	dc.b	'cacr',0
	dc.b	'caar',0
	dc.b	'mmusr',0
	dc.b	'tc',0
	dc.b	'tt0',0
	dc.b	'tt1',0
	dc.b	'crp',0
	dc.b	'srp',0
	dc.b	'fpcr',0
	dc.b	'fpsr',0
	dc.b	'fpiar',0
	dc.b	'itt0',0
	dc.b	'itt1',0
	dc.b	'dtt0',0
	dc.b	'dtt1',0
	dc.b	'urp',0

DD4C	dc.w	0,3,$A,$FF00
DD54	dc.w	0,3,$A,$301
	dc.w	0,$5F,3,3
	dc.w	$64,$302,0,$63
	dc.w	$FF00
DD6E	dc.w	0,3,$A,$304
	dc.w	3,$68,$301,0
	dc.w	$5F,$306,1,$72
	dc.w	3,3,$64,$305
	dc.w	3,$6C,$302,0
	dc.w	$63,$307,3,$74
	dc.w	$FF00
DDA0	dc.w	0,3,$A,$401
	dc.w	0,$5F,$608,1
	dc.w	$7A,$70C,7,$88
	dc.w	3,3,$64,$402
	dc.w	0,$63,$909,3
	dc.w	$7C,$30D,7,$90
	dc.w	5,3,$6C,$306
	dc.w	1,$72,$60A,3
	dc.w	$80,4,3,$68
	dc.w	$307,3,$74,$20B
	dc.w	3,$84,$FF00
DDF6	dc.w	0,3,$A,$301
	dc.w	3,$5C,$509,3
	dc.w	$7C,$211,3,$80
	dc.w	3,3,$64,$302
	dc.w	3,$60,$208,3
	dc.w	$78,$212,3,$84
	dc.w	5,3,$6C,$206
	dc.w	3,$70,$415,3
	dc.w	$94,$213,3,$88
	dc.w	4,3,$68,$150D
	dc.w	3,$90,$214,3
	dc.w	$8C,$FF00
ED52	dc.w	$E,1,$172,$20F
	dc.w	3,$174,$210,3
	dc.w	$178,$FF00
ED66	dc.b	$73
ED67	dc.b	$6E
	dc.w	$616E
	dc.b	0
ED6B	dc.b	'infinity',0

	bsr	ID70
	move.l	(a1),d2
	bra	IDA0
	bsr	ID70
	move.l	(a1),d2
	bsr	IDA0
	move.l	4(a1),d2
	bra	IDA0
ED90	beq.s	ED9E
	move.b	(a0)+,d1
	bsr	QC52
	move.b	(a0)+,d1
	bra	QC52
ED9E	addq.l	#2,a0
	bsr	ID88
	bra	ID88
EDA8	lea	EDF2(pc),a0
	btst	#$F,d4
	bsr.s	ED90
	btst	#$E,d4
	bsr.s	ED90
	moveq	#$53,d1
	btst	#$D,d4
	bne.s	EDC2
	moveq	#$55,d1
EDC2	bsr	QC52
	moveq	#$4D,d1
	btst	#$C,d4
	bne.s	EDD0
	moveq	#$49,d1
EDD0	bsr	QC52
	moveq	#4,d2
EDD6	btst	#4,d4
	bsr.s	EDE4
	add.b	d4,d4
	dbf	d2,EDD6
	rts
EDE4	beq.s	EDEC
	move.b	(a0)+,d1
	bra	QC52
EDEC	addq.l	#1,a0
	bra	ID88
EDF2	addq.b	#2,$31(a0,d5.w*4)
	addq.w	#4,a6
	addq.w	#5,(a6)
	chk.l	d0,d1
EDFC	bra	ZCF2
	bra.s	FD0E
	bra.s	FD0E
	bra.s	FD0E
	bra.s	FD0E
	bra.s	FD0E
	bra.s	FD0E
	nop
FD0E	moveq	#$1B,d1
	rts
FD12	movea.l	$34(a3),a2
	move.w	2(a3),d6
FD1A	tst.b	$31(a3)
	bne.s	FD34
	moveq	#8,d2
	move.l	a2,d0
	bsr	DE02
	bne.s	FD4A
	move.l	a2,d2
	bsr	IDA0
	moveq	#0,d2
	bra.s	FD4E
FD34	move.l	a2,d2
	bsr	IDA0
	bsr	ID88
	move.l	a2,d0
	move.b	$31(a3),d2
	bsr	DE02
	beq.s	FD4E
FD4A	bsr	ZDE2
FD4E	bsr	ID7C
	moveq	#$20,d1
	cmpa.l	$54(a6),a2
	bne.s	FD5C
	moveq	#$3E,d1
FD5C	bsr	QC52
	bsr	HDF6
	move.l	a2,-(a7)
	bsr	PCD0
	bsr	ID9A
	movea.l	(a7)+,a2
	subq.b	#1,d6
	bne.s	FD1A
	rts
FD76	bsr.s	FDC8
	subq.l	#2,a2
FD7A	move.l	a2,$34(a3)
	moveq	#-1,d0
	rts
FD82	bsr.s	FDC8
	addq.l	#2,a2
	bra.s	FD7A
FD88	bra	FD12
	bra.s	FD98
	bra.s	FDA8
	bra.s	FDDE
	bra.s	FDD6
	bra.s	FD76
	bra.s	FD82
FD98	move.w	2(a3),d0
	add.w	d0,d0
	ext.l	d0
	sub.l	d0,$34(a3)
	moveq	#-1,d0
	rts
FDA8	move.l	$34(a3),d0
	addq.l	#1,d0
	bclr	#0,d0
	movea.l	d0,a2
	move.w	2(a3),d6
FDB8	bsr	HD6A
	subq.b	#1,d6
	bne.s	FDB8
FDC0	move.l	a2,$34(a3)
	moveq	#-1,d1
	rts
FDC8	move.l	$34(a3),d0
	addq.l	#1,d0
	bclr	#0,d0
	movea.l	d0,a2
	rts
FDD6	bsr.s	FDC8
	bsr	HD6A
	bra.s	FDC0
FDDE	bsr.s	FDC8
	bsr	LBB2
	bra.s	FDC0
FDE6	movea.l	$34(a3),a2
	move.w	2(a3),d6
	move.w	$32(a3),d4
	subq.w	#1,d6
FDF4	bsr	GDF2
	dbeq	d6,FDF4
	bne.s	GD0E
	tst.w	d6
	bmi.s	GD0E
GD02	bsr	PCD0
	bsr	ID9A
	dbf	d6,GD02
GD0E	rts
GD10	cmpa.l	$156(a6),a2
	beq.s	GD2E
	cmpi.b	#$A,-(a2)
	bne.s	GD10
GD1C	cmpa.l	$156(a6),a2
	beq.s	GD2A
	cmpi.b	#$A,-(a2)
	bne.s	GD1C
	addq.l	#1,a2
GD2A	subq.w	#1,d4
	moveq	#-1,d0
GD2E	rts
GD30	moveq	#0,d0
	rts
GD34	bra	FDE6
	bra.s	GD6C
	bra.s	GD82
	bra.s	GD44
	bra.s	GDA4
	bra.s	GD30
	bra.s	GD30
GD44	movea.l	$34(a3),a2
	move.w	$32(a3),d4
	bsr.s	GD10
	beq.s	GD68
	move.l	a2,-(a7)
	bsr	PCC6
	bsr	PCD0
	movea.l	(a7)+,a2
	move.w	d4,$32(a3)
	move.l	a2,$34(a3)
	bsr	GDF2
GD68	moveq	#0,d0
	rts
GD6C	movea.l	$34(a3),a2
	move.w	2(a3),d2
	move.w	$32(a3),d4
	subq.w	#1,d2
GD7A	bsr.s	GD10
	dbeq	d2,GD7A
	bra.s	GD98
GD82	movea.l	$34(a3),a2
	move.w	$32(a3),d4
	move.w	2(a3),d2
	subq.w	#1,d2
GD90	bsr.s	GDDE
	beq.s	GDDA
	dbf	d2,GD90
GD98	move.l	a2,$34(a3)
	move.w	d4,$32(a3)
	moveq	#-1,d0
	rts
GDA4	movea.l	$34(a3),a2
	move.w	$32(a3),d4
	move.w	2(a3),d2
	subq.w	#1,d2
GDB2	bsr.s	GDDE
	beq.s	GDDA
	dbf	d2,GDB2
	move.l	a2,-(a7)
	bsr	PCAE
	bsr	PCD0
	movea.l	(a7)+,a2
	bsr.s	GDF2
	movea.l	$34(a3),a2
	move.w	$32(a3),d4
	bsr.s	GDDE
	move.l	a2,$34(a3)
	move.w	d4,$32(a3)
GDDA	moveq	#0,d0
	rts
GDDE	cmpa.l	$15A(a6),a2
	beq	HD68
	cmpi.b	#$A,(a2)+
	bne.s	GDDE
	addq.w	#1,d4
	moveq	#-1,d0
	rts
GDF2	cmpa.l	$15A(a6),a2
	beq.s	HD68
	tst.b	$584(a6)
	beq.s	HD1A
	bmi.s	HD0E
	moveq	#0,d1
	move.w	d4,d1
	move.l	a2,-(a7)
	bsr	IDD4
	movea.l	(a7)+,a2
	bra.s	HD14
HD0E	move.w	d4,d2
	bsr	IDA8
HD14	bsr	ID88
	moveq	#0,d3
HD1A	cmpa.l	$15A(a6),a2
	beq.s	HD68
	move.b	(a2)+,d1
	cmp.b	#$D,d1
	beq.s	HD1A
	cmp.b	#$A,d1
	beq.s	HD58
	cmp.b	#9,d1
	beq.s	HD3C
	bsr	QC52
	addq.w	#1,d3
	bra.s	HD1A
HD3C	move.w	d3,d2
	moveq	#0,d1
	move.b	$31(a3),d1
	subq.w	#1,d1
	not.w	d1
	and.w	d1,d2
	add.b	$31(a3),d2
	sub.w	d3,d2
	add.w	d2,d3
	bsr	ID7C
	bra.s	HD1A
HD58	move.l	a2,-(a7)
	bsr	PCD0
	movea.l	(a7)+,a2
	bsr	ID9A
	addq.w	#1,d4
	moveq	#-1,d0
HD68	rts
HD6A	bsr	RD6C
	bne.s	HDA8
	lea	$A(a2),a2
	bsr	RD6C
	lea	-$A(a2),a2
	bne.s	HDA8
	movem.l	d4-d7/a3-a5,-(a7)
	movea.l	a2,a5
	move.l	$AE(a6),-(a7)
	move.l	$136(a6),-(a7)
	clr.l	$AE(a6)
	clr.l	$136(a6)
	bsr	DAD2
	move.l	(a7)+,$136(a6)
	move.l	(a7)+,$AE(a6)
	movea.l	a5,a2
	movem.l	(a7)+,d4-d7/a3-a5
	rts
HDA8	addq.w	#2,a2
	rts
HDAC	move.l	a2,d0
	addq.l	#1,d0
	bclr	#0,d0
	movea.l	d0,a2
	bsr	RD6C
	bne	ID58
	lea	$A(a2),a2
	bsr	RD6C
	lea	-$A(a2),a2
	bne	ID58
	movem.l	d4-d7/a3-a5,-(a7)
	movea.l	a2,a5
	bsr	DAD2
	movea.l	a5,a2
	move.l	a4,d2
	sub.l	a6,d2
	subi.w	#$98A,d2
	movem.l	(a7)+,d4-d7/a3-a5
	lea	$988(a6),a0
HDEA	move.b	(a0)+,d1
	bsr	QC52
	dbf	d2,HDEA
	rts
HDF6	move.l	a2,d0
	addq.l	#1,d0
	bclr	#0,d0
	movea.l	d0,a2
	bsr	RD6C
	bne.s	ID58
	lea	$A(a2),a2
	bsr	RD6C
	lea	-$A(a2),a2
	bne.s	ID58
	movem.l	d4-d7/a3-a5,-(a7)
	movea.l	a2,a5
	bsr	DAD2
	movea.l	a5,a2
	move.l	a4,d2
	sub.l	a6,d2
	subi.w	#$98A,d2
	movem.l	(a7)+,d4-d7/a3-a5
	lea	$988(a6),a0
ID30	move.b	(a0)+,d1
	cmp.b	#$20,d1
	bne.s	ID4E
	move.w	d2,-(a7)
	moveq	#8,d2
	sub.l	a0,d2
	pea	$988(a6)
	add.l	(a7)+,d2
	bmi.s	ID4A
	bsr	ID7C
ID4A	move.w	(a7)+,d2
	moveq	#$20,d1
ID4E	bsr	QC52
	dbf	d2,ID30
	rts
ID58	addq.l	#2,a2
	moveq	#$2A,d1
	bra	QC52
ID60	lea	GE2B(pc),a0
ID64	tst.b	d1
	beq.s	ID70
ID68	tst.b	(a0)+
	bne.s	ID68
	subq.b	#1,d1
	bne.s	ID68
ID70	move.b	(a0)+,d1
	beq.s	ID7A
	bsr	QC52
	bra.s	ID70
ID7A	rts
ID7C	tst.b	d2
ID7E	beq.s	ID86
	bsr.s	ID88
	subq.b	#1,d2
	bra.s	ID7E
ID86	rts
ID88	moveq	#$20,d1
	bra	QC52
ID8E	moveq	#$2A,d1
	bsr	QC52
	moveq	#$2A,d1
	bra	QC52
ID9A	moveq	#$A,d1
	bra	QC52
IDA0	move.w	d2,-(a7)
	swap	d2
	bsr.s	IDA8
	move.w	(a7)+,d2
IDA8	move.w	d2,-(a7)
	lsr.w	#8,d2
	bsr.s	IDB0
	move.w	(a7)+,d2
IDB0	move.w	d2,-(a7)
	lsr.b	#4,d2
	bsr.s	IDB8
	move.w	(a7)+,d2
IDB8	andi.w	#$F,d2
	move.b	IDC4(pc,d2.w),d1
	bra	QC52

IDC4	dc.b	'0123456789ABCDEF'

IDD4	lea	QC52(pc),a2
	lea	JD2E(pc),a0
	moveq	#-1,d2
	moveq	#3,d0
	bra.s	IDEE
IDE2	lea	QC52(pc),a2
IDE6	lea	JD1A(pc),a0
	moveq	#1,d2
	moveq	#8,d0
IDEE	moveq	#0,d3
	cmp.l	(a0)+,d1
	bcs.s	JD00
	sub.l	-(a0),d1
IDF6	addq.b	#1,d3
	sub.l	(a0),d1
	bcc.s	IDF6
	add.l	(a0)+,d1
	bra.s	JD04
JD00	tst.b	d2
	bpl.s	JD10
JD04	st	d2
	addi.b	#$30,d3
	exg	d3,d1
	jsr	(a2)
	exg	d3,d1
JD10	dbf	d0,IDEE
	addi.b	#$30,d1
	jmp	(a2)
JD1A	dc.l	$3B9ACA00,$5F5E100
	dc.l	$989680,$F4240
	dc.l	$186A0
JD2E	dc.l	$2710,$3E8
	dc.l	$64,$A
JD3E	move.l	a4,-(a7)
	st	$7F5(a6)
	bsr	JD76
	bne.s	JD58
	tst.b	d1
	bne.s	JD58
	sf	$7F5(a6)
	moveq	#0,d0
	movea.l	(a7)+,a4
	rts
JD58	sf	$7F5(a6)
	moveq	#-1,d0
	movea.l	(a7)+,a4
	rts
JD62	bsr.s	JD76
JD64	bne.s	JD6A
	tst.b	d1
	beq.s	JD70
JD6A	bsr	VCDE
	moveq	#-1,d0
JD70	rts
JD72	bsr.s	JD78
	bra.s	JD64
JD76	move.b	(a4)+,d1
JD78	lea	$7CC(a6),a0
	clr.w	(a0)
	lea	$7E0(a6),a0
	clr.w	(a0)
	clr.b	$7F4(a6)
	movem.l	d4-d7,-(a7)
	bsr	KD16
	movem.l	(a7)+,d4-d7
	tst.w	$7CC(a6)
	bne.s	JDA6
	tst.w	$7E0(a6)
	bne.s	JDA6
	move.b	$7F4(a6),d0
	rts
JDA6	moveq	#1,d0
	rts
JDAA	dc.w	$132B,$142D,$62A,$72F
	dc.w	$228,$329,$157E,$1723
	dc.w	$183F,$A3D,$1026,$117C
	dc.w	$1121,$125E,$47B,$57D
	dc.w	$FE24,$FC25,$FA40,$F827
	dc.w	$F822,$F65C
	dc.b	0
JDD7	dc.b	0
	dc.w	0,0,4,$416,$1601
	dc.w	$101,$101,$112,$1212
	dc.w	$202,$1D1E,$1F1F
JDF0	dc.w	$2F0,$236,$254,$258
	dc.w	$25C,$272,$266,$26C
	dc.w	$278,$27E,$248,$24C
	dc.w	$250,$22E,$232,$284
	dc.w	$288,$28C,$2BC
KD16	lea	$7CC(a6),a0
	move.w	(a0),d0
	addq.w	#2,(a0)+
	move.w	#0,0(a0,d0.w)
	moveq	#1,d5
	bsr	NDA2
KD2A	cmp.b	#2,d5
	bne.s	KD40
	cmp.b	#6,d7
	bcs	LD8E
	cmp.b	#$19,d7
	bcc	LD8E
KD40	cmp.b	#1,d7
	bne.s	KD56
KD46	lea	$7E0(a6),a0
	move.w	(a0),d0
	addq.w	#4,(a0)+
	move.l	d2,0(a0,d0.w)
	bra	LD84
KD56	cmp.b	#2,d7
	beq.s	KDD6
	cmp.b	#4,d7
	beq	KDF8
	cmp.b	#6,d7
	bcs	LDA0
	cmp.b	#$19,d7
	bcc	LDA0
	cmp.b	#1,d5
	bne.s	KDAA
	cmp.b	#$13,d7
	beq.s	KDAA
	cmp.b	#$14,d7
	beq.s	KDA8
	cmp.b	#6,d7
	beq.s	KDA2
	cmp.b	#$17,d7
	beq.s	KDAA
	cmp.b	#$18,d7
	beq.s	KDAA
	cmp.b	#$15,d7
	bne	JDA6
	bra.s	KDAA
KDA2	move.l	$54(a6),d2
	bra.s	KD46
KDA8	moveq	#$16,d7
KDAA	lea	JDD7(pc),a2
	lea	$7CC(a6),a0
	move.w	(a0),d0
	move.w	0(a0,d0.w),d6
	move.b	0(a2,d6.w),d6
	cmp.b	0(a2,d7.w),d6
	bge.s	KDCA
	addq.w	#2,(a0)+
	move.w	d7,0(a0,d0.w)
	bra.s	KDD0
KDCA	bsr	LDD6
	bra.s	KDAA
KDD0	moveq	#0,d5
	bra	LD84
KDD6	bsr	KD16
	lea	$7E0(a6),a0
	move.w	(a0),d0
	addq.w	#4,(a0)+
	move.l	d2,0(a0,d0.w)
	cmp.b	#3,d7
	beq.s	KDF2
KDEC	move.b	#2,$7F4(a6)
KDF2	moveq	#1,d5
	bra	LD84
KDF8	bsr	KD16
	cmp.b	#5,d7
	bne.s	KDEC
	cmp.b	#$2E,d1
	bne.s	LD4E
	move.b	(a4)+,d0
	move.b	(a4)+,d1
	andi.b	#$DF,d0
	cmp.b	#$42,d0
	beq.s	LD2A
	cmp.b	#$57,d0
	beq.s	LD3A
	cmp.b	#$4C,d0
	beq.s	LD4E
	move.b	#7,$7F4(a6)
	bra.s	LD84
LD2A	movea.l	d2,a2
	bsr	RD6C
	bne.s	LD78
	movea.l	d2,a0
	moveq	#0,d2
	move.b	(a0),d2
	bra.s	LD68
LD3A	btst	#0,d2
	bne.s	LD78
	movea.l	d2,a2
	bsr	RD6C
	bne.s	LD78
	moveq	#0,d2
	move.w	(a2),d2
	bra.s	LD68
LD4E	btst	#0,d2
	bne.s	LD78
	movea.l	d2,a2
	bsr	RD6C
	bne.s	LD78
	addq.l	#3,a2
	bsr	RD6C
	bne.s	LD78
	movea.l	d2,a0
	move.l	(a0),d2
LD68	lea	$7E0(a6),a0
	move.w	(a0),d0
	addq.w	#4,(a0)+
	move.l	d2,0(a0,d0.w)
	moveq	#1,d5
	bra.s	LD84
LD78	tst.b	$7F5(a6)
	bne.s	LD68
	move.b	#6,$7F4(a6)
LD84	addq.w	#1,d5
	bsr	NDA2
	bra	KD2A
LD8E	cmp.b	#3,d7
	beq.s	LDA0
	cmp.b	#5,d7
	beq.s	LDA0
	movea.l	a0,a4
	move.b	-1(a4),d1
LDA0	lea	JDD7(pc),a2
LDA4	lea	$7CC(a6),a0
	move.w	(a0),d0
	tst.w	0(a0,d0.w)
	beq.s	LDB6
	bsr	LDD6
	bra.s	LDA4
LDB6	subq.w	#2,$7CC(a6)
	lea	$7E0(a6),a0
	subq.w	#4,(a0)
	move.w	(a0)+,d0
	move.l	0(a0,d0.w),d2
	rts
LDC8	move.w	(a7)+,d1
LDCA	move.w	#4,(a0)
	move.b	#8,$7F4(a6)
	rts
LDD6	lea	$7E0(a6),a0
	subq.w	#4,(a0)
	bcs.s	LDCA
	move.w	(a0)+,d0
	move.l	0(a0,d0.w),d2
	move.w	d1,-(a7)
	lea	$7CC(a6),a1
	subq.w	#2,(a1)
	move.w	(a1)+,d1
	move.w	0(a1,d1.w),d1
	cmp.b	#$15,d1
	bcc.s	MD04
	subq.w	#4,-(a0)
	bcs.s	LDC8
	move.w	(a0)+,d0
	move.l	0(a0,d0.w),d0
	exg	d0,d2
MD04	lea	JDF0(pc),a1
	add.w	d1,d1
	move.w	-$C(a1,d1.w),d1
	jsr	0(a1,d1.w)
	move.w	(a7)+,d1
	move.w	-(a0),d0
	addq.w	#4,(a0)+
	move.l	d2,0(a0,d0.w)
	rts
	add.l	d0,d2
	rts
	sub.l	d0,d2
	rts
	move.l	d7,-(a7)
	bsr	ND14
	movem.l	(a7)+,d7
	beq.s	MD36
	move.b	d0,$7F4(a6)
MD36	rts
	and.l	d0,d2
	rts
	or.l	d0,d2
	rts
	eor.l	d0,d2
	rts
	lsl.l	d0,d2
	rts
	lsr.l	d0,d2
	rts
	cmp.l	d0,d2
	seq	d2
MD50	ext.w	d2
	ext.l	d2
	rts
	cmp.l	d0,d2
	slt	d2
	bra.s	MD50
	cmp.l	d0,d2
	sgt	d2
	bra.s	MD50
	cmp.l	d0,d2
	sne	d2
	bra.s	MD50
	cmp.l	d0,d2
	sle	d2
	bra.s	MD50
	cmp.l	d0,d2
	sge	d2
	bra.s	MD50
	not.l	d2
	rts
	neg.l	d2
	rts
	movem.l	d0-d1/a0,-(a7)
	move.l	$57C(a6),d1
	beq.s	MDA8
	movea.l	$580(a6),a0
	cmp.l	(a0),d2
	bcs.s	MD9E
	subq.l	#1,d1
	bra.s	MD96
MD92	cmp.l	(a0),d2
	bcs.s	MD9C
MD96	addq.l	#8,a0
	dbeq	d1,MD92
MD9C	subq.l	#8,a0
MD9E	move.l	4(a0),d2
MDA2	movem.l	(a7)+,d0-d1/a0
	rts
MDA8	moveq	#0,d2
	bra.s	MDA2
MDAC	movem.l	d0-d1/a0,-(a7)
	move.l	$57C(a6),d1
	beq.s	MDD8
	movea.l	$580(a6),a0
	cmp.l	4(a0),d2
	bcs.s	MDD8
	subq.l	#1,d1
	bra.s	MDCA
MDC4	cmp.l	4(a0),d2
	bcs.s	MDD2
MDCA	addq.l	#8,a0
	dbeq	d1,MDC4
	bne.s	MDD8
MDD2	move.l	-8(a0),d2
	bra.s	MDDA
MDD8	moveq	#0,d2
MDDA	movem.l	(a7)+,d0-d1/a0
	rts
	move.l	d2,d6
	eor.l	d0,d6
	tst.l	d2
	bgt.s	MDEA
	neg.l	d2
MDEA	tst.l	d0
	bgt.s	MDF0
	neg.l	d0
MDF0	move.l	d2,d3
	swap	d3
	mulu.w	d0,d2
	swap	d0
	tst.w	d3
	beq.s	ND00
	swap	d0
	bra.s	ND06
ND00	tst.w	d0
	beq.s	ND0C
	swap	d3
ND06	mulu.w	d3,d0
	swap	d0
	add.l	d0,d2
ND0C	tst.l	d6
	bpl.s	ND12
	neg.l	d2
ND12	rts
ND14	tst.l	d0
	beq.s	ND62
	move.l	d2,d6
	eor.l	d0,d6
	move.l	d6,-(a7)
	move.l	d2,-(a7)
	tst.l	d0
	bpl.s	ND26
	neg.l	d0
ND26	tst.l	d2
	bpl.s	ND2C
	neg.l	d2
ND2C	moveq	#$1F,d6
	move.l	d0,d7
	moveq	#0,d0
ND32	add.l	d7,d7
	dbcs	d6,ND32
	roxr.l	#1,d7
	subi.w	#$1F,d6
	neg.w	d6
ND40	add.l	d0,d0
	cmp.l	d7,d2
	bcs.s	ND4A
	addq.l	#1,d0
	sub.l	d7,d2
ND4A	lsr.l	#1,d7
	dbf	d6,ND40
	move.l	(a7)+,d6
	bpl.s	ND56
	neg.l	d2
ND56	move.l	(a7)+,d6
	bpl.s	ND5C
	neg.l	d0
ND5C	exg	d0,d2
	cmp.b	d0,d0
	rts
ND62	moveq	#3,d0
	rts
ND66	tst.b	d1
	bmi.s	ND9E
	cmp.b	#$2E,d1
	beq.s	ND9E
	cmp.b	#$30,d1
	bcs.s	ND9A
	cmp.b	#$3A,d1
	bcs.s	ND9E
	cmp.b	#$40,d1
	bcs.s	ND9A
	cmp.b	#$5B,d1
	bcs.s	ND9E
	cmp.b	#$5F,d1
	beq.s	ND9E
	cmp.b	#$61,d1
	bcs.s	ND9A
	cmp.b	#$7B,d1
	bcs.s	ND9E
ND9A	moveq	#-1,d0
	rts
ND9E	moveq	#0,d0
	rts
NDA2	movem.l	d5-d6/a1-a2,-(a7)
	move.l	a4,-(a7)
	moveq	#0,d7
	lea	JDAA(pc),a0
NDAE	move.b	(a0)+,d7
	beq.s	NDC0
	cmp.b	(a0)+,d1
	bne.s	NDAE
	tst.b	d7
	bmi	OD8E
	bra	OD40
NDC0	cmp.b	#$3C,d1
	beq.s	OD14
	cmp.b	#$3E,d1
	beq.s	OD2A
	moveq	#0,d2
	cmp.b	#$3A,d1
	bcc.s	NDDA
	cmp.b	#$30,d1
	bcc.s	OD4A
NDDA	moveq	#1,d7
	bsr.s	ND66
	bne.s	OD10
	lea	-1(a4),a1
	moveq	#0,d2
NDE6	addq.w	#1,d2
	move.b	(a4)+,d1
	bsr	ND66
	beq.s	NDE6
	bsr	PDF8
	bne.s	NDFC
	move.l	(a0),d2
	bra	OD8A
NDFC	move.l	a1,-(a7)
	bsr	TDB4
	movea.l	(a7)+,a1
	beq	OD8A
	movea.l	a1,a4
	moveq	#0,d2
	bra	PD18
OD10	moveq	#$19,d7
	bra.s	OD42
OD14	moveq	#$C,d7
	move.b	(a4)+,d1
	cmp.b	#$3C,d1
	beq.s	OD3E
	cmp.b	#$3E,d1
	beq.s	OD26
	bra.s	OD34
OD26	moveq	#$B,d7
	bra.s	OD40
OD2A	moveq	#$D,d7
	move.b	(a4)+,d1
	cmp.b	#$3E,d1
	beq.s	OD3E
OD34	cmp.b	#$3D,d1
	bne.s	OD42
	addq.w	#2,d7
	bra.s	OD40
OD3E	subq.w	#4,d7
OD40	move.b	(a4)+,d1
OD42	movea.l	(a7)+,a0
	movem.l	(a7)+,d5-d6/a1-a2
	rts
OD4A	moveq	#0,d2
	subq.l	#1,a4
	moveq	#1,d7
	bra	PD18
OD54	move.b	(a4)+,d1
	cmp.b	#$30,d1
	bcs	PD44
	cmp.b	#$3A,d1
	bcc	PD44
OD66	add.l	d2,d2
	move.l	d2,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d2
	subi.b	#$30,d1
	andi.l	#$F,d1
	add.l	d1,d2
	move.b	(a4)+,d1
	cmp.b	#$3A,d1
	bcc.s	OD8A
	cmp.b	#$30,d1
	bcc.s	OD66
OD8A	moveq	#1,d7
	bra.s	OD42
OD8E	neg.b	d7
	ext.w	d7
	moveq	#0,d2
	moveq	#1,d0
	exg	d0,d7
	jmp	OD9A-2(pc,d0.w)

OD9A	bra.s	PD18
	bra.s	ODCC
	bra.s	ODF0
	bra.s	ODA6
	bra.s	OD54
ODA6	moveq	#4,d0
	move.b	d1,d3
ODAA	move.b	(a4)+,d1
	cmp.b	#$A,d1
	beq	PD44
	cmp.b	d3,d1
	bne.s	ODC0
	move.b	(a4)+,d1
	cmp.b	d3,d1
	beq.s	ODC0
	bra.s	OD42
ODC0	subq.b	#1,d0
	bcs	PD52
	lsl.l	#8,d2
	move.b	d1,d2
	bra.s	ODAA
ODCC	move.b	(a4)+,d1
	subi.b	#$30,d1
	bcs.s	PD44
	cmp.b	#2,d1
	bcc.s	PD44
ODDA	add.l	d2,d2
	bcs.s	PD52
	or.b	d1,d2
	move.b	(a4)+,d1
	subi.b	#$30,d1
	bcs.s	PD36
	cmp.b	#2,d1
	bcs.s	ODDA
	bra.s	PD36
ODF0	move.b	(a4),d0
	subi.b	#$30,d0
	bcs.s	PD3E
	cmp.b	#9,d0
	bcc.s	PD3E
	move.b	d0,d1
	addq.l	#1,a4
PD02	lsl.l	#3,d2
	bcs.s	PD52
	or.b	d1,d2
	move.b	(a4)+,d1
	subi.b	#$30,d1
	bcs.s	PD36
	cmp.b	#9,d1
	bcs.s	PD02
	bra.s	PD36
PD18	lea	PD56(pc),a0
	moveq	#0,d1
	move.b	(a4)+,d1
	bmi.s	PD44
	move.b	0(a0,d1.w),d1
	bmi.s	PD44
PD28	lsl.l	#4,d2
	or.b	d1,d2
	move.b	(a4)+,d1
	bmi.s	PD36
	move.b	0(a0,d1.w),d1
	bpl.s	PD28
PD36	move.b	-1(a4),d1
	bra	OD42
PD3E	moveq	#$40,d1
	bra	NDDA
PD44	moveq	#4,d0
PD46	tst.b	$7F4(a6)
	bne.s	PD36
	move.b	d0,$7F4(a6)
	bra.s	PD36
PD52	moveq	#5,d0
	bra.s	PD46
PD56	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	1,$203,$405,$607
	dc.w	$809,$FFFF,$FFFF,$FFFF
	dc.w	$FF0A,$B0C,$D0E,$FFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FF0A,$B0C,$D0E,$FFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
PDD6	move.b	1(a1),d0
	subi.b	#$30,d0
	bcs.s	QD08
	cmp.b	#$A,d0
	bcc.s	QD08
	ext.w	d0
	add.w	d0,d0
	lea	RD58(pc),a0
	move.w	0(a0,d0.w),d0
	lea	0(a6,d0.w),a0
	bra.s	QD70
PDF8	move.b	(a1),d0
	andi.b	#$DF,d0
	cmp.w	#2,d2
	beq.s	QD0C
	bcc	QD90
QD08	moveq	#-1,d0
	rts
QD0C	lea	$30(a6),a0
	cmp.b	#$41,d0
	beq.s	QD74
	lea	$10(a6),a0
	cmp.b	#$44,d0
	beq.s	QD74
	cmp.b	#$53,d0
	beq.s	QD48
	cmp.b	#$4D,d0
	beq.s	PDD6
	cmp.b	#$50,d0
	bne.s	QD08
	lea	$54(a6),a0
	cmpi.b	#$43,1(a1)
	beq.s	QD70
	cmpi.b	#$63,1(a1)
	beq.s	QD70
	bra.s	QD08
QD48	move.b	1(a1),d0
	andi.b	#$DF,d0
	lea	$58(a6),a0
	cmp.b	#$52,d0
	beq.s	QD70
	cmp.b	#$50,d0
	bne.s	QD08
	lea	$4C(a6),a0
	btst	#5,$5A(a6)
	beq.s	QD70
	lea	$50(a6),a0
QD70	moveq	#0,d0
	rts
QD74	move.b	1(a1),d0
	subi.b	#$30,d0
	bcs.s	QD08
	cmp.b	#8,d0
	bcc.s	QD08
	andi.w	#$F,d0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0
	bra.s	QD70
QD90	movem.l	d1/d3/a1,-(a7)
	move.b	#$DF,d3
	cmp.w	#3,d2
	bne.s	QDCC
	move.b	(a1)+,d1
	and.b	d3,d1
	cmp.b	#$53,d1
	bne.s	QDC8
	move.b	(a1)+,d1
	and.b	d3,d1
	cmp.b	#$53,d1
	bne.s	QDC8
	move.b	(a1)+,d1
	and.b	d3,d1
	cmp.b	#$50,d1
	bne.s	QDC8
	lea	$50(a6),a0
	moveq	#0,d1
QDC2	movem.l	(a7)+,d1/d3/a1
	rts
QDC8	moveq	#-1,d1
	bra.s	QDC2
QDCC	cmp.w	#4,d2
	beq.s	QDD4
	bcs.s	QDC8
QDD4	clr.l	-(a7)
	movea.l	a7,a0
	move.b	(a1)+,d1
	and.b	d3,d1
	move.b	d1,(a0)+
	move.b	(a1)+,d1
	and.b	d3,d1
	move.b	d1,(a0)+
	move.b	(a1)+,d1
	and.b	d3,d1
	move.b	d1,(a0)+
	move.b	(a1)+,d1
	and.b	d3,d1
	move.b	d1,(a0)+
	move.l	(a7)+,d1
	cmp.l	#$434F4445,d1
	beq.s	RD0A
	cmp.l	#$48554E4B,d1
	bne.s	QDC8
	cmp.w	#4,d2
	bne.s	RD16
	bra.s	QDC8
RD0A	cmp.w	#4,d2
	bne.s	QDC8
	lea	$AA(a6),a0
	bra.s	QDC2
RD16	move.w	d2,d0
	subq.w	#4,d0
	moveq	#0,d3
RD1C	move.b	(a1)+,d1
	subi.b	#$30,d1
	bcs.s	QDC8
	cmp.b	#$A,d1
	bcc.s	QDC8
	mulu.w	#$A,d3
	ext.w	d1
	add.w	d1,d3
	subq.w	#1,d0
	bne.s	RD1C
	lea	NE0C(pc),a0
RD3A	tst.l	(a0)
	beq.s	QDC8
	movea.l	(a0),a0
	adda.l	a0,a0
	adda.l	a0,a0
	subq.w	#1,d3
	bcc.s	RD3A
	addq.l	#4,a0
	move.l	a0,$7C8(a6)
	lea	$7C8(a6),a0
	moveq	#0,d1
	bra	QDC2

RD58	dc.w	$07b4,$05fe,$0644,$068a,$06d0,$0716
	dc.w	$07b8,$07bc,$07c0,$07c4

RD6C	move.l	a2,d0
	andi.l	#$FF000000,d0
	bne.s	RD7E
	cmpa.l	#$F80000,a2
	bcc.s	RD9A
RD7E	movem.l	d1/a0-a1/a6,-(a7)
	movea.l	4.w,a6
	move.l	a2,d0
	move.w	#$8000,d0
	movea.l	d0,a1
	jsr	-$216(a6)
	movem.l	(a7)+,d1/a0-a1/a6
	tst.w	d0
	beq.s	RD9E
RD9A	moveq	#0,d0
	rts
RD9E	moveq	#-1,d0
	rts
	andi.b	#$FE,d0
RDA6	cmp.l	#8,d0
	bcs.s	RDB2
	cmp.b	d0,d0
	rts
RDB2	andi.b	#4,ccr
	rts
RDB8	move.l	a0,d1
	move.l	#$3EE,d2
RDC0	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d3
	bne.s	RDDE
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	moveq	#0,d1
RDDE	eori.b	#4,ccr
	rts
RDE4	move.l	a5,d1
	move.l	#$3ED,d2
	bra.s	RDC0
RDEE	move.l	d3,-(a7)
	move.l	d3,d1
	moveq	#0,d2
	moveq	#1,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$42(a6)
	movea.l	(a7)+,a6
	move.l	(a7),d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$42(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	move.l	(a7),d1
	moveq	#0,d2
	moveq	#-1,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$42(a6)
	movea.l	(a7)+,a6
	move.l	(a7)+,d3
	rts
SD2C	move.l	d3,-(a7)
	move.l	d3,d1
	move.l	a0,d2
	move.l	d4,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	move.l	(a7)+,d3
	rts

SD44	move.l	d3,-(a7)
	move.l	d3,d1
	move.l	a0,d2
	move.l	d4,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$30(a6)
	movea.l	(a7)+,a6
	move.l	(a7)+,d3
	tst.l	d0
	bge.s	SD72

	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	move.w	d0,-(a7)
	bsr.s	SD76
	move.w	(a7)+,d0
	rts

SD72	moveq	#0,d0
	rts

SD76	move.l	d3,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
	rts

SD86	move.l	d3,$174(a6)

SD8A	;lea	$BE8(a6),a0
	move.l	file.dsm.mem(pc),a0

	move.l	a0,$178(a6)		; disassembly buffer ptr
	rts

SD94	bsr.s	SDC2
	move.l	$174(a6),d3
	bra.s	SD76

SD9C	bsr	RB26
	beq	TDA2

;	lea	$DE8(a6),a0
	move.l	file.dsm.mem(pc),a0
	add.l	#FILE_DSM_BUF_SIZE,a0

	movea.l	$178(a6),a1		; disassembly buffer ptr
	cmpa.l	a0,a1
	bne.s	SDB8
	move.w	d1,-(a7)
	bsr.s	SDC2
	move.w	(a7)+,d1
	bra.s	SD9C

SDB8	move.b	d1,(a1)+
	move.l	a1,$178(a6)		; disassembly buffer ptr
	bra	TDA8

SDC2	move.l	$178(a6),d0		; disassembly buffer ptr

;	lea	$BE8(a6),a0
	move.l	file.dsm.mem(pc),a0

	sub.l	a0,d0
	beq.s	SDE8

	movem.l	d3-d4,-(a7)
	move.l	$174(a6),d3		; file lock

;	lea	$BE8(a6),a0
	move.l	file.dsm.mem(pc),a0

	move.l	d0,d4
	bsr	SD44
	beq.s	SDE8
	bclr	#7,$E4(a6)

SDE8	movem.l	(a7)+,d3-d4
	bra.s	SD8A

SDEE	move.l	a0,-(a7)
	bsr.s	TD2E
	move.l	(a7),d1
	move.l	#$3EE,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	bne.s	TD1C
	addq.l	#4,a7
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$84(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	rts
TD1C	move.l	d0,$190(a6)
	lea	$864(a6),a1
	movea.l	(a7)+,a0
TD26	move.b	(a0)+,(a1)+
	bne.s	TD26
	moveq	#0,d0
	rts
TD2E	move.l	$190(a6),d1
	beq.s	TD44
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
	clr.l	$190(a6)
TD44	rts

TD46	tst.b	$E4(a6)
	bpl.s	TDA8
	cmp.b	#$A,d1
	bne.s	TD5A
	tst.b	d3
	beq.s	TD72
	moveq	#$20,d1
	bra.s	TD72

TD5A	cmp.b	#9,d1
	bne.s	TD64
	tst.b	d3
	beq.s	TD72
TD64	move.b	d1,d0
	andi.b	#$7F,d0
	cmp.b	#$20,d0
	bcc.s	TD72
	moveq	#$20,d1
TD72	tst.l	$174(a6)
	bne	SD9C

	move.b	d1,-(a7)
	move.l	$190(a6),d1
	move.l	a7,d2
	moveq	#1,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$30(a6)
	movea.l	(a7)+,a6
	move.b	(a7)+,d1
	subq.l	#1,d0
	bne.s	TDA2
	cmp.b	#$A,d1
	bne.s	TDA8
	bsr	RB26
	bne.s	TDA8
TDA2	bclr	#7,$E4(a6)
TDA8	movem.l	(a7)+,d0-d3/d7/a0-a2
	rts

TDAE	tst.l	$190(a6)
	rts
TDB4	tst.b	$586(a6)
	beq.s	TDFC
	lea	$C4C(a6),a0
	move.b	d2,(a0)
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	#$5F,(a0)+
	subq.w	#1,d0
	bmi	AE34
TDCE	move.b	(a1)+,(a0)+
	dbf	d0,TDCE
	lea	$C4E(a6),a1
	bsr	TDFC
	beq	AE34
	lea	$C4C(a6),a1
	move.b	(a1)+,d2
	addq.b	#1,d2
	bsr	TDFC
	beq	AE34
	lea	$C4C(a6),a1
	move.b	(a1)+,d2
	addq.b	#1,d2
	move.b	#$40,(a1)
TDFC	movem.l	d1/d4/a2,-(a7)
	lea	$AE(a6),a2
	tst.l	(a2)
	beq	UDC4
	moveq	#0,d0
	move.b	d2,d0
	cmp.w	$7F6(a6),d0
	ble.s	UD18
	move.w	$7F6(a6),d0
UD18	tst.b	$E6(a6)
	bne	UDCC
	clr.l	-(a7)
	movea.l	a7,a0
	moveq	#1,d1
	move.b	(a1)+,(a0)+
	cmp.b	d1,d0
	beq.s	UD46
	addq.b	#1,d1
	move.b	(a1)+,(a0)+
	cmp.b	d1,d0
	beq.s	UD46
	addq.b	#1,d1
	move.b	(a1)+,(a0)+
	cmp.b	d1,d0
	beq.s	UD46
	addq.b	#1,d1
	move.b	(a1)+,(a0)+
	cmp.b	d1,d0
	beq.s	UD46
	addq.b	#1,d1
UD46	move.l	(a7)+,d1
UD48	move.l	(a2),d3
	beq.s	UD5E
	asl.l	#2,d3
	movea.l	d3,a2
	lea	4(a2),a0
	cmpi.l	#$3F0,(a0)+
	bne.s	UD48
	moveq	#1,d3
UD5E	beq.s	UDC4
UD60	move.l	(a0)+,d3
	beq.s	UD48
	asl.l	#2,d3
	cmp.l	(a0),d1
	bne.s	UDBE
	move.w	d3,d4
	cmp.w	$7F6(a6),d3
	ble.s	UD76
	move.w	$7F6(a6),d4
UD76	cmp.w	d4,d0
	bgt.s	UDBE
	cmp.w	#4,d4
	bne.s	UD86
	cmp.w	d4,d0
	ble.s	UDAE
	bra.s	UDBE
UD86	movem.l	d0-d1/a0-a1,-(a7)
	addq.l	#4,a0
	subq.l	#4,d0
	subq.l	#4,d4
UD90	move.b	(a0)+,d1
	beq.s	UDBA
	cmp.b	(a1)+,d1
	bne.s	UDBA
	subq.w	#1,d0
	beq.s	UDA2
	subq.w	#1,d4
	bne.s	UD90
	bra.s	UDBA
UDA2	subq.l	#1,d4
	beq.s	UDAA
	tst.b	(a0)
	bne.s	UDBA
UDAA	movem.l	(a7)+,d0-d1/a0-a1
UDAE	move.l	0(a0,d3.l),d2
	movem.l	(a7)+,d1/d4/a2
	moveq	#0,d0
	rts
UDBA	movem.l	(a7)+,d0-d1/a0-a1
UDBE	lea	4(a0,d3.l),a0
	bra.s	UD60
UDC4	movem.l	(a7)+,d1/d4/a2
	moveq	#-1,d0
	rts
UDCC	move.l	(a2),d3
	beq.s	UDE2
	asl.l	#2,d3
	movea.l	d3,a2
	lea	4(a2),a0
	cmpi.l	#$3F0,(a0)+
	bne.s	UDCC
	moveq	#1,d3
UDE2	beq.s	UDC4
	move.b	(a1),d1
	bsr	VD30
UDEA	move.l	(a0)+,d3
	beq.s	UDCC
	asl.l	#2,d3
	move.w	d3,d4
	cmp.w	$7F6(a6),d3
	ble.s	UDFC
	move.w	$7F6(a6),d4
UDFC	cmp.w	d4,d0
	bgt.s	VD2A
	movem.l	d0-d1/a0-a1,-(a7)
VD04	move.b	(a0)+,d1
	beq.s	VD26
	bsr.s	VD30
	move.b	d1,-(a7)
	move.b	(a1)+,d1
	bsr.s	VD30
	cmp.b	(a7)+,d1
	bne.s	VD26
	subq.w	#1,d0
	beq.s	VD1E
	subq.w	#1,d4
	bne.s	VD04
	bra.s	VD26
VD1E	subq.l	#1,d4
	beq.s	UDAA
	tst.b	(a0)
	beq.s	UDAA
VD26	movem.l	(a7)+,d0-d1/a0-a1
VD2A	lea	4(a0,d3.l),a0
	bra.s	UDEA
VD30	cmp.b	#$61,d1
	bcs.s	VD40
	cmp.b	#$7B,d1
	bcc.s	VD40
	andi.b	#$DF,d1
VD40	rts
VD42	bsr	BEEA
VD46	move.l	$AE(a6),d1
	cmp.l	A58(pc),d1
	beq.s	VD5C
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$9C(a6)
	movea.l	(a7)+,a6
VD5C	clr.l	$AE(a6)
	move.l	$588(a6),d0
	beq.s	VD80
	movea.l	d0,a1
	move.l	$58C(a6),d0
	lsl.l	#2,d0
	addq.l	#4,d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D2(a6)
	movea.l	(a7)+,a6
	clr.l	$588(a6)
VD80	rts
VD82	tst.l	$15E(a6)
	bne	YDD6
	move.l	a0,-(a7)
	bsr.s	VD42
	suba.l	a4,a4
	lea	NE0C(pc),a5
	move.l	(a7)+,d1
	move.l	#$3ED,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	beq	WD56
	moveq	#$1A,d1
	bsr	ID60
	bsr	ZDA2
	cmp.l	#$3F3,d0
	bne	WD48
VDC2	bsr	ZDA2
	beq.s	VDCE
	bsr	ZDDA
	bra.s	VDC2
VDCE	bsr	ZDA2
	bsr	ZDA2
	move.l	d0,d5
	bsr	ZDA2
	sub.l	d5,d0
	addq.l	#1,d0
	bsr	ZDDA
VDE4	bsr	ZDA2
VDE8	cmp.l	#$3F0,d0
	beq	WD92
	cmp.l	#$3F1,d0
	beq	XD1E
	cmp.l	#$3EC,d0
	beq.s	WD68
	cmp.l	#$3F2,d0
	bne.s	WD24
	bsr	ZDA2
	tst.l	d1
	bne.s	VDE8
	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
	rts
WD24	movea.l	(a5),a5
	adda.l	a5,a5
	adda.l	a5,a5
	andi.l	#$3FFFFFFF,d0
	cmp.l	#$3E9,d0
	beq.s	WD78
	cmp.l	#$3EA,d0
	beq.s	WD78
	cmp.l	#$3EB,d0
	beq.s	WD8A
WD48	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
WD56	rts
WD58	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
	rts
WD68	bsr	ZDA2
	beq	VDE4
	addq.l	#1,d0
	bsr	ZDDA
	bra.s	WD68
WD78	bsr	ZDA2
	andi.l	#$3FFFFFFF,d0
	bsr	ZDDA
	bra	VDE4
WD8A	bsr	ZDA2
	bra	VDE4
WD92	bsr	ZD48
	bsr	ZD7A
	move.l	d0,d5
	subq.l	#4,d5
	moveq	#2,d6
WDA0	bsr	ZD86
	beq.s	WDB2
	add.l	d0,d6
	addq.l	#2,d6
	addq.l	#1,d0
	bsr	ZD92
	bra.s	WDA0
WDB2	asl.l	#2,d6
	move.l	d5,d0
	bsr	ZDD4
	bsr	WDD6
	beq.s	WD58
	lea	8(a4),a0
	move.l	a5,d1
	addq.l	#4,d1
WDC8	move.l	(a0)+,d0
	beq	VDE4
	asl.l	#2,d0
	adda.l	d0,a0
	add.l	d1,(a0)+
	bra.s	WDC8
WDD6	moveq	#8,d0
	add.l	d6,d0
	moveq	#0,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	beq.s	XD1C
	movea.l	a4,a0
	movea.l	d0,a4
	move.l	a0,d1
	bne.s	WDF8
	lea	$AE(a6),a0
WDF8	addq.l	#4,d0
	asr.l	#2,d0
	move.l	d0,(a0)
	moveq	#8,d1
	add.l	d6,d1
	move.l	d1,(a4)+
	clr.l	(a4)
	move.l	d4,d1
	move.l	a4,d2
	addq.l	#4,d2
	move.l	d6,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	move.l	a4,d0
XD1C	rts
XD1E	bsr	ZDA2
	lea	-$10(a7),a7
	asl.l	#2,d0
	move.l	d0,(a7)
	bsr	ZDC0
	move.l	d0,4(a7)
	add.l	d0,(a7)
	bsr	ZDA2
	move.l	d0,8(a7)
	bsr	ZDA2
	bsr	YDBE
	bne	YD06
	move.l	8(a7),d1
	lea	4(a5,d1.l),a0
	move.l	a0,d1
	bsr	YD88
	beq	YD06
	movea.l	a0,a3
	move.l	a3,$C(a7)
	move.l	4(a7),d0
	addq.l	#4,d0
	move.l	d0,$28(a3)
	cmpi.l	#$53524320,$24(a3)
	beq.s	XDA0
	bsr	ZDA2
	bsr	YD14
	bsr	ZDC0
	move.l	d0,$2C(a3)
	sub.l	(a7),d0
	neg.l	d0
	move.l	d0,$38(a3)
	cmpi.l	#$4C494E45,$24(a3)
	beq.s	YD00
	bsr	ZDA2
	addq.l	#4,$2C(a3)
	bra.s	YD02
XDA0	moveq	#9,d0
	bsr	ZDDA
	bsr	ZD48
	bsr	ZD86
	move.l	d0,$38(a3)
	bsr	ZD86
	bsr	ZD86
	move.l	d0,4(a7)
	bsr	ZD7A
	add.l	4(a7),d0
	move.l	d0,$2C(a3)
	move.l	4(a7),d3
	addq.w	#4,a3
	bra.s	XDE2
XDD2	move.b	(a0)+,d0
	beq.s	XDEC
	cmp.b	#$3A,d0
	beq.s	XDE2
	cmp.b	#$2F,d0
	bne.s	XDE6
XDE2	move.l	a0,4(a7)
XDE6	dbf	d3,XDD2
	clr.b	(a0)
XDEC	movea.l	4(a7),a0
	moveq	#$1E,d0
XDF2	move.b	(a0)+,(a3)+
	dbeq	d0,XDF2
	movea.l	$C(a7),a3
	move.l	$38(a3),d0
YD00	asr.l	#3,d0
YD02	move.l	d0,$34(a3)
YD06	move.l	(a7),d0
	lea	$10(a7),a7
	bsr	ZDD4
	bra	VDE4
YD14	pea	$22(a3)
	move.l	a3,-(a7)
	addq.w	#4,a3
	bra.s	YD4C
YD1E	move.l	d0,-(a7)
	bsr	ZDA2
	moveq	#3,d1
YD26	rol.l	#8,d0
	cmp.b	#$3A,d0
	beq.s	YD40
	cmp.b	#$2F,d0
	beq.s	YD40
	move.b	d0,(a3)+
	cmpa.l	8(a7),a3
	bls.s	YD46
	subq.l	#1,a3
	bra.s	YD46
YD40	movea.l	4(a7),a3
	addq.w	#4,a3
YD46	dbf	d1,YD26
	move.l	(a7)+,d0
YD4C	dbf	d0,YD1E
	clr.b	(a3)
	movea.l	(a7)+,a3
	addq.l	#4,a7
	rts
YD58	movem.l	d1/a1,-(a7)
	asl.l	#2,d0
	bra.s	YD6E
YD60	cmpi.b	#$3A,(a0)+
	beq.s	YD6E
	cmpi.b	#$2F,-1(a0)
	bne.s	YD72
YD6E	movea.l	a0,a1
	move.l	d0,d1
YD72	dbf	d0,YD60
	movem.l	(a7)+,d0/a0
YD7A	move.b	(a1)+,(a0)+
	beq.s	YD86
	subq.l	#1,d0
	dbls	d1,YD7A
	clr.b	(a1)
YD86	rts
YD88	movem.l	d0-d1,-(a7)
	moveq	#$3C,d0
	bsr	FE6A
	movem.l	(a7)+,d0-d1
	beq	YDBC
	clr.l	$28(a0)
	move.l	d0,$24(a0)
	move.l	d1,$30(a0)
	lea	$578(a6),a1
YDAA	move.l	(a1),d0
	beq.s	YDB8
	exg	d0,a1
	cmp.l	$30(a1),d1
	bcc.s	YDAA
	exg	d0,a1
YDB8	move.l	d0,(a0)
	move.l	a0,(a1)
YDBC	rts
YDBE	cmp.l	#$48434C4E,d0
	beq.s	YDD4
	cmp.l	#$4C494E45,d0
	beq.s	YDD4
	cmp.l	#$53524320,d0
YDD4	rts
YDD6	lea	A58,a4
	move.l	(a4),$AE(a6)
YDE0	move.l	(a4),d0
	beq.s	ZD46
	asl.l	#2,d0
	movea.l	d0,a4
	lea	4(a4),a2
	cmpi.l	#$3F1,(a2)+
	bne.s	YDE0
	addq.l	#8,a2
	move.l	(a2),d0
	bsr.s	YDBE
	bne.s	YDE0
	move.l	-4(a2),d1
	bsr.s	YD88
	beq.s	ZD46
	movea.l	a0,a3
	move.l	4(a2),d1
	asl.l	#2,d1
	lea	8(a2,d1.l),a0
	cmpi.l	#$4C494E45,$24(a3)
	beq.s	ZD1E
	move.l	(a0)+,d0
	bra.s	ZD2A
ZD1E	move.l	-8(a2),d0
	sub.l	4(a2),d0
	subq.l	#3,d0
	asr.l	#1,d0
ZD2A	move.l	d0,$34(a3)
	move.l	a0,$2C(a3)
	move.l	4(a2),d0
	moveq	#$1E,d1
	lea	8(a2),a0
	lea	4(a3),a1
	bsr	YD58
	bra.s	YDE0
ZD46	rts

ZD48	bsr	ZDC0
	move.l	d0,-(a7)
	move.l	d4,d1
	lea	$BE8(a6),a0
	move.l	a0,d2
	move.l	#$200,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	bge.s	ZD6E
	moveq	#0,d0
ZD6E	lea	$BE8(a6),a0
	movea.l	(a7)+,a1
	move.l	d0,d2
	add.l	a0,d2
	rts

ZD7A	move.l	a0,d0
	pea	$BE8(a6)
	sub.l	(a7)+,d0
	add.l	a1,d0
	rts

ZD86	cmp.l	a0,d2
	beq.s	ZD8E
	move.l	(a0)+,d0
	rts
ZD8E	bsr.s	ZD48
	bra.s	ZD86
ZD92	tst.l	d0
	beq.s	ZDA0
ZD96	move.l	d0,-(a7)
	bsr.s	ZD86
	moveq	#-1,d0
	add.l	(a7)+,d0
	bne.s	ZD96
ZDA0	rts
ZDA2	move.l	d4,d1
	lea	$988(a6),a0
	move.l	a0,d2
	moveq	#4,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	move.l	d0,d1
	move.l	$988(a6),d0
	rts
ZDC0	moveq	#0,d2
	moveq	#0,d3
ZDC4	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$42(a6)
	movea.l	(a7)+,a6
	rts
ZDD4	moveq	#-1,d3
	move.l	d0,d2
	bra.s	ZDC4
ZDDA	moveq	#0,d3
	move.l	d0,d2
	asl.l	#2,d2
	bra.s	ZDC4
ZDE2	movea.l	d0,a0
	move.l	(a0)+,d0
	asl.l	#2,d0
	subq.l	#1,d0
ZDEA	move.b	(a0)+,d1
	beq.s	ZDF8
	bsr	QC52
	subq.b	#1,d2
	dbeq	d0,ZDEA
ZDF8	rts
ZDFA	movem.l	d1/a0,-(a7)
	movea.l	d0,a0
	move.l	(a0)+,d0
	asl.l	#2,d0
	subq.l	#1,d0
	cmp.w	#$F,d0
	bcs.s	AE0E
	moveq	#$F,d0
AE0E	move.b	(a0)+,d1
	beq.s	AE18
	move.b	d1,(a4)+
	dbf	d0,AE0E
AE18	movem.l	(a7)+,d1/a0
	rts
AE1E	movea.l	a4,a0
	move.l	d4,d3
	subq.l	#1,d3
AE24	move.b	(a0)+,d1
	beq.s	AE30
	bsr	QC52
	dbf	d3,AE24
AE30	rts
AE32	cmp.b	d0,d0
AE34	rts
AE36	bsr	T10
	movem.l	d2-d5/a0/a2-a4,-(a7)
	moveq	#0,d5
	moveq	#0,d2
	lea	$578(a6),a2
AE46	bsr	BE76
	beq	AE56
	add.l	$34(a2),d5
	addq.l	#1,d2
	bra.s	AE46
AE56	move.l	d5,d0
	beq	BE72
	asl.l	#3,d0
	bsr	FE6A
	beq	BE72
	movea.l	a0,a3
	movea.l	a0,a4
	tst.l	$15E(a6)
	bne.s	AE8E
	move.l	#TB4+1,d1
	move.l	#$3ED,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	beq	BE6C
AE8E	lea	$578(a6),a2
AE92	movea.l	$10(a7),a0
	bsr	BE76
	beq	BE40
	tst.l	$15E(a6)
	beq.s	AEC6
	movea.l	$2C(a2),a0
	move.l	$34(a2),d0
	cmpi.l	#$48434C4E,$24(a2)
	bne.s	AEC0
	bsr	BEA8
	bra.s	AE92
AEBC	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
AEC0	subq.l	#1,d0
	bcc.s	AEBC
	bra.s	AE92
AEC6	move.l	$28(a2),d0
	bsr	ZDD4
	bsr	ZDA2
	cmp.l	$24(a2),d0
	bne	BE5E
	move.l	$2C(a2),d0
	bsr	ZDD4
	move.l	$38(a2),d3
	cmpi.l	#$48434C4E,$24(a2)
	bne.s	BE1A
	move.l	d3,d0
	bsr	FE6A
	beq	BE5E
	move.l	d4,d1
	move.l	a0,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	movea.l	d2,a0
	bsr	BEA8
	movea.l	d2,a0
	bsr	FE94
	bra	AE92
BE1A	move.l	d4,d1
	move.l	a4,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	move.l	$34(a2),d0
	move.l	$30(a2),d1
	bra.s	BE38
BE34	addq.l	#4,a4
	add.l	d1,(a4)+
BE38	subq.l	#1,d0
	bcc.s	BE34
	bra	AE92
BE40	tst.l	$15E(a6)
	bne.s	BE54
	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
BE54	movea.l	a3,a0
	move.l	d5,d0
BE58	movem.l	(a7)+,d2-d5/a1-a4
	rts
BE5E	move.l	d4,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
BE6C	movea.l	a3,a0
	bsr	FE94
BE72	moveq	#0,d0
	bra.s	BE58
BE76	move.l	(a2),d0
	beq	BEA0
	movea.l	d0,a2
	movem.l	a0/a2,-(a7)
	addq.w	#4,a2
BE84	move.b	(a0)+,d1
	bsr	VD30
	move.b	d1,d0
	move.b	(a2)+,d1
	bsr	VD30
	cmp.b	d0,d1
	bne.s	BEA2
	tst.b	d0
	bne.s	BE84
	movem.l	(a7)+,a0/a2
	moveq	#1,d0
BEA0	rts
BEA2	movem.l	(a7)+,a0/a2
	bra.s	BE76
BEA8	move.l	a3,-(a7)
	suba.l	a1,a1
	movea.l	$30(a2),a3
	move.l	$34(a2),d1
	add.l	d1,d1
	bra.s	BEC4
BEB8	move.b	(a0)+,d0
	beq.s	BECC
	ext.w	d0
BEBE	adda.w	d0,a1
BEC0	move.l	a1,(a4)+
	exg	a1,a3
BEC4	subq.l	#1,d1
	bcc.s	BEB8
	movea.l	(a7)+,a3
	rts

BECC	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	bne.s	BEBE
	tst.w	d0
	bne.s	BEBE
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	adda.l	d0,a1
	bra.s	BEC0
BEEA	move.l	$578(a6),d0
	beq.s	CE00
	clr.l	$578(a6)
BEF4	movea.l	d0,a0
	move.l	(a0),-(a7)
	bsr	FE94
	move.l	(a7)+,d0
	bne.s	BEF4
CE00	rts
CE02	move.l	(a1),d1
	beq.s	CE18
	asl.l	#2,d1
	movea.l	d1,a1
	lea	4(a1),a0
	cmpi.l	#$3F0,(a0)+
	bne.s	CE02
	moveq	#1,d1
CE18	rts
CE1A	lea	$AE(a6),a1
	moveq	#0,d0
CE20	bsr.s	CE02
	beq.s	CE34
CE24	addq.l	#3,d0
	move.l	(a0),d1
	asl.l	#2,d1
	lea	8(a0,d1.l),a0
	bne.s	CE24
	subq.l	#3,d0
	bra.s	CE20
CE34	tst.l	d0
	beq.s	CE90
	lsr.l	#1,d0
	bset	#0,d0
	addq.l	#2,d0
	move.l	d0,$58C(a6)
	asl.l	#2,d0
	addq.l	#4,d0
	move.l	#$10000,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	move.l	d0,$588(a6)
	beq.s	CE90
	movem.l	d6-d7,-(a7)
	lea	$AE(a6),a1
CE68	bsr.s	CE02
	beq.s	CE8C
	move.l	a1,-(a7)
CE6E	move.l	(a0),d1
	bne.s	CE76
	movea.l	(a7)+,a1
	bra.s	CE68
CE76	asl.l	#2,d1
	move.l	4(a0,d1.l),d0
	move.l	a0,-(a7)
	bsr.s	CE92
	movea.l	(a7)+,a0
	beq.s	CE86
	move.l	a0,(a1)
CE86	lea	8(a0,d1.l),a0
	bra.s	CE6E
CE8C	movem.l	(a7)+,d6-d7
CE90	rts
CE92	movea.l	$588(a6),a1
	move.l	$58C(a6),d2
	move.l	d0,d6
	divu.w	d2,d6
	bvc.s	CEB2
	movem.l	d0/d2,-(a7)
	exg	d2,d0
	bsr	ND14
	move.l	d0,d6
	swap	d6
	movem.l	(a7)+,d0/d2
CEB2	swap	d6
	ext.l	d6
	bpl.s	CEBA
	neg.l	d6
CEBA	add.l	d6,d6
	add.l	d6,d6
	add.l	d2,d2
	add.l	d2,d2
CEC2	move.l	0(a1,d6.l),d7
	beq.s	CEE2
	movea.l	d7,a0
	move.l	(a0),d7
	asl.l	#2,d7
	cmp.l	4(a0,d7.l),d0
	beq.s	CEDE
	addq.l	#4,d6
	cmp.l	d6,d2
	bne.s	CEC2
	moveq	#0,d6
	bra.s	CEC2
CEDE	movea.l	a0,a1
	rts
CEE2	lea	0(a1,d6.l),a1
	moveq	#-1,d7
	rts
CEEA	movem.l	d1-d2/d6-d7/a0-a1,-(a7)
	tst.l	d0
	bmi.s	CEF6
	bsr.s	CE92
	beq.s	CEFA
CEF6	moveq	#0,d0
	bra.s	CEFC
CEFA	move.l	a1,d0
CEFC	movem.l	(a7)+,d1-d2/d6-d7/a0-a1
	rts

DE02	tst.l	$588(a6)
	bne.s	CEEA
	tst.b	$163(a6)
	bne.s	DE10
	rts

DE10	cmp.l	$16C(a6),d0
	bcs.s	DE36
	cmp.l	$170(a6),d0
	bhi.s	DE36
	movem.l	d1/a0,-(a7)
	tst.b	$163(a6)
	bmi.s	DE4E
	movea.l	$164(a6),a0
DE2A	move.l	(a0)+,d1
	beq.s	DE3A
	cmp.l	d0,d1
	bne.s	DE2A
DE32	movem.l	(a7)+,d1/a0
DE36	moveq	#0,d0
	rts

DE3A	tst.l	$168(a6)
	beq.s	DE46
	cmpa.l	$168(a6),a0
	bge.s	DE32
DE46	move.l	d0,-4(a0)
	clr.l	(a0)
	bra.s	DE32
DE4E	movea.l	$164(a6),a0
DE52	move.l	(a0)+,d1
	beq.s	DE32
	cmp.l	d1,d0
	bne.s	DE52

	lea	$180(a6),a0
	move.b	#$6C,(a0)+
	move.l	d0,d1
	exg	a0,a4
	bsr	DA18
	exg	a0,a4
	clr.b	(a0)
	move.l	a0,d1
	lea	$17C(a6),a0
	sub.l	a0,d1
	subq.l	#1,d1
	asr.l	#2,d1
	move.l	d1,(a0)
	move.l	a0,d0
	movem.l	(a7)+,d1/a0
	rts

DE84	sf	$592(a6)
	move.l	d0,-(a7)
	bsr	DE02
	bne.s	DEB8
	move.l	(a7),d0
	move.l	a0,(a7)
	btst	#0,d0
	bne.s	DEBC
	bsr	RD6C
	bne.s	DEBC
	movea.l	d0,a0
	cmpi.w	#$4EF9,(a0)
	bne.s	DEBC
	move.l	2(a0),d0
	movea.l	(a7),a0
	bsr	DE02
	beq.s	DEB8
	st	$592(a6)
DEB8	addq.w	#4,a7
	rts
DEBC	movea.l	(a7)+,a0
	moveq	#0,d0
	rts
DEC2	tst.b	$162(a6)
	beq.s	DEEA
	move.l	A60,d0
	beq	EEB4
	moveq	#0,d4
	movea.l	d0,a0
	lea	8(a0),a4
	move.l	a4,$136(a6)
	tst.b	(a0)
	beq	EEB4
	clr.b	(a0)
	bra	EE86
DEEA	moveq	#$1B,d1
	bsr	ID60
	move.l	#FED0+5,d1
	move.l	#$3ED,d2
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	bne.s	EE24
	move.l	#FED0,d1
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$1E(a6)
	movea.l	(a7)+,a6
	move.l	d0,d4
	beq	EEB4
EE24	moveq	#$1C,d1
	bsr	ID60
	lea	$988(a6),a0
	move.l	d4,d1
	move.l	a0,d2
	moveq	#8,d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
	subq.l	#8,d0
	bne	EEA4
	cmpi.l	#$420003F0,$988(a6)
	bne.s	EEA4
	move.l	$98C(a6),d0
	beq.s	EEA4
	move.l	d0,$13A(a6)
	moveq	#0,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	tst.l	d0
	beq.s	EEA4
	move.l	d0,$136(a6)
	movea.l	d0,a4
	move.l	d4,d1
	move.l	a4,d2
	move.l	$13A(a6),d3
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$2A(a6)
	movea.l	(a7)+,a6
EE86	move.l	(a4)+,d1
	beq.s	EEA4
	asl.l	#2,d1
	adda.l	d1,a4
	move.w	(a4),d1
	ext.l	d1
	move.l	(a4),d2
	ext.l	d2
	asl.l	#2,d1
	lea	$B6(a6),a0
	add.l	0(a0,d1.l),d2
	move.l	d2,(a4)+
	bra.s	EE86
EEA4	move.l	d4,d1
	beq.s	EEB4
	move.l	a6,-(a7)
	movea.l	$C2(a6),a6
	jsr	-$24(a6)
	movea.l	(a7)+,a6
EEB4	rts
EEB6	move.l	$136(a6),d0
	beq.s	EEDA
	movem.l	d1/a0,-(a7)
	exg	d0,a0
EEC2	move.l	(a0),d1
	beq.s	EED6
	asl.l	#2,d1
	cmp.l	4(a0,d1.l),d0
	beq.s	EED4
	lea	8(a0,d1.l),a0
	bra.s	EEC2
EED4	move.l	a0,d0
EED6	movem.l	(a7)+,d1/a0
EEDA	rts
	tst.l	$AE(a6)
	beq	FE4E
	lea	KED2(pc),a2
	bsr	WC36
	lea	$AE(a6),a5
	moveq	#0,d6
EEF2	move.l	(a5),d0
	beq.s	FE08
	asl.l	#2,d0
	movea.l	d0,a5
	lea	4(a5),a4
	cmpi.l	#$3F0,(a4)+
	bne.s	EEF2
	moveq	#1,d0
FE08	beq.s	FE46
FE0A	move.l	(a4)+,d4
	beq.s	EEF2
	asl.l	#2,d4
	move.l	0(a4,d4.l),d2
	bsr	IDA0
	bsr	ID88
	bsr	AE1E
	lea	4(a4,d4.l),a4
	bsr	ID9A
	addq.w	#1,d6
	cmp.w	2(a3),d6
	bne.s	FE0A
	bsr	RB9A
	cmp.b	#$1B,d1
	beq.s	FE4A
	moveq	#0,d6
	bsr	OC34
	clr.l	6(a3)
	bra.s	FE0A
FE46	bsr	RB9A
FE4A	bsr	VC2A
FE4E	rts
FE50	movem.w	(a0)+,d0-d3
	exg	d0,d1
	movea.l	a0,a1
	movea.l	$5B4(a6),a0
	move.l	a6,-(a7)
	movea.l	$BE(a6),a6
	jsr	-$10E(a6)
	movea.l	(a7)+,a6
	rts
FE6A	addq.l	#8,d0
	move.l	d0,-(a7)
	moveq	#1,d1
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$C6(a6)
	movea.l	(a7)+,a6
	move.l	(a7)+,d1
	tst.l	d0
	beq.s	FE92
	movea.l	d0,a0
	move.l	$CA(a6),(a0)
	move.l	a0,$CA(a6)
	addq.l	#4,a0
	move.l	d1,(a0)+
	rts
FE92	rts
FE94	move.l	a0,d0
	beq.s	FEBE
	subq.l	#8,a0
	lea	$CA(a6),a1
FE9E	cmpa.l	(a1),a0
	beq.s	FEAA
	tst.l	(a1)
	beq.s	FEBE
	movea.l	(a1),a1
	bra.s	FE9E
FEAA	move.l	(a0),(a1)
	movea.l	a0,a1
	move.l	4(a0),d0
	move.l	a6,-(a7)
	movea.l	4.w,a6
	jsr	-$D2(a6)
	movea.l	(a7)+,a6
FEBE	rts
FEC0	move.l	$CA(a6),d0
	beq.s	FECE
	addq.l	#8,d0
	movea.l	d0,a0
	bsr.s	FE94
	bra.s	FEC0
FECE	rts

FED0	dc.b	'LIBS:monam.libfile',0

FEE3	dc.b	'intuition.library',0

FEF5	dc.b	'dos.library',0

GE01	dc.b	'graphics.library',0

GE12	dc.b	'console.device',0

GE21	dc.b	'Workbench',0

GE2B	dc.b	'pc = ',0
	dc.b	'sr = ',0
	dc.b	'a7''= ',0

	dc.b	'Divide by zero',0

	dc.b	'CHK exception',0

	dc.b	'TRAPV exception',0

	dc.b	'Privilege violation',0

	dc.b	'Trace',0

	dc.b	'Bad interrupt',0

	dc.b	'Invalid TRAP',0

	dc.b	'Illegal exception',0

	dc.b	'Breakpoint',0

	dc.b	'd =',0

	dc.b	'a =',0

	dc.b	'Searching...',0

	dc.b	'Address error',0

	dc.b	'Bus error',0

	dc.b	'  ;',0

	dc.b	', ',0

	dc.b	'Text: ',0

	dc.b	'Data: ',0

	dc.b	'BSS : ',0

	dc.b	'Current Breakpoints:',10,0

	dc.b	'Data start,end<,size>',0

	dc.b	'Cross-reference list',0

	dc.b	'Filename',0

	dc.b	'Checking for symbols..',0

	dc.b	'Checking for libfile..',10,0

	dc.b	'Loading libfile..',10,0

	dc.b	'Task terminated',0

	dc.b	'Unknown exception',0

	dc.b	'Line A exception',0

	dc.b	'Line F exception',0

	dc.b	'Task must be running!',0

	dc.b	'Task loaded!',0

	dc.b	'No task loaded!',0

	dc.b	'Task must be suspended!',0

	dc.b	'Executing',0

	dc.b	'None',0

	dc.b	'Suspended',0

	dc.b	'Free memory Chip,Fast,All: ',0

	dc.b	'Task: ',0

	dc.b	'Hunk list:',0

	dc.b	'Memory list:',0

	dc.b	'Unordered condition',0

	dc.b	'Inexact result',0

	dc.b	'FP divide by zero',0

	dc.b	'Underflow',0

	dc.b	'Operand error',0

	dc.b	'Overflow',0

	dc.b	'Signaling NAN',0

	dc.b	'Co-processor violation',0

	dc.b	'Format error',0

	dc.b	'Bad MMU configuration',0

JE12	dc.b	'Disassembly',0

JE1E	dc.b	'Memory',0

JE25	dc.b	'Registers',0

JE2F	dc.b	'Source (',0

JE38	dc.b	'  ESC to abort   ',0

JE4A	dc.b	'Window start address?',0

JE60	dc.b	'Go to source line?',0

JE73	dc.b	'[Return]',0

JE7C	dc.b	' ',0

JE7E	dc.b	'Filename to load',0

JE8F	dc.b	'Source file to load',0

JEA3	dc.b	'Executable file to load',0

JEBB	dc.b	'Command line',0

JEC8	dc.b	'Register=value',0

JED7	dc.b	'Cannot run',0

JEE2	dc.b	'In ROM!',0

JEEA	dc.b	'It''s odd!',0

JEF4	dc.b	'Cannot write!',0

KE02	dc.b	'Too many breakpoints!',0

KE18	dc.b	'Run until address[,param n=*?-]',0

KE38	dc.b	'Kill all breakpoints',0

KE4D	dc.b	' Y/N?',0

KE53	dc.b	'Breakpoint address[,param n=*?-]',0

KE74	dc.b	'History',0

KE7C	dc.b	'Search for B/W/L/T/I? ',0

KE93	dc.b	'No printer device selected',0

KEAE	dc.b	'Expression to lock',0

KEC1	dc.b	'Enter expression',0

KED2	dc.b	'Symbols',0

KEDA	dc.b	'PREFERENCES',0

KEE6	dc.b	'Show relative offset symbols Y/N? ',0

LE09	dc.b	'Case insensitive symbols Y/N? ',0

LE28	dc.b	'Ignore case Y/N? ',0

LE3A	dc.b	'Symbol significance',0

LE4E	dc.b	'Copy start,end,to',0

LE60	dc.b	'Fill start,end,with',0

LE74	dc.b	'Set current drive/directory',0

LE90	dc.b	'Save binary, filename',0

LEA6	dc.b	'start address,end',0

LEB8	dc.b	'Run: Go,Instruction ',0

LECD	dc.b	'Help',0

LED2	dc.b	'Disassemble start,end',0

LEE8	dc.b	'Save preferences Y/N? ',0

LEFF	dc.b	'AmigaDOS error '

ME0E	dc.b	'12345',0

ME14	dc.b	'Quit with task running',0

ME2B	dc.b	'Printer device name',0

ME3F	dc.b	'Press any key'
ME4C	dc.b	0

ME4D	dc.b	'Stop task',0

ME57	dc.b	'Kill task',0

ME61	dc.b	'Unload symbols',0

ME70	dc.b	'Interlace Y/N/D? ',0

ME82	dc.b	'Source window line numbers H/D/N? ',0

MEA5	dc.b	'Auto-load source file Y/N? ',0

MEC1	dc.b	'Automatic ''_'' or ''@'' prefix Y/N? ',0

MEE3	dc.b	'Show ZAn in disassembly Y/N? ',0

NE02	dc.w	0,0
NE06	dc.w	0,0
NE0A	dc.b	0
NE0B	dc.b	0
NE0C	dc.w	0,0
NE10	dc.w	0
NE12	dc.w	0
NE14	dc.w	0,0,0,0
NE1C	dc.w	0
NE1E	dc.w	0,0
NE22	dc.w	0,0
NE26	dc.w	0
NE28	dc.w	0,0
NE2C	dc.w	0,0
NE30	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0
NE64	dc.w	0,0,0,0
NE6C	dc.w	0,0
NE70	dc.w	0,0
NE74	dc.w	0
NE76	dc.w	0,0
NE7A	dc.w	0,0,0,0
	dc.w	0,0,0,1
	dc.w	0,1

	dc.w	0,0,0,0
NE96	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
NEB6	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0
OE9A	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0


file.dsm.data.areas

* long - start, long - end, byte - size, for each data area

	ds.w	5*MAX_DATA_AREAS
	dc.l	0


	section	DanAmData,data_c


PE08	dc.w	$B,$C,$FFFA,$FFFE
	dc.w	0,0,0,$1F00
	dc.w	$A00,$3580,0,$7FC0
	dc.w	0,$7FC0,0,$3F80
	dc.w	0,$5F40
	dc.w	0,$5140
	dc.w	0,$9120,0,$A0A0
	dc.w	0,$A0A0,$8020,$A0A0
	dc.w	$2080,$2080,0,0
	dc.w	0,0

