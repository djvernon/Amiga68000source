	section	BounceDot,code_c
	opt	o+,o2-



start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	move.l	#32000,d0	1*4*40*200
	move.l	#$10002,d1	clear chip
	jsr	-198(a6)	AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
;	add.l	#32000,d0
;	move.l	d0,screen2

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt
	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz	division-by-zero exception handler
	move.l	#rteins,$14.w	set to rte instruction

	move.l	screen1(pc),d0	set up bitplanes
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

	lea	coltab(pc),a0		initialise colours
	lea	$dff180,a1
	moveq	#15,d0
nextcol	move.w	(a0)+,(a1)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$f4c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#120,bpl1mod(a6)
	move.w	#120,bpl2mod(a6)



;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)	ownblitter

	move.l	gfxbase(pc),a1
	move.l	38(a1),oldcopper

	lea	$dff000,a6
	move.l	#new,cop1lc(a6)
	clr.w	copjmp1(a6)
	move.w	#$83c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.l	#199,d0		count
	moveq	#0,d1		offset starts at zero
	move.w	#160,d2		bytes per line = 160
	lea	ytable(pc),a0
ytab	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,ytab



;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old
	move.l	#level3,$6c.w



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr.s	movedot
	btst	#6,$bfe001
	bne.s	loop

	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)
	clr.w	copjmp1(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0	set SET and INTEN bits
	move.w	d0,intena(a6)	restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#32000,d0	1*4*40*200
	jsr	-210(a6)	FreeMem

	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	movem.l	(sp)+,d0-d7/a0-a6
rteins	rte



movedot	move.w	x,d0
	tst.w	xdirection
	bne.s	moveleft
moveright
	addq.w	#1,d0
	cmp.w	#320,d0
	bcs.s	xok
	not.w	xdirection
	bra.s	xok
moveleft
	subq.w	#1,d0
	bcc.s	xok
	not.w	xdirection
xok	move.w	d0,x

	move.w	y,d1
	tst.w	ydirection
	bne.s	moveleft2
moveright2
	addq.w	#1,d1
	cmp.w	#200,d1
	bcs.s	yok
	not.w	ydirection
	bra.s	yok
moveleft2
	subq.w	#1,d1
	bcc.s	yok
	not.w	ydirection
yok	move.w	d1,y

	move.w	d0,d2
	mulu	d1,d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	andi.w	#$f,d2
	move.w	d2,newcolour
	bsr	plotpixel
	rts

x	dc.w	0
y	dc.w	0
xdirection	dc.w	0
ydirection	dc.w	0



;""""""""""""""""
;" LINE ROUTINE "
;"		"
;""""""""""""""""

setline	lsl.w	#3,d0			; set colour for lines
	lea	colmasks(pc,d0.w),a0
	move.l	a0,linecol
	rts

colmasks
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000
	dc.w	$0000,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000
	dc.w	$0000,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000
	dc.w	$0000,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$0000
	dc.w	$0000,$0000,$0000,$ffff
	dc.w	$ffff,$0000,$0000,$ffff
	dc.w	$0000,$ffff,$0000,$ffff
	dc.w	$ffff,$ffff,$0000,$ffff
	dc.w	$0000,$0000,$ffff,$ffff
	dc.w	$ffff,$0000,$ffff,$ffff
	dc.w	$0000,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff


drawline			; d0 = x1, d1 = y1, d2 = x2, d3 = y2
	cmp.w	d2,d0
	bcs.s	x2gx1
	exg	d0,d2
	exg	d1,d3

x2gx1	sub.w	d0,d2
	sub.w	d1,d3
	add.w	d1,d1
	lea	ytable(pc),a1
	move.w	(a1,d1.w),d1
	moveq	#$f,d4
	and.w	d0,d4
	sub.w	d4,d0
	lsr.w	#3,d0
	add.w	d0,d1
	move.l	screen1(pc),a1
	add.w	d1,a1
	ror.w	#4,d4
	ori.w	#$bca,d4
	swap	d4
	tst.w	d3
	bmi.s	y1gy2
	cmp.w	d2,d3
	blt.s	dxgdy
	exg	d2,d3
	move.w	#1,d4
	bra.s	dlsize

dxgdy	move.w	#$11,d4
	bra.s	dlsize

y1gy2	neg.w	d3
	cmp.w	d2,d3
	blt.s	dxgdy2
	exg	d2,d3
	move.w	#5,d4
	bra.s	dlsize

dxgdy2	move.w	#$19,d4

dlsize	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#6,d1
	addq.w	#2,d1

	move.l	linecol(pc),a2

	add.w	d3,d3
	move.w	d3,d0
	sub.w	d2,d0
	bpl.s	nosign
	ori.b	#$40,d4

nosign	add.w	d2,d2

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin
	move.w	d3,bltbmod(a6)
	sub.w	d2,d3
	move.w	d3,bltamod(a6)
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#160,d3
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	moveq	#3,d2
	move.w	(a2)+,d3
	bra.s	dlstart

dlloop	lea	40(a1),a1
	move.w	(a2)+,d3

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

dlstart	move.l	a1,bltcpth(a6)
	move.l	a1,bltdpth(a6)
	move.w	d0,bltaptl(a6)
	move.l	d4,bltcon0(a6)
	move.w	d3,bltbdat(a6)
	move.w	d1,bltsize(a6)
	dbra	d2,dlloop
	rts

linecol	dc.l	0

ytable	ds.w	200



;""""""""""""""""""""""
;" PIXEL PLOT ROUTINE "
;"		      "
;""""""""""""""""""""""

plotpixel			; d0 = x, d1 = y
	tst.w	d0		check x is onscreen
	bmi.s	endplotpixel	less than 0 ?
	cmp.w	#320,d0
	bcc.s	endplotpixel	greater than 319 ?
	tst.w	d1		check y is onscreen
	bmi.s	endplotpixel	less than 0 ?
	cmp.w	#200,d1
	bcc.s	endplotpixel	greater than 199 ?

	move.w	newcolour(pc),d2
	cmp.w	oldcolour(pc),d2
	beq.s	plot2
	move.w	d2,oldcolour
	lsl.w	#4,d2		16 bytes of instructions
	lea	plotins(pc,d2.w),a0
	lea	plot3(pc),a1
	move.l	(a0)+,(a1)+	copy instructions
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

plot2	move.l	screen1(pc),a0
	lea	ytable(pc),a1
	add.w	d1,d1
	add.w	(a1,d1.w),a0	address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0		address of word containing pixel
	add.w	d1,d1
	move.w	pixelmasks(pc,d1.w),d0	positive mask
	move.w	d0,d1
	not.w	d1		make negative mask

plot3	and.w	d1,0(a0)	plane1
	and.w	d1,40(a0)	plane2
	and.w	d1,80(a0)	plane3
	and.w	d1,120(a0)	plane4
endplotpixel
	rts

newcolour	dc.w	0
oldcolour	dc.w	0

pixelmasks
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

plotins	and.w	d1,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth		4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0

	dc.w	intreq,$8010

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
potgor	equ	$016
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

screenmem	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0



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

coltab	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
