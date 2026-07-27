
	*** LOADER FOR DEMO VERSION OF PIPE MANIA ***

start	move.l	4,a6
	move.l	#97140,d0
	moveq	#2,d1		chip
	jsr	-198(a6)	AllocMem
	move.l	d0,memory

	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,a0
	move.l	a0,coplist

	lea	36(a0),a0
	move.l	a0,cscreen
	lea	32000(a0),a0
	move.l	a0,pscreen
	lea	32000(a0),a0
	move.l	a0,background
	lea	32000(a0),a0
	move.l	a0,rippleaddr

	move.l	4,a6
	lea	grafname,a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	move.l	d0,a1
	move.l	38(a1),old
	move.l	4,a6
	jsr	-414(a6)	closelibrary

	bsr	clss
	bsr	waitframe

	lea	$dff180,a0	color0
	lea	$dff144,a1	spr0data
	moveq	#0,d0
	moveq	#15,d1
nextclc	move.l	d0,(a0)+
	move.w	d0,(a1)+
	dbf	d1,nextclc

	move.w	#$20,$dff09a	disable vert. blank interrupt
	move.w	#$4200,$dff100	4 bitplane display
	move.w	#0,$dff102	no scroll value
	move.w	#$38,$dff092	ddfstrt
	move.w	#$d0,$dff094	ddfstop
	move.w	#$3a81,$dff08e	diwstrt
	move.w	#$02c1,$dff090	diwstop
	move.w	#120,$dff108	bpl1mod
	move.w	#120,$dff10a	bpl2mod
	move.w	#$20,$dff096	disable sprite DMA
	bsr	showtitles

	move.w	#$c020,$dff09a	enable vert. blank interrupt
	move.w	#$8220,$dff096	enable sprite DMA

	move.l	old,$dff080	restore copper list
	move.w	d0,$dff088

	move.l	4,a6
	move.l	memory,a1
	move.l	#97140,d0
	jsr	-210(a6)	FreeMem

end	rts


cscreen	dc.l	0
pscreen	dc.l	0
background	dc.l	0
size	dc.w	1
rippleaddr	dc.l	0


waitframe
	lea	$dff006,a0	vhposr
wfr2	btst	#0,$dff005	msb of vertical position
	beq.s	wfr2
wfr1	cmpi.b	#2,(a0)
	bcs.s	wfr1
	move.l	cscreen,d0
	move.l	pscreen,cscreen
	move.l	d0,pscreen

	move.l	coplist,a0
	moveq	#3,d1
	move.w	#$e0,d2		bpl1pth
bploop	move.w	d2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	addq.w	#2,d2
	move.w	d2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	addq.w	#2,d2
	addi.l	#40,d0
	dbf	d1,bploop
	move.l	#$fffffffe,(a0)+	end copper

	move.l	coplist,$dff080		set new copper list
	move.w	d0,$dff088
	rts


clss	move.w	#124,d7
	move.l	#32000,d6
	bra.s	title1
titleclsblk
	move.w	#50,d7
	move.l	#13056,d6
title1	move.l	cscreen,a0
	add.l	d6,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	sub.l	a1,a1
clss1	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	dbf	d7,clss1
	rts


dologo	muls	size,d0
	asr.w	#4,d0
	addi.w	#160,d0
	muls	size,d1
	asr.w	#4,d1
	addi.w	#40,d1
	move.l	cscreen,a1
	muls	#160,d1
	add.w	d1,a1
	move.w	d0,d1
	andi.w	#$f,d0
	sub.w	d0,d1
	lsr.w	#3,d1
	add.w	d1,a1
	move.l	#$10000,d1
	lsl.l	d0,d1
	lea	shrinks,a2
	add.w	size,a2
	add.w	size,a2
	move.w	(a2),d4
	swap	d4
	move.w	(a2),d4
	move.w	d3,-(a7)
dl1	move.l	d1,-(a7)
	move.l	d1,d0
	move.l	d1,d3
	move.l	d1,d5
	move.w	d2,d7
	swap	d4
	rol.w	#1,d4
	bcs.s	dl2
	swap	d4
	andi.w	#$fff0,d7
	lsr.w	#1,d7
	lea	8(a0,d7.w),a0
	bra	dl7

dl2	swap	d4
	move.l	a1,a2
	moveq	#0,d6
dl3	dbf	d6,dl4
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	move.w	(a0)+,d3
	move.w	(a0)+,d5
	moveq	#$f,d6
