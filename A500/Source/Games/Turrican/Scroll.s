	section	Scroll,code_c
	opt	o+,o3-


; Change incbin (near bottom of file) to "Map1.2" or "Map1.3" to show other maps



start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off

	move.l	#4*48*256+200*4,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	move.l	d0,screen.part1
;	move.l	#4*40*200,d1
;	add.l	d1,d0
;	move.l	d0,screen2
;	add.l	d1,d0
;	move.l	d0,screen3

	lea	graf.name(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter

	move.l	38(a6),old.copper

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction

	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0
set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c91,diwstrt(a6)
	move.w	#$ecc1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	#3*48+8,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)




;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)




;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w




;""""""""""""""""""""
;" CALCULATE TABLES "
;"		    "
;""""""""""""""""""""

	move.w	#200-1,d0		count
	moveq	#0,d1			offset starts at zero
	moveq	#51,d2			51 rows per column of map
	lea	map.offsets.table(pc),a0

.loop	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,.loop




	move.w	#256-1,d0		count
	moveq	#0,d1			offset starts at zero
	move.l	#192,d2			192 bytes per line
	lea	y.offsets.table(pc),a0

.loop2	move.l	d1,(a0)+
	add.l	d2,d1
	dbra	d0,.loop2




	move.w	#209-1,d0		count
	lea	tile0(pc),a0
	move.w	#512,d1			512 bytes per tile
	lea	tile.table(pc),a1

.loop3	move.l	a0,(a1)+
	add.w	d1,a0
	dbra	d0,.loop3




	bsr	plot.map.screen




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	read.joystick
	bsr	get.new.direction
	bsr	vertical.scroll
	bsr	horizontal.scroll

	clr.w	next.frame
wait	tst.w	next.frame
	beq.s	wait

	bsr	set.screen.position

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old.level3(pc),$6c.w

	move.l	old.copper(pc),cop1lch(a6)

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		DisownBlitter

	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	screen.mem(pc),a1
	move.l	#4*48*256+200*4,d0
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	move.w	#1,next.frame

	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

read.joystick
	move.w	joy1dat(a6),d0
	moveq	#0,d2			initial x speed
	moveq	#0,d3			initial y speed

test.joy.left
	btst	#9,d0
	beq.s	test.joy.right

	moveq	#-4,d2
	bra.s	test.joy.up

test.joy.right
	btst	#1,d0
	beq.s	test.joy.up

	moveq	#4,d2

test.joy.up
	move.w	d0,d1
	lsr.w	#1,d1
	eor.w	d0,d1

	btst	#8,d1
	beq.s	test.joy.down

	moveq	#-4,d3
	bra.s	joystick.read

test.joy.down
	btst	#0,d1
	beq.s	joystick.read

	moveq	#4,d3

joystick.read
	move.w	d2,x.speed
	move.w	d3,y.speed
	rts




get.new.direction
	moveq	#0,d1
	moveq	#0,d2

x.direction
	move.w	x.speed(pc),d0
	bne.s	some.x.movement

	move.w	old.direction(pc),d1
	and.w	#2,d1			get old x direction
	bra.s	y.direction

some.x.movement
	bpl.s	y.direction
	moveq	#2,d1

y.direction
	move.w	y.speed(pc),d0
	bne.s	some.y.movement

	move.w	old.direction(pc),d2
	and.w	#1,d2			get old y direction
	bra.s	compare.directions

some.y.movement
	bpl.s	compare.directions
	moveq	#1,d2

compare.directions
	add.w	d2,d1			new direction value

	move.w	old.direction(pc),d2
	move.w	d1,old.direction

	cmp.w	d2,d1
	beq.s	no.direction.change

	add.w	d2,d2
	add.w	d2,d2
	add.w	d1,d2			new value determines column
	add.w	d2,d2
	add.w	d2,d2			old value determines row

	move.l	direction.table(pc,d2.w),a0
	jmp	(a0)

no.direction.change
	rts




direction.table
	dc.l	0,up,left,up.left
	dc.l	down,0,down.left,left
	dc.l	right,up.right,0,up
	dc.l	down.right,right,down,0

up.left	moveq	#0,d7
	bsr.s	set.vertical.direction
left	moveq	#0,d7
	bra.s	set.horizontal.direction

down.left
	moveq	#0,d7
	bsr.s	set.horizontal.direction
down	moveq	#1,d7
	bra.s	set.vertical.direction

up.right
	moveq	#1,d7
	bsr.s	set.horizontal.direction
up	moveq	#0,d7
	bra.s	set.vertical.direction

down.right
	moveq	#1,d7
	bsr.s	set.vertical.direction
right	moveq	#1,d7
;	bra.s	set.horizontal.direction	directly after it




set.horizontal.direction
	movem.w	map.x.position(pc),d0-d1
	tst.w	d7
	beq.s	going.left

going.right
	add.w	#11,d0			set to right side of screen
	lea	offsets.table1(pc),a2
	bra.s	set.horiz.count

going.left
	subq.w	#1,d0			set to left side of screen
	bpl.s	not.left.limit

	clr.w	horizontal.scroll.info	clear tile count if edge reached
	bra.s	horiz.pointers.set

not.left.limit
	lea	offsets.table2(pc),a2

set.horiz.count
	bsr	set.horiz.pointers

horiz.pointers.set
	lea	vertical.scroll.info(pc),a2
	tst.w	(a2)			vertical tile count, quit if zero
	beq.s	horizontal.direction.set

	tst.w	d7
	bne.s	going.right2

going.left2
	lea	vert.scroll.data1(pc),a1
	bra.s	set.vert.values

going.right2
	lea	vert.scroll.data2(pc),a1

set.vert.values
	move.l	a1,2(a2)		set position values pointer
	move.w	#12,(a2)		12 tiles to draw

horizontal.direction.set
	rts




set.vertical.direction
	movem.w	map.x.position(pc),d0-d1
	tst.w	d7
	beq.s	going.up

going.down
	addq.w	#7,d1			set to bottom of screen
	bra.s	set.vert.count

going.up
	subq.w	#1,d1			set to top of screen
	bpl.s	set.vert.count

	clr.w	vertical.scroll.info	clear tile count if edge reached
	bra.s	vert.pointers.set

set.vert.count
	move.w	screen.part2.height(pc),d2
	and.w	#$ffe0,d2		multiple of 32
	bsr	set.vert.pointers

	move.w	vertical.scroll.value(pc),d0
	add.w	d0,screen.part2.height

vert.pointers.set
	lea	horizontal.scroll.info(pc),a2
	tst.w	(a2)			horizontal tile count, quit if zero
	beq.s	vertical.direction.set

	tst.w	d7
	bne.s	going.down2

going.up2
	lea	horiz.scroll.data1(pc),a1
	bra.s	set.horiz.values

going.down2
	lea	horiz.scroll.data2(pc),a1

set.horiz.values
	move.l	a1,2(a2)		set position values pointer
	move.w	#8,(a2)			8 tiles to draw

vertical.direction.set
	rts




horizontal.scroll
	tst.w	x.speed
	bne.s	horizontal.movement
	rts

horizontal.movement
	bsr	draw.horizontal.tiles

	move.w	x.speed(pc),d0
	sub.w	d0,horizontal.scroll.value
	bpl.s	check.horiz.scroll.max

	movem.w	map.x.position(pc),d0-d1
	addq.w	#1,d0			next map position right
	cmp.w	max.map.x.position(pc),d0
	bls.s	map.x.not.max

	clr.w	x.speed
	clr.w	horizontal.scroll.value
	rts

map.x.not.max
	move.w	d0,map.x.position
	addq.l	#4,screen.part1
	addq.l	#4,screen.part2
	add.w	#32,horizontal.scroll.value
	addq.w	#1,horizontal.offset

	add.w	#11,d0			set to right side of screen
	lea	offsets.table1(pc),a2
	bra.s	set.horiz.pointers

check.horiz.scroll.max
	cmp.w	#32,horizontal.scroll.value
	blt.s	horizontal.scroll.done

	movem.w	map.x.position(pc),d0-d1
	subq.w	#1,d0			next map position left
	bpl.s	map.x.not.min

	clr.w	x.speed
	move.w	#31,horizontal.scroll.value
	rts

map.x.not.min
	move.w	d0,map.x.position
	subq.l	#4,screen.part1
	subq.l	#4,screen.part2
	sub.w	#32,horizontal.scroll.value
	subq.w	#1,horizontal.offset

	subq.w	#1,d0			set to left side of screen
	lea	offsets.table2(pc),a2
	bra.s	set.horiz.pointers

horizontal.scroll.done
	rts




set.horiz.pointers
	lea	horizontal.scroll.info(pc),a0

	tst.w	d0			map x position
	bpl.s	map.x.ok

	clr.w	(a0)			clear tile count
	bra.s	clear.horiz.tile.flags

map.x.ok
	move.w	#8,(a0)			set tile count - 8 tiles to draw

	lea	map.offsets.table(pc),a1
	add.w	d0,d0
	add.w	(a1,d0.w),d1
	lea	map(pc),a1
	add.w	d1,a1
	move.l	a1,10(a0)		set map pointer

	move.w	old.direction(pc),d0
	and.w	#1,d0
	beq.s	going.down3

going.up3
	lea	horiz.scroll.data1(pc),a1
	bra.s	set.horiz.data.pointers

going.down3
	lea	horiz.scroll.data2(pc),a1

set.horiz.data.pointers
	move.l	a1,2(a0)		set position values pointer

	move.w	screen.part2.height(pc),d0
	and.w	#$ffe0,d0		multiple of 32
	sub.w	#7*32,d0
	neg.w	d0			get complement value
	lsr.w	#3,d0			offset into table
	add.w	d0,a2
	move.l	a2,6(a0)		set offset values pointer

clear.horiz.tile.flags
	lea	horiz.tile.flags(pc),a2
	moveq	#0,d0
	move.l	d0,(a2)+
	move.l	d0,(a2)			clear 8 tile flags

	move.w	d0,vertical.offset
	rts




vertical.scroll
	tst.w	y.speed
	beq	set.screen.address

vertical.movement
	bsr	draw.vertical.tiles

	move.w	y.speed(pc),d0
	sub.w	d0,vertical.scroll.value
	bpl.s	check.vert.scroll.max

	move.w	screen.part2.height(pc),d2
	and.w	#$ffe0,d2		multiple of 32
	sub.w	#32,d2
	add.w	#32,vertical.scroll.value

	movem.w	map.x.position(pc),d0-d1
	addq.w	#1,d1			next map position down
	cmp.w	max.map.y.position(pc),d1
	bls.s	map.y.not.max

	clr.w	y.speed
	clr.w	vertical.scroll.value
	bra.s	set.screen.address

map.y.not.max
	move.w	d1,map.y.position
	addq.w	#1,vertical.offset

	addq.w	#7,d1			set to bottom of screen
	bsr	set.vert.pointers
	bra.s	set.screen.address

check.vert.scroll.max
	cmp.w	#32,vertical.scroll.value
	blt.s	set.screen.address

	move.w	screen.part2.height(pc),d2
	and.w	#$ffe0,d2		multiple of 32
	add.w	#32,d2
	sub.w	#32,vertical.scroll.value

	movem.w	map.x.position(pc),d0-d1
	subq.w	#1,d1			next map position up
	bpl.s	map.y.not.min

	clr.w	y.speed
	move.w	#31,vertical.scroll.value
	bra.s	set.screen.address

map.y.not.min
	move.w	d1,map.y.position
	subq.w	#1,vertical.offset

	subq.w	#1,d1			set to top of screen
	bsr.s	set.vert.pointers

