
LF	equ	10
FF	equ	12
CR	equ	13


	bra.s	l2656FC

	dc.b	FF,LF,'* THIS IS SHAREWARE !*',0,0

l2656FC	movea.l	4,a6
	lea	l2661B6(pc),a1
	moveq	#0,d0
	jsr	-$228(a6)
	move.l	d0,l2661C4
	beq	l265D44
	movea.l	l2661C4,a6
	jsr	-$36(a6)
	move.l	d0,l2661CC
	jsr	-$3C(a6)
	move.l	d0,l2661C8
	bsr	l266060
	dc.b	FF,'SPEED 2.00 - Amiga Performance Analyser by Jez San (c)1989 Argonaut Software.',LF,LF
	dc.b	'This tests two aspects of your Amiga system :-',LF
	dc.b	'a) The approximate clockspeed the processor is running at.',LF
	dc.b	'b) The approximate system performance in the form of a benchmark.',LF,LF
	dc.b	'Both figures a & b are important for different reasons eg: Despite',LF
	dc.b	'having a fast clockspeed, your machine may not run at its full',LF
	dc.b	'system performance, due to Waitstates, Cache''s, Burstfetches etc',LF
	dc.b	'Hence the need for a good measure of both clockspeed AND realworld',LF
	dc.b	'performance when compared to a normally aspirated Amiga.',LF,LF,0

	bsr	l266060
	dc.b	'The Amiga EXEC reckons that a ',0,0

	movea.l	4,a6
	moveq	#0,d0
	move.w	$128(a6),d0
	movea.l	l2661C4,a6
	btst	#3,d0
	beq.s	l2659C4
	bsr	l266060
	dc.b	'68040',0
	move.l	#$258,l2661D0
	bra.s	l265A2C

l2659C4	btst	#2,d0
	beq.s	l2659E0
	bsr	l266060
	dc.b	'68030',0
	move.l	#$2E4,l2661D0
	bra.s	l265A2C

l2659E0	btst	#1,d0
	beq.s	l2659FC
	bsr	l266060
	dc.b	'68020',0
	move.l	#$2FA,l2661D0
	bra.s	l265A2C

l2659FC	btst	#0,d0
	beq.s	l265A18
	bsr	l266060
	dc.b	'68010',0
	move.l	#$69E,l2661D0
	bra.s	l265A2C

l265A18	bsr	l266060
	dc.b	'68000',0

	move.l	#$6C4,l2661D0
l265A2C	bsr	l266060
	dc.b	' processor is installed in this system.',LF,0,0

	bsr	l266060
	dc.b	'Analysing clockspeed... ',0,0

	bsr	l266030
	move.l	d0,-(a7)
	movea.l	4,a6
	addq.b	#1,$127(a6)
	bsr	l265D7C
	movea.l	4,a6
	subq.b	#1,$127(a6)
	bsr	l266030
	sub.l	(a7)+,d0
	move.l	d0,-(a7)
	bsr	l266060
	dc.b	'Took ',0
	
	move.l	(a7),d0
	bsr	l2660FA
	bsr	l266060
	dc.b	' ticks, which is ',0

	move.l	(a7)+,d6
	move.l	l2661D0,d0
	move.l	d0,d5
	bsr	l26609C
	bsr	l266060
	dc.b	' Mhz +-2% (fig A)',LF,LF,0

	bsr	l266030
	move.l	d0,-(a7)
	bsr	l266060
	dc.b	'Computing 10,000 SlightlyMoistSmallRocks in... ',0

	movea.l	4,a6
	addq.b	#1,$127(a6)
	bsr	l265DB0
	movea.l	4,a6
	subq.b	#1,$127(a6)
	bsr	l266030
	sub.l	(a7)+,d0
	move.l	d0,d6
	move.l	d6,-(a7)
	bsr	l2660FA
	bsr	l266060
	dc.b	' ticks.',LF,LF,0

	move.l	(a7),d6
	move.l	#$2BE,d0
	move.l	d0,d5
	bsr	l26609C
	bsr	l266060
	dc.b	' times (fig B) the speed of a normal Amiga at 7.159 Mhz +-2%.',LF,0,0

	move.l	(a7)+,d6
	move.l	#$EA,d0
	move.l	d0,d5
	bsr	l26609C
	bsr	l266060
	dc.b	' times the speed of an A2620 at 14.318 Mhz +-2%.',LF,LF
	dc.b	'Rating against an A2620 : ',0,0

	move.w	l2661C2,d0
	dbf	d0,l265C24
	bsr	l266060
	dc.b	'Yawn.',LF,0,0
	bra	l265D34
	
