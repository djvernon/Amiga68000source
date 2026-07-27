	section	3D_Bobs,code_c
	opt	o+



XMID	equ	320/2+16
YMID	equ	196/2



start	bset	#1,$bfe001		low pass filter off

	move.l	4.w,a6
	move.l	#3*4*42*196+2,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
	addi.l	#4*42*196,d0
	move.l	d0,screen2
	addi.l	#4*42*196,d0
	move.l	d0,screen3

	bsr	make.copper.lists

	move.l	4.w,a6
	jsr	-132(a6)		turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	andi.l	#$1ff00,d0
	lsr.l	#8,d0
	cmpi.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz		division-by-zero exception handler
	move.l	#rteins,$14.w		set to rte instruction

	lea	coltab(pc),a0		initialise colours
	lea	$dff180,a1
	moveq	#15,d0
nextcol	move.w	(a0)+,(a1)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4c81,diwstrt(a6)	196 tall
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#3*40+4*2,bpl1mod(a6)
	move.w	#3*40+4*2,bpl2mod(a6)



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
	move.l	copper3(pc),cop1lc(a6)
	move.w	d0,copjmp1(a6)
	move.w	#$83c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#196-1,d0	count
	moveq	#0,d1		offset starts at zero
	move.w	#168,d2		bytes per line = 168
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



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	calc.sin.cos.values
	bsr	rotate.draw

	bsr	frames.per.sec

;	clr.w	next.frame
;wait	tst.w	next.frame
;	beq.s	wait

	bsr	update.screens

	bsr	clear

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
	move.l	#3*4*42*196+2,d0
	jsr	-210(a6)		FreeMem

	bclr	#1,$bfe001		low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d1/a0,-(sp)
	move.w	#$10,intreq(a6)

;	move.w	#1,next.frame

	lea	mouse.data(pc),a0

	move.b	$b(a6),d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x(pc),d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$a(a6),d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y(pc),d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y

	lea	mouse.data(pc),a0
	bsr.s	set.angles

	movem.l	(sp)+,d0-d1/a0
rteins	rte


set.angles
	btst	#2,potgor(a6)		right mouse button
	beq.s	right.pressed

	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,zangle		update z angle
	andi.w	#$7fe,zangle

	move.b	(a0),d0			mouse y
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,xangle		update x angle
	andi.w	#$7fe,xangle
	rts

right.pressed
	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,yangle		update y angle
	andi.w	#$7fe,yangle

	move.b	(a0),d0			mousey
	ext.w	d0
	add.w	d0,zoffset		update z distance
	rts



;""""""""""""""""""
;" 3D SUBROUTINES "
;"		  "
;""""""""""""""""""

clear	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	clear
	move.w	#2,bltdmod(a6)		one word
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1(pc),a0
	addq.w	#2,a0
	move.l	a0,bltdpth(a6)
	move.w	#196*4*64+20,bltsize(a6)	width = 20 words
	rts



calc.sin.cos.values
	movem.w	xangle(pc),d0-d2	xangle, yangle, zangle
	lea	sin.cos.values(pc),a0

	lea	cosine(pc),a1
	move.w	(a1,d0.w),d3		cosx
	move.w	(a1,d1.w),d4		cosy
	move.w	(a1,d2.w),d5		cosz

	lea	sine(pc),a1
	move.w	(a1,d0.w),d0		sinx
	move.w	(a1,d1.w),d1		siny
	move.w	(a1,d2.w),d2		sinz

	move.w	d4,d6			cosy
	muls	d5,d6			cosy.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.COSZ

	move.w	d0,d6			sinx
	muls	d1,d6			sinx.siny
	add.l	d6,d6
	swap	d6
	move.w	d6,a2			sinx.siny - save for later
	muls	d5,d6			sinx.siny.cosz
	move.w	d3,d7			cosx
	muls	d2,d7			cosx.sinz
	sub.l	d7,d6			sinx.siny.cosz - cosx.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		SINX.SINY.COSZ - COSX.SINZ

	move.w	d3,d6			cosx
	muls	d1,d6			cosx.siny
	add.l	d6,d6
	swap	d6
	move.w	d6,a3			cosx.siny - save for later
	muls	d5,d6			cosx.siny.cosz
	move.w	d0,d7			sinx
	muls	d2,d7			sinx.sinz
	add.l	d7,d6			cosx.siny.cosz + sinx.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSX.SINY.COSZ + SINX.SINZ

	move.w	d4,d6			cosy
	muls	d2,d6			cosy.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.SINZ

	move.w	a2,d6			sinx.siny
	muls	d2,d6			sinx.siny.sinz
	move.w	d3,d7			cosx
	muls	d5,d7			cosx.cosz
	add.l	d7,d6			sinx.siny.sinz + cosx.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		SINX.SINY.SINZ + COSX.COSZ

	move.w	a3,d6			cosx.siny
	muls	d2,d6			cosx.siny.sinz
	muls	d0,d5			sinx.cosz
	sub.l	d5,d6			cosx.siny.sinz - sinx.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSX.SINY.SINZ - SINX.COSZ

	neg.w	d1			-siny
	move.w	d1,(a0)+		-SINY

	muls	d4,d0			sinx.cosy
	add.l	d0,d0
	swap	d0
	move.w	d0,(a0)+		SINX.COSY

	muls	d3,d4			cosx.cosy
	add.l	d4,d4
	swap	d4
	move.w	d4,(a0)			COSX.COSY

	rts



