	section	Sprite,code_c
	opt	o+




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#4*40*256,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem


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
	moveq	#16-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$2cc1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#%100100,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

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

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87e0,dmacon(a6)	DMA on




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	position.sprites

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	btst	#6,$bfe001
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
	move.l	#4*40*256,d0
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

position.sprites
	move.b	joy0dat+1(a6),d0	x mouse movement
	move.b	d0,d1
	sub.b	register.mouse.x(pc),d0
	move.b	d1,register.mouse.x
	ext.w	d0
	add.w	sprite.horiz(pc),d0
	bpl.s	horiz.ok

	moveq	#0,d0
	bra.s	horiz.ok2

horiz.ok
	cmp.w	#511,d0
	ble.s	horiz.ok2

	move.w	#511,d0

horiz.ok2
	move.w	d0,sprite.horiz



	move.b	joy0dat(a6),d1		y mouse movement
	move.b	d1,d2
	sub.b	register.mouse.y(pc),d1
	move.b	d2,register.mouse.y
	ext.w	d1
	add.w	sprite.vert(pc),d1

	cmp.w	#26,d1
	bge.s	vert.ok

	moveq	#26,d1
	bra.s	vert.ok2

vert.ok	cmp.w	#280,d1
	ble.s	vert.ok2

	move.w	#280,d1

vert.ok2
	move.w	d1,sprite.vert



	moveq	#64,d2			height of sprites
	add.w	d1,d2

	lsl.w	#8,d2
	bcc.s	no.vstop8

	addq.w	#2,d2			set vstop bit 8

no.vstop8
	lsl.w	#8,d1
	bcc.s	no.vstart8

	addq.w	#4,d2			set vstart bit 8

no.vstart8
	lsr.w	#1,d0
	bcc.s	no.hstart0

	addq.w	#1,d2			set hstart bit 0

no.hstart0
	move.b	d0,d1

	or.w	#%10000000,d2		set attach bit



	move.w	d1,sprite0
	move.w	d1,sprite1
	addq.b	#8,d1
	move.w	d1,sprite2
	move.w	d1,sprite3
	addq.b	#8,d1
	move.w	d1,sprite4
	move.w	d1,sprite5
	addq.b	#8,d1
	move.w	d1,sprite6
	move.w	d1,sprite7

	move.w	d2,sprite0+2
	move.w	d2,sprite1+2
	move.w	d2,sprite2+2
	move.w	d2,sprite3+2
	move.w	d2,sprite4+2
	move.w	d2,sprite5+2
	move.w	d2,sprite6+2
	move.w	d2,sprite7+2



	move.w	sprite.horiz(pc),d0
	bsr	make.decimal
	moveq	#14,d0
	moveq	#120,d1
	lea	decimal.text(pc),a0
	bsr.s	print

	move.w	sprite.vert(pc),d0
	bsr	make.decimal
	moveq	#19,d0
	moveq	#120,d1
	lea	decimal.text(pc),a0
;	bra.s	print




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

print	move.l	screen.mem(pc),a1	d0 = x, d1 = y
	mulu	#160,d1			a0 = text ending with 0
	add.l	d1,a1
	add.w	d0,a1			screen start address

print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2

char.loop
	move.b	(a3)+,d1
	move.b	d1,(a2)			copy byte of character, bitplane 1
	move.b	d1,40(a2)		bitplane 2
	move.b	d1,80(a2)		bitplane 3
	move.b	d1,120(a2)		bitplane 4

	lea	160(a2),a2		next screen line
	dbra	d0,char.loop

	addq.l	#1,a1			next column
	bra.s	print.loop

end.print
	rts



; Spectrum font, characters 32-126, each 8*8 pixels

font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$00,$04,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00




make.hex
	lea	hex.text(pc),a0		d0.l = number
	lea	hex.digits(pc),a1
	moveq	#0,d1

make.hex.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	make.hex.loop
	rts



hex.digits
	dc.b	'0123456789ABCDEF'



hex.text
	ds.b	9
	even




make.decimal
	and.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros

make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	add.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)			save units
	rts



decimal.text
	ds.b	6




frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter(pc),d1	get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#'.',-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#16,d0			x
	moveq	#6,d1			y
	bra	print



old.counter
	dc.w	0



