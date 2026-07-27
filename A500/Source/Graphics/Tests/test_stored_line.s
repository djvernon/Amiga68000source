	section	test,code_c
	opt	o+


; Press right mouse button to run test


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

	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




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
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




;"""""""""""""""""""""""
;" PRE-CALCULATE LINES "
;"		       "
;"""""""""""""""""""""""

	lea	y.table(pc),a0
	move.l	screen.mem(pc),a1
	lea	lines.storage(pc),a5

	move.w	#310,a3
	move.w	#190,a4

	moveq	#0,d5			x1
	moveq	#0,d6			y2
	moveq	#20-1,d7

calc.lines
	move.w	d5,d0
	moveq	#0,d1
	move.w	a3,d2
	move.w	d6,d3
	bsr	store.line

	move.w	a3,d0
	sub.w	d5,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	d6,d3
	bsr	store.line

	move.w	d5,d0
	move.w	a4,d1
	move.w	a3,d2
	move.w	a4,d3
	sub.w	d6,d3
	bsr	store.line

	move.w	a3,d0
	sub.w	d5,d0
	move.w	a4,d1
	moveq	#0,d2
	move.w	a4,d3
	sub.w	d6,d3
	bsr	store.line

	add.w	#16,d5
	add.w	#10,d6
	dbra	d7,calc.lines




	moveq	#-1,d3
	move.w	d3,bltafwm(a6)
	move.w	#4*40,bltcmod(a6)	total width of bitplanes
	move.w	d3,bltbdat(a6)		set line mask
	move.w	#$8000,bltadat(a6)

wait.start
	btst	#2,potgor(a6)
	bne.s	wait.start




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

outer.loop
	lea	lines.storage(pc),a0
	moveq	#80-1,d7

draw.line				; using pre-calculated values
	btst	#6,dmaconr(a6)
	bne.s	draw.line

	move.w	(a0)+,bltapth+2(a6)	2 Sdelta - Ldelta
	move.w	(a0)+,bltbmod(a6)	2 Sdelta
	move.w	(a0)+,bltamod(a6)	2 Sdelta - 2 Ldelta

	move.l	(a0)+,d0
	move.l	d0,bltcpth(a6)		start address of line
	move.l	d0,bltdpth(a6)		start address of line

	move.l	(a0)+,bltcon0(a6)
	move.w	(a0)+,bltsize(a6)	start blitter

	dbra	d7,draw.line

	subq.w	#1,number
	bne.s	outer.loop

	bra.s	wait




number	dc.w	100




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


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

store.line				; store line values for blitter
	cmp.w	d2,d0
	ble.s	x1.less.than.x2

	exg	d0,d2			ensure line is going left-to-right
	exg	d1,d3

x1.less.than.x2
	sub.w	d0,d2			x2-x1
	sub.w	d1,d3			y2-y1

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x-start

	lsr.w	#3,d0			x-start offset in even bytes

	add.w	d1,d1			word offset
	add.w	(a0,d1.w),d0		add y offset

	lea	(a1,d0.w),a2		start address of line

	ror.w	#4,d4			low four bits from x-start
	or.w	#$bca,d4		USE A,C,D	D = A.B + notA.C
	swap	d4

	tst.w	d3			delta-y
	bmi.s	y2.less.than.y1

	cmp.w	d2,d3
	blt.s	dy.less.than.dx

	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	sl.size

dy.less.than.dx
	move.w	#%10001,d4
	bra.s	sl.size


y2.less.than.y1
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	dy.less.than.dx2

	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	sl.size

dy.less.than.dx2
	move.w	#%11001,d4


sl.size	move.w	d2,d1			larger delta is line length
	lsl.w	#6,d1			into correct position
	add.w	#$42,d1			length + 1, + width of two

	add.w	d3,d3			2 Sdelta
	move.w	d3,d0
	sub.w	d2,d0			2 Sdelta - Ldelta
	bge.s	no.sign

	or.w	#%1000000,d4		set SIGN flag

no.sign	move.w	d0,(a5)+		2 Sdelta - Ldelta
	move.w	d3,(a5)+		2 Sdelta
	sub.w	d2,d0
	move.w	d0,(a5)+		2 Sdelta - 2 Ldelta

	move.l	a2,(a5)+		start address of line

	move.l	d4,(a5)+		bltcon0 value
	move.w	d1,(a5)+		bltsize value
	rts




y.table	ds.w	200




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of one bitplane

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

lines.storage

;	dc.w	bltapth+2, bltbmod, bltamod
;	dc.l	bltcpth / bltdpth, bltcon0
;	dc.w	bltsize

	ds.w	80*8
