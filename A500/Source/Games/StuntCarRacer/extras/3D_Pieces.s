	section	pieces,code_c
	opt	o+,o3-




XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#3*4*40*200,d0
	moveq	#2,d1			chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now

	move.l	d0,screen1
	move.l	#4*40*200,d1
	add.l	d1,d0
	move.l	d0,screen2
	add.l	d1,d0
	move.l	d0,screen3


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem

	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

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




*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

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


	bsr	make.copper.lists	initialise copper

	move.l	copper1(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




*"""""""""""""""""""""
*" CALCULATE Y-TABLE "
*"		     "
*"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




	bsr	set.piece.x.z.coords
	move.w	current.section(pc),d0
	bsr	set.piece.y.coords

	move.b	joy0dat+1(a6),register.mouse.x
	move.b	joy0dat(a6),register.mouse.y




*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

loop	bsr	to.next.piece

	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	lea	sin.cos.values(pc),a0
	bsr	calc.sin.cos.values

	bsr	rotate.draw.piece

	bsr	keyboard.requests

	move.w	number(pc),d0
	bsr	make.decimal
	lea	decimal.text(pc),a0
	moveq	#4,d0
	moveq	#32,d1
	bsr	print

	bsr	update.screens
	bsr	clear

	cmp.b	#$45,raw.key.code
	bne.s	loop
	clr.b	raw.key.code




*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10010111,$bfed01	restore CIA-A ICR

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
	move.l	#3*4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts

number	dc.w	0


*"""""""""""""""""""""
*" LEVEL 2 INTERRUPT "
*"		     "
*"""""""""""""""""""""

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

* now check for special key presses

	move.b	raw.key.code(pc),d0

	cmp.b	#$46,d0			DELETE
	bne.s	end.level2
	not.b	frames.requested

end.level2
	move.l	(sp)+,a0
	move.l	(sp)+,d0
rte.ins	rte




*"""""""""""""""""""""
*" LEVEL 3 INTERRUPT "
*"		     "
*"""""""""""""""""""""

new.level3
	movem.l	d0-d2,-(sp)
	move.w	#$10,intreq(a6)

	move.b	joy0dat+1(a6),d0	x mouse movement
	move.b	d0,d1
	sub.b	register.mouse.x(pc),d0
	move.b	d1,register.mouse.x

	move.b	joy0dat(a6),d1		y mouse movement
	move.b	d1,d2
	sub.b	register.mouse.y(pc),d1
	move.b	d2,register.mouse.y

	btst	#2,potgor(a6)		right mouse button
	beq.s	right.pressed

	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.z.angle		update z angle
	and.w	#$7fe,base.z.angle

	ext.w	d1
	add.w	d1,d1			word offset for tables
	add.w	d1,base.x.angle		update x angle
	and.w	#$7fe,base.x.angle

	movem.l	(sp)+,d0-d2
	rte




right.pressed
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.y.angle		update y angle
	and.w	#$7fe,base.y.angle

	ext.w	d1
	add.w	d1,z.offset		update z distance

	movem.l	(sp)+,d0-d2
	rte




*""""""""""""""""""""""""""""""""""""""""
*" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
*"					"
*""""""""""""""""""""""""""""""""""""""""

to.next.piece
	btst	#6,$bfe001
	bne.s	no.piece.change

	lea	left.y.coordinate.IDs(pc),a3
	lea	right.y.coordinate.IDs(pc),a4
	lea	road.section.angle.and.piece(pc),a5

to.next.section
	move.w	current.section(pc),d0
	move.w	d0,d1
	addq.w	#1,d1
	cmp.w	#44,d1
	bne.s	not.end.of.pieces
	moveq	#0,d1

not.end.of.pieces
	move.w	d1,current.section

	move.b	(a3,d0.w),d2		only go to next piece if it is
	cmp.b	(a3,d1.w),d2		different to the current one
	bne.s	now.set.piece

	move.b	(a4,d0.w),d2
	and.b	#$7f,d2
	move.b	(a4,d1.w),d3
	and.b	#$7f,d3
	cmp.b	d2,d3
	bne.s	now.set.piece

	move.b	(a5,d0.w),d2
	and.b	#$f,d2
	move.b	(a5,d1.w),d3
	and.b	#$f,d3
	cmp.b	d2,d3
	beq.s	to.next.section

now.set.piece
	move.w	current.section(pc),d0
	bsr.s	set.piece.y.coords

wait.release
	btst	#6,$bfe001
	beq.s	wait.release

no.piece.change
	rts




set.piece.y.coords
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	lea	left.y.coordinate.IDs(pc),a3
	lea	right.y.coordinate.IDs(pc),a4
	lea	road.section.angle.and.piece(pc),a5
	move.b	(a3,d0.w),d3
	bpl.s	y.coords.not.words
	moveq	#-1,d1			if y coords are stored as words

y.coords.not.words
	move.b	(a4,d0.w),d4
	move.b	(a5,d0.w),d5
	add.w	d0,d0
	lea	overall.left.y.shifts(pc),a3
	lea	overall.right.y.shifts(pc),a4
	move.w	(a3,d0.w),d6		overall left y shift
	move.w	(a4,d0.w),d7		overall right y shift
	sub.w	#2048,d6
	sub.w	#2048,d7

	add.b	d3,d3			get rid of top bits
	add.b	d4,d4
	add.w	d3,d3
	add.w	d4,d4
	lea	y.coordinate.pointers(pc),a4
	move.l	(a4,d3.w),a3		address of left y coords
	move.l	(a4,d4.w),a4		address of right y coords

	lea	piece.coords.ptrs(pc),a5
	and.w	#$f,d5
	move.w	d5,number
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a5,d5.w),a5
	move.l	a5,current.piece

	move.w	(a5)+,d5		count-1
	lsr.w	#2,d5
	lea	2(a5),a5		skip first top x

	tst.l	d1
	bmi.s	next.word.y.coord.pair

next.byte.y.coord.pair
	move.b	(a3)+,d0
	move.b	d0,d1
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d1
	asl.w	#8,d1
	or.w	d1,d0
	add.w	d6,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,(a5)			save top left y
	lea	6(a5),a5

	move.b	(a4)+,d0
	move.b	d0,d1
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d1
	asl.w	#8,d1
	or.w	d1,d0
	add.w	d7,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,(a5)			save top right y
	lea	6(a5),a5

	dbra	d5,next.byte.y.coord.pair
	rts

next.word.y.coord.pair
	move.b	(a3)+,d0
	move.b	(a3)+,d1
	and.w	#$7f,d0
	asl.w	#8,d0
	or.b	d1,d0
	add.w	d6,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,(a5)			save top left y
	lea	6(a5),a5

	move.b	(a4)+,d0
	move.b	(a4)+,d1
	and.w	#$7f,d0
	asl.w	#8,d0
	or.b	d1,d0
	add.w	d7,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,(a5)			save top right y
	lea	6(a5),a5

	dbra	d5,next.word.y.coord.pair
	rts




set.piece.x.z.coords
	lea	piece.coords.ptrs(pc),a4
	lea	piece.x.z.coords.ptrs(pc),a5
	moveq	#16-1,d4		16 piece pointers

next.piece
	move.l	(a5)+,a3
	move.l	(a4)+,d7
	beq.s	piece.done

	move.l	d7,a2
	move.w	(a2)+,d7		count-1
	move.w	d7,d6
	addq.w	#1,d6
	move.w	d6,d5
	add.w	d6,d6
	add.w	d5,d6
	lea	(a2,d6.w),a1		address of bottom co-ords
	lsr.w	#1,d7

next.coord
	move.w	(a3)+,d5
	rol.w	#8,d5
	sub.w	#$400,d5		x co-ord
	move.w	(a3)+,d6
	rol.w	#8,d6
	sub.w	#$400,d6		z co-ord

	move.w	d5,(a2)+		save top x
	lea	2(a2),a2		skip top y
	move.w	d6,(a2)+		save top z

	move.w	d5,(a1)+		save bottom x
	move.w	#512-128,(a1)+		save bottom y
	move.w	d6,(a1)+		save bottom z
	dbra	d7,next.coord

piece.done
	dbra	d4,next.piece
	rts




clear	btst	#6,dmaconr(a6)
	bne.s	clear

	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)
	move.l	screen1(pc),bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)
	rts




calc.sin.cos.values
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
	move.w	d0,d7			sinx
	muls	d1,d7			sinx.siny
	add.l	d7,d7
	swap	d7
	move.w	d7,a1			sinx.siny - save for later
	muls	d2,d7			sinx.siny.sinz
	sub.l	d7,d6			cosy.cosz - sinx.siny.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.COSZ - SINX.SINY.SINZ

	move.w	d3,d6			cosx
	muls	d2,d6			cosx.sinz
	add.l	d6,d6
	swap	d6
	neg.w	d6
	move.w	d6,(a0)+		- COSX.SINZ

	move.w	d1,d6			siny
	muls	d5,d6			siny.cosz
	move.w	d0,d7			sinx
	muls	d4,d7			sinx.cosy
	add.l	d7,d7
	swap	d7
	move.w	d7,a2			sinx.cosy - save for later
	muls	d2,d7			sinx.cosy.sinz
	add.l	d7,d6			siny.cosz + sinx.cosy.sinz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		SINY.COSZ + SINX.COSY.SINZ

	move.w	d4,d6			cosy
	muls	d2,d6			cosy.sinz
	move.w	a1,d7			sinx.siny
	muls	d5,d7			sinx.siny.cosz
	add.l	d7,d6			cosy.sinz + sinx.siny.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSY.SINZ + SINX.SINY.COSZ

	move.w	d3,d6			cosx
	muls	d5,d6			cosx.cosz
	add.l	d6,d6
	swap	d6
	move.w	d6,(a0)+		COSX.COSZ

	muls	d1,d2			siny.sinz
	move.w	a2,d6			sinx.cosy
	muls	d5,d6			sinx.cosy.cosz
	sub.l	d6,d2			siny.sinz - sinx.cosy.cosz
	add.l	d2,d2
	swap	d2
	move.w	d2,(a0)+		SINY.SINZ - SINX.COSY.COSZ

	muls	d3,d1			cosx.siny
	add.l	d1,d1
	swap	d1
	neg.w	d1
	move.w	d1,(a0)+		- COSX.SINY

	move.w	d0,(a0)+		SINX

	muls	d3,d4			cosx.cosy
	add.l	d4,d4
	swap	d4
	move.w	d4,(a0)			COSX.COSY
	rts




end.rotate.draw
	rts


rotate.draw.piece
	move.l	current.piece(pc),a0
	lea	sin.cos.values(pc),a1
	lea	new.coords(pc),a2
	move.w	(a0)+,d7		count-1
	move.w	#XMID,a3
	move.w	#YMID,a4

rotate.loop
	movem.w	(a0)+,d0-d2		get current X, Y, Z
	move.w	d0,d3			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d0		X(cosy.cosz - sinx.siny.sinz)
	muls	(a1)+,d4		Y(-cosx.sinz)
	muls	(a1)+,d5		Z(siny.cosz + sinx.cosy.sinz)
	add.l	d4,d0
	add.l	d5,d0			rotated X

	move.w	d3,d6			X
	move.w	d1,d4			Y
	move.w	d2,d5			Z

	muls	(a1)+,d3		X(cosy.sinz + sinx.siny.cosz)
	muls	(a1)+,d1		Y(cosx.cosz)
	muls	(a1)+,d5		Z(siny.sinz - sinx.cosy.cosz)
	add.l	d3,d1
	add.l	d5,d1			rotated Y

	muls	(a1)+,d6		X(-cosx.siny)
	muls	(a1)+,d4		Y(sinx)
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

	add.w	a3,d0			centre on screen
	add.w	a4,d1

	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y
	move.w	d2,(a2)+		save z

	dbra	d7,rotate.loop

draw.piece.lines
	move.l	#line.colour.masks+3*8,top.colours
	move.l	#line.colour.masks+7*8,top.colours+4

	move.l	current.piece(pc),a0
	move.w	(a0),d7			count-1
	lea	new.coords(pc),a4
	move.w	d7,d6
	addq.w	#1,d6
	move.w	d6,d5
	add.w	d6,d6
	add.w	d5,d6
	lea	(a4,d6.w),a5		address of bottom co-ords

	lsr.w	#2,d7
	subq.w	#1,d7

	move.w	d7,-(sp)

	move.l	#line.colour.masks+5*8,dl.col+2

	movem.w	(a5),d0-d1		bottom to bottom+6
	movem.w	6(a5),d2-d3
	bsr	clip.line

	move.l	#line.colour.masks+1*8,dl.col+2

	movem.w	(a4),d0-d1		top to top+6
	movem.w	6(a4),d2-d3
	bsr	clip.line

	move.w	(sp)+,d7

next.piece.line
	move.w	d7,-(sp)

	move.l	#line.colour.masks+5*8,dl.col+2

	movem.w	(a5),d0-d1		bottom to bottom+12
	movem.w	12(a5),d2-d3
	bsr	clip.line

	movem.w	6(a5),d0-d1		bottom+6 to bottom+18
	movem.w	18(a5),d2-d3
	bsr	clip.line

	move.l	#line.colour.masks+1*8,dl.col+2

	movem.w	(a4),d0-d1		top to bottom
	movem.w	(a5),d2-d3
	bsr	clip.line

	movem.w	6(a4),d0-d1		top+6 to bottom+6
	movem.w	6(a5),d2-d3
	bsr	clip.line

	movem.l	top.colours(pc),d6-d7
	exg	d6,d7
	movem.l	d6-d7,top.colours
	move.l	d7,dl.col+2

	movem.w	(a4),d0-d1		top to top+12
	movem.w	12(a4),d2-d3
	bsr.s	clip.line

	movem.w	6(a4),d0-d1		top+6 to top+18
	movem.w	18(a4),d2-d3
	bsr.s	clip.line

	lea	12(a4),a4
	lea	12(a5),a5

	move.w	(sp)+,d7
	dbra	d7,next.piece.line

	move.l	#line.colour.masks+5*8,dl.col+2

	movem.w	(a5),d0-d1		bottom to bottom+6
	movem.w	6(a5),d2-d3
	bsr.s	clip.line

	move.l	#line.colour.masks+1*8,dl.col+2

	movem.w	(a4),d0-d1		top to bottom
	movem.w	(a5),d2-d3
	bsr.s	clip.line

	movem.w	6(a4),d0-d1		top+6 to bottom+6
	movem.w	6(a5),d2-d3
	bsr.s	clip.line

	move.l	#line.colour.masks+1*8,dl.col+2

	movem.w	(a4),d0-d1		top to top+6
	movem.w	6(a4),d2-d3
;	bra.s	clip.line




*"""""""""""""""""
*" LINE ROUTINES "
*"		 "
*"""""""""""""""""

* d0 = x1, d1 = y1, d2 = x2, d3 = y2

clip.line
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.not.off.left

* x1 is off left of screen

	tst.w	d2			x2
	bmi.s	end.clip.line		if line is off left of screen

* clip line to left edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	muls	d0,d5			x1 * (y2-y1)
	divs	d4,d5			(x1 * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - ((x1 * (y2-y1)) / (x2-x1))
	moveq	#0,d0			x1 = 0
	bra.s	x1.clipped

end.clip.line
	rts




x1.not.off.left
	cmp.w	d6,d0			x1
	ble.s	x1.clipped

* x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	end.clip.line		if line is off right of screen

* clip line to right edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d6,d0			x1-max
	muls	d0,d5			(x1-max) * (y2-y1)
	divs	d4,d5			((x1-max) * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - (((x1-max) * (y2-y1)) / (x2-x1))
	move.w	d6,d0			x1 = max




x1.clipped
	tst.w	d1			y1
	bpl.s	y1.not.off.top

* y1 is off top of screen

	tst.w	d3			y2
	bmi.s	end.clip.line		if line is off top of screen

* clip line to top edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y2
	muls	d1,d4			y1 * (x2-x1)
	divs	d5,d4			(y1 * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - ((y1 * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	moveq	#0,d1			y1 = 0

	cmp.w	d6,d0
	ble.s	y1.clipped		if new x1 is not off right of screen

end.clip.line2
	rts




y1.not.off.top
	cmp.w	d7,d1			y1
	ble.s	y1.clipped

* y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	end.clip.line2		if line is off bottom of screen

* clip line to bottom edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d7,d1			y1-max
	muls	d1,d4			(y1-max) * (x2-x1)
	divs	d5,d4			((y1-max) * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - (((y1-max) * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	cmp.w	d6,d0
	bgt.s	end.clip.line2		if new x1 is off right of screen

	move.w	d7,d1			y1 = max




y1.clipped
	tst.w	d2			x2
	bpl.s	x2.not.off.left

* x2 is off left of screen

* clip line to left edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d2,d5			x2 * (y1-y2)
	divs	d4,d5			(x2 * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - ((x2 * (y1-y2)) / (x1-x2))
	moveq	#0,d2			x2 = 0
	bra.s	x2.clipped




x2.not.off.left
	cmp.w	d6,d2			x2
	ble.s	x2.clipped

* x2 is off right of screen

* clip line to right edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d6,d2			x2-max
	muls	d2,d5			(x2-max) * (y1-y2)
	divs	d4,d5			((x2-max) * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - (((x2-max) * (y1-y2)) / (x1-x2))
	move.w	d6,d2			x2 = max




x2.clipped
	tst.w	d3			y2
	bpl.s	y2.not.off.top

* y2 is off top of screen

* clip line to top edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d3,d4			y2 * (x1-x2)
	divs	d5,d4			(y2 * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - ((y2 * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	moveq	#0,d3			y2 = 0

	cmp.w	d6,d2
	ble.s	draw.line		if new x2 is not off right of screen

end.clip.line3
	rts




y2.not.off.top
	cmp.w	d7,d3			y2
	ble.s	draw.line

* y2 is off bottom of screen

* clip line to bottom edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d7,d3			y2-max
	muls	d3,d4			(y2-max) * (x1-x2)
	divs	d5,d4			((y2-max) * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - (((y2-max) * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	cmp.w	d6,d2
	bgt.s	end.clip.line3		if new x2 is off right of screen

	move.w	d7,d3			y2 = max




draw.line				* draw line using blitter
	cmp.w	d2,d0
	ble.s	x1.less.than.x2

	exg	d0,d2			ensure line is going left-to-right
	exg	d1,d3

x1.less.than.x2
	sub.w	d0,d2			x2-x1
	sub.w	d1,d3			y2-y1

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x-start

	sub.w	d4,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes

	add.w	d1,d1			word offset
	lea	y.table(pc),a1
	add.w	(a1,d1.w),d0		add y offset

	move.l	screen1(pc),a1
	add.w	d0,a1			start address of line

	ror.w	#4,d4			low four bits from x-start
	or.w	#$bca,d4		USE A,C,D	D = A.B + notA.C
	swap	d4

	tst.w	d3			delta-y
	bmi.s	y2.less.than.y1

	cmp.w	d2,d3
	blt.s	dy.less.than.dx

	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	dl.size

dy.less.than.dx
	move.w	#%10001,d4
	bra.s	dl.size


y2.less.than.y1
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	dy.less.than.dx2

	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	dl.size

dy.less.than.dx2
	move.w	#%11001,d4


dl.size	move.w	d2,d1			larger delta is line length
	addq.w	#1,d1			+ 1 to prevent length of zero
	lsl.w	#6,d1			into correct position
	addq.w	#2,d1			+ width of two

	add.w	d3,d3			2 Sdelta
	move.w	d3,d0
	sub.w	d2,d0			2 Sdelta - Ldelta
	bge.s	no.sign

	or.w	#%1000000,d4		set SIGN flag

no.sign	add.w	d2,d2			2 Ldelta

dl.col	move.l	#line.colour.masks,a2

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	d3,bltbmod(a6)		2 Sdelta
	sub.w	d2,d3			2 Sdelta - 2 Ldelta
	move.w	d3,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#4*40,d3		total width of bitplanes
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	moveq	#4-1,d2
	move.w	(a2)+,d3		get first line mask
	bra.s	dl.start


dl.loop	lea	40(a1),a1
	move.w	(a2)+,d3		get next line mask

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

dl.start
	move.l	a1,bltcpth(a6)		start address of line
	move.l	a1,bltdpth(a6)		start address of line
	move.w	d0,bltapth+2(a6)	2 Sdelta - Ldelta
	move.l	d4,bltcon0(a6)
	move.w	d3,bltbdat(a6)		set line mask
	move.w	d1,bltsize(a6)		start blitter

	dbra	d2,dl.loop		do all bitplanes
	rts



y.table	ds.w	200




*"""""""""""""""""""""
*" OTHER SUBROUTINES "
*"		     "
*"""""""""""""""""""""

keyboard.requests
	move.b	frames.requested(pc),d0
	beq.s	no.request1

	bsr	frames.per.sec

no.request1
	rts




print	move.l	screen1(pc),a1		d0 = x, d1 = y
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



* Spectrum font, characters 32-126, each 8*8 pixels

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




frames.per.sec			* using horiz. sync. pulse counter in CIA-B
				* it is a 24-bit counter
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
	lea	frames.text+3(pc),a1
	move.b	(a0),(a1)
	move.b	#'.',-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#18,d0			x
	moveq	#0,d1			y
	bra	print



old.counter
	dc.w	0



frames.text
	dc.b	'    ',0
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

	move.l	d0,cop1lch(a6)		set new copper list address
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
;	bra.s	init.copper




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




*""""""""""""""""""""
*" THE COPPER LISTS "
*"		    "
*""""""""""""""""""""

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

	dc.w	$1001,$ff00

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

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list3
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.mem	dc.l	0

screen1		dc.l	0
screen2		dc.l	0
screen3		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2
copper3		dc.l	copper.list3

gfxbase		dc.l	0
old.ints	dc.w	0
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0

raw.key.code	dc.b	0
frames.requested	dc.b	0

register.mouse.x	dc.b	0
register.mouse.y	dc.b	0

base.x.angle	dc.w	0
base.y.angle	dc.w	0
base.z.angle	dc.w	0

sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	$4000000

new.coords	ds.w	200*3		space for 200 coordinates

current.section	dc.w	0
current.piece	dc.l	0




*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
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




*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$997,$bb9,$ff0,$9b3,$577,$5bf,$59f
	dc.w	$357,$500,$733,$955,$d99,$775,$bbb,$fff



top.colours
	dc.l	0,0



line.colour.masks
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000
	dc.w	$0000,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000
	dc.w	$0000,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000
	dc.w	$0000,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$0000
	dc.w	$0000,$0000,$0000,$ffff
	dc.w	$ffff,$0000,$0000,$ffff
	dc.w	$0000,$ffff,$0000,$ffff
	dc.w	$ffff,$ffff,$0000,$ffff
	dc.w	$0000,$0000,$ffff,$ffff
	dc.w	$ffff,$0000,$ffff,$ffff
	dc.w	$0000,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff



piece.coords.ptrs
	dc.l	piece1.coords,piece2.coords,0,piece3.coords,piece4.coords
	dc.l	0,piece5.coords,piece6.coords,0,0,piece7.coords,0,0,0,0,0



left.y.coordinate.IDs

* Bit 8 indicates that the y coords for that section are stored as words
* e.g. for steeper sections on the roller coaster or the high jump

	dc.b	$6a,$6b,$24,$50,$50,$25,$00,$00
	dc.b	$19,$63,$04,$65,$68,$64,$69,$17
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$03,$16,$00,$19,$04,$00,$00,$00
	dc.b	$28,$29,$00,$2a,$2b,$00,$00,$09
	dc.b	$16,$00,$1b,$04


right.y.coordinate.IDs

* Bit 8 goes to other.road.line.colour

	dc.b	$6a,$6b,$24,$50,$50,$25,$00,$00
	dc.b	$19,$63,$64,$66,$e7,$04,$69,$17
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$04,$17,$80,$18,$03,$80,$00,$80
	dc.b	$28,$a9,$00,$aa,$2b,$80,$00,$8a
	dc.b	$17,$00,$9a,$03


road.section.angle.and.piece

* Top two bits are the rough angle for the piece (0, 90, 180 or 270 degrees).
*
* Bit 4 indicates that piece is rotated through a further 180 degrees.
*
* Bottom nibble is the near section piece to use.

	dc.b	$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	dc.b	$a0,$a0,$80,$86,$57,$c0,$e0,$e0
	dc.b	$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
	dc.b	$c0,$c6,$b7,$01,$94,$2a,$2a,$2a
	dc.b	$2a,$2a,$2a,$2a,$2a,$2a,$2a,$04
	dc.b	$d3,$66,$17,$80


overall.left.y.shifts

* A value for each road section, used to shift all the left side y
* co-ordinates up by the same amount.

	dc.w	$0280,$0280,$0780,$0a60,$1260,$1a60,$1d40,$1d40
	dc.w	$1ce0,$1920,$17a0,$1380,$0ea0,$0660,$0560,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0500,$0700,$0760,$0700,$0500,$0500,$0500,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0700,$0760,$0700,$0500


overall.right.y.shifts

* Same as above, but for the right side y co-ordinates.

	dc.w	$0280,$0280,$0780,$0a60,$1260,$1a60,$1d40,$1d40
	dc.w	$1ce0,$1920,$1160,$0ec0,$0aa0,$08a0,$0560,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0300,$02a0,$02a0,$02a0,$0300,$0500,$0500,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0300
	dc.w	$02a0,$02a0,$02a0,$0300


piece.x.z.coords.ptrs
	dc.l	piece1,piece2,0,piece3,piece4,0,piece5,piece6
	dc.l	0,0,piece7,0,0,0,0,0


* Groups of X and Z co-ordinates follow.  There are two bytes for each
* co-ordinate - stored in low byte, high byte order.
*
* First line is :-	X = $340, Z = $000, X = $4c0, Z = $000

piece1	dc.b	$40,$03,$00,$00,$c0,$04,$00,$00		straight 8
	dc.b	$40,$03,$00,$01,$c0,$04,$00,$01
	dc.b	$40,$03,$00,$02,$c0,$04,$00,$02
	dc.b	$40,$03,$00,$03,$c0,$04,$00,$03
	dc.b	$40,$03,$00,$04,$c0,$04,$00,$04
	dc.b	$40,$03,$00,$05,$c0,$04,$00,$05
	dc.b	$40,$03,$00,$06,$c0,$04,$00,$06
	dc.b	$40,$03,$00,$07,$c0,$04,$00,$07
	dc.b	$40,$03,$00,$08,$c0,$04,$00,$08


piece2	dc.b	$40,$03,$00,$00,$c0,$04,$00,$00		curve 8
	dc.b	$4c,$03,$05,$01,$ca,$04,$df,$00
	dc.b	$73,$03,$07,$02,$eb,$04,$bc,$01
	dc.b	$b2,$03,$05,$03,$22,$05,$95,$02
	dc.b	$0a,$04,$fb,$03,$6d,$05,$68,$03
	dc.b	$7a,$04,$e7,$04,$cd,$05,$32,$04
	dc.b	$00,$05,$c8,$05,$40,$06,$f2,$04
	dc.b	$9c,$05,$9a,$06,$c5,$06,$a6,$05
	dc.b	$4c,$06,$5b,$07,$5b,$07,$4c,$06


piece3	dc.b	$3f,$03,$00,$00,$bf,$04,$00,$00		curve 8
	dc.b	$35,$03,$df,$00,$b3,$04,$05,$01
	dc.b	$14,$03,$bc,$01,$8c,$04,$07,$02
	dc.b	$dd,$02,$95,$02,$4d,$04,$05,$03
	dc.b	$92,$02,$68,$03,$f5,$03,$fb,$03
	dc.b	$32,$02,$32,$04,$85,$03,$e7,$04
	dc.b	$bf,$01,$f2,$04,$ff,$02,$c8,$05
	dc.b	$3a,$01,$a6,$05,$63,$02,$9a,$06
	dc.b	$a4,$00,$4c,$06,$b3,$01,$5b,$07


piece4	dc.b	$78,$ff,$87,$00,$87,$00,$78,$ff		curve 13
	dc.b	$2c,$00,$3c,$01,$3c,$01,$2c,$00
	dc.b	$e1,$00,$f0,$01,$f0,$01,$e1,$00
	dc.b	$96,$01,$a5,$02,$a5,$02,$96,$01
	dc.b	$4a,$02,$5a,$03,$5a,$03,$4a,$02
	dc.b	$ff,$02,$0e,$04,$0e,$04,$ff,$02
	dc.b	$b3,$03,$c3,$04,$c3,$04,$b3,$03
	dc.b	$68,$04,$77,$05,$77,$05,$68,$04
	dc.b	$1d,$05,$2c,$06,$2c,$06,$1d,$05
	dc.b	$d1,$05,$e1,$06,$e1,$06,$d1,$05
	dc.b	$86,$06,$95,$07,$95,$07,$86,$06
	dc.b	$3a,$07,$4a,$08,$4a,$08,$3a,$07
	dc.b	$ef,$07,$ff,$08,$ff,$08,$ef,$07
	dc.b	$a4,$08,$b3,$09,$b3,$09,$a4,$08


piece5	dc.b	$40,$03,$00,$00,$c0,$04,$00,$00		curve 9
	dc.b	$4c,$03,$1c,$01,$ca,$04,$fb,$00
	dc.b	$71,$03,$36,$02,$eb,$04,$f4,$01
	dc.b	$af,$03,$4c,$03,$22,$05,$e9,$02
	dc.b	$04,$04,$5c,$04,$6d,$05,$d9,$03
	dc.b	$71,$04,$63,$05,$cd,$05,$c1,$04
	dc.b	$f5,$04,$60,$06,$41,$06,$a0,$05
	dc.b	$8e,$05,$50,$07,$c8,$06,$73,$06
	dc.b	$3b,$06,$32,$08,$61,$07,$3b,$07
	dc.b	$fc,$06,$03,$09,$0b,$08,$f4,$07


piece6	dc.b	$40,$03,$00,$00,$c0,$04,$00,$00		curve 9
	dc.b	$35,$03,$fb,$00,$b3,$04,$1c,$01
	dc.b	$14,$03,$f4,$01,$8e,$04,$36,$02
	dc.b	$dd,$02,$e9,$02,$50,$04,$4c,$03
	dc.b	$92,$02,$d9,$03,$fb,$03,$5c,$04
	dc.b	$32,$02,$c1,$04,$8e,$03,$63,$05
	dc.b	$be,$01,$a0,$05,$0a,$03,$60,$06
	dc.b	$37,$01,$73,$06,$71,$02,$50,$07
	dc.b	$9e,$00,$3b,$07,$c4,$01,$32,$08
	dc.b	$f4,$ff,$f4,$07,$03,$01,$03,$09


piece7	dc.b	$78,$ff,$87,$00,$87,$00,$78,$ff		straight 11
	dc.b	$32,$00,$41,$01,$41,$01,$32,$00
	dc.b	$ec,$00,$fc,$01,$fc,$01,$ec,$00
	dc.b	$a6,$01,$b6,$02,$b6,$02,$a6,$01
	dc.b	$60,$02,$70,$03,$70,$03,$60,$02
	dc.b	$1b,$03,$2a,$04,$2a,$04,$1b,$03
	dc.b	$d5,$03,$e4,$04,$e4,$04,$d5,$03
	dc.b	$8f,$04,$9f,$05,$9f,$05,$8f,$04
	dc.b	$49,$05,$59,$06,$59,$06,$49,$05
	dc.b	$03,$06,$13,$07,$13,$07,$03,$06
	dc.b	$be,$06,$cd,$07,$cd,$07,$be,$06
	dc.b	$78,$07,$87,$08,$87,$08,$78,$07




y.coordinate.pointers
	dc.l	B1037,B1051,W1060,B1078,B1092,B1106,B1116,B1126
	dc.l	B1135,B1144,B1158,B1172,B1181,B1190,W1202,B1226
	dc.l	W1235,B1259,B1271,B1281,B1290,B1300,B1309,B1319
	dc.l	B1329,B1338,B1347,B1357,B1367,B1376,B1385,B1394
	dc.l	B1403,B1412,B1424,B1433,B1442,B1451,B1463,B1472
	dc.l	B1481,B1493,B1505,B1517,B1529,B1538,B1547,B1556
	dc.l	B1565,B1574,B1586,B1598,B1612,B1622,B1631,W1640
	dc.l	B1658,B1667,B1676,B1685,B1694,B1703,B1712,B1721
	dc.l	B1731,B1740,W1750,B1768,B1777,B1786,B1795,B1804
	dc.l	B1814,B1823,B1832,B1841,B1850,B1862,B1871,W1880
	dc.l	B1904,0,B1918,B1927,B1936,B1950,B1964,B1973
	dc.l	B1983,B1993,B2005,B2014,B2023,B2032,B2042,W2051
	dc.l	W2069,W2087,W2105,B2123,B2132,B2144,B2154,B2164
	dc.l	B2174,B2184,B2193,B2202,B2211,B2220,B2229,B2238
	dc.l	B2250,B2260,W2272,B2296,B2308,W2317,B2335,B2344
	dc.l	0,0,B2353,0,B2362,B2372,B2382,B2392


******** Start of y co-ordinates for near sections ********
*
*	B means co-ords are stored as bytes, W means words.
*

B1037	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

B1051	dc.b	$00,$60,$61,$03,$44,$26,$28,$2a,$2c

W1060	dc.b	$00,$00,$02,$00,$04,$00,$06,$00,$08,$00,$0a,$00,$0c,$00
	dc.b	$0e,$00,$10,$00

B1078	dc.b	$00,$20,$40,$60,$01,$21,$41,$61,$02,$02,$02,$02,$02,$02

B1092	dc.b	$02,$61,$41,$21,$01,$60,$40,$20,$00,$00,$00,$00,$00,$00

B1106	dc.b	$00,$60,$21,$51,$02,$22,$42,$62,$03,$13

B1116	dc.b	$00,$20,$40,$70,$21,$41,$61,$02,$22,$32

B1126	dc.b	$00,$02,$04,$06,$e7,$29,$ca,$4b,$2c

B1135	dc.b	$46,$96,$55,$85,$24,$33,$b2,$21,$00

B1144	dc.b	$00,$00,$00,$00,$00,$10,$20,$40,$60,$01,$21,$41,$61,$02

B1158	dc.b	$02,$02,$02,$02,$02,$71,$61,$41,$21,$01,$60,$40,$20,$00

B1172	dc.b	$00,$10,$10,$10,$10,$10,$10,$90,$80

B1181	dc.b	$10,$00,$00,$00,$00,$00,$00,$80,$90

B1190	dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b

W1202	dc.b	$1b,$80,$1c,$80,$1d,$80,$1e,$80,$1f,$80,$20,$80,$a1,$80
	dc.b	$80,$00,$00,$00,$00,$00,$00,$00,$00,$00

B1226	dc.b	$4e,$1d,$db,$0a,$a8,$36,$34,$22,$00

W1235	dc.b	$00,$00,$9b,$20,$19,$e0,$18,$a0,$17,$60,$16,$20,$14,$e0
	dc.b	$13,$a0,$12,$60,$11,$20,$0f,$e0,$0e,$a0

B1259	dc.b	$48,$27,$26,$35,$44,$63,$13,$42,$71,$21,$50,$00

B1271	dc.b	$13,$03,$62,$42,$22,$02,$51,$21,$e0,$80

B1281	dc.b	$05,$05,$85,$00,$00,$85,$05,$05,$05

B1290	dc.b	$32,$22,$02,$61,$41,$21,$70,$40,$a0,$80

B1300	dc.b	$00,$40,$01,$41,$02,$42,$03,$33,$63

B1309	dc.b	$00,$20,$30,$30,$30,$30,$30,$30,$30,$30

B1319	dc.b	$30,$10,$00,$00,$00,$00,$00,$00,$00,$00

B1329	dc.b	$00,$00,$00,$00,$00,$00,$00,$90,$b0

B1338	dc.b	$30,$30,$30,$30,$30,$30,$30,$a0,$80

B1347	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$90,$b0

B1357	dc.b	$30,$30,$30,$30,$30,$30,$30,$30,$a0,$80

B1367	dc.b	$00,$21,$42,$53,$e4,$65,$e6,$57,$48

B1376	dc.b	$00,$60,$41,$92,$62,$a3,$63,$14,$44

B1385	dc.b	$00,$20,$40,$d0,$60,$60,$d0,$40,$20

B1394	dc.b	$04,$63,$b3,$03,$42,$82,$31,$60,$00

B1403	dc.b	$a6,$80,$00,$00,$00,$00,$00,$80,$35

B1412	dc.b	$47,$87,$46,$75,$25,$44,$63,$03,$22,$41,$60,$00

B1424	dc.b	$08,$27,$36,$c5,$44,$43,$32,$21,$00

B1433	dc.b	$50,$50,$50,$50,$c0,$30,$20,$10,$00

B1442	dc.b	$00,$00,$10,$30,$60,$11,$51,$22,$72

B1451	dc.b	$00,$60,$41,$a2,$d2,$62,$f2,$72,$72,$72,$72,$72

B1463	dc.b	$22,$b2,$32,$a2,$12,$f1,$31,$60,$00

B1472	dc.b	$0a,$68,$47,$26,$05,$63,$42,$21,$00

B1481	dc.b	$00,$10,$30,$60,$21,$71,$42,$13,$63,$34,$05,$55

B1493	dc.b	$55,$26,$76,$47,$18,$68,$39,$8a,$00,$00,$00,$00

B1505	dc.b	$00,$c7,$76,$26,$55,$05,$34,$63,$13,$42,$71,$21

B1517	dc.b	$21,$60,$30,$10,$00,$00,$00,$00,$00,$00,$00,$00

B1529	dc.b	$8a,$80,$00,$00,$00,$00,$00,$80,$4c

B1538	dc.b	$00,$41,$03,$44,$06,$47,$09,$4a,$0c

B1547	dc.b	$70,$50,$30,$10,$00,$10,$30,$50,$70

B1556	dc.b	$aa,$80,$00,$00,$00,$00,$00,$80,$2a

B1565	dc.b	$59,$49,$39,$a9,$63,$63,$63,$63,$47

B1574	dc.b	$00,$00,$00,$10,$30,$50,$01,$31,$71,$42,$23,$14

B1586	dc.b	$62,$62,$62,$d2,$42,$a2,$02,$61,$b1,$01,$40,$00

B1598	dc.b	$00,$40,$01,$41,$02,$42,$03,$43,$04,$64,$45,$26,$07,$67

B1612	dc.b	$00,$10,$20,$30,$40,$40,$40,$40,$40,$40

B1622	dc.b	$00,$00,$00,$00,$00,$10,$30,$60,$21

B1631	dc.b	$8d,$80,$00,$00,$00,$00,$00,$00,$00

W1640	dc.b	$00,$00,$00,$00,$80,$00,$9c,$80,$1c,$80,$9c,$80,$80,$00
	dc.b	$00,$00,$00,$00

B1658	dc.b	$00,$00,$10,$20,$40,$60,$01,$31,$71

B1667	dc.b	$00,$10,$30,$70,$31,$71,$b2,$52,$62

B1676	dc.b	$00,$00,$00,$10,$30,$60,$21,$02,$03

B1685	dc.b	$00,$10,$30,$60,$21,$71,$62,$53,$44

B1694	dc.b	$00,$70,$61,$52,$43,$34,$25,$16,$07

B1703	dc.b	$00,$00,$00,$00,$00,$00,$00,$80,$2e

B1712	dc.b	$00,$01,$f1,$52,$a3,$63,$94,$34,$54

B1721	dc.b	$00,$30,$d0,$70,$11,$a1,$31,$41,$41,$41

B1731	dc.b	$40,$10,$00,$00,$00,$10,$40,$11,$61

B1740	dc.b	$40,$40,$40,$40,$40,$40,$30,$20,$10,$00

W1750	dc.b	$9a,$c0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$80,$00,$0c,$80

B1768	dc.b	$24,$03,$02,$21,$60,$30,$10,$00,$00

B1777	dc.b	$47,$46,$65,$25,$05,$05,$15,$35,$75

B1786	dc.b	$80,$e6,$16,$45,$74,$24,$53,$23,$13

B1795	dc.b	$46,$25,$14,$13,$22,$41,$70,$30,$00

B1804	dc.b	$00,$01,$12,$33,$54,$75,$17,$38,$59,$7a

B1814	dc.b	$02,$71,$d1,$21,$60,$30,$10,$00,$00

B1823	dc.b	$00,$00,$10,$30,$60,$21,$d1,$71,$02

B1832	dc.b	$00,$40,$81,$31,$d1,$61,$f1,$71,$71

B1841	dc.b	$22,$61,$21,$60,$30,$10,$00,$00,$00

B1850	dc.b	$00,$60,$41,$22,$03,$63,$44,$25,$06,$66,$47,$28

B1862	dc.b	$00,$00,$10,$30,$60,$21,$71,$52,$43

B1871	dc.b	$24,$45,$e6,$80,$21,$42,$63,$05,$26

W1880	dc.b	$28,$60,$27,$c0,$27,$40,$26,$e0,$26,$a0,$26,$80,$26,$80
	dc.b	$26,$a0,$26,$e0,$27,$20,$a7,$60,$00,$00

B1904	dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$68,$49,$2a,$0b,$6b

B1918	dc.b	$00,$70,$51,$32,$13,$73,$54,$35,$06

B1927	dc.b	$00,$50,$31,$12,$72,$53,$34,$15,$06

B1936	dc.b	$00,$60,$41,$22,$03,$73,$64,$65,$66,$67,$68,$69,$6a,$6b

B1950	dc.b	$00,$60,$41,$22,$03,$53,$24,$64,$25,$65,$26,$66,$27,$67

B1964	dc.b	$00,$81,$61,$a2,$42,$52,$52,$52,$52

B1973	dc.b	$00,$41,$72,$14,$35,$56,$77,$19,$3a,$5b

B1983	dc.b	$00,$21,$42,$63,$05,$26,$47,$68,$1a,$5b

B1993	dc.b	$64,$14,$43,$72,$22,$51,$01,$40,$20,$10,$00,$00

B2005	dc.b	$05,$05,$05,$15,$25,$45,$e5,$00,$00

B2014	dc.b	$22,$12,$f1,$51,$31,$11,$60,$30,$00

B2023	dc.b	$00,$50,$31,$22,$23,$34,$55,$76,$18

B2032	dc.b	$00,$21,$42,$63,$05,$26,$47,$68,$79,$7a

B2042	dc.b	$52,$71,$21,$60,$30,$10,$00,$00,$00

W2051	dc.b	$00,$00,$00,$20,$00,$40,$00,$60,$32,$00,$00,$60,$00,$40
	dc.b	$00,$20,$00,$00

W2069	dc.b	$00,$00,$00,$20,$00,$40,$00,$60,$32,$00,$00,$60,$00,$40
	dc.b	$00,$20,$00,$00

W2087	dc.b	$00,$00,$00,$20,$00,$40,$00,$60,$32,$00,$00,$60,$00,$40
	dc.b	$00,$20,$00,$00

W2105	dc.b	$00,$00,$00,$20,$00,$40,$00,$60,$32,$00,$00,$60,$00,$40
	dc.b	$00,$20,$00,$00

B2123	dc.b	$63,$43,$a3,$f2,$42,$02,$41,$01,$40

B2132	dc.b	$28,$47,$66,$06,$25,$44,$63,$03,$22,$41,$60,$00

B2144	dc.b	$14,$73,$43,$03,$42,$02,$41,$01,$40,$00

B2154	dc.b	$74,$14,$43,$03,$42,$02,$41,$01,$40,$00

B2164	dc.b	$14,$53,$13,$52,$12,$51,$11,$50,$a0,$80

B2174	dc.b	$74,$34,$73,$33,$72,$32,$71,$31,$e0,$80

B2184	dc.b	$23,$62,$22,$61,$21,$70,$40,$20,$00

B2193	dc.b	$42,$42,$52,$72,$13,$43,$f3,$80,$00

B2202	dc.b	$00,$00,$00,$80,$85,$05,$05,$05,$05

B2211	dc.b	$0c,$59,$47,$55,$04,$52,$41,$50,$00

B2220	dc.b	$00,$10,$30,$50,$e0,$50,$30,$10,$00

B2229	dc.b	$00,$00,$00,$00,$80,$00,$00,$00,$00

B2238	dc.b	$04,$04,$04,$04,$04,$04,$73,$e3,$33,$52,$41,$00

B2250	dc.b	$44,$04,$43,$03,$42,$02,$41,$01,$40,$00

B2260	dc.b	$41,$41,$41,$41,$41,$41,$31,$a1,$01,$e0,$30,$00

W2272	dc.b	$18,$c0,$16,$80,$14,$40,$12,$00,$0f,$c0,$0d,$80,$0b,$40
	dc.b	$09,$00,$06,$c0,$04,$80,$02,$40,$00,$00

B2296	dc.b	$7e,$4c,$1a,$08,$16,$44,$13,$02,$11,$40,$10,$00

B2308	dc.b	$60,$30,$10,$00,$00,$10,$30,$60,$21

W2317	dc.b	$13,$00,$10,$a0,$0e,$40,$0b,$e0,$09,$80,$07,$20,$04,$c0
	dc.b	$02,$60,$00,$00

B2335	dc.b	$00,$e8,$18,$47,$76,$26,$55,$05,$34

B2344	dc.b	$00,$00,$00,$10,$30,$60,$21,$71,$42

B2353	dc.b	$00,$21,$42,$63,$05,$26,$47,$68,$0a

B2362	dc.b	$00,$60,$31,$71,$32,$72,$33,$73,$34,$74

B2372	dc.b	$00,$20,$50,$11,$51,$12,$52,$13,$53,$14

B2382	dc.b	$00,$40,$01,$41,$02,$42,$03,$43,$94,$f4

B2392	dc.b	$00,$40,$01,$41,$02,$42,$03,$43,$f3,$94
	even




piece1.coords
	dc.w	36-1
	ds.w	36*3



piece2.coords
	dc.w	36-1
	ds.w	36*3



piece3.coords
	dc.w	36-1
	ds.w	36*3



piece4.coords
	dc.w	56-1
	ds.w	56*3



piece5.coords
	dc.w	40-1
	ds.w	40*3



piece6.coords
	dc.w	40-1
	ds.w	40*3



piece7.coords
	dc.w	48-1
	ds.w	48*3




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