rotate.draw
	lea	shape.data(pc),a5	address of object data
	lea	sin.cos.values(pc),a1
	lea	screen.coords(pc),a2
	move.w	(a5)+,d7		count
	bmi.s	end.rotate.draw		quit if there are no coordinates

rotate.loop
	movem.w	(a5)+,d0-d2		X, Y, Z
	move.w	d0,d3			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d0		X(cosy.cosz)
	muls	(a1)+,d4		Y(sinx.siny.cosz - cosx.sinz)
	muls	(a1)+,d5		Z(cosx.siny.cosz + sinx.sinz)
	add.l	d4,d0
	add.l	d5,d0			rotated X

	move.w	d3,d6			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d3		X(cosy.sinz)
	muls	(a1)+,d1		Y(sinx.siny.sinz + cosx.cosz)
	muls	(a1)+,d5		Z(cosx.siny.sinz - sinx.cosz)
	add.l	d3,d1
	add.l	d5,d1			rotated Y

	muls	(a1)+,d6		X(-siny)
	muls	(a1)+,d4		Y(sinx.cosy)
	muls	(a1)+,d2		Z(cosx.cosy)
	add.l	d6,d2
	add.l	d4,d2			rotated Z

	add.l	(a1)+,d0		add X offset
	add.l	(a1)+,d1		add Y offset
	add.l	(a1),d2			add Z offset
	bmi.s	end.rotate.draw		quit if z is negative

	lea	-26(a1),a1		18+2*4 - reset to start of values
	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0			X/Z - perspective for X
	divs	d2,d1			Y/Z - perspective for Y

	addi.w	#XMID,d0		centre on screen
	addi.w	#YMID,d1

	move.w	d0,(a2)+		save X
	move.w	d1,(a2)+		save Y
	move.w	d2,(a2)+		save Z
	dbra	d7,rotate.loop

	lea	which.line.first.data(pc),a0
	move.w	(a0)+,d0
	move.w	(a0),d1
	lea	screen.coords(pc),a0
	move.w	(a0,d0.w),d0		see which line is in front
	cmp.w	(a0,d1.w),d0		line1 Z - line3 Z
	bmi.s	draw.line.3.first

draw.line.1.first
	bsr.s	draw.line.1
	bsr.s	draw.line.2
	bsr.s	draw.line.3
	rts

draw.line.3.first
	bsr.s	draw.line.3
	bsr.s	draw.line.2
	bsr.s	draw.line.1

end.rotate.draw
	rts



draw.line.1
	lea	line.1.data(pc),a5
	move.w	(a5)+,d0		Z start offset, line 1
	move.w	(a5)+,d1		Z end offset, line 1
	move.w	(a5)+,d7		count for line 1
	lea	screen.coords(pc),a4
	move.w	(a4,d0.w),d0		see which end is in front
	cmp.w	(a4,d1.w),d0		start Z - end Z
	bmi.s	line.1.backwards
	bsr.s	line.forwards
	rts

line.1.backwards
	add.w	#num.line.1.chars*6,a4		to end of line 1 coords
	add.w	#num.line.1.chars,a5		to end of ASCII characters
	bsr.s	line.backwards
	rts



draw.line.2
	lea	line.2.data(pc),a5
	move.w	(a5)+,d0		Z start offset, line 2
	move.w	(a5)+,d1		Z end offset, line 2
	move.w	(a5)+,d7		count for line 2
	lea	screen.coords+num.line.1.chars*6(pc),a4
	move.w	(a4,d0.w),d0		see which end is in front
	cmp.w	(a4,d1.w),d0		start Z - end Z
	bmi.s	line.2.backwards
	bsr.s	line.forwards
	rts

