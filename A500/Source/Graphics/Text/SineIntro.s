	section SineIntro,code_c
	opt	o+,o3-



start	bset	#1,$bfe001		low pass filter off

	bsr	mt_init

	move.l	4.w,a6
	move.l	#2*44*272+46*15,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
	add.l	#44*272,d0
	move.l	d0,screen2
	add.l	#44*272,d0
	move.l	d0,scrollbarrel

	move.l	4.w,a6
	jsr	-132(a6)		turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	andi.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz		division-by-zero exception handler
	move.l	#rteins,$14.w		set to rte instruction

	move.l	screen1(pc),d0		set up bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h

	move.w	#$1200,bplcon0(a6)	initialise screen
	move.w	#$2071,diwstrt(a6)
	move.w	#$30d1,diwstop(a6)
	move.w	#$30,ddfstrt(a6)
	move.w	#$d8,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
;	move.w	d0,bpl2mod(a6)
	move.w	d0,color0(a6)



;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		ownblitter

	move.l	gfxbase(pc),a1
	move.l	38(a1),oldcopper

	lea	$dff000,a6
	move.l	#new,cop1lc(a6)
	clr.w	copjmp1(a6)
	move.w	#$83c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old
	move.l	#level3,$6c.w



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	btst	#2,potgor(a6)		right mouse button
	beq.s	pause
	bsr	docopperbars
	bsr	scroll
	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait
	bsr	swap.screens
pause	btst	#6,$bfe001		left mouse button
	bne.s	loop

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2


	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	moveq	#0,d0
	move.w	d0,aud0vol(a6)
	move.w	d0,aud1vol(a6)
	move.w	d0,aud2vol(a6)
	move.w	d0,aud3vol(a6)

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)		turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#2*44*272+46*15,d0
	jsr	-210(a6)		FreeMem

	bclr	#1,$bfe001		low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	bsr	mt_music

	move.w	#1,nextframe

	movem.l	(sp)+,d0-d7/a0-a6
rteins	rte



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

scroll	move.w	scrollpause(pc),d0
	beq.s	movebarrel
	subq.w	#1,d0
	move.w	d0,scrollpause
	bra.s	sinscroll

movebarrel
	move.l	scrollbarrel(pc),a0
bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin
	move.l	a0,bltdpth(a6)
	addq.l	#2,a0
	move.l	a0,bltapth(a6)
	moveq	#-1,d0
	move.l	d0,bltafwm(a6)
	moveq	#0,d0
	move.l	d0,bltamod(a6)
	move.l	#$c9f00000,bltcon0(a6)
	move.w	#15*64+23,bltsize(a6)

	move.w	countdown(pc),d0
	beq	getnewchar
	subq.w	#1,d0
	move.w	d0,countdown

sinscroll
	btst	#6,dmaconr(a6)		clear old data from screen
	bne.s	sinscroll
	move.l	screen1(pc),bltdpth(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)
	move.w	#272*64+22,bltsize(a6)

	move.l	sinptr(pc),a3
	subq.l	#4,a3
	tst.w	(a3)
	bpl.s	notsineend
	lea	sintabend(pc),a3
notsineend
	move.l	a3,sinptr
	moveq	#22-1,d0		22 characters on screen
	move.l	scrollbarrel(pc),a0
	move.l	screen1(pc),a1
	move.w	#15*64+1,d1		size of each blit is 16 by 15 pixels

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2
	move.w	#44,bltamod(a6)		46-2
	move.w	#42,bltdmod(a6)		44-2
	move.w	#42,bltbmod(a6)		44-2

sineloop
	bsr	getsinval
sine1	btst	#6,dmaconr(a6)
	bne.s	sine1
	move.l	a0,bltapth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$8000,bltafwm(a6)
	move.w	#$9f0,bltcon0(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine2	btst	#6,dmaconr(a6)
	bne.s	sine2
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$4000,bltafwm(a6)
	move.w	#$dfc,bltcon0(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine3	btst	#6,dmaconr(a6)
	bne.s	sine3
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$2000,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine4	btst	#6,dmaconr(a6)
	bne.s	sine4
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$1000,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine5	btst	#6,dmaconr(a6)
	bne.s	sine5
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$800,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine6	btst	#6,dmaconr(a6)
	bne.s	sine6
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$400,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine7	btst	#6,dmaconr(a6)
	bne.s	sine7
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$200,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine8	btst	#6,dmaconr(a6)
	bne.s	sine8
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$100,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sine9	btst	#6,dmaconr(a6)
	bne.s	sine9
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$80,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sineA	btst	#6,dmaconr(a6)
	bne.s	sineA
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$40,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sineB	btst	#6,dmaconr(a6)
	bne.s	sineB
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$20,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sineC	btst	#6,dmaconr(a6)
	bne.s	sineC
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$10,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	getsinval
sineD	btst	#6,dmaconr(a6)
	bne.s	sineD
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$8,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	getsinval
sineE	btst	#6,dmaconr(a6)
	bne.s	sineE
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$4,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	getsinval
sineF	btst	#6,dmaconr(a6)
	bne.s	sineF
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$2,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	getsinval
sine10	btst	#6,dmaconr(a6)
	bne.s	sine10
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$1,bltafwm(a6)
	move.w	d1,bltsize(a6)

	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,sineloop
	rts


