	section	test,code_c




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


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
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$8380,dmacon(a6)	DMA on




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

outer.loop
	move.w	line.colour(pc),d0
	addq.w	#1,d0
	and.w	#15,d0
	move.w	d0,line.colour
	bsr	set.pixel.colour	set colour for subsequent lines

	move.w	#0,x1
	move.w	#0,y2
	move.w	#20-1,d7

inner.loop
	move.w	x1(pc),d0
	move.w	#0,d1
	move.w	#310,d2
	move.w	y2(pc),d3
	bsr	draw.line

	move.w	#310,d0
	sub.w	x1(pc),d0
	move.w	#0,d1
	move.w	#0,d2
	move.w	y2(pc),d3
	bsr	draw.line

	move.w	x1(pc),d0
	move.w	#190,d1
	move.w	#310,d2
	move.w	#190,d3
	sub.w	y2(pc),d3
	bsr	draw.line

	move.w	#310,d0
	sub.w	x1(pc),d0
	move.w	#190,d1
	move.w	#0,d2
	move.w	#190,d3
	sub.w	y2(pc),d3
	bsr	draw.line

	add.w	#16,x1
	add.w	#10,y2
	dbra	d7,inner.loop

	subq.w	#1,number
	bne	outer.loop

	bra.s	exit




number	dc.w	100




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

exit	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a1
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;""""""""""""""""""""
;" THE LINE ROUTINE "
;"		    "
;""""""""""""""""""""

draw.line
	move.l	#line,a3
	cmp.w	d3,d1
	bgt.s	y1.greater.than.y2
	beq.s	horizontal.line

	exg	d0,d2			ensure line is going upwards
	exg	d1,d3

y1.greater.than.y2
	move.w	d1,(a3)+
	move.w	d3,(a3)+
	move.w	d0,(a3)+
	move.w	d2,(a3)+

	sub.w	d0,d2			x2-x1
	sub.w	d3,d1			y1-y2
	swap	d0
	clr.w	d0			starting x * 65536
	ext.l	d2
	lsl.l	#8,d2
	divs	d1,d2
	bvs.s	gradient.overflow
	ext.l	d2
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x

gradient.overflow
	asr.l	#8,d2
	divs	d1,d2
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x
	move.l	d2,d3
	asr.l	#1,d3
	add.l	d3,d0			adjust starting x

calculate.line
	subq.w	#1,d1			count

edge.loop
	swap	d0
	move.w	d0,(a3)+
	swap	d0
	add.l	d2,d0			calculate next x value using gradient
	dbra	d1,edge.loop

line.calculated
	move.w	#$8000,(a3)
	move.l	#line,a3
	jsr	plot.line
	rts


horizontal.line
	move.w	d1,(a3)+
	move.w	d3,(a3)+
	move.w	d0,(a3)+
	move.w	d2,(a3)+
	move.w	#$8000,(a3)
	move.l	#line,a3
	jsr	plot.line
	rts


plot.line
	cmp.w	#200,2(a3)
	bcc	pl15

	move.l	a3,a2
	add.l	#8,a3
	move.w	(a2),d5
	subq.w	#1,d5
	move.w	4(a2),d4
	beq	pl5

	cmp.w	#320,d4
	bge	pl1

	move.w	(a3)+,d6
	bpl	pl6

	move.w	6(a2),d6
	bra	pl6

pl1	bne	pl15

	subq.w	#1,d4
	bra	pl3

pl2	subq.w	#1,d5
pl3	move.w	(a3)+,d6
	cmp.w	#320,d6
	beq	pl2

	tst.w	d6
	bpl	pl6

	move.w	6(a2),d6
	cmp.w	#320,d6
	beq	pl15
	bra	pl6

pl4	subq.w	#1,d5
pl5	move.w	(a3)+,d6
	beq	pl4
	bpl	pl6

	move.w	6(a2),d6
	beq	pl15

