	section	palette,code_c
	opt	o+,o3-




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem

	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts


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


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




	move.w	#4,fill.colour+2
	moveq	#0,d2
	move.w	#319,d3
	move.w	#200-1,d1

	lea	fill.coords(pc),a1
	move.w	#0,(a1)+		save start y

ffill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,ffill.box.loop

	bsr.s	fill




	bsr	display.palette




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


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
	move.l	#4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




rte.ins	rte




;""""""""""""""""""""
;" THE FILL ROUTINE "
;"		    "
;""""""""""""""""""""

fill	st	(a1)			end-of-fill marker
	move.l	screen.mem(pc),a1
	lea	fill.coords(pc),a4
	move.w	(a4)+,d0		get y-start
	add.w	d0,d0			word offset
	lea	y.table(pc),a2
	add.w	(a2,d0.w),a1		add y offset

fill.colour
	move.w	#0,d1
	cmp.w	#15*4,d1
	bgt	stipple.fill

	move.l	fill.table(pc,d1.w),a3	set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl.s	fill.it
	rts



fill.table
	dc.l	mask2,mask1,mask16,mask8,mask10,mask15,mask13,mask7
	dc.l	mask3,mask9,mask11,mask14,mask4,mask12,mask5,mask6



fill.it	move.w	#4*64,d2		height = 4

	lea	start.masks(pc),a5

bltfin3	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin3

	move.l	#$7ca0000,bltcon0(a6)	USE B,C,D	D = A.B + notA.C
	move.w	#$ffff,bltadat(a6)	mask for all planes

fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line		if x-end is less than x-start

	moveq	#$f,d3
	and.w	d0,d3			low four bits from x-start

	sub.w	d3,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	add.w	d3,d1			correct bit position for x-end

	add.w	d3,d3
	move.w	(a5,d3.w),d0		get start mask
	swap	d0

	add.w	d1,d1
	move.w	32(a5,d1.w),d0		get end mask

	lsr.w	#5,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d3			width of one bitplane
	sub.w	d1,d3
	sub.w	d1,d3			modulo value

	or.w	d2,d1			bltsize value, with height = 4

bltfin4	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin4

	movem.l	d0/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d3,bltbmod(a6)		set modulos
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)
	move.w	d1,bltsize(a6)		start blitter

next.line
	lea	160(a1),a1		next line
	move.w	(a4)+,d0		next x-start
	bpl.s	fill.it.loop
	rts



start.masks
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001



end.masks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



stipple.fill
	move.l	#$1000,d4		value for bltcon1
	btst	#1,d0
	beq.s	even.scan.line
	swap	d4

even.scan.line
	sub.w	#16*4,d1
	move.l	stipple.fill.table(pc,d1.w),a3
;					set pointer for correct colour
	move.w	(a4)+,d0		first x-start
	bpl	stipple.fill.it
	rts



stipple.fill.table
	dc.l	mask17,mask31,mask23,mask25,mask30,mask28,mask22,mask18
	dc.l	mask24,mask26,mask29,mask19,mask27,mask20,mask21

	dc.l	mask32,mask33,mask34,mask35,mask36,mask37,mask38,mask39
	dc.l	mask40,mask41,mask42,mask43,mask44,mask45

	dc.l	mask46,mask47,mask48,mask49,mask50,mask51,mask52,mask53
	dc.l	mask54,mask55,mask56,mask57,mask58

	dc.l	mask59,mask60,mask61,mask62,mask63,mask64,mask65,mask66
	dc.l	mask67,mask68,mask69,mask70

	dc.l	mask71,mask72,mask73,mask74,mask75,mask76,mask77,mask78
	dc.l	mask79,mask80,mask81

	dc.l	mask82,mask83,mask84,mask85,mask86,mask87,mask88,mask89
	dc.l	mask90,mask91

	dc.l	mask92,mask93,mask94,mask95,mask96,mask97,mask98,mask99
	dc.l	mask100

	dc.l	mask101,mask102,mask103,mask104,mask105,mask106,mask107,mask108

	dc.l	mask109,mask110,mask111,mask112,mask113,mask114,mask115

	dc.l	mask116,mask117,mask118,mask119,mask120,mask121

	dc.l	mask122,mask123,mask124,mask125,mask126

	dc.l	mask127,mask128,mask129,mask130

	dc.l	mask131,mask132,mask133

	dc.l	mask134,mask135

	dc.l	mask136



stipple.fill.it
	move.w	#4*64,d2		height = 4
	moveq	#16,d5

	lea	start.masks(pc),a5

bltfin5	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin5

	move.w	#$7ca,bltcon0(a6)	USE B,C,D	D = A.B + notA.C
	move.w	#$ffff,bltadat(a6)	mask for all planes

stipple.fill.it.loop
	move.w	(a4)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line2		if x-end is less than x-start

	moveq	#$f,d3
	and.w	d0,d3			low four bits from x-start
	bne.s	not.word.boundary

	sub.w	d5,d0			start one word earlier
	add.w	d5,d1			one word extra width
	bra.s	no.start.mask

not.word.boundary
	sub.w	d3,d0			x-start offset in multiples of 16
	add.w	d3,d1			correct bit position for x-end

	add.w	d3,d3
	move.w	(a5,d3.w),d3		get start mask

no.start.mask
	swap	d3
	asr.w	#3,d0			x-start offset in even bytes
	lea	(a1,d0.w),a2		start address of fill

	add.w	d1,d1
	move.w	32(a5,d1.w),d3		get end mask

	lsr.w	#5,d1
	addq.w	#1,d1			width of fill in words

	moveq	#40,d0			width of one bitplane
	sub.w	d1,d0
	sub.w	d1,d0			modulo value

	or.w	d2,d1			bltsize value, with height = 4

