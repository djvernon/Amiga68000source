	section	SineIntro,code_c
	opt	o+,o3-




start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off


	move.l	#2*44*272+46*15,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	move.l	d0,screen1
	add.l	#44*272,d0
	move.l	d0,screen2
	add.l	#44*272,d0
	move.l	d0,scroll.barrel


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c010,intena(a6)	enable copper interrupt


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	move.w	#$1200,bplcon0(a6)	initialise screen
	move.w	#$2471,diwstrt(a6)
	move.w	#$34d1,diwstop(a6)
	move.w	#$30,ddfstrt(a6)
	move.w	#$d8,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
;	move.w	d0,bpl2mod(a6)
	move.w	#$006,color1(a6)


	move.l	screen1(pc),d0		initialise copper
	lea	copper.list(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#$2401ff00,d3		wait position
	move.l	#$01800000,d4		color1, value
	move.l	#$01001200,d5		bplcon0, value
	move.l	#$01000000,d6
	move.w	#272-1,d7
	lea	wave.colours(pc),a3

clear.wave
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	add.l	d6,d3
	dbra	d7,clear.wave

	move.l	#$ffe1fffe,wave.colours+($ff-$24)*12+8
;					PAL enable

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	btst	#2,potgor(a6)
	beq.s	pause

	bsr	scroll
	bsr	wave.copper

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	bsr	swap.screens

pause	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#2*44*272+46*15,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
;	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	st	next.frame

;	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

scroll	move.w	scroll.pause(pc),d0
	beq.s	move.barrel
	subq.w	#1,d0
	move.w	d0,scroll.pause
	bra.s	sine.scroll

move.barrel
	move.l	scroll.barrel(pc),a0
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

	move.w	count.down(pc),d0
	beq	get.new.char
	subq.w	#1,d0
	move.w	d0,count.down

sine.scroll
	btst	#6,dmaconr(a6)		clear old data from screen
	bne.s	sine.scroll

	move.l	screen1(pc),bltdpth(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)
	move.w	#272*64+22,bltsize(a6)

	move.l	sine.ptr(pc),a3
	subq.l	#4,a3
	tst.w	(a3)
	bpl.s	not.sine.end
	lea	end.sine.table(pc),a3

not.sine.end
	move.l	a3,sine.ptr

	moveq	#22-1,d0		22 characters on screen
	move.l	scroll.barrel(pc),a0
	move.l	screen1(pc),a1
	move.w	#15*64+1,d1		size of each blit is 16 by 15 pixels

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

	move.w	#46-2,bltamod(a6)
	move.w	#44-2,bltdmod(a6)
	move.w	#44-2,bltbmod(a6)

sine.loop
	bsr	get.sine.value
sine1	btst	#6,dmaconr(a6)
	bne.s	sine1
	move.l	a0,bltapth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$8000,bltafwm(a6)
	move.w	#$9f0,bltcon0(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine2	btst	#6,dmaconr(a6)
	bne.s	sine2
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$4000,bltafwm(a6)
	move.w	#$dfc,bltcon0(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine3	btst	#6,dmaconr(a6)
	bne.s	sine3
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$2000,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine4	btst	#6,dmaconr(a6)
	bne.s	sine4
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$1000,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine5	btst	#6,dmaconr(a6)
	bne.s	sine5
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$800,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine6	btst	#6,dmaconr(a6)
	bne.s	sine6
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$400,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine7	btst	#6,dmaconr(a6)
	bne.s	sine7
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$200,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine8	btst	#6,dmaconr(a6)
	bne.s	sine8
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$100,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sine9	btst	#6,dmaconr(a6)
	bne.s	sine9
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$80,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sineA	btst	#6,dmaconr(a6)
	bne.s	sineA
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$40,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sineB	btst	#6,dmaconr(a6)
	bne.s	sineB
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$20,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sineC	btst	#6,dmaconr(a6)
	bne.s	sineC
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$10,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr	get.sine.value
sineD	btst	#6,dmaconr(a6)
	bne.s	sineD
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$8,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	get.sine.value
sineE	btst	#6,dmaconr(a6)
	bne.s	sineE
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$4,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	get.sine.value
sineF	btst	#6,dmaconr(a6)
	bne.s	sineF
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$2,bltafwm(a6)
	move.w	d1,bltsize(a6)

	bsr.s	get.sine.value
sine10	btst	#6,dmaconr(a6)
	bne.s	sine10
	move.l	a0,bltapth(a6)
	move.l	a2,bltbpth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#$1,bltafwm(a6)
	move.w	d1,bltsize(a6)

	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,sine.loop
	rts




get.sine.value
	move.w	(a3)+,d2
	tst.w	(a3)
	bpl.s	not.sine.end2
	lea	sine.table(pc),a3
not.sine.end2
	lea	(a1,d2.w),a2
	rts




get.new.char
	move.w	#4-1,count.down
	move.l	scroll.barrel(pc),a1
	lea	44(a1),a1
	bsr.s	char.address
	moveq	#15-1,d0

splat.char
	move.w	(a0),(a1)
	lea	40(a0),a0
	lea	46(a1),a1
	dbra	d0,splat.char
	bra	sine.scroll




char.address
	move.l	message.ptr(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0

	cmp.b	#255,d0
	bne.s	not.end.char
	lea	message(pc),a0
	moveq	#32,d0
	bra.s	not.pause.char

not.end.char
	cmp.b	#254,d0
	bne.s	not.pause.char
	move.w	#200,scroll.pause
	moveq	#32,d0

not.pause.char
	move.l	a0,message.ptr

	lea	font(pc),a0
	sub.b	#32,d0
	divu	#20,d0			20 characters on each line
	move.w	d0,d1
	mulu	#40*16,d1		each character is 16 pixels high
	add.l	d1,a0
	swap	d0
	add.w	d0,d0
	add.w	d0,a0
	rts




message.ptr	dc.l	message

message
	dc.b	"       WELCOME       ",254," TO THIS SMALL DEMO  ",254
	dc.b	"       WRITTEN BY  % DANIEL VERNON %   ",254
	dc.b	".......IN 68000 ASSEMBLY LANGUAGE."
	dc.b	"                    $ PRESS RIGHT BUTTON TO PAUSE THIS SCROLL $"
	dc.b	"                    THIS DEMO CONSISTS OF A ONE BITPLANE OVERSCAN SCREEN"
	dc.b	" (352 PIXELS WIDE, 272 TALL), A SINE SCROLL AND THE COPPER BAR WAVE "
	dc.b	"IN THE BACKGROUND, WHICH USES 272 LOTS OF COPPER WAIT FOLLOWED BY MOVE "
	dc.b	"INSTRUCTIONS TO CHANGE THE VALUE OF COLOUR REGISTER ZERO ON EACH LINE "
	dc.b	"OF THE VISIBLE SCREEN.                    "
	dc.b	"$ PRESS LEFT BUTTON TO QUIT $                             ",255
	even


sine.ptr	dc.l	end.sine.table

; table of sine values from 0 to 256, multiplied by bytes per line (i.e. 44)
;
; 600 values

	dc.w	$ffff
sine.table
	dc.w	$1600,$162c,$1684,$16b0,$16dc,$1734,$1760,$178c,$17e4,$1810,$183c,$1894,$18c0,$18ec,$1944,$1970
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
end.sine.table
	dc.w	$15d4,$ffff




wave.copper
	not.w	wave.flag
	bne.s	wave.end

	move.w	#272-1,d0
	moveq	#0,d1
	move.w	#16,d2
	lea	wave.colours+6(pc),a0
	move.l	wave.ptr(pc),a1
	move.l	a1,a2

wave.loop
	move.w	(a1)+,(a0)
	lea	12(a0),a0
	addq.w	#1,d1
	cmp.w	d2,d1
	bne.s	wave.next.line

	moveq	#0,d1

	lea	2(a2),a1
	cmp.l	#end.wave.table,a1
	bne.s	not.wave.end

	lea	wave.table(pc),a1

not.wave.end
	move.l	a1,a2

wave.next.line
	dbra	d0,wave.loop

	addq.l	#2,wave.ptr
	move.l	wave.ptr(pc),d0
	cmp.l	#end.wave.table,d0
	bne.s	wave.end

	move.l	#wave.table,wave.ptr

wave.end
	rts




swap.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	lea	copper.list(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		1 bitplane display
	dc.w	bpl1ptl,0

wave.colours
	ds.w	6*272

	dc.w	$3401,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




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
color4	equ	$188
color8	equ	$190
color16	equ	$1a0




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0

screen1		dc.l	0
screen2		dc.l	0

scroll.barrel	dc.l	0

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0

scroll.pause	dc.w	0
count.down	dc.w	0

wave.flag	dc.w	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

font	incbin	sinefont3



wave.ptr	dc.l	wave.table

wave.table
	dc.w	$ff0,$ee0,$de0,$ce0,$be0,$ae0,$9e1,$8e2
	dc.w	$7e3,$6e4,$5e5,$4e6,$3e7,$2e8,$1e9,$0ea
	dc.w	$0db,$0cc,$0bd,$0ae,$09f,$18f,$27f,$36f
	dc.w	$45f,$54f,$63f,$72f,$81f,$90f,$a0f,$b0f
	dc.w	$c0d,$d0c,$e0b,$f0a,$f19,$f28,$f37,$f46
	dc.w	$f55,$f64,$f73,$f82,$f91,$fa0,$eb0,$dc0
	dc.w	$cd0,$be0,$af0,$9f1,$8f2,$7f3,$6f4,$5f5
	dc.w	$4f6,$3f7,$2f8,$1f9,$0fa,$0eb,$0dc,$0cd
	dc.w	$0be,$0af,$19f,$28f,$37f,$46f,$55f,$64f
	dc.w	$73f,$82f,$91f,$a0f,$b0e,$c0d,$d0c,$e0b
	dc.w	$f0a,$f19,$f28,$f37,$f46,$f55,$f64,$f73
	dc.w	$f82,$f91,$fa0,$eb0,$dc0,$cd0,$be0,$af0
	dc.w	$9f1,$8f2,$7f3,$6f4,$5f5,$4f6,$3f7,$2f8
	dc.w	$1f9,$0fa,$0eb,$0dc,$0cd,$0be,$0af,$19f
	dc.w	$28f,$37f,$46f,$55f,$64f,$73f,$82f,$91f
	dc.w	$a0f,$b0e,$c0d,$d0c,$e0b,$f0a,$f19,$f28
	dc.w	$f37,$f46,$f55,$f64,$f73,$f82,$f91,$fa0
	dc.w	$fb0,$fc0,$fd0,$fe0
end.wave.table
	dc.w	$ff0,$ee0,$de0,$ce0,$be0,$ae0,$9e1,$8e2
	dc.w	$7e3,$6e4,$5e5,$4e6,$3e7,$2e8,$1e9,$0ea
