	section	Trodd,code_c


	bra	A.30c1c

******** Troddler's Sales Curve Software Scaling Intro ********

A.30000
	dc.b	$00,$53,$00,$02,$ff,$e0,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$0c,$ff,$e0
	dc.b	$ff,$e1,$ff,$e6,$ff,$eb,$ff,$ed,$ff,$f5,$ff,$f9,$ff,$fe,$00,$04
	dc.b	$00,$0a,$00,$1e,$00,$1f,$00,$16,$ff,$e0,$ff,$e1,$ff,$e5,$ff,$e7
	dc.b	$ff,$ea,$ff,$ec,$ff,$f0,$ff,$f2,$ff,$f7,$ff,$f9,$ff,$fe,$00,$00
	dc.b	$00,$04,$00,$06,$00,$09,$00,$0c,$00,$0f,$00,$11,$00,$18,$00,$1b
	dc.b	$00,$1e,$00,$1f,$00,$16,$ff,$e0,$ff,$e1,$ff,$e4,$ff,$e6,$ff,$eb
	dc.b	$ff,$ec,$ff,$f0,$ff,$f2,$ff,$f6,$ff,$f8,$ff,$ff,$00,$01,$00,$04
	dc.b	$00,$06,$00,$0a,$00,$0c,$00,$0f,$00,$11,$00,$18,$00,$1b,$00,$1e
	dc.b	$00,$1f,$00,$14,$ff,$e0,$ff,$e1,$ff,$e4,$ff,$e6,$ff,$f0,$ff,$f2
	dc.b	$ff,$f6,$ff,$f8,$ff,$ff,$00,$01,$00,$04,$00,$06,$00,$0a,$00,$0d
	dc.b	$00,$0f,$00,$13,$00,$16,$00,$1b,$00,$1e,$00,$1f,$00,$14,$ff,$e0
	dc.b	$ff,$e1,$ff,$e4,$ff,$e7,$ff,$f0,$ff,$f2,$ff,$f5,$ff,$f8,$ff,$ff
	dc.b	$00,$02,$00,$04,$00,$06,$00,$0a,$00,$0d,$00,$0f,$00,$13,$00,$16
	dc.b	$00,$1b,$00,$1e,$00,$1f,$00,$16,$ff,$e0,$ff,$e1,$ff,$e4,$ff,$e9
	dc.b	$ff,$f0,$ff,$f2,$ff,$f5,$ff,$f8,$ff,$ff,$00,$02,$00,$04,$00,$06
	dc.b	$00,$0a,$00,$0c,$00,$0f,$00,$10,$00,$12,$00,$17,$00,$19,$00,$1b
	dc.b	$00,$1e,$00,$1f,$00,$16,$ff,$e0,$ff,$e1,$ff,$e5,$ff,$eb,$ff,$f0
	dc.b	$ff,$f2,$ff,$f5,$ff,$f8,$ff,$ff,$00,$02,$00,$04,$00,$06,$00,$09
	dc.b	$00,$0c,$00,$0f,$00,$10,$00,$12,$00,$17,$00,$19,$00,$1b,$00,$1e
	dc.b	$00,$1f,$00,$14,$ff,$e0,$ff,$e1,$ff,$e7,$ff,$ec,$ff,$f0,$ff,$f2
	dc.b	$ff,$f5,$ff,$f8,$ff,$ff,$00,$02,$00,$04,$00,$0a,$00,$0f,$00,$10
	dc.b	$00,$13,$00,$16,$00,$19,$00,$1b,$00,$1e,$00,$1f,$00,$16,$ff,$e0
	dc.b	$ff,$e1,$ff,$e9,$ff,$ed,$ff,$f0,$ff,$f2,$ff,$f5,$ff,$f8,$ff,$ff
	dc.b	$00,$02,$00,$04,$00,$06,$00,$08,$00,$0a,$00,$0f,$00,$10,$00,$13
	dc.b	$00,$16,$00,$19,$00,$1b,$00,$1e,$00,$1f,$00,$16,$ff,$e0,$ff,$e1
	dc.b	$ff,$ea,$ff,$ed,$ff,$f0,$ff,$f2,$ff,$f6,$ff,$f8,$ff,$ff,$00,$01
	dc.b	$00,$04,$00,$06,$00,$08,$00,$0b,$00,$0f,$00,$10,$00,$13,$00,$16
	dc.b	$00,$19,$00,$1b,$00,$1e,$00,$1f,$00,$18,$ff,$e0,$ff,$e1,$ff,$e4
	dc.b	$ff,$e5,$ff,$ea,$ff,$ed,$ff,$f0,$ff,$f2,$ff,$f6,$ff,$f8,$ff,$ff
	dc.b	$00,$01,$00,$04,$00,$06,$00,$09,$00,$0b,$00,$0f,$00,$10,$00,$14
	dc.b	$00,$15,$00,$19,$00,$1b,$00,$1e,$00,$1f,$00,$18,$ff,$e0,$ff,$e1
	dc.b	$ff,$e4,$ff,$e7,$ff,$e9,$ff,$ec,$ff,$f0,$ff,$f2,$ff,$f7,$ff,$f9
	dc.b	$ff,$fe,$00,$00,$00,$04,$00,$06,$00,$09,$00,$0c,$00,$0f,$00,$10
	dc.b	$00,$14,$00,$15,$00,$19,$00,$1b,$00,$1e,$00,$1f,$00,$12,$ff,$e0
	dc.b	$ff,$e1,$ff,$e6,$ff,$ea,$ff,$f0,$ff,$f2,$ff,$f9,$ff,$fe,$00,$04
	dc.b	$00,$06,$00,$0a,$00,$0c,$00,$0f,$00,$10,$00,$19,$00,$1b,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0
	dc.b	$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$06,$ff,$e0,$ff,$e1,$ff,$fa,$00,$05,$00,$1e,$00,$1f,$00,$06
	dc.b	$ff,$e0,$ff,$e1,$ff,$f7,$00,$08,$00,$1e,$00,$1f,$00,$06,$ff,$e0
	dc.b	$ff,$e1,$ff,$f4,$00,$0b,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1
	dc.b	$ff,$f2,$00,$0d,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$f1
	dc.b	$00,$0e,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ef,$00,$10
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$ee,$ff,$f0,$00,$05
	dc.b	$00,$11,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$ed,$ff,$f8
	dc.b	$00,$07,$00,$12,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ec
	dc.b	$00,$13,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$eb,$ff,$ed
	dc.b	$00,$0a,$00,$14,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$ea
	dc.b	$ff,$f5,$00,$0b,$00,$15,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1
	dc.b	$ff,$ea,$00,$15,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e9
	dc.b	$ff,$eb,$00,$0c,$00,$16,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e8,$ff,$f2,$00,$0d,$00,$17,$00,$1e,$00,$1f,$00,$06,$ff,$e0
	dc.b	$ff,$e1,$ff,$e8,$00,$17,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1
	dc.b	$ff,$e7,$00,$18,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$e7
	dc.b	$00,$18,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$e7,$00,$18
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e6,$ff,$e8,$00,$0f
	dc.b	$00,$19,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e6,$ff,$f0
	dc.b	$00,$10,$00,$19,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$e6
	dc.b	$00,$19,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e5,$ff,$e7
	dc.b	$00,$12,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e5
	dc.b	$ff,$ef,$00,$13,$00,$1a,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1
	dc.b	$ff,$e5,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e5
	dc.b	$ff,$e7,$00,$13,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e5,$ff,$ef,$00,$12,$00,$1a,$00,$1e,$00,$1f,$00,$06,$ff,$e0
	dc.b	$ff,$e1,$ff,$e5,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e5,$ff,$e7,$00,$11,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e5,$ff,$ef,$00,$12,$00,$1a,$00,$1e,$00,$1f,$00,$06
	dc.b	$ff,$e0,$ff,$e1,$ff,$e5,$00,$1a,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e5,$ff,$e7,$00,$12,$00,$1a,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e5,$ff,$f0,$00,$12,$00,$1a,$00,$1e,$00,$1f
	dc.b	$00,$06,$ff,$e0,$ff,$e1,$ff,$e6,$00,$19,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e6,$ff,$e8,$00,$12,$00,$19,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e7,$ff,$f1,$00,$13,$00,$19,$00,$1e
	dc.b	$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$e7,$00,$18,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e7,$ff,$e9,$00,$10,$00,$18,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e8,$ff,$f2,$00,$0e,$00,$18
	dc.b	$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$e8,$00,$17,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e9,$ff,$eb,$00,$0c,$00,$17
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$ea,$ff,$f4,$00,$0c
	dc.b	$00,$16,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ea,$00,$15
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$eb,$ff,$ed,$00,$0c
	dc.b	$00,$15,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$ec,$ff,$f7
	dc.b	$00,$0c,$00,$14,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ec
	dc.b	$00,$13,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ed,$00,$12
	dc.b	$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ee,$00,$11,$00,$1e
	dc.b	$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$ef,$00,$10,$00,$1e,$00,$1f
	dc.b	$00,$06,$ff,$e0,$ff,$e1,$ff,$f1,$00,$0e,$00,$1e,$00,$1f,$00,$06
	dc.b	$ff,$e0,$ff,$e1,$ff,$f2,$00,$0d,$00,$1e,$00,$1f,$00,$06,$ff,$e0
	dc.b	$ff,$e1,$ff,$f4,$00,$0b,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1
	dc.b	$ff,$f6,$00,$08,$00,$1e,$00,$1f,$00,$06,$ff,$e0,$ff,$e1,$ff,$f9
	dc.b	$00,$05,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1
	dc.b	$00,$1e,$00,$1f,$00,$1c,$ff,$e0,$ff,$e1,$ff,$e5,$ff,$e7,$ff,$ea
	dc.b	$ff,$ec,$ff,$ef,$ff,$f0,$ff,$f4,$ff,$f7,$ff,$fa,$ff,$fc,$00,$01
	dc.b	$00,$03,$00,$05,$00,$06,$00,$08,$00,$09,$00,$0b,$00,$0e,$00,$11
	dc.b	$00,$12,$00,$15,$00,$16,$00,$18,$00,$1b,$00,$1e,$00,$1f,$00,$20
	dc.b	$ff,$e0,$ff,$e1,$ff,$e4,$ff,$e5,$ff,$e9,$ff,$ea,$ff,$ec,$ff,$ed
	dc.b	$ff,$ef,$ff,$f0,$ff,$f4,$ff,$f5,$ff,$f9,$ff,$fa,$00,$00,$00,$01
	dc.b	$00,$05,$00,$06,$00,$08,$00,$09,$00,$0b,$00,$0c,$00,$0e,$00,$0f
	dc.b	$00,$11,$00,$12,$00,$15,$00,$16,$00,$18,$00,$19,$00,$1e,$00,$1f
	dc.b	$00,$1c,$ff,$e0,$ff,$e1,$ff,$e5,$ff,$e6,$ff,$e9,$ff,$ed,$ff,$ef
	dc.b	$ff,$f0,$ff,$f4,$ff,$f6,$ff,$fa,$ff,$fb,$00,$00,$00,$01,$00,$05
	dc.b	$00,$06,$00,$08,$00,$09,$00,$0b,$00,$0e,$00,$11,$00,$12,$00,$14
	dc.b	$00,$15,$00,$18,$00,$1a,$00,$1e,$00,$1f,$00,$20,$ff,$e0,$ff,$e1
	dc.b	$ff,$e6,$ff,$e7,$ff,$e9,$ff,$ea,$ff,$ec,$ff,$ed,$ff,$ef,$ff,$f0
	dc.b	$ff,$f4,$ff,$f5,$ff,$fb,$ff,$fc,$00,$00,$00,$01,$00,$05,$00,$06
	dc.b	$00,$08,$00,$09,$00,$0b,$00,$0c,$00,$0e,$00,$0f,$00,$11,$00,$12
	dc.b	$00,$14,$00,$15,$00,$18,$00,$19,$00,$1e,$00,$1f,$00,$1c,$ff,$e0
	dc.b	$ff,$e1,$ff,$e4,$ff,$e6,$ff,$e9,$ff,$ea,$ff,$ec,$ff,$ed,$ff,$ef
	dc.b	$ff,$f2,$ff,$f4,$ff,$f7,$ff,$f9,$ff,$fb,$00,$01,$00,$03,$00,$06
	dc.b	$00,$08,$00,$0b,$00,$0c,$00,$0e,$00,$0f,$00,$12,$00,$14,$00,$18
	dc.b	$00,$1b,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$02,$ff,$e0,$00,$1f
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
A.3073a
	dc.b	$00,$53,$00,$02,$ff,$e0
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0
	dc.b	$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1
	dc.b	$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04
	dc.b	$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0
	dc.b	$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1
	dc.b	$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04
	dc.b	$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0
	dc.b	$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$f4,$00,$0b,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$f2,$00,$0d,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$f1,$00,$0e,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ef,$00,$10,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ee,$00,$11,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ed,$00,$12
	dc.b	$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ec
	dc.b	$00,$13,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3
	dc.b	$ff,$eb,$00,$14,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$ea,$00,$15,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$ea,$00,$15,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e9,$00,$16,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e8,$00,$17,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e8,$00,$17,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$0a,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e7,$ff,$e9
	dc.b	$00,$0d,$00,$18,$00,$1c,$00,$1e,$00,$1f,$00,$0a,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$e7,$ff,$f1,$00,$0e,$00,$18,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e7,$00,$18,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e6,$00,$19,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e6,$00,$19
	dc.b	$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e6
	dc.b	$00,$19,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3
	dc.b	$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a
	dc.b	$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e5
	dc.b	$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3
	dc.b	$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$e5,$00,$1a,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e6,$00,$19,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e6,$00,$19,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e7,$00,$19,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e7,$00,$18
	dc.b	$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$e7
	dc.b	$00,$18,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3
	dc.b	$ff,$e8,$00,$18,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$e8,$00,$17,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$e9,$00,$17,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ea,$00,$16,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ea,$00,$15,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$eb,$00,$15,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ec,$00,$14
	dc.b	$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$ec
	dc.b	$00,$13,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3
	dc.b	$ff,$ed,$00,$12,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0,$ff,$e1
	dc.b	$ff,$e3,$ff,$ee,$00,$11,$00,$1c,$00,$1e,$00,$1f,$00,$08,$ff,$e0
	dc.b	$ff,$e1,$ff,$e3,$ff,$ef,$00,$10,$00,$1c,$00,$1e,$00,$1f,$00,$08
	dc.b	$ff,$e0,$ff,$e1,$ff,$e3,$ff,$f1,$00,$0e,$00,$1c,$00,$1e,$00,$1f
	dc.b	$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$f2,$00,$0d,$00,$1c,$00,$1e
	dc.b	$00,$1f,$00,$08,$ff,$e0,$ff,$e1,$ff,$e3,$ff,$f4,$00,$0b,$00,$1c
	dc.b	$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04
	dc.b	$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0
	dc.b	$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f
	dc.b	$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1
	dc.b	$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04
	dc.b	$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e
	dc.b	$00,$1f,$00,$04,$ff,$e0,$ff,$e1,$00,$1e,$00,$1f,$00,$02,$ff,$e0
	dc.b	$00,$1f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

