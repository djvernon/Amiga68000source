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

	dc.w	$180,$0
	dc.w	$1809,$fffe
	dc.w	$180,$100
	dc.w	$1c09,$fffe
	dc.w	$180,$200
	dc.w	$2009,$fffe
	dc.w	$180,$300
	dc.w	$2409,$fffe
	dc.w	$180,$400
	dc.w	$2809,$fffe
	dc.w	$180,$500
	dc.w	$2c09,$fffe
	dc.w	$180,$600
	dc.w	$3009,$fffe
	dc.w	$180,$700
	dc.w	$3409,$fffe
	dc.w	$180,$800
	dc.w	$3809,$fffe
	dc.w	$180,$900
	dc.w	$3c09,$fffe
	dc.w	$180,$a00
	dc.w	$4009,$fffe
	dc.w	$180,$b00
	dc.w	$4409,$fffe
	dc.w	$180,$c00
	dc.w	$4809,$fffe
	dc.w	$180,$d00
	dc.w	$4c09,$fffe
	dc.w	$180,$e20
	dc.w	$5009,$fffe
	dc.w	$180,$f30
	dc.w	$5409,$fffe
	dc.w	$180,$f40
	dc.w	$5809,$fffe
	dc.w	$180,$f50
	dc.w	$5c09,$fffe
	dc.w	$180,$f60
	dc.w	$6009,$fffe
	dc.w	$180,$f70
	dc.w	$6409,$fffe
	dc.w	$180,$f80
	dc.w	$6809,$fffe
	dc.w	$180,$f90
	dc.w	$6c09,$fffe
	dc.w	$180,$fa0
	dc.w	$7009,$fffe
	dc.w	$180,$fb0
	dc.w	$7409,$fffe
	dc.w	$180,$fc0
	dc.w	$7809,$fffe
	dc.w	$180,$fd0
	dc.w	$7c09,$fffe
	dc.w	$180,$fe0
	dc.w	$8009,$fffe
	dc.w	$180,$ff0
	dc.w	$8409,$fffe
	dc.w	$180,$0
	dc.w	$8509,$fffe
	dc.w	$180,$3
	dc.w	$8809,$fffe
	dc.w	$180,$4
	dc.w	$8b09,$fffe
	dc.w	$180,$5
	dc.w	$8e09,$fffe
	dc.w	$180,$6
	dc.w	$9109,$fffe
	dc.w	$180,$7
	dc.w	$9409,$fffe
	dc.w	$180,$8
	dc.w	$9709,$fffe
	dc.w	$180,$9
	dc.w	$9a09,$fffe
	dc.w	$180,$a
	dc.w	$9d09,$fffe
	dc.w	$180,$b
	dc.w	$a009,$fffe
	dc.w	$180,$c
	dc.w	$a309,$fffe
	dc.w	$180,$d
	dc.w	$a609,$fffe
	dc.w	$180,$1e
	dc.w	$a909,$fffe
	dc.w	$180,$2f
	dc.w	$ac09,$fffe
	dc.w	$180,$3f
	dc.w	$af09,$fffe
	dc.w	$180,$4f
	dc.w	$b209,$fffe
	dc.w	$180,$5f
	dc.w	$b509,$fffe
	dc.w	$180,$6f
	dc.w	$b809,$fffe
	dc.w	$180,$7f
	dc.w	$bb09,$fffe
	dc.w	$180,$8f
	dc.w	$be09,$fffe
	dc.w	$180,$9f
	dc.w	$c109,$fffe
	dc.w	$180,$af
	dc.w	$c409,$fffe
	dc.w	$180,$bf
	dc.w	$c709,$fffe
	dc.w	$180,$cf
	dc.w	$ca09,$fffe
	dc.w	$180,$0
	dc.w	$cc09,$fffe
	dc.w	$180,$f0
	dc.w	$cd09,$fffe
	dc.w	$180,$d0
	dc.w	$ce09,$fffe
	dc.w	$180,$b0
	dc.w	$cf09,$fffe
	dc.w	$180,$90
	dc.w	$d009,$fffe
	dc.w	$180,$70
	dc.w	$d109,$fffe
	dc.w	$180,$50
	dc.w	$d209,$fffe
	dc.w	$180,$30
	dc.w	$d309,$fffe
	dc.w	$180,$10
	dc.w	$d409,$fffe
	dc.w	$180,$0
	dc.w	$f709,$fffe
	dc.w	$180,$10
	dc.w	$f809,$fffe
	dc.w	$180,$30
	dc.w	$f909,$fffe
	dc.w	$180,$50
	dc.w	$fa09,$fffe
	dc.w	$180,$70
	dc.w	$fb09,$fffe
	dc.w	$180,$90
	dc.w	$fc09,$fffe
	dc.w	$180,$b0
	dc.w	$fd09,$fffe
	dc.w	$180,$d0
	dc.w	$fe09,$fffe
	dc.w	$180,$f0
	dc.w	$ff09,$fffe
	dc.w	$180,$0

	dc.w	$ffff,$fffe		end of copper list


OLD	dc.l	0


GRAFNAME	dc.b	"graphics.library",0