frames.text
	dc.b	'F/S     ',0
	even




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

	dc.w	spr0pth
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

	dc.w	$2c01,$ff00
	dc.w	color0,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$2c01,$ff00
	dc.w	color0,$008

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

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0

sprite.horiz	dc.w	256		start in centre of screen
sprite.vert	dc.w	140

register.mouse.x	dc.b	0
register.mouse.y	dc.b	0




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

sprite0	dc.w	$8c80,$cc00
	dc.w	$7de0,$0ff8
	dc.w	$3ef3,$09f8
	dc.w	$0f62,$04fd
	dc.w	$018b,$037e
	dc.w	$68df,$49bc
	dc.w	$7e65,$36de
	dc.w	$56ab,$24de
	dc.w	$4693,$7e2f
	dc.w	$69c9,$6f17
	dc.w	$0ec9,$0f8f
	dc.w	$67e5,$1fd7
	dc.w	$3ff0,$4def
	dc.w	$07ae,$7f47
	dc.w	$72db,$0f6e
	dc.w	$7e77,$06f3
	dc.w	$7d7d,$6017
	dc.w	$7ffb,$7fed
	dc.w	$41dc,$3e75
	dc.w	$5fab,$3234
	dc.w	$49f2,$3602
	dc.w	$7ffc,$7ff4
	dc.w	$7ffe,$7ffe
	dc.w	$7fe4,$7ffc
	dc.w	$3ff0,$7ffe
	dc.w	$7c40,$03be
	dc.w	$3e0c,$41f3
	dc.w	$7fca,$7ffb
	dc.w	$7feb,$7f77
	dc.w	$3fab,$7ff7
	dc.w	$7e09,$01ff
	dc.w	$7e9b,$217d
	dc.w	$7fef,$7fed
	dc.w	$7ff3,$201d
	dc.w	$3e17,$41e7
	dc.w	$7fc2,$3fb4
	dc.w	$7f8f,$007c
	dc.w	$7ff7,$07ec
	dc.w	$7fc4,$073f
	dc.w	$7e01,$01ff
	dc.w	$7904,$06fb
	dc.w	$3c82,$437d
	dc.w	$7ffc,$7de7
	dc.w	$7ff0,$7f3f
	dc.w	$1964,$669b
	dc.w	$7ffe,$0001
	dc.w	$57e0,$285f
	dc.w	$7fe0,$7fff
	dc.w	$1300,$6cff
	dc.w	$0002,$7fff
	dc.w	$6208,$1df7
	dc.w	$7fff,$0000
	dc.w	$13e4,$6c1b
	dc.w	$7ff9,$7fc7
	dc.w	$3ffc,$7fe3
	dc.w	$68f8,$1747
	dc.w	$7fff,$7fff
	dc.w	$7fc7,$7fc5
	dc.w	$7ffc,$0003
	dc.w	$7ede,$0121
	dc.w	$6fff,$7c62
	dc.w	$423f,$7fd6
	dc.w	$7ffd,$0002
	dc.w	$7e7f,$0180
	dc.w	$3f3f,$40c0
	dc.w	$0000,$0000