A.30c1c	move.w	#$4000,$dff000+intena
	move.l	#Trodd,$80		trap 0
	trap	#0
	rts


Trodd	lea	$7fffe,sp
	lea	$dff000,a0
	move.w	#$7fff,dmacon(a0)
	move.w	#$7fff,intena(a0)
	move.w	#$7fff,intreq(a0)
	move.w	#0,color0(a0)
	move.w	#$8210,dmacon(a0)
	move.b	#$7f,$bfed01
	move.b	#$7f,$bfdd00
	move.b	#0,$bfee01
	move.b	#0,$bfef01
	move.b	#0,$bfde00
	move.b	#0,$bfdd00
	move.b	#3,$bfe201
	move.b	#0,$bfe301
	move.b	#$c0,$bfd200
	move.b	#$ff,$bfd300

	bsr	Get.Chip.Memory
	move.l	a0,$84			trap 1
	move.l	d0,$88			trap 2

	bsr	Do.Copper.and.Other.Data
	clr.w	A.31a16
	move.l	#A.30d24,$6c
	move.w	#$c020,$dff000+intena

l000003	lea	$a7b8,a0
	lea	$dab8,a1
	bsr	l000043
	lea	A.319f5,a0		Trodd.Dat Pointer
	lea	$35000,a1
	bsr	l000044
	tst.l	d0
	beq.s	l000003
	lea	$35000,a0
	add.l	d0,a0
	lea	$40000,a1
	bsr	l000076
	move.w	#$ffff,A.31a16

l000004	tst.w	A.31a16
	bmi.s	l000004

	jmp	$7460c

