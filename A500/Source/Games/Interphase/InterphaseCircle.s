	section	Circle,code_c
	opt	o+,o3-




start	bset	#1,$bfe001	low pass filter off

	move.l	4,a6
	move.l	#32000,d0	4*40*200
	move.l	#$10002,d1	clear chip
	jsr	-198(a6)	AllocMem
	move.l	d0,screen

	move.l	4,a6
	jsr	-132(a6)	turn off multitasking

	move.w	#$01e0,$dff096	DMA off

	move.l	screen,d0	set up bitplanes
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

	move.l	4,a6
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

;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.l	#199,d0		count
	moveq	#0,d1		offset starts at zero
	move.w	#160,d2		bytes per line = 160
	lea	ytable,a0
ytab	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,ytab


;""""""""""""""""""""""
;" DRAW A FEW CIRCLES "
;"		      "
;""""""""""""""""""""""

	move.w	#16,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#99,d7		radius
	bsr	circle

	move.w	#32,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#93,d7		radius
	bsr	circle

	move.w	#48,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#87,d7		radius
	bsr	circle

	move.w	#64,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#81,d7		radius
	bsr	circle

	move.w	#80,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#75,d7		radius
	bsr	circle

	move.w	#96,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#69,d7		radius
	bsr	circle

	move.w	#112,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#63,d7		radius
	bsr	circle

	move.w	#128,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#57,d7		radius
	bsr	circle

	move.w	#144,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#51,d7		radius
	bsr	circle

	move.w	#160,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#45,d7		radius
	bsr	circle

	move.w	#176,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#39,d7		radius
	bsr	circle

	move.w	#192,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#33,d7		radius
	bsr	circle

	move.w	#208,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#27,d7		radius
	bsr	circle

	move.w	#224,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#21,d7		radius
	bsr	circle

	move.w	#240,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#15,d7		radius
	bsr	circle

	move.w	#0,colour
	move.w	#159,d1		x
	move.w	#99,d2		y
	move.w	#9,d7		radius
	bsr.s	circle


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
	move.l	4,a6
	jsr	-414(a6)	closelibrary

end	move.l	4,a6
	jsr	-138(a6)	turn on multitasking

	move.l	4,a6
	move.l	screen,a1
	move.l	#32000,d0	4*40*200
	jsr	-210(a6)	FreeMem

	move.w	#$f,dmacon(a5)	sound off
	clr.w	aud0vol(a5)
	clr.w	aud1vol(a5)
	clr.w	aud2vol(a5)
	clr.w	aud3vol(a5)
	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE CIRCLE ROUTINE "
