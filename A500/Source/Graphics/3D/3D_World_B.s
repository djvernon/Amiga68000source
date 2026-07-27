	section	3D_World,code_c




XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2

SPEED.LIMIT	equ	8192
FLOOR.LIMIT	equ	$20000000
VISION.LIMIT	equ	$20000000




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


	bsr	make.copper.lists	initialise copper

	move.l	copper1(pc),cop1lch(a6)
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




	move.b	joy0dat+1(a6),register.mouse.x
	move.b	joy0dat(a6),register.mouse.y




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	clear.plane.2

	bsr	player.movement

	bsr	update.3d.world

	bsr	clear.planes.1.3

	bsr	player.collisions

	bsr	draw.horizon

	bsr	draw.floor

	bsr	draw.3d.world

	bsr	keyboard.requests

	bsr	update.screens

	btst	#6,$bfe001
	bne.s	loop




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
	move.l	#3*4*40*200,d0
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
	bne.s	check.help
	not.b	frames.requested
	bra.s	end.level2

check.help
	cmp.b	#$5f,d0			HELP
	bne.s	end.level2
	not.b	palette.requested

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

	move.b	joy0dat+1(a6),d0	x mouse movement
	move.b	d0,d1
	sub.b	register.mouse.x(pc),d0
	move.b	d1,register.mouse.x

	move.b	joy0dat(a6),d1		y mouse movement
	move.b	d1,d2
	sub.b	register.mouse.y(pc),d1
	move.b	d2,register.mouse.y

check.left.button
	btst	#6,$bfe001
	seq	left.mouse.button

check.right.button
	btst	#2,potgor(a6)
	seq	right.mouse.button
	beq.s	speed.change

direction.change
	ext.w	d0
	add.w	d0,d0
	sub.w	d0,player.z.angle

	ext.w	d1
	add.w	d1,d1
	sub.w	d1,player.x.angle

	movem.l	(sp)+,d0-d2
	rte




speed.change
	ext.w	d1
	beq.s	end.level3

	sf	collision.flag

	add.w	d1,d1
	neg.w	d1
	add.w	player.speed(pc),d1
	cmp.w	#-SPEED.LIMIT,d1
	blt.s	end.level3

	cmp.w	#SPEED.LIMIT,d1
	bgt.s	end.level3

	move.w	d1,player.speed

end.level3
	movem.l	(sp)+,d0-d2
	rte




;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""

player.movement
	move.w	x.rebound.count(pc),d0
	beq.s	no.x.rebound

	subq.w	#1,x.rebound.count

	move.w	x.rebound.value(pc),d0
	sub.w	d0,player.x.angle

no.x.rebound
	move.b	collision.flag(pc),d0
	beq.s	no.collision

	move.w	player.speed(pc),d0	reduce speed after collision
	asr.w	#3,d0
	sub.w	d0,player.speed

no.collision
	move.w	player.x.angle(pc),d0
	move.w	player.z.angle(pc),d1
	asr.w	#1,d0
	asr.w	#1,d1

	move.w	#-256,d2
	move.w	#256,d3

	cmp.w	d2,d0
	bge.s	x.not.min

	move.w	d2,d0

x.not.min
	cmp.w	d3,d0
	ble.s	x.not.max

	move.w	d3,d0

x.not.max
	cmp.w	d2,d1
	bge.s	z.not.min

	move.w	d2,d1

z.not.min
	cmp.w	d3,d1
	ble.s	z.not.max

	move.w	d3,d1

z.not.max
	move.w	d1,d2

	and.w	#$7fe,d0
	and.w	#$7fe,d1
	move.w	d0,new.x.angle
	move.w	d1,new.z.angle

	swap	d2
	clr.w	d2
	asr.l	#3,d2
	add.l	d2,new.y.angle
	and.w	#$3ff,new.y.angle

	move.w	new.x.angle(pc),d0
	move.w	new.y.angle(pc),d1
	move.w	new.z.angle(pc),d2
	add.w	d1,d1
	lea	world.sin.cos.values(pc),a0
	bsr	calc.sin.cos.values

	movem.w	world.sin.cos.values+12(pc),d0-d2
	move.w	player.speed(pc),d3
	muls	d3,d0
	muls	d3,d1
	muls	d3,d2
	add.l	d0,player.x.offset
	add.l	d2,player.z.offset
	add.l	player.y.offset(pc),d1
	move.l	d1,d2
	swap	d2
	asr.w	#8,d2
	asr.w	#4,d2
	beq.s	within.y.boundary	if between 0 and $fff

	move.w	x.rebound.count(pc),d0
	bne.s	set.player.view

	move.w	player.x.angle(pc),d0
	asr.w	#2,d0
	move.w	d0,x.rebound.value
	move.w	#5,x.rebound.count

;	bsr	reduce.player.energy
	bra.s	set.player.view

within.y.boundary
	move.l	d1,player.y.offset

set.player.view
	move.w	required.view.angle(pc),d0
	sub.w	current.view.angle(pc),d0
	and.w	#$3ff,d0
	beq.s	set.view.values		if required view reached

	add.w	#$10,current.view.angle
	cmp.w	#$200,d0
	ble.s	set.view.values

	sub.w	#$20,current.view.angle

set.view.values
	move.w	current.view.angle(pc),d0
	and.w	#$3ff,d0
	add.w	d0,d0

	lea	cosine(pc),a0
	move.w	(a0,d0.w),d7		cosy

	lea	sine(pc),a0
	move.w	(a0,d0.w),d6		siny

	movem.w	world.sin.cos.values(pc),d0-d2
	movem.w	world.sin.cos.values+12(pc),d3-d5

	muls	d7,d0			X parts * cosy
	muls	d7,d1
	muls	d7,d2

	muls	d6,d3			Z parts * siny
	muls	d6,d4
	muls	d6,d5

	add.l	d0,d3			X cosy + Z siny
	add.l	d1,d4
	add.l	d2,d5

	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	swap	d3
	swap	d4
	swap	d5

	movem.w	world.sin.cos.values(pc),d0-d2

	movem.w	d3-d5,world.sin.cos.values	save new X parts

	movem.w	world.sin.cos.values+12(pc),d3-d5

	muls	d7,d3			Z parts * cosy
	muls	d7,d4
	muls	d7,d5

	muls	d6,d0			X parts * siny
	muls	d6,d1
	muls	d6,d2

	sub.l	d0,d3			Z cosy - X siny
	sub.l	d1,d4
	sub.l	d2,d5

	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	swap	d3
	swap	d4
	swap	d5

	movem.w	d3-d5,world.sin.cos.values+12	save new Z parts
	rts




;reduce.player.energy
;	move.w	player.speed(pc),d0
;	bpl.s	speed.positive
;
;	neg.w	d0
;
;speed.positive
;	lsr.w	#7,d0
;	sub.w	d0,player.energy
;	bhi.s	energy.not.depleted
;
;	clr.w	player.energy
;
;energy.not.depleted
;	rts




player.collisions
	move.l	collision.pointer(pc),d0
	beq.s	collision.done

	neg.w	player.speed

	st	collision.flag

collision.done
	rts




rotate.point
	lea	world.sin.cos.values(pc),a1
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
	muls	(a1),d2			Z(cosx.cosy)
	add.l	d6,d2
	add.l	d4,d2			rotated Z
	rts




draw.horizon
	lea	world.sin.cos.values(pc),a0
	move.w	12(a0),d0
	move.w	16(a0),d2

	move.w	#$1000,d1
	sub.w	player.y.offset(pc),d1

	move.w	d0,d3
	move.w	d2,d4
	muls	d3,d3
	muls	d4,d4
	add.l	d3,d4
	swap	d4

	move.w	d1,d3
	muls	14(a0),d3
	swap	d3
	sub.w	#$2000,d3
	neg.w	d3
	muls	d3,d0
	muls	d3,d2

	divs	d4,d0
	divs	d4,d2

	move.w	d0,d3
	add.w	d2,d0
	sub.w	d3,d2

	movem.w	d0-d2,-(sp)

	bsr.s	rotate.point

	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0
	add.w	#YMID,d1

	move.w	d0,a0
	move.w	d1,a2

	move.w	(sp)+,d2		old X becomes Z
	move.w	(sp)+,d1		restore Y
	move.w	(sp)+,d0		old Z becomes X

	neg.w	d0

	bsr	rotate.point

	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0
	add.w	#YMID,d1

	move.w	a0,d2
	move.w	a2,d3

	move.l	screen1(pc),a1
	lea	120(a1),a1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d4,d6

	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	bpl.s	y2.bigger.than.y1

	exg	d0,d2
	exg	d1,d3

	neg.w	d4
	neg.w	d5

y2.bigger.than.y1
	tst.w	d3			y2
	ble	fill.whole.plane	if bottom y off top

	tst.w	d1			y1
	bpl.s	y1.on.screen

	muls	d4,d1			y1 * (x2-x1)
	divs	d5,d1			(y1 * (x2-x1)) / (y2-y1)
	sub.w	d1,d0			x1 - ((y1 * (x2-x1)) / (y2-y1))

	moveq	#0,d1			y1 = 0

y1.on.screen
	tst.w	d4			x2-x1
	bmi.s	slope.negative

	cmp.w	#XMAX,d0		x1
	bge	fill.whole.plane	if smallest x off right

	tst.w	d2			x2
	ble	fill.whole.plane	if largest x off left

	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.on.screen

	muls	d5,d0			x1 * (y2-y1)
	divs	d4,d0			(x1 * (y2-y1)) / (x2-x1)
	sub.w	d0,d1			y1 - ((x1 * (y2-y1)) / (x2-x1))

	sub.w	d1,d7			number of non-clear lines
	ble	clear.whole.plane

	bsr	fill.clear.lines
	moveq	#0,d0			x1 = 0

x1.on.screen
	tst.w	d5			y2-y1
	beq	fill.solid.lines

	moveq	#0,d2
	move.w	d4,d2			x2-x1
	divu	d5,d2			(x2-x1) / (y2-y1)
	move.w	d2,d1
	swap	d1
	clr.w	d2

	divu	d5,d2
	move.w	d2,d1
	bra.s	fill.sloped.part




slope.negative
	tst.w	d0			x1
	ble	fill.whole.plane	if largest x off left

	cmp.w	#XMAX,d2		x2
	bge	fill.whole.plane	if smallest x off right

	move.w	#YMAX-1,d7

	cmp.w	#XMAX,d0		x1
	blt.s	x1.on.screen2

	sub.w	#XMAX,d0		x1-max
	muls	d5,d0			(x1-max) * (y2-y1)
	divs	d4,d0			((x1-max) * (y2-y1)) / (x2-x1)
	sub.w	d0,d1			y1 - (((x1-max) * (y2-y1)) / (x2-x1))

	sub.w	d1,d7			number of non-clear lines
	ble	clear.whole.plane

	bsr	fill.clear.lines
	move.w	#XMAX,d0		x1 = max

x1.on.screen2
	tst.w	d5			y2-y1
	beq	fill.solid.lines

	neg.w	d4
	moveq	#0,d2
	move.w	d4,d2
	divu	d5,d2
	move.w	d2,d1
	swap	d1
	clr.w	d2

	divu	d5,d2
	move.w	d2,d1
	neg.l	d1

fill.sloped.part
	swap	d0
	clr.w	d0
	moveq	#-1,d3
	lea	filled.to.clear.masks(pc),a0

	move.l	d1,d4
	swap	d4
	eor.w	d6,d4
	bpl.s	fill.sloped.line

	not.w	d3
	lea	clear.to.filled.masks(pc),a0

fill.sloped.line
	add.l	d1,d0
	bmi	fill.solid.lines

	move.l	d0,d4
	swap	d4
	cmp.w	#XMAX,d4
	bge.s	fill.solid.lines

	moveq	#$f,d5
	and.w	d4,d5
	sub.w	d5,d4
	lsr.w	#3,d4
	neg.w	d4
	jmp	fill.words(pc,d4.w)

	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+

