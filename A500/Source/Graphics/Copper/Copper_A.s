	section	Copper,code_c
	opt	o+


color0	equ	$180


start	move.l	4.w,a6
	
	lea	GRAFNAME(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	move.l	d0,a1
	move.l	38(a1),OLD

	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

	move.l	#NEW,$dff080	cop1lch

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	OLD,$dff080
	rts


NEW	dc.w	$100,$0200		zero bitplane display

	dc.w	color0,$f
	dc.w	$3209,$fffe
	dc.w	color0,$e
	dc.w	$3809,$fffe
	dc.w	color0,$d
	dc.w	$3e09,$fffe
	dc.w	color0,$c
	dc.w	$4409,$fffe
	dc.w	color0,$b
	dc.w	$4a09,$fffe
	dc.w	color0,$a
	dc.w	$5009,$fffe
	dc.w	color0,$9
	dc.w	$5609,$fffe
	dc.w	color0,$8
	dc.w	$5c09,$fffe
	dc.w	color0,$7
	dc.w	$6209,$fffe
	dc.w	color0,$6
	dc.w	$6809,$fffe
	dc.w	color0,$5
	dc.w	$6e09,$fffe
	dc.w	color0,$4
	dc.w	$7409,$fffe
	dc.w	color0,$3
	dc.w	$7a09,$fffe
	dc.w	color0,$2
	dc.w	$8009,$fffe
	dc.w	color0,$1
	dc.w	$8609,$fffe
	dc.w	color0,$0
	dc.w	$a609,$fffe
	dc.w	color0,$1
	dc.w	$ac09,$fffe
	dc.w	color0,$2
	dc.w	$b209,$fffe
	dc.w	color0,$3
	dc.w	$b809,$fffe
	dc.w	color0,$4
	dc.w	$be09,$fffe
	dc.w	color0,$5
	dc.w	$c409,$fffe
	dc.w	color0,$6
	dc.w	$ca09,$fffe
	dc.w	color0,$7
	dc.w	$d009,$fffe
	dc.w	color0,$8
	dc.w	$d609,$fffe
	dc.w	color0,$9
	dc.w	$dc09,$fffe
	dc.w	color0,$a
	dc.w	$e209,$fffe
	dc.w	color0,$b
	dc.w	$e809,$fffe
	dc.w	color0,$c
	dc.w	$ee09,$fffe
	dc.w	color0,$d
	dc.w	$f409,$fffe
	dc.w	color0,$e
	dc.w	$fa09,$fffe
	dc.w	color0,$f

	dc.w	$ffff,$fffe		end of copper list


OLD	dc.l	0


GRAFNAME	dc.b	"graphics.library",0
