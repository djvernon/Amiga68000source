
*** DEMO NUMBER TWO BY DANIEL VERNON ***
*** VERSION 1.2   DATE: 4-3-90 ***
*** FULL SCREEN, 4 LAYER SPRITE STARFIELD ***
*** MIDDLE WAVY IRON MAIDEN LOGO ***
*** BOTTOM SCROLLING MESSAGE ***

	section dan,code_c
	opt c-

start	bset	#1,$bfe001	low pass filter off

	move.l	#18000,d0
delay1	move.w	$dff006,$dff180
	move.l	#100,d1
delay2	dbra	d1,delay2
	dbra	d0,delay1

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	move.w	#$01e0,$dff096	DMA off

;	bsr	mt_init

	move.l	#top,d0		set up bitplanes
	move.w	d0,bp1l1
	swap	d0
	move.w	d0,bp1h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp2l1
	swap	d0
	move.w	d0,bp2h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp3l1
	swap	d0
	move.w	d0,bp3h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp4l1
	swap	d0
	move.w	d0,bp4h1
	swap	d0
	add.l	#11264,d0

	move.l	d0,a0		initialise colours
	lea	colours1(pc),a1
	move.w	#color0,d1
	moveq	#15,d0
nextc1	move.w	d1,(a1)+
	add.w	#2,d1
	move.w	(a0)+,(a1)+
	dbra	d0,nextc1


;""""""""""""""""""""""""""""""""""""""""""""
;	MAKE SPRITES FOR STARFIELD
;

;sprite0
	move.l	#sprite0,a0
	bsr	spricol1
;sprite1
	move.l	#sprite1,a0
	bsr	spricol2
;sprite2
	move.l	#sprite2,a0
	bsr	spricol1
;sprite3
	move.l	#sprite3,a0
	bsr	spricol2
	jmp	set

spricol1
	moveq	#26,d0		27 sprites
	move.l	#$2c002d00,d1	start = $2c, height = 1
spc11
	move.l	d1,(a0)+
	move.l	#$80000000,(a0)+	%1000000000000000 0000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc11
	moveq	#4,d0		5 sprites
	move.l	#$4000506,d1	start = $4+256 = 260, height = 1
spc12
	move.l	d1,(a0)+
	move.l	#$80000000,(a0)+	%1000000000000000 0000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc12
	rts


spricol2
	moveq	#26,d0		27 sprites
	move.l	#$2c002d00,d1	start = $2c, height = 1
spc21
	move.l	d1,(a0)+
	move.l	#$8000,(a0)+	%0000000000000000 1000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc21
	moveq	#4,d0		5 sprites
	move.l	#$4000506,d1	start = $4+256 = 260, height = 1
spc22
	move.l	d1,(a0)+
	move.l	#$8000,(a0)+	%0000000000000000 1000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc22
	rts


;"""""""""""""""""""""""""""""""""""""""""""""
;	SET UP SPRITE POINTERS
;
set	move.l	#sprite0,d0
	move.w	d0,sp0l
	swap	d0
	move.w	d0,sp0h
	move.l	#sprite1,d0
	move.w	d0,sp1l
	swap	d0
	move.w	d0,sp1h
	move.l	#sprite2,d0
	move.w	d0,sp2l
	swap	d0
	move.w	d0,sp2h
	move.l	#sprite3,d0
	move.w	d0,sp3l
	swap	d0
	move.w	d0,sp3h
	move.l	#sprite4,d0
	move.w	d0,sp4l
	swap	d0
	move.w	d0,sp4h
	move.l	#sprite5,d0
	move.w	d0,sp5l
	swap	d0
	move.w	d0,sp5h
	move.l	#sprite6,d0
	move.w	d0,sp6l
	swap	d0
	move.w	d0,sp6h
	move.l	#sprite7,d0
	move.w	d0,sp7l
	swap	d0
	move.w	d0,sp7h


;""""""""""""""""""""""""""""""""""""""""""""
;	SET THE NEW COPPER LOCATION

	lea	$dff000,a5

	move.l	4.w,a6
	lea	grafname,a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,a1
	move.l	38(a1),oldcopper
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

	move.w	#$0080,dmacon(a5)
	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$81e0,dmacon(a5)	DMA on (bitplane, copper,
;						blitter, sprite)


;"""""""""""""""""""""""""""""""""
;" SET UP INTERRUPT FROM COPPER  "
;"				 "
;"""""""""""""""""""""""""""""""""
	move.w	#$8010,intena(a5)
	move.l	$6c,old
	move.l	#copint,$6c


;""""""""""""""""""""""""""""""""""""""""
;	LOOP TO TEST MOUSE BUTTON

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	old,$6c
	move.l	oldcopper,cop1lc(a5)
	clr.w	copjmp1(a5)

end	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.w	#$f,dmacon(a5)		sound off
	clr.w	aud0vol(a5)
	clr.w	aud1vol(a5)
	clr.w	aud2vol(a5)
	clr.w	aud3vol(a5)
	bclr	#1,$bfe001	low pass filter on
	move.l	4,a6
	jsr	-150(a6)	SuperState
	jmp	$fc00d2		Reset


;interrupt routine

copint	movem.l	d0-d7/a0-a6,-(sp)
	and.w	#$10,intreqr(a5)
	beq.s	out
	move.w	#$10,intreq(a5)

;	bsr	mt_music
	btst	#7,$bfe001
	beq.s	out

	bsr.s	starfield
	bsr	copwobble
	bsr	scroll

out	movem.l	(sp)+,d0-d7/a0-a6
	dc.w	$4ef9		jump to old interrupt routine
old	dc.l	0


;""""""""""""""""""""""""""""""""""""""""
;	" INTERRUPT ROUTINES "
;	"		     "
;	""""""""""""""""""""""

starfield
;sprite0
	moveq	#31,d0		32 sprites
	move.l	#sprite0,a1
update0
	addq.b	#2,1(a1)	4 pixels
	add.l	#8,a1		next sprite
	dbf	d0,update0


;sprite1
	moveq	#31,d0		32 sprites
	move.l	#sprite1,a1
update1
	move.b	3(a1),d1
	andi.b	#1,d1
	beq	fine1		1 pixel
	andi.b	#$fe,3(a1)
	addq.b	#1,1(a1)
fdone1
	addq.b	#1,1(a1)	2 more pixels (3 in total)
	add.l	#8,a1		next sprite
	dbf	d0,update1


;sprite2
	moveq	#31,d0		32 sprites
	move.l	#sprite2,a1
update2
	addq.b	#1,1(a1)	2 pixels
	add.l	#8,a1		next sprite
	dbf	d0,update2


;sprite3
	moveq	#31,d0		32 sprites
	move.l	#sprite3,a1
update3
	move.b	3(a1),d1
	andi.b	#1,d1
	beq	fine3		1 pixel
	andi.b	#$fe,3(a1)
	addq.b	#1,1(a1)
fdone3
	add.l	#8,a1		next sprite
	dbf	d0,update3
	rts

fine1	eori.b	#$01,3(a1)
	bra	fdone1
fine3	eori.b	#$01,3(a1)
	bra	fdone3


copwobble
	lea	woblogoclist,a0
	moveq	#556-444,d0	number of lines
cwloop	move.b	15(a0),7(a0)
	add.l	#8,a0
	dbra	d0,cwloop
cwloop2	move.l	wobptr,a1
	move.b	(a1)+,d0
	cmp.b	#$fe,d0
	bne.s	valok
	move.l	#woblist,wobptr
	bra.s	cwloop2
valok	move.l	a1,wobptr
	move.b	d0,7(a0)
	rts


prnchr	lea 	font,a0
	lea 	top+224*44+40,a1		; destination
	sub.b 	#32,d0			; de-ascii
	mulu 	#512,d0			; find position in font
	add.l 	d0,a0
	moveq 	#3,d1
lp1	moveq 	#31,d2
	move.l 	a1,a2