;	"		     "
;	""""""""""""""""""""""

XMAX	equ	320
YMAX	equ	200

return	rts
circle	move.w	d1,d5
	add.w	d7,d5
	bmi.s	return
	move.w	d1,d5
	sub.w	d7,d5
	cmp.w	#XMAX,d5
	bge.s	return
	move.w	d2,d5
	sub.w	d7,d5
	cmp.w	#YMAX,d5
	bge.s	return
	move.w	d2,d5
	add.w	d7,d5
	bmi.s	return
	cmp.w	#YMAX-1,d5
	ble.s	circ1
	move.w	#YMAX-1,d5
circ1	lea	coords(pc),a3
	tst.w	d2
	bpl.s	circ2
	move.w	d7,d0
	move.w	d2,d7
	muls	d0,d0
	muls	d2,d2
	sub.l	d2,d0
	bsr	circ10
	swap	d2
	add.w	d7,d2
	neg.w	d2
	add.w	d7,d7
	subq.w	#1,d7
	clr.w	(a3)+
	bra.s	circA

circ2	sub.w	d7,d2
	bpl.s	circ3
	move.w	d7,d0
	add.w	d2,d7
	move.w	d7,d2
	muls	d0,d0
	muls	d2,d2
	sub.l	d2,d0
	bsr	circ10
	swap	d2
	add.w	d7,d2
	neg.w	d2
	clr.w	(a3)+
	bra.s	circ4

circ3	move.w	d2,(a3)+
	sub.w	d2,d5
	moveq	#0,d4
	move.w	d7,d2
	neg.w	d2
circ4	add.w	d7,d7
	subq.w	#1,d7
circ5	move.w	d4,d0
	add.w	d0,d0
	addq.w	#1,d0
	add.w	d0,d2
	bgt.s	circ7
circ6	addq.w	#1,d4
	addq.w	#2,d0
	add.w	d0,d2
	ble.s	circ6

circ7	sub.w	d0,d2
	move.w	d1,d3
	sub.w	d4,d3
	bpl.s	circ8
	moveq	#0,d3
circ8	swap	d3
	move.w	d1,d3
	add.w	d4,d3
	cmp.w	#XMAX-1,d3
	ble.s	circ9
	move.w	#XMAX-1,d3
circ9	move.l	d3,(a3)+
	sub.w	d7,d2
	subq.w	#2,d7
	dbmi	d5,circ5
	subq.w	#1,d5
	bmi.s	circF

circA	tst.w	d2
	ble.s	circC
	moveq	#-1,d0
	sub.w	d4,d0
	sub.w	d4,d0
circB	addq.w	#2,d0
	add.w	d0,d2
	dble	d4,circB
	subq.w	#1,d4
circC	move.w	d1,d3
	sub.w	d4,d3
	bpl.s	circD
	moveq	#0,d3
circD	swap	d3
	move.w	d1,d3
	add.w	d4,d3
	bmi.s	circF
	cmp.w	#XMAX-1,d3
	ble.s	circE
	move.w	#XMAX-1,d3
circE	move.l	d3,(a3)+
	sub.w	d7,d2
	subq.w	#2,d7
	dbf	d5,circA
circF	bra.s	fill

circ10	moveq	#15,d3
	move.l	#$40000000,d4
	move.l	d0,d2
	clr.w	d2
	swap	d2
circ11	swap	d4
	sub.l	d4,d2
	bcc.s	circ12
	add.l	d4,d2
	swap	d4
	add.w	d4,d4
	add.w	d0,d0
	addx.l	d2,d2
	add.w	d0,d0
	addx.l	d2,d2
	dbf	d3,circ11
	rts

circ12	swap	d4
	add.w	d4,d4
	addq.w	#1,d4
	add.w	d0,d0
	addx.l	d2,d2
	add.w	d0,d0
	addx.l	d2,d2
	dbf	d3,circ11
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE FILL ROUTINE "
;	"		   "
;	""""""""""""""""""""

fill	st	(a3)+		end-of-fill marker
	lea	coords,a3
	move.l	screen,a1
	lea	ytable,a2
	move.w	(a3)+,d1	get y-start
	add.w	d1,d1
	add.w	(a2,d1.w),a1	add y offset
	move.w	colour,d0
	lsr.w	#2,d0
	move.l	table(pc,d0.w),a4
	move.w	(a3)+,d2	first x-start
	bpl.s	fillit
	rts

table	dc.l	b7,b6,b15,b5,b9,b14,b11,b4
	dc.l	b8,b16,b13,b12,b1,b10,b2,b3

first	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1

fillit	move.w	(a3)+,d3	next x-end
	sub.w	d2,d3
	blt.s	nextline
	moveq	#$f,d4
	and.w	d2,d4		low four bits from x start
	sub.w	d4,d2		x-start offset in multiples of 16
	lsr.w	#3,d2		x-start offset in even bytes
	lea	(a1,d2.w),a2	start of fill
	add.w	d4,d3
	add.w	d4,d4
	move.w	first(pc,d4.w),d2
	swap	d2
	moveq	#$f,d4
	and.w	d3,d4
	add.w	d4,d4
	move.w	last(pc,d4.w),d2
	lsr.w	#4,d3
	addq.w	#1,d3
	moveq	#40,d4
	sub.w	d3,d4
	sub.w	d3,d4
	or.w	#$100,d3	height = 4
bltfin	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin
	move.l	d2,bltafwm(a5)		first and last word masks
	move.w	#$ffff,bltadat(a5)	mask for all planes
	move.w	d4,bltcmod(a5)
	move.w	d4,bltbmod(a5)
	move.w	d4,bltdmod(a5)
	move.l	a4,bltbpth(a5)		masks for each plane
	move.l	a2,bltcpth(a5)		start address
	move.l	a2,bltdpth(a5)		start address
	move.l	#$7ca0000,bltcon0(a5)	USE B,C,D ; LFx: $CA
	move.w	d3,bltsize(a5)
nextline
	lea	160(a1),a1	next line
	move.w	(a3)+,d2	next x-start
	bpl.s	fillit
	rts

last	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

colour	dc.w	0

ytable	ds.w	200

coords	ds.w	401

b1	dcb.w	20,0
b2	dcb.w	20,0
b3	dcb.w	20,$ffff
b4	dcb.w	20,$ffff
b5	dcb.w	20,$ffff
b6	dcb.w	20,$ffff
b7	dcb.w	20,0
b8	dcb.w	20,0
b9	dcb.w	20,0
	dcb.w	20,0
b10	dcb.w	20,$ffff
b11	dcb.w	20,0
b12	dcb.w	20,$ffff
	dcb.w	20,$ffff
b13	dcb.w	20,0
b14	dcb.w	20,$ffff
b15	dcb.w	20,0
b16	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0
	dcb.w	20,$ffff


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

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
joy0dat	equ	$00A
joy1dat	equ	$00C
clxdat	equ	$00E
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potinp	equ	$016
serdatr	equ	$018
dskbytr	equ	$01A
intenar	equ	$01C
intreqr	equ	$01E
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02A
vhposw	equ	$02C
copcon	equ	$02E
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03A
strhor	equ	$03C
strlong	equ	$03E
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08A
copins	equ	$08C
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
aud0vol	equ	$0A8
aud1vol	equ	$0B8
aud2vol	equ	$0C8
aud3vol	equ	$0D8
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bpl5pth	equ	$0F0
bpl5ptl	equ	$0F2
bpl6pth	equ	$0F4
bpl6ptl	equ	$0F6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
bpldat	equ	$110
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12A
spr3pth	equ	$12C
spr3ptl	equ	$12E
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13A
spr7pth	equ	$13C
spr7ptl	equ	$13E
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14A
spr2ctl	equ	$152
spr3ctl	equ	$15A
spr4ctl	equ	$162
spr5ctl	equ	$16A
spr6ctl	equ	$172
spr7ctl	equ	$17A
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
color16	equ	$1A0


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0


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

coltab	dc.w	$000,$333,$777,$bbb,$fff,$700,$b00,$f00
	dc.w	$007,$00b,$00f,$070,$0b0,$0f0,$f0f,$0ff
