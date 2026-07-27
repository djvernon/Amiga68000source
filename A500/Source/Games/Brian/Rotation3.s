	section	Rotation,code_f
	opt	c+




	move.l	4.w,a6
	jsr	-132(a6)		Forbid


;	move.l	#4*40*200,d0
;	move.l	#$10002,d1		clear chip
;	jsr	-198(a6)		AllocMem
;	move.l	d0,screen.mem
;	beq	exit_now


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem

	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$64.w,old.level1




*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#310,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	bsr	R.c00506




*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

	bsr	R.c009ba




*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level1(pc),$64.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
;	move.l	#4*40*200,d0
;	move.l	screen.mem(pc),a1
;	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

gfxbase		dc.l	0
old.ints	dc.w	0
old.level1	dc.l	0




*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

R.c00506
	lea	TAB.c01306(pc),a5
	lea	$dff000,a6
	move.w	#$8760,dmacon(a6)
	moveq	#0,d0
	move.w	d0,bplcon0(a6)
	move.w	d0,color0(a6)
	move.w	d0,$1fc(a6)
	lea	copper.sptrs+2,a0
	move.l	#source.sprites,d0
	moveq	#8-1,d7

.l001	move.w	d0,(a0)			set up sprite pointers
	swap	d0
	move.w	d0,4(a0)
	swap	d0
	add.l	#$294,d0
	addq.l	#8,a0
	dbra	d7,.l001

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002

	bsr	R.c01270		make 180 deg rotation of picture

	lea	DAT.32dc0,a0
	bsr	R.c0097e		clear 45056 words

.l003	btst	#6,dmaconr(a6)
	bne.s	.l003

	move.l	#$dfc0000,bltcon0(a6)	D = A + B
	moveq	#38,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltdmod(a6)
	move.w	#320-1,d7
	move.l	#$80008000,d0
	lea	source.picture,a1
	lea	DAT.32dc0,a0

.l004	btst	#6,dmaconr(a6)
	bne.s	.l004

	move.l	d0,bltafwm(a6)
	movem.l	a0-a1,bltbpth(a6)
	move.l	a0,bltdpth(a6)
	move.w	#768*64+1,bltsize(a6)
	ror.l	#1,d0
	bpl.s	.l005
	addq.l	#2,a0
	addq.l	#2,a1

.l005	lea	160(a0),a0
	dbra	d7,.l004

	move.w	#20479,d7
	lea	DAT.32dc0,a0
	lea	DAT.c14378,a1

.l006	move.l	(a0)+,(a1)+
	dbra	d7,.l006

	lea	DAT.32dc0,a0
	bsr	R.c0097e

	lea	2(a6),a2
	lea	114(a6),a3
	lea	bltsize(a6),a4
	moveq	#6,d2