line.2.backwards
	add.w	#num.line.2.chars*6,a4		to end of line 2 coords
	add.w	#num.line.2.chars,a5		to end of ASCII characters
	bsr.s	line.backwards
	rts



draw.line.3
	lea	line.3.data(pc),a5
	move.w	(a5)+,d0		Z start offset, line 3
	move.w	(a5)+,d1		Z end offset, line 3
	move.w	(a5)+,d7		count for line 3
	lea	screen.coords+(num.line.1.chars+num.line.2.chars)*6(pc),a4
	move.w	(a4,d0.w),d0		see which end is in front
	cmp.w	(a4,d1.w),d0		start Z - end Z
	bmi.s	line.3.backwards
	bsr.s	line.forwards
	rts

line.3.backwards
	add.w	#num.line.3.chars*6,a4		to end of line 3 coords
	add.w	#num.line.3.chars,a5		to end of ASCII characters
	bsr.s	line.backwards
	rts



line.forwards
	move.w	(a4)+,d0		X
	move.w	(a4)+,d1		Y

	subq.w	#8,d0			for top-left corner of character
	subi.w	#11,d1

	addq.w	#2,a4			skip z

	move.b	(a5)+,d2		ASCII character
	bsr.s	print.char
	dbra	d7,line.forwards
	rts



line.backwards
	subq.w	#2,a4			skip z
	move.w	-(a4),d1		Y
	move.w	-(a4),d0		X

	subq.w	#8,d0			for top-left corner of character
	subi.w	#11,d1

	move.b	-(a5),d2		ASCII character
	bsr.s	print.char
	dbra	d7,line.backwards
	rts



;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

print.char			; d0.w = X, d1.w = Y
				; d2.b = ASCII character code
				; font is 66 lines tall, 40 bytes wide
	lea	font.data(pc),a1
	subi.b	#32,d2			ASCII value for space
	cmpi.b	#40,d2
	bpl.s	third.line
	cmpi.b	#20,d2			20 characters per line of font
	bpl.s	second.line

font.address
	ext.w	d2
	add.w	d2,d2
	add.w	d2,a1			start address of character data

	lea	4*66*40(a1),a2		start address of character mask
	move.w	#22*64+1+1,d3		bltsize value, 1 word extra width
	moveq	#22,d4			character height

	bra.s	blit.char


second.line
	subi.b	#20,d2
	add.l	#22*40,a1
	bra.s	font.address

third.line
	subi.b	#40,d2
	add.l	#44*40,a1
	bra.s	font.address



blit.char
					; clip bob against top of screen
	move.w	d1,d5			bob Y
	bpl.s	check.bob.y.max

	neg.w	d5			amount off screen
	cmp.w	d4,d5			if bob is fully off screen then quit
	bpl	end.blit.char

	move.w	d5,d6
	mulu	#40,d6			number of lines * bytes per line
	add.w	d6,a1			add to bob start address
	add.w	d6,a2			add to mask start address
	lsl.w	#6,d5			number of lines * 64
	sub.w	d5,d3			remove from bltsize value
	moveq	#0,d1			set bob Y to zero
	bra.s	check.bob.x.min


check.bob.y.max				; clip bob against bottom of screen
	move.w	#196,d5			screen height
	sub.w	d4,d5			screen height - bob height = maximum
	sub.w	d1,d5			maximum - bob Y position
	bpl.s	check.bob.x.min

	neg.w	d5			amount off screen
	cmp.w	d4,d5			if bob is fully off screen then quit
	bpl	end.blit.char

	lsl.w	#6,d5			number of lines * 64
	sub.w	d5,d3			remove from bltsize value


check.bob.x.min				; clip bob against left of screen
	moveq	#0,d5
	cmp.w	d0,d5			start of visible screen - bob X
	bpl	end.blit.char


check.bob.x.max				; clip bob against right of screen
	move.w	#335,d5			end of visible screen
	cmp.w	d0,d5			bob X
	bmi	end.blit.char