bltfin6	btst	#6,dmaconr(a6)		wait until blitter ready
	bne.s	bltfin6

	movem.l	d3/a2-a3,bltafwm(a6)	set masks, source C and source B
	move.l	a2,bltdpth(a6)		set destination
	move.w	d0,bltbmod(a6)		set modulos
	move.w	d0,bltcmod(a6)
	move.w	d0,bltdmod(a6)
	move.w	d4,bltcon1(a6)
	move.w	d1,bltsize(a6)		start blitter

next.line2
	swap	d4
	lea	160(a1),a1		next line
	move.w	(a4)+,d0		next x-start
	bpl.s	stipple.fill.it.loop
	rts



y.table	ds.w	200



fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker



mask1	dcb.w	20,$ffff		solid colours
mask2	dcb.w	20,0
mask3	dcb.w	20,0
mask4	dcb.w	20,0
mask5	dcb.w	20,0
mask6	dcb.w	20,$ffff
mask7	dcb.w	20,$ffff
mask8	dcb.w	20,$ffff
mask9	dcb.w	20,$ffff
mask10	dcb.w	20,0
mask11	dcb.w	20,0
mask12	dcb.w	20,$ffff
mask13	dcb.w	20,0
mask14	dcb.w	20,$ffff
mask15	dcb.w	20,$ffff
mask16	dcb.w	20,0
	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0

mask17	dcb.w	20,$5555		colour 0 with 1-15
mask18	dcb.w	20,0
mask19	dcb.w	20,0
mask20	dcb.w	20,0
mask21	dcb.w	20,$5555
mask22	dcb.w	20,$5555
mask23	dcb.w	20,$5555
mask24	dcb.w	20,$5555
mask25	dcb.w	20,0
mask26	dcb.w	20,0
mask27	dcb.w	20,$5555
mask28	dcb.w	20,0
mask29	dcb.w	20,$5555
mask30	dcb.w	20,$5555
mask31	dcb.w	20,0
	dcb.w	20,$5555
	dcb.w	20,0
	dcb.w	20,0

mask32	dcb.w	20,$5555!$0000		colour 1 with 2-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask33	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask34	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask35	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask36	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask37	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask38	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask39	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask40	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask41	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask42	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask43	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask44	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask45	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask46	dcb.w	20,$0000!$aaaa		colour 2 with 3-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000

mask47	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask48	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask49	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask50	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask51	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask52	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask53	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask54	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask55	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask56	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask57	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask58	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask59	dcb.w	20,$5555!$0000		colour 3 with 4-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask60	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask61	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask62	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000

mask63	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask64	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask65	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask66	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa

mask67	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask68	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask69	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa

mask70	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa


mask71	dcb.w	20,$0000!$aaaa		colour 4 with 5-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask72	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask73	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask74	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask75	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask76	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask77	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask78	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask79	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask80	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask81	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask82	dcb.w	20,$5555!$0000		colour 5 with 6-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask83	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask84	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask85	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask86	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask87	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask88	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask89	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask90	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask91	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask92	dcb.w	20,$0000!$aaaa		colour 6 with 7-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000

mask93	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask94	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask95	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask96	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask97	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask98	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask99	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask100	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask101	dcb.w	20,$5555!$0000		colour 7 with 8-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask102	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask103	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask104	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa

mask105	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask106	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask107	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa

mask108	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa


mask109	dcb.w	20,$0000!$aaaa		colour 8 with 9-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask110	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask111	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask112	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask113	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask114	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask115	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask116	dcb.w	20,$5555!$0000		colour 9 with 10-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask117	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask118	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask119	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask120	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask121	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask122	dcb.w	20,$0000!$aaaa		colour 10 with 11-15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa

mask123	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask124	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask125	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask126	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask127	dcb.w	20,$5555!$0000		colour 11 with 12-15
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask128	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask129	dcb.w	20,$5555!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa

mask130	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa


mask131	dcb.w	20,$0000!$aaaa		colour 12 with 13-15
	dcb.w	20,$0000!$0000
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask132	dcb.w	20,$0000!$0000
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask133	dcb.w	20,$0000!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa


mask134	dcb.w	20,$5555!$0000		colour 13 with 14-15
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa

mask135	dcb.w	20,$5555!$aaaa
	dcb.w	20,$0000!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa


mask136	dcb.w	20,$0000!$aaaa		colour 14 with 15
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa
	dcb.w	20,$5555!$aaaa



poly.coords	ds.w	64		space for 16 sided polygon




display.palette
	moveq	#2,d0			start y
	moveq	#8-1,d1			8 rows
	clr.w	fill.colour+2		start colour at 0

next.row
	moveq	#0,d2			start x
	moveq	#17-1,d3		17 columns

next.column
	bsr.s	fill.box

	addq.w	#4,fill.colour+2	next colour
	add.w	#19,d2			next start x
	dbra	d3,next.column

	add.w	#25,d0			next start y
	dbra	d1,next.row
	rts




fill.box
	movem.w	d0-d3,-(sp)

	move.w	d2,d3
	add.w	#15,d3			16 pixels wide
	moveq	#20-1,d1		20 pixels tall

	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

	bsr	fill

	movem.w	(sp)+,d0-d3
	rts




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.l	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

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

gfxbase		dc.l	0
old.ints	dc.w	0
old.dbz		dc.l	0




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

colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab
