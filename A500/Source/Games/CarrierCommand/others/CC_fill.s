	section	CC_fill,code_c
	opt	o+


start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	move.w	#$01e0,$dff096	DMA off

	move.l	#screen,d0		set up bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp2l
	swap	d0
	move.w	d0,bp2h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp3l
	swap	d0
	move.w	d0,bp3h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp4l
	swap	d0
	move.w	d0,bp4h

	lea	coltab,a0		initialise colours
	lea	colours(pc),a1
	move.w	#color0,d1
	moveq	#15,d0
nextc	move.w	d1,(a1)+
	addq.w	#2,d1
	move.w	(a0)+,(a1)+
	dbra	d0,nextc


;"""""""""""""""""""""""""""""""""""""""""""""
;	SET UP SPRITE POINTERS
;
	move.l	#sprite0,d0
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
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)	ownblitter

	move.l	gfxbase,a1
	move.l	38(a1),oldcopper

	move.w	#$0080,dmacon(a5)
	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$81e0,dmacon(a5)	DMA on (bitplane, copper,
;						blitter, sprite)

;""""""""""""""""""""
;" DRAW A FEW BOXES "
;"		    "
;""""""""""""""""""""

	moveq	#3,d1	start y value
	moveq	#7,d2	8 down
	moveq	#0,d4	start colour at 0
down	moveq	#7,d3	8 wide
	moveq	#5,d0	start x value
across	bsr.s	square
	addq	#1,d4	update colour
	addi.w	#38,d0
	dbf	d3,across	next column
	addi.w	#24,d1
	dbf	d2,down	next row


;"""""""""""""""""""""""""""""
;" LOOP TO TEST MOUSE BUTTON "
;"			     "
;"""""""""""""""""""""""""""""

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	oldcopper,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.l	gfxbase,a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase,a1
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.w	#$f,dmacon(a5)		sound off
	clr.w	aud0vol(a5)
	clr.w	aud1vol(a5)
	clr.w	aud2vol(a5)
	clr.w	aud3vol(a5)
	bclr	#1,$bfe001	low pass filter on
	clr.l	d0
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" SUBROUTINES "
;	"	      "
;	"""""""""""""""

square	movem.w	d0-d4,-(sp)
	move.w	d0,d2	copy x
	addi.w	#30,d2
	jsr	setcds
	movem.w	(sp)+,d0-d4
	rts

setcds	moveq	#19,d5
	lea	coords,a0