.l007	btst	d2,(a2)
	bne.s	.l007

	moveq	#96,d3
	move.w	d3,96(a6)
	move.w	d3,bltdmod(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#1026,d4
	moveq	#11,d5
	lea	DAT.311a0,a0
	lea	DAT.32dc0,a1

.l008	moveq	#15,d6
	move.l	#$bca,d1

.l009	moveq	#3,d7

.l00a	btst	d2,(a2)
	bne.s	.l00a

	move.w	#65504,82(a6)
	move.w	#65472,bltamod(a6)
	move.w	#0,bltbmod(a6)
	move.w	d1,bltcon0(a6)
	move.w	#61505,66(a6)
	move.w	#32768,116(a6)
	move.l	a1,72(a6)
	move.l	a1,bltdpth(a6)
	move.w	(a0)+,d3

.l00b	btst	d2,(a2)
	bne.s	.l00b
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l00c	btst	d2,(a2)
	bne.s	.l00c
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l00d	btst	d2,(a2)
	bne.s	.l00d
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l00e	btst	d2,(a2)
	bne.s	.l00e
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l00f	btst	d2,(a2)
	bne.s	.l00f
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l010	btst	d2,(a2)
	bne.s	.l010
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l011	btst	d2,(a2)
	bne.s	.l011
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l012	btst	d2,(a2)
	bne.s	.l012
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l013	btst	d2,(a2)
	bne.s	.l013
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l014	btst	d2,(a2)
	bne.s	.l014
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l015	btst	d2,(a2)
	bne.s	.l015
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l016	btst	d2,(a2)
	bne.s	.l016
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l017	btst	d2,(a2)
	bne.s	.l017
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l018	btst	d2,(a2)
	bne.s	.l018
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l019	btst	d2,(a2)
	bne.s	.l019
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l01a	btst	d2,(a2)
	bne.s	.l01a
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l01b	btst	d2,(a2)
	bne.s	.l01b
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l01c	btst	d2,(a2)
	bne.s	.l01c
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l01d	btst	d2,(a2)
	bne.s	.l01d
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l01e	btst	d2,(a2)
	bne.s	.l01e
	move.w	d3,(a3)
	move.w	d4,(a4)
	lea	24(a1),a1
	dbra	d7,.l00a

	add.w	#4096,d1
	lea	-320(a0),a0
	dbra	d6,.l009

	addq.l	#2,a1
	dbra	d5,.l008

	move.w	#12287,d7
	lea	DAT.32dc0,a0
	lea	DAT.c28378,a1

.l01f	move.l	(a0)+,(a1)+
	dbra	d7,.l01f

	lea	DAT.32dc0,a0
	bsr	R.c0097e

.l020	btst	#6,dmaconr(a6)
	bne.s	.l020

	move.l	#$0dfc0000,bltcon0(a6)
	moveq	#38,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltdmod(a6)
	move.w	#319,d7
	move.l	#$80008000,d0
	lea	DAT.29a40,a1
	lea	DAT.32dc0,a0

.l021	btst	#6,dmaconr(a6)
	bne.s	.l021

	move.l	d0,bltafwm(a6)
	movem.l	a0-a1,bltbpth(a6)
	move.l	a0,bltdpth(a6)
	move.w	#49153,bltsize(a6)
	ror.l	#1,d0
	bpl.s	.l022
	addq.l	#2,a0
	addq.l	#2,a1

.l022	lea	160(a0),a0
	dbra	d7,.l021

	move.w	#20479,d7
	lea	DAT.32dc0,a0
	lea	DAT.c34378,a1

.l023	move.l	(a0)+,(a1)+
	dbra	d7,.l023

	lea	DAT.32dc0,a0
	bsr	R.c0097e
	lea	2(a6),a2
	lea	114(a6),a3
	lea	bltsize(a6),a4
	moveq	#6,d2

.l024	btst	d2,(a2)
	bne.s	.l024
	moveq	#96,d3
	move.w	d3,96(a6)
	move.w	d3,bltdmod(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#1026,d4
	moveq	#11,d5
	lea	source.sprites-160,a0
	lea	DAT.32dc0,a1

.l025	moveq	#15,d6
	move.l	#$bca,d1

.l026	moveq	#3,d7

.l027	btst	d2,(a2)
	bne.s	.l027
	move.w	#65504,82(a6)
	move.w	#65472,bltamod(a6)
	move.w	#0,bltbmod(a6)
	move.w	d1,bltcon0(a6)
	move.w	#61505,66(a6)
	move.w	#32768,116(a6)
	move.l	a1,72(a6)
	move.l	a1,bltdpth(a6)
	move.w	(a0)+,d3

.l028	btst	d2,(a2)
	bne.s	.l028
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l029	btst	d2,(a2)
	bne.s	.l029
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02a	btst	d2,(a2)
	bne.s	.l02a
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02b	btst	d2,(a2)
	bne.s	.l02b
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02c	btst	d2,(a2)
	bne.s	.l02c
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02d	btst	d2,(a2)
	bne.s	.l02d
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02e	btst	d2,(a2)
	bne.s	.l02e
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l02f	btst	d2,(a2)
	bne.s	.l02f
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l030	btst	d2,(a2)
	bne.s	.l030
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l031	btst	d2,(a2)
	bne.s	.l031
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l032	btst	d2,(a2)
	bne.s	.l032
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l033	btst	d2,(a2)
	bne.s	.l033
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l034	btst	d2,(a2)
	bne.s	.l034
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l035	btst	d2,(a2)
	bne.s	.l035
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l036	btst	d2,(a2)
	bne.s	.l036
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l037	btst	d2,(a2)
	bne.s	.l037
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l038	btst	d2,(a2)
	bne.s	.l038
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l039	btst	d2,(a2)
	bne.s	.l039
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l03a	btst	d2,(a2)
	bne.s	.l03a
	move.w	d3,(a3)
	move.w	d4,(a4)
	move.w	(a0)+,d3

.l03b	btst	d2,(a2)
	bne.s	.l03b
	move.w	d3,(a3)
	move.w	d4,(a4)
	lea	24(a1),a1
	dbra	d7,.l027

	add.w	#4096,d1
	lea	-320(a0),a0
	dbra	d6,.l026

	addq.l	#2,a1
	dbra	d5,.l025

	move.w	#12287,d7
	lea	DAT.32dc0,a0
	lea	DAT.c48378,a1

.l03c	move.l	(a0)+,(a1)+
	dbra	d7,.l03c

	lea	DAT.32dc0,a0
	bsr	R.c0097e
	bsr	R.c00a28
	move.l	10(a5),d0
	move.l	14(a5),10(a5)
	move.l	d0,14(a5)
	bsr	R.c00ba8
	clr.w	0(a5)

	lea	copper.list,a0
	move.l	a0,cop1lch(a6)
	clr.w	copjmp1(a6)

	lea	R.c00ae8(pc),a0
	move.l	a0,$64.w
	move.w	#$0001,intreq(a6)
	move.w	#$c001,intena(a6)
	move.w	#$8080,dmacon(a6)
	rts


R.c0097e
	btst	#6,dmaconr(a6)
	bne.s	R.c0097e

	move.l	a0,bltdpth(a6)
	move.l	#$1000000,bltcon0(a6)
	move.w	#0,bltdmod(a6)
	move.w	#22,bltsize(a6)		1024 high, 44 bytes wide

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002

	move.w	#22,bltsize(a6)		1024 high, 44 bytes wide

.l003	btst	#6,dmaconr(a6)
	bne.s	.l003
	rts


W.c009b6	dc.w	1500
W.c009b8	dc.w	0


R.c009ba
	btst	#7,$bfe001
	beq	.l003

	tst.w	W.c009b8
	bne	.l002

	tst.w	4(a5)
	beq.s	R.c009ba

	tst.w	20(a5)
	beq.s	R.c009ba

	move.w	2(a5),d7
	lea	TAB.c00b88(pc),a0
	move.l	4(a0,d7.w),a0
	jsr	(a0)
	clr.w	20(a5)
	clr.w	4(a5)
	bra.s	R.c009ba

.l002	move.l	#0,$f4
	bra	.l004

.l003	move.l	#-1,$f4

.l004	st	W.c00a26

.l005	tst.w	W.c00a26
	bne.s	.l005

.l006	btst	#6,dmaconr(a6)
	bne.s	.l006
	rts


W.c00a24	dc.w	0
W.c00a26	dc.w	0


R.c00a28
	lea	DAT.c14378,a0
	move.l	14(a5),a1
	lea	2(a1),a1
	move.w	#2047,d7

.l001	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	4(a1),a1
	dbra	d7,.l001
	rts


R.c00a58
	lea	DAT.c28378,a0
	move.l	14(a5),a1
	lea	2(a1),a1
	move.w	#2047,d7

.l001	clr.l	(a1)+
	clr.l	(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	lea	4(a1),a1
	dbra	d7,.l001
	rts


R.c00a88
	lea	DAT.c34378,a0
	move.l	14(a5),a1
	lea	2(a1),a1
	move.w	#2047,d7

.l001	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	4(a1),a1
	dbra	d7,.l001
	rts


R.c00ab8
	lea	DAT.c48378,a0
	move.l	14(a5),a1
	lea	2(a1),a1
	move.w	#2047,d7

.l001	clr.l	(a1)+
	clr.l	(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	lea	4(a1),a1
	dbra	d7,.l001
	rts


R.c00ae8
	movem.l	d7/a0-a1,-(a7)
	cmp.w	#127,0(a5)
	bne	.l001
	tst.w	20(a5)
	bne	.l007

.l001	move.l	10(a5),d0
	move.l	6(a5),10(a5)
	move.l	d0,6(a5)
	bsr	R.c00c7e
	subq.w	#1,W.c009b6
	bpl	.l002
	st	W.c009b8

.l002	tst.w	W.c00a26
	bne	.l004
	addq.w	#1,W.c00a24
	cmp.w	#32,W.c00a24
	beq.s	.l003
	bsr	R.c01166
	bra	.l006

.l003	move.l	#L.c011ec,L.c011e4
	move.w	#31,W.c00a24
	bra	.l006

.l004	subq.w	#1,W.c00a24
	bmi.s	.l005
	bsr	R.c01166
	bra	.l006

.l005	clr.w	W.c00a26

.l006	move.w	2(a5),d0
	move.l	TAB.c00b88(pc,d0.w),a0
	jsr	(a0)

.l007	move.w	#1,156(a6)
	st	4(a5)
	movem.l	(a7)+,d7/a0-a1
	rte	


TAB.c00b88
	dc.l	R.c00cf2,R.c00a58,R.c00f0a,R.c00a88
	dc.l	R.c00cf2,R.c00ab8,R.c00f0a,R.c00a28


R.c00ba8
	clr.w	0(a5)

.l001	lea	DAT.c0131c,a0
	move.w	0(a5),d7
	mulu	#604,d7
	add.l	d7,a0
	lea	404(a0),a1
	move.w	0(a5),d7
	sub.w	#64,d7
	muls	#5,d7
	move.w	d7,18(a5)
	move.w	18(a5),d7
	muls	d7,d7
	asl.l	#8,d7
	asl.l	#6,d7
	divu	#51200,d7
	add.l	d7,d7
	add.l	#$10000,d7
	move.l	d7,d6
	lsr.l	#2,d6
	mulu	#400,d6
	swap	d6
	neg.w	d6
	add.w	#256,d6
	mulu	#176,d6
	move.l	#$5000,d5
	muls	18(a5),d5
	move.l	d5,d4
	add.l	#$8000,d5
	neg.l	d4
	asr.l	#2,d4
	divs	#100,d4
	ext.l	d4
	add.l	d4,d4
	add.l	d4,d4
	move.l	d5,d2
	swap	d2
	asr.w	#4,d2
	add.w	d2,d2
	addq.w	#2,d2
	ext.l	d2
	move.l	d2,d0
	add.l	d6,d0
	move.l	d0,(a0)+
	move.l	#$8000,d0
	move.w	#199,d6

.l002	swap	d0
	move.w	d0,d1
	swap	d0
	mulu	#176,d1
	swap	d5
	moveq	#-16,d3
	and.w	d5,d3
	asr.w	#3,d3
	add.w	d3,d1
	moveq	#15,d3
	and.w	d5,d3
	eor.w	#15,d3
	swap	d5
	exg	d1,d2
	neg.w	d1
	add.w	d2,d1
	sub.w	#40,d1
	move.w	d1,(a0)+
	move.b	d3,(a1)
	asl.w	#4,d3
	or.b	d3,(a1)+
	add.l	d7,d0
	add.l	d4,d5
	dbra	d6,.l002
	addq.w	#1,0(a5)
	cmp.w	#128,0(a5)
	ble	.l001
	rts


R.c00c7e
	lea	DAT.c0131c,a0
	move.w	0(a5),d7
	mulu	#604,d7
	add.l	d7,a0
	lea	404(a0),a1
	lea	copper.bptrs+2,a2
	move.l	6(a5),d0
	add.l	(a0)+,d0
	moveq	#44,d1
	move.w	d0,(a2)
	swap	d0
	move.w	d0,4(a2)

	swap	d0
	add.l	d1,d0
	move.w	d0,8(a2)
	swap	d0
	move.w	d0,12(a2)

	swap	d0
	add.l	d1,d0
	move.w	d0,16(a2)
	swap	d0
	move.w	d0,20(a2)

	swap	d0
	add.l	d1,d0
	move.w	d0,24(a2)
	swap	d0
	move.w	d0,28(a2)

	lea	copper.waits+18,a2
	move.w	#200-1,d6
	moveq	#16,d2

.l001	move.w	(a0)+,d0
	move.w	d0,(a2)
	move.w	d0,-4(a2)
	move.b	(a1)+,9(a2)
	add.w	d2,a2
	dbra	d6,.l001
	rts


R.c00cf2
	movem.l	6(a5),a0/a2
	move.w	0(a5),d0
	move.w	#2544,d4
	move.w	#3556,d5
	cmp.w	#127,0(a5)
	bne	.l001
	bsr	R.c00ed8
	move.w	#256,d4
	move.w	#256,d5

.l001	btst	#6,dmaconr(a6)
	bne.s	.l001
	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.w	#0,66(a6)
	moveq	#42,d1
	move.w	d1,bltamod(a6)
	move.w	d1,bltbmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	d0,d1
	muls	#5,d1
	lsr.w	#1,d1
	muls	#176,d1
	add.l	#$fffffdf2,d1
	move.w	d0,d2
	lsr.w	#2,d2
	neg.w	d2
	add.w	#16,d2
	muls	#176,d2
	move.w	d2,d3
	sub.w	#176,d3
	cmp.w	#64,d0
	blt	.l002
	add.w	d2,a0
	add.w	d2,a2

.l002	addq.w	#1,0(a5)
	addq.w	#2,d2
	addq.w	#2,d3
	add.l	d1,a0
	lea	-176(a0),a0
	btst	#0,d0
	bne.s	.l003
	lea	-176(a0),a0

.l003	lea	-176(a0),a1
	add.l	d1,a2
	move.w	#55809,d6
	moveq	#4,d7
	moveq	#3,d1
	and.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	lsr.w	#1,d0
	and.w	#30,d0
	move.w	TAB.c00dba(pc,d0.w),112(a6)
	jmp	.l004(pc,d1.w)

.l004	bra	R.c00e28
	bra	R.c00e0e
	bra	R.c00df4
	bra	R.c00dda


TAB.c00dba
	dc.w	$ff00,$ffff,$f000,$fff0,$fc00,$fffc,$c000,$ffc0
	dc.w	$8000,$ff80,$f800,$fff8,$fe00,$fffe,$e000,$ffe0


R.c00dda
	bsr	R.c00eba
	bsr	R.c00eba
	bsr	R.c00eba
	bsr	R.c00e42
	lea	-176(a2),a2
	dbra	d7,R.c00dda
	rts


R.c00df4
	bsr	R.c00eba
	bsr	R.c00e42
	bsr	R.c00e7e
	bsr	R.c00e60
	lea	-176(a2),a2
	dbra	d7,R.c00df4
	rts


R.c00e0e
	bsr	R.c00eba
	bsr	R.c00e9c
	bsr	R.c00e42
	bsr	R.c00e60
	lea	-176(a2),a2
	dbra	d7,R.c00e0e
	rts


R.c00e28
	bsr	R.c00e42
	bsr	R.c00e60
	bsr	R.c00e60
	bsr	R.c00e60
	lea	-176(a2),a2
	dbra	d7,R.c00e28
	rts


R.c00e42
	btst	#6,dmaconr(a6)
	bne.s	R.c00e42
	move.w	d5,bltcon0(a6)
	movem.l	a0-a2,bltbpth(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2
	rts


R.c00e60
	btst	#6,dmaconr(a6)
	bne.s	R.c00e60
	move.w	d4,bltcon0(a6)
	movem.l	a0/a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2
	rts


R.c00e7e
	btst	#6,dmaconr(a6)
	bne.s	R.c00e7e
	move.w	d4,bltcon0(a6)
	movem.l	a0/a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d3,a0
	add.w	d3,a1
	add.w	d3,a2
	rts


R.c00e9c
	btst	#6,dmaconr(a6)
	bne.s	R.c00e9c
	move.w	d4,bltcon0(a6)
	movem.l	a1-a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2
	rts


R.c00eba
	btst	#6,dmaconr(a6)
	bne.s	R.c00eba
	move.w	d4,bltcon0(a6)
	movem.l	a1-a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d3,a0
	add.w	d3,a1
	add.w	d3,a2
	rts


R.c00ed8
	movem.l	6(a5),d1-d3
	move.l	d1,14(a5)
	move.l	d2,6(a5)
	move.l	d3,10(a5)
	move.w	#65535,0(a5)
	move.w	2(a5),d1
	addq.w	#8,d1
	and.w	#24,d1
	move.w	d1,2(a5)
	st	20(a5)
	move.l	d2,a2
	sub.w	#2,d0
	rts


R.c00f0a
	movem.l	6(a5),a0/a2
	move.w	0(a5),d0
	move.w	#2544,d4
	move.w	#3556,d5
	cmp.w	#127,0(a5)
	bne	.l001
	bsr	R.c01132
	move.w	#256,d4
	move.w	#256,d5

.l001	btst	#6,dmaconr(a6)
	bne.s	.l001
	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.w	#0,66(a6)
	moveq	#42,d1
	move.w	d1,bltamod(a6)
	move.w	d1,bltbmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	d0,d1
	muls	#3,d1
	lsr.w	#1,d1
	muls	#176,d1
	btst	#0,d0
	beq.s	.l002
	add.w	#176,d1

.l002	add.l	#$fffffdfa,d1
	move.w	d0,d2
	lsr.w	#2,d2
	neg.w	d2
	add.w	#16,d2
	muls	#176,d2
	move.w	d2,d3
	sub.w	#176,d3
	cmp.w	#64,d0
	blt	.l003
	add.w	d2,a0
	add.w	d2,a2

.l003	addq.w	#1,0(a5)
	addq.w	#2,d2
	addq.w	#2,d3
	add.l	d1,a0
	btst	#0,d0
	bne.s	.l004
	lea	-176(a0),a0

.l004	lea	-176(a0),a1
	add.l	d1,a2
	move.w	#44289,d6
	moveq	#2,d7
	moveq	#3,d1
	and.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	lsr.w	#1,d0
	and.w	#30,d0
	move.w	TAB.c00fd8(pc,d0.w),112(a6)
	jmp	.l005(pc,d1.w)

.l005	bra	R.c01046
	bra	R.c0102c
	bra	R.c01012
	bra	R.c00ff8


TAB.c00fd8
	dc.w	$ff00,$ffff,$f000,$fff0,$fc00,$fffc,$c000,$ffc0
	dc.w	$8000,$ff80,$f800,$fff8,$fe00,$fffe,$e000,$ffe0


R.c00ff8
	bsr	R.c01108
	bsr	R.c01108
	bsr	R.c01108
	bsr	R.c01060
	lea	-176(a2),a2
	dbra	d7,R.c00ff8
	rts


R.c01012
	bsr	R.c01108
	bsr	R.c01060
	bsr	R.c010b4
	bsr	R.c0108a
	lea	-176(a2),a2
	dbra	d7,R.c01012
	rts


R.c0102c
	bsr	R.c01108
	bsr	R.c010de
	bsr	R.c01060
	bsr	R.c0108a
	lea	-176(a2),a2
	dbra	d7,R.c0102c
	rts


R.c01046
	bsr	R.c01060
	bsr	R.c0108a
	bsr	R.c0108a
	bsr	R.c0108a
	lea	-176(a2),a2
	dbra	d7,R.c01046
	rts


R.c01060
	btst	#6,dmaconr(a6)
	bne.s	R.c01060
	move.w	d5,bltcon0(a6)
	movem.l	a0-a2,bltbpth(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002
	move.w	d6,bltsize(a6)
	rts


R.c0108a
	btst	#6,dmaconr(a6)
	bne.s	R.c0108a
	move.w	d4,bltcon0(a6)
	movem.l	a0/a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002
	move.w	d6,bltsize(a6)
	rts


R.c010b4
	btst	#6,dmaconr(a6)
	bne.s	R.c010b4
	move.w	d4,bltcon0(a6)
	movem.l	a0/a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d3,a0
	add.w	d3,a1
	add.w	d3,a2

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002
	move.w	d6,bltsize(a6)
	rts


R.c010de
	btst	#6,dmaconr(a6)
	bne.s	R.c010de
	move.w	d4,bltcon0(a6)
	movem.l	a1-a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d2,a0
	add.w	d2,a1
	add.w	d2,a2

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002
	move.w	d6,bltsize(a6)
	rts


R.c01108
	btst	#6,dmaconr(a6)
	bne.s	R.c01108
	move.w	d4,bltcon0(a6)
	movem.l	a1-a2,80(a6)
	move.w	d6,bltsize(a6)
	add.w	d3,a0
	add.w	d3,a1
	add.w	d3,a2

.l002	btst	#6,dmaconr(a6)
	bne.s	.l002
	move.w	d6,bltsize(a6)
	rts


R.c01132
	movem.l	6(a5),d1-d3
	move.l	d1,14(a5)
	move.l	d2,6(a5)
	move.l	d3,10(a5)
	move.w	#65535,0(a5)
	move.w	2(a5),d1
	addq.w	#8,d1
	and.w	#24,d1
	move.w	d1,2(a5)
	st	20(a5)
	move.l	d2,a2
	sub.w	#2,d0
	rts


W.c01164	dc.w	0


R.c01166
	eor.w	#1,W.c01164
	bne	.l008

	move.l	L.c011e4,a2
	lea	copper.colours+2,a0
	move.l	(a2),a1
	moveq	#31,d7

.l001	move.w	(a0),d0
	move.w	(a1)+,d1
	move.w	d0,d2
	move.w	d1,d3
	and.w	#3840,d2
	and.w	#3840,d3
	cmp.w	d2,d3
	blt.s	.l002
	beq.s	.l003
	add.w	#256,d0
	bra.s	.l003

.l002	sub.w	#256,d0

.l003	move.w	d0,d2
	move.w	d1,d3
	and.w	#240,d2
	and.w	#240,d3
	cmp.w	d2,d3
	blt.s	.l004
	beq.s	.l005
	add.w	#16,d0
	bra.s	.l005

.l004	sub.w	#16,d0

.l005	move.w	d0,d2
	move.w	d1,d3
	and.w	#15,d2
	and.w	#15,d3
	cmp.w	d2,d3
	blt.s	.l006
	beq.s	.l007
	add.w	#1,d0
	bra.s	.l007

.l006	sub.w	#1,d0

.l007	move.w	d0,(a0)
	addq.l	#4,a0
	dbra	d7,.l001

.l008	rts


L.c011e4	dc.l	L.c011e8
L.c011e8	dc.l	TAB.c011f0
L.c011ec	dc.l	TAB.c01230


TAB.c011f0
	dc.w	$0000,$0aff,$0036,$0047,$0058,$0069,$007a,$008b
	dc.w	$009c,$00ad,$00be,$00cf,$00df,$00ef,$05ff,$0025
	dc.w	$0000,$0fff,$0888,$0000,$0000,$0fff,$0888,$0000
	dc.w	$0000,$0fff,$0888,$0000,$0000,$0fff,$0888,$0000

TAB.c01230
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


R.c01270
	bsr.s	R.c012d2		make reverse of all byte values

	lea	source.picture,a0
	lea	DAT.311a0+40,a1
	bsr.s	.l001

	lea	source.picture+40,a0
	lea	DAT.311a0+80,a1
	bsr.s	.l001

	lea	source.picture+80,a0
	lea	DAT.311a0+120,a1
	bsr.s	.l001

	lea	source.picture+120,a0
	lea	DAT.311a0+160,a1

.l001	lea	DAT.311a0+160,a2
	move.w	#40-1,d0
	move.w	#192-1,d1

.l002	move.b	(a0)+,d2
	move.b	(a2,d2.w),-(a1)
	dbra	d0,.l002		reverse one line

	move.w	#40-1,d0
	lea	-120(a1),a1
	lea	120(a0),a0
 	dbra	d1,.l002		reverse one bitplane
	rts


R.c012d2
	lea	DAT.311a0+160,a0
	moveq	#0,d7

.l001	moveq	#0,d1
	move.w	d7,d0
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	lsr.w	#1,d0
	roxl.w	#1,d1
	move.b	d1,(a0)+
	addq.b	#1,d7
	bne.s	.l001
	rts


TAB.c01306
	dc.w	$0000,$0000,$0000,$0003,$2dc0,$0004,$a940,$0006
	dc.w	$24c0,$ff00,$ffff




	section	DataTables,bss_f


DAT.c0131c
	ds.w	38958


DAT.c14378
	ds.w	40960


DAT.c28378
	ds.w	24576


DAT.c34378
	ds.w	40960


DAT.c48378
	ds.w	24576




	section	Graphics,data_c


*"""""""""""""""""""
*" THE COPPER LIST "
*"		   "
*"""""""""""""""""""

copper.list
	dc.w	$1011,$fffe
copper.sptrs
	dc.w	$0122,$0000
	dc.w	$0120,$0000
	dc.w	$0126,$0000
	dc.w	$0124,$0000
	dc.w	$012a,$0000
	dc.w	$0128,$0000
	dc.w	$012e,$0000
	dc.w	$012c,$0000
	dc.w	$0132,$0000
	dc.w	$0130,$0000
	dc.w	$0136,$0000
	dc.w	$0134,$0000
	dc.w	$013a,$0000
	dc.w	$0138,$0000
	dc.w	$013e,$0000
	dc.w	$013c,$0000

	dc.w	$2811,$fffe
	dc.w	diwstrt,$2c91
	dc.w	diwstop,$f4c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

copper.bptrs
	dc.w	bpl1ptl,0
	dc.w	bpl1pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl4pth,0

copper.colours
	dc.w	$0180,$0000
	dc.w	$0182,$0000
	dc.w	$0184,$0000
	dc.w	$0186,$0000
	dc.w	$0188,$0000
	dc.w	$018a,$0000
	dc.w	$018c,$0000
	dc.w	$018e,$0000
	dc.w	$0190,$0000
	dc.w	$0192,$0000
	dc.w	$0194,$0000
	dc.w	$0196,$0000
	dc.w	$0198,$0000
	dc.w	$019a,$0000
	dc.w	$019c,$0000
	dc.w	$019e,$0000
	dc.w	$01a0,$0000
	dc.w	$01a2,$0000
	dc.w	$01a4,$0000
	dc.w	$01a6,$0000
	dc.w	$01a8,$0000
	dc.w	$01aa,$0000
	dc.w	$01ac,$0000
	dc.w	$01ae,$0000
	dc.w	$01b0,$0000
	dc.w	$01b2,$0000
	dc.w	$01b4,$0000
	dc.w	$01b6,$0000
	dc.w	$01b8,$0000
	dc.w	$01ba,$0000
	dc.w	$01bc,$0000
	dc.w	$01be,$0000

	dc.w	bplcon0,$4200
	dc.w	bplcon2,%100100

copper.waits
	dc.w	$2b11,$fffe
	dc.w	$01fe,$0000
	dc.w	$0102,$0000
	dc.w	$0108,$0000
	dc.w	$010a,$0000

	dc.w	$2be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$2ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$2de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$2ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$2fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$30e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$31e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$32e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$33e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$34e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$35e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$36e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$37e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$38e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$39e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$3fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$40e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$41e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$42e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$43e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$44e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$45e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$46e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$47e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$48e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$49e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$4fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$50e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$51e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$52e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$53e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$54e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$55e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$56e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$57e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$58e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$59e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$5fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$60e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$61e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$62e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$63e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$64e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$65e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$66e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$67e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$68e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$69e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$6fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$70e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$71e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$72e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$73e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$74e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$75e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$76e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$77e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$78e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$79e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$7fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$80e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$81e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$82e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$83e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$84e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$85e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$86e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$87e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$88e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$89e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$8fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$90e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$91e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$92e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$93e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$94e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$95e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$96e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$97e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$98e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$99e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9ae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9be1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9ce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9de1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9ee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$9fe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a3e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a4e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a5e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a6e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a7e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a8e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$a9e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$aae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$abe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$ace1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$ade1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$aee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$afe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b3e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b4e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b5e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b6e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b7e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b8e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$b9e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bbe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bde1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$bfe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c3e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c4e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c5e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c6e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c7e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c8e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$c9e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cbe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cde1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$cfe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d3e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d4e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d5e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d6e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d7e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d8e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$d9e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dbe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dce1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dde1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$dfe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e3e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e4e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e5e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e6e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e7e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e8e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$e9e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$eae1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$ebe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$ece1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$ede1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$eee1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$efe1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$f0e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$f1e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$f2e1,$fffe
	dc.w	$0102,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050

	dc.w	$f411,$fffe
	dc.w	intreq,$8001
	dc.w	$ffff,$fffe




*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

source.picture
	incbin	Brian.bin


source.sprites
	incbin	Brian.Sprites.bin




	section	Space,bss_c


DAT.29a40
	ds.w	15280			180 deg rotation of source.picture
DAT.311a0
	ds.w	80


	ds.b	256			reverse byte table


	ds.w	3392


DAT.32dc0
	ds.w	45056			cleared

	ds.w	134944




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