lp2	move.l	(a0)+,(a2)
	add.l #44,a2
	dbra d2,lp2
	add.l #11264,a1
	dbra d1,lp1
	rts


scroll	cmp.b #0,scrlctd	font is 32 pixels high and 224 lines from top
	beq.s scrl2
	subq.b #1,scrlctd
	rts
scrl2	bsr.s blitscr
	move.b scrlptr,d0
	subq.b #1,d0
	beq.s zero
 	move.b d0,scrlptr
	rts
zero	move.b #8,scrlptr
	move.l txtptr,a0
	moveq #0,d0
	move.b (a0)+,d0
	cmp.b #0,d0
 	bne.s charok
	move.l #text,txtptr
	bra.s zero
charok	cmp.b #254,d0
	bne.s notpuse
	move.b #80,scrlctd
	move.l a0,txtptr
	moveq #32,d0
	bsr prnchr
	rts
notpuse move.l a0,txtptr
	bsr prnchr
	rts	


blitscr	moveq 	#3,d0
	lea 	top+224*44,a0
blitlp	btst 	#6,$dff002
	bne.s 	blitlp
	move.l 	a0,$dff050
	move.l 	a0,a1
	subq.l 	#2,a1
	move.l 	a1,$dff054
	clr.l 	$dff064
	move.l 	#-1,$dff044
	move.w 	#%1101100111110000,$dff040
	clr.w	$dff042
	move.w	#22+32*64,$dff058
	add.l 	#11264,a0
	dbra d0,blitlp
blitfin	btst 	#6,$dff002
	bne.s	blitfin	
	rts


scrlptr	dc.b	6
scrlctd	dc.b	0
	even
txtptr	dc.l 	text
text	dc.b 	"        THIS DEMO WAS WRITTEN BY...     DEGSY    ",254
	dc.b	"        THE MUSIC IS TAKEN FROM IRON MAIDEN`S `PHANTOM OF THE OPERA'                        ",0
		even


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bplcon0,$4200
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon1,$0
	dc.w	bplcon2,$0
	dc.w	bpl1mod,$4
	dc.w	bpl2mod,$4

	dc.w	bpl1pth		4 bitplane display
bp1h1	dc.w	0,bpl1ptl
bp1l1	dc.w	0,bpl2pth
bp2h1	dc.w	0,bpl2ptl
bp2l1	dc.w	0,bpl3pth
bp3h1	dc.w	0,bpl3ptl
bp3l1	dc.w	0,bpl4pth
bp4h1	dc.w	0,bpl4ptl
bp4l1	dc.w	0,spr0pth	set up sprite pointers now
sp0h	dc.w	0,spr0ptl
sp0l	dc.w	0,spr1pth
sp1h	dc.w	0,spr1ptl
sp1l	dc.w	0,spr2pth
sp2h	dc.w	0,spr2ptl
sp2l	dc.w	0,spr3pth
sp3h	dc.w	0,spr3ptl
sp3l	dc.w	0,spr4pth
sp4h	dc.w	0,spr4ptl
sp4l	dc.w	0,spr5pth
sp5h	dc.w	0,spr5ptl
sp5l	dc.w	0,spr6pth
sp6h	dc.w	0,spr6ptl
sp6l	dc.w	0,spr7pth
sp7h	dc.w	0,spr7ptl
sp7l	dc.w	0

colours1	ds.w	32

	dc.w	$1a2,$fff	sprite colours
	dc.w	$1a4,$ccc
	dc.w	$1aa,$999
	dc.w	$1ac,$666

