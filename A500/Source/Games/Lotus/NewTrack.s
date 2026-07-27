	section	NewTrack,code_c
	opt	o+,o3-



start	bset	#1,$bfe001		low pass filter off

	move.l	4.w,a6
	move.l	#3*4*42*196,d0
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
	move.w	#$3a81,diwstrt(a6)	196 tall
	move.w	#$fec1,diwstop(a6)
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



	bsr	make.track.data



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	update.course.position
	bsr	shear.track
	bsr	track.bends.and.hills
	bsr	make.screen.track
	bsr	clear
	bsr	draw.track

	bsr	frames.per.sec

	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait

	bsr	update.screens

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
	move.l	#3*4*42*196,d0
	jsr	-210(a6)		FreeMem

	bclr	#1,$bfe001		low pass filter on
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
;"""""""""""""""

TOP.WIDTH	equ	16
BOTTOM.WIDTH	equ	512

make.track.data
	lea	track.data.plane.1(pc),a0
	lea	track.data.plane.2(pc),a1
	lea	track.data.ptrs+8*4(pc),a2
	lea	track.data.masks(pc),a4
	move.w	#249-1,d0		count
	move.l	#TOP.WIDTH*248,d1	start width * number of steps

m.t.d.loop
	move.l	a0,(a2)+		save current pointer
	move.l	d1,d2
	divu	#248,d2			calculate current width

	lea	42(a0),a0		leave 21 clear words

	move.w	d2,d3
	lsr.w	#4,d3			divide by 16 i.e. number of words
	subq.w	#1,d3			count for dbra
	moveq	#-1,d4			$ffff
.loop	move.w	d4,(a0)+		fill words
	dbra	d3,.loop

	move.w	d2,d3			save width for later
	andi.w	#$f,d2			low four bits from width
	beq.s	next.t.d.line		skip if exact number of words

	subq.w	#1,d2
	add.w	d2,d2
	move.w	(a4,d2.w),(a0)+		get last word from mask table

next.t.d.line
	rept	21
	move.w	d4,(a1)+		fill 21 words
	endr

	moveq	#0,d4			stripe 1 starts at 0
	move.l	stripe1.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s1.no.rounding2
	addq.w	#1,d5			round it up
s1.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe1.end.inc(pc),d5
	add.l	d5,stripe1.end.value

	move.l	stripe2.start.value(pc),d4	stripe 2
	divu	#248,d4
	move.l	d4,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s2.no.rounding1
	addq.w	#1,d4			round it up
s2.no.rounding1
	move.l	stripe2.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s2.no.rounding2
	addq.w	#1,d5			round it up
s2.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe2.start.inc(pc),d4
	move.l	stripe2.end.inc(pc),d5
	add.l	d4,stripe2.start.value
	add.l	d5,stripe2.end.value

	move.l	stripe3.start.value(pc),d4	stripe 3
	divu	#248,d4
	move.l	d4,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s3.no.rounding1
	addq.w	#1,d4			round it up
s3.no.rounding1
	move.l	stripe3.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s3.no.rounding2
	addq.w	#1,d5			round it up
s3.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe3.start.inc(pc),d4
	move.l	stripe3.end.inc(pc),d5
	add.l	d4,stripe3.start.value
	add.l	d5,stripe3.end.value

	move.l	stripe4.start.value(pc),d4	stripe 4
	divu	#248,d4
	move.l	d4,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s4.no.rounding1
	addq.w	#1,d4			round it up
s4.no.rounding1
	move.l	stripe4.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s4.no.rounding2
	addq.w	#1,d5			round it up
s4.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe4.start.inc(pc),d4
	move.l	stripe4.end.inc(pc),d5
	add.l	d4,stripe4.start.value
	add.l	d5,stripe4.end.value

	move.l	stripe5.start.value(pc),d4	stripe 5
	divu	#248,d4
	move.l	d4,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s5.no.rounding1
	addq.w	#1,d4			round it up
s5.no.rounding1
	move.l	stripe5.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s5.no.rounding2
	addq.w	#1,d5			round it up
s5.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe5.start.inc(pc),d4
	move.l	stripe5.end.inc(pc),d5
	add.l	d4,stripe5.start.value
	add.l	d5,stripe5.end.value

	move.l	stripe6.start.value(pc),d4	stripe 6
	divu	#248,d4
	move.l	d4,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s6.no.rounding1
	addq.w	#1,d4			round it up
s6.no.rounding1
	move.l	stripe6.end.value(pc),d5
	divu	#248,d5
	move.l	d5,d6
	swap	d6			get remainder
	cmpi.w	#124,d6
	bcs.s	s6.no.rounding2
	addq.w	#1,d5			round it up
s6.no.rounding2
	move.l	a1,a5
	bsr	fill.track.data
	move.l	stripe6.start.inc(pc),d4
	move.l	stripe6.end.inc(pc),d5
	add.l	d4,stripe6.start.value
	add.l	d5,stripe6.end.value

	addi.w	#15,d3			width from earlier
	andi.w	#$fff0,d3
	lsr.w	#3,d3
	add.w	d3,a1			add number of even bytes

	move.w	-2(a0),d2		get last word from plane 1
	not.w	d2
	or.w	d2,-2(a1)		OR it with last word from plane 2

	add.l	#BOTTOM.WIDTH-TOP.WIDTH,d1	add increment
	dbra	d0,m.t.d.loop

	moveq	#-1,d0

	rept	21
	move.w	d0,(a1)+		fill 21 words
	endr

	rts


track.data.ptrs
	ds.l	8			used for alignment
	ds.l	249			there are 257 lines of data

track.data.masks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe

stripe1.end.value
	dc.l	0*248
stripe1.end.inc
	dc.l	5

stripe2.start.value
	dc.l	3*248
stripe2.start.inc
	dc.l	98
stripe2.end.value
	dc.l	3*248
stripe2.end.inc
	dc.l	103

stripe3.start.value
	dc.l	6*248
stripe3.start.inc
	dc.l	196
stripe3.end.value
	dc.l	6*248
stripe3.end.inc
	dc.l	201

stripe4.start.value
	dc.l	9*248
stripe4.start.inc
	dc.l	295
stripe4.end.value
	dc.l	9*248
stripe4.end.inc
	dc.l	300

stripe5.start.value
	dc.l	12*248
stripe5.start.inc
	dc.l	393
stripe5.end.value
	dc.l	12*248
stripe5.end.inc
	dc.l	398

stripe6.start.value
	dc.l	15*248
stripe6.start.inc
	dc.l	491
stripe6.end.value
	dc.l	15*248
stripe6.end.inc
	dc.l	496



fill.track.data
	moveq	#$f,d6
	moveq	#$f,d7
	and.w	d4,d6			low four bits from start
	and.w	d5,d7			low four bits from end
	sub.w	d6,d4			start offset in multiples of 16 bits
	sub.w	d7,d5			end offset in multiples of 16 bits
	add.w	d6,d6
	move.w	start.masks(pc,d6.w),d6
	add.w	d7,d7
	move.w	end.masks(pc,d7.w),d7
	lsr.w	#3,d4			start offset in even bytes
	lsr.w	#3,d5			end offset in even bytes
	add.w	d4,a5			start address
	cmp.w	d4,d5			are start and end in the same word ?
	bne.s	adjacent.words

	and.w	d7,d6			make mask
	or.w	d6,(a5)			write mask
	rts

adjacent.words
	or.w	d6,(a5)+		write start mask
	or.w	d7,(a5)			write end mask
	rts


start.masks
	dc.w	$ffff,$7fff,$3fff,$1fff
	dc.w	$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f
	dc.w	$000f,$0007,$0003,$0001

end.masks
	dc.w	$8000,$c000,$e000,$f000
	dc.w	$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0
	dc.w	$fff8,$fffc,$fffe,$ffff



COURSE.SPEED	equ	2000

update.course.position
	lea	course.information(pc),a0
	move.l	course.position(pc),d0
	add.l	#COURSE.SPEED,d0	update position
	move.l	d0,d1
	lsl.l	#4,d1
	swap	d1
	andi.w	#$fffc,d1		longword offset
	add.w	d1,a0
	cmpa.l	#end.of.course.information,a0
	bne.s	not.end.of.course

	subi.l	#COURSE.LENGTH*16384,d0	reset to start of course

not.end.of.course
	move.l	d0,course.position
	rts



course.information
	dc.w	0,0			bend value, hill value
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	0,0
	dc.w	0,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	-4,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,4
	dc.w	0,4
	dc.w	0,4
	dc.w	0,4
	dc.w	5,0
	dc.w	5,0
	dc.w	5,0
	dc.w	5,0
	dc.w	5,-4
	dc.w	5,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	-5,0
	dc.w	-5,0
	dc.w	-5,0
	dc.w	-5,0
	dc.w	-5,4
	dc.w	-5,4
	dc.w	0,4
	dc.w	0,4
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	-6,0
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,0
	dc.w	0,0
	dc.w	0,4
	dc.w	0,4
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,4
	dc.w	0,4
	dc.w	0,4
	dc.w	0,4
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,-4
	dc.w	0,0
	dc.w	0,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
	dc.w	9,0
end.of.course.information

COURSE.LENGTH	equ	(end.of.course.information-course.information)/4



track.bends.and.hills
	lea	course.information(pc),a0
	lea	track.real.world.widths(pc),a1
	lea	track.real.world.heights(pc),a2
	lea	new.track.bends.and.heights(pc),a3
	lea	end.of.course.information(pc),a4
	move.l	course.position(pc),d0
	move.w	d0,d1
	rol.w	#6,d1
	andi.w	#$f,d1			get low four bits
	moveq	#$f,d2
	sub.w	d1,d2
	move.w	d2,first.section.count
	addq.w	#1,d1
	move.w	d1,last.section.count
	lsl.l	#4,d0
	swap	d0
	andi.w	#$fffc,d0		longword offset
	add.w	d0,a0			start address for track info

	moveq	#0,d0			zero initial bend increment
	moveq	#0,d1			zero initial bend value
	moveq	#0,d2			zero initial hill increment
	moveq	#0,d3			zero initial hill value
	move.w	#196,d7			maximum height + 1

	tst.w	first.section.count
	beq.s	main.nine.sections	skip first section if necessary

	move.w	(a0),d4			bend value
	ext.l	d4
	move.w	2(a0),d5		hill value

first.section
	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.1
	move.w	d6,d7			get height if it has reduced
not.reduced.1
	subq.w	#1,first.section.count
	bne.s	first.section

main.nine.sections
	addq.w	#4,a0			next track info
	move.w	#7,main.section.count	7 main sections

main.sections.loop
	cmp.l	a4,a0			check for end of course
	bne.s	not.end.of.course.2

	lea	course.information(pc),a0

not.end.of.course.2
	move.w	(a0)+,d4		next bend value
	ext.l	d4
	move.w	(a0)+,d5		next hill value

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.2
	move.w	d6,d7			get height if it has reduced
not.reduced.2

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.3
	move.w	d6,d7			get height if it has reduced
not.reduced.3

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.4
	move.w	d6,d7			get height if it has reduced
not.reduced.4

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.5
	move.w	d6,d7			get height if it has reduced
not.reduced.5

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.6
	move.w	d6,d7			get height if it has reduced
not.reduced.6

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.7
	move.w	d6,d7			get height if it has reduced
not.reduced.7

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.8
	move.w	d6,d7			get height if it has reduced
not.reduced.8

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.9
	move.w	d6,d7			get height if it has reduced
not.reduced.9

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.10
	move.w	d6,d7			get height if it has reduced
not.reduced.10

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.11
	move.w	d6,d7			get height if it has reduced
not.reduced.11

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.12
	move.w	d6,d7			get height if it has reduced
not.reduced.12

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.13
	move.w	d6,d7			get height if it has reduced
not.reduced.13

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.14
	move.w	d6,d7			get height if it has reduced
not.reduced.14

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.15
	move.w	d6,d7			get height if it has reduced
not.reduced.15

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc.s	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.16
	move.w	d6,d7			get height if it has reduced
not.reduced.16

	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc.s	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.17
	move.w	d6,d7			get height if it has reduced
not.reduced.17
	subq.w	#1,main.section.count
	bne	main.sections.loop

	cmp.l	a4,a0			check for end of course
	bne.s	not.end.of.course.3

	lea	course.information(pc),a0

not.end.of.course.3
	move.w	(a0)+,d4		next bend value
	ext.l	d4
	move.w	(a0)+,d5		next hill value

last.section
	add.l	d4,d0			increase bend increment
	add.w	d5,d2			increase hill increment

	add.l	d0,d1			old bend value + increment
	add.w	d2,d3			old hill value + increment

	move.l	d1,(a3)+		save bend value

	move.w	d3,d6			hill value
	muls	(a1)+,d6		* track width
	swap	d6			/ 65536
	add.w	(a2)+,d6		+ track height
	move.w	d6,(a3)+		save height value

	cmpi.w	#196,d6
	bcc.s	out.of.range		quit if height is off screen

	cmp.w	d7,d6
	bcc.s	not.reduced.18
	move.w	d6,d7			get height if it has reduced
not.reduced.18
	subq.w	#1,last.section.count
	bne.s	last.section

	move.w	#128,d0			maximum number of real world lines
	bra.s	end.bends.and.hills


out.of.range
	bpl.s	not.negative
	moveq	#0,d7			height is negative, set minimum to 0
	clr.w	-2(a3)			set last height to 0
	move.l	a3,d0
	subi.l	#new.track.bends.and.heights,d0
	divu	#6,d0			number of lines
	bra.s	end.bends.and.hills

not.negative
	move.l	a3,d0			height is over maximum
	subi.l	#new.track.bends.and.heights,d0
	divu	#6,d0			number of lines
	subq.w	#1,d0			last values not wanted
end.bends.and.hills
	move.w	d0,real.world.line.count
	move.w	d7,track.y.start

	move.w	#195,new.track.bends.and.heights+4   set maximum start height
	rts


track.real.world.widths
	dc.w	4096,3292,2752,2365,2072,1845,1662,1512,1387,1281,1190,1112
	dc.w	1042,981,927,879,835,795,759,727,696,669,643,619
	dc.w	597,577,558,540,523,507,492,478,465,452,440,429
	dc.w	418,408,399,389,381,372,364,356,349,342,335,328
	dc.w	322,316,310,305,299,294,289,284,279,275,270,266
	dc.w	262,258,254,250,246,243,239,236,233,230,226,223
	dc.w	221,218,215,212,210,207,204,202,200,197,195,193
	dc.w	190,188,186,184,182,180,178,176,175,173,171,169
	dc.w	168,166,164,163,161,160,158,157,155,154,152,151
	dc.w	150,148,147,146,145,143,142,141,140,139,137,136
	dc.w	135,134,133,132,131,130,129,128

track.real.world.heights
	dc.w	195,179,168,160,154,149,146,143,140,138,136,135
	dc.w	133,132,131,130,129,128,127,127,126,126,125,125
	dc.w	124,124,123,123,123,122,122,122,121,121,121,121
	dc.w	120,120,120,120,120,120,119,119,119,119,119,119
	dc.w	119,118,118,118,118,118,118,118,118,118,117,117
	dc.w	117,117,117,117,117,117,117,117,117,117,117,117
	dc.w	116,116,116,116,116,116,116,116,116,116,116,116
	dc.w	116,116,116,116,116,116,116,116,116,116,115,115
	dc.w	115,115,115,115,115,115,115,115,115,115,115,115
	dc.w	115,115,115,115,115,115,115,115,115,115,115,115
	dc.w	115,115,115,115,115,115,115,115

new.track.bends.and.heights
	ds.w	128*3			128 real world lines

course.position
	dc.l	0

first.section.count
	dc.w	0

main.section.count
	dc.w	0

last.section.count
	dc.w	0

real.world.line.count
	dc.w	0



make.screen.track
	lea	new.track.bends.and.heights(pc),a0
	lea	screen.track.bends.and.widths(pc),a1
	lea	track.real.world.widths(pc),a2
	lea	width.increments(pc),a3
	move.w	real.world.line.count(pc),d0
	move.w	d0,d7
	subq.w	#1,d7			count

	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,a2			start at end of width list
	add.w	d0,d1
	add.w	d1,d1
	add.w	d1,a0			start at end of bend and height list

	move.w	-(a0),d1		get first height value

	move.w	-(a2),d0		get first width value

	move.w	d1,d2
	add.w	d2,d2
	add.w	d1,d2
	add.w	d2,d2
	add.w	d2,a1			start address for destination

	moveq	#-1,d6			comparison value

make.screen.track.loop
	move.l	-(a0),d2		next (or first) bend value
	move.w	-(a0),d5		next height value

	move.w	-(a2),d4		next width value

	cmp.w	d5,d1			see if height has changed
	bne.s	height.change

	move.w	d4,d0			update width value
	bra.s	next.world.line

height.change
	sub.w	d5,d1			old height - new height
	cmp.w	d6,d1			has it changed by only one ?
	beq.s	change.of.1
	bmi.s	change.of.more.than.1
	add.w	d1,d1			now know heights are reducing
	sub.w	d1,a1			so go back this many steps
	add.w	d1,d1
	sub.w	d1,a1
	bra.s	update.width.and.height

change.of.more.than.1
	neg.w	d1			make difference positive
	move.w	d4,d3			new width value
	sub.w	d0,d3			minus old width, => width difference
	andi.w	#$fff0,d3		multiple of 16
	add.w	d1,d3			+ y difference
	add.w	d3,d3
	add.w	d3,d3			longword offset
	move.l	(a3,d3.w),d3		get increment value from table
	move.l	-4(a0),d6		next bend value
	sub.l	d2,d6			minus current bend value
	divs	d1,d6			bend increment
	ext.l	d6
	subq.w	#2,d1			count
	ext.l	d0
fill.in.values
	move.l	d2,(a1)+		save bend value
	move.w	d0,(a1)+		save width value

	swap	d0
	add.l	d3,d0			increase width value
	swap	d0

	add.l	d6,d2			increase bend value

	dbra	d1,fill.in.values

	moveq	#-1,d6			restore comparison value

change.of.1
	move.l	d2,(a1)+		save bend value
	move.w	d0,(a1)+		save width value

update.width.and.height
	move.w	d4,d0			update width
	move.w	d5,d1			update height

next.world.line
	subq.w	#1,d7
	bne.s	make.screen.track.loop

	move.l	d2,(a1)+		save bend value
	move.w	track.real.world.widths(pc),(a1)     save maximum start width
	rts



width.increments
;
;	Calculation of Values.
;      """"""""""""""""""""""""
;  There are sets of values for each of the real world width differences
;  from 0 to (4096-3292).  There are sets from 0 to 50 because (4096-3292)/16
;  = 50.
;
;  For set 1 the values were calculated as follows :-
;
;  0, 0, (1*16*65536)/2, (1*16*65536)/3
;  (1*16*65536)/4, (1*16*65536)/5, etc.
;		|		|
;		 \_____________/
;			|
;		  height changes
;
;
;  And for set 2 the values were calculated as follows :-
;
;  0, 0, (2*16*65536)/2, (2*16*65536)/3
;  (2*16*65536)/4, (2*16*65536)/5, etc.
;   |
;  set number
;
;
;  All values are stored in hex.
;
;		 ______________________
;		| |		       \
	dc.l	0,0,0,0			first two values are not used
	dc.l	0,0,0,0			( for height change of 0 and 1)
	dc.l	0,0,0,0
	dc.l	0,0,0,0			they are therefore used as values
;					for height change of 16 and 17,
	dc.l	0,0,$80000,$55555	for the previous set of values
	dc.l	$40000,$33333,$2aaaa,$24924
	dc.l	$20000,$1c71c,$19999,$1745d
	dc.l	$15555,$13b13,$12492,$11111

	dc.l	$10000,$f0f0		- for previous set
	dc.l	$100000,$aaaaa
	dc.l	$80000,$66666,$55555,$49249
	dc.l	$40000,$38e38,$33333,$2e8ba
	dc.l	$2aaaa,$27627,$24924,$22222

	dc.l	$20000,$1e1e1
	dc.l	$180000,$100000
	dc.l	$c0000,$99999,$80000,$6db6d
	dc.l	$60000,$55555,$4cccc,$45d17
	dc.l	$40000,$3b13b,$36db6,$33333

	dc.l	$30000,$2d2d2
	dc.l	$200000,$155555
	dc.l	$100000,$ccccc,$aaaaa,$92492
	dc.l	$80000,$71c71,$66666,$5d174
	dc.l	$55555,$4ec4e,$49249,$44444

	dc.l	$40000,$3c3c3
	dc.l	$280000,$1aaaaa
	dc.l	$140000,$100000,$d5555,$b6db6
	dc.l	$a0000,$8e38e,$80000,$745d1
	dc.l	$6aaaa,$62762,$5b6db,$55555

	dc.l	$50000,$4b4b4
	dc.l	$300000,$200000
	dc.l	$180000,$133333,$100000,$db6db
	dc.l	$c0000,$aaaaa,$99999,$8ba2e
	dc.l	$80000,$76276,$6db6d,$66666

	dc.l	$60000,$5a5a5
	dc.l	$380000,$255555
	dc.l	$1c0000,$166666,$12aaaa,$100000
	dc.l	$e0000,$c71c7,$b3333,$a2e8b
	dc.l	$95555,$89d89,$80000,$77777

	dc.l	$70000,$69696
	dc.l	$400000,$2aaaaa
	dc.l	$200000,$199999,$155555,$124924
	dc.l	$100000,$e38e3,$ccccc,$ba2e8
	dc.l	$aaaaa,$9d89d,$92492,$88888

	dc.l	$80000,$78787
	dc.l	$480000,$300000
	dc.l	$240000,$1ccccc,$180000,$149249
	dc.l	$120000,$100000,$e6666,$d1745
	dc.l	$c0000,$b13b1,$a4924,$99999

	dc.l	$90000,$87878
	dc.l	$500000,$355555
	dc.l	$280000,$200000,$1aaaaa,$16db6d
	dc.l	$140000,$11c71c,$100000,$e8ba2
	dc.l	$d5555,$c4ec4,$b6db6,$aaaaa

	dc.l	$a0000,$96969
	dc.l	$580000,$3aaaaa
	dc.l	$2c0000,$233333,$1d5555,$192492
	dc.l	$160000,$138e38,$119999,$100000
	dc.l	$eaaaa,$d89d8,$c9249,$bbbbb

	dc.l	$b0000,$a5a5a
	dc.l	$600000,$400000
	dc.l	$300000,$266666,$200000,$1b6db6
	dc.l	$180000,$155555,$133333,$11745d
	dc.l	$100000,$ec4ec,$db6db,$ccccc

	dc.l	$c0000,$b4b4b
	dc.l	$680000,$455555
	dc.l	$340000,$299999,$22aaaa,$1db6db
	dc.l	$1a0000,$171c71,$14cccc,$12e8ba
	dc.l	$115555,$100000,$edb6d,$ddddd

	dc.l	$d0000,$c3c3c
	dc.l	$700000,$4aaaaa
	dc.l	$380000,$2ccccc,$255555,$200000
	dc.l	$1c0000,$18e38e,$166666,$145d17
	dc.l	$12aaaa,$113b13,$100000,$eeeee

	dc.l	$e0000,$d2d2d
	dc.l	$780000,$500000
	dc.l	$3c0000,$300000,$280000,$224924
	dc.l	$1e0000,$1aaaaa,$180000,$15d174
	dc.l	$140000,$127627,$112492,$100000

	dc.l	$f0000,$e1e1e
	dc.l	$800000,$555555
	dc.l	$400000,$333333,$2aaaaa,$249249
	dc.l	$200000,$1c71c7,$199999,$1745d1
	dc.l	$155555,$13b13b,$124924,$111111

	dc.l	$100000,$f0f0f
	dc.l	$880000,$5aaaaa
	dc.l	$440000,$366666,$2d5555,$26db6d
	dc.l	$220000,$1e38e3,$1b3333,$18ba2e
	dc.l	$16aaaa,$14ec4e,$136db6,$122222

	dc.l	$110000,$100000
	dc.l	$900000,$600000
	dc.l	$480000,$399999,$300000,$292492
	dc.l	$240000,$200000,$1ccccc,$1a2e8b
	dc.l	$180000,$162762,$149249,$133333

	dc.l	$120000,$10f0f0
	dc.l	$980000,$655555
	dc.l	$4c0000,$3ccccc,$32aaaa,$2b6db6
	dc.l	$260000,$21c71c,$1e6666,$1ba2e8
	dc.l	$195555,$176276,$15b6db,$144444

	dc.l	$130000,$11e1e1
	dc.l	$a00000,$6aaaaa
	dc.l	$500000,$400000,$355555,$2db6db
	dc.l	$280000,$238e38,$200000,$1d1745
	dc.l	$1aaaaa,$189d89,$16db6d,$155555

	dc.l	$140000,$12d2d2
	dc.l	$a80000,$700000
	dc.l	$540000,$433333,$380000,$300000
	dc.l	$2a0000,$255555,$219999,$1e8ba2
	dc.l	$1c0000,$19d89d,$180000,$166666

	dc.l	$150000,$13c3c3
	dc.l	$b00000,$755555
	dc.l	$580000,$466666,$3aaaaa,$324924
	dc.l	$2c0000,$271c71,$233333,$200000
	dc.l	$1d5555,$1b13b1,$192492,$177777

	dc.l	$160000,$14b4b4
	dc.l	$b80000,$7aaaaa
	dc.l	$5c0000,$499999,$3d5555,$349249
	dc.l	$2e0000,$28e38e,$24cccc,$21745d
	dc.l	$1eaaaa,$1c4ec4,$1a4924,$188888

	dc.l	$170000,$15a5a5
	dc.l	$c00000,$800000
	dc.l	$600000,$4ccccc,$400000,$36db6d
	dc.l	$300000,$2aaaaa,$266666,$22e8ba
	dc.l	$200000,$1d89d8,$1b6db6,$199999

	dc.l	$180000,$169696
	dc.l	$c80000,$855555
	dc.l	$640000,$500000,$42aaaa,$392492
	dc.l	$320000,$2c71c7,$280000,$245d17
	dc.l	$215555,$1ec4ec,$1c9249,$1aaaaa

	dc.l	$190000,$178787
	dc.l	$d00000,$8aaaaa
	dc.l	$680000,$533333,$455555,$3b6db6
	dc.l	$340000,$2e38e3,$299999,$25d174
	dc.l	$22aaaa,$200000,$1db6db,$1bbbbb

	dc.l	$1a0000,$187878
	dc.l	$d80000,$900000
	dc.l	$6c0000,$566666,$480000,$3db6db
	dc.l	$360000,$300000,$2b3333,$2745d1
	dc.l	$240000,$213b13,$1edb6d,$1ccccc

	dc.l	$1b0000,$196969
	dc.l	$e00000,$955555
	dc.l	$700000,$599999,$4aaaaa,$400000
	dc.l	$380000,$31c71c,$2ccccc,$28ba2e
	dc.l	$255555,$227627,$200000,$1ddddd

	dc.l	$1c0000,$1a5a5a
	dc.l	$e80000,$9aaaaa
	dc.l	$740000,$5ccccc,$4d5555,$424924
	dc.l	$3a0000,$338e38,$2e6666,$2a2e8b
	dc.l	$26aaaa,$23b13b,$212492,$1eeeee

	dc.l	$1d0000,$1b4b4b
	dc.l	$f00000,$a00000
	dc.l	$780000,$600000,$500000,$449249
	dc.l	$3c0000,$355555,$300000,$2ba2e8
	dc.l	$280000,$24ec4e,$224924,$200000

	dc.l	$1e0000,$1c3c3c
	dc.l	$f80000,$a55555
	dc.l	$7c0000,$633333,$52aaaa,$46db6d
	dc.l	$3e0000,$371c71,$319999,$2d1745
	dc.l	$295555,$262762,$236db6,$211111

	dc.l	$1f0000,$1d2d2d
	dc.l	$1000000,$aaaaaa
	dc.l	$800000,$666666,$555555,$492492
	dc.l	$400000,$38e38e,$333333,$2e8ba2
	dc.l	$2aaaaa,$276276,$249249,$222222

	dc.l	$200000,$1e1e1e
	dc.l	$1080000,$b00000
	dc.l	$840000,$699999,$580000,$4b6db6
	dc.l	$420000,$3aaaaa,$34cccc,$300000
	dc.l	$2c0000,$289d89,$25b6db,$233333

	dc.l	$210000,$1f0f0f
	dc.l	$1100000,$b55555
	dc.l	$880000,$6ccccc,$5aaaaa,$4db6db
	dc.l	$440000,$3c71c7,$366666,$31745d
	dc.l	$2d5555,$29d89d,$26db6d,$244444

	dc.l	$220000,$200000
	dc.l	$1180000,$baaaaa
	dc.l	$8c0000,$700000,$5d5555,$500000
	dc.l	$460000,$3e38e3,$380000,$32e8ba
	dc.l	$2eaaaa,$2b13b1,$280000,$255555

	dc.l	$230000,$20f0f0
	dc.l	$1200000,$c00000
	dc.l	$900000,$733333,$600000,$524924
	dc.l	$480000,$400000,$399999,$345d17
	dc.l	$300000,$2c4ec4,$292492,$266666

	dc.l	$240000,$21e1e1
	dc.l	$1280000,$c55555
	dc.l	$940000,$766666,$62aaaa,$549249
	dc.l	$4a0000,$41c71c,$3b3333,$35d174
	dc.l	$315555,$2d89d8,$2a4924,$277777

	dc.l	$250000,$22d2d2
	dc.l	$1300000,$caaaaa
	dc.l	$980000,$799999,$655555,$56db6d
	dc.l	$4c0000,$438e38,$3ccccc,$3745d1
	dc.l	$32aaaa,$2ec4ec,$2b6db6,$288888

	dc.l	$260000,$23c3c3
	dc.l	$1380000,$d00000
	dc.l	$9c0000,$7ccccc,$680000,$592492
	dc.l	$4e0000,$455555,$3e6666,$38ba2e
	dc.l	$340000,$300000,$2c9249,$299999

	dc.l	$270000,$24b4b4
	dc.l	$1400000,$d55555
	dc.l	$a00000,$800000,$6aaaaa,$5b6db6
	dc.l	$500000,$471c71,$400000,$3a2e8b
	dc.l	$355555,$313b13,$2db6db,$2aaaaa

	dc.l	$280000,$25a5a5
	dc.l	$1480000,$daaaaa
	dc.l	$a40000,$833333,$6d5555,$5db6db
	dc.l	$520000,$48e38e,$419999,$3ba2e8
	dc.l	$36aaaa,$327627,$2edb6d,$2bbbbb

	dc.l	$290000,$269696
	dc.l	$1500000,$e00000
	dc.l	$a80000,$866666,$700000,$600000
	dc.l	$540000,$4aaaaa,$433333,$3d1745
	dc.l	$380000,$33b13b,$300000,$2ccccc

	dc.l	$2a0000,$278787
	dc.l	$1580000,$e55555
	dc.l	$ac0000,$899999,$72aaaa,$624924
	dc.l	$560000,$4c71c7,$44cccc,$3e8ba2
	dc.l	$395555,$34ec4e,$312492,$2ddddd

	dc.l	$2b0000,$287878
	dc.l	$1600000,$eaaaaa
	dc.l	$b00000,$8ccccc,$755555,$649249
	dc.l	$580000,$4e38e3,$466666,$400000
	dc.l	$3aaaaa,$362762,$324924,$2eeeee

	dc.l	$2c0000,$296969
	dc.l	$1680000,$f00000
	dc.l	$b40000,$900000,$780000,$66db6d
	dc.l	$5a0000,$500000,$480000,$41745d
	dc.l	$3c0000,$376276,$336db6,$300000

	dc.l	$2d0000,$2a5a5a
	dc.l	$1700000,$f55555
	dc.l	$b80000,$933333,$7aaaaa,$692492
	dc.l	$5c0000,$51c71c,$499999,$42e8ba
	dc.l	$3d5555,$389d89,$349249,$311111

	dc.l	$2e0000,$2b4b4b
	dc.l	$1780000,$faaaaa
	dc.l	$bc0000,$966666,$7d5555,$6b6db6
	dc.l	$5e0000,$538e38,$4b3333,$445d17
	dc.l	$3eaaaa,$39d89d,$35b6db,$322222

	dc.l	$2f0000,$2c3c3c
	dc.l	$1800000,$1000000
	dc.l	$c00000,$999999,$800000,$6db6db
	dc.l	$600000,$555555,$4ccccc,$45d174
	dc.l	$400000,$3b13b1,$36db6d,$333333

	dc.l	$300000,$2d2d2d
	dc.l	$1880000,$1055555
	dc.l	$c40000,$9ccccc,$82aaaa,$700000
	dc.l	$620000,$571c71,$4e6666,$4745d1
	dc.l	$415555,$3c4ec4,$380000,$344444

	dc.l	$310000,$2e1e1e
	dc.l	$1900000,$10aaaaa
	dc.l	$c80000,$a00000,$855555,$724924
	dc.l	$640000,$58e38e,$500000,$48ba2e
	dc.l	$42aaaa,$3d89d8,$392492,$355555

	dc.l	$320000,$2f0f0f



draw.track
	move.l	screen1(pc),a0
	move.w	track.y.start(pc),d0
	move.w	d0,d1
	add.w	d1,d1
	lea	y.table(pc),a1
	add.w	(a1,d1.w),a0		start address for screen

	lea	track.data.ptrs(pc),a1
	lea	screen.track.bends.and.widths(pc),a2
	add.w	d0,d1
	add.w	d1,d1
	add.w	d1,a2			start address

	move.w	track.shear.value(pc),d1
	ext.l	d1

	lea	overflow.correction.values.1(pc),a4
	lea	overflow.correction.values.2(pc),a5

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	#0,bltcon1(a6)		set up constant values
	move.l	#$ffffffff,bltafwm(a6)
	move.w	#9467*2-21*2,bltamod(a6)
	move.w	#0,bltdmod(a6)

draw.track.loop
	moveq	#0,d6

	move.l	(a2)+,d2		get bend value
	add.l	d1,d2			bend value + shear value
	move.w	(a2)+,d3		get real world width value

	move.w	d3,d4
	lsr.w	#2,d4			get the track line to draw
	andi.w	#$fffc,d4		longword offset
	move.l	(a1,d4.w),a3		get data pointer

check.overflow
	cmpi.l	#32768,d2		is value too big for a word ?
	bmi.s	not.too.positive

	subi.l	#32767,d2
	move.w	d3,d4			real world width
	moveq	#$3f,d5
	and.w	d4,d5			get low 6 bits (0-63)
	sub.w	d5,d4			mask off low 6 bits
	lsr.w	#4,d4			longword offset
	add.l	(a5,d4.w),d6
	add.w	d5,d5
	add.w	d5,d5			longword offset
	add.l	(a4,d5.w),d6
	bra.s	check.overflow

not.too.positive
	cmpi.l	#-32767,d2		is value too big for a word ?
	bpl.s	not.too.negative

	addi.l	#32767,d2
	move.w	d3,d4			real world width
	moveq	#$3f,d5
	and.w	d4,d5			get low 6 bits (0-63)
	sub.w	d5,d4			mask off low 6 bits
	lsr.w	#4,d4			longword offset
	sub.l	(a5,d4.w),d6
	add.w	d5,d5
	add.w	d5,d5			longword offset
	sub.l	(a4,d5.w),d6
	bra.s	not.too.positive

not.too.negative
	move.w	d3,d4
	add.w	d4,d4			2 real world width
	muls	d4,d2			* 2 real world width
	add.l	d6,d2			+ overflow part
	swap	d2			/ 65536

	move.w	d3,d4
	lsr.w	#4,d4			actual width / 2
	addi.w	#21*16-320/2,d4		centering value
	add.w	d4,d2			scroll value

	cmpi.w	#1,d2
	bpl.s	scroll.value.positive
	moveq	#16,d2			if scroll value is zero or less

scroll.value.positive
	lsr.w	#3,d3			actual width
	addi.w	#21*16,d3		21 words before track data
	cmp.w	d2,d3
	bpl.s	scroll.value.ok
	move.w	d3,d2			if scroll value is too large

scroll.value.ok
	moveq	#$f,d3
	and.w	d2,d3			low four bits from offset
	bne.s	no.word.change
	subi.w	#16,d2
no.word.change
	sub.w	d3,d2			offset in multiples of 16 bits
	lsr.w	#3,d2			offset in even bytes
	add.w	d2,a3			start address for data
	add.w	d3,d3

	move.w	bltcon0.values(pc,d3.w),bltcon0(a6)
	move.l	a3,bltapth(a6)
	move.l	a0,bltdpth(a6)
	move.w	#2*64+21,bltsize(a6)

	adda.w	#168,a0			next line
	addq.w	#1,d0
	cmpi.w	#196,d0
	bne	draw.track.loop
	rts


bltcon0.values
	dc.w	$09f0,$f9f0,$e9f0,$d9f0,$c9f0,$b9f0,$a9f0,$99f0
	dc.w	$89f0,$79f0,$69f0,$59f0,$49f0,$39f0,$29f0,$19f0

track.y.start
	dc.w	0

screen.track.bends.and.widths
	ds.w	250*3		     one longword, one word per screen line
				; this is no certain value, just some space

y.table	ds.w	196			one word per screen line

overflow.correction.values.1
	dc.l	0*32767*2,1*32767*2,2*32767*2,3*32767*2,4*32767*2,5*32767*2,6*32767*2,7*32767*2
	dc.l	8*32767*2,9*32767*2,10*32767*2,11*32767*2,12*32767*2,13*32767*2,14*32767*2,15*32767*2
	dc.l	16*32767*2,17*32767*2,18*32767*2,19*32767*2,20*32767*2,21*32767*2,22*32767*2,23*32767*2
	dc.l	24*32767*2,25*32767*2,26*32767*2,27*32767*2,28*32767*2,29*32767*2,30*32767*2,31*32767*2
	dc.l	32*32767*2,33*32767*2,34*32767*2,35*32767*2,36*32767*2,37*32767*2,38*32767*2,39*32767*2
	dc.l	40*32767*2,41*32767*2,42*32767*2,43*32767*2,44*32767*2,45*32767*2,46*32767*2,47*32767*2
	dc.l	48*32767*2,49*32767*2,50*32767*2,51*32767*2,52*32767*2,53*32767*2,54*32767*2,55*32767*2
	dc.l	56*32767*2,57*32767*2,58*32767*2,59*32767*2,60*32767*2,61*32767*2,62*32767*2,63*32767*2

overflow.correction.values.2
	dc.l	0*64*32767*2,1*64*32767*2,2*64*32767*2,3*64*32767*2,4*64*32767*2,5*64*32767*2,6*64*32767*2,7*64*32767*2
	dc.l	8*64*32767*2,9*64*32767*2,10*64*32767*2,11*64*32767*2,12*64*32767*2,13*64*32767*2,14*64*32767*2,15*64*32767*2
	dc.l	16*64*32767*2,17*64*32767*2,18*64*32767*2,19*64*32767*2,20*64*32767*2,21*64*32767*2,22*64*32767*2,23*64*32767*2
	dc.l	24*64*32767*2,25*64*32767*2,26*64*32767*2,27*64*32767*2,28*64*32767*2,29*64*32767*2,30*64*32767*2,31*64*32767*2
	dc.l	32*64*32767*2,33*64*32767*2,34*64*32767*2,35*64*32767*2,36*64*32767*2,37*64*32767*2,38*64*32767*2,39*64*32767*2
	dc.l	40*64*32767*2,41*64*32767*2,42*64*32767*2,43*64*32767*2,44*64*32767*2,45*64*32767*2,46*64*32767*2,47*64*32767*2
	dc.l	48*64*32767*2,49*64*32767*2,50*64*32767*2,51*64*32767*2,52*64*32767*2,53*64*32767*2,54*64*32767*2,55*64*32767*2
	dc.l	56*64*32767*2,57*64*32767*2,58*64*32767*2,59*64*32767*2,60*64*32767*2,61*64*32767*2,62*64*32767*2,63*64*32767*2
	dc.l	64*64*32767*2



SHEAR.MIN	equ	-384*8
SHEAR.MAX	equ	384*8
SHEAR.SPEED	equ	8*8

shear.track
	move.w	joy1dat(a6),d0
	btst	#1,d0			joystick right
	beq.s	try.left
	cmpi.w	#SHEAR.MAX,track.shear.value
	bge.s	no.shear
	addi.w	#SHEAR.SPEED,track.shear.value
	rts

try.left
	btst	#9,d0			joystick left
	beq.s	no.shear
	cmpi.w	#SHEAR.MIN,track.shear.value
	ble.s	no.shear
	subi.w	#SHEAR.SPEED,track.shear.value
no.shear
	rts


track.shear.value	dc.w	0



clear	move.w	third.old.track.y.start(pc),d0
	move.w	d0,d1
	move.w	track.y.start(pc),d2
	move.w	second.old.track.y.start(pc),third.old.track.y.start
	move.w	first.old.track.y.start(pc),second.old.track.y.start
	move.w	d2,first.old.track.y.start
	sub.w	d2,d1			old y - new y
	bpl.s	no.clear

	move.l	screen1(pc),a0
	add.w	d0,d0
	lea	y.table(pc),a1
	add.w	(a1,d0.w),a0
	addq.l	#2,a0			start address
	move.w	#2*40+3*2,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	a0,bltdpth(a6)
	neg.w	d1			positive difference
	lsl.w	#6,d1			height * 64
	addi.w	#41,d1			width = 20+1+20 = 41 words
	move.w	d1,bltsize(a6)
no.clear
	rts


first.old.track.y.start
	dc.w	195


second.old.track.y.start
	dc.w	195


third.old.track.y.start
	dc.w	195



;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

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
	moveq	#0,d1			y
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

	dc.w	$ae01,$ff00
	dc.w	color3,$eee

	dc.w	$af01,$ff00
	dc.w	color3,$555

	dc.w	$b001,$ff00
	dc.w	color3,$eee

	dc.w	$b101,$ff00
	dc.w	color3,$555

	dc.w	$b301,$ff00
	dc.w	color3,$eee

	dc.w	$b501,$ff00
	dc.w	color3,$555

	dc.w	$b801,$ff00
	dc.w	color3,$eee

	dc.w	$bc01,$ff00
	dc.w	color3,$555

	dc.w	$c001,$ff00
	dc.w	color3,$eee

	dc.w	$c901,$ff00
	dc.w	color3,$555

	dc.w	$d001,$ff00
	dc.w	color3,$eee

	dc.w	$df01,$ff00
	dc.w	color3,$555

	dc.w	$ea01,$ff00
	dc.w	color3,$eee

	dc.w	$fe01,$ff00

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

	dc.w	$ae01,$ff00
	dc.w	color3,$eee

	dc.w	$af01,$ff00
	dc.w	color3,$555

	dc.w	$b001,$ff00
	dc.w	color3,$eee

	dc.w	$b101,$ff00
	dc.w	color3,$555

	dc.w	$b301,$ff00
	dc.w	color3,$eee

	dc.w	$b501,$ff00
	dc.w	color3,$555

	dc.w	$b801,$ff00
	dc.w	color3,$eee

	dc.w	$bc01,$ff00
	dc.w	color3,$555

	dc.w	$c001,$ff00
	dc.w	color3,$eee

	dc.w	$c901,$ff00
	dc.w	color3,$555

	dc.w	$d001,$ff00
	dc.w	color3,$eee

	dc.w	$df01,$ff00
	dc.w	color3,$555

	dc.w	$ea01,$ff00
	dc.w	color3,$eee

	dc.w	$fe01,$ff00

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

	dc.w	$ae01,$ff00
	dc.w	color3,$eee

	dc.w	$af01,$ff00
	dc.w	color3,$555

	dc.w	$b001,$ff00
	dc.w	color3,$eee

	dc.w	$b101,$ff00
	dc.w	color3,$555

	dc.w	$b301,$ff00
	dc.w	color3,$eee

	dc.w	$b501,$ff00
	dc.w	color3,$555

	dc.w	$b801,$ff00
	dc.w	color3,$eee

	dc.w	$bc01,$ff00
	dc.w	color3,$555

	dc.w	$c001,$ff00
	dc.w	color3,$eee

	dc.w	$c901,$ff00
	dc.w	color3,$555

	dc.w	$d001,$ff00
	dc.w	color3,$eee

	dc.w	$df01,$ff00
	dc.w	color3,$555

	dc.w	$ea01,$ff00
	dc.w	color3,$eee

	dc.w	$fe01,$ff00

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

coltab	dc.w	$000,$555,$333,$eee,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff

track.data.plane.1			; actual space for data
	ds.w	9467			size was found using calculator
track.data.plane.2
	ds.w	9467
