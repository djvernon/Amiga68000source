l000001	move.l	a6,-(sp)
	move.l	4.w,a6
	jsr	-138(a6)		Permit
	move.l	(sp)+,a6
	rts


l000002	dc.b	'Directory Error',0
font	dc.b	'topaz.font',0

l000003	dc.b	'(dir) ',0

l000004	dc.b	'<ASN> ',0

l000005	dc.b	'File  ',0

l000006	dc.b	'Drawer',0

l000007	dc.b	'  OK  ',0

l000008	dc.b	'Parent',0

l000009	dc.b	'CANCEL',0

l00000a	dc.b	'Drives',0

l00000b	dc.b	128,0,0

l00000c	dc.l	font
	dc.w	8
	dc.w	1
	dc.w	0

l00000d	dc.w	%0000000100000000
	dc.w	%0000001110000000
	dc.w	%0000011111000000
	dc.w	%0000111111100000
	dc.w	%0001111111110000
	dc.w	%0011111111111000
	dc.w	%0000011111000000
	dc.w	%0000011111000000
	dc.w	%0000011111000000

l00000e	dc.w	0

l00000f	dc.w	60,103
	dc.w	232,10
	dc.w	1,4

	dc.w	60,90
	dc.w	232,10
	dc.w	1,4

	dc.w	283,15
	dc.w	11,49
	dc.w	3,3

	dc.w	15,116
	dc.w	56,13
	dc.w	1,1

	dc.w	225,116
	dc.w	56,13
	dc.w	1,1

	dc.w	85,116
	dc.w	56,13
	dc.w	1,1

	dc.w	155,116
	dc.w	56,13
	dc.w	1,1

	dc.w	281,64
	dc.w	15,10
	dc.w	3,1

	dc.w	281,75
	dc.w	15,10
	dc.w	3,1



file.requester
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	a0,a2
	clr.l	d7
	move.l	#1172,d0
	jsr	-342(a6)		DosAllocMem
	move.l	d0,a5
	tst.l	d0
	beq	l000055
	move.l	a2,280(a5)
	lea	l00000f(pc),a0
	lea	362(a5),a1
	move.w	#$7680,d0

l000010	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr.w	(a1)+
	move.l	(a0)+,(a1)+
	add.w	#20,a1
	move.w	d0,(a1)+
	addq.w	#8,a1
	addq.w	#1,d0
	cmp.w	#$7689,d0
	blt.s	l000010

	lea	868(a5),a0
	move.l	a0,836(a5)
	move.l	a0,800(a5)
	moveq	#33,d0
	moveq	#32,d1
	btst	#0,17(a2)
	beq.s	l000011
	move.w	#254,d0
	moveq	#126,d1

l000011	move.w	d0,806(a5)
	move.w	d1,842(a5)
	move.l	4(a2),832(a5)
	move.l	8(a2),796(a5)
	lea	832(a5),a0
	move.l	a0,392(a5)
	lea	796(a5),a0
	move.l	a0,436(a5)
	move.w	#13,774(a5)
	lea	754(a5),a0
	move.l	a0,464(a5)
	lea	774(a5),a0
	move.l	a0,480(a5)
	lea	1124(a5),a0
	move.l	22(a2),d0
	beq.s	l000012
	subq.w	#1,d0
	bra.s	l000013

l000012	move.l	#$00190014,d0
l000013	move.l	d0,(a0)+
	move.l	#$012c0088,d0
	move.l	d0,(a0)+
	move.w	#1,(a0)+
	clr.l	(a0)+
	move.l	#$0001100a,(a0)+
	addq.w	#8,a0
	move.l	(a2),(a0)+
	addq.w	#8,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	addq.w	#1,(a0)
	move.l	12(a2),d0
	beq.s	l000014

	move.l	d0,a0
	move.l	46(a0),a1
	move.l	a1,1154(a5)
	moveq	#15,d0
	and.w	20(a1),d0
	move.w	d0,1170(a5)

