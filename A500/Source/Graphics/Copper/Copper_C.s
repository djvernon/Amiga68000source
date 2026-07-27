	section	Copper,code_c
	opt	o+


col	equ	15		starting colour
inc	equ	16		value added to colour each time

	lea	colours,a0	set up copper rainbow
	move.w	#$2809,d0
	move.w	#col,d1		starting colour
	move.w	#215,d2		count-1

cloop	move.w	d0,(a0)+
	move.w	#$fffe,(a0)+
	move.w	#$180,(a0)+
	move.w	d1,(a0)+
	add.w	#$100,d0	update wait position
	add.w	#inc,d1		update colour
	dbra	d2,cloop

	move.l	#$ffdffffe,(a0)+	pal enable
	move.w	#39,d2		count-1

cloop2	move.w	d0,(a0)+
	move.w	#$fffe,(a0)+
	move.w	#$180,(a0)+
	move.w	d1,(a0)+
	add.w	#$100,d0	update wait position
	add.w	#inc,d1		update colour
	dbra	d2,cloop2

	move.l	#$2809fffe,(a0)+
	move.l	#$1800000,(a0)+

	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	move.l	d0,a1
	move.l	38(a1),old

	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

	move.l	#new,$dff080	cop1lc

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	old,$dff080
	rts


new	dc.w	$100,$0200
	dc.w	$180,$0

colours	ds.w	1030

	dc.w	$ffff,$fffe


old	dc.l	0

grafname	dc.b	"graphics.library",0