fill.words
	add.w	d5,d5
	move.w	(a0,d5.w),(a1)+
	neg.w	d4
	not.w	d3
	jmp	fill.words2(pc,d4.w)

fill.words2
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+

	not.w	d3
	lea	120(a1),a1
	dbra	d7,fill.sloped.line
	rts




fill.solid.lines
	neg.w	d6
	move.w	d7,d1
	addq.w	#1,d1
	bra.s	fill.clear.lines




fill.whole.plane
	neg.w	d6

clear.whole.plane
	move.w	#YMAX,d1

fill.clear.lines
	moveq	#-1,d2

	tst.w	d6
	bmi.s	line.mask.set

	not.l	d2

line.mask.set
	bra.s	next.whole.line




fill.whole.line
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+

	lea	120(a1),a1

next.whole.line
	dbra	d1,fill.whole.line
	rts



clear.to.filled.masks
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001



filled.to.clear.masks
	dc.w	$0000,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe




draw.floor
	move.w	#fcol21,fill.colour+2

	move.w	world.sin.cos.values(pc),d0
	move.w	world.sin.cos.values+6(pc),d1
	move.w	world.sin.cos.values+12(pc),d2

	move.w	world.sin.cos.values+4(pc),d3
	move.w	world.sin.cos.values+10(pc),d4
	move.w	world.sin.cos.values+16(pc),d5

	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	ext.l	d4
	ext.l	d5

	moveq	#9,d6
	asl.l	d6,d0
	asl.l	d6,d1
	asl.l	d6,d2
	asl.l	d6,d3
	asl.l	d6,d4
	asl.l	d6,d5

	movem.l	d0-d5,tileX.xpart

	tst.l	d2
	bpl.s	Z.xpart.positive

	neg.l	d0
	neg.l	d1
	neg.l	d2

Z.xpart.positive
	tst.l	d5
	bpl.s	Z.zpart.positive

	neg.l	d3
	neg.l	d4
	neg.l	d5

Z.zpart.positive
	cmp.l	d2,d5
	bgt.s	zpart.greater.than.xpart

	exg	d0,d3
	exg	d1,d4
	exg	d2,d5

zpart.greater.than.xpart
	asl.l	#3,d0
	asl.l	#3,d1
	asl.l	#3,d2
	asl.l	#3,d3
	asl.l	#3,d4
	asl.l	#3,d5

	movem.l	d0-d5,gapX.xpart

; draw ceiling

	move.w	player.y.offset(pc),d1
	neg.w	d1
	lea	point.offsets2(pc),a0
	bsr.s	draw.tiled.surface

; draw floor

	move.w	#$1000,d1
	sub.w	player.y.offset(pc),d1
	lea	point.offsets1(pc),a0

draw.tiled.surface
	move.w	player.x.offset(pc),d0
	and.w	#$fff,d0
	neg.w	d0
	add.w	#$800,d0

	move.w	player.z.offset(pc),d2
	and.w	#$fff,d2
	neg.w	d2
	add.w	#$800,d2

	bsr	rotate.point

	add.l	#$800*32768,d2

	movem.l	d0-d2,-(sp)
	bsr.s	half.tiled.surface
	movem.l	(sp)+,d0-d2

	neg.l	gapX.xpart
	neg.l	gapY.xpart
	neg.l	gapZ.xpart

half.tiled.surface
test.x	move.l	d0,d3
	bpl.s	x.plus

	neg.l	d3

x.plus	cmp.l	d3,d2
	blt.s	z.less.than.x

test.x2	move.l	d0,d3
	bpl.s	x.plus2

	neg.l	d3

x.plus2	cmp.l	d3,d2
	blt.s	z.less.than.x2

	cmp.l	#FLOOR.LIMIT,d3
	bgt.s	out.of.range

	sub.l	gapX.zpart(pc),d0
	sub.l	gapY.zpart(pc),d1
	sub.l	gapZ.zpart(pc),d2
	bpl.s	test.x2

	bra.s	z.less.than.x2

z.less.than.x
	move.l	d0,d3
	bpl.s	x.plus3

	neg.l	d3

x.plus3	cmp.l	d3,d2
	bgt.s	z.less.than.x2

	cmp.l	#FLOOR.LIMIT,d3
	bgt.s	out.of.range

	add.l	gapX.zpart(pc),d0
	add.l	gapY.zpart(pc),d1
	add.l	gapZ.zpart(pc),d2

	cmp.l	#FLOOR.LIMIT,d2
	blt.s	z.less.than.x

	bra.s	out.of.range

z.less.than.x2
	movem.l	d0-d2,-(sp)
	bsr.s	draw.tile.strip
	movem.l	(sp)+,d0-d2

out.of.range
	add.l	gapX.xpart(pc),d0
	add.l	gapY.xpart(pc),d1
	add.l	gapZ.xpart(pc),d2

	move.l	d0,d3
	bpl.s	x.plus4

	neg.l	d3

x.plus4	cmp.l	#FLOOR.LIMIT,d3
	blt.s	half.tiled.surface
	rts




draw.tile.strip
	sub.l	#$800*32768,d2

draw.tile
	movem.l	d0-d2/a0,-(sp)

	lea	new.coords(pc),a2
	move.l	d0,d3
	move.l	d1,d4
	asr.l	#8,d3
	asr.l	#8,d4
	swap	d2
	cmp.w	#128,d2
	blt	tile.too.near

	divs	d2,d3
	divs	d2,d4
	add.w	#XMID,d3		centre on screen
	add.w	#YMID,d4
	move.w	d3,(a2)+		save screen x
	move.w	d4,(a2)+		save screen y
	move.w	d2,(a2)+		save z
	swap	d2
	add.l	tileX.zpart(pc),d0
	add.l	tileY.zpart(pc),d1
	add.l	tileZ.zpart(pc),d2

	move.l	d0,d3
	move.l	d1,d4
	asr.l	#8,d3
	asr.l	#8,d4
	swap	d2
	cmp.w	#128,d2
	blt	tile.too.near

	divs	d2,d3
	divs	d2,d4
	add.w	#XMID,d3		centre on screen
	add.w	#YMID,d4
	move.w	d3,(a2)+		save screen x
	move.w	d4,(a2)+		save screen y
	move.w	d2,(a2)+		save z
	swap	d2
	add.l	tileX.xpart(pc),d0
	add.l	tileY.xpart(pc),d1
	add.l	tileZ.xpart(pc),d2

	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	cmp.w	#128,d2
	blt.s	tile.too.near

	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0		centre on screen
	add.w	#YMID,d1
	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y
	move.w	d2,(a2)+		save z

	movem.l	(sp),d0-d2
	add.l	tileX.xpart(pc),d0
	add.l	tileY.xpart(pc),d1
	add.l	tileZ.xpart(pc),d2

	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	cmp.w	#128,d2
	blt.s	tile.too.near

	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0		centre on screen
	add.w	#YMID,d1
	move.w	d0,(a2)+		save screen x
	move.w	d1,(a2)+		save screen y
	move.w	d2,(a2)			save z

	lea	new.coords(pc),a1
	bsr	polygon

next.tile
	movem.l	(sp)+,d0-d2/a0

	add.l	gapX.zpart(pc),d0
	add.l	gapY.zpart(pc),d1
	add.l	gapZ.zpart(pc),d2

	cmp.l	#FLOOR.LIMIT,d2
	blt	draw.tile
	rts




tile.too.near
	movem.l	(sp),d0-d2
	lea	new.coords(pc),a2
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,(a2)+		save x
	move.w	d1,(a2)+		save y
	move.w	d2,(a2)+		save z
	swap	d0
	swap	d1
	cmp.w	#128,d2
	blt.s	no.screen.x.y

	move.l	d0,d3
	move.l	d1,d4
	asr.l	#8,d3
	asr.l	#8,d4
	divs	d2,d3
	divs	d2,d4
	add.w	#XMID,d3		centre on screen
	add.w	#YMID,d4
	movem.w	d3-d4,(a2)		save screen x and y

no.screen.x.y
	addq.l	#4,a2
	swap	d2
	add.l	tileX.zpart(pc),d0
	add.l	tileY.zpart(pc),d1
	add.l	tileZ.zpart(pc),d2

	swap	d0
	swap	d1
	swap	d2
	move.w	d0,(a2)+		save x
	move.w	d1,(a2)+		save y
	move.w	d2,(a2)+		save z
	swap	d0
	swap	d1
	cmp.w	#128,d2
	blt.s	no.screen.x.y2

	move.l	d0,d3
	move.l	d1,d4
	asr.l	#8,d3
	asr.l	#8,d4
	divs	d2,d3
	divs	d2,d4
	add.w	#XMID,d3		centre on screen
	add.w	#YMID,d4
	movem.w	d3-d4,(a2)		save screen x and y

no.screen.x.y2
	addq.l	#4,a2
	swap	d2
	add.l	tileX.xpart(pc),d0
	add.l	tileY.xpart(pc),d1
	add.l	tileZ.xpart(pc),d2

	swap	d0
	swap	d1
	swap	d2
	move.w	d0,(a2)+		save x
	move.w	d1,(a2)+		save y
	move.w	d2,(a2)+		save z
	cmp.w	#128,d2
	blt.s	no.screen.x.y3

	swap	d0
	swap	d1
	asr.l	#8,d0
	asr.l	#8,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0		centre on screen
	add.w	#YMID,d1
	movem.w	d0-d1,(a2)		save screen x and y

no.screen.x.y3
	addq.l	#4,a2

	movem.l	(sp),d0-d2
	add.l	tileX.xpart(pc),d0
	add.l	tileY.xpart(pc),d1
	add.l	tileZ.xpart(pc),d2

	swap	d0
	swap	d1
	swap	d2
	move.w	d0,(a2)+		save x
	move.w	d1,(a2)+		save y
	move.w	d2,(a2)+		save z
	cmp.w	#128,d2
	blt.s	no.screen.x.y4

	swap	d0
	swap	d1
	asr.l	#8,d0
	asr.l	#8,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0		centre on screen
	add.w	#YMID,d1
	movem.w	d0-d1,(a2)		save screen x and y

no.screen.x.y4
	lea	10(a0),a0
	bsr	polygon.z.clip
	bra	next.tile



point.offsets1
	dc.w	4,0,6,12,18
	dc.w	4,4,14,24,34,4

point.offsets2
	dc.w	4,18,12,6,0
	dc.w	4,34,24,14,4,34




update.3d.world
	lea	world.data(pc),a1
	clr.l	world.pointer
	clr.l	collision.pointer

	move.w	(a1),d0
	beq.s	next.object

update	bsr.s	objects.position

next.object
	lea	36(a1),a1
	move.w	(a1),d0
	beq.s	next.object

	bpl.s	update
	rts




objects.position

; work out objects position relative to the player

	movem.l	10(a1),d0-d2		objects offsets in world
	sub.l	player.x.offset(pc),d0
	sub.l	player.y.offset(pc),d1
	sub.l	player.z.offset(pc),d2
	swap	d0			X
	swap	d1			Y
	swap	d2			Z

	move.w	d2,d6
	movem.w	world.sin.cos.values+12(pc),d3-d5
	muls	d0,d3			X(-cosx.siny)
	muls	d1,d4			Y(sinx)
	muls	d5,d2			Z(cosx.cosy)
	add.l	d3,d2
	add.l	d4,d2			rotated Z
	bgt.s	object.in.front

end.update
	rts