bob.clipped
	move.l	screen1(pc),a0
	add.w	d1,d1
	lea	y.table(pc),a3
	add.w	(a3,d1.w),a0		add y offset

	moveq	#$f,d1
	and.w	d0,d1			low four bits from x
	sub.w	d1,d0			x offset in multiples of 16 bits
	lsr.w	#3,d0			x offset in even bytes
	add.w	d0,a0			start address for screen

	ror.w	#4,d1			shift distance

	move.w	#66*40,d0		font is 66 lines tall, 40 bytes wide

	move.w	#168-2-2,d2		byte modulo value for screen
				; = screen width - bob width - 1 extra word
	moveq	#40-2-2,d4		modulo for bob data and mask

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen -- destination
	move.w	d1,bltcon1(a6)
	ori.w	#$fca,d1		USE A,B,C,D ; LFx : D = A.B + a.C
	move.w	d1,bltcon0(a6)
	move.l	#$ffff0000,bltafwm(a6)	mask off last word
	move.w	d4,bltamod(a6)		to start of next line
	move.w	d4,bltbmod(a6)		to start of next line
	move.w	d2,bltcmod(a6)
	move.w	d2,bltdmod(a6)
	move.w	d3,bltsize(a6)

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

bltfin3	btst	#6,dmaconr(a6)
	bne.s	bltfin3

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

bltfin4	btst	#6,dmaconr(a6)
	bne.s	bltfin4

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

end.blit.char
	rts



y.table	ds.w	196			one word per screen line



print	move.l	screen1(pc),a1		d0=x, d1=y, a0=text ending with 0
	add.w	d1,d1
	lea	y.table(pc),a2
	add.w	(a2,d1.w),a1
	add.w	d0,a1			screen start address
	move.w	#168,d2			bytes per line
print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	subi.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2
copy.loop
	move.b	(a3),(a2)		copy byte of character, bitplane 1
	move.b	(a3),42(a2)		bitplane 2
	move.b	(a3),84(a2)		bitplane 3
	move.b	(a3)+,126(a2)		bitplane 4
	add.w	d2,a2			next screen line
	dbra	d0,copy.loop

	addq.w	#1,a1			next column
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



make.decimal
	andi.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros
make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#" ",(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	addi.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmpi.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	addi.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	clr.b	(a0)			end with zero
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
	sub.w	old.counter,d1		get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#".",-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#17,d0			x
	moveq	#17,d1			y
	bsr	print
	rts


old.counter
	dc.w	0


frames.text
	dc.b	"F/S     ",0
	even



update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	screen3(pc),screen2
	move.l	d0,screen3

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	copper3(pc),copper2
	move.l	d0,copper3

	move.l	d0,cop1lc(a6)		set new copper list address
	rts



make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
	bsr.s	init.copper

	move.l	screen3(pc),d0
	move.l	copper3(pc),a0
	bsr.s	init.copper
	rts



init.copper
	moveq	#4-1,d1
	addq.l	#2,d0			skip one word
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	addi.l	#42,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list.1
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$4c01,$ff00
	dc.w	color0,$000

	dc.w	$ffdf,$fffe		PAL enable

	dc.w	$1001,$ff00
	dc.w	color0,$555

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END



copper.list.2
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$4c01,$ff00
	dc.w	color0,$000

	dc.w	$ffdf,$fffe		PAL enable

	dc.w	$1001,$ff00
	dc.w	color0,$555

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END



copper.list.3
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$4c01,$ff00
	dc.w	color0,$000

	dc.w	$ffdf,$fffe		PAL enable

	dc.w	$1001,$ff00
	dc.w	color0,$555

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
color3	equ	$186
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
screen3		dc.l	0

copper1		dc.l	copper.list.1
copper2		dc.l	copper.list.2
copper3		dc.l	copper.list.3

olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
next.frame	dc.w	0

mouse.data	dc.b	0,0
old.mouse.x	dc.b	0
old.mouse.y	dc.b	0

xangle		dc.w	0
yangle		dc.w	0
zangle		dc.w	0

sin.cos.values	ds.w	9
xoffset		dc.l	0
yoffset		dc.l	0
zoffset		dc.l	$4000000

screen.coords	ds.w	128*3		space for 128 coordinates



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even



