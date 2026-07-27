	bra.s	start

	dc.b	' -- Spam & Spam Disk Load v1.0 (C) Random Access 1989 -- ',0

start	move.w	#$7fff,$dff09a
	move.l	4,a0
	cmp.b	#50,530(a0)
	beq.s	freq.ok

freq.bad
	move.w	#$800,$dff180
	bra.s	freq.bad

table	dc.l	$0a30242d,$ffffffff,$0030923c,$00c24884

freq.ok	movem.l	table(pc),d0-d3
	movem.l	d0-d7,$70000

	lea	loader(pc),a0
	lea	$100,a1
	move.w	#256-1,d0

copy	move.l	(a0)+,(a1)+
	dbra	d0,copy

	jsr	$428

loader	incbin	Loader
