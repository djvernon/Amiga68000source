	section	BlitBob,code_c
	opt	o+,o3-



start	bset	#1,$bfe001		low pass filter off

	move.l	4.w,a6
	move.l	#3*4*42*196,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
	addi.l	#4*42*196,d0
	move.l	d0,screen2
	addi.l	#4*42*196,d0
	move.l	d0,screen3

	bsr	make.copper.lists

	move.l	4.w,a6
	jsr	-132(a6)		turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	andi.l	#$1ff00,d0
	lsr.l	#8,d0
	cmpi.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz		division-by-zero exception handler
	move.l	#rteins,$14.w		set to rte instruction

	lea	coltab(pc),a0		initialise colours
	lea	$dff180,a1
	moveq	#15,d0
nextcol	move.w	(a0)+,(a1)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$3a81,diwstrt(a6)	196 tall
	move.w	#$fec1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#3*40+4*2,bpl1mod(a6)
	move.w	#3*40+4*2,bpl2mod(a6)



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
	move.l	copper3(pc),cop1lc(a6)
	move.w	d0,copjmp1(a6)
	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#196-1,d0	count
	moveq	#0,d1		offset starts at zero
	move.w	#168,d2		bytes per line = 168
	lea	y.table(pc),a0
y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop



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

loop	bsr	frames.per.sec

****************************************

	move.w	bob.x.speed(pc),d0
	add.w	d0,bob1.x

	cmp.w	#336,bob1.x
	bmi.s	bob.x.ok
	neg.w	bob.x.speed

bob.x.ok
	cmp.w	#16+1-bob1.width,bob1.x
	bpl.s	bob.x.ok2
	neg.w	bob.x.speed

bob.x.ok2
	move.w	bob.y.speed(pc),d0
	add.w	d0,bob1.y

	cmp.w	#196,bob1.y
	bmi.s	bob.y.ok
	neg.w	bob.y.speed

bob.y.ok
	cmp.w	#0+1-bob1.width,bob1.y
	bpl.s	bob.y.ok2
	neg.w	bob.y.speed

bob.y.ok2
	lea	bob1.info(pc),a0
	bsr	clip.blit.bob

****************************************

	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait

	bsr	update.screens

	btst	#6,$bfe001
	bne.s	loop



;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)		turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#3*4*42*196,d0
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

	move.w	#1,nextframe

	movem.l	(sp)+,d0-d7/a0-a6
rteins	rte



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

bob1.width	equ	64		pixel width
bob1.height	equ	64		pixel height



bob1.info			; data structure for bob
bob1.x	dc.w	16
				; X position of top-left corner
bob1.y	dc.w	0
				; Y position of top-left corner
	dc.w	168-(bob1.width/8)-2
				; byte modulo value for screen
				; = screen width - bob width - 1 extra word
	dc.w	(bob1.height*64)+(bob1.width/16)+1
				; bltsize value, 1 word extra width
	dc.w	bob1.width
				; used for clipping
	dc.w	bob1.height
				; used for clipping
	dc.l	bob1.data
				; address of bob's binary data
	dc.l	bob1.data+((bob1.width/8)*bob1.height*4)
				; address of bob's mask



bob.x.speed	dc.w	2
bob.y.speed	dc.w	2



clip.blit.bob
	movem.w	(a0)+,d0-d5		X, Y, modulo, bltsize, width, height
	moveq	#-2,d6			modulo for bob data and mask

	move.w	d4,d7			bob width
	lsr.w	#3,d7			bob width in even bytes
	mulu	d5,d7			number of lines * bytes per line
	move.w	d7,next.plane.offset

	move.l	(a0)+,a1		start address for source
	move.l	(a0),a2			start address for mask


check.bob.y.min				; clip bob against top of screen
	move.w	d1,d7
	bpl.s	check.bob.y.max

	neg.w	d7			amount off screen
	cmp.w	d5,d7			if bob is fully off screen then quit
	bpl	end.clip.blit.bob

	move.w	d4,a0			save bob width
	lsr.w	#3,d4			bob width in even bytes
	mulu	d7,d4			number of lines * bytes per line
	add.w	d4,a1			add to bob start address
	add.w	d4,a2			add to mask start address
	lsl.w	#6,d7			number of lines * 64
	sub.w	d7,d3			remove from bltsize value
	moveq	#0,d1			set bob Y to zero
	move.w	a0,d4			restore bob width
	bra.s	check.bob.x.min


check.bob.y.max				; clip bob against bottom of screen
	move.w	#196,d7			screen height
	sub.w	d5,d7			screen height - bob height = maximum
	sub.w	d1,d7			maximum - bob Y position
	bpl.s	check.bob.x.min

	neg.w	d7			amount off screen
	cmp.w	d5,d7			if bob is fully off screen then quit
	bpl	end.clip.blit.bob

	lsl.w	#6,d7			number of lines * 64
	sub.w	d7,d3			remove from bltsize value


check.bob.x.min				; clip bob against left of screen
	move.w	d0,d7			bob X
	subi.w	#16,d7			bob X - start of visible screen
	bpl.s	check.bob.x.max

	neg.w	d7			amount off screen
	cmp.w	d4,d7			if bob is fully off screen then quit
	bpl	end.clip.blit.bob

	lsr.w	#4,d7			no. of words to miss off
	sub.w	d7,d3			remove from bltsize value
	add.w	d7,d7			no. of bytes to miss off
	add.w	d7,d2			add to screen modulo value
	add.w	d7,d6			add to bob modulo value
	add.w	d7,a1			add to bob start address
	add.w	d7,a2			add to bob mask address
	lsl.w	#3,d7			no. of pixels to miss off in multiples
	add.w	d7,d0			of 16 bits -- add to bob X

	bra.s	bob.clipped


check.bob.x.max				; clip bob against right of screen
	move.w	#336,d7			screen width
	sub.w	d4,d7			screen width - bob width = maximum
	sub.w	d0,d7			maximum - bob X position
	bpl.s	bob.clipped

	neg.w	d7			amount off screen
	cmp.w	d4,d7			if bob is fully off screen then quit
	bpl	end.clip.blit.bob

	lsr.w	#4,d7			no. of words to miss off
	sub.w	d7,d3			remove from bltsize value
	add.w	d7,d7			no. of bytes to miss off
	add.w	d7,d2			add to screen modulo value
	add.w	d7,d6			add to bob modulo value


bob.clipped
	move.l	screen1(pc),a0
	add.w	d1,d1
	lea	y.table(pc),a3
	add.w	(a3,d1.w),a0		add y offset

	moveq	#$f,d1
	and.w	d0,d1			low four bits from x
	sub.w	d1,d0			x offset in multiples of 16 bits
	lsr.w	#3,d0			x offset in even bytes
	add.w	d0,a0			start address for screen

	ror.w	#4,d1			shift distance

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen -- destination
	move.w	d1,bltcon1(a6)
	ori.w	#$fca,d1		USE A,B,C,D ; LFx : D = A.B + a.C
	move.w	d1,bltcon0(a6)
	move.l	#$ffff0000,bltafwm(a6)	mask off last word
	move.w	d6,bltamod(a6)		to start of next line
	move.w	d6,bltbmod(a6)		to start of next line
	move.w	d2,bltcmod(a6)
	move.w	d2,bltdmod(a6)
	move.w	d3,bltsize(a6)

	move.w	next.plane.offset(pc),d0

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

bltfin3	btst	#6,dmaconr(a6)
	bne.s	bltfin3

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

bltfin4	btst	#6,dmaconr(a6)
	bne.s	bltfin4

	lea	42(a0),a0		next bitplane of screen
	add.w	d0,a1			next bitplane of bob data
	movem.l	a0-a2,bltcpth(a6)	bob mask, bob data, screen -- source
	move.l	a0,bltdpth(a6)		screen - destination
	move.w	d3,bltsize(a6)

end.clip.blit.bob
	rts



next.plane.offset
	dc.w	0



y.table	ds.w	196			one word per screen line



;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

print	move.l	screen1(pc),a1		d0=x, d1=y, a0=text ending with 0
	add.w	d1,d1
	lea	y.table(pc),a2
	add.w	(a2,d1.w),a1
	add.w	d0,a1			screen start address
	move.w	#168,d2			bytes per line
print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	subi.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2
copy.loop
	move.b	(a3),(a2)		copy byte of character, bitplane 1
	move.b	(a3),42(a2)		bitplane 2
	move.b	(a3),84(a2)		bitplane 3
	move.b	(a3)+,126(a2)		bitplane 4
	add.w	d2,a2			next screen line
	dbra	d0,copy.loop

	addq.w	#1,a1			next column
	bra.s	print.loop
end.print
	rts


; Spectrum font, characters 32-126, each 8*8 pixels

font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$00,$04,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00



make.decimal
	andi.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros
make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#" ",(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	addi.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmpi.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	addi.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	clr.b	(a0)			end with zero
	rts



decimal.text
	ds.b	6



frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter,d1		get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#".",-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#17,d0			x
	moveq	#17,d1			y
	bsr	print
	rts


old.counter
	dc.w	0


frames.text
	dc.b	"F/S     ",0
	even



update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	screen3(pc),screen2
	move.l	d0,screen3

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	copper3(pc),copper2
	move.l	d0,copper3

	move.l	d0,cop1lc(a6)		set new copper list address
	rts



make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
	bsr.s	init.copper

	move.l	screen3(pc),d0
	move.l	copper3(pc),a0
	bsr.s	init.copper
	rts



init.copper
	moveq	#4-1,d1
	addq.l	#2,d0			skip one word
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	addi.l	#42,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list.1
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END



copper.list.2
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END



copper.list.3
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

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
color3	equ	$186
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
screen3		dc.l	0

copper1		dc.l	copper.list.1
copper2		dc.l	copper.list.2
copper3		dc.l	copper.list.3

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

coltab	dc.w	$000,$fff,$ed0,$cb0,$a90,$870,$650,$430
	dc.w	$f0c,$d0e,$90c,$50b,$209,$008,$016,$eee

bob1.data	incbin	Pac.bin.mask