setlop	move.w	d0,(a0)+
	move.w	d2,(a0)+
	dbf	d5,setlop
	moveq	#19,d0		20 down
	move.w	d4,d2		colour
	lea	coords,a0
	jsr	fill
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE FILL ROUTINES "
;	"		    "
;	"""""""""""""""""""""

fill	cmp.w	#16,d2
	bge	fill2
	lea	table,a2
	lsl.w	#2,d2
	move.l	(a2,d2.w),a2	set source B for colour
	lea	screen,a3
	mulu	#160,d1		ystart * bytes per row
	add.l	d1,a3		correct starting row
wblit	btst	#6,2(a5)
	bne.s	wblit
	move.w	#$7ca,bltcon0(a5)	Use B,C,D
	move.w	#0,bltcon1(a5)		nothing active
	move.w	#$ffff,bltadat(a5)	mask for fill
	moveq	#$f,d1
	move.w	#40,d7		width of one plane

floop	movem.w	(a0)+,d2-d3	get x1 and x2
	move.w	d2,d4
	lsr.w	#4,d2		number of words for x1
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	first,a1
	move.w	(a1,d4.w),d5	get first word mask
	swap	d5
	move.w	d3,d4
	lsr.w	#4,d3		number of words for x2
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	last,a1
	move.w	(a1,d4.w),d5	get last word mask
	sub.w	d2,d3		(x2 words) - (x1 words)
	blt.s	next		if negative then miss it out
	lsl.w	#1,d2		start offset in bytes
	ext.l	d2
	move.l	a3,a1
	add.l	d2,a1		start address of fill
	addq.w	#1,d3		width of fill in words
	move.w	d3,d4
	addi.w	#$100,d4	width + (height of 4)
	lsl.w	#1,d3		width in bytes
	neg.w	d3
	add.w	d7,d3		modulo value
wblit2	btst	#6,2(a5)
	bne.s	wblit2
	movem.l	d5/a1-a2,bltafwm(a5)	set mask, source C, source B
	move.w	d3,bltcmod(a5)		modulo for C
	move.w	d3,bltbmod(a5)		modulo for B
	move.w	d3,bltdmod(a5)		modulo for D
	move.l	a1,bltdpth(a5)		set source D
	move.w	d4,bltsize(a5)		start blitter
next	add.l	#160,a3		next row
	dbf	d0,floop
	rts


fill2	move.l	#$1000,d6
	btst	#0,d1
	beq.s	even
	swap	d6
even	lea	table,a2
	lsl.w	#2,d2
	move.l	(a2,d2.w),a2	set source B for colour
	lea	screen,a3
	mulu	#160,d1		ystart * bytes per row
	add.l	d1,a3		correct starting row
wblit3	btst	#6,2(a5)
	bne.s	wblit3
	move.w	#$7ca,bltcon0(a5)	Use B,C,D
	move.w	#$ffff,bltadat(a5)	mask for fill
	moveq	#$f,d1
	move.w	#40,d7		width of one plane

floop2	movem.w	(a0)+,d2-d3	get x1 and x2
	move.w	d2,d4
	lsr.w	#4,d2		number of words for x1
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	first,a1
	move.w	(a1,d4.w),d5	get first word mask
	swap	d5
	move.w	d3,d4
	lsr.w	#4,d3		number of words for x2
	and.w	d1,d4		get bottom 4 bits
	lsl.w	#1,d4
	lea	last,a1
	move.w	(a1,d4.w),d5	get last word mask
	sub.w	d2,d3		(x2 words) - (x1 words)
	blt.s	next2		if negative then miss it out
	lsl.w	#1,d2		start offset in bytes
	ext.l	d2
	move.l	a3,a1
	add.l	d2,a1		start address of fill
	addq.w	#1,d3		width of fill in words
	move.w	d3,d4
	addi.w	#$100,d4	width + (height of 4)
	lsl.w	#1,d3		width in bytes
	neg.w	d3
	add.w	d7,d3		modulo value
wblit4	btst	#6,2(a5)
	bne.s	wblit4
	move.w	d6,bltcon1(a5)
	movem.l	d5/a1-a2,bltafwm(a5)	set mask, source C, source B
	move.w	d3,bltcmod(a5)		modulo for C
	move.w	d3,bltbmod(a5)		modulo for B
	move.w	d3,bltdmod(a5)		modulo for D
	move.l	a1,bltdpth(a5)		set source D
	move.w	d4,bltsize(a5)		start blitter
	swap	d6
next2	add.l	#160,a3		next row
	dbf	d0,floop2
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bplcon0,$4200
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$f4c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon1,$0
	dc.w	bplcon2,$0
	dc.w	bpl1mod,120
	dc.w	bpl2mod,120

	dc.w	bpl1pth		4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0,spr0pth	set up sprite pointers now
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


colours	ds.w	32

	dc.w	$ffff,$fffe	END


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

;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

oldcopper	dc.l	0
gfxbase	dc.l	0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even

;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sprite0
sprite1
sprite2
sprite3
sprite4
sprite5
sprite6
sprite7	dc.w	0,0,0,0


screen	dcb.b	32000,0

coltab	dc.w	$000,$e40,$0ae,$864,$286,$ca0,$a80,$88a
	dc.w	$eee,$0a0,$04c,$8ce,$666,$a00,$e64,$a84

;"""""""""""""""""""""""""
;" DATA FOR FILL ROUTINE "
;"			 "
;"""""""""""""""""""""""""

coords	ds.w	40

table	dc.l	b2,b1,b16,b8,b10,b15,b13,b7
	dc.l	b3,b9,b11,b14,b4,b12,b5,b6
	dc.l	b17,b18,b32,b24,b26,b31,b29,b23
	dc.l	b19,b25,b27,b30,b20,b28,b21,b22
	dc.l	b49,b42,b58,b48,b59,b33,b53,b45
	dc.l	b56,b36,b50,b37,b55,b61,b39,b35
	dc.l	b51,b64,b52,b44,b34,b43,b60,b46
	dc.l	b38,b40,b62,b63,b57,b41,b54,b47

first	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1

last	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

b1	dcb.w	20,$ffff
b2	dcb.w	20,0
b3	dcb.w	20,0
b4	dcb.w	20,0
b5	dcb.w	20,0
b6	dcb.w	20,$ffff
b7	dcb.w	20,$ffff
b8	dcb.w	20,$ffff
b9	dcb.w	20,$ffff
b10	dcb.w	20,0
b11	dcb.w	20,0
b12	dcb.w	20,$ffff
b13	dcb.w	20,0
b14	dcb.w	20,$ffff
b15	dcb.w	20,$ffff
b16	dcb.w	20,0
	dcb.w	20,$ffff
	dcb.w	20,0
b17	dcb.w	20,0
	dcb.w	20,$aaaa
	dcb.w	20,$5555
b18	dcb.w	20,$5555
b19	dcb.w	20,0
b20	dcb.w	20,0
b21	dcb.w	20,0
b22	dcb.w	20,$5555
b23	dcb.w	20,$5555
b24	dcb.w	20,$5555
b25	dcb.w	20,$5555
b26	dcb.w	20,0
b27	dcb.w	20,0
b28	dcb.w	20,$5555
b29	dcb.w	20,0
b30	dcb.w	20,$5555
b31	dcb.w	20,$5555
b32	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,0
b33	dcb.w	20,0
	dcb.w	20,$ffff
b34	dcb.w	20,$aaaa
b35	dcb.w	20,0
b36	dcb.w	20,$5555
b37	dcb.w	20,$aaaa
	dcb.w	20,0
b38	dcb.w	20,$5555
b39	dcb.w	20,$5555
b40	dcb.w	20,$ffff
b41	dcb.w	20,0
b42	dcb.w	20,$aaaa
b43	dcb.w	20,$5555
	dcb.w	20,$aaaa
b44	dcb.w	20,$aaaa
b45	dcb.w	20,$ffff
	dcb.w	20,$ffff
	dcb.w	20,$5555
b46	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,$ffff
b47	dcb.w	20,$ffff
b48	dcb.w	20,$aaaa
b49	dcb.w	20,$aaaa
	dcb.w	20,$5555
	dcb.w	20,0
b50	dcb.w	20,$5555
b51	dcb.w	20,$5555
	dcb.w	20,$aaaa
	dcb.w	20,$aaaa
b52	dcb.w	20,$aaaa
b53	dcb.w	20,$5555
	dcb.w	20,$ffff
	dcb.w	20,$5555
b54	dcb.w	20,$0
b55	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,$5555
b56	dcb.w	20,$5555
	dcb.w	20,$aaaa
b57	dcb.w	20,$5555
	dcb.w	20,$ffff
	dcb.w	20,$ffff
b58	dcb.w	20,0
	dcb.w	20,$ffff
	dcb.w	20,$5555
b59	dcb.w	20,$5555
	dcb.w	20,$aaaa
	dcb.w	20,$5555
b60	dcb.w	20,0
	dcb.w	20,0
b61	dcb.w	20,$ffff
	dcb.w	20,$5555
	dcb.w	20,$aaaa
b62	dcb.w	20,$aaaa
	dcb.w	20,$ffff
	dcb.w	20,$5555
b63	dcb.w	20,$0000
	dcb.w	20,$ffff
	dcb.w	20,$ffff
b64	dcb.w	20,$5555
	dcb.w	20,$ffff
	dcb.w	20,$aaaa
	dcb.w	20,$aaaa