set.screen.address
	lea	y.offsets.table(pc),a1
	move.l	screen.part1(pc),d1
	move.w	screen.part2.height(pc),d2
	and.w	#$ffe0,d2		multiple of 32
	add.w	vertical.scroll.value(pc),d2
	move.w	d2,screen.part2.height
	bmi.s	minus
	beq.s	equal

	sub.w	#256,d2

minus	neg.w	d2
	add.w	d2,d2
	add.w	d2,d2
	add.l	(a1,d2.w),d1

equal	move.l	d1,screen.part2
	rts




set.vert.pointers
	lea	vertical.scroll.info(pc),a0

	cmp.w	#$ffc0,d2		-64
	bgt.s	greater

	move.w	#192,d2

greater	cmp.w	#224,d2
	blt.s	less

	moveq	#-32,d2

less	move.w	d2,screen.part2.height

	tst.w	d1			map y position
	bpl.s	map.y.ok

	clr.w	(a0)			clear tile count
	bra.s	clear.vert.tile.flags

map.y.ok
	move.w	#12,(a0)		set tile count - 12 tiles to draw

	lea	map.offsets.table(pc),a1
	add.w	d0,d0
	add.w	(a1,d0.w),d1
	lea	map(pc),a1
	add.w	d1,a1
	move.l	a1,10(a0)		set map pointer

	move.w	old.direction(pc),d0
	and.w	#2,d0
	beq.s	going.right3

going.left3
	lea	vert.scroll.data1(pc),a1
	bra.s	set.vert.data.pointers

going.right3
	lea	vert.scroll.data2(pc),a1

set.vert.data.pointers
	move.l	a1,2(a0)		set position values pointer

	sub.w	#192,d2
	neg.w	d2			192 - value
	add.w	d2,d2
	add.w	d2,d2
	lea	y.offsets.table(pc),a2
	move.l	(a2,d2.w),d2
	add.l	screen.part1(pc),d2
	move.l	d2,14(a0)		set screen address

clear.vert.tile.flags
	lea	vert.tile.flags(pc),a2
	moveq	#0,d0
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)			clear 12 tile flags

	move.w	d0,horizontal.offset
	rts




draw.horizontal.tiles
	lea	horizontal.scroll.info(pc),a0
	move.w	horizontal.scroll.value(pc),d0
	move.w	x.speed(pc),d1
	move.l	screen.part1(pc),d3
	lea	get.horiz.tile.value(pc),a5
	move.w	vertical.offset(pc),d2
	cmp.w	#7,d2
	blt.s	tile.count.not.max

clear.tile.count
	clr.w	(a0)
	rts

tile.count.not.max
	cmp.w	#-7,d2
	ble.s	clear.tile.count
	bra.s	check.tile.count

draw.vertical.tiles
	lea	vertical.scroll.info(pc),a0
	move.w	vertical.scroll.value(pc),d0
	move.w	y.speed(pc),d1
	move.l	14(a0),d3		screen address
	lea	get.vert.tile.value(pc),a5
	move.w	horizontal.offset(pc),d2
	cmp.w	#11,d2
	blt.s	tile.count.not.max2

clear.tile.count2
	clr.w	(a0)
	rts

tile.count.not.max2
	cmp.w	#-11,d2
	ble.s	clear.tile.count2

check.tile.count
	tst.w	(a0)
	bne.s	tile.count.not.zero
	rts

tile.count.not.zero
	lea	tile.count.values(pc),a1
	tst.w	d1			x or y speed
	bpl.s	speed.positive

	sub.w	#31,d0
	neg.w	d0			31 - scroll value
	neg.w	d1			positive speed

speed.positive
	subq.w	#1,d1
	lsl.w	#5,d0
	add.w	d1,d0
	move.b	(a1,d0.w),d1		number of frames left

	subq.w	#1,d1
	move.w	(a0),d0			number of tiles left to draw
	subq.w	#1,d0
	lsl.w	#5,d0
	add.w	d1,d0
	move.b	(a1,d0.w),d0		number to draw in this frame
	ext.w	d0
	sub.w	d0,(a0)			remove from tile count
	subq.w	#1,d0			count for dbra

	move.l	#$9f00000,bltcon0(a6)
	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.l	#48-4,bltamod(a6)

	move.l	10(a0),a1		map pointer
	move.l	2(a0),a2		position values pointer
	move.l	6(a0),a3		offset values pointer
	lea	tile.table(pc),a4

draw.tile
	move.w	(a2)+,d2		position on screen
	move.w	(a2)+,d4		position at which to get tile

	jsr	(a5)

	bne.s	draw.next.tile

	add.w	d1,d1
	add.w	d1,d1
	move.l	(a4,d1.w),bltapth(a6)	tile address
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a3,d2.w),d2		start offset for screen
	add.l	d3,d2			start address for screen
	move.l	d2,bltdpth(a6)
	move.w	#4*32*64+2,bltsize(a6)

draw.next.tile
	dbra	d0,draw.tile

	move.l	a2,2(a0)		save position values pointer
	rts




get.horiz.tile.value
	move.l	a5,-(sp)
	lea	horiz.tile.flags(pc),a5
	move.w	vertical.offset(pc),d7
	btst	#0,old.direction+1
	beq.s	going.down4

going.up4
	subq.w	#1,d7

going.down4
	tst.w	d7
	beq.s	test.tile.flag
	bpl.s	compare.position2

	addq.w	#7,d7

compare.position
	cmp.w	d7,d2
	bls.s	test.tile.flag

	subq.w	#8,d4
	bra.s	clear.tile.flag

compare.position2
	cmp.w	d7,d2
	bcc.s	test.tile.flag

	addq.w	#8,d4

clear.tile.flag
	sf	(a5,d2.w)

test.tile.flag
	tst.b	(a5,d2.w)
	bne.s	tile.position.filled	zero flag clear

	st	(a5,d2.w)

	moveq	#0,d1
	move.b	(a1,d4.w),d1		get tile value

	moveq	#0,d7			set zero flag

tile.position.filled
	move.l	(sp)+,a5
	rts




get.vert.tile.value
	move.l	a5,-(sp)
	move.w	d2,d6
	move.w	horizontal.offset(pc),d7
	btst	#1,old.direction+1
	beq.s	going.right4

going.left4
	subq.w	#1,d7

going.right4
	tst.w	d7
	beq.s	test.tile.flag2
	bpl.s	compare.position4

	add.w	#11,d7

compare.position3
	cmp.w	d7,d2
	bls.s	test.tile.flag2

	sub.w	#12,d2
	move.w	d2,d4
	neg.w	d4
	lea	map.offsets.table(pc),a5
	add.w	d4,d4
	move.w	(a5,d4.w),d4
	neg.w	d4
	bra.s	clear.tile.flag2

compare.position4
	cmp.w	d7,d2
	bcc.s	test.tile.flag2

	add.w	#12,d2
	move.w	d2,d4
	lea	map.offsets.table(pc),a5
	add.w	d4,d4
	move.w	(a5,d4.w),d4

clear.tile.flag2
	lea	vert.tile.flags(pc),a5
	sf	(a5,d6.w)

test.tile.flag2
	lea	vert.tile.flags(pc),a5
	tst.b	(a5,d6.w)
	bne.s	tile.position.filled2	zero flag clear

	st	(a5,d6.w)

	moveq	#0,d1
	move.b	(a1,d4.w),d1		get tile value

	moveq	#0,d7			set zero flag

tile.position.filled2
	move.l	(sp)+,a5
	rts




plot.map.screen				; 12 tiles wide by 8 tiles down
	lea	map(pc),a0
	movem.w	map.x.position(pc),d0-d1
	lea	map.offsets.table(pc),a1
	add.w	d0,d0
	add.w	(a1,d0.w),d1
	add.w	d1,a0			map address

	lea	tile.table(pc),a1
	move.l	screen.part1(pc),a2

	move.l	#$9f00000,bltcon0(a6)
	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.l	#48-4,bltamod(a6)

	move.w	#4*32*64+2,d3
	moveq	#12-1,d0		column count

