	section	Keyboard,code_c
	opt	o+




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

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	$68.w,old.level2
	move.l	#new.level2,$68.w

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c018,intena(a6)	enable copper and level2 interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

	move.w	#$03ff,dmacon(a6)	DMA off


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#16-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#%100100,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	bsr	screen.pattern


	move.l	#mouse.pointer,d0	initialise copper
	lea	copper.list(pc),a0
	move.w	d0,38(a0)
	swap	d0
	move.w	d0,34(a0)
	move.l	screen.mem(pc),d0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87e0,dmacon(a6)	DMA on




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




	move.b	joy0dat+1(a6),register.mouse.x
	move.b	joy0dat(a6),register.mouse.y




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	clear

	move.b	raw.key.code(pc),d0	print raw key code
	and.l	#$ff,d0
	bsr	make.hex
	lea	hex.text(pc),a0
	moveq	#16,d0			x
	moveq	#100,d1			y
	bsr	print

	move.w	mouse.x(pc),d0		print mouse x position
	bsr	make.decimal
	lea	decimal.text(pc),a0
	moveq	#16,d0			x
	moveq	#64,d1			y
	bsr	print

	move.w	mouse.y(pc),d0		print mouse y position
	bsr	make.decimal
	lea	decimal.text(pc),a0
	moveq	#16,d0			x
	moveq	#72,d1			y
	bsr	print

	bsr	keyboard.requests

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	cmp.b	#$45,raw.key.code	ESCAPE
	bne.s	loop

	clr.b	raw.key.code




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	old.level2(pc),$68.w

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
	move.l	#4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level2
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$8,intreq(a6)

	lea	$bfe001,a0

	btst	#3,$d00(a0)		read CIA-A ICR
	beq.s	end.level2		if key not pressed

	move.b	$c00(a0),d0		get raw key code
	not.b	d0
	ror.b	#1,d0
	move.b	d0,raw.key.code

	bset	#6,$e00(a0)		set SP to output

	moveq	#54,d0

hand.shake
	dbra	d0,hand.shake		output handshake pulse

	bclr	#6,$e00(a0)		set SP back to input

; now check for special key presses

	move.b	raw.key.code(pc),d0

	cmp.b	#$46,d0			DELETE
	bne.s	end.level2
	not.b	frames.requested

end.level2
	move.l	(sp)+,a0
	move.l	(sp)+,d0
rte.ins	rte




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d2,-(sp)
	move.w	#$10,intreq(a6)

	st	next.frame

	move.b	joy0dat+1(a6),d0	x mouse movement
	move.b	d0,d1
	sub.b	register.mouse.x(pc),d0
	move.b	d1,register.mouse.x
	ext.w	d0
	add.w	mouse.x(pc),d0
	bpl.s	mouse.x.pos

	moveq	#0,d0
	bra.s	mouse.x.ok

mouse.x.pos
	cmp.w	#319,d0
	ble.s	mouse.x.ok

	move.w	#319,d0

mouse.x.ok
	move.w	d0,mouse.x




	move.b	joy0dat(a6),d1		y mouse movement
	move.b	d1,d2
	sub.b	register.mouse.y(pc),d1
	move.b	d2,register.mouse.y
	ext.w	d1
	add.w	mouse.y(pc),d1
	bpl.s	mouse.y.pos

	moveq	#0,d1
	bra.s	mouse.y.ok

mouse.y.pos
	cmp.w	#199,d1
	ble.s	mouse.y.ok

	move.w	#199,d1

mouse.y.ok
	move.w	d1,mouse.y




	add.w	#$80,d0			hardware x start
	add.w	#$48,d1			hardware y start
	moveq	#16,d2			height of mouse pointer
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

	move.w	d1,mouse.pointer	set sprite control words
	move.w	d2,mouse.pointer+2




	tst.b	left.mouse.button
	bne.s	check.right.button

	btst	#6,$bfe001
	bne.s	check.right.button

	st	left.mouse.button
	move.l	mouse.x(pc),left.mouse.button.x