sprite1	dc.w	$8c80,$cc80
	dc.w	$71ff,$01e0
	dc.w	$36ff,$40f0
	dc.w	$0b7a,$7000
	dc.w	$408d,$7c38
	dc.w	$785f,$3604
	dc.w	$7e27,$0908
	dc.w	$57ab,$0f06
	dc.w	$4793,$47c5
	dc.w	$69c9,$79e3
	dc.w	$0ee1,$7e72
	dc.w	$6761,$0678
	dc.w	$33b0,$0119
	dc.w	$00ac,$001c
	dc.w	$709b,$0006
	dc.w	$0716,$781e
	dc.w	$62ed,$7d03
	dc.w	$7ff3,$7c22
	dc.w	$419c,$0017
	dc.w	$4dc1,$000b
	dc.w	$49fe,$0001
	dc.w	$7ff9,$1e02
	dc.w	$7ff9,$7fc8
	dc.w	$7ffe,$7fe5
	dc.w	$7ffd,$3ff1
	dc.w	$7c40,$0001
	dc.w	$7e0c,$001c
	dc.w	$7fde,$0024
	dc.w	$7f7b,$60cd
	dc.w	$7fbe,$3008
	dc.w	$7e1d,$000b
	dc.w	$5e9f,$000b
	dc.w	$7fff,$4037
	dc.w	$2017,$7ffb
	dc.w	$7e17,$000f
	dc.w	$404f,$000a
	dc.w	$7f8f,$000e
	dc.w	$07ef,$7813
	dc.w	$073e,$78c0
	dc.w	$7e00,$0000
	dc.w	$7904,$0000
	dc.w	$7c82,$0000
	dc.w	$7de7,$721c
	dc.w	$7f3f,$7ef0
	dc.w	$1964,$0000
	dc.w	$7ffe,$0000
	dc.w	$57a0,$0000
	dc.w	$7fff,$7fe0
	dc.w	$6cff,$1300
	dc.w	$7fff,$0002
	dc.w	$6208,$0000
	dc.w	$7fff,$0000
	dc.w	$13e4,$0000
	dc.w	$7fc1,$71bf
	dc.w	$7fe0,$38df
	dc.w	$68b8,$0000
	dc.w	$7fff,$0000
	dc.w	$7fc5,$7fff
	dc.w	$7ffc,$0000
	dc.w	$7ede,$0000
	dc.w	$7c62,$6fff
	dc.w	$7fd6,$423f
	dc.w	$7ffd,$0000
	dc.w	$7e7f,$0000
	dc.w	$7f3f,$0000
	dc.w	$0000,$0000
	
sprite2	dc.w	$8c88,$cc00
	dc.w	$69d8,$f1e0
	dc.w	$793b,$752b
	dc.w	$7d5a,$180b
	dc.w	$ad5c,$305c
	dc.w	$b5a8,$7aa6
	dc.w	$acae,$6fa8
	dc.w	$ccc4,$2ffe
	dc.w	$ec8c,$8bfe
	dc.w	$58a0,$bff7
	dc.w	$f020,$d707
	dc.w	$b390,$d03f
	dc.w	$de90,$cd37
	dc.w	$6800,$fba7
	dc.w	$8806,$fb9f
	dc.w	$8440,$f1cf
	dc.w	$a000,$701f
	dc.w	$081f,$881f
	dc.w	$8a00,$8aff
	dc.w	$499e,$8f9e
	dc.w	$0784,$0787
	dc.w	$8118,$2f1f
	dc.w	$d81c,$9fdc
	dc.w	$1fc3,$3bdf
	dc.w	$2ffb,$67fb
	dc.w	$4c7d,$cfff
	dc.w	$88ed,$8dfd
	dc.w	$a853,$bfdb
	dc.w	$9857,$9bbf
	dc.w	$65e3,$fa13
	dc.w	$143b,$87eb
	dc.w	$0fe6,$8476
	dc.w	$0fe5,$84ed
	dc.w	$8fed,$002d
	dc.w	$8fcd,$c05d
	dc.w	$0fdf,$405f
	dc.w	$87de,$c07f
	dc.w	$83f8,$c13f
	dc.w	$81e2,$e13f
	dc.w	$c1fc,$601d
	dc.w	$c1f7,$b017
	dc.w	$41e5,$d027
	dc.w	$01e0,$d01f
	dc.w	$1180,$d967
	dc.w	$7121,$8de5
	dc.w	$11e0,$f3e7
	dc.w	$0073,$f977
	dc.w	$3e3f,$febf
	dc.w	$010e,$fd4f
	dc.w	$40cf,$ffef
	dc.w	$002e,$ffaf
	dc.w	$e11f,$1f7f
	dc.w	$0177,$fe77
	dc.w	$c1ef,$3fff
	dc.w	$e5fa,$9e7a
	dc.w	$046a,$fe7a
	dc.w	$047c,$267c
	dc.w	$f873,$3a71
	dc.w	$371f,$cf1f
	dc.w	$75df,$8fdd
	dc.w	$ffce,$f5ce
	dc.w	$fd63,$7fe3
	dc.w	$c5ff,$3ffd
	dc.w	$f476,$0ef2
	dc.w	$fa3b,$0779
	dc.w	$0000,$0000
	
sprite3	dc.w	$8c88,$cc80
	dc.w	$eff8,$61c7
	dc.w	$fb33,$31e4
	dc.w	$9612,$71e6
	dc.w	$fe7e,$019f
	dc.w	$b4d2,$0109
	dc.w	$a8d8,$100f
	dc.w	$e8de,$1005
	dc.w	$6cfe,$100d
	dc.w	$58f8,$0008
	dc.w	$b04c,$88f8
	dc.w	$b374,$0cc0
	dc.w	$fefc,$0448
	dc.w	$486e,$c458
	dc.w	$8806,$4460
	dc.w	$0840,$6e70
	dc.w	$a81d,$6fe0
	dc.w	$781f,$77fe
	dc.w	$faff,$7700
	dc.w	$6f9f,$f9fd
	dc.w	$d787,$fffb
	dc.w	$d09f,$f067
	dc.w	$e02f,$4003
	dc.w	$5bc3,$8ce0
	dc.w	$bffb,$1c37
	dc.w	$7fff,$3c59
	dc.w	$da3f,$700b
	dc.w	$e43b,$4017
	dc.w	$7a6f,$0442
	dc.w	$65f3,$000e
	dc.w	$7feb,$f836
	dc.w	$7c77,$fbe9
	dc.w	$7cf7,$fbfa
	dc.w	$783f,$ffd2
	dc.w	$b86f,$7ff7
	dc.w	$bc7f,$7feb
	dc.w	$be5f,$7ff2
	dc.w	$bf3d,$7fe8
	dc.w	$9f3f,$7fe2
	dc.w	$de1d,$3ff2
	dc.w	$0e1f,$7ff8
	dc.w	$6e3f,$5ff9
	dc.w	$ee3f,$1fe0
	dc.w	$f707,$1ff8
	dc.w	$63ff,$1f1b
	dc.w	$1dff,$0798
	dc.w	$06f7,$038b
	dc.w	$ff7f,$39c7
	dc.w	$fbbf,$00f6
	dc.w	$fcdf,$4031
	dc.w	$007f,$001e
	dc.w	$e1df,$0007
	dc.w	$00ff,$015f
	dc.w	$3de8,$c090
	dc.w	$9c75,$e5c0
	dc.w	$0465,$0590
	dc.w	$dc77,$fd84
	dc.w	$397c,$fd82
	dc.w	$3618,$06e8
	dc.w	$7650,$0422
	dc.w	$f541,$fe30
	dc.w	$7dec,$e010
	dc.w	$c570,$0140
	dc.w	$f7f9,$0150
	dc.w	$fbfc,$00a8
	dc.w	$0000,$0000
	
sprite4	dc.w	$8c90,$cc00
	dc.w	$3789,$37b5
	dc.w	$02d3,$feeb
	dc.w	$0033,$ca43
	dc.w	$0036,$cc06
	dc.w	$026f,$4a07
	dc.w	$83fc,$cfed
	dc.w	$719e,$ffbf
	dc.w	$712c,$f98b
	dc.w	$77cd,$ffca
	dc.w	$442d,$4fae
	dc.w	$424a,$4f8c
	dc.w	$01db,$055c
	dc.w	$305d,$34d9
	dc.w	$b31a,$b5f4
	dc.w	$b3cd,$b5f9
	dc.w	$8388,$b7ac
	dc.w	$8387,$ffaf
	dc.w	$0005,$fffd
	dc.w	$c408,$bc0c
	dc.w	$023a,$7a3d
	dc.w	$1c3d,$e3fe
	dc.w	$0800,$0ff9
	dc.w	$e032,$fb82
	dc.w	$d873,$fe66
	dc.w	$140f,$ffe7
	dc.w	$c717,$3baf
	dc.w	$1a37,$d9d9
	dc.w	$681b,$4dfb
	dc.w	$77a4,$405f
	dc.w	$7e06,$3786
	dc.w	$7f82,$3bda
	dc.w	$5fc2,$77de
	dc.w	$2fe3,$5ef1
	dc.w	$fbe1,$ed7f
	dc.w	$e863,$bb1a
	dc.w	$b8c0,$f330
	dc.w	$1c00,$ffe0
	dc.w	$0251,$db90
	dc.w	$2543,$fd40
	dc.w	$a273,$bc31
	dc.w	$e3d7,$e653
	dc.w	$85e7,$8067
	dc.w	$90cf,$8347
	dc.w	$bc78,$a89c
	dc.w	$0efd,$f61d
	dc.w	$28fe,$f0bf
	dc.w	$f0da,$f8e9
	dc.w	$089b,$ccd9
	dc.w	$e8f0,$ecf9
	dc.w	$d964,$f9e9
	dc.w	$f9ca,$fbfd
	dc.w	$eff8,$ffdf
	dc.w	$fd60,$fdf7
	dc.w	$ee40,$a867
	dc.w	$ee60,$f2e7
	dc.w	$ca21,$8822
	dc.w	$b159,$015a
	dc.w	$fb63,$e367
	dc.w	$8679,$0877
	dc.w	$ef4a,$e347
	dc.w	$e663,$e86e
	dc.w	$e66b,$c067
	dc.w	$a7ed,$01e7
	dc.w	$53f6,$00f3
	dc.w	$0000,$0000
	