object.in.front
	lea	world.sin.cos.values(pc),a2
	move.w	d0,d3			X
	move.w	d1,d4			Y
	move.w	d6,d5			Z

	muls	(a2)+,d0		X(cosy.cosz - sinx.siny.sinz)
	muls	(a2)+,d4		Y(-cosx.sinz)
	muls	(a2)+,d5		Z(siny.cosz + sinx.cosy.sinz)
	add.l	d4,d0
	add.l	d5,d0			rotated X

	muls	(a2)+,d3		X(cosy.sinz + sinx.siny.cosz)
	muls	(a2)+,d1		Y(cosx.cosz)
	muls	(a2),d6			Z(siny.sinz - sinx.cosy.cosz)
	add.l	d3,d1
	add.l	d6,d1			rotated Y

	movem.l	d0-d2,22(a1)		save objects transformed offsets

	cmp.l	d2,d1
	bgt.s	end.update		if object off bottom

	add.l	d2,d1
	blt.s	end.update		if object off top

	cmp.l	d2,d0
	bgt.s	end.update		if object off right

	add.l	d2,d0
	blt.s	end.update		if object off left

	cmp.l	#1200*32768,d2
	bgt.s	out.of.collision.range

	movem.l	d2/a1,collision.z.distance

out.of.collision.range
	cmp.l	#VISION.LIMIT,d2
	bgt.s	end.update		if object too far away

	moveq	#0,d0
	move.l	d0,2(a1)
	move.l	d0,6(a1)

	move.l	world.pointer(pc),d1
	beq.s	save.world.pointer

z.compare
	move.l	d1,a2
	cmp.l	30(a2),d2		transformed Z
	bgt.s	further.away

	move.l	2(a2),d1
	bne.s	z.compare

	move.l	a1,2(a2)
	rts

further.away
	move.l	6(a2),d1
	bne.s	z.compare

	move.l	a1,6(a2)
	rts

save.world.pointer
	move.l	a1,world.pointer
	rts




draw.3d.world
	move.l	world.pointer(pc),d0
	beq.s	end.draw.3d.world	if zero then no objects to draw

next.set
	move.l	d0,a1
	move.l	a1,-(sp)
	move.l	6(a1),d0		get pointer to next set
	beq.s	next.set.clear

	bsr.s	next.set
	move.l	(sp),a1

next.set.clear
	move.w	(a1),d3			get offset for this object
	beq.s	no.object

	jsr	object.table(pc,d3.w)	draw object

no.object
	move.l	(sp)+,a1
	move.l	2(a1),d0		get pointer to previous object
	bne.s	next.set

end.draw.3d.world
	rts



object.table
	bra.s	object.table
	bra.s	draw.tent
	bra.s	draw.house
	bra.s	draw.police
	bra.s	draw.angel
	bra.s	draw.power




next.anim.frame
	move.w	34(a1),d0		offset for current frame
	addq.w	#4,d0			next frame
	move.l	(a0,d0.w),d1
	bne.s	save.anim.offset

	moveq	#0,d0			reset to start of frames
	move.l	(a0),d1

save.anim.offset
	move.w	d0,34(a1)
	move.l	d1,a0
	rts




draw.tent
	lea	tent.frames(pc),a0
	bsr.s	next.anim.frame
	bra.s	angles.and.offsets

draw.house
	lea	house(pc),a0
	bra.s	angles.and.offsets

draw.police
	lea	police(pc),a0
	bra.s	angles.and.offsets

draw.angel
	lea	angel(pc),a0
	bra.s	angles.and.offsets

draw.power
	lea	power(pc),a0

angles.and.offsets
	movem.w	world.sin.cos.values(pc),d0-d7/a2
	movem.w	d0-d7/a2,sin.cos.values

	movem.l	22(a1),d0-d2		get objects offsets in world
	movem.l	d0-d2,x.offset

	bra	draw.3d.object




clear.planes.1.3
	btst	#6,dmaconr(a6)
	bne.s	clear.planes.1.3

	move.w	#40,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1(pc),bltdpth(a6)
	move.w	#YMAX*2*64+20,bltsize(a6)
	rts




clear.plane.2
	btst	#6,dmaconr(a6)
	bne.s	clear.plane.2

	move.w	#120,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1(pc),a0
	lea	40(a0),a0
	move.l	a0,bltdpth(a6)
	move.w	#YMAX*64+20,bltsize(a6)
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




rotate.coords
	lea	sin.cos.values(pc),a1
	lea	new.coords(pc),a2
	add.w	(a0)+,a2		point to correct coordinates
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
	bmi.s	end.draw.3d.object	quit if z is negative

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

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




polygon.draw
	lea	new.coords(pc),a1
	bsr	polygon

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




polygon.orientation
	lea	new.coords(pc),a1
	movem.w	(a0)+,d0-d3		get three offsets and skip value

	movem.w	(a1,d0.w),d0/d4		x1, y1
	movem.w	(a1,d1.w),d1/d5		x2, y2
	movem.w	(a1,d2.w),d2/d6		x3, y3

	sub.w	d1,d0			x1-x2
	sub.w	d5,d6			y3-y2
	sub.w	d1,d2			x3-x2
	sub.w	d5,d4			y1-y2
	muls	d0,d6			(x1-x2)*(y3-y2)
	muls	d2,d4			(x3-x2)*(y1-y2)
	sub.l	d4,d6			(x1-x2)*(y3-y2) - (x3-x2)*(y1-y2)
	bpl.s	skip.polygon		if polygon is anti-clockwise

	bsr	polygon

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

skip.polygon
	add.w	d3,a0			miss out polygon data




draw.3d.object
	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

sub.object
	pea	2(a0)
	add.w	(a0),a0
	bsr.s	draw.3d.object
	move.l	(sp)+,a0

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)

end.draw.3d.object
	rts




set.fill.colour
	move.w	(a0)+,fill.colour+2	set colour for subsequent fills

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




set.line.colour
	lea	line.colour.masks(pc),a1
	add.w	(a0)+,a1		add offset for correct colour
	move.l	a1,dl.col+2		set colour for subsequent lines

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




line	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get start offset
	move.w	(a0)+,d2		get end offset
	movem.w	(a1,d0.w),d0-d1		get start coordinates
	movem.w	(a1,d2.w),d2-d3		get end coordinates
	bsr.s	clip.line

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




circle	lea	new.coords(pc),a1
	move.w	(a0)+,d0		get offset
	movem.w	(a1,d0.w),d0-d2		get centre coordinates
	move.l	(a0)+,d3
	divs	d2,d3			calculate radius
	bsr	calc.circle

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




component.priority
	lea	new.coords(pc),a1
	movem.w	(a0)+,d0-d2		get two offsets and skip value
	move.w	(a1,d0.w),d0		get z value
	cmp.w	(a1,d1.w),d0		subtract other z value
	bge.s	correct.order
	add.w	d2,a0			add skip value

correct.order
	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




skip.data
	add.w	(a0),a0

	move.w	(a0)+,d0
	jmp	line(pc,d0.w)




;"""""""""""""""""
;" LINE ROUTINES "
;"		 "
;"""""""""""""""""

; d0 = x1, d1 = y1, d2 = x2, d3 = y2

clip.line
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.not.off.left

; x1 is off left of screen

	tst.w	d2			x2
	bmi.s	end.clip.line		if line is off left of screen

; clip line to left edge, giving a new value for y1

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

; x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	end.clip.line		if line is off right of screen

; clip line to right edge, giving a new value for y1

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

; y1 is off top of screen

	tst.w	d3			y2
	bmi.s	end.clip.line		if line is off top of screen

; clip line to top edge, giving a new value for x1

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

; y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	end.clip.line2		if line is off bottom of screen

; clip line to bottom edge, giving a new value for x1

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

; x2 is off left of screen

; clip line to left edge, giving a new value for y2

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

; x2 is off right of screen

; clip line to right edge, giving a new value for y2

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

; y2 is off top of screen

; clip line to top edge, giving a new value for x2

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
	ble.s	draw.line		if new x1 is not off right of screen

end.clip.line3
	rts




y2.not.off.top
	cmp.w	d7,d3			y2
	ble.s	draw.line

; y2 is off bottom of screen

; clip line to bottom edge, giving a new value for x2

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




draw.line				; draw line using blitter
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
	moveq	#40,d5			width of one bitplane

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


dl.loop	add.l	d5,a1
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
return	rts




;""""""""""""""""""""""
;" THE CIRCLE ROUTINE "
;"		      "
;""""""""""""""""""""""

calc.circle
	move.w	#XMAX-1,d6

	move.w	d0,d5			x centre
	sub.w	d3,d5			- radius
	cmp.w	d6,d5
	bgt.s	return			quit if off right of screen

	move.w	d0,d5			x centre
	add.w	d3,d5			+ radius
	bmi.s	return			quit if off left of screen

	move.w	#YMAX-1,d2

	move.w	d1,d5			y centre
	sub.w	d3,d5			- radius
	cmp.w	d2,d5
	bgt.s	return			quit if off bottom of screen

	move.w	d1,d5			y centre
	add.w	d3,d5			+ radius
	bmi.s	return			quit if off top of screen

	cmp.w	d2,d5
	ble.s	circ1			if not off bottom at all

	move.w	d2,d5			set to bottom of screen


circ1	lea	fill.coords(pc),a1
	tst.w	d1			y centre
	bpl.s	circ2

					; some of bottom half to be done
	move.w	d3,d2			radius
	move.w	d1,d3			y centre

	muls	d2,d2			R*R
	muls	d1,d1			Y*Y
	sub.l	d1,d2			R*R - Y*Y
	bsr	circ10			calculate X

	add.w	d3,d1

	neg.w	d1
	add.w	d3,d3
	subq.w	#1,d3

	clr.w	(a1)+			set y-start to top of screen
	bra.s	circA



					; all of bottom half to be done
circ2	sub.w	d3,d1			- radius
	bpl.s	circ3

					; some of top half to be done
	move.w	d3,d2			radius
	add.w	d3,d1			y centre
	move.w	d1,d3			y centre

	muls	d2,d2			R*R
	muls	d1,d1			Y*Y
	sub.l	d1,d2			R*R - Y*Y
	bsr	circ10			calculate X

	add.w	d3,d1

	clr.w	(a1)+			set y-start to top of screen
	bra.s	circ4



					; all of top half to be done
circ3	move.w	d1,(a1)+		save y-start
	sub.w	d1,d5			number of lines high
	moveq	#0,d7
	move.w	d3,d1			radius


circ4	neg.w	d1			- radius
	add.w	d3,d3			2R
	subq.w	#1,d3			2R - 1




circ5	move.w	d7,d2			do top half of circle
	add.w	d2,d2
	addq.w	#1,d2
	add.w	d2,d1
	bgt.s	circ7

circ6	addq.w	#1,d7
	addq.w	#2,d2
	add.w	d2,d1
	ble.s	circ6

circ7	sub.w	d2,d1

	move.w	d0,d4
	sub.w	d7,d4			starting x
	bpl.s	circ8
	moveq	#0,d4			if off screen then set to 0

circ8	swap	d4

	move.w	d0,d4
	add.w	d7,d4			ending x
	cmp.w	d6,d4
	ble.s	circ9
	move.w	d6,d4			if off screen then set to maximum

circ9	move.l	d4,(a1)+		save starting and ending x

	sub.w	d3,d1
	subq.w	#2,d3
	dbmi	d5,circ5




	subq.w	#1,d5
	bmi.s	circF




circA	tst.w	d1			do bottom half of circle
	ble.s	circC

	moveq	#-1,d2
	sub.w	d7,d2
	sub.w	d7,d2

circB	addq.w	#2,d2
	add.w	d2,d1
	dble	d7,circB

	subq.w	#1,d7

circC	move.w	d0,d4
	sub.w	d7,d4			starting x
	bpl.s	circD
	moveq	#0,d4			if off screen then set to 0

circD	swap	d4

	move.w	d0,d4
	add.w	d7,d4			ending x
	cmp.w	d6,d4
	ble.s	circE
	move.w	d6,d4			if off screen then set to maximum