woblogoclist
	dc.w	$6009,$fffe,bplcon1,$88
	dc.w	$6109,$fffe,bplcon1,$88
	dc.w	$6209,$fffe,bplcon1,$88
	dc.w	$6309,$fffe,bplcon1,$88
	dc.w	$6409,$fffe,bplcon1,$88
	dc.w	$6509,$fffe,bplcon1,$88
	dc.w	$6609,$fffe,bplcon1,$88
	dc.w	$6709,$fffe,bplcon1,$88
	dc.w	$6809,$fffe,bplcon1,$88
	dc.w	$6909,$fffe,bplcon1,$88
	dc.w	$6a09,$fffe,bplcon1,$88
	dc.w	$6b09,$fffe,bplcon1,$88
	dc.w	$6c09,$fffe,bplcon1,$88
	dc.w	$6d09,$fffe,bplcon1,$88
	dc.w	$6e09,$fffe,bplcon1,$88
	dc.w	$6f09,$fffe,bplcon1,$88
	dc.w	$7009,$fffe,bplcon1,$88
	dc.w	$7109,$fffe,bplcon1,$88
	dc.w	$7209,$fffe,bplcon1,$88
	dc.w	$7309,$fffe,bplcon1,$88
	dc.w	$7409,$fffe,bplcon1,$88
	dc.w	$7509,$fffe,bplcon1,$88
	dc.w	$7609,$fffe,bplcon1,$88
	dc.w	$7709,$fffe,bplcon1,$88
	dc.w	$7809,$fffe,bplcon1,$88
	dc.w	$7909,$fffe,bplcon1,$88
	dc.w	$7a09,$fffe,bplcon1,$88
	dc.w	$7b09,$fffe,bplcon1,$88
	dc.w	$7c09,$fffe,bplcon1,$88
	dc.w	$7d09,$fffe,bplcon1,$88
	dc.w	$7e09,$fffe,bplcon1,$88
	dc.w	$7f09,$fffe,bplcon1,$88
	dc.w	$8009,$fffe,bplcon1,$88
	dc.w	$8109,$fffe,bplcon1,$88
	dc.w	$8209,$fffe,bplcon1,$88
	dc.w	$8309,$fffe,bplcon1,$88
	dc.w	$8409,$fffe,bplcon1,$88
	dc.w	$8509,$fffe,bplcon1,$88
	dc.w	$8609,$fffe,bplcon1,$88
	dc.w	$8709,$fffe,bplcon1,$88
	dc.w	$8809,$fffe,bplcon1,$88
	dc.w	$8909,$fffe,bplcon1,$88
	dc.w	$8a09,$fffe,bplcon1,$88
	dc.w	$8b09,$fffe,bplcon1,$88
	dc.w	$8c09,$fffe,bplcon1,$88
	dc.w	$8d09,$fffe,bplcon1,$88
	dc.w	$8e09,$fffe,bplcon1,$88
	dc.w	$8f09,$fffe,bplcon1,$88
	dc.w	$9009,$fffe,bplcon1,$88
	dc.w	$9109,$fffe,bplcon1,$88
	dc.w	$9209,$fffe,bplcon1,$88
	dc.w	$9309,$fffe,bplcon1,$88
	dc.w	$9409,$fffe,bplcon1,$88
	dc.w	$9509,$fffe,bplcon1,$88
	dc.w	$9609,$fffe,bplcon1,$88
	dc.w	$9709,$fffe,bplcon1,$88
	dc.w	$9809,$fffe,bplcon1,$88
	dc.w	$9909,$fffe,bplcon1,$88
	dc.w	$9a09,$fffe,bplcon1,$88
	dc.w	$9b09,$fffe,bplcon1,$88
	dc.w	$9c09,$fffe,bplcon1,$88
	dc.w	$9d09,$fffe,bplcon1,$88
	dc.w	$9e09,$fffe,bplcon1,$88
	dc.w	$9f09,$fffe,bplcon1,$88
	dc.w	$a009,$fffe,bplcon1,$88
	dc.w	$a109,$fffe,bplcon1,$88
	dc.w	$a209,$fffe,bplcon1,$88
	dc.w	$a309,$fffe,bplcon1,$88
	dc.w	$a409,$fffe,bplcon1,$88
	dc.w	$a509,$fffe,bplcon1,$88
	dc.w	$a609,$fffe,bplcon1,$88
	dc.w	$a709,$fffe,bplcon1,$88
	dc.w	$a809,$fffe,bplcon1,$88
	dc.w	$a909,$fffe,bplcon1,$88
	dc.w	$aa09,$fffe,bplcon1,$88
	dc.w	$ab09,$fffe,bplcon1,$88
	dc.w	$ac09,$fffe,bplcon1,$88
	dc.w	$ad09,$fffe,bplcon1,$88
	dc.w	$ae09,$fffe,bplcon1,$88
	dc.w	$af09,$fffe,bplcon1,$88
	dc.w	$b009,$fffe,bplcon1,$88
	dc.w	$b109,$fffe,bplcon1,$88
	dc.w	$b209,$fffe,bplcon1,$88
	dc.w	$b309,$fffe,bplcon1,$88
	dc.w	$b409,$fffe,bplcon1,$88
	dc.w	$b509,$fffe,bplcon1,$88
	dc.w	$b609,$fffe,bplcon1,$88
	dc.w	$b709,$fffe,bplcon1,$88
	dc.w	$b809,$fffe,bplcon1,$88
	dc.w	$b909,$fffe,bplcon1,$88
	dc.w	$ba09,$fffe,bplcon1,$88
	dc.w	$bb09,$fffe,bplcon1,$88
	dc.w	$bc09,$fffe,bplcon1,$88
	dc.w	$bd09,$fffe,bplcon1,$88
	dc.w	$be09,$fffe,bplcon1,$88
	dc.w	$bf09,$fffe,bplcon1,$88
	dc.w	$c009,$fffe,bplcon1,$88
	dc.w	$c109,$fffe,bplcon1,$88
	dc.w	$c209,$fffe,bplcon1,$88
	dc.w	$c309,$fffe,bplcon1,$88
	dc.w	$c409,$fffe,bplcon1,$88
	dc.w	$c509,$fffe,bplcon1,$88
	dc.w	$c609,$fffe,bplcon1,$88
	dc.w	$c709,$fffe,bplcon1,$88
	dc.w	$c809,$fffe,bplcon1,$88
	dc.w	$c909,$fffe,bplcon1,$88
	dc.w	$ca09,$fffe,bplcon1,$88
	dc.w	$cb09,$fffe,bplcon1,$88
	dc.w	$cc09,$fffe,bplcon1,$88
	dc.w	$cd09,$fffe,bplcon1,$88
	dc.w	$ce09,$fffe,bplcon1,$88
	dc.w	$cf09,$fffe,bplcon1,$88
	dc.w	$d009,$fffe,bplcon1,$88
	dc.w	$d109,$fffe,bplcon1,$88
	dc.w	$d209,$fffe,bplcon1,$0

	dc.w	$ffdf,$fffe	PAL copper enable
	dc.w	$182,$000,$184,$eee,$186,$ddd
	dc.w	$188,$ccc,$18a,$bbb,$18c,$aaa,$18e,$999
	dc.w	$190,$888,$192,$777,$194,$666,$196,$555
	dc.w	$198,$444,$19a,$333,$19c,$222,$19e,$111

	dc.w	$1009,$fffe,$186,$100	colours for scrolltext
	dc.w	$1109,$fffe,$186,$200
	dc.w	$1209,$fffe,$186,$300
	dc.w	$1309,$fffe,$186,$400
	dc.w	$1409,$fffe,$186,$500
	dc.w	$1509,$fffe,$186,$600
	dc.w	$1609,$fffe,$186,$700
	dc.w	$1709,$fffe,$186,$800
	dc.w	$1809,$fffe,$186,$900
	dc.w	$1909,$fffe,$186,$a00
	dc.w	$2109,$fffe,$186,$a10
	dc.w	$2209,$fffe,$186,$a20
	dc.w	$2309,$fffe,$186,$a30
	dc.w	$2409,$fffe,$186,$a40
	dc.w	$2509,$fffe,$186,$a50
	dc.w	$2609,$fffe,$186,$a60
	dc.w	$2709,$fffe,$186,$a70
	dc.w	$2809,$fffe,$186,$a80
	dc.w	$2909,$fffe,$186,$a90
	dc.w	intreq,$8010
	dc.w	$ffff,$fffe	END


