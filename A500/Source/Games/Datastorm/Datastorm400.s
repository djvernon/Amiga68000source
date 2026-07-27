	section	DS,code_f

* Datastorm loader
* Amiga needs 512K Chip and 4MB Fast RAM to assemble and run this

DISK_ACCESS_DISABLED	equ	1
PROTECTION_DISABLED	equ	1
NO_SHIP_ANIMATIONS	equ	1	disable pilot cockpit animation before game and ship destroyed animation

INFINITE_LIVES		equ	1
INFINITE_SHIELD		equ	1
INFINITE_SMART_BOMBS	equ	1
INFINITE_MISSILES	equ	1

start	move.w	#$7fff,$dff09a
	move.l	#trap0,$80
	trap	#0		enter supervisor mode

trap0	movea.l	#$400,a7
;	move.b	#$4c,$bfdc00
;	move.w	#$7fff,$dff09a
;	move.w	#$4000,$dff09a

* Copy game code to Chip RAM
	movea.l	#$400,a0
	movea.l	#Data400,a1
.copy	move.l	(a1)+,(a0)+
	cmpa.l	#$20400,a0
	bne.s	.copy

;	movea.l	#$400,a7
;	lea	$bfd100,a0	turn drive 0 motor on
;	bclr	#7,(a0)		motor on
;	bset	#3,(a0)
;	bclr	#3,(a0)		select drive 0

	move.b	#$79,$bfdc00

;	move.l	#$aac,$7fffc
	IFND	PROTECTION_DISABLED
	move.l	#$33ab1144,$74f56
;	move.l	#$a6cd233b,$74f32
	move.l	#$fb,$73334
	move.w	#$6263,$75f42
	move.w	#$fffe,$30600
	move.b	#$50,$76b50
	move.b	#$f8,$76cc0
	ENDC
	move.w	#$7fff,$dff096
;	move.l	#$45a38,$dff080		doesn't appear to be valid copper list
;	move.l	#$45c04,$dff084		doesn't appear to be valid copper list
;	move.w	$dff088,d0
;	move.w	$dff08a,d0
	move.b	#$64,$bfe401
	move.b	#$80,$bfe501
	move.b	#$88,$bfee01
	move.b	#$81,$bfed01
	move.w	#$4489,$dff07e
	move.w	#$6e00,$dff09e
	move.w	#$9500,$dff09e
	move.w	#$83d0,$dff096

;	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff09c
	move.w	#$8010,$dff09a
	move.w	#$8a05,$dff09c
	move.w	#$ff,$dff09e
	move.w	#$80df,$dff09e
;.loop	bra.s	.loop

* Modify start / size of next RAM area to be used (already populated with data that used to be loaded from disk)
	move.l	#Data200000,$70000	start
	move.l	#$100000,$70004		size

* Jump to start of game
	jmp	$400.w




	section	DSdata,data_f

Data200000	incbin	Datastorm200000
load_space	ds.b	$100000-(load_space-Data200000)		; make up to 1MB of memory space




	section	DScode,code_f

Data400	; Don't move this after the org $400 below
	; (because copy loop above would try to copy from $400 instead of actual address of Data400)

	org	$400


* Datastorm game start
	movea.l	#$400,a7
	move.l	#$1700c,L1ad32
	jsr	L1ad36		load high score data
	jsr	Lfeca		set interrupt vectors
	move.w	#$100,Lcae
	jsr	L177b8		load main data (compressed graphics and sound)
	jmp	Lcbc


L430
	movea.l	#$49e,a0
	jmp	L58e


	move.l	(a0),Lc6a
	move.b	$7(a0),Lcb1
	move.b	$4(a0),L80c+2
	clr.b	$4(a0)
L456
	clr.b	Lcb4
	clr.b	Lcb3
	move.b	#$1,Lcb2
	jmp	L810
	moveq	#$0,d0
	move.b	#$1,Lcb9
L47a
	tst.l	L8a4
	beq.s	L496
	move.l	d0,-(a7)
	jsr	L430
	move.l	(a7)+,d0
	addq.l	#1,d0
	cmpi.l	#$1c,d0
	bne.s	L47a
L496
	clr.b	Lcb9
	rts


* list of disk data memory addresses
* 30 pairs of destination address (of compressed data in Chip RAM), source address (in expansion RAM)
L49e	dc.l	$00068708			0 game sprites, radar outline, font
L4a2	dc.l	$00000000
	dc.w	$0006,$2690,$0000,$0000		1 hall of fame graphic and running man sprites
	dc.w	$0004,$4cb2,$0000,$0000		2 datascores music
	dc.w	$0006,$8626,$0000,$0000		3 game choice screen, 'datastorm' logo (without triangle below)
	dc.w	$0001,$c764,$0000,$0000		4 datatitle music
L4c6	dc.w	$0000,$0000,$0000,$0000		5 squid
L4ce	dc.w	$0000,$0000,$0000,$0000		6 skull
	dc.w	$0007,$260a,$0000,$0000		7 walker sprite (from attract screens)
	dc.w	$0006,$5e9a,$0000,$0000		8 flags (from attract screens)
	dc.w	$0002,$0400,$0000,$0000		9 pilot's hand animation
	dc.w	$0005,$2dfa,$0000,$0000		10 pilot in cockpit
	dc.w	$0002,$0400,$0000,$0000		11 cockpit windscreen
	dc.w	$0005,$0000,$0000,$0000		12 possibly copper lists and some code
	dc.w	$0005,$42da,$0000,$0000		13 title screen with datastorm logo
	dc.w	$0001,$ca00,$0000,$0000		14 game sound effects
L516	dc.w	$0000,$0000,$0000,$0000		15 possibly mask data
	dc.w	$0004,$749a,$0000,$0000		16 'game play' screen 1 (all game play screens are 5 bitplanes)
	dc.w	$0004,$749a,$0000,$0000		17 'game play' screen 2
	dc.w	$0004,$749a,$0000,$0000		18 'game play' screen 3
	dc.w	$0004,$749a,$0000,$0000		19 'game play' screen 4
	dc.w	$0004,$749a,$0000,$0000		20 'game play' screen 5
	dc.w	$0004,$749a,$0000,$0000		21 'game play' screen 6 (tornado / blitters / mutants)
	dc.w	$0004,$749a,$0000,$0000		22 'game play' screen 7 (enemies)
	dc.w	$0004,$749a,$0000,$0000		23 'game play' screen 8 (specials)
	dc.w	$0004,$749a,$0000,$0000		24 title screen without datastorm logo
	dc.w	$0005,$42da,$0000,$0000		25 title screen with ship animation and without datastorm logo
	dc.w	$0005,$0000,$0000,$0000		26 title screen ship at full size, with moon
	dc.w	$0003,$5000,$0000,$0000		27 ship destroyed (game over) screen, with engine heat animation
	dc.w	$0001,$d4ac,$0000,$0000		28 unknown data (not code)
	dc.w	$0001,$d4ac,$0000,$0000		29 unknown data (not code)


L58e
	movem.l	d0-d7/a0-a1/a3-a4,-(a7)
	clr.w	Lcb2
	clr.b	Lcb4
	cmpi.l	#-$1,d0
	beq.s	L600
	mulu.w	#$8,d0
	lea	L49e,a0
	movea.l	(a0,d0.w),a3
	tst.l	$4(a0,d0.w)
	beq.s	L5d0
	movea.l	$4(a0,d0.w),a4
	lea	L7dc(pc),a0
	move.l	$4(a0,d0.w),d1
	movea.l	a3,a5
L5c8
	move.b	(a4)+,(a5)+
	subq.l	#1,d1
	bne.s	L5c8
	bra.s	L5e4


L5d0
	lea	L7dc(pc),a0
	move.l	(a0,d0.w),d6
L5d8
	divu.w	#$200,d6
	ext.l	d6
	move.l	$4(a0,d0.w),d5
	bsr.s	L63a
L5e4
	move.l	#$20002,Le124
	movea.l	a3,a2
	adda.l	$4(a0,d0.w),a2
	move.l	a2,Lc6a
	movem.l	(a7)+,d0-d7/a0-a1/a3-a4
	rts


L600
	movea.l	#$4b314,a3
	move.l	#$27cc,d5
	move.l	#$638,d6
	IFND	DISK_ACCESS_DISABLED
	bsr	L63a
	ELSE
	nop
	nop
	ENDC
	movea.l	a3,a2
	adda.l	#$27cc,a2
	move.l	a2,Lc6a
	move.l	#$4b322,$84
	st	L10876
	movem.l	(a7)+,d0-d7/a0-a1/a3-a4
	rts


L63a
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move.w	#$4489,$7e(a6)
	move.w	#$7f00,$9e(a6)
	move.w	#$9500,$9e(a6)
	move.l	#$55555555,d4
L65c
	bsr	L8cc
	lea	L734(pc),a0
	moveq	#$a,d0
L666
	clr.l	(a0)+
	dbra	d0,L666
	moveq	#$b,d7
	move.w	#$4000,$24(a6)
	lea	L17918,a5
	move.l	a5,$20(a6)
	clr.l	$440(a5)
	move.w	#$1002,$9c(a6)
	move.w	#$99e0,$24(a6)
	move.w	#$99e0,$24(a6)
L694
	tst.l	$440(a5)
	beq.s	L694
	movea.l	a5,a0
	bsr.s	L6e6
	bsr	L760
	tst.l	d0
	bne.s	L65c
L6a6
	btst	#$1,$1f(a6)
	beq.s	L6a6
	move.w	#$1002,$9c(a6)
	movea.l	a5,a0
L6b6
	bsr.s	L6e6
	bsr	L760
	tst.l	d0
	bne.s	L65c
	moveq	#$7f,d0
L6c2
	move.l	(a0),d2
	move.l	$200(a0),d3
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#1,d2
	or.l	d2,d3
	move.l	d3,(a0)+
	dbra	d0,L6c2
	lea	$200(a0),a0
	subq.l	#1,d7
	beq.s	L6f2
L6de
	cmpi.w	#$4489,(a0)+
	bne.s	L6de
	bra.s	L6b6


L6e6
	cmpi.w	#$4489,(a0)
	bne.s	L6f0
	addq.l	#2,a0
	bra.s	L6e6


L6f0
	rts


L6f2
	divu.w	#$b,d6
	move.l	d6,d0
	addq.w	#1,d6
	mulu.w	#$b,d6
	swap	d0
	mulu.w	#$4,d0
	lea	L734(pc),a0
	adda.l	d0,a0
L70a
	btst	#$6,$2(a6)
	bne.s	L70a
L712
	movea.l	(a0)+,a1
	move.w	#$200,d0
L718
	move.b	(a1)+,(a3)+
	subq.l	#1,d5
	beq.s	L72e
	subq.w	#1,d0
	bne.s	L718
	cmpa.l	#$760,a0
	bne.s	L712
	bra	L65c


L72e
	movem.l	(a7)+,d0-d7/a0-a6
	rts


L734	ds.w	11*2


L760
	bsr.s	L7b4
	move.l	d1,d2
	swap	d2
	lsr.b	#1,d2
	cmp.b	L95c(pc),d2
	beq.s	L776
	st	L95c
	bra.s	L7b0


L776
	lsr.w	#8,d1
	lsl.w	#2,d1
	move.w	d1,d2
	moveq	#$9,d0
	bsr.s	L7c4
	move.l	d0,d3
	adda.w	#$28,a0
	bsr.s	L7b4
	cmp.l	d3,d1
	bne.s	L7b0
	addq.l	#8,a0
	bsr.s	L7b4
	addq.l	#8,a0
	move.l	#$ff,d0
	bsr.s	L7c4
	cmp.l	d1,d0
	bne.s	L7b0
	lea	L734(pc),a1
	cmpi.w	#$2c,d2
	bcc.s	L7b0
	move.l	a0,(a1,d2.w)
	moveq	#$0,d0
	rts


L7b0
	moveq	#-$1,d0
	rts


L7b4
	move.l	(a0),d0
	move.l	$4(a0),d1
	and.l	d4,d0
	and.l	d4,d1
	lsl.l	#1,d0
	or.l	d0,d1
	rts


L7c4
	movem.l	d1-d2/a0,-(a7)
	moveq	#$0,d1
L7ca
	move.l	(a0)+,d2
	eor.l	d2,d1
	dbra	d0,L7ca
	move.l	d1,d0
	and.l	d4,d0
	movem.l	(a7)+,d1-d2/a0
	rts


* list of disk data to load
* 30 pairs of disk offset, length
L7dc	dc.l	$00002c00,$00009790
	dc.l	$0000c400,$000081e0
	dc.l	$00014600,$00008950
	dc.l	$0001d000,$0000566c
	dc.l	$00022800,$00023748
	dc.l	$00046000,$00001400
L80c	dc.l	$00047400
L810	dc.l	$00003904
	dc.l	$0004ae00,$0000119c
	dc.l	$0004c000,$000032a4
	dc.l	$0004f400,$0000e91c
	dc.l	$0005de00,$00004920
	dc.l	$00062800,$000012bc
	dc.l	$00063c00,$000006b8
	dc.l	$00064400,$00008ce4
	dc.l	$0006d200,$00026004
	dc.l	$00093400,$000009dc
	dc.l	$00093e00,$00000f30
	dc.l	$00094e00,$00000b04
	dc.l	$00095a00,$00001700
	dc.l	$00097200,$00000e4c
	dc.l	$00098200,$00000794
	dc.l	$00098a00,$0000078c
	dc.l	$00099200,$00000b78
	dc.l	$00099e00,$00000bcc
	dc.l	$0009aa00,$00008338
L8a4	dc.l	$000a2e00
L8a8	dc.l	$00015fc0
	dc.l	$000b8e00,$00001e90
	dc.l	$000bae00,$0000b088
	dc.l	$000c6000,$000001f0
	dc.l	$000c6200,$00000cc0


L8cc
	movem.l	d0-d1/a1-a2,-(a7)
	lea	$bfd100,a1
	lea	$bfe001,a2
	bclr	#$7,(a1)
	bset	#$3,(a1)
	bclr	#$3,(a1)
	tst.b	L95c
	bpl.s	L900
L8f0
	btst	#$4,(a2)
	beq.s	L8fa
	bsr.s	L93c
	bra.s	L8f0


L8fa
	clr.b	L95c
L900
	move.l	d6,d0
	divu.w	#$16,d0
L906
	cmp.b	L95c(pc),d0
	beq.s	L922
	bcs.s	L918
	bsr.s	L942
	addq.b	#1,L95c
	bra.s	L906


L918
	bsr.s	L93c
	subq.b	#1,L95c
	bra.s	L906


L922
	move.l	d6,d1
	divu.w	#$b,d1
	bset	#$2,(a1)
	btst	#$0,d1
	beq.s	L936
	bclr	#$2,(a1)
L936
	movem.l	(a7)+,d0-d1/a1-a2
	rts


L93c
	bset	#$1,(a1)
	bra.s	L946


L942
	bclr	#$1,(a1)
L946
	bclr	#$0,(a1)
	bset	#$0,(a1)
	move.l	d0,-(a7)
	move.w	#$e00,d0
L954
	dbra	d0,L954
	move.l	(a7)+,d0
	rts


L95c
	dc.w	$ffff
L95e
	dc.w	$0000,$0000
L962
	dc.w	$0000,$0000


* Data load routine
L966
	moveq	#$0,d0
L968
	lea	L7dc(pc),a0
	move.l	d0,d1
	mulu.w	#$8,d1
	move.l	L962(pc),d5
	cmp.l	$4(a0,d1.w),d5
	bcs.s	L9ac
	movea.l	L95e(pc),a3
	lea	L4a2,a1
	move.l	a3,(a1,d1.w)
	move.l	$4(a0,d1.w),d5
	move.l	(a0,d1.w),d6
	divu.w	#$200,d6
	ext.l	d6
	IFD	DISK_ACCESS_DISABLED
	nop
	nop
	ELSE
	bsr	L63a		load from disk
	ENDC
	move.l	$4(a0,d1.w),d1
	add.l	d1,L95e
	sub.l	d1,L962
L9ac
	addq.l	#1,d0
	IFD	DISK_ACCESS_DISABLED
	cmpi.l	#30,d0		process all 30 data areas
	ELSE
	cmpi.l	#28,d0
	ENDC
	bne.s	L968
	rts


	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
	illegal
La04
	bra	Lbca


	cmpi.b	#$14,d0
	bne.s	La66
	btst	#$6,$2(a6)
	bne	Lbca
	move.l	#$192ee,$4c(a6)
	move.l	#$17916,$48(a6)
	move.l	#$17916,$54(a6)
	move.l	#$0,$60(a6)
	move.w	#$0,$66(a6)
	move.l	#$ffffffff,$44(a6)
	move.w	#$aaaa,$74(a6)
	move.l	#$7caf000,$40(a6)
	move.w	#$3f8e,$58(a6)
	move.b	#$1e,Lcb2
	bra	Lbca


La66
	cmpi.b	#$1e,d0
	bne	Lb82
	btst	#$6,$2(a6)
	bne	Lbca
	movem.l	d2-d3/a1,-(a7)
	bsr	Lc48
	movea.l	(a0),a1
	tst.b	Lcb9
	beq.s	La90
	movea.l	#$192e8,a1
La90
	moveq	#$0,d1
	moveq	#$0,d2
	move.l	a0,-(a7)
	move.l	#$19c8,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	movea.l	#$17918,a0
Laa6
	move.w	(a0)+,d3
	add.w	d3,d2
	eor.w	d3,d1
	dbra	d0,Laa6
	move.w	d2,d0
	addq.w	#4,a0
	cmp.w	(a0)+,d1
	bne.s	Labc
	cmp.w	(a0)+,d0
	beq.s	Lace
Labc
	ori.w	#$8000,Lcb6
	movea.l	(a7)+,a0
	movem.l	(a7)+,d2-d3/a1
	bra	L95e


Lace
	tst.l	L5d8
	beq.s	Laf6
	movea.l	#$17918,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	adda.w	d0,a0
	movea.l	a1,a2
	adda.w	d1,a2
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	decompress
	movem.l	(a7)+,d0-d7/a0-a6
	movea.l	a2,a1
Laf6
	movea.l	(a7)+,a0
	clr.b	Lcb4
	tst.b	Lcb9
	bne.s	Lb08
	move.l	a1,(a0)
Lb08
	movea.l	#$17918,a1
	tst.b	L80c+2
	bne	Lb74
	lea	L58e,a0
	move.w	Lcb0,d0
	andi.w	#$ff,d0
	lsl.w	#2,d0
	cmpi.l	#$80000,(a0,d0.w)
	bcc.s	Lb74
	move.l	L8a4,d1
	beq.s	Lb74
	move.l	d1,(a0,d0.w)
	movea.l	d1,a0
	move.l	#$674,d0
Lb48
	move.l	(a1)+,(a0)+
	dbra	d0,Lb48
	move.l	a0,L8a4
	move.l	L8a8,d0
	subi.l	#$19d4,d0
	move.l	d0,L8a8
	cmpi.l	#$19d4,d0
	bge.s	Lb74
	clr.l	L8a4
Lb74
	movem.l	(a7)+,d2-d3/a1
	move.b	#$28,Lcb2
	bra.s	Lbca


Lb82
	cmpi.b	#$28,d0
	bne.s	Lbc8
	btst	#$6,$2(a6)
	bne.s	Lbca
	addq.b	#1,Lcb3
	move.b	#$1,Lcb2
	tst.b	Lcb5
	bpl.s	Lbb2
	clr.b	Lcb5
	clr.b	Lcb2
Lbb2
	move.w	Lcb0,d0
Lbb8
	addq.w	#1,d0
	cmpi.w	#$150,d0
	beq.s	Lbb8
	move.w	d0,Lcb0
	bra.s	Lbca


Lbc8
	nop
Lbca
	rts


	move.w	Lcb0,d0
	lsr.w	#1,d0
	move.w	Lcae,d1
	lsr.w	#1,d1
	sub.w	d1,d0
	beq.s	Lc20
	tst.w	d0
	bmi.s	Lbf0
	bclr	#$1,(a5)
	addq.w	#2,Lcae
	bra.s	Lbfa


Lbf0
	bset	#$1,(a5)
	subq.w	#2,Lcae
Lbfa
	bclr	#$0,(a5)
	nop
	nop
	bset	#$0,(a5)
	bsr	Lc96
	move.w	Lcb0,d0
	lsr.w	#1,d0
	move.w	Lcae,d1
	lsr.w	#1,d1
	sub.w	d1,d0
	beq.s	Lc20
	rts


Lc20
	move.w	Lcb0,d1
	move.w	d1,Lcae
	cmpi.w	#$151,d1
	beq.s	Lc40
	btst	#$0,d1
	beq.s	Lc40
	bset	#$2,(a5)
	moveq	#$0,d0
	rts


Lc40
	bclr	#$2,(a5)
	moveq	#$0,d0
	rts


Lc48
	move.w	L192e0,d0
	move.w	d0,d1
	andi.w	#$80,d0
	move.b	d0,Lcb5
	andi.w	#$70,d1
	lsr.w	#2,d1
	movea.l	#$c6a,a0
	adda.w	d1,a0
	rts


Lc6a
	dc.w	$0000,$0000,$0000,$0002,$fffe,$0000,$0000,$0000,$0000,$0002,$fffe,$0000,$0000,$0000,$0000,$0002
	dc.w	$fffe,$0000,$0000,$0000,$0002,$fffe


Lc96
	clr.b	Lcb8
	bset	#$0,$bfee01
Lca4
	tst.b	Lcb8
	beq.s	Lca4
	rts


Lcae
	dc.w	$0000
Lcb0
	dc.b	$00
Lcb1
	dc.b	$00
Lcb2
	dc.b	$00
Lcb3
	dc.b	$00
Lcb4
	dc.b	$00
Lcb5
	dc.b	$00
Lcb6
	dc.w	$0000
Lcb8
	dc.b	$00
Lcb9
	dc.b	$00

	dc.w	$0000


Lcbc
	move.w	#$8400,$dff096
	jsr	Lff52
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	moveq	#$4,d0
	jsr	L430
	movea.l	#$3feac,a0
	movea.l	#$1c764,a1
	movea.l	#$4749a,a2
	jsr	decompress
	movea.l	#$1c764,a0
	jsr	L1ad00
Ld32
	movea.l	#$400,a7
	move.l	#$7f448,L133a6
	jsr	L120a
	jsr	L124c
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	move.w	#$1,L1698
	move.w	#$1,L1ad30
	move.l	#$74000,L133a6
	jsr	L14ac4
	jsr	L14b9e
	move.l	#$6c9d2,L133a6
	move.w	#$1,L1698
	move.w	#$1,L1ad30
	jsr	L16784
	jsr	L16932
	move.l	#$64c70,L133a6
	jsr	L16a2
	jsr	Le9e
	jsr	L16a2
	move.l	#$17916,L133a6
	move.w	#$8400,$dff096
	jmp	Lf92


Ldf4
	move.l	#$76000,L133a6
	jsr	L15310
	jsr	L15404
	jmp	Ld32


Le10
	move.w	#$8400,$dff096
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	jsr	L1576c
	jsr	L15876
	tst.w	L161d0
	beq.s	Le74
	jsr	L161d2
	jsr	L162b8
Le74
	move.l	#$4e4a0,L133a6
	clr.w	L1698
	clr.w	L1ad30
	jsr	Le9e
	move.w	#$a,L169e
	jmp	Lf92


Le9e
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	tst.w	L1698
	bne	Lf04
	moveq	#$e,d0
	jsr	L430
	movea.l	#$42a04,a0
	movea.l	#$1ca00,a1
	movea.l	#$447c6,a2
	jsr	decompress
	move.l	#$44d76,L516
	move.l	#$44d76,L4136
	bra.s	Lf18


Lf04
	move.l	#$4749a,L516
	move.l	#$4749a,L4136
Lf18
	moveq	#$f,d0
	jsr	L430
	movea.l	L4136,a0
	adda.w	#$9dc,a0
	movea.l	L4136,a1
	movea.l	L4136,a2
	adda.w	#$19c8,a2
	jsr	decompress
	move.w	#$8400,$dff096
	jsr	L3070
	jsr	L3c8c
	jsr	L4ca4
	jsr	L4cf2
	jsr	L4e10
	jsr	L13b88
	jsr	Ld644
	jsr	Lfef8
	st	L169a
	move.w	#$2,Le124
	clr.w	L10876
	jmp	$24


Lf92
	jsr	Le988
	jsr	L13d9c
	move.w	L562e,Ledd2
	jsr	Le8c8
	jsr	Leace
	jsr	L706a
	jsr	L10410
	jsr	L11b30
	jsr	La26c
	jsr	L4dac
	jsr	L11db0
	jsr	L11dfc
	jsr	L127ae
	jsr	Le952
	jsr	L1ad42
	jsr	Ld6a4
	jsr	Ld922
	jsr	L13c38
	jsr	L727c
	jsr	L74cc
	jsr	L4e74
	jsr	Le902
	jsr	L95be
	jsr	L794a
	jsr	L7b74
	jsr	L9c12
	jsr	L4150
	jsr	L9eb0
	jsr	L878c
	jsr	L76f2
	jsr	Lceac
	jsr	L4fdc
	jsr	L7d92
	jsr	L80e2
	jsr	Lda40
	jsr	L10d2a
	jsr	L11414
	jsr	L94e8
	jsr	L5630
	jsr	L65c2
	jsr	L61ec
	jsr	L636c
	jsr	L7114
	jsr	L7178
	jsr	L4be6
	jsr	L176e
	tst.w	L1698
	beq.s	L10d2
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L10c0
	bra.s	L10c6


L10c0
	btst	#$6,d0
	bne.s	L10d2
L10c6
	jsr	L1ad06
	jmp	Le10


L10d2
	jsr	L3a3a
	cmpi.w	#$3,L103ea
	beq.s	L1122
	clr.w	d0
	tst.w	L103ea
	beq.s	L10f2
	move.w	L74a6,d0
L10f2
	or.w	L7256,d0
	tst.w	d0
	bne.s	L1144
	move.w	L103ea,d0
	tst.w	d0
	beq.s	L110c
	cmpi.w	#$2,d0
	beq.s	L1114
L110c
	move.w	L7264,d0
	bra.s	L111a


L1114
	move.w	L74b4,d0
L111a
	tst.w	d0
	bne.s	L1144
	bra	L11ac


L1122
	tst.w	L7256
	bne.s	L1144
	tst.w	L7264
	beq.s	L1144
	tst.w	L74b4
	beq.s	L1144
	tst.w	L8832
	bne.s	L1144
	bra.s	L11ac


L1144
	jsr	L1656
	tst.w	L1698
	bne	Lf92
	move.b	$bfec01,d0
	cmpi.b	#$75,d0
	bne	Lf92
	move.l	#$30303030,L37d0
	move.l	#$30303030,L37d4
	move.w	#$3030,L37d8
	move.l	#$30303030,L37dc
	move.l	#$30303030,L37e0
	move.w	#$3030,L37e4
	jsr	L1ad2a
	jsr	Ld644
	jmp	Lcbc


L11ac
	jsr	L1ad2a
	jsr	Ld644
	tst.w	L15f70
	beq.s	L11cc
	jsr	L15f72
	jsr	L1604e
L11cc
	jsr	L16784
	cmpi.w	#$1,d0
	beq.s	L11e4
	jsr	L16932
	jmp	Lcbc


L11e4
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L11f2
	bra.s	L11f8


L11f2
	btst	#$6,d0
	bne.s	L1204
L11f8
	jsr	L1ad06
	jmp	Le10


L1204
	jmp	Lcbc


L120a
	moveq	#$d,d0
	jsr	L430
	movea.l	#$5cfbe,a0
	movea.l	#$542da,a1
	movea.l	#$6111a,a2
	jsr	decompress
	move.l	#$f218,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	jmp	$24


L124c
	move.l	#$3f7a0,d6
L1252
	jsr	L1656
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L1266
	bra.s	L126c


L1266
	btst	#$6,d0
	bne.s	L1278
L126c
	jsr	L1ad06
	jmp	Le10


L1278
	subi.l	#$1,d6
	bne	L1252
	moveq	#$18,d0
	jsr	L430
	movea.l	#$4f7d2,a0
	movea.l	#$4749a,a1
	movea.l	#$542da,a2
	jsr	decompress
	move.l	#$f666,Le53e
	move.l	#$e128,$6c
	move.w	#$8030,$dff09a
	move.l	#$f640,Lfcf8
	jsr	Lfcfc
	move.w	#$18,Le534
	jsr	Le888
	clr.w	L13da
	move.w	#$2,L13dc
	moveq	#$19,d0
	jsr	L430
	movea.l	#$6a29a,a0
	movea.l	#$542da,a1
	movea.l	#$7aa7a,a2
	jsr	decompress
L130a
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L1318
	bra.s	L131e


L1318
	btst	#$6,d0
	bne.s	L132a
L131e
	jsr	L1ad06
	jmp	Le10


L132a
	jsr	Lea8a
	jsr	L13de
	jsr	L1656
	cmpi.w	#$19,L13da
	beq.s	L1348
	bra.s	L130a


L1348
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$0,$dff180
	jmp	$24


L136c
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	#$741a2,d1
	move.l	Le536,d0
	addi.l	#$2c0,d0
	moveq	#$4,d7
L13aa
	jsr	Leaae
	move.l	d1,$dff050
	move.l	d0,$dff054
	move.w	#$1e96,$dff058
	addi.l	#$14f8,d1
	addi.l	#$2940,d0
	dbra	d7,L13aa
	rts


	dc.w	$0000,$0846
L13da
	dc.w	$0000
L13dc
	dc.w	$0002


L13de
	jsr	L136c
	subq.w	#1,L13dc
	tst.w	L13dc
	bpl.s	L140c
	move.w	#$2,L13dc
	cmpi.w	#$19,L13da
	beq	L14c0
	addq.w	#1,L13da
L140c
	move.w	L13da,d0
	mulu.w	#$10,d0
	addi.l	#$14c6,d0
	movea.l	d0,a0
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$160,L1338a
	move.w	#$f0,L1338c
	move.w	#$0,L13396
	move.w	#$10,L13398
	move.w	L13da,d0
	move.w	L13da,d1
	mulu.w	#$b,d0
	mulu.w	#$4,d1
	add.w	d0,L13396
	add.w	d1,L13398
	move.w	$2(a0),L1339a
	move.w	$6(a0),L1339c
	move.l	$8(a0),L1339e
	move.l	$c(a0),L1338e
	move.w	#$1,L133a4
	jsr	L133b4
L14c0
	rts


	dc.w	$0000,$0846,$0000,$00d0,$0000,$0062,$0000,$09f4,$0006,$111a,$0000,$00c0,$0000,$005a,$0000,$0870
	dc.w	$0006,$42de,$0000,$00b0,$0000,$0052,$0000,$070c,$0006,$6d0e,$0000,$00a0,$0000,$004b,$0000,$05dc
	dc.w	$0006,$904a,$0000,$0090,$0000,$0045,$0000,$04da,$0006,$ad96,$0000,$0080,$0000,$003f,$0000,$03f0
	dc.w	$0006,$c5d8,$0000,$0080,$0000,$003a,$0000,$03a0,$0006,$d988,$0000,$0070,$0000,$0035,$0000,$02e6
	dc.w	$0006,$eba8,$0000,$0070,$0000,$0031,$0000,$02ae,$0006,$fa26,$0000,$0060,$0000,$002d,$0000,$021c
	dc.w	$0007,$078c,$0000,$0060,$0000,$0028,$0000,$01e0,$0007,$1218,$0000,$0050,$0000,$0025,$0000,$0172
	dc.w	$0007,$1b78,$0000,$0050,$0000,$0022,$0000,$0154,$0007,$22b2,$0000,$0040,$0000,$001f,$0000,$00f8
	dc.w	$0007,$2956,$0000,$0040,$0000,$001d,$0000,$00e8,$0007,$2e2e,$0000,$0040,$0000,$001a,$0000,$00d0
	dc.w	$0007,$32b6,$0000,$0030,$0000,$0018,$0000,$0090,$0007,$36c6,$0000,$0030,$0000,$0014,$0000,$0078
	dc.w	$0007,$3996,$0000,$0030,$0000,$0010,$0000,$0060,$0007,$3bee,$0000,$0020,$0000,$000e,$0000,$0038
	dc.w	$0007,$3dce,$0000,$0020,$0000,$000b,$0000,$002c,$0007,$3ee6,$0000,$0020,$0000,$000a,$0000,$0028
	dc.w	$0007,$3fc2,$0000,$0020,$0000,$0008,$0000,$0020,$0007,$408a,$0000,$0010,$0000,$0007,$0000,$000e
	dc.w	$0007,$412a,$0000,$0010,$0000,$0005,$0000,$000a,$0007,$4170


L1656
	move.w	Le124,d1
	move.b	$bfec01,d0
	cmpi.b	#-$33,d0
	bne.s	L168c
L1668
	move.b	$bfec01,d0
	cmpi.b	#-$33,d0
	beq.s	L1668
L1674
	move.b	$bfec01,d0
	cmpi.b	#-$33,d0
	bne.s	L1674
L1680
	move.b	$bfec01,d0
	cmpi.b	#-$33,d0
	beq.s	L1680
L168c
	move.w	d1,Le124
	rts


	dc.w	$0000,$0846
L1698
	dc.w	$0000
L169a
	dc.w	$0000
L169c
	dc.w	$0000
L169e
	dc.w	$0000
L16a0
	dc.w	$0001


L16a2
	clr.w	L103ea
	clr.w	L76f0
	move.w	#$1,Le0ec
	move.l	#$64c70,L37ca
	move.l	#$64c70,L37c6
	move.l	#$64c70,L4c6
	move.l	#$64c70,L4ce
	clr.w	L169a
	move.w	#$1,L197c
	move.l	#$1936,L1978
	clr.w	L16a0
	move.w	#$1,L1698
	move.w	#$1,L1ad30
	clr.w	L169c
	clr.w	L9fd4
	clr.w	L9fd6
	move.w	#$a,L7264
	move.w	#$a,L74b4
	clr.w	L7266
	clr.w	L74b6
	clr.w	L103ea
	clr.w	L169e
	jsr	L1758
	jsr	L109ca
	rts


	dc.w	$0000,$0846


L1758
	movea.l	#$4749a,a0
	move.w	#$20a7,d0
L1762
	clr.l	(a0)+
	dbra	d0,L1762
	rts


	dc.w	$0000,$08a0


L176e
	tst.w	L1698
	beq	L18f6
	jsr	L2f58
	addq.w	#1,L169c
	cmpi.w	#$49e,L169c
	bne.s	L1794
	jsr	Lec8c
L1794
	cmpi.w	#$4b0,L169c
	bne.s	L17ae
	jsr	Lec24
	move.l	#$8000,Leac8
L17ae
	cmpi.w	#$7df,L169c
	bne.s	L17be
	jsr	L18fe
L17be
	tst.l	L1b9e
	beq	L18be
	movea.l	L1b9e,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L17de
	clr.w	$a00(a0)
L17de
	tst.l	L1ba2
	beq	L17fe
	movea.l	L1ba2,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L17fe
	clr.w	$a00(a0)
L17fe
	tst.l	L1ba6
	beq	L181e
	movea.l	L1ba6,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L181e
	clr.w	$a00(a0)
L181e
	tst.l	L1baa
	beq	L183e
	movea.l	L1baa,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L183e
	clr.w	$a00(a0)
L183e
	tst.l	L1bae
	beq	L185e
	movea.l	L1bae,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L185e
	clr.w	$a00(a0)
L185e
	tst.l	L1bb2
	beq	L187e
	movea.l	L1bb2,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L187e
	clr.w	$a00(a0)
L187e
	tst.l	L1bb6
	beq	L189e
	movea.l	L1bb6,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L189e
	clr.w	$a00(a0)
L189e
	tst.l	L1bba
	beq	L18be
	movea.l	L1bba,a0
	addq.b	#1,$a01(a0)
	cmpi.b	#$5,$a01(a0)
	bcs.s	L18be
	clr.w	$a00(a0)
L18be
	movea.l	L1978,a0
	move.w	L169c,d0
	cmp.w	(a0),d0
	bne.s	L18f6
	addq.l	#2,L1978
	movea.l	L1978,a0
	cmpi.w	#-$1,(a0)
	beq.s	L18f8
	eori.w	#$1,L197c
	tst.w	L197c
	beq	L199e
	bra	L197e


L18f6
	rts


L18f8
	jmp	Ldf4


L18fe
	movea.l	#$bb40,a0
	moveq	#$7f,d7
L1906
	cmpi.b	#$5,$603(a0)
	bne.s	L192a
	move.l	a0,-(a7)
	jsr	L11bdc
	movea.l	(a7)+,a0
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	clr.l	(a0)
	jsr	L11604
	rts


L192a
	subq.l	#4,a0
	dbra	d7,L1906
	rts


	dc.w	$0000,$08a0,$0005,$0096,$009b,$0140,$0145,$0195,$019a,$0226,$022b,$02b2,$02b7,$035c,$0366,$0406
	dc.w	$040b,$04a6,$04b0,$055a,$055f,$0609,$060e,$06b8,$06bd,$0767,$076c,$07b2,$07b7,$0861,$0866,$091a
	dc.w	$091f,$09c9,$ffff
L1978
	dc.w	$0000,$1936
L197c
	dc.w	$0001


L197e
	jsr	L1758
	jsr	L109ca
	clr.w	L648a
	clr.w	L5532
	clr.w	L4f7a
	rts


L199e
	tst.w	L169e
	beq	L1bbe
	cmpi.w	#$1,L169e
	beq	L1c1a
	cmpi.w	#$2,L169e
	beq	L1da8
	cmpi.w	#$3,L169e
	beq	L1c78
	cmpi.w	#$4,L169e
	beq	L1ce8
	cmpi.w	#$5,L169e
	beq	L1d6a
	cmpi.w	#$6,L169e
	beq	L1df6
	cmpi.w	#$7,L169e
	beq	L1e1a
	cmpi.w	#$8,L169e
	beq	L1ec8
	cmpi.w	#$9,L169e
	beq	L1f48
	cmpi.w	#$a,L169e
	beq	L1fac
	cmpi.w	#$b,L169e
	beq	L1ff4
	cmpi.w	#$c,L169e
	beq	L2054
	cmpi.w	#$d,L169e
	beq	L20b8
	cmpi.w	#$e,L169e
	beq	L2102
	cmpi.w	#$f,L169e
	beq	L2160
	rts


L1a5e
	clr.w	L1b10
	clr.l	L1b9e
	clr.l	L1ba2
	clr.l	L1ba6
	clr.l	L1baa
	clr.l	L1bae
	clr.l	L1bb2
	clr.l	L1bb6
	clr.l	L1bba
	clr.l	L1b10
L1a9a
	move.l	(a0)+,d0
	beq.s	L1b04
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	clr.l	d3
	clr.l	d6
	move.l	a0,-(a7)
	jsr	Lb8ca
	cmpi.b	#$10,$603(a0)
	beq.s	L1b14
	cmpi.b	#$11,$603(a0)
	beq.s	L1b26
	cmpi.b	#$12,$603(a0)
	beq.s	L1b38
	cmpi.b	#$13,$603(a0)
	beq	L1b4a
	cmpi.b	#$14,$603(a0)
	beq	L1b5c
	cmpi.b	#$15,$603(a0)
	beq	L1b6e
	cmpi.b	#$16,$603(a0)
	beq	L1b80
	cmpi.b	#$17,$603(a0)
	beq	L1b94
	cmpi.b	#$c,$603(a0)
	beq.s	L1b26
L1b00
	movea.l	(a7)+,a0
	bra.s	L1a9a


L1b04
	lea	$24+$1812,a6
	pea	-$1812(a6)
	rts


L1b10
	dc.w	$0000,$0000


L1b14
	tst.l	L1b9e
	bne	L1b26
	move.l	a0,L1b9e
	bra.s	L1b00


L1b26
	tst.l	L1ba2
	bne	L1b38
	move.l	a0,L1ba2
	bra.s	L1b00


L1b38
	tst.l	L1ba6
	bne	L1b4a
	move.l	a0,L1ba6
	bra.s	L1b00


L1b4a
	tst.l	L1baa
	bne	L1b5c
	move.l	a0,L1baa
	bra.s	L1b00


L1b5c
	tst.l	L1bae
	bne	L1b6e
	move.l	a0,L1bae
	bra.s	L1b00


L1b6e
	tst.l	L1bb2
	bne	L1b80
	move.l	a0,L1bb2
	bra.s	L1b00


L1b80
	tst.l	L1bb6
	bne	L1b94
	move.l	a0,L1bb6
	bra	L1b00


L1b94
	move.l	a0,L1bba
	bra	L1b00


L1b9e
	dc.w	$0000,$0000
L1ba2
	dc.w	$0000,$0000
L1ba6
	dc.w	$0000,$0000
L1baa
	dc.w	$0000,$0000
L1bae
	dc.w	$0000,$0000
L1bb2
	dc.w	$0000,$0000
L1bb6
	dc.w	$0000,$0000
L1bba
	dc.w	$0000,$0000


L1bbe
	jsr	L1758
	clr.w	Lb8c8
	movea.l	#$21a4,a0
	jsr	L1a5e
	addq.w	#1,L169e
	move.w	#$1,Lb8c8
	movea.l	#$4749a,a0
	movea.l	#$25b0,a1
	moveq	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	movea.l	#$4749a,a0
	movea.l	#$2649,a1
	moveq	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	rts


L1c1a
	clr.w	Lb8c8
	movea.l	#$2250,a0
	jsr	L1a5e
	addq.w	#1,L169e
	move.w	#$1,Lb8c8
	movea.l	#$4749a,a0
	movea.l	#$26c8,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	movea.l	#$4749a,a0
	movea.l	#$2760,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	rts


	dc.w	$0000,$08a0


L1c78
	moveq	#$5,d0
	jsr	L430
	movea.l	L37ca,a0
	adda.w	#$1400,a0
	movea.l	L37ca,a1
	movea.l	L37ca,a2
	adda.w	#$318c,a2
	jsr	decompress
	jsr	L64fc
	move.w	#$18,L648c
	st	L649a
	move.w	#$7a,L64aa
	move.w	#$40,L64ba
	movea.l	#$4749a,a0
	movea.l	#$27df,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	addq.w	#1,L169e
	rts


L1ce8
	moveq	#$6,d0
	jsr	L430
	movea.l	L37c6,a0
	adda.w	#$3904,a0
	movea.l	L37c6,a1
	movea.l	L37c6,a2
	adda.w	#$7d62,a2
	jsr	decompress
	jsr	L55c6
	move.w	#$d,L5534
	st	L5564
	move.w	#$7a,L5574
	move.w	#$40,L5584
	move.w	#$204,L55a4
	move.l	#$5548,L5544
	movea.l	#$4749a,a0
	movea.l	#$28d7,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	addq.w	#1,L169e
	rts


L1d6a
	clr.w	Lb8c8
	movea.l	#$2308,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	movea.l	#$4749a,a0
	movea.l	#$298f,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	addq.w	#1,L169e
	rts


L1da8
	addq.w	#1,L169e
	movea.l	#$4749a,a0
	movea.l	#$2bac,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	move.w	#$93,L4f7c
	move.w	#$50,L4f7e
	move.w	#$1,L4f7a
	clr.w	L4f86
	move.w	#$a,L4f88
	rts


	dc.w	$0000,$08a0


L1df6
	addq.w	#1,L169e
	movea.l	#$4749a,a0
	movea.l	#$2c05,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	rts


L1e1a
	addq.w	#1,L169e
	movea.l	#$4749a,a0
	movea.l	#$2db9,a1
	move.w	#$2c,d1
	move.l	#$1a20,d3
	jsr	L137ce
	move.l	#$1a20,L13382
	move.w	#$160,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$160,L1338a
	move.w	#$98,L1338c
	move.l	#$4749a,L1337a
	move.l	#$6fbb6,L1338e
	move.w	#$ca,L13396
	move.w	#$37,L13398
	move.w	#$30,L1339a
	move.w	#$4,L1339c
	move.l	#$18,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	rts


	dc.w	$0000,$08a0


L1ec8
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	moveq	#$10,d0
	jsr	L430
	movea.l	#$483ca,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	addi.w	#$2f6,L7268
	addi.w	#$2f6,L74b8
	addi.w	#$2f6,Le0ea
	movea.l	#$2348,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	rts


L1f48
	moveq	#$11,d0
	jsr	L430
	movea.l	#$47f9e,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	subi.w	#$c8,L7268
	subi.w	#$c8,L74b8
	subi.w	#$c8,Le0ea
	movea.l	#$2364,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	jsr	Lec5a
	rts


	dc.w	$0000,$08a0


L1fac
	moveq	#$12,d0
	jsr	L430
	movea.l	#$48b9a,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	movea.l	#$2380,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	jsr	Lec24
	rts


L1ff4
	moveq	#$13,d0
	jsr	L430
	movea.l	#$482e6,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	addi.w	#$145,L7268
	addi.w	#$145,L74b8
	addi.w	#$145,Le0ea
	clr.w	Lb8c8
	movea.l	#$23e4,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	jsr	Lecbe
	rts


L2054
	moveq	#$14,d0
	jsr	L430
	movea.l	#$47c2e,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	subi.w	#$145,L7268
	subi.w	#$145,L74b8
	subi.w	#$145,Le0ea
	movea.l	#$2460,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	jsr	Lec24
	rts


	dc.w	$0000,$08a0


L20b8
	moveq	#$15,d0
	jsr	L430
	movea.l	#$47c26,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	move.w	#$1,L21a2
	jsr	L11c32
	move.w	#$2,L21a2
	jsr	L11c32
	clr.w	L21a2
	rts


L2102
	moveq	#$16,d0
	jsr	L430
	movea.l	#$48012,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	movea.l	#$2470,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	movea.l	#$b984,a0
	move.l	#$3480000,$200(a0)
	move.l	#$500000,$400(a0)
	jsr	L11366
	rts


L2160
	moveq	#$17,d0
	jsr	L430
	movea.l	Lc6a,a0
	movea.l	#$4749a,a1
	movea.l	#$4eb5a,a2
	jsr	decompress
	addq.w	#1,L169e
	clr.w	Lb8c8
	movea.l	#$24ec,a0
	jsr	L1a5e
	move.w	#$1,Lb8c8
	rts


L21a2
	dc.w	$0000,$001f,$0000,$0021,$0000,$0000,$0008,$001f,$0000,$0031,$0000,$0000,$0001,$001b,$0000,$0041
	dc.w	$0000,$0000,$0005,$001b,$0000,$0051,$0000,$0000,$0006,$001f,$0000,$0061,$0000,$0000,$0009,$001f
	dc.w	$0000,$0071,$0000,$0000,$000a,$001f,$0000,$0081,$0000,$0000,$000b,$00b9,$0000,$0021,$0000,$0000
	dc.w	$0002,$00b9,$0000,$0031,$0000,$0000,$0003,$00b9,$0000,$0041,$0000,$0000,$001c,$00b9,$0000,$0051
	dc.w	$0000,$0000,$001d,$00b5,$0000,$0061,$0000,$0000,$001e,$00ba,$0000,$0071,$0000,$0000,$0007,$00b9
	dc.w	$0000,$0082,$0000,$0000,$000d,$0000,$0000,$001f,$0000,$0021,$0000,$0000,$001b,$0020,$0000,$0031
	dc.w	$0000,$0000,$001f,$0020,$0000,$0041,$0000,$0000,$0021,$0020,$0000,$004f,$0000,$0000,$0022,$0020
	dc.w	$0000,$0057,$0000,$0000,$0023,$0020,$0000,$0061,$0000,$0000,$0024,$001c,$0000,$0071,$0000,$0000
	dc.w	$0025,$0020,$0000,$0081,$0000,$0000,$0027,$00b9,$0000,$0021,$0000,$0000,$002c,$00b5,$0000,$0032
	dc.w	$0000,$0000,$002d,$00b9,$0000,$0041,$0000,$0000,$002e,$00b9,$0000,$0051,$0000,$0000,$0010,$00ba
	dc.w	$0000,$0061,$0000,$0000,$000c,$00b9,$0000,$0071,$0000,$0000,$0020,$00b8,$0000,$0081,$0000,$0000
	dc.w	$0029,$0000,$0000,$0020,$0000,$0012,$0000,$0000,$0018,$0020,$0000,$0027,$0000,$0000,$001a,$0020
	dc.w	$0000,$003c,$0000,$0000,$002f,$0020,$0000,$0051,$0000,$0000,$0019,$0020,$0000,$0074,$0000,$0000
	dc.w	$002a,$0000,$0000,$0338,$0000,$002e,$0000,$0000,$0010,$0401,$0000,$004b,$0000,$0000,$0011,$0000
	dc.w	$0000,$02c4,$0000,$003f,$0000,$0000,$0010,$0306,$0000,$0064,$0000,$0000,$0011,$0000,$0000,$028d
	dc.w	$0000,$001e,$0000,$0000,$0010,$02ff,$0000,$0053,$0000,$0000,$0011,$0317,$0000,$005b,$0000,$0000
	dc.w	$0012,$02d6,$0000,$0016,$0000,$0000,$0008,$0293,$0000,$003e,$0000,$0000,$0008,$029a,$0000,$004b
	dc.w	$0000,$0000,$0008,$029f,$0000,$005b,$0000,$0000,$0001,$02ad,$0000,$0063,$0000,$0000,$000c,$0000
	dc.w	$0000,$03ec,$0000,$0018,$0000,$0000,$0010,$0487,$0000,$0048,$0000,$0000,$0011,$03f0,$0000,$007f
	dc.w	$0000,$0000,$0001,$038f,$0000,$0086,$0000,$0000,$0001,$03b9,$0000,$0078,$0000,$0000,$0001,$0409
	dc.w	$0000,$0078,$0000,$0000,$0001,$036f,$0000,$006f,$0000,$0000,$0001,$03c3,$0000,$008e,$0000,$0000
	dc.w	$0001,$03b3,$0000,$008a,$0000,$0000,$0001,$040f,$0000,$0088,$0000,$0000,$0001,$0000,$0000,$028e
	dc.w	$0000,$0040,$0000,$0000,$0001,$0000,$0000,$0248,$0000,$002c,$0000,$0000,$001b,$0248,$0000,$0040
	dc.w	$0000,$0000,$0002,$0248,$0000,$0054,$0000,$0000,$001c,$0248,$0000,$0068,$0000,$0000,$0007,$0248
	dc.w	$0000,$007a,$0000,$0000,$0027,$0338,$0000,$0040,$0000,$0000,$0003,$0340,$0000,$0040,$0000,$0000
	dc.w	$0003,$0348,$0000,$0040,$0000,$0000,$0003,$0350,$0000,$0040,$0000,$0000,$0003,$0333,$0000,$007a
	dc.w	$0000,$0000,$0008,$0000,$0000,$028c,$0000,$003e,$0000,$0000,$0010,$0294,$0000,$003e,$0000,$0000
	dc.w	$0011,$029c,$0000,$003e,$0000,$0000,$0012,$02a4,$0000,$003e,$0000,$0000,$0013,$02ac,$0000,$003e
	dc.w	$0000,$0000,$0014,$02b4,$0000,$003e,$0000,$0000,$0015,$02bc,$0000,$003e,$0000,$0000,$0016,$02c4
	dc.w	$0000,$003e,$0000,$0000,$0017,$02e1,$0000,$003e,$0000,$0000,$0020,$02ac,$0000,$0050,$0000,$0000
	dc.w	$0020,$02b4,$0000,$0050,$0000,$0000,$0020,$02bc,$0000,$0050,$0000,$0000,$0020,$02c4,$0000,$0050
	dc.w	$0000,$0000,$0020,$02e1,$0000,$0051,$0000,$0000,$002a,$02c4,$0000,$0072,$0000,$0000,$0020,$02e1
	dc.w	$0000,$0072,$0000,$0000,$0029,$0000,$0000


	dc.b	$0d,'w',$0c,$02,'d a t a s c o r e s',$0d,'?',$15,$03,'lander ',$01,'50 pts',$0d,'?',$0f,$02,'crazy ',$01,'150 pts',$0d,'?',$0f,$04,'t'
	dc.b	'ornado ',$01,'500 pts',$0d,'?',$0e,$04,'blitter ',$01,'75 pts',$0d,'?',$0f,$05,'mutant',$01,' 75 pts',$0d,'?',$0f,$05,'mutant',$01,' '
	dc.b	'75 pts',$0d,'?',$0f,$05,'mutant',$01,' 75 pts',$00,$0d,$d4,'"',$03,'gravitron',$01,' 100 pts',$0d,$d4,$0f,$03,'pulsar',$01,' 50 pt'
	dc.b	's',$0d,$d4,$0f,$04,'saturn',$01,' 200 pts',$0d,$d4,$0f,$04,'drone',$01,' 50 pts',$0d,$d4,$0f,$02,'baiter',$01,' 200 pts',$0d,$d4,$0f,$03,'egg',$01
	dc.b	' 50 pts',$0d,$d4,$0f,$05,'wall',$01,' 25 pts',$00,$0d,'w',$0c,$02,'d a t a s c o r e s',$0d,'?',$15,$02,'bipod',$01,' 100 pt'
	dc.b	's',$0d,'?',$0f,$03,'spiker',$01,' 100 pts',$0d,'?',$0f,$03,'twirler',$01,' 50 pts',$0d,'?',$0f,$04,'rocket',$01,' 50 pts',$0d,'?',$0f,$04,'bla'
	dc.b	'st',$01,' 50 pts',$0d,'?',$0f,$02,'tanker',$01,' 250 pts',$0d,'?',$0f,$03,'bomber',$01,' 75 pts',$00,$0d,$d4,'"',$02,'hunter',$01,' 100 '
	dc.b	'pts',$0d,$d4,$0f,$05,'fireball',$01,' 10 pts',$0d,$d4,$0f,$05,'mc squid',$01,' 10 pts',$0d,$d4,$0f,$04,'pod',$01,' 1/2/4/800 pt'
	dc.b	's',$0d,$d4,$0f,$04,'traitor',$01,' 100 pts',$0d,$d4,$0f,$03,'man',$0d,$d4,$0f,$03,'zomboid',$01,' ? pts',$00,$0d,'w',$05,$02,'d a t a s c o'
	dc.b	' r e s',$0d,$82,$14,$02,'space squid',$01,' 1500 pts',$0d,$82,$08,$05,'(',$04,'needs multiple hits',$05,')',$0d,$a0,$1d,$03,'sm'
	dc.b	'all squid ',$0d,$a0,$08,$05,'(',$04,'cannot be destroyed',$05,')',$0d,$82,' ',$02,'tentacle ',$01,'25 pts',$0d,$82,$08,$05,'(',$04,'s'
	dc.b	'hoot off lowest tentacles first,',$0d,$82,$07,' need 3 hits each',$05,')',$0d,'(',$13,$02,'smartb'
	dc.b	'omb ',$04,'has limited effect on space squid',$00,$0d,'w',$05,$02,'d a t a s c o r e s',$0d,$82
	dc.b	$14,$02,'intergalactic space skull',$01,' 2500 pts',$0d,$82,$08,$05,'(',$04,'needs multiple hits',$05,')'
	dc.b	$0d,$a9,'#',$03,'small skull ',$0d,$a9,$08,$05,'(',$04,'cannot be destroyed',$05,')',$0d,$8c,$1d,$02,'smartbomb ',$04,'has li'
	dc.b	'mited effect',$0d,$aa,$07,' on space skull',$00,$0d,$91,$03,$02,'p o w e r s',$0d,'?',$0e,$03,'lazer ',$01,'arms yo'
	dc.b	'ur ship with additional lazer',$0d,'c',$06,'guns that fire simultaneously',$0d,'?',$0d
	dc.b	$03,'autofire ',$01,'will help you fire lazers very',$0d,'u',$06,'rapidly, lasts for 5'
	dc.b	'00 shots',$0d,'?',$0d,$03,'supershield ',$01,'while active will allow you',$0d,$87,$06,'to de-res'
	dc.b	' anything you fly into',$0d,'?',$0d,$03,'missile ',$01,'automaticly launches when a l'
	dc.b	'ander',$0d,'o',$06,'threatens a pod. the missile will',$0d,'Q',$06,$05,'{',$01,'    track down th'
	dc.b	'e lander and destroy it,',$0d,'o',$06,'rescueing the pod',$0d,'?',$0d,$03,'warp ',$01,'will warp '
	dc.b	'you to the next level,',$0d,']',$06,'giving you points for all invaders from'
	dc.b	$0d,']',$06,'the current level',$0d,'?',$0d,$04,'collect powers by flying into them!',$00,$0d,'w',$0c,$02
	dc.b	'd a t a s c o r e s',$0d,$87,'2',$03,'u.f.o. ',$01,'500 pts',$0d,'d1',$02,'smartbomb ',$04,'has limited'
	dc.b	' effect',$0d,$93,$07,' on u.f.o.',$00,$0d,'k',$0c,$04,'i n s t r u c t i o n s',$0d,'"',$14,$01,'using the jo'
	dc.b	'ystick you are able to control your',$0d,'"',$09,$01,'ship in any of 8 directio'
	dc.b	'ns, and fly anywhere',$0d,'"',$09,$01,'over the surface of the planet.',$0d,'"',$10,$03,'press'
	dc.b	'ing the firebutton rapidly will fire a',$0d,'"',$09,$03,'stream of lazers again'
	dc.b	'st invading forces.',$0d,'"',$10,$04,'holding down the firebutton for a moment '
	dc.b	'(or by',$0d,'"',$09,$04,'hitting any key) will launch a smartbomb ',$02,'{',$04,',',$0d,'"',$09,'which '
	dc.b	'will destroy all but the most resilient',$0d,'"',$09,$04,'invaders on the visib'
	dc.b	'le area.',$00,$0d,'k',$0c,$04,'i n s t r u c t i o n s',$0d,'"',$14,$01,'by pressing the spacebar'
	dc.b	' you can activate, and',$0d,'"',$09,$01,'deactivate your shield. ',$04,'be sure to ke'
	dc.b	'ep an eye',$0d,'"',$09,$04,'on your shield energy level        ',$03,'shield will',$0d,'"',$09,'r'
	dc.b	'efill by 50% at the end of each level.',$0d,'"',$0f,$05,'extra ship + extra sma'
	dc.b	'rtbomb ',$04,'at every 10000',$0d,'"',$12,$02,'p   = pause/unpause any screen',$0d,'"',$0c,$02,'esc '
	dc.b	'= quit game',$0d,'"',$12,$03,'hold down firebutton at ',$02,'game over',$03,' or after',$0d,'"',$09,$03,'e'
	dc.b	'ntering your highscore to restart game!',$00


L2f58
	cmpi.w	#$9,L169e
	bcc	L2fec
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$10,L13386
	clr.w	L13388
	move.w	#$160,L1338a
	move.w	#$98,L1338c
	move.l	#$4749a,L1338e
	move.w	#$10,L13396
	clr.w	L13398
	move.w	#$160,L1339a
	move.w	#$98,L1339c
	move.l	#$1a20,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	rts


	dc.w	$0000,$08f2


L2fec
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$20,L13386
	clr.w	L13388
	move.w	#$140,L1338a
	move.w	#$98,L1338c
	move.l	#$4749a,L1338e
	move.w	#$20,L13396
	clr.w	L13398
	move.w	#$140,L1339a
	move.w	#$98,L1339c
	move.l	#$17c0,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	rts


L3070
	clr.l	L76ec
	clr.w	Le534
	move.w	#$1388,L10d1e
	clr.l	L4bce
	clr.l	L4140
	clr.l	L4144
	clr.l	L4148
	clr.l	L414c
	clr.w	Le0ea
	move.w	#$ffff,L16a0
	move.l	#$ed62,Le53e
	move.l	#$ef3a,Le542
	clr.w	Le534
	jsr	Le6e8
	move.w	#$5,L10d24
	move.w	#$9,L10d26
	move.w	#$4,L10d28
	clr.w	L138de
	movea.l	#$4f73a,a0
	movea.l	#$57fca,a1
	move.l	#$96ef,d0
L3100
	clr.b	(a0)+
	clr.b	(a1)+
	dbra	d0,L3100
	movea.l	#$6085a,a0
	movea.l	#$6251a,a1
	move.l	#$1cbf,d0
L311a
	clr.b	(a0)+
	clr.b	(a1)+
	dbra	d0,L311a
	movea.l	#$648b0,a0
	movea.l	#$649a0,a1
	movea.l	#$64a90,a2
	movea.l	#$64b80,a3
	move.l	#$ef,d0
L3140
	clr.b	(a0)+
	clr.b	(a1)+
	clr.b	(a2)+
	clr.b	(a3)+
	dbra	d0,L3140
	moveq	#$1,d0
	movea.l	#$6085a,a0
L3154
	movem.l	d0/a0,-(a7)
	move.l	a0,L1337a
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$a8,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$20,L1338c
	move.l	#$6ee00,L1338e
	move.w	#$5e,L13396
	move.w	#$0,L13398
	move.w	#$d0,L1339a
	move.w	#$1b,L1339c
	move.l	#$2be,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	movem.l	(a7)+,d0/a0
	adda.l	#$1cc0,a0
	dbra	d0,L3154
	moveq	#$1,d0
	movea.l	#$648b0,a0
L31f0
	movem.l	d0/a0,-(a7)
	move.l	a0,L1337a
	move.l	#$30,L13382
	move.w	#$40,L1337e
	move.w	#$6,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$40,L1338a
	move.w	#$6,L1338c
	move.l	#$6ee00,L1338e
	move.w	#$3e,L13396
	move.w	#$fff7,L13398
	move.w	#$d0,L1339a
	move.w	#$1b,L1339c
	move.l	#$2be,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	movem.l	(a7)+,d0/a0
	adda.w	#$1e0,a0
	dbra	d0,L31f0
	moveq	#$1,d0
	movea.l	#$649a0,a0
L328a
	movem.l	d0/a0,-(a7)
	move.l	a0,L1337a
	move.l	#$30,L13382
	move.w	#$40,L1337e
	move.w	#$6,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$40,L1338a
	move.w	#$6,L1338c
	move.l	#$6ee00,L1338e
	move.w	#$ff3e,L13396
	move.w	#$fff7,L13398
	move.w	#$d0,L1339a
	move.w	#$1b,L1339c
	move.l	#$2be,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	movem.l	(a7)+,d0/a0
	adda.w	#$1e0,a0
	dbra	d0,L328a
	clr.w	L4bb4
	clr.w	L4bb6
	clr.w	L4bb8
	jsr	L4e10
	jsr	L381e
	move.w	#$aaf6,d1
	jsr	L1ad48
	move.l	#$e128,$6c
	move.l	#$ed3c,Lfcf8
	jsr	Lfcfc
	move.w	#$8030,$dff09a
	jsr	L1ad12
L336c
	move.b	$dff006,d0
	cmpi.b	#-$10,d0
	bne.s	L336c
	move.b	Le162,d1
L337e
	move.b	$dff006,d0
	cmpi.b	#$30,d0
	bne.s	L337e
	moveq	#$1,d0
	cmp.b	Le162,d1
	nop
	moveq	#$2,d0
	move.w	d0,L10aa4
	move.l	#$2,d0
	jsr	L1ad18
	move.w	#$0,L10aa2
	move.w	#$fa,L10d20
	move.w	#$3,L10d22
	move.w	#$0,L103ec
	move.w	#$0,L4b7a
	move.w	#$0,L4b78
	st	L103f6
	clr.w	L7d8e
	clr.w	L7d90
	jsr	L5f64
	clr.b	Lfde4
	move.w	#$ffff,L11d7c
	move.w	#$ffff,L11de6
	move.w	#$1,L11640
	clr.w	L11b2c
	clr.w	L10aa8
	move.w	#$1e,L116ac
	move.l	#$37d0,L166c4
	clr.w	L11554
	clr.w	L11602
	move.w	#$4,L114f0
	move.w	#$64,L11b2e
	clr.w	L4b90
	clr.w	L11c2c
	clr.w	L4f7a
	clr.w	L5532
	clr.w	L5f7c
	clr.w	L6300
	clr.w	L648a
	move.l	#$30303030,L37d0
	move.l	#$30303030,L37d4
	move.w	#$3030,L37d8
	move.l	#$30303030,L37dc
	move.l	#$30303030,L37e0
	move.w	#$3030,L37e4
	move.w	#$3030,L7068
	move.w	#$9,L3808
	clr.w	L380a
	clr.w	L381c
	move.w	#$1e,L413a
	clr.w	L4bb4
	clr.w	L4bb6
	clr.w	L4bb8
	move.w	#$1,L11706
	clr.l	Le248
	clr.l	Le24c
	clr.w	Lee62
	clr.w	Ledca
	move.w	#$4,L7256
	move.w	#$3,L7258
	clr.w	L725a
	move.w	#$21,L725c
	clr.w	L725e
	clr.w	L7260
	clr.w	L7262
	clr.w	L7264
	move.l	#$a00000,L7268
	move.l	#$0,L726c
	clr.l	L7270
	clr.l	L7274
	move.w	#$1,L9bf0
	clr.w	L9bf4
	clr.w	L727a
	move.w	#$5,L74a6
	move.w	#$3,L74a8
	clr.w	L74aa
	move.w	#$21,L74ac
	clr.w	L74ae
	clr.w	L74b0
	clr.w	L74b2
	move.l	#$a00000,L74b8
	move.l	#$0,L74bc
	clr.l	L74c0
	clr.l	L74c4
	move.w	#$1,L9bf2
	clr.w	L9bf6
	clr.w	L74ca
	movea.l	#$b944,a0
	move.w	#$47f,d0
L35d8
	clr.l	(a0)+
	dbra	d0,L35d8
	movea.l	#$b944,a0
	movea.l	#$65ff8,a1
	move.w	#$47f,d0
L35ee
	move.l	(a0)+,(a1)+
	dbra	d0,L35ee
	move.w	L10aa8,(a1)+
	move.w	L4b7a,(a1)+
	move.w	L4b78,(a1)+
	move.w	L116ac,(a1)+
	move.w	L10aa2,(a1)+
	move.w	L10d20,(a1)+
	move.w	L10d1e,(a1)+
	move.w	L10d22,(a1)+
	move.w	L103ec,(a1)+
	move.w	L11b2c,(a1)+
	move.w	L103f6,(a1)+
	move.w	L11640,(a1)+
	move.w	L11554,(a1)+
	move.w	L11602,(a1)+
	move.w	L10aa6,(a1)+
	move.w	L114f0,(a1)+
	move.w	L11412,(a1)+
	move.w	L11b2e,(a1)+
	move.w	L1040e,(a1)+
	move.w	L4b90,(a1)+
	move.w	L11c2c,(a1)+
	move.w	L4f7a,(a1)+
	move.w	L4f7c,(a1)+
	move.w	L4f7e,(a1)+
	move.w	L4f80,(a1)+
	move.w	L4f82,(a1)+
	move.w	L4f84,(a1)+
	move.w	L4f86,(a1)+
	move.w	L4f88,(a1)+
	move.w	L5532,(a1)+
	move.w	L5534,(a1)+
	move.w	L5536,(a1)+
	move.w	L5538,(a1)+
	move.w	L553a,(a1)+
	move.w	L553c,(a1)+
	move.w	L553e,(a1)+
	move.w	L5540,(a1)+
	move.w	L5f48,(a1)+
	move.w	L5542,(a1)+
	move.l	L5548,(a1)+
	move.w	L10d28,(a1)+
	move.w	L10d24,(a1)+
	move.w	L10d26,(a1)+
	move.w	L648a,(a1)+
	move.w	L648c,(a1)+
	move.w	L648e,(a1)+
	move.w	L6490,(a1)+
	move.w	L6492,(a1)+
	move.w	L6494,(a1)+
	move.w	L6496,(a1)+
	move.w	L6498,(a1)+
	move.w	L6bb8,(a1)+
	move.w	L6e02,(a1)+
	move.w	L6e04,(a1)+
	move.w	L6e06,(a1)+
	move.w	L6e08,(a1)+
	move.w	L7014,(a1)+
	move.w	L11706,(a1)+
	movea.l	#$6bba,a4
	moveq	#$e,d0
L3758
	move.w	(a4)+,(a1)+
	dbra	d0,L3758
	movea.l	#$6bf6,a4
	moveq	#$e,d0
L3766
	move.w	(a4)+,(a1)+
	dbra	d0,L3766
	moveq	#$17,d0
	movea.l	#$10aaa,a0
L3774
	move.w	(a0)+,(a1)+
	dbra	d0,L3774
	movea.l	#$ee62,a0
	moveq	#$f,d0
L3782
	clr.w	(a0)
	addq.w	#4,a0
	dbra	d0,L3782
	move.w	#$10,Leac6
	move.l	#$eb8c,Leabe
	move.l	#$ee62,Leac2
	move.l	#$f0000,Leaba
	move.l	#$10000,Leac8
	jsr	L4150
	rts


	dc.w	$0000,$08f2
L37c6
	dc.w	$0000,$0000
L37ca
	dc.w	$0000,$0000,$0404


L37d0
	dc.b	'0000'
L37d4
	dc.b	'0'
L37d5
	dc.b	'000'
L37d8
	dc.b	'00',$00


	dc.b	$02


L37dc
	dc.b	'0000'
L37e0
	dc.b	'0'
L37e1
	dc.b	'000'
L37e4
	dc.b	'00',$00


	dc.b	$04


	dc.b	'player 1',$00


	dc.b	$03


	dc.b	'player 2',$00


	dc.b	$05


	dc.b	'game  over',$00


	dc.b	$00
L3808
	dc.b	$00
L3809
	dc.b	$09
L380a
	dc.b	$00
L380b
	dc.b	$00,$01
L380d
	dc.b	$00

	dc.w	$0000,$0006,$0c12,$181e,$242a,$3036,$3c00
L381c
	dc.w	$0000


L381e
	movea.l	#$6085a,a0
	adda.l	#$5c,a0
	movea.l	#$37e7,a1
	move.w	#$26,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	adda.l	#$5c,a0
	movea.l	#$37e7,a1
	move.w	#$26,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	cmpi.w	#$3,L103ea
	beq	L38c2
	movea.l	#$6085a,a0
	adda.l	#$5c,a0
	movea.l	#$37f1,a1
	move.w	#$129,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	adda.l	#$5c,a0
	movea.l	#$37f1,a1
	move.w	#$129,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
L38c2
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$20,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$20,L1338c
	move.l	#$6085a,L1337a
	move.l	#$6fbb6,L1338e
	move.w	#$20,L13396
	move.w	#$16,L13398
	move.w	#$30,L1339a
	move.w	#$4,L1339c
	move.l	#$18,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	move.l	#$6251a,L1337a
	move.l	#$6fbb6,L1338e
	move.w	#$20,L13396
	move.w	#$16,L13398
	move.w	#$30,L1339a
	move.w	#$4,L1339c
	move.l	#$18,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	cmpi.w	#$3,L103ea
	beq	L3a38
	move.l	#$6085a,L1337a
	move.l	#$6fc2e,L1338e
	move.w	#$124,L13396
	move.w	#$16,L13398
	move.w	#$30,L1339a
	move.w	#$4,L1339c
	move.l	#$18,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	move.l	#$6251a,L1337a
	move.l	#$6fc2e,L1338e
	move.w	#$124,L13396
	move.w	#$16,L13398
	move.w	#$30,L1339a
	move.w	#$4,L1339c
	move.l	#$18,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
L3a38
	rts


L3a3a
	addq.b	#1,L3809
	cmpi.b	#$a,L3809
	bne.s	L3a50
	clr.b	L3809
L3a50
	movea.l	#$648b0,a0
	move.w	L3808,d4
	movea.l	#$37d0,a2
	move.b	(a2,d4.w),L380d
	movea.l	#$380c,a1
	clr.w	d0
	move.b	$4(a1,d4.w),d0
	moveq	#$8,d1
	moveq	#$30,d3
	jsr	L137ce
	cmpi.w	#$3,L103ea
	beq	L3abe
	movea.l	#$649a0,a0
	move.w	L3808,d4
	movea.l	#$37dc,a2
	move.b	(a2,d4.w),L380d
	movea.l	#$380c,a1
	clr.w	d0
	move.b	$4(a1,d4.w),d0
	addq.b	#4,d0
	moveq	#$8,d1
	moveq	#$30,d3
	jsr	L137ce
L3abe
	move.b	Le127,d0
	add.b	d0,L380b
	andi.b	#$1f,L380b
	cmpi.b	#$b,L380b
	bcs	L3b78
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.w	#$0,$dff064
	move.w	#$26,$dff066
	move.w	#$184,d7
	move.l	#$648b0,$dff050
	movea.l	Le53a,a2
	adda.l	#$1a2,a2
	move.w	#$9f0,$dff040
	moveq	#$4,d2
L3b22
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	dbra	d2,L3b22
	jsr	Leaae
	move.l	#$649a0,$dff050
	movea.l	Le53a,a2
	adda.l	#$1c2,a2
	moveq	#$4,d2
L3b56
	jsr	Leaae
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	dbra	d2,L3b56
	rts


	dc.w	$0000,$08f2


L3b78
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.w	#$0,$dff064
	move.w	#$26,$dff066
	move.w	#$184,d7
	move.l	#$64a90,$dff050
	movea.l	Le53a,a2
	adda.l	#$1a2,a2
	move.w	#$9f0,$dff040
	moveq	#$4,d2
L3bbc
	jsr	Leaae
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	dbra	d2,L3bbc
	jsr	Leaae
	move.l	#$64b80,$dff050
	movea.l	Le53a,a2
	adda.l	#$1c2,a2
	moveq	#$4,d2
L3bf6
	jsr	Leaae
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	dbra	d2,L3bf6
	rts


	dc.w	$0420,$2020,$2020,$2000,$0420,$2020,$2020,$2000,$047b,$7c20,$2020,$2000,$047b,$7c7b,$7c20,$2000
	dc.w	$047b,$7c7b,$7c7b,$7c00,$0320,$2020,$2020,$2000,$0320,$2020,$2020,$2000,$037b,$7c20,$2020,$2000
	dc.w	$037b,$7c7b,$7c20,$2000,$037b,$7c7b,$7c7b,$7c00,$0220,$2020,$0002,$7b20,$2000,$027b,$7b20,$0002
	dc.w	$7b7b,$7b00,$0520,$2020,$0005,$7b20,$2000,$057b,$7b20,$0005,$7b7b,$7b00


L3c8c
	clr.l	d0
	move.w	L7256,d0
	cmpi.w	#$3,L103ea
	bne.s	L3ca0
	addq.w	#1,d0
L3ca0
	cmpi.w	#$4,d0
	bcs.s	L3caa
	move.w	#$4,d0
L3caa
	asl.w	#3,d0
	addi.l	#$3c14,d0
	movea.l	d0,a1
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$2b2,a0
	move.w	#$20,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$2b2,a0
	move.w	#$20,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	tst.w	L7266
	beq.s	L3d08
	tst.w	L7256
	nop
L3d08
	clr.l	d0
	move.w	L7258,d0
	cmpi.w	#$4,d0
	bcs.s	L3d1a
	move.w	#$3,d0
L3d1a
	mulu.w	#$5,d0
	addi.l	#$3c64,d0
	movea.l	d0,a1
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$2e0,a0
	move.w	#$48,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$2e0,a0
	move.w	#$48,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	clr.l	d0
	move.w	L725a,d0
	cmpi.w	#$4,d0
	bcs.s	L3d7c
	move.w	#$3,d0
L3d7c
	mulu.w	#$5,d0
	addi.l	#$3c78,d0
	movea.l	d0,a1
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$3c6,a0
	move.w	#$47,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$3c6,a0
	move.w	#$47,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	clr.l	d0
	move.w	L74a6,d0
	cmpi.w	#$4,d0
	bcs.s	L3dde
	move.w	#$4,d0
L3dde
	asl.w	#3,d0
	addi.l	#$3c3c,d0
	movea.l	d0,a1
	cmpi.w	#$3,L103ea
	beq	L3e34
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$2b2,a0
	move.w	#$124,d0
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$2b2,a0
	move.w	#$124,d0
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
L3e34
	tst.w	L74b6
	beq.s	L3e44
	tst.w	L74a6
	nop
L3e44
	clr.l	d0
	move.w	L74a8,d0
	cmpi.w	#$4,d0
	bcs.s	L3e56
	move.w	#$3,d0
L3e56
	mulu.w	#$5,d0
	addi.l	#$3c64,d0
	movea.l	d0,a1
	cmpi.w	#$3,L103ea
	beq	L3f14
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$2e0,a0
	move.w	#$14c,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$2e0,a0
	move.w	#$14c,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	clr.l	d0
	move.w	L74aa,d0
	cmpi.w	#$4,d0
	bcs.s	L3ec4
	move.w	#$3,d0
L3ec4
	mulu.w	#$5,d0
	addi.l	#$3c78,d0
	movea.l	d0,a1
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$3c6,a0
	move.w	#$14b,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$3c6,a0
	move.w	#$14b,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
L3f14
	rts


	dc.w	$8000,$0000,$2000,$0000,$c000,$0000,$2000,$0000,$e000,$0000,$2000,$0000,$f000,$0000,$2000,$0000
	dc.w	$f800,$0000,$2000,$0000,$fc00,$0000,$2000,$0000,$fe00,$0000,$2000,$0000,$ff00,$0000,$2000,$0000
	dc.w	$ff80,$0000,$2000,$0000,$ffc0,$0000,$2000,$0000,$ffe0,$0000,$2000,$0000,$fff0,$0000,$2000,$0000
	dc.w	$fff8,$0000,$2000,$0000,$fffc,$0000,$2000,$0000,$fffe,$0000,$2000,$0000,$ffff,$0000,$2000,$0000
	dc.w	$ffff,$8000,$2000,$0000,$ffff,$c000,$2000,$0000,$ffff,$e000,$2000,$0000,$ffff,$f000,$2000,$0000
	dc.w	$ffff,$f800,$2000,$0000,$ffff,$fc00,$2000,$0000,$ffff,$fe00,$2000,$0000,$ffff,$ff00,$2000,$0000
	dc.w	$ffff,$ff80,$2000,$0000,$ffff,$ffc0,$2000,$0000,$ffff,$ffe0,$2000,$0000,$ffff,$fff0,$2000,$0000
	dc.w	$ffff,$fff8,$2000,$0000,$ffff,$fffc,$2000,$0000,$ffff,$fffe,$2000,$0000,$ffff,$ffff,$2000,$0000
	dc.w	$ffff,$ffff,$a000,$0000,$ffff,$ffff,$e000,$0000,$8800,$0000,$0200,$0000,$8c00,$0000,$0200,$0000
	dc.w	$8e00,$0000,$0200,$0000,$8f00,$0000,$0200,$0000,$8f80,$0000,$0200,$0000,$8fc0,$0000,$0200,$0000
	dc.w	$8fe0,$0000,$0200,$0000,$8ff0,$0000,$0200,$0000,$8ff8,$0000,$0200,$0000,$8ffc,$0000,$0200,$0000
	dc.w	$8ffe,$0000,$0200,$0000,$8fff,$0000,$0200,$0000,$8fff,$8000,$0200,$0000,$8fff,$c000,$0200,$0000
	dc.w	$8fff,$e000,$0200,$0000,$8fff,$f000,$0200,$0000,$8fff,$f800,$0200,$0000,$8fff,$fc00,$0200,$0000
	dc.w	$8fff,$fe00,$0200,$0000,$8fff,$ff00,$0200,$0000,$8fff,$ff80,$0200,$0000,$8fff,$ffc0,$0200,$0000
	dc.w	$8fff,$ffe0,$0200,$0000,$8fff,$fff0,$0200,$0000,$8fff,$fff8,$0200,$0000,$8fff,$fffc,$0200,$0000
	dc.w	$8fff,$fffe,$0200,$0000,$8fff,$ffff,$0200,$0000,$8fff,$ffff,$8200,$0000,$8fff,$ffff,$c200,$0000
	dc.w	$8fff,$ffff,$e200,$0000,$8fff,$ffff,$f200,$0000,$8fff,$ffff,$fa00,$0000,$8fff,$ffff,$fe00,$0000
L4136
	dc.w	$0000,$0000
L413a
	dc.b	$00
L413b
	dc.b	$1e
L413c
	dc.w	$0000
L413e
	dc.w	$0000
L4140
	dc.w	$0000,$0000
L4144
	dc.w	$0000,$0000
L4148
	dc.w	$0000,$0000
L414c
	dc.w	$0000,$0000


L4150
	tst.w	L103ec
	bne.s	L4188
	move.w	L727a,d0
	andi.w	#$fffc,d0
	cmpi.w	#$38,d0
	bne.s	L4170
	moveq	#$22,d0
	jsr	L1ad18
L4170
	move.w	L74ca,d0
	andi.w	#$fffc,d0
	cmpi.w	#$38,d0
	bne.s	L4188
	moveq	#$22,d0
	jsr	L1ad18
L4188
	move.w	L9bf4,d2
	lsr.w	#4,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	d2,a0
	cmpa.l	L4140,a0
	beq	L4228
	move.l	a0,L4140
	movea.l	#$6085a,a1
	adda.l	#$4e2,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$143,d7
	move.w	#$29f0,$dff040
	moveq	#$4,d2
L41ee
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L41ee
L4228
	move.w	L727a,d2
	lsr.w	#5,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	#$ce4,a0
	adda.l	d2,a0
	cmpa.l	L4144,a0
	beq	L42ce
	move.l	a0,L4144
	movea.l	#$6085a,a1
	adda.l	#$4de,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.w	#$0,$dff064
	move.w	#$2a,$dff066
	move.w	#$142,d7
	move.w	#$9f0,$dff040
	moveq	#$4,d2
L4294
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L4294
L42ce
	move.w	L9bf6,d2
	lsr.w	#4,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	d2,a0
	cmpa.l	L4148,a0
	beq	L444c
	move.l	a0,L4148
	jsr	L45c8
	movea.l	#$6085a,a1
	adda.l	#$502,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$143,d7
	move.w	#$6dfc,$dff040
	move.w	#$0,$dff042
	moveq	#$4,d2
L434a
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.l	a1,$dff04c
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L434a
	move.w	L74ca,d2
	lsr.w	#5,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	#$ce4,a0
	adda.l	d2,a0
	move.l	a0,L414c
	movea.l	#$6085a,a1
	adda.l	#$4fe,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$143,d7
	move.w	#$4dfc,$dff040
	move.w	#$0,$dff042
	moveq	#$4,d2
L4402
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.l	a1,$dff04c
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L4402
	bra	L4618


L444c
	move.w	L74ca,d2
	lsr.w	#5,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	#$ce4,a0
	adda.l	d2,a0
	cmpa.l	L414c,a0
	beq	L4618
	move.l	a0,L414c
	jsr	L45c8
	movea.l	#$6085a,a1
	adda.l	#$4fe,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$143,d7
	move.w	#$4dfc,$dff040
	move.w	#$0,$dff042
	moveq	#$4,d2
L44ce
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.l	a1,$dff04c
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L44ce
	move.w	L9bf6,d2
	lsr.w	#4,d2
	mulu.w	#$14,d2
	movea.l	L4136,a0
	adda.l	d2,a0
	move.l	a0,L4148
	movea.l	#$6085a,a1
	adda.l	#$502,a1
	movea.l	a1,a2
	adda.l	#$1cc0,a2
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$143,d7
	move.w	#$6dfc,$dff040
	move.w	#$0,$dff042
	moveq	#$4,d2
L4580
	move.l	a0,$dff050
	move.l	a1,$dff054
	move.l	a1,$dff04c
	move.w	d7,$dff058
	move.l	a0,$dff050
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$5c0,a2
	adda.l	#$294,a0
	adda.l	#$5c0,a1
	dbra	d2,L4580
	bra.s	L4618


L45c8
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$24,$dff066
	move.l	#$60d58,d0
	move.w	#$145,d7
	moveq	#$9,d2
L45f6
	jsr	Leaae
	move.l	d0,$dff054
	move.w	d7,$dff058
	addi.l	#$5c0,d0
	dbra	d2,L45f6
	rts


	dc.w	$0000,$09a8


L4618
	tst.w	L727a
	beq	L47ae
	tst.w	L7264
	bne	L47ae
	tst.w	L103ec
	bne	L4684
	move.b	#$55,L9970
	clr.l	L9af0
	move.l	L7268,L99f0
	move.l	L726c,L9a70
	addq.w	#4,L9a70
	andi.w	#$7ff,L99f0
	move.l	#$4,L9b70
	move.w	Le126,d0
	sub.w	d0,L727a
	bpl.s	L4684
	clr.w	L727a
L4684
	move.w	L7268,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L4698
	addi.w	#$800,d0
L4698
	subq.w	#3,d0
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	clr.w	L13386
	clr.w	L13388
	nop
	nop
	nop
	nop
	nop
	nop
	move.w	#$160,L1338a
	move.w	#$98,L1338c
	move.l	Le536,L1337a
	tst.w	L7278
	beq.s	L4706
	addq.w	#1,L413c
	cmpi.w	#$6,L413c
	bne.s	L471c
	clr.w	L413c
	bra.s	L471c


L4706
	subq.w	#1,L413c
	tst.w	L413c
	bpl.s	L471c
	move.w	#$5,L413c
L471c
	move.w	L413c,d1
	mulu.w	#$dc,d1
	addi.l	#$68708,d1
	move.l	d1,L1338e
	tst.w	L7278
	beq.s	L4744
	addi.l	#$528,L1338e
L4744
	move.w	d0,L13396
	move.w	L726c,L13398
	subq.w	#2,L13398
	move.w	#$20,L1339a
	move.w	#$b,L1339c
	move.l	#$2c,L1339e
	clr.w	L133a4
	move.w	L413c,d1
	mulu.w	#$2c,d1
	addi.l	#$69158,d1
	move.l	d1,L13392
	tst.w	L7278
	beq.s	L47a8
	subq.w	#1,L13396
	addi.l	#$108,L13392
L47a8
	jsr	L133b4
L47ae
	tst.w	L74ca
	beq	L4938
	tst.w	L74b4
	bne	L4938
	tst.w	L103ec
	bne	L481a
	move.b	#$55,L9974
	clr.l	L9af4
	move.l	L74b8,L99f4
	move.l	L74bc,L9a74
	addq.w	#4,L9a74
	andi.w	#$7ff,L99f4
	move.l	#$4,L9b74
	move.w	Le126,d0
	sub.w	d0,L74ca
	bpl.s	L481a
	clr.w	L74ca
L481a
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L482e
	addi.w	#$800,d0
L482e
	subq.w	#3,d0
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	clr.w	L13386
	clr.w	L13388
	move.w	#$160,L1338a
	move.w	#$98,L1338c
	move.l	Le536,L1337a
	tst.w	L74c8
	beq.s	L4890
	addq.w	#1,L413e
	cmpi.w	#$6,L413e
	bne.s	L48a6
	clr.w	L413e
	bra.s	L48a6


L4890
	subq.w	#1,L413e
	tst.w	L413e
	bpl.s	L48a6
	move.w	#$5,L413e
L48a6
	move.w	L413e,d1
	mulu.w	#$dc,d1
	addi.l	#$68708,d1
	move.l	d1,L1338e
	tst.w	L74c8
	beq.s	L48ce
	addi.l	#$528,L1338e
L48ce
	move.w	d0,L13396
	move.w	L74bc,L13398
	subq.w	#2,L13398
	move.w	#$20,L1339a
	move.w	#$b,L1339c
	move.l	#$2c,L1339e
	clr.w	L133a4
	move.w	L413e,d1
	mulu.w	#$2c,d1
	addi.l	#$69158,d1
	move.l	d1,L13392
	tst.w	L74c8
	beq.s	L4932
	subq.w	#1,L13396
	addi.l	#$108,L13392
L4932
	jsr	L133b4
L4938
	clr.l	d0
	move.w	L725c,d0
	asl.w	#3,d0
	addi.l	#$3f16,d0
	movea.l	d0,a0
	movea.l	Le53a,a1
	adda.l	#$1700,a1
	adda.l	#$426,a1
	move.l	(a0),(a1)
	move.l	(a0)+,$2e(a1)
	move.w	(a0),$4(a1)
	move.w	(a0),$32(a1)
	cmpi.w	#$3,L103ea
	beq	L49b2
	clr.l	d0
	move.w	L74ac,d0
	asl.w	#3,d0
	addi.l	#$4026,d0
	movea.l	d0,a0
	movea.l	Le53a,a1
	adda.l	#$1700,a1
	adda.l	#$41e,a1
	move.l	(a0),$28(a1)
	move.l	(a0)+,d0
	andi.l	#$cfffffff,d0
	move.l	d0,$56(a1)
	move.w	(a0),$2c(a1)
	move.w	(a0),$5a(a1)
L49b2
	move.b	Le127,d0
	sub.b	d0,L413b
	tst.b	L413b
	bpl.s	L4a44
	move.b	#$28,L413b
	tst.w	L725e
	beq.s	L4a0c
	IFND	INFINITE_SHIELD
	subq.b	#1,L725d
	ELSE
	nop
	nop
	nop
	ENDC
	cmpi.b	#$2,L725d
	bne.s	L49ee
	moveq	#$22,d0
	jsr	L1ad18
L49ee
	tst.b	L725d
	bne.s	L4a0c
	clr.w	L725e
	cmpi.w	#$3,L103ea
	bne.s	L4a0c
	clr.w	L74ae
L4a0c
	cmpi.w	#$3,L103ea
	beq.s	L4a44
	tst.w	L74ae
	beq.s	L4a44
	subq.b	#1,L74ad
	cmpi.b	#$2,L74ad
	bne.s	L4a36
	moveq	#$22,d0
	jsr	L1ad18
L4a36
	tst.b	L74ad
	bne.s	L4a44
	clr.w	L74ae
L4a44
	tst.w	L103ec
	bne.s	L4ac8
	move.w	L7264,d0
	tst.w	L103ea
	beq.s	L4a6a
	cmpi.w	#$2,L103ea
	bne.s	L4a6a
	move.w	L74b4,d0
L4a6a
	cmpi.w	#$3,L103ea
	bne.s	L4a86
	tst.w	L7264
	beq.s	L4a8a
	tst.w	L74b4
	beq.s	L4a8a
	bra.s	L4ac8


L4a86
	tst.w	d0
	bne.s	L4ac8
L4a8a
	move.b	$bfec01,d0
	cmpi.b	#$7f,d0
	bne.s	L4b0e
	cmpi.b	#$7f,L4b16
	beq.s	L4b0c
	move.b	d0,L4b16
	tst.w	L103ea
	beq.s	L4ab8
	cmpi.w	#$1,L103ea
	bne.s	L4aca
L4ab8
	tst.w	L725c
	beq.s	L4ac8
	eori.w	#$1,L725e
L4ac8
	rts


L4aca
	cmpi.w	#$2,L103ea
	bne.s	L4aea
	tst.w	L74ac
	beq.s	L4ac8
	eori.w	#$1,L74ae
	rts


	dc.w	$0000,$09a8


L4aea
	cmpi.w	#$3,L103ea
	bne.s	L4b0c
	tst.w	L725c
	beq.s	L4b0c
	eori.w	#$1,L725e
	eori.w	#$1,L74ae
L4b0c
	rts


L4b0e
	clr.b	L4b16
	rts


L4b16
	dc.w	$0000
L4b18
	dc.w	$0000,$0000
L4b1c
	dc.w	$0000,$0000
L4b20
	dc.w	$0000,$0000
L4b24
	dc.w	$0000,$0000
L4b28
	dc.w	$0000,$0000
L4b2c
	dc.w	$0000,$0000
L4b30
	dc.w	$0000,$0000
L4b34
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000
L4b58
	dc.w	$0000,$0000
L4b5c
	dc.w	$0000,$0000
L4b60
	dc.w	$0000,$0000
L4b64
	dc.w	$0000,$0000
L4b68
	dc.w	$0000,$0000
L4b6c
	dc.w	$0000,$0000
L4b70
	dc.w	$0000,$0000
L4b74
	dc.w	$0000,$0000
L4b78
	dc.b	$00
L4b79
	dc.b	$08
L4b7a
	dc.b	$00
L4b7b
	dc.b	$00


	dc.b	$05,'out:     in:',$00


	dc.b	$05
L4b8b
	dc.b	$38

	dc.w	$0005
L4b8e
	dc.w	$3000
L4b90
	dc.w	$0000,$0125,$2600,$0125,$0226,$0002,$2501,$2600,$0225,$2600,$0000,$4b92,$0000,$4b96,$0000,$4b9b
	dc.w	$0000,$4ba0
L4bb4
	dc.w	$0000
L4bb6
	dc.w	$0000
L4bb8
	dc.w	$0000,$0d71,$1905
L4bbe
	dc.w	$2525,$2525,$0000,$0dfa,$1905
L4bc8
	dc.w	$2525,$2525,$0000
L4bce
	dc.w	$0000
L4bd0
	dc.w	$0000,$2020,$2020,$2520,$2020,$2525,$2020,$2525,$2520,$2525,$2525


L4be6
	cmpi.w	#$2,L103ea
	beq.s	L4c4a
	move.w	L4b90,d0
	cmp.w	L4bce,d0
	beq.s	L4c48
	move.w	d0,L4bce
	movea.l	#$4bd2,a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),L4bbe
	movea.l	#$6085a,a0
	movea.l	#$4bba,a1
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	movea.l	#$4bba,a1
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
L4c48
	rts


L4c4a
	move.w	L4b90,d0
	cmp.w	L4bd0,d0
	beq.s	L4ca2
	move.w	d0,L4bd0
	movea.l	#$4bd2,a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),L4bc8
	movea.l	#$6085a,a0
	movea.l	#$4bc4,a1
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	movea.l	#$4bc4,a1
	moveq	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
L4ca2
	rts


L4ca4
	movea.l	#$6085a,a0
	adda.l	#$4da,a0
	movea.l	#$4b7c,a1
	move.w	#$97,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	adda.l	#$4da,a0
	movea.l	#$4b7c,a1
	move.w	#$97,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	rts


L4cf2
	move.b	L4b79,d0
	addi.b	#$30,d0
	move.b	d0,L4b8b
	move.b	L4b7b,d0
	addi.b	#$30,d0
	move.b	d0,L4b8e
	movea.l	#$6085a,a0
	adda.l	#$4da,a0
	movea.l	#$4b8a,a1
	move.w	#$ae,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	adda.l	#$4da,a0
	movea.l	#$4b8a,a1
	move.w	#$ae,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6085a,a0
	adda.l	#$4da,a0
	movea.l	#$4b8d,a1
	move.w	#$de,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	#$6251a,a0
	adda.l	#$4da,a0
	movea.l	#$4b8d,a1
	move.w	#$de,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	rts


L4dac
	move.w	Le126,d0
	tst.w	L4bb4
	beq.s	L4de2
	sub.w	d0,L4bb4
	tst.w	L4bb4
	beq.s	L4dca
	bpl.s	L4de2
L4dca
	eori.w	#$1,L4bb8
	clr.w	L4bb4
	move.w	d0,-(a7)
	jsr	L4e10
	move.w	(a7)+,d0
L4de2
	tst.w	L4bb6
	beq.s	L4e0e
	sub.w	d0,L4bb6
	tst.w	L4bb6
	beq.s	L4dfa
	bpl.s	L4e0e
L4dfa
	eori.w	#$2,L4bb8
	clr.w	L4bb6
	jsr	L4e10
L4e0e
	rts


L4e10
	move.w	L4bb8,d0
	lsl.b	#2,d0
	movea.l	#$4ba4,a0
	movea.l	(a0,d0.w),a1
	move.l	a1,-(a7)
	movea.l	#$6085a,a0
	adda.l	#$4da,a0
	move.w	#$ba,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	movea.l	(a7)+,a1
	movea.l	#$6251a,a0
	adda.l	#$4da,a0
	move.w	#$ba,d0
	move.w	#$2e,d1
	move.l	#$5c0,d3
	jsr	L137ce
	rts


	dc.w	$0000,$09a8


L4e6c
	move.b	(a0)+,(a1)+
	dbra	d0,L4e6c
	rts


L4e74
	tst.w	L103ea
	beq.s	L4e9c
	cmpi.w	#$1,L103ea
	beq.s	L4e9c
	cmpi.w	#$2,L103ea
	beq.s	L4ec0
	cmpi.w	#$3,L103ea
	beq.s	L4ee0
	rts


L4e9c
	move.l	L7268,L4f64
	move.l	L726c,L4f68
	move.l	L7270,L4f6c
	rts


	dc.w	$0000,$09a8


L4ec0
	move.l	L74b8,L4f64
	move.l	L74bc,L4f68
	move.l	L74c0,L4f6c
	rts


L4ee0
	move.w	Le126,d0
	sub.w	d0,L4f70
	tst.w	L4f70
	bpl.s	L4f04
	move.w	#$32,L4f70
	eori.b	#$1,L4f73
L4f04
	tst.b	L4f73
	beq.s	L4f22
	move.l	L74b8,L4f64
	move.l	L74bc,L4f68
	bra.s	L4f36


L4f22
	move.l	L7268,L4f64
	move.l	L726c,L4f68
L4f36
	clr.l	L4f6c
	tst.w	L7264
	bne.s	L4f4e
	move.l	L7270,L4f6c
L4f4e
	tst.w	L74b4
	bne.s	L4f62
	move.l	L74c0,d0
	add.l	d0,L4f6c
L4f62
	rts


L4f64
	dc.w	$0000,$0000
L4f68
	dc.w	$0000,$0000
L4f6c
	dc.w	$0000,$0000
L4f70
	dc.w	$0000

	dc.b	$00
L4f73
	dc.b	$00
L4f74
	dc.b	$00
L4f75
	dc.b	$00
L4f76
	dc.w	$0000,$0000
L4f7a
	dc.w	$0000
L4f7c
	dc.w	$0000
L4f7e
	dc.w	$0000
L4f80
	dc.w	$0000
L4f82
	dc.w	$0000
L4f84
	dc.w	$0000
L4f86
	dc.w	$0001
L4f88
	dc.w	$0032


L4f8a
	clr.l	L1b30a
	move.w	#$1,L4f7a
	move.w	L4f64,d0
	addi.w	#$400,d0
	andi.w	#$7ff,d0
	move.w	d0,L4f7c
	move.w	#$4b,L4f7e
	clr.w	L4f80
	clr.w	L4f82
	clr.w	L4f84
	clr.w	L4f86
	move.w	#$28,L4f88
	jsr	L5444
	rts


L4fdc
	clr.l	L4f76
	tst.w	L4f7a
	beq	L5362
	tst.w	L1698
	bne.s	L506c
	move.w	Le126,d0
	sub.w	d0,L4f7c
	andi.w	#$7ff,L4f7c
	sub.w	d0,L4f80
	bpl.s	L5052
	move.w	#$190,L4f80
	move.w	#$13,L4f84
	moveq	#$2,d1
	jsr	L1ad48
	tst.w	d0
	beq.s	L5040
	cmpi.w	#$26,L4f7e
	bcs.s	L5040
L5036
	move.w	#$ffff,L4f82
	bra.s	L5052


L5040
	cmpi.w	#$60,L4f7e
	bcc.s	L5036
	move.w	#$1,L4f82
L5052
	tst.w	L4f84
	beq.s	L506c
	subq.w	#1,L4f84
	move.w	L4f82,d0
	add.w	d0,L4f7e
L506c
	addq.b	#1,L4f75
	cmpi.b	#$3,L4f75
	bne.s	L5082
	clr.b	L4f75
L5082
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	L4f74,d0
	addq.b	#2,d0
	mulu.w	#$21c,d0
	tst.w	L4f86
	beq.s	L50fa
	moveq	#$e,d0
	jsr	L1ad18
	moveq	#$0,d0
	cmpi.w	#$14,L4f88
	bcc.s	L50f4
	move.l	#$21c,d0
L50f4
	clr.w	L4f86
L50fa
	addi.l	#$69368,d0
	move.l	d0,L1338e
	move.w	L4f7c,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	L4f7e,L13398
	move.w	#$30,L1339a
	move.w	#$12,L1339c
	move.l	#$6c,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	moveq	#$1f,d7
	movea.l	#$9970,a0
L5152
	tst.l	(a0)
	beq.s	L51ac
	move.w	L4f7c,d0
	move.w	$80(a0),d1
	addi.w	#$400,d0
	addi.w	#$400,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L51ac
	addi.w	#$2e,d0
	cmp.w	d1,d0
	bcs.s	L51ac
	move.w	L4f7e,d0
	cmp.w	$100(a0),d0
	bcc.s	L51ac
	addi.w	#$12,d0
	cmp.w	$100(a0),d0
	bcs.s	L51ac
	move.w	#$1,L4f86
	clr.l	(a0)
	subq.w	#1,L4f88
	tst.w	L4f88
	beq	L5364
L51ac
	addq.l	#4,a0
	dbra	d7,L5152
	tst.w	L4f88
	bmi	L5364
	tst.w	L7266
	beq.s	L5228
	tst.w	L7264
	bne.s	L5228
	move.w	L4f7c,d0
	move.w	L7268,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5228
	addi.w	#$2e,d0
	cmp.w	d1,d0
	bcs.s	L5228
	move.w	L4f7e,d0
	subi.w	#$5,d0
	cmp.w	L726c,d0
	bcc.s	L5228
	addi.w	#$12,d0
	cmp.w	L726c,d0
	bcs.s	L5228
	tst.w	L725e
	bne.s	L5228
	tst.w	L727a
	bne.s	L5228
	st	L7d8e
L5228
	tst.w	L74b6
	beq.s	L5294
	tst.w	L74b4
	bne.s	L5294
	move.w	L4f7c,d0
	move.w	L74b8,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5294
	addi.w	#$2e,d0
	cmp.w	d1,d0
	bcs.s	L5294
	move.w	L4f7e,d0
	subi.w	#$5,d0
	cmp.w	L74bc,d0
	bcc.s	L5294
	addi.w	#$12,d0
	cmp.w	L74bc,d0
	bcs.s	L5294
	tst.w	L74ae
	bne.s	L5294
	tst.w	L74ca
	bne.s	L5294
	st	L7d90
L5294
	move.w	L4f7c,d0
	sub.w	Le0ea,d0
	subi.w	#$4ba,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	L52b2
	eori.w	#$7ff,d0
L52b2
	andi.l	#$ffff,d0
	lsr.w	#4,d0
	addq.w	#5,d0
	cmpi.w	#$3f,d0
	bcs.s	L52c6
	move.w	#$3f,d0
L52c6
	cmp.l	L4f76,d0
	bcs.s	L52d4
	move.l	d0,L4f76
L52d4
	move.l	L4f76,L1b30a
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L52f4
	move.w	L74b4,d0
L52f4
	tst.w	d0
	bne.s	L5362
	tst.w	L1698
	bne.s	L5362
	jsr	L1189e
	move.w	L4f7c,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L531a
	addi.w	#$800,d0
L531a
	cmpi.w	#$16f,d0
	bcc.s	L5362
	subq.w	#1,L5442
	tst.w	L5442
	bpl.s	L5362
	moveq	#$46,d1
	jsr	L1ad48
	move.w	d0,L5442
	move.w	L4f7c,d0
	addi.w	#$16,d0
	andi.w	#$7ff,d0
	move.w	L4f7e,d1
	addq.w	#8,d1
	moveq	#$2,d2
	jsr	L13b98
	moveq	#$14,d0
	jsr	L1ad18
L5362
	rts


L5364
	move.l	#$e294,Le248
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	moveq	#$11,d2
	jsr	Ld66e
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$10,d2
	jsr	Ld66e
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	addi.w	#$12,d1
	moveq	#$f,d2
	jsr	Ld66e
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	addi.w	#$12,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$e,d2
	jsr	Ld66e
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	addi.w	#$9,d1
	addi.w	#$14,d0
	andi.w	#$7ff,d0
	moveq	#$1,d2
	jsr	Ld66e
	clr.w	L4f7a
	move.l	L4f7c,d0
	move.l	L4f7e,d1
	jsr	L11768
	movea.l	#$16736,a0
	movea.l	L166c4,a1
	jsr	L1675e
	jsr	L5444
	moveq	#$17,d0
	jsr	L1ad18
	move.l	L4f7c,d0
	move.l	L4f7e,d1
	jsr	L11612
	rts


L5442
	dc.w	$0000


L5444
	moveq	#$15,d0
	tst.w	L4f7a
	bne.s	L5456
	jsr	L1ad24
	rts


L5456
	jsr	L1ad18
	rts


	dc.w	$0000,$09a8


L5462
	tst.w	L648a
	beq	L54c4
	move.w	Le126,-(a7)
	move.w	Le124,-(a7)
	move.l	#$4b314,L37ca
	move.l	#$4b314,L4c6
	moveq	#$5,d0
	jsr	L430
	movea.l	L37ca,a0
	adda.l	#$1400,a0
	movea.l	L37ca,a1
	movea.l	L37ca,a2
	adda.l	#$318c,a2
	jsr	decompress
	move.w	(a7)+,Le124
	move.w	(a7)+,Le126
L54c4
	tst.w	L5532
	beq	L5526
	move.w	Le126,-(a7)
	move.w	Le124,-(a7)
	move.l	#$4673e,L37c6
	move.l	#$4673e,L4ce
	moveq	#$6,d0
	jsr	L430
	movea.l	L37c6,a0
	adda.l	#$3904,a0
	movea.l	L37c6,a1
	movea.l	L37c6,a2
	adda.l	#$7d62,a2
	jsr	decompress
	move.w	(a7)+,Le124
	move.w	(a7)+,Le126
L5526
	clr.b	Lfde4
	rts


L552e
	dc.w	$0000,$0000
L5532
	dc.w	$0000
L5534
	dc.w	$0000
L5536
	dc.w	$0000
L5538
	dc.w	$0000
L553a
	dc.b	$00
L553b
	dc.b	$00
L553c
	dc.w	$0000
L553e
	dc.w	$0001
L5540
	dc.w	$0032
L5542
	dc.w	$0000
L5544
	dc.w	$0000,$5548
L5548
	dc.w	$0001,$0003,$0005,$0007,$0009,$000b,$000d,$000f,$0011,$0013,$000c,$0005,$0001,$0000
L5564
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L5574
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L5584
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L55a4
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L55c4
	dc.w	$0000


L55c6
	tst.w	L5532
	bne.s	L562c
	clr.l	L1b382
	move.w	#$1,L5532
	move.w	L4f64,d0
	addi.w	#$200,d0
	andi.w	#$7ff,d0
	move.w	d0,L5534
	move.w	#$a,L5536
	clr.w	L5538
	clr.w	L553a
	clr.w	L553c
	clr.w	L553e
	move.w	#$12c,L5540
	jsr	L5f4a
	movea.l	#$5564,a0
	moveq	#$7,d0
L5626
	clr.w	(a0)+
	dbra	d0,L5626
L562c
	rts


L562e
	dc.w	$0000


L5630
	clr.l	L552e
	move.w	#$68f,L562e
	tst.w	L5532
	beq	L5e82
	move.w	#$ddd,L562e
	tst.w	L1698
	bne.s	L5676
	move.w	Le126,d0
	tst.w	L553a
	beq.s	L5668
	neg.w	d0
L5668
	add.w	d0,L5534
	andi.w	#$7ff,L5534
L5676
	move.w	Le126,d0
	sub.w	d0,L5538
	bpl.s	L56c2
	move.w	#$12c,d1
	jsr	L1ad48
	move.w	d0,L5538
	move.w	L5534,d0
	move.w	L4f64,d1
	addi.w	#$400,d0
	addi.w	#$400,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	clr.w	L553a
	cmp.w	d0,d1
	bcc.s	L56c2
	move.b	#$1,L553b
L56c2
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	moveq	#$0,d0
	tst.w	L553e
	beq.s	L5734
	moveq	#$e,d0
	jsr	L1ad18
	move.l	#$5212,d0
	clr.w	L553e
	cmpi.w	#$1e,L5540
	bcc.s	L5734
	move.l	#$31ce,d0
L5734
	add.l	L37c6,d0
	move.l	d0,L1338e
	move.w	L5534,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	L5536,L13398
	move.w	#$70,L1339a
	move.w	#$76,L1339c
	move.l	#$674,L1339e
	clr.w	L133a4
	move.l	L37c6,L13392
	addi.l	#$31ce,L13392
	jsr	L133b4
	move.w	L4f64,d5
	addi.w	#$b8,d5
	andi.w	#$7ff,d5
	sub.w	L5534,d5
	tst.w	d5
	bpl.s	L57b2
	addi.w	#$800,d5
L57b2
	andi.l	#$7ff,d5
	divu.w	#$e,d5
	addi.w	#$d,d5
	move.w	L4f68,d6
	andi.l	#$ff,d6
	divu.w	#$e,d6
	subq.w	#4,d6
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$10,L1339a
	move.w	#$3,L1339c
	move.l	#$6,L1339e
	move.w	#$1,L133a4
	move.l	L37c6,L1338e
	addi.l	#$22f6,L1338e
	move.w	L5534,d0
	add.w	d5,d0
	andi.w	#$7ff,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	L5536,d0
	addi.w	#$48,d0
	add.w	d6,d0
	move.w	d0,L13398
	movem.w	d5-d6,-(a7)
	jsr	L133b4
	movem.w	(a7)+,d5-d6
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$10,L1339a
	move.w	#$3,L1339c
	move.l	#$6,L1339e
	move.w	#$1,L133a4
	move.l	L37c6,L1338e
	addi.l	#$22f6,L1338e
	move.w	L5534,d0
	jsr	L7030
	add.w	d5,d0
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	move.w	d0,L13396
	move.w	L5536,d0
	addi.w	#$48,d0
	add.w	d6,d0
	move.w	d0,L13398
	jsr	L133b4
	moveq	#$1f,d7
	movea.l	#$9970,a0
L593a
	tst.l	(a0)
	beq.s	L5994
	move.w	L5534,d0
	move.w	$80(a0),d1
	addi.w	#$400,d0
	addi.w	#$400,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5994
	addi.w	#$32,d0
	cmp.w	d1,d0
	bcs.s	L5994
	move.w	L5536,d0
	cmp.w	$100(a0),d0
	bcc.s	L5994
	addi.w	#$76,d0
	cmp.w	$100(a0),d0
	bcs.s	L5994
	move.w	#$1,L553e
	clr.l	(a0)
	subq.w	#1,L5540
	tst.w	L5540
	beq	L5e84
L5994
	addq.l	#4,a0
	dbra	d7,L593a
	tst.w	L5540
	bmi	L5e84
	tst.w	L7266
	beq.s	L5a24
	tst.w	L7264
	bne.s	L5a24
	move.w	L5534,d0
	move.w	L7268,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5a24
	addi.w	#$68,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L5a24
	move.w	L5536,d0
	subi.w	#$5,d0
	cmp.w	L726c,d0
	bcc.s	L5a24
	addi.w	#$74,d0
	cmp.w	L726c,d0
	bcs.s	L5a24
	tst.w	L725e
	bne.s	L5a24
	tst.w	L727a
	bne.s	L5a24
	st	L7d8e
	addi.w	#$400,L5534
	andi.w	#$7ff,L5534
L5a24
	tst.w	L74b6
	beq.s	L5aa4
	tst.w	L74b4
	bne.s	L5aa4
	move.w	L5534,d0
	move.w	L74b8,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5aa4
	addi.w	#$68,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L5aa4
	move.w	L5536,d0
	subi.w	#$5,d0
	cmp.w	L74bc,d0
	bcc.s	L5aa4
	addi.w	#$74,d0
	cmp.w	L74bc,d0
	bcs.s	L5aa4
	tst.w	L74ae
	bne.s	L5aa4
	tst.w	L74ca
	bne.s	L5aa4
	addi.w	#$400,L5534
	andi.w	#$7ff,L5534
	st	L7d90
L5aa4
	move.w	L5534,d0
	sub.w	Le0ea,d0
	subi.w	#$4ba,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	L5ac2
	eori.w	#$7ff,d0
L5ac2
	andi.l	#$ffff,d0
	lsr.w	#4,d0
	addq.w	#5,d0
	cmpi.w	#$3f,d0
	bcs.s	L5ad6
	move.w	#$3f,d0
L5ad6
	cmp.l	L552e,d0
	bcs.s	L5ae4
	move.l	d0,L552e
L5ae4
	move.l	L552e,L1b382
	subq.w	#1,L55c4
	tst.w	L55c4
	bpl	L5ba0
	tst.w	L1698
	bne	L5ba0
	move.w	#$14,L55c4
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L5b26
	move.w	L74b4,d0
L5b26
	tst.w	d0
	bne.s	L5ba0
	moveq	#$7,d0
	movea.l	#$5564,a0
L5b32
	tst.b	(a0)
	beq.s	L5b3e
	addq.l	#2,a0
	dbra	d0,L5b32
	bra.s	L5ba0


L5b3e
	st	(a0)
	move.w	#$fffd,$30(a0)
	move.w	L5534,d0
	move.w	L4f64,d1
	cmp.w	d0,d1
	bcs.s	L5b5c
	move.w	#$3,$30(a0)
L5b5c
	move.w	L5534,d0
	move.w	L5536,d1
	addi.w	#$1e,d0
	addi.w	#$64,d1
	andi.w	#$7ff,d0
	move.w	d0,$10(a0)
	move.w	d1,$20(a0)
	move.w	#$204,$40(a0)
	move.w	#$6e,d1
	jsr	L1ad48
	andi.w	#$fffe,d0
	move.w	d0,$50(a0)
	move.l	#$5548,L5544
	nop
L5ba0
	moveq	#$7,d7
	movea.l	#$5564,a0
L5ba8
	tst.b	(a0)
	beq	L5d1a
	tst.w	L1698
	bne	L5c50
	cmpi.b	#$0,$40(a0)
	beq.s	L5be8
	cmpi.b	#$4,$40(a0)
	beq.s	L5be8
	subq.b	#1,$41(a0)
	tst.b	$41(a0)
	bne.s	L5be8
	move.b	#$4,$41(a0)
	tst.w	$30(a0)
	bpl.s	L5be4
	subq.b	#1,$40(a0)
	bra.s	L5be8


L5be4
	addq.b	#1,$40(a0)
L5be8
	move.w	Le126,d0
	addq.w	#1,d0
	tst.w	$30(a0)
	bpl.s	L5bf8
	neg.w	d0
L5bf8
	add.w	d0,$10(a0)
	andi.w	#$7ff,$10(a0)
	moveq	#$1,d0
	move.w	$20(a0),d1
	cmp.w	$50(a0),d1
	beq.s	L5c1a
	bcc.s	L5c16
	add.w	d0,$20(a0)
	bra.s	L5c1a


L5c16
	sub.w	d0,$20(a0)
L5c1a
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L5c30
	move.w	L74b4,d0
L5c30
	tst.w	d0
	bne.s	L5c50
	moveq	#$f,d1
	jsr	L1ad48
	cmpi.w	#$1,d0
	bne.s	L5c50
	movem.l	d7/a0,-(a7)
	jsr	L11818
	movem.l	(a7)+,d7/a0
L5c50
	move.w	$10(a0),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L5c62
	addi.w	#$800,d0
L5c62
	cmpi.w	#$170,d0
	bcc	L5d18
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$20,L1339a
	move.w	#$20,L1339c
	move.l	#$80,L1339e
	move.w	#$1,L133a4
	move.b	$40(a0),d0
	andi.l	#$ff,d0
	mulu.w	#$280,d0
	add.l	L37c6,d0
	addi.l	#$2314,d0
	move.l	d0,L1338e
	move.w	$10(a0),d0
	jsr	L7030
	move.w	d0,L13396
	move.w	$20(a0),L13398
	movem.l	d7/a0,-(a7)
	jsr	L133b4
	movem.l	(a7)+,d7/a0
	bra.s	L5d1a


L5d18
	sf	(a0)
L5d1a
	addq.l	#2,a0
	dbra	d7,L5ba8
	moveq	#$7,d7
	movea.l	#$5564,a0
L5d28
	tst.b	(a0)
	beq	L5db6
	move.w	$10(a0),d0
	move.w	L4f64,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L5db6
	addi.w	#$1e,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L5db6
	move.w	$20(a0),d0
	subi.w	#$5,d0
	cmp.w	L4f68,d0
	bcc.s	L5db6
	addi.w	#$22,d0
	cmp.w	L4f68,d0
	bcs.s	L5db6
	tst.w	L103ea
	beq.s	L5d9e
	cmpi.w	#$1,L103ea
	beq.s	L5d9e
	tst.w	L74ae
	bne.s	L5db6
	tst.w	L74ca
	bne.s	L5db6
	st	L7d90
	bra.s	L5dbc


L5d9e
	tst.w	L725e
	bne.s	L5db6
	tst.w	L727a
	bne.s	L5db6
	st	L7d8e
	bra.s	L5dbc


L5db6
	addq.l	#2,a0
	dbra	d7,L5d28
L5dbc
	movea.l	L5544,a0
	tst.w	(a0)
	beq.s	L5dd2
	move.w	(a0)+,L5542
	move.l	a0,L5544
L5dd2
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$30,L1339a
	move.w	#$17,L1339c
	move.l	#$8a,L1339e
	move.w	#$1,L133a4
	move.l	L37c6,L1338e
	addi.l	#$2044,L1338e
	move.w	L5534,d0
	addi.w	#$19,d0
	andi.w	#$7ff,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	L5536,d0
	add.w	L5542,d0
	addi.w	#$6b,d0
	move.w	d0,L13398
	jsr	L133b4
L5e82
	rts


L5e84
	jsr	L617e
	movea.l	#$16754,a0
	movea.l	L166c4,a1
	jsr	L1675e
	move.l	#$e2a6,Le248
	move.w	L5534,d0
	move.w	L5536,d1
	moveq	#$11,d2
	jsr	Ld66e
	move.w	L5534,d0
	move.w	L5536,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$10,d2
	jsr	Ld66e
	move.w	L5534,d0
	move.w	L5536,d1
	addi.w	#$12,d1
	moveq	#$f,d2
	jsr	Ld66e
	move.w	L5534,d0
	move.w	L5536,d1
	addi.w	#$12,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$e,d2
	jsr	Ld66e
	move.w	L5534,d0
	move.w	L5536,d1
	addi.w	#$9,d1
	addi.w	#$14,d0
	andi.w	#$7ff,d0
	moveq	#$1,d2
	jsr	Ld66e
	clr.w	L5532
	jsr	L5f4a
	moveq	#$17,d0
	jsr	L1ad18
	rts


	dc.w	$0000,$09a8
L5f48
	dc.w	$0000


L5f4a
	moveq	#$18,d0
	tst.w	L5532
	bne.s	L5f5c
	jsr	L1ad24
	rts


L5f5c
	jsr	L1ad18
	rts


L5f64
	moveq	#$7,d0
	movea.l	#$5564,a0
	movea.l	#$649a,a1
L5f72
	clr.w	(a0)+
	clr.w	(a1)+
	dbra	d0,L5f72
	rts


L5f7c	dc.w	0
L5f7e	ds.w	256


L617e
	moveq	#$0,d4
	moveq	#$0,d5
	moveq	#$1f,d7
	movea.l	#L5f7e,a0
L618a
	move.w	d4,d0
	mulu.w	#$e,d0
	add.w	L5534,d0
	andi.w	#$7ff,d0
	move.w	d0,(a0)
	move.w	d5,d0
	mulu.w	#$24,d0
	add.w	L5536,d0
	move.w	d0,$80(a0)
	addq.w	#1,d4
	cmpi.w	#$8,d4
	bne.s	L61b8
	clr.w	d4
	addq.w	#1,d5
L61b8
	moveq	#$a,d1
	jsr	L1ad48
	subq.w	#5,d0
	swap	d0
	move.l	d0,$100(a0)
	moveq	#$8,d1
	jsr	L1ad48
	subq.w	#4,d0
	swap	d0
	move.l	d0,$180(a0)
	addq.l	#4,a0
	dbra	d7,L618a
	move.w	#$64,L5f7c
	rts


	dc.w	$0000,$09a8


L61ec
	tst.w	L5f7c
	beq	L62fc
	subq.w	#1,L5f7c
	moveq	#$1f,d7
	movea.l	#L5f7e,a0
L6204
	movem.l	d7/a0,-(a7)
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$20,L1339a
	move.w	#$1f,L1339c
	move.l	#$7c,L1339e
	clr.w	L133a4
	move.l	L37c6,L13392
	addi.l	#$7c06,L13392
	add.w	L62fe,d7
	andi.w	#$3,d7
	mulu.w	#$26c,d7
	ext.l	d7
	add.l	L37c6,d7
	addi.l	#$7256,d7
	move.l	d7,L1338e
	move.w	(a0),d0
	jsr	L7030
	move.w	d0,L13396
	move.w	$80(a0),L13398
	jsr	L133b4
	movem.l	(a7)+,d7/a0
	move.l	$100(a0),d0
	add.l	d0,(a0)
	andi.w	#$7ff,(a0)
	move.l	$180(a0),d0
	add.l	d0,$80(a0)
	addq.l	#4,a0
	dbra	d7,L6204
	addq.w	#1,L62fe
	movea.l	Le536,a0
	movea.l	#$12740,a1
	move.w	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L62fc
	rts


L62fe
	dc.w	$0000
L6300
	dc.w	$0000


L6302
	moveq	#$0,d4
	moveq	#$0,d5
	moveq	#$1f,d7
	movea.l	#L5f7e,a0
L630e
	move.w	d4,d0
	mulu.w	#$e,d0
	add.w	L648c,d0
	andi.w	#$7ff,d0
	move.w	d0,(a0)
	move.w	d5,d0
	mulu.w	#$24,d0
	add.w	L648e,d0
	move.w	d0,$80(a0)
	addq.w	#1,d4
	cmpi.w	#$8,d4
	bne.s	L633c
	clr.w	d4
	addq.w	#1,d5
L633c
	moveq	#$a,d1
	jsr	L1ad48
	subq.w	#5,d0
	swap	d0
	move.l	d0,$100(a0)
	moveq	#$8,d1
	jsr	L1ad48
	subq.w	#4,d0
	swap	d0
	move.l	d0,$180(a0)
	addq.l	#4,a0
	dbra	d7,L630e
	move.w	#$64,L6300
	rts


L636c
	tst.w	L6300
	beq	L6484
	subq.w	#1,L6300
	moveq	#$1f,d7
	movea.l	#L5f7e,a0
L6384
	movem.l	d7/a0,-(a7)
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$20,L1339a
	move.w	#$1f,L1339c
	move.l	#$7c,L1339e
	clr.w	L133a4
	move.l	L37ca,L13392
	addi.l	#$3110,L13392
	add.w	L62fe,d7
	andi.w	#$3,d7
	mulu.w	#$26c,d7
	ext.l	d7
	add.l	L37ca,d7
	addi.l	#$2760,d7
	move.l	d7,L1338e
	move.w	(a0),d0
	jsr	L7030
	move.w	d0,L13396
	move.w	$80(a0),L13398
	jsr	L133b4
	movem.l	(a7)+,d7/a0
	move.l	$100(a0),d0
	add.l	d0,(a0)
	andi.w	#$7ff,(a0)
	move.l	$180(a0),d0
	add.l	d0,$80(a0)
	addi.l	#$2000,$180(a0)
	addq.l	#4,a0
	dbra	d7,L6384
	addq.w	#1,L62fe
	movea.l	Le536,a0
	movea.l	#$1274c,a1
	move.w	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L6484
	rts


L6486
	dc.w	$0000,$0000
L648a
	dc.w	$0000
L648c
	dc.w	$0000
L648e
	dc.w	$0000
L6490
	dc.w	$0000
L6492
	dc.b	$00
L6493
	dc.b	$00
L6494
	dc.w	$0000
L6496
	dc.w	$0001
L6498
	dc.w	$0032
L649a
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L64aa
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L64ba
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L64fa
	dc.w	$0000


L64fc
	tst.w	L648a
	bne	L65c0
	clr.l	L1b3aa
	move.w	#$1,L648a
	move.w	#$f,L6bb8
	move.w	L4f64,d0
	addi.w	#$200,d0
	andi.w	#$7ff,d0
	move.w	d0,L648c
	move.w	#$a,L648e
	clr.w	L6490
	clr.w	L6492
	clr.w	L6494
	clr.w	L6496
	move.w	#$32,L6498
	jsr	L7016
	movea.l	#$649a,a0
	moveq	#$7,d0
L6566
	clr.w	(a0)+
	dbra	d0,L6566
	movea.l	#$6bba,a0
	moveq	#$e,d0
L6574
	move.w	#$1,(a0)+
	dbra	d0,L6574
	movea.l	#$6bf6,a0
	moveq	#$4,d0
L6584
	move.w	#$2c,(a0)
	move.w	#$4d,$a(a0)
	move.w	#$68,$14(a0)
	addq.l	#2,a0
	dbra	d0,L6584
	move.w	#$73,L6e02
	move.w	#$2,L6e04
	move.w	#$4,L6e06
	move.w	#$4,L6e08
	clr.w	L7014
L65c0
	rts


L65c2
	clr.l	L6486
	tst.w	L648a
	beq	L6f4c
	tst.w	L1698
	bne.s	L65f8
	move.w	Le126,d0
	tst.w	L6492
	beq.s	L65ea
	neg.w	d0
L65ea
	add.w	d0,L648c
	andi.w	#$7ff,L648c
L65f8
	move.w	Le126,d0
	sub.w	d0,L6490
	bpl.s	L6644
	move.w	#$12c,d1
	jsr	L1ad48
	move.w	d0,L6490
	move.w	L648c,d0
	move.w	L4f64,d1
	addi.w	#$400,d0
	addi.w	#$400,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	clr.w	L6492
	cmp.w	d0,d1
	bcc.s	L6644
	move.b	#$1,L6493
L6644
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.l	L37ca,d0
	addi.l	#$866,d0
	tst.w	L6496
	beq.s	L66b0
	moveq	#$e,d0
	jsr	L1ad18
	move.l	L37ca,d0
	clr.w	L6496
L66b0
	move.l	d0,L1338e
	move.w	L648c,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	L648e,L13398
	move.w	#$50,L1339a
	move.w	#$2b,L1339c
	move.l	#$1ae,L1339e
	clr.w	L133a4
	move.l	L37ca,L13392
	jsr	L133b4
	tst.w	L6bb8
	bne.s	L6772
	moveq	#$1f,d7
	movea.l	#$9970,a0
L6712
	tst.l	(a0)
	beq.s	L676c
	move.w	L648c,d0
	move.w	$80(a0),d1
	addi.w	#$400,d0
	addi.w	#$400,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L676c
	addi.w	#$50,d0
	cmp.w	d1,d0
	bcs.s	L676c
	move.w	L648e,d0
	cmp.w	$100(a0),d0
	bcc.s	L676c
	addi.w	#$2b,d0
	cmp.w	$100(a0),d0
	bcs.s	L676c
	move.w	#$1,L6496
	clr.l	(a0)
	subq.w	#1,L6498
	tst.w	L6498
	beq	L6f50
L676c
	addq.l	#4,a0
	dbra	d7,L6712
L6772
	tst.w	L6498
	bmi	L6f50
	tst.w	L7266
	beq	L680a
	tst.w	L7264
	bne.s	L680a
	move.w	L648c,d0
	move.w	L7268,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L680a
	addi.w	#$40,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L680a
	move.w	L648e,d0
	subi.w	#$5,d0
	cmp.w	L726c,d0
	bcc.s	L680a
	addi.w	#$29,d0
	move.w	L6e04,d1
	mulu.w	#$22,d1
	add.w	d1,d0
	cmp.w	L726c,d0
	bcs.s	L680a
	tst.w	L725e
	bne.s	L680a
	tst.w	L727a
	bne.s	L680a
	st	L7d8e
	addi.w	#$400,L648c
	andi.w	#$7ff,L648c
L680a
	tst.w	L74b6
	beq	L6898
	tst.w	L74b4
	bne.s	L6898
	move.w	L648c,d0
	move.w	L74b8,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L6898
	addi.w	#$40,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L6898
	move.w	L648e,d0
	subi.w	#$5,d0
	cmp.w	L74bc,d0
	bcc.s	L6898
	addi.w	#$29,d0
	move.w	L6e04,d1
	mulu.w	#$22,d1
	add.w	d1,d0
	cmp.w	L74bc,d0
	bcs.s	L6898
	tst.w	L74ae
	bne.s	L6898
	tst.w	L74ca
	bne.s	L6898
	addi.w	#$400,L648c
	andi.w	#$7ff,L648c
	st	L7d90
L6898
	move.w	L648c,d0
	sub.w	Le0ea,d0
	subi.w	#$4ba,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	L68b6
	eori.w	#$7ff,d0
L68b6
	andi.l	#$ffff,d0
	lsr.w	#4,d0
	addq.w	#5,d0
	cmpi.w	#$3f,d0
	bcs.s	L68ca
	move.w	#$3f,d0
L68ca
	cmp.l	L6486,d0
	bcs.s	L68d8
	move.l	d0,L6486
L68d8
	move.l	L6486,L1b3aa
	subq.w	#1,L64fa
	tst.w	L64fa
	bpl	L698a
	move.w	#$1e,L64fa
	tst.w	L1698
	bne	L698a
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L691a
	move.w	L74b4,d0
L691a
	tst.w	d0
	bne.s	L698a
	moveq	#$7,d0
	movea.l	#$649a,a0
L6926
	tst.b	(a0)
	beq.s	L6932
	addq.l	#2,a0
	dbra	d0,L6926
	bra.s	L698a


L6932
	st	(a0)
	move.w	#$fffd,$30(a0)
	move.w	L648c,d0
	move.w	L4f64,d1
	cmp.w	d0,d1
	bcs.s	L6950
	move.w	#$3,$30(a0)
L6950
	move.w	L648c,d0
	move.w	L648e,d1
	addi.w	#$1e,d0
	addi.w	#$2d,d1
	andi.w	#$7ff,d0
	move.w	d0,$10(a0)
	move.w	d1,$20(a0)
	move.w	#$204,$40(a0)
	move.w	#$6e,d1
	jsr	L1ad48
	andi.w	#$fffe,d0
	move.w	d0,$50(a0)
	nop
L698a
	moveq	#$7,d7
	movea.l	#$649a,a0
L6992
	tst.b	(a0)
	beq	L6b0c
	cmpi.b	#$0,$40(a0)
	beq.s	L69c8
	cmpi.b	#$4,$40(a0)
	beq.s	L69c8
	subq.b	#1,$41(a0)
	tst.b	$41(a0)
	bne.s	L69c8
	move.b	#$4,$41(a0)
	tst.w	$30(a0)
	bpl.s	L69c4
	subq.b	#1,$40(a0)
	bra.s	L69c8


L69c4
	addq.b	#1,$40(a0)
L69c8
	tst.w	L1698
	bne.s	L6a02
	move.w	Le126,d0
	addq.w	#1,d0
	tst.w	$30(a0)
	bpl.s	L69e0
	neg.w	d0
L69e0
	add.w	d0,$10(a0)
	andi.w	#$7ff,$10(a0)
	moveq	#$1,d0
	move.w	$20(a0),d1
	cmp.w	$50(a0),d1
	beq.s	L6a02
	bcc.s	L69fe
	add.w	d0,$20(a0)
	bra.s	L6a02


L69fe
	sub.w	d0,$20(a0)
L6a02
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L6a18
	move.w	L74b4,d0
L6a18
	tst.w	d0
	bne.s	L6a40
	tst.w	L1698
	bne.s	L6a40
	moveq	#$23,d1
	jsr	L1ad48
	cmpi.w	#$1,d0
	bne.s	L6a40
	movem.l	d7/a0,-(a7)
	jsr	L1185a
	movem.l	(a7)+,d7/a0
L6a40
	move.w	$10(a0),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L6a52
	addi.w	#$800,d0
L6a52
	cmpi.w	#$170,d0
	bcc	L6b0a
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$10,L1339a
	move.w	#$17,L1339c
	move.l	#$2e,L1339e
	move.w	#$1,L133a4
	move.b	L6f4f,d0
	andi.l	#$1,d0
	mulu.w	#$e6,d0
	add.l	L37ca,d0
	addi.l	#$24b8,d0
	move.l	d0,L1338e
	move.w	$10(a0),d0
	jsr	L7030
	move.w	d0,L13396
	move.w	$20(a0),L13398
	movem.l	d7/a0,-(a7)
	jsr	L133b4
	movem.l	(a7)+,d7/a0
	bra.s	L6b0c


L6b0a
	sf	(a0)
L6b0c
	addq.l	#2,a0
	dbra	d7,L6992
	addq.b	#1,L6f4f
	moveq	#$7,d7
	movea.l	#$649a,a0
L6b20
	tst.b	(a0)
	beq	L6bae
	move.w	$10(a0),d0
	move.w	L4f64,d1
	addi.w	#$400,d0
	addi.w	#$405,d1
	andi.w	#$7ff,d0
	andi.w	#$7ff,d1
	cmp.w	d1,d0
	bcc.s	L6bae
	addi.w	#$f,d0
	andi.w	#$7ff,d0
	cmp.w	d1,d0
	bcs.s	L6bae
	move.w	$20(a0),d0
	subi.w	#$5,d0
	cmp.w	L4f68,d0
	bcc.s	L6bae
	addi.w	#$15,d0
	cmp.w	L4f68,d0
	bcs.s	L6bae
	tst.w	L103ea
	beq.s	L6b96
	cmpi.w	#$1,L103ea
	beq.s	L6b96
	tst.w	L74ae
	bne.s	L6bae
	tst.w	L74ca
	bne.s	L6bae
	st	L7d90
	bra.s	L6bb4


L6b96
	tst.w	L725e
	bne.s	L6bae
	tst.w	L727a
	bne.s	L6bae
	st	L7d8e
	bra.s	L6bb4


L6bae
	addq.l	#2,a0
	dbra	d7,L6b20
L6bb4
	bra	L6c48


L6bb8
	dc.w	$000f,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$0014,$0020,$002b,$0039,$0007,$0014,$0020,$002b,$0039,$0007,$0014,$0020,$002b,$0039,$002c
	dc.w	$002c,$002c,$002c,$002c,$004d,$004d,$004d,$004d,$004d,$0068,$0068,$0068,$0068,$0068,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$fffc,$ffff,$0000
	dc.w	$0001,$0004,$fffc,$fffe,$0001,$0003,$0006
L6c46
	dc.w	$0000


L6c48
	moveq	#$0,d7
	movea.l	#$6bba,a0
L6c50
	cmpi.w	#$b4,$3c(a0)
	bcc	L6df4
	tst.w	(a0)
	bne.s	L6c62
	addq.w	#4,$3c(a0)
L6c62
	move.l	Le536,L1337a
	move.l	#$1b50,L13382
	move.w	#$170,L1337e
	move.w	#$98,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$98,L1338c
	move.w	#$10,L1339a
	move.w	#$22,L1339c
	move.l	#$44,L1339e
	move.w	#$1,L133a4
	eori.w	#$1,L6c46
	tst.w	L6c46
	beq.s	L6d0e
	cmpi.w	#$5,d7
	bcc.s	L6d0e
	move.w	$64(a0),$6e(a0)
	move.w	$5a(a0),$64(a0)
	moveq	#$2,d1
	jsr	L1ad48
	tst.w	d0
	bne.s	L6d04
	cmpi.w	#$4,$5a(a0)
	beq.s	L6d0a
L6cfe
	addq.w	#1,$5a(a0)
	bra.s	L6d0e


L6d04
	tst.w	$5a(a0)
	beq.s	L6cfe
L6d0a
	subq.w	#1,$5a(a0)
L6d0e
	cmpi.w	#$5,d7
	bcc.s	L6d30
	move.w	$5a(a0),d0
	mulu.w	#$154,d0
	add.l	L37ca,d0
	addi.l	#$10cc,d0
	move.l	d0,L1338e
	bra.s	L6d6c


L6d30
	cmpi.w	#$a,d7
	bcc.s	L6d52
	move.w	$5a(a0),d0
	mulu.w	#$154,d0
	add.l	L37ca,d0
	addi.l	#$1770,d0
	move.l	d0,L1338e
	bra.s	L6d6c


L6d52
	move.w	$5a(a0),d0
	mulu.w	#$154,d0
	add.l	L37ca,d0
	addi.l	#$1e14,d0
	move.l	d0,L1338e
L6d6c
	cmpi.w	#$5,d7
	bcc.s	L6d78
	move.w	$1e(a0),d0
	bra.s	L6dbc


L6d78
	cmpi.w	#$a,d7
	bcc.s	L6d94
	move.w	$50(a0),d0
	add.b	d0,d0
	movea.l	#$6c32,a1
	move.w	(a1,d0.w),d0
	add.w	$1e(a0),d0
	bra.s	L6dbc


L6d94
	move.w	$46(a0),d0
	add.b	d0,d0
	movea.l	#$6c32,a1
	move.w	(a1,d0.w),d0
	move.w	d0,d1
	move.w	$50(a0),d0
	add.b	d0,d0
	movea.l	#$6c3c,a1
	move.w	(a1,d0.w),d0
	add.w	$1e(a0),d0
	add.w	d1,d0
L6dbc
	add.w	L648c,d0
	andi.w	#$7ff,d0
	jsr	L7030
	move.w	d0,L13396
	move.w	$3c(a0),L13398
	move.w	L648e,d0
	add.w	d0,L13398
	movem.l	d7/a0,-(a7)
	jsr	L133b4
	movem.l	(a7)+,d7/a0
L6df4
	addq.l	#2,a0
	addq.w	#1,d7
	cmpi.w	#$f,d7
	bne	L6c50
	bra.s	L6e0a


L6e02
	dc.w	$0073
L6e04
	dc.w	$0002
L6e06
	dc.w	$0004
L6e08
	dc.w	$0004


L6e0a
	tst.w	L6bb8
	beq	L6f4c
	moveq	#$1f,d7
	movea.l	#$9970,a0
L6e1c
	tst.l	(a0)
	beq	L6f46
	move.w	L648c,d0
	move.w	$80(a0),d1
	cmp.w	d1,d0
	bcc	L6f46
	addi.w	#$20,d0
	cmp.w	d1,d0
	bcs	L6f46
	move.w	L6e02,d0
	cmp.w	$100(a0),d0
	bcc	L6f46
	addi.w	#$1e,d0
	cmp.w	$100(a0),d0
	bcs	L6f46
	clr.l	(a0)
	move.l	#$e322,Le248
	movem.l	d7/a0,-(a7)
	moveq	#$e,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a0
	subq.w	#1,L6e08
	tst.w	L6e08
	bne	L6f46
	move.l	a0,-(a7)
	movea.l	#$166dc,a0
	movea.l	L166c4,a1
	jsr	L1675e
	movea.l	(a7)+,a0
	move.w	#$3,L6e08
	tst.l	$180(a0)
	bmi.s	L6ef6
	movea.l	#$6bba,a1
	move.w	L6e04,d0
	mulu.w	#$a,d0
	ext.l	d0
	adda.l	d0,a1
	moveq	#$4,d0
L6ebc
	tst.w	(a1)
	beq.s	L6eee
	clr.w	(a1)
	subq.w	#1,L6bb8
	subq.w	#1,L6e06
	tst.w	L6e06
	bpl.s	L6f46
	move.w	#$4,L6e06
	subq.w	#1,L6e04
	subi.w	#$22,L6e02
	bra.s	L6f46


L6eee
	addq.l	#2,a1
	dbra	d0,L6ebc
	bra.s	L6f46


L6ef6
	movea.l	#$6bba,a1
	move.w	L6e04,d0
	mulu.w	#$a,d0
	ext.l	d0
	adda.l	d0,a1
	addq.l	#8,a1
	moveq	#$4,d0
L6f0e
	tst.w	(a1)
	beq.s	L6f40
	clr.w	(a1)
	subq.w	#1,L6bb8
	subq.w	#1,L6e06
	tst.w	L6e06
	bpl.s	L6f46
	move.w	#$4,L6e06
	subq.w	#1,L6e04
	subi.w	#$22,L6e02
	bra.s	L6f46


L6f40
	subq.l	#2,a1
	dbra	d0,L6f0e
L6f46
	addq.l	#4,a0
	dbra	d7,L6e1c
L6f4c
	rts


	dc.b	$00
L6f4f
	dc.b	$00


L6f50
	jsr	L6302
	movea.l	#$1674a,a0
	movea.l	L166c4,a1
	jsr	L1675e
	move.l	#$e2e4,Le248
	move.w	L648c,d0
	move.w	L648e,d1
	moveq	#$11,d2
	jsr	Ld66e
	move.w	L648c,d0
	move.w	L648e,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$10,d2
	jsr	Ld66e
	move.w	L648c,d0
	move.w	L648e,d1
	addi.w	#$12,d1
	moveq	#$f,d2
	jsr	Ld66e
	move.w	L648c,d0
	move.w	L648e,d1
	addi.w	#$12,d1
	addi.w	#$28,d0
	andi.w	#$7ff,d0
	moveq	#$e,d2
	jsr	Ld66e
	move.w	L648c,d0
	move.w	L648e,d1
	addi.w	#$9,d1
	addi.w	#$14,d0
	andi.w	#$7ff,d0
	moveq	#$1,d2
	jsr	Ld66e
	clr.w	L648a
	jsr	L7016
	moveq	#$17,d0
	jsr	L1ad18
	jmp	La04


L7014
	dc.w	$0000


L7016
	moveq	#$19,d0
	tst.w	L648a
	bne.s	L7028
	jsr	L1ad24
	rts


L7028
	jsr	L1ad18
	rts


L7030
	move.w	d0,d1
	sub.w	Le0ea,d0
	cmpi.w	#$400,d1
	bcs.s	L7052
	cmpi.w	#$170,Le0ea
	bcc.s	L7052
	subi.w	#$800,d0
	jmp	La04


L7052
	cmpi.w	#$400,Le0ea
	bcs.s	L7066
	cmpi.w	#$170,d1
	bcc.s	L7066
	addi.w	#$800,d0
L7066
	rts


L7068
	dc.b	$30
L7069
	dc.b	$30


L706a
	tst.w	L7266
	beq.s	L70be
	move.b	L37d5,d0
	cmp.b	L7068,d0
	beq.s	L70be
	addq.b	#1,L7068
	cmpi.b	#$3a,L7068
	bne.s	L7098
	move.b	#$30,L7068
L7098
	addq.w	#1,L7256
	addq.w	#1,L7258
	jsr	L3c8c
	moveq	#$12,d0
	jsr	L1ad18
	move.l	#$e250,Le24c
	bra.s	L706a


L70be
	tst.w	L74b6
	beq.s	L7112
	move.b	L37e1,d0
	cmp.b	L7069,d0
	beq.s	L7112
	addq.b	#1,L7069
	cmpi.b	#$3a,L7069
	bne.s	L70ec
	move.b	#$30,L7069
L70ec
	addq.w	#1,L74a6
	addq.w	#1,L74a8
	jsr	L3c8c
	moveq	#$12,d0
	jsr	L1ad18
	move.l	#$e272,Le24c
	bra.s	L70be


L7112
	rts


L7114
	cmpi.w	#$3,L103ea
	beq	L7218
	tst.w	L103ea
	beq.s	L7132
	cmpi.w	#$1,L103ea
	bne.s	L7176
L7132
	tst.w	L7264
	beq.s	L7176
	subq.w	#1,L7264
	bne.s	L7176
L7142
	tst.w	L7256
	beq.s	L7176
	IFND	INFINITE_LIVES
	subq.w	#1,L7256
	ELSE
	nop
	nop
	nop
	ENDC
	st	L9fd4
	jsr	L3c8c
	tst.w	L7256
	bne.s	L7176
	sf	L9fd4
	clr.w	L725e
	clr.w	L7266
L7176
	rts


L7178
	cmpi.w	#$3,L103ea
	beq.s	L71da
	tst.w	L103ea
	beq.s	L71d8
	cmpi.w	#$2,L103ea
	bne.s	L71d8
	tst.w	L74b4
	beq.s	L71d8
	subq.w	#1,L74b4
	bne.s	L71d8
L71a4
	tst.w	L74a6
	beq.s	L71d8
	subq.w	#1,L74a6
	st	L9fd6
	jsr	L3c8c
	tst.w	L74a6
	bne.s	L71d8
	sf	L9fd6
	clr.w	L74ae
	clr.w	L74b6
L71d8
	rts


L71da
	tst.w	L74b4
	beq.s	L7216
	subq.w	#1,L74b4
	bne.s	L7216
	tst.w	L7256
	bne.s	L71fc
	move.w	#$2,L74b4
	bra.s	L7216


L71fc
	IFND	INFINITE_LIVES
	subq.w	#1,L7256
	ELSE
	nop
	nop
	nop
	ENDC
	tst.w	L103ec
	bne.s	L7210
	st	L9fd6
L7210
	jsr	L3c8c
L7216
	rts


L7218
	tst.w	L7264
	beq.s	L7254
	subq.w	#1,L7264
	bne.s	L7254
	tst.w	L7256
	bne.s	L723a
	move.w	#$2,L7264
	bra.s	L7254


L723a
	IFND	INFINITE_LIVES
	subq.w	#1,L7256
	ELSE
	nop
	nop
	nop
	ENDC
	tst.w	L103ec
	bne.s	L724e
	st	L9fd4
L724e
	jsr	L3c8c
L7254
	rts


L7256
	dc.w	$0005
L7258
	dc.w	$0003
L725a
	dc.w	$0000
L725c
	dc.b	$00
L725d
	dc.b	$21
L725e
	dc.w	$0001
L7260
	dc.w	$0000
L7262
	dc.b	$00
L7263
	dc.b	$00
L7264
	dc.w	$0000
L7266
	dc.w	$0001
L7268
	dc.w	$00a0,$0000
L726c
	dc.w	$0000,$0000
L7270
	dc.w	$0000,$0000
L7274
	dc.w	$0000,$0000
L7278
	dc.w	$0001
L727a
	dc.w	$0000


L727c
	jsr	L9fe2
	tst.w	L7266
	bne.s	L729a
	move.w	L74b8,L7268
	jmp	La04


L729a
	move.w	Le126,d7
	subq.b	#1,d7
L72a2
	cmpi.b	#$1,L9fdb
	beq.s	L72c2
	cmpi.b	#$2,L9fdb
	beq.s	L72c2
	cmpi.b	#$3,L9fdb
	beq.s	L72c2
	bra.s	L72e8


L72c2
	clr.w	L7278
	tst.l	L7270
	bmi.s	L72dc
	cmpi.l	#$80000,L7270
	bcc.s	L732e
L72dc
	addi.l	#$5800,L7270
	bra.s	L732e


L72e8
	cmpi.b	#$5,L9fdb
	beq.s	L7308
	cmpi.b	#$6,L9fdb
	beq.s	L7308
	cmpi.b	#$7,L9fdb
	beq.s	L7308
	bra.s	L732e


L7308
	move.w	#$1,L7278
	tst.l	L7270
	bpl.s	L7324
	cmpi.l	#-$80000,L7270
	bcs.s	L732e
L7324
	subi.l	#$5800,L7270
L732e
	cmpi.b	#$3,L9fdb
	beq.s	L734e
	cmpi.b	#$4,L9fdb
	beq.s	L734e
	cmpi.b	#$5,L9fdb
	beq.s	L734e
	bra.s	L736e


L734e
	tst.l	L7274
	bmi.s	L7362
	cmpi.l	#$30000,L7274
	bcc.s	L73ac
L7362
	addi.l	#$8000,L7274
	bra.s	L73ac


L736e
	cmpi.b	#$7,L9fdb
	beq.s	L738e
	cmpi.b	#$0,L9fdb
	beq.s	L738e
	cmpi.b	#$1,L9fdb
	beq.s	L738e
	bra.s	L73ac


L738e
	tst.l	L7274
	bpl.s	L73a2
	cmpi.l	#-$30000,L7274
	bcs.s	L73ac
L73a2
	subi.l	#$8000,L7274
L73ac
	tst.l	L7270
	bpl.s	L73c0
	addi.l	#$1000,L7270
	bra.s	L73ca


L73c0
	subi.l	#$1000,L7270
L73ca
	tst.l	L7274
	bpl.s	L73de
	addi.l	#$100,L7274
	bra.s	L73e8


L73de
	subi.l	#$100,L7274
L73e8
	addi.l	#$800,L7274
	move.l	L7270,d0
	tst.l	d0
	bpl.s	L7402
	eori.l	#$ffffffff,d0
L7402
	cmpi.l	#$1000,d0
	bcc.s	L7410
	clr.l	L7270
L7410
	move.l	L7270,d0
	add.l	d0,L7268
	andi.l	#$7ffffff,L7268
	move.l	L7274,d0
	add.l	d0,L726c
	andi.l	#$ffffff,L726c
	cmpi.w	#$d2,L726c
	bcs.s	L7462
	clr.w	L726c
	move.l	L7274,d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,L7274
L7462
	cmpi.w	#$91,L726c
	bcs.s	L7490
	move.w	#$90,L726c
	move.l	L7274,d1
	lsr.l	#1,d1
	move.l	L7274,d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,L7274
L7490
	dbra	d7,L72a2
	tst.w	L726c
	bne.s	L74a4
	move.w	#$1,L726c
L74a4
	rts


L74a6
	dc.w	$0004
L74a8
	dc.w	$0003
L74aa
	dc.w	$0000
L74ac
	dc.b	$00
L74ad
	dc.b	$05
L74ae
	dc.w	$0001
L74b0
	dc.w	$0000
L74b2
	dc.b	$00
L74b3
	dc.b	$00
L74b4
	dc.w	$0000
L74b6
	dc.w	$0000
L74b8
	dc.w	$00a0,$0000
L74bc
	dc.w	$0000,$0000
L74c0
	dc.w	$0000,$0000
L74c4
	dc.w	$0000,$0000
L74c8
	dc.w	$0001
L74ca
	dc.w	$0000


L74cc
	tst.w	L74b6
	bne.s	L74e0
	move.w	L7268,L74b8
	rts


L74e0
	move.w	Le126,d7
	subq.b	#1,d7
L74e8
	cmpi.b	#$1,L9fdf
	beq.s	L7508
	cmpi.b	#$2,L9fdf
	beq.s	L7508
	cmpi.b	#$3,L9fdf
	beq.s	L7508
	bra.s	L752e


L7508
	clr.w	L74c8
	tst.l	L74c0
	bmi.s	L7522
	cmpi.l	#$80000,L74c0
	bcc.s	L7574
L7522
	addi.l	#$5800,L74c0
	bra.s	L7574


L752e
	cmpi.b	#$5,L9fdf
	beq.s	L754e
	cmpi.b	#$6,L9fdf
	beq.s	L754e
	cmpi.b	#$7,L9fdf
	beq.s	L754e
	bra.s	L7574


L754e
	move.w	#$1,L74c8
	tst.l	L74c0
	bpl.s	L756a
	cmpi.l	#-$80000,L74c0
	bcs.s	L7574
L756a
	subi.l	#$5800,L74c0
L7574
	cmpi.b	#$3,L9fdf
	beq.s	L7594
	cmpi.b	#$4,L9fdf
	beq.s	L7594
	cmpi.b	#$5,L9fdf
	beq.s	L7594
	bra.s	L75b4


L7594
	tst.l	L74c4
	bmi.s	L75a8
	cmpi.l	#$30000,L74c4
	bcc.s	L75f2
L75a8
	addi.l	#$8000,L74c4
	bra.s	L75f2


L75b4
	cmpi.b	#$7,L9fdf
	beq.s	L75d4
	cmpi.b	#$0,L9fdf
	beq.s	L75d4
	cmpi.b	#$1,L9fdf
	beq.s	L75d4
	bra.s	L75f2


L75d4
	tst.l	L74c4
	bpl.s	L75e8
	cmpi.l	#-$30000,L74c4
	bcs.s	L75f2
L75e8
	subi.l	#$8000,L74c4
L75f2
	tst.l	L74c0
	bpl.s	L7606
	addi.l	#$1000,L74c0
	bra.s	L7610


L7606
	subi.l	#$1000,L74c0
L7610
	tst.l	L74c4
	bpl.s	L7624
	addi.l	#$100,L74c4
	bra.s	L762e


L7624
	subi.l	#$100,L74c4
L762e
	addi.l	#$800,L74c4
	move.l	L74c0,d0
	tst.l	d0
	bpl.s	L7648
	eori.l	#$ffffffff,d0
L7648
	cmpi.l	#$1000,d0
	bcc.s	L7656
	clr.l	L74c0
L7656
	move.l	L74c0,d0
	add.l	d0,L74b8
	andi.l	#$7ffffff,L74b8
	move.l	L74c4,d0
	add.l	d0,L74bc
	andi.l	#$ffffff,L74bc
	cmpi.w	#$d2,L74bc
	bcs.s	L76a8
	clr.w	L74bc
	move.l	L74c4,d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,L74c4
L76a8
	cmpi.w	#$91,L74bc
	bcs.s	L76d6
	move.w	#$90,L74bc
	move.l	L74c4,d1
	lsr.l	#1,d1
	move.l	L74c4,d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,L74c4
L76d6
	dbra	d7,L74e8
	tst.w	L74bc
	bne.s	L76ea
	move.w	#$1,L74bc
L76ea
	rts


L76ec
	dc.w	$0000,$0000
L76f0
	dc.w	$0000


L76f2
	cmpi.w	#$3,L103ea
	beq	L78bc
	tst.w	L1698
	bne	L77e8
	tst.w	L103ea
	beq.s	L771a
	cmpi.w	#$1,L103ea
	bne.s	L7782
L771a
	tst.w	L76f0
	beq.s	L7776
	tst.w	L11de6
	bpl	L7776
	tst.w	L7278
	beq.s	L7748
	cmpi.w	#-$c4,L76ec
	beq.s	L775a
	subi.w	#$e,L76ec
	bra.s	L775a


L7748
	cmpi.w	#$c4,L76ec
	beq.s	L775a
	addi.w	#$e,L76ec
L775a
	move.l	L7268,d0
	add.l	L76ec,d0
	move.l	d0,L74b8
	andi.w	#$7ff,L74b8
	bra.s	L77e8


L7776
	move.l	L7268,L74b8
	bra.s	L77e8


L7782
	cmpi.w	#$2,L103ea
	bne.s	L77e8
	tst.w	L76f0
	beq.s	L77de
	tst.w	L74c8
	beq.s	L77b0
	cmpi.w	#-$c4,L76ec
	beq.s	L77c2
	subi.w	#$e,L76ec
	bra.s	L77c2


L77b0
	cmpi.w	#$c4,L76ec
	beq.s	L77c2
	addi.w	#$e,L76ec
L77c2
	move.l	L74b8,d0
	add.l	L76ec,d0
	move.l	d0,L7268
	andi.w	#$7ff,L7268
	bra.s	L77e8


L77de
	move.l	L74b8,L7268
L77e8
	move.w	L74b8,d0
	sub.w	L7268,d0
	andi.w	#$7ff,d0
	cmpi.w	#$168,d0
	bcs.s	L7802
	addi.w	#$800,d0
L7802
	lsr.w	#1,d0
	add.w	L7268,d0
	subi.w	#$b8,d0
	andi.w	#$7ff,d0
	move.w	d0,Le0ea
	movea.l	#$eeec,a0
	move.w	d0,d1
	lsr.w	#3,d0
	andi.l	#$fffe,d0
	addi.l	#$70a00,d0
	movea.l	#$ee5e,a1
	andi.w	#$f,d1
	eori.b	#$f,d1
	move.w	d1,d2
	lsl.w	#4,d2
	or.w	d2,d1
	move.w	d1,(a1)
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)
	swap	d0
	addi.l	#$12a0,d0
	move.w	d0,$e(a0)
	swap	d0
	move.w	d0,$a(a0)
	swap	d0
	addi.l	#$12a0,d0
	move.w	d0,$16(a0)
	swap	d0
	move.w	d0,$12(a0)
	swap	d0
	addi.l	#$12a0,d0
	move.w	d0,$1e(a0)
	swap	d0
	move.w	d0,$1a(a0)
	swap	d0
	addi.l	#$12a0,d0
	move.w	d0,$26(a0)
	swap	d0
	move.w	d0,$22(a0)
	movea.l	#$16603,a0
	adda.l	#$11b5,a0
	move.l	(a0),d0
	move.l	$a(a0),d1
	eor.l	d1,d0
	subi.l	#$56cd3323,d0
	tst.l	d0
	bne	L7802
	jmp	La04


L78bc
	move.w	L7264,d0
	or.w	L74b4,d0
	tst.w	d0
	beq	L77e8
	tst.w	L7264
	bne.s	L78e4
	move.l	L7268,L74b8
	bra	L77e8


L78e4
	move.l	L74b8,L7268
	bra	L77e8


	dc.w	$0006,$fca6,$0006,$fdbe,$0006,$fed6,$0006,$fd32,$0006,$fe4a,$0006,$ff62,$0006,$ffee,$0007,$0106
	dc.w	$0007,$021e,$0007,$007a,$0007,$0192,$0007,$02aa,$0007,$0336,$0007,$03ea,$0007,$049e,$0007,$03ea
	dc.w	$0007,$0552,$0007,$0606,$0007,$06ba,$0007,$0606
L7942
	dc.b	$00
L7943
	dc.b	$04
L7944
	dc.b	$00
L7945
	dc.b	$00

	dc.w	$0001,$000b


L794a
	eori.b	#$c,L7943
	addq.b	#1,L7945
	andi.b	#$3,L7945
	tst.w	L7266
	beq	L7b72
	tst.w	L7264
	bne	L7b72
	movea.l	Le536,a1
	movea.l	#$ffea,a3
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$1c3,d7
	move.w	#$0,$dff042
	move.w	L7268,d0
	sub.w	Le0ea,d0
	subq.w	#5,d0
	tst.w	d0
	bpl.s	L79ca
	addi.w	#$800,d0
L79ca
	cmpi.w	#$170,d0
	bcc	L7b72
	movea.l	a1,a2
	move.w	L726c,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	#$78f2,a5
	tst.w	L7278
	beq.s	L7a08
	movea.l	#$78fe,a5
L7a08
	cmpi.w	#-$1,L9fda
	beq.s	L7a18
	adda.w	L7942,a5
L7a18
	move.l	(a5),$dff050
	moveq	#$4,d1
L7a20
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7a20
	tst.w	L725e
	beq	L7adc
	move.w	#$243,d7
	move.w	L7268,d0
	sub.w	Le0ea,d0
	subq.w	#2,d0
	tst.w	L7278
	bne.s	L7a68
	addq.w	#1,d0
L7a68
	tst.w	d0
	bpl.s	L7a70
	addi.w	#$800,d0
L7a70
	movea.l	a1,a2
	move.w	L726c,d1
	subq.b	#1,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	#$7922,a5
	tst.w	L7278
	beq.s	L7aa8
	movea.l	#$7932,a5
L7aa8
	move.w	L7944,d0
	lsl.w	#2,d0
	adda.w	d0,a5
	move.l	(a5),$dff050
	moveq	#$4,d1
L7aba
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7aba
L7adc
	tst.w	L7260
	beq	L7b72
	move.w	#$82,d7
	move.w	L7268,d0
	sub.w	Le0ea,d0
	movea.l	#$7946,a0
	move.w	L7278,d1
	add.b	d1,d1
	add.w	(a0,d1.w),d0
	tst.w	d0
	bpl.s	L7b10
	addi.w	#$800,d0
L7b10
	movea.l	a1,a2
	move.w	L726c,d1
	addq.b	#6,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	move.l	#$7076e,$dff050
	move.w	#$2a,$dff066
	move.w	#$2a,$dff062
	moveq	#$4,d1
L7b50
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7b50
L7b72
	rts


L7b74
	tst.w	L74b6
	beq	L7d8c
	tst.w	L74b4
	bne	L7d8c
	movea.l	Le536,a1
	movea.l	#$ffea,a3
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$28,$dff066
	move.w	#$28,$dff062
	move.w	#$1c3,d7
	move.w	#$0,$dff042
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	subq.w	#5,d0
	tst.w	d0
	bpl.s	L7bde
	addi.w	#$800,d0
L7bde
	cmpi.w	#$170,d0
	bcc	L7d8c
	movea.l	a1,a2
	move.w	L74bc,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	#$790a,a5
	tst.w	L74c8
	beq.s	L7c1c
	movea.l	#$7916,a5
L7c1c
	cmpi.w	#-$1,L9fde
	beq.s	L7c2c
	adda.w	L7942,a5
L7c2c
	move.l	(a5),$dff050
	moveq	#$4,d1
L7c34
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7c34
	jsr	Leaae
	tst.w	L74ae
	beq	L7cf6
	move.w	#$243,d7
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	subq.w	#2,d0
	tst.w	L74c8
	bne.s	L7c82
	addq.w	#1,d0
L7c82
	tst.w	d0
	bpl.s	L7c8a
	addi.w	#$800,d0
L7c8a
	movea.l	a1,a2
	move.w	L74bc,d1
	subq.b	#1,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	#$7922,a5
	tst.w	L74c8
	beq.s	L7cc2
	movea.l	#$7932,a5
L7cc2
	move.w	L7944,d0
	lsl.w	#2,d0
	adda.w	d0,a5
	move.l	(a5),$dff050
	moveq	#$4,d1
L7cd4
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7cd4
L7cf6
	tst.w	L74b0
	beq	L7d8c
	move.w	#$82,d7
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	movea.l	#$7946,a0
	move.w	L74c8,d1
	add.b	d1,d1
	add.w	(a0,d1.w),d0
	tst.w	d0
	bpl.s	L7d2a
	addi.w	#$800,d0
L7d2a
	movea.l	a1,a2
	move.w	L74bc,d1
	addq.b	#6,d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	move.l	#$7076e,$dff050
	move.w	#$2a,$dff066
	move.w	#$2a,$dff062
	moveq	#$4,d1
L7d6a
	jsr	Leaae
	move.l	a2,$dff04c
	move.l	a2,$dff054
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L7d6a
L7d8c
	rts


L7d8e
	dc.w	$0000
L7d90
	dc.w	$0000


L7d92
	tst.w	L7266
	beq	L7f96
	tst.w	L7264
	bne	L7f96
	tst.w	L7d8e
	bne	L7e80
	move.w	L7268,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L7dc4
	addi.w	#$800,d0
L7dc4
	movea.l	#$ffea,a3
	movea.l	#$64544,a5
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a5
	move.w	L726c,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	adda.w	(a3,d1.w),a5
	tst.b	(a5)
	bne.s	L7df2
	addq.l	#1,a5
	tst.b	(a5)
	bne.s	L7df2
L7df0
	rts


L7df2
	movea.l	#$b944,a0
	adda.l	#$603,a0
	clr.w	d1
	move.b	(a5),d1
	lsl.w	#2,d1
	move.b	(a0,d1.w),d0
	cmpi.b	#$18,d0
	beq	L7fd2
	cmpi.b	#$19,d0
	beq	L8028
	cmpi.b	#$1a,d0
	beq	L807e
	cmpi.b	#$e,d0
	beq	L7f96
	cmpi.b	#$20,d0
	beq	L7f96
	cmpi.b	#$29,d0
	beq	L7f96
	cmpi.b	#$28,d0
	beq	L7f96
	cmpi.b	#$2b,d0
	beq	L7f96
	cmpi.b	#$2a,d0
	beq	L8058
	cmpi.b	#$2f,d0
	beq	L80aa
	andi.b	#$f8,d0
	cmpi.b	#$10,d0
	beq	L7f98
	tst.w	L725e
	bne.s	L7df0
	tst.w	L727a
	bne	L7df0
	tst.w	L103ec
	bne	L7df0
L7e80
	move.l	L7268,L9434
	move.l	L726c,L9438
	jsr	L943c
	move.w	#$46,L7264
	clr.w	L7d8e
	jsr	L10900
	cmpi.w	#$3,L103ea
	beq.s	L7ed2
	cmpi.w	#$1,L7256
	bne.s	L7ed2
	jsr	L7142
	move.b	#$1,d0
	jsr	L11de8
L7ed2
	cmpi.w	#$1,L9bf0
	beq.s	L7ee2
	subq.w	#1,L9bf0
L7ee2
	clr.w	L9fd4
	move.l	#$e32e,Le248
	tst.w	L7260
	beq.s	L7f3a
	move.l	L7268,d0
	addi.l	#$50000,d0
	move.l	L726c,d1
	clr.l	d2
	move.w	L7262,d2
	clr.w	Lb8c8
	jsr	L11a90
	tst.w	d7
	bmi.s	L7f32
	move.l	#$100,$e00(a0)
	clr.w	L7260
L7f32
	move.w	#$1,Lb8c8
L7f3a
	tst.w	L103ea
	beq.s	L7f8e
	cmpi.w	#$3,L103ea
	beq.s	L7f8e
	tst.w	L74a6
	beq.s	L7f8e
	move.w	#$2,L103ea
	move.l	#$37dc,L166c4
	movea.l	#$64c70,a1
	movea.l	#$65ff8,a2
	jsr	L8456
	jsr	L5462
	jsr	L4cf2
	move.b	#$2,d0
	jsr	L11d7e
L7f8e
	moveq	#$1d,d0
	jsr	L1ad18
L7f96
	rts


L7f98
	tst.w	L7260
	bne.s	L7fd0
	tst.w	L4b78
	beq.s	L7fd0
	move.b	(a0,d1.w),d0
	move.b	d0,L7263
	move.w	d1,L7260
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	jsr	L844a
	moveq	#$f,d0
	jsr	L1ad18
L7fd0
	rts


L7fd2
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	clr.b	d0
	cmpi.w	#$3,L9bf0
	beq.s	L7ff6
	st	d0
	addq.w	#1,L9bf0
L7ff6
	subq.w	#1,L10aa8
	tst.b	d0
	bne.s	L801e
	ext.l	d1
	adda.l	d1,a0
	jsr	L11760
	movea.l	#$16736,a0
	movea.l	L166c4,a1
	jsr	L1675e
	rts


L801e
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L8028
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	addq.w	#1,L725a
	jsr	L3c8c
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	jmp	La04


L8058
	jsr	L844a
	subq.w	#1,L10aa8
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	jsr	L109da
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L807e
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	move.w	#$208,L9bf4
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	jmp	La04


L80aa
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	move.w	#$406,L727a
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	cmpi.w	#$3,L103ea
	beq.s	L80e0
	clr.w	L725e
L80e0
	rts


L80e2
	tst.w	L74b6
	beq	L82e6
	tst.w	L74b4
	bne	L82e6
	tst.w	L7d90
	bne	L81d0
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L8114
	addi.w	#$800,d0
L8114
	movea.l	#$ffea,a3
	movea.l	#$64544,a5
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a5
	move.w	L74bc,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	adda.w	(a3,d1.w),a5
	tst.b	(a5)
	bne.s	L8142
	addq.l	#1,a5
	tst.b	(a5)
	bne.s	L8142
L8140
	rts


L8142
	movea.l	#$b944,a0
	adda.l	#$603,a0
	clr.w	d1
	move.b	(a5),d1
	lsl.w	#2,d1
	move.b	(a0,d1.w),d0
	cmpi.b	#$18,d0
	beq	L8322
	cmpi.b	#$19,d0
	beq	L837c
	cmpi.b	#$1a,d0
	beq	L83ce
	cmpi.b	#$e,d0
	beq	L82e6
	cmpi.b	#$20,d0
	beq	L82e6
	cmpi.b	#$29,d0
	beq	L82e6
	cmpi.b	#$28,d0
	beq	L82e6
	cmpi.b	#$2b,d0
	beq	L82e6
	cmpi.b	#$2a,d0
	beq	L83f6
	cmpi.b	#$2f,d0
	beq	L841c
	andi.b	#$f8,d0
	cmpi.b	#$10,d0
	beq	L82e8
	tst.w	L74ae
	bne.s	L8140
	tst.w	L74ca
	bne	L8140
	tst.w	L103ec
	bne	L8140
L81d0
	move.l	L74b8,L9434
	move.l	L74bc,L9438
	jsr	L943c
	move.w	#$46,L74b4
	clr.w	L7d90
	jsr	L10900
	cmpi.w	#$3,L103ea
	beq.s	L8222
	cmpi.w	#$1,L74a6
	bne.s	L8222
	jsr	L71a4
	move.b	#$2,d0
	jsr	L11de8
L8222
	cmpi.w	#$1,L9bf2
	beq.s	L8232
	subq.w	#1,L9bf2
L8232
	clr.w	L9fd6
	move.l	#$e32e,Le248
	tst.w	L74b0
	beq.s	L828a
	move.l	L74b8,d0
	addi.l	#$50000,d0
	move.l	L74bc,d1
	clr.l	d2
	move.w	L74b2,d2
	clr.w	Lb8c8
	jsr	L11a90
	tst.w	d7
	bmi.s	L8282
	move.l	#$100,$e00(a0)
	clr.w	L74b0
L8282
	move.w	#$1,Lb8c8
L828a
	tst.w	L103ea
	beq.s	L82de
	cmpi.w	#$3,L103ea
	beq.s	L82de
	tst.w	L7256
	beq.s	L82de
	move.w	#$1,L103ea
	move.l	#$37d0,L166c4
	movea.l	#$65ff8,a1
	movea.l	#$64c70,a2
	jsr	L8456
	jsr	L5462
	jsr	L4cf2
	move.b	#$1,d0
	jsr	L11d7e
L82de
	moveq	#$1d,d0
	jsr	L1ad18
L82e6
	rts


L82e8
	tst.w	L74b0
	bne.s	L8320
	tst.w	L4b78
	beq.s	L8320
	move.b	(a0,d1.w),d0
	move.b	d0,L74b3
	move.w	d1,L74b0
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	jsr	L844a
	moveq	#$f,d0
	jsr	L1ad18
L8320
	rts


L8322
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	clr.b	d0
	cmpi.w	#$3,L9bf2
	beq.s	L8346
	st	d0
	addq.w	#1,L9bf2
L8346
	subq.w	#1,L10aa8
	tst.b	d0
	bne.s	L836e
	ext.l	d1
	adda.l	d1,a0
	jsr	L11760
	movea.l	#$16736,a0
	movea.l	L166c4,a1
	jsr	L1675e
	rts


L836e
	moveq	#$1a,d0
	jsr	L1ad18
	jmp	La04


L837c
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	cmpi.w	#$3,L103ea
	beq.s	L83b2
	addq.w	#1,L74aa
	jsr	L3c8c
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L83b2
	addq.w	#1,L725a
	jsr	L3c8c
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L83ce
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	move.w	#$208,L9bf6
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L83f6
	jsr	L844a
	subq.w	#1,L10aa8
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	jsr	L109da
	moveq	#$1a,d0
	jsr	L1ad18
	rts


L841c
	jsr	L844a
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	move.w	#$406,L74ca
	subq.w	#1,L10aa8
	moveq	#$1a,d0
	jsr	L1ad18
	clr.w	L74ae
	rts


L844a
	suba.l	#$603,a0
	clr.l	(a0,d1.w)
	rts


L8456
	movea.l	#$b944,a0
	move.w	#$47f,d0
L8460
	move.l	(a0)+,(a1)+
	dbra	d0,L8460
	move.w	L10aa8,(a1)+
	move.w	L4b7a,(a1)+
	move.w	L4b78,(a1)+
	move.w	L116ac,(a1)+
	move.w	L10aa2,(a1)+
	move.w	L10d20,(a1)+
	move.w	L10d1e,(a1)+
	move.w	L10d22,(a1)+
	move.w	L103ec,(a1)+
	move.w	L11b2c,(a1)+
	move.w	L103f6,(a1)+
	move.w	L11640,(a1)+
	move.w	L11554,(a1)+
	move.w	L11602,(a1)+
	move.w	L10aa6,(a1)+
	move.w	L114f0,(a1)+
	move.w	L11412,(a1)+
	move.w	L11b2e,(a1)+
	move.w	L1040e,(a1)+
	move.w	L4b90,(a1)+
	move.w	L11c2c,(a1)+
	move.w	L4f7a,(a1)+
	move.w	L4f7c,(a1)+
	move.w	L4f7e,(a1)+
	move.w	L4f80,(a1)+
	move.w	L4f82,(a1)+
	move.w	L4f84,(a1)+
	move.w	L4f86,(a1)+
	move.w	L4f88,(a1)+
	move.w	L5532,(a1)+
	move.w	L5534,(a1)+
	move.w	L5536,(a1)+
	move.w	L5538,(a1)+
	move.w	L553a,(a1)+
	move.w	L553c,(a1)+
	move.w	L553e,(a1)+
	move.w	L5540,(a1)+
	move.w	L5f48,(a1)+
	move.w	L5542,(a1)+
	move.l	L5548,(a1)+
	move.w	L10d28,(a1)+
	move.w	L10d24,(a1)+
	move.w	L10d26,(a1)+
	move.w	L648a,(a1)+
	move.w	L648c,(a1)+
	move.w	L648e,(a1)+
	move.w	L6490,(a1)+
	move.w	L6492,(a1)+
	move.w	L6494,(a1)+
	move.w	L6496,(a1)+
	move.w	L6498,(a1)+
	move.w	L6bb8,(a1)+
	move.w	L6e02,(a1)+
	move.w	L6e04,(a1)+
	move.w	L6e06,(a1)+
	move.w	L6e08,(a1)+
	move.w	L7014,(a1)+
	move.w	L11706,(a1)+
	movea.l	#$6bba,a4
	moveq	#$e,d0
L85ca
	move.w	(a4)+,(a1)+
	dbra	d0,L85ca
	movea.l	#$6bf6,a4
	moveq	#$e,d0
L85d8
	move.w	(a4)+,(a1)+
	dbra	d0,L85d8
	moveq	#$17,d0
	movea.l	#$10aaa,a0
L85e6
	move.w	(a0)+,(a1)+
	dbra	d0,L85e6
	movea.l	#$b944,a1
	move.w	#$47f,d0
L85f6
	move.l	(a2)+,(a1)+
	dbra	d0,L85f6
	move.w	(a2)+,L10aa8
	move.w	(a2)+,L4b7a
	move.w	(a2)+,L4b78
	move.w	(a2)+,L116ac
	move.w	(a2)+,L10aa2
	move.w	(a2)+,L10d20
	move.w	(a2)+,L10d1e
	move.w	(a2)+,L10d22
	move.w	(a2)+,L103ec
	move.w	(a2)+,L11b2c
	move.w	(a2)+,L103f6
	move.w	(a2)+,L11640
	move.w	(a2)+,L11554
	move.w	(a2)+,L11602
	move.w	(a2)+,L10aa6
	move.w	(a2)+,L114f0
	move.w	(a2)+,L11412
	move.w	(a2)+,L11b2e
	move.w	(a2)+,L1040e
	move.w	(a2)+,L4b90
	move.w	(a2)+,L11c2c
	move.w	(a2)+,L4f7a
	move.w	(a2)+,L4f7c
	move.w	(a2)+,L4f7e
	move.w	(a2)+,L4f80
	move.w	(a2)+,L4f82
	move.w	(a2)+,L4f84
	move.w	(a2)+,L4f86
	move.w	(a2)+,L4f88
	move.w	(a2)+,L5532
	move.w	(a2)+,L5534
	move.w	(a2)+,L5536
	move.w	(a2)+,L5538
	move.w	(a2)+,L553a
	move.w	(a2)+,L553c
	move.w	(a2)+,L553e
	move.w	(a2)+,L5540
	move.w	(a2)+,L5f48
	move.w	(a2)+,L5542
	move.l	(a2)+,L5548
	move.w	(a2)+,L10d28
	move.w	(a2)+,L10d24
	move.w	(a2)+,L10d26
	move.w	(a2)+,L648a
	move.w	(a2)+,L648c
	move.w	(a2)+,L648e
	move.w	(a2)+,L6490
	move.w	(a2)+,L6492
	move.w	(a2)+,L6494
	move.w	(a2)+,L6496
	move.w	(a2)+,L6498
	move.w	(a2)+,L6bb8
	move.w	(a2)+,L6e02
	move.w	(a2)+,L6e04
	move.w	(a2)+,L6e06
	move.w	(a2)+,L6e08
	move.w	(a2)+,L7014
	move.w	(a2)+,L11706
	movea.l	#$6bba,a4
	moveq	#$e,d0
L8760
	move.w	(a2)+,(a4)+
	dbra	d0,L8760
	movea.l	#$6bf6,a4
	moveq	#$e,d0
L876e
	move.w	(a2)+,(a4)+
	dbra	d0,L876e
	moveq	#$17,d0
	movea.l	#$10aaa,a1
L877c
	move.w	(a2)+,(a1)+
	dbra	d0,L877c
	jmp	La04


L8788
	subi.b	#-$79,d0
L878c
	tst.w	L7260
	beq.s	L87de
	cmpi.w	#$2b,L726c
	bcs.s	L87de
	move.w	L8788,d0
	cmp.w	L7268,d0
	bcc.s	L87de
	addi.w	#$18,d0
	cmp.w	L7268,d0
	bcs.s	L87de
	clr.w	L7260
	subq.w	#1,L4b78
	addq.w	#1,L4b7a
	jsr	L4cf2
	subq.w	#1,L10aa8
	moveq	#$10,d0
	jsr	L1ad18
L87de
	tst.w	L74b0
	beq.s	L8830
	cmpi.w	#$2b,L74bc
	bcs.s	L8830
	move.w	L8788,d0
	cmp.w	L74b8,d0
	bcc.s	L8830
	addi.w	#$10,d0
	cmp.w	L74b8,d0
	bcs.s	L8830
	clr.w	L74b0
	subq.w	#1,L4b78
	addq.w	#1,L4b7a
	jsr	L4cf2
	subq.w	#1,L10aa8
	moveq	#$10,d0
	jsr	L1ad18
L8830
	rts


L8832	dc.w	$0000
L8834	ds.w	6*256


L9434
	dc.w	$0000,$0000
L9438
	dc.w	$0000,$0000


L943c
	jsr	L5f4a
	tst.w	L8832
	bne	L94d6
	move.w	#$64,L8832
	move.w	#$ff,d7
	move.l	#$220d0,d1
	moveq	#$0,d0
	lea	L10aa4+$84,a2
	move.w	-$84(a2),d0
	lsr.l	d0,d1
	movea.l	d1,a2
	movea.l	#$447c6,a3
L9474
	move.l	L9434,(a2)
	move.l	L9438,$400(a2)
	moveq	#$b,d1
	jsr	L1ad48
	move.w	d0,d2
	swap	d2
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d2
	subi.l	#$50000,d2
	add.l	L7270,d2
	move.l	d2,$800(a2)
	moveq	#$a,d1
	jsr	L1ad48
	move.w	d0,d2
	swap	d2
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d2
	subi.l	#$80000,d2
	move.l	d2,(a3)
	addq.l	#4,a2
	addq.l	#4,a3
	dbra	d7,L9474
L94d6
	IFND	PROTECTION_DISABLED
	cmpi.w	#$6600,L15aa4
	bne.s	L950e
	ELSE
	nop
	nop
	nop
	nop
	nop
	ENDC
	pea	La04
	rts


L94e8
	tst.w	L8832
	beq	L95b6
	subq.w	#1,L8832
	movea.l	#$ffea,a3
	move.w	#$ff,d7
	movea.l	#L8834,a0
	movea.l	#$447c6,a4
L950e
	move.l	$800(a0),d0
	add.l	d0,(a0)
	addi.l	#$4000,(a4)
	move.l	(a4),d0
	add.l	d0,$400(a0)
	move.w	(a0),d4
	sub.w	Le0ea,d4
	tst.w	d0
	bpl.s	L9530
	addi.w	#$800,d4
L9530
	move.w	$400(a0),d5
	andi.w	#$7ff,d4
	cmpi.w	#$16f,d4
	bcc.s	L95a0
	cmpi.w	#$97,d5
	bcc.s	L95a0
	movea.l	Le536,a2
	clr.l	d0
	move.w	d5,d0
	add.w	d0,d0
	adda.w	(a3,d0.w),a2
	move.w	d4,d0
	lsr.w	#3,d0
	adda.w	d0,a2
	move.w	d4,d1
	andi.w	#$7,d1
	eori.b	#$7,d1
	move.b	$dff006,d2
	bne	L9572
	move.b	#$1,d2
L9572
	clr.b	d0
	bset	d1,d0
	addq.b	#1,d1
	bset	d1,d0
	lsr.b	#1,d2
	bcc.s	L9580
	move.b	d0,(a2)
L9580
	lsr.b	#1,d2
	bcc.s	L9588
	move.b	d0,$1b50(a2)
L9588
	lsr.b	#1,d2
	bcc.s	L9590
	move.b	d0,$36a0(a2)
L9590
	lsr.b	#1,d2
	bcc.s	L9598
	move.b	d0,$51f0(a2)
L9598
	lsr.b	#1,d2
	bcc.s	L95a0
	move.b	d0,$6d40(a2)
L95a0
	addq.l	#4,a0
	addq.l	#4,a4
	dbra	d7,L950e
	tst.w	L8832
	bne.s	L95b6
	clr.b	Lfde4
L95b6
	rts


L95b8
	dc.w	$0000
L95ba
	dc.w	$0000
L95bc
	dc.w	$0001


L95be
	tst.w	L8832
	bne	L9670
	tst.w	L95bc
	beq	L9672
	tst.w	L1698
	bne	L9672
	cmpi.b	#$70,Lfde4
	beq.s	L95f2
	cmpi.b	#$20,Lfde4
	beq.s	L95f2
	bra.s	L95f8


L95f2
	clr.b	Lfde4
L95f8
	tst.w	L103ea
	beq.s	L960a
	cmpi.w	#$2,L103ea
	beq.s	L963e
L960a
	move.b	Lfde4,d0
	beq	L96a6
	move.w	L9fdc,-(a7)
	move.w	#$ffff,L9fdc
	clr.b	Lfde4
	move.w	#$1e,L95b8
	jsr	L9672
	move.w	(a7)+,L9fdc
	rts


L963e
	move.b	Lfde4,d0
	beq	L96f4
	move.w	L9fe0,-(a7)
	move.w	#$ffff,L9fe0
	clr.b	Lfde4
	move.w	#$1e,L95ba
	jsr	L9672
	move.w	(a7)+,L9fe0
L9670
	rts


L9672
	tst.w	L7258
	beq.s	L96a6
	tst.w	L9fdc
	beq.s	L96a6
	move.w	Le126,d0
	add.w	d0,L95b8
	cmpi.w	#$10,L95b8
	bcc.s	L969a
	bra.s	L96ac


L969a
	IFND	INFINITE_SMART_BOMBS
	subq.w	#1,L7258
	ELSE
	nop
	nop
	nop
	ENDC
	jsr	L9742
L96a6
	clr.w	L95b8
L96ac
	cmpi.w	#$3,L103ea
	beq.s	L96fc
	tst.w	L74a8
	beq.s	L96f4
	tst.w	L9fe0
	beq.s	L96f4
	move.w	Le126,d0
	add.w	d0,L95ba
	cmpi.w	#$10,L95ba
	bcc.s	L96de
	rts


L96de
	cmpi.w	#$3,L103ea
	beq.s	L96fc
	subq.w	#1,L74a8
	jsr	L9742
L96f4
	clr.w	L95ba
	rts


L96fc
	tst.w	L95bc
	bne	L9670
	tst.w	L7258
	beq.s	L973a
	tst.w	L9fe0
	beq.s	L973a
	move.w	Le126,d0
	add.w	d0,L95ba
	cmpi.w	#$10,L95ba
	bcc.s	L972e
	rts


L972e
	subq.w	#1,L7258
	jsr	L9742
L973a
	clr.w	L95ba
	rts


L9742
	jsr	L13b88
	move.l	#$e350,Le248
	jsr	L3c8c
	tst.w	L11b2c
	bne	L996e
	move.w	L4f7c,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L9776
	addi.w	#$800,d0
L9776
	cmpi.w	#$170,d0
	bcc.s	L9782
	subq.w	#5,L4f88
L9782
	move.w	L5534,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L9796
	addi.w	#$800,d0
L9796
	cmpi.w	#$170,d0
	bcc.s	L97a2
	subq.w	#5,L5540
L97a2
	moveq	#$7f,d7
	movea.l	#$b944,a0
L97aa
	tst.l	(a0)
	beq	L9960
	tst.w	$1002(a0)
	bne	L9960
	move.b	$603(a0),d0
	cmpi.b	#$18,d0
	beq	L9960
	cmpi.b	#$19,d0
	beq	L9960
	cmpi.b	#$1a,d0
	beq	L9960
	cmpi.b	#$e,d0
	beq	L9960
	cmpi.b	#$20,d0
	beq	L9960
	cmpi.b	#$29,d0
	beq	L9960
	cmpi.b	#$2a,d0
	beq	L9960
	cmpi.b	#$2f,d0
	beq	L9960
	cmpi.b	#$28,d0
	beq	L9960
	cmpi.b	#$2b,d0
	beq	L9960
	andi.b	#$f8,d0
	cmpi.b	#$10,d0
	beq	L9960
	cmpi.b	#$4,$603(a0)
	bne.s	L983c
	movea.l	#$4b18,a2
	move.w	$c00(a0),d1
	lsl.w	#2,d1
	clr.b	$40(a2,d1.w)
	movea.l	$20(a2,d1.w),a2
	move.l	#$100,$e00(a2)
L983c
	move.w	$200(a0),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L984e
	addi.w	#$800,d0
L984e
	cmpi.w	#$170,d0
	bcc	L9960
	move.l	a0,-(a7)
	movea.l	#$cde4,a5
	move.w	$602(a0),d2
	lsl.b	#2,d2
	movea.l	(a5,d2.w),a0
	movea.l	L166c4,a1
	jsr	L1675e
	movea.l	(a7)+,a0
	clr.l	(a0)
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	move.w	$602(a0),d2
	movem.l	d7/a0,-(a7)
	movea.l	#$cb44,a0
	add.b	d2,d2
	move.w	(a0,d2.w),d2
	jsr	Ld66e
	subq.w	#1,L10aa8
	movem.l	(a7)+,d7/a0
	cmpi.b	#$2d,$603(a0)
	beq.s	L98b2
	jsr	L116ae
L98b2
	cmpi.b	#$1f,$603(a0)
	bne.s	L98c0
	jsr	L11708
L98c0
	cmpi.b	#$5,$603(a0)
	bne.s	L98ea
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	jsr	L11604
	subq.w	#1,L11c2c
	movem.l	d7/a0,-(a7)
	jsr	L11d5e
	movem.l	(a7)+,d7/a0
L98ea
	cmpi.b	#$2,$603(a0)
	bne.s	L9960
	jsr	L11642
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	moveq	#$3,d2
	subq.w	#5,d1
	movem.l	d0-d1/d7/a0,-(a7)
	jsr	Ld66e
	movem.l	(a7)+,d0-d1/d7/a0
	moveq	#$3,d2
	addq.w	#5,d0
	addq.w	#5,d1
	movem.l	d0-d1/d7/a0,-(a7)
	jsr	Ld66e
	movem.l	(a7)+,d0-d1/d7/a0
	moveq	#$3,d2
	subq.w	#5,d0
	addq.w	#5,d1
	movem.l	d0-d1/d7/a0,-(a7)
	jsr	Ld66e
	movem.l	(a7)+,d0-d1/d7/a0
	moveq	#$3,d2
	subq.w	#5,d1
	subq.w	#5,d0
	movem.l	d0-d1/d7/a0,-(a7)
	jsr	Ld66e
	movem.l	(a7)+,d0-d1/d7/a0
	movem.l	d0-d1/d7/a0,-(a7)
	swap	d0
	swap	d1
	jsr	L11a52
	movem.l	(a7)+,d0-d1/d7/a0
L9960
	addq.l	#4,a0
	dbra	d7,L97aa
	moveq	#$13,d0
	jsr	L1ad18
L996e
	rts


L9970	dc.w	$0000,$0000
L9974	ds.w	62

L99f0	dc.w	$0000,$0000
L99f4	ds.w	62

L9a70	dc.w	$0000,$0000
L9a74	ds.w	62

L9af0	dc.w	$0000,$0000
L9af4	ds.w	62

L9b70	dc.w	$0000,$0000
L9b74	ds.w	62

L9bf0	dc.w	$0001
L9bf2	dc.w	$0001
L9bf4	dc.w	$0000
L9bf6	dc.w	$0000,$ba54,$c05f,$ffa0,$ffff,$ffff,$2a50,$fa03,$05ff,$ffff,$ffff
L9c0c	dc.w	$0000
L9c0e	dc.w	$0000,$0000


L9c12
	tst.w	L9bf4
	beq.s	L9c22
	tst.w	L9fdc
	bne.s	L9c32
L9c22
	move.w	L9fdc,d0
	cmp.w	L9c0c,d0
	beq	L9d5e
L9c32
	move.w	d0,L9c0c
	tst.w	Le0ec
	bne	L9c48
	tst.w	d0
	beq	L9d5e
L9c48
	tst.w	L9bf4
	beq.s	L9c56
	subq.w	#1,L9bf4
L9c56
	moveq	#$1,d0
	jsr	L1ad18
	cmpi.w	#$1,L9bf0
	bne.s	L9c72
	jsr	L9cde
	bra	L9d5e


L9c72
	cmpi.w	#$2,L9bf0
	bne.s	L9ca6
	subi.w	#$3,L726c
	jsr	L9cde
	addi.w	#$6,L726c
	jsr	L9cde
	subi.w	#$3,L726c
	jmp	L9d5e


L9ca6
	subi.w	#$8,L726c
	jsr	L9cde
	addi.w	#$8,L726c
	jsr	L9cde
	addi.w	#$8,L726c
	jsr	L9cde
	subi.w	#$8,L726c
	jmp	L9d5e


L9cde
	movea.l	#$9970,a0
	moveq	#$1f,d7
L9ce6
	tst.l	(a0)
	bne.s	L9d58
	st	(a0)
	move.l	L7268,$80(a0)
	subi.l	#$80000,$80(a0)
	move.l	L726c,$100(a0)
	addi.l	#$50000,$100(a0)
	tst.w	$100(a0)
	bpl.s	L9d16
	sf	(a0)
	bra.s	L9d5e


L9d16
	cmpi.w	#$97,$100(a0)
	bcs.s	L9d24
	move.w	#$96,$100(a0)
L9d24
	move.l	L7270,$180(a0)
	tst.w	L7278
	beq.s	L9d3e
	subi.l	#$70000,$180(a0)
	bra.s	L9d4e


L9d3e
	addi.l	#$100000,$80(a0)
	addi.l	#$70000,$180(a0)
L9d4e
	move.l	#$28,$200(a0)
	bra.s	L9d5e


L9d58
	addq.l	#4,a0
	dbra	d7,L9ce6
L9d5e
	tst.w	L9bf6
	beq.s	L9d6e
	tst.w	L9fe0
	bne.s	L9d7e
L9d6e
	move.w	L9fe0,d0
	cmp.w	L9c0e,d0
	beq	L9eae
L9d7e
	move.w	d0,L9c0e
	tst.w	Le0ec
	bne	L9d94
	tst.w	d0
	beq	L9eae
L9d94
	tst.w	L9bf6
	beq.s	L9da2
	subq.w	#1,L9bf6
L9da2
	move.l	#$1,d0
	jsr	L1ad18
	cmpi.w	#$1,L9bf2
	bne.s	L9dc2
	jsr	L9e2e
	bra	L9eae


L9dc2
	cmpi.w	#$2,L9bf2
	bne.s	L9df6
	subi.w	#$3,L74bc
	jsr	L9e2e
	addi.w	#$6,L74bc
	jsr	L9e2e
	subi.w	#$3,L74bc
	jmp	L9eae


L9df6
	subi.w	#$6,L74bc
	jsr	L9e2e
	addi.w	#$6,L74bc
	jsr	L9e2e
	addi.w	#$6,L74bc
	jsr	L9e2e
	subi.w	#$6,L74bc
	jmp	L9eae


L9e2e
	movea.l	#$9970,a0
	moveq	#$1f,d7
L9e36
	tst.l	(a0)
	bne.s	L9ea8
	st	(a0)
	move.l	L74b8,$80(a0)
	subi.l	#$80000,$80(a0)
	move.l	L74bc,$100(a0)
	addi.l	#$50000,$100(a0)
	tst.w	$100(a0)
	bpl.s	L9e66
	sf	(a0)
	bra.s	L9eae


L9e66
	cmpi.w	#$97,$100(a0)
	bcs.s	L9e74
	move.w	#$96,$100(a0)
L9e74
	move.l	L74c0,$180(a0)
	tst.w	L74c8
	beq.s	L9e8e
	subi.l	#$70000,$180(a0)
	bra.s	L9e9e


L9e8e
	addi.l	#$100000,$80(a0)
	addi.l	#$70000,$180(a0)
L9e9e
	move.l	#$28,$200(a0)
	rts


L9ea8
	addq.l	#4,a0
	dbra	d7,L9e36
L9eae
	rts


L9eb0
	movea.l	Le536,a1
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$26,$dff066
	move.w	#$26,$dff062
	move.w	#$42,d7
	move.w	#$0,$dff042
	movea.l	#$ffea,a3
	moveq	#$1f,d6
	movea.l	#$9970,a0
L9ef8
	tst.b	(a0)
	beq	L9fcc
	move.w	Le126,d1
	subq.b	#1,d1
L9f06
	move.l	$180(a0),d0
	add.l	d0,$80(a0)
	dbra	d1,L9f06
	clr.l	d0
	move.w	Le126,d0
	sub.l	d0,$200(a0)
	bcs.s	L9f24
	beq.s	L9f24
	bra.s	L9f2a


L9f24
	sf	(a0)
	bra	L9fcc


L9f2a
	move.w	$80(a0),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L9f3c
	addi.w	#$800,d0
L9f3c
	cmpi.w	#$170,d0
	bcc	L9fcc
	movea.l	#$641da,a5
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a5
	move.w	$100(a0),d1
	subq.w	#4,d1
	bpl.s	L9f5a
	clr.w	d1
L9f5a
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	adda.w	(a3,d1.w),a5
	move.b	d6,(a5)
	addq.b	#1,(a5)
	move.b	d6,$1(a5)
	addq.b	#1,$1(a5)
	cmpi.b	#$55,(a0)
	beq.s	L9fcc
	movea.l	a1,a2
	move.w	$100(a0),d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	lsl.w	#8,d0
	lsl.w	#4,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	#$9bf8,a5
	tst.l	$180(a0)
	bpl.s	L9fa8
	adda.l	#$a,a5
L9fa8
	move.l	a5,$dff050
	moveq	#$4,d1
L9fb0
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,L9fb0
L9fcc
	addq.l	#4,a0
	dbra	d6,L9ef8
	rts


L9fd4
	dc.w	$0000
L9fd6
	dc.w	$0000
L9fd8
	dc.w	$0000
L9fda
	dc.b	$ff
L9fdb
	dc.b	$ff
L9fdc
	dc.b	$00
L9fdd
	dc.b	$00
L9fde
	dc.b	$ff
L9fdf
	dc.b	$ff
L9fe0
	dc.b	$00
L9fe1
	dc.b	$00


L9fe2
	move.w	L7268,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L9ff6
	addi.w	#$800,d0
L9ff6
	cmpi.w	#$28,d0
	bcc.s	La01c
	move.w	Le0ea,L7268
	addi.w	#$2a,L7268
	andi.w	#$7ff,L7268
	clr.l	L7270
La01c
	cmpi.w	#$142,d0
	bcs.s	La04a
	tst.l	L7270
	bmi.s	La04a
	move.w	Le0ea,L7268
	addi.w	#$141,L7268
	andi.w	#$7ff,L7268
	clr.l	L7270
La04a
	move.w	L74b8,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	La05e
	addi.w	#$800,d0
La05e
	cmpi.w	#$28,d0
	bcc.s	La084
	move.w	Le0ea,L74b8
	addi.w	#$2a,L74b8
	andi.w	#$7ff,L74b8
	clr.l	L74c0
La084
	cmpi.w	#$142,d0
	bcs.s	La0b2
	tst.l	L74c0
	bmi.s	La0b2
	move.w	Le0ea,L74b8
	addi.w	#$141,L74b8
	andi.w	#$7ff,L74b8
	clr.l	L74c0
La0b2
	move.b	$bfe001,L9fdd
	eori.b	#$80,L9fdd
	andi.b	#$80,L9fdd
	move.w	$dff00c,d1
	andi.w	#$303,d1
	movea.l	#$a198,a0
	moveq	#-$2,d0
La0de
	addq.w	#2,d0
	cmp.w	(a0,d0.w),d1
	beq.s	La0f6
	cmpi.w	#$e,d0
	bne.s	La0de
	move.w	#$ffff,L9fda
	bra.s	La0fe


La0f6
	lsr.w	#1,d0
	move.w	d0,L9fda
La0fe
	move.w	$dff00a,d1
	move.b	$bfe001,L9fe1
	move.b	#$40,d0
	tst.w	L9fd8
	beq.s	La122
	lsl.w	#1,d0
	move.w	$dff00c,d1
La122
	eor.b	d0,L9fe1
	and.b	d0,L9fe1
	andi.w	#$303,d1
	movea.l	#$a198,a0
	moveq	#-$2,d0
La13a
	addq.w	#2,d0
	cmp.w	(a0,d0.w),d1
	beq.s	La152
	cmpi.w	#$e,d0
	bne.s	La13a
	move.w	#$ffff,L9fde
	bra.s	La15a


La152
	lsr.w	#1,d0
	move.w	d0,L9fde
La15a
	tst.w	L7264
	bne.s	La16a
	tst.w	L9fd4
	bne.s	La178
La16a
	clr.w	L9fdc
	move.w	#$ffff,L9fda
La178
	tst.w	L74b4
	bne.s	La188
	tst.w	L9fd6
	bne.s	La196
La188
	clr.w	L9fe0
	move.w	#$ffff,L9fde
La196
	rts


	dc.w	$0100,$0103,$0003,$0002,$0001,$0301,$0300,$0200,$0000
La1aa
	dc.w	$0000,$0000,$b7cc,$0000,$a352,$0000,$a49c,$0000,$a500,$0000,$a652,$0000,$a818,$0000,$a8b6,$0000
	dc.w	$a940,$0000,$a992,$0000,$aaf8,$0000,$aaf8,$0000,$aaf8,$0000,$ac3e,$0000,$acca,$0000,$ace6,$0000
	dc.w	$aebe,$0000,$aee8,$0000,$aee8,$0000,$aee8,$0000,$aee8,$0000,$aee8,$0000,$aee8,$0000,$aee8,$0000
	dc.w	$aee8,$0000,$afa0,$0000,$afa0,$0000,$afa0,$0000,$aff4,$0000,$b076,$0000,$b0c8,$0000,$b1ca,$0000
	dc.w	$b2ce,$0000,$b348,$0000,$b7cc,$0000,$b372,$0000,$b422,$0000,$b47c,$0000,$b4e8,$0000,$b572,$0000
	dc.w	$b592,$0000,$b5dc,$0000,$b5f2,$0000,$afa0,$0000,$b5dc,$0000,$b66c,$0000,$b784,$0000,$b784,$0000
	dc.w	$afa0


La26c
	clr.w	La1aa
	move.l	#$ffffffff,L4b18
	move.l	#$ffffffff,L4b1c
	move.l	#$ffffffff,L4b20
	move.l	#$ffffffff,L4b24
	move.l	#$ffffffff,L4b28
	move.l	#$ffffffff,L4b2c
	move.l	#$ffffffff,L4b30
	move.l	#$ffffffff,L4b34
	clr.l	L11c2e
	movea.l	#$b944,a2
	moveq	#$7f,d7
La2d0
	tst.l	(a2)
	beq	Lb7cc
	st	La1aa
	move.w	Le126,d0
	sub.w	d0,$1002(a2)
	bmi.s	La322
	move.w	$1002(a2),d0
	cmpi.w	#$70,d0
	bcc	Lb7cc
	tst.b	$1000(a2)
	bne	Lb7cc
	st	$1000(a2)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	movem.l	d7/a2,-(a7)
	jsr	Ld8ec
	moveq	#$6,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
	bra	Lb7cc


La322
	clr.w	$1002(a2)
	movea.l	#$a1ac,a0
	move.w	$602(a2),d0
	lsl.b	#2,d0
	movea.l	(a0,d0.w),a0
	cmpi.b	#$6,$603(a2)
	beq.s	La350
	cmpi.b	#$1d,$603(a2)
	beq.s	La350
	tst.w	L169a
	beq	Lb7cc
La350
	jmp	(a0)


	move.w	$200(a2),d0
	subi.w	#$ba,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	La384
	tst.l	$800(a2)
	bmi.s	La37a
	cmpi.l	#$a0000,$800(a2)
	bcc.s	La39c
La37a
	addi.l	#$8000,$800(a2)
	bra.s	La39c


La384
	tst.l	$800(a2)
	bpl.s	La394
	cmpi.l	#-$a0000,$800(a2)
	bcs.s	La39c
La394
	subi.l	#$8000,$800(a2)
La39c
	move.w	L4f68,d1
	move.w	$200(a2),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	La3b4
	addi.w	#$800,d0
La3b4
	cmpi.w	#$170,d0
	bcs.s	La3be
	move.w	$a00(a2),d1
La3be
	cmp.w	$400(a2),d1
	bcs.s	La3de
	tst.l	$e00(a2)
	bmi.s	La3d4
	cmpi.l	#$70000,$e00(a2)
	bcc.s	La3f6
La3d4
	addi.l	#$3000,$e00(a2)
	bra.s	La3f6


La3de
	tst.l	$e00(a2)
	bpl.s	La3ee
	cmpi.l	#-$70000,$e00(a2)
	bcs.s	La3f6
La3ee
	subi.l	#$3000,$e00(a2)
La3f6
	tst.l	$800(a2)
	bpl.s	La406
	addi.l	#$4000,$800(a2)
	bra.s	La40e


La406
	subi.l	#$4000,$800(a2)
La40e
	tst.l	$e00(a2)
	bpl.s	La41e
	addi.l	#$1000,$e00(a2)
	bra.s	La426


La41e
	addi.l	#-$1001,$e00(a2)
La426
	move.w	Le126,d1
	subq.b	#1,d1
La42e
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	dbra	d1,La42e
	move.w	Le126,d1
	subq.b	#1,d1
La44a
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d1,La44a
	cmpi.w	#$d2,$400(a2)
	bcs.s	La474
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
La474
	cmpi.w	#$90,$400(a2)
	bcs.s	La498
	move.w	#$8f,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
La498
	bra	Lb7cc


	move.w	Le126,d2
	subq.b	#1,d2
La4a4
	move.w	$a00(a2),d1
	cmp.w	$400(a2),d1
	bcs.s	La4c8
	tst.l	$e00(a2)
	bmi.s	La4be
	cmpi.l	#$1f000,$e00(a2)
	bcc.s	La4e0
La4be
	addi.l	#$800,$e00(a2)
	bra.s	La4e0


La4c8
	tst.l	$e00(a2)
	bpl.s	La4d8
	cmpi.l	#-$1f000,$e00(a2)
	bcs.s	La4e0
La4d8
	subi.l	#$800,$e00(a2)
La4e0
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d2,La4a4
	bra	Lb7cc


	cmpi.w	#$a,L169e
	bcs	Lb7cc
	move.w	Le126,d2
	move.w	$a00(a2),d0
	andi.b	#$1,d0
	tst.b	d0
	beq.s	La540
	cmpi.w	#$8,$a00(a2)
	bcs.s	La534
	addq.w	#5,$a00(a2)
	andi.w	#$7,$a00(a2)
	bra	La5ba


La534
	addq.w	#1,$a00(a2)
	andi.w	#$7,$a00(a2)
	bra.s	La5ba


La540
	sub.w	d2,$c00(a2)
	tst.w	$c00(a2)
	bpl.s	La5ba
	subq.w	#1,$a02(a2)
	tst.w	$a02(a2)
	bpl.s	La55a
	move.w	#$a,$a02(a2)
La55a
	cmpi.w	#$3,$a02(a2)
	bcs.s	La59e
	move.w	$200(a2),d0
	subi.w	#$ba,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	La584
	cmpi.w	#$6,$a00(a2)
	beq.s	La58e
	bra.s	La5b4


La584
	cmpi.w	#$2,$a00(a2)
	beq.s	La58e
	bra.s	La5ae


La58e
	move.w	#$32,d1
	jsr	L1ad48
	move.w	d0,$c00(a2)
	bra.s	La5ba


La59e
	move.w	#$64,d1
	jsr	L1ad48
	move.w	d0,$c00(a2)
	beq.s	La5b4
La5ae
	addq.w	#1,$a00(a2)
	bra.s	La5ba


La5b4
	addi.w	#$9,$a00(a2)
La5ba
	subq.b	#1,d2
La5bc
	movea.l	#$a612,a0
	move.w	$a00(a2),d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	add.w	d1,$200(a2)
	move.w	$20(a0,d0.w),d1
	add.w	d1,$400(a2)
	andi.w	#$7ff,$200(a2)
	andi.w	#$7ff,$400(a2)
	dbra	d2,La5bc
	cmpi.w	#$d2,$400(a2)
	bcs.s	La5fa
	clr.w	$400(a2)
	move.w	#$4,$a00(a2)
La5fa
	cmpi.w	#$90,$400(a2)
	bcs.s	La60e
	move.w	#$8f,$400(a2)
	move.w	#$0,$a00(a2)
La60e
	bra	Lb7cc


	dc.w	$0000,$0000,$fffe,$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


	move.w	$c00(a2),d1
	lsl.w	#2,d1
	movea.l	#$4b18,a0
	movea.l	$20(a0,d1.w),a1
	cmpi.l	#-$1,(a0,d1.w)
	bne.s	La692
	move.l	#$8,$600(a2)
	move.l	#$1,$a00(a2)
	moveq	#$2,d1
	jsr	L1ad48
	swap	d0
	move.w	#$7fff,d0
	move.l	d0,$800(a2)
	bra	Lb7cc


La692
	cmpi.w	#$1,$c02(a2)
	beq.s	La6d6
	move.w	$200(a1),d0
	cmp.w	$200(a2),d0
	bcs.s	La6be
	tst.l	$800(a2)
	bmi.s	La6b4
	cmpi.l	#$90000,$800(a2)
	bcc.s	La6d6
La6b4
	addi.l	#$4000,$800(a2)
	bra.s	La6d6


La6be
	tst.l	$800(a2)
	bpl.s	La6ce
	cmpi.l	#-$90000,$800(a2)
	bcs.s	La6d6
La6ce
	addi.l	#-$4001,$800(a2)
La6d6
	movea.l	#$e0f4,a5
	move.w	Le0ec,d5
	lsl.b	#2,d5
	move.l	(a5,d5.w),d5
	tst.w	$c02(a2)
	beq.s	La70e
	move.b	#$2,$40(a0,d1.w)
	sub.l	d5,$400(a2)
	move.l	$200(a2),$200(a1)
	subq.w	#1,$200(a1)
	move.l	$400(a2),$400(a1)
	addq.w	#8,$400(a1)
	bra.s	La712


La70e
	add.l	d5,$400(a2)
La712
	cmpi.w	#$1,$c02(a2)
	beq	La736
	cmpi.w	#$88,$400(a2)
	bcs.s	La736
	move.w	#$1,$c02(a2)
	jsr	Lb7fc
	jsr	L11556
La736
	cmpi.w	#$3,$400(a2)
	bcc.s	La79e
	cmpi.w	#$1,$c02(a2)
	bne.s	La79e
	move.l	#$1,$600(a2)
	movem.l	d7/a1-a2,-(a7)
	moveq	#$c,d0
	jsr	L1ad18
	move.w	#$82,d1
	jsr	L1ad48
	movem.l	(a7)+,d7/a1-a2
	move.w	d0,$a00(a2)
	move.b	#$c,$603(a1)
	move.l	#$100,$e00(a1)
	subq.w	#1,L4b78
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$d,d2
	jsr	Ld66e
	jsr	L4cf2
	movem.l	(a7)+,d7/a2
La79e
	tst.l	$800(a2)
	bpl.s	La7ae
	addi.l	#$1000,$800(a2)
	bra.s	La7b6


La7ae
	subi.l	#$1000,$800(a2)
La7b6
	move.w	Le126,d1
	subq.b	#1,d1
La7be
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	dbra	d1,La7be
	cmpi.w	#$d2,$400(a2)
	bcs.s	La7f0
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
La7f0
	cmpi.w	#$90,$400(a2)
	bcs.s	La814
	move.w	#$8f,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
La814
	bra	Lb7cc


	move.w	Le126,d1
	subq.b	#1,d1
La820
	move.w	$200(a2),d0
	subi.w	#$400,d0
	movea.l	$a00(a2),a0
	move.w	(a0),d2
	sub.w	d2,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcc.s	La858
	tst.l	$800(a2)
	bmi	La84c
	cmpi.l	#$50000,$800(a2)
	bcc.s	La872
La84c
	addi.l	#$1800,$800(a2)
	bra	La872


La858
	tst.l	$800(a2)
	bpl	La86a
	cmpi.l	#-$50000,$800(a2)
	bcs.s	La872
La86a
	subi.l	#$1800,$800(a2)
La872
	cmpi.w	#$400,d0
	bcs.s	La87c
	eori.w	#$7ff,d0
La87c
	andi.l	#$ffff,d0
	lsr.w	#4,d0
	addq.w	#5,d0
	cmpi.w	#$3f,d0
	bcs.s	La890
	move.w	#$3f,d0
La890
	cmp.l	L11c2e,d0
	bcs.s	La89e
	move.l	d0,L11c2e
La89e
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	dbra	d1,La820
	bra	Lb7cc


	cmpi.w	#$6,L169e
	bcs	Lb7cc
	move.w	Le126,d1
	subq.b	#1,d1
La8ca
	move.w	$200(a2),d0
	subi.w	#$400,d0
	movea.l	$a00(a2),a0
	move.w	(a0),d2
	sub.w	d2,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcc.s	La902
	tst.l	$800(a2)
	bmi	La8f6
	cmpi.l	#$50000,$800(a2)
	bcc.s	La91c
La8f6
	addi.l	#$1000,$800(a2)
	bra	La91c


La902
	tst.l	$800(a2)
	bpl	La914
	cmpi.l	#-$50000,$800(a2)
	bcs.s	La91c
La914
	subi.l	#$1000,$800(a2)
La91c
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	movea.l	$a00(a2),a0
	move.l	$600(a0),d0
	add.l	d0,$200(a2)
	dbra	d1,La8ca
	bra	Lb7cc


	move.w	Le126,d1
	subq.b	#1,d1
La948
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	addi.l	#$900,$e00(a2)
	dbra	d1,La948
	move.w	Le126,d1
	subq.b	#1,d1
La96c
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d1,La96c
	cmpi.w	#$90,$400(a2)
	bcs.s	La98e
	move.w	#$8f,$400(a2)
	move.l	#$fffd0000,$e00(a2)
La98e
	bra	Lb7cc


	tst.w	L16a0
	beq.s	La9b2
	moveq	#$0,d0
	movea.l	#$4b18,a0
La9a2
	tst.b	$40(a0,d0.w)
	bne.s	La9b2
	move.w	$200(a2),d1
	cmp.w	(a0,d0.w),d1
	beq.s	La9be
La9b2
	addq.b	#4,d0
	cmpi.b	#$20,d0
	bne.s	La9a2
	bra	Laa54


La9be
	move.w	L10aa2,d1
	asl.w	#3,d1
	sub.w	d1,L10aa6
	tst.w	L10aa6
	bpl	Laa54
	move.w	#$50,L10aa6
	move.w	$200(a2),d1
	subi.w	#$ba,d1
	sub.w	Le0ea,d1
	andi.w	#$7ff,d1
	cmpi.w	#$400,d1
	bcc.s	Laa08
	move.w	#$b4,L4bb4
	ori.w	#$1,L4bb8
	bra.s	Laa18


Laa08
	move.w	#$b4,L4bb6
	ori.w	#$2,L4bb8
Laa18
	movem.l	d0/d7/a0/a2,-(a7)
	jsr	L4e10
	movem.l	(a7)+,d0/d7/a0/a2
	move.b	#$1,$40(a0,d0.w)
	move.b	#$4,$603(a2)
	lsr.b	#2,d0
	move.w	d0,$c00(a2)
	clr.w	$c02(a2)
	clr.w	$a00(a2)
	movem.l	d7/a2,-(a7)
	moveq	#$8,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
	bra	Lb7cc


Laa54
	move.w	Le126,d1
	subq.b	#1,d1
Laa5c
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	dbra	d1,Laa5c
	tst.l	$a00(a2)
	beq.s	Laac2
	clr.l	d0
	move.w	Le126,d0
	sub.l	d0,$a00(a2)
	tst.l	$a00(a2)
	bpl	Lb7cc
	clr.l	$a00(a2)
	move.w	$400(a2),d4
	moveq	#$2,d1
	jsr	L1ad48
	ext.l	d0
	tst.w	d0
	bne.s	Laaa6
	addi.w	#$2d,d4
	bra.s	Laaaa


Laaa6
	subi.w	#$2d,d4
Laaaa
	cmpi.w	#$72,d4
	bcs.s	Laab4
	eori.b	#$1,d0
Laab4
	swap	d0
	move.w	#$2c,d0
	move.l	d0,$c00(a2)
	bra	Lb7cc


Laac2
	tst.w	$c02(a2)
	bne.s	Laae0
	move.w	#$3e8,d1
	jsr	L1ad48
	andi.l	#$fff,d0
	move.l	d0,$a00(a2)
	bra	Lb7cc


Laae0
	tst.w	$c00(a2)
	beq.s	Laaec
	subq.w	#1,$400(a2)
	bra.s	Laaf0


Laaec
	addq.w	#1,$400(a2)
Laaf0
	subq.w	#1,$c02(a2)
	bra	Lb7cc


	move.w	$200(a2),d0
	subi.w	#$ba,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	Lab2a
	tst.l	$800(a2)
	bmi.s	Lab20
	cmpi.l	#$90000,$800(a2)
	bcc.s	Lab42
Lab20
	addi.l	#$4000,$800(a2)
	bra.s	Lab42


Lab2a
	tst.l	$800(a2)
	bpl.s	Lab3a
	cmpi.l	#-$90000,$800(a2)
	bcs.s	Lab42
Lab3a
	subi.l	#$4000,$800(a2)
Lab42
	move.w	$200(a2),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Lab54
	addi.w	#$800,d0
Lab54
	cmpi.w	#$170,d0
	bcc.s	Lab80
	move.w	L4f68,d1
	cmp.w	$400(a2),d1
	bcs.s	Lab80
	tst.l	$e00(a2)
	bmi.s	Lab76
	cmpi.l	#$70000,$e00(a2)
	bcc.s	Lab98
Lab76
	addi.l	#$2000,$e00(a2)
	bra.s	Lab98


Lab80
	tst.l	$e00(a2)
	bpl.s	Lab90
	cmpi.l	#-$70000,$e00(a2)
	bcs.s	Lab98
Lab90
	subi.l	#$2000,$e00(a2)
Lab98
	tst.l	$800(a2)
	bpl.s	Laba8
	addi.l	#$2000,$800(a2)
	bra.s	Labb0


Laba8
	subi.l	#$2000,$800(a2)
Labb0
	tst.l	$e00(a2)
	bpl.s	Labc0
	addi.l	#$1000,$e00(a2)
	bra.s	Labc8


Labc0
	addi.l	#-$1001,$e00(a2)
Labc8
	move.w	Le126,d1
	subq.b	#1,d1
Labd0
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	dbra	d1,Labd0
	move.w	Le126,d1
	subq.b	#1,d1
Labec
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d1,Labec
	cmpi.w	#$d2,$400(a2)
	bcs.s	Lac16
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
Lac16
	cmpi.w	#$90,$400(a2)
	bcs.s	Lac3a
	move.w	#$8f,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
Lac3a
	bra	Lb7cc


	addq.b	#1,$a01(a2)
	cmpi.b	#$5,$a01(a2)
	bcs.s	Lac4e
	clr.w	$a00(a2)
Lac4e
	tst.l	$e00(a2)
	bne.s	Lac72
	move.w	Le126,d0
	subq.w	#1,d0
	move.l	$800(a2),d1
Lac60
	add.l	d1,$200(a2)
	andi.w	#$7ff,$200(a2)
	dbra	d0,Lac60
	bra	Lb7cc


Lac72
	move.w	Le126,d0
	subq.w	#1,d0
Lac7a
	addi.l	#$800,$e00(a2)
	move.l	$e00(a2),d1
	add.l	d1,$400(a2)
	dbra	d0,Lac7a
	cmpi.l	#$900000,$400(a2)
	bcs	Lb7cc
	move.l	#$900000,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	sub.l	d1,$e00(a2)
	cmpi.l	#$500,$e00(a2)
	bcs.s	Lacc2
	eori.l	#$ffffffff,$e00(a2)
	bra	Lb7cc


Lacc2
	clr.l	$e00(a2)
	bra	Lb7cc


	move.l	$800(a2),d0
	move.w	Le126,d1
Lacd4
	add.l	d0,$200(a2)
	dbra	d1,Lacd4
	andi.w	#$7ff,$200(a2)
	bra	Lb7cc


	move.w	Le126,d2
	subq.b	#1,d2
	movea.l	$a00(a2),a0
	tst.l	(a0)
	beq.s	Lacfe
	cmpi.b	#$4,$603(a0)
	beq.s	Lad36
Lacfe
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$1a,d2
	jsr	Ld66e
	moveq	#$9,d0
	jsr	L1ad18
	addq.w	#1,L725a
	jsr	L3c8c
	movem.l	(a7)+,d7/a2
	clr.l	(a2)
	subq.w	#1,L10aa8
	bra	Lb7cc


Lad36
	move.w	$400(a0),d1
	cmp.w	$400(a2),d1
	bcs.s	Lad5a
	tst.l	$e00(a2)
	bmi.s	Lad50
	cmpi.l	#$40000,$e00(a2)
	bcc.s	Lad72
Lad50
	addi.l	#$10000,$e00(a2)
	bra.s	Lad72


Lad5a
	tst.l	$e00(a2)
	bpl.s	Lad6a
	cmpi.l	#-$40000,$e00(a2)
	bcs.s	Lad72
Lad6a
	subi.l	#$10000,$e00(a2)
Lad72
	move.w	$200(a0),d0
	subi.w	#$400,d0
	move.w	$200(a2),d1
	sub.w	d1,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	Lada4
	tst.l	$800(a2)
	bmi.s	Lad9a
	cmpi.l	#$60000,$800(a2)
	bcc.s	Ladbc
Lad9a
	addi.l	#$8000,$800(a2)
	bra.s	Ladbc


Lada4
	tst.l	$800(a2)
	bpl.s	Ladb4
	cmpi.l	#-$60000,$800(a2)
	bcs.s	Ladbc
Ladb4
	subi.l	#$8000,$800(a2)
Ladbc
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	move.w	$200(a2),d0
	cmp.w	$200(a0),d0
	bcc	Lae74
	addi.w	#$a,d0
	cmp.w	$200(a0),d0
	bcs	Lae74
	move.w	$200(a2),d0
	cmp.w	$200(a0),d0
	bcc.s	Lae74
	addi.w	#$a,d0
	cmp.w	$200(a0),d0
	bcs.s	Lae74
	movem.l	d2-d7/a0-a6,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$10,d2
	jsr	Ld66e
	moveq	#$9,d0
	jsr	L1ad18
	movem.l	(a7),d2-d7/a0-a6
	movea.l	#$cde4,a5
	move.w	$602(a2),d2
	lsl.b	#2,d2
	movea.l	(a5,d2.w),a0
	movea.l	L166c4,a1
	jsr	L1675e
	movem.l	(a7)+,d2-d7/a0-a6
	cmpi.w	#$667e,L1087e
Lae48
	bne.s	Lae48
	movea.l	#$4b18,a1
	move.w	$c00(a0),d1
	lsl.w	#2,d1
	clr.b	$40(a1,d1.w)
	movea.l	$20(a1,d1.w),a1
	move.l	#$100,$e00(a1)
	clr.l	(a2)
	clr.l	(a0)
	subq.w	#2,L10aa8
	bra	Lb7cc


Lae74
	dbra	d2,Lad36
	cmpi.w	#$d2,$400(a2)
	bcs.s	Lae96
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
Lae96
	cmpi.w	#$90,$400(a2)
	bcs.s	Laeba
	move.w	#$8f,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
Laeba
	bra	Lb7cc


	bra	Lb7cc


Laec2
	clr.l	$7ba84
	clr.l	$7ba9c
	IFND	PROTECTION_DISABLED
	cmpi.b	#$50,$76b50
	bne.s	Laec2
	cmpi.b	#$f8,$76cc0
	bne.s	Laec2
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	jmp	$24


	move.w	$602(a2),d2
	subi.w	#$10,d2
	lsl.w	#2,d2
	movea.l	#$4b18,a0
	move.l	$200(a2),(a0,d2.w)
	move.l	a2,$20(a0,d2.w)
	addq.b	#1,$a01(a2)
	cmpi.b	#$5,$a01(a2)
	bcs.s	Laf12
	clr.w	$a00(a2)
Laf12
	tst.w	L103ec
	bne.s	Laf2a
	cmpi.b	#$2,$40(a0,d2.w)
	beq	Lb7cc
	tst.l	$e00(a2)
	bne.s	Laf48
Laf2a
	move.w	Le126,d0
	subq.w	#1,d0
	move.l	$800(a2),d1
Laf36
	add.l	d1,$200(a2)
	andi.w	#$7ff,$200(a2)
	dbra	d0,Laf36
	bra	Lb7cc


Laf48
	move.w	Le126,d0
	subq.w	#1,d0
Laf50
	addi.l	#$800,$e00(a2)
	move.l	$e00(a2),d1
	add.l	d1,$400(a2)
	dbra	d0,Laf50
	cmpi.l	#$900000,$400(a2)
	bcs	Lb7cc
	move.l	#$900000,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	sub.l	d1,$e00(a2)
	cmpi.l	#$500,$e00(a2)
	bcs.s	Laf98
	eori.l	#$ffffffff,$e00(a2)
	bra	Lb7cc


Laf98
	clr.l	$e00(a2)
	bra	Lb7cc


	move.w	Le126,d2
	subq.b	#1,d2
Lafa8
	move.w	#$4b,d1
	cmp.w	$400(a2),d1
	bcs.s	Lafcc
	tst.l	$e00(a2)
	bmi.s	Lafc2
	cmpi.l	#$20000,$e00(a2)
	bcc.s	Lafe4
Lafc2
	addi.l	#$1000,$e00(a2)
	bra.s	Lafe4


Lafcc
	tst.l	$e00(a2)
	bpl.s	Lafdc
	cmpi.l	#-$20000,$e00(a2)
	bcs.s	Lafe4
Lafdc
	subi.l	#$1000,$e00(a2)
Lafe4
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d2,Lafa8
	bra	Lb7cc


	move.w	Le126,d0
	cmpi.w	#$1,d0
	beq.s	Lb002
	subq.w	#1,d0
Lb002
	tst.b	$800(a2)
	bpl.s	Lb00a
	neg.w	d0
Lb00a
	add.w	d0,$200(a2)
	andi.w	#$7ff,$200(a2)
	move.w	L8788,d0
	cmp.w	$200(a2),d0
	bcc	Lb7cc
	addq.w	#8,d0
	cmp.w	$200(a2),d0
	bcs	Lb7cc
	tst.w	L4b7a
	beq	Lb7cc
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$7,d2
	jsr	Ld66e
	moveq	#$9,d0
	jsr	L1ad18
	moveq	#$1b,d0
	jsr	L1ad18
	subq.w	#1,L4b7a
	jsr	L4cf2
	movem.l	(a7)+,d7/a2
	clr.l	(a2)
	subq.w	#1,L10aa8
	bra	Lb7cc


	move.w	$c00(a2),d1
	cmp.w	$400(a2),d1
	bcs.s	Lb09a
	tst.l	$e00(a2)
	bmi.s	Lb090
	cmpi.l	#$30000,$e00(a2)
	bcc.s	Lb0b2
Lb090
	addi.l	#$6000,$e00(a2)
	bra.s	Lb0b2


Lb09a
	tst.l	$e00(a2)
	bpl.s	Lb0aa
	cmpi.l	#-$30000,$e00(a2)
	bcs.s	Lb0b2
Lb0aa
	subi.l	#$6000,$e00(a2)
Lb0b2
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	addq.w	#4,$200(a2)
	andi.w	#$7ff,$200(a2)
	bra	Lb7cc


	cmpi.w	#$a,L169e
	bcs	Lb7cc
	move.w	Le126,d2
	subq.b	#1,d2
	tst.b	$a03(a2)
	beq.s	Lb116
	sub.b	d2,$a03(a2)
	cmpi.b	#$a,$a03(a2)
	bcc.s	Lb116
	move.b	#$ff,$a03(a2)
	movem.l	d2/d7/a2,-(a7)
	jsr	L113d8
	moveq	#$1c,d0
	jsr	L1ad18
	movem.l	(a7)+,d2/d7/a2
	clr.l	(a2)
	subq.w	#1,L10aa8
	bra	Lb7cc


Lb116
	move.w	$c02(a2),d1
	cmp.w	$400(a2),d1
	bcs.s	Lb13a
	tst.l	$e00(a2)
	bmi.s	Lb130
	cmpi.l	#$20000,$e00(a2)
	bcc.s	Lb152
Lb130
	addi.l	#$1000,$e00(a2)
	bra.s	Lb152


Lb13a
	tst.l	$e00(a2)
	bpl.s	Lb14a
	cmpi.l	#-$20000,$e00(a2)
	bcs.s	Lb152
Lb14a
	subi.l	#$1000,$e00(a2)
Lb152
	move.w	$200(a2),d0
	subi.w	#$400,d0
	move.w	$c00(a2),d1
	sub.w	d1,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcc.s	Lb184
	tst.l	$800(a2)
	bmi.s	Lb17a
	cmpi.l	#$20000,$800(a2)
	bcc.s	Lb19c
Lb17a
	addi.l	#$2000,$800(a2)
	bra.s	Lb19c


Lb184
	tst.l	$800(a2)
	bpl.s	Lb194
	cmpi.l	#-$20000,$800(a2)
	bcs.s	Lb19c
Lb194
	subi.l	#$2000,$800(a2)
Lb19c
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d2,Lb116
	tst.w	L1698
	bne	Lb7cc
	subq.w	#1,$c00(a2)
	bra	Lb7cc


	move.w	Le126,d2
	subq.b	#1,d2
Lb1d2
	move.w	#$82,d1
	cmpi.w	#$50,L4f68
	bcs.s	Lb1e4
	move.w	#$14,d1
Lb1e4
	cmp.w	$400(a2),d1
	bcs.s	Lb204
	tst.l	$e00(a2)
	bmi.s	Lb1fa
	cmpi.l	#$20000,$e00(a2)
	bcc.s	Lb21c
Lb1fa
	addi.l	#$a00,$e00(a2)
	bra.s	Lb21c


Lb204
	tst.l	$e00(a2)
	bpl.s	Lb214
	cmpi.l	#-$20000,$e00(a2)
	bcs.s	Lb21c
Lb214
	subi.l	#$a00,$e00(a2)
Lb21c
	move.w	$200(a2),d0
	subi.w	#$400,d0
	move.w	L4f64,d1
	sub.w	d1,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcc.s	Lb250
	tst.l	$800(a2)
	bmi.s	Lb246
	cmpi.l	#$60000,$800(a2)
	bcc.s	Lb268
Lb246
	addi.l	#$5000,$800(a2)
	bra.s	Lb268


Lb250
	tst.l	$800(a2)
	bpl.s	Lb260
	cmpi.l	#-$60000,$800(a2)
	bcs.s	Lb268
Lb260
	subi.l	#$5000,$800(a2)
Lb268
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	dbra	d2,Lb1d2
	cmpi.w	#$d2,$400(a2)
	bcs.s	Lb2a6
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
	bra	Lb7cc


Lb2a6
	cmpi.w	#$90,$400(a2)
	bcs.s	Lb2ca
	move.w	#$8f,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
Lb2ca
	bra	Lb7cc


	tst.w	$a02(a2)
	bne.s	Lb2ec
	movea.l	#$e100,a5
	move.w	Le0ec,d5
	lsl.b	#2,d5
	move.l	(a5,d5.w),d5
	add.l	d5,$e00(a2)
	bra.s	Lb308


Lb2ec
	movea.l	$c00(a2),a1
	cmpi.b	#$1f,$603(a1)
	bne.s	Lb304
	tst.l	(a1)
	beq.s	Lb304
	tst.w	$a02(a1)
	beq.s	Lb304
	bra.s	Lb308


Lb304
	clr.w	$a02(a2)
Lb308
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	cmpi.w	#$8f,$400(a2)
	bcs.s	Lb344
	subq.w	#1,L10aa8
	clr.l	(a2)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	move.b	$dff006,d2
	movem.l	d7/a2,-(a7)
	jsr	Ld66e
	moveq	#$9,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
Lb344
	bra	Lb7cc


	tst.w	L103ec
	bne	Lb7cc
	tst.l	$800(a2)
	bpl.s	Lb35e
	subq.w	#1,$200(a2)
	bra.s	Lb362


Lb35e
	addq.w	#1,$200(a2)
Lb362
	andi.l	#$7ff0000,$200(a2)
	bra	Lb7cc


	bra	Lb7cc


	movea.l	$a00(a2),a0
	cmpi.b	#$23,$603(a0)
	bne.s	Lb3c2
	tst.l	(a0)
	beq.s	Lb3c2
	move.l	$200(a0),d0
	cmp.l	$200(a2),d0
	bne.s	Lb3c2
	tst.w	$c02(a2)
	beq.s	Lb3b8
	move.w	L4f64,d0
	addi.w	#$a0,d0
	sub.w	$200(a2),d0
	tst.w	d0
	bpl.s	Lb3a8
	addi.w	#$800,d0
Lb3a8
	andi.w	#$7ff,d0
	cmpi.w	#$170,d0
	bcc	Lb7cc
	clr.w	$c02(a2)
Lb3b8
	cmpi.w	#$28,$400(a2)
	bcc.s	Lb400
	bra.s	Lb3e0


Lb3c2
	jsr	L112b0
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$e,d2
	jsr	Ld66e
	movem.l	(a7)+,d7/a2
Lb3e0
	clr.l	$600(a2)
	clr.l	(a2)
	subq.w	#1,L10aa8
	movem.l	d7/a2,-(a7)
	moveq	#$1f,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
	bra	Lb7cc


Lb400
	movea.l	#$e10c,a5
	move.w	Le0ec,d5
	lsl.b	#2,d5
	move.l	(a5,d5.w),d5
	add.l	d5,$e00(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	bra	Lb7cc


	movea.l	$a00(a2),a0
	cmpi.b	#$22,$603(a0)
	bne.s	Lb44a
	tst.l	(a0)
	beq.s	Lb44a
	move.l	$200(a0),d0
	cmp.l	$200(a2),d0
	bne.s	Lb44a
	move.w	$400(a0),$400(a2)
	addq.w	#8,$400(a2)
	bra	Lb7cc


Lb44a
	jsr	L112b0
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$e,d2
	jsr	Ld66e
	movem.l	(a7)+,d7/a2
	movea.l	$a00(a2),a0
	clr.l	$600(a2)
	clr.l	(a2)
	subq.w	#1,L10aa8
	bra	Lb7cc


	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	add.l	d0,$400(a2)
	movea.l	#$e118,a5
	move.w	Le0ec,d5
	lsl.b	#2,d5
	move.l	(a5,d5.w),d5
	add.l	d5,$e00(a2)
	cmpi.w	#$92,$400(a2)
	bcs	Lb7cc
	movem.l	d7/a2,-(a7)
	move.w	$200(a2),d0
	move.w	$400(a2),d1
	moveq	#$e,d2
	jsr	Ld66e
	moveq	#$17,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
	clr.l	(a2)
	subq.w	#1,L10aa8
	bra	Lb7cc


	move.w	$200(a2),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Lb4fa
	addi.w	#$800,d0
Lb4fa
	cmpi.w	#$170,d0
	bcc.s	Lb526
	addq.w	#1,$c00(a2)
	cmpi.w	#$c,$c00(a2)
	bcs.s	Lb526
	movem.l	d7/a2,-(a7)
	jsr	L114b8
	moveq	#$1e,d0
	jsr	L1ad18
	movem.l	(a7)+,d7/a2
	clr.w	$c00(a2)
Lb526
	subq.w	#1,$a02(a2)
	tst.w	$a02(a2)
	bne.s	Lb550
	moveq	#$3,d1
	jsr	L1ad48
	move.w	d0,$a00(a2)
	move.w	#$64,$a02(a2)
	cmpi.w	#$2,$a00(a2)
	bne.s	Lb550
	move.w	#$14,$a02(a2)
Lb550
	tst.w	$a00(a2)
	bne.s	Lb55c
	addq.w	#2,$200(a2)
	bra.s	Lb568


Lb55c
	cmpi.w	#$1,$a00(a2)
	bne.s	Lb568
	subq.w	#2,$200(a2)
Lb568
	andi.w	#$7ff,$200(a2)
	bra	Lb7cc


	move.w	Le126,d0
	addq.w	#6,d0
	sub.w	d0,$400(a2)
	tst.w	$400(a2)
	bpl	Lb7cc
	subq.w	#1,L10aa8
	clr.l	(a2)
	bra	Lb7cc


	subq.w	#2,$200(a2)
	andi.w	#$7ff,$200(a2)
	subq.w	#1,$a00(a2)
	bpl	Lb7cc
	movem.l	d7/a2,-(a7)
	clr.w	Lb8c8
	jsr	L11112
	move.w	#$1,Lb8c8
	tst.w	d7
	bmi.s	Lb5c6
	addq.w	#1,L10aa8
Lb5c6
	movem.l	(a7)+,d7/a2
	move.w	#$7d0,d1
	jsr	L1ad48
	move.w	d0,$a00(a2)
	bra	Lb7cc


	subq.w	#1,$a02(a2)
	tst.w	$a02(a2)
	bpl.s	Lb5ee
	clr.l	(a2)
	subq.w	#1,L10aa8
Lb5ee
	bra	Lb7cc


	tst.l	$800(a2)
	bpl.s	Lb5fe
	subq.w	#1,$200(a2)
	bra.s	Lb602


Lb5fe
	addq.w	#1,$200(a2)
Lb602
	andi.l	#$7ff0000,$200(a2)
	cmpi.w	#$3,L10d22
	bne.s	Lb622
	cmpi.w	#$5,L10aa8
	bcc.s	Lb622
	clr.w	$c00(a2)
Lb622
	move.w	Le126,d0
	sub.w	d0,$c00(a2)
	tst.w	$c00(a2)
	bpl	Lb7cc
	subq.w	#1,L10aa8
	clr.l	(a2)
	movem.l	d7/a2,-(a7)
	move.w	Le0ea,-(a7)
	move.w	$200(a2),d0
	subi.w	#$ba,d0
	andi.w	#$7ff,d0
	move.w	d0,Le0ea
	jsr	L9742
	move.w	(a7)+,Le0ea
	movem.l	(a7)+,d7/a2
	bra	Lb7cc


	move.w	$200(a2),d0
	subi.w	#$ba,d0
	add.w	$a00(a2),d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	Lb6a2
	tst.l	$800(a2)
	bmi.s	Lb698
	cmpi.l	#$40000,$800(a2)
	bcc.s	Lb6ba
Lb698
	addi.l	#$6000,$800(a2)
	bra.s	Lb6ba


Lb6a2
	tst.l	$800(a2)
	bpl.s	Lb6b2
	cmpi.l	#-$40000,$800(a2)
	bcs.s	Lb6ba
Lb6b2
	subi.l	#$6000,$800(a2)
Lb6ba
	move.w	L4f68,d1
	cmp.w	$400(a2),d1
	bcs.s	Lb6e0
	tst.l	$e00(a2)
	bmi.s	Lb6d6
	cmpi.l	#$30000,$e00(a2)
	bcc.s	Lb6f8
Lb6d6
	addi.l	#$4000,$e00(a2)
	bra.s	Lb6f8


Lb6e0
	tst.l	$e00(a2)
	bpl.s	Lb6f0
	cmpi.l	#-$30000,$e00(a2)
	bcs.s	Lb6f8
Lb6f0
	subi.l	#$4000,$e00(a2)
Lb6f8
	tst.l	$800(a2)
	bpl.s	Lb708
	addi.l	#$4000,$800(a2)
	bra.s	Lb710


Lb708
	subi.l	#$4000,$800(a2)
Lb710
	tst.l	$e00(a2)
	bpl.s	Lb720
	addi.l	#$1000,$e00(a2)
	bra.s	Lb728


Lb720
	subi.l	#$1000,$e00(a2)
Lb728
	move.l	$800(a2),d0
	add.l	d0,$200(a2)
	andi.l	#$7ffffff,$200(a2)
	move.l	$e00(a2),d0
	add.l	d0,$400(a2)
	cmpi.w	#$d2,$400(a2)
	bcs.s	Lb75e
	clr.w	$400(a2)
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	move.l	d0,d1
	sub.l	d1,d0
	move.l	d0,$e00(a2)
Lb75e
	cmpi.w	#$91,$400(a2)
	bcs.s	Lb782
	move.w	#$90,$400(a2)
	move.l	$e00(a2),d1
	lsr.l	#1,d1
	move.l	$e00(a2),d0
	eori.l	#$ffffffff,d0
	add.l	d1,d0
	move.l	d0,$e00(a2)
Lb782
	bra.s	Lb7cc


	move.w	Le126,d0
	addq.b	#1,d0
	add.b	d0,d0
	tst.l	$800(a2)
	bpl.s	Lb79a
	sub.w	d0,$200(a2)
	bra.s	Lb79e


Lb79a
	add.w	d0,$200(a2)
Lb79e
	andi.w	#$7ff,$200(a2)
	move.w	$200(a2),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Lb7b6
	addi.w	#$800,d0
Lb7b6
	cmpi.w	#$1d4,d0
	bcs.s	Lb7cc
	cmpi.w	#$79c,d0
	bcc.s	Lb7cc
	subq.w	#1,L10aa8
	clr.l	(a2)
	nop
Lb7cc
	addq.l	#4,a2
	dbra	d7,La2d0
	move.l	L11c2e,L1b26a
	tst.w	La1aa
	bne.s	Lb7ec
Lb7e4
	clr.w	L10d20
	rts


Lb7ec
	move.w	L10aa8,d0
	cmp.w	L4b90,d0
	beq.s	Lb7e4
	rts


Lb7fc
	cmpi.w	#$3,L103ea
	beq.s	Lb818
	tst.w	L103ea
	beq.s	Lb818
	cmpi.w	#$2,L103ea
	beq.s	Lb870
Lb818
	tst.w	L725a
	beq.s	Lb86e
	move.l	L4f64,d0
	move.l	L4f68,d1
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$e,d2
	clr.l	d3
	clr.l	d6
	move.l	a2,d4
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	Lb854
	addq.w	#1,L10aa8
	IFND	INFINITE_MISSILES
	subq.w	#1,L725a
	ELSE
	nop
	nop
	nop
	ENDC
Lb854
	move.w	#$1,Lb8c8
	jsr	L3c8c
	moveq	#$16,d0
	jsr	L1ad18
	movem.l	(a7)+,d2-d7/a0-a6
Lb86e
	rts


Lb870
	tst.w	L74aa
	beq.s	Lb8c6
	move.l	L4f64,d0
	move.l	L4f68,d1
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$e,d2
	clr.l	d3
	clr.l	d6
	move.l	a2,d4
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	Lb8ac
	addq.w	#1,L10aa8
	subq.w	#1,L74aa
Lb8ac
	move.w	#$1,Lb8c8
	jsr	L3c8c
	moveq	#$16,d0
	jsr	L1ad18
	movem.l	(a7)+,d2-d7/a0-a6
Lb8c6
	rts


Lb8c8
	dc.w	$0001


Lb8ca
	moveq	#$7e,d7
	movea.l	#$b948,a0
Lb8d2
	tst.l	(a0)
	bne.s	Lb93c
Lb8d6
	st	(a0)
	move.l	d0,$200(a0)
	move.l	d1,$400(a0)
	move.l	d2,$600(a0)
	move.l	d3,$800(a0)
	move.l	d4,$a00(a0)
	move.l	d5,$c00(a0)
	move.l	d6,$e00(a0)
	cmpi.b	#$3,d2
	beq.s	Lb92e
	tst.w	Lb8c8
	beq.s	Lb926
	move.l	#$ff000070,$1000(a0)
	swap	d0
	swap	d1
	move.l	a0,-(a7)
	jsr	Ld8ec
	movea.l	(a7)+,a0
	addq.w	#1,L10aa8
	moveq	#$1,d7
	jmp	La04


Lb926
	clr.l	$1000(a0)
	moveq	#$1,d7
	rts


Lb92e
	clr.l	$1000(a0)
	addq.w	#1,L10aa8
	moveq	#$1,d7
	rts


Lb93c
	addq.l	#4,a0
	dbra	d7,Lb8d2
	rts


	ds.w	9*256

	dc.w	$0000,$000c,$0018,$000f,$0010,$001a,$0003,$001c,$0012,$0004,$0004,$0004,$000e,$0018

	dc.b	$00
Lcb61
	dc.b	$1a

	dc.w	$0000,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005

	dc.b	$00
Lcb75
	dc.b	$1a,$00
Lcb77
	dc.b	$1a,$00
Lcb79
	dc.b	$1a,$00
Lcb7b
	dc.b	$0d

	dc.w	$0011,$0018,$0011

	dc.b	$00
Lcb83
	dc.b	$18

	dc.w	$0000,$0010,$0002,$0002,$0001,$0002,$0019,$000d,$0000,$0000

	dc.b	$00
Lcb99
	dc.b	$1a

	dc.w	$0000,$000c,$000c,$000c

	dc.b	$00
Lcba3
	dc.b	$1a

	dc.w	$0000,$0000,$0006,$a300,$0006,$b200,$0006,$b700,$0006,$9e00,$0006,$bf20,$0006,$bc00,$0006,$b480
	dc.w	$0006,$9e00,$0006,$a440,$0006,$a580,$0006,$a6c0,$0006,$c790,$0006,$a080,$0006,$d820,$0000,$0000
	dc.w	$0006,$c600,$0006,$c600,$0006,$c600,$0006,$c600,$0006,$c600,$0006,$c600,$0006,$c600,$0006,$c600
	dc.w	$0006,$d780,$0006,$d5a0,$0006,$d500,$0006,$a800,$0006,$da00,$0006,$ad00,$0006,$aee0,$0006,$c100
	dc.w	$0006,$cb00,$0006,$bfc0,$0006,$d3c0,$0006,$d8c0,$0006,$cf60,$0006,$b160,$0006,$db90,$0006,$dcd0
	dc.w	$0006,$df00,$0006,$d000,$0006,$d640,$0006,$e040,$0006,$c920,$0006,$e2c0,$0006,$e400,$0006,$d6e0
	dc.w	$0000,$0007,$0000,$0003,$0000,$0007,$0000,$000f,$0000,$0007,$0000,$0001,$0000,$0007,$0000,$0007
	dc.w	$0000,$0007,$0000,$0003,$0000,$0003,$0000,$0003,$0000,$0007,$0000,$0007,$0000,$0001,$0000,$0000
	dc.w	$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007
	dc.w	$0000,$0001,$0000,$0001,$0000,$0001,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$0007,$0000,$000f
	dc.w	$0000,$000f,$0000,$0003,$0000,$0003,$0000,$0003,$0000,$0001,$0000,$0001,$0000,$0003,$0000,$0007
	dc.w	$0000,$0003,$0000,$0007,$0000,$0001,$0000,$0003,$0000,$0007,$0000,$0003,$0000,$0001,$0000,$0001
	dc.w	$0000,$0000,$000c,$0003,$0000,$0000,$0000,$0000,$0000,$0000,$0050,$0003,$0000,$0000,$0000,$0000
	dc.w	$00c8,$0002,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000a,$0002,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0001,$670e,$0001,$6704,$0001,$66e6,$0001,$6722,$0001,$6736,$0001,$66fa,$0001,$66e6
	dc.w	$0001,$66e6,$0001,$6704,$0001,$66dc,$0001,$66d2,$0001,$66d2,$0001,$66d2,$0001,$66d2,$0001,$66d2
	dc.w	$0001,$66fa,$0001,$66fa,$0001,$66fa,$0001,$66fa,$0001,$66fa,$0001,$66fa,$0001,$66fa,$0001,$66fa
	dc.w	$0001,$6736,$0001,$6736,$0001,$6736,$0001,$6704,$0001,$6718,$0001,$66e6,$0001,$6718,$0001,$6704
	dc.w	$0001,$66d2,$0001,$66e6,$0001,$66e6,$0001,$66e6,$0001,$66e6,$0001,$6722,$0001,$66c8,$0001,$66fa
	dc.w	$0001,$66d2,$0001,$6704,$0001,$66d2,$0001,$66d2,$0001,$6704,$0001,$66d2,$0001,$66d2,$0001,$66d2
Lcea4
	dc.w	$0000
Lcea6
	dc.l	0
Lceaa
	dc.w	$0000


Lceac
	addq.b	#1,Lcb99
	addq.b	#1,Lcba3
	addq.b	#1,Lcb75
	addq.b	#1,Lcb77
	addq.b	#1,Lcb79
	eori.b	#$1,Lcb7b
	eori.b	#$1a,Lcb61
	eori.b	#$14,Lcb83
	movea.l	#$ffea,a3
	movea.l	#$cc64,a6
	eori.w	#$1,Lcea4
	beq.s	Lcefe
	addq.w	#1,Lceaa
Lcefe
	movea.l	Le536,a1
	movea.l	#$cba4,a4
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$2a,$dff066
	move.w	#$2a,$dff062
	move.w	#$202,d7
	move.w	#$0,$dff042
	movea.l	#$b849,a0
	adda.l	Lcea6,a0
	moveq	#$7f,d6
Lcf46
	tst.b	(a0)
	beq	Ld4fa
	tst.w	$1002(a0)
	bne	Ld4fa
	move.w	$200(a0),d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Lcf66
	addi.w	#$800,d0
Lcf66
	cmpi.w	#$16f,d0
	bcc	Ld4fa
	movea.l	#$641da,a5
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a5
	move.w	$400(a0),d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	adda.w	(a3,d1.w),a5
	tst.b	(a5)
	bne.s	Lcfd4
	addq.l	#1,a5
	tst.b	(a5)
	bne.s	Lcfd4
	adda.l	#$36a,a5
	eori.b	#$7f,d6
	move.b	d6,(a5)
	move.b	d6,-$1(a5)
	eori.b	#$7f,d6
	movea.l	#$cd26,a5
	move.w	$602(a0),d3
	lsl.w	#2,d3
	move.w	(a5,d3.w),d2
	beq	Ld2f6
	movem.l	d0-d7/a0-a6,-(a7)
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	jsr	L13920
	movem.l	(a7)+,d0-d7/a0-a6
	bra	Ld2f6


Lcfd4
	cmpi.b	#$18,$603(a0)
	beq	Ld2f6
	cmpi.b	#$19,$603(a0)
	beq	Ld2f6
	cmpi.b	#$1a,$603(a0)
	beq	Ld2f6
	cmpi.b	#$28,$603(a0)
	beq	Ld2f6
	cmpi.b	#$2b,$603(a0)
	beq	Ld2f6
	cmpi.b	#$2a,$603(a0)
	beq	Ld2f6
	cmpi.b	#$2f,$603(a0)
	beq	Ld2f6
	cmpi.b	#$e,$603(a0)
	beq	Ld2f6
	cmpi.b	#$1c,$603(a0)
	bne.s	Ld036
	jsr	L11366
	bra	Ld172


Ld036
	cmpi.b	#$1f,$603(a0)
	bne.s	Ld048
	jsr	L11708
	bra	Ld172


Ld048
	cmpi.b	#$29,$603(a0)
	beq	Ld2f6
	cmpi.b	#$1d,$603(a0)
	bne.s	Ld080
	subq.b	#1,$a00(a0)
	tst.b	$a00(a0)
	beq	Ld172
	move.b	#$1,$a01(a0)
	movem.l	d0-d7/a0-a6,-(a7)
	moveq	#$e,d0
	jsr	L1ad18
	movem.l	(a7)+,d0-d7/a0-a6
	bra	Ld2c2


Ld080
	move.w	L727a,d1
	or.w	L74ca,d1
	tst.w	d1
	beq	Ld0d2
	cmpi.b	#$20,$603(a0)
	beq.s	Ld0a8
	move.b	$603(a0),d1
	andi.b	#$f8,d1
	cmpi.b	#$10,d1
	bne.s	Ld0d2
Ld0a8
	movem.l	d1/a2,-(a7)
	move.b	(a5),d1
	movea.l	#$9970,a2
	subq.b	#1,d1
	eori.b	#$1f,d1
	ext.w	d1
	lsl.w	#2,d1
	cmpi.b	#$55,(a2,d1.w)
	bne.s	Ld0ce
	movem.l	(a7)+,d1/a2
	bra	Ld2f6


Ld0ce
	movem.l	(a7)+,d1/a2
Ld0d2
	cmpi.b	#$20,$603(a0)
	bne.s	Ld0ea
	move.b	#$29,$603(a0)
	subq.w	#1,L4b90
	bra	Ld2f6


Ld0ea
	cmpi.b	#$2c,$603(a0)
	bne	Ld172
	subq.b	#1,$c01(a0)
	tst.b	$c01(a0)
	bmi.s	Ld172
	move.l	d0,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	moveq	#$e,d0
	jsr	L1ad18
	movem.l	(a7),d1-d7/a0-a6
	move.b	(a5),d1
	movea.l	#$9af0,a2
	subq.b	#1,d1
	eori.b	#$1f,d1
	ext.w	d1
	lsl.w	#2,d1
	move.l	(a2,d1.w),d0
	movem.l	(a7)+,d1-d7/a0-a6
	tst.l	d0
	bpl.s	Ld150
	tst.l	$800(a0)
	bpl.s	Ld142
	sub.l	d0,$800(a0)
	sub.l	d0,$800(a0)
	move.l	(a7)+,d0
	bra	Ld2c2


Ld142
	add.l	d0,$800(a0)
	add.l	d0,$800(a0)
	move.l	(a7)+,d0
	bra	Ld2c2


Ld150
	tst.l	$800(a0)
	bmi.s	Ld164
	sub.l	d0,$800(a0)
	sub.l	d0,$800(a0)
	move.l	(a7)+,d0
	bra	Ld2c2


Ld164
	add.l	d0,$800(a0)
	add.l	d0,$800(a0)
	move.l	(a7)+,d0
	bra	Ld2c2


Ld172
	movem.l	d2-d7/a0-a6,-(a7)
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	move.w	$602(a0),d2
	add.b	d2,d2
	movea.l	#$cb44,a5
	move.w	(a5,d2.w),d2
	jsr	Ld66e
	moveq	#$9,d0
	jsr	L1ad18
	movem.l	(a7),d2-d7/a0-a6
	movea.l	#$cde4,a5
	move.w	$602(a0),d2
	lsl.b	#2,d2
	movea.l	(a5,d2.w),a0
	movea.l	L166c4,a1
	jsr	L1675e
	movem.l	(a7)+,d2-d7/a0-a6
	cmpi.b	#$5,$603(a0)
	bne.s	Ld1f4
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	L11bdc
	subq.w	#1,L11c2c
	jsr	L11d5e
	movem.l	(a7)+,d0-d7/a0-a6
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	jsr	L11604
	bra	Ld2a6


Ld1f4
	cmpi.b	#$2,$603(a0)
	bne.s	Ld21c
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	jsr	L11a52
	movem.l	(a7)+,d0-d7/a0-a6
	jsr	L11642
	bra	Ld2a6


Ld21c
	cmpi.b	#$4,$603(a0)
	bne.s	Ld248
	jsr	L11798
	movea.l	#$4b18,a2
	move.w	$c00(a0),d1
	lsl.w	#2,d1
	clr.b	$40(a2,d1.w)
	movea.l	$20(a2,d1.w),a2
	move.l	#$100,$e00(a2)
	bra.s	Ld2a6


Ld248
	move.b	$603(a0),d0
	andi.b	#$f8,d0
	cmpi.b	#$10,d0
	bne.s	Ld2a6
	subq.b	#1,L4b79
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	L4cf2
	moveq	#$1b,d0
	jsr	L1ad18
	movem.l	(a7)+,d0-d7/a0-a6
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	#$fffe,$dff064
	move.w	#$2a,$dff066
	move.w	#$2a,$dff062
	move.w	#$202,d7
	move.w	#$0,$dff042
Ld2a6
	clr.l	(a0)
	clr.b	$603(a0)
	subq.w	#1,L10aa8
	cmpi.b	#$2d,$603(a0)
	beq	Ld2c2
	jsr	L116ae
Ld2c2
	move.b	(a5),d1
	clr.b	-$1(a5)
	clr.b	(a5)
	clr.b	$1(a5)
	movea.l	#$9970,a2
	subq.b	#1,d1
	eori.b	#$1f,d1
	ext.w	d1
	lsl.w	#2,d1
	clr.l	(a2,d1.w)
	cmpi.b	#$1d,$603(a0)
	beq.s	Ld2f6
	cmpi.b	#$2c,$603(a0)
	beq.s	Ld2f6
	bra	Ld4fa


Ld2f6
	movea.l	a1,a2
	move.w	$400(a0),d1
	add.w	d1,d1
	adda.w	(a3,d1.w),a2
	move.w	d0,d1
	lsr.w	#3,d1
	adda.w	d1,a2
	ror.w	#4,d0
	andi.w	#$f000,d0
	ori.w	#$dfc,d0
	move.w	d0,$dff040
	movea.l	a4,a5
	move.l	$600(a0),d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	move.w	Lceaa,d1
	add.w	d6,d1
	cmpi.b	#$3,$603(a0)
	bne.s	Ld33c
	move.w	$a00(a0),d1
	bra	Ld4cc


Ld33c
	cmpi.b	#$1d,$603(a0)
	bne.s	Ld36e
	tst.b	$a01(a0)
	beq.s	Ld354
	moveq	#$5,d1
	clr.b	$a01(a0)
	bra	Ld4d0


Ld354
	clr.w	d1
	addq.b	#1,$a02(a0)
	cmpi.b	#$5,$a02(a0)
	bcs.s	Ld366
	clr.b	$a02(a0)
Ld366
	move.b	$a02(a0),d1
	bra	Ld4d0


Ld36e
	cmpi.b	#$20,$603(a0)
	bne.s	Ld39c
	addi.l	#$8000,$a00(a0)
	cmpi.w	#$7,$a00(a0)
	bcs.s	Ld38a
	clr.w	$a00(a0)
Ld38a
	move.w	$a00(a0),d1
	tst.l	$800(a0)
	bpl	Ld4d0
	addq.b	#7,d1
	bra	Ld4d0


Ld39c
	cmpi.b	#$29,$603(a0)
	bne.s	Ld3ca
	addi.l	#$8000,$a00(a0)
	cmpi.w	#$6,$a00(a0)
	bcs.s	Ld3b8
	clr.w	$a00(a0)
Ld3b8
	move.w	$a00(a0),d1
	tst.l	$800(a0)
	bpl	Ld4d0
	addq.b	#6,d1
	bra	Ld4d0


Ld3ca
	cmpi.b	#$1b,$603(a0)
	bne.s	Ld3e4
	tst.b	$800(a0)
	bpl	Ld4cc
	adda.l	#$280,a5
	bra	Ld4cc


Ld3e4
	cmpi.b	#$2d,$603(a0)
	bne.s	Ld3fe
	tst.l	$800(a0)
	bpl	Ld4cc
	suba.l	#$140,a5
	bra	Ld4cc


Ld3fe
	cmpi.b	#$7,$603(a0)
	bne.s	Ld416
	tst.w	$800(a0)
	bpl	Ld4cc
	eori.b	#$7,d1
	bra	Ld4cc


Ld416
	cmpi.b	#$1c,$603(a0)
	bne.s	Ld452
	tst.b	$a01(a0)
	beq.s	Ld42e
	moveq	#$5,d1
	clr.b	$a01(a0)
	bra	Ld4d0


Ld42e
	addq.w	#1,$a02(a0)
	cmpi.w	#$5,$a02(a0)
	bcs.s	Ld43e
	clr.w	$a02(a0)
Ld43e
	move.w	$a02(a0),d1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bra.s	Ld4d0


Ld452
	cmpi.b	#$2c,$603(a0)
	bne.s	Ld470
	addq.w	#1,$a02(a0)
	cmpi.w	#$6,$a02(a0)
	bcs.s	Ld46a
	clr.w	$a02(a0)
Ld46a
	move.w	$a02(a0),d1
	bra.s	Ld4d0


Ld470
	cmpi.b	#$27,$603(a0)
	bne.s	Ld48e
	addq.w	#1,$a02(a0)
	cmpi.w	#$5,$a02(a0)
	bcs.s	Ld488
	clr.w	$a02(a0)
Ld488
	move.w	$a02(a0),d1
	bra.s	Ld4d0


Ld48e
	cmpi.b	#$c,$603(a0)
	beq.s	Ld4a4
	move.b	$603(a0),d2
	andi.b	#$f8,d2
	cmpi.b	#$10,d2
	bne.s	Ld4b8
Ld4a4
	move.w	$a00(a0),d1
	tst.l	$800(a0)
	bpl.s	Ld4cc
	move.b	#$4,d2
	sub.b	d1,d2
	move.b	d2,d1
	bra.s	Ld4cc


Ld4b8
	cmpi.b	#$e,$603(a0)
	bne.s	Ld4cc
	moveq	#$0,d1
	tst.l	$800(a0)
	bmi.s	Ld4d4
	moveq	#$50,d1
	bra.s	Ld4d4


Ld4cc
	and.l	(a6,d0.w),d1
Ld4d0
	mulu.w	#$50,d1
Ld4d4
	adda.w	d1,a5
	move.l	a5,$dff050
	moveq	#$4,d1
Ld4de
	move.l	a2,$dff054
	move.l	a2,$dff04c
	move.w	d7,$dff058
	adda.l	#$1b50,a2
	dbra	d1,Ld4de
Ld4fa
	addq.l	#4,a0
	dbra	d6,Lcf46
	rts


	ds.w	160
Ld642	dc.w	$0000


Ld644
	movea.l	#$d502,a0
	movea.l	#$d7ea,a1
	movea.l	#$9970,a2
	moveq	#$1f,d0
Ld658
	clr.w	(a0)+
	clr.w	(a1)+
	clr.l	(a2)+
	dbra	d0,Ld658
	clr.w	L8832
	jmp	La04


Ld66e
	movea.l	#$d502,a0
	addq.w	#2,Ld642
	andi.w	#$3f,Ld642
	move.w	Ld642,d3
	adda.w	d3,a0
	andi.w	#$fffe,d0
	st	(a0)
	move.w	d0,$40(a0)
	move.w	d1,$80(a0)
	move.w	#$52,$c0(a0)
	move.w	d2,$100(a0)
	rts


Ld6a4
	movea.l	Le536,a1
	movea.l	#$ffea,a3
	move.w	Le126,d3
	moveq	#$1f,d7
	movea.l	#$d502,a0
Ld6be
	tst.w	(a0)
	beq	Ld780
	move.w	$40(a0),d4
	move.w	$80(a0),d5
	move.w	#$54,d6
	sub.w	$c0(a0),d6
	sub.w	Le0ea,d4
	tst.w	d4
	bpl.s	Ld6e2
	addi.w	#$800,d4
Ld6e2
	sub.w	d6,d5
	jsr	Ld788
	sub.w	d6,d5
	jsr	Ld788
	add.w	d6,d4
	add.w	d6,d4
	jsr	Ld788
	sub.w	d6,d4
	add.w	d6,d5
	jsr	Ld788
	add.w	d6,d5
	jsr	Ld788
	add.w	d6,d4
	jsr	Ld788
	add.w	d6,d5
	add.w	d6,d5
	jsr	Ld788
	sub.w	d6,d4
	sub.w	d6,d5
	jsr	Ld788
	sub.w	d6,d4
	jsr	Ld788
	add.w	d6,d5
	jsr	Ld788
	sub.w	d6,d4
	sub.w	d6,d4
	jsr	Ld788
	sub.w	d6,d5
	add.w	d6,d4
	jsr	Ld788
	sub.w	d6,d5
	jsr	Ld788
	sub.w	d6,d4
	jsr	Ld788
	sub.w	d6,d5
	sub.w	d6,d5
	jsr	Ld788
	add.w	d6,d4
	add.w	d6,d5
	jsr	Ld788
	sub.w	d3,$c0(a0)
	move.w	$c0(a0),(a0)
	tst.w	(a0)
	bpl.s	Ld780
	clr.w	(a0)
Ld780
	addq.l	#2,a0
	dbra	d7,Ld6be
	rts


Ld788
	andi.w	#$7ff,d4
	cmpi.w	#$16f,d4
	bcc.s	Ld7e8
	cmpi.w	#$97,d5
	bcc.s	Ld7e8
	movea.l	a1,a2
	clr.l	d0
	move.w	d5,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	adda.w	d0,a2
	move.w	d4,d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	move.w	$100(a0),d2
	clr.b	d0
	bset	d1,d0
	addq.b	#1,d1
	bset	d1,d0
	lsr.b	#1,d2
	bcc.s	Ld7c8
	move.b	d0,(a2)
Ld7c8
	lsr.b	#1,d2
	bcc.s	Ld7d0
	move.b	d0,$1b50(a2)
Ld7d0
	lsr.b	#1,d2
	bcc.s	Ld7d8
	move.b	d0,$36a0(a2)
Ld7d8
	lsr.b	#1,d2
	bcc.s	Ld7e0
	move.b	d0,$51f0(a2)
Ld7e0
	lsr.b	#1,d2
	bcc.s	Ld7e8
	move.b	d0,$6d40(a2)
Ld7e8
	rts


	ds.w	128
Ld8ea	dc.w	$0000


Ld8ec
	movea.l	#$d7ea,a0
	addq.w	#2,Ld8ea
	andi.w	#$3f,Ld8ea
	move.w	Ld8ea,d3
	adda.w	d3,a0
	andi.w	#$fffe,d0
	st	(a0)
	addq.w	#4,d0
	addq.w	#4,d1
	move.w	d0,$40(a0)
	move.w	d1,$80(a0)
	move.w	#$70,$c0(a0)
	rts


Ld922
	movea.l	#$ffea,a3
	movea.l	Le536,a1
	move.w	Le126,d3
	moveq	#$1f,d7
	movea.l	#$d7ea,a0
Ld93c
	tst.w	(a0)
	beq	Ld9fa
	move.w	$40(a0),d4
	move.w	$80(a0),d5
	move.w	$c0(a0),d6
	sub.w	Le0ea,d4
	tst.w	d4
	bpl.s	Ld95c
	addi.w	#$800,d4
Ld95c
	sub.w	d6,d5
	jsr	Lda06
	sub.w	d6,d5
	jsr	Lda06
	add.w	d6,d4
	add.w	d6,d4
	jsr	Lda06
	sub.w	d6,d4
	add.w	d6,d5
	jsr	Lda06
	add.w	d6,d5
	jsr	Lda06
	add.w	d6,d4
	jsr	Lda06
	add.w	d6,d5
	add.w	d6,d5
	jsr	Lda06
	sub.w	d6,d4
	sub.w	d6,d5
	jsr	Lda06
	sub.w	d6,d4
	jsr	Lda06
	add.w	d6,d5
	jsr	Lda06
	sub.w	d6,d4
	sub.w	d6,d4
	jsr	Lda06
	sub.w	d6,d5
	add.w	d6,d4
	jsr	Lda06
	sub.w	d6,d5
	jsr	Lda06
	sub.w	d6,d4
	jsr	Lda06
	sub.w	d6,d5
	sub.w	d6,d5
	jsr	Lda06
	add.w	d6,d4
	add.w	d6,d5
	jsr	Lda06
	sub.w	d3,$c0(a0)
	move.w	$c0(a0),(a0)
	tst.w	(a0)
	bpl.s	Ld9fa
	clr.w	(a0)
Ld9fa
	addq.l	#2,a0
	dbra	d7,Ld93c
	jmp	Lbca


Lda06
	andi.w	#$7ff,d4
	cmpi.w	#$170,d4
	bcc.s	Lda3e
	cmpi.w	#$97,d5
	bcc.s	Lda3e
	movea.l	a1,a2
	clr.l	d0
	move.w	d5,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	adda.w	d0,a2
	move.w	d4,d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	clr.b	d0
	bset	d1,d0
	addq.b	#1,d1
	bset	d1,d0
	move.b	d0,(a2)
Lda3e
	rts


Lda40
	movea.l	#$ffea,a3
	IFND	PROTECTION_DISABLED
	movea.l	#$feeb,a1
	adda.l	#$995,a1
	cmpi.l	#$c790007,(a1)
	bne.s	Lda40
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	movea.l	#$70796,a4
	movea.l	Le53a,a1
	adda.l	#$96,a1
	movea.l	#$b944,a0
	moveq	#$7f,d7
Lda74
	tst.w	(a0)
	beq	Ldb1a
	cmpi.w	#$72,$1002(a0)
	bcc	Ldb1a
	movea.l	a1,a2
	move.w	$400(a0),d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	move.w	(a3,d1.w),d1
	adda.w	d1,a2
	move.w	$200(a0),d0
	addi.w	#$340,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	move.w	$602(a0),d2
	add.w	d2,d2
	movea.l	#$cb44,a5
	move.w	(a5,d2.w),d2
	lsr.b	#1,d2
	bcc.s	Ldada
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldada
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldaea
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldaea
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldafa
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldafa
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldb0a
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldb0a
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldb1a
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldb1a
	addq.l	#4,a0
	dbra	d7,Lda74
	movea.l	Le53a,a1
	adda.l	#$660,a1
	ori.b	#$c0,(a1)
	ori.b	#$3,$3(a1)
	ori.b	#$80,$2e(a1)
	ori.b	#$1,$31(a1)
	adda.l	#$b80,a1
	ori.b	#$c0,(a1)
	ori.b	#$3,$3(a1)
	ori.b	#$80,$2e(a1)
	ori.b	#$1,$31(a1)
	adda.l	#$5c0,a1
	ori.b	#$c0,(a1)
	ori.b	#$3,$3(a1)
	ori.b	#$80,$2e(a1)
	ori.b	#$1,$31(a1)
	movea.l	Le53a,a1
	adda.l	#$9f8,a1
	ori.b	#$80,(a1)
	ori.b	#$1,$3(a1)
	ori.b	#$c0,$2e(a1)
	ori.b	#$3,$31(a1)
	adda.l	#$b80,a1
	ori.b	#$80,(a1)
	ori.b	#$1,$3(a1)
	ori.b	#$c0,$2e(a1)
	ori.b	#$3,$31(a1)
	adda.l	#$5c0,a1
	ori.b	#$80,(a1)
	ori.b	#$1,$3(a1)
	ori.b	#$c0,$2e(a1)
	ori.b	#$3,$31(a1)
	tst.w	L7264
	bne	Ldc7e
	tst.w	L7266
	beq	Ldc7e
	movea.l	Le53a,a2
	adda.l	#$96,a2
	move.w	L726c,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	move.w	(a3,d1.w),d1
	adda.w	d1,a2
	move.w	L7268,d0
	addi.w	#$340,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	moveq	#$1a,d2
	lsr.b	#1,d2
	bcc.s	Ldc3e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldc3e
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldc4e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldc4e
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldc5e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldc5e
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldc6e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldc6e
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldc7e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldc7e
	tst.w	L74b4
	bne	Ldd28
	tst.w	L74b6
	beq	Ldd28
	movea.l	Le53a,a2
	adda.l	#$96,a2
	move.w	L74bc,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	move.w	(a3,d1.w),d1
	adda.w	d1,a2
	move.w	L74b8,d0
	addi.w	#$340,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	moveq	#$1a,d2
	lsr.b	#1,d2
	bcc.s	Ldce8
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldce8
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldcf8
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldcf8
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldd08
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldd08
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldd18
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldd18
	adda.l	#$5c0,a2
	lsr.b	#1,d2
	bcc.s	Ldd28
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldd28
	movea.l	Le53a,a2
	adda.l	#$96,a2
	move.w	#$64,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	move.w	(a3,d1.w),d1
	adda.w	d1,a2
	move.w	L8788,d0
	addi.w	#$340,d0
	sub.w	Le0ea,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	moveq	#$3,d3
Ldd72
	moveq	#$1a,d2
	lsr.b	#1,d2
	bcc.s	Ldd7e
	move.b	(a2),d0
	bset	d1,d0
	move.b	d0,(a2)
Ldd7e
	lsr.b	#1,d2
	bcc.s	Ldd8c
	move.b	$5c0(a2),d0
	bset	d1,d0
	move.b	d0,$5c0(a2)
Ldd8c
	lsr.b	#1,d2
	bcc.s	Ldd9a
	move.b	$b80(a2),d0
	bset	d1,d0
	move.b	d0,$b80(a2)
Ldd9a
	lsr.b	#1,d2
	bcc.s	Ldda8
	move.b	$1140(a2),d0
	bset	d1,d0
	move.b	d0,$1140(a2)
Ldda8
	lsr.b	#1,d2
	bcc.s	Lddb6
	move.b	$1700(a2),d0
	bset	d1,d0
	move.b	d0,$1700(a2)
Lddb6
	adda.l	#$5c,a2
	dbra	d3,Ldd72
	tst.w	L5532
	beq	Ldf4e
	move.l	Le53a,L1337a
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$20,L13380
	move.w	#$60,L13386
	move.w	#$3,L13388
	move.w	#$c0,L1338a
	move.w	#$13,L1338c
	move.w	#$10,L1339a
	move.w	#$16,L1339c
	move.l	#$2c,L1339e
	move.w	#$1,L133a4
	move.l	L37c6,L1338e
	addi.l	#$7c86,L1338e
	move.w	L5534,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Lde58
	addi.w	#$800,d0
Lde58
	addi.w	#$320,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	addi.w	#$60,d0
	move.w	d0,L13396
	move.w	#$2,L13398
	movem.l	d0/a4,-(a7)
	jsr	L133b4
	movem.l	(a7)+,d0/a4
	cmpi.w	#$110,d0
	bcs	Ldf4e
	move.l	Le53a,L1337a
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$20,L13380
	move.w	#$60,L13386
	move.w	#$3,L13388
	move.w	#$c0,L1338a
	move.w	#$13,L1338c
	move.w	#$10,L1339a
	move.w	#$16,L1339c
	move.l	#$2c,L1339e
	move.w	#$1,L133a4
	move.l	L37c6,L1338e
	addi.l	#$7c86,L1338e
	move.w	L5534,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Ldf20
	addi.w	#$800,d0
Ldf20
	addi.w	#$320,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	addi.w	#$60,d0
	subi.w	#$c0,d0
	move.w	d0,L13396
	move.w	#$2,L13398
	jsr	L133b4
Ldf4e
	tst.w	L648a
	beq	Le0e8
	IFND	PROTECTION_DISABLED
Ldf58	cmpi.l	#$4eb90004,L108d8
	bne.s	Ldf58
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	move.l	Le53a,L1337a
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$20,L13380
	move.w	#$60,L13386
	move.w	#$3,L13388
	move.w	#$c0,L1338a
	move.w	#$13,L1338c
	move.w	#$10,L1339a
	move.w	#$16,L1339c
	move.l	#$2c,L1339e
	move.w	#$1,L133a4
	move.l	L37ca,L1338e
	addi.l	#$2684,L1338e
	move.w	L648c,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Ldff2
	addi.w	#$800,d0
Ldff2
	addi.w	#$320,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	addi.w	#$60,d0
	move.w	d0,L13396
	move.w	#$2,L13398
	movem.l	d0/a4,-(a7)
	jsr	L133b4
	movem.l	(a7)+,d0/a4
	cmpi.w	#$110,d0
	bcs	Le0e8
	move.l	Le53a,L1337a
	move.l	#$5c0,L13382
	move.w	#$170,L1337e
	move.w	#$20,L13380
	move.w	#$60,L13386
	move.w	#$3,L13388
	move.w	#$c0,L1338a
	move.w	#$13,L1338c
	move.w	#$10,L1339a
	move.w	#$16,L1339c
	move.l	#$2c,L1339e
	move.w	#$1,L133a4
	move.l	L37ca,L1338e
	addi.l	#$2684,L1338e
	move.w	L648c,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	Le0ba
	addi.w	#$800,d0
Le0ba
	addi.w	#$320,d0
	andi.w	#$7ff,d0
	lsr.w	#2,d0
	andi.w	#$fffe,d0
	move.w	(a4,d0.w),d0
	addi.w	#$60,d0
	subi.w	#$c0,d0
	move.w	d0,L13396
	move.w	#$2,L13398
	jsr	L133b4
Le0e8
	rts


Le0ea
	dc.w	$0000
Le0ec
	dc.w	$0001,$ffff,$0000,$0001,$0000,$8000,$0001,$0000,$0002,$0000,$0000,$2800,$0000,$5000,$0000,$a000
	dc.w	$ffff,$e800,$ffff,$d000,$ffff,$a000,$0000,$1000,$0000,$2000,$0000,$3000
Le124
	dc.b	$00
Le125
	dc.b	$00
Le126
	dc.b	$00
Le127
	dc.b	$01


	movem.l	d0/a0,-(a7)
	move.w	$dff01e,d0
	btst	#$4,d0
	bne.s	Le14e
	btst	#$5,d0
	bne.s	Le164
	andi.w	#$7fff,d0
	move.w	d0,$dff09c
	movem.l	(a7)+,d0/a0
	rte


Le14e
	addq.b	#1,Le125
	move.w	#$10,$dff09c
	movem.l	(a7)+,d0/a0
	rte


Le162
	dc.w	$0000


Le164
	addq.b	#1,Le162
	movea.l	Le248,a0
	cmpa.l	#$0,a0
	beq.s	Le18a
	move.w	(a0)+,Ledca
	cmpi.w	#-$1,(a0)
	bne.s	Le18a
	movea.l	#$0,a0
Le18a
	move.l	a0,Le248
	movea.l	Le24c,a0
	cmpa.l	#$0,a0
	beq.s	Le1b0
	move.w	(a0)+,Lef62
	cmpi.w	#-$1,(a0)
	bne.s	Le1b0
	movea.l	#$0,a0
Le1b0
	move.l	a0,Le24c
	movem.l	(a7)+,d0/a0
	move.w	#$20,$dff09c
	rte


	movem.l	d0-d1/a0,-(a7)
	move.w	$dff01e,d0
	btst	#$4,d0
	bne.s	Le1ea
	btst	#$5,d0
	bne.s	Le1fe
	andi.w	#$7fff,d0
	move.w	d0,$dff09c
	movem.l	(a7)+,d0-d1/a0
	rte


Le1ea
	addq.b	#1,Le125
	move.w	#$10,$dff09c
	movem.l	(a7)+,d0-d1/a0
	rte


Le1fe
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	Leace
	movem.l	(a7)+,d0-d7/a0-a6
	move.l	$e(a7),d0
	cmpi.l	#$1668,d0
	bcs.s	Le220
	cmpi.l	#$168c,d0
	bcs.s	Le23a
Le220
	jsr	L16c5c
	jsr	L16d18
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	L1732e
	movem.l	(a7)+,d0-d7/a0-a6
Le23a
	movem.l	(a7)+,d0-d1/a0
	move.w	#$20,$dff09c
	rte


Le248
	dc.w	$0000,$0000
Le24c
	dc.w	$0000,$0000,$000f,$000e,$000d,$000c,$000b,$000a,$0009,$0008,$0007,$0006,$0005,$0004,$0003,$0002
	dc.w	$0001,$0000,$ffff,$00f0,$00e0,$00d0,$00c0,$00b0,$00a0,$0090,$0080,$0070,$0060,$0050,$0040,$0030
	dc.w	$0020,$0010,$0000,$ffff,$0800,$0700,$0600,$0500,$0400,$0300,$0200,$0000,$ffff,$0fff,$0eef,$0ddf
	dc.w	$0ccf,$0bbf,$0aaf,$099f,$088f,$077f,$066f,$055f,$044f,$033f,$022f,$011f,$000e,$000d,$000c,$000b
	dc.w	$000a,$0009,$0008,$0007,$0006,$0005,$0004,$0003,$0002,$0001,$0000,$ffff,$0fff,$0efe,$0dfd,$0cfc
	dc.w	$0bfb,$0afa,$09f9,$08f8,$07f7,$06f6,$05f5,$04f4,$03f3,$02f2,$01f1,$00e0,$00d0,$00c0,$00b0,$00a0
	dc.w	$0090,$0080,$0070,$0060,$0050,$0040,$0030,$0020,$0010,$0000,$ffff,$0550,$0440,$0330,$0220,$0000
	dc.w	$ffff,$0fff,$0eee,$0ddd,$0ccc,$0bbb,$0aaa,$0999,$0888,$0777,$0666,$0555,$0444,$0333,$0222,$0111
	dc.w	$0000,$ffff,$0f00,$0000,$0d00,$0000,$0b00,$0000,$0900,$0000,$0700,$0000,$0500,$0000,$0300,$0000
	dc.w	$0200,$0000,$ffff,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff
	dc.w	$0333,$0fff,$0333,$0fff,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333
	dc.w	$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0fff,$0333,$0000,$ffff,$0fff,$0ccc
	dc.w	$0777,$0222,$0000,$ffff
Le534
	dc.b	$00
Le535
	dc.b	$00
Le536
	dc.w	$0004,$f73a
Le53a
	dc.w	$0004,$f73a
Le53e
	dc.w	$0004,$f73a
Le542
	dc.w	$0004,$f73a,$0000,$0005,$7fca,$0004,$f73c,$0005,$128c,$0005,$2ddc,$0005,$492c,$0005,$647c,$0004
	dc.w	$f73a,$0005,$7fcc,$0005,$9b1c,$0005,$b66c,$0005,$d1bc,$0005,$ed0c,$0006,$251a,$0006,$085c,$0006
	dc.w	$0e1c,$0006,$13dc,$0006,$199c,$0006,$1f5c,$0006,$085a,$0006,$251c,$0006,$2adc,$0006,$309c,$0006
	dc.w	$365c,$0006,$3c1c,$0005,$83da,$0004,$d02c,$0004,$f41c,$0005,$180c,$0005,$3bfc,$0005,$5fec,$0004
	dc.w	$d02a,$0005,$83dc,$0005,$a7cc,$0005,$cbbc,$0005,$efac,$0006,$139c,$0005,$aaea,$0004,$f73c,$0005
	dc.w	$1b2c,$0005,$3f1c,$0005,$630c,$0005,$86fc,$0004,$f73a,$0005,$aaec,$0005,$cedc,$0005,$f2cc,$0006
	dc.w	$16bc,$0006,$3aac,$0005,$a466,$0004,$d626,$0004,$ff66,$0005,$28a6,$0005,$51e6,$0005,$7b26,$0004
	dc.w	$d626,$0005,$a466,$0005,$cda6,$0005,$f6e6,$0006,$2026,$0006,$4966,$0005,$0c32,$0004,$f73a,$0005
	dc.w	$212a,$0005,$3622,$0005,$b082,$0005,$4b1a,$0005,$5f62,$0005,$73aa,$0005,$87f2,$0005,$9c3a,$0004
	dc.w	$f73a,$0005,$0c32,$0005,$212a,$0005,$3622,$0005,$4b1a,$0005,$b082,$0005,$c4ca,$0005,$d912,$0005
	dc.w	$ed5a,$0006,$01a2,$0006,$ca7a,$0005,$fc3a,$0006,$257a,$0006,$4eba,$0006,$77fa,$0006,$a13a,$0005
	dc.w	$fc3a,$0006,$ca7a,$0006,$f3ba,$0007,$1cfa,$0007,$463a,$0007,$6f7a,$0005,$42da,$0004,$749a,$0004
	dc.w	$9dda,$0004,$c71a,$0004,$f05a,$0005,$199a,$0004,$749a,$0005,$42da,$0005,$6c1a,$0005,$955a,$0005
	dc.w	$be9a,$0005,$e7da


Le6e8
	eori.b	#$18,Le535
	movea.l	#$e548,a0
	movea.l	#$e578,a2
	adda.w	Le534,a0
	adda.w	Le534,a2
	move.l	(a0)+,Le536
	move.l	Le536,$8
	move.l	(a2)+,Le53a
	movea.l	Le53e,a1
	movea.l	Le542,a3
	moveq	#$9,d0
Le72c
	move.w	(a0)+,(a1)
	move.w	(a2)+,(a3)
	addq.l	#4,a1
	addq.l	#4,a3
	dbra	d0,Le72c
	rts


Le73a
	addi.b	#$18,Le535
	cmpi.b	#$30,Le535
	bne.s	Le752
	clr.b	Le535
Le752
	movea.l	#$e5a8,a0
	adda.w	Le534,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$9,d0
Le76c
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le76c
	jmp	Lbca


Le77a
	addi.b	#$18,Le535
	cmpi.b	#$30,Le535
	bne.s	Le792
	clr.b	Le535
Le792
	movea.l	#$e5d8,a0
	adda.w	Le534,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$9,d0
Le7ac
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le7ac
	rts


Le7b6
	addi.b	#$18,Le535
	cmpi.b	#$30,Le535
	bne.s	Le7ce
	clr.b	Le535
Le7ce
	movea.l	#$e608,a0
	move.w	Le534,d0
	ext.l	d0
	adda.l	d0,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$9,d0
Le7ec
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le7ec
	rts


Le7f6
	addi.b	#$28,Le535
	cmpi.b	#$50,Le535
	bne.s	Le80e
	clr.b	Le535
Le80e
	movea.l	#$e638,a0
	adda.w	Le534,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$5,d0
Le828
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le828
	move.l	(a0)+,Le53a
	movea.l	Le542,a1
	moveq	#$9,d0
Le83e
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le83e
	rts


Le848
	addi.b	#$18,Le535
	cmpi.b	#$30,Le535
	bne.s	Le860
	clr.b	Le535
Le860
	movea.l	#$e688,a0
	move.w	Le534,d0
	ext.l	d0
	adda.l	d0,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$9,d0
Le87e
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le87e
	rts


Le888
	addi.b	#$18,Le535
	cmpi.b	#$30,Le535
	bne.s	Le8a0
	clr.b	Le535
Le8a0
	movea.l	#$e6b8,a0
	move.w	Le534,d0
	ext.l	d0
	adda.l	d0,a0
	move.l	(a0)+,Le536
	movea.l	Le53e,a1
	moveq	#$9,d0
Le8be
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,Le8be
	rts


Le8c8
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$2,$dff066
	move.l	Le536,d0
	addq.l	#2,d0
	move.l	d0,$dff054
	move.w	#$be16,$dff058
	rts


Le902
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$16,$dff066
	moveq	#$4,d1
	move.l	Le53a,d0
	addi.l	#$96,d0
Le932
	jsr	Leaae
	move.l	d0,$dff054
	move.w	#$4cc,$dff058
	addi.l	#$5c0,d0
	dbra	d1,Le932
	rts


Le952
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$0,$dff066
	move.l	#$641da,$dff054
	move.w	#$997,$dff058
	rts


Le988
	move.w	Le124,d0
Le98e
	cmp.w	Le124,d0
	beq.s	Le98e
	cmpi.w	#$1,Le124
	beq.s	Le988
	move.w	Le124,Le126
	clr.w	Le124
	movea.l	#$e0ee,a0
	move.w	Le0ec,d0
	add.b	d0,d0
	move.w	(a0,d0.w),d0
	add.w	d0,Le126
	bsr	Le6e8
	rts


Le9ce
	move.w	Le124,d0
Le9d4
	cmp.w	Le124,d0
	beq.s	Le9d4
	move.w	Le124,Le126
	clr.w	Le124
	bsr	Le73a
	rts


Le9f2
	move.w	Le124,d0
Le9f8
	cmp.w	Le124,d0
	beq.s	Le9f8
	move.w	Le124,Le126
	clr.w	Le124
	bsr	Le77a
	jmp	Lbca


Lea1a
	move.w	Le124,d0
Lea20
	cmp.w	Le124,d0
	beq.s	Lea20
	move.w	Le124,Le126
	clr.w	Le124
	bsr	Le7b6
	rts


Lea3e
	move.w	Le124,d0
Lea44
	cmp.w	Le124,d0
	beq.s	Lea44
	move.w	Le124,Le126
	clr.w	Le124
	jsr	Le7f6
	rts


Lea64
	move.w	Le124,d0
Lea6a
	cmp.w	Le124,d0
	beq.s	Lea6a
	move.w	Le124,Le126
	clr.w	Le124
	jsr	Le848
	rts


Lea8a
	move.w	Le124,d0
Lea90
	cmp.w	Le124,d0
	beq.s	Lea90
	move.w	Le124,Le126
	clr.w	Le124
	bsr	Le888
	rts


Leaae
	btst	#6,$dff002
	bne.s	Leaae
	rts


Leaba
	dc.w	$0000,$0000
Leabe
	dc.w	$0000,$0000
Leac2
	dc.w	$0000,$0000
Leac6
	dc.w	$000f
Leac8
	dc.w	$0000,$8000
Leacc
	dc.w	$0000


Leace
	tst.w	Leaba
	beq	Leb86
	move.w	Leaba,d0
	move.l	Leac8,d1
	sub.l	d1,Leaba
	cmp.w	Leaba,d0
	beq	Leb86
	move.w	Leacc,d3
	movea.l	Leabe,a0
	movea.l	Leac2,a1
	move.w	Leac6,d7
	subq.b	#1,d7
Leb0e
	cmpi.w	#$180,-$2(a1)
	bcs.s	Leb88
	cmpi.w	#$1c0,-$2(a1)
	bcc.s	Leb88
	tst.w	d3
	beq.s	Leb28
	cmp.w	-$2(a1),d3
	bne.s	Leb88
Leb28
	move.w	(a0),d0
	move.w	(a1),d1
	move.w	d1,d2
	andi.w	#$f,d0
	andi.w	#$f,d1
	cmp.w	d0,d1
	beq.s	Leb46
	bcc.s	Leb42
	addi.w	#$1,d2
	bra.s	Leb46


Leb42
	subi.w	#$1,d2
Leb46
	move.w	(a0),d0
	move.w	(a1),d1
	andi.w	#$f0,d0
	andi.w	#$f0,d1
	cmp.w	d0,d1
	beq.s	Leb62
	bcc.s	Leb5e
	addi.w	#$10,d2
	bra.s	Leb62


Leb5e
	subi.w	#$10,d2
Leb62
	move.w	(a0)+,d0
	move.w	(a1),d1
	andi.w	#$f00,d0
	andi.w	#$f00,d1
	cmp.w	d0,d1
	beq.s	Leb7e
	bcc.s	Leb7a
	addi.w	#$100,d2
	bra.s	Leb7e


Leb7a
	subi.w	#$100,d2
Leb7e
	move.w	d2,(a1)
Leb80
	addq.l	#4,a1
	dbra	d7,Leb0e
Leb86
	rts


Leb88
	addq.w	#1,d7
	bra.s	Leb80


	dc.w	$0411,$0fc0,$0eb0,$0d91,$0c81,$0c71,$0b61,$0a51,$0952,$0842,$0732,$0632,$0621,$0521,$0411,$0311
	dc.w	$0003,$0fff,$0dde,$0bbd,$099c,$088b,$066a,$0559,$0448,$0337,$0226,$0115,$0114,$0003,$0002,$0001
	dc.w	$0300,$0fee,$0ecc,$0daa,$0c99,$0b77,$0a66,$0955,$0844,$0733,$0622,$0511,$0411,$0300,$0200,$0100
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


Lec0c
	tst.w	L11b2c
	bne	Lecbe
	move.w	L10aa2,d0
	andi.b	#$3,d0
	tst.b	d0
	beq.s	Lec5a
Lec24
	move.w	#$10,Leac6
	move.l	#$eb8c,Leabe
	move.l	#$ee62,Leac2
	move.l	#$100000,Leaba
	move.l	#$4000,Leac8
	jmp	Lbca


Lec5a
	move.w	#$10,Leac6
	move.l	#$ebac,Leabe
	move.l	#$ee62,Leac2
	move.l	#$100000,Leaba
	move.l	#$4000,Leac8
	rts


Lec8c
	move.w	#$10,Leac6
	move.l	#$ebec,Leabe
	move.l	#$ee62,Leac2
	move.l	#$100000,Leaba
	move.l	#$10000,Leac8
	rts


Lecbe
	move.w	#$10,Leac6
	move.l	#$ebcc,Leabe
	move.l	#$ee62,Leac2
	move.l	#$100000,Leaba
	move.l	#$8000,Leac8
	rts


	dc.w	$0180,$0000,$0100,$0200,$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000,$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000,$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000,$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e,$2a71,$0090,$f4d1,$0092,$0030
	dc.w	$0094,$00d8,$0102,$0000,$0108,$0002,$010a,$0002,$00e0
Led62
	dc.w	$0000,$00e2
Led66
	dc.w	$0000,$00e4,$0000,$00e6,$0000,$00e8,$0000,$00ea,$0000,$00ec,$0000,$00ee,$0000,$00f0,$0000,$00f2
	dc.w	$0000,$0120
Led8a
	dc.w	$0001,$0122
Led8e
	dc.w	$3e24,$0124
Led92
	dc.w	$0001,$0126
Led96
	dc.w	$3fb8,$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000,$0130,$0000,$0132,$0000,$0134,$0000,$0136
	dc.w	$0000,$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000,$0180
Ledca
	dc.w	$0000,$0182,$0fff,$0184
Ledd2
	dc.w	$068f,$0186,$0c4c,$0188,$0808,$018a,$0d96,$018c,$0a74,$018e,$0853,$0190,$0642,$0192,$0532,$0194
	dc.w	$0420,$0196,$0700,$0198,$0b10,$019a,$0e10,$019c,$0f50,$019e,$0f80,$01a0,$0fc2,$01a2,$0ac1,$01a4
	dc.w	$06a1,$01a6,$0380,$01a8,$0160,$01aa,$0040,$01ac,$0226,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4
	dc.w	$0eee,$01b6,$0888,$01b8,$0666,$01ba,$0555,$01bc,$0444,$01be,$0222,$c201,$ff00,$0100,$0200,$0092
	dc.w	$0028,$0108,$00fc,$010a,$00fc,$0102,$0000,$0180
Lee62
	dc.w	$0411,$0182,$0fc0,$0184,$0eb0,$0186,$0d91,$0188,$0c81,$018a,$0c71,$018c,$0b61,$018e,$0a51,$0190
	dc.w	$0952,$0192,$0842,$0194,$0732,$0196,$0632,$0198,$0621,$019a,$0521,$019c,$0411,$019e,$0311,$01a0
	dc.w	$0000,$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000,$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae
	dc.w	$0000,$01b0,$0000,$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000,$01b8,$0000,$01ba,$0000,$01bc
	dc.w	$0000,$01be,$0000,$01b0,$0000,$00e0,$0005,$00e2,$0000,$00e4,$0005,$00e6,$1280,$00e8,$0005,$00ea
	dc.w	$2500,$00ec,$0005,$00ee,$3780,$00f0,$0005,$00f2,$4a00,$c301,$ff00,$0100,$5200,$0180,$0000,$d301
	dc.w	$ff00,$0100,$0200,$0092,$0030,$0108,$0002,$010a,$0002,$0102,$0000,$00e0,$0000,$00e2,$0000,$00e4
	dc.w	$0000,$00e6,$0000,$00e8,$0000,$00ea,$0000,$00ec,$0000,$00ee,$0000,$00f0,$0000,$00f2,$0000,$0180
Lef62
	dc.w	$0000,$0182,$0fff,$0184,$068f,$0186,$0c4c,$0188,$0909,$018a,$0d96,$018c,$0a74,$018e,$0853,$0190
	dc.w	$0642,$0192,$0532,$0194,$0420,$0196,$0700,$0198,$0b10,$019a,$0e10,$019c,$0f50,$019e,$0f80,$01a0
	dc.w	$0fc2,$01a2,$0ac1,$01a4,$06a1,$01a6,$0380,$01a8,$0160,$01aa,$0040,$01ac,$0226,$01ae,$0448,$01b0
	dc.w	$0569,$01b2,$088b,$01b4,$0eee,$01b6,$0888,$01b8,$0666,$01ba,$0555,$01bc,$0444,$01be,$0222,$d401
	dc.w	$ff00,$5100,$5200,$d601,$ff00,$009c,$8010,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e,$2a71,$0090
	dc.w	$f2d1,$0092,$0030,$0094,$00d8,$0108,$0002,$010a,$0002,$00e0,$0000,$00e2,$0000,$00e4,$0000,$00e6
	dc.w	$0000,$00e8,$0000,$00ea,$0000,$00ec,$0000,$00ee,$0000,$00f0,$0000,$00f2,$0000,$0180,$0000,$0182
	dc.w	$0f00,$0184,$0f00,$0186,$0b0b,$0188,$0909,$018a,$0d96,$018c,$0a74,$018e,$0853,$0190,$0642,$0192
	dc.w	$0532,$0194,$0420,$0196,$0700,$0198,$0b10,$019a,$0e10,$019c,$0f50,$019e,$0f80,$01a0,$0fc2,$01a2
	dc.w	$0ac1,$01a4,$06a1,$01a6,$0380,$01a8,$0160,$01aa,$0040,$01ac,$0226,$01ae,$0448,$01b0,$0569,$01b2
	dc.w	$088b,$01b4,$0eee,$01b6,$0888,$01b8,$0666,$01ba,$0555,$01bc,$0444,$01be,$0222,$d001,$ff00,$009c
	dc.w	$8010,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e,$2c81,$0090,$f4c1,$0092,$0038,$0094,$00d0,$0108
	dc.w	$0000,$010a,$0000,$00e0,$0005,$00e2,$0000,$00e4,$0005,$00e6,$1f40,$00e8,$0005,$00ea,$3e80,$00ec
	dc.w	$0005,$00ee,$5dc0,$00f0,$0005,$00f2,$7d00,$0180,$0000,$0182,$0f00,$0184,$0f00,$0186,$0b0b,$0188
	dc.w	$0909,$018a,$0d96,$018c,$0a74,$018e,$0853,$0190,$0642,$0192,$0532,$0194,$0420,$0196,$0700,$0198
	dc.w	$0b10,$019a,$0e10,$019c,$0f50,$019e,$0f80,$01a0,$0fc2,$01a2,$0ac1,$01a4,$06a1,$01a6,$0380,$01a8
	dc.w	$0160,$01aa,$0040,$01ac,$0226,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4,$0eee,$01b6,$0888,$01b8
	dc.w	$0666,$01ba,$0555,$01bc,$0444,$01be,$0222,$9801,$ff00,$0180,$0000,$0182,$0f00,$0184,$0f00,$0186
	dc.w	$0b0b,$0188,$0909,$018a,$0d96,$018c,$0a74,$018e,$0853,$0190,$0642,$0192,$0532,$0194,$0420,$0196
	dc.w	$0700,$0198,$0b10,$019a,$0e10,$019c,$0f50,$019e,$0f80,$01a0,$0fc2,$01a2,$0ac1,$01a4,$06a1,$01a6
	dc.w	$0380,$01a8,$0160,$01aa,$0040,$01ac,$0226,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4,$0eee,$01b6
	dc.w	$0888,$01b8,$0666,$01ba,$0555,$01bc,$0444,$01be,$0222,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e
	dc.w	$1671,$0090,$06d1,$0092,$0030,$0094,$00d8,$0102,$0000,$0108,$0000,$010a,$0000,$00e0,$0005,$00e2
	dc.w	$42da,$00e4,$0005,$00e6,$6c1a,$00e8,$0005,$00ea,$955a,$00ec,$0005,$00ee,$be9a,$00f0,$0005,$00f2
	dc.w	$e7da,$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000,$0128,$0000,$012a,$0000,$012c,$0000,$012e
	dc.w	$0000,$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000,$0138,$0000,$013a,$0000,$013c,$0000,$013e
	dc.w	$0000,$0180,$0000,$0182,$0fff,$0184,$0f00,$0186,$0fde,$0188,$0fbc,$018a,$0fac,$018c,$0f9b,$018e
	dc.w	$0e7a,$0190,$0d59,$0192,$0c18,$0194,$0a18,$0196,$0808,$0198,$0606,$019a,$0505,$019c,$0404,$019e
	dc.w	$0303,$01a2,$038a,$01a4,$0068,$01a6,$0057,$01bc,$0f83,$01be,$0f83,$01a0,$05ac,$01a8,$0bce,$01aa
	dc.w	$09ac,$01ac,$089b,$01ae,$078a,$01b0,$0679,$01b2,$0568,$01b4,$0457,$01b6,$0346,$01b8,$0235,$01ba
	dc.w	$0dee,$01bc,$0c63,$01be,$0a54,$0184,$0a00,$3301,$ff00,$0184,$0b00,$3601,$ff00,$0184,$0c00,$3901
	dc.w	$ff00,$0184,$0e00,$3c01,$ff00,$0184,$0f40,$3e01,$ff00,$0184,$0f60,$4101,$ff00,$0184,$0f70,$4401
	dc.w	$ff00,$0184,$0f80,$4701,$ff00,$0184,$0f90,$4a01,$ff00,$0184,$0fa0,$4c01,$ff00,$0184,$0fb0,$4f01
	dc.w	$ff00,$0184,$0fc0,$5201,$ff00,$0184,$0fd0,$5501,$ff00,$0184,$0fe0,$6b01,$ff00,$01a8,$0bce,$01aa
	dc.w	$09ac,$01ac,$089b,$01ae,$078a,$01b0,$0679,$01b2,$0568,$01b4,$0457,$01b6,$0346,$01b8,$0235,$a301
	dc.w	$ff00,$019a,$0945,$019c,$0745,$019e,$0636,$01a0,$0537,$01a2,$0437,$01a4,$0227,$01a6,$0005,$0196
	dc.w	$0f83,$0198,$0e70,$b901,$ff00,$0186,$0fb9,$0188,$0f96,$018a,$0f83,$018c,$0e70,$018e,$0c63,$0190
	dc.w	$0a54,$0192,$0755,$0194,$0544,$d001,$ff00,$019a,$0bef,$019c,$09df,$019e,$07cd,$01a0,$05ac,$01a2
	dc.w	$038a,$01a4,$0068,$01a6,$0057,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e,$1571,$0090,$05d1,$0092
	dc.w	$0030,$0094,$00d8,$0102,$0000,$0108,$0000,$010a,$0000,$00e0,$0005,$00e2,$0000,$00e4,$0005,$00e6
	dc.w	$2940,$00e8,$0005,$00ea,$5280,$00ec,$0005,$00ee,$7bc0,$00f0,$0005,$00f2,$a500,$0120,$0000,$0122
	dc.w	$0000,$0124,$0000,$0126,$0000,$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000,$0130,$0000,$0132
	dc.w	$0000,$0134,$0000,$0136,$0000,$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000,$0180,$0000,$0182
	dc.w	$0fdc,$0184,$0dba,$0186,$0b98,$0188,$0976,$018a,$0754,$018c,$0aaa,$018e,$0f09,$0190,$0642,$0192
	dc.w	$0532,$0194,$0420,$0196,$0700,$0198,$0b10,$019a
Lf4f2
	dc.w	$0e10,$019c,$0f50,$019e,$0f80,$01a0,$0fc2,$01a2,$0777,$01a4,$0555,$01a6,$0180,$01a8,$0160,$01aa
	dc.w	$0040,$01ac,$0227,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4,$0888,$01b6,$0666,$01b8,$0444,$01ba
	dc.w	$0333,$01bc,$0222,$01be,$0111,$3001,$ff00,$019a,$0000,$3101,$ff00,$019a,$0000,$3201,$ff00,$019a
	dc.w	$0000,$3301,$ff00,$019a,$0000,$3401,$ff00,$019a,$0000,$3501,$ff00,$019a,$0000,$3601,$ff00,$019a
	dc.w	$0000,$3701,$ff00,$019a,$0000,$3801,$ff00,$019a,$0000,$3901,$ff00,$019a,$0000,$3a01,$ff00,$019a
	dc.w	$0000,$3b01,$ff00,$019a,$0000,$3c01,$ff00,$019a,$0000,$3d01,$ff00,$019a,$0000,$3e01,$ff00,$019a
	dc.w	$0000,$3f01,$ff00,$019a,$0000,$4001,$ff00,$019a,$0000,$4101,$ff00,$019a,$0000,$4201,$ff00,$019a
	dc.w	$0000,$4301,$ff00,$019a,$0000,$4401,$ff00,$019a,$0000,$4501,$ff00,$019a,$0000,$4601,$ff00,$019a
	dc.w	$0000,$4701,$ff00,$019a,$0000,$4801,$ff00,$019a,$0000,$4901,$ff00,$019a,$0000,$4a01,$ff00,$019a
	dc.w	$0000,$4b01,$ff00,$019a,$0000,$4c01,$ff00,$019a,$0000,$4c01,$ff00,$019a,$0000,$4d01,$ff00,$019a
Lf632
	dc.w	$0e10,$ff01,$ff00,$009c,$8010,$ffff,$fffe,$0100,$5200,$0104,$0000,$008e,$1671,$0090,$06d1,$0092
	dc.w	$0030,$0094,$00d8,$0102,$0000,$0108,$0000,$010a,$0000,$00e0,$0005,$00e2,$42da,$00e4,$0005,$00e6
	dc.w	$6c1a,$00e8,$0005,$00ea,$955a,$00ec,$0005,$00ee,$be9a,$00f0,$0005,$00f2,$e7da,$0120,$0000,$0122
	dc.w	$0000,$0124,$0000,$0126,$0000,$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000,$0130,$0000,$0132
	dc.w	$0000,$0134,$0000,$0136,$0000,$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000,$0180,$0000,$0182
	dc.w	$0fff,$0184,$0900,$0186,$0fde,$0188,$0fbc,$018a,$0fac,$018c,$0f9b,$018e,$0e7a,$0190,$0d59,$0192
	dc.w	$0c18,$0194,$0a18,$0196,$0808,$0198,$0606,$019a,$0505,$019c,$0404,$019e,$0303,$01a0,$05ac,$01a2
	dc.w	$038a,$01a4,$0068,$01a6,$0057,$01a8,$09df,$01aa,$07cf,$01ac,$0046,$01ae,$0035,$01b0,$0ff6,$01b2
	dc.w	$0fa0,$01b4,$0f63,$01b6,$0445,$01b8,$0334,$01ba,$0eee,$01bc,$0f00,$01be,$0b00,$9001,$ff00,$01a0
	dc.w	$05ac,$01a8,$0bce,$01aa,$09ac,$01ac,$089b,$01ae,$078a,$01b0,$0679,$01b2,$0568,$01b4,$0457,$01b6
	dc.w	$0346,$01b8,$0235,$01ba,$0dee,$01bc,$0c63,$01be,$0a54,$a301,$ff00,$019a,$0945,$019c,$0745,$019e
	dc.w	$0636,$01a0,$0537,$01a2,$0437,$01a4,$0227,$01a6,$0005,$0196,$0f83,$0198,$0e70,$b901,$ff00,$0186
	dc.w	$0fb9,$0188,$0f96,$018a,$0f83,$018c,$0e70,$018e,$0c63,$0190,$0a54,$0192,$0755,$0194,$0544,$d001
	dc.w	$ff00,$019a,$0bef,$019c,$09df,$019e,$07cd,$01a0,$05ac,$01a2,$038a,$01a4,$0068,$01a6,$0057,$df01
	dc.w	$ff00,$009c,$8010,$ffff,$fffe,$0100,$5200,$0104,$0040,$008e,$1571,$0090,$f9d1,$0092,$0030,$0094
	dc.w	$00d8,$0102,$0000,$0108,$0000,$010a,$0000,$00e0,$0005,$00e2,$0000,$00e4,$0005,$00e6,$2940,$00e8
	dc.w	$0005,$00ea,$5280,$00ec,$0005,$00ee,$7bc0,$00f0,$0005,$00f2,$a500,$0180,$0000,$0182,$0fff,$0184
	dc.w	$0b87,$0186,$0800,$0188,$0ccd,$018a,$0aab,$018c,$0700,$018e,$0930,$0190,$0e10,$0192,$0b54,$0194
	dc.w	$0f50,$0196,$0d86,$0198,$0fb8,$019a,$0127,$019c,$0249,$019e,$0f80,$01a0,$026b,$01a2,$0fc2,$01a4
	dc.w	$028d,$01a6,$099a,$01a8,$07cf,$01aa,$0889,$01ac,$0667,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4
	dc.w	$06c5,$01b6,$0150,$01b8,$0380,$01ba,$0532,$01bc,$0743,$01be,$0a75,$4b01,$ff00,$0186,$0006,$4c01
	dc.w	$ff00,$0184,$0fff,$0186,$0117,$4d01,$ff00,$0184,$0fdd,$0186,$0228,$4e01,$ff00,$0184,$0fcc,$0186
	dc.w	$0339,$4f01,$ff00,$0184,$0eaa,$0186,$044a,$5001,$ff00,$0184,$0e88,$0186,$055b,$5101,$ff00,$0184
	dc.w	$0e77,$0186,$077c,$5201,$ff00,$0184,$0e66,$0186,$099d,$5301,$ff00,$0184,$0e44,$0186,$0bbe,$5401
	dc.w	$ff00,$0184,$0d33,$0186,$0ddf,$5501,$ff00,$0184,$0d11,$0186,$0eef,$5601,$ff00,$0184,$0d00,$0186
	dc.w	$0eef,$5701,$ff00,$0184,$0d11,$0186,$0ddf,$5801,$ff00,$0184,$0d33,$0186,$0ccf,$5901,$ff00,$0184
	dc.w	$0d33,$0186,$0bbe,$5a01,$ff00,$0184,$0e44,$0186,$099d,$5b01,$ff00,$0184,$0e66,$0186,$077c,$5c01
	dc.w	$ff00,$0184,$0e77,$0186,$055b,$5d01,$ff00,$0184,$0e88,$0186,$044a,$5e01,$ff00,$0184,$0eaa,$0186
	dc.w	$0339,$5f01,$ff00,$0184,$0fcc,$0186,$0228,$6001,$ff00,$0184,$0fdd,$0186,$0117,$6101,$ff00,$0184
	dc.w	$0fff,$0186,$0006,$7e01,$ff00,$0100,$0600,$0102,$0000,$0108,$0028,$010a,$0000,$00e0,$0005,$00e2
	dc.w	$0000,$00e8,$0005,$00ea,$5280,$00f0,$0005,$00f2,$a500,$00e4,$0005,$00e6,$2940,$00ec,$0005,$00ee
	dc.w	$7bc0,$00f4,$0005,$00f6,$7bc0,$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000,$0128,$0000,$012a
	dc.w	$0000,$012c,$0000,$012e,$0000,$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000,$0138,$0000,$013a
	dc.w	$0000,$013c,$0000,$013e,$0000,$0180,$0000,$0182,$0557,$0184,$0335,$0186,$0433,$0188,$011b,$018a
	dc.w	$011b,$018c,$011b,$018e,$011b,$0192,$077f,$0194,$0f55,$0196,$055f,$0198,$077f,$019a,$077f,$019c
	dc.w	$077f,$019e,$077f,$01a0,$0fc2,$01a2,$0777,$01a4,$0555,$01a6,$0180,$01a8,$0160,$01aa,$0040,$01ac
	dc.w	$0227,$01ae,$0448,$01b0,$0569,$01b2,$088b,$01b4,$0888,$01b6,$0666,$01b8,$0444,$01ba,$0333,$01bc
	dc.w	$0222,$01be,$0111,$7f01,$ff00,$0100,$6600,$8101,$ff00,$0194,$0fff,$8201,$ff00,$0194,$0ddd,$8301
	dc.w	$ff00,$0194,$0bbb,$8401,$ff00,$0194,$0999,$8501,$ff00,$0194,$0777,$8a01,$ff00,$0194,$0fff,$8b01
	dc.w	$ff00,$0194,$0ddd,$8c01,$ff00,$0194,$0bbb,$8d01,$ff00,$0194,$0999,$8e01,$ff00,$0194,$0777,$9801
	dc.w	$ff00,$0194,$0fff,$9901,$ff00,$0194,$0ddd,$9a01,$ff00,$0194,$0bbb,$9b01,$ff00,$0194,$0999,$9c01
	dc.w	$ff00,$0194,$0777,$a001,$ff00,$0194,$0fff,$0198,$0fff,$a101,$ff00,$0194,$0ddd,$a201,$ff00,$0194
	dc.w	$0bbb,$a301,$ff00,$0194,$0999,$a401,$ff00,$0194,$0777,$a901,$ff00,$0194,$0fdd,$aa01,$ff00,$0194
	dc.w	$0faa,$ab01,$ff00,$0194,$0f88,$ac01,$ff00,$0194,$0f66,$ad01,$ff00,$0194,$0f44,$b101,$ff00,$0194
	dc.w	$0dfd,$b201,$ff00,$0194,$0afa,$b301,$ff00,$0194,$07f7,$b401,$ff00,$0194,$04f4,$b501,$ff00,$0194
	dc.w	$02f2,$b901,$ff00,$0194,$0aff,$ba01,$ff00,$0194,$08ee,$bc01,$ff00,$0194,$06dd,$bd01,$ff00,$0194
	dc.w	$04cc,$be01,$ff00,$0194,$02aa,$c101,$ff00,$0194,$0ccf,$c201,$ff00,$0194,$0aaf,$c301,$ff00,$0194
	dc.w	$088f,$c401,$ff00,$0194,$066f,$c501,$ff00,$0194,$033f,$c901,$ff00,$0194,$0ffa,$ca01,$ff00,$0194
	dc.w	$0ff7,$cb01,$ff00,$0194,$0ee4,$cc01,$ff00,$0194,$0dd3,$cd01,$ff00,$0194,$0dd0,$d101,$ff00,$0194
	dc.w	$0fbf,$d201,$ff00,$0194,$0f8f,$d301,$ff00,$0194,$0f6f,$d401,$ff00,$0194,$0f3f,$d501,$ff00,$0194
	dc.w	$0f1f,$d901,$ff00,$0194,$0fa5,$da01,$ff00,$0194,$0e94,$db01,$ff00,$0194,$0d82,$dc01,$ff00,$0194
	dc.w	$0c50,$dd01,$ff00,$0194,$0b40,$e101,$ff00,$0194,$05fa,$e201,$ff00,$0194,$04e9,$e301,$ff00,$0194
	dc.w	$02d8,$e401,$ff00,$0194,$00c5,$e501,$ff00,$0194,$00b4,$e901,$ff00,$0194,$07bf,$ea01,$ff00,$0194
	dc.w	$06ae,$eb01,$ff00,$0194,$048d,$ec01,$ff00,$0194,$026c,$ed01,$ff00,$0194,$004b,$ff01,$ff00,$009c
	dc.w	$8010,$ffff,$fffe
Lfcf8
	dc.w	$0000,$0000


Lfcfc
	move.l	Lfcf8,$dff080
	rts


Lfd08
	dc.w	$0000
Lfd0a
	dc.w	$0000,$0000
Lfd0e
	dc.w	$0000,$0000


Lfd12
	move	sr,Lfd08
	ori	#$2700,sr
	movea.l	#$64,a0
	move.l	#$fdb2,(a0)+
	move.l	#$fde6,(a0)+
	move.l	#$fdbc,(a0)+
	move.l	#$fdc6,(a0)+
	move.l	#$fdd0,(a0)+
	move.l	#$fe46,(a0)+
	move.l	#$fdda,(a0)+
	move.w	#$4e75,$24
	move	Lfd08,sr
	rts


Lfd5c
	move.l	$20,Lfd0a
	movea.l	#$20,a0
	move.l	#$fd96,(a0)
	ori	#$2000,sr
	move.l	Lfd0a,$20
	rts


	move.l	Lfd0a,$20
	move.l	a7,Lfd0e
	move	usp,a7
	rts


	ori.w	#$2000,(a7)
	addi.l	#$10,$2(a7)
	rte


	move	a7,usp
	movea.l	Lfd0e,a7
	andi	#$71f,sr
	rts


	move.w	#$7,$dff09c
	rte


	move.w	#$70,$dff09c
	rte


	move.w	#$780,$dff09c
	rte


	move.w	#$1800,$dff09c
	rte


	move.w	#$8000,$dff09c
	rte


Lfde4
	dc.w	$0000


	move.w	#$8,$dff09c
	movem.l	d0/a0,-(a7)
	move.b	$bfed01,d0
	btst	#$0,d0
	beq.s	Lfe06


	dc.w	$13fc,$ffff,$0000,$0cb8


Lfe06
	btst	#$3,d0
	beq.s	Lfe40
	move.b	$bfec01,d0
	ori.b	#$40,$bfee01
	eori.b	#$fe,d0
	lsr.b	#1,d0
	bcs.s	Lfe32
	ext.w	d0
	lea	Lfe5a,a0
	move.b	(a0,d0.w),Lfde4
Lfe32
	moveq	#$50,d0
Lfe34
	dbra	d0,Lfe34
	andi.b	#$bf,$bfee01
Lfe40
	movem.l	(a7)+,d0/a0
	rte


	move.l	d0,-(a7)
	move.b	$bfdd00,d0
	move.w	#$2000,$dff09c
	move.l	(a7)+,d0
	rte


Lfe5a
	dc.b	'`1234567890-=\',$00,$00,'qwertyuiop[]',$00,'123asdfghjkl;''',$0d,$00,'456',$00,'zxcvbnm,./',$00,$00,'789'
	dc.b	' ',$0a,$00,$0d,$0d,$00,$0a,$00,$00,$00,'-',$00,$00,$00,$00,$0a


	ds.w	16


Lfeca
	bsr	Lfd5c
	bsr	Lfd12
	move.w	#$c008,$dff09a
	move.w	#$8210,$dff096
	IFND	PROTECTION_DISABLED
Lfee2	cmpi.w	#$fffe,$30600
	bne.s	Lfee2
	cmpi.w	#$6263,$75f42
	bne.s	Lfee2
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	rts


Lfef8
	jsr	Lff3a
	move.w	#$81a0,$dff096
	jmp	Lbca


Lff0c
	move.w	#$1a0,$dff096
	bsr	Lff1e
	jmp	Lbca


Lff1e
	move.w	#$20,$dff096
	moveq	#$b,d0
	movea.l	#$dff140,a0
Lff2e
	move.l	#$0,(a0)+
	dbra	d0,Lff2e
	rts


Lff3a
	move.w	#$ea60,d1
Lff3e
	subi.w	#$1,d1
	beq.s	Lff50
	move.b	$dff006,d0
	cmpi.b	#-$6,d0
	bne.s	Lff3e
Lff50
	rts


Lff52
	movea.l	#$ffea,a0
	moveq	#$0,d0
Lff5a
	move.w	d0,d1
	mulu.w	#$2e,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	cmpi.w	#$c8,d0
	bne.s	Lff5a
	movea.l	#Lffc0,a0
	moveq	#$0,d0
Lff72
	move.w	d0,d1
	mulu.w	#$28,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	cmpi.w	#$15,d0
	bne.s	Lff72
	movea.l	#L1036a,a0
	moveq	#$0,d0
Lff8a
	move.w	d0,d1
	mulu.w	#$78,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	cmpi.w	#$40,d0
	bne.s	Lff8a
	movea.l	#$1017a,a0
	moveq	#$0,d0
Lffa2
	move.w	d0,d1
	mulu.w	#$2c,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	cmpi.w	#$f0,d0
	bne.s	Lffa2
	cmpi.w	#$4a79,L10878
	bne	L10410
	rts


Lffc0	ds.w	461
	dc.w	$0000,$0030,$0060,$0090,$00c0,$00f0,$0120,$0150

L1036a	ds.w	64

L103ea
	dc.w	$0000
L103ec
	dc.w	$0064
L103ee
	dc.w	$0000
L103f0
	dc.w	$0000
L103f2
	dc.w	$0000
L103f4
	dc.w	$0000
L103f6
	dc.w	$0000,$0001,$6704,$0001,$6718,$0001,$672c,$0001,$6740
L10408
	dc.w	$0000
L1040a
	dc.w	$0000
L1040c
	dc.w	$0000
L1040e
	dc.w	$0000


L10410
	move.w	L4b90,d0
	cmp.w	L10aa8,d0
	beq.s	L10428
	tst.w	L10aa8
	bne	L10870
L10428
	cmpi.w	#$3,L10d22
	bne	L10870
	clr.w	L10aa8
	tst.w	L103ec
	bne	L105ac
	tst.w	L4f7a
	bne	L10870
	tst.w	L5532
	bne	L10870
	tst.w	L648a
	bne	L10870
	jsr	L109ca
	jsr	L13b88
	clr.w	L9fd4
	clr.w	L9fd6
	clr.w	L725e
	clr.w	L74ae
	move.w	#$170c,L10d1e
	tst.l	L4f6c
	bne	L10870
	tst.w	L76f0
	beq.s	L104b8
	cmpi.w	#$c4,L76ec
	beq.s	L104b8
	cmpi.w	#-$c4,L76ec
	beq.s	L104b8
	bra	L10870


L104b8
	move.w	L10aa2,d0
	subq.b	#1,d0
	andi.w	#$3,d0
	asl.w	#2,d0
	movea.l	#$11e6c,a0
	move.l	(a0,d0.w),L11e58
	addq.w	#1,L10aa2
	move.w	#$c8,L103ec
	move.w	#$11,L103ee
	move.w	L4b7a,L103f2
	move.w	Le0ea,L10408
	addi.w	#$84,L10408
	move.w	Le0ea,L1040a
	cmpi.w	#$8,L4b7a
	bne.s	L10520
	addq.w	#1,L4b90
L10520
	move.w	L4b90,L103f4
	move.w	Le0ea,L1040c
	addi.w	#$b2,L1040c
	cmpi.w	#$1,L10aa2
	bne.s	L10550
	move.w	#$2,L103ec
	bra.s	L105ac


L10550
	move.l	#$20202030,L11e3e
	move.w	L10aa2,d0
	subq.w	#2,d0
L10562
	addq.b	#1,L11e41
	cmpi.b	#$3a,L11e41
	bne.s	L10588
	addq.b	#1,L11e40
	ori.b	#$10,L11e40
	move.b	#$30,L11e41
L10588
	cmpi.b	#$3a,L11e40
	bne.s	L105a8
	addq.b	#1,L11e3f
	ori.b	#$10,L11e3f
	move.b	#$30,L11e40
L105a8
	dbra	d0,L10562
L105ac
	eori.w	#$1,L103f0
	beq.s	L10620
	cmpi.w	#$46,L103ec
	bcc.s	L10620
	tst.w	L103ee
	beq.s	L10620
	subq.w	#1,L103ee
	tst.w	L11b2c
	bne.s	L10620
	cmpi.w	#$3,L103ea
	beq.s	L105f0
	tst.w	L7266
	beq.s	L10600
	tst.w	L7264
	bne.s	L10600
L105f0
	cmpi.w	#$21,L725c
	beq.s	L10600
	addq.w	#1,L725c
L10600
	tst.w	L74b6
	beq.s	L10620
	tst.w	L74b4
	bne.s	L10620
	cmpi.w	#$21,L74ac
	beq.s	L10620
	addq.w	#1,L74ac
L10620
	movea.l	#$f6c3,a0
	adda.l	#$11b5,a0
	jsr	(a0)
	cmpi.w	#$1,L10aa2
	beq	L10776
	tst.l	L4f6c
	bne	L10776
	movea.l	Le536,a0
	adda.l	#$8fc,a0
	movea.l	#$11e32,a1
	move.w	#$74,d0
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
	movea.l	Le536,a0
	movea.l	#$11eb3,a1
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
	tst.w	L1040e
	beq.s	L106a4
	movea.l	Le536,a0
	movea.l	#$11ebc,a1
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L106a4
	tst.w	L103f2
	bne.s	L106de
	tst.l	L4f6c
	bne	L10776
	movea.l	Le536,a0
	adda.l	#$c94,a0
	movea.l	#$11e5c,a1
	move.w	#$95,d0
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
	bra	L10776


L106de
	movea.l	Le536,a0
	adda.l	#$c94,a0
	movea.l	#$11e4e,a1
	move.w	#$a2,d0
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
	tst.l	L4f6c
	bne.s	L10776
	tst.w	L4b7a
	beq.s	L10776
	move.w	L103ec,d0
	andi.w	#$7,d0
	tst.w	d0
	bne.s	L10776
	subq.w	#1,L4b7a
	movea.l	L166c4,a1
	move.w	L10aa2,d0
	subq.b	#2,d0
	andi.w	#$3,d0
	asl.w	#2,d0
	movea.l	#$103f8,a0
	movea.l	(a0,d0.w),a0
	jsr	L1675e
	jsr	L4cf2
	move.w	L10408,d0
	swap	d0
	move.l	#$4f0000,d1
	moveq	#$10,d2
	clr.l	d3
	jsr	Lb8ca
	subq.w	#1,L10aa8
	addi.w	#$10,L10408
L10776
	tst.w	L103f4
	bne.s	L1078e
	cmpi.w	#$4,L4b90
	bne.s	L1078e
	st	L1040e
L1078e
	tst.w	L103f4
	beq.s	L107c2
	subq.w	#1,L103f4
	move.w	L1040c,d0
	swap	d0
	move.l	#$5f0000,d1
	moveq	#$20,d2
	clr.l	d3
	jsr	Lb8ca
	subq.w	#1,L10aa8
	addi.w	#$10,L1040c
L107c2
	subq.w	#1,L103ec
	bne	L10870
	clr.l	L4b58
	clr.l	L4b5c
	clr.l	L4b60
	clr.l	L4b64
	clr.l	L4b68
	clr.l	L4b6c
	clr.l	L4b70
	clr.l	L4b74
	jsr	L109ca
	tst.b	L103f6
	beq.s	L10818
	sf	L103f6
	move.w	#$8,L103f2
L10818
	move.w	L103f2,L4b78
	sf	L11b2c
	jsr	L10adc
	clr.w	L7260
	clr.w	L74b0
	cmpi.w	#$3,L103ea
	beq.s	L1085e
	tst.w	L103ea
	beq.s	L10864
	cmpi.w	#$1,L103ea
	beq.s	L10864
	st	L9fd6
	bra.s	L1086a


L1085e
	st	L9fd6
L10864
	st	L9fd4
L1086a
	jsr	L4cf2
L10870
	jmp	Lbca


L10876
	dc.w	$0000


L10878
	tst.w	L1698
L1087e
	bne.s	L108fe
	cmpi.w	#$7,L10aa2
	bne.s	L108fe
	tst.b	L10876
	bne.s	L108fe
	cmpi.b	#$18,Le535
	bne.s	L108fe
	moveq	#-$1,d0
	jsr	L430
	bra.s	L108e8


	dc.w	$4e71,$4e71,$0c6a


	move.w	#$197,Lcb0
	st	L80c+2
	jsr	L456
	movea.l	Lc6a,a0
	movea.l	#$4b314,a1
	movea.l	#$4c000,a2
	jsr	decompress
L108d8
	jsr	$4b314
	move.w	$10,Lcae
L108e8
	move.w	#$2,Le126
	move.w	#$2,Le124
	clr.b	Lfde4
L108fe
	rts


L10900
	jsr	L5f64
	movea.l	#$b944,a0
	moveq	#$7f,d1
L1090e
	tst.l	(a0)
	beq	L109c2
	move.b	$603(a0),d0
	cmpi.b	#$4,d0
	bne.s	L10966
	movem.l	d1/a0,-(a7)
	move.l	#$8,$600(a0)
	move.l	#$1,$a00(a0)
	moveq	#$2,d1
	jsr	L1ad48
	swap	d0
	move.w	#$7fff,d0
	move.l	d0,$800(a0)
	movea.l	#$4b18,a2
	move.w	$c00(a0),d1
	lsl.w	#2,d1
	clr.b	$40(a2,d1.w)
	movea.l	$20(a2,d1.w),a2
	move.l	#$100,$e00(a2)
	movem.l	(a7)+,d1/a0
	bra.s	L109ba


L10966
	cmpi.b	#$2d,$603(a0)
	bne.s	L10978
	subq.w	#1,L10aa8
	clr.l	(a0)
	bra.s	L109c2


L10978
	cmpi.b	#$2e,$603(a0)
	bne.s	L1098a
	subq.w	#1,L10aa8
	clr.l	(a0)
	bra.s	L109c2


L1098a
	cmpi.b	#$24,d0
	bne.s	L1099a
	clr.l	(a0)
	subq.w	#1,L10aa8
	bra.s	L109c2


L1099a
	cmpi.b	#$e,d0
	bne.s	L109aa
	clr.l	(a0)
	subq.w	#1,L10aa8
	bra.s	L109c2


L109aa
	cmpi.b	#$17,d0
	bcc.s	L109ba
	andi.b	#$f8,d0
	cmpi.b	#$10,d0
	beq.s	L109c2
L109ba
	move.l	#$154,$1000(a0)
L109c2
	addq.l	#4,a0
	dbra	d1,L1090e
	rts


L109ca
	moveq	#$7f,d0
	movea.l	#$b944,a0
L109d2
	clr.l	(a0)+
	dbra	d0,L109d2
	rts


L109da
	moveq	#$2,d0
L109dc
	move.w	d0,-(a7)
	jsr	L10da2
	move.w	(a7)+,d0
	dbra	d0,L109dc
	moveq	#$7f,d0
	movea.l	#$b944,a0
L109f2
	tst.l	(a0)
	beq.s	L10a3e
	move.b	$603(a0),d1
	andi.b	#$f8,d1
	cmpi.b	#$10,d1
	bne.s	L10a12
	addq.w	#1,L4b7a
	subq.w	#1,L4b78
	bra.s	L10a36


L10a12
	movem.l	d0/a0,-(a7)
	movea.l	#$cde4,a5
	move.w	$602(a0),d2
	lsl.b	#2,d2
	movea.l	(a5,d2.w),a0
	movea.l	L166c4,a1
	jsr	L1675e
	movem.l	(a7)+,d0/a0
L10a36
	clr.l	(a0)
	subq.w	#1,L10aa8
L10a3e
	addq.l	#4,a0
	dbra	d0,L109f2
	tst.w	L7260
	beq.s	L10a64
	clr.w	L7260
	subq.w	#1,L4b78
	addq.w	#1,L4b7a
	subq.w	#1,L10aa8
L10a64
	tst.w	L74b0
	beq.s	L10a84
	clr.w	L74b0
	subq.w	#1,L4b78
	addq.w	#1,L4b7a
	subq.w	#1,L10aa8
L10a84
	jsr	L4cf2
	move.w	#$3,L10d22
	jsr	Ld644
	moveq	#$6,d0
	jsr	L1ad24
	rts


L10aa2
	dc.w	$0005
L10aa4
	dc.w	$0000
L10aa6
	dc.w	$0000
L10aa8
	dc.w	$0000
L10aaa
	dc.w	$0000
L10aac
	dc.w	$0000
L10aae
	dc.w	$0000
L10ab0
	dc.w	$0000
L10ab2
	dc.w	$0000
L10ab4
	dc.w	$0000
L10ab6
	dc.w	$0000
L10ab8
	dc.w	$0000
L10aba
	dc.w	$0000
L10abc
	dc.w	$0000
L10abe
	dc.w	$0000
L10ac0
	dc.w	$0000
L10ac2
	dc.w	$0000
L10ac4
	dc.w	$0000
L10ac6
	dc.w	$0000
L10ac8
	dc.w	$0000
L10aca
	dc.w	$0000
L10acc
	dc.w	$0000,$0000,$0000,$0000
L10ad4
	dc.w	$0000
L10ad6
	dc.w	$0000
L10ad8
	dc.w	$0000,$0000


L10adc
	jsr	Lec0c
	clr.w	L10aa8
	move.w	L4b78,d0
L10aee
	tst.w	d0
	beq.s	L10b1c
	move.w	d0,-(a7)
	clr.l	d2
	move.w	d0,d2
	addi.w	#$f,d2
	clr.w	Lb8c8
	jsr	L11a7c
	addq.w	#1,L10aa8
	move.w	#$1,Lb8c8
	move.w	(a7)+,d0
	subq.b	#1,d0
	bra.s	L10aee


L10b1c
	movea.l	#$10aaa,a0
	moveq	#$17,d0
L10b24
	clr.w	(a0)+
	dbra	d0,L10b24
	move.w	L10aa2,d0
	andi.b	#$3,d0
	tst.b	d0
	beq	L10ce2
	move.w	L10aa2,d0
	cmpi.w	#$1,d0
	beq.s	L10b5c
	moveq	#$3,d1
	jsr	L1ad48
	add.w	d0,d0
	movea.l	#$10ace,a0
	move.w	#$1,(a0,d0.w)
L10b5c
	cmpi.w	#$3,L10aa2
	bcs.s	L10b96
	move.w	L10aa2,d0
	andi.w	#$3,d0
	eori.b	#$3,d0
	move.w	d0,L10ad8
	andi.w	#$2,d0
	move.w	d0,L10ad6
	andi.w	#$1,d0
	move.w	d0,L10ad4
	move.w	#$2,L11412
L10b96
	move.w	L10aa2,d0
	lsr.w	#2,d0
	addq.w	#1,d0
	cmpi.w	#$7,d0
	bcs.s	L10ba8
	moveq	#$7,d0
L10ba8
	move.w	d0,L10ac8
	move.w	d0,L10acc
	lsr.w	#1,d0
	move.w	d0,L10aca
	move.w	L10aa2,d0
	addi.w	#$8,d0
	cmpi.w	#$28,d0
	bcs.s	L10bd0
	move.w	#$28,d0
L10bd0
	move.w	d0,L10aaa
	lsr.w	#1,d0
	move.w	d0,L10aac
	lsr.w	#1,d0
	move.w	d0,L10aae
	move.w	L10aa2,d0
	lsr.w	#1,d0
	move.w	d0,L10ab2
	lsr.w	#1,d0
	move.w	d0,L10ab0
	lsr.w	#1,d0
	move.w	d0,L10ab4
	clr.l	d0
	move.w	L10aa2,d0
	divu.w	#$3,d0
	move.w	d0,L10ab6
	lsr.w	#1,d0
	move.w	d0,L10ab8
	lsr.w	#1,d0
	move.w	d0,L10aba
	clr.l	d0
	move.w	L10aa2,d0
	addq.w	#1,d0
	divu.w	#$4,d0
	move.w	d0,L10abe
	tst.w	L10abe
	beq.s	L10c4a
	move.w	#$1,L10abe
L10c4a
	lsr.w	#1,d0
	move.w	d0,L10ac0
	lsr.w	#1,d0
	move.w	d0,L10abc
	andi.w	#$1,L10abc
	andi.w	#$3,L10ac0
	move.w	L10aa2,d0
	andi.w	#$1,d0
	tst.w	d0
	beq.s	L10cca
	clr.l	d0
	move.w	L10aa2,d0
	divu.w	#$6,d0
	move.w	d0,L10ac2
	lsr.w	#1,d0
	move.w	d0,L10ac6
	lsr.w	#1,d0
	move.w	d0,L10ac4
	tst.w	L10ac2
	beq.s	L10caa
	move.w	#$1,L10ac2
L10caa
	tst.w	L10ac4
	beq.s	L10cba
	move.w	#$1,L10ac4
L10cba
	tst.w	L10ac6
	beq.s	L10cca
	move.w	#$1,L10ac6
L10cca
	move.w	#$32,L10d20
	clr.w	L10d22
	move.w	#$170c,L10d1e
	rts


L10ce2
	st	L103f6
	move.w	L10aa2,d0
	lsr.w	#2,d0
	addq.w	#2,d0
	cmpi.w	#$6,d0
	bcs.s	L10cfa
	moveq	#$6,d0
L10cfa
	move.w	d0,L10aca
	clr.l	d0
	move.w	L10aa2,d0
	divu.w	#$2,d0
	addi.w	#$6,d0
	move.w	d0,L10ab6
	clr.l	L10ab8
	bra.s	L10cca


L10d1e
	dc.w	$0000
L10d20
	dc.w	$0000
L10d22
	dc.w	$0000
L10d24
	dc.w	$0007
L10d26
	dc.w	$000a
L10d28
	dc.w	$0004


L10d2a
	tst.w	L1698
	bne	L11040
	cmpi.w	#$3,L103ea
	beq.s	L10d5a
	move.w	L7264,d0
	cmpi.w	#$2,L103ea
	bne.s	L10d54
	move.w	L74b4,d0
L10d54
	tst.w	d0
	bne	L11040
L10d5a
	move.w	Le126,d0
	sub.w	d0,L10d1e
	bpl.s	L10d92
	move.w	#$15e,L10d1e
	jsr	L11112
	move.b	#$1,$603(a0)
	move.w	#$82,d1
	jsr	L1ad48
	move.w	d0,$a00(a0)
	moveq	#$6,d0
	jsr	L1ad18
L10d92
	move.w	Le126,d0
	sub.w	d0,L10d20
	bpl	L11040
L10da2
	cmpi.w	#$3,L10d22
	beq	L11040
	move.w	L10aa8,-(a7)
	clr.w	L11602
	tst.w	L1040e
	beq.s	L10dd4
	clr.w	L4b90
	clr.w	L1040e
	jsr	L117d4
L10dd4
	cmpi.w	#$1,L10d22
	bne.s	L10dfa
	subq.w	#1,L10d28
	tst.w	L10d28
	bne.s	L10dfa
	move.w	#$3,L10d28
	jsr	L4f8a
L10dfa
	cmpi.w	#$1,L10d22
	bne.s	L10e26
	subq.w	#1,L10d24
	tst.w	L10d24
	bne.s	L10e26
	move.w	#$a,L10d24
	jsr	L64fc
	jsr	L5462
L10e26
	cmpi.w	#$1,L10d22
	bne.s	L10e52
	subq.w	#1,L10d26
	tst.w	L10d26
	bne.s	L10e52
	move.w	#$a,L10d26
	jsr	L55c6
	jsr	L5462
L10e52
	tst.w	L10d22
	bne.s	L10e72
	move.w	L4b90,d0
L10e60
	tst.w	d0
	beq.s	L10e72
	move.w	d0,-(a7)
	jsr	L11acc
	move.w	(a7)+,d0
	subq.w	#1,d0
	bra.s	L10e60


L10e72
	tst.w	L103f6
	bne.s	L10ea4
	cmpi.w	#$1,L10d22
	beq.s	L10ea4
	cmpi.w	#$2,L10aa2
	bcs.s	L10ea4
	moveq	#$3,d1
	jsr	L1ad48
L10e96
	move.w	d0,-(a7)
	jsr	L11042
	move.w	(a7)+,d0
	dbra	d0,L10e96
L10ea4
	tst.w	L10d22
	beq.s	L10ece
	move.w	#$8,d0
	sub.w	L4b7a,d0
	sub.w	L4b78,d0
L10ebc
	tst.w	d0
	beq.s	L10ece
	move.w	d0,-(a7)
	jsr	L11240
	move.w	(a7)+,d0
	subq.w	#1,d0
	bra.s	L10ebc


L10ece
	jsr	L111aa
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10abc,a0
	move.w	(a0,d0.w),d1
L10ee6
	tst.w	d1
	beq.s	L10f06
	movem.l	d0-d1,-(a7)
	move.l	#$14,L11c24
	jsr	L11c32
	movem.l	(a7)+,d0-d1
	dbra	d1,L10ee6
L10f06
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10ace,a0
	move.w	(a0,d0.w),d1
L10f18
	tst.w	d1
	beq.s	L10f2e
	movem.l	d0-d1,-(a7)
	jsr	L114f2
	movem.l	(a7)+,d0-d1
	dbra	d1,L10f18
L10f2e
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10aaa,a0
	move.w	(a0,d0.w),d1
L10f40
	tst.w	d1
	beq.s	L10f56
	movem.l	d0-d1,-(a7)
	jsr	L11112
	movem.l	(a7)+,d0-d1
	dbra	d1,L10f40
L10f56
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10ac8,a0
	move.w	(a0,d0.w),d1
L10f68
	tst.w	d1
	beq.s	L10f7e
	movem.l	d0-d1,-(a7)
	jsr	L1130c
	movem.l	(a7)+,d0-d1
	dbra	d1,L10f68
L10f7e
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10ac2,a0
	move.w	(a0,d0.w),d1
L10f90
	tst.w	d1
	beq.s	L10fa6
	movem.l	d0-d1,-(a7)
	jsr	L110c4
	movem.l	(a7)+,d0-d1
	dbra	d1,L10f90
L10fa6
	tst.w	L10d22
	beq.s	L10fb4
	jsr	L1196a
L10fb4
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10ab0,a0
	move.w	(a0,d0.w),d1
L10fc6
	tst.w	d1
	beq.s	L10fdc
	movem.l	d0-d1,-(a7)
	jsr	L118fe
	movem.l	(a7)+,d0-d1
	dbra	d1,L10fc6
L10fdc
	move.w	L10d22,d0
	lsl.w	#1,d0
	movea.l	#$10ab6,a0
	move.w	(a0,d0.w),d1
L10fee
	tst.w	d1
	beq.s	L11004
	movem.l	d0-d1,-(a7)
	jsr	L119f8
	movem.l	(a7)+,d0-d1
	dbra	d1,L10fee
L11004
	addq.w	#1,L10d22
	move.w	#$4b0,L10d20
	cmpi.w	#$8,L10aa2
	bcs.s	L11024
	move.w	#$5dc,L10d20
L11024
	move.w	(a7)+,d0
	cmp.w	L10aa8,d0
	bne.s	L11038
	move.w	#$2,L10d20
	bra.s	L11040


L11038
	moveq	#$6,d0
	jsr	L1ad18
L11040
	rts


L11042
	cmpi.w	#$64,L10aa8
	bcc.s	L110ba
	clr.l	d3
	move.w	#$800,d1
	jsr	L1ad48
	swap	d0
	move.l	d0,d7
	moveq	#$7,d1
	jsr	L1ad48
	addq.b	#3,d0
	clr.w	d1
L11068
	movem.l	d0-d1/d7,-(a7)
	move.l	d7,d0
	move.l	#$1,d4
	lsl.w	#3,d1
	swap	d1
	clr.w	d1
	moveq	#$1f,d2
	clr.l	d3
	clr.l	d6
	move.l	L110bc,d5
	jsr	Lb8ca
	move.l	a0,L110bc
	movem.l	(a7)+,d0-d1/d7
	addq.w	#1,d1
	cmpi.w	#$1,d1
	bne.s	L110a8
	move.l	L110bc,L110c0
L110a8
	cmp.w	d0,d1
	bne.s	L11068
	movea.l	L110c0,a0
	move.l	L110bc,$c00(a0)
L110ba
	rts


L110bc
	dc.w	$0000,$0000
L110c0
	dc.w	$0000,$0000


L110c4
	moveq	#$3,d1
	jsr	L1ad48
	addq.w	#1,d0
	move.w	d0,d3
	swap	d3
	clr.w	d3
	move.w	#$800,d1
	jsr	L1ad48
	btst	#$0,d0
	beq.s	L110ea
	eori.l	#$ffffffff,d3
L110ea
	moveq	#$12,d1
L110ec
	movem.l	d0-d1/d3,-(a7)
	swap	d0
	clr.w	d0
	lsl.w	#3,d1
	swap	d1
	clr.w	d1
	moveq	#$d,d2
	clr.l	d6
	jsr	Lb8ca
	movem.l	(a7)+,d0-d1/d3
	dbra	d1,L110ec
	jmp	Lbca


L11112
	move.w	#$3e8,d1
	jsr	L1ad48
	ext.l	d0
	clr.l	d4
	move.w	d0,d4
	move.w	L10aa2,d1
	lsr.w	#3,d1
	addi.w	#$1,d1
	jsr	L1ad48
	cmpi.w	#$1,d0
	bcs.s	L1113e
	move.w	#$1,d0
L1113e
	move.w	d0,d3
	swap	d3
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d3
	addi.l	#$8000,d3
	moveq	#$2,d1
	jsr	L1ad48
	tst.b	d0
	beq.s	L1116c
	move.l	#$ffffffff,d0
	sub.l	d3,d0
	move.l	d0,d3
L1116c
	move.w	#$6e,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d0,d2
	move.w	#$800,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d2,d1
	tst.w	Lb8c8
	bne.s	L1119c
	move.l	$200(a2),d0
	move.l	$400(a2),d1
L1119c
	clr.l	d5
	clr.l	d6
	moveq	#$8,d2
	jsr	Lb8ca
	rts


L111aa
	move.w	L10aa2,d0
	andi.b	#$3,d0
	tst.b	d0
	bne	L1123e
	move.w	#$258,d1
	jsr	L1ad48
	move.w	d0,d4
	swap	d4
	move.w	L10aa2,d1
	lsr.w	#3,d1
	addi.w	#$1,d1
	jsr	L1ad48
	cmpi.w	#$1,d0
	bcs.s	L111e4
	move.w	#$1,d0
L111e4
	move.w	d0,d3
	swap	d3
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d3
	addi.l	#$8000,d3
	moveq	#$2,d1
	jsr	L1ad48
	tst.b	d0
	beq.s	L11212
	move.l	#$ffffffff,d0
	sub.l	d3,d0
	move.l	d0,d3
L11212
	move.w	#$6e,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d0,d2
	move.w	#$800,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d2,d1
	clr.l	d5
	clr.l	d6
	moveq	#$27,d2
	jsr	Lb8ca
L1123e
	rts


L11240
	cmpi.w	#$7c,L10aa8
	bcc.s	L1128e
	cmpi.w	#$4,L10aa2
	bcs.s	L1128e
	move.w	#$800,d1
	jsr	L1ad48
	swap	d0
	move.l	#$8a0000,d1
	moveq	#$22,d2
	move.l	d0,-(a7)
	move.w	#$1,d5
	jsr	Lb8ca
	move.l	(a7)+,d0
	move.l	#$920000,d1
	moveq	#$23,d2
	move.l	a0,d4
	move.l	a0,-(a7)
	jsr	Lb8ca
	movea.l	(a7)+,a1
	move.l	a0,$a00(a1)
L1128e
	rts


	dc.w	$0001,$0002,$0002,$0001,$ffff,$fffe,$fffe,$ffff,$fffe,$ffff,$0001,$0002,$0002,$0001,$ffff,$fffe


L112b0
	clr.w	Lb8c8
	movem.l	d7/a2,-(a7)
	moveq	#$7,d6
L112bc
	move.w	d6,-(a7)
	move.l	$200(a2),d0
	move.l	$400(a2),d1
	moveq	#$24,d2
	movea.l	#$11290,a0
	add.w	d6,d6
	move.w	(a0,d6.w),d3
	move.w	$10(a0,d6.w),d6
	swap	d3
	swap	d6
	clr.w	d3
	clr.w	d6
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L112f0
	addq.w	#1,L10aa8
L112f0
	move.w	(a7)+,d6
	movem.l	(a7),d7/a2
	dbra	d6,L112bc
	movem.l	(a7)+,d7/a2
	move.w	#$1,Lb8c8
	jmp	Lbca


L1130c
	moveq	#$50,d1
	jsr	L1ad48
	addi.w	#$14,d0
	move.w	d0,-(a7)
	move.w	#$400,d1
	jsr	L1ad48
	addi.w	#$400,d0
	move.w	(a7)+,d1
	swap	d0
	swap	d1
	moveq	#$1c,d2
	move.l	#$1000000,d4
	move.l	d1,d5
	addi.l	#$f0000,d5
	jsr	Lb8ca
	rts


	dc.w	$000a,$0000,$000f,$0000,$fff4,$0000,$ffed,$0000,$0008,$0000,$fffb,$0000,$000f,$0000,$fff6,$0000


L11366
	movem.l	d0-d7/a0-a6,-(a7)
	clr.w	Lb8c8
	moveq	#$3,d6
L11372
	movem.l	d6/a0,-(a7)
	movea.l	#$11346,a1
	lsl.w	#2,d6
	move.w	$200(a0),d5
	swap	d5
	move.w	$400(a0),d5
	move.l	$200(a0),d0
	add.l	(a1,d6.w),d0
	andi.l	#$7ff0000,d0
	move.l	$400(a0),d1
	add.l	$10(a1,d6.w),d1
	moveq	#$1d,d2
	move.l	#$2000000,d4
	tst.w	d6
	bne.s	L113ae
	move.b	#$ff,d4
L113ae
	clr.l	d3
	clr.l	d6
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L113c2
	addq.w	#1,L10aa8
L113c2
	movem.l	(a7)+,d6/a0
	dbra	d6,L11372
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d0-d7/a0-a6
	rts


L113d8
	move.l	$200(a2),d0
	move.l	$400(a2),d1
	moveq	#$1e,d2
	clr.l	d3
	clr.l	d6
	clr.l	d4
	move.l	#$500050,d5
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L11404
	addq.w	#1,L10aa8
L11404
	move.w	#$1,Lb8c8
	jmp	Lbca


L11412
	dc.w	$0000


L11414
	cmpi.w	#$4,L4b78
	bcc	L114b6
	cmpi.w	#$3,L10d22
	beq	L114b6
	tst.w	L103ec
	bne	L114b6
	move.w	L7264,d0
	tst.w	L103ea
	beq.s	L11454
	cmpi.w	#$2,L103ea
	bne.s	L11454
	move.w	L74b4,d0
L11454
	tst.w	d0
	bne.s	L114b6
	subq.w	#1,L11412
	tst.w	L11412
	bne.s	L114b6
	move.w	#$c8,L11412
	move.w	L10d22,d0
	add.w	d0,d0
	movea.l	#$10ad4,a0
	move.w	(a0,d0.w),d1
	tst.w	d1
	beq.s	L114b6
	subq.w	#1,(a0,d0.w)
	moveq	#$3,d1
	jsr	L1ad48
	swap	d0
	move.w	#$1e,d0
	move.l	d0,d4
	move.w	#$800,d1
	jsr	L1ad48
	move.l	#$900000,d1
	swap	d0
	clr.l	d6
	clr.l	d3
	moveq	#$25,d2
	jsr	Lb8ca
L114b6
	rts


L114b8
	move.l	$200(a2),d0
	addi.l	#$40000,d0
	andi.l	#$7ff0000,d0
	move.l	#$8b0000,d1
	moveq	#$26,d2
	clr.w	Lb8c8
	jsr	Lb8ca
	move.w	#$1,Lb8c8
	tst.w	d7
	bmi.s	L114ee
	addq.w	#1,L10aa8
L114ee
	rts


L114f0
	dc.w	$0004


L114f2
	moveq	#$6,d7
	subq.w	#1,L114f0
	tst.w	L114f0
	bpl.s	L1150c
	move.w	#$4,L114f0
	moveq	#$14,d7
L1150c
	move.w	#$800,d1
	jsr	L1ad48
	move.w	d0,d6
L11518
	movem.w	d6-d7,-(a7)
	move.w	#$90,d1
	jsr	L1ad48
	move.w	d0,d2
	move.w	#$64,d1
	jsr	L1ad48
	add.w	d6,d0
	andi.w	#$7ff,d0
	move.w	d2,d1
	swap	d0
	swap	d1
	clr.l	d6
	clr.l	d3
	moveq	#$21,d2
	jsr	Lb8ca
	movem.w	(a7)+,d6-d7
	dbra	d7,L11518
	rts


L11554
	dc.w	$0000


L11556
	move.w	L10aa2,d0
	subq.w	#1,L11554
	tst.w	L11554
	bmi.s	L11570
	rts


	dc.w	$0000,$08a0


L11570
	cmpi.w	#$4,L10aa2
	bcc.s	L11584
	move.w	#$2,L11554
	bra.s	L115a2


L11584
	cmpi.w	#$9,L10aa2
	bcc.s	L11598
	move.w	#$3,L11554
	bra.s	L115a2


L11598
	move.w	#$1,L11554
	nop
L115a2
	movem.l	d0-d7/a0-a6,-(a7)
	moveq	#$6,d0
	jsr	L1ad18
	clr.l	d3
	move.w	$200(a2),d0
	subi.w	#$400,d0
	move.w	L8788,d1
	sub.w	d1,d0
	andi.w	#$7ff,d0
	cmpi.w	#$400,d0
	bcs.s	L115d0
	move.l	#$ffffffff,d3
L115d0
	move.l	$200(a2),d0
	moveq	#$2,d7
L115d6
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	#$900000,d1
	moveq	#$1b,d2
	jsr	Lb8ca
	movem.l	(a7)+,d0-d7/a0-a6
	addi.l	#$300000,d0
	andi.l	#$7ff0000,d0
	dbra	d7,L115d6
	movem.l	(a7)+,d0-d7/a0-a6
	rts


L11602
	dc.w	$0000


L11604
	tst.w	L11602
	bne.s	L1163e
	st	L11602
L11612
	movem.l	d0-d7/a0-a6,-(a7)
	moveq	#$18,d2
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L11632
	addq.w	#1,L10aa8
L11632
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d0-d7/a0-a6
L1163e
	rts


L11640
	dc.b	$00
L11641
	dc.b	$01


L11642
	subq.b	#1,L11641
	tst.b	L11641
	bne.s	L116aa
	move.b	#$4,L11641
	cmpi.w	#$12,L10aa2
	bcs.s	L1166a
	move.b	#$3,L11641
L1166a
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	addi.l	#$a0000,d0
	andi.l	#$7ff0000,d0
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$19,d2
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L1169e
	addq.w	#1,L10aa8
L1169e
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d2-d7/a0-a6
L116aa
	rts


L116ac
	dc.b	$00
L116ad
	dc.b	$1e


L116ae
	subq.b	#1,L116ad
	tst.b	L116ad
	bne.s	L11704
	move.b	#$4b,L116ad
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	addi.l	#$140000,d0
	andi.l	#$7ff0000,d0
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$1a,d2
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L116f8
	addq.w	#1,L10aa8
L116f8
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d2-d7/a0-a6
L11704
	rts


L11706
	dc.w	$0000


L11708
	subq.w	#1,L11706
	tst.w	L11706
	bpl.s	L1175e
	move.w	#$32,L11706
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	subi.l	#$80000,d0
	andi.l	#$7ff0000,d0
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$2f,d2
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L11752
	addq.w	#1,L10aa8
L11752
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d2-d7/a0-a6
L1175e
	rts


L11760
	move.l	$200(a0),d0
	move.l	$400(a0),d1
L11768
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$28,d2
	moveq	#$32,d4
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L1178a
	addq.w	#1,L10aa8
L1178a
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d2-d7/a0-a6
	rts


L11798
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	movem.l	d2-d7/a0-a6,-(a7)
	moveq	#$2b,d2
	moveq	#$32,d4
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L117c2
	addq.w	#1,L10aa8
L117c2
	move.w	#$1,Lb8c8
	movem.l	(a7)+,d2-d7/a0-a6
	rts


	dc.w	$0000,$08a0


L117d4
	move.w	#$800,d1
	jsr	L1ad48
	swap	d0
	move.l	d0,-(a7)
	move.w	#$8c,d1
	jsr	L1ad48
	swap	d0
	move.l	d0,d1
	move.l	(a7)+,d0
	moveq	#$2a,d2
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L1180e
	addq.w	#1,L10aa8
L1180e
	move.w	#$1,Lb8c8
	rts


L11818
	moveq	#$2,d1
	jsr	L1ad48
	subq.w	#1,d0
	ext.l	d0
	move.l	d0,d3
	move.w	$10(a0),d0
	move.w	$20(a0),d1
	addi.w	#$c,d1
	swap	d0
	swap	d1
	moveq	#$2d,d2
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L11850
	addq.w	#1,L10aa8
L11850
	move.w	#$1,Lb8c8
	rts


L1185a
	moveq	#$2,d1
	jsr	L1ad48
	subq.w	#1,d0
	ext.l	d0
	move.l	d0,d3
	move.w	$10(a0),d0
	move.w	$20(a0),d1
	addi.w	#$c,d1
	swap	d0
	swap	d1
	moveq	#$2e,d2
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L11892
	addq.w	#1,L10aa8
L11892
	move.w	#$1,Lb8c8
	rts


L1189c
	dc.w	$00c8


L1189e
	subq.w	#1,L1189c
	bne	L118fc
	move.w	#$c8,L1189c
	move.w	#$32,d1
	jsr	L1ad48
	subi.w	#$19,d0
	move.w	d0,d4
	swap	d4
	move.w	L4f7c,d0
	move.w	L4f7e,d1
	swap	d0
	swap	d1
	moveq	#$2c,d2
	move.l	#$10000,d5
	clr.l	d3
	clr.l	d6
	clr.w	Lb8c8
	jsr	Lb8ca
	tst.w	d7
	bmi.s	L118f4
	addq.w	#1,L10aa8
L118f4
	move.w	#$1,Lb8c8
L118fc
	rts


L118fe
	move.w	#$1,d1
	jsr	L1ad48
	move.w	d0,d3
	swap	d3
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d3
	addi.l	#$8000,d3
	moveq	#$2,d1
	jsr	L1ad48
	tst.b	d0
	beq.s	L11936
	move.l	#$ffffffff,d0
	sub.l	d3,d0
	move.l	d0,d3
L11936
	move.w	#$90,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d0,d2
	andi.l	#$ff,d2
	move.w	#$800,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d2,d1
	moveq	#$1,d5
	clr.l	d6
	moveq	#$7,d2
	jsr	Lb8ca
	rts


L1196a
	moveq	#$7f,d0
	movea.l	#$b944,a0
L11972
	cmpi.w	#$7,$602(a0)
	bne.s	L1197e
	clr.l	$c00(a0)
L1197e
	addq.l	#4,a0
	dbra	d0,L11972
	moveq	#$7f,d0
	movea.l	#$b944,a0
L1198c
	cmpi.w	#$7,$602(a0)
	bne.s	L119c0
	tst.l	(a0)
	beq.s	L119c0
	tst.l	$c00(a0)
	beq.s	L119a0
	bra.s	L119c0


L119a0
	movem.l	d0/a0,-(a7)
	move.l	$200(a0),d0
	move.l	$400(a0),d1
	moveq	#$7,d2
	move.l	$800(a0),d3
	moveq	#$1,d4
	moveq	#$1,d5
	jsr	Lb8ca
	movem.l	(a7)+,d0/a0
L119c0
	addq.l	#4,a0
	dbra	d0,L1198c
	rts


	lsl.w	#2,d0
	movea.l	#$b944,a0
	adda.w	d0,a0
	move.l	#$1,$600(a0)
	clr.l	d0
	clr.l	d1
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	move.l	#$7,d2
	jsr	Ld66e
	rts


	dc.w	$0000,$08a0


L119f8
	move.l	#$6000,d3
	moveq	#$2,d1
	jsr	L1ad48
	tst.b	d0
	beq.s	L11a14
	move.l	#$ffffffff,d0
	sub.l	d3,d0
	move.l	d0,d3
L11a14
	move.w	#$7ff,d1
	jsr	L1ad48
	swap	d0
	move.l	d0,d2
	move.w	#$28,d1
	jsr	L1ad48
	move.w	d0,d1
	addi.w	#$31,d0
	swap	d0
	swap	d1
	move.l	d0,d4
	move.l	d2,d0
	moveq	#$2,d2
	moveq	#$0,d6
	andi.l	#$7ff0000,d0
	andi.l	#$7ff0000,d1
	jsr	Lb8ca
	rts


L11a52
	moveq	#$3,d2
L11a54
	movem.l	d0-d2/a0,-(a7)
	move.l	#$a0000,d4
	move.w	d2,d4
	add.w	d4,d4
	swap	d4
	moveq	#$3,d2
	moveq	#$5,d5
	jsr	Lb8ca
	movem.l	(a7)+,d0-d2/a0
	dbra	d2,L11a54
	rts


	dc.w	$0000,$08a0


L11a7c
	move.w	#$800,d1
	jsr	L1ad48
	swap	d0
	move.l	#$900000,d1
	clr.l	d6
L11a90
	movem.l	d0-d1,-(a7)
	move.w	#$7fff,d1
	jsr	L1ad48
	andi.l	#$ffff,d0
	move.l	d0,d3
	addi.l	#$8000,d3
	move.b	$dff006,d0
	andi.b	#$2,d0
	tst.b	d0
	beq.s	L11ac0
	eori.l	#$ffffffff,d3
L11ac0
	movem.l	(a7)+,d0-d1
	jsr	Lb8ca
	rts


L11acc
	move.w	#$7d0,d1
	jsr	L1ad48
	swap	d0
	move.l	d0,d5
	move.w	#$800,d1
	jsr	L1ad48
	swap	d0
	move.l	#$900000,d1
	clr.l	d6
	movem.l	d0-d1,-(a7)
	move.w	#$7fff,d1
	jsr	L1ad48
	andi.l	#$ffff,d0
	move.l	d0,d3
	addi.l	#$8000,d3
	move.b	$dff006,d0
	andi.b	#$2,d0
	tst.b	d0
	beq.s	L11b1e
	eori.l	#$ffffffff,d3
L11b1e
	movem.l	(a7)+,d0-d1
	moveq	#$20,d2
	jsr	Lb8ca
	rts


L11b2c
	dc.w	$0000
L11b2e
	dc.w	$0064


L11b30
	subq.w	#1,L11b2e
	tst.w	L11b2e
	bpl	L11bda
	clr.w	L11b2e
	tst.w	L103ec
	bne	L11bda
	tst.w	L4b7a
	bne	L11bda
	tst.w	L4b78
	bne.s	L11bda
	tst.w	L11b2c
	bne.s	L11bda
	move.l	#$e372,Le248
	moveq	#$2,d0
L11b76
	move.w	d0,-(a7)
	jsr	L10da2
	move.w	(a7)+,d0
	dbra	d0,L11b76
	clr.w	L4b90
	moveq	#$7f,d2
	movea.l	#$b944,a2
L11b92
	move.l	#$1,$600(a2)
	move.w	#$82,d1
	jsr	L1ad48
	move.w	d0,$a00(a2)
	addq.l	#4,a2
	dbra	d2,L11b92
	st	L11b2c
	clr.w	L11c2c
	clr.w	L4f7a
	jsr	L11d5e
	jsr	L5444
	moveq	#$b,d0
	jsr	L1ad18
	jsr	Lec0c
L11bda
	rts


L11bdc
	move.l	L11c24,d3
L11be2
	cmpi.b	#$6,$603(a0)
	bne.s	L11c1c
	tst.l	(a0)
	beq.s	L11c1c
	move.l	a1,-(a7)
	moveq	#$3,d1
	jsr	L1ad48
	addi.w	#$9,d0
	ext.l	d0
	move.l	d0,$600(a0)
	movea.l	(a7)+,a1
	moveq	#$1,d2
	movem.l	d3/a0,-(a7)
	move.w	$200(a0),d0
	move.w	$400(a0),d1
	jsr	Ld66e
	movem.l	(a7)+,d3/a0
L11c1c
	subq.l	#4,a0
	dbra	d3,L11be2
	rts


L11c24
	dc.w	$0000,$0010
L11c28
	dc.w	$0000,$0000
L11c2c
	dc.w	$0000
L11c2e
	dc.w	$0000,$0000


L11c32
	moveq	#$7f,d7
	movea.l	#$b944,a2
	move.l	L11c24,d0
L11c40
	tst.l	(a2)
	beq.s	L11c52
	move.l	L11c24,d0
L11c4a
	addq.l	#4,a2
	dbra	d7,L11c40
	rts


L11c52
	dbra	d0,L11c4a
	move.w	#$800,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	move.l	d0,L11c28
	tst.w	L1698
	beq.s	L11c9e
	cmpi.w	#$1,L21a2
	bne	L11c88
	move.l	#$26a0000,L11c28
L11c88
	cmpi.w	#$2,L21a2
	bne	L11c9e
	move.l	#$3380000,L11c28
L11c9e
	move.l	L11c24,d6
	clr.l	d4
L11ca6
	move.w	#$2,d1
	jsr	L1ad48
	move.w	d0,d3
	swap	d3
	move.w	#$7fff,d1
	jsr	L1ad48
	add.w	d0,d0
	move.w	d0,d3
	addi.l	#$c000,d3
	moveq	#$2,d1
	jsr	L1ad48
	tst.b	d0
	beq.s	L11cde
	move.l	#$ffffffff,d0
	sub.l	d3,d0
	move.l	d0,d3
L11cde
	move.w	#$82,d1
	jsr	L1ad48
	ext.l	d0
	swap	d0
	tst.w	L21a2
	beq.s	L11cfa
	addi.l	#$a0000,d0
L11cfa
	move.l	d0,d2
	move.l	L11c28,d0
	move.l	d2,d1
	cmp.l	L11c24,d6
	bne.s	L11d38
	move.l	#$7268,d4
	moveq	#$5,d2
	movea.l	a2,a3
	move.l	#$10000,d3
	bra	L11d42


	cmpi.l	#$7268,d4
	bne.s	L11d38
	move.l	a3,d4
	addi.l	#$200,d4
	movea.l	a2,a3
	moveq	#$5,d2
	bra	L11d42


L11d38
	move.l	a3,d4
	addi.l	#$200,d4
	moveq	#$6,d2
L11d42
	movea.l	a2,a0
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	Lb8d6
	movem.l	(a7)+,d0-d7/a0-a6
	subq.l	#4,a2
	dbra	d6,L11ca6
	addq.w	#1,L11c2c
L11d5e
	moveq	#$11,d0
	tst.w	L11c2c
	bne.s	L11d70
	jsr	L1ad24
	rts


L11d70
	jsr	L1ad18
	rts


	dc.w	$0000,$08a0
L11d7c
	dc.w	$ffff


L11d7e
	addi.b	#$30,d0
	move.b	d0,L11e87
	move.w	#$fa,L11d7c
	jsr	Lec0c
	jsr	L11d5e
	jsr	L5444
	jsr	L5f4a
	jsr	L7016
	rts


L11db0
	tst.w	L11d7c
	bmi.s	L11de4
	move.w	Le126,d0
	sub.w	d0,L11d7c
	movea.l	Le536,a0
	movea.l	#$11e7c,a1
	move.w	#$0,d0
	move.w	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L11de4
	rts


L11de6
	dc.w	$ffff


L11de8
	addi.b	#$30,d0
	move.b	d0,L11e9e
	move.w	#$c8,L11de6
	rts


L11dfc
	tst.w	L11de6
	bmi.s	L11e30
	move.w	Le126,d0
	sub.w	d0,L11de6
	movea.l	Le536,a0
	movea.l	#$11e93,a1
	move.w	#$0,d0
	move.w	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L11e30
	rts


	dc.b	$04,'attack wave'
L11e3e
	dc.b	' '
L11e3f
	dc.b	' '
L11e40
	dc.b	' '
L11e41
	dc.b	'1 completed',$00,$00,$04,$04,'pods x ',$04
L11e58
	dc.b	'200',$00,$01,'sorry no bonus',$00,'100',$00,'200',$00,'400',$00,'800',$00,$0d,$8c,'P',$02,'player '
L11e87
	dc.b	'1 get ready',$00,$0d,$a7,'n',$02,'player '
L11e9e
	dc.b	'1',$0d,$91,$09,'g a m e  o v e r',$00,$0d,$96,'a',$05,'men:',$00,$0d,'ts',$02,'w a r p  g a t e  ',$03,'created',$00,$04,'  '
	dc.b	'    ',$00,$02,'please',$00,$02,'select',$00,$02,' play ',$00,$02,' mode ',$00,$04,'      ',$00,$04,'  use ',$00,$02,'  f1  ',$00,$02,'  '
	dc.b	'f2  ',$00,$02,'  f3  ',$00,$04,'  or  ',$00,$02,'  f4  ',$00,$04,'      ',$00,$04,'      ',$00,$02,'  to  ',$00,$02,'change',$00,$02,'sk'
	dc.b	'ill ',$00,$02,'level ',$00,$04,' use  ',$00,$02,'  1   ',$00,$02,'  2   ',$00,$04,'  or  ',$00,$02,'  3   ',$00,$04,'      ',$00,$04,'  '
	dc.b	'    ',$00,$02,'smart ',$00,$02,'bomb  ',$00,$04,' can  ',$00,$04,' be   ',$00,$04,'fired ',$00,$04,'from  ',$00,$04,'either',$00,$02,' k'
	dc.b	'ey  ',$00,$02,'board ',$00,$04,'  or  ',$00,$02,' joy  ',$00,$02,'stick ',$00,$04,'      ',$00,$04,'press ',$00,$02,'k or j',$00,$02,'k '
	dc.b	'or j',$00,$04,'      ',$00,$04,'      ',$00,$04,' use  ',$00,$04,' keys ',$00,$02,'  d   ',$00,$04,'  or  ',$00,$02,'  n   ',$00,$04,' f'
	dc.b	'or  ',$00,$04,' def  ',$00,$04,'  or  ',$00,$04,'normal',$00,$04,'screen',$00,$04,'scroll',$00,$04,' mode ',$00,$04,'      ',$00,$04,'  '
	dc.b	'    ',$00,$04,'      ',$00,$ff,$0d,$99,$bd,$04,'current',$0d,$86,$05,'skill level: ',$02
L120c8
	dc.b	'1',$0d,$96,$06,' normal ',$00,'  slow   normal   fast  ',$0d,$ae,$d7
L120f0
	dc.b	$04,'k',$0d,$ae,$06
L120f5
	dc.b	$04,'j',$00,$0d,'<',$c4,$02,' normal ',$00,' normal def mode',$0d,'<',$c2,$02,'        ',$00,$0d,'<',$c4,$02,'        ',$00,$02,$0d,$0a,$00,'th'
	dc.b	'e beginning is a relatively fractal multiverse.',$03,$0d,$0a,$08,'know then tha'
	dc.b	't the code exists in only one metaprogram,',$0d,$0a,$06,$02,'D A T A S T O R M.'
	dc.b	$04,$0d,$0a,$06,'the algorithm force of the is a cray megafloppy',$0d,$0a,$06,'meditation'
	dc.b	' syndrome,.... 68xxx code.',$01,$0d,$0a,$06,'within this unimultiverse trace th'
	dc.b	'e fine lines of',$0d,$0a,$06,'cellular autonoma, mirror shades are geometric'
	dc.b	'ally',$0d,$0a,$06,'undefinable et al.',$05,$0d,$0a,$06,'the stringspace extends life? the c'
	dc.b	'yberspace extends',$0d,$0a,$06,'that thot dimension. humanrace the intrinsic'
	dc.b	' is in',$0d,$0a,$06,'there mathtrix.',$03,$0d,$0a,$06,'fee new secs sky guild and! its dyna'
	dc.b	'mic, whom',$0d,$0a,$06,'vectorspace has radically mutated over 7.314 holopla'
	dc.b	'nes,',$0d,$0a,$06,'osaka, used 2 the irreversible megavrap, that is, to',$0d,$0a,$06,'ab'
	dc.b	'stract pzychomatter. is that to by any means the end',$0d,$0a,$06,'of the re'
	dc.b	'latively multi wraparound beginning?',$02,$0d,$0a,$06,'oh no!',$04,', momentary lapse'
	dc.b	' of limbic repitititious',$0d,$0a,$06,'dreasonsing.',$01,$0d,$0a,$06,'free new secs rotate '
	dc.b	'along impure peeramid reactricity,',$0d,$0a,$06,'of the multiverse. (The cod'
	dc.b	'e is in the vowels).',$03,$0d,$0a,$06,'a simplicit implocity of vast reason jud'
	dc.b	'ges the',$0d,$0a,$06,'tunnelling gate.',$04,$0d,$0a,$06,'hideous within the boxomatic r syn'
	dc.b	'tax terrors, known',$0d,$0a,$06,'as joyclik generators;...yet.  thoses tools'
	dc.b	'ines',$0d,$0a,$06,'fasteuristics kinetic a win, a gluon quirk of table(s).',$02,$0d
	dc.b	$0a,$07,'  the game is fast, very (f10) wisely composed.',$0d,$0d,$0e,$04,'(',$01,'c',$04,') ',$05,'copy'
	dc.b	'right 1989',$04,'  visionary design technologies inc.',$00,$00,$0d,$82,$0e,'production a'
	dc.b	'nd manufacturing by',$0d,$82,$08,'visionary design technologies, inc.',$0d,$82,$08,'cana'
	dc.b	'da',$0d,$82,$1a,'program code and game design by',$0d,$82,$08,'s`ren ''sodan'' gr`nbech',$0d,$82,$08
	dc.b	'denmark',$0d,$82,$1a,'graphics and animations by',$0d,$82,$08,'digital dream productions'
	dc.b	$0d,$82,$08,'united states',$0d,$82,$19,'musical scores composed by',$0d,$82,$08,'timm engels',$0d,$82,$08,'we'
	dc.b	'st germany',$00,$0d,$a5,$0a,$04,'2 5 0 0',$00,$0d,$a5,$0a,$03,'1 5 0 0',$00,$0d,'a',$7f,$01,'a ',$02,'mastercoda',$03,' experience'
	dc.b	$04,' mutation',$0d,'U',$07,$05,'realeyezed',$03,' bi ',$04,'s`ren ',$05,$27,$01,'sodan',$05,$27,' ',$02,'gr`nbech',$00


L127ae
	move.b	$bfec01,d0
	cmpi.b	#$4d,d0
	beq	L127e6
	cmpi.b	#$77,d0
	bne.s	L127e2
	movea.l	Le536,a0
	movea.l	#$12758,a1
	move.w	#$0,d0
	move.w	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
L127e2
	rts


L127e4
	dc.w	$0006


L127e6
	move.l	Le536,-(a7)
	move.w	Led62,d0
	swap	d0
	move.w	Led66,d0
	move.l	d0,Le536
	movea.l	#$1289c,a0
L12806
	subq.w	#1,L127e4
	tst.w	L127e4
	bpl.s	L12864
	move.w	#$5,L127e4
L1281c
	move.b	(a0)+,d0
	beq	L12872
	move.b	d0,L132f3
	move.b	$bfe001,d0
	btst	#$7,d0
	beq.s	L12872
	move.l	a0,-(a7)
	movea.l	Le536,a0
	adda.l	#$20,a0
	movea.l	#$132f0,a1
	moveq	#$0,d0
	moveq	#$2e,d1
	move.l	#$1b50,d3
	jsr	L137ce
	movea.l	(a7)+,a0
	cmpi.b	#$6,L132f3
	bcs.s	L1281c
L12864
	jsr	L132f6
	jsr	L1656
	bra.s	L12806


L12872
	move.b	$bfe001,d0
	btst	#$7,d0
	beq.s	L12872
	move.w	#$2,Le126
	move.w	#$2,Le124
	move.l	(a7)+,Le536
	clr.b	Lfde4
	rts


	dc.b	$03,'union of',$02,' elite programmers ',$03,'and ',$02,'hackers',$03,' who are experts in e'
	dc.b	'xecuting sophisticated maneuvers. featuring a limited membership'
	dc.b	' throughout the world of aggressive, skillful individuals, afrai'
	dc.b	'd of nothing to master their craft.            ',$03,'  welcome user! '
	dc.b	'to the multiverse of ',$02,'datastorm',$03,'.',$04,'  yet another program written '
	dc.b	'entirely in 68000.         ',$03,'the very first version of',$02,' datastorm'
	dc.b	' ',$03,'was hacked together in less than 3 days. it had all 128 enemys'
	dc.b	' running, explosions, radar, smartbombs and def mountains scroll'
	dc.b	'ing around. it also used dual playfield, with some terrible graf'
	dc.b	'ix. the code was about 3K.    ',$01,'now after 3 months of programming'
	dc.b	' is here the last and final version ready. the source is about 2'
	dc.b	'2000 lines, and is split up into two pieces (the dumb assembler '
	dc.b	'ran out of symboltable memory, ',$02,'arrgh',$01,'). no system-routines were'
	dc.b	' used, that means no libraries (-127), no intuition (nerd.base),'
	dc.b	' just 512k of free memory, one 68000 and three ladies.     ',$03,'hope'
	dc.b	' you all liked ',$02,'sword of sodan',$01,', got a lot of positive response '
	dc.b	'for that one. thannx.  ',$03,'i also hope you like ',$02,'datastorm,',$03,' it is '
	dc.b	'actually my own favorite game (being too selfish here???). i''ve '
	dc.b	'already been considering a ''datastorm 2'', and with a name like ',$02
	dc.b	'video storm -',$04,' revenge of the pixels',$03,', it could be a great follo'
	dc.b	'w up!            ',$01,'and now the essential greetings: ',$05,'to randy lin'
	dc.b	'den and mark vange for providing me with the best possible condi'
	dc.b	'tions to create the program, to andy hook for showing me that a '
	dc.b	'simple add.l would work fine as gravity instead of 25 lines of w'
	dc.b	'ierd code - and for the 3 days of hack (watch out for v o r t e '
	dc.b	'x), to the jb boys for great artwork (actually to much of it, it'
	dc.b	' would not fit on the disk), to timm engels for the musixxx and '
	dc.b	'my first telegram, to peter harlick for doing the datastorm ad, '
	dc.b	'to eric hymander, fulvio ciano, andy blau, andreas hommel, helga'
	dc.b	', chris chirogene, kim packard, claus lippert, torben, tomorrow '
	dc.b	'xyzlophone goodin, ivan, diana walsh, bob ''the waiter'' (encore a'
	dc.b	't marriot marque, new york), jan k.m., heidi, my parents, friend'
	dc.b	's and family.       ',$04,'a special greeting goes to jenna tedesco.  '
	dc.b	$03,'          my bet on the best music: ',$01,'pink floyd, the cure, enya'
	dc.b	' watermark, edie brickell, midnight oil, duran duran, kate bush '
	dc.b	'and brian eno.     ',$02,'and don''t miss the movie:',$04,' the big blue/le g'
	dc.b	'rand bleu.                  ',$03,'anyway i should be going now, but s'
	dc.b	'end us your comments about the program to the team at ',$04,'visionary'
	dc.b	' design technologies...  ',$01,'                 signed  ',$02,'s`ren gr`nbe'
	dc.b	'ch',$01,'      april 7 1989      ',$02,'           sodan',$04,': the fine',$03,' art',$04,' of'
	dc.b	' assembler programming.                                         '
	dc.b	'                   ',$00


	dc.w	$0d5a

	dc.b	$48
L132f3
	dc.b	$00

	dc.w	$0000


L132f6
	move.w	Le124,d0
L132fc
	cmp.w	Le124,d0
	beq.s	L132fc
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$f9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	Le536,d0
	addi.l	#$cf0,d0
	move.l	d0,d1
	subq.l	#2,d1
	moveq	#$4,d7
L13340
	jsr	Leaae
	movea.l	d0,a1
	adda.l	#$2c,a1
	clr.w	(a1)
	move.l	d0,$dff050
	move.l	d1,$dff054
	move.w	#$1d7,$dff058
	addi.l	#$1b50,d0
	addi.l	#$1b50,d1
	dbra	d7,L13340
	rts


	dc.w	$0000,$08a0
L1337a
	dc.w	$0000,$0400
L1337e
	dc.w	$0170
L13380
	dc.w	$0020
L13382
	dc.w	$0000,$1e30
L13386
	dc.w	$0000
L13388
	dc.w	$0000
L1338a
	dc.w	$0170
L1338c
	dc.w	$00a8
L1338e
	dc.w	$0006,$0000
L13392
	dc.w	$0004,$0000
L13396
	dc.w	$00a8
L13398
	dc.w	$0064
L1339a
	dc.w	$0040
L1339c
	dc.w	$0040
L1339e
	dc.w	$0000,$0200
L133a2
	dc.b	$00
L133a3
	dc.b	$05
L133a4
	dc.w	$0001
L133a6
	dc.w	$0004,$0000
L133aa
	dc.w	$fffe
L133ac
	dc.w	$0000
L133ae
	dc.w	$0000
L133b0
	dc.w	$0000
L133b2
	dc.w	$0000


L133b4
	move.w	L13396,d0
	move.w	L13386,d1
	add.w	L1338a,d1
	cmp.w	d1,d0
	bmi.s	L133ce
	bcc	L1367e
L133ce
	add.w	L1339a,d0
	sub.w	L13386,d0
	subq.w	#1,d0
	tst.w	d0
	bmi	L1367e
	move.w	L13398,d0
	move.w	L13388,d1
	add.w	L1338c,d1
	cmp.w	d1,d0
	bmi.s	L133fc
	bcc	L1367e
L133fc
	add.w	L1339c,d0
	sub.w	L13388,d0
	subq.w	#1,d0
	tst.w	d0
	bmi	L1367e
	tst.w	L133a4
	beq.s	L1341e
	jsr	L136a0
L1341e
	sf	L133b0
	sf	L133b2
	move.w	L1339a,L133ac
	move.w	L1339c,L133ae
	move.w	#$fffe,L133aa
	movea.l	L1337a,a0
	move.w	L13396,d0
	tst.w	d0
	bpl.s	L13468
	eori.w	#$ffff,d0
	lsr.w	#3,d0
	andi.b	#$fe,d0
	addq.w	#2,d0
	suba.w	d0,a0
	clr.w	d0
	bra.s	L13470


L13468
	lsr.w	#3,d0
	andi.b	#$fe,d0
	adda.w	d0,a0
L13470
	move.w	L1337e,d0
	lsr.w	#3,d0
	move.w	L13398,d1
	mulu.w	d0,d1
	adda.w	d1,a0
	clr.l	d0
	move.w	L13386,d0
	andi.w	#$fff0,d0
	sub.w	L13396,d0
	bmi.s	L134c2
	st	L133b0
	move.w	d0,d1
	andi.w	#$fff0,d1
	sub.w	d1,L1339a
	lsr.w	#3,d0
	andi.b	#$fe,d0
	add.l	d0,L1338e
	add.l	d0,L13392
	adda.w	d0,a0
	add.w	d0,L133aa
L134c2
	move.w	L13396,d0
	add.w	L133ac,d0
	move.w	L13386,d1
	add.w	L1338a,d1
	sub.w	d1,d0
	bmi.s	L134fc
	move.w	d0,d1
	andi.w	#$fff0,d1
	sub.w	d1,L1339a
	st	L133b2
	lsr.w	#3,d0
	andi.b	#$fe,d0
	add.w	d0,L133aa
L134fc
	move.w	L13398,d0
	sub.w	L13388,d0
	bpl.s	L1353c
	neg.w	d0
	sub.w	d0,L1339c
	move.w	L1337e,d1
	lsr.w	#3,d1
	mulu.w	d0,d1
	andi.b	#$fe,d1
	adda.w	d1,a0
	move.w	L133ac,d1
	lsr.w	#3,d1
	mulu.w	d0,d1
	andi.b	#$fe,d1
	add.l	d1,L1338e
	add.l	d1,L13392
L1353c
	move.w	L13388,d0
	add.w	L1338c,d0
	move.w	L13398,d1
	add.w	L133ae,d1
	sub.w	d1,d0
	bpl.s	L13560
	neg.w	d0
	sub.w	d0,L1339c
L13560
	jsr	Leaae
	move.w	L1337e,d5
	sub.w	L1339a,d5
	lsr.w	#3,d5
	andi.b	#$fe,d5
	subq.w	#2,d5
	movea.l	#$13680,a1
	move.w	L13396,d0
	andi.w	#$f,d0
	move.w	d0,d1
	tst.w	L13396
	nop
	neg.b	d0
	andi.w	#$f,d0
	add.w	d0,d0
	move.w	#$ffff,d2
	tst.b	L133b0
	beq.s	L135ac
	move.w	(a1,d0.w),d2
L135ac
	swap	d2
	clr.w	d2
	move.w	#$1,d6
	tst.b	L133b2
	beq.s	L135e2
	move.w	L13396,d0
	andi.w	#$f,d0
	eori.b	#$f,d0
	add.w	d0,d0
	move.w	(a1,d0.w),d2
	eori.w	#$ffff,d2
	clr.w	d6
	addi.w	#$2,L133aa
	addi.w	#$2,d5
L135e2
	move.l	d2,$dff044
	move.w	L133aa,$dff064
	move.w	L133aa,$dff062
	move.w	d5,$dff060
	move.w	d5,$dff066
	lsl.w	#8,d1
	lsl.w	#4,d1
	move.w	d1,$dff042
	ori.w	#$fca,d1
	move.w	d1,$dff040
	move.w	L1339c,d0
	lsl.w	#6,d0
	move.w	L1339a,d1
	lsr.w	#4,d1
	add.w	d1,d0
	add.w	d6,d0
	move.b	L133a3,d1
	subq.b	#1,d1
L13638
	move.l	L13392,$dff050
	move.l	L1338e,$dff04c
	move.l	a0,$dff048
	move.l	a0,$dff054
	move.w	d0,$dff058
	move.l	L1339e,d2
	add.l	d2,L1338e
	adda.l	L13382,a0
	tst.b	d1
	beq.s	L1367e
	jsr	Leaae
	subq.b	#1,d1
	bra.s	L13638


L1367e
	rts


	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001


L136a0
	move.l	L133a6,L13392
	bsr	Leaae
	move.l	#$ffff0000,$dff044
	move.l	L13392,$dff054
	move.l	L1338e,d0
	move.l	d0,$dff050
	add.l	L1339e,d0
	move.l	d0,$dff04c
	add.l	L1339e,d0
	move.l	d0,$dff048
	add.l	L1339e,d0
	move.w	#$fffe,$dff060
	move.w	#$fffe,$dff062
	move.w	#$fffe,$dff064
	move.w	#$fffe,$dff066
	move.w	#$ffe,$dff040
	move.w	#$0,$dff042
	move.w	L1339c,d1
	lsl.w	#6,d1
	move.w	L1339a,d2
	addi.w	#$10,d2
	lsr.w	#4,d2
	or.w	d2,d1
	move.w	d1,$dff058
	jsr	Leaae
	move.l	L13392,$dff054
	move.l	d0,$dff048
	add.l	L1339e,d0
	move.l	d0,$dff04c
	move.l	L13392,$dff050
	move.w	d1,$dff058
	rts


	dc.b	$04,'(',$01,'ever',$04,')',$0d,'hello',$00,'   ',$00,$0d,'2',$14,'                                         '
	dc.b	'         ',$00


	dc.w	$0007,$6a00,$0007,$8800,$0007,$a600,$0007,$c400,$0007,$e200
L137ca
	dc.w	$0007,$6a00


L137ce
	subq.w	#4,d1
	jsr	Leaae
	move.l	#$ffff0000,$dff044
	move.w	d1,$dff064
	move.w	#$0,$dff062
	move.w	d1,$dff066
	move.w	#$182,d7
	move.w	#$0,$dff042
	movea.l	#$137b6,a3
	movea.l	#L1036a,a4
	addq.w	#4,d1
L1380e
	move.b	(a1)+,d2
	beq	L138dc
	cmpi.b	#$d,d2
	bne.s	L1382a
	clr.w	d0
	move.b	(a1)+,d0
	clr.w	d2
	move.b	(a1)+,d2
L13822
	adda.w	d1,a0
	dbra	d2,L13822
	bra.s	L1380e


L1382a
	cmpi.b	#$6,d2
	bcc.s	L13842
	andi.w	#$ff,d2
	subq.b	#1,d2
	lsl.w	#2,d2
	move.l	(a3,d2.w),L137ca
	bra.s	L1380e


L13842
	andi.l	#$ff,d2
	cmpi.b	#$60,d2
	bcs.s	L13854
	subi.b	#$40,d2
	bra.s	L13858


L13854
	subi.b	#$20,d2
L13858
	lsl.w	#1,d2
	move.w	(a4,d2.w),d2
	add.l	L137ca,d2
	jsr	Leaae
	move.l	d2,$dff04c
	movea.l	#$138e0,a5
	move.w	d0,d2
	andi.w	#$f,d2
	lsl.b	#2,d2
	jsr	Leaae
	move.l	(a5,d2.w),$dff044
	move.w	d0,d2
	lsl.w	#8,d2
	lsl.w	#4,d2
	move.w	d2,$dff042
	move.w	#$dfc,d2
	move.w	d2,$dff040
	movea.l	a0,a2
	move.w	d0,d2
	lsr.w	#3,d2
	andi.b	#$fe,d2
	adda.w	d2,a2
	moveq	#$4,d2
L138b0
	jsr	Leaae
	move.l	a2,$dff054
	move.l	a2,$dff050
	move.w	d7,$dff058
	tst.w	L138de
	bne.s	L138d2
	adda.l	d3,a2
L138d2
	dbra	d2,L138b0
	addq.w	#6,d0
	bra	L1380e


L138dc
	rts


L138de
	dc.w	$0000,$03ff,$ffff,$81ff,$ffff,$c0ff,$ffff,$e07f,$ffff,$f03f,$ffff,$f81f,$ffff,$fc0f,$ffff,$fe07
	dc.w	$ffff,$ff03,$ffff,$ff81,$ffff,$ffc0,$ffff,$ffe0,$7fff,$fff0,$3fff,$fff8,$1fff,$fffc,$0fff,$fffe
	dc.w	$07ff


L13920
	tst.w	L1698
	bne.s	L13958
	movem.w	d0-d1,-(a7)
	move.w	-$2(a5,d3.w),d1
	jsr	L1ad48
	move.w	d0,d3
	movem.w	(a7)+,d0-d1
	cmpi.w	#$3,d3
	bne.s	L13958
	cmpi.b	#$1e,$603(a0)
	beq.s	L1395a
	jsr	L13b98
	moveq	#$d,d0
	jsr	L1ad18
L13958
	rts


L1395a
	move.w	L4f64,-(a7)
	move.w	$200(a0),L4f64
	jsr	L13b98
	moveq	#$d,d0
	jsr	L1ad18
	move.w	(a7)+,L4f64
	rts


	dc.w	$0000,$08a0
	ds.w	257
L13b84	dc.w	$0000


L13b86
	move.b	d0,d5
L13b88
	movea.l	#$13984,a0
	moveq	#$1f,d0
L13b90
	clr.w	(a0)+
	dbra	d0,L13b90
	rts


L13b98
	movea.l	#$13984,a0
	moveq	#$7,d3
L13ba0
	addq.w	#2,L13b84
	andi.w	#$f,L13b84
	move.w	L13b84,d7
	tst.w	(a0,d7.w)
	beq.s	L13bc0
	dbra	d3,L13ba0
	rts


L13bc0
	clr.w	$140(a0)
	clr.w	$180(a0)
	clr.w	$c0(a0)
	clr.w	$100(a0)
	clr.b	d5
	clr.b	d6
	clr.l	d3
	adda.w	d7,a0
	move.w	d0,$40(a0)
	move.w	d1,$80(a0)
	move.w	d2,$1c0(a0)
	clr.l	d2
	move.w	L4f64,d2
	move.w	L4f68,d3
	sub.w	d0,d2
	bpl.s	L13bfc
	neg.w	d2
	move.b	#$80,d5
L13bfc
	sub.w	d1,d3
	bpl.s	L13c06
	neg.w	d3
	move.b	#$80,d6
L13c06
	cmp.w	d2,d3
	bcc.s	L13c1a
	lsl.l	#8,d3
	divu.w	d2,d3
	move.w	d3,$100(a0)
	move.b	#$1,$c0(a0)
	bra.s	L13c2c


L13c1a
	tst.w	d3
	beq.s	L13c36
	lsl.l	#8,d2
	divu.w	d3,d2
	move.w	d2,$c0(a0)
	move.b	#$1,$100(a0)
L13c2c
	or.b	d5,$c0(a0)
	or.b	d6,$100(a0)
	st	(a0)
L13c36
	rts


L13c38
	eori.b	#$a,L13b86
	movea.l	#$ffea,a3
	movea.l	Le536,a1
	movea.l	#$13984,a0
	moveq	#$7,d7
L13c54
	tst.b	(a0)
	beq	L13d8e
	move.b	$c0(a0),d0
	or.b	$100(a0),d0
	tst.b	d0
	bne.s	L13c6c
	clr.w	(a0)
	bra	L13d8e


L13c6c
	move.w	Le126,d4
	add.w	$1c0(a0),d4
L13c76
	move.w	$100(a0),d0
	move.w	d0,d2
	andi.w	#$f00,d0
	clr.w	d1
	move.b	$180(a0),d1
	clr.w	d3
	move.b	$101(a0),d3
	add.w	d3,d1
	move.b	d1,$180(a0)
	andi.w	#$f00,d1
	add.w	d1,d0
	lsr.w	#8,d0
	tst.w	d2
	bpl.s	L13ca0
	neg.w	d0
L13ca0
	add.w	d0,$80(a0)
	move.w	$c0(a0),d0
	move.w	d0,d2
	andi.w	#$f00,d0
	clr.w	d1
	move.b	$140(a0),d1
	clr.w	d3
	move.b	$c1(a0),d3
	add.w	d3,d1
	move.b	d1,$140(a0)
	andi.w	#$f00,d1
	add.w	d1,d0
	lsr.w	#8,d0
	tst.w	d2
	bpl.s	L13cce
	neg.w	d0
L13cce
	add.w	d0,$40(a0)
	dbra	d4,L13c76
	move.w	$40(a0),d4
	andi.w	#$7ff,d4
	sub.w	Le0ea,d4
	tst.w	d4
	bpl.s	L13cec
	addi.w	#$800,d4
L13cec
	cmpi.w	#$16f,d4
	bcc	L13d96
	move.w	$80(a0),d5
	cmpi.w	#$96,d5
	bcc	L13d96
	movea.l	#$64544,a5
	move.w	d4,d1
	lsr.w	#3,d1
	adda.w	d1,a5
	move.w	d5,d1
	lsr.w	#2,d1
	andi.w	#$fffe,d1
	adda.w	(a3,d1.w),a5
	ori.b	#$80,d7
	move.b	d7,(a5)
	andi.b	#$7f,d7
	movea.l	a1,a2
	clr.l	d0
	move.w	d5,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	adda.w	d0,a2
	move.w	d4,d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	move.b	L13b86,d2
	clr.b	d0
	bset	d1,d0
	addq.b	#1,d1
	bset	d1,d0
	movea.l	a2,a4
	adda.l	#$2e,a4
	lsr.b	#1,d2
	bcc.s	L13d5e
	move.b	d0,(a2)
	move.b	d0,(a4)
L13d5e
	lsr.b	#1,d2
	bcc.s	L13d6a
	move.b	d0,$1b50(a2)
	move.b	d0,$1b50(a4)
L13d6a
	lsr.b	#1,d2
	bcc.s	L13d76
	move.b	d0,$36a0(a2)
	move.b	d0,$36a0(a4)
L13d76
	lsr.b	#1,d2
	bcc.s	L13d82
	move.b	d0,$51f0(a2)
	move.b	d0,$51f0(a4)
L13d82
	lsr.b	#1,d2
	bcc.s	L13d8e
	move.b	d0,$6d40(a2)
	move.b	d0,$6d40(a4)
L13d8e
	addq.l	#2,a0
	dbra	d7,L13c54
	rts


L13d96
	sf	(a0)
	bra.s	L13d8e


L13d9a
	dc.b	$00
L13d9b
	dc.b	$00


L13d9c
	movea.l	#$13e24,a0
	addq.b	#1,L13d9b
	andi.b	#$3,L13d9b
	move.w	L13d9a,d0
	mulu.w	#$328,d0
	ext.l	d0
	adda.l	d0,a0
	move.l	a0,d0
	move.w	d0,Led8e
	swap	d0
	move.w	d0,Led8a
	swap	d0
	addi.l	#$194,d0
	move.w	d0,Led96
	swap	d0
	move.w	d0,Led92
	move.w	L8788,d0
	addi.w	#$6c,d0
	sub.w	Le0ea,d0
	tst.w	d0
	bpl.s	L13dfc
	addi.w	#$800,d0
L13dfc
	cmpi.w	#$1f4,d0
	bcs.s	L13e04
	clr.w	d0
L13e04
	move.w	d0,d1
	lsr.w	#1,d0
	ori.w	#$5f00,d0
	move.w	d0,(a0)
	move.w	d0,$194(a0)
	andi.w	#$1,d1
	ori.w	#$c280,d1
	move.w	d1,$2(a0)
	move.w	d1,$196(a0)
	rts


	dc.w	$5f5e,$c280,$0080,$0480,$0400,$0080,$0080,$0000,$0400,$0400,$0080,$0480,$0400,$0480,$0000,$0080
	dc.w	$0400,$0080,$0000,$0480,$0600,$0680,$0000,$0280,$0200,$0080,$0080,$0080,$0200,$0200,$0080,$0200
	dc.w	$0000,$0280,$0080,$0280,$0080,$0280,$0000,$0280,$0080,$0200,$0000,$0200,$0280,$0280,$0000,$0080
	dc.w	$0200,$0080,$0000,$0280,$0200,$0280,$0200,$0280,$0000,$0280,$0200,$0080,$0080,$0080,$0200,$0200
	dc.w	$0080,$0200,$0000,$0280,$0080,$0280,$0080,$0280,$0000,$0280,$0080,$0200,$0000,$0200,$0280,$0280
	dc.w	$0000,$0080,$0200,$0080,$0400,$0680,$0200,$0680,$0400,$0080,$0000,$0080,$0400,$0480,$0080,$0480
	dc.w	$0000,$0400,$0080,$0400,$0000,$0480,$0080,$0480,$0000,$0400,$0080,$0480,$0400,$0480,$0000,$0080
	dc.w	$0400,$0080,$0000,$0480,$0400,$0480,$0000,$0480,$0400,$0080,$0080,$0080,$0400,$0400,$0080,$0400
	dc.w	$0000,$0480,$0080,$0480,$0080,$0480,$0000,$0480,$0080,$0400,$0000,$0400,$0480,$0480,$0000,$0080
	dc.w	$0400,$0080,$0000,$0480,$0400,$0480,$0400,$0480,$0000,$0480,$0000,$0480,$0080,$0480,$0000,$0400
	dc.w	$0080,$0400,$0000,$0480,$0080,$0480,$0400,$0400,$0000,$0000,$0400,$0000,$0000,$0400,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0600,$0000,$0600,$0000,$0600,$0000,$1680,$1080
	dc.w	$1680,$1080,$2940,$2640,$50a0,$4f20,$a050,$9f90,$0000,$0000,$5f5e,$c280,$0480,$0480,$0480,$0480
	dc.w	$0480,$0480,$0080,$0480,$0000,$0480,$0000,$0480,$0400,$0480,$0400,$0480,$0400,$0480,$0600,$0680
	dc.w	$0200,$0280,$0200,$0280,$0200,$0280,$0080,$0280,$0080,$0280,$0080,$0280,$0080,$0280,$0080,$0280
	dc.w	$0080,$0280,$0080,$0280,$0080,$0280,$0000,$0280,$0200,$0280,$0200,$0280,$0200,$0280,$0200,$0280
	dc.w	$0200,$0280,$0200,$0280,$0200,$0280,$0200,$0280,$0080,$0280,$0080,$0280,$0080,$0280,$0080,$0280
	dc.w	$0080,$0280,$0080,$0280,$0080,$0280,$0080,$0280,$0000,$0280,$0200,$0280,$0200,$0280,$0600,$0680
	dc.w	$0600,$0680,$0400,$0480,$0400,$0480,$0000,$0480,$0000,$0480,$0080,$0480,$0080,$0480,$0080,$0480
	dc.w	$0080,$0480,$0080,$0480,$0000,$0480,$0000,$0480,$0400,$0480,$0400,$0480,$0400,$0480,$0400,$0480
	dc.w	$0400,$0480,$0400,$0480,$0400,$0480,$0080,$0480,$0080,$0480,$0080,$0480,$0080,$0480,$0080,$0480
	dc.w	$0080,$0480,$0080,$0480,$0080,$0480,$0000,$0480,$0400,$0480,$0400,$0480,$0400,$0480,$0400,$0480
	dc.w	$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0080,$0480,$0080,$0480,$0080,$0480,$0080,$0480
	dc.w	$0000,$0400,$0400,$0400,$0400,$0400,$0400,$0400,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0600,$0000,$0f00,$0000,$0f00,$1080,$0f00,$1080,$0f00,$2040,$1f80,$4020,$3fc0
	dc.w	$8010,$7fe0,$0000,$0000,$0000,$0000,$0000,$0000,$0800,$0800,$0000,$0800,$0800,$0000,$0000,$0000
	dc.w	$0800,$0800,$0200,$0a00,$0000,$0a00,$0200,$0800,$0800,$0800,$0200,$0200,$0800,$0200,$0000,$0a00
	dc.w	$0800,$0a00,$0000,$0200,$0400,$0600,$0000,$0600,$0400,$0200,$0200,$0200,$0400,$0400,$0200,$0400
	dc.w	$0000,$0600,$0200,$0600,$0100,$0500,$0000,$0500,$0100,$0400,$0000,$0400,$0500,$0500,$0000,$0100
	dc.w	$0400,$0100,$0000,$0500,$0400,$0500,$0000,$0100,$0400,$0500,$0000,$0500,$0500,$0100,$0000,$0000
	dc.w	$0500,$0400,$0000,$0500,$0100,$0500,$0100,$0500,$0000,$0500,$0100,$0400,$0000,$0400,$0100,$0500
	dc.w	$0400,$0500,$0000,$0100,$0400,$0100,$0000,$0500,$0400,$0500,$0400,$0100,$0000,$0100,$0500,$0500
	dc.w	$0000,$0400,$0100,$0400,$0000,$0500,$0100,$0500,$0000,$0400,$0000,$0400,$0100,$0500,$0400,$0500
	dc.w	$0100,$0000,$0400,$0000,$0100,$0500,$0400,$0500,$0000,$0100,$0000,$0100,$0000,$0100,$0800,$0900
	dc.w	$0000,$0900,$0800,$0100,$0100,$0100,$0800,$0800,$0100,$0800,$0000,$0900,$0100,$0900,$0000,$0800
	dc.w	$0100,$0900,$0000,$0900,$0000,$0900,$0800,$0900,$0000,$0100,$0800,$0100,$0000,$0900,$0800,$0900
	dc.w	$0100,$0100,$0000,$0000,$0100,$0000,$0000,$0100,$0100,$0100,$0000,$0000,$0600,$0000,$0600,$0000
	dc.w	$0600,$0000,$1680,$1080,$1680,$1080,$2940,$2640,$50a0,$4f20,$a050,$9f90,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0800,$0800,$0800,$0800,$0800,$0800,$0800,$0800,$0000,$0800,$0200,$0a00,$0200,$0a00
	dc.w	$0200,$0a00,$0200,$0a00,$0800,$0a00,$0800,$0a00,$0800,$0a00,$0800,$0a00,$0000,$0200,$0400,$0600
	dc.w	$0400,$0600,$0400,$0600,$0400,$0600,$0200,$0600,$0200,$0600,$0200,$0600,$0200,$0600,$0100,$0500
	dc.w	$0100,$0500,$0100,$0500,$0100,$0500,$0000,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500
	dc.w	$0000,$0100,$0400,$0500,$0400,$0500,$0400,$0500,$0500,$0500,$0100,$0500,$0100,$0500,$0100,$0500
	dc.w	$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0000,$0500,$0000,$0500,$0400,$0500,$0400,$0500
	dc.w	$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0000,$0500,$0100,$0500,$0100,$0500,$0100,$0500
	dc.w	$0100,$0500,$0000,$0400,$0000,$0400,$0100,$0500,$0100,$0500,$0500,$0500,$0500,$0500,$0400,$0500
	dc.w	$0400,$0500,$0000,$0100,$0000,$0100,$0000,$0100,$0800,$0900,$0800,$0900,$0800,$0900,$0800,$0900
	dc.w	$0100,$0900,$0100,$0900,$0100,$0900,$0100,$0900,$0100,$0900,$0000,$0900,$0000,$0900,$0000,$0900
	dc.w	$0000,$0900,$0800,$0900,$0800,$0900,$0800,$0900,$0800,$0900,$0000,$0100,$0100,$0100,$0100,$0100
	dc.w	$0100,$0100,$0100,$0100,$0000,$0000,$0000,$0600,$0000,$0f00,$0000,$0f00,$1080,$0f00,$1080,$0f00
	dc.w	$2040,$1f80,$4020,$3fc0,$8010,$7fe0,$0000,$0000,$0000,$0000,$0000,$0000,$0080,$0080,$0000,$0080
	dc.w	$0080,$0000,$0000,$0000,$0080,$0080,$0000,$0080,$0080,$0480,$0400,$0000,$0080,$0000,$0400,$0480
	dc.w	$0180,$0580,$0000,$0500,$0100,$0400,$0000,$0400,$0100,$0500,$0000,$0500,$0000,$0500,$0400,$0500
	dc.w	$0000,$0100,$0400,$0100,$0000,$0500,$0400,$0500,$0100,$0100,$0400,$0400,$0100,$0400,$0000,$0500
	dc.w	$0100,$0500,$0000,$0400,$0100,$0500,$0000,$0500,$0000,$0500,$0400,$0500,$0000,$0100,$0400,$0100
	dc.w	$0000,$0500,$0400,$0500,$0100,$0500,$0400,$0000,$0100,$0000,$0400,$0500,$0100,$0500,$0000,$0400
	dc.w	$0000,$0400,$0100,$0500,$0000,$0500,$0100,$0400,$0000,$0400,$0500,$0500,$0000,$0100,$0400,$0100
	dc.w	$0000,$0500,$0400,$0500,$0400,$0500,$0000,$0500,$0400,$0100,$0100,$0100,$0400,$0400,$0100,$0400
	dc.w	$0000,$0500,$0100,$0500,$0000,$0400,$0000,$0400,$0000,$0400,$0080,$0480,$0400,$0480,$0080,$0000
	dc.w	$0400,$0000,$0080,$0480,$0400,$0480,$0000,$0480,$0400,$0080,$0000,$0080,$0400,$0480,$0000,$0480
	dc.w	$0000,$0480,$0080,$0480,$0000,$0400,$0080,$0400,$0000,$0480,$0080,$0480,$0400,$0400,$0000,$0000
	dc.w	$0400,$0000,$0000,$0400,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0600,$0000,$0600,$0000,$0600,$0000,$1680,$1080,$1680,$1080,$2940,$2640,$50a0,$4f20,$a050,$9f90
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0080,$0080,$0080,$0080,$0080,$0080,$0080,$0080,$0000,$0080
	dc.w	$0000,$0080,$0400,$0480,$0480,$0480,$0480,$0480,$0080,$0480,$0180,$0580,$0100,$0500,$0100,$0500
	dc.w	$0100,$0500,$0000,$0500,$0000,$0500,$0000,$0500,$0000,$0500,$0400,$0500,$0400,$0500,$0400,$0500
	dc.w	$0400,$0500,$0400,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0000,$0500
	dc.w	$0000,$0500,$0000,$0500,$0000,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500
	dc.w	$0500,$0500,$0500,$0500,$0100,$0500,$0100,$0500,$0000,$0400,$0000,$0400,$0100,$0500,$0100,$0500
	dc.w	$0100,$0500,$0100,$0500,$0000,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500
	dc.w	$0400,$0500,$0400,$0500,$0400,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0000,$0400
	dc.w	$0000,$0400,$0000,$0400,$0080,$0480,$0080,$0480,$0480,$0480,$0480,$0480,$0400,$0480,$0400,$0480
	dc.w	$0400,$0480,$0400,$0480,$0400,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0080,$0480
	dc.w	$0080,$0480,$0080,$0480,$0080,$0480,$0000,$0400,$0400,$0400,$0400,$0400,$0400,$0400,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0600,$0000,$0f00,$0000,$0f00
	dc.w	$1080,$0f00,$1080,$0f00,$2040,$1f80,$4020,$3fc0,$8010,$7fe0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0400,$0400,$0000,$0400,$0400,$0000,$0000,$0000,$0400,$0400,$0000,$0400,$0000,$0400,$0000,$0400
	dc.w	$0000,$0400,$0000,$0400,$0100,$0500,$0000,$0500,$0500,$0400,$0000,$0000,$0500,$0100,$0000,$0500
	dc.w	$0400,$0500,$0000,$0100,$0000,$0100,$0400,$0500,$0000,$0500,$0400,$0100,$0100,$0100,$0400,$0400
	dc.w	$0100,$0400,$0000,$0500,$0100,$0500,$0000,$0400,$0100,$0500,$0000,$0500,$0100,$0400,$0400,$0400
	dc.w	$0100,$0100,$0400,$0100,$0000,$0500,$0400,$0500,$0000,$0100,$0400,$0500,$0000,$0500,$0400,$0100
	dc.w	$0100,$0100,$0400,$0400,$0100,$0400,$0000,$0500,$0100,$0500,$0100,$0500,$0000,$0500,$0100,$0400
	dc.w	$0000,$0400,$0500,$0500,$0000,$0100,$0400,$0100,$0000,$0500,$0600,$0700,$0000,$0300,$0200,$0100
	dc.w	$0000,$0100,$0300,$0300,$0000,$0200,$0100,$0200,$0000,$0300,$0100,$0300,$0000,$0200,$0000,$0200
	dc.w	$0000,$0200,$0200,$0200,$0000,$0000,$0280,$0080,$0000,$0280,$0680,$0600,$0000,$0400,$0480,$0080
	dc.w	$0000,$0080,$0400,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0080,$0480
	dc.w	$0000,$0400,$0480,$0400,$0000,$0080,$0480,$0080,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0600,$0000,$0600,$0000,$0600,$0000,$1680,$1080,$1680,$1080,$2940,$2640
	dc.w	$50a0,$4f20,$a050,$9f90,$0000,$0000,$0000,$0000,$0000,$0000,$0400,$0400,$0400,$0400,$0400,$0400
	dc.w	$0400,$0400,$0000,$0400,$0000,$0400,$0000,$0400,$0000,$0400,$0000,$0400,$0000,$0400,$0100,$0500
	dc.w	$0100,$0500,$0100,$0500,$0500,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0000,$0100,$0000,$0100
	dc.w	$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500
	dc.w	$0000,$0400,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0400,$0500,$0400,$0500,$0400,$0500
	dc.w	$0400,$0500,$0000,$0100,$0400,$0500,$0400,$0500,$0400,$0500,$0400,$0500,$0100,$0500,$0100,$0500
	dc.w	$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0100,$0500,$0000,$0500,$0400,$0500
	dc.w	$0400,$0500,$0400,$0500,$0600,$0700,$0200,$0300,$0200,$0300,$0200,$0300,$0000,$0300,$0100,$0300
	dc.w	$0100,$0300,$0100,$0300,$0100,$0300,$0000,$0200,$0000,$0200,$0000,$0200,$0000,$0200,$0200,$0200
	dc.w	$0280,$0280,$0280,$0280,$0680,$0680,$0480,$0480,$0400,$0480,$0400,$0480,$0000,$0480,$0000,$0480
	dc.w	$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0000,$0480,$0080,$0480,$0080,$0480,$0480,$0480
	dc.w	$0480,$0480,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0600
	dc.w	$0000,$0f00,$0000,$0f00,$1080,$0f00,$1080,$0f00,$2040,$1f80,$4020,$3fc0,$8010,$7fe0,$0000,$0000


L14ac4
	clr.w	Le534
	clr.l	Leaba
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.l	#$e128,$6c
	move.l	#$20,Le53e
	addi.l	#$71c02,Le53e
	jsr	Ld644
	moveq	#$8,d0
	jsr	L430
	movea.l	#$6913e,a0
	movea.l	#$65e9a,a1
	movea.l	#$6f49a,a2
	jsr	decompress
	move.w	#$364c,d0
	movea.l	#$14f98,a0
	movea.l	#$71c00,a1
L14b3a
	move.b	(a0)+,(a1)+
	dbra	d0,L14b3a
	move.l	#$4f73a,Le536
	jsr	L156ca
	move.l	#$5aaea,Le536
	jsr	L156ca
	jsr	L14cdc
	jsr	Le77a
	move.l	#$71c00,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	move.w	#$8030,$dff09a
	move.w	#$c8,L1547a
	rts


	dc.w	$0000,$08a0


L14b9e
	jsr	Le9f2
	jsr	L1656
	jsr	Leaae
	jsr	L156ca
	jsr	L14ef2
	jsr	L14e0e
	tst.w	L1698
	beq.s	L14bec
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L14bd8
	bra.s	L14bde


L14bd8
	btst	#$6,d0
	bne.s	L14bec
L14bde
	addq.l	#4,a7
	jsr	L1ad06
	jmp	Le10


L14bec
	subq.w	#1,L1547a
	tst.w	L1547a
	bpl.s	L14b9e
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$30,$dff09a
	move.w	#$0,$dff180
	moveq	#$1a,d0
	jsr	L430
	movea.l	#$51e90,a0
	movea.l	#$50000,a1
	movea.l	#$59c80,a2
	jsr	decompress
	movea.l	#$59c40,a0
	movea.l	#$f112,a1
	moveq	#$1f,d0
L14c4e
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,L14c4e
	movea.l	#$50000,a0
	movea.l	#$14d16,a1
	moveq	#$28,d1
	move.l	#$1f40,d3
	jsr	L137ce
	move.l	#$f0c8,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	move.l	#$3d090,d7
L14c92
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L14ca0
	bra.s	L14ca6


L14ca0
	btst	#$6,d0
	bne.s	L14cb4
L14ca6
	addq.l	#4,a7
	jsr	L1ad06
	jmp	Le10


L14cb4
	jsr	L1656
	subi.l	#$1,d7
	bne	L14c92
	move.l	#$ecf0,Lfcf8
	jsr	Lff0c
	jsr	Lfcfc
	rts


L14cdc
	move.w	#$23ef,d0
	movea.l	#$6f49a,a0
L14ce6
	clr.b	(a0)+
	dbra	d0,L14ce6
	move.w	#$1,L138de
	movea.l	#$6f49a,a0
	movea.l	#$12626,a1
	moveq	#$2e,d1
	move.l	#$23f0,d3
	jsr	L137ce
	clr.w	L138de
	rts


	dc.b	$0d,$14,'v',$01,'diskloader and compression system by',$0d,$14,$07,$04,'randy linden',$0d,$14,$0b,$01,'spec'
	dc.b	'ial thanks to',$0d,$14,$07,$04,'andy hook  ',$01,'for math help',$0d,$14,$07,$04,'mark vange and r.l'
	dc.b	'. ',$01,' for selling this program',$0d,$14,$09,$01,'and to the rest of the team here'
	dc.b	' at',$0d,$14,$07,$04,'visionary design technologies',$00,$00


L14dfc
	dc.w	$0000,$0006,$a99a,$0006,$cf1a,$0006,$841a,$0006,$5e9a


L14e0e
	addq.w	#1,L14dfc
	cmpi.w	#$a,L14dfc
	bne	L14e26
	clr.w	L14dfc
L14e26
	moveq	#$3,d7
L14e28
	move.w	d7,-(a7)
	move.l	Le536,L1337a
	move.l	#$23f0,L13382
	move.w	#$170,L1337e
	move.w	#$c8,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$c8,L1338c
	move.w	d7,d0
	eori.b	#$3,d0
	lsl.w	#2,d0
	movea.l	#$14dfe,a0
	move.l	(a0,d0.w),d0
	move.w	L14dfc,d1
	move.w	d7,d2
	lsl.w	#2,d2
	add.w	d2,d1
L14e8c
	cmpi.w	#$9,d1
	ble	L14e9a
	subi.w	#$a,d1
	bra.s	L14e8c


L14e9a
	mulu.w	#$3c0,d1
	add.l	d1,d0
	move.l	d0,L1338e
	move.w	#$32,L13396
	move.w	d7,d0
	eori.b	#$3,d0
	mulu.w	#$2d,d0
	addi.w	#$a,d0
	move.w	d0,L13398
	move.w	#$30,L1339a
	move.w	#$20,L1339c
	move.l	#$c0,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	move.w	(a7)+,d7
	dbra	d7,L14e28
	rts


L14ef2
	move.w	#$1,L133a2
	move.l	Le536,L1337a
	addi.l	#$8fc0,L1337a
	move.l	#$23f0,L13382
	move.w	#$170,L1337e
	move.w	#$c8,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$c8,L1338c
	move.l	#$6f49a,L1338e
	move.w	#$0,L13396
	move.w	#$0,L13398
	move.w	#$170,L1339a
	move.w	#$c8,L1339c
	move.l	#$23f0,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	move.w	#$5,L133a2
	rts


	dc.w	$0000,$08a0,$0100,$5200,$0104,$0000,$008e,$2a71,$0090,$f2d1,$0092,$0030,$0094,$00d8,$0108,$0002
	dc.w	$010a,$0002,$00e0,$0000,$00e2,$0000,$00e4,$0000,$00e6,$0000,$00e8,$0000,$00ea,$0000,$00ec,$0000
	dc.w	$00ee,$0000,$00f0,$0000,$00f2,$0000,$0180,$0003,$0182,$0fff,$0184,$0ddd,$0186,$009d,$0188,$007b
	dc.w	$018a,$0059,$018c,$0d33,$018e,$0a22,$0190,$0333,$0192,$0fa0,$0194,$0f80,$0196,$0c60,$0198,$0f53
	dc.w	$019a,$0444,$019c,$0ff0,$019e,$0cc0,$01a0,$0fff,$01a2,$0777,$01a4,$0555,$01a6,$04f4,$01a8,$03f7
	dc.w	$01aa,$03fb,$01ac,$02ff,$01ae,$0000,$01b0,$016f,$01b2,$000f,$01b4,$0888,$01b6,$0666,$01b8,$0444
	dc.w	$01ba,$0333,$01bc,$0222,$01be,$0111,$3901,$ff00,$01a0,$0fff,$3a01,$ff00,$01a0,$0ddd,$3b01,$ff00
	dc.w	$01a0,$0bbb,$3c01,$ff00,$01a0,$0999,$3d01,$ff00,$01a0,$0777,$4201,$ff00,$01a0,$0fff,$4301,$ff00
	dc.w	$01a0,$0ddd,$4401,$ff00,$01a0,$0bbb,$4501,$ff00,$01a0,$0999,$4601,$ff00,$01a0,$0777,$4b01,$ff00
	dc.w	$01a0,$0fff,$4c01,$ff00,$01a0,$0ddd,$4d01,$ff00,$01a0,$0bbb,$4e01,$ff00,$01a0,$0999,$4f01,$ff00
	dc.w	$01a0,$0777,$6601,$ff00,$01a0,$0fff,$6701,$ff00,$01a0,$0fcc,$6801,$ff00,$01a0,$0faa,$6901,$ff00
	dc.w	$01a0,$0f77,$6a01,$ff00,$01a0,$0f55,$6f01,$ff00,$01a0,$0fff,$7001,$ff00,$01a0,$0fcc,$7101,$ff00
	dc.w	$01a0,$0faa,$7201,$ff00,$01a0,$0f77,$7301,$ff00,$01a0,$0f55,$7801,$ff00,$01a0,$0fff,$7901,$ff00
	dc.w	$01a0,$0fcc,$7a01,$ff00,$01a0,$0faa,$7b01,$ff00,$01a0,$0f77,$7c01,$ff00,$01a0,$0f55,$9301,$ff00
	dc.w	$01a0,$0fff,$9401,$ff00,$01a0,$0ddf,$9501,$ff00,$01a0,$0bbf,$9601,$ff00,$01a0,$099f,$9701,$ff00
	dc.w	$01a0,$077f,$9c01,$ff00,$01a0,$0fff,$9d01,$ff00,$01a0,$0ddf,$9e01,$ff00,$01a0,$0bbf,$9f01,$ff00
	dc.w	$01a0,$099f,$a001,$ff00,$01a0,$077f,$a501,$ff00,$01a0,$0fff,$a601,$ff00,$01a0,$0ddf,$a701,$ff00
	dc.w	$01a0,$0bbf,$a801,$ff00,$01a0,$099f,$a901,$ff00,$01a0,$077f,$bf01,$ff00,$01a0,$0fff,$c001,$ff00
	dc.w	$01a0,$0ffc,$c101,$ff00,$01a0,$0ffa,$c201,$ff00,$01a0,$0ff8,$c301,$ff00,$01a0,$0ff5,$c801,$ff00
	dc.w	$01a0,$0fff,$c901,$ff00,$01a0,$0ffc,$ca01,$ff00,$01a0,$0ffa,$cb01,$ff00,$01a0,$0ff8,$cc01,$ff00
	dc.w	$01a0,$0ff5,$d101,$ff00,$01a0,$0fff,$d201,$ff00,$01a0,$0ffc,$d301,$ff00,$01a0,$0ffa,$d401,$ff00
	dc.w	$01a0,$0ff8,$d501,$ff00,$01a0,$0ff5,$d701,$ff00,$009c,$8010,$ffff,$fffe


	jsr	Lff0c
	move.l	#$e128,$6c
	move.l	#$eff4,Lfcf8
	jsr	Lfcfc
	move.l	#$f016,Le53e
	movea.l	#$7250a,a0
	move.w	#$ff,d0
L15280
	clr.b	(a0)+
	dbra	d0,L15280
	movea.l	#$4d02a,a0
	move.w	#$9c3f,d0
L15290
	clr.w	(a0)+
	dbra	d0,L15290
	move.w	#$3f,d0
	movea.l	#$7258a,a0
L152a0
	move.w	d0,d1
	asl.w	#1,d1
	move.w	d0,(a0,d1.w)
	subq.w	#1,d0
	bne.s	L152a0
	jsr	Lfef8
	jsr	Lff1e
L152b8
	jsr	Le9ce
	jsr	L1656
	jsr	L156ca
	jsr	Leaae
	jsr	L15704
	move.w	Le124,d1
L152dc
	move.b	$bfec01,d0
	cmpi.b	#$77,d0
	beq.s	L152dc
	move.w	d1,Le124
	move.b	$bfec01,d0
	cmpi.b	#$75,d0
	beq.s	L15308
	cmpi.l	#$b7b0,Le536
	bne.s	L152b8
	bra.s	L152b8


L15308
	jsr	Lff0c
	rts


L15310
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.l	#$e128,$6c
	move.l	#$f016,Le53e
	move.w	#$29e,L1547a
	moveq	#$7,d0
	jsr	L430
	movea.l	#$737a6,a0
	movea.l	#$7260a,a1
	movea.l	#$75a12,a2
	jsr	decompress
	jsr	Le73a
	movea.l	#$7250a,a0
	move.w	#$ff,d0
L15372
	clr.b	(a0)+
	dbra	d0,L15372
	move.w	#$3f,d0
	movea.l	#$7258a,a0
L15382
	move.w	d0,d1
	lsl.w	#1,d1
	move.w	d0,(a0,d1.w)
	subq.w	#1,d0
	bne.s	L15382
	movea.l	#$656ca,a0
	move.w	#$abe0,d0
L15398
	clr.b	(a0)+
	dbra	d0,L15398
	movea.l	#$4d02a,a0
	move.w	#$59d7,d0
L153a8
	clr.l	(a0)+
	dbra	d0,L153a8
	st	L15576
	move.w	#$d7,L15572
	move.w	#$c6,L15574
	clr.w	L155e2
	clr.l	L156b8
	move.w	#$258,L156bc
	jsr	L1547c
	move.w	#$8030,$dff09a
	move.l	#$eff4,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	rts


L15404
	jsr	Le9ce
	jsr	L1656
	jsr	L156ca
	jsr	Leaae
	jsr	L15704
	jsr	L15578
	jsr	Ld6a4
	jsr	L1549e
	jsr	L155e4
	tst.w	L1698
	beq.s	L15464
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L15450
	bra.s	L15456


L15450
	btst	#$6,d0
	bne.s	L15464
L15456
	addq.l	#4,a7
	jsr	L1ad06
	jmp	Le10


L15464
	subq.w	#1,L1547a
	tst.w	L1547a
	bpl.s	L15404
	jsr	Lff0c
	rts


L1547a
	dc.w	$0000


L1547c
	movea.l	#$656ca,a0
	movea.l	#$1212f,a1
	move.w	#$32,d0
	move.w	#$2c,d1
	move.l	#$2260,d3
	jsr	L137ce
	rts


L1549e
	move.l	Le536,L1337a
	move.l	#$23f0,L13382
	move.w	#$170,L1337e
	move.w	#$c8,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$c8,L1338c
	move.l	#$656ca,L1338e
	move.w	L15572,L13396
	move.w	L15574,L13398
	move.w	#$160,L1339a
	move.w	#$c8,L1339c
	move.l	#$2260,L1339e
	move.l	L133a6,-(a7)
	clr.w	L133a4
	move.l	#$702aa,L13392
	tst.w	L15576
	beq.s	L15550
	move.w	#$1,L133a4
	clr.w	L15576
	move.l	#$702aa,L133a6
L15550
	jsr	L133b4
	move.l	(a7)+,L133a6
	tst.w	L15574
	beq.s	L15570
	subq.w	#1,L15572
	subq.w	#1,L15574
L15570
	rts


L15572
	dc.w	$00d8
L15574
	dc.w	$00c7
L15576
	dc.w	$0001


L15578
	move.w	#$1e,d1
	jsr	L1ad48
	addq.w	#1,d0
	move.w	d0,d2
	addq.w	#1,L155e2
	move.w	L155e2,d0
	cmpi.w	#$c8,d0
	bcs.s	L155b2
	cmpi.w	#$d8,d0
	bcc.s	L155b2
	subi.w	#$c8,d0
	mulu.w	#$14,d0
	move.w	#$c4,d1
	jsr	Ld66e
	rts


L155b2
	cmpi.w	#$d8,d0
	bcs.s	L155da
	cmpi.w	#$e8,d0
	bcc.s	L155da
	subi.w	#$d8,d0
	mulu.w	#$14,d0
	move.w	#$140,d1
	sub.w	d0,d1
	move.w	d1,d0
	move.w	#$c4,d1
	jsr	Ld66e
	rts


L155da
	clr.w	L155e2
	rts


L155e2
	dc.w	$0000


L155e4
	move.l	Le536,L1337a
	move.l	#$23f0,L13382
	move.w	#$170,L1337e
	move.w	#$c8,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$170,L1338a
	move.w	#$c8,L1338c
	move.w	L156b8,d0
	mulu.w	#$820,d0
	addi.l	#$72952,d0
	move.l	d0,L1338e
	move.w	L156bc,L13396
	move.w	#$8e,L13398
	move.w	#$40,L1339a
	move.w	#$34,L1339c
	move.l	#$1a0,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	move.l	L156b8,d1
	addi.l	#$6000,L156b8
	swap	d1
	cmp.w	L156b8,d1
	beq.s	L156a4
	asl.w	#1,d1
	movea.l	#$156be,a0
	move.w	(a0,d1.w),d0
	sub.w	d0,L156bc
L156a4
	cmpi.l	#$60000,L156b8
	bne.s	L156b6
	clr.l	L156b8
L156b6
	rts


L156b8
	dc.w	$0000,$0000
L156bc
	dc.w	$021c,$fffe,$0006,$0002,$0002,$0006,$0002


L156ca
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$2,$dff066
	move.l	Le536,d0
	addq.l	#2,d0
	move.l	d0,$dff054
	move.w	#$fa16,$dff058
	rts


L15704
	movea.l	#$7250a,a5
	moveq	#$3f,d7
L1570c
	subq.w	#1,$80(a5)
	bne.s	L15724
	move.w	#$23f0,d1
	jsr	L1ad48
	move.w	d0,(a5)
	move.w	#$40,$80(a5)
L15724
	movea.l	Le536,a1
	adda.w	(a5),a1
	move.b	#$4,d0
	move.b	$81(a5),d2
	andi.b	#$1f,d2
	lsr.b	#1,d2
	bcc.s	L1573e
	move.b	d0,(a1)
L1573e
	lsr.b	#1,d2
	bcc.s	L15746
	move.b	d0,$23f0(a1)
L15746
	lsr.b	#1,d2
	bcc.s	L1574e
	move.b	d0,$47e0(a1)
L1574e
	lsr.b	#1,d2
	bcc.s	L15756
	move.b	d0,$6bd0(a1)
L15756
	lsr.b	#1,d2
	bcc.s	L15764
	move.l	#$8fc0,d1
	move.b	d0,(a1,d1.l)
L15764
	addq.l	#2,a5
	dbra	d7,L1570c
	rts


L1576c
	move.l	#$6736e,L133a6
	move.w	#$30,$dff09a
	moveq	#$3,d0
	jsr	L430
	movea.l	#$6dc92,a0
	movea.l	#$68626,a1
	movea.l	#$76a00,a2
	jsr	decompress
	clr.w	L138de
	clr.w	Le534
	clr.w	L15aac
	movea.l	#$f4be,a0
	moveq	#$1f,d0
L157b8
	clr.w	(a0)
	addq.l	#4,a0
	dbra	d0,L157b8
	moveq	#$3b,d0
	movea.l	#$672a6,a0
L157c8
	clr.w	(a0)+
	dbra	d0,L157c8
	move.w	#$20,Leac6
	move.l	#$15e08,Leabe
	move.l	#$f4be,Leac2
	move.l	#$f0000,Leaba
	move.l	#$10000,Leac8
	move.w	#$64,L15d6c
	move.l	#$11edb,L15c12
	move.w	#$1e,L15c16
	move.l	#$f430,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	move.l	#$f456,Le53e
	move.l	#$e128,$6c
	move.w	#$8030,$dff09a
	move.w	#$1,Le0ec
	clr.w	L9fd8
	tst.w	L161d0
	beq	L15868
L15868
	nop
	nop
	nop
	nop
	nop
	nop
L15874
	rts


L15876
	jsr	Lea1a
	jsr	L1656
	jsr	L15ae0
	jsr	Leace
	jsr	L15eec
	jsr	L15b3c
	jsr	L15c18
	jsr	L15d6e
	tst.w	L15aac
	beq.s	L158c8
	addq.w	#1,L15aac
	cmpi.w	#$12,L15aac
	bcc	L15aae
	tst.w	L15aac
	bne.s	L15876
L158c8
	move.b	$bfec01,d0
	cmpi.b	#$76,d0
	beq.s	L15876
	move.b	d0,L15988
L158da
	cmpi.b	#$5f,d0
	beq	L1598a
	cmpi.b	#$5c,d0
	beq	L159ba
	cmpi.b	#$5b,d0
	beq	L159f0
	cmpi.b	#$59,d0
	beq	L15a1e
	cmpi.b	#-$4d,d0
	beq	L1595a
	cmpi.b	#-$4f,d0
	beq	L15966
	cmpi.b	#-$45,d0
	beq	L15972
	cmpi.b	#-$6d,d0
	beq	L1597e
	cmpi.b	#-$3,d0
	beq	L15936
	cmpi.b	#-$5,d0
	beq	L15942
	cmpi.b	#-$7,d0
	beq	L1594e
	bra	L15876


L15936
	move.w	#$0,Le0ec
	bra	L15876


L15942
	move.w	#$1,Le0ec
	bra	L15876


L1594e
	move.w	#$2,Le0ec
	bra	L15876


L1595a
	move.w	#$0,L95bc
	bra	L15876


L15966
	move.w	#$1,L95bc
	bra	L15876


L15972
	move.w	#$1,L76f0
	bra	L15876


L1597e
	clr.w	L76f0
	bra	L15876


L15988
	dc.w	$0000


L1598a
	move.w	#$1,L7266
	move.w	#$0,L74b6
	clr.w	L9fd4
	clr.w	L9fd6
	move.w	#$0,L103ea
	move.w	#$2,L74b4
	bra	L15a4e


L159ba
	move.w	#$1,L7266
	move.w	#$1,L74b6
	clr.w	L9fd4
	clr.w	L9fd6
	move.w	#$1,L103ea
	move.w	#$50,L74b4
	move.w	#$ffff,L9fd8
	bra.s	L15a4e


L159f0
	move.w	#$1,L7266
	move.w	#$1,L74b6
	clr.w	L9fd4
	clr.w	L9fd6
	move.w	#$1,L103ea
	move.w	#$50,L74b4
	bra.s	L15a4e


L15a1e
	clr.w	L76f0
	move.w	#$1,L7266
	move.w	#$1,L74b6
	st	L9fd4
	st	L9fd6
	move.w	#$3,L103ea
	clr.w	L74b4
L15a4e
	cmpi.w	#$6666,L15aac
	beq	L15874
	move.w	#$3b,Leac6
	move.l	#$672a6,Leabe
	move.l	#$f4be,Leac2
	move.l	#$f0000,Leaba
	move.l	#$10000,Leac8
	move.w	#$1,L15aac
	movea.l	#$f1dd,a0
	adda.l	#$d0f,a0
	IFND	PROTECTION_DISABLED
	cmpi.l	#$c796263,(a0)
L15aa4	bne	L15bda
	ELSE
	nop
	nop
	nop
	nop
	nop
	ENDC
	bra	L15876


L15aac
	dc.w	$0000


L15aae
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$30,$dff09a
	clr.l	Leac8
	moveq	#$9,d0
	jsr	L430
	rts


	dc.w	$0000,$08a0


L15ae0
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	#$68626,$dff050
	move.l	Le536,$dff054
	move.w	#$962c,$dff058
	rts


	dc.w	$0000,$000e,$0009,$0005,$000f,$0000,$0000,$0001,$0001,$0000


L15b3c
	moveq	#$4,d7
L15b3e
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$160,L1338a
	move.w	#$f0,L1338c
	move.w	#$10,L1339a
	move.w	#$2,L1339c
	move.l	#$4,L1339e
	move.w	#$1,L133a4
	move.l	#$769ec,L1338e
	move.w	d7,d0
	mulu.w	#$7,d0
	addi.w	#$f6,d0
	move.w	d0,L13396
	move.w	#$ce,L13398
	movea.l	#$15b28,a0
	move.w	d7,d0
	add.b	d0,d0
	moveq	#$1,d1
	tst.w	$a(a0,d0.w)
	beq.s	L15bda
	neg.w	d1
L15bda
	add.w	d1,(a0,d0.w)
	move.w	(a0,d0.w),d1
	cmpi.w	#$12,d1
	bne.s	L15bee
	eori.w	#$1,$a(a0,d0.w)
L15bee
	tst.w	d1
	bne.s	L15bf8
	eori.w	#$1,$a(a0,d0.w)
L15bf8
	move.w	(a0,d0.w),d0
	add.w	d0,L13398
	move.w	d7,-(a7)
	jsr	L133b4
	move.w	(a7)+,d7
	dbra	d7,L15b3e
	rts


L15c12
	dc.w	$0000,$0000
L15c16
	dc.w	$0000


L15c18
	tst.w	L95bc
	beq.s	L15c32
	move.b	#$4,L120f5
	move.b	#$2,L120f0
	bra.s	L15c42


L15c32
	move.b	#$2,L120f5
	move.b	#$4,L120f0
L15c42
	movea.l	Le536,a0
	movea.l	#$120ed,a1
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	movea.l	Le536,a0
	adda.l	#$20d4,a0
	movea.l	L15c12,a1
	move.w	#$f6,d0
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	move.w	Le126,d0
	sub.w	d0,L15c16
	tst.w	L15c16
	bpl.s	L15ca2
	move.w	#$14,L15c16
	move.l	a1,L15c12
L15ca2
	movea.l	L15c12,a1
	cmpi.b	#-$1,(a1)
	bne.s	L15cb8
	move.l	#$11edb,L15c12
L15cb8
	move.w	Le0ec,d0
	addi.b	#$31,d0
	move.b	d0,L120c8
	subi.b	#$31,d0
	lsl.w	#3,d0
	addi.l	#$120d5,d0
	movea.l	d0,a0
	moveq	#$7,d0
	movea.l	#$120cc,a1
	jsr	L4e6c
	movea.l	Le536,a0
	movea.l	#$120ac,a1
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	move.w	L76f0,d0
	lsl.w	#3,d0
	addi.l	#$12105,d0
	movea.l	d0,a0
	moveq	#$7,d0
	movea.l	#$120fc,a1
	jsr	L4e6c
	movea.l	Le536,a0
	movea.l	#$12115,a1
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	movea.l	Le536,a0
	movea.l	#$12122,a1
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	movea.l	Le536,a0
	movea.l	#$120f8,a1
	moveq	#$2c,d1
	move.l	#$2940,d3
	jsr	L137ce
	rts


L15d6c
	dc.w	$008c


L15d6e
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	move.w	#$0,L13386
	move.w	#$1a,L13388
	move.w	#$160,L1338a
	move.w	#$1d,L1338c
	move.w	#$130,L1339a
	move.w	#$1d,L1339c
	move.l	#$44e,L1339e
	move.w	#$1,L133a4
	move.l	#$75466,L1338e
	move.w	#$19,L13396
	move.w	L15d6c,L13398
	cmpi.w	#$1a,L15d6c
	beq.s	L15e00
	subq.w	#2,L15d6c
L15e00
	jsr	L133b4
	rts


	dc.w	$0000,$0fdc,$0dba,$0b98,$0976,$0754,$0aaa,$0f09,$0642,$0532,$0420,$0700,$0b10,$0e10,$0f50,$0f80
	dc.w	$0fc2,$0777,$0555,$0180,$0160,$0040,$0227,$0448,$0569,$088b,$0888,$0666,$0444,$0333,$0222,$0111
	dc.w	$0700,$0800,$0800,$0900,$0900,$0a00,$0a00,$0b00,$0c00,$0c00,$0d00,$0d00,$0e00,$0e00,$0f11,$0f21
	dc.w	$0f41,$0f51,$0f61,$0f71,$0f82,$0f92,$0fa2,$0fb2,$0fd2,$0fe2,$0ff2,$0040,$0050,$0060,$0060,$0070
	dc.w	$0081,$0092,$0093,$00a3,$00b4,$00c4,$00d5,$00d6,$00e7,$00f8,$01f9,$03f9,$04fa,$05fa,$06fb,$08fc
	dc.w	$09fc,$0afd,$0bfd,$0dfe,$0efe,$0fff,$0007,$0008,$0018,$0019,$0019,$002a,$002a,$003b,$004c,$004c
	dc.w	$005d,$005d,$006e,$007e,$008f,$019f,$039f,$04af,$05af,$06bf,$08bf,$09cf,$0adf,$0bdf,$0cef,$0def
	dc.w	$0fff
L15eea
	dc.w	$0000


L15eec
	move.w	Lf4f2,Lf632
	tst.w	L15aac
	bne.s	L15f6e
	tst.l	Leaba
	bne.s	L15f6e
	addq.w	#1,L15eea
	cmpi.w	#$3,L15eea
	bne.s	L15f1c
	clr.w	L15eea
L15f1c
	move.w	#$1b,Leac6
	move.w	L15eea,d0
	mulu.w	#$36,d0
	ext.l	d0
	addi.l	#$15e48,d0
	move.l	d0,Leabe
	move.l	#$f53e,Leac2
	move.l	#$f0000,Leaba
	cmpi.l	#$15eb4,d0
	bne	L15f64
	move.l	#$c0000,Leaba
L15f64
	move.l	#$10000,Leac8
L15f6e
	rts


L15f70
	IFD	NO_SHIP_ANIMATIONS
	dc.w	0
	ELSE
	dc.w	1		1 = show animation
	ENDC


L15f72
	clr.w	L15f70
	move.l	#$798ba,L133a6
	moveq	#$1b,d0
	jsr	L430
	movea.l	#$40088,a0
	movea.l	#$35000,a1
	movea.l	#$4d418,a2
	jsr	decompress
	move.l	#$671f,d0
	movea.l	#$5fc3a,a0
L15fae
	clr.l	(a0)+
	dbra	d0,L15fae
	movea.l	#$41e40,a0
	movea.l	#$1663a,a1
	moveq	#$1f,d0
L15fc2
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,L15fc2
	move.w	#$30,$dff09a
	jsr	Lff1e
	move.l	#$165d2,Le53e
	jsr	Le848
	move.l	#$165ac,Lfcf8
	jsr	Lfcfc
	move.l	#$e128,$6c
	move.w	#$8030,$dff09a
	jsr	Lfef8
	jsr	Lff1e
	move.w	#$a0,L1547a
	moveq	#$1d,d0
	jsr	L430
	movea.l	Lc6a,a0
	movea.l	#$1c764,a1
	movea.l	#$1d408,a2
	jsr	decompress
	jsr	L1ad12
	moveq	#$21,d0
	jsr	L1ad18
	rts


L1604e
	jsr	Lea64
	jsr	L1656
	jsr	L160de
	jsr	L16128
	subq.w	#1,L1547a
	bpl.s	L1604e
	jsr	L1ad2a
	moveq	#$c,d0
	jsr	L430
	movea.l	#$506b8,a0
	movea.l	#$50000,a1
	movea.l	#$5898c,a2
	jsr	decompress
	move.l	Le536,$50000
	jsr	$50004
	jsr	Lff0c
	move.w	#$30,$dff09a
	moveq	#$0,d0
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	rts


	dc.w	$0000,$08a0


L160de
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	#$35000,$dff050
	move.l	Le536,$dff054
	move.w	#$962c,$dff058
	rts


L16126
	dc.w	$0000


L16128
	addq.w	#1,L16126
	cmpi.w	#$c,L16126
	bne.s	L1613e
	clr.w	L16126
L1613e
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	clr.w	L13386
	clr.w	L13388
	move.w	#$160,L1338a
	move.w	#$f0,L1338c
	move.w	#$30,L1339a
	move.w	#$7f,L1339c
	move.l	#$2fa,L1339e
	move.w	#$1,L133a4
	move.l	#$41e80,L1338e
	move.w	L16126,d0
	mulu.w	#$f22,d0
	add.l	d0,L1338e
	clr.w	L13396
	move.w	#$10,L13398
	jsr	L133b4
	rts


L161d0
	IFD	NO_SHIP_ANIMATIONS
	dc.w	0
	ELSE
	dc.w	1		1 = show animation
	ENDC


L161d2
	clr.w	L161d0
	move.l	#$798ba,L133a6
	moveq	#$a,d0
	jsr	L430
	movea.l	#$2ed1c,a0
	movea.l	#$20400,a1
	movea.l	#$52dfa,a2
	jsr	decompress
	movea.l	#$5771a,a0
	movea.l	#$52dfa,a1
	movea.l	#$5fc3a,a2
	jsr	decompress
	move.l	#$671f,d0
	movea.l	#$5fc3a,a0
L16226
	clr.l	(a0)+
	dbra	d0,L16226
	movea.l	#$22a52,a0
	movea.l	#$1663a,a1
	moveq	#$1f,d0
L1623a
	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d0,L1623a
	move.w	#$30,$dff09a
	jsr	Lff1e
	move.l	#$165d2,Le53e
	jsr	Le848
	move.l	#$165ac,Lfcf8
	jsr	Lfcfc
	move.l	#$e128,$6c
	move.w	#$8030,$dff09a
	jsr	Lfef8
	jsr	Lff1e
	move.w	#$474,L1547a
	moveq	#$1c,d0
	jsr	L430
	movea.l	Lc6a,a0
	movea.l	#$1c764,a1
	movea.l	#$1c956,a2
	jsr	decompress
	rts


L162b8
	jsr	Lea64
	jsr	L1656
	jsr	L16336
	jsr	L1647a
	jsr	L163b0
	cmpi.w	#$1b,L16478
	bne	L162b8
	subq.w	#1,L1547a
	bpl.s	L162b8
	move.w	#$f,$dff096
	moveq	#$c,d0
	jsr	L430
	movea.l	#$506b8,a0
	movea.l	#$50000,a1
	movea.l	#$5898c,a2
	jsr	decompress
	move.l	Le536,$50000
	jsr	$50004
	jsr	Lff0c
	move.w	#$30,$dff09a
	rts


	dc.w	$0000,$08a0


L16336
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	#$52dfa,$dff050
	move.l	Le536,$dff054
	move.w	#$962c,$dff058
	rts


L1637e
	dc.w	$0014
L16380
	dc.w	$0000,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0004,$0001,$0001,$0001
	dc.w	$0001,$0001,$0005,$0001,$0001,$0000
L163ac
	dc.w	$0001,$6382


L163b0
	movea.l	L163ac,a0
	tst.w	(a0)
	beq	L16474
	subq.w	#1,L1637e
	bpl.s	L163e2
	movea.l	L163ac,a0
	tst.w	(a0)+
	beq	L163e2
	move.l	a0,L163ac
	move.w	(a0),L1637e
	addq.w	#1,L16380
L163e2
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	clr.w	L13386
	clr.w	L13388
	move.w	#$160,L1338a
	move.w	#$f0,L1338c
	move.w	#$90,L1339a
	move.w	#$6d,L1339c
	move.l	#$7aa,L1339e
	move.w	#$1,L133a4
	move.l	#$20400,L1338e
	move.w	L16380,d0
	mulu.w	#$2692,d0
	add.l	d0,L1338e
	move.w	#$24,L13396
	move.w	#$38,L13398
	jsr	L133b4
L16474
	rts


L16476
	dc.w	$0000
L16478
	dc.w	$fe9a


L1647a
	movea.l	L163ac,a0
	tst.w	(a0)
	bne	L165a8
	cmpi.w	#$2,L16476
	beq	L164ee
	addq.w	#1,L16476
	cmpi.w	#$2,L16476
	bne	L165a8
	moveq	#$b,d0
	jsr	L430
	movea.l	#$216bc,a0
	movea.l	#$20400,a1
	movea.l	#$25b80,a2
	jsr	decompress
	lea	$dff000,a6
	movea.l	#$1c764,a0
	move.w	#$f9,d0
	move.l	a0,$a0(a6)
	move.w	d0,$a4(a6)
	move.w	#$40,$a8(a6)
	move.w	#$5dc,$a6(a6)
	move.w	#$8201,$96(a6)
L164ee
	move.l	Le536,L1337a
	move.l	#$2940,L13382
	move.w	#$160,L1337e
	move.w	#$f0,L13380
	move.w	#$0,L13386
	move.w	#$0,L13388
	move.w	#$160,L1338a
	move.w	#$f0,L1338c
	move.w	#$140,L1339a
	move.w	#$70,L1339c
	move.l	#$1180,L1339e
	move.w	#$1,L133a4
	move.l	#$20400,L1338e
	move.w	L16478,L13396
	cmpi.w	#$1b,L16478
	beq	L1657c
	addq.w	#5,L16478
	bra.s	L1659a


L1657c
	jsr	L1ad2a
	tst.w	L165aa
	bne	L1659a
	move.w	#$2,L1547a
	st	L165aa
L1659a
	move.w	#$38,L13398
	jsr	L133b4
L165a8
	rts


L165aa
	dc.w	$0000,$0100,$5200,$0104,$0000,$008e,$1671,$0090,$06d1,$0092,$0030,$0094,$00d8,$0102,$0000,$0108
	dc.w	$0000,$010a,$0000,$00e0,$0005,$00e2,$0000,$00e4,$0005,$00e6,$2940,$00e8,$0005,$00ea,$5280,$00ec
	dc.w	$0005,$00ee,$7bc0,$00f0,$0005,$00f2,$a500,$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000,$0128
	dc.w	$0000,$012a,$0000,$012c,$0000,$012e,$0000,$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000,$0138
	dc.w	$0000,$013a,$0000,$013c,$0000,$013e,$0000,$0180,$0000,$0182,$0fff,$0184,$0f00,$0186,$0fde,$0188
	dc.w	$0fbc,$018a,$0fac,$018c,$0f9b,$018e,$0e7a,$0190,$0d59,$0192,$0c18,$0194,$0a18,$0196,$0808,$0198
	dc.w	$0606,$019a,$0505,$019c,$0404,$019e,$0303,$01a0,$05ac,$01a2,$038a,$01a4,$0068,$01a6,$0057,$01a8
	dc.w	$0597,$01aa,$07bb,$01ac,$0acc,$01ae,$0ed7,$01b0,$0ff6,$01b2,$0fb6,$01b4,$0f86,$01b6,$0445,$01b8
	dc.w	$0334,$01ba,$0eee,$01bc,$0f83,$01be,$0f83,$e001,$ff00,$009c,$8010,$ffff,$fffe
L166c4
	dc.w	$0000,$37d0


	dc.b	'0000000000000000001000000000250000000050000000007000000000750000'
	dc.b	'0001000000000150000000020000000002500000000400000000050000000008'
	dc.b	'0000000015000000002500'


L1675e
	moveq	#$9,d0
L16760
	move.b	(a1,d0.w),d1
	add.b	(a0,d0.w),d1
	subi.b	#$30,d1
	cmpi.b	#$3a,d1
	bcs.s	L1677a
	subi.b	#$a,d1
	addq.b	#1,-$1(a1,d0.w)
L1677a
	move.b	d1,(a1,d0.w)
	dbra	d0,L16760
	rts


L16784
	clr.w	Le534
	tst.w	L1698
	bne	L167dc
	moveq	#$0,d0
	movea.l	#$37d0,a0
	cmpi.l	#$30303030,(a0)
	bne.s	L167dc
	cmpi.l	#$30303030,$4(a0)
	bne.s	L167dc
	cmpi.w	#$3030,$8(a0)
	bne.s	L167dc
	movea.l	#$37dc,a0
	cmpi.l	#$30303030,(a0)
	bne.s	L167dc
	cmpi.l	#$30303030,$4(a0)
	bne.s	L167dc
	cmpi.w	#$3030,$8(a0)
	bne	L167dc
	moveq	#$1,d0
	rts


L167dc
	move.l	#$448ca,L133a6
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$30,$dff09a
	tst.w	L1698
	bne.s	L16838
	moveq	#$2,d0
	jsr	L430
	movea.l	#$4d602,a0
	movea.l	#$44cb2,a1
	movea.l	#$4f73a,a2
	jsr	decompress
	movea.l	#$44cb2,a0
	jsr	L1ad00
L16838
	moveq	#$1,d0
	jsr	L430
	movea.l	#$6a870,a0
	movea.l	#$62690,a1
	movea.l	#$76a00,a2
	jsr	decompress
	move.w	#$8400,$dff096
	move.w	#$4fc,d0
	movea.l	#$f7fc,a0
	movea.l	#$616ea,a1
	movea.l	#$61c62,a2
L16876
	move.b	(a0)+,(a1)+
	clr.b	(a2)+
	dbra	d0,L16876
	move.w	#$ffff,L1751a
	move.w	#$1,L138de
	jsr	Ld644
	clr.w	Le534
	clr.w	L15aac
	move.l	#$e1c4,$6c
	move.l	#$616ea,Lfcf8
	jsr	Lfcfc
	move.l	#$618f4,Le53e
	move.l	#$61710,Le542
	jsr	Le7f6
	move.w	#$3,L17514
	move.w	#$1,L175ec
	jsr	L16c16
	jsr	L16f18
	clr.w	L1732c
	move.w	#$3a,L177b4
	clr.w	L177b6
	clr.b	Lfde4
	jsr	L16c5c
	jsr	L16d18
	move.w	#$8030,$dff09a
	jsr	Lfef8
	jsr	Lff1e
	rts


	dc.w	$0000,$08a0
L16930
	dc.w	$0000


L16932
	jsr	Lea3e
	tst.w	L1751a
	bpl.s	L16946
	jsr	L1656
L16946
	jsr	L16be0
	jsr	L175ee
	jsr	L176c8
	jsr	L16df8
	tst.b	L1732a
	beq	L16974
	sf	L1732a
	jsr	L16f96
L16974
	tst.b	L1732b
	beq	L1698a
	sf	L1732b
	jsr	L16f18
L1698a
	tst.w	L1698
	beq.s	L169b4
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L169a0
	bra.s	L169a6


L169a0
	btst	#$6,d0
	bne.s	L169b4
L169a6
	addq.l	#4,a7
	jsr	L1ad06
	jmp	Le10


L169b4
	tst.w	L1698
	bne	L16aac
	cmpi.w	#-$1,L1751a
	bne	L16aac
	cmpi.w	#$21,L17514
	beq	L16aac
	movea.l	#$37d0,a0
	cmpi.l	#$67616d65,(a0)
	beq.s	L16a4a
	cmpi.l	#$30303030,(a0)
	bne.s	L16a00
	cmpi.l	#$30303030,$4(a0)
	bne.s	L16a00
	cmpi.w	#$3030,$8(a0)
	beq	L16a4a
L16a00
	jsr	L17520
	move.l	a2,L1750c
	move.l	#$67616d65,L37d0
	cmpa.l	#$0,a2
	beq.s	L16a4a
	movea.l	#$17276,a0
	cmpi.w	#$3,L103ea
	bne.s	L16a34
	movea.l	#$17306,a0
L16a34
	movea.l	#$17251,a1
	moveq	#$23,d0
	jsr	L4e6c
	jsr	L16f18
	bra.s	L16aac


L16a4a
	movea.l	#$37dc,a0
	cmpi.l	#$67616d65,(a0)
	beq.s	L16aac
	cmpi.l	#$30303030,(a0)
	bne.s	L16a74
	cmpi.l	#$30303030,$4(a0)
	bne.s	L16a74
	cmpi.w	#$3030,$8(a0)
	beq	L16aac
L16a74
	jsr	L17520
	move.l	a2,L17510
	cmpa.l	#$0,a2
	beq.s	L16aac
	movea.l	#$1729a,a0
	movea.l	#$17251,a1
	moveq	#$23,d0
	jsr	L4e6c
	jsr	L16f18
	move.l	#$67616d65,L37dc
L16aac
	subq.w	#1,L16930
	tst.w	L16930
	bpl.s	L16ade
	move.w	#$5,L16930
	moveq	#$7a,d1
	jsr	L1ad48
	move.w	d0,d2
	move.w	#$160,d1
	jsr	L1ad48
	move.w	d2,d1
	jsr	L16dc2
L16ade
	tst.w	L1751a
	bpl	L16932
	addq.w	#1,L15aac
	cmpi.w	#$9c,L15aac
	beq.s	L16b38
	cmpi.w	#$94,L15aac
	bne	L16932
	move.w	#$ae,Leac6
	move.l	#$61c62,Leabe
	move.l	#$616ec,Leac2
	move.l	#$f0000,Leaba
	move.l	#$8000,Leac8
	bra	L16932


L16b38
	clr.w	L138de
	jsr	Lff0c
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$30,$dff09a
	tst.w	L1698
	bne.s	L16b78
	jsr	L1ad06
	IFD	DISK_ACCESS_DISABLED
	nop
	nop
	nop
	ELSE
	jsr	L1ad3c		save high scores
	ENDC
	move.w	#$100,Lcae
L16b78
	clr.l	Leac8
	jsr	Ld644
	clr.w	Le534
	tst.w	L1698
	bne.s	L16bde
	move.b	$bfe001,d0
	btst	#$7,d0
	bne.s	L16ba0
	bra.s	L16ba6


L16ba0
	btst	#$6,d0
	bne.s	L16bde
L16ba6
	jsr	L1ad06
	move.l	#$ecf0,Lfcf8
	jsr	Lfcfc
	move.w	#$0,$dff180
	move.b	L15988,d0
	move.w	#$6666,L15aac
	jsr	L158da
	jmp	Le74


L16bde
	rts


L16be0
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$0,$dff066
	move.l	Le536,$dff054
	move.w	#$1e96,$dff058
	rts


L16c16
	jsr	Leaae
	move.l	#$0,$dff044
	move.l	#$1000000,$dff040
	move.w	#$0,$dff066
	move.l	#$4f73a,$dff054
	move.w	#$b42c,$dff058
	rts


	dc.w	$0000,$08a0
L16c50
	dc.w	$0000
L16c52
	dc.w	$0000
L16c54
	dc.w	$0000
L16c56
	dc.w	$0000
L16c58
	dc.w	$0000
L16c5a
	dc.w	$0000


L16c5c
	move.l	#$62690,d0
	move.w	L16c52,d1
	mulu.w	#$54,d1
	ext.l	d1
	add.l	d1,d0
	move.w	L16c50,d1
	ext.l	d1
	add.l	d1,d0
	movea.l	#$618dc,a0
	move.w	d0,$4(a0)
	swap	d0
	move.w	d0,(a0)
	swap	d0
	addq.l	#8,a0
	addi.l	#$5010,d0
	move.w	d0,$4(a0)
	swap	d0
	move.w	d0,(a0)
	tst.w	L16c54
	beq.s	L16cfe
	cmpi.w	#$1,L16c54
	beq.s	L16ccc
	cmpi.w	#$2,L16c54
	beq.s	L16ce6
	subq.w	#2,L16c50
	tst.w	L16c50
	bne.s	L16d16
	clr.w	L16c54
	rts


L16ccc
	addq.w	#2,L16c50
	cmpi.w	#$2a,L16c50
	bne.s	L16d16
	move.w	#$2,L16c54
	rts


L16ce6
	subq.w	#1,L16c52
	tst.w	L16c52
	bne.s	L16d16
	move.w	#$3,L16c54
	rts


L16cfe
	addq.w	#1,L16c52
	cmpi.w	#$50,L16c52
	bne.s	L16d16
	move.w	#$1,L16c54
L16d16
	rts


L16d18
	move.l	#$6a9d0,d0
	move.w	L16c58,d1
	mulu.w	#$54,d1
	ext.l	d1
	add.l	d1,d0
	move.w	L16c56,d1
	ext.l	d1
	add.l	d1,d0
	movea.l	#$618ec,a0
	move.w	d0,$4(a0)
	swap	d0
	move.w	d0,(a0)
	tst.w	L16c5a
	beq.s	L16da8
	cmpi.w	#$1,L16c5a
	beq.s	L16d76
	cmpi.w	#$2,L16c5a
	beq.s	L16d90
	subq.w	#2,L16c56
	tst.w	L16c56
	bne.s	L16dc0
	clr.w	L16c5a
	rts


L16d76
	addq.w	#2,L16c56
	cmpi.w	#$2a,L16c56
	bne.s	L16dc0
	move.w	#$2,L16c5a
	rts


L16d90
	subq.w	#2,L16c58
	tst.w	L16c58
	bne.s	L16dc0
	move.w	#$3,L16c5a
	rts


L16da8
	addq.w	#2,L16c58
	cmpi.w	#$50,L16c58
	bne.s	L16dc0
	move.w	#$1,L16c5a
L16dc0
	rts


L16dc2
	movea.l	#$d502,a0
	addq.w	#2,Ld642
	andi.w	#$3f,Ld642
	move.w	Ld642,d3
	adda.w	d3,a0
	andi.w	#$fffe,d0
	st	(a0)
	move.w	d0,$40(a0)
	move.w	d1,$80(a0)
	move.w	#$52,$c0(a0)
	move.w	d2,$100(a0)
	rts


L16df8
	movea.l	Le536,a1
	movea.l	#$1017a,a3
	move.w	Le126,d3
	moveq	#$1f,d7
	movea.l	#$d502,a0
L16e12
	tst.w	(a0)
	beq	L16ece
	move.w	$40(a0),d4
	move.w	$80(a0),d5
	move.w	#$54,d6
	sub.w	$c0(a0),d6
	tst.w	d4
	bpl.s	L16e30
	addi.w	#$800,d4
L16e30
	sub.w	d6,d5
	jsr	L16eda
	sub.w	d6,d5
	jsr	L16eda
	add.w	d6,d4
	add.w	d6,d4
	jsr	L16eda
	sub.w	d6,d4
	add.w	d6,d5
	jsr	L16eda
	add.w	d6,d5
	jsr	L16eda
	add.w	d6,d4
	jsr	L16eda
	add.w	d6,d5
	add.w	d6,d5
	jsr	L16eda
	sub.w	d6,d4
	sub.w	d6,d5
	jsr	L16eda
	sub.w	d6,d4
	jsr	L16eda
	add.w	d6,d5
	jsr	L16eda
	sub.w	d6,d4
	sub.w	d6,d4
	jsr	L16eda
	sub.w	d6,d5
	add.w	d6,d4
	jsr	L16eda
	sub.w	d6,d5
	jsr	L16eda
	sub.w	d6,d4
	jsr	L16eda
	sub.w	d6,d5
	sub.w	d6,d5
	jsr	L16eda
	add.w	d6,d4
	add.w	d6,d5
	jsr	L16eda
	subq.w	#2,$c0(a0)
	move.w	$c0(a0),(a0)
	tst.w	(a0)
	bpl.s	L16ece
	clr.w	(a0)
L16ece
	addq.l	#2,a0
	dbra	d7,L16e12
	rts


	dc.w	$0000,$08a0


L16eda
	andi.w	#$7ff,d4
	cmpi.w	#$160,d4
	bcc.s	L16f16
	cmpi.w	#$79,d5
	bcc.s	L16f16
	movea.l	a1,a2
	clr.l	d0
	move.w	d5,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	adda.w	d0,a2
	move.w	d4,d0
	move.w	d0,d1
	lsr.w	#3,d0
	adda.w	d0,a2
	andi.w	#$7,d1
	eori.b	#$7,d1
	move.w	$100(a0),d2
	clr.b	d0
	bset	d1,d0
	addq.b	#1,d1
	bset	d1,d0
	move.b	d0,(a2)
L16f16
	rts


L16f18
	movea.l	#$5212a,a0
	movea.l	#$17054,a1
	moveq	#$2c,d1
	jsr	L137ce
	movea.l	#$5212a,a0
	movea.l	#$17109,a1
	moveq	#$2c,d1
	jsr	L137ce
	movea.l	#$53622,a0
	movea.l	#$171c2,a1
	moveq	#$2c,d1
	jsr	L137ce
	movea.l	#$53622,a0
	movea.l	#$17208,a1
	moveq	#$2c,d1
	jsr	L137ce
	movea.l	#$5212a,a0
	movea.l	#$1724e,a1
	moveq	#$2c,d1
	jsr	L137ce
	movea.l	#$5212a,a0
	movea.l	#$17010,a1
	moveq	#$2c,d1
	jsr	L137ce
	rts


	dc.w	$0000,$08a0


L16f96
	cmpi.w	#$21,L17514
	bne.s	L16fb6
	movea.l	#$5212a,a0
	movea.l	#$17010,a1
	moveq	#$2c,d1
	jsr	L137ce
	rts


L16fb6
	movea.l	L17516,a0
	move.w	(a0),L1751c
	move.b	$2(a0),L1751c+2
	moveq	#$f,d2
	move.l	#$1ad9,d1
	move.w	L175ec,d0
	cmpi.w	#$a,d0
	bcs.s	L16fec
	subi.w	#$a,d0
	addi.l	#$c,d1
	addi.w	#$22,d2
L16fec
	mulu.w	#$160,d0
	add.l	d0,d1
	movea.l	#$50c32,a0
	adda.l	d1,a0
	movea.l	#$1751c,a1
	moveq	#$2c,d1
	move.w	d2,d0
	jsr	L137ce
	rts


	dc.b	'SODA',$0d,'Y',$01,'t h e  i m m o r t a l : '
L1702c
	dc.b	'-'
L1702d
	dc.b	'-'
L1702e
	dc.b	'-',$0d,'L',$08,'---------------------------------',$00,$0d,'O!',$01,'--- 0000000000',$01,$0d,'O',$07,'--- '
	dc.b	'0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000'
	dc.b	$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 00'
	dc.b	'00000000',$01,$0d,'O',$07,'--- 0000000000',$00,$0d,$d1,'!--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d
	dc.b	$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000'
	dc.b	'000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07
	dc.b	'--- 0000000000',$00,$00,'SODA',$0d,'7! 1.',$01,$0d,'7',$07,' 2.',$01,$0d,'7',$07,' 3.',$01,$0d,'7',$07,' 4.',$01,$0d,'7',$07,' 5.',$01,$0d,'7',$07,' 6.',$01,$0d,'7'
	dc.b	$07,' 7.',$01,$0d,'7',$07,' 8.',$01,$0d,'7',$07,' 9.',$01,$0d,'7',$07,'10.',$00,$0d,$b9,'!11.',$01,$0d,$b9,$07,'12.',$01,$0d,$b9,$07,'13.',$01,$0d,$b9,$07,'14.',$01,$0d,$b9,$07,'15.',$01,$0d,$b9,$07
	dc.b	'16.',$01,$0d,$b9,$07,'17.',$01,$0d,$b9,$07,'18.',$01,$0d,$b9,$07,'19.',$01,$0d,$b9,$07,'20.',$00,$0d,'D',$18,'        t h e  m o r t a l s '
	dc.b	'       ',$00,'player 1, please enter your initialsplayer 2, please ent'
	dc.b	'er your initials        t h e  m o r t a l s                   a'
	dc.b	'nd winner text             please enter your team initials  '
L1732a
	dc.b	$00


L1732b
	dc.b	$00
L1732c
	dc.w	$0000


L1732e
	cmpi.w	#-$1,L1751a
	beq	L173d8
	addq.w	#1,L1732c
	cmpi.w	#$5dc,L1732c
	beq	L1746a
	move.w	#$92,L15aac
	move.b	Lfde4,d0
	cmpi.b	#$0,d0
	beq.s	L173a2
	clr.w	L1732c
	cmpi.b	#$d,d0
	beq	L1746a
	cmpi.b	#$a,d0
	beq.s	L173aa
	move.w	L17514,d0
	cmp.w	L1751a,d0
	beq.s	L173a2
	movea.l	L17516,a0
	move.w	L1751a,d0
	move.b	Lfde4,(a0,d0.w)
	addq.w	#1,L1751a
	st	L1732a
L173a2
	clr.b	Lfde4
	rts


L173aa
	tst.w	L1751a
	beq.s	L173d0
	subq.w	#1,L1751a
	movea.l	L17516,a0
	move.w	L1751a,d0
	move.b	#$2d,(a0,d0.w)
	st	L1732a
L173d0
	clr.b	Lfde4
	rts


L173d8
	cmpi.w	#$21,L17514
	bne.s	L1741e
	move.l	#$17032,L17516
	clr.w	L1751a
	movea.l	#$172e2,a0
	movea.l	#$17251,a1
	moveq	#$23,d0
	jsr	L4e6c
	st	L1732b
	move.w	#$2d2d,L1702c
	move.b	#$2d,L1702e
	rts


L1741e
	tst.l	L1750c
	beq.s	L17444
	move.l	L1750c,L17516
	subq.l	#4,L17516
	clr.l	L1750c
	clr.w	L1751a
	rts


L17444
	tst.l	L17510
	beq.s	L17468
	move.l	L17510,L17516
	subq.l	#4,L17516
	clr.l	L17510
	clr.w	L1751a
L17468
	rts


L1746a
	clr.w	L1732c
	tst.w	L175ec
	bne.s	L174a6
	cmpi.w	#$21,L17514
	beq.s	L174ae
	move.w	#$21,L17514
	movea.l	#$17058,a0
	move.b	(a0),L1702c
	move.b	$1(a0),L1702d
	move.b	$2(a0),L1702e
L174a6
	tst.w	L175ec
	beq.s	L174d0
L174ae
	move.w	#$3,L17514
	movea.l	#$172be,a0
	movea.l	#$17251,a1
	moveq	#$23,d0
	jsr	L4e6c
	st	L1732b
L174d0
	move.w	#$ffff,L1751a
	clr.b	Lfde4
	movea.l	L17516,a0
	cmpi.b	#$2a,(a0)
	bne.s	L174ee
	move.b	#$2d,(a0)
L174ee
	cmpi.b	#$2a,$1(a0)
	bne.s	L174fc
	move.b	#$2d,$1(a0)
L174fc
	cmpi.b	#$2a,$2(a0)
	bne.s	L1750a
	move.b	#$2d,$2(a0)
L1750a
	rts


L1750c
	dc.w	$0000,$0000
L17510
	dc.w	$0000,$0000
L17514
	dc.w	$0003
L17516
	dc.w	$0000,$0000
L1751a
	dc.w	$ffff


L1751c
	move.l	$2d00(a5),-(a6)
L17520
	moveq	#$13,d7
	movea.l	#$0,a2
	movea.l	#$171b2,a1
L1752e
	move.l	(a0),d0
	cmp.l	(a1),d0
	beq.s	L17538
	bcs.s	L17554
	bra.s	L1755e


L17538
	move.l	$4(a0),d0
	cmp.l	$4(a1),d0
	beq.s	L17546
	bcs.s	L17554
	bra.s	L1755e


L17546
	move.w	$8(a0),d0
	cmp.w	$8(a1),d0
	beq.s	L1755e
	bcs.s	L17554
	bra.s	L1755e


L17554
	cmpa.l	#$0,a2
	bne.s	L1756a
	rts


L1755e
	movea.l	a1,a2
	suba.l	#$12,a1
	dbra	d7,L1752e
L1756a
	move.w	#$13,L175ec
	movea.l	#$171b2,a1
L17578
	cmpa.l	a2,a1
	beq.s	L175ac
	move.b	-$16(a1),-$4(a1)
	move.b	-$15(a1),-$3(a1)
	move.b	-$14(a1),-$2(a1)
	move.l	-$12(a1),(a1)
	move.l	-$e(a1),$4(a1)
	move.w	-$a(a1),$8(a1)
	suba.l	#$12,a1
	subq.w	#1,L175ec
	bra.s	L17578


L175ac
	move.w	#$2a2a,-$4(a2)
	move.b	#$2a,-$2(a2)
	move.l	(a0),(a2)
	move.l	$4(a0),$4(a2)
	move.w	$8(a0),$8(a2)
	tst.w	L175ec
	bne.s	L175de
	movea.l	#$17032,a4
	moveq	#$20,d0
L175d6
	move.b	#$2d,(a4)+
	dbra	d0,L175d6
L175de
	nop
	nop
	nop
	nop
	nop
	nop
	rts


L175ec
	dc.w	$0001


L175ee
	jsr	Leaae
	move.l	#$ffffffff,$dff044
	move.l	#$9f00000,$dff040
	move.w	#$0,$dff066
	move.w	#$0,$dff064
	move.l	#$6eb70,$dff050
	move.l	Le53a,$dff054
	move.w	#$9396,$dff058
	rts


	dc.w	$fff8,$000e,$0024,$003a,$0050,$0066,$007c,$0092,$00a8,$00be,$00d4,$00ea,$0100,$0116,$012c,$0142
	dc.w	$fff8,$fff8,$fff8,$0142,$0142,$0142,$000e,$0024,$003a,$0050,$0066,$007c,$0092,$00a8,$00be,$00d4
	dc.w	$00ea,$0100,$0116,$012c,$0012,$0012,$0012,$0012,$0012,$0012,$0012,$0012,$0012,$0012,$0012,$0012
	dc.w	$0012,$0012,$0012,$0012,$0028,$003e,$0054,$0028,$003e,$0054,$0054,$0054,$0054,$0054,$0054,$0054
	dc.w	$0054,$0054,$0054,$0054,$0054,$0054,$0054,$0054
L176c6
	dc.w	$0000


L176c8
	tst.w	L177b4
	beq.s	L176dc
	subq.w	#1,L177b4
	addq.w	#2,L177b6
L176dc
	addq.w	#1,L176c6
	cmpi.w	#$e,L176c6
	bne.s	L176f2
	clr.w	L176c6
L176f2
	moveq	#$23,d7
	movea.l	#$17636,a0
L176fa
	movem.l	d7/a0,-(a7)
	move.l	Le53a,L1337a
	move.l	#$1448,L13382
	move.w	#$160,L1337e
	move.w	#$76,L13380
	clr.w	L13386
	move.w	L177b4,L13388
	move.w	#$160,L1338a
	move.w	L177b6,L1338c
	move.w	L176c6,d0
	add.w	d7,d0
L1774c
	cmpi.w	#$e,d0
	bcs.s	L17758
	subi.w	#$e,d0
	bra.s	L1774c


L17758
	mulu.w	#$1cc,d0
	addi.l	#$750d8,d0
	move.l	d0,L1338e
	move.w	d7,d0
	add.w	d0,d0
	move.w	(a0,d0.w),L13396
	move.w	$48(a0,d0.w),L13398
	subq.w	#1,L13398
	move.w	#$20,L1339a
	move.w	#$17,L1339c
	move.l	#$5c,L1339e
	move.w	#$1,L133a4
	jsr	L133b4
	movem.l	(a7)+,d7/a0
	dbra	d7,L176fa
	rts


L177b4
	dc.w	$003a
L177b6
	dc.w	$0000


L177b8
	move.w	$dff010,d0
	cmpi.b	#-$21,d0
	bne.s	L177b8
	move.w	#$ff,$dff09e
	clr.l	$0
	clr.l	$4
	move.l	$70000,(L95e).w
	move.l	$70004,(L962).w
	jsr	(L966).w
	bset	#$1,$bfe001
	move.l	#$50000,Lc6a
	move.w	#$19c,Lcb0
	nop
	nop
	nop
	nop
	nop
	nop
	moveq	#$0,d1
	movea.l	#$17918,a0
	movea.l	#$58e,a1
	move.w	#$9f,d0
L17824
	move.w	(a0)+,d1
	tst.l	(a1)+
	dbra	d0,L17824

	IFND	PROTECTION_DISABLED
	move.l	$73336,Lcea6
	ELSE
	nop
	nop
	nop
	nop
	nop
	ENDC

	moveq	#$1,d0
	btst	#$1,$dff01e
	IFD	DISK_ACCESS_DISABLED
	* Force load of data area 0, not 1
	* (Laec2 never exits if data area 1 was loaded, which is done if disk transfer hasn't finished, for some reason)
	nop
	ELSE
	beq.s	L1784e
	ENDC

	IFND	PROTECTION_DISABLED
	move.l	$73334,Lcea6
	ELSE
	move.l  #$fb,Lcea6
	ENDC

	moveq	#$0,d0
L1784e
	jsr	L430
	movea.l	#$71e98,a0
	movea.l	#$68708,a1
	movea.l	#$80000,a2
	jsr	decompress
	jsr	Laec2
	nop
	nop
	nop
	rts


	move.w	#$7fff,$dff09a
	jsr	Lff52
	move.w	#$9c3f,d0
	movea.l	#$50000,a0
L17892
	clr.b	(a0)+
	dbra	d0,L17892
	move.l	#$f0c8,Lfcf8
	jsr	Lfcfc
	jsr	Lfef8
	jsr	Lff1e
	movea.l	#$f196,a0
	movea.l	#$f112,a1
	moveq	#$1f,d0
L178c2
	move.w	(a0),(a1)
	addq.l	#4,a0
	addq.l	#4,a1
	dbra	d0,L178c2
	movea.l	#$50000,a0
	movea.l	#$178ea,a1
	moveq	#$28,d1
	move.l	#$1f40,d3
	jsr	L137ce
	stop	#$2000


	dc.w	$0d2f,$5f02


	dc.b	'fatal diskette error -',$03,' please reboot!',$00


	dc.b	$00

	dc.w	$0000
L17918	ds.w	3300
L192e0	ds.w	3344


L1ad00
	jmp	L1b654


L1ad06
	jmp	L1b6bc


decompress
;L1ad0c
	jmp	L1bcf6


L1ad12
	jmp	L1ad4e


L1ad18
	jmp	L1ae2a


	jmp	L1b55e


L1ad24
	jmp	L1b624


L1ad2a
	jmp	L1adfe


L1ad30
	dc.w	$0000
L1ad32
	dc.w	$0000,$0000


L1ad36
	jmp	L1c0e6


L1ad3c
	jmp	L1c150


L1ad42
	jmp	L1c64c


L1ad48
	jmp	L1c6ae


L1ad4e
	tst.w	L1ad30
	bne	L1adf4
	movea.l	#$1af4a,a0
	movea.l	#$1af66,a1
	movea.l	#$1af82,a2
	movea.l	#$1af9e,a3
	move.l	#$dff0a0,$0(a0)
	move.l	#$dff0b0,$0(a1)
	move.l	#$dff0c0,$0(a2)
	move.l	#$dff0d0,$0(a3)
	move.b	#$1,$7(a0)
	move.b	#$2,$7(a1)
	move.b	#$4,$7(a2)
	move.b	#$8,$7(a3)
	clr.l	$8(a0)
	clr.l	$8(a1)
	clr.l	$8(a2)
	clr.l	$8(a3)
	move.w	#$f,$dff096
	move.w	#$780,$dff09a
	move.w	#$1f4,d0
L1adcc
	dbra	d0,L1adcc
	move.w	#$780,$dff09c
	move.l	$70,L1adfa
	move.w	#$8780,$dff09a
	move.l	#L1b532,$70
L1adf4
	jmp	L1c2c0


L1adfa
	dc.w	$0000,$0000


L1adfe
	tst.w	L1ad30
	bne.s	L1ae28
	move.w	#$f,$dff096
	move.w	#$780,$dff09a
	move.w	#$780,$dff09c
	move.l	L1adfa,$70
L1ae28
	rts


L1ae2a
	tst.w	L1ad30
	bne.s	L1ae28
	move.w	d0,d1
	mulu.w	#$28,d1
	addi.l	#$1af41,d1
	moveq	#$0,d6
	move.b	$bfdc00,d6
	add.l	d6,d1
	movea.l	d1,a0
	tst.l	$24(a0)
	beq.s	L1ae68
	movea.l	#$1af4a,a1
	moveq	#$3,d7
L1ae58
	cmp.l	$8(a1),d0
	beq.s	L1aebc
	adda.l	#$1c,a1
	dbra	d7,L1ae58
L1ae68
	movea.l	#$1af4a,a1
	moveq	#$3,d7
L1ae70
	tst.l	$8(a1)
	beq.s	L1aebc
	adda.l	#$1c,a1
	dbra	d7,L1ae70
	moveq	#$0,d2
	moveq	#$0,d3
	movea.l	#$1af4a,a1
	moveq	#$3,d7
L1ae8c
	move.l	$10(a0),d1
	cmp.l	$c(a1),d1
	bcs.s	L1aeac
L1ae96
	adda.l	#$1c,a1
	dbra	d7,L1ae8c
	tst.l	d2
	beq.s	L1aeaa
	movea.l	d2,a1
	bra	L1aebc


L1aeaa
	rts


L1aeac
	cmp.l	$c(a1),d3
	bcc.s	L1ae96
	move.l	$c(a1),d3
	move.l	a1,d2
	bra	L1ae96


L1aebc
	move.w	$6(a1),d1
	lsl.w	#7,d1
	move.w	d1,$dff09a
	move.w	$6(a1),d1
	move.w	d1,$dff096
	move.w	#$cd,d1
L1aed6
	dbra	d1,L1aed6
	move.l	d0,$8(a1)
	move.l	$10(a0),$c(a1)
	move.l	$8(a0),$10(a1)
	move.l	$c(a0),$14(a1)
	move.l	$14(a0),$18(a1)
	movea.l	$0(a1),a2
	move.w	$a(a0),$8(a2)
	move.w	$e(a0),$6(a2)
	move.l	$4(a0),d1
	lsr.w	#1,d1
	move.w	d1,$4(a2)
	move.l	$0(a0),(a2)
	move.w	#$cd,d0
L1af18
	dbra	d0,L1af18
	move.w	$6(a1),d1
	ori.w	#$8000,d1
	move.w	d1,$dff096
	move.w	#$cd,d0
L1af2e
	dbra	d0,L1af2e
	move.w	$6(a1),d1
	lsl.w	#7,d1
	move.w	d1,$dff09c
	ori.w	#$8000,d1
	move.w	d1,$dff09a
	rts


	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0005,$0000,$0000,$06ae,$0000,$0000,$0000,$007c
	dc.w	$0000,$0001,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$f6fc,$0000,$050a
	dc.w	$0000,$000d,$0000,$01a2,$0000,$0009,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0001,$ca00,$0000,$2cfc,$0000,$0016,$0000,$01e8,$0000,$0001,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0001,$ca00,$0000,$ae60,$0000,$0040,$0000,$01ac,$0000,$0001,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$7860,$0000,$5a40,$0000,$0028,$0000,$01ac
	dc.w	$0000,$0001,$0000,$0001,$0000,$0005,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$8fa0,$0000,$4300
	dc.w	$0000,$0028,$0000,$01ac,$0000,$0001,$0000,$0003,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$fc06,$0000,$3be0,$0000,$001e,$0000,$0212,$0000,$0003,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001,$0003,$6412,$0000,$6666,$0000,$0001,$0000,$0226,$0000,$0002,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0002,$37e6,$0000,$1ac2,$0000,$001e,$0000,$015e
	dc.w	$0000,$0002,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0002,$52a8,$0000,$186c
	dc.w	$0000,$0036,$0000,$01d2,$0000,$0008,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0001,$ca00,$0000,$ae60,$0000,$0040,$0000,$01b7,$0000,$0001,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0002,$6b14,$0000,$61a0,$0000,$0040,$0000,$01f4,$0000,$0001,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$ccb4,$0000,$19ce,$0000,$002d,$0000,$0166
	dc.w	$0000,$0003,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0002,$e682,$0000,$0de0
	dc.w	$0000,$003c,$0000,$010e,$0000,$0005,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0001,$f6fc,$0000,$050a,$0000,$002d,$0000,$00e6,$0000,$0007,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001,$0002,$f462,$0000,$0670,$0000,$0032,$0000,$01ac,$0000,$0004,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$fad2,$0000,$0670,$0000,$0032,$0000,$01ac
	dc.w	$0000,$0004,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$0142,$0000,$27fe
L1b26a
	dc.w	$0000,$0032,$0000,$00f5,$0000,$0003,$0000,$0001,$0000,$0011,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0003,$2940,$0000,$2e70,$0000,$0040,$0000,$021c,$0000,$0002,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0003,$57b0,$0000,$20ae,$0000,$0040,$0000,$00b4,$0000,$0003,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0002,$e682,$0000,$0de0,$0000,$003c,$0000,$0118
	dc.w	$0000,$0005,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0003,$785e,$0000,$09dc
L1b30a
	dc.w	$0000,$0032,$0000,$01ac,$0000,$0003,$0000,$0001,$0000,$0015,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0003,$823a,$0000,$19f4,$0000,$0040,$0000,$0226,$0000,$0005,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0002,$52a8,$0000,$186c,$0000,$0040,$0000,$024a,$0000,$0007,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0003,$f71c,$0000,$2540
L1b382
	dc.w	$0000,$0040,$0000,$01ac,$0000,$0003,$0000,$0001,$0000,$0018,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0003,$785e,$0000,$09dc
L1b3aa
	dc.w	$0000,$0032,$0000,$0152,$0000,$0003,$0000,$0001,$0000,$0019,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0003,$9c2e,$0000,$201c,$0000,$0028,$0000,$0168,$0000,$0005,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001,$0003,$bc4a,$0000,$1bc8,$0000,$0040,$0000,$00f0,$0000,$0004,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$d812,$0000,$1f0a,$0000,$0032,$0000,$0154
	dc.w	$0000,$0005,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0004,$1c5c,$0000,$25ca
	dc.w	$0000,$0040,$0000,$02f4,$0000,$0002,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0004,$4228,$0000,$05a0,$0000,$0040,$0000,$00d6,$0000,$0006,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001,$0004,$1c5c,$0000,$25ca,$0000,$0036,$0000,$01f2,$0000,$0006,$0000,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$c764,$0000,$01f2,$0000,$0040,$0000,$03de
	dc.w	$0000,$0001,$0000,$0063,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$c764,$0000,$0ca4
	dc.w	$0000,$0040,$0000,$00f0,$0000,$0001,$0000,$000b,$0000,$0000,$ffff,$fffc,$0000,$0023,$0000,$0001
	dc.w	$0003,$58d0,$0000,$0146,$0000,$0023,$0000,$012c,$0000,$0005,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$0000,$0032,$0000,$0001


L1b532
	move.w	#$780,$dff09a
	movem.l	d0-d7/a0-a6,-(a7)
	bsr	L1b55e
	movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$8780,$dff09a
	IFND	PROTECTION_DISABLED
L1b54e	cmpi.l	#$c9233ab,L1c13c
	bne	L1b532
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	rte


L1b55e
	tst.w	L1ad30
	bne	L1ae28
	move.w	$dff01e,d0
	move.w	d0,d1
	lsr.w	#7,d1
	andi.w	#$f,d1
	movea.l	#$dfbadd,a0
	btst	#$2,$3542(a0)
	beq	L1ae28
	movea.l	#$1b614,a0
	move.b	(a0,d1.w),d2
	ext.w	d2
	mulu.w	#$1c,d2
	movea.l	#$1af4a,a0
	adda.l	d2,a0
	movea.l	$0(a0),a2
	move.l	$8(a0),d2
	mulu.w	#$28,d2
	movea.l	#$1afba,a1
	adda.l	d2,a1
	move.l	$1c(a1),d2
	add.l	d2,$10(a0)
	move.l	$20(a1),d2
	add.l	d2,$14(a0)
	move.w	$12(a0),$8(a2)
	move.w	$16(a0),$6(a2)
	subq.l	#1,$18(a0)
	beq.s	L1b5d8
	bra	L1b608


L1b5d8
	clr.l	$8(a0)
	move.w	d1,$dff096
	move.w	#$cd,d2
L1b5e6
	dbra	d2,L1b5e6
	move.l	$18(a1),d2
	beq.s	L1b608
	andi.w	#$780,d0
	move.w	d0,$dff09c
	move.l	d2,d0
	jsr	L1ae2a
	jmp	L1c2a0


L1b608
	andi.w	#$780,d0
	move.w	d0,$dff09c
	rts


	dc.w	$0000,$0100,$0200,$0000,$0300,$0000,$0000,$0000


L1b624
	moveq	#$1,d1
	movea.l	#$1af4a,a0
	moveq	#$3,d7
L1b62e
	cmp.l	$8(a0),d0
	beq.s	L1b642
	lsl.b	#1,d1
	adda.l	#$1c,a0
	dbra	d7,L1b62e
	rts


L1b642
	movea.l	#$1afba,a1
	clr.w	d0
	jmp	L1b5d8


L1b650
	dc.w	$0000,$0000


L1b654
	move.l	a0,L1b650
	bsr	L1b726
	move.l	$78,L1b722
	move.b	#$7f,$bfdd00
	move.b	#$cc,$bfd400
	move.b	#$2,$bfd500
	move.b	#$12,$bfd600
	move.b	#$0,$bfd700
	move.b	#$1,$bfde00
	move.b	#$41,$bfdf00
	move.l	#$1b700,$78
	move.b	#$82,$bfdd00
	move.w	#$a000,$dff09a
	rts


L1b6bc
	move.l	L1b722,$78
	move.w	#$2000,$dff09a
	move.b	#$0,$bfde00
	move.b	#$0,$bfdf00
	move.w	#$f,$dff096
	move.w	#$258,d0
L1b6ea
	dbra	d0,L1b6ea
	move.w	#$780,$dff09a
	move.w	#$780,$dff09c
	rts


	movem.l	d0-d7/a0-a6,-(a7)
	move.b	$bfdd00,d0
	andi.b	#$2,d0
	beq.s	L1b714
	bsr	L1b7fc
L1b714
	move.w	#$2000,$dff09c
	movem.l	(a7)+,d0-d7/a0-a6
	rte


L1b722
	dc.w	$0000,$0000


L1b726
	adda.l	#$3b8,a0
	move.l	#$80,d0
	moveq	#$0,d1
L1b734
	move.l	d1,d2
	subq.w	#1,d0
L1b738
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	L1b734
	dbra	d0,L1b738
	addq.b	#1,d2
	movea.l	L1b650,a0
	lea	L1bc26(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	addi.l	#$43c,d2
	add.l	a0,d2
	moveq	#$1e,d0
L1b75c
	move.l	d2,(a1)+
	moveq	#$0,d1
	move.w	$2a(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	adda.w	#$1e,a0
	dbra	d0,L1b75c
	lea	L1bc26(pc),a0
	moveq	#$0,d0
L1b776
	movea.l	(a0,d0.l),a1
	clr.l	(a1)
	addq.l	#4,d0
	cmpi.l	#$7c,d0
	bne.s	L1b776
	move.w	#$0,$dff0a8
	move.w	#$0,$dff0b8
	move.w	#$0,$dff0c8
	move.w	#$0,$dff0d8
	clr.l	L1bc16
	clr.l	L1bc12
	clr.l	L1bc1e
	move.l	a0,-(a7)
	movea.l	L1b650,a0
	adda.w	#$3b6,a0
	move.b	(a0),L1bca3
	movea.l	(a7)+,a0
	jmp	L1c6dc


	move.w	#$0,$dff0a8
	move.w	#$0,$dff0b8
	move.w	#$0,$dff0c8
	move.w	#$0,$dff0d8
	move.w	#$f,$dff096
	rts


L1b7fc
	addq.l	#1,L1bc1a
L1b802
	cmpi.l	#$6,L1bc1a
	bne.s	L1b824
	IFND	PROTECTION_DISABLED
L1b80e	cmpi.l	#$cb90c92,L1b54e
	bne.s	L1b7fc
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	clr.l	L1bc1a
	bra	L1b940


L1b824
	lea	L1bbaa(pc),a6
	tst.b	$3(a6)
	beq.s	L1b836
	lea	$dff0a0,a5
	bsr.s	L1b86e
L1b836
	lea	L1bbc4(pc),a6
	tst.b	$3(a6)
	beq.s	L1b848
	lea	$dff0b0,a5
	bsr.s	L1b86e
L1b848
	lea	L1bbde(pc),a6
	tst.b	$3(a6)
	beq.s	L1b85a
	lea	$dff0c0,a5
	bsr.s	L1b86e
L1b85a
	lea	L1bbf8(pc),a6
	tst.b	$3(a6)
	beq.s	L1b86c
	lea	$dff0d0,a5
	bra.s	L1b86e


L1b86c
	rts


L1b86e
	move.b	$2(a6),d0
	andi.b	#$f,d0
	tst.b	d0
	beq.s	L1b8c8
	cmpi.b	#$1,d0
	beq.s	L1b888
	cmpi.b	#$2,d0
	beq.s	L1b8a8
	rts


L1b888
	moveq	#$0,d0
	move.b	$3(a6),d0
	sub.w	d0,$16(a6)
	cmpi.w	#$71,$16(a6)
	bpl.s	L1b8a0
	move.w	#$71,$16(a6)
L1b8a0
	move.w	$16(a6),$6(a5)
	rts


L1b8a8
	moveq	#$0,d0
	move.b	$3(a6),d0
	add.w	d0,$16(a6)
	cmpi.w	#$358,$16(a6)
	bmi.s	L1b8c0
	move.w	#$358,$16(a6)
L1b8c0
	move.w	$16(a6),$6(a5)
	rts


L1b8c8
	cmpi.l	#$1,L1bc1a
	beq.s	L1b906
	cmpi.l	#$2,L1bc1a
	beq.s	L1b910
	cmpi.l	#$3,L1bc1a
	beq.s	L1b91c
	cmpi.l	#$4,L1bc1a
	beq.s	L1b906
	cmpi.l	#$5,L1bc1a
	beq.s	L1b910
	rts


L1b906
	moveq	#$0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	L1b922


L1b910
	moveq	#$0,d0
	move.b	$3(a6),d0
	andi.b	#$f,d0
	bra.s	L1b922


L1b91c
	move.w	$10(a6),d2
	bra.s	L1b93a


L1b922
	asl.w	#1,d0
	moveq	#$0,d1
	move.w	$10(a6),d1
	lea	L1bca8(pc),a0
L1b92e
	move.w	(a0,d0.l),d2
	cmp.w	(a0),d1
	beq.s	L1b93a
	addq.l	#2,a0
	bra.s	L1b92e


L1b93a
	move.w	d2,$6(a5)
	rts


L1b940
	movea.l	L1b650,a0
	movea.l	a0,a3
	adda.w	#$c,a3
	movea.l	a0,a2
	adda.w	#$3b8,a2
	adda.w	#$43c,a0
	move.l	L1bc16,d0
	moveq	#$0,d1
	move.b	(a2,d0.l),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	L1bc12,d1
	move.l	d1,L1bc1e
	clr.w	L1bca4
	lea	$dff0a0,a5
	lea	L1bbaa(pc),a6
	bsr	L1ba92
	lea	$dff0b0,a5
	lea	L1bbc4(pc),a6
	bsr	L1ba92
	lea	$dff0c0,a5
	lea	L1bbde(pc),a6
	bsr	L1ba92
	lea	$dff0d0,a5
	lea	L1bbf8(pc),a6
	bsr	L1ba92
	move.w	#$1f4,d1
L1b9b4
	dbra	d1,L1b9b4
	move.w	#$8000,d0
	or.w	L1bca4,d0
	move.w	d0,$dff096
	lea	L1bbf8(pc),a6
	cmpi.w	#$1,$e(a6)
	bne.s	L1b9e4
	move.l	$a(a6),$dff0d0
	move.w	#$1,$dff0d4
L1b9e4
	lea	L1bbde(pc),a6
	cmpi.w	#$1,$e(a6)
	bne.s	L1ba0a
	move.l	$a(a6),$dff0c0
	move.w	#$1,$dff0c4
	btst	#$0,$dff01f
	beq.s	L1b9e4
L1ba0a
	lea	L1bbc4(pc),a6
	cmpi.w	#$1,$e(a6)
	bne.s	L1ba26
	move.l	$a(a6),$dff0b0
	move.w	#$1,$dff0b4
L1ba26
	lea	L1bbaa(pc),a6
	cmpi.w	#$1,$e(a6)
	bne.s	L1ba42
	move.l	$a(a6),$dff0a0
	move.w	#$1,$dff0a4
L1ba42
	move.l	L1bc12,d0
	addi.l	#$10,d0
	move.l	d0,L1bc12
	cmpi.l	#$400,d0
	bne.s	L1ba80
L1ba5c
	clr.l	L1bc12
	addq.l	#1,L1bc16
	moveq	#$0,d0
	move.w	L1bca2,d0
	move.l	L1bc16,d1
	cmp.l	d0,d1
	bne.s	L1ba80
	clr.l	L1bc16
L1ba80
	tst.w	L1bca6
	beq.s	L1ba90
	clr.w	L1bca6
	bra.s	L1ba5c


L1ba90
	rts


L1ba92
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#$0,d2
	move.b	$2(a6),d2
	andi.b	#$f0,d2
	lsr.b	#4,d2
	move.w	(a6),d3
	andi.w	#$f000,d3
	andi.w	#$fff,(a6)
	lsr.w	#8,d3
	or.w	d3,d2
	tst.b	d2
	beq.s	L1bb30
	moveq	#$0,d3
	lea	L1bc22(pc),a1
	move.l	d2,d4
	lsl.l	#2,d2
	mulu.w	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	move.b	$2(a6),d0
	andi.b	#$f,d0
	cmpi.b	#$c,d0
	bne.s	L1baf4
	move.w	$2(a6),d0
	andi.w	#$ff,d0
	move.w	d0,$12(a6)
L1baf4
	tst.w	d3
	beq.s	L1bb1a
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$4(a6)
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	L1bb30


L1bb1a
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
L1bb30
	tst.w	(a6)
	beq.s	L1bb58
	move.w	(a6),$10(a6)
	move.w	$14(a6),$dff096
	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	(a6),$6(a5)
	move.w	$14(a6),d0
	or.w	d0,L1bca4
L1bb58
	tst.w	(a6)
	beq.s	L1bb60
	move.w	(a6),$16(a6)
L1bb60
	move.b	$2(a6),d0
	andi.b	#$f,d0
	cmpi.b	#$a,d0
	beq.s	L1bb8a
	cmpi.b	#$c,d0
	beq.s	L1bb7c
	cmpi.b	#$f,d0
	beq.s	L1bb92
	rts


L1bb7c
	move.w	$2(a6),d0
	andi.w	#$ff,d0
	move.w	d0,$8(a5)
	rts


L1bb8a
	not.w	L1bca6
	rts


L1bb92
	move.b	$3(a6),d0
	andi.b	#$f,d0
	beq.s	L1bba8
	clr.l	L1bc1a
	move.b	d0,L1b802+5
L1bba8
	rts


L1bbaa
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0000
L1bbc4
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
L1bbde
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0004,$0000,$0000
L1bbf8
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000
L1bc12
	dc.w	$0000,$0000
L1bc16
	dc.w	$0000,$0000
L1bc1a
	dc.w	$0000,$0000
L1bc1e
	dc.w	$0000,$0000
L1bc22
	dc.w	$0000,$0000
L1bc26	ds.w	62
L1bca2
	dc.b	$00
L1bca3
	dc.b	$00
L1bca4
	dc.w	$0000
L1bca6
	dc.w	$0000
L1bca8
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w	$0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w	$0087,$007f,$0078,$0071,$0000,$0000,$0000


* decompress data
* a0 = end of source (compressed) data
* a1 = start of source (compressed) data (used as end marker when decompressing)
* a2 = end of destination (decompressed) data
* routine works from end to start of compressed data
L1bcf6
	move.l	#$1,d7
	move.l	#$ff,d6
	move.l	#$8,d5
	move.l	#$7,d4
	lea	L1bfe2,a3
	move.l	-(a0),d0
	bra	L1beba


L1bd1a
	lsr.l	d7,d0
	bcc.s	L1bd2a
	bne	L1bf66
	move.l	-(a0),d0
	roxr.l	d7,d0
	bcs	L1bf66
L1bd2a
	clr.w	d3
	lsr.l	d7,d0
	bne.s	L1bd34
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bd34
	roxl.b	d7,d3
	lsr.l	d7,d0
	bne.s	L1bd3e
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bd3e
	roxl.b	d7,d3
	lsr.l	d7,d0
	bne.s	L1bd48
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bd48
	roxl.b	d7,d3
L1bd4a
	cmp.l	d0,d6
	bcc.s	L1bd5e
	move.b	d0,-(a2)
	lsr.l	d5,d0
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bd5e
	lsr.l	d7,d0
	bne.s	L1bd76
	move.l	-(a0),d0
	move.b	d0,-(a2)
	roxr.l	d7,d0
	lsr.l	d4,d0
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bd76
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1bda8
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bda8
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1bdd6
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bdd6
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1be00
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1be00
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1be26
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1be26
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1be48
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1be48
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1be66
	move.l	-(a0),d0
	roxr.l	d7,d0
	roxl.b	d7,d2
	lsr.l	d7,d0
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1be66
	roxl.b	d7,d2
	lsr.l	d7,d0
	bne.s	L1be70
	move.l	-(a0),d0
	roxr.l	d7,d0
L1be70
	roxl.b	d7,d2
	move.b	d2,-(a2)
	dbra	d3,L1bd4a
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1be80
	clr.w	d3
	cmp.l	d0,d6
	bcc.s	L1be90
	move.b	d0,d3
	lsr.l	d5,d0
	addq.w	#8,d3
	bra	L1bd4a


L1be90
	lsr.l	d7,d0
	bne.s	L1bea2
	move.l	-(a0),d0
	move.b	d0,d3
	roxr.l	d7,d0
	lsr.l	d4,d0
	addq.w	#8,d3
	bra	L1bd4a


L1bea2
	roxl.b	d7,d3
	moveq	#$6,d1
L1bea6
	lsr.l	d7,d0
	bne.s	L1beae
	move.l	-(a0),d0
	roxr.l	d7,d0
L1beae
	roxl.b	d7,d3
	dbra	d1,L1bea6
	addq.w	#8,d3
	bra	L1bd4a


L1beba
	lsr.l	d7,d0
	bcc	L1bd1a
	bne.s	L1beca
	move.l	-(a0),d0
	roxr.l	d7,d0
	bcc	L1bd1a
L1beca
	lsr.l	d7,d0
	bcc	L1bfa2
	bne.s	L1beda
	move.l	-(a0),d0
	roxr.l	d7,d0
	bcc	L1bfa2
L1beda
	lsr.l	d7,d0
	bcc.s	L1bee6
	bne.s	L1be80
	move.l	-(a0),d0
	roxr.l	d7,d0
	bcs.s	L1be80
L1bee6
	clr.w	d3
	cmp.l	d0,d6
	bcc.s	L1bef2
	move.b	d0,d3
	lsr.l	d5,d0
	bra.s	L1bf20


L1bef2
	lsr.l	d7,d0
	bne.s	L1bf0e
	move.l	-(a0),d0
	move.b	d0,d3
	roxr.l	d7,d0
	lsr.l	d4,d0
	IFND	PROTECTION_DISABLED
	cmpi.l	#$cb90cb9,L1b80e
	bne	L1bef2
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	bra.s	L1bf20


L1bf0e
	roxl.b	d7,d3
	moveq	#$6,d1
L1bf12
	lsr.l	d7,d0
	bne.s	L1bf1a
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bf1a
	roxl.b	d7,d3
	dbra	d1,L1bf12
L1bf20
	clr.w	d2
	cmp.l	d0,d6
	bcs.s	L1bf48
	lsr.l	d7,d0
	bne.s	L1bf34
	move.l	-(a0),d0
	move.b	d0,d2
	roxr.l	d7,d0
	lsr.l	d4,d0
	bra.s	L1bf4c


L1bf34
	roxl.b	d7,d2
	moveq	#$6,d1
L1bf38
	lsr.l	d7,d0
	bne.s	L1bf40
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bf40
	roxl.w	d7,d2
	dbra	d1,L1bf38
	bra.s	L1bf4c


L1bf48
	move.b	d0,d2
	lsr.l	d5,d0
L1bf4c
	lea	(a2,d2.w),a4
	move.b	-(a4),-(a2)
	move.b	-(a4),-(a2)
	move.b	-(a4),-(a2)
	move.b	-(a4),-(a2)
L1bf58
	move.b	-(a4),-(a2)
	dbra	d3,L1bf58
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bf66
	clr.w	d2
	cmp.l	d0,d6
	bcs.s	L1bf8e
	lsr.l	d7,d0
	bne.s	L1bf7a
	move.l	-(a0),d0
	move.b	d0,d2
	roxr.l	d7,d0
	lsr.l	d4,d0
	bra.s	L1bf92


L1bf7a
	roxl.b	d7,d2
	moveq	#$6,d1
L1bf7e
	lsr.l	d7,d0
	bne.s	L1bf86
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bf86
	roxl.w	d7,d2
	dbra	d1,L1bf7e
	bra.s	L1bf92


L1bf8e
	move.b	d0,d2
	lsr.l	d5,d0
L1bf92
	lea	(a2,d2.w),a4
	move.b	-(a4),-(a2)
	move.b	-(a4),-(a2)
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bfa2
	moveq	#$0,d3
	lsr.l	d7,d0
	bne.s	L1bfac
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bfac
	roxl.b	d7,d3
	moveq	#$8,d1
	add.w	d3,d1
	clr.w	d2
L1bfb4
	lsr.l	d7,d0
	bne.s	L1bfbc
	move.l	-(a0),d0
	roxr.l	d7,d0
L1bfbc
	roxl.w	d7,d2
	dbra	d1,L1bfb4
	lea	(a2,d2.w),a4
	move.b	-(a4),-(a2)
	move.b	-(a4),-(a2)
L1bfca
	move.b	-(a4),-(a2)
	dbra	d3,L1bfd8
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bfd8
	move.b	-(a4),-(a2)
	cmpa.l	a2,a1
	blt	L1beba
	rts


L1bfe2
	ori.l	#$40c020a0,d0
	bra.s	L1bfca


	dc.w	$1090,$50d0,$30b0,$70f0,$0888,$48c8,$28a8,$68e8,$1898,$58d8,$38b8,$78f8,$0484,$44c4,$24a4,$64e4
	dc.w	$1494,$54d4,$34b4,$74f4,$0c8c,$4ccc,$2cac,$6cec,$1c9c,$5cdc,$3cbc,$7cfc,$0282,$42c2,$22a2,$62e2
	dc.w	$1292,$52d2,$32b2,$72f2,$0a8a,$4aca,$2aaa,$6aea,$1a9a,$5ada,$3aba,$7afa,$0686,$46c6,$26a6,$66e6
	dc.w	$1696,$56d6,$36b6,$76f6,$0e8e,$4ece,$2eae,$6eee,$1e9e,$5ede,$3ebe,$7efe,$0181,$41c1,$21a1,$61e1
	dc.w	$1191,$51d1,$31b1,$71f1,$0989,$49c9,$29a9,$69e9,$1999,$59d9,$39b9,$79f9,$0585,$45c5,$25a5,$65e5
	dc.w	$1595,$55d5,$35b5,$75f5,$0d8d,$4dcd,$2dad,$6ded,$1d9d,$5ddd,$3dbd,$7dfd,$0383,$43c3,$23a3,$63e3
	dc.w	$1393,$53d3,$33b3,$73f3,$0b8b,$4bcb,$2bab,$6beb,$1b9b,$5bdb,$3bbb,$7bfb,$0787,$47c7,$27a7,$67e7
	dc.w	$1797,$57d7,$37b7,$77f7,$0f8f,$4fcf,$2faf,$6fef,$1f9f,$5fdf,$3fbf,$7fff,$0000,$0000


L1c0e6
	clr.l	$fc0004
	IFD	DISK_ACCESS_DISABLED
	nop
	nop
	nop
	ELSE
	jsr	L1c172		move disk head to track 0
	ENDC
	movea.l	#$4f73a,a0
	moveq	#$0,d0
	move.l	#$1,$fc0004
	IFD	DISK_ACCESS_DISABLED
	nop
	nop
	nop
	ELSE
	jsr	L1c1c4		load high score data from track 0 (side 1), if present
	ENDC

	IFND	PROTECTION_DISABLED
	movea.l	#$74f56,a2
	ELSE
	nop
	nop
	nop
	ENDC
	movea.l	#$4f73a,a0
	move.l	$1b2(a0),d0
	and.l	(a0),d0
	or.l	(a0),d0
	cmpi.l	#$534f4441,d0
	beq.s	L1c12c
	movea.l	#$1c456,a0
L1c12c
	move.w	#$1b5,d0
	movea.l	L1ad32,a1
L1c136
	move.b	(a0)+,(a1)+
	dbra	d0,L1c136

	IFND	PROTECTION_DISABLED
L1c13c	cmpi.l	#$33ab1144,(a2)
L1c142	bne.s	L1c136
	ELSE
	nop
	nop
	nop
	nop
	ENDC

	move.l	#$ffffffff,$fc0004
	rts


L1c150
	jsr	L1c172
	movea.l	L1ad32,a0
	moveq	#$0,d0
	jsr	L1c2b0
	rts


L1c166
	btst	#$5,$bfe001
	bne.s	L1c166
	rts


L1c172
	bclr	#$2,$bfd100
	btst	#$4,$bfe001
	beq.s	L1c166
	bsr	L1c190
	jsr	L1c1b6
	bra.s	L1c172


L1c190
	bset	#$1,$bfd100
	bclr	#$0,$bfd100
	nop
	nop
	bset	#$0,$bfd100
	jsr	L1c1b6
	bra	L1c166


L1c1b6
	move.l	d7,-(a7)
	move.w	#$1388,d7
L1c1bc
	dbra	d7,L1c1bc
	move.l	(a7)+,d7
	rts


L1c1c4
	movem.l	d0-d2/d5-d6/a1,-(a7)
	moveq	#$3,d6
L1c1ca
	move.w	#$2,$dff09c
	movea.l	#$51e4a,a1
	clr.l	$2(a1)
	move.l	a1,$dff020
	move.w	#$8010,$dff096
	move.w	#$4489,$dff07e
	move.w	#$8500,$dff09e
	move.w	#$4000,$dff024
	move.b	$bfdd00,d0
L1c208
	move.b	$bfdd00,d0
	btst	#$4,d0
	beq.s	L1c208
	IFND	PROTECTION_DISABLED
	cmpi.l	#$c9233ab,L1c13c
	bne.s	L1c208
	cmpi.l	#$66f223fc,L1c142
	bne.s	L1c208
	ELSE
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ENDC
	move.w	#$9f40,$dff024
	move.w	#$9f40,$dff024
	move.l	#$186a0,d1
L1c242
	move.w	$dff01e,d0
	btst	#$1,d0
	bne	L1c256
	subq.l	#1,d1
	bne	L1c242
L1c256
	cmpi.l	#$552aaaa5,$2(a1)
	bne	L1c2a2
	cmpi.l	#$552aaaa9,$6(a1)
	bne	L1c2a2
	moveq	#$a,d5
	lea	$3a(a1),a1
L1c274
	moveq	#$7f,d6
L1c276
	move.l	$200(a1),d1
	move.l	(a1)+,d0
	asl.l	#1,d0
	andi.l	#$aaaaaaaa,d0
	andi.l	#$55555555,d1
	or.l	d1,d0
	move.l	d0,(a0)+
	dbra	d6,L1c276
	adda.l	#$240,a1
	dbra	d5,L1c274
L1c29c
	movem.l	(a7)+,d0-d2/d5-d6/a1
L1c2a0
	rts


L1c2a2
	subq.w	#1,d6
	beq.s	L1c29c
	jsr	L1c1b6
	bra	L1c1ca


L1c2b0
	move.l	d0,d7
L1c2b2
	moveq	#$0,d0
	moveq	#$0,d1
	jsr	L1c2c2
	dbra	d7,L1c2b2
L1c2c0
	rts


L1c2c2
	movem.l	d0-d7/a1-a4,-(a7)
	movea.l	#$51e4a,a1
	move.w	#$f9,d6
L1c2d0
	move.l	#$aaaaaaaa,(a1)+
	dbra	d6,L1c2d0
	moveq	#$a,d3
	moveq	#$b,d2
L1c2de
	movea.l	a1,a6
	move.l	#$aaaaaaaa,(a1)+
	move.l	#$44894489,(a1)+
	move.b	#$ff,d7
	asl.l	#8,d7
	move.b	d0,d7
	asl.l	#8,d7
	move.b	d1,d7
	asl.l	#8,d7
	move.b	d2,d7
	movea.l	a1,a2
	move.l	d7,d6
	andi.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	move.l	d6,(a1)+
	andi.l	#$55555555,d7
	move.l	d7,(a1)+
	moveq	#$1,d5
	jsr	L1c420
	eor.l	d6,d7
	movea.l	a1,a2
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	move.l	d7,d6
	andi.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	move.l	d6,(a1)+
	andi.l	#$55555555,d7
	move.l	d7,(a1)+
	moveq	#$5,d5
	jsr	L1c420
	movea.l	a1,a3
	addq.l	#8,a1
	movea.l	a1,a4
	moveq	#$7f,d5
	moveq	#$0,d4
L1c354
	move.l	(a0)+,d7
	move.l	d7,d6
	andi.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	andi.l	#$55555555,d7
	move.l	d7,$200(a1)
	move.l	d6,(a1)+
	eor.l	d6,d4
	eor.l	d7,d4
	dbra	d5,L1c354
	move.l	d4,d7
	andi.l	#$aaaaaaaa,d4
	lsr.l	#1,d4
	andi.l	#$55555555,d7
	movea.l	a3,a2
	move.l	d4,(a3)+
	move.l	d7,(a3)
	moveq	#$1,d5
	jsr	L1c420
	movea.l	a4,a2
	move.w	#$80,d5
	jsr	L1c420
	addq.b	#1,d1
	subq.b	#1,d2
	adda.l	#$200,a1
	dbra	d3,L1c2de
	move.l	#$aaaaaaaa,(a1)
	move.w	#$2,$dff09c
	movea.l	#$51e4a,a1
	move.l	a1,$dff020
	move.w	#$8010,$dff096
	move.w	#$7fff,$dff09e
	move.w	#$8100,$dff09e
	move.w	#$4000,$dff024
	move.b	$bfdd00,d0
L1c3ec
	move.b	$bfdd00,d0
	btst	#$4,d0
	beq.s	L1c3ec
	move.w	#$d955,$dff024
	move.w	#$d955,$dff024
L1c408
	move.w	$dff01e,d0
	btst	#$1,d0
	beq.s	L1c408
	movem.l	(a7)+,d0-d7/a1-a4
	bsr	L1c1b6
	bra	L1c166


L1c420
	movem.l	d0-d5/a2,-(a7)
	add.w	d5,d5
	subq.w	#1,d5
	move.b	-$1(a2),d0
L1c42c
	move.l	(a2),d4
	move.l	d4,d1
	move.l	d4,d2
	not.l	d1
	andi.l	#$55555555,d1
	asl.l	#1,d1
	move.l	d1,d3
	roxr.b	#1,d0
	roxr.l	#1,d4
	eor.l	d4,d1
	and.l	d3,d1
	or.l	d1,d2
	move.l	d2,(a2)+
	move.b	d2,d0
	dbra	d5,L1c42c
	movem.l	(a7)+,d0-d5/a2
	rts


	dc.b	'SODA',$0d,'Y',$01,'t h e  i m m o r t a l : ---',$0d,'L',$08,'--------------------------'
	dc.b	'-------',$00,$0d,'O!',$01,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d
	dc.b	'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000'
	dc.b	'000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$01,$0d,'O',$07,'--- 0000000000',$00,$0d,$d1,'!'
	dc.b	'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 000000'
	dc.b	'0000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--'
	dc.b	'- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$01,$0d,$d1,$07,'--- 0000000000',$00,$00,'SODA',$00


	dc.b	$00

	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000a
	dc.w	$0014,$001e,$0028,$0032,$003c,$0046,$0050,$0064,$006e,$0078,$0082,$008c,$0096,$00a0,$00aa


L1c64c
	movea.l	#$1c60c,a5
	moveq	#$f,d7
L1c654
	subq.w	#1,$20(a5)
	bne.s	L1c66c
	move.w	#$1b22,d1
	jsr	L1c6ae
	move.w	d0,(a5)
	move.w	#$a0,$20(a5)
L1c66c
	movea.l	$8,a1
	adda.w	(a5),a1
	move.b	#$4,d0
	move.b	$21(a5),d2
	andi.b	#$1f,d2
	lsr.b	#1,d2
	bcc.s	L1c686
	move.b	d0,(a1)
L1c686
	lsr.b	#1,d2
	bcc.s	L1c68e
	move.b	d0,$1b50(a1)
L1c68e
	lsr.b	#1,d2
	bcc.s	L1c696
	move.b	d0,$36a0(a1)
L1c696
	lsr.b	#1,d2
	bcc.s	L1c69e
	move.b	d0,$51f0(a1)
L1c69e
	lsr.b	#1,d2
	bcc.s	L1c6a6
	move.b	d0,$6d40(a1)
L1c6a6
	addq.w	#2,a5
	dbra	d7,L1c654
	rts


L1c6ae
	lea	L1c6e4,a1
	tst.w	d1
	ble.s	L1c6de
	move.l	(a1),d0
	add.l	d0,d0
	bhi	L1c6c6
	eori.l	#$1d872b41,d0
L1c6c6
	move.l	d0,(a1)
	andi.l	#$ffff,d0
	divu.w	d1,d0
	swap	d0
	btst	#$3,$dff01e
	beq.s	L1c6c6
L1c6dc
	rts


L1c6de
	neg.w	d1
	move.l	d1,(a1)
	rts


L1c6e4	ds.w	7822