A.30d24
	movem.l	d0-d7/a0-a6,-(sp)
	pea.l	A.30d3e
	tst.w	A.31a16
	beq	l00000f
	bmi	l00000d
	rts

A.30d3e
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$20,$dff000+intreq
	rte	


Do.Copper.and.Other.Data
	bsr	l000017
	bsr	l000014
	bsr	Make.CopperList
	bsr	Set.Copper.And.Dma
	move.w	#$000,$dff000+color0
	move.w	#$fff,$dff000+color1
	move.w	#$00c,$dff000+color2
	move.w	#$c00,$dff000+color3
	bsr	l00000b
	move.w	#197,A.31a1a
	move.l	#$fffffffe,$8878
	move.l	#$fffffffe,$9818
	rts


Get.Chip.Memory
	move.l	$4,a6
	clr.l	d0
	move.l	322(a6),a0		MemList

l000007	tst.l	(a0)
	beq.s	l000009
	move.w	14(a0),d1
	and.w	#4,d1
	bne.s	l000008
	move.l	(a0),a0
	bra.s	l000007

l000008	move.l	24(a0),d0
	move.l	20(a0),a0
	sub.l	a0,d0
	rts

l000009	move.l	62(a6),d0		MaxLocMem (chip)
	lea	$80000,a0
	sub.l	a0,d0
	tst.l	d0
	bpl.s	l00000a
	clr.l	d0
l00000a	rts


l00000b	lea	$400,a0			Destination Address
	clr.w	d0			Destination Modulo

	move.w	#83*64+22,d1		Blit size
	bsr	Clear

	lea	$2088,a0
	bsr	Clear

l00000c	lea	$3d10,a0
	clr.w	d0

	move.w	#166*64+22,d1
	bsr	Clear
	rts


l00000d	bsr	l000037
	bsr	l000011
	bsr	l00000c
	bsr	l00002e
	bsr	l00003e
	lea	$5998,a1
	bsr	l000020
	bsr	l00002c
	lea	$6550,a1
	bsr	l000026
	bsr	l00003e
	bsr	l00002d
	addq.w	#2,A.31a1a
	cmp.w	#197,A.31a1a
	blt.s	l00000e

	move.w	#0,$dff000+color1
	subq.w	#2,A.31a1a
	move.w	#1,A.31a16
l00000e	rts


l00000f	bsr	l000037
	bsr	l000011
	bsr	l00000c
	bsr	l00002e
	bsr	l00003e
	lea	$5998,a1
	bsr	l000020
	bsr	l00002c
	lea	$6550,a1
	bsr	l000026
	bsr	l00003e
	bsr	l00002d
	subq.w	#1,A.31a1a
	tst.w	A.31a1a
	bpl.s	l000010
	move.w	#197,A.31a1a
	move.w	#0,A.31a1a
	move.w	#1,A.31a16
	rts


l000010	rts


l000011	not.w	A.31a14
	beq.s	l000012
	move.l	#$400,A.31a04
	move.l	#$2088,A.31a00
	move.l	#$8878,A.31a0c
	move.l	#$9818,A.31a08
	rts


l000012	move.l	#$2088,A.31a04
	move.l	#$400,A.31a00
	move.l	#$9818,A.31a0c
	move.l	#$8878,A.31a08
	rts


	move.w	#500,d0
	move.w	#128,d1
	move.w	#10,d2

l000013	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,l000013
	rts


l000014	lea	$7108,a0
	move.w	#0,d0

l000015	move.w	#65336,d1
	clr.w	d2
	sub.w	d0,d1
	beq.s	l000016
	move.w	d0,d2
	muls	#128,d2
	divs	d1,d2

l000016	move.w	d2,(a0)+
	sub.w	#1,d0
	cmp.w	#65336,d0
	bge.s	l000015
	rts


l000017	lea	$5998,a2
	lea	A.30000,a1
	bsr	l000018
	lea	$6550,a2
	lea	A.3073a,a1

l000018	move.w	#$ffce,d0

l000019	move.l	a1,-(sp)
	move.w	d0,(a2)+
	move.w	#$ffff,(a2)
	move.w	(a1)+,d1
	subq.w	#1,d1
	moveq	#0,d3

l00001a	move.w	(a1)+,d2
	subq.w	#1,d2

l00001b	cmp.w	(a1)+,d0
	beq.s	l00001f

l00001c	dbra	d2,l00001b
	add.w	#44,d3
	dbra	d1,l00001a
	tst.w	(a2)
	beq.s	l00001d
	subq.w	#2,a2
	bra.s	l00001e


l00001d	move.w	#$ffff,(a2)+

l00001e	addq.w	#1,d0
	cmp.w	#50,d0
	move.l	(sp)+,a1
	blt.s	l000019
	move.w	#$4000,(a2)+
	rts


l00001f	move.w	d3,(a2)+
	clr.w	(a2)
	bra.s	l00001c


l000020	lea	$7108,a0
	lea	A.329c8,a4
	move.l	#$b0,d2
	move.w	A.31a1a,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d4

l000021	move.w	(a1)+,d1
	cmp.w	#$4000,d1
	beq	l000025
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	l000022
	clr.w	d3

l000022	cmp.w	#352,d3
	blt.s	l000023
	move.w	#351,d3

l000023	lea	$3d10,a3
	move.b	0(a4,d3.w),d6
	asr.w	#3,d3
	add.w	d3,a3

l000024	move.w	(a1)+,d3
	bmi.s	l000021
	eor.b	d6,0(a3,d3.w)
	bra.s	l000024

l000025	rts

l000026	lea	$7108,a0
	lea	A.329c8,a4
	move.l	#$b0,d2
	move.w	A.31a1a,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d4

l000027	move.w	(a1)+,d1
	cmp.w	#$4000,d1
	beq	l00002b
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	l000028
	clr.w	d3

l000028	cmp.w	#352,d3
	blt.s	l000029
	move.w	#351,d3

l000029	lea	$4b54,a3
	move.b	0(a4,d3.w),d6
	asr.w	#3,d3
	add.w	d3,a3

l00002a	move.w	(a1)+,d3
	bmi.s	l000027
	eor.b	d6,0(a3,d3.w)
	bra.s	l00002a

l00002b	rts

l00002c	lea	$4b52,a0
	move.l	A.31a00,a1
	add.l	#$e42,a1
	clr.w	d0
	clr.w	d1
	move.w	#5334,d2
	bsr	l00003e
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d0,$dff000+bltamod
	move.w	d1,$dff000+bltdmod
	move.l	a0,$dff000+bltapth
	move.l	a1,$dff000+bltdpth
	move.w	#$9f0,$dff000+bltcon0
	move.w	#$12,$dff000+bltcon1
	move.w	d2,$dff000+bltsize
	rts

l00002d	lea	$5996,a0
	move.l	A.31a00,a1
	add.l	#$1c86,a1
	clr.w	d0
	clr.w	d1
	move.w	#5334,d2
	bsr	l00003e
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d0,$dff000+bltamod
	move.w	d1,$dff000+bltdmod
	move.l	a0,$dff000+bltapth
	move.l	a1,$dff000+bltdpth
	move.w	#$9f0,$dff000+bltcon0
	move.w	#$12,$dff000+bltcon1
	move.w	d2,$dff000+bltsize
	rts

l00002e	move.l	A.31a08,a2
	lea	$7108,a0
	move.l	#$a9,d2
	move.w	#82,d6
	move.w	#65494,d1
	move.w	A.31a1a,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d4
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	subq.w	#1,d3
	cmp.w	#26,d3
	bge.s	l00002f
	move.w	#26,d3

l00002f	lsl.w	#8,d3
	or.w	#113,d3
	move.w	#142,(a2)+
	move.w	d3,(a2)+
	move.w	d4,d3
	muls	#42,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	#42,d3
	cmp.w	#312,d3
	ble.s	l000030
	move.w	#312,d3

l000030	lsl.w	#8,d3
	or.w	#209,d3
	move.w	#144,(a2)+
	move.w	d3,(a2)+
	move.l	A.31a00,d5
	move.l	d5,d7
	add.l	#$e44,d7
	clr.w	A.31204

l000031	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	l000032
	clr.w	d3

l000032	cmp.w	#312,d3
	blt.s	l000033
	bra.s	l000035
	move.w	#312,d3

l000033	lsl.w	#8,d3
	bcc.s	l000034
	tst.w	A.31204
	bne.s	l000034
	not.w	A.31204
	move.l	#$ffe1fffe,(a2)+

l000034	or.w	#1,d3
	move.w	d3,(a2)+
	move.w	#$fffe,(a2)+
	move.w	#226,(a2)+
	move.w	d5,(a2)+
	move.w	#230,(a2)+
	move.w	d7,(a2)+
	add.w	#44,d5
	add.w	#44,d7
	addq.w	#1,d1
	dbra	d6,l000031

l000035	move.l	#$fffffffe,(a2)+
	rts

A.31204
	dc.w	0

Make.CopperList
	lea	CopperList1,a2
	move.w	#bplcon0,(a2)+
	move.w	#$2200,(a2)+
	move.w	#ddfstrt,(a2)+
	move.w	#$30,(a2)+
	move.w	#ddfstop,(a2)+
	move.w	#$d8,(a2)+
	move.w	#diwstrt,(a2)+
	move.w	#$1a71,(a2)+
	move.w	#diwstop,(a2)+
	move.w	#$38d1,(a2)+
	move.w	#bpl1mod,(a2)+
	move.w	#-44,(a2)+
	move.w	#bpl2mod,(a2)+
	move.w	#-44,(a2)+
	move.w	#bplcon1,(a2)+
	clr.w	(a2)+
	move.l	a2,A.31a10
	pea.l	Do.Sprite.Pointers

l000037	move.l	A.31a10,a2
	move.w	#bpl1pth,d0
	move.l	A.31a04,d1
	bsr	Write.Copper

	move.w	#bpl2pth,d0
	move.l	A.31a04,d1
	bsr	Write.Copper

	move.w	#cop2lch,d0
	move.l	A.31a0c,d1
	bsr	Write.Copper
	rts

Do.Sprite.Pointers
	move.w	#spr0pth,d0
	move.l	#Zero.Sprite.Pointers,d1
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	bsr	Write.Copper
	move.w	#copjmp2,(a2)+
	move.w	#0,(a2)+
	move.l	#$fffffffe,(a2)+
	move.w	#$1e01,d0
	moveq	#$52,d1

l000038	move.w	d0,(a2)+
	move.w	#$fffe,(a2)+
	move.w	#bpl1mod,(a2)+
	move.w	#-44,(a2)+
	add.w	#$300,d0
	bcc.s	l000039
	move.w	#$ffe1,(a2)+
	move.w	#$fffe,(a2)+

l000039	move.w	d0,(a2)+
	move.w	#$fffe,(a2)+
	move.w	#bpl1mod,(a2)+
	move.w	#0,(a2)+
	add.w	#$100,d0
	bcc.s	l00003a
	move.w	#$ffe1,(a2)+
	move.w	#$fffe,(a2)+

l00003a	dbra	d1,l000038
	move.l	#$fffffffe,(a2)+
	rts

	cmp.w	#$601,d0
	bcc.s	l00003b
	move.w	#$ffe3,(a2)+
	move.w	#$fffe,(a2)+

l00003b	rts

Write.Copper
	move.w	d0,(a2)+
	swap	d1
	move.w	d1,(a2)+
	addq.w	#2,d0
	move.w	d0,(a2)+
	swap	d1
	move.w	d1,(a2)+
	addq.w	#2,d0
	rts

Set.Copper.And.Dma
	lea	$dff000,a0
	move.l	#CopperList1,cop1lch(a0)
	move.w	copjmp1(a0),d0
	move.w	#$87e0,dmacon(a0)
	rts

l00003e	btst	#6,$dff000+dmaconr
	bne.s	l00003e
	rts

l00003f	btst	#6,$dff000+dmaconr
	bne.s	l00003f
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d1,$dff000+bltamod
	move.w	d2,$dff000+bltdmod
	move.l	a1,$dff000+bltapth
	move.l	a2,$dff000+bltdpth
	move.w	#$9f0,$dff000+bltcon0
	move.w	#0,$dff000+bltcon1
	move.w	d3,$dff000+bltsize
	rts


	clr.l	d0
	move.b	$bfec01,d0
	move.b	#69,$bfee01
	clr.b	$bfec01
	move.b	#5,$bfee01
	btst	#0,d0
	beq	l000040
	not.b	d0
	lsr.b	#1,d0
	rts

l000040	move.w	#65535,d0
	rts

Clear	btst	#6,$dff000+dmaconr
	bne.s	Clear

	move.w	d0,$dff000+bltdmod
	move.l	a0,$dff000+bltdpth
	move.w	#$100,$dff000+bltcon0
	move.w	#0,$dff000+bltcon1
	move.w	d1,$dff000+bltsize
	rts

l000042	btst	#6,$dff000+dmaconr
	bne.s	l000042
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d1,$dff000+bltamod
	move.w	d1,$dff000+bltbmod
	move.w	d2,$dff000+bltdmod
	move.w	d2,$dff000+bltcmod
	move.l	a3,$dff000+bltapth
	move.l	a1,$dff000+bltbpth
	move.l	a2,$dff000+bltdpth
	move.l	a2,$dff000+bltcpth
	move.w	#$fca,$dff000+bltcon0
	move.w	#0,$dff000+bltcon1
	move.w	d3,$dff000+bltsize
	rts

l000043	move.l	a0,A.318b0
	move.l	a1,A.318b4
	bsr	l00006e
	rts

l000044	movem.l	d1-d7/a3-a6,-(sp)
	bsr	l000062
	move.w	#65535,A.318b8
	move.l	a0,A.318a8
	move.l	a1,A.318ac
	move.l	A.318b0,A.318a4
	move.w	#880,d0
	bsr	l00005a
	move.w	d0,d4
	bsr	l000048
	tst.w	d7
	bmi	l000047
	move.l	A.318a8,a0
	bsr	l000055
	lsl.w	#2,d0
	move.l	A.318b4,a0
	add.w	d4,a0

l000045	move.l	0(a0,d0.w),d0
	beq	l000047
	bsr	l00005a
	bsr	l000052
	tst.w	d1
	bpl.s	l000046
	move.l	A.318b4,a0
	add.w	#496,d0
	bra.s	l000045

l000046	bsr	l00004f
	bsr	l000064
	movem.l	(sp)+,d1-d7/a3-a6
	move.l	a2,d0
	sub.l	A.318ac,d0
	rts

l000047	bsr	l000064
	movem.l	(sp)+,d1-d7/a3-a6
	moveq	#0,d0
	rts

l000048	move.l	A.318a8,a0

l000049	move.l	a0,a1

l00004a	tst.b	(a0)
	beq.s	l00004d
	cmp.b	#47,(a0)+
	bne.s	l00004a
	clr.b	-1(a0)
	move.l	a0,-(sp)
	move.l	a1,a0
	bsr	l000055
	lsl.w	#2,d0
	move.l	A.318b4,a0
	add.w	d4,a0

l00004b	move.l	0(a0,d0.w),d0
	beq.s	l00004e
	bsr	l00005a
	move.w	d0,d4
	bsr	l000052
	tst.w	d1
	bpl.s	l00004c
	move.l	A.318b4,a0
	add.w	#496,d0
	bra.s	l00004b

l00004c	move.l	(sp)+,a0
	move.b	#47,-1(a0)
	move.l	a0,A.318a8
	bra	l000049

l00004d	moveq	#0,d7
	rts

l00004e	move.l	(sp)+,a0
	move.b	#47,-1(a0)
	moveq	#-1,d7
	rts

l00004f	move.l	A.318ac,a2

l000050	move.l	A.318b4,a0
	move.l	16(a0,d0.w),d0
	bsr	l00005a
	move.l	12(a0,d0.w),d1
	subq.w	#1,d1
	lea	24(a0,d0.w),a3

l000051	move.b	(a3)+,(a2)+
	dbra	d1,l000051
	cmp.l	#$1e8,12(a0,d0.w)
	beq.s	l000050
	rts

l000052	move.l	A.318b4,a0
	add.w	d0,a0
	add.w	#433,a0
	move.l	A.318a8,a1
	moveq	#0,d1

l000053	tst.b	(a1)
	beq.s	l000054
	move.b	(a0)+,d2
	bsr	l000058
	move.b	d2,d3
	move.b	(a1)+,d2
	bsr	l000058
	cmp.b	d2,d3
	beq.s	l000053
	moveq	#-1,d1

l000054	rts

l000055	movem.l	d1-d2/a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0

l000056	addq.w	#1,d0
	tst.b	(a1)+
	bne.s	l000056
	moveq	#0,d2
	move.w	d0,d1
	subq.w	#1,d1

l000057	mulu	#13,d0
	move.b	(a0)+,d2
	bsr	l000058
	add.w	d2,d0
	and.w	#2047,d0
	dbra	d1,l000057
	divu	#72,d0
	swap	d0
	addq.w	#6,d0
	movem.l	(sp)+,d1-d2/a1
	rts