dl4	rol.w	#1,d4
	bcc.s	dl5
	add.l	d1,d1
	add.l	d0,d0
	add.l	d3,d3
	add.l	d5,d5
	dbcs	d7,dl3
	bcc.s	dl6
	swap	d1
	swap	d0
	swap	d3
	swap	d5
	move.w	d0,40(a2)
	move.w	d3,80(a2)
	move.w	d5,120(a2)
	move.w	d1,(a2)+
	move.w	#1,d0
	move.w	#1,d3
	move.w	#1,d5
	swap	d0
	swap	d3
	swap	d5
	move.w	#1,d1
	swap	d1
	dbf	d7,dl3
	bra.s	dl6

dl5	add.w	d1,d1
	add.w	d0,d0
	add.w	d3,d3
	add.w	d5,d5
	dbf	d7,dl3
dl6	add.l	d1,d1
	add.l	d0,d0
	add.l	d3,d3
	add.l	d5,d5
	bcc.s	dl6
	swap	d1
	swap	d0
	swap	d3
	swap	d5
	move.w	d0,40(a2)
	move.w	d3,80(a2)
	move.w	d5,120(a2)
	move.w	d1,(a2)+
	lea	160(a1),a1
dl7	move.l	(a7)+,d1
	subq.w	#1,(a7)
	bpl	dl1
	addq.w	#2,a7
	rts


growlogo
	move.w	#1,size
growlp	bsr	titleclsblk
	lea	logo,a0
	moveq	#-96,d0
	moveq	#-40,d1
	move.w	#191,d2
	moveq	#80,d3
	bsr	dologo
	bsr	waitframe
	addq.w	#1,size
	cmpi.w	#16,size
	ble.s	growlp
	rts


shrinklogo
	move.w	#16,size
shklp	bsr	titleclsblk
	lea	logo,a0
	moveq	#-96,d0
	moveq	#-40,d1
	move.w	#191,d2
	moveq	#80,d3
	bsr	dologo
	bsr	waitframe
	subq.w	#1,size
	bne.s	shklp
	rts


showtitles
	bsr	clss
	bsr	waitframe
	bsr	clss
	bsr	waitframe
	movem.l	palnew,d0-d7
	add.l	d0,d0
	add.l	d1,d1
	add.l	d2,d2
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	add.l	d6,d6
	add.l	d7,d7
	movem.l	d0-d7,$dff180
	bsr	allogo
	rts


palnew	dc.w	$000,$777,$666,$555,$444,$333,$222,$111
	dc.w	$005,$745,$734,$723,$700,$600,$500,$400

shrinks	dc.w	0,$100,$1010,$2104,$4444,$4912,$5252,$552a,$aaaa
	dc.w	$ab55,$b5b5,$b76d,$dddd,$df7b,$f7f7,$ff7f,$ffff

endofpath	dc.l	0

lastfrclock	dc.w	0

lmasks	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,7,3,1
rmasks	dc.w	0,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

text	dc.w	$ffd3,0,$ffda,$1e,$ffe0,$3e,$ffe8,$6e
	dc.w	$ffee,$8c,$fff4,$8c,$fffa,$3e,0,$c6
	dc.w	9,$e4,$f,$106,$12,$11a,$1a,$106
	dc.w	$20,$134,$23,$140,$29,$3e,$8000

letterT	dc.w	$ff7e,0,$50,$ffda,0,$2e,$40,$ffb4,$50
	dc.w	$ff7e,$20,0,$ffb4,$130,$76

letterH	dc.w	$ff7e,0,0,$ffda,$130,$ff7e,$30,0,$ffda
	dc.w	$130,$ff7e,0,$90,4,$30,$76

letterE	dc.w	$ff7e,$30,$e0,$ffda,$130,$2e,0,$ffb4,0
	dc.w	$2e,$30,$ffb4,$50,$ff7e,0,$90,4,$20
	dc.w	$ff7e,$20,$70,$ffda,$c0,$76

letterA	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30
	dc.w	$ffb4,$130,$ff7e,0,$90,4,$30,$76

letterS	dc.w	$ff7e,0,$e0,$ffda,$130,$2e,$30,$ffb4,$c0
	dc.w	$ff7e,$20,$b0,$ffda,$a0,$ff7e,$10,$90,$ffda
	dc.w	$80,$ff7e,0,$70,$ffda,0,$2e,$30,$ffb4,$50,$76