l265C24	dbf	d0,l265C42
	bsr	l266060
	dc.b	'About the same.',LF,0,0
	bra	l265D34

l265C42	dbf	d0,l265C5C
	bsr	l266060
	dc.b	'Quite fast.',LF,0,0
	bra	l265D34

l265C5C	dbf	d0,l265C76
	bsr	l266060
	dc.b	'Pretty fast.',LF,0
	bra	l265D34

l265C76	dbf	d0,l265C96
	bsr	l266060
	dc.b	'Quite Impressive.',LF,0,0
	bra	l265D34

l265C96	dbf	d0,l265CB6
	bsr	l266060
	dc.b	'Mighty Impressive.',LF,0
	bra	l265D34

l265CB6	dbf	d0,l265CD2
	bsr	l266060
	dc.b	'Like wow man!',LF,0,0
	bra	l265D34

l265CD2	dbf	d0,l265CFA
	bsr	l266060
	dc.b	'This is my kinda machine!!',LF,0
	bra	l265D34

l265CFA	bsr	l266060
	dc.b	'Off the scale, this machine has some serious speed!',LF,0,0

l265D34	movea.l	4,a6
	movea.l	l2661C4,a1
	jsr	-$19E(a6)
l265D44	rts

	bsr	l266060
	dc.b	'Hmmm, Error in Calculation (Zero time taken!).',LF,0
	bra.s	l265D34

l265D7C	move.w	#$C350,d7
	move.l	#$FFFF,d2
	move.l	#$FFFF,d3
l265D8C	move.l	d2,d0
	move.l	d3,d1
	divs.w	d0,d1
	move.l	d2,d0
	move.l	d3,d1
	divs.w	d0,d1
	move.l	d2,d0
	move.l	d3,d1
	divs.w	d0,d1
	move.l	d2,d0
	move.l	d3,d1
	divs.w	d0,d1
	move.l	d2,d0
	move.l	d3,d1
	divs.w	d0,d1
	dbf	d7,l265D8C
	rts

l265DB0	move.w	#$2710,d7
l265DB4	bsr	l265DF4
	bsr	l265E10
	bsr	l265E30
	bsr	l265E30
	bsr	l266018
	bsr	l266018
	bsr	l266018
	bsr	l266018
	bsr	l266018
	bsr	l265E3C
	bsr	l265E3C
	bsr	l265E3C
	bsr	l265E3C
	bsr	l265E3C
	dbf	d7,l265DB4
	rts

	dc.w	0
	
l265DF4	move.l	#$7FFF,d0
	move.l	#$7FFF,d1
	muls.w	d0,d1
	move.l	#$7FFF,d0
	moveq	#-1,d1
	mulu.w	d0,d1
	rts

	dc.w	0

l265E10	move.l	#$FFFF,d0
	move.l	#$7FFF,d1
	divs.w	d1,d0
	move.l	#$FFFF,d0
	move.l	#$7FFF,d1
	divu.w	d1,d0
	rts

	dc.w	0
	
l265E30	asl.l	#8,d0
	asr.l	#8,d0
	rol.l	#8,d0
	ror.l	#8,d0
	rts

	dc.w	0

l265E3C	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	d0,d0
	addi.l	#$3039,d0
	subi.l	#$3039,d0
	lea	l266124(pc),a0
	move.l	4(a0),d0
	move.l	8(a0),d0
	move.l	$C(a0),d0
	bsr	l266016
	ext.w	d0
	ext.l	d0
	move.l	#$3039,d0
	swap	d0
	exg	d0,d1
	clr.l	d1
	neg.l	d0
	bra	l266012
	nop

l266012	move.w	#$7B,d1
l266016	rts

l266018	andi.l	#$FFFF,d0
	ori.l	#$FFFF,d0
	eori.l	#$FFFF,d0
	and.l	d1,d0
	not.l	d0
	rts