check.right.button
	tst.b	right.mouse.button
	bne.s	end.level3

	btst	#2,potgor(a6)
	bne.s	end.level3

	st	right.mouse.button
	move.l	mouse.x(pc),right.mouse.button.x

end.level3
	movem.l	(sp)+,d0-d2
	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

clear	btst	#6,dmaconr(a6)
	bne.s	clear

	move.w	#40-8,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen.mem(pc),a0
	lea	16(a0),a0
	move.l	a0,bltdpth(a6)
	move.w	#8*4*64+4,bltsize(a6)
	rts




screen.pattern
	moveq	#0,d4
	moveq	#-1,d5
	move.l	screen.mem(pc),a1
	lea	40(a1),a2
	lea	40(a2),a3
	lea	40(a3),a4

	move.w	#200-1,d6
.loop	rept	20
	move.b	d4,(a1)+
	move.b	d5,(a1)+
	endr
	lea	120(a1),a1
	dbra	d6,.loop

	move.w	#200-1,d6
.loop2	rept	10
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	endr
	lea	120(a2),a2
	dbra	d6,.loop2

	move.w	#200-1,d6
.loop3	rept	5
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	endr
	lea	120(a3),a3
	dbra	d6,.loop3

	move.w	#200-1,d6
.loop4	rept	2
	move.l	d4,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d5,(a4)+
	endr
	move.l	d4,(a4)+
	move.l	d4,(a4)+
	lea	120(a4),a4
	dbra	d6,.loop4
	rts




keyboard.requests
	tst.b	frames.requested
	beq.s	no.request1

	bsr	frames.per.sec

no.request1
	rts




y.table	ds.w	200




print	move.l	screen.mem(pc),a1	d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address
	moveq	#0,d1

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
	move.b	(a3)+,(a2)		copy byte of character, bitplane 1
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
	moveq	#0,d1			y
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

	dc.w	spr0pth,0
	dc.w	spr0ptl,0
	dc.w	spr1pth,0
	dc.w	spr1ptl,0
	dc.w	spr2pth,0
	dc.w	spr2ptl,0
	dc.w	spr3pth,0
	dc.w	spr3ptl,0
	dc.w	spr4pth,0
	dc.w	spr4ptl,0
	dc.w	spr5pth,0
	dc.w	spr5ptl,0
	dc.w	spr6pth,0
	dc.w	spr6ptl,0
	dc.w	spr7pth,0
	dc.w	spr7ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

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
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0

raw.key.code	dc.b	0
frames.requested	dc.b	0

register.mouse.x	dc.b	0
register.mouse.y	dc.b	0
mouse.x		dc.w	0
mouse.y		dc.w	0
left.mouse.button	dc.b	0
right.mouse.button	dc.b	0
left.mouse.button.x	dc.w	0
left.mouse.button.y	dc.w	0
right.mouse.button.x	dc.w	0
right.mouse.button.y	dc.w	0




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
	dc.w	$000,$fff,$eee,$ddd,$ccc,$bbb,$aaa,$999
	dc.w	$888,$777,$666,$555,$444,$333,$222,$111
	dc.w	$000,$000,$fff,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000



mouse.pointer
	dc.w	$4840,$5800
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1011000000000000,%0100000000000000
	dc.w	%0100110000000000,%0011000000000000
	dc.w	%0100001100000000,%0011110000000000
	dc.w	%0010000011000000,%0001111100000000
	dc.w	%0010000000110000,%0001111111000000
	dc.w	%0001000000001000,%0000111111110000
	dc.w	%0001000000010000,%0000111111100000
	dc.w	%0000100000100000,%0000011111000000
	dc.w	%0000100000010000,%0000011111100000
	dc.w	%0000010010001000,%0000001101110000
	dc.w	%0000010101000100,%0000001000111000
	dc.w	%0000001000100010,%0000000000011100
	dc.w	%0000000000010001,%0000000000001110
	dc.w	%0000000000001010,%0000000000000100
	dc.w	%0000000000000100,%0000000000000000
	dc.w	0,0
