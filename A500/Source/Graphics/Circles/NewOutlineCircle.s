	section	OutlineCircle,code_c
	opt	o+,o2-,o3-




start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off

	move.l	#4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	lea	graf.name(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter

	move.l	38(a6),old.copper

	move.l	screen.mem(pc),d0
	lea	copper.list(pc),a0
	bsr	init.copper

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction

	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0
set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)




;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)




;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0		count
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			bytes per line
	lea	y.table(pc),a0
y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




	move.w	#160,d5			x centre
	moveq	#100,d6			y centre




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	move.w	vhposr(a6),d0
	and.w	#15,d0
	move.w	d0,new.colour

	moveq	#0,d4
	move.b	joy0dat+1(a6),d4	radius
	bsr.s	outline.circle

;	clr.w	next.frame
;wait	tst.w	next.frame
;	beq.s	wait

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old.level3(pc),$6c.w

	move.l	old.copper(pc),cop1lch(a6)

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		DisownBlitter

	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	screen.mem(pc),a1
	move.l	#4*40*200,d0
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	move.w	#1,next.frame

	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""""""""""""""""
;" OUTLINE CIRCLE SUBROUTINE "
;"			     "
;"""""""""""""""""""""""""""""

outline.circle				; d4.w = radius (maximum of 100)
					; d5.w = x centre, d6.w = y centre
					; new.colour.w = circle colour
	moveq	#0,d3			starting X, radius becomes Y

	bsr.s	plot.8.circle.octants

	moveq	#3,d7
	sub.w	d4,d7			3-R
	sub.w	d4,d7			3-2R = first decision parameter

	bpl.s	move.M2			when decision parameter >= 0

move.M1					; when decision parameter < 0
	addq.w	#1,d3			X+1

	cmp.w	d4,d3			X-Y
	bge.s	end.outline.circle	if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	d3,d2
	add.w	d2,d2			2Xn
	add.w	d2,d2			4Xn
	add.w	d2,d7			old parameter + 4Xn
	addq.w	#2,d7			old parameter + 4Xn + 2

	bmi.s	move.M1

move.M2					; when decision parameter >= 0
	addq.w	#1,d3			X+1
	subq.w	#1,d4			Y-1

	cmp.w	d4,d3			X-Y
	bge.s	end.outline.circle	if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	d3,d2
	sub.w	d4,d2
	add.w	d2,d2			2(Xn-Yn)
	add.w	d2,d2			4(Xn-Yn)
	add.w	d2,d7			old parameter + 4(Xn-Yn)
	addq.w	#2,d7			old parameter + 4(Xn-Yn) + 2

	bmi.s	move.M1
	bra.s	move.M2

end.outline.circle			; X >= Y
	beq.s	plot.8.circle.octants	plot last points (here X = Y)

	rts				if X not equal to Y then don't plot



plot.8.circle.octants			; take advantage of symmetry
	move.w	d3,d0			X
	move.w	d4,d1			Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d3			-X
	move.w	d3,d0			-X
	move.w	d4,d1			Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d4			-Y
	move.w	d3,d0			-X
	move.w	d4,d1			-Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d3			X
	move.w	d3,d0			X
	move.w	d4,d1			-Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	exg	d3,d4			exchange X with Y

	move.w	d3,d0			-Y
	move.w	d4,d1			X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d4			-X
	move.w	d3,d0			-Y
	move.w	d4,d1			-X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d3			Y
	move.w	d3,d0			Y
	move.w	d4,d1			-X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.pixel

	neg.w	d4			X
	move.w	d3,d0			Y
	move.w	d4,d1			X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	exg	d3,d4			restore X and Y
;	bra.s	plot.pixel		directly after it




;""""""""""""""""""""""
;" PIXEL PLOT ROUTINE "
;"		      "
;""""""""""""""""""""""

plot.pixel				; d0.w = x, d1.w = y
	tst.w	d0			check x is onscreen
	bmi.s	end.plot.pixel		less than 0 ?
	cmp.w	#319,d0
	bgt.s	end.plot.pixel		greater than 319 ?

	tst.w	d1			check y is onscreen
	bmi.s	end.plot.pixel		less than 0 ?
	cmp.w	#199,d1
	bgt.s	end.plot.pixel		greater than 199 ?

	move.w	new.colour(pc),d2
	cmp.w	old.colour(pc),d2
	beq.s	plot.colour.ok
	move.w	d2,old.colour
	lsl.w	#4,d2			16 bytes of instructions
	lea	plot.ins(pc,d2.w),a0
	lea	plot.now(pc),a1
	move.l	(a0)+,(a1)+		copy instructions
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

plot.colour.ok
	move.l	screen.mem(pc),a0
	lea	y.table(pc),a1
	add.w	d1,d1
	add.w	(a1,d1.w),a0		address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0			address of word containing pixel
	add.w	d1,d1
	move.w	pixel.masks(pc,d1.w),d0	positive mask
	move.w	d0,d1
	not.w	d1			make negative mask

plot.now
	and.w	d1,0(a0)		plane1
	and.w	d1,40(a0)		plane2
	and.w	d1,80(a0)		plane3
	and.w	d1,120(a0)		plane4

end.plot.pixel
	rts



new.colour	dc.w	0
old.colour	dc.w	0



pixel.masks
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001



plot.ins
	and.w	d1,0(a0)
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




y.table	ds.w	200




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of screen in bytes
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

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




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0
old.ints	dc.w	0
old.dbz		dc.l	0
gfxbase		dc.l	0
old.copper	dc.l	0
old.level3	dc.l	0
next.frame	dc.w	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

colour.table
	dc.w	$000,$888,$fff,$800,$f00,$080,$0f0,$008
	dc.w	$00f,$880,$ff0,$088,$0ff,$808,$f0f,$c6c
