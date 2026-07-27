	section	StarField,code_c
	opt	o+,o2-,o3-




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#2*4*44*272,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	move.l	d0,screen1
	add.l	#4*44*272,d0
	move.l	d0,screen2


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c010,intena(a6)	enable copper interrupt


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




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
	move.w	#$2471,diwstrt(a6)
	move.w	#$34d1,diwstop(a6)
	move.w	#$30,ddfstrt(a6)
	move.w	#$d8,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	#3*44,bpl1mod(a6)
	move.w	#3*44,bpl2mod(a6)


	bsr	make.copper.lists	initialise copper

	move.l	copper1(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#272-1,d0
	moveq	#0,d1			offset starts at zero
	move.l	#4*44,d2		width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.l	d1,(a0)+
	add.l	d2,d1
	dbra	d0,y.tab.loop




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	btst	#2,potgor(a6)
	beq.s	pause

	bsr	starfield

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	bsr	swap.pointers

pause	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


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
	move.l	#2*4*44*272,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
;	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	st	next.frame

;	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

num.stars	equ	48
star.speed	equ	14
star.z.start	equ	1024



starfield
	move.l	old.stars1(pc),a2
	lea	new.stars(pc),a3
	moveq	#num.stars-1,d3

star.loop
	move.w	(a2),d0			old screen x
	move.w	2(a2),d1		old screen y
	bsr	clear.pixel		clear old pixel

	move.w	(a3)+,d0		new world x
	move.w	(a3)+,d1		new world y
	move.w	(a3),d4			new world z
	sub.w	#star.speed,(a3)+	update z, move pixel closer

	tst.w	d4
	ble.s	make.new.star		get new star if z out of range

in.range
	ext.l	d0			make x a longword
	ext.l	d1			make y a longword
	divs	d4,d0			x / z = screen x
	divs	d4,d1			y / z = screen y
	add.w	#176,d0			centre horizontally
	add.w	#136,d1			centre vertically

	tst.w	d0
	blt.s	make.new.star		get new star if x too small

	cmp.w	#352,d0
	bge.s	make.new.star		get new star if x too big

	tst.w	d1
	blt.s	make.new.star		get new star if y too small

	cmp.w	#272,d1
	bge.s	make.new.star		get new star if y too big

	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y

	ext.l	d4			make z a longword
	divs	#star.z.start/15,d4
	and.w	#15,d4
	moveq	#15,d5
	sub.w	d4,d5			calculate pixel colour (0-15)
	move.w	d5,new.colour

draw.star
	bsr.s	plot.pixel		draw new pixel

	dbra	d3,star.loop
	rts




make.new.star
	lea	random.value(pc),a0
	move.w	vhposr(a6),d0		new value
	muls	(a0),d0			multiply by old value
	add.w	#5293,d0		plus a constant
	move.w	d0,(a0)			save new value
	move.w	d0,-6(a3)		new x

	move.w	vhposr(a6),d1		new value
	muls	(a0),d1			multiply by old value
	add.w	#5293,d1		plus a constant
	move.w	d1,(a0)			save new value
	move.w	d1,-4(a3)		new y

	move.w	#star.z.start,d4	new z
	move.w	d4,-2(a3)
	bra.s	in.range



random.value
	dc.w	0




clear.pixel				; d0 = x, d1 = y
	move.l	screen1(pc),a0		; d0-d1 and a0-a1 trashed
	lea	y.table(pc),a1
	add.w	d1,d1
	add.w	d1,d1
	add.l	(a1,d1.w),a0		address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0			address of word containing pixel
	add.w	d1,d1
	move.w	pixel.masks(pc,d1.w),d0	positive mask
	not.w	d0			make negative mask

	and.w	d0,(a0)			plane1
	and.w	d0,44(a0)		plane2
	and.w	d0,88(a0)		plane3
	and.w	d0,132(a0)		plane4
	rts




plot.pixel				; d0 = x, d1 = y
	move.w	new.colour(pc),d2	; d0-d2 and a0-a1 trashed
	cmp.w	old.colour(pc),d2
	beq.s	plot2

	move.w	d2,old.colour
	lsl.w	#4,d2			16 bytes of instructions
	lea	plot.ins(pc,d2.w),a0
	lea	plot3(pc),a1
	move.l	(a0)+,(a1)+		copy instructions
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

plot2	move.l	screen1(pc),a0
	lea	y.table(pc),a1
	add.w	d1,d1
	add.w	d1,d1
	add.l	(a1,d1.w),a0		address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0			address of word containing pixel
	add.w	d1,d1
	move.w	pixel.masks(pc,d1.w),d0	positive mask
	move.w	d0,d1
	not.w	d1			make negative mask

plot3	and.w	d1,0(a0)		plane1
	and.w	d1,44(a0)		plane2
	and.w	d1,88(a0)		plane3
	and.w	d1,132(a0)		plane4
	rts



new.colour	dc.w	0
old.colour	dc.w	0



pixel.masks
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001



plot.ins
	and.w	d1,0(a0)
	and.w	d1,44(a0)
	and.w	d1,88(a0)
	and.w	d1,132(a0)

	or.w	d0,0(a0)
	and.w	d1,44(a0)
	and.w	d1,88(a0)
	and.w	d1,132(a0)

	and.w	d1,0(a0)
	or.w	d0,44(a0)
	and.w	d1,88(a0)
	and.w	d1,132(a0)

	or.w	d0,0(a0)
	or.w	d0,44(a0)
	and.w	d1,88(a0)
	and.w	d1,132(a0)

	and.w	d1,0(a0)
	and.w	d1,44(a0)
	or.w	d0,88(a0)
	and.w	d1,132(a0)

	or.w	d0,0(a0)
	and.w	d1,44(a0)
	or.w	d0,88(a0)
	and.w	d1,132(a0)

	and.w	d1,0(a0)
	or.w	d0,44(a0)
	or.w	d0,88(a0)
	and.w	d1,132(a0)

	or.w	d0,0(a0)
	or.w	d0,44(a0)
	or.w	d0,88(a0)
	and.w	d1,132(a0)

	and.w	d1,0(a0)
	and.w	d1,44(a0)
	and.w	d1,88(a0)
	or.w	d0,132(a0)

	or.w	d0,0(a0)
	and.w	d1,44(a0)
	and.w	d1,88(a0)
	or.w	d0,132(a0)

	and.w	d1,0(a0)
	or.w	d0,44(a0)
	and.w	d1,88(a0)
	or.w	d0,132(a0)

	or.w	d0,0(a0)
	or.w	d0,44(a0)
	and.w	d1,88(a0)
	or.w	d0,132(a0)

	and.w	d1,0(a0)
	and.w	d1,44(a0)
	or.w	d0,88(a0)
	or.w	d0,132(a0)

	or.w	d0,0(a0)
	and.w	d1,44(a0)
	or.w	d0,88(a0)
	or.w	d0,132(a0)

	and.w	d1,0(a0)
	or.w	d0,44(a0)
	or.w	d0,88(a0)
	or.w	d0,132(a0)

	or.w	d0,0(a0)
	or.w	d0,44(a0)
	or.w	d0,88(a0)
	or.w	d0,132(a0)



y.table	ds.l	272


old.stars1	dc.l	old.stars1.mem
old.stars1.mem	ds.w	num.stars*2

old.stars2	dc.l	old.stars2.mem
old.stars2.mem	ds.w	num.stars*2


new.stars	ds.w	num.stars*3




swap.pointers
	move.l	old.stars1(pc),d0
	move.l	old.stars2(pc),old.stars1
	move.l	d0,old.stars2

	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	d0,copper2

	move.l	d0,cop1lch(a6)		set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
;	bra.s	init.copper




init.copper
	moveq	#4-1,d1
	moveq	#44,d2			width of one bitplane

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

copper.list1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$3401,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$3401,$ff00

	dc.w	intreq,$8010

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

screen1		dc.l	0
screen2		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0




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
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
