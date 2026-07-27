	section	Grass,code
	opt	c+,a+


	include DH0:Devpac/System2.gs


SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	256
SCREEN_DEPTH	equ	1


* Open the intuition library

	moveq	#0,d0
	lea	intuition.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit.false

* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.close.int

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Allocate screen memory

	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.close.dos

* Initialize bitmap

	lea	the.bitmap(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen.memory(pc),a0
	lea	the.bitmap(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Open the screen

	lea	the.new.screen(pc),a0
	CALLINT	OpenScreen
	move.l	d0,the.screen
	beq	exit.free.mem

* Change colours

	move.l	the.screen(pc),a0
	lea	sc_ViewPort(a0),a0
	lea	colour.table(pc),a1
	moveq	#1<<SCREEN_DEPTH,d0	number of colours
	CALLGRAF LoadRGB4

	move.l	the.screen(pc),a1
	lea	sc_RastPort(a1),a1
	move.l	a1,the.screen.RP


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

main	btst	#2,$dff016.l
	bne.s	main

wait	btst	#2,$dff016.l
	beq.s	wait

	move.l	the.screen.RP(pc),a1
	CALLGRAF ClearScreen
	bsr	draw.plant
	bsr	replace.chars

	btst	#6,$bfe001.l
	bne.s	main


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit.close.screen
	move.l	the.screen(pc),a0
	CALLINT	CloseScreen

exit.free.mem
	move.l	screen.memory(pc),a1
	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	CALLEXEC FreeMem

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.int
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

one	dc.b	'11[1[1[1]]]',0
	even
UNIT_LENGTH	equ	6
UNIT_ANGLE	equ	45

TABLE_OFFSET	equ	(UNIT_ANGLE*2048)/360


draw.plant
	move.w	#0,angle.count
	move.w	#160,x
	move.w	#255,y
	move.w	#UNIT_ANGLE,d4
	move.l	plant.chars.ptr(pc),a2

draw.branch
	move.b	(a2)+,d3		get character at current position

draw.branch.select
	cmp.b	#'1',d3			if a '1', draw a segment
	bne.s	check.branch.clockwise
	move.w	x(pc),d0
	move.w	y(pc),d1
	move.l	the.screen.RP(pc),a1
	CALLGRAF Move

	move.w	angle.count(pc),d1
	and.w	#$7fe,d1
	lea	sine(pc),a1
	move.w	(a1,d1.w),d0
	lea	cosine(pc),a1
	move.w	(a1,d1.w),d1
	muls	#UNIT_LENGTH*2,d0
	muls	#UNIT_LENGTH,d1
	add.l	d0,d0
	add.l	d1,d1
	swap	d0
	swap	d1
	add.w	d0,x
	sub.w	d1,y

	move.w	x(pc),d0
	move.w	y(pc),d1
	move.l	the.screen.RP(pc),a1
	CALLGRAF Draw
	bra.s	draw.branch.next

check.branch.clockwise
	cmp.b	#'[',d3			if a '[', branch off
	bne.s	draw.branch.next

	add.w	d4,angle.count

	move.w	x(pc),-(sp)
	move.w	y(pc),-(sp)
	bsr.s	draw.branch
	move.w	(sp)+,y
	move.w	(sp)+,x

draw.branch.next
	move.b	(a2)+,d3
	beq.s	end.draw.branch		if end of plant string

	cmp.b	#']',d3
	bne	draw.branch.select	if not end of branch

	sub.w	d4,angle.count		decrease angle count

end.draw.branch
	rts


replace.chars
	tst.b	replace.no.more
	beq.s	replace.ok
	rts

replace.ok
	tst.b	which.plant.chars
	bne.s	chars2.is.source

	lea	plant.chars1(pc),a2
	lea	plant.chars2.l,a3
	lea	end.chars2.l,a4
	move.l	a3,plant.chars.ptr
	move.l	a2,d7
	bra.s	replace.loop

chars2.is.source
	lea	plant.chars2.l,a2
	lea	plant.chars1(pc),a3
	lea	end.chars1.l,a4
	move.l	a3,plant.chars.ptr
	move.l	a2,d7

replace.loop
	move.b	(a2)+,d2
	beq.s	replace.end

	cmp.b	#'1',d2
	bne.s	no.replace

	lea	one(pc),a5		replace '1' with one
.copy	move.b	(a5)+,d5
	beq.s	replace.loop

	move.b	d5,(a3)+
	cmp.l	a4,a3
	bge.s	replace.final
	bra.s	.copy

no.replace
	move.b	d2,(a3)+		leave character unchanged
	cmp.l	a4,a3
	bge.s	replace.final
	bra.s	replace.loop

replace.end
	move.b	d2,(a3)
	not.b	which.plant.chars
	rts

replace.final
	st	replace.no.more
	move.l	d7,plant.chars.ptr
	rts


x	dc.w	0
y	dc.w	0
angle.count	dc.w	0
plant.chars.ptr	dc.l	plant.chars1
which.plant.chars	dc.b	0
replace.no.more	dc.b	0


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0

screen.memory	dc.l	0
the.screen	dc.l	0
the.screen.RP	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME

screen.title	dc.b	'Dan''s Screen',0
	even


*""""""""""""""""""""""""
*" INTUITION STRUCTURES "
*"			"
*""""""""""""""""""""""""

the.new.screen	dc.w	0,0		left, top
		dc.w	SCREEN_WIDTH,SCREEN_HEIGHT
		dc.w	SCREEN_DEPTH
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	CUSTOMBITMAP!CUSTOMSCREEN	type
		dc.l	0		font
		dc.l	screen.title	title
		dc.l	0		gadgets
		dc.l	the.bitmap	bitmap

the.bitmap	ds.w	1		bytes per row
		ds.w	1		rows
		ds.b	1		flags
		ds.b	1		depth
		ds.w	1		pad
		ds.l	8		plane pointers


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$484


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


plant.chars1
	dc.b	'1'
	ds.b	39999
end.chars1
	dc.b	0

plant.chars2
	ds.b	40000
end.chars2
	dc.b	0
	even