circE	move.l	d4,(a1)+		save starting and ending x

	sub.w	d3,d1
	subq.w	#2,d3
	dbra	d5,circA




circF	bra	fill




circ10	moveq	#16-1,d4		calculate square root of d2
	move.l	#$40000000,d7
	move.l	d2,d1
	clr.w	d1
	swap	d1

circ11	swap	d7
	sub.l	d7,d1
	bcc.s	circ12

	add.l	d7,d1
	swap	d7

	add.w	d7,d7

	add.w	d2,d2
	addx.l	d1,d1
	add.w	d2,d2
	addx.l	d1,d1

	dbra	d4,circ11

	swap	d1			/ 65536 to give result in d1
	rts




circ12	swap	d7

	add.w	d7,d7
	addq.w	#1,d7

	add.w	d2,d2
	addx.l	d1,d1
	add.w	d2,d2
	addx.l	d1,d1

	dbra	d4,circ11

	swap	d1			/ 65536 to give result in d1
	rts




;""""""""""""""""""""""""
;" THE POLYGON ROUTINES	"
;"			"
;""""""""""""""""""""""""

z.clip1				; d0 = offset for z coord below limit
				; d1 = offset for z coord above limit
	move.l	-4(a1,d0.w),d4		get x, y (below)
	move.l	-4(a1,d1.w),d2		get x, y (above)
	move.w	(a1,d0.w),d5		z off
	move.w	d5,d0			z off
	sub.w	(a1,d1.w),d5		z off - z on

	sub.w	#128,d0			z off - 128

	move.w	d2,d3			y on
	sub.w	d4,d3			y on - y off
	muls	d0,d3			(y on - y off) * (z off - 128)
	divs	d5,d3	    ((y on - y off) * (z off - 128)) / (z off - z on)
	add.w	d4,d3
;		  (((y on - y off) * (z off - 128)) / (z off - z on)) + y off

	swap	d4			x off
	swap	d2			x on

	sub.w	d4,d2			x on - x off
	muls	d0,d2			(x on - x off) * (z off - 128)
	divs	d5,d2	    ((x on - x off) * (z off - 128)) / (z off - z on)
	add.w	d4,d2
;		  (((x on - x off) * (z off - 128)) / (z off - z on)) + x off

	add.w	d2,d2			perspective for x
	bvs.s	z.clipped1

	add.w	d3,d3			perspective for y
	bvs.s	z.clipped1

	add.w	#XMID,d2		centre x on screen
	bvs.s	z.clipped1

	add.w	#YMID,d3		centre y on screen

z.clipped1
	rts




z.clip2				; d0 = offset for z coord above limit
				; d1 = offset for z coord below limit
	move.l	-4(a1,d1.w),d4		get x, y (below)
	move.l	-4(a1,d0.w),d2		get x, y (above)
	move.w	(a1,d1.w),d5		z off
	move.w	d5,d3			z off
	sub.w	(a1,d0.w),d5		z off - z on

	sub.w	#128,d3			z off - 128
	move.w	d3,d0			z off - 128

	move.w	d2,d3			y on
	sub.w	d4,d3			y on - y off
	muls	d0,d3			(y on - y off) * (z off - 128)
	divs	d5,d3	    ((y on - y off) * (z off - 128)) / (z off - z on)
	add.w	d4,d3
;		  (((y on - y off) * (z off - 128)) / (z off - z on)) + y off

	swap	d4			x off
	swap	d2			x on

	sub.w	d4,d2			x on - x off
	muls	d0,d2			(x on - x off) * (z off - 128)
	divs	d5,d2	    ((x on - x off) * (z off - 128)) / (z off - z on)
	add.w	d4,d2
;		  (((x on - x off) * (z off - 128)) / (z off - z on)) + x off

	add.w	d2,d2			perspective for x
	bvs.s	z.clipped2

	add.w	d3,d3			perspective for y
	bvs.s	z.clipped2

	add.w	#XMID,d2		centre x on screen
	bvs.s	z.clipped2

	add.w	#YMID,d3		centre y on screen

z.clipped2
	rts




polygon.z.clip
	move.w	(a0)+,d7		get number of sides
	subq.w	#1,d7
	lea	new.coords(pc),a1
	lea	poly.coords(pc),a2
	moveq	#0,d6
	move.w	(a0)+,d1		get offset for first z coord
	cmp.w	#128,(a1,d1.w)
	bge.s	find.value.below

find.value.above
	move.w	d1,d0			save previous offset
	move.w	(a0)+,d1		get offset for next z coord
	cmp.w	#128,(a1,d1.w)
	dbge	d7,find.value.above	until value above limit is found

	blt.s	poly.clip.sort

	bsr	z.clip1
	bvs.s	end.polygon.z.clip

	move.w	d2,(a2)+		save new x
	move.w	d3,(a2)+		save new y

	addq.w	#1,d6
	dbra	d7,find.value.below

	bra.s	poly.clip.sort




end.polygon.z.clip
	add.w	d7,d7
	add.w	d7,a0			skip rest of polygon offsets
	rts




find.value.below
	move.l	2(a1,d1.w),(a2)+	save x, y values that are above limit
	addq.w	#1,d6
	move.w	d1,d0			save previous offset
	move.w	(a0)+,d1		get offset for next z coord
	cmp.w	#128,(a1,d1.w)
	dblt	d7,find.value.below	until value below limit is found

	bge.s	poly.clip.sort

	bsr	z.clip2
	bvs.s	end.polygon.z.clip

	move.w	d2,(a2)+		save new x
	move.w	d3,(a2)+		save new y

	addq.w	#1,d6
	dbra	d7,find.value.above


poly.clip.sort
	move.w	d6,d1			number of coords saved (sides)
	beq.s	end.poly.clip.sort

	add.w	d1,d1
	add.w	d1,d1			4 bytes per side
	subq.w	#2,d6			count
	lea	poly.coords(pc),a2	temporary space for coords
	lea	(a2,d1.w),a4
	move.l	a2,a3
	move.l	(a2)+,d4		get first coords
	move.w	d4,d5			y
	move.l	d4,d2
	swap	d2			x
	move.w	d2,d3			x
	move.l	d4,(a4)+

clip.sort
	move.l	(a2)+,d0		get next coords
	move.l	d0,(a4)+

	cmp.w	d0,d4
	ble.s	clip.sort1
	move.w	d0,d4			top y
	lea	-4(a2),a3		address of top coords
	bra.s	clip.sort2

clip.sort1
	cmp.w	d0,d5
	bge.s	clip.sort2
	move.w	d0,d5			bottom y

clip.sort2
	swap	d0
	cmp.w	d0,d2
	ble.s	clip.sort3
	move.w	d0,d2			smallest x
	bra.s	clip.sort4

clip.sort3
	cmp.w	d0,d3
	bge.s	clip.sort4
	move.w	d0,d3			largest x

clip.sort4
	dbra	d6,clip.sort

	bra.s	poly.check.on.screen

end.poly.clip.sort
	rts




poly.line
	move.w	d4,(a1)+		save starting y

	tst.w	d2			smallest x
	bpl.s	poly.line1
	moveq	#0,d2			if off screen then set to 0

poly.line1
	move.w	d2,(a1)+		save starting x

	cmp.w	d6,d3			largest x
	ble.s	poly.line2
	move.w	d6,d3			if off screen then set to maximum

poly.line2
	move.w	d3,(a1)+		save ending x

	bra	fill




return2	rts




polygon	move.w	(a0)+,d0		get number of sides
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1			4 bytes per side
	subq.w	#2,d0			count
	lea	poly.coords(pc),a2	temporary space for coords
	lea	(a2,d1.w),a4
	move.w	(a0)+,d4		get offset for first coords
	move.l	(a1,d4.w),d4		get first coords
	move.w	d4,d5			y
	move.l	d4,d2
	swap	d2			x
	move.w	d2,d3			x
	move.l	a2,a3
	move.l	d4,(a2)+
	move.l	d4,(a4)+

poly.sort
	move.w	(a0)+,d6		get offset for next coords
	move.l	(a1,d6.w),d6		get next coords

	cmp.w	d6,d4
	ble.s	poly.sort1
	move.w	d6,d4			top y
	move.l	a2,a3			address of top coords
	bra.s	poly.sort2

poly.sort1
	cmp.w	d6,d5
	bge.s	poly.sort2
	move.w	d6,d5			bottom y

poly.sort2
	move.l	d6,(a2)+
	move.l	d6,(a4)+

	swap	d6
	cmp.w	d6,d2
	ble.s	poly.sort3
	move.w	d6,d2			smallest x
	bra.s	poly.sort4

poly.sort3
	cmp.w	d6,d3			largest x
	bge.s	poly.sort4
	move.w	d6,d3

poly.sort4
	dbra	d0,poly.sort

poly.check.on.screen
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d3
	bmi.s	return2			quit if largest x off left

	cmp.w	d6,d2
	bgt.s	return2			quit if smallest x off right

	tst.w	d5
	bmi.s	return2			quit if bottom y off top

	cmp.w	d7,d4
	bgt.s	return2			quit if top y off bottom

	lea	fill.coords(pc),a1

	cmp.w	d4,d5
	beq	poly.line		if smallest y = largest y

	lea	(a3,d1.w),a2		address of top coords
	move.l	#65536,a4
	move.l	#-65536,a5

	tst.w	d4
	bpl	top.y.on.screen

top.y.off.screen
	move.l	-(a2),d2		get previous coords
	tst.w	d2			y
	bmi.s	top.y.off.screen	get first coords that are on screen

	move.l	4(a2),d0		get last coords that were off screen

	move.w	d0,d4			y off
	move.w	d2,d5			y on
	sub.w	d0,d5			y on - y off
	swap	d2			x on
	swap	d0			x off
	sub.w	d0,d2			x on - x off
	muls	d2,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d0	  x off - (((x on - x off) * y off) / (y on - y off))
	swap	d0
	clr.w	d0			new starting x * 65536

	ext.l	d2			x on - x off
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (y on - y off)
	bvs.s	gradient.overflow1
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x

gradient.overflow1
	asr.l	#8,d2			x on - x off
	divs	d5,d2			/ (y on - y off)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive1
	neg.l	d5			make positive

grad.positive1
	cmp.l	a4,d5
	bge.s	grad.greater1
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater1
	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

top.y.off.screen2
	move.l	(a3)+,d1		get current coords
	tst.w	2(a3)			y
	bmi.s	top.y.off.screen2	until first coords are on screen

	move.l	(a3),d3			get first coords that are on screen

	move.w	d1,d4			y off
	move.w	d3,d5			y on
	sub.w	d1,d5			y on - y off
	swap	d3			x on
	swap	d1			x off
	sub.w	d1,d3			x on - x off
	muls	d3,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d1	  x off - (((x on -  x off) * y off) / (y on - yoff))
	swap	d1
	clr.w	d1			new ending x * 65536

	ext.l	d3			x on - x off
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (y on - y off)
	bvs.s	gradient.overflow2
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x

gradient.overflow2
	asr.l	#8,d3			x on - x off
	divs	d5,d3			/ (y on - y off)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x
	move.l	d3,d5			gradient
	bpl.s	grad.positive2
	neg.l	d5			make positive

grad.positive2
	cmp.l	a4,d5
	bge.s	grad.greater2
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater2
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	moveq	#0,d4			set starting y to 0
	move.w	d4,(a1)+		save starting y

	bra	do.poly.edges




next.y.smaller1
	cmp.l	a2,a3
	beq	bottom.of.polygon.flat	if pointers have overlapped

	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient2




next.y.smaller2
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient2




top.y.on.screen
	move.w	d4,(a1)+		save starting y

calc.end.gradient
	move.l	(a3)+,d4		get current coords

calc.end.gradient2
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller1

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow3
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	calc.start.gradient

gradient.overflow3
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