l000014	move.l	a6,-(sp)
	btst	#3,16(a2)
	beq.s	l000015
	lea	1124(a5),a0
	moveq	#8,d0
	bsr	l00008e

l000015	lea	1124(a5),a0
	move.l	56(a6),a6
	jsr	-204(a6)
	move.l	d0,a3
	tst.l	d0
	beq	l000054
	move.l	50(a3),d6
	btst	#4,16(a2)
	bne.s	l000016
	move.l	12(a2),d0
	beq.s	l000016
	move.l	d0,a0
	move.l	86(a0),86(a3)

l000016	move.l	a3,a0
	move.l	#$00400668,d0
	jsr	-150(a6)
	move.l	(sp),a6
	move.l	52(a6),a6
	lea	l00000c(pc),a0
	jsr	-72(a6)
	move.l	d0,354(a5)
	beq.s	l000017
	move.l	d0,a0
	move.l	d6,a1
	jsr	-66(a6)

l000017	moveq	#1,d0
	bsr	l000085
	moveq	#3,d0
	add.b	55(a3),d0
	move.w	d0,452(a5)
	move.w	672(a5),d1
	sub.w	d0,d1
	subq.w	#3,d1
	move.w	d1,456(a5)
	moveq	#86,d1
	btst	#5,16(a2)
	bne.s	l000018
	move.b	55(a3),d1

l000018	moveq	#4,d0
	move.w	8(a3),d2
	subq.w	#5,d2
	move.w	10(a3),d3
	subq.w	#3,d3
	bsr	l00008a
	move.l	(sp),a6
	moveq	#8,d2
	lea	358(a5),a2

l000019	move.l	a2,a1
	moveq	#-1,d0
	bsr	l00003a
	lea	44(a2),a2
	dbra	d2,l000019

	move.l	280(a5),a0
	btst	#2,16(a0)
	beq.s	l00001a
	move.l	a3,a0
	moveq	#4,d0
	bsr	l00008e

l00001a	movem.l	d2-d5/d7/a2/a6,-(sp)
	move.l	52(a6),d5
	moveq	#20,d0
	move.l	#$10002,d1
	move.l	$4,a6
	jsr	-198(a6)
	move.l	d0,d7
	beq	l00001d
	exg	d5,a6
	moveq	#2,d0
	bsr	l000085
	moveq	#1,d0
	move.l	d6,a1
	jsr	-348(a6)
	lea	402(a5),a2
	lea	l000006(pc),a0
	bsr	l00008d
	lea	358(a5),a2
	lea	l000005(pc),a0
	bsr	l00008d
	move.w	670(a5),d0
	subq.w	#2,d0
	moveq	#0,d1
	move.b	55(a3),d1
	moveq	#18,d2
	add.w	d0,d2
	move.w	716(a5),d3
	add.w	720(a5),d3
	bsr	l00008a
	moveq	#86,d1
	bsr	l00008b
	move.w	10(a3),d1
	subq.w	#2,d1
	bsr	l00008b
	moveq	#0,d1
	move.b	55(a3),d1
	bsr	l00008b
	moveq	#2,d0
	bsr	l00008c
	move.w	8(a3),d0
	subq.w	#4,d0
	bsr	l00008c
	moveq	#1,d0
	bsr	l000085
	moveq	#-2,d0
	moveq	#-2,d1
	moveq	#3,d2
	moveq	#3,d3
	lea	446(a5),a2
	bsr	l000089
	moveq	#0,d0
	bsr	l000085
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#1,d2
	moveq	#1,d3
	bsr	l000089
	lea	490(a5),a2
	lea	l000007(pc),a1
	bsr	l000088
	lea	534(a5),a2
	lea	l000009(pc),a1
	bsr	l000088
	lea	622(a5),a2
	lea	l000008(pc),a1
	bsr	l000088
	lea	578(a5),a2
	lea	l00000a(pc),a1
	bsr	l000088
	bsr	l000083
	lea	l00000d(pc),a0
	move.l	d7,a1

