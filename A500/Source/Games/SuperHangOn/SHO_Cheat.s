
main	lea	start1,a0
	move.l	#$40000,a1
	move.l	#67,d0
loop1	move.w	(a0)+,(a1)+
	dbra	d0,loop1

	lea	start2,a0
	move.l	#$71fca,a1
	move.l	#13,d0
loop2	move.w	(a0)+,(a1)+
	dbra	d0,loop2

	lea	start3,a0
	move.l	#$200,a1
	move.l	#11,d0
loop3	move.w	(a0)+,(a1)+
	dbra	d0,loop3

loop4	btst	#6,$bfe001
	bne	loop4
	jmp	$40000


start1	dc.w	$6100,$003e,$337c,$0002,$001c,$42a9,$002c,$237c,$0000
	dc.w	$0400,$0024,$237c,$0003,$0000,$0028,$4eae,$fe38,$23fc
	dc.w	$0004,$0032,$0003,$021a,$4ef9,$0003,$000c,$33fc,$6890
	dc.w	$0007,$2038,$4ef9,$0007,$2000,$2c79,$0000,$0004,$93c9
	dc.w	$4eae,$feda,$45fa,$009c,$2480,$43fa,$0086,$4eae,$fe9e
	dc.w	$43fa,$002e,$4280,$4281,$41fa,$0014,$4eae,$fe44,$43fa
	dc.w	$001e,$45fa,$006a,$234a,$000e,$4e75,$7472,$6163,$6b64
	dc.w	$6973,$6b2e,$6465,$7669,$6365

start2	dc.w	$0c79,$4ef9,$0007,$2222,$6600,$003e,$23fc,$0000,$0200
	dc.w	$0007,$2224,$4ef9,$0007,$2012

start3	dc.w	$23fc,$11fc,$0035,$0000,$500c,$23fc,$6d36,$4e75,$0000
	dc.w	$5010,$4ef8,$0300