sine	dc.w	$0000,$00c9,$0192,$025b,$0324,$03ed,$04b6,$057e,$0647
	dc.w	$0710,$07d9,$08a1,$096a,$0a32,$0afb,$0bc3,$0c8b,$0d53
	dc.w	$0e1b,$0ee3,$0fab,$1072,$1139,$1200,$12c7,$138e,$1455
	dc.w	$151b,$15e1,$16a7,$176d,$1833,$18f8,$19bd,$1a82,$1b46
	dc.w	$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc,$209f,$2161,$2223
	dc.w	$22e4,$23a6,$2467,$2527,$25e7,$26a7,$2767,$2826,$28e5
	dc.w	$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54,$2e10,$2ecc,$2f86
	dc.w	$3041,$30fb,$31b4,$326d,$3326,$33de,$3496,$354d,$3603
	dc.w	$36b9,$376f,$3824,$38d8,$398c,$3a3f,$3af2,$3ba4,$3c56
	dc.w	$3d07,$3db7,$3e67,$3f16,$3fc5,$4073,$4120,$41cd,$4279
	dc.w	$4325,$43d0,$447a,$4523,$45cc,$4674,$471c,$47c3,$4869
	dc.w	$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f,$4ce0,$4d80,$4e20
	dc.w	$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce,$5268,$5301,$539a
	dc.w	$5432,$54c9,$555f,$55f4,$5689,$571d,$57b0,$5842,$58d3
	dc.w	$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28,$5cb3,$5d3d,$5dc6
	dc.w	$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb,$616e,$61f0,$6271
	dc.w	$62f1,$6370,$63ee,$646b,$64e7,$6562,$65dd,$6656,$66ce
	dc.w	$6745,$67bc,$6831,$68a5,$6919,$698b,$69fc,$6a6c,$6adb
	dc.w	$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61,$6dc9,$6e30,$6e95
	dc.w	$6efa,$6f5e,$6fc0,$7022,$7082,$70e1,$7140,$719d,$71f9
	dc.w	$7254,$72ae,$7306,$735e,$73b5,$740a,$745e,$74b1,$7503
	dc.w	$7554,$75a4,$75f3,$7640,$768d,$76d8,$7722,$776b,$77b3
	dc.w	$77f9,$783f,$7883,$78c6,$7908,$7949,$7989,$79c7,$7a04
	dc.w	$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c,$7b91,$7bc4,$7bf7
	dc.w	$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e,$7d38,$7d61,$7d89
	dc.w	$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e,$7e7e,$7e9c,$7eb9
	dc.w	$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c,$7f61,$7f74,$7f86
	dc.w	$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7,$7fe0,$7fe8,$7fef
	dc.w	$7ff5,$7ff9,$7ffc,$7ffe