calc.start.gradient
	move.l	(a2),d4			get current coords

calc.start.gradient2
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous coords
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller2

	move.w	(a2),d2			get previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow4
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.ending.x

gradient.overflow4
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.ending.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive3

	cmp.l	a5,d5
	ble.s	grad.greater3
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater3
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

grad.positive3
	move.l	d3,d5			gradient
	bmi.s	grad.negative1

	cmp.l	a4,d5
	bge.s	grad.greater4
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater4
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

grad.negative1
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen1
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen1
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen1
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen1
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

adjust.starting.ending.x2
	move.l	d2,d5			gradient
	bmi.s	grad.negative2		if -ve then add it on

	cmp.l	a4,d5
	bge.s	grad.greater5
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater5
	asr.l	#1,d5
grad.negative2
	add.l	d5,d0			adjust starting x

	move.l	d3,d5			gradient
	bpl.s	grad.positive4		if +ve then add it on

	cmp.l	a5,d5
	ble.s	grad.greater6
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater6
	asr.l	#1,d5
	add.l	a4,d1			+ 1
grad.positive4
	add.l	d5,d1			adjust ending x




do.poly.edges
	move.w	2(a2),d5		get y value for end of starting edge

	cmp.l	a2,a3
	beq	bottom.of.polygon	if pointers have overlapped

	cmp.w	2(a3),d5
	bgt	starting.edge.longer

	beq	both.edges.equal.length

ending.edge.longer
	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges1

	subq.w	#1,d5			count

edge.loop1
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen2
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen2
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen2
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen2
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop1

skip.edges1
	move.l	(a2),d4			get current coords

calc.start.gradient3
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous y
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller3

	move.w	(a2),d2			previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow5
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x2

gradient.overflow5
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x2
	move.l	d2,d5			gradient
	bpl.s	grad.positive5

	cmp.l	a5,d5
	ble.s	grad.greater7
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater7
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

	bra.s	do.poly.edges




next.y.smaller3
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient3




grad.positive5
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen3
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen3
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen3
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen3
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d3,d1			add gradient to get next x value

	move.l	d2,d5			gradient

	cmp.l	a4,d5
	bge.s	grad.greater8
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater8
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x

	bra	do.poly.edges




starting.edge.longer
	move.w	2(a3),d5		get y value for end of ending edge

	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges2

	subq.w	#1,d5			count

edge.loop2
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen4
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen4
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen4
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen4
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop2

skip.edges2
	move.l	(a3)+,d4		get current coords

calc.end.gradient3
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller4

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x
	swap	d4			current y

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow6
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x2

gradient.overflow6
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x2
	move.l	d3,d5			gradient
	bmi.s	grad.negative3

	cmp.l	a4,d5
	bgt.s	grad.greater9
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater9
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	bra	do.poly.edges




next.y.smaller4
	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient3




grad.negative3
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen5
	moveq	#0,d5

start.x.on.screen5
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen5
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen5
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d2,d0			add gradient to get next x value

	move.l	d3,d5			gradient

	cmp.l	a5,d5
	blt.s	grad.greaterA
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greaterA
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x
	add.l	a4,d1			+ 1

	bra	do.poly.edges




both.edges.equal.length
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble	calc.end.gradient

	subq.w	#1,d5			count

edge.loop3
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen6
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen6
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen6
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen6
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop3

	bra	calc.end.gradient




bottom.of.polygon.flat
	move.l	(a2),d0			get current coords

	cmp.w	d7,d0
	bgt	fill			if bottom is off screen

	clr.w	d0			starting x * 65536

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x3

	cmp.l	a4,d5
	ble.s	adjust.ending.x3

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x3
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen7
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen7
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screen7
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen7
	move.l	d5,(a1)+		save starting and ending x

	bra.s	fill




bottom.is.off.screen
	sub.w	d4,d7			end y - current y = count
	blt.s	fill

edge.loop4
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen8
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen8
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen8
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen8
	move.l	d5,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d7,edge.loop4

	bra.s	fill




bottom.of.polygon
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	adjust.last.x.values

	subq.w	#1,d5			count

edge.loop5
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen9
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen9
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen9
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen9
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop5

adjust.last.x.values
	move.l	(a2),d0			get current coords
	move.l	d0,d1			both coords are the same

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x4

	cmp.l	a4,d5
	ble.s	adjust.ending.x4

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x4
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values2

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values2
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screenA
	moveq	#0,d5			if off screen then set to 0

start.x.on.screenA
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screenA
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screenA
	move.l	d5,(a1)+		save starting and ending x

;	bra.s	fill




;""""""""""""""""""""
;" THE FILL ROUTINE "
;"		    "
;""""""""""""""""""""

fill	st	(a1)			end-of-fill marker
	move.l	screen1(pc),a1
	lea	fill.coords(pc),a4
	move.w	(a4)+,d0		get y-start
	add.w	d0,d0			word offset
	lea	y.table(pc),a2
	add.w	(a2,d0.w),a1		add y offset

fill.colour
	move.w	#0,d1
	cmp.w	#15*4,d1
	bgt	stipple.fill

	move.l	fill.table(pc,d1.w),a3	set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl.s	fill.it
	rts



fill.table
	dc.l	mask2,mask1,mask16,mask8,mask10,mask15,mask13,mask7
	dc.l	mask3,mask9,mask11,mask14,mask4,mask12,mask5,mask6



fill.it	move.w	#4*64,d2		height = 4

	lea	start.masks(pc),a5

bltfin3	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin3

	move.l	#$7ca0000,bltcon0(a6)	USE B,C,D	D = A.B + notA.C
	move.w	#$ffff,bltadat(a6)	mask for all planes

fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line		if x-end is less than x-start

	moveq	#$f,d3
	and.w	d0,d3			low four bits from x-start

	sub.w	d3,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	add.w	d3,d1			correct bit position for x-end

	add.w	d3,d3
	move.w	(a5,d3.w),d0		get start mask
	swap	d0

	add.w	d1,d1
	move.w	32(a5,d1.w),d0		get end mask

	lsr.w	#5,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d3			width of one bitplane
	sub.w	d1,d3
	sub.w	d1,d3			modulo value

	or.w	d2,d1			bltsize value, with height = 4

bltfin4	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin4

	movem.l	d0/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d3,bltbmod(a6)		set modulos
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)
	move.w	d1,bltsize(a6)		start blitter

next.line
	lea	160(a1),a1		next line
	move.w	(a4)+,d0		next x-start
	bpl.s	fill.it.loop
	rts



start.masks
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001



end.masks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



stipple.fill
	move.l	#$1000,d4		value for bltcon1
	btst	#1,d0
	beq.s	even.scan.line
	swap	d4

even.scan.line
	sub.w	#16*4,d1
	move.l	stipple.fill.table(pc,d1.w),a3
;					set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl	stipple.fill.it
	rts



stipple.fill.table
	dc.l	mask17,mask31,mask23,mask25,mask30,mask28,mask22,mask18
	dc.l	mask24,mask26,mask29,mask19,mask27,mask20,mask21

	dc.l	mask32,mask33,mask34,mask35,mask36,mask37,mask38,mask39
	dc.l	mask40,mask41,mask42,mask43,mask44,mask45

	dc.l	mask46,mask47,mask48,mask49,mask50,mask51,mask52,mask53
	dc.l	mask54,mask55,mask56,mask57,mask58

	dc.l	mask59,mask60,mask61,mask62,mask63,mask64,mask65,mask66
	dc.l	mask67,mask68,mask69,mask70

	dc.l	mask71,mask72,mask73,mask74,mask75,mask76,mask77,mask78
	dc.l	mask79,mask80,mask81

	dc.l	mask82,mask83,mask84,mask85,mask86,mask87,mask88,mask89
	dc.l	mask90,mask91

	dc.l	mask92,mask93,mask94,mask95,mask96,mask97,mask98,mask99
	dc.l	mask100

	dc.l	mask101,mask102,mask103,mask104,mask105,mask106,mask107,mask108

	dc.l	mask109,mask110,mask111,mask112,mask113,mask114,mask115

	dc.l	mask116,mask117,mask118,mask119,mask120,mask121

	dc.l	mask122,mask123,mask124,mask125,mask126

	dc.l	mask127,mask128,mask129,mask130

	dc.l	mask131,mask132,mask133

	dc.l	mask134,mask135

	dc.l	mask136



stipple.fill.it
	move.w	#4*64,d2		height = 4
	moveq	#16,d5

	lea	start.masks(pc),a5

bltfin5	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin5

	move.w	#$7ca,bltcon0(a6)	USE B,C,D	D = A.B + notA.C
	move.w	#$ffff,bltadat(a6)	mask for all planes

stipple.fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line2		if x-end is less than x-start

	moveq	#$f,d3
	and.w	d0,d3			low four bits from x-start
	bne.s	not.word.boundary

	sub.w	d5,d0			start one word earlier
	add.w	d5,d1			one word extra width
	bra.s	no.start.mask

not.word.boundary
	sub.w	d3,d0			x-start offset in multiples of 16
	add.w	d3,d1			correct bit position for x-end

	add.w	d3,d3
	move.w	(a5,d3.w),d3		get start mask

no.start.mask
	swap	d3
	asr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	add.w	d1,d1
	move.w	32(a5,d1.w),d3		get end mask

	lsr.w	#5,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d0			width of one bitplane
	sub.w	d1,d0
	sub.w	d1,d0			modulo value

	or.w	d2,d1			bltsize value, with height = 4

bltfin6	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin6

	movem.l	d3/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d0,bltbmod(a6)		set modulos
	move.w	d0,bltcmod(a6)
	move.w	d0,bltdmod(a6)
	move.w	d4,bltcon1(a6)
	move.w	d1,bltsize(a6)		start blitter

next.line2
	swap	d4
	lea	160(a1),a1		next line
	move.w	(a4)+,d0		next x-start
	bpl.s	stipple.fill.it.loop
	rts



y.table	ds.w	200



fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker



mask1	dcb.w	20,$ffff
mask2	dcb.w	20,0
mask3	dcb.w	20,0
mask4	dcb.w	20,0
mask5	dcb.w	20,0
mask6	dcb.w	20,$ffff
mask7	dcb.w	20,$ffff
mask8	dcb.w	20,$ffff
mask9	dcb.w	20,$ffff
mask10	dcb.w	20,0
mask11	dcb.w	20,0
mask12	dcb.w	20,$ffff
mask13	dcb.w	20,0
mask14	dcb.w	20,$ffff
mask15	dcb.w	20,$ffff
mask16	dcb.w	20,0
	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0

mask17	dcb.w	20,$5555
mask18	dcb.w	20,0
mask19	dcb.w	20,0
mask20	dcb.w	20,0
mask21	dcb.w	20,$5555
mask22	dcb.w	20,$5555
mask23	dcb.w	20,$5555
mask24	dcb.w	20,$5555
mask25	dcb.w	20,0
mask26	dcb.w	20,0
mask27	dcb.w	20,$5555
mask28	dcb.w	20,0
mask29	dcb.w	20,$5555
mask30	dcb.w	20,$5555
mask31	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,0
	dcb.w	20,0

mask32	dcb.w	20,$5555!$0000		colour 1 with 2-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask33	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask34	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask35	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask36	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask37	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask38	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask39	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask40	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask41	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask42	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask43	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask44	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask45	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask46	dcb.w	20,$0000!$aaaa		colour 2 with 3-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask47	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask48	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask49	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask50	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask51	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask52	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask53	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask54	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask55	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask56	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask57	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask58	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask59	dcb.w	20,$5555!$0000		colour 3 with 4-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask60	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask61	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask62	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask63	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask64	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask65	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask66	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask67	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask68	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask69	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask70	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask71	dcb.w	20,$0000!$aaaa		colour 4 with 5-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask72	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask73	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask74	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask75	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask76	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask77	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask78	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask79	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask80	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask81	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask82	dcb.w	20,$5555!$0000		colour 5 with 6-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask83	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask84	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask85	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask86	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask87	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask88	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask89	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask90	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask91	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask92	dcb.w	20,$0000!$aaaa		colour 6 with 7-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask93	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask94	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask95	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask96	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask97	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask98	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask99	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask100	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask101	dcb.w	20,$5555!$0000		colour 7 with 8-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask102	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask103	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask104	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask105	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask106	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask107	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask108	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask109	dcb.w	20,$0000!$aaaa		colour 8 with 9-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask110	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask111	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask112	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask113	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask114	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask115	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask116	dcb.w	20,$5555!$0000		colour 9 with 10-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask117	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask118	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask119	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask120	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask121	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask122	dcb.w	20,$0000!$aaaa		colour 10 with 11-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask123	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask124	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask125	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask126	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask127	dcb.w	20,$5555!$0000		colour 11 with 12-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask128	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask129	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask130	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask131	dcb.w	20,$0000!$aaaa		colour 12 with 13-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask132	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask133	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa


mask134	dcb.w	20,$5555!$0000		colour 13 with 14-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask135	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa


mask136	dcb.w	20,$0000!$aaaa		colour 14 with 15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa



poly.coords	ds.w	64		space for 16 sided polygon




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

keyboard.requests
	move.b	frames.requested(pc),d0
	beq.s	no.request1

	bsr	frames.per.sec

no.request1
	move.b	palette.requested(pc),d0
	beq.s	no.request2

	bsr.s	display.palette
	bsr	update.screens

palette.wait
	move.b	palette.requested(pc),d0
	bne.s	palette.wait

no.request2
	move.b	raw.key.code(pc),d0
	beq.s	keys.checked

	clr.b	raw.key.code

check.keypad8
	cmp.b	#$3e,d0
	bne.s	check.keypad4

	clr.w	required.view.angle
	bra.s	keys.checked

check.keypad4
	cmp.b	#$2d,d0
	bne.s	check.keypad2

	move.w	#$100,required.view.angle
	bra.s	keys.checked

check.keypad2
	cmp.b	#$1e,d0
	bne.s	check.keypad6

	move.w	#$200,required.view.angle
	bra.s	keys.checked

check.keypad6
	cmp.b	#$2f,d0
	bne.s	keys.checked

	move.w	#$300,required.view.angle

keys.checked
	rts




display.palette
	moveq	#2,d0			start y
	moveq	#8-1,d1			8 rows
	clr.w	fill.colour+2		start colour at 0

next.row
	moveq	#0,d2			start x
	moveq	#17-1,d3		17 columns

next.column
	bsr.s	fill.box

	addq.w	#4,fill.colour+2	next colour
	add.w	#19,d2			next start x
	dbra	d3,next.column

	add.w	#25,d0			next start y
	dbra	d1,next.row
	rts




fill.box
	movem.w	d0-d3,-(sp)

	move.w	d2,d3
	add.w	#15,d3			16 pixels wide
	moveq	#20-1,d1		20 pixels tall

	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

	bsr	fill

	movem.w	(sp)+,d0-d3
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
	move.l	#part2,cop2lch(a6)

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




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""

copper.list1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	copjmp2,0




copper.list2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	copjmp2,0




copper.list3
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	copjmp2,0




part2	dc.w	$a001,$ff00
	dc.w	$19c,$010
	dc.w	$a201,$ff00
	dc.w	$19c,$020
	dc.w	$a401,$ff00
	dc.w	$19c,$030
	dc.w	$a601,$ff00
	dc.w	$19c,$040
	dc.w	$a801,$ff00
	dc.w	$19c,$050
	dc.w	$aa01,$ff00
	dc.w	$19c,$060
	dc.w	$ac01,$ff00
	dc.w	$19c,$070
	dc.w	$ae01,$ff00
	dc.w	$19c,$180
	dc.w	$b001,$ff00
	dc.w	$19c,$390
	dc.w	$b201,$ff00
	dc.w	$19c,$5a0
	dc.w	$b401,$ff00
	dc.w	$19c,$7b0
	dc.w	$b601,$ff00
	dc.w	$19c,$9c0
	dc.w	$b801,$ff00
	dc.w	$19c,$bd0
	dc.w	$ba01,$ff00
	dc.w	$19c,$de0
	dc.w	$bc01,$ff00
	dc.w	$19c,$ff0
	dc.w	$be01,$ff00
	dc.w	$19c,$dd0
	dc.w	$c001,$ff00
	dc.w	$19c,$bb0
	dc.w	$c201,$ff00
	dc.w	$19c,$990
	dc.w	$c401,$ff00
	dc.w	$19c,$770
	dc.w	$c601,$ff00
	dc.w	$19c,$550
	dc.w	$c801,$ff00
	dc.w	$19c,$330
	dc.w	$ca01,$ff00
	dc.w	$19c,$110
	dc.w	$cc01,$ff00
	dc.w	$19c,$000

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
palette.requested	dc.b	0
frames.requested	dc.b	0

collision.flag	dc.b	0

register.mouse.x	dc.b	0
register.mouse.y	dc.b	0
left.mouse.button	dc.b	0
right.mouse.button	dc.b	0

player.x.offset	dc.l	0
player.y.offset	dc.l	$8000000
player.z.offset	dc.l	0

player.x.angle	dc.w	0
player.z.angle	dc.w	0

player.speed	dc.w	0

current.view.angle	dc.w	0
required.view.angle	dc.w	0

x.rebound.value	dc.w	0
x.rebound.count	dc.w	0

collision.z.distance	dc.l	0
collision.pointer	dc.l	0

new.x.angle	dc.w	0
new.y.angle	dc.l	0
new.z.angle	dc.w	0

world.sin.cos.values	ds.w	9

sin.cos.values	ds.w	9
x.offset	dc.l	0
y.offset	dc.l	0
z.offset	dc.l	0

gapX.xpart	dc.l	0
gapY.xpart	dc.l	0
gapZ.xpart	dc.l	0
gapX.zpart	dc.l	0
gapY.zpart	dc.l	0
gapZ.zpart	dc.l	0

tileX.xpart	dc.l	0
tileY.xpart	dc.l	0
tileZ.xpart	dc.l	0
tileX.zpart	dc.l	0
tileY.zpart	dc.l	0
tileZ.zpart	dc.l	0

new.coords	ds.w	100*3		space for 100 coordinates




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

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




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

P1	equ	0			coordinate offsets
P2	equ	6
P3	equ	12
P4	equ	18
P5	equ	24
P6	equ	30
P7	equ	36
P8	equ	42
P9	equ	48
P10	equ	54
P11	equ	60
P12	equ	66
P13	equ	72
P14	equ	78
P15	equ	84
P16	equ	90
P17	equ	96
P18	equ	102
P19	equ	108
P20	equ	114
P21	equ	120
P22	equ	126
P23	equ	132
P24	equ	138
P25	equ	144
P26	equ	150
P27	equ	156
P28	equ	162
P29	equ	168
P30	equ	174
P31	equ	180
P32	equ	186
P33	equ	192
P34	equ	198
P35	equ	204
P36	equ	210
P37	equ	216
P38	equ	222
P39	equ	228
P40	equ	234
P41	equ	240
P42	equ	246
P43	equ	252
P44	equ	258
P45	equ	264
P46	equ	270
P47	equ	276
P48	equ	282
P49	equ	288
P50	equ	294
P51	equ	300
P52	equ	306
P53	equ	312
P54	equ	318
P55	equ	324
P56	equ	330
P57	equ	336
P58	equ	342
P59	equ	348
P60	equ	354
P61	equ	360
P62	equ	366
P63	equ	372
P64	equ	378
P65	equ	384
P66	equ	390
P67	equ	396
P68	equ	402
P69	equ	408
P70	equ	414
P71	equ	420
P72	equ	426
P73	equ	432
P74	equ	438
P75	equ	444
P76	equ	450
P77	equ	456
P78	equ	462
P79	equ	468
P80	equ	474
P81	equ	480
P82	equ	486
P83	equ	492
P84	equ	498
P85	equ	504
P86	equ	510
P87	equ	516
P88	equ	522
P89	equ	528
P90	equ	534
P91	equ	540
P92	equ	546
P93	equ	552
P94	equ	558
P95	equ	564
P96	equ	570
P97	equ	576
P98	equ	582
P99	equ	588
P100	equ	594



colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab



fcol0	equ	0*4
fcol1	equ	1*4
fcol2	equ	2*4
fcol3	equ	3*4
fcol4	equ	4*4
fcol5	equ	5*4
fcol6	equ	6*4
fcol7	equ	7*4
fcol8	equ	8*4
fcol9	equ	9*4
fcol10	equ	10*4
fcol11	equ	11*4
fcol12	equ	12*4
fcol13	equ	13*4
fcol14	equ	14*4
fcol15	equ	15*4

fcol16	equ	16*4
fcol17	equ	17*4
fcol18	equ	18*4
fcol19	equ	19*4
fcol20	equ	20*4
fcol21	equ	21*4
fcol22	equ	22*4
fcol23	equ	23*4
fcol24	equ	24*4
fcol25	equ	25*4
fcol26	equ	26*4
fcol27	equ	27*4
fcol28	equ	28*4
fcol29	equ	29*4
fcol30	equ	30*4

fcol31	equ	31*4
fcol32	equ	32*4
fcol33	equ	33*4
fcol34	equ	34*4
fcol35	equ	35*4
fcol36	equ	36*4
fcol37	equ	37*4
fcol38	equ	38*4
fcol39	equ	39*4
fcol40	equ	40*4
fcol41	equ	41*4
fcol42	equ	42*4
fcol43	equ	43*4
fcol44	equ	44*4

fcol45	equ	45*4
fcol46	equ	46*4
fcol47	equ	47*4
fcol48	equ	48*4
fcol49	equ	49*4
fcol50	equ	50*4
fcol51	equ	51*4
fcol52	equ	52*4
fcol53	equ	53*4
fcol54	equ	54*4
fcol55	equ	55*4
fcol56	equ	56*4
fcol57	equ	57*4

fcol58	equ	58*4
fcol59	equ	59*4
fcol60	equ	60*4
fcol61	equ	61*4
fcol62	equ	62*4
fcol63	equ	63*4
fcol64	equ	64*4
fcol65	equ	65*4
fcol66	equ	66*4
fcol67	equ	67*4
fcol68	equ	68*4
fcol69	equ	69*4

fcol70	equ	70*4
fcol71	equ	71*4
fcol72	equ	72*4
fcol73	equ	73*4
fcol74	equ	74*4
fcol75	equ	75*4
fcol76	equ	76*4
fcol77	equ	77*4
fcol78	equ	78*4
fcol79	equ	79*4
fcol80	equ	80*4

fcol81	equ	81*4
fcol82	equ	82*4
fcol83	equ	83*4
fcol84	equ	84*4
fcol85	equ	85*4
fcol86	equ	86*4
fcol87	equ	87*4
fcol88	equ	88*4
fcol89	equ	89*4
fcol90	equ	90*4

fcol91	equ	91*4
fcol92	equ	92*4
fcol93	equ	93*4
fcol94	equ	94*4
fcol95	equ	95*4
fcol96	equ	96*4
fcol97	equ	97*4
fcol98	equ	98*4
fcol99	equ	99*4

fcol100	equ	100*4
fcol101	equ	101*4
fcol102	equ	102*4
fcol103	equ	103*4
fcol104	equ	104*4
fcol105	equ	105*4
fcol106	equ	106*4
fcol107	equ	107*4