map.column
	move.l	a2,bltdpth(a6)
	moveq	#8-1,d1			row count

map.row	moveq	#0,d2
	move.b	(a0)+,d2		get tile number
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a1,d2.w),bltapth(a6)	set tile address
	move.w	d3,bltsize(a6)
	dbra	d1,map.row

	lea	51-8(a0),a0		next column of map
	addq.w	#4,a2			next screen column
	dbra	d0,map.column
	rts




set.screen.position
	moveq	#2,d0			1 word
	move.w	horizontal.scroll.value(pc),d1
	cmp.w	#16,d1
	blt.s	extra.word
	moveq	#0,d0			no words

extra.word
	and.w	#$f,d1
	move.w	d1,d2
	lsl.w	#4,d2
	or.w	d1,d2
	move.w	d2,copper.list+2	put value into copper list

	move.l	d0,d3
	add.l	screen.part1(pc),d0
	move.w	screen.part2.height(pc),d2
	beq.s	first.screen
	bmi.s	second.screen

	cmp.w	#192,d2
	bge.s	second.screen

both.screens
	add.w	#$2c,d2			hardware screen start
	move.b	d2,copper.wait

	lea	bitplane.ptrs2(pc),a0
	bsr.s	init.copper

	move.l	screen.part2(pc),d0
	add.l	d3,d0
	lea	bitplane.ptrs1(pc),a0
	bra.s	init.copper

second.screen
	move.l	screen.part2(pc),d0
	add.l	d3,d0

first.screen
	clr.b	copper.wait

	lea	bitplane.ptrs2(pc),a0
;	bra.s	init.copper		directly after it




init.copper
	moveq	#4-1,d1
	moveq	#48,d2			width of screen in bytes
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list
	dc.w	bplcon1,0

bitplane.ptrs1
	dc.w	bpl1pth
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

copper.wait
	dc.w	$0001,$ff00