l00001b	move.w	(a0)+,(a1)+
	bne.s	l00001b

	move.w	670(a5),d2
	move.w	672(a5),d3
	bsr.s	l000020
	lea	l00000e(pc),a0
	move.l	d7,a1

l00001c	move.w	-(a0),(a1)+
	bne.s	l00001c
	move.w	716(a5),d3
	bsr.s	l000020
	move.l	d7,a1
	moveq	#20,d0
	move.l	$4,a6
	jsr	-210(a6)

l00001d	movem.l	(sp)+,d2-d5/d7/a2/a6
	move.l	62(a3),a0
	moveq	#-1,d0
	bsr	l00003c

l00001e	bsr	l00005c

l00001f	lea	358(a5),a0
	bsr	l00003e
	bra.s	l000022

l000020	move.l	d6,a1
	move.l	d7,a0
	moveq	#0,d0
	moveq	#2,d1
	moveq	#15,d4
	moveq	#10,d5
	jmp	-36(a6)

l000021	bsr	l000075

l000022	move.w	318(a5),d0
	subq.w	#6,d0
	move.w	d0,d1
	mulu	778(a5),d0
	swap	d0
	cmp.w	d1,d0
	ble.s	l000023
	move.w	d1,d0

l000023	tst.w	d0
	bge.s	l000024
	moveq	#0,d0

l000024	move.w	d0,316(a5)

l000025	move.l	86(a3),a0
	move.l	$4,a6
	jsr	-372(a6)
	tst.l	d0
	bne.s	l000029
	move.l	(sp),a6
	subq.w	#1,324(a5)
	bne.s	l000026
	bsr	l00007a

l000026	tst.w	320(a5)
	beq.s	l000028
	bsr	l000060
	tst.w	320(a5)
	beq.s	l000027
	moveq	#15,d0
	and.w	318(a5),d0
	bne.s	l000025

l000027	bsr	l00004b
	bra.s	l000025

l000028	move.l	86(a3),a0
	move.l	$4,a6
	jsr	-384(a6)
	bra.s	l000025

l000029	move.l	d0,a1
	cmp.l	44(a1),a3
	beq.s	l00002b
	move.l	280(a5),a0
	btst	#6,16(a0)
	beq.s	l00002a
	move.l	a1,a0
	moveq	#64,d0
	bsr	l00008e
	bra.s	l000025

l00002a	jsr	-378(a6)
	bra.s	l000025

l00002b	move.l	20(a1),d2
	move.l	28(a1),a2
	move.l	24(a1),346(a5)
	move.l	32(a1),326(a5)
	move.l	36(a1),338(a5)
	move.l	40(a1),342(a5)
	jsr	-378(a6)
	move.l	(sp),a6
	cmp.w	#512,d2
	beq	l000052
	cmp.w	#8,d2
	beq	l000047
	cmp.l	#$00400000,d2
	beq.s	l00002f
	cmp.w	#1024,d2
	beq	l00001f
	cmp.w	#32,d2
	beq.s	l00002c
	cmp.w	#64,d2
	bne	l000025

l00002c	moveq	#0,d0
	move.w	38(a2),d0
	move.l	d0,d1
	sub.w	#30336,d0
	beq	l000051
	subq.w	#1,d0
	beq	l00001e
	subq.w	#1,d0
	beq	l000021
	subq.w	#1,d0
	beq	l000051
	subq.w	#1,d0
	beq	l000052
	subq.w	#1,d0
	beq	l000048
	subq.w	#1,d0
	beq	l000037
	subq.w	#2,d0
	ble.s	l00002e
	move.l	280(a5),a0
	btst	#1,16(a0)
	beq.s	l00002d
	move.l	d1,a0
	moveq	#2,d0
	bsr	l00008e
	tst.l	d0
	bne	l000052

l00002d	bra	l000025

l00002e	move.w	#5,350(a5)
	bra.s	l000033

l00002f	move.w	848(a5),d0
	cmp.w	352(a5),d0
	beq.s	l000032
	move.w	d0,352(a5)
	beq.s	l000032
	moveq	#-1,d2
	lea	284(a5),a2

l000030	addq.w	#1,d2
	move.l	(a2),a2
	move.l	a2,d0
	beq.s	l000031
	move.l	832(a5),a0
	jsr	-630(a6)
	lea	6(a2),a1
	jsr	-522(a6)
	bgt.s	l000030

l000031	move.w	d2,316(a5)
	moveq	#0,d0
	bra.s	l000034

l000032	subq.w	#1,350(a5)
	bgt	l000025

l000033	moveq	#-1,d0
	moveq	#7,d1
	btst	d1,459(a5)
	bne	l000021
	btst	d1,679(a5)
	bne.s	l000034
	moveq	#1,d0
	btst	d1,723(a5)
	beq	l000025

l000034	add.w	316(a5),d0
	move.w	318(a5),d1
	subq.w	#7,d1
	cmp.w	d1,d0
	blt.s	l000035
	move.w	d1,d0

l000035	move.w	d0,316(a5)
	bge.s	l000036
	clr.w	316(a5)

l000036	bsr	l00004b
	bsr	l000075
	bra	l000025

l000037	bsr	l000057
	bra	l000046

l000038	move.l	a3,a0
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-228(a6)
	move.l	(sp)+,a6
	rts

l000039	moveq	#1,d0

l00003a	move.l	a3,a0
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-42(a6)
	move.l	(sp)+,a6
	rts

l00003b	moveq	#1,d0

l00003c	move.l	a3,a1
	sub.l	a2,a2
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-222(a6)
	move.l	(sp)+,a6
	rts

l00003d	lea	402(a5),a0

l00003e	move.l	a3,a1
	sub.l	a2,a2
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-462(a6)
	move.l	(sp)+,a6
	rts

l00003f	move.l	280(a5),a0
	move.l	8(a0),-(sp)
	cmp.b	#8,d1
	beq.s	l000040
	move.l	(sp),a0
	clr.b	(a0)

l000040	lea	402(a5),a1
	bsr.s	l000038
	move.w	806(a5),d0
	move.l	(sp),a0

l000041	tst.b	(a0)+
	dbeq	d0,l000041
	move.l	a2,a0

l000042	tst.b	(a0)+
	dbeq	d0,l000042

	subq.w	#1,d0
	bgt.s	l000043
	lea	l000002(pc),a1
	bsr	l000068
	bra.s	l000045

l000043	move.l	(sp),a0
	move.l	a2,a1
	bsr	l00009d
	clr.w	804(a5)
	move.l	(sp),a0

l000044	tst.b	(a0)+
	beq.s	l000045
	addq.w	#1,804(a5)
	bra.s	l000044

l000045	addq.w	#4,sp
	lea	402(a5),a1
	bsr	l000039

l000046	lea	402(a5),a0
	bsr	l00003b
	lea	402(a5),a1
	bsr.s	l00003d
	bsr	l00005c
	bra	l000022

l000047	move.w	346(a5),d0
	cmp.w	#105,d0
	bne	l00004e

l000048	tst.w	322(a5)
	bne.s	l000049
	move.w	318(a5),316(a5)
	lea	284(a5),a0
	moveq	#11,d0
	jsr	-516(a6)
	add.w	d0,318(a5)
	move.w	#1,322(a5)
	bsr.s	l00004b
	bsr	l000075

l000049	bsr	l00003d

l00004a	bra	l000025

l00004b	movem.l	d5/a6,-(sp)
	moveq	#7,d4
	cmp.w	318(a5),d4
	bgt.s	l00004c
	move.w	318(a5),d4

l00004c	move.l	#$60000,d0
	divu	d4,d0
	move.w	d0,d4
	lea	446(a5),a0
	move.l	a3,a1
	sub.l	a2,a2
	moveq	#13,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	316(a5),d2
	mulu	#65535,d2
	move.w	318(a5),d3
	subq.w	#7,d3
	ble.s	l00004d
	divu	d3,d2

l00004d	swap	d2
	clr.w	d2
	swap	d2
	moveq	#0,d3
	move.l	56(a6),a6
	moveq	#1,d5
	jsr	-468(a6)
	movem.l	(sp)+,d5/a6
	rts

l00004e	cmp.w	#104,d0
	bne.s	l00004a
	moveq	#-6,d0
	add.w	326(a5),d0
	blt.s	l000049
	cmp.w	#264,d0
	bge.s	l000049
	moveq	#-14,d0
	add.w	328(a5),d0
	ble.s	l000049
	cmp.w	#69,d0
	bge.s	l000049
	ext.l	d0
	divu	#10,d0
	move.w	d0,-(sp)
	asl.w	#2,d0
	lea	288(a5),a2
	add.w	d0,a2
	moveq	#6,d2
	move.w	(sp)+,d3
	mulu	#10,d3
	add.w	#15,d3
	move.l	a6,-(sp)
	move.l	52(a6),a6
	moveq	#2,d0
	bsr	l000087
	move.l	(sp),a6
	moveq	#5,d1
	jsr	-198(a6)
	moveq	#6,d2
	move.l	52(a6),a6
	moveq	#2,d0
	bsr	l000087
	move.l	(sp)+,a6
	move.l	(a2),d1
	beq	l000025
	move.l	d1,a2
	move.b	4(a2),d1
	addq.w	#6,a2
	cmp.b	#0,d1
	bne	l00003f
	movem.l	d0-d3/a6,-(sp)
	movem.l	330(a5),d0-d3
	movem.l	d2-d3,330(a5)
	move.l	56(a6),a6
	jsr	-102(a6)
	tst.l	d0
	movem.l	(sp)+,d0-d3/a6
	beq.s	l00004f

	move.l	a2,a0
	move.l	280(a5),a1
	move.l	4(a1),a1
	jsr	-522(a6)
	tst.l	d0
	beq.s	l000051

l00004f	lea	358(a5),a1
	bsr	l000038
	moveq	#32,d0
	move.l	280(a5),a0
	move.l	4(a0),a0

l000050	move.b	(a2)+,(a0)+
	dbeq	d0,l000050

	lea	358(a5),a1
	bsr	l000039
	lea	358(a5),a0
	bsr	l00003b
	move.w	848(a5),352(a5)
	bra	l000022

l000051	moveq	#3,d0
	and.w	348(a5),d0
	bne	l000049
	move.l	280(a5),a0
	move.l	4(a0),d7

l000052	move.l	a3,a0
	move.l	280(a5),a1
	move.l	4(a0),22(a1)
	addq.l	#1,22(a1)
	btst	#4,16(a1)
	move.l	12(a1),a1
	beq.s	l000053
	sub.l	a1,a1

l000053	bsr	l000090
	move.l	354(a5),d0
	beq.s	l000054
	move.l	52(a6),a6
	move.l	d0,a1
	jsr	-78(a6)

l000054	move.l	(sp)+,a6
	bsr.s	l000056
	move.l	a5,a1
	jsr	-348(a6)

l000055	move.l	d7,d0
	movem.l	(sp)+,d2-d7/a2-a5
	rts

l000056	move.l	a5,a0
	jsr	-450(a6)
	move.l	284(a5),a1
	bsr	l000074
	clr.l	284(a5)
	rts

l000057	lea	402(a5),a1
	bsr	l000038
	move.l	280(a5),a0
	move.l	8(a0),a0

l000058	move.l	a0,a1

l000059	move.b	(a0)+,d0
	beq.s	l00005b
	cmp.b	#47,d0
	bne.s	l00005a
	lea	-1(a0),a1
	bra.s	l000059

l00005a	cmp.b	#58,d0
	bne.s	l000059
	tst.b	(a0)
	bne.s	l000058

l00005b	clr.b	(a1)
	move.l	280(a5),a0
	move.l	a1,d0
	sub.l	8(a0),d0
	move.w	d0,804(a5)
	move.w	d0,812(a5)
	lea	402(a5),a1
	bra	l000039

l00005c	move.l	280(a5),a0
	move.l	(a0),a1
	bsr	l000069
	lea	288(a5),a0
	moveq	#9,d0

l00005d	clr.l	(a0)+
	dbra	d0,l00005d
	addq.w	#1,320(a5)
	addq.w	#1,324(a5)
	bsr.s	l000056
	sub.w	#304,sp
	move.l	280(a5),a0
	move.l	8(a0),a0
	move.l	sp,a1
	jsr	-558(a6)
	tst.w	d0
	beq.s	l00005e
	bsr.s	l000057
	bra.s	l00005f

l00005e	move.l	sp,a0
	lea	l00000b(pc),a1
	bsr	l00009d

l00005f	move.l	sp,d0
	move.l	a5,a0
	jsr	-438(a6)
	add.w	#304,sp
	bra.s	l000061

l000060	tst.w	320(a5)
	beq.s	l000064
	move.l	a5,a0
	jsr	-444(a6)

l000061	tst.l	d0
	beq.s	l000065
	cmp.w	#232,d0
	beq.s	l000063

l000062	lea	l000002(pc),a1
	bsr.s	l000068

l000063	clr.w	320(a5)
l000064	rts

l000065	move.l	280(a5),a0
	btst	#7,16(a0)
	beq.s	l000066
	move.l	a5,a0
	move.l	#$80,d0
	bsr	l00008e
	tst.l	d0
	bne.s	l000064

l000066	moveq	#8,d1
	tst.l	24(a5)
	bge.s	l000067
	moveq	#0,d1

l000067	lea	28(a5),a0
	lea	284(a5),a1
	bsr.s	l00006a
	tst.l	d0
	beq.s	l000062
	move.w	318(a5),d1
	addq.w	#1,318(a5)
	cmp.w	#7,d1
	bge.s	l000064
	lea	288(a5),a0
	asl.w	#2,d1
	move.l	d0,0(a0,d1.w)
	bra	l00007a

l000068	move.l	a1,a2
	sub.l	a0,a0
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-96(a6)
	move.l	(sp)+,a6
	move.l	a2,a1

l000069	move.l	280(a5),a0
	move.l	(a0),a2
	move.l	a3,a0
	move.l	a6,-(sp)
	move.l	56(a6),a6
	jsr	-276(a6)
	move.l	(sp)+,a6
	rts

l00006a	moveq	#0,d0
	movem.l	d1/a0-a3,-(sp)
	tst.l	d0
	bne.s	l00006c
	moveq	#-1,d0

l00006b	addq.l	#1,d0
	tst.b	(a0)+
	bne.s	l00006b

l00006c	move.l	d0,-(sp)
	addq.l	#7,d0
	jsr	-342(a6)
	move.l	(sp)+,d1
	tst.l	d0
	beq.s	l000072
	move.l	d0,a3
	move.l	(sp)+,d0
	move.b	d0,4(a3)
	lea	6(a3),a1
	move.l	(sp)+,a0

l00006d	move.b	(a0)+,(a1)+
	dbra	d1,l00006d

	clr.b	-(a1)
	move.l	(sp),a2
	subq.w	#8,sp
	bra.s	l00006f

l00006e	move.l	(a2),a2

l00006f	move.l	(a2),d0
	beq.s	l000071
	move.l	d0,a1
	move.b	4(a3),d1
	cmp.b	4(a1),d1
	bne.s	l000070
	lea	6(a3),a0
	lea	6(a1),a1
	jsr	-522(a6)

l000070	bge.s	l00006e

l000071	move.l	(a2),(a3)
	move.l	a3,(a2)
	move.l	a3,d0

l000072	movem.l	(sp)+,d1/a0-a3
	rts

l000073	move.l	(a1),-(sp)
	jsr	-348(a6)
	move.l	(sp)+,a1

l000074	move.l	a1,d0
	bne.s	l000073
	rts

l000075	lea	284(a5),a0
	move.w	316(a5),d0

l000076	bsr.s	l000078
	dbra	d0,l000076
	lea	288(a5),a1
	moveq	#6,d0

l000077	move.l	a0,(a1)+
	bsr.s	l000078
	dbra	d0,l000077
	move.w	#1,324(a5)

l000078	move.l	a0,d1
	beq.s	l000079
	move.l	(a0),a0
l000079	rts

l00007a	movem.l	d2-d4/a2-a4/a6,-(sp)
	move.l	52(a6),a6
	lea	288(a5),a2
	moveq	#6,d4
	moveq	#5,d3

l00007b	moveq	#10,d2
	add.w	d2,d3
	moveq	#5,d0
	bsr	l000086
	moveq	#3,d0
	bsr	l000085
	moveq	#0,d0
	move.l	d6,a1
	jsr	-348(a6)
	moveq	#6,d0
	move.l	d3,d1
	addq.w	#6,d1
	move.l	d6,a1
	jsr	-240(a6)
	move.l	(a2)+,d0
	beq.s	l00007f
	move.l	d0,a4
	lea	6(a4),a3
	move.b	4(a4),d0
	cmp.b	#0,d0
	beq.s	l00007d
	lea	l000003(pc),a0
	cmp.b	#8,d0
	beq.s	l00007c
	lea	l000004(pc),a0
	cmp.b	#40,d0
	beq.s	l00007c
	moveq	#1,d0
	bsr.s	l000086
	bra.s	l00007e

l00007c	bsr.s	l000081

l00007d	bsr.s	l000083

l00007e	move.l	a3,a0
	bsr.s	l000081

l00007f	move.l	d6,a1
	move.w	36(a1),d2
	cmp.w	#274,d2
	bge.s	l000080
	moveq	#1,d0
	bsr.s	l000087

l000080	dbra	d4,l00007b
	movem.l	(sp)+,d2-d4/a2-a4/a6
	rts

l000081	move.l	a0,a1
	moveq	#-1,d0

l000082	addq.l	#1,d0
	tst.b	(a1)+
	bne.s	l000082
	move.l	d6,a1
	jsr	-60(a6)
	rts

l000083	moveq	#0,d0
	move.l	280(a5),a0
	btst	#5,16(a0)
	bne.s	l000084
	moveq	#1,d0

l000084	bsr.s	l000085
	move.l	d6,a1
	move.b	25(a1),d0
	eor.b	#1,d0
	jmp	-348(a6)

l000085	move.l	d6,a1
	jmp	-342(a6)

l000086	move.l	d6,a1
	jmp	-354(a6)

l000087	bsr.s	l000086
	bsr.s	l000083
	move.l	d2,d0
	move.l	#$112,d2
	move.l	d3,d1
	addq.w	#7,d3
	bsr.s	l00008a
	subq.w	#7,d3
	rts

l000088	movem.l	d2-d3/a3,-(sp)
	move.l	a1,a3
	moveq	#2,d0
	bsr.s	l000085
	moveq	#3,d0
	moveq	#1,d1
	moveq	#1,d2
	moveq	#1,d3
	bsr.s	l000089
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#1,d2
	moveq	#1,d3
	bsr.s	l000089
	moveq	#1,d0
	bsr.s	l000085
	moveq	#0,d0
	moveq	#0,d1
	moveq	#-1,d2
	moveq	#-1,d3
	bsr.s	l000089
	moveq	#0,d0
	bsr.s	l000085
	moveq	#4,d0
	add.w	4(a2),d0
	moveq	#9,d1
	add.w	6(a2),d1
	move.l	d6,a1
	jsr	-240(a6)
	move.l	a3,a0
	movem.l	(sp)+,d2-d3/a3
	bra	l000081

l000089	add.w	4(a2),d0
	add.w	6(a2),d1
	add.w	8(a2),d2
	add.w	10(a2),d3
	add.w	d0,d2
	add.w	d1,d3

l00008a	move.l	d6,a1
	jmp	-306(a6)

l00008b	move.l	d1,d3
	subq.w	#1,d1
	moveq	#-3,d2
	add.w	8(a3),d2
	moveq	#2,d0
	bra.s	l00008a

l00008c	moveq	#0,d1
	move.b	55(a3),d1
	move.w	d0,d2
	addq.w	#1,d2
	move.w	10(a3),d3
	subq.w	#2,d3
	bra.s	l00008a

l00008d	move.l	a0,-(sp)
	moveq	#10,d0
	moveq	#6,d1
	add.w	6(a2),d1
	move.l	d6,a1
	jsr	-240(a6)
	move.l	(sp)+,a0
	bsr	l000081
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#1,d2
	moveq	#-1,d3
	bra.s	l000089

l00008e	movem.l	d0/a0/a6,-(sp)
	move.l	280(a5),a1
	move.l	18(a1),d1
	beq.s	l00008f
	move.l	d1,a1
	jsr	(a1)

l00008f	movem.l	(sp)+,d1/a0/a6
	rts

l000090	movem.l	a0-a1/a5-a6,-(sp)
	move.l	56(a6),a5
	move.l	$4,a6
	addq.b	#1,295(a6)

l000091	move.l	(sp),a0
	move.l	86(a0),d0
	beq.s	l000093
	move.l	d0,a0
	jsr	-372(a6)
	tst.l	d0
	beq.s	l000092
	move.l	d0,a1
	jsr	-378(a6)
	bra.s	l000091

l000092	tst.l	4(sp)
	beq.s	l000093
	move.l	(sp),a0
	clr.l	86(a0)
	moveq	#0,d0
	exg	a5,a6
	jsr	-150(a6)
	exg	a5,a6

l000093	move.l	(sp),a0
	exg	a5,a6
	jsr	-72(a6)
	exg	a5,a6
	jsr	-138(a6)
	movem.l	(sp)+,a0-a1/a5-a6
	rts

	movem.l	d2-d4/a2-a5,-(sp)
	move.l	d0,d2
	move.l	a0,a5
	moveq	#0,d4
	sub.w	#256,sp
	move.l	$4,a0
	addq.b	#1,295(a0)
	sub.l	a2,a2
	jsr	-366(a6)

l000094	jsr	-366(a6)
	bne.s	l000096

l000095	bsr	l000001
	add.w	#256,sp
	move.l	d4,d0
	movem.l	(sp)+,d2-d4/a2-a5
	rts

l000096	move.l	sp,a0
	move.l	40(a2),d0
	moveq	#80,d1
	jsr	-354(a6)
	add.w	d0,a0
	move.b	#58,(a0)+
	clr.b	(a0)+
	move.l	a0,a4
	move.l	4(a2),d0
	bne.s	l00009a
	btst	#0,d2
	beq.s	l000094
	btst	#1,d2
	beq.s	l000097
	tst.l	8(a2)
	beq.s	l000094

l000097	moveq	#16,d1

l000098	move.l	a4,d0
	and.w	#1,d0
	add.w	d0,a4
	move.l	a2,(a4)+
	move.l	a4,d0
	sub.l	sp,d0

l000099	move.l	a5,a1
	move.l	sp,a0
	addq.w	#1,d4
	jsr	-510(a6)
	tst.l	d0
	bne.s	l000094
	moveq	#0,d4
	bra.s	l000095

l00009a	cmp.w	#2,d0
	bne.s	l00009c
	btst	#2,d2
	beq.s	l000094
	moveq	#24,d1
	tst.l	8(a2)
	bne.s	l00009b
	moveq	#32,d1

l00009b	moveq	#0,d0
	bra.s	l000099

l00009c	cmp.w	#1,d0
	bne	l000094
	btst	#3,d2
	beq	l000094
	moveq	#40,d1
	bra.s	l000098

l00009d	moveq	#58,d0

l00009e	tst.b	(a0)
	beq.s	l00009f
	move.b	(a0)+,d0
	bra.s	l00009e

l00009f	tst.b	(a1)
	beq.s	l0000a0
	cmp.b	#58,d0
	beq.s	l0000a0
	cmp.b	#47,d0
	beq.s	l0000a0
	move.b	#47,(a0)+

l0000a0	move.b	(a1)+,(a0)+
	bne.s	l0000a0
	subq.w	#1,a0
	rts
