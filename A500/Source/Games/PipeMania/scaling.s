
		*** SOFTWARE SCALING OF THE XENON2 LOGO ***

start	move.l	4,a6
	move.l	#64036,d0
	move.l	#$10002,d1	chip + clear
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

	move.l	4,a6
	lea	grafname,a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	move.l	d0,a1
	move.l	38(a1),old
	move.l	4,a6
	jsr	-414(a6)	closelibrary

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
	move.l	#64036,d0
	jsr	-210(a6)	FreeMem

end	rts


cscreen	dc.l	0
pscreen	dc.l	0
size	dc.w	1


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


clear	lea	$dff000,a5
clr	btst	#6,2(a5)
	bne.s	clr
	clr.w	$66(a5)
	move.l	#$1000000,$40(a5)	USE D
	move.l	cscreen,$54(a5)
	move.w	#96*4*64+20,$58(a5)	width = 20 words
	rts


dologo	muls	size,d0		; d0 = x offset from middle of screen
	asr.w	#4,d0		; d1 = y offset from middle of screen
	add.w	#160,d0		; d2 = x width-1
				; d3 = y width-1
	muls	size,d1		; a0 = graphic data address
	asr.w	#4,d1		; size = value from 1 to 16
	add.w	#100,d1

	move.l	cscreen,a1
	lea	ytable,a2
	add.w	d1,d1
	add.w	(a2,d1.w),a1	add y offset

	move.w	d0,d1
	and.w	#$f,d0		low four bits from x offset
	sub.w	d0,d1		x offset in multiples of 16 bits
	lsr.w	#3,d1		x offset in even bytes
	add.w	d1,a1		start address

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
	and.w	#$fff0,d7
	lsr.w	#1,d7		d7 = total bytes per line of graphic
	lea	8(a0,d7.w),a0	next line + 8 bytes (width of 16 pixels) more
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
growlp	bsr	clear
	lea	logo,a0
	moveq	#-112,d0
	moveq	#-100,d1
	move.w	#207,d2
	moveq	#53,d3
	bsr	dologo
	bsr	waitframe
	addq.w	#1,size
	cmpi.w	#16,size
	ble.s	growlp
	rts


shrinklogo
	move.w	#16,size
shklp	bsr	clear
	lea	logo,a0
	moveq	#-112,d0
	moveq	#-100,d1
	move.w	#207,d2
	moveq	#53,d3
	bsr	dologo
	bsr	waitframe
	subq.w	#1,size
	bne.s	shklp
	rts


showtitles
	move.l	#199,d0		count
	moveq	#0,d1		offset starts at zero
	move.w	#160,d2		bytes per line = 160
	lea	ytable,a0
ytab	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,ytab

	movem.l	palnew,d0-d7
	movem.l	d0-d7,$dff180
	bsr	growlogo	grow the xenon2 logo
	bsr	shrinklogo	shrink the xenon2 logo
	rts


palnew	dc.w	$000,$ea6,$e84,$c64,$446,$668,$88a,$ece
	dc.w	$aac,$224,$002,$400,$600,$820,$ea0,$a42

shrinks	dc.w	0,$100,$1010,$2104,$4444,$4912,$5252,$552a,$aaaa
	dc.w	$ab55,$b5b5,$b76d,$dddd,$df7b,$f7f7,$ff7f,$ffff


logo	incbin	xenon2.bin

ytable	ds.w	200

coplist	dc.l	0
old	dc.l	0
memory	dc.l	0

grafname	dc.b	"graphics.library",0
	even
