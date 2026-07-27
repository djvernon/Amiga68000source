	section	chunky4,code


* A1200 NF		-      	0:44	-	11/sec
* A1200 VIPER 28Mhz '30 -	0:23	-	22/sec
* A1200 FLAPS 66Mhz '60	-	!?!?	-	:-)
* A1200 BIG KAHUNAS 90Mhz -	!?!?	-	;->


; Press right mouse button to run test


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2


	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#4*40*200,d0
	moveq	#1,d1			Public
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.source
	beq	exit.now


	move.l	#4*40*200,d0
	move.l	#$10002,d1		Chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.dest
	beq	exit.freemem


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit.freemem2


*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts


*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#310,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4201,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$b0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)
	move.w	#3,$1fc(a6)

	move.l	screen.dest(pc),d0	initialise copper
	lea	copper.list,a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$8380,dmacon(a6)	DMA on


	bsr	make.source.data


wait.start
	btst	#2,potgor(a6)
	bne.s	wait.start


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""


test.loop
	bsr	chunky.convert

	subq.w	#1,number
	bne.s	test.loop

	bra.s	exit


number	dc.w	500


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit	lea	$dff000,a6
	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a1
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit.freemem2
	move.l	#4*40*200,d0
	move.l	screen.dest(pc),a1
	jsr	-210(a6)		FreeMem

exit.freemem
	move.l	#4*40*200,d0
	move.l	screen.source(pc),a1
	jsr	-210(a6)		FreeMem

exit.now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

init.copper
	moveq	#4-1,d1
	move.l	#40*200,d2		size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts


make.source.data
	move.l	screen.source(pc),a0
	move.l	#$01234567,d0
	move.l	#$89abcdef,d1
	move.w	#YMAX*4-1,d2

.loop
	REPT	5
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	ENDR
	dbra	d2,.loop
	rts


	cnop	0,4


chunky.convert
	move.l	screen.source(pc),a0
	move.l	screen.dest(pc),a4
	lea	8000(a4),a3
	lea	16000(a4),a2
	lea	24000(a4),a1
	move.w	#YMAX*10-1,d7

.next.32.pixels
	moveq	#4-1,d6

.next.long.word.chunky
	move.l	(a0)+,d0

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	dbra	d6,.next.long.word.chunky

	move.l	d1,(a1)+
	move.l	d2,(a2)+
	move.l	d3,(a3)+
	move.l	d4,(a4)+
	dbra	d7,.next.32.pixels
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.source	dc.l	0
screen.dest	dc.l	0
gfxbase		dc.l	0
old.ints	dc.w	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
		even


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$011,$022,$033,$044,$055,$066,$077
	dc.w	$088,$099,$0aa,$0bb,$0cc,$0dd,$0ee,$0ff


*"""""""""""""""""""
*" THE COPPER LIST "
*"		   "
*"""""""""""""""""""
	section	copper,code_c


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


*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

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
bpl7pth	equ	$0f8
bpl7ptl	equ	$0fa
bpl8pth	equ	$0fc
bpl8ptl	equ	$0fe
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
