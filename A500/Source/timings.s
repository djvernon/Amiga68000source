	move.l	(a3,d1.w),d6

	add.l	d6,d6
	or.l	(a3,d1.w),d6

	move.b	d6,(a0)+
	move.b	(a2,d6.w),(a4)+
	swap	d6
	move.b	d6,(a5)+
	move.b	(a2,d6.w),(a6)+

	move.l	chunky.memory(pc),a0
	rts

chunky.memory	dc.l	0