bitplane.ptrs2
	dc.w	bpl1pth
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$ec01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;""""""""""""""""""""""
;" Hardware registers "
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

screen.part1	dc.l	0
screen.part2	dc.l	0

old.ints	dc.w	0
old.dbz		dc.l	0
gfxbase		dc.l	0
old.copper	dc.l	0
old.level3	dc.l	0
next.frame	dc.w	0

x.speed		dc.w	0
y.speed		dc.w	0

old.direction	dc.w	0

horizontal.scroll.info
		dc.w	0
		dc.l	0
		dc.l	0
		dc.l	0

vertical.scroll.info
		dc.w	0
		dc.l	0
		dc.l	offsets.table3
		dc.l	0
		dc.l	0

horiz.tile.flags
		ds.b	8
vert.tile.flags	ds.b	12

horizontal.offset
		dc.w	0
vertical.offset	dc.w	0

map.x.position	dc.w	0
map.y.position	dc.w	0

max.map.x.position
		dc.w	137-11
max.map.y.position
		dc.w	51-7

horizontal.scroll.value
		dc.w	31
vertical.scroll.value
		dc.w	31

screen.part2.height
		dc.w	-32

map.offsets.table
		ds.w	200

y.offsets.table	ds.l	256




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even


horiz.scroll.data1
		dc.w	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,-1,-1

horiz.scroll.data2
		dc.w	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0,-1,-1


offsets.table1	dc.l	44
		dc.l	32*192+44
		dc.l	2*32*192+44
		dc.l	3*32*192+44
		dc.l	4*32*192+44
		dc.l	5*32*192+44
		dc.l	6*32*192+44
		dc.l	7*32*192+44
		dc.l	44
		dc.l	32*192+44
		dc.l	2*32*192+44
		dc.l	3*32*192+44
		dc.l	4*32*192+44
		dc.l	5*32*192+44
		dc.l	6*32*192+44
		dc.l	7*32*192+44


offsets.table2	dc.l	-4
		dc.l	32*192-4
		dc.l	2*32*192-4
		dc.l	3*32*192-4
		dc.l	4*32*192-4
		dc.l	5*32*192-4
		dc.l	6*32*192-4
		dc.l	7*32*192-4
		dc.l	-4
		dc.l	32*192-4
		dc.l	2*32*192-4
		dc.l	3*32*192-4
		dc.l	4*32*192-4
		dc.l	5*32*192-4
		dc.l	6*32*192-4
		dc.l	7*32*192-4


vert.scroll.data1
		dc.w	0,0,1,51,2,2*51,3,3*51,4,4*51,5,5*51,6,6*51,7,7*51
		dc.w	8,8*51,9,9*51,10,10*51,11,11*51,-1,-1

vert.scroll.data2
		dc.w	11,11*51,10,10*51,9,9*51,8,8*51,7,7*51,6,6*51,5,5*51
		dc.w	4,4*51,3,3*51,2,2*51,1,51,0,0,-1,-1


		dc.l	-64,-60,-56,-52,-48,-44,-40,-36
		dc.l	-32,-28,-24,-20,-16,-12,-8,-4
offsets.table3	dc.l	0,4,8,12,16,20,24,28,32,36,40,44,48
		dc.l	52,56,60,64,68,72,76,80,84,88,92,96,100


tile.count.values
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	4,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	5,3,2,2,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	6,3,2,2,2,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	7,4,3,2,2,2,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	8,4,3,2,2,2,2,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	9,5,3,3,2,2,2,2,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	10,5,4,3,2,2,2,2,2,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	11,6,4,3,3,2,2,2,2,2,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	12,6,4,3,3,2,2,2,2,2,2,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	13,7,5,4,3,3,2,2,2,2,2,2,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	14,7,5,4,3,3,2,2,2,2,2,2,2,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	15,8,5,4,3,3,3,2,2,2,2,2,2,2,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	16,8,6,4,4,3,3,2,2,2,2,2,2,2,2,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	17,9,6,5,4,3,3,3,2,2,2,2,2,2,2,2
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	18,9,6,5,4,3,3,3,2,2,2,2,2,2,2,2
	dc.b	2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	19,10,7,5,4,4,3,3,3,2,2,2,2,2,2,2
	dc.b	2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	20,10,7,5,4,4,3,3,3,2,2,2,2,2,2,2
	dc.b	2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	21,11,7,6,5,4,3,3,3,3,2,2,2,2,2,2
	dc.b	2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	22,11,8,6,5,4,4,3,3,3,2,2,2,2,2,2
	dc.b	2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1

	dc.b	23,12,8,6,5,4,4,3,3,3,3,2,2,2,2,2
	dc.b	2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1

	dc.b	24,12,8,6,5,4,4,3,3,3,3,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1

	dc.b	25,13,9,7,5,5,4,4,3,3,3,3,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1

	dc.b	26,13,9,7,6,5,4,4,3,3,3,3,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1

	dc.b	27,14,9,7,6,5,4,4,3,3,3,3,3,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1

	dc.b	28,14,10,7,6,5,4,4,4,3,3,3,3,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1

	dc.b	29,15,10,8,6,5,5,4,4,3,3,3,3,3,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1

	dc.b	30,15,10,8,6,5,5,4,4,3,3,3,3,3,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1

	dc.b	31,16,11,8,7,6,5,4,4,4,3,3,3,3,3,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1

	dc.b	32,16,11,8,7,6,5,4,4,4,3,3,3,3,3,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

colour.table
	dc.w	$000,$420,$742,$a70,$ca7,$09e,$36f,$591
	dc.w	$223,$445,$778,$aab,$c00,$f60,$ff0,$fff


map	incbin	Map1.1


tile.table
	ds.l	209


tile0	incbin	Tiles1
