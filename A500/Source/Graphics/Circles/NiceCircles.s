	section	NiceCircles,code_c
	opt	o+,o2-,o3-



start	bset	#1,$bfe001		low pass filter off

	move.l	4.w,a6
	move.l	#4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screenmem

	move.l	4.w,a6
	jsr	-132(a6)		turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	andi.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz		division-by-zero exception handler
	move.l	#rteins,$14.w		set to rte instruction

	move.l	screenmem(pc),d0	set up bitplanes
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
	jsr	-552(a6)		openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		ownblitter

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

	move.l	#200-1,d0		count
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			bytes per line = 160
	lea	y.table(pc),a0
y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop



;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old
	move.l	#level3,$6c.w



circle	macro
	move.w	#\1,new.colour
	moveq	#\2,d4			radius
	move.w	#160,d5			x centre
	move.w	#100,d6			y centre
	bsr	outline.circle
	endm



	circle	1,99
	circle	2,98
	circle	3,97
	circle	4,96
	circle	5,95
	circle	6,94
	circle	7,93
	circle	8,92
	circle	9,91
	circle	10,90
	circle	11,89
	circle	12,88
	circle	13,87
	circle	14,86
	circle	15,85
	circle	14,84
	circle	13,83
	circle	12,82
	circle	11,81
	circle	10,80
	circle	9,79
	circle	8,78
	circle	7,77
	circle	6,76
	circle	5,75
	circle	4,74
	circle	3,73
	circle	2,72
	circle	1,71



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait

	btst	#6,$bfe001
	bne.s	loop



;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)		turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#4*40*200,d0
	jsr	-210(a6)		FreeMem

	bclr	#1,$bfe001		low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	move.w	#1,nextframe

	movem.l	(sp)+,d0-d7/a0-a6
rteins	rte



;"""""""""""""""""""""""""""""
;" OUTLINE CIRCLE SUBROUTINE "
;"			     "
;"""""""""""""""""""""""""""""

outline.circle				; d4.w = radius (maximum of 100)
					; d5.w = x centre, d6.w = y centre
					; new.colour.w = circle colour
	moveq	#0,d3			starting X, radius becomes Y

	bsr.s	plot.8.circle.octants

	move.w	d3,a2			save X and Y for next time
	move.w	d4,a3

	moveq	#3,d7
	sub.w	d4,d7			3-R
	sub.w	d4,d7			3-2R = first decision parameter
choose.move
	bpl.s	move.M2			when decision parameter >= 0
move.M1					; when decision parameter < 0
	addq.w	#1,d3			X+1

	cmp.w	d4,d3			X-Y
	bpl.s	end.calculate.circle	if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	a2,d2			calculate next decision parameter

	move.w	d3,a2			save X and Y for next time
	move.w	d4,a3

	add.w	d2,d2			2Xn
	add.w	d2,d2			4Xn
	add.w	d2,d7			old parameter + 4Xn
	addq.w	#6,d7			old parameter + 4Xn + 6

	bra.s	choose.move

move.M2
	addq.w	#1,d3			X+1
	subq.w	#1,d4			Y-1

	cmp.w	d4,d3			X-Y
	bpl.s	end.calculate.circle	if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	a2,d2			calculate next decision parameter
	sub.w	a3,d2

	move.w	d3,a2			save X and Y for next time
	move.w	d4,a3

	add.w	d2,d2			2(Xn-Yn)
	add.w	d2,d2			4(Xn-Yn)
	add.w	d2,d7			old parameter + 4(Xn-Yn)
	addi.w	#10,d7			old parameter + 4(Xn-Yn) + 10

	bra.s	choose.move

end.calculate.circle			; X >= Y
	bne.s	end.outline.circle	if X not equal to Y then don't plot

	bsr.s	plot.8.circle.octants	plot last points (here X = Y)
end.outline.circle
	rts



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
	bsr.s	plot.pixel

	exg	d3,d4			restore X and Y
	rts



;""""""""""""""""""""""
;" PIXEL PLOT ROUTINE "
;"		      "
;""""""""""""""""""""""

plot.pixel				; d0.w = x, d1.w = y
	tst.w	d0			check x is onscreen
	bmi.s	end.plot.pixel		less than 0 ?
	cmp.w	#320,d0
	bpl.s	end.plot.pixel		greater than 319 ?

	tst.w	d1			check y is onscreen
	bmi.s	end.plot.pixel		less than 0 ?
	cmp.w	#200,d1
	bpl.s	end.plot.pixel		greater than 199 ?

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
	move.l	screenmem(pc),a0
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



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth			4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0

	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END



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
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
nextframe	dc.w	0



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