getsinval
	move.w	(a3)+,d2
	tst.w	(a3)
	bpl.s	notsineend2
	lea	sintab(pc),a3
notsineend2
	lea	(a1,d2.w),a2
	rts


getnewchar
	move.w	#4-1,countdown
	move.l	scrollbarrel(pc),a1
	add.l	#44,a1
	bsr.s	charaddress
	moveq	#15-1,d0
splatchar
	move.w	(a0),(a1)
	lea	40(a0),a0
	lea	46(a1),a1
	dbra	d0,splatchar
	bra	sinscroll


charaddress
	move.l	mesptr(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0

	cmp.b	#255,d0
	bne.s	notendchar
	lea	message(pc),a0
	moveq	#32,d0
	bra.s	notpausechar

notendchar
	cmp.b	#254,d0
	bne.s	notpausechar
	move.w	#200,scrollpause
	moveq	#32,d0

notpausechar
	move.l	a0,mesptr
	lea	font(pc),a0
	sub.b	#32,d0
	divu	#20,d0			20 characters on each line
	move.w	d0,d1
	mulu	#40*16,d1		each character is 16 pixels high
	add.w	d1,a0
	swap	d0
	add.w	d0,d0
	add.w	d0,a0
	rts


countdown	dc.w	0
scrollpause	dc.w	0


mesptr	dc.l	message
message
	dc.b	"       WELCOME        ",254,"   TO MY NEW INTRO    ",254
	dc.b	"WRITTEN BY  % DANIEL VERNON %   ",254
	dc.b	"THE MUSIC WAS RIPPED FROM   $ THE HEAVY DEMO $  ",254
	dc.b	"      PRESS LEFT BUTTON TO QUIT                                    ",255
	even


sinptr	dc.l	sintabend

; table of sine values from 0 to 256, multiplied by bytes per line (i.e. 44)
;
; 600 values

	dc.w	$ffff
sintab	dc.w	$1600,$162c,$1684,$16b0,$16dc,$1734,$1760,$178c,$17e4,$1810,$183c,$1894,$18c0,$18ec,$1944,$1970
	dc.w	$199c,$19f4,$1a20,$1a4c,$1aa4,$1ad0,$1afc,$1b54,$1b80,$1bac,$1bd8,$1c30,$1c5c,$1c88,$1ce0,$1d0c
	dc.w	$1d38,$1d64,$1dbc,$1de8,$1e14,$1e40,$1e98,$1ec4,$1ef0,$1f1c,$1f48,$1fa0,$1fcc,$1ff8,$2024,$2050
	dc.w	$20a8,$20d4,$2100,$212c,$2158,$2184,$21dc,$2208,$2234,$2260,$228c,$22b8,$22e4,$2310,$233c,$2368
	dc.w	$23c0,$23ec,$2418,$2444,$2470,$249c,$24c8,$24f4,$2520,$254c,$2578,$25a4,$25a4,$25d0,$25fc,$2628
	dc.w	$2654,$2680,$26ac,$26d8,$2704,$2704,$2730,$275c,$2788,$27b4,$27e0,$27e0,$280c,$2838,$2864,$2864
	dc.w	$2890,$28bc,$28bc,$28e8,$2914,$2940,$2940,$296c,$296c,$2998,$29c4,$29c4,$29f0,$29f0,$2a1c,$2a1c
	dc.w	$2a48,$2a74,$2a74,$2a74,$2aa0,$2aa0,$2acc,$2acc,$2af8,$2af8,$2b24,$2b24,$2b24,$2b50,$2b50,$2b50
	dc.w	$2b7c,$2b7c,$2b7c,$2b7c,$2ba8,$2ba8,$2ba8,$2ba8,$2bd4,$2bd4,$2bd4,$2bd4,$2bd4,$2bd4,$2c00,$2c00
	dc.w	$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2c00,$2bd4
	dc.w	$2bd4,$2bd4,$2bd4,$2bd4,$2bd4,$2ba8,$2ba8,$2ba8,$2ba8,$2b7c,$2b7c,$2b7c,$2b7c,$2b50,$2b50,$2b50
	dc.w	$2b24,$2b24,$2b24,$2af8,$2af8,$2acc,$2acc,$2aa0,$2aa0,$2a74,$2a74,$2a74,$2a48,$2a1c,$2a1c,$29f0
	dc.w	$29f0,$29c4,$29c4,$2998,$296c,$296c,$2940,$2940,$2914,$28e8,$28bc,$28bc,$2890,$2864,$2864,$2838
	dc.w	$280c,$27e0,$27e0,$27b4,$2788,$275c,$2730,$2704,$2704,$26d8,$26ac,$2680,$2654,$2628,$25fc,$25d0
	dc.w	$25a4,$25a4,$2578,$254c,$2520,$24f4,$24c8,$249c,$2470,$2444,$2418,$23ec,$23c0,$2368,$233c,$2310
	dc.w	$22e4,$22b8,$228c,$2260,$2234,$2208,$21dc,$2184,$2158,$212c,$2100,$20d4,$20a8,$2050,$2024,$1ff8
	dc.w	$1fcc,$1fa0,$1f48,$1f1c,$1ef0,$1ec4,$1e98,$1e40,$1e14,$1de8,$1dbc,$1d64,$1d38,$1d0c,$1ce0,$1c88
	dc.w	$1c5c,$1c30,$1bd8,$1bac,$1b80,$1b54,$1afc,$1ad0,$1aa4,$1a4c,$1a20,$19f4,$199c,$1970,$1944,$18ec
	dc.w	$18c0,$1894,$183c,$1810,$17e4,$178c,$1760,$1734,$16dc,$16b0,$1684,$162c,$1600,$15d4,$157c,$1550
	dc.w	$1524,$14cc,$14a0,$1474,$141c,$13f0,$13c4,$136c,$1340,$1314,$12bc,$1290,$1264,$120c,$11e0,$11b4
	dc.w	$115c,$1130,$1104,$10ac,$1080,$1054,$1028,$0fd0,$0fa4,$0f78,$0f20,$0ef4,$0ec8,$0e9c,$0e44,$0e18
	dc.w	$0dec,$0dc0,$0d68,$0d3c,$0d10,$0ce4,$0cb8,$0c60,$0c34,$0c08,$0bdc,$0bb0,$0b58,$0b2c,$0b00,$0ad4
	dc.w	$0aa8,$0a7c,$0a24,$09f8,$09cc,$09a0,$0974,$0948,$091c,$08f0,$08c4,$0898,$0840,$0814,$07e8,$07bc
	dc.w	$0790,$0764,$0738,$070c,$06e0,$06b4,$0688,$065c,$065c,$0630,$0604,$05d8,$05ac,$0580,$0554,$0528
	dc.w	$04fc,$04fc,$04d0,$04a4,$0478,$044c,$0420,$0420,$03f4,$03c8,$039c,$039c,$0370,$0344,$0344,$0318
	dc.w	$02ec,$02c0,$02c0,$0294,$0294,$0268,$023c,$023c,$0210,$0210,$01e4,$01e4,$01b8,$018c,$018c,$018c
	dc.w	$0160,$0160,$0134,$0134,$0108,$0108,$00dc,$00dc,$00dc,$00b0,$00b0,$00b0,$0084,$0084,$0084,$0084
	dc.w	$0058,$0058,$0058,$0058,$002c,$002c,$002c,$002c,$002c,$002c,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$002c,$002c,$002c,$002c,$002c
	dc.w	$002c,$0058,$0058,$0058,$0058,$0084,$0084,$0084,$0084,$00b0,$00b0,$00b0,$00dc,$00dc,$00dc,$0108
	dc.w	$0108,$0134,$0134,$0160,$0160,$018c,$018c,$018c,$01b8,$01e4,$01e4,$0210,$0210,$023c,$023c,$0268
	dc.w	$0294,$0294,$02c0,$02c0,$02ec,$0318,$0344,$0344,$0370,$039c,$039c,$03c8,$03f4,$0420,$0420,$044c
	dc.w	$0478,$04a4,$04d0,$04fc,$04fc,$0528,$0554,$0580,$05ac,$05d8,$0604,$0630,$065c,$065c,$0688,$06b4
	dc.w	$06e0,$070c,$0738,$0764,$0790,$07bc,$07e8,$0814,$0840,$0898,$08c4,$08f0,$091c,$0948,$0974,$09a0
	dc.w	$09cc,$09f8,$0a24,$0a7c,$0aa8,$0ad4,$0b00,$0b2c,$0b58,$0bb0,$0bdc,$0c08,$0c34,$0c60,$0cb8,$0ce4
	dc.w	$0d10,$0d3c,$0d68,$0dc0,$0dec,$0e18,$0e44,$0e9c,$0ec8,$0ef4,$0f20,$0f78,$0fa4,$0fd0,$1028,$1054
	dc.w	$1080,$10ac,$1104,$1130,$115c,$11b4,$11e0,$120c,$1264,$1290,$12bc,$1314,$1340,$136c,$13c4,$13f0
	dc.w	$141c,$1474,$14a0,$14cc,$1524,$1550,$157c
sintabend
	dc.w	$15d4,$ffff



docopperbars
	moveq	#0,d0			first clear old colour values
	moveq	#10-1,d1
	lea	barstart+6(pc),a0	start copper list address
clearloop
	move.w	d0,(a0)
	move.w	d0,12(a0)
	move.w	d0,24(a0)
	move.w	d0,36(a0)
	move.w	d0,48(a0)
	move.w	d0,60(a0)
	move.w	d0,72(a0)
	move.w	d0,84(a0)
	move.w	d0,96(a0)
	move.w	d0,108(a0)
	move.w	d0,120(a0)
	move.w	d0,132(a0)
	move.w	d0,144(a0)
	move.w	d0,156(a0)
	move.w	d0,168(a0)
	move.w	d0,180(a0)
	add.l	#192,a0			16*12
	dbra	d1,clearloop

	moveq	#7-1,d0			seven bars
	lea	barlist(pc),a2		now make new bars
makebarloop
	move.l	(a2),a0			get bar position
	addq.l	#2,a0			next value from table
	tst.w	(a0)
	bpl.s	barvalueok
	lea	barmovedata(pc),a0
	move.l	a0,(a2)+
	bsr.s	updatebarpri
	bra.s	barsupdated

barvalueok
	move.l	a0,(a2)+		save new position
barsupdated
	move.w	(a0),d1
	lea	barstart+6(pc),a1	start copper list address
	add.w	d1,a1			get destination address
	move.l	(a2)+,a0		address of bar colour values
	move.w	d0,-(sp)		save counter
	bsr.s	printbar
	move.w	(sp)+,d0		restore counter
	dbra	d0,makebarloop
	rts


updatebarpri
	lea	barlist(pc),a3
	move.l	(a3),d1			move position-pointers
	move.l	8(a3),d2
	move.l	16(a3),d3
	move.l	24(a3),d4
	move.l	32(a3),d5
	move.l	40(a3),d6
	move.l	48(a3),d7

	move.l	d1,8(a3)
	move.l	d2,24(a3)
	move.l	d3,(a3)
	move.l	d4,40(a3)
	move.l	d5,16(a3)
	move.l	d6,48(a3)
	move.l	d7,32(a3)

	addq.l	#4,a3

	move.l	(a3),d1			move colour-pointers
	move.l	8(a3),d2
	move.l	16(a3),d3
	move.l	24(a3),d4
	move.l	32(a3),d5
	move.l	40(a3),d6
	move.l	48(a3),d7

	move.l	d1,8(a3)
	move.l	d2,24(a3)
	move.l	d3,(a3)
	move.l	d4,40(a3)
	move.l	d5,16(a3)
	move.l	d6,48(a3)
	move.l	d7,32(a3)

	rts


printbar
	movem.w	(a0)+,d0-d7		write values into copper list
	move.w	d0,(a1)
	move.w	d1,12(a1)
	move.w	d2,24(a1)
	move.w	d3,36(a1)
	move.w	d4,48(a1)
	move.w	d5,60(a1)
	move.w	d6,72(a1)
	move.w	d7,84(a1)
	movem.w	(a0)+,d0-d6
	move.w	d0,96(a1)
	move.w	d1,108(a1)
	move.w	d2,120(a1)
	move.w	d3,132(a1)
	move.w	d4,144(a1)
	move.w	d5,156(a1)
	move.w	d6,168(a1)
	rts


barlist	dc.l	barmovedata+128*2,bar6data
	dc.l	barmovedata+153*2,bar7data
	dc.l	barmovedata+102*2,bar5data
	dc.l	barmovedata,bar1data
	dc.l	barmovedata+76*2,bar4data
	dc.l	barmovedata+25*2,bar2data
	dc.l	barmovedata+50*2,bar3data


bar1data
	dc.w	$100,$300,$500,$700,$900,$b00,$d00,$f00,$d00,$b00,$900,$700,$500,$300,$100
bar2data
	dc.w	$011,$033,$055,$077,$099,$0bb,$0dd,$0ff,$0dd,$0bb,$099,$077,$055,$033,$011
bar3data
	dc.w	$110,$330,$550,$770,$990,$bb0,$dd0,$ff0,$dd0,$bb0,$990,$770,$550,$330,$110
bar4data
	dc.w	$010,$030,$050,$070,$090,$0b0,$0d0,$0f0,$0d0,$0b0,$090,$070,$050,$030,$010
bar5data
	dc.w	$101,$303,$505,$707,$909,$b0b,$d0d,$f0f,$d0d,$b0b,$909,$707,$505,$303,$101
bar6data
	dc.w	$001,$003,$005,$007,$009,$00b,$00d,$00f,$00d,$00b,$009,$007,$005,$003,$001
bar7data
	dc.w	$111,$333,$555,$777,$999,$bbb,$ddd,$fff,$ddd,$bbb,$999,$777,$555,$333,$111


; table of sine values from 0 to 145, multiplied
; by bytes per line of copper list (i.e. 12)
;
; 180 values

barmovedata
	dc.w	$0000,$0000,$0000,$0000,$000c,$000c,$0018,$0018,$0024,$0030,$0030,$003c,$0048,$0054,$0060,$0078
	dc.w	$0084,$0090,$00a8,$00b4,$00cc,$00e4,$00f0,$0108,$0120,$0138,$0150,$0168,$0180,$0198,$01b0,$01c8
	dc.w	$01ec,$0204,$021c,$0240,$0258,$027c,$0294,$02ac,$02d0,$02e8,$030c,$0324,$0348,$036c,$0384,$03a8
	dc.w	$03c0,$03e4,$03fc,$0420,$0438,$0450,$0474,$048c,$04b0,$04c8,$04e0,$0504,$051c,$0534,$054c,$0564
	dc.w	$057c,$0594,$05ac,$05c4,$05dc,$05e8,$0600,$0618,$0624,$063c,$0648,$0654,$066c,$0678,$0684,$0690
	dc.w	$069c,$069c,$06a8,$06b4,$06b4,$06c0,$06c0,$06cc,$06cc,$06cc,$06cc,$06cc,$06cc,$06cc,$06c0,$06c0
	dc.w	$06b4,$06b4,$06a8,$069c,$069c,$0690,$0684,$0678,$066c,$0654,$0648,$063c,$0624,$0618,$0600,$05e8
	dc.w	$05dc,$05c4,$05ac,$0594,$057c,$0564,$054c,$0534,$051c,$0504,$04e0,$04c8,$04b0,$048c,$0474,$0450
	dc.w	$0438,$0420,$03fc,$03e4,$03c0,$03a8,$0384,$036c,$0348,$0324,$030c,$02e8,$02d0,$02ac,$0294,$027c
	dc.w	$0258,$0240,$021c,$0204,$01ec,$01c8,$01b0,$0198,$0180,$0168,$0150,$0138,$0120,$0108,$00f0,$00e4
	dc.w	$00cc,$00b4,$00a8,$0090,$0084,$0078,$0060,$0054,$0048,$003c,$0030,$0030,$0024,$0018,$0018,$000c
	dc.w	$000c,$0000,$0000,$0000,$ffff



swap.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	rts



;""""""""""""""""
;" Music Player	"
;"		"
;""""""""""""""""

mt_init	lea	mt_data(pc),a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1
	move.l	d1,d2
	subq.w	#1,d0
mt_init2
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3
	lea	mt_data(pc),a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6(pc),mt_maxpart+1
	rts

mt_music
	addq.w	#1,mt_counter
mt_cool	cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2

mt_notsix
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5
	bsr.s	mt_arprout
mt_arp1	lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2	lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3	lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4	rts

mt_arprout
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts

mt_portup
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1	move.w	22(a6),6(a5)
	rts

mt_portdwn
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2	move.w	22(a6),6(a5)
	rts

mt_volslide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3	move.w	18(a6),8(a5)
	rts
mt_voldwn
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4	move.w	18(a6),8(a5)
	rts

mt_arpegrt
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart
	move.w	d2,6(a5)
	rts

mt_rout2
	lea	mt_data(pc),a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon(pc),d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0

	move.b #$1c,eq4
	move.w (a6),eq4p

	move.w	#1,$dff0d4
mt_voice3
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0

	move.b #$1c,eq3
	move.w (a6),eq3p

	move.w	#1,$dff0c4
mt_voice2
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0

	move.b #$1c,eq2
	move.w (a6),eq2p

	move.w	#1,$dff0b4
mt_voice1
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0

	move.b #$1c,eq1
	move.w (a6),eq1p

	move.w	#1,$dff0a4
mt_voice0
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
mt_stop	tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2
	rts

mt_playit
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol
	move.b	3(a6),8(a5)
	rts

mt_break
	not.w	mt_status
	rts

mt_setfil
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back	rts

mt_aud1temp
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote	dc.l	0
mt_partnrplay	dc.l	0
mt_counter	dc.w	0
mt_partpoint	dc.l	0
mt_samples	dc.l	0
mt_sample1	dcb.l	31,0
mt_maxpart	dc.w	0
mt_dmacon	dc.w	0
mt_status	dc.w	0

mt_arpeggio
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


notetable	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000

eq1	dc.b	0
eq2	dc.b	0
eq3	dc.b	0
eq4	dc.b	0
eq1p	dc.w	381
eq2p	dc.w	381
eq3p	dc.w	381
eq4p	dc.w	381
eqtab	dcb.w	40



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth		1 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0

	dc.w	color1,$8ff

	dc.w	$2201,$ff00
	dc.w	color1,$9ff

	dc.w	$2401,$ff00
	dc.w	color1,$aff

	dc.w	$2601,$ff00
	dc.w	color1,$bff

	dc.w	$2801,$ff00
	dc.w	color1,$cff

	dc.w	$2a01,$ff00
	dc.w	color1,$dff

	dc.w	$2c01,$ff00
	dc.w	color1,$eff

	dc.w	$2e01,$ff00
	dc.w	color1,$fff		White

	dc.w	$3001,$ff00
	dc.w	color1,$eff

	dc.w	$3201,$ff00
	dc.w	color1,$dff

	dc.w	$3401,$ff00
	dc.w	color1,$cff

	dc.w	$3601,$ff00
	dc.w	color1,$bff

	dc.w	$3801,$ff00
	dc.w	color1,$aff

	dc.w	$3a01,$ff00
	dc.w	color1,$9ff

	dc.w	$3c01,$ff00
	dc.w	color1,$8ff

	dc.w	$3e01,$ff00
	dc.w	color1,$7ff

	dc.w	$4001,$ff00
	dc.w	color1,$6ff

	dc.w	$4201,$ff00
	dc.w	color1,$5ff

	dc.w	$4401,$ff00
	dc.w	color1,$4ff

	dc.w	$4601,$ff00
	dc.w	color1,$3ff

	dc.w	$4801,$ff00
	dc.w	color1,$2ff

	dc.w	$4a01,$ff00
	dc.w	color1,$1ff

	dc.w	$4c01,$ff00
	dc.w	color1,$0ff		Light Blue

	dc.w	$4e01,$ff00
	dc.w	color1,$0ef

	dc.w	$5001,$ff00
	dc.w	color1,$0df

	dc.w	$5201,$ff00
	dc.w	color1,$0cf

	dc.w	$5401,$ff00
	dc.w	color1,$0bf

	dc.w	$5601,$ff00
	dc.w	color1,$0af

barstart
	dc.w	$5701,$ff00
	dc.w	color0,0
	dc.w	color1,$0af

	dc.w	$5801,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$5901,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$5a01,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$5b01,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$5c01,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$5d01,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$5e01,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$5f01,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$6001,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$6101,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$6201,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$6301,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$6401,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$6501,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$6601,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$6701,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$6801,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$6901,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$6a01,$ff00
	dc.w	color0,0
	dc.w	color1,$00f		Blue

	dc.w	$6b01,$ff00
	dc.w	color0,0
	dc.w	color1,$00f

	dc.w	$6c01,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$6d01,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$6e01,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$6f01,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$7001,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$7101,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$7201,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$7301,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$7401,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$7501,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$7601,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$7701,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$7801,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$7901,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$7a01,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$7b01,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$7c01,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$7d01,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$7e01,$ff00
	dc.w	color0,0
	dc.w	color1,$0af

	dc.w	$7f01,$ff00
	dc.w	color0,0
	dc.w	color1,$0af

	dc.w	$8001,$ff00
	dc.w	color0,0
	dc.w	color1,$0bf

	dc.w	$8101,$ff00
	dc.w	color0,0
	dc.w	color1,$0bf

	dc.w	$8201,$ff00
	dc.w	color0,0
	dc.w	color1,$0cf

	dc.w	$8301,$ff00
	dc.w	color0,0
	dc.w	color1,$0cf

	dc.w	$8401,$ff00
	dc.w	color0,0
	dc.w	color1,$0df

	dc.w	$8501,$ff00
	dc.w	color0,0
	dc.w	color1,$0df

	dc.w	$8601,$ff00
	dc.w	color0,0
	dc.w	color1,$0ef

	dc.w	$8701,$ff00
	dc.w	color0,0
	dc.w	color1,$0ef

	dc.w	$8801,$ff00
	dc.w	color0,0
	dc.w	color1,$0ff		Light Blue

	dc.w	$8901,$ff00
	dc.w	color0,0
	dc.w	color1,$0ff

	dc.w	$8a01,$ff00
	dc.w	color0,0
	dc.w	color1,$1ff

	dc.w	$8b01,$ff00
	dc.w	color0,0
	dc.w	color1,$1ff

	dc.w	$8c01,$ff00
	dc.w	color0,0
	dc.w	color1,$2ff

	dc.w	$8d01,$ff00
	dc.w	color0,0
	dc.w	color1,$2ff

	dc.w	$8e01,$ff00
	dc.w	color0,0
	dc.w	color1,$3ff

	dc.w	$8f01,$ff00
	dc.w	color0,0
	dc.w	color1,$3ff

	dc.w	$9001,$ff00
	dc.w	color0,0
	dc.w	color1,$4ff

	dc.w	$9101,$ff00
	dc.w	color0,0
	dc.w	color1,$4ff

	dc.w	$9201,$ff00
	dc.w	color0,0
	dc.w	color1,$5ff

	dc.w	$9301,$ff00
	dc.w	color0,0
	dc.w	color1,$5ff

	dc.w	$9401,$ff00
	dc.w	color0,0
	dc.w	color1,$6ff

	dc.w	$9501,$ff00
	dc.w	color0,0
	dc.w	color1,$6ff

	dc.w	$9601,$ff00
	dc.w	color0,0
	dc.w	color1,$7ff

	dc.w	$9701,$ff00
	dc.w	color0,0
	dc.w	color1,$7ff

	dc.w	$9801,$ff00
	dc.w	color0,0
	dc.w	color1,$8ff

	dc.w	$9901,$ff00
	dc.w	color0,0
	dc.w	color1,$8ff

	dc.w	$9a01,$ff00
	dc.w	color0,0
	dc.w	color1,$9ff

	dc.w	$9b01,$ff00
	dc.w	color0,0
	dc.w	color1,$9ff

	dc.w	$9c01,$ff00
	dc.w	color0,0
	dc.w	color1,$aff

	dc.w	$9d01,$ff00
	dc.w	color0,0
	dc.w	color1,$aff

	dc.w	$9e01,$ff00
	dc.w	color0,0
	dc.w	color1,$bff

	dc.w	$9f01,$ff00
	dc.w	color0,0
	dc.w	color1,$bff

	dc.w	$a001,$ff00
	dc.w	color0,0
	dc.w	color1,$cff

	dc.w	$a101,$ff00
	dc.w	color0,0
	dc.w	color1,$cff

	dc.w	$a201,$ff00
	dc.w	color0,0
	dc.w	color1,$dff

	dc.w	$a301,$ff00
	dc.w	color0,0
	dc.w	color1,$dff

	dc.w	$a401,$ff00
	dc.w	color0,0
	dc.w	color1,$eff

	dc.w	$a501,$ff00
	dc.w	color0,0
	dc.w	color1,$eff

	dc.w	$a601,$ff00
	dc.w	color0,0
	dc.w	color1,$fff		White

	dc.w	$a701,$ff00
	dc.w	color0,0
	dc.w	color1,$fff

	dc.w	$a801,$ff00
	dc.w	color0,0
	dc.w	color1,$eff

	dc.w	$a901,$ff00
	dc.w	color0,0
	dc.w	color1,$eff

	dc.w	$aa01,$ff00
	dc.w	color0,0
	dc.w	color1,$dff

	dc.w	$ab01,$ff00
	dc.w	color0,0
	dc.w	color1,$dff

	dc.w	$ac01,$ff00
	dc.w	color0,0
	dc.w	color1,$cff

	dc.w	$ad01,$ff00
	dc.w	color0,0
	dc.w	color1,$cff

	dc.w	$ae01,$ff00
	dc.w	color0,0
	dc.w	color1,$bff

	dc.w	$af01,$ff00
	dc.w	color0,0
	dc.w	color1,$bff

	dc.w	$b001,$ff00
	dc.w	color0,0
	dc.w	color1,$aff

	dc.w	$b101,$ff00
	dc.w	color0,0
	dc.w	color1,$aff

	dc.w	$b201,$ff00
	dc.w	color0,0
	dc.w	color1,$9ff

	dc.w	$b301,$ff00
	dc.w	color0,0
	dc.w	color1,$9ff

	dc.w	$b401,$ff00
	dc.w	color0,0
	dc.w	color1,$8ff

	dc.w	$b501,$ff00
	dc.w	color0,0
	dc.w	color1,$8ff

	dc.w	$b601,$ff00
	dc.w	color0,0
	dc.w	color1,$7ff

	dc.w	$b701,$ff00
	dc.w	color0,0
	dc.w	color1,$7ff

	dc.w	$b801,$ff00
	dc.w	color0,0
	dc.w	color1,$6ff

	dc.w	$b901,$ff00
	dc.w	color0,0
	dc.w	color1,$6ff

	dc.w	$ba01,$ff00
	dc.w	color0,0
	dc.w	color1,$5ff

	dc.w	$bb01,$ff00
	dc.w	color0,0
	dc.w	color1,$5ff

	dc.w	$bc01,$ff00
	dc.w	color0,0
	dc.w	color1,$4ff

	dc.w	$bd01,$ff00
	dc.w	color0,0
	dc.w	color1,$4ff

	dc.w	$be01,$ff00
	dc.w	color0,0
	dc.w	color1,$3ff

	dc.w	$bf01,$ff00
	dc.w	color0,0
	dc.w	color1,$3ff

	dc.w	$c001,$ff00
	dc.w	color0,0
	dc.w	color1,$2ff

	dc.w	$c101,$ff00
	dc.w	color0,0
	dc.w	color1,$2ff

	dc.w	$c201,$ff00
	dc.w	color0,0
	dc.w	color1,$1ff

	dc.w	$c301,$ff00
	dc.w	color0,0
	dc.w	color1,$1ff

	dc.w	$c401,$ff00
	dc.w	color0,0
	dc.w	color1,$0ff		Light Blue

	dc.w	$c501,$ff00
	dc.w	color0,0
	dc.w	color1,$0ff

	dc.w	$c601,$ff00
	dc.w	color0,0
	dc.w	color1,$0ef

	dc.w	$c701,$ff00
	dc.w	color0,0
	dc.w	color1,$0ef

	dc.w	$c801,$ff00
	dc.w	color0,0
	dc.w	color1,$0df

	dc.w	$c901,$ff00
	dc.w	color0,0
	dc.w	color1,$0df

	dc.w	$ca01,$ff00
	dc.w	color0,0
	dc.w	color1,$0cf

	dc.w	$cb01,$ff00
	dc.w	color0,0
	dc.w	color1,$0cf

	dc.w	$cc01,$ff00
	dc.w	color0,0
	dc.w	color1,$0bf

	dc.w	$cd01,$ff00
	dc.w	color0,0
	dc.w	color1,$0bf

	dc.w	$ce01,$ff00
	dc.w	color0,0
	dc.w	color1,$0af

	dc.w	$cf01,$ff00
	dc.w	color0,0
	dc.w	color1,$0af

	dc.w	$d001,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$d101,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$d201,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$d301,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$d401,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$d501,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$d601,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$d701,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$d801,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$d901,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$da01,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$db01,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$dc01,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$dd01,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$de01,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$df01,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$e001,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$e101,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$e201,$ff00
	dc.w	color0,0
	dc.w	color1,$00f		Blue

	dc.w	$e301,$ff00
	dc.w	color0,0
	dc.w	color1,$00f

	dc.w	$e401,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$e501,$ff00
	dc.w	color0,0
	dc.w	color1,$01f

	dc.w	$e601,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$e701,$ff00
	dc.w	color0,0
	dc.w	color1,$02f

	dc.w	$e801,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$e901,$ff00
	dc.w	color0,0
	dc.w	color1,$03f

	dc.w	$ea01,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$eb01,$ff00
	dc.w	color0,0
	dc.w	color1,$04f

	dc.w	$ec01,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$ed01,$ff00
	dc.w	color0,0
	dc.w	color1,$05f

	dc.w	$ee01,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$ef01,$ff00
	dc.w	color0,0
	dc.w	color1,$06f

	dc.w	$f001,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$f101,$ff00
	dc.w	color0,0
	dc.w	color1,$07f

	dc.w	$f201,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$f301,$ff00
	dc.w	color0,0
	dc.w	color1,$08f

	dc.w	$f401,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$f501,$ff00
	dc.w	color0,0
	dc.w	color1,$09f

	dc.w	$f601,$ff00
	dc.w	color0,0
	dc.w	color1,$0af
barend
	dc.w	$f701,$ff00
	dc.w	color0,0		make sure it is black

	dc.w	$f801,$ff00
	dc.w	color1,$0bf

	dc.w	$fa01,$ff00
	dc.w	color1,$0cf

	dc.w	$fc01,$ff00
	dc.w	color1,$0df

	dc.w	$fe01,$ff00
	dc.w	color1,$0ef
	dc.w	intreq,$8010

	dc.w	$ffdf,$fffe		PAL enable

	dc.w	$0001,$ff00
	dc.w	color1,$0ff		Light Blue

	dc.w	$0201,$ff00
	dc.w	color1,$1ff

	dc.w	$0401,$ff00
	dc.w	color1,$2ff

	dc.w	$0601,$ff00
	dc.w	color1,$3ff

	dc.w	$0801,$ff00
	dc.w	color1,$4ff

	dc.w	$0a01,$ff00
	dc.w	color1,$5ff

	dc.w	$0c01,$ff00
	dc.w	color1,$6ff

	dc.w	$0e01,$ff00
	dc.w	color1,$7ff

	dc.w	$1001,$ff00
	dc.w	color1,$8ff

	dc.w	$1201,$ff00
	dc.w	color1,$9ff

	dc.w	$1401,$ff00
	dc.w	color1,$aff

	dc.w	$1601,$ff00
	dc.w	color1,$bff

	dc.w	$1801,$ff00
	dc.w	color1,$cff

	dc.w	$1a01,$ff00
	dc.w	color1,$dff

	dc.w	$1c01,$ff00
	dc.w	color1,$eff

	dc.w	$1e01,$ff00
	dc.w	color1,$fff		White

	dc.w	$2001,$ff00
	dc.w	color1,$eff

	dc.w	$2201,$ff00
	dc.w	color1,$dff

	dc.w	$2401,$ff00
	dc.w	color1,$cff

	dc.w	$2601,$ff00
	dc.w	color1,$bff

	dc.w	$2801,$ff00
	dc.w	color1,$aff

	dc.w	$2a01,$ff00
	dc.w	color1,$9ff

	dc.w	$2c01,$ff00
	dc.w	color1,$8ff

	dc.w	$2e01,$ff00
	dc.w	color1,$7ff


	dc.w	$ffff,$fffe		END



;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
joy0dat	equ	$00A
joy1dat	equ	$00C
clxdat	equ	$00E
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01A
intenar	equ	$01C
intreqr	equ	$01E
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02A
vhposw	equ	$02C
copcon	equ	$02E
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03A
strhor	equ	$03C
strlong	equ	$03E
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08A
copins	equ	$08C
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
aud0vol	equ	$0A8
aud1vol	equ	$0B8
aud2vol	equ	$0C8
aud3vol	equ	$0D8
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bpl5pth	equ	$0F0
bpl5ptl	equ	$0F2
bpl6pth	equ	$0F4
bpl6ptl	equ	$0F6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
bpldat	equ	$110
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12A
spr3pth	equ	$12C
spr3ptl	equ	$12E
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13A
spr7pth	equ	$13C
spr7ptl	equ	$13E
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14A
spr2ctl	equ	$152
spr3ctl	equ	$15A
spr4ctl	equ	$162
spr5ctl	equ	$16A
spr6ctl	equ	$172
spr7ctl	equ	$17A
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
color4	equ	$188
color8	equ	$190
color16	equ	$1A0



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screenmem	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
scrollbarrel	dc.l	0
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
nextframe	dc.w	0



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even



;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

font	incbin	sinefont3

mt_data	incbin	DH0:Music/Modules/MOD.heavyzing