;""""""""""""""""
;" Music Player	"
;"		"
;""""""""""""""""

eq1 dc.b 0
eq2 dc.b 0
eq3 dc.b 0
eq4 dc.b 0
eq1p dc.w 381
eq2p dc.w 381
eq3p dc.w 381
eq4p dc.w 381
eqtab dcb.w 40

mt_init:lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4:
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear:
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6,mt_maxpart+1
	rts

mt_music:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2

mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts

mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0

	move.b #$1c,eq4
	move.w (a6),eq4p

	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0

	move.b #$1c,eq3
	move.w (a6),eq3p

	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0

	move.b #$1c,eq2
	move.w (a6),eq2p

	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0

	move.b #$1c,eq1
	move.w (a6),eq1p

	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back:rts

mt_aud1temp:
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp:
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp:
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp:
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.w	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	dcb.l	31,0
mt_maxpart:	dc.w	0
mt_dmacon:	dc.w	0
mt_status:	dc.w	0

mt_arpeggio:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000

mt_data	;incbin st-01:mod.phantom



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

oldcopper	dc.l	0

wobptr		dc.l	woblist


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even

woblist	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$99
	dc.b $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$88,$88,$88,$88,$88,$88
	dc.b $77,$77,$77,$77,$66,$66,$66,$66,$66,$55,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b $55,$66,$66,$66,$66,$77,$77,$77,$88,$88,$88,$99,$99,$99,$aa,$aa,$aa,$bb
	dc.b $bb,$bb,$bb,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$bb,$bb,$bb,$bb
	dc.b $aa,$aa,$aa,$99,$99,$99,$88,$88,$88,$77,$77,$77,$66,$66,$66,$55,$55,$55
	dc.b $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$66,$66,$66,$77,$77,$77,$88
	dc.b $88,$88,$99,$99,$99,$aa,$aa,$aa,$aa,$aa,$bb,$bb,$bb,$bb,$bb,$bb,$bb,$aa
	dc.b $aa,$aa,$aa,$99,$99,$99,$88,$88,$77,$77,$77,$66,$66,$55,$55,$44,$44,$44
	dc.b $33,$33,$33,$33,$33,$22,$22,$22,$33,$33,$33,$33,$33,$33,$44,$44,$44,$55
	dc.b $55,$55,$66,$66,$66,$77,$77,$77,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $77,$77,$77,$66,$66,$66,$55,$55,$44,$44,$33,$33,$22,$22,$22,$11,$11,$11
	dc.b $11,$11,$11,$11,$11,$11,$11,$11,$11,$22,$22,$33,$33,$44,$44,$55,$55,$66
	dc.b $66,$66,$77,$77,$88,$88,$88,$88,$99,$99,$99,$99,$88,$88,$88,$88,$88,$77
	dc.b $77,$77,$66,$66,$66,$55,$55,$55,$55,$44,$44,$44,$44,$44,$55,$55,$55,$66
	dc.b $66,$77,$77,$88,$88,$99,$aa,$aa,$bb,$cc,$cc,$dd,$dd,$dd,$ee,$ee,$ee,$ee
	dc.b $ee,$ee,$ee,$ee,$dd,$dd,$cc,$cc,$bb,$bb,$aa,$aa,$99,$88,$88,$88,$77,$77
	dc.b $77,$77,$77,$77,$77,$77,$77,$77,$88,$88,$88,$99,$99,$99,$aa,$aa,$aa,$aa
	dc.b $aa,$aa,$aa,$99,$99,$99,$88,$77,$77,$66,$55,$44,$44,$33,$22,$22,$11,$11
	dc.b $11,$11,$11,$11,$11,$11,$22,$22,$55,$66,$66,$77,$88,$99,$99,$aa,$bb,$bb
	dc.b $bb,$bb,$bb,$bb,$bb,$bb,$aa,$aa,$99,$99,$88,$88,$88,$88,$77,$77,$88,$88
	dc.b $88,$88,$99,$99,$aa,$aa,$bb,$bb,$bb,$cc,$cc,$cc,$bb,$bb,$aa,$aa,$99,$88
	dc.b $77,$66,$55,$66,$77,$88,$99,$aa,$bb,$bb,$bb,$cc,$cc,$bb,$bb,$bb,$aa,$aa
	dc.b $99,$99,$99,$88,$88,$88,$88,$77,$88,$88,$88,$88,$99,$99,$aa,$aa,$bb,$bb
	dc.b $bb,$bb,$bb,$bb,$bb,$bb,$aa,$aa,$99,$88,$88,$77,$66,$55,$44,$33,$33,$22
	dc.b $22,$11,$11,$11,$11,$11,$11,$11,$22,$22,$33,$33,$44,$55,$66,$66,$77,$88
	dc.b $88,$99,$99,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$99,$99,$99,$88,$88,$88,$77,$77
	dc.b $77,$77,$77,$77,$77,$77,$77,$77,$77,$88,$88,$99,$99,$aa,$aa,$bb,$cc,$cc
	dc.b $dd,$dd,$dd,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$dd,$dd,$cc,$cc,$bb,$bb,$aa
	dc.b $99,$99,$88,$77,$77,$66,$66,$55,$55,$55,$55,$44,$44,$44,$44,$55,$55,$55
	dc.b $55,$66,$66,$66,$77,$77,$77,$88,$88,$88,$88,$99,$99,$99,$99,$99,$88,$88
	dc.b $88,$88,$77,$77,$77,$66,$66,$55,$55,$44,$44,$33,$33,$22,$22,$11,$11,$11
	dc.b $11,$11,$11,$11,$11,$11,$11,$11,$11,$22,$22,$22,$33,$33,$44,$44,$55,$55
	dc.b $66,$66,$66,$77,$77,$77,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$77,$77
	dc.b $77,$66,$66,$66,$55,$55,$55,$44,$44,$44,$33,$33,$33,$33,$33,$22,$22,$22
	dc.b $22,$33,$33,$33,$33,$33,$44,$44,$44,$55,$55,$66,$66,$66,$77,$77,$88,$88
	dc.b $99,$99,$99,$aa,$aa,$aa,$aa,$bb,$bb,$bb,$bb,$bb,$bb,$bb,$aa,$aa,$aa,$aa
	dc.b $aa,$99,$99,$99,$88,$88,$88,$77,$77,$77,$66,$66,$66,$55,$55,$55,$55,$55
	dc.b $55,$55,$55,$55,$55,$55,$55,$55,$55,$66,$66,$66,$66,$77,$77,$88,$88,$88
	dc.b $99,$99,$99,$aa,$aa,$aa,$bb,$bb,$bb,$bb,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
	dc.b $cc,$cc,$cc,$bb,$bb,$bb,$bb,$aa,$aa,$aa,$99,$99,$99,$88,$88,$88,$77,$77
	dc.b $77,$66,$66,$66,$66,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$66,$66,$66
	dc.b $66,$66,$77,$77,$77,$77,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$99,$99
	dc.b $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$fe


;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sprite0	ds.w	32*4
	dc.w	0,0
sprite1	ds.w	32*4
	dc.w	0,0
sprite2	ds.w	32*4
	dc.w	0,0
sprite3	ds.w	32*4
	dc.w	0,0
sprite4	dc.w	0,0,0,0
sprite5	dc.w	0,0,0,0
sprite6	dc.w	0,0,0,0
sprite7	dc.w	0,0,0,0


top	incbin	IronMaiden.bin	256*44*4

font	dcb.l	128,0		for `space' character
	incbin	font.bin


;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E
adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potinp	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E
dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E
bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058
bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066
bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074
dsksync	EQU   $07E
cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E
aud0vol	EQU   $0A8
aud1vol EQU   $0B8
aud2vol	EQU   $0C8
aud3vol	EQU   $0D8
bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6
bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A
bpldat	EQU   $110
spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E
spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178
spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A
spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c
spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e
color0	EQU   $180
color1 	EQU   $182
color2	EQU   $184
color4  EQU   $188
color8	EQU   $190
color16 EQU   $1A0