l000058	cmp.b	#97,d2
	bcs.s	l000059
	cmp.b	#122,d2
	bhi.s	l000059
	sub.b	#32,d2

l000059	rts

l00005a	moveq	#0,d1
	move.w	d0,d1
	divu	#11,d1
	cmp.w	A.318b8,d1
	beq.s	l00005b
	movem.w	d0-d1,-(sp)
	move.w	d1,A.318b8
	move.l	A.318b4,a1
	bsr	l00005c
	movem.w	(sp)+,d0-d1

l00005b	mulu	#11,d1
	sub.w	d1,d0
	lsl.w	#8,d0
	lsl.w	#1,d0
	rts

l00005c	move.w	d1,d0
	bsr	l000065
	bsr	l000071
	rts

	bsr	l000062

l00005d	move.b	$bfe001,d0
	btst	#4,d0
	beq.s	l00005e
	bsr	l00006a
	bra.s	l00005d

l00005e	clr.w	A.318a2
	bsr	l000064
	rts

l00005f	move.w	d0,-(sp)
	move.b	#126,$bfdd00
	move.b	#0,$bfdf00
	move.w	(sp)+,d0
	move.b	d0,$bfd600
	lsr.w	#8,d0
	move.b	d0,$bfd700
	move.b	#9,$bfdf00

l000060	btst	#0,$bfdf00
	bne.s	l000060
	rts


	bsr	l000062
	move.w	d1,d0
	bsr	l000065

l000061	move.w	d7,-(sp)
	bsr	l000071
	lea	5632(a1),a1
	bsr	l00006c
	move.w	(sp)+,d7
	subq.w	#1,d7
	bne.s	l000061
	bsr	l000064
	rts

l000062	move.w	d1,-(sp)
	move.w	#$8010,$dff000+dmacon
	move.b	#$7f,$bfd100
	move.b	#$77,$bfd100
	moveq	#9,d1

l000063	move.w	#35796,d0
	bsr	l00005f
	dbra	d1,l000063
	move.w	(sp)+,d1
	rts

l000064	dc.w	$13fc
	dc.w	$ffff
	dc.w	$00bf
	addx.b	d0,d0
	dc.w	$13fc
	dc.w	$fff7
	dc.w	$00bf
	addx.b	d0,d0
	dc.w	$13fc
	dc.w	$ffff
	dc.w	$00bf
	addx.b	d0,d0
	rts

l000065	move.w	A.318a2,d1
	move.w	d1,d2
	and.w	#1,d2
	lsl.w	#2,d2
	eor.b	#119,d2
	move.b	d2,$bfd100
	cmp.w	d1,d0
	blt.s	l000067
	beq.s	l000069
	sub.w	d1,d0
	move.w	d0,d1
	subq.w	#1,d1

l000066	bsr	l00006c
	dbra	d1,l000066
	rts

l000067	sub.w	d0,d1
	subq.w	#1,d1

l000068	bsr	l00006a
	dbra	d1,l000068

l000069	rts

l00006a	move.w	A.318a2,d0
	move.w	#930,d2
	and.w	#1,d0
	bne.s	l00006b
	move.w	#2148,d2
	move.b	#115,$bfd100
	move.b	#114,$bfd100

l00006b	move.b	#115,$bfd100
	subq.w	#1,A.318a2
	move.w	A.318a2,d0
	and.w	#1,d0
	lsl.w	#2,d0
	eor.b	#4,d0
	or.b	d0,$bfd100
	move.w	d2,d0
	bsr	l00005f
	rts

l00006c	move.w	A.318a2,d0
	move.w	#930,d2
	and.w	#1,d0
	beq.s	l00006d
	move.w	#2148,d2
	move.b	#113,$bfd100
	move.b	#112,$bfd100

l00006d	move.b	#113,$bfd100
	addq.w	#1,A.318a2
	move.w	A.318a2,d0
	and.w	#1,d0
	lsl.w	#2,d0
	eor.b	#4,d0
	or.b	d0,$bfd100
	move.w	d2,d0
	bsr	l00005f
	rts

l00006e	bsr	l000062

l00006f	move.b	$bfe001,d0
	btst	#4,d0
	beq.s	l000070
	bsr	l00006a
	bra.s	l00006f

l000070	clr.w	A.318a2
	bsr	l000064
	rts

l000071	movem.l	d0-d7/a0-a5,-(sp)

l000072	moveq	#10,d5
	lea	$dff000+dsklen,a3
	move.w	#2,intena-dsklen(a3)
	move.w	#2,intreq-dsklen(a3)
	move.l	A.318a4,a5
	move.l	a5,dskpth-dsklen(a3)
	move.w	#$8010,dmacon-dsklen(a3)
	move.w	#$4489,d4
	move.w	d4,dsksync-dsklen(a3)
	move.w	#$9500,adkcon-dsklen(a3)
	clr.w	(a3)
	move.w	#$9980,(a3)
	move.w	#$9980,(a3)

l000073	btst	#1,intreqr+1-dsklen(a3)
	beq.s	l000073

l000074	cmp.w	(a5)+,d4
	bne.s	l000074
	cmp.w	(a5),d4
	beq.s	l000074
	move.l	#$55555555,d7
	move.l	(a5),d0
	move.l	4(a5),d1
	and.l	d7,d0
	add.l	d0,d0
	and.l	d7,d1
	or.l	d1,d0
	add.l	d0,d0
	and.w	#7680,d0
	lea	0(a1,d0.w),a2
	lea	52(a5),a5
	move.l	(a5)+,d2
	moveq	#$7f,d3

l000075	move.l	512(a5),d1
	eor.l	d1,d2
	move.l	(a5)+,d0
	eor.l	d0,d2
	and.l	d7,d0
	add.l	d0,d0
	and.l	d7,d1
	or.l	d1,d0
	move.l	d0,(a2)+
	dbra	d3,l000075
	and.l	d7,d2
	bne	l000072
	dbra	d5,l000074
	movem.l	(sp)+,d0-d7/a0-a5
	rts

A.318a2	dc.w	0
A.318a4	dc.l	0
A.318a8	dc.l	0
A.318ac	dc.l	0
A.318b0	dc.l	0
A.318b4	dc.l	0
A.318b8	dc.w	$ffff

l000076	move.l	-(a0),a2
	add.l	a1,a2
	tst.l	-(a0)
	move.l	-(a0),d0

l000077	moveq	#3,d1
	bsr	l00008a
	tst.w	d2
	beq.s	l00007e
	cmp.w	#7,d2
	bne.s	l00007a
	lsr.l	#1,d0
	bne.s	l000078
	bsr	l000089

l000078	bcc.s	l000079
	moveq	#10,d1
	bsr	l00008a
	tst.w	d2
	bne.s	l00007a
	moveq	#18,d1
	bsr	l00008a
	bra.s	l00007a

l000079	moveq	#4,d1
	bsr	l00008a
	addq.w	#7,d2

l00007a	subq.w	#1,d2

l00007b	moveq	#7,d1

l00007c	lsr.l	#1,d0
	beq.s	l00007d
	roxl.l	#1,d3
	dbra	d1,l00007c
	move.b	d3,-(a2)
	dbra	d2,l00007b
	bra.s	l00007e

l00007d	move.l	-(a0),d0
	move.w	#16,ccr
	roxr.l	#1,d0
	roxl.l	#1,d3
	dbra	d1,l00007c
	move.b	d3,-(a2)
	dbra	d2,l00007b

l00007e	cmp.l	a2,a1
	bge	l000088
	moveq	#2,d1
	bsr	l00008a
	moveq	#2,d3
	moveq	#8,d1
	tst.w	d2
	beq.s	l000086
	moveq	#4,d3
	cmp.w	#2,d2
	beq.s	l000083
	moveq	#3,d3
	cmp.w	#1,d2
	beq.s	l000081
	moveq	#2,d1
	bsr.s	l00008a
	cmp.w	#3,d2
	beq.s	l000080
	cmp.w	#2,d2
	beq.s	l00007f
	addq.w	#5,d2
	move.w	d2,d3
	bra.s	l000083

l00007f	moveq	#2,d1
	bsr.s	l00008a
	addq.w	#7,d2
	move.w	d2,d3
	bra.s	l000083

l000080	moveq	#8,d1
	bsr.s	l00008a
	move.w	d2,d3
	bra.s	l000083