sprite5	dc.w	$8c90,$cc80
	dc.w	$078d,$cbc3
	dc.w	$7adb,$0187
	dc.w	$fc3b,$0187
	dc.w	$cc36,$33cf
	dc.w	$3277,$858e
	dc.w	$c3fc,$b22e
	dc.w	$c9be,$415c
	dc.w	$c928,$475c
	dc.w	$fff9,$423c
	dc.w	$7fed,$c05c
	dc.w	$4f6b,$f238
	dc.w	$359b,$cb30
	dc.w	$781f,$b338
	dc.w	$c91a,$0221
	dc.w	$c9dd,$03f2
	dc.w	$fba8,$0077
	dc.w	$bfaf,$0078
	dc.w	$fffd,$001a
	dc.w	$bc0c,$47f3
	dc.w	$fe3f,$fdc6
	dc.w	$fc03,$fc03
	dc.w	$f807,$f001
	dc.w	$e3bb,$047e
	dc.w	$dffe,$f9bd
	dc.w	$ffef,$4019
	dc.w	$785f,$c41f
	dc.w	$fc07,$1a06
	dc.w	$7414,$f220
	dc.w	$7fa4,$f802
	dc.w	$3787,$ee79
	dc.w	$3bff,$efbd
	dc.w	$77ff,$dffd
	dc.w	$7efd,$afde
	dc.w	$fd7f,$f39e
	dc.w	$fffe,$57fd
	dc.w	$fffc,$8fff
	dc.w	$bff8,$13ff
	dc.w	$fbd8,$25ff
	dc.w	$f540,$5abf
	dc.w	$f431,$1fef
	dc.w	$fe53,$9fef
	dc.w	$8667,$ffde
	dc.w	$b347,$fdfe
	dc.w	$fd9e,$5f79
	dc.w	$fe1b,$0df9
	dc.w	$f0be,$0ffa
	dc.w	$f8f4,$f7d3
	dc.w	$ccf9,$37be
	dc.w	$ecf0,$d7be
	dc.w	$f964,$df9e
	dc.w	$fbce,$feb2
	dc.w	$effa,$f0f0
	dc.w	$0173,$03a8
	dc.w	$1047,$41b8
	dc.w	$0367,$13d8
	dc.w	$3421,$41ff
	dc.w	$4f59,$90f7
	dc.w	$076b,$02f8
	dc.w	$707d,$89fa
	dc.w	$134e,$02f9
	dc.w	$106b,$09f3
	dc.w	$586f,$61fa
	dc.w	$59ff,$807c
	dc.w	$acff,$403e
	dc.w	$0000,$0000
	
