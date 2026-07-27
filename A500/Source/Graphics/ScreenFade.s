	section	ScreenFade,code_c
	opt	o+



start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt
	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz	division-by-zero exception handler
	move.l	#rteins,$14.w	set to rte instruction

	lea	screen(pc),a0		set up bitplanes
	move.l	a0,d0
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	swap	d0
	add.l	#40*200,d0

	move.w	d0,bp2l
	swap	d0
	move.w	d0,bp2h
	swap	d0
	add.l	#40*200,d0

	move.w	d0,bp3l
	swap	d0
	move.w	d0,bp3h
	swap	d0
	add.l	#40*200,d0

	move.w	d0,bp4l
	swap	d0
	move.w	d0,bp4h

	lea	$dff180,a0		initialise colours to zero
	moveq	#7,d0
	moveq	#0,d1
nextcol	move.l	d1,(a0)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$f4c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)



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

	lea	screen(pc),a0
	add.l	#4*40*200,a0		address of colour values

loop	bsr	fadedelay
	btst	#6,$bfe001
	beq.s	wait
	bsr	fadein
	btst	#6,$bfe001
	beq.s	wait
	bsr	fadedelay
	btst	#6,$bfe001
	beq.s	wait
	bsr	fadeout
	btst	#6,$bfe001
	bne.s	loop

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

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

	bclr	#1,$bfe001	low pass filter on
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



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""		; a0 = address of colour list

fadein	move.w	#1,d0		starting fade value

fadeinloop
	move.l	a0,a1
	move.w	#16-1,d1	number of colours-1
	move.w	#color0,d2	starting colour register

fadeincols
	move.w	(a1)+,d3	get next colour
	move.w	d3,d4
	move.w	d4,d5
	andi.w	#$f00,d3	red
	andi.w	#$f0,d4		green
	andi.w	#$f,d5		blue
	mulu	d0,d3		calculate new colour
	mulu	d0,d4
	mulu	d0,d5
	lsr.w	#4,d3
	lsr.w	#4,d4
	lsr.w	#4,d5
	andi.w	#$f00,d3	red
	andi.w	#$f0,d4		green
	andi.w	#$f,d5		blue
	or.w	d5,d4
	or.w	d4,d3		new colour
	move.w	d3,(a6,d2.w)	write out to colour register
	addi.w	#2,d2		next colour register
	dbra	d1,fadeincols	do all colours

	bsr.s	fadedelay	time delay

	addq.w	#1,d0
	cmp.w	#17,d0
	bne.s	fadeinloop	next fade
	rts



				; a0 = address of colour list

fadeout	move.w	#15,d0		starting fade value

fadeoutloop
	move.l	a0,a1
	move.w	#16-1,d1	number of colours-1
	move.w	#color0,d2	starting colour register

fadeoutcols
	move.w	(a1)+,d3	get next colour
	move.w	d3,d4
	move.w	d4,d5
	andi.w	#$f00,d3	red
	andi.w	#$f0,d4		green
	andi.w	#$f,d5		blue
	mulu	d0,d3		calculate new colour
	mulu	d0,d4
	mulu	d0,d5
	lsr.w	#4,d3
	lsr.w	#4,d4
	lsr.w	#4,d5
	andi.w	#$f00,d3	red
	andi.w	#$f0,d4		green
	andi.w	#$f,d5		blue
	or.w	d5,d4
	or.w	d4,d3		new colour
	move.w	d3,(a6,d2.w)	write out to colour register
	addi.w	#2,d2		next colour register
	dbra	d1,fadeoutcols	do all colours

	bsr.s	fadedelay	time delay

	dbra	d0,fadeoutloop	next fade
	rts



fadedelay
	moveq	#1,d1		two frame delay
fdelay1	clr.w	nextframe
fdwait	tst.w	nextframe
	beq.s	fdwait
	dbra	d1,fdelay1
	rts



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

	dc.w	$f501,$ff00

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

screen	incbin	Crunched/End_of_Turrican.bin