l000081	moveq	#8,d1
	lsr.l	#1,d0
	bne.s	l000082
	bsr.s	l000089

l000082	bcs.s	l000086
	moveq	#14,d1
	bra.s	l000086

l000083	moveq	#16,d1
	lsr.l	#1,d0
	bne.s	l000084
	bsr.s	l000089

l000084	bcc.s	l000086
	moveq	#8,d1
	lsr.l	#1,d0
	bne.s	l000085
	bsr.s	l000089

l000085	bcs.s	l000086
	moveq	#12,d1

l000086	bsr.s	l00008a
	subq.w	#1,d3

l000087	move.b	-1(a2,d2.l),-(a2)
	dbra	d3,l000087
	cmp.l	a2,a1
	blt	l000077

l000088	moveq	#1,d0
	rts

l000089	move.l	-(a0),d0
	move.w	#16,ccr
	roxr.l	#1,d0
	rts

l00008a	subq.w	#1,d1
	clr.l	d2

l00008b	lsr.l	#1,d0
	beq.s	l00008c
	roxl.l	#1,d2
	dbra	d1,l00008b
	rts

l00008c	move.l	-(a0),d0
	move.w	#16,ccr
	roxr.l	#1,d0
	roxl.l	#1,d2
	dbra	d1,l00008b
	rts


	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

	dc.b	'graphics.library',0

A.319f5
	dc.b	 'Trodd.dat'

A.319fe
	dc.w	$00fe
A.31a00
	dc.l	$00000400
A.31a04
	dc.l	$00002088
A.31a08
	dc.l	$00008878
A.31a0c
	dc.l	$00009818
A.31a10
	dc.w	0
	dc.w	0
A.31a14
	dc.w	0
A.31a16
	dc.w	0
	dc.w	0
A.31a1a
	dc.w	0

Zero.Sprite.Pointers
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

CopperList1
	ds.b	1392

A.31f98	dc.w	0,0,0,0
A.31fa0	dc.w	0
A.31fa2	dc.l	0
A.31fa6	dc.w	0
A.31fa8	dc.w	0
A.31faa	dc.w	0
A.31fac	dc.l	0
A.31fb0	dc.l	$1a866
A.31fb4	dc.l	0
A.31fb8	dc.w	3

	ds.b	38

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$03,$b3,$0e,$00,$00,$00,$00,$00,$03,$b2,$7e,$00,$00
	dc.b	$00,$00,$00,$03,$b2,$c6,$00,$00,$00,$00,$00,$03,$af,$0e,$00,$00
	dc.b	$24,$80,$00,$03,$20,$8a,$00,$c2,$00,$f0,$00,$00,$00,$28,$00,$00
	dc.b	$00,$00,$00,$03,$af,$0e,$00,$00,$24,$80,$00,$03,$20,$98,$00,$c2
	dc.b	$00,$f0,$00,$00,$00,$28,$00,$00,$00,$00,$00,$03,$af,$0e,$00,$00
	dc.b	$24,$80,$00,$03,$20,$a1,$00,$c2,$00,$f0,$00,$00,$00,$28,$00,$00
	dc.b	$00,$00,$00,$03,$af,$0e,$00,$00,$24,$80,$00,$03,$20,$c3,$00,$c8
	dc.b	$00,$f0,$00,$00,$00,$28,$00,$00,$00,$00,$00,$03,$af,$0e,$00,$00
	dc.b	$24,$80,$00,$03,$20,$ab,$00,$c8,$01,$2f,$00,$00,$00,$28,$00,$00
	dc.b	$00,$00

	dc.b	'Curs:00,00 Bl',0
	dc.b	'Save As?',0
	dc.b	'Load Num?',0
	dc.b	'000',0
	dc.b	'dos.library',0
	dc.b	'po:maps/00',0
	dc.b	'Hunk:00 Y:00 X:00 Num:00 Typ:0 Ind:0 Att:000 '
	dc.b	'Wait:000',0,'00',0,'00',0,'00',0,'00',0,'00',0
	dc.b	'00',0,'00',0,'00',0,'00',0,'00',0

	dc.b	$00,$03,$af,$0e,$00,$01,$a7,$26,$00,$03,$20,$c6,$00,$01
	dc.b	$00,$00,$00,$00,$00,$28,$00,$00,$00,$00,$00,$03,$af,$0e,$00,$01
	dc.b	$9f,$a6,$00,$03,$20,$fc,$00,$02,$00,$f0,$00,$00,$00,$28,$00,$03
	dc.b	$af,$0e,$00,$01,$9f,$a6,$00,$03,$20,$ff,$00,$02,$01,$00,$00,$00
	dc.b	$00,$28,$00,$03,$af,$0e,$00,$01,$9f,$a6,$00,$03,$21,$02,$00,$02
	dc.b	$01,$10,$00,$00,$00,$28,$00,$03,$af,$0e,$00,$01,$9f,$a6,$00,$03
	dc.b	$21,$05,$00,$02,$01,$20,$00,$00,$00,$28,$00,$03,$af,$0e,$00,$01
	dc.b	$9f,$a6,$00,$03,$21,$08,$00,$02,$01,$30,$00,$00,$00,$28,$00,$03
	dc.b	$af,$0e,$00,$01,$9f,$a6,$00,$03,$21,$0b,$00,$09,$00,$f0,$00,$00
	dc.b	$00,$28,$00,$03,$af,$0e,$00,$01,$9f,$a6,$00,$03,$21,$0e,$00,$09
	dc.b	$01,$00,$00,$00,$00,$28,$00,$03,$af,$0e,$00,$01,$9f,$a6,$00,$03
	dc.b	$21,$11,$00,$09,$01,$10,$00,$00,$00,$28,$00,$03,$af,$0e,$00,$01
	dc.b	$9f,$a6,$00,$03,$21,$14,$00,$09,$01,$20,$00,$00,$00,$28,$00,$03
	dc.b	$af,$0e,$00,$01,$9f,$a6,$00,$03,$21,$17,$00,$09,$01,$30,$00,$00
	dc.b	$00,$28,$00,$00,$00,$00

	dc.b	'0001020304050607080910111213141516'
	dc.b	'0123456789ABCDEF'

	ds.w	5