l266030	lea	l2661D4(pc),a0
	move.l	a0,d1
	movea.l	l2661C4,a6
	jsr	-$C0(a6)
	lea	l2661D4(pc),a0
	move.l	4(a0),d0
	andi.l	#$FFFF,d0
	mulu.w	#$BB8,d0
	move.l	8(a0),d1
	andi.l	#$FFFF,d1
	add.l	d1,d0
	rts

l266060	move.l	a3,-(a7)
	movea.l	4(a7),a3
	movem.l	d1-d3/a0-a1,-(a7)
	move.l	a3,d2
l26606C	tst.b	(a3)+
	bne.s	l26606C
	move.l	a3,d3
	subq.l	#1,d3
	sub.l	d2,d3
	move.l	l2661C8,d1
	movea.l	l2661C4,a6
	jsr	-$30(a6)
	movem.l	(a7)+,d1-d3/a0-a1
	move.w	a3,d1
	andi.b	#1,d1
	beq.s	l266094
	addq.l	#1,a3
l266094	move.l	a3,4(a7)
	movea.l	(a7)+,a3
	rts

l26609C	tst.w	d6
	beq.s	l2660DC
	divu.w	d6,d0
	move.l	d0,d4
	clr.w	d4
	swap	d4
	lea	l2661E4(pc),a4
	move.w	d0,l2661C2
	bsr	l26614C
	move.b	#$2E,(a4)+
	mulu.w	#$64,d4
	tst.w	d6
	beq.s	l2660DC
	divu.w	d6,d4
	cmp.w	#$64,d4
	bge.s	l2660DC
	cmp.w	#$A,d4
	bge.s	l2660D4
	move.b	#$30,(a4)+
l2660D4	move.l	d4,d0
	bsr	l26614C
	bra.s	l2660E0

l2660DC	move.b	#$30,(a4)+
l2660E0	lea	l2661E4(pc),a5
	move.l	a5,d2
	suba.l	a5,a4
	move.l	a4,d3
	move.l	l2661C8,d1
	movea.l	l2661C4,a6
	jmp	-$30(a6)

l2660FA	move.l	d0,-(a7)
	lea	l2661E4(pc),a4
	bsr	l26614C
	lea	l2661E4(pc),a5
	move.l	a5,d2
	suba.l	a5,a4
	move.l	a4,d3
	move.l	l2661C8,d1
	movea.l	l2661C4,a6
	jsr	-$30(a6)
	move.l	(a7)+,d0
	rts

	dc.w	0
l266124	dc.l	1
	dc.l	$a
	dc.l	$64
	dc.l	$3e8
	dc.l	$2710
l266138	dc.l	$186a0
	dc.l	$f4240
	dc.l	$989680
	dc.l	$5f5e100
l266148	dc.l	$3b9aca00

l26614C	movem.l	d0-d7/a0,-(a7)
	andi.l	#$FFFF,d0
	clr.w	d4
	lea	l266138(pc),a0
	moveq	#4,d3
	tst.w	d0
	beq.s	l2661AA
	bpl.s	l266180
	neg.w	d0
	bra.s	l26617C
	movem.l	d0-d7/a0,-(a7)
	clr.w	d4
	lea	l266148(pc),a0
	moveq	#8,d3
	tst.l	d0
	beq.s	l2661AA
	bpl.s	l266180
	neg.l	d0
l26617C	move.b	#$2D,(a4)+
l266180	move.l	-(a0),d1
	clr.w	d2
l266184	sub.l	d1,d0
	bmi.s	l26618C
	addq.w	#1,d2
	bra.s	l266184
l26618C	add.l	d1,d0
	tst.w	d2
	bne.s	l266196
	tst.w	d4
	beq.s	l2661A0
l266196	move.w	d2,d1
	addi.w	#$30,d1
	move.b	d1,(a4)+
	moveq	#1,d4
l2661A0	dbf	d3,l266180
	movem.l	(a7)+,d0-d7/a0
	rts
l2661AA	move.b	#$30,(a4)+
	clr.b	(a4)+
	movem.l	(a7)+,d0-d7/a0
	rts

l2661B6	dc.b	'dos.library',0

l2661C2	dc.w	0
l2661C4	dc.l	0
l2661C8	dc.l	0
l2661CC	dc.l	0
l2661D0	dc.l	0
l2661D4	ds.w	8
l2661E4	ds.w	20