sprite6	dc.w	$8c98,$cc00
	dc.w	$d980,$e7bf
	dc.w	$9bc0,$e3bf
	dc.w	$b7ff,$c387
	dc.w	$6f2b,$87cc
	dc.w	$67e0,$8408
	dc.w	$4da4,$8e37
	dc.w	$3f4f,$9c68
	dc.w	$bad7,$3c58
	dc.w	$75af,$28e0
	dc.w	$7f90,$612b
	dc.w	$7a4f,$713f
	dc.w	$a62c,$80ef
	dc.w	$018f,$0070
	dc.w	$001c,$04ef
	dc.w	$0138,$4247
	dc.w	$28cf,$a13f
	dc.w	$18c3,$da47
	dc.w	$9d00,$e8df
	dc.w	$16c8,$d737
	dc.w	$0bff,$c880
	dc.w	$89ff,$4a40
	dc.w	$1fcf,$b8ef
	dc.w	$21af,$07af
	dc.w	$7aff,$d950
	dc.w	$b39f,$ff70
	dc.w	$dc0f,$c9b8
	dc.w	$e9bf,$ffe8
	dc.w	$e13f,$b97f
	dc.w	$70bf,$eec0
	dc.w	$18df,$37e0
	dc.w	$3c6f,$06f0
	dc.w	$1dff,$577f
	dc.w	$83f0,$dfff
	dc.w	$d03f,$41c0
	dc.w	$623f,$6dc0
	dc.w	$461f,$75e0
	dc.w	$0060,$35df
	dc.w	$9000,$5fff
	dc.w	$f7ff,$e818
	dc.w	$dfdb,$e024
	dc.w	$0623,$07ff
	dc.w	$0fe0,$0fff
	dc.w	$4380,$439f
	dc.w	$06ff,$7900
	dc.w	$7c03,$8000
	dc.w	$2f27,$d0d8
	dc.w	$ffcc,$ff9f
	dc.w	$dfc3,$de7f
	dc.w	$6fe1,$ef3f
	dc.w	$ffc3,$03bc
	dc.w	$ffff,$0000
	dc.w	$1fbf,$e040
	dc.w	$c624,$ffff
	dc.w	$e312,$ffff
	dc.w	$8df3,$73fc
	dc.w	$8760,$ffff
	dc.w	$ff1f,$efff
	dc.w	$bfff,$c000
	dc.w	$8307,$c4f8
	dc.w	$ffff,$d300
	dc.w	$7fff,$ffc0
	dc.w	$9f00,$fcff
	dc.w	$f808,$07f7
	dc.w	$fc04,$83fb
	dc.w	$0000,$0000
	
sprite7	dc.w	$8c98,$cc80
	dc.w	$d9a0,$81c0
	dc.w	$9fc0,$8380
	dc.w	$bfff,$0387
	dc.w	$7f3c,$070b
	dc.w	$77e8,$0e17
	dc.w	$6df7,$1c2c
	dc.w	$7fef,$1c58
	dc.w	$fbdf,$3070
	dc.w	$f7af,$10f0
	dc.w	$ff93,$11e4
	dc.w	$7e4f,$81cf
	dc.w	$be2c,$63bc
	dc.w	$19bf,$e700
	dc.w	$3950,$c600
	dc.w	$3138,$8e80
	dc.w	$5a8f,$8d14
	dc.w	$3dc7,$c078
	dc.w	$de9f,$5160
	dc.w	$5c48,$e080
	dc.w	$cf7f,$f000
	dc.w	$cdbf,$b000
	dc.w	$bbcf,$c33c
	dc.w	$a1af,$fe7f
	dc.w	$7eaf,$2000
	dc.w	$b78f,$8280
	dc.w	$ffc7,$d440
	dc.w	$fde8,$62b7
	dc.w	$7f7f,$66bf
	dc.w	$3cff,$3300
	dc.w	$1edf,$d900
	dc.w	$feef,$fd00
	dc.w	$dfff,$edc0
	dc.w	$cbff,$7770
	dc.w	$723f,$dd00
	dc.w	$7e3f,$f200
	dc.w	$5e1f,$ee00
	dc.w	$41df,$8e60
	dc.w	$3fff,$c000
	dc.w	$d7e7,$8000
	dc.w	$dfdb,$8000
	dc.w	$87ff,$7e23
	dc.w	$8fff,$7fe0
	dc.w	$c39f,$7fe0
	dc.w	$86ff,$0000
	dc.w	$7fff,$0000
	dc.w	$2f27,$0000
	dc.w	$ffbf,$01ec
	dc.w	$de7f,$7fc3
	dc.w	$6f3f,$3fe1
	dc.w	$fc43,$0000
	dc.w	$ffff,$0000
	dc.w	$1fbf,$0000
	dc.w	$ffff,$c624
	dc.w	$ffff,$6312
	dc.w	$0c03,$8000
	dc.w	$ffff,$0760
	dc.w	$efff,$3b1f
	dc.w	$bfff,$0000
	dc.w	$bb07,$8000
	dc.w	$d300,$ffff
	dc.w	$7fc0,$803f
	dc.w	$8300,$8000
	dc.w	$f808,$8000
	dc.w	$fc04,$4000
	dc.w	$0000,$0000



colour.table
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$000,$558,$001,$012,$023,$003,$310,$850
	dc.w	$640,$740,$a72,$850,$a71,$d93,$fc5,$530