fcol108	equ	108*4
fcol109	equ	109*4
fcol110	equ	110*4
fcol111	equ	111*4
fcol112	equ	112*4
fcol113	equ	113*4
fcol114	equ	114*4

fcol115	equ	115*4
fcol116	equ	116*4
fcol117	equ	117*4
fcol118	equ	118*4
fcol119	equ	119*4
fcol120	equ	120*4

fcol121	equ	121*4
fcol122	equ	122*4
fcol123	equ	123*4
fcol124	equ	124*4
fcol125	equ	125*4

fcol126	equ	126*4
fcol127	equ	127*4
fcol128	equ	128*4
fcol129	equ	129*4

fcol130	equ	130*4
fcol131	equ	131*4
fcol132	equ	132*4

fcol133	equ	133*4
fcol134	equ	134*4

fcol135	equ	135*4



lcol0	equ	0*8
lcol1	equ	1*8
lcol2	equ	2*8
lcol3	equ	3*8
lcol4	equ	4*8
lcol5	equ	5*8
lcol6	equ	6*8
lcol7	equ	7*8
lcol8	equ	8*8
lcol9	equ	9*8
lcol10	equ	10*8
lcol11	equ	11*8
lcol12	equ	12*8
lcol13	equ	13*8
lcol14	equ	14*8
lcol15	equ	15*8



rotate.coords.offset	equ	rotate.coords-line

polygon.draw.offset	equ	polygon.draw-line

polygon.orientation.offset	equ	polygon.orientation-line

sub.object.offset	equ	sub.object-line

end.offset	equ	end.draw.3d.object-line

set.fill.colour.offset	equ	set.fill.colour-line

set.line.colour.offset	equ	set.line.colour-line

line.offset	equ	0

circle.offset	equ	circle-line

component.priority.offset	equ	component.priority-line

skip.data.offset	equ	skip.data-line



tent1	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-300,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent2	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-325,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent3	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-350,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent4	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-375,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent5	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-400,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent6	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-425,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent7	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-450,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent8	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-475,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent9	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-500,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent10	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-475,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent11	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-450,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent12	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-425,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent13	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-400,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent14	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-375,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent15	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-350,0

	dc.w	skip.data.offset
	dc.w	tent-*



tent16	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	1-1

	dc.w	0,-325,0



tent	dc.w	rotate.coords.offset

	dc.w	1*6

	dc.w	12-1

	dc.w	173,0,-300
	dc.w	-173,0,-300
	dc.w	-346,0,0
	dc.w	-173,0,300
	dc.w	173,0,300
	dc.w	346,0,0

	dc.w	173,-300,-300
	dc.w	-173,-300,-300
	dc.w	-346,-300,0
	dc.w	-173,-300,300
	dc.w	173,-300,300
	dc.w	346,-300,0


	dc.w	set.fill.colour.offset
	dc.w	fcol8

	dc.w	polygon.orientation.offset
	dc.w	P2,P3,P9
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P3,P9,P8

	dc.w	polygon.orientation.offset
	dc.w	P4,P5,P11
	dc.w	2+4*2
	dc.w	4
	dc.w	P4,P5,P11,P10

	dc.w	polygon.orientation.offset
	dc.w	P6,P7,P13
	dc.w	2+4*2
	dc.w	4
	dc.w	P6,P7,P13,P12


	dc.w	set.fill.colour.offset
	dc.w	fcol6

	dc.w	polygon.orientation.offset
	dc.w	P3,P4,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P4,P10,P9

	dc.w	polygon.orientation.offset
	dc.w	P5,P6,P12
	dc.w	2+4*2
	dc.w	4
	dc.w	P5,P6,P12,P11

	dc.w	polygon.orientation.offset
	dc.w	P7,P2,P8
	dc.w	2+4*2
	dc.w	4
	dc.w	P7,P2,P8,P13


	dc.w	set.fill.colour.offset
	dc.w	fcol7

	dc.w	polygon.orientation.offset
	dc.w	P8,P9,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P8,P9,P1

	dc.w	polygon.orientation.offset
	dc.w	P10,P11,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P10,P11,P1

	dc.w	polygon.orientation.offset
	dc.w	P12,P13,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P12,P13,P1


	dc.w	set.fill.colour.offset
	dc.w	fcol9

	dc.w	polygon.orientation.offset
	dc.w	P9,P10,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P9,P10,P1

	dc.w	polygon.orientation.offset
	dc.w	P11,P12,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P11,P12,P1

	dc.w	polygon.orientation.offset
	dc.w	P13,P8,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P13,P8,P1

	dc.w	end.offset



house	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	22-1

	dc.w	-350,0,280
	dc.w	-350,0,-280
	dc.w	350,0,-280
	dc.w	350,0,280

	dc.w	-350,-500,280
	dc.w	-350,-500,-280
	dc.w	350,-500,-280
	dc.w	350,-500,280

	dc.w	-350,-650,0
	dc.w	350,-650,0

	dc.w	-60,0,-280
	dc.w	-60,-240,-280
	dc.w	60,-240,-280
	dc.w	60,0,-280

	dc.w	-280,-300,-280
	dc.w	-280,-430,-280
	dc.w	-100,-430,-280
	dc.w	-100,-300,-280

	dc.w	100,-300,-280
	dc.w	100,-430,-280
	dc.w	280,-430,-280
	dc.w	280,-300,-280


	dc.w	set.fill.colour.offset
	dc.w	fcol29

	dc.w	polygon.orientation.offset
	dc.w	P1,P5,P6
	dc.w	2+5*2
	dc.w	5
	dc.w	P1,P5,P9,P6,P2

	dc.w	polygon.orientation.offset
	dc.w	P3,P7,P8
	dc.w	2+5*2
	dc.w	5
	dc.w	P3,P7,P10,P8,P4


	dc.w	set.fill.colour.offset
	dc.w	fcol14

	dc.w	polygon.orientation.offset
	dc.w	P2,P6,P7
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P6,P7,P3

	dc.w	polygon.orientation.offset
	dc.w	P4,P8,P5
	dc.w	2+4*2
	dc.w	4
	dc.w	P4,P8,P5,P1


	dc.w	set.fill.colour.offset
	dc.w	fcol56

	dc.w	polygon.orientation.offset
	dc.w	P6,P9,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P6,P9,P10,P7

	dc.w	polygon.orientation.offset
	dc.w	P8,P10,P9
	dc.w	2+4*2
	dc.w	4
	dc.w	P8,P10,P9,P5


	dc.w	set.fill.colour.offset
	dc.w	fcol2

	dc.w	polygon.orientation.offset
	dc.w	P11,P12,P13
	dc.w	2+4*2
	dc.w	4
	dc.w	P11,P12,P13,P14


	dc.w	set.fill.colour.offset
	dc.w	fcol44

	dc.w	polygon.orientation.offset
	dc.w	P15,P16,P17
	dc.w	2+4*2
	dc.w	4
	dc.w	P15,P16,P17,P18

	dc.w	polygon.orientation.offset
	dc.w	P19,P20,P21
	dc.w	2+4*2
	dc.w	4
	dc.w	P19,P20,P21,P22

	dc.w	end.offset



police	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	20-1

	dc.w	180,0,420
	dc.w	75,-180,-300
	dc.w	180,0,-420
	dc.w	180,60,-420
	dc.w	75,120,-300
	dc.w	180,60,420
	dc.w	-180,0,420
	dc.w	-75,-180,-300
	dc.w	-180,0,-420
	dc.w	-180,60,-420
	dc.w	-75,120,-300
	dc.w	-180,60,420

	dc.w	30,-180,-300
	dc.w	30,-165,-240
	dc.w	-30,-165,-240
	dc.w	-30,-180,-300

	dc.w	30,-240,-300
	dc.w	30,-240,-240
	dc.w	-30,-240,-240
	dc.w	-30,-240,-300


	dc.w	set.fill.colour.offset
	dc.w	fcol3

	dc.w	polygon.orientation.offset
	dc.w	P2,P8,P7
	dc.w	378
	dc.w	4
	dc.w	P2,P8,P7,P1


	dc.w	rotate.coords.offset

	dc.w	20*6

	dc.w	23-1

	dc.w	150,-9,390
	dc.w	150,-39,270
	dc.w	102,-30,306
	dc.w	150,-21,342

	dc.w	90,-39,270
	dc.w	42,-39,270
	dc.w	42,-9,390
	dc.w	90,-9,390

	dc.w	30,-39,270
	dc.w	30,-9,390
	dc.w	-18,-9,390

	dc.w	-30,-39,270
	dc.w	-30,-9,390

	dc.w	-90,-39,270
	dc.w	-42,-39,270
	dc.w	-42,-9,390
	dc.w	-90,-9,390

	dc.w	-150,-39,270
	dc.w	-102,-39,270
	dc.w	-102,-24,330
	dc.w	-126,-24,330
	dc.w	-102,-9,390
	dc.w	-150,-9,390


	dc.w	set.line.colour.offset
	dc.w	lcol0

	dc.w	line.offset
	dc.w	P21,P22

	dc.w	line.offset
	dc.w	P22,P23

	dc.w	line.offset
	dc.w	P23,P24


	dc.w	line.offset
	dc.w	P25,P26

	dc.w	line.offset
	dc.w	P26,P27

	dc.w	line.offset
	dc.w	P27,P28

	dc.w	line.offset
	dc.w	P28,P25


	dc.w	line.offset
	dc.w	P29,P30

	dc.w	line.offset
	dc.w	P30,P31


	dc.w	line.offset
	dc.w	P32,P33


	dc.w	line.offset
	dc.w	P34,P35

	dc.w	line.offset
	dc.w	P35,P36

	dc.w	line.offset
	dc.w	P36,P37


	dc.w	line.offset
	dc.w	P38,P39

	dc.w	line.offset
	dc.w	P39,P42

	dc.w	line.offset
	dc.w	P42,P43

	dc.w	line.offset
	dc.w	P40,P41


	dc.w	sub.object.offset
	dc.w	120


; top - small box

	dc.w	set.fill.colour.offset
	dc.w	fcol14

	dc.w	polygon.orientation.offset
	dc.w	P14,P18,P19
	dc.w	2+4*2
	dc.w	4
	dc.w	P14,P18,P19,P15

	dc.w	polygon.orientation.offset
	dc.w	P13,P16,P20
	dc.w	2+4*2
	dc.w	4
	dc.w	P13,P16,P20,P17


	dc.w	set.fill.colour.offset
	dc.w	fcol30

	dc.w	polygon.orientation.offset
	dc.w	P14,P13,P17
	dc.w	2+4*2
	dc.w	4
	dc.w	P14,P13,P17,P18

	dc.w	polygon.orientation.offset
	dc.w	P16,P15,P19
	dc.w	2+4*2
	dc.w	4
	dc.w	P16,P15,P19,P20


	dc.w	set.fill.colour.offset
	dc.w	fcol15

	dc.w	polygon.orientation.offset
	dc.w	P20,P19,P18
	dc.w	2+4*2
	dc.w	4
	dc.w	P20,P19,P18,P17

	dc.w	end.offset


	dc.w	sub.object.offset
	dc.w	-116


; bottom - main body

	dc.w	set.fill.colour.offset
	dc.w	fcol4

	dc.w	polygon.orientation.offset
	dc.w	P3,P2,P1
	dc.w	2+3*2
	dc.w	3
	dc.w	P3,P2,P1

	dc.w	polygon.orientation.offset
	dc.w	P4,P6,P5
	dc.w	2+3*2
	dc.w	3
	dc.w	P4,P6,P5

	dc.w	polygon.orientation.offset
	dc.w	P7,P8,P9
	dc.w	2+3*2
	dc.w	3
	dc.w	P7,P8,P9

	dc.w	polygon.orientation.offset
	dc.w	P10,P11,P12
	dc.w	2+3*2
	dc.w	3
	dc.w	P10,P11,P12


	dc.w	set.fill.colour.offset
	dc.w	fcol5

	dc.w	polygon.orientation.offset
	dc.w	P3,P1,P6
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P1,P6,P4

	dc.w	polygon.orientation.offset
	dc.w	P7,P9,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P7,P9,P10,P12

	dc.w	polygon.orientation.offset
	dc.w	P3,P4,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P4,P10,P9

	dc.w	polygon.orientation.offset
	dc.w	P1,P7,P12
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P7,P12,P6


	dc.w	set.fill.colour.offset
	dc.w	fcol46

	dc.w	polygon.orientation.offset
	dc.w	P2,P3,P9
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P3,P9,P8


	dc.w	set.fill.colour.offset
	dc.w	fcol45

	dc.w	polygon.orientation.offset
	dc.w	P5,P11,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P5,P11,P10,P4


	dc.w	set.fill.colour.offset
	dc.w	fcol19

	dc.w	polygon.orientation.offset
	dc.w	P6,P12,P11
	dc.w	2+4*2
	dc.w	4
	dc.w	P6,P12,P11,P5

	dc.w	end.offset



angel	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	13-1

	dc.w	-300,0,450
	dc.w	-300,0,-300
	dc.w	300,0,-300
	dc.w	300,0,450

	dc.w	-240,-600,240
	dc.w	-240,-600,-240
	dc.w	240,-600,-240
	dc.w	240,-600,240

	dc.w	0,-840,0

	dc.w	-240,-840,0
	dc.w	240,-840,0

	dc.w	-300,-1140,0
	dc.w	300,-1140,0


	dc.w	set.fill.colour.offset
	dc.w	fcol3

	dc.w	polygon.orientation.offset
	dc.w	P8,P7,P6
	dc.w	74
	dc.w	4
	dc.w	P8,P7,P6,P5


	dc.w	sub.object.offset
	dc.w	66


; head

	dc.w	set.line.colour.offset
	dc.w	lcol13

	dc.w	set.fill.colour.offset
	dc.w	fcol14

	dc.w	component.priority.offset
	dc.w	P10+4,P11+4
	dc.w	6+8+6+2


	dc.w	line.offset
	dc.w	P10,P12

	dc.w	circle.offset
	dc.w	P9
	dc.l	30*1024

	dc.w	line.offset
	dc.w	P11,P13

	dc.w	end.offset


	dc.w	line.offset
	dc.w	P11,P13

	dc.w	circle.offset
	dc.w	P9
	dc.l	30*1024

	dc.w	line.offset
	dc.w	P10,P12

	dc.w	end.offset


	dc.w	sub.object.offset
	dc.w	-62


; body

	dc.w	set.fill.colour.offset
	dc.w	fcol5

	dc.w	polygon.orientation.offset
	dc.w	P2,P6,P7
	dc.w	2+4*2
	dc.w	4
	dc.w	P2,P6,P7,P3

	dc.w	polygon.orientation.offset
	dc.w	P4,P8,P5
	dc.w	2+4*2
	dc.w	4
	dc.w	P4,P8,P5,P1


	dc.w	set.fill.colour.offset
	dc.w	fcol4

	dc.w	polygon.orientation.offset
	dc.w	P1,P5,P6
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P5,P6,P2

	dc.w	polygon.orientation.offset
	dc.w	P3,P7,P8
	dc.w	2+4*2
	dc.w	4
	dc.w	P3,P7,P8,P4


	dc.w	set.fill.colour.offset
	dc.w	fcol2

	dc.w	polygon.orientation.offset
	dc.w	P1,P2,P3
	dc.w	2+4*2
	dc.w	4
	dc.w	P1,P2,P3,P4

	dc.w	end.offset



power	dc.w	rotate.coords.offset

	dc.w	0

	dc.w	25-1

	dc.w	375,-975,0
	dc.w	-375,-975,0
	dc.w	249,-1044,87
	dc.w	-249,-1023,-78
	dc.w	123,-957,-171
	dc.w	-123,-1065,102
	dc.w	0,-855,204

	dc.w	750,0,450
	dc.w	-750,0,450
	dc.w	750,0,-450
	dc.w	-750,0,-450

	dc.w	300,-75,120
	dc.w	-300,-75,120
	dc.w	300,-75,-120
	dc.w	-300,-75,-120

	dc.w	225,-225,45
	dc.w	-225,-225,45
	dc.w	225,-225,-45
	dc.w	-225,-225,-45

	dc.w	375,-975,75
	dc.w	-375,-975,75
	dc.w	375,-975,-75
	dc.w	-375,-975,-75

	dc.w	150,-1725,0
	dc.w	-150,-1725,0


	dc.w	set.fill.colour.offset
	dc.w	fcol2

	dc.w	polygon.orientation.offset
	dc.w	P14,P12,P8
	dc.w	2+4*2
	dc.w	4
	dc.w	P14,P12,P8,P10

	dc.w	polygon.orientation.offset
	dc.w	P13,P15,P11
	dc.w	2+4*2
	dc.w	4
	dc.w	P13,P15,P11,P9


	dc.w	set.fill.colour.offset
	dc.w	fcol3

	dc.w	polygon.orientation.offset
	dc.w	P15,P14,P10
	dc.w	2+4*2
	dc.w	4
	dc.w	P15,P14,P10,P11

	dc.w	polygon.orientation.offset
	dc.w	P12,P13,P9
	dc.w	2+4*2
	dc.w	4
	dc.w	P12,P13,P9,P8


	dc.w	set.fill.colour.offset
	dc.w	fcol59

	dc.w	polygon.orientation.offset
	dc.w	P18,P16,P12
	dc.w	2+4*2
	dc.w	4
	dc.w	P18,P16,P12,P14

	dc.w	polygon.orientation.offset
	dc.w	P17,P19,P15
	dc.w	2+4*2
	dc.w	4
	dc.w	P17,P19,P15,P13


	dc.w	set.fill.colour.offset
	dc.w	fcol5

	dc.w	polygon.orientation.offset
	dc.w	P19,P18,P14
	dc.w	2+4*2
	dc.w	4
	dc.w	P19,P18,P14,P15

	dc.w	polygon.orientation.offset
	dc.w	P16,P17,P13
	dc.w	2+4*2
	dc.w	4
	dc.w	P16,P17,P13,P12


	dc.w	set.fill.colour.offset
	dc.w	fcol46

	dc.w	polygon.orientation.offset
	dc.w	P18,P19,P17
	dc.w	2+4*2
	dc.w	4
	dc.w	P18,P19,P17,P16

	dc.w	polygon.orientation.offset
	dc.w	P20,P22,P18
	dc.w	2+4*2
	dc.w	4
	dc.w	P20,P22,P18,P16

	dc.w	polygon.orientation.offset
	dc.w	P23,P21,P17
	dc.w	2+4*2
	dc.w	4
	dc.w	P23,P21,P17,P19


	dc.w	set.fill.colour.offset
	dc.w	fcol47

	dc.w	polygon.orientation.offset
	dc.w	P22,P20,P24
	dc.w	2+3*2
	dc.w	3
	dc.w	P22,P20,P24

	dc.w	polygon.orientation.offset
	dc.w	P21,P23,P25
	dc.w	2+3*2
	dc.w	3
	dc.w	P21,P23,P25


	dc.w	set.line.colour.offset
	dc.w	lcol12

	dc.w	line.offset
	dc.w	P1,P3

	dc.w	line.offset
	dc.w	P3,P5

	dc.w	line.offset
	dc.w	P5,P7

	dc.w	line.offset
	dc.w	P7,P6

	dc.w	line.offset
	dc.w	P6,P4

	dc.w	line.offset
	dc.w	P4,P2


	dc.w	polygon.orientation.offset
	dc.w	P18,P22,P20
	dc.w	2+4*2
	dc.w	4
	dc.w	P16,P18,P22,P20

	dc.w	polygon.orientation.offset
	dc.w	P17,P21,P23
	dc.w	2+4*2
	dc.w	4
	dc.w	P19,P17,P21,P23


	dc.w	set.fill.colour.offset
	dc.w	fcol59

	dc.w	polygon.orientation.offset
	dc.w	P24,P20,P22
	dc.w	2+3*2
	dc.w	3
	dc.w	P24,P20,P22

	dc.w	polygon.orientation.offset
	dc.w	P25,P23,P21
	dc.w	2+3*2
	dc.w	3
	dc.w	P25,P23,P21

	dc.w	end.offset




tent.frames
	dc.l	tent1,tent2,tent3,tent4,tent5,tent6,tent7,tent8
	dc.l	tent9,tent10,tent11,tent12,tent13,tent14,tent15,tent16,0




world.pointer
	dc.l	world.data


world.data
	dc.w	6
	dc.l	0,0
	dc.l	$d0000000,$1000498e,$b0000000
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$e0000000,$100080d9,$40000000
	dc.l	0,0,0
	dc.w	0

	dc.w	10
	dc.l	0,0
	dc.l	$c0000000,$100038fd,$10000000
	dc.l	0,0,0
	dc.w	0

	dc.w	6
	dc.l	0,0
	dc.l	$70000000,$10001b40,$00000000
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$20000000,$100060a1,$20000000
	dc.l	0,0,0
	dc.w	0

	dc.w	10
	dc.l	0,0
	dc.l	$50000000,$100006a4,$70000000
	dc.l	0,0,0
	dc.w	0

	dc.w	6
	dc.l	0,0
	dc.l	$10000000,$00005ff3,$f0000000
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$00000000,$00007333,$20000000
	dc.l	0,0,0
	dc.w	0

	dc.w	10
	dc.l	0,0
	dc.l	$70000000,$0000f9d6,$50000000
	dc.l	0,0,0
	dc.w	0

	dc.w	6
	dc.l	0,0
	dc.l	$e0000000,$00006d6c,$20000000
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$10000000,$00002f72,$20000000
	dc.l	0,0,0
	dc.w	0

	dc.w	10
	dc.l	0,0
	dc.l	$a0000000,$10007de2,$40000000
	dc.l	0,0,0
	dc.w	0

	dc.w	2
	dc.l	0,0
	dc.l	$80000000,$10000000,$80000000
	dc.l	0,0,0
	dc.w	0

	dc.w	2
	dc.l	0,0
	dc.l	$00000000,$10000000,$80000000
	dc.l	0,0,0
	dc.w	0

	dc.w	2
	dc.l	0,0
	dc.l	$80000000,$10000000,$00000000
	dc.l	0,0,0
	dc.w	0

	dc.w	2
	dc.l	0,0
	dc.l	$00000000,$10000000,$00000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$c4000000,$1000498e,$04000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$f8000000,$100080d9,$64000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$fc000000,$100038fd,$1c000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$ac000000,$10001b40,$e8000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$fc000000,$100060a1,$e4000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$80000000,$100006a4,$18000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$1c000000,$00005ff3,$cc000000
	dc.l	0,0,0
	dc.w	0

	dc.w	4
	dc.l	0,0
	dc.l	$ac000000,$00007333,$fc000000
	dc.l	0,0,0
	dc.w	0

	dc.w	6
	dc.l	0,0
	dc.l	$d5368216,$0b500000,$b08a6f01
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$0815cf37,$10000000,$f923abbb
	dc.l	0,0,0
	dc.w	0

	dc.w	10
	dc.l	0,0
	dc.l	$1fe290a3,$0847a77e,$46b9a884
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	6
	dc.l	0,0
	dc.l	$1d245785,$0847a77e,$505abe60
	dc.l	0,0,0
	dc.w	0

	dc.w	8
	dc.l	0,0
	dc.l	$1f1fc0aa,$0847a77e,$4736b2d1
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	0
	dc.l	0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.w	0

	dc.w	$ffff