cosine	dc.w	$7fff,$7ffe,$7ffc,$7ff9,$7ff5,$7fef,$7fe8,$7fe0,$7fd7
	dc.w	$7fcd,$7fc1,$7fb4,$7fa6,$7f96,$7f86,$7f74,$7f61,$7f4c
	dc.w	$7f37,$7f20,$7f08,$7eef,$7ed4,$7eb9,$7e9c,$7e7e,$7e5e
	dc.w	$7e3e,$7e1c,$7df9,$7dd5,$7db0,$7d89,$7d61,$7d38,$7d0e
	dc.w	$7ce2,$7cb6,$7c88,$7c59,$7c29,$7bf7,$7bc4,$7b91,$7b5c
	dc.w	$7b25,$7aee,$7ab5,$7a7c,$7a41,$7a04,$79c7,$7989,$7949
	dc.w	$7908,$78c6,$7883,$783f,$77f9,$77b3,$776b,$7722,$76d8
	dc.w	$768d,$7640,$75f3,$75a4,$7554,$7503,$74b1,$745e,$740a
	dc.w	$73b5,$735e,$7306,$72ae,$7254,$71f9,$719d,$7140,$70e1
	dc.w	$7082,$7022,$6fc0,$6f5e,$6efa,$6e95,$6e30,$6dc9,$6d61
	dc.w	$6cf8,$6c8e,$6c23,$6bb7,$6b4a,$6adb,$6a6c,$69fc,$698b
	dc.w	$6919,$68a5,$6831,$67bc,$6745,$66ce,$6656,$65dd,$6562
	dc.w	$64e7,$646b,$63ee,$6370,$62f1,$6271,$61f0,$616e,$60eb
	dc.w	$6067,$5fe2,$5f5d,$5ed6,$5e4f,$5dc6,$5d3d,$5cb3,$5c28
	dc.w	$5b9c,$5b0f,$5a81,$59f3,$5963,$58d3,$5842,$57b0,$571d
	dc.w	$5689,$55f4,$555f,$54c9,$5432,$539a,$5301,$5268,$51ce
	dc.w	$5133,$5097,$4ffa,$4f5d,$4ebf,$4e20,$4d80,$4ce0,$4c3f
	dc.w	$4b9d,$4afa,$4a57,$49b3,$490e,$4869,$47c3,$471c,$4674
	dc.w	$45cc,$4523,$447a,$43d0,$4325,$4279,$41cd,$4120,$4073
	dc.w	$3fc5,$3f16,$3e67,$3db7,$3d07,$3c56,$3ba4,$3af2,$3a3f
	dc.w	$398c,$38d8,$3824,$376f,$36b9,$3603,$354d,$3496,$33de
	dc.w	$3326,$326d,$31b4,$30fb,$3041,$2f86,$2ecc,$2e10,$2d54
	dc.w	$2c98,$2bdb,$2b1e,$2a61,$29a3,$28e5,$2826,$2767,$26a7
	dc.w	$25e7,$2527,$2467,$23a6,$22e4,$2223,$2161,$209f,$1fdc
	dc.w	$1f19,$1e56,$1d93,$1ccf,$1c0b,$1b46,$1a82,$19bd,$18f8
	dc.w	$1833,$176d,$16a7,$15e1,$151b,$1455,$138e,$12c7,$1200
	dc.w	$1139,$1072,$0fab,$0ee3,$0e1b,$0d53,$0c8b,$0bc3,$0afb
	dc.w	$0a32,$096a,$08a1,$07d9,$0710,$0647,$057e,$04b6,$03ed
	dc.w	$0324,$025b,$0192,$00c9,$0000,$ff37,$fe6e,$fda5,$fcdc
	dc.w	$fc13,$fb4a,$fa82,$f9b9,$f8f0,$f827,$f75f,$f696,$f5ce
	dc.w	$f505,$f43d,$f375,$f2ad,$f1e5,$f11d,$f055,$ef8e,$eec7
	dc.w	$ee00,$ed39,$ec72,$ebab,$eae5,$ea1f,$e959,$e893,$e7cd
	dc.w	$e708,$e643,$e57e,$e4ba,$e3f5,$e331,$e26d,$e1aa,$e0e7
	dc.w	$e024,$df61,$de9f,$dddd,$dd1c,$dc5a,$db99,$dad9,$da19
	dc.w	$d959,$d899,$d7da,$d71b,$d65d,$d59f,$d4e2,$d425,$d368
	dc.w	$d2ac,$d1f0,$d134,$d07a,$cfbf,$cf05,$ce4c,$cd93,$ccda
	dc.w	$cc22,$cb6a,$cab3,$c9fd,$c947,$c891,$c7dc,$c728,$c674
	dc.w	$c5c1,$c50e,$c45c,$c3aa,$c2f9,$c249,$c199,$c0ea,$c03b
	dc.w	$bf8d,$bee0,$be33,$bd87,$bcdb,$bc30,$bb86,$badd,$ba34
	dc.w	$b98c,$b8e4,$b83d,$b797,$b6f2,$b64d,$b5a9,$b506,$b463
	dc.w	$b3c1,$b320,$b280,$b1e0,$b141,$b0a3,$b006,$af69,$aecd
	dc.w	$ae32,$ad98,$acff,$ac66,$abce,$ab37,$aaa1,$aa0c,$a977
	dc.w	$a8e3,$a850,$a7be,$a72d,$a69d,$a60d,$a57f,$a4f1,$a464
	dc.w	$a3d8,$a34d,$a2c3,$a23a,$a1b1,$a12a,$a0a3,$a01e,$9f99
	dc.w	$9f15,$9e92,$9e10,$9d8f,$9d0f,$9c90,$9c12,$9b95,$9b19
	dc.w	$9a9e,$9a23,$99aa,$9932,$98bb,$9844,$97cf,$975b,$96e7
	dc.w	$9675,$9604,$9594,$9525,$94b6,$9449,$93dd,$9372,$9308
	dc.w	$929f,$9237,$91d0,$916b,$9106,$90a2,$9040,$8fde,$8f7e
	dc.w	$8f1f,$8ec0,$8e63,$8e07,$8dac,$8d52,$8cfa,$8ca2,$8c4b
	dc.w	$8bf6,$8ba2,$8b4f,$8afd,$8aac,$8a5c,$8a0d,$89c0,$8973
	dc.w	$8928,$88de,$8895,$884d,$8807,$87c1,$877d,$873a,$86f8
	dc.w	$86b7,$8677,$8639,$85fc,$85bf,$8584,$854b,$8512,$84db
	dc.w	$84a4,$846f,$843c,$8409,$83d7,$83a7,$8378,$834a,$831e
	dc.w	$82f2,$82c8,$829f,$8277,$8250,$822b,$8207,$81e4,$81c2
	dc.w	$81a2,$8182,$8164,$8147,$812c,$8111,$80f8,$80e0,$80c9
	dc.w	$80b4,$809f,$808c,$807a,$806a,$805a,$804c,$803f,$8033
	dc.w	$8029,$8020,$8018,$8011,$800b,$8007,$8004,$8002,$8001
	dc.w	$8002,$8004,$8007,$800b,$8011,$8018,$8020,$8029,$8033
	dc.w	$803f,$804c,$805a,$806a,$807a,$808c,$809f,$80b4,$80c9
	dc.w	$80e0,$80f8,$8111,$812c,$8147,$8164,$8182,$81a2,$81c2
	dc.w	$81e4,$8207,$822b,$8250,$8277,$829f,$82c8,$82f2,$831e
	dc.w	$834a,$8378,$83a7,$83d7,$8409,$843c,$846f,$84a4,$84db
	dc.w	$8512,$854b,$8584,$85bf,$85fc,$8639,$8677,$86b7,$86f8
	dc.w	$873a,$877d,$87c1,$8807,$884d,$8895,$88de,$8928,$8973
	dc.w	$89c0,$8a0d,$8a5c,$8aac,$8afd,$8b4f,$8ba2,$8bf6,$8c4b
	dc.w	$8ca2,$8cfa,$8d52,$8dac,$8e07,$8e63,$8ec0,$8f1f,$8f7e
	dc.w	$8fde,$9040,$90a2,$9106,$916b,$91d0,$9237,$929f,$9308
	dc.w	$9372,$93dd,$9449,$94b6,$9525,$9594,$9604,$9675,$96e7
	dc.w	$975b,$97cf,$9844,$98bb,$9932,$99aa,$9a23,$9a9e,$9b19
	dc.w	$9b95,$9c12,$9c90,$9d0f,$9d8f,$9e10,$9e92,$9f15,$9f99
	dc.w	$a01e,$a0a3,$a12a,$a1b1,$a23a,$a2c3,$a34d,$a3d8,$a464
	dc.w	$a4f1,$a57f,$a60d,$a69d,$a72d,$a7be,$a850,$a8e3,$a977
	dc.w	$aa0c,$aaa1,$ab37,$abce,$ac66,$acff,$ad98,$ae32,$aecd
	dc.w	$af69,$b006,$b0a3,$b141,$b1e0,$b280,$b320,$b3c1,$b463
	dc.w	$b506,$b5a9,$b64d,$b6f2,$b797,$b83d,$b8e4,$b98c,$ba34
	dc.w	$badd,$bb86,$bc30,$bcdb,$bd87,$be33,$bee0,$bf8d,$c03b
	dc.w	$c0ea,$c199,$c249,$c2f9,$c3aa,$c45c,$c50e,$c5c1,$c674
	dc.w	$c728,$c7dc,$c891,$c947,$c9fd,$cab3,$cb6a,$cc22,$ccda
	dc.w	$cd93,$ce4c,$cf05,$cfbf,$d07a,$d134,$d1f0,$d2ac,$d368
	dc.w	$d425,$d4e2,$d59f,$d65d,$d71b,$d7da,$d899,$d959,$da19
	dc.w	$dad9,$db99,$dc5a,$dd1c,$dddd,$de9f,$df61,$e024,$e0e7
	dc.w	$e1aa,$e26d,$e331,$e3f5,$e4ba,$e57e,$e643,$e708,$e7cd
	dc.w	$e893,$e959,$ea1f,$eae5,$ebab,$ec72,$ed39,$ee00,$eec7
	dc.w	$ef8e,$f055,$f11d,$f1e5,$f2ad,$f375,$f43d,$f505,$f5ce
	dc.w	$f696,$f75f,$f827,$f8f0,$f9b9,$fa82,$fb4a,$fc13,$fcdc
	dc.w	$fda5,$fe6e,$ff37,$0000,$00c9,$0192,$025b,$0324,$03ed
	dc.w	$04b6,$057e,$0647,$0710,$07d9,$08a1,$096a,$0a32,$0afb
	dc.w	$0bc3,$0c8b,$0d53,$0e1b,$0ee3,$0fab,$1072,$1139,$1200
	dc.w	$12c7,$138e,$1455,$151b,$15e1,$16a7,$176d,$1833,$18f8
	dc.w	$19bd,$1a82,$1b46,$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc
	dc.w	$209f,$2161,$2223,$22e4,$23a6,$2467,$2527,$25e7,$26a7
	dc.w	$2767,$2826,$28e5,$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54
	dc.w	$2e10,$2ecc,$2f86,$3041,$30fb,$31b4,$326d,$3326,$33de
	dc.w	$3496,$354d,$3603,$36b9,$376f,$3824,$38d8,$398c,$3a3f
	dc.w	$3af2,$3ba4,$3c56,$3d07,$3db7,$3e67,$3f16,$3fc5,$4073
	dc.w	$4120,$41cd,$4279,$4325,$43d0,$447a,$4523,$45cc,$4674
	dc.w	$471c,$47c3,$4869,$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f
	dc.w	$4ce0,$4d80,$4e20,$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce
	dc.w	$5268,$5301,$539a,$5432,$54c9,$555f,$55f4,$5689,$571d
	dc.w	$57b0,$5842,$58d3,$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28
	dc.w	$5cb3,$5d3d,$5dc6,$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb
	dc.w	$616e,$61f0,$6271,$62f1,$6370,$63ee,$646b,$64e7,$6562
	dc.w	$65dd,$6656,$66ce,$6745,$67bc,$6831,$68a5,$6919,$698b
	dc.w	$69fc,$6a6c,$6adb,$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61
	dc.w	$6dc9,$6e30,$6e95,$6efa,$6f5e,$6fc0,$7022,$7082,$70e1
	dc.w	$7140,$719d,$71f9,$7254,$72ae,$7306,$735e,$73b5,$740a
	dc.w	$745e,$74b1,$7503,$7554,$75a4,$75f3,$7640,$768d,$76d8
	dc.w	$7722,$776b,$77b3,$77f9,$783f,$7883,$78c6,$7908,$7949
	dc.w	$7989,$79c7,$7a04,$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c
	dc.w	$7b91,$7bc4,$7bf7,$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e
	dc.w	$7d38,$7d61,$7d89,$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e
	dc.w	$7e7e,$7e9c,$7eb9,$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c
	dc.w	$7f61,$7f74,$7f86,$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7
	dc.w	$7fe0,$7fe8,$7fef,$7ff5,$7ff9,$7ffc,$7ffe



;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

coltab	dc.w	$000,$a50,$540,$000,$000,$000,$000,$000
	dc.w	$fd0,$ec0,$db0,$ca0,$b90,$a80,$970,$860



font.data	incbin	graphics_data/3D_Bobs_Font.bin.mask



shape.data
	dc.w	29-1			number of coords

	dc.w	-768,-300,0		line 1		X, Y, Z
	dc.w	-640,-300,0
	dc.w	-512,-300,0
	dc.w	-384,-300,0
	dc.w	-256,-300,0
	dc.w	-128,-300,0
	dc.w	128,-300,0
	dc.w	256,-300,0
	dc.w	384,-300,0
	dc.w	512,-300,0
	dc.w	640,-300,0
	dc.w	768,-300,0

	dc.w	-448,0,0		line 2
	dc.w	-320,0,0
	dc.w	-192,0,0
	dc.w	-64,0,0
	dc.w	64,0,0
	dc.w	192,0,0
	dc.w	320,0,0
	dc.w	448,0,0

	dc.w	-576,300,0		line 3
	dc.w	-320,300,0
	dc.w	-192,300,0
	dc.w	-64,300,0
	dc.w	192,300,0
	dc.w	320,300,0
	dc.w	448,300,0
	dc.w	576,300,0

	dc.w	-768,300,0		extra point for priority check



which.line.first.data
	dc.w	4			Z start offsets for lines 1 and 3
	dc.w	(num.line.1.chars+num.line.2.chars+num.line.3.chars)*6+4



num.line.1.chars	equ	12


line.1.data
	dc.w	4			Z start and end offsets, line 1
	dc.w	num.line.1.chars*6-2

	dc.w	num.line.1.chars-1	number of coords for line 1

	dc.b	'DANIELVERNON'
	even



num.line.2.chars	equ	8


line.2.data
	dc.w	4			Z start and end offsets, line 2
	dc.w	num.line.2.chars*6-2

	dc.w	num.line.2.chars-1	number of coords for line 2

	dc.b	'PRESENTS'
	even



num.line.3.chars	equ	8


line.3.data
	dc.w	4			Z start and end offsets, line 3
	dc.w	num.line.3.chars*6-2

	dc.w	num.line.3.chars-1	number of coords for line 3

	dc.b	'ANEWDEMO'
	even