pl6	cmp.w	#200,d5
	bcc	pl15

	cmp.w	#320,d4
	bcc	pl15

	sub.l	#2,a3
	move.w	4(a2),d0
	sub.w	6(a2),d0
	bmi	ple

	move.l	screen.mem,a0
	move.w	d4,d0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0
	move.b	#0,d2
	move.w	(a3)+,d6
	bpl	pl7

	tst.b	d2
	bmi	pld

	move.b	#$80,d2
	sub.l	#2,a3
	move.w	6(a2),d6
pl7	bne	pl8

	move.w	#$ffff,d6

pl8	jsr	plot.pixel

	cmp.w	d4,d6
	bne	plb

	move.w	(a3)+,d6
	bpl	pl9

	tst.b	d2
	bmi	pld

	move.b	#$80,d2
	sub.l	#2,a3
	move.w	6(a2),d6
pl9	bne	pla

	move.w	#$ffff,d6

pla	subq.w	#1,d5
	bmi	pl15

	sub.l	#40,a0
	cmp.w	d4,d6
	beq	pl8

plb	move.w	d4,d0
	subq.w	#1,d4
	and.w	#$f,d0
	bne	plc

	tst.w	d4
	bmi	pl15

	sub.l	#2,a0
plc	bra	pl8
pld	rts


ple	move.l	screen.mem,a0
	move.w	d4,d0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0
	move.b	#0,d2
	move.w	(a3)+,d6
	bpl	plf

	tst.b	d2
	bmi	pl15

	move.b	#$80,d2
	sub.l	#2,a3
	move.w	6(a2),d6
plf	bne	pl10

	move.w	#$ffff,d6

pl10	jsr	plot.pixel

	cmp.w	d4,d6
	bne	pl13

	move.w	(a3)+,d6
	bpl	pl11

	tst.b	d2
	bmi	pl15

	move.b	#$80,d2
	sub.l	#2,a3
	move.w	6(a2),d6
pl11	bne	pl12

	move.w	#$ffff,d6

pl12	subq.w	#1,d5
	bmi	pl15

	sub.l	#40,a0
	cmp.w	d4,d6
	beq	pl10

pl13	addq.w	#1,d4
	move.w	d4,d0
	and.w	#$f,d0
	bne	pl14

	cmp.w	#320,d4
	bge	pl15

	add.l	#2,a0
pl14	bra	pl10
pl15	rts



line	ds.w	400



set.pixel.colour
	lsr.b	#1,d0
	bcs	spc1
	bclr	#6,pp1+1
	bclr	#6,pp6+1
	bra	spc2
spc1	bset	#6,pp1+1
	bset	#6,pp6+1

spc2	lsr.b	#1,d0
	bcs	spc3
	bclr	#6,pp2+1
	bclr	#6,pp7+1
	bra	spc4
spc3	bset	#6,pp2+1
	bset	#6,pp7+1

spc4	lsr.b	#1,d0
	bcs	spc5
	bclr	#6,pp3+1
	bclr	#6,pp8+1
	bra	spc6
spc5	bset	#6,pp3+1
	bset	#6,pp8+1

spc6	lsr.b	#1,d0
	bcs	spc7
	bclr	#6,pp4+1
	bclr	#6,pp9+1
	bra	spc8
spc7	bset	#6,pp4+1
	bset	#6,pp9+1
spc8	rts


plot.pixel
	move.b	d4,d0
	and.w	#$f,d0
	eor.w	#$f,d0
	cmp.w	#8,d0
	bge	pp5

pp1	bclr	d0,1(a0)
pp2	bclr	d0,8001(a0)
pp3	bclr	d0,16001(a0)
pp4	bclr	d0,24001(a0)
	rts


pp5	and.w	#7,d0
pp6	bclr	d0,(a0)
pp7	bclr	d0,8000(a0)
pp8	bclr	d0,16000(a0)
pp9	bclr	d0,24000(a0)
	rts




init.copper
	moveq	#4-1,d1
	move.l	#40*200,d2		size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.l	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffff,$fffe




;""""""""""""""""""""""
;" HARDWARE REGISTERS "
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

gfxbase		dc.l	0
old.ints	dc.w	0

x1	dc.w	0
y2	dc.w	0
line.colour	dc.w	0




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
	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee
