	section	ToChunky,code


	bsr	to.chunky
	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

to.chunky				; 8 bitplane
	lea	chunky.data(pc),a5
	move.w	#0,a2

.long	move.l	plane1.ptr(pc),a0
	move.l	(a0)+,d1
	move.l	a0,plane1.ptr

	move.l	plane2.ptr(pc),a0
	move.l	(a0)+,d2
	move.l	a0,plane2.ptr

	move.l	plane3.ptr(pc),a0
	move.l	(a0)+,d3
	move.l	a0,plane3.ptr

	move.l	plane4.ptr(pc),a0
	move.l	(a0)+,d4
	move.l	a0,plane4.ptr

	move.l	plane5.ptr(pc),a0
	move.l	(a0)+,d5
	move.l	a0,plane5.ptr

	move.l	plane6.ptr(pc),a0
	move.l	(a0)+,d6
	move.l	a0,plane6.ptr

	move.l	plane7.ptr(pc),a0
	move.l	(a0)+,d7
	move.l	a0,plane7.ptr

	move.l	plane8.ptr(pc),a0
	move.l	(a0)+,a1
	move.l	a0,plane8.ptr

	move.w	#0,a3

.bits	moveq	#0,d0
	add.l	d1,d1
	bcc.s	.pl2			plane 1
	addq.w	#1,d0

.pl2	add.l	d2,d2
	bcc.s	.pl3			plane 2
	addq.w	#2,d0

.pl3	add.l	d3,d3
	bcc.s	.pl4			plane 3
	addq.w	#4,d0

.pl4	add.l	d4,d4
	bcc.s	.pl5			plane 4
	addq.w	#8,d0

.pl5	add.l	d5,d5
	bcc.s	.pl6			plane 5
	addi.w	#16,d0

.pl6	add.l	d6,d6
	bcc.s	.pl7			plane 6
	addi.w	#32,d0

.pl7	add.l	d7,d7
	bcc.s	.pl8			plane 7
	addi.w	#64,d0

.pl8	exg	d1,a1
	add.l	d1,d1
	exg	d1,a1
	bcc.s	.done			plane 8
	addi.w	#128,d0

.done	move.b	d0,(a5)+
	addq.w	#1,a3
	cmp.w	#32,a3			bits in longword
	bne.s	.bits

	addq.w	#1,a2
	cmp.w	#2,a2			do two longwords
	bne	.long
	rts


plane1.ptr	dc.l	plane1.data
plane2.ptr	dc.l	plane2.data
plane3.ptr	dc.l	plane3.data
plane4.ptr	dc.l	plane4.data
plane5.ptr	dc.l	plane5.data
plane6.ptr	dc.l	plane6.data
plane7.ptr	dc.l	plane7.data
plane8.ptr	dc.l	plane8.data

plane1.data	dc.l	$7fe00000,$6000109f
plane2.data	dc.l	$fff08014,$0cb8771f
plane3.data	dc.l	$f0cee033,$93457660
plane4.data	dc.l	$00009fd0,$00007700
plane5.data	dc.l	$70c7602f,$e0031480
plane6.data	dc.l	$000f9fdf,$9346fe60
plane7.data	dc.l	$8f386020,$1ffd647f
plane8.data	dc.l	$7ff69fd3,$ecb80a9f

chunky.data	ds.b	64