letterM	dc.w	$ff7e,0,$130,$ffda,0,$2e,$60,$ffb4,$130
	dc.w	$ff7e,$30,0,$ffb4,$130,$76

letterB	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30,$ffb4
	dc.w	$130,4,0,$ff7e,0,$90,4,$30,$76

letterL	dc.w	$ff7e,0,0,$ffda,$130,$2e,$30,$ffb4,$e0,$76

letterY	dc.w	$ff7e,0,0,$ffda,$90,4,$30,$ff7e,$30,0,$ffda,$130,$76

letterI	dc.w	$ff7e,0,0,$ffda,$130,$76

letterN	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30,$ffb4,$130,$76

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

logodef	incbin	logodef.bin


copytobkgnd
	move.l	pscreen,a1
	move.l	background,a2
	bra.s	copyit

copybkgnd
	move.l	background,a1
	move.l	cscreen,a2
copyit	move.w	#199,d7
citloop	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,40(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,80(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,120(a2)
	lea	160(a2),a2
	dbf	d7,citloop
	rts


cls	move.l	cscreen,a0
	lea	32000(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,a1
	move.l	d1,a2
	move.l	d0,a3
	move.l	d1,a4
	move.w	#118,d6
clsloop	movem.l	d0-d5/a1-a4,-(a0)
	movem.l	d0-d5/a1-a4,-(a0)
	movem.l	d0-d5/a1-a4,-(a0)
	movem.l	d0-d5/a1-a4,-(a0)
	dbf	d6,clsloop
	rts


genripple
	move.l	rippleaddr,a0
	moveq	#91,d7
genloop	move.w	#$4000,(a0)+
	dbf	d7,genloop

	move.w	#367,d7
	moveq	#0,d0
gen2	move.l	d0,d1
	swap	d1
	andi.w	#$3ff,d1
	add.w	d1,d1
	move.w	d1,a1
	add.l	#cosine,a1
	move.w	(a1),d1
	sub.l	#cosine,a1
	bpl.s	gen1
	neg.w	d1
gen1	lsr.w	#1,d1
	move.w	d1,(a0)+
	add.l	#$2c859,d0
	dbf	d7,gen2

	moveq	#91,d7
gen3	move.w	#$4000,(a0)+
	dbf	d7,gen3
	rts


plotripple
	move.l	cscreen,a1
	lea	13600(a1),a1
	lea	lmasks,a4
	lea	logodef,a5
	moveq	#-1,d5
	moveq	#91,d7
prloop	move.l	a5,a2
	move.l	a1,a3
	move.w	(a0)+,d0
	bsr	plotline
	lea	32(a5),a5
	lea	160(a1),a1
	dbf	d7,prloop
	rts


plotshrink
	move.l	cscreen,a1
	lea	lmasks,a4
	move.l	#$2e000,d0
	divu	d7,d0
	neg.w	d0
	addi.w	#131,d0
	mulu	#160,d0
	add.w	d0,a1
	move.l	#$4000000,d0
	divu	d7,d0
	moveq	#0,d6
	move.w	d7,d6
	lsl.l	#4,d6
	lea	logodef,a5
	moveq	#-1,d5
	moveq	#0,d7
psloop	move.l	d7,d1
	swap	d1
	asl.w	#5,d1
	lea	(a5,d1.w),a2
	move.l	a1,a3
	bsr	plotline
	lea	160(a1),a1
	add.l	d6,d7
	cmp.l	#$5c0000,d7
	bcs.s	psloop
	rts


plotline
	move.w	(a2)+,d1
	muls	d0,d1
	swap	d1
	addi.w	#160,d1
	bpl.s	pl1
	moveq	#0,d1
pl1	move.w	(a2)+,d2
	muls	d0,d2
	swap	d2
	addi.w	#160,d2
	bmi.s	pl1
	cmp.w	#320,d2
	bcs.s	pl2
	move.w	#319,d2
pl2	move.w	d2,d4
	moveq	#$f,d3
	and.w	d1,d3
	sub.w	d3,d1
	sub.w	d1,d4
	lsr.w	#3,d1
	add.w	d1,a3
loop	add.w	d3,d3
	move.w	(a4,d3.w),d3
	cmp.w	#$f,d4
	ble.s	pl3
	or.w	d3,(a3)+
	move.w	d4,d1
	andi.w	#$f,d4
	sub.w	d4,d1
	lsr.w	#3,d1
	neg.w	d1
	jmp	pl3(pc,d1.w)
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	moveq	#-1,d3
pl3	add.w	d4,d4
	and.w	32(a4,d4.w),d3
	or.w	d3,(a3)
	cmp.w	#319,d2
	beq	return
	move.w	d2,d1
	move.w	(a2)+,d2
	cmp.w	#$8000,d2
	beq	return
	muls	d0,d2
	swap	d2
	addi.w	#160,d2
	cmp.w	#320,d2
	bcs.s	pl4
	move.w	#319,d2
pl4	lea	120(a3),a3
	move.w	d2,d4
	moveq	#$f,d3
	and.w	d1,d3
	sub.w	d3,d1
	sub.w	d1,d4
	add.w	d3,d3
	move.w	(a4,d3.w),d3
	cmp.w	#$f,d4
	ble.s	pl5
	or.w	d3,(a3)+
	move.w	d4,d1
	andi.w	#$f,d4
	sub.w	d4,d1
	lsr.w	#3,d1
	neg.w	d1
	jmp	pl5(pc,d1.w)
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	moveq	#-1,d3
pl5	add.w	d4,d4
	and.w	32(a4,d4.w),d3
	or.w	d3,(a3)
	lea	-120(a3),a3
	cmp.w	#319,d2
	beq.s	return
	move.w	d2,d1
	move.w	(a2)+,d2
	cmp.w	#$8000,d2
	beq.s	return
	muls	d0,d2
	swap	d2
	addi.w	#160,d2
	cmp.w	#320,d2
	bcs.s	pl6
	move.w	#319,d2
pl6	move.w	d2,d4
	moveq	#$f,d3
	and.w	d1,d3
	sub.w	d3,d1
	sub.w	d1,d4
	bra	loop
return	rts


doletters
	lea	text,a0
dltrs	move.l	a0,-(a7)
	move.w	d6,-(a7)
	bsr	doletter
	move.w	(a7)+,d6
	move.l	(a7)+,a0
	addq.l	#4,a0
	cmpi.w	#$8000,(a0)
	beq.s	endltrs
	subi.w	#$100,d6
	cmp.w	#$240,d6
	bge.s	dltrs
endltrs	rts


doletters2
	lea	text,a0
dltrs2	cmp.w	#$240,d6
	blt.s	dltrs21
	move.l	a0,-(a7)
	move.w	d6,-(a7)
	bsr	doletter
	move.w	(a7)+,d6
	move.l	(a7)+,a0
dltrs21	addq.l	#4,a0
	addi.w	#$100,d6
	cmpi.w	#$8000,(a0)
	bne.s	dltrs2
	rts


doletter
	cmp.w	#$1000,d6
	blt.s	dltr
	move.w	#$1000,d6
dltr	move.l	#$1000000,d7
	divu	d6,d7
	move.w	(a0),d0
	asl.w	#4,d0
	muls	d7,d0
	swap	d0
	addi.w	#160,d0
	move.w	d0,a4
	move.w	#-$200,d0
	muls	d7,d0
	swap	d0
	addi.w	#210,d0
	move.w	d0,a5
	move.w	2(a0),a0
	add.l	#letterT,a0
letter	move.w	d7,d6
	rol.w	#3,d6
	andi.w	#7,d6
	bra.s	m1


do.moveto
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	mulu	d7,d0
	mulu	d7,d1
	swap	d0
	swap	d1
	add.w	a4,d0
	add.w	a5,d1

m1	move.w	(a0)+,d4
	jmp	cmd(pc,d4.w)

do.vto	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	bge.s	vto1
	exg	d1,d3
vto1	add.w	d6,d1
	sub.w	d6,d3
	bra	v1

do.vto2	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	blt.s	vto21
	add.w	d6,d1
	add.w	d6,d3
	bra.s	v1
vto21	exg	d1,d3
	sub.w	d6,d1
	sub.w	d6,d3
	bra	v1

do.vto12
	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	bge.s	vto121
	exg	d1,d3
vto121	sub.w	d6,d1
	add.w	d6,d3

v1	bsr	rectangle
	move.w	(a7)+,d1
	move.w	(a7)+,d0
	move.w	(a0)+,d4

cmd	jmp	cmd(pc,d4.w)

do.hto	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	bge.s	hto1
	exg	d0,d2
hto1	add.w	d6,d0
	sub.w	d6,d2

h1	bsr	rectangle
	move.w	(a7)+,d0
	move.w	(a7)+,d1
	move.w	(a0)+,d4
	jmp	cmd(pc,d4.w)

do.hto2	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	blt.s	hto21
	add.w	d6,d0
	add.w	d6,d2
	bra	h1
hto21	exg	d0,d2
	sub.w	d6,d0
	sub.w	d6,d2
	bra	h1

do.hto12
	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	bge.s	hto121
	exg	d0,d2
hto121	sub.w	d6,d0
	add.w	d6,d2
	bra	h1

do.ret	rts


rectangle
	tst.w	d0
	bpl.s	rect1
	clr.w	d0
rect1	tst.w	d1
	bpl.s	rect2
	clr.w	d1
rect2	cmp.w	#320,d2
	blt.s	rect3
	move.w	#319,d2
rect3	cmp.w	#200,d3
	blt.s	rect4
	move.w	#199,d3
rect4	sub.w	d0,d2
	bmi.s	do.ret
	sub.w	d1,d3
	bmi.s	do.ret
	move.l	cscreen,a2
	move.w	d1,a1
	add.w	d1,d1
	add.w	d1,d1
	add.w	a1,d1
	lsl.w	#5,d1
	add.w	d1,a2
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	add.w	d1,d2
	lsr.w	#3,d0
	add.w	d0,a2
	lea	lmasks(pc),a1
	add.w	d1,d1
	move.w	(a1,d1.w),d0
	moveq	#$f,d1
	and.w	d2,d1
	sub.w	d1,d2
	beq	thinrect
	swap	d0
	add.w	d1,d1
	move.w	34(a1,d1.w),d0
	move.l	d0,d1
	not.l	d1
rectlp	and.l	d1,40(a2)
	or.l	d0,80(a2)
	or.l	d0,120(a2)
	and.l	d1,(a2)+
	lea	156(a2),a2
	dbf	d3,rectlp
	rts

thinrect
	add.w	d1,d1
	and.w	34(a1,d1.w),d0
	move.w	d0,d1
	not.w	d1
thinlp	and.w	d1,40(a2)
	or.w	d0,80(a2)
	or.w	d0,120(a2)
	and.w	d1,(a2)+
	lea	158(a2),a2
	dbf	d3,thinlp
	rts


allogo	bsr	growlogo	grow the empire logo
	move.l	pscreen,a1
	move.l	cscreen,a2
	bsr	copyit

	bsr	genripple	grow the blue and white logo
	lea	-184(a0),a0
	move.l	a0,endofpath
	move.w	#$8000,d7
zoomin	move.w	d7,-(a7)
	bsr	cls
	bsr	plotshrink
	bsr	waitframe
	move.w	(a7)+,d7
	subi.w	#$100,d7
	cmp.w	#$1000,d7
	bne.s	zoomin

	move.l	rippleaddr,a0	ripple the blue and white logo
ripple	move.l	a0,-(a7)
	bsr	cls
	move.l	(a7),a0
	bsr	plotripple
	bsr	waitframe
	move.l	(a7)+,a0
	lea	8(a0),a0
	cmp.l	endofpath,a0
	ble.s	ripple

	bsr	copytobkgnd	bring in the text
	move.w	#576,d6
shrink	move.w	d6,-(a7)
	bsr	copybkgnd
	bsr	doletters
	bsr	waitframe
	move.w	(a7)+,d6
	addi.w	#64,d6
	cmp.w	#$1f00,d6
	bne.s	shrink

	bsr	shrinklogo	shrink the empire logo
	bsr	clss

	move.w	#$1000,d7
	bsr	plotshrink

	move.l	pscreen,-(a7)
	move.l	cscreen,pscreen
	bsr	copytobkgnd
	move.l	(a7)+,pscreen

	move.w	#$1000,d6	remove the text
expand	move.w	d6,-(a7)
	bsr	copybkgnd
	bsr	doletters2
	bsr	waitframe
	move.w	(a7)+,d6
	subi.w	#64,d6
	cmp.w	#$f340,d6
	bne.s	expand

	move.w	#$1000,d7	shrink the blue and white logo
zoomout	move.w	d7,-(a7)
	bsr	cls
	bsr	plotshrink
	bsr	waitframe
	move.w	(a7)+,d7
	addi.w	#$100,d7
	cmpi.w	#$8000,d7
	bne.s	zoomout
	rts

logo	incbin	logo.bin


coplist	dc.l	0
old	dc.l	0
memory	dc.l	0

grafname	dc.b	"graphics.library",0
	even
dosname	dc.b	"dos.library",0
	even
fname	dc.b	"pipeline.bin",0
	even