* This is the start of the FORM ILBMBMHD

	dc.b	$46,$4f,$52,$4d,$00,$00,$60,$e8,$49,$4c,$42,$4d,$42,$4d
	dc.b	$48,$44,$00,$00,$00,$14,$01,$40,$00,$c8,$00,$00,$00,$00,$04,$00
	dc.b	$01,$00,$00,$00,$0a,$0b,$01,$40,$00,$c8,$43,$41,$4d,$47,$00,$00
	dc.b	$00,$04,$00,$00,$00,$00,$43,$4d,$41,$50,$00,$00,$00,$30,$60,$60
	dc.b	$60,$20,$40,$20,$40,$60,$40,$70,$a0,$70,$20,$30,$40,$40,$40,$60
	dc.b	$60,$60,$80,$80,$80,$a0,$40,$00,$00,$60,$00,$00,$80,$20,$00,$a0
	dc.b	$40,$20,$c0,$60,$20,$e0,$a0,$00,$00,$00,$00,$b0,$b0,$f0,$42,$4f
	dc.b	$44,$59,$00,$00,$60,$7c,$01,$4f,$48,$fd,$00,$07,$0f,$30,$00,$00
	dc.b	$4f,$4a,$2f,$8c,$f7,$00,$07,$28,$54,$28,$54,$28,$54,$28,$54,$fb
	dc.b	$00,$01,$14,$00,$01,$ff,$b7,$fc,$ff,$00,$cf,$fe,$ff,$1c,$b7,$ff
	dc.b	$f3,$f7,$7f,$2a,$be,$fe,$fe,$3e,$fe,$fe,$fc,$9b,$99,$9b,$99,$9b
	dc.b	$99,$9b,$99,$07,$e0,$7f,$fe,$fc,$1e,$ee,$07,$01,$e6,$37,$fd,$ff
	dc.b	$21,$e6,$07,$ff,$ff,$e6,$37,$e7,$01,$f7,$7f,$2a,$be,$fe,$fe,$3e
	dc.b	$fe,$fe,$fc,$85,$e1,$85,$e1,$85,$e1,$85,$e1,$07,$e0,$7f,$fe,$fc
	dc.b	$1e,$a2,$07,$01,$a6,$35,$fd,$ff,$11,$a6,$05,$ff,$ff,$a6,$35,$c7
	dc.b	$00,$f7,$7f,$2a,$be,$fe,$fe,$3e,$fe,$fe,$fc,$f9,$ff,$07,$07,$e0
	dc.b	$7f,$fe,$fc,$1e,$a2,$07,$27,$40,$04,$ff,$7f,$ff,$fe,$a0,$04,$7f
	dc.b	$ff,$40,$01,$c5,$41,$a2,$7f,$00,$22,$7e,$7e,$3e,$7e,$7e,$f8,$24
	dc.b	$e4,$24,$e4,$24,$e4,$24,$e4,$08,$80,$39,$52,$c4,$0c,$54,$0a,$01
	dc.b	$ff,$fb,$fd,$ff,$01,$df,$fb,$fc,$ff,$1a,$fe,$ff,$fe,$ff,$fd,$81
	dc.b	$81,$41,$81,$81,$06,$1e,$78,$de,$7b,$de,$78,$1e,$7b,$17,$18,$fe
	dc.b	$ed,$7b,$ff,$eb,$f7,$f5,$ff,$1b,$ea,$ab,$88,$ff,$d5,$3f,$19,$19
	dc.b	$59,$19,$19,$36,$4d,$f2,$cd,$f3,$cd,$f2,$4d,$f3,$1f,$f8,$80,$4d
	dc.b	$ff,$e1,$8b,$f1,$10,$9f,$f9,$01,$00,$00,$01,$1f,$f9,$80,$00,$9f
	dc.b	$fc,$0a,$aa,$08,$c0,$d5,$fe,$01,$13,$41,$01,$01,$06,$00,$40,$c0
	dc.b	$43,$c0,$40,$00,$43,$10,$18,$80,$4d,$03,$e1,$8b,$f1,$27,$4f,$48
	dc.b	$01,$3e,$1e,$08,$1f,$48,$61,$00,$4f,$32,$06,$68,$1d,$74,$7f,$ff
	dc.b	$80,$80,$40,$80,$80,$04,$28,$54,$68,$56,$68,$54,$28,$56,$07,$20
	dc.b	$45,$d2,$f7,$d4,$5f,$f2,$27,$ff,$b7,$ff,$ff,$e1,$fd,$ff,$b7,$f6
	dc.b	$ff,$ff,$cd,$ff,$f7,$f2,$ca,$aa,$be,$ff,$ff,$3f,$ff,$ff,$fa,$9b
	dc.b	$99,$fb,$9f,$fb,$99,$9b,$9f,$3f,$c4,$fe,$6d,$fd,$eb,$ff,$ff,$11
	dc.b	$e6,$37,$ff,$ff,$e1,$ff,$c6,$37,$ff,$ef,$e6,$0f,$94,$c4,$e2,$ff
	dc.b	$80,$3e,$fc,$19,$10,$32,$85,$e1,$f5,$ef,$f5,$e1,$85,$ef,$3f,$e4
	dc.b	$90,$09,$00,$00,$3f,$fc,$11,$a6,$35,$aa,$a0,$a1,$09,$c6,$35,$a0
	dc.b	$ea,$a6,$0d,$10,$c4,$62,$80,$80,$20,$fc,$01,$10,$02,$ff,$ff,$df
	dc.b	$fb,$df,$ff,$ff,$fb,$20,$1c,$90,$09,$00,$00,$30,$04,$14,$40,$04
	dc.b	$00,$2a,$0e,$b4,$05,$04,$50,$c0,$42,$28,$5f,$75,$2a,$ea,$2a,$a9
	dc.b	$80,$80,$02,$fe,$80,$0f,$24,$e4,$74,$ee,$74,$e4,$24,$ee,$1f,$a8
	dc.b	$06,$00,$04,$0a,$5a,$d0,$01,$ff,$fb,$fe,$ff,$22,$49,$ff,$fb,$e3
	dc.b	$ff,$ff,$d7,$ef,$fb,$f5,$54,$ff,$d6,$ff,$ff,$fd,$ff,$ff,$7f,$1e
	dc.b	$78,$fe,$7f,$fe,$78,$1e,$7f,$7f,$c2,$ff,$ff,$fb,$f5,$f5,$27,$27
	dc.b	$ff,$ff,$55,$7f,$5a,$7f,$5a,$ab,$fe,$d5,$d5,$52,$a6,$c2,$80,$7f
	dc.b	$d5,$56,$19,$19,$b9,$19,$19,$3b,$4d,$f2,$fd,$ff,$fd,$f2,$4d,$ff
	dc.b	$7f,$f2,$bd,$9d,$fb,$f5,$bf,$fd,$27,$9f,$f9,$55,$61,$50,$41,$5a
	dc.b	$a9,$82,$15,$95,$52,$a6,$c2,$80,$00,$d5,$56,$01,$01,$81,$01,$01
	dc.b	$03,$00,$40,$e8,$57,$e8,$40,$00,$57,$47,$0e,$ad,$9d,$fb,$f5,$a0
	dc.b	$05,$27,$4f,$48,$aa,$be,$bf,$82,$a7,$e4,$4b,$ea,$47,$9d,$6f,$7f
	dc.b	$05,$4c,$6a,$ae,$80,$80,$86,$80,$80,$c2,$28,$54,$70,$4e,$70,$54
	dc.b	$28,$4e,$5f,$a4,$1e,$20,$1f,$ec,$75,$52,$01,$ff,$b7,$fe,$ff,$22
	dc.b	$e9,$ff,$fb,$e7,$ff,$ff,$ef,$ff,$fb,$ff,$f2,$95,$53,$ff,$ff,$79
	dc.b	$ff,$ff,$3d,$9b,$99,$ff,$bf,$ff,$99,$9b,$bf,$3f,$c2,$ff,$c7,$ff
	dc.b	$f3,$da,$a5,$14,$e6,$37,$55,$7f,$47,$3f,$47,$a3,$fa,$25,$c0,$02
	dc.b	$ce,$c9,$fa,$ff,$95,$50,$19,$19,$31,$fe,$19,$0f,$85,$e1,$fd,$ff
	dc.b	$fd,$e1,$85,$ff,$7f,$f2,$fa,$17,$3f,$f9,$1f,$fc,$11,$a6,$35,$55
	dc.b	$7f,$47,$29,$43,$81,$a0,$05,$80,$02,$ce,$c1,$fa,$80,$95,$50,$fb
	dc.b	$01,$0f,$ff,$ff,$f7,$ef,$f7,$ff,$ff,$ef,$0e,$0e,$c2,$0f,$30,$01
	dc.b	$00,$04,$27,$40,$04,$aa,$b4,$af,$c4,$af,$f4,$57,$ea,$4f,$c5,$5f
	dc.b	$79,$35,$40,$3f,$fd,$fe,$fe,$7e,$fe,$fe,$fc,$24,$e4,$7c,$ee,$7c
	dc.b	$e4,$24,$ee,$3e,$4c,$1a,$40,$52,$52,$53,$a4,$08,$ff,$fb,$ff,$eb
	dc.b	$ff,$f3,$ff,$fb,$ef,$fb,$ff,$02,$e0,$ff,$fb,$fb,$ff,$0f,$1e,$78
	dc.b	$fa,$5f,$fa,$78,$1e,$5f,$ff,$81,$7f,$a2,$fd,$a7,$bc,$53,$fc,$ff
	dc.b	$22,$9f,$ff,$d3,$f7,$1f,$e7,$4f,$ee,$cb,$8a,$ff,$ff,$fe,$ff,$ff
	dc.b	$78,$ff,$fe,$3d,$4d,$f2,$fd,$ff,$fd,$f2,$4d,$ff,$ff,$e1,$7c,$32
	dc.b	$bf,$fc,$bf,$f9,$27,$9f,$f9,$ff,$c1,$ff,$91,$f7,$c1,$87,$1f,$a7
	dc.b	$0f,$ee,$c3,$8a,$c0,$e0,$02,$ff,$ff,$78,$ff,$fe,$3d,$00,$40,$f0
	dc.b	$4f,$f0,$40,$00,$4f,$9c,$1f,$4c,$2e,$a0,$04,$a0,$01,$27,$4f,$48
	dc.b	$aa,$a0,$bf,$e4,$bf,$f4,$4f,$fa,$4f,$ed,$6f,$43,$55,$3e,$aa,$93
	dc.b	$fe,$fe,$78,$fe,$fe,$3c,$28,$54,$74,$2e,$74,$54,$28,$2e,$3c,$c6
	dc.b	$3d,$8c,$75,$b6,$7d,$52,$01,$ff,$b7,$fe,$ff,$02,$fb,$ff,$fb,$fb
	dc.b	$ff,$03,$bf,$c0,$75,$69,$fb,$ff,$0f,$9b,$99,$fb,$df,$fb,$99,$9b
	dc.b	$df,$ff,$09,$ff,$41,$da,$43,$d2,$a5,$19,$e6,$37,$ff,$ff,$ef,$af
	dc.b	$e7,$c3,$ff,$8f,$ef,$a7,$c1,$81,$aa,$ff,$3f,$fc,$99,$99,$81,$99
	dc.b	$99,$03,$85,$e1,$fe,$ff,$0a,$e1,$85,$ff,$ff,$e1,$fe,$61,$1f,$f9
	dc.b	$1f,$fc,$11,$a6,$35,$ff,$c1,$ef,$89,$e7,$c1,$9f,$8f,$af,$87,$c0
	dc.b	$81,$aa,$80,$00,$00,$fc,$81,$10,$03,$ff,$ff,$e3,$c7,$e3,$ff,$ff
	dc.b	$c7,$98,$1f,$9e,$5f,$00,$01,$00,$04,$11,$60,$02,$aa,$a0,$af,$ec
	dc.b	$af,$f0,$4f,$ea,$4f,$e5,$40,$01,$3f,$40,$b2,$68,$fb,$00,$0f,$24
	dc.b	$e4,$00,$80,$00,$e4,$24,$80,$39,$9a,$3c,$c6,$49,$52,$54,$a6,$fc
	dc.b	$ff,$00,$f3,$f9,$ff,$19,$d7,$bf,$ed,$93,$ff,$ff,$7f,$ff,$ff,$fe
	dc.b	$1e,$78,$fe,$7f,$fe,$78,$1e,$7f,$fe,$0d,$ff,$09,$b6,$a7,$bb,$53
	dc.b	$19,$ff,$ff,$55,$7f,$5f,$87,$57,$c7,$ef,$b5,$ef,$8a,$bf,$fe,$80
	dc.b	$2b,$7f,$fe,$ff,$ff,$7f,$ff,$ff,$fe,$4d,$f2,$fe,$ff,$0a,$f2,$4d
	dc.b	$ff,$ff,$c1,$ff,$e1,$bf,$fc,$bf,$f9,$27,$df,$f9,$55,$41,$5f,$81
	dc.b	$57,$c5,$8f,$95,$af,$8a,$bf,$fe,$80,$2b,$40,$02,$ff,$ff,$7f,$ff
	dc.b	$ff,$fe,$00,$40,$fe,$7f,$fe,$40,$00,$7f,$90,$3f,$98,$1f,$a0,$04
	dc.b	$a0,$01,$27,$0f,$4a,$00,$20,$0f,$e0,$0f,$fc,$5f,$c0,$5f,$e0,$1f
	dc.b	$7c,$55,$14,$20,$01,$ff,$ff,$7f,$ff,$ff,$fe,$28,$54,$78,$1e,$78
	dc.b	$54,$28,$1e,$5b,$0e,$39,$8a,$50,$02,$7a,$b2,$01,$ff,$b5,$fc,$ff
	dc.b	$12,$f3,$ff,$ff,$cf,$ff,$ff,$fb,$fe,$eb,$c0,$02,$ff,$ff,$df,$ff
	dc.b	$ff,$fd,$9b,$99,$fe,$ff,$0a,$99,$9b,$ff,$bc,$15,$fe,$1d,$e0,$07
	dc.b	$d5,$47,$11,$e6,$37,$55,$7f,$47,$07,$43,$97,$ff,$85,$ef,$a2,$9e
	dc.b	$f0,$aa,$eb,$7f,$fe,$fb,$ff,$0f,$85,$e1,$e3,$c7,$e3,$e1,$85,$c7
	dc.b	$ff,$c9,$ff,$c1,$3f,$fd,$1f,$fc,$14,$a6,$35,$55,$41,$47,$05,$43
	dc.b	$81,$af,$85,$8f,$82,$8e,$f0,$aa,$eb,$40,$02,$ff,$ff,$bf,$fc,$ff
	dc.b	$0d,$e3,$c7,$e3,$ff,$ff,$c7,$80,$3f,$90,$3f,$20,$05,$00,$04,$27
	dc.b	$40,$04,$aa,$a0,$af,$e0,$8f,$e4,$7f,$c2,$67,$c5,$1e,$7c,$54,$3e
	dc.b	$85,$53,$ff,$ff,$1f,$ff,$ff,$fc,$24,$e4,$74,$ae,$74,$e4,$24,$ae
	dc.b	$05,$88,$5b,$0e,$54,$0e,$55,$44,$11,$ff,$fb,$55,$7f,$5f,$ff,$7f
	dc.b	$fb,$df,$fd,$df,$fa,$ff,$fb,$ff,$c0,$7a,$af,$fc,$cc,$10,$cd,$1e
	dc.b	$78,$fa,$5f,$fa,$78,$1e,$5f,$bb,$65,$bc,$15,$ab,$f7,$fa,$b3,$27
	dc.b	$ff,$ff,$55,$7f,$58,$27,$58,$0f,$c7,$55,$f7,$0a,$a0,$ca,$aa,$ff
	dc.b	$7a,$af,$33,$33,$f3,$33,$33,$37,$4d,$f2,$e3,$c7,$e3,$f2,$4d,$c7
	dc.b	$fe,$59,$ff,$c9,$ab,$f0,$bf,$f9,$14,$9f,$f9,$55,$41,$50,$05,$50
	dc.b	$09,$87,$15,$97,$0a,$a0,$c2,$aa,$80,$7a,$ae,$33,$33,$b3,$fe,$33
	dc.b	$0f,$00,$40,$e2,$47,$e2,$40,$00,$47,$82,$7f,$80,$3f,$ab,$f0,$a0
	dc.b	$01,$27,$7f,$f0,$00,$34,$27,$c0,$37,$fc,$7f,$98,$43,$cc,$0e,$76
	dc.b	$5a,$e1,$2c,$af,$cc,$cc,$2c,$cc,$cc,$ca,$28,$54,$60,$46,$60,$54
	dc.b	$28,$46,$3a,$5c,$06,$08,$10,$c2,$5c,$d2,$fe,$ff,$24,$eb,$df,$ff
	dc.b	$cf,$e3,$df,$e7,$ef,$f3,$ff,$f9,$f7,$7e,$df,$da,$cc,$cc,$ec,$cc
	dc.b	$cc,$cf,$9b,$99,$ff,$bf,$ff,$99,$9b,$bf,$c7,$ab,$b8,$25,$ff,$fd
	dc.b	$f3,$25,$fd,$ff,$23,$c4,$47,$c4,$2f,$d0,$87,$f8,$43,$80,$c0,$80
	dc.b	$7f,$c2,$03,$ff,$ff,$9f,$ff,$ff,$fd,$85,$e1,$c5,$e3,$c5,$e1,$85
	dc.b	$e3,$fc,$33,$ff,$99,$aa,$15,$bf,$fd,$14,$b8,$01,$ff,$c1,$c0,$05
	dc.b	$c0,$01,$80,$07,$88,$03,$80,$c0,$80,$40,$c2,$00,$33,$33,$b3,$fe
	dc.b	$33,$0f,$ff,$ff,$c7,$e3,$c7,$ff,$ff,$e3,$c4,$3f,$80,$7f,$aa,$15
	dc.b	$a0,$05,$27,$6c,$36,$00,$3e,$02,$28,$2b,$ac,$6e,$08,$41,$80,$56
	dc.b	$6d,$14,$02,$01,$43,$33,$33,$53,$33,$33,$30,$24,$e4,$48,$d2,$48
	dc.b	$e4,$24,$d2,$06,$20,$38,$38,$7f,$be,$60,$04,$01,$fb,$d9,$fe,$ff
	dc.b	$0f,$d7,$d7,$c3,$df,$f7,$f7,$ff,$af,$f2,$fb,$c0,$ff,$fe,$ff,$ff
	dc.b	$bf,$fe,$ff,$0f,$1e,$78,$f6,$6f,$f6,$78,$1e,$6f,$47,$ca,$40,$6a
	dc.b	$ff,$7f,$d0,$03,$fd,$ff,$23,$d5,$57,$d2,$9f,$ca,$17,$fd,$8f,$a2
A.329c8
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	dc.b	$80,$40,$20,$10,$08,$04,$02,$01,$f5


;""""""""""""""""""""""
;" HARDWARE REGISTERS "
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
color3	equ	$186
color4	equ	$188
color8	equ	$190
color16	equ	$1a0
