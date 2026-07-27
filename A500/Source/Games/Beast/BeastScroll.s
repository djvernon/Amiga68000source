	section	Beast_Scroll,code_c
	opt	o+,o3-


start	bset	#1,$bfe001	low pass filter off

	move.l	4,a6
	jsr	-132(a6)	turn off multitasking

	lea	$dff000,a5
	move.w	intenar(a5),ints	save system interrupt status
	move.w	#$3fef,intena(a5)
	move.w	#$c010,intena(a5)	enable copper interrupt
	move.w	#$03ff,dmacon(a5)	DMA off


	move.l	#playfield1,d0
	move.w	d0,bp1l1
	swap	d0
	move.w	d0,bp1h1
	swap	d0
	add.l	#84*179,d0	84 bytes per line, 179 lines
	move.w	d0,bp1l2
	swap	d0
	move.w	d0,bp1h2
	swap	d0
	add.l	#84*21,d0	84 bytes per line, 21 lines

	move.w	d0,bp3l1
	swap	d0
	move.w	d0,bp3h1
	swap	d0
	add.l	#84*179,d0	84 bytes per line, 179 lines
	move.w	d0,bp3l2
	swap	d0
	move.w	d0,bp3h2
	swap	d0
	add.l	#84*21,d0	84 bytes per line, 21 lines

	move.w	d0,bp5l1
	swap	d0
	move.w	d0,bp5h1
	swap	d0
	add.l	#84*179,d0	84 bytes per line, 179 lines
	move.w	d0,bp5l2
	swap	d0
	move.w	d0,bp5h2


	move.l	#playfield2,d0
	move.w	d0,bp2l1
	swap	d0
	move.w	d0,bp2h1
	swap	d0
	add.l	#80*22,d0	80 bytes per line, 22 lines
	move.w	d0,bp2l2
	swap	d0
	move.w	d0,bp2h2
	swap	d0
	add.l	#80*41,d0	80 bytes per line, 41 lines
	move.w	d0,bp2l3
	swap	d0
	move.w	d0,bp2h3
	swap	d0
	add.l	#80*19,d0	80 bytes per line, 19 lines
	move.w	d0,bp2l4
	swap	d0
	move.w	d0,bp2h4
	swap	d0
	add.l	#80*9,d0	80 bytes per line, 9 lines
	move.w	d0,bp2l5
	swap	d0
	move.w	d0,bp2h5
	swap	d0
	add.l	#80*6,d0	80 bytes per line, 6 lines
	move.w	d0,bp2l6
	swap	d0
	move.w	d0,bp2h6
	swap	d0
	add.l	#80*73,d0	80 bytes per line, 73 lines
	move.w	d0,bp2l7
	swap	d0
	move.w	d0,bp2h7
	swap	d0
	add.l	#80*2,d0	80 bytes per line, 2 lines
	move.w	d0,bp2l8
	swap	d0
	move.w	d0,bp2h8
	swap	d0
	add.l	#80*3,d0	80 bytes per line, 3 lines
	move.w	d0,bp2l9
	swap	d0
	move.w	d0,bp2h9
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp2l10
	swap	d0
	move.w	d0,bp2h10
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp2l11
	swap	d0
	move.w	d0,bp2h11
	swap	d0
	add.l	#80*11,d0	80 bytes per line, 11 lines

	move.w	d0,bp4l1
	swap	d0
	move.w	d0,bp4h1
	swap	d0
	add.l	#80*22,d0	80 bytes per line, 22 lines
	move.w	d0,bp4l2
	swap	d0
	move.w	d0,bp4h2
	swap	d0
	add.l	#80*41,d0	80 bytes per line, 41 lines
	move.w	d0,bp4l3
	swap	d0
	move.w	d0,bp4h3
	swap	d0
	add.l	#80*19,d0	80 bytes per line, 19 lines
	move.w	d0,bp4l4
	swap	d0
	move.w	d0,bp4h4
	swap	d0
	add.l	#80*9,d0	80 bytes per line, 9 lines
	move.w	d0,bp4l5
	swap	d0
	move.w	d0,bp4h5
	swap	d0
	add.l	#80*6,d0	80 bytes per line, 6 lines
	move.w	d0,bp4l6
	swap	d0
	move.w	d0,bp4h6
	swap	d0
	add.l	#80*73,d0	80 bytes per line, 73 lines
	move.w	d0,bp4l7
	swap	d0
	move.w	d0,bp4h7
	swap	d0
	add.l	#80*2,d0	80 bytes per line, 2 lines
	move.w	d0,bp4l8
	swap	d0
	move.w	d0,bp4h8
	swap	d0
	add.l	#80*3,d0	80 bytes per line, 3 lines
	move.w	d0,bp4l9
	swap	d0
	move.w	d0,bp4h9
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp4l10
	swap	d0
	move.w	d0,bp4h10
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp4l11
	swap	d0
	move.w	d0,bp4h11
	swap	d0
	add.l	#80*11,d0	80 bytes per line, 11 lines

	move.w	d0,bp6l1
	swap	d0
	move.w	d0,bp6h1
	swap	d0
	add.l	#80*22,d0	80 bytes per line, 22 lines
	move.w	d0,bp6l2
	swap	d0
	move.w	d0,bp6h2
	swap	d0
	add.l	#80*41,d0	80 bytes per line, 41 lines
	move.w	d0,bp6l3
	swap	d0
	move.w	d0,bp6h3
	swap	d0
	add.l	#80*19,d0	80 bytes per line, 19 lines
	move.w	d0,bp6l4
	swap	d0
	move.w	d0,bp6h4
	swap	d0
	add.l	#80*9,d0	80 bytes per line, 9 lines
	move.w	d0,bp6l5
	swap	d0
	move.w	d0,bp6h5
	swap	d0
	add.l	#80*6,d0	80 bytes per line, 6 lines
	move.w	d0,bp6l6
	swap	d0
	move.w	d0,bp6h6
	swap	d0
	add.l	#80*73,d0	80 bytes per line, 73 lines
	move.w	d0,bp6l7
	swap	d0
	move.w	d0,bp6h7
	swap	d0
	add.l	#80*2,d0	80 bytes per line, 2 lines
	move.w	d0,bp6l8
	swap	d0
	move.w	d0,bp6h8
	swap	d0
	add.l	#80*3,d0	80 bytes per line, 3 lines
	move.w	d0,bp6l9
	swap	d0
	move.w	d0,bp6h9
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp6l10
	swap	d0
	move.w	d0,bp6h10
	swap	d0
	add.l	#80*7,d0	80 bytes per line, 7 lines
	move.w	d0,bp6l11
	swap	d0
	move.w	d0,bp6h11


	move.l	#energy1,d0
	move.w	d0,sp0l1
	swap	d0
	move.w	d0,sp0h1

	move.l	#energy2,d0
	move.w	d0,sp1l1
	swap	d0
	move.w	d0,sp1h1

	move.l	#pulse1a,d0
	move.w	d0,sp2l1
	swap	d0
	move.w	d0,sp2h1

	move.l	#pulse1b,d0
	move.w	d0,sp3l1
	swap	d0
	move.w	d0,sp3h1

	move.l	#largeship3,d0
	move.w	d0,sp2l2
	swap	d0
	move.w	d0,sp2h2

	move.l	#largeship4,d0
	move.w	d0,sp3l2
	swap	d0
	move.w	d0,sp3h2

	move.l	#bluepotion1,d0
	move.w	d0,sp4l1
	swap	d0
	move.w	d0,sp4h1

	move.l	#bluepotion2,d0
	move.w	d0,sp5l1
	swap	d0
	move.w	d0,sp5h1

	move.l	#redpotion1,d0
	move.w	d0,sp6l1
	swap	d0
	move.w	d0,sp6h1

	move.l	#redpotion2,d0
	move.w	d0,sp7l1
	swap	d0
	move.w	d0,sp7h1


	move.w	#$6600,bplcon0(a5)	initialise screen
	move.w	#$2c90,diwstrt(a5)
	move.w	#$f4b0,diwstop(a5)
	move.w	#$38,ddfstrt(a5)
	move.w	#$d0,ddfstop(a5)
	move.w	#44,bpl1mod(a5)
	move.w	#40,bpl2mod(a5)


;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	4,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)	ownblitter

	move.l	gfxbase,a1
	move.l	38(a1),oldcopper

	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$83e0,dmacon(a5)	DMA on (bitplane, copper,
;						blitter, sprite)


;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c,old
	move.l	#level3,$6c


;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	old,$6c

	move.l	oldcopper,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.l	gfxbase,a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase,a1
	move.l	4,a6
	jsr	-414(a6)	closelibrary

	move.w	#$8010,dmacon(a5)	disk DMA on
	move.w	ints,d0
	ori.w	#$c000,d0	set SET and INTEN bits
	move.w	d0,intena(a5)	restore system interrupt status

end	move.l	4,a6
	jsr	-138(a6)	turn on multitasking

	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts


;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a5)

	btst	#7,$bfe001
	beq.s	out

	bsr.s	animatepulse
	bsr	movelargeship
	bsr	movesmallship
	bsr	movetree
	bsr	logoscrl
	bsr	clouds1scrl
	bsr	clouds2scrl
	bsr	clouds3scrl
	bsr	clouds4scrl
	bsr	clouds5scrl
	bsr	mountainscrl
	bsr	grass1scrl
	bsr	grass2scrl
	bsr	grass3scrl
	bsr	fencescrl
	bsr	grass4scrl
	bsr	grass5scrl

	bsr	updatecopper

out	movem.l	(sp)+,d0-d7/a0-a6
	rte


animatepulse				; update every fifth frame
	subq.w	#1,pulsedelay
	bne.s	endpulseanim
	move.w	#5,pulsedelay
	add.l	#2*17*4,pulseadr	next pair of sprites
	cmpi.l	#pulse1a+14*2*17*4,pulseadr
	bne.s	setpulsesprites
	move.l	#pulse1a,pulseadr	back to start

setpulsesprites
	move.l	pulseadr,d0
	move.w	d0,sp2l1
	swap	d0
	move.w	d0,sp2h1
	swap	d0
	add.l	#17*4,d0

	move.w	d0,sp3l1
	swap	d0
	move.w	d0,sp3h1
endpulseanim
	rts


movelargeship				; one pixel every third frame
	subq.b	#1,largeshipdelay
	bne.s	endmovelship

	move.b	#3,largeshipdelay
	tst.b	largeshipxbit0
	bne.s	inclshipbits1to7
	move.b	#1,largeshipxbit0
	bra.s	updatelargeship

endmovelship
	rts

inclshipbits1to7
	clr.b	largeshipxbit0
	addq.b	#1,largeshipx
updatelargeship
	move.b	largeshipx,d0
	move.b	d0,largeship1+1
	addq.b	#8,d0
	move.b	d0,largeship2+1
	addq.b	#8,d0
	move.b	d0,largeship3+1
	addq.b	#8,d0
	move.b	d0,largeship4+1

	move.b	largeshipxbit0,d0
	move.b	d0,largeship1+3
	move.b	d0,largeship2+3
	move.b	d0,largeship3+3
	move.b	d0,largeship4+3
	rts


movesmallship				; one pixel every fourth frame
	subq.b	#1,smallshipdelay
	bne.s	endmovesship

	move.b	#4,smallshipdelay
	tst.b	smallshipxbit0
	bne.s	incsshipbits1to7
	move.b	#1,smallshipxbit0
	subq.b	#1,smallshipx
	bra.s	updatesmallship

endmovesship
	rts

incsshipbits1to7
	clr.b	smallshipxbit0
updatesmallship
	move.b	smallshipx,d0
	move.b	d0,smallship1+1
	addq.b	#8,d0
	move.b	d0,smallship2+1

	move.b	smallshipxbit0,d0
	move.b	d0,smallship1+3
	move.b	d0,smallship2+3
	rts


movetree				; two pixels every frame
	tst.w	treedelay
	bne.s	pausetree

	cmpi.b	#-36,treex
	bne.s	dontdelay

	move.w	#125,treedelay
dontdelay
	subq.b	#1,treex
treeupdate
	move.b	treex,d0
	move.b	d0,tree1+1
	addq.b	#8,d0
	move.b	d0,tree2+1
	addq.b	#8,d0
	move.b	d0,tree3+1
	addq.b	#8,d0
	move.b	d0,tree4+1
	addq.b	#8,d0
	move.b	d0,tree5+1
	addq.b	#8,d0
	move.b	d0,tree6+1
	addq.b	#8,d0
	move.b	d0,tree7+1
	addq.b	#8,d0
	move.b	d0,tree8+1
	rts

pausetree
	subq.w	#1,treedelay
	rts


logoscrl				; two pixels every frame
	tst.w	logodelay
	beq.s	scrolllogo
	subq.w	#1,logodelay
	bne.s	endlogoscrl

	not.w	logodirection

scrolllogo
	tst.w	logodirection
	beq.s	scrollleft

scrollright
	subq.w	#2,pf1scroll1
	cmpi.w	#-2,pf1scroll1
	bne.s	endlogoscrl

	move.w	#14,pf1scroll1
	addq.l	#2,logoadr
	cmp.l	#playfield1+42,logoadr
	bne.s	endlogoscrl

	move.w	#250,logodelay
	bra.s	endlogoscrl

scrollleft
	addq.w	#2,pf1scroll1
	cmpi.w	#16,pf1scroll1
	bne.s	endlogoscrl

	clr.w	pf1scroll1
	subq.l	#2,logoadr
	cmp.l	#playfield1,logoadr
	bne.s	endlogoscrl

	move.w	#250,logodelay
endlogoscrl
	rts


clouds1scrl				; one pixel every frame
	subq.w	#1,pf2scroll1
	cmpi.w	#-1,pf2scroll1
	bne.s	endclouds1scrl

	move.w	#15,pf2scroll1
	addq.l	#2,clouds1adr
	cmp.l	#playfield2+42,clouds1adr
	bne.s	endclouds1scrl
	move.l	#playfield2+2,clouds1adr
endclouds1scrl
	rts


clouds2scrl				; one pixel every second frame
	subq.w	#1,scroll1count
	move.w	scroll1count,d0
	andi.w	#1,d0
	cmpi.w	#1,d0
	bne.s	endclouds2scrl

	subq.w	#1,pf2scroll2
	cmpi.w	#-1,pf2scroll2
	bne.s	endclouds2scrl

	move.w	#15,pf2scroll2
	addq.l	#2,clouds2adr
	cmp.l	#playfield2+80*22+42,clouds2adr
	bne.s	endclouds2scrl
	move.l	#playfield2+80*22+2,clouds2adr
endclouds2scrl
	rts


clouds3scrl				; one pixel every third frame
	subq.w	#1,scroll2count
	move.w	scroll2count,d0
	cmpi.w	#-1,d0
	bgt.s	endclouds3scrl
	move.w	#2,scroll2count

	subq.w	#1,pf2scroll3
	cmpi.w	#-1,pf2scroll3
	bne.s	endclouds3scrl

	move.w	#15,pf2scroll3
	addq.l	#2,clouds3adr
	cmp.l	#playfield2+80*63+42,clouds3adr
	bne.s	endclouds3scrl
	move.l	#playfield2+80*63+2,clouds3adr
endclouds3scrl
	rts


clouds4scrl				; one pixel every fourth frame
	subq.w	#1,scroll3count
	move.w	scroll3count,d0
	andi.w	#3,d0
	tst.w	d0
	bne.s	endclouds4scrl

	subq.w	#1,pf2scroll4
	cmpi.w	#-1,pf2scroll4
	bne.s	endclouds4scrl

	move.w	#15,pf2scroll4
	addq.l	#2,clouds4adr
	cmp.l	#playfield2+80*82+42,clouds4adr
	bne.s	endclouds4scrl
	move.l	#playfield2+80*82+2,clouds4adr
endclouds4scrl
	rts


clouds5scrl				; one pixel every fifth frame
	subq.w	#1,scroll4count
	move.w	scroll4count,d0
	cmpi.w	#-1,d0
	bne.s	endclouds5scrl
	move.w	#4,scroll4count

	subq.w	#1,pf2scroll5
	cmpi.w	#-1,pf2scroll5
	bne.s	endclouds5scrl

	move.w	#15,pf2scroll5
	addq.l	#2,clouds5adr
	cmp.l	#playfield2+80*91+42,clouds5adr
	bne.s	endclouds5scrl
	move.l	#playfield2+80*91+2,clouds5adr
endclouds5scrl
	rts


mountainscrl				; one pixel every second frame
	subq.w	#1,scroll5count
	move.w	scroll5count,d0
	andi.w	#1,d0
	cmpi.w	#1,d0
	bne.s	endmountnscrl

	subq.w	#1,pf2scroll6
	cmpi.w	#-1,pf2scroll6
	bne.s	endmountnscrl

	move.w	#15,pf2scroll6
	addq.l	#2,mountainadr
	cmp.l	#playfield2+80*97+42,mountainadr
	bne.s	endmountnscrl
	move.l	#playfield2+80*97+2,mountainadr
endmountnscrl
	rts


grass1scrl				; one pixel every frame
	subq.w	#1,pf2scroll7
	cmpi.w	#-1,pf2scroll7
	bne.s	endgrass1scrl

	move.w	#15,pf2scroll7
	addq.l	#2,grass1adr
	cmp.l	#playfield2+80*170+42,grass1adr
	bne.s	endgrass1scrl
	move.l	#playfield2+80*170+2,grass1adr
endgrass1scrl
	rts


grass2scrl				; two pixels every frame
	subq.w	#2,pf2scroll8
	cmpi.w	#-2,pf2scroll8
	bne.s	endgrass2scrl

	move.w	#14,pf2scroll8
	addq.l	#2,grass2adr
	cmp.l	#playfield2+80*172+42,grass2adr
	bne.s	endgrass2scrl
	move.l	#playfield2+80*172+2,grass2adr
endgrass2scrl
	rts


grass3scrl				; three pixels every frame
	subq.w	#3,pf2scroll9
	cmpi.w	#-1,pf2scroll9
	bgt.s	endgrass3scrl

	addi.w	#16,pf2scroll9
	addq.l	#2,grass3adr
	cmp.l	#playfield2+80*175+42,grass3adr
	bne.s	endgrass3scrl
	move.l	#playfield2+80*175+2,grass3adr
endgrass3scrl
	rts


fencescrl				; seven pixels every frame
	subq.w	#7,pf1scroll2
	cmpi.w	#-1,pf1scroll2
	bgt.s	endfencescrl

	addi.w	#16,pf1scroll2
	addq.l	#2,fenceadr
	cmp.l	#playfield1+84*179+42,fenceadr
	bne.s	endfencescrl
	move.l	#playfield1+84*179+2,fenceadr
endfencescrl
	rts


grass4scrl				; four pixels every frame
	subq.w	#4,pf2scroll10
	cmpi.w	#-1,pf2scroll10
	bgt.s	endgrass4scrl

	addi.w	#16,pf2scroll10
	addq.l	#2,grass4adr
	cmp.l	#playfield2+80*182+42,grass4adr
	bne.s	endgrass4scrl
	move.l	#playfield2+80*182+2,grass4adr
endgrass4scrl
	rts


grass5scrl				; five pixels every frame
	subq.w	#5,pf2scroll11
	cmpi.w	#-1,pf2scroll11
	bgt.s	endgrass5scrl

	addi.w	#16,pf2scroll11
	addq.l	#2,grass5adr
	cmp.l	#playfield2+80*189+42,grass5adr
	bne.s	endgrass5scrl
	move.l	#playfield2+80*189+2,grass5adr
endgrass5scrl
	rts


updatecopper
	move.l	logoadr,d0
	move.w	d0,bp1l1
	swap	d0
	move.w	d0,bp1h1
	swap	d0
	add.l	#84*200,d0	84 bytes per line, 200 lines

	move.w	d0,bp3l1
	swap	d0
	move.w	d0,bp3h1
	swap	d0
	add.l	#84*200,d0	84 bytes per line, 200 lines

	move.w	d0,bp5l1
	swap	d0
	move.w	d0,bp5h1


	move.l	clouds1adr,d0
	move.w	d0,bp2l1
	swap	d0
	move.w	d0,bp2h1
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l1
	swap	d0
	move.w	d0,bp4h1
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l1
	swap	d0
	move.w	d0,bp6h1

	move.w	pf2scroll1,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll1


	move.l	clouds2adr,d0
	move.w	d0,bp2l2
	swap	d0
	move.w	d0,bp2h2
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l2
	swap	d0
	move.w	d0,bp4h2
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l2
	swap	d0
	move.w	d0,bp6h2

	move.w	pf2scroll2,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll2


	move.l	clouds3adr,d0
	move.w	d0,bp2l3
	swap	d0
	move.w	d0,bp2h3
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l3
	swap	d0
	move.w	d0,bp4h3
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l3
	swap	d0
	move.w	d0,bp6h3

	move.w	pf2scroll3,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll3


	move.l	clouds4adr,d0
	move.w	d0,bp2l4
	swap	d0
	move.w	d0,bp2h4
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l4
	swap	d0
	move.w	d0,bp4h4
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l4
	swap	d0
	move.w	d0,bp6h4

	move.w	pf2scroll4,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll4


	move.l	clouds5adr,d0
	move.w	d0,bp2l5
	swap	d0
	move.w	d0,bp2h5
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l5
	swap	d0
	move.w	d0,bp4h5
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l5
	swap	d0
	move.w	d0,bp6h5

	move.w	pf2scroll5,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll5


	move.l	mountainadr,d0
	move.w	d0,bp2l6
	swap	d0
	move.w	d0,bp2h6
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l6
	swap	d0
	move.w	d0,bp4h6
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l6
	swap	d0
	move.w	d0,bp6h6

	move.w	pf2scroll6,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll6


	move.l	grass1adr,d0
	move.w	d0,bp2l7
	swap	d0
	move.w	d0,bp2h7
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l7
	swap	d0
	move.w	d0,bp4h7
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l7
	swap	d0
	move.w	d0,bp6h7

	move.w	pf2scroll7,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll7


	move.l	grass2adr,d0
	move.w	d0,bp2l8
	swap	d0
	move.w	d0,bp2h8
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l8
	swap	d0
	move.w	d0,bp4h8
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l8
	swap	d0
	move.w	d0,bp6h8

	move.w	pf2scroll8,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll8


	move.l	grass3adr,d0
	move.w	d0,bp2l9
	swap	d0
	move.w	d0,bp2h9
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l9
	swap	d0
	move.w	d0,bp4h9
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l9
	swap	d0
	move.w	d0,bp6h9

	move.w	pf2scroll9,d0
	lsl.w	#4,d0
	add.w	pf1scroll1,d0
	move.w	d0,scroll9


	move.l	fenceadr,d0
	move.w	d0,bp1l2
	swap	d0
	move.w	d0,bp1h2
	swap	d0
	add.l	#84*200,d0	84 bytes per line, 200 lines

	move.w	d0,bp3l2
	swap	d0
	move.w	d0,bp3h2
	swap	d0
	add.l	#84*200,d0	84 bytes per line, 200 lines

	move.w	d0,bp5l2
	swap	d0
	move.w	d0,bp5h2

	move.w	pf2scroll9,d0
	lsl.w	#4,d0
	add.w	pf1scroll2,d0
	move.w	d0,scroll10


	move.l	grass4adr,d0
	move.w	d0,bp2l10
	swap	d0
	move.w	d0,bp2h10
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l10
	swap	d0
	move.w	d0,bp4h10
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l10
	swap	d0
	move.w	d0,bp6h10

	move.w	pf2scroll10,d0
	lsl.w	#4,d0
	add.w	pf1scroll2,d0
	move.w	d0,scroll11


	move.l	grass5adr,d0
	move.w	d0,bp2l11
	swap	d0
	move.w	d0,bp2h11
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp4l11
	swap	d0
	move.w	d0,bp4h11
	swap	d0
	add.l	#80*200,d0	80 bytes per line, 200 lines

	move.w	d0,bp6l11
	swap	d0
	move.w	d0,bp6h11

	move.w	pf2scroll11,d0
	lsl.w	#4,d0
	add.w	pf1scroll2,d0
	move.w	d0,scroll12

	rts


pf1scroll1	dc.w	0
pf1scroll2	dc.w	0
pf2scroll1	dc.w	0
pf2scroll2	dc.w	0
pf2scroll3	dc.w	0
pf2scroll4	dc.w	0
pf2scroll5	dc.w	0
pf2scroll6	dc.w	0
pf2scroll7	dc.w	0
pf2scroll8	dc.w	0
pf2scroll9	dc.w	0
pf2scroll10	dc.w	0
pf2scroll11	dc.w	0
pulsedelay	dc.w	5
largeshipdelay	dc.b	1
largeshipx	dc.b	0
largeshipxbit0	dc.b	0
smallshipdelay	dc.b	1
smallshipx	dc.b	250
smallshipxbit0	dc.b	0
treex		dc.b	-40
		dc.b	0
treedelay	dc.w	400
logodelay	dc.w	250
logodirection	dc.w	0
scroll1count	dc.w	0
scroll2count	dc.w	0
scroll3count	dc.w	0
scroll4count	dc.w	0
scroll5count	dc.w	0
pulseadr	dc.l	pulse1a
logoadr		dc.l	playfield1
clouds1adr	dc.l	playfield2
clouds2adr	dc.l	playfield2+80*22
clouds3adr	dc.l	playfield2+80*63
clouds4adr	dc.l	playfield2+80*82
clouds5adr	dc.l	playfield2+80*91
mountainadr	dc.l	playfield2+80*97
grass1adr	dc.l	playfield2+80*170
grass2adr	dc.l	playfield2+80*172
grass3adr	dc.l	playfield2+80*175
fenceadr	dc.l	playfield1+84*179
grass4adr	dc.l	playfield2+80*182
grass5adr	dc.l	playfield2+80*189


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	spr0pth
sp0h1	dc.w	0,spr0ptl
sp0l1	dc.w	0,spr1pth
sp1h1	dc.w	0,spr1ptl
sp1l1	dc.w	0,spr2pth
sp2h1	dc.w	0,spr2ptl
sp2l1	dc.w	0,spr3pth
sp3h1	dc.w	0,spr3ptl
sp3l1	dc.w	0,spr4pth
sp4h1	dc.w	0,spr4ptl
sp4l1	dc.w	0,spr5pth
sp5h1	dc.w	0,spr5ptl
sp5l1	dc.w	0,spr6pth
sp6h1	dc.w	0,spr6ptl
sp6l1	dc.w	0,spr7pth
sp7h1	dc.w	0,spr7ptl
sp7l1	dc.w	0

	dc.w	bplcon2,$24
	dc.w	color9,$ccc
	dc.w	color10,$bbb
	dc.w	color11,$aaa
	dc.w	color12,$999
	dc.w	color13,$888
	dc.w	color14,$777
	dc.w	color15,$678

	dc.w	bpl2pth		clouds1
bp2h1	dc.w	0,bpl2ptl
bp2l1	dc.w	0,bpl4pth
bp4h1	dc.w	0,bpl4ptl
bp4l1	dc.w	0,bpl6pth
bp6h1	dc.w	0,bpl6ptl
bp6l1	dc.w	0

	dc.w	bpl1pth		logo
bp1h1	dc.w	0,bpl1ptl
bp1l1	dc.w	0,bpl3pth
bp3h1	dc.w	0,bpl3ptl
bp3l1	dc.w	0,bpl5pth
bp5h1	dc.w	0,bpl5ptl
bp5l1	dc.w	0

	dc.w	bplcon1
scroll1	dc.w	0

	dc.w	color1,$aaa
	dc.w	color2,$f00
	dc.w	color3,$fff
	dc.w	color4,$daa
	dc.w	color5,$b66
	dc.w	color6,$a22
	dc.w	color7,$800

	dc.w	color17,$0f0
	dc.w	color18,$660
	dc.w	color19,$770
	dc.w	color20,$005
	dc.w	color21,$007
	dc.w	color22,$228
	dc.w	color23,$449
	dc.w	color24,$55a
	dc.w	color25,$66b
	dc.w	color26,$c00
	dc.w	color27,$b0b
	dc.w	color28,$808
	dc.w	color29,$606
	dc.w	color30,$404
	dc.w	color31,$550

	dc.w	$2d01,$ff00
	dc.w	color17,$335

	dc.w	$2e01,$ff00
	dc.w	color17,$446

	dc.w	$2f01,$ff00
	dc.w	color17,$557

	dc.w	$3001,$ff00
	dc.w	color17,$668

	dc.w	$3101,$ff00
	dc.w	color17,$779

	dc.w	$3201,$ff00
	dc.w	color17,$88a

	dc.w	$3301,$ff00
	dc.w	color17,$99b

	dc.w	$3401,$ff00
	dc.w	color17,$543

	dc.w	$3501,$ff00
	dc.w	color17,$654

	dc.w	$3601,$ff00
	dc.w	color17,$765

	dc.w	$3701,$ff00
	dc.w	color17,$876

	dc.w	$3801,$ff00
	dc.w	color17,$987

	dc.w	$3901,$ff00
	dc.w	color17,$a98

	dc.w	$3a01,$ff00
	dc.w	color17,$ba9

	dc.w	$3ad1,$fffe

	dc.w	spr2pth
sp2h2	dc.w	0,spr2ptl
sp2l2	dc.w	0,spr3pth
sp3h2	dc.w	0,spr3ptl
sp3l2	dc.w	0

	dc.w	bplcon2,0

	dc.w	color25,$89a
	dc.w	color26,$789
	dc.w	color29,$89a
	dc.w	color30,$789
	dc.w	color17,$567
	dc.w	color21,$567
	dc.w	color18,$456
	dc.w	color22,$456
	dc.w	color19,$345
	dc.w	color23,$345

	dc.w	$3c41,$fffe
	dc.w	color0,$678

	dc.w	$3cd1,$fffe
	dc.w	color0,0

	dc.w	$3d41,$fffe
	dc.w	color0,$678

	dc.w	$3dd1,$fffe
	dc.w	color0,0

	dc.w	$3e41,$fffe
	dc.w	color0,$678

	dc.w	$3ed1,$fffe
	dc.w	color0,0

	dc.w	$3f41,$fffe
	dc.w	color0,$678

	dc.w	$3fd1,$fffe
	dc.w	color0,0

	dc.w	$4041,$fffe
	dc.w	color0,$678

	dc.w	$40d1,$fffe
	dc.w	color0,0

	dc.w	$4141,$fffe
	dc.w	color0,$678

	dc.w	$41d1,$fffe
	dc.w	color0,0

	dc.w	$4201,$ff00

	dc.w	bpl2pth		clouds2
bp2h2	dc.w	0,bpl2ptl
bp2l2	dc.w	0,bpl4pth
bp4h2	dc.w	0,bpl4ptl
bp4l2	dc.w	0,bpl6pth
bp6h2	dc.w	0,bpl6ptl
bp6l2	dc.w	0

	dc.w	bplcon1
scroll2	dc.w	0

	dc.w	$4241,$fffe
	dc.w	color0,$678

	dc.w	$42d1,$fffe
	dc.w	color0,0

	dc.w	$4341,$fffe
	dc.w	color0,$678

	dc.w	$43d1,$fffe
	dc.w	color0,0

	dc.w	$4441,$fffe
	dc.w	color0,$678

	dc.w	$44d1,$fffe
	dc.w	color0,0

	dc.w	$4541,$fffe
	dc.w	color0,$678

	dc.w	$45d1,$fffe
	dc.w	color0,0

	dc.w	$4641,$fffe
	dc.w	color0,$678

	dc.w	$46d1,$fffe
	dc.w	color0,0

	dc.w	$4741,$fffe
	dc.w	color0,$678

	dc.w	$47d1,$fffe
	dc.w	color0,0

	dc.w	$4841,$fffe
	dc.w	color0,$678

	dc.w	$48d1,$fffe
	dc.w	color0,0

	dc.w	$4941,$fffe
	dc.w	color0,$678

	dc.w	$49d1,$fffe
	dc.w	color0,0

	dc.w	$4a41,$fffe
	dc.w	color0,$678

	dc.w	$4ad1,$fffe
	dc.w	color0,0

	dc.w	$4b41,$fffe
	dc.w	color0,$678

	dc.w	$4bd1,$fffe
	dc.w	color0,0

	dc.w	$4c41,$fffe
	dc.w	color0,$678

	dc.w	$4cd1,$fffe
	dc.w	color0,0

	dc.w	$4d41,$fffe
	dc.w	color0,$678

	dc.w	$4dd1,$fffe
	dc.w	color0,0

	dc.w	$4e41,$fffe
	dc.w	color0,$678

	dc.w	$4ed1,$fffe
	dc.w	color0,0

	dc.w	$4f41,$fffe
	dc.w	color0,$678

	dc.w	$4fd1,$fffe
	dc.w	color0,0

	dc.w	$5041,$fffe
	dc.w	color0,$678

	dc.w	$50d1,$fffe
	dc.w	color0,0

	dc.w	$5141,$fffe
	dc.w	color0,$678

	dc.w	$51d1,$fffe
	dc.w	color0,0

	dc.w	$5241,$fffe
	dc.w	color0,$678

	dc.w	$52d1,$fffe
	dc.w	color0,0

	dc.w	$5341,$fffe
	dc.w	color0,$678

	dc.w	$53d1,$fffe
	dc.w	color0,0

	dc.w	$5441,$fffe
	dc.w	color0,$678

	dc.w	$54d1,$fffe
	dc.w	color0,0

	dc.w	$5541,$fffe
	dc.w	color0,$678

	dc.w	$55d1,$fffe
	dc.w	color0,0

	dc.w	$5641,$fffe
	dc.w	color0,$678

	dc.w	$56d1,$fffe
	dc.w	color0,0

	dc.w	$5741,$fffe
	dc.w	color0,$678

	dc.w	$57d1,$fffe
	dc.w	color0,0

	dc.w	$5841,$fffe
	dc.w	color0,$678

	dc.w	$58d1,$fffe
	dc.w	color0,0

	dc.w	$5901,$ff00
	dc.w	color2,0

	dc.w	$5941,$fffe
	dc.w	color0,$678

	dc.w	$59d1,$fffe
	dc.w	color0,0

	dc.w	$5a41,$fffe
	dc.w	color0,$678

	dc.w	$5ad1,$fffe
	dc.w	color0,0

	dc.w	color17,$889
	dc.w	color18,$778
	dc.w	color19,$667

	dc.w	$5b01,$ff00
	dc.w	color2,$125

	dc.w	$5b41,$fffe
	dc.w	color0,$678

	dc.w	$5bd1,$fffe
	dc.w	color0,0

	dc.w	$5c01,$ff00
	dc.w	color2,$236

	dc.w	$5c41,$fffe
	dc.w	color0,$678

	dc.w	$5cd1,$fffe
	dc.w	color0,0

	dc.w	$5d01,$ff00
	dc.w	color2,$347

	dc.w	$5d41,$fffe
	dc.w	color0,$678

	dc.w	$5dd1,$fffe
	dc.w	color0,0

	dc.w	$5e01,$ff00
	dc.w	color2,$458

	dc.w	$5e41,$fffe
	dc.w	color0,$678

	dc.w	$5ed1,$fffe
	dc.w	color0,0

	dc.w	$5f01,$ff00
	dc.w	color2,$569

	dc.w	$5f41,$fffe
	dc.w	color0,$678

	dc.w	$5fd1,$fffe
	dc.w	color0,0

	dc.w	$6001,$ff00
	dc.w	color2,$67a

	dc.w	$6041,$fffe
	dc.w	color0,$678

	dc.w	$60d1,$fffe
	dc.w	color0,0

	dc.w	$6101,$ff00
	dc.w	color2,$78b

	dc.w	$6141,$fffe
	dc.w	color0,$678

	dc.w	$61d1,$fffe
	dc.w	color0,0

	dc.w	$6201,$ff00
	dc.w	color2,$89c

	dc.w	$6241,$fffe
	dc.w	color0,$678

	dc.w	$62d1,$fffe
	dc.w	color0,0

	dc.w	$6301,$ff00
	dc.w	color2,$9ad

	dc.w	$6341,$fffe
	dc.w	color0,$678

	dc.w	$63d1,$fffe
	dc.w	color0,0

	dc.w	$6401,$ff00
	dc.w	color2,$abe

	dc.w	$6441,$fffe
	dc.w	color0,$678

	dc.w	$64d1,$fffe
	dc.w	color0,0

	dc.w	$6501,$ff00
	dc.w	color2,$bcf

	dc.w	$6541,$fffe
	dc.w	color0,$678

	dc.w	$65d1,$fffe
	dc.w	color0,0

	dc.w	$6601,$ff00
	dc.w	color2,$cdf

	dc.w	$6641,$fffe
	dc.w	color0,$678

	dc.w	$66d1,$fffe
	dc.w	color0,0

	dc.w	$6701,$ff00
	dc.w	color2,$fff

	dc.w	$6741,$fffe
	dc.w	color0,$678

	dc.w	$67d1,$fffe
	dc.w	color0,0

	dc.w	$6801,$ff00
	dc.w	color2,0

	dc.w	$6841,$fffe
	dc.w	color0,$678

	dc.w	$68d1,$fffe
	dc.w	color0,0

	dc.w	$6901,$ff00
	dc.w	color2,$324

	dc.w	$6941,$fffe
	dc.w	color0,$678

	dc.w	$69d1,$fffe
	dc.w	color0,0

	dc.w	$6a01,$ff00
	dc.w	color2,$435

	dc.w	$6a41,$fffe
	dc.w	color0,$678

	dc.w	$6ad1,$fffe
	dc.w	color0,0

	dc.w	$6b01,$ff00

	dc.w	bpl2pth		clouds3
bp2h3	dc.w	0,bpl2ptl
bp2l3	dc.w	0,bpl4pth
bp4h3	dc.w	0,bpl4ptl
bp4l3	dc.w	0,bpl6pth
bp6h3	dc.w	0,bpl6ptl
bp6l3	dc.w	0

	dc.w	bplcon1
scroll3	dc.w	0

	dc.w	color2,$546

	dc.w	$6b41,$fffe
	dc.w	color0,$678

	dc.w	$6bd1,$fffe
	dc.w	color0,0

	dc.w	$6c01,$ff00
	dc.w	color2,$657

	dc.w	$6c41,$fffe
	dc.w	color0,$678

	dc.w	$6cd1,$fffe
	dc.w	color0,0

	dc.w	$6d01,$ff00
	dc.w	color2,$768

	dc.w	$6d41,$fffe
	dc.w	color0,$678

	dc.w	$6dd1,$fffe
	dc.w	color0,0

	dc.w	$6e01,$ff00
	dc.w	color2,$879

	dc.w	$6e41,$fffe
	dc.w	color0,$678

	dc.w	$6ed1,$fffe
	dc.w	color0,0

	dc.w	$6f01,$ff00
	dc.w	color2,$98a

	dc.w	$6f41,$fffe
	dc.w	color0,$678

	dc.w	$6fd1,$fffe
	dc.w	color0,0

	dc.w	$7001,$ff00
	dc.w	color2,$a9b

	dc.w	$7041,$fffe
	dc.w	color0,$678

	dc.w	$70d1,$fffe
	dc.w	color0,0

	dc.w	$7101,$ff00
	dc.w	color2,$bac

	dc.w	color17,$553
	dc.w	color18,$442
	dc.w	color19,$331
	dc.w	color21,$553
	dc.w	color22,$442
	dc.w	color23,$331
	dc.w	color25,$553
	dc.w	color26,$442
	dc.w	color27,$331
	dc.w	color29,$553
	dc.w	color30,$442
	dc.w	color31,$331

	dc.w	bplcon2,$20

	dc.w	$7201,$ff00
	dc.w	color2,$cbd

	dc.w	$7301,$ff00
	dc.w	color2,$dce

	dc.w	$7401,$ff00
	dc.w	color2,$edf

	dc.w	$7501,$ff00
	dc.w	color2,$fef

	dc.w	$7601,$ff00
	dc.w	color2,$fff

	dc.w	$7801,$ff00
	dc.w	color15,$778

	dc.w	$7e01,$ff00

	dc.w	bpl2pth		clouds4
bp2h4	dc.w	0,bpl2ptl
bp2l4	dc.w	0,bpl4pth
bp4h4	dc.w	0,bpl4ptl
bp4l4	dc.w	0,bpl6pth
bp6h4	dc.w	0,bpl6ptl
bp6l4	dc.w	0

	dc.w	bplcon1
scroll4	dc.w	0

	dc.w	$8701,$ff00

	dc.w	bpl2pth		clouds5
bp2h5	dc.w	0,bpl2ptl
bp2l5	dc.w	0,bpl4pth
bp4h5	dc.w	0,bpl4ptl
bp4l5	dc.w	0,bpl6pth
bp6h5	dc.w	0,bpl6ptl
bp6l5	dc.w	0

	dc.w	bplcon1
scroll5	dc.w	0

	dc.w	$8d01,$ff00

	dc.w	bpl2pth		mountains
bp2h6	dc.w	0,bpl2ptl
bp2l6	dc.w	0,bpl4pth
bp4h6	dc.w	0,bpl4ptl
bp4l6	dc.w	0,bpl6pth
bp6h6	dc.w	0,bpl6ptl
bp6l6	dc.w	0

	dc.w	bplcon1
scroll6	dc.w	0

	dc.w	color9,$ba9
	dc.w	color10,$a98
	dc.w	color11,$987
	dc.w	color12,$876
	dc.w	color13,$765
	dc.w	color14,$654

	dc.w	$9301,$ff00
	dc.w	color15,$878

	dc.w	$9c01,$ff00
	dc.w	color5,$987
	dc.w	color1,$876
	dc.w	color2,$765
	dc.w	color3,$654
	dc.w	color4,$543

	dc.w	$a101,$ff00
	dc.w	color15,$978

	dc.w	$ab01,$ff00
	dc.w	color15,$a78

	dc.w	$b101,$ff00
	dc.w	color1,$aaa
	dc.w	color5,$aaa
	dc.w	color7,$555

	dc.w	$b201,$ff00
	dc.w	color6,$124

	dc.w	$b301,$ff00
	dc.w	color15,$b78
	dc.w	color6,$235

	dc.w	$b401,$ff00
	dc.w	color6,$346

	dc.w	$b501,$ff00
	dc.w	color6,$457

	dc.w	$b601,$ff00
	dc.w	color6,$568

	dc.w	$b701,$ff00
	dc.w	color6,$679

	dc.w	$b801,$ff00
	dc.w	color6,$78a

	dc.w	$b901,$ff00
	dc.w	color6,$89b

	dc.w	$ba01,$ff00
	dc.w	color15,$c78
	dc.w	color6,$9ac
	dc.w	color2,$236

	dc.w	$bb01,$ff00
	dc.w	color2,$347
	dc.w	color6,$abd

	dc.w	$bc01,$ff00
	dc.w	color2,$458
	dc.w	color6,$bce

	dc.w	$bd01,$ff00
	dc.w	color2,$67a
	dc.w	color6,$cdf

	dc.w	$be01,$ff00
	dc.w	color2,$89c
	dc.w	color6,$def

	dc.w	$bf01,$ff00
	dc.w	color2,$abe
	dc.w	color6,$eef

	dc.w	$c001,$ff00
	dc.w	color15,$d78
	dc.w	color6,$fff
	dc.w	color2,$453

	dc.w	$c101,$ff00
	dc.w	color2,$546
	dc.w	color6,$321

	dc.w	$c201,$ff00
	dc.w	color2,$657
	dc.w	color6,$432

	dc.w	$c301,$ff00
	dc.w	color2,$768
	dc.w	color6,$543

	dc.w	$c401,$ff00
	dc.w	color2,$879
	dc.w	color6,$654

	dc.w	$c501,$ff00
	dc.w	color2,$98a
	dc.w	color6,$765

	dc.w	$c601,$ff00
	dc.w	color15,$e78
	dc.w	color2,$a9b
	dc.w	color6,$876

	dc.w	$c701,$ff00
	dc.w	color2,$bac
	dc.w	color6,$987

	dc.w	$c801,$ff00
	dc.w	color2,$cbd
	dc.w	color6,$a98

	dc.w	$c901,$ff00
	dc.w	color2,$dce
	dc.w	color6,$ba9

	dc.w	$ca01,$ff00
	dc.w	color15,$f78
	dc.w	color2,$edf
	dc.w	color6,$cba

	dc.w	$cb01,$ff00
	dc.w	color6,$dcb

	dc.w	$cc01,$ff00
	dc.w	color6,$edc

	dc.w	$cd01,$ff00
	dc.w	color6,$fed

	dc.w	$ce01,$ff00
	dc.w	color6,$ffe

	dc.w	$d201,$ff00
	dc.w	color1,$666

	dc.w	$d301,$ff00
	dc.w	color1,$555

	dc.w	$d401,$ff00
	dc.w	color1,$444

	dc.w	$d501,$ff00
	dc.w	color1,$333

	dc.w	$d601,$ff00
	dc.w	color9,$780
	dc.w	color10,$670
	dc.w	color11,$560
	dc.w	color12,$450
	dc.w	color13,$340
	dc.w	color14,$230
	dc.w	color15,$890

	dc.w	bpl2pth		grass1
bp2h7	dc.w	0,bpl2ptl
bp2l7	dc.w	0,bpl4pth
bp4h7	dc.w	0,bpl4ptl
bp4l7	dc.w	0,bpl6pth
bp6h7	dc.w	0,bpl6ptl
bp6l7	dc.w	0

	dc.w	bplcon1
scroll7	dc.w	0

	dc.w	color1,$222

	dc.w	$d701,$ff00
	dc.w	color1,$111

	dc.w	$d801,$ff00

	dc.w	bpl2pth		grass2
bp2h8	dc.w	0,bpl2ptl
bp2l8	dc.w	0,bpl4pth
bp4h8	dc.w	0,bpl4ptl
bp4l8	dc.w	0,bpl6pth
bp6h8	dc.w	0,bpl6ptl
bp6l8	dc.w	0

	dc.w	bplcon1
scroll8	dc.w	0

	dc.w	color1,0

	dc.w	$db01,$ff00

	dc.w	bpl2pth		grass3
bp2h9	dc.w	0,bpl2ptl
bp2l9	dc.w	0,bpl4pth
bp4h9	dc.w	0,bpl4ptl
bp4l9	dc.w	0,bpl6pth
bp6h9	dc.w	0,bpl6ptl
bp6l9	dc.w	0

	dc.w	bplcon1
scroll9	dc.w	0

	dc.w	$df01,$ff00
	dc.w	color1,$555
	dc.w	color2,$444
	dc.w	color3,$333
	dc.w	color4,$222
	dc.w	color5,$321
	dc.w	color6,$542
	dc.w	color7,$431

	dc.w	bpl1pth		fence
bp1h2	dc.w	0,bpl1ptl
bp1l2	dc.w	0,bpl3pth
bp3h2	dc.w	0,bpl3ptl
bp3l2	dc.w	0,bpl5pth
bp5h2	dc.w	0,bpl5ptl
bp5l2	dc.w	0

	dc.w	bplcon1
scroll10
	dc.w	0

	dc.w	$e201,$ff00

	dc.w	bpl2pth		grass4
bp2h10	dc.w	0,bpl2ptl
bp2l10	dc.w	0,bpl4pth
bp4h10	dc.w	0,bpl4ptl
bp4l10	dc.w	0,bpl6pth
bp6h10	dc.w	0,bpl6ptl
bp6l10	dc.w	0

	dc.w	bplcon1
scroll11
	dc.w	0

	dc.w	$e901,$ff00

	dc.w	bpl2pth		grass5
bp2h11	dc.w	0,bpl2ptl
bp2l11	dc.w	0,bpl4pth
bp4h11	dc.w	0,bpl4ptl
bp4l11	dc.w	0,bpl6pth
bp6h11	dc.w	0,bpl6ptl
bp6l11	dc.w	0

	dc.w	bplcon1
scroll12
	dc.w	0

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe	END


;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
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
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02a
vhposw	equ	$02c
copcon	equ	$02e
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03a
strhor	equ	$03c
strlong	equ	$03e
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04a
bltbpth	equ	$04c
bltbptl	equ	$04e
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
dsksync	equ	$07e
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08a
copins	equ	$08c
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
bpldat	equ	$110
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
color5	equ	$18a
color6	equ	$18c
color7	equ	$18e
color8	equ	$190
color9	equ	$192
color10	equ	$194
color11	equ	$196
color12	equ	$198
color13	equ	$19a
color14	equ	$19c
color15	equ	$19e
color16	equ	$1a0
color17	equ	$1a2
color18	equ	$1a4
color19	equ	$1a6
color20	equ	$1a8
color21	equ	$1aa
color22	equ	$1ac
color23	equ	$1ae
color24	equ	$1b0
color25	equ	$1b2
color26	equ	$1b4
color27	equ	$1b6
color28	equ	$1b8
color29	equ	$1ba
color30	equ	$1bc
color31	equ	$1be


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0


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

playfield1	incbin	playfield1.bin
playfield2	incbin	playfield2.bin

energy1	dc.w	$2d53,$3b00
	dc.w	$00e0,$0000
	dc.w	$01e0,$0000
	dc.w	$03e0,$0000
	dc.w	$07e0,$0000
	dc.w	$0fe0,$0000
	dc.w	$01e0,$0000
	dc.w	$01e0,$0000
	dc.w	$01e0,$0000
	dc.w	$01e0,$0000
	dc.w	$01e0,$0000
	dc.w	$01e0,$0000
	dc.w	$03e0,$0000
	dc.w	$01f0,$0000
	dc.w	$00f0,$0000
largeship1
	dc.w	$4000,$5b00
	dc.w	$0000,$7fc0
	dc.w	$0000,$fc00
	dc.w	$0000,$fff0
	dc.w	$0000,$ffff
	dc.w	$0000,$ffff
	dc.w	$0005,$fffa
	dc.w	$000b,$7ff4
	dc.w	$00bf,$7f40
	dc.w	$00ea,$3f15
	dc.w	$03f4,$1c0b
	dc.w	$07a9,$0856
	dc.w	$0e40,$11bf
	dc.w	$1902,$06ff
	dc.w	$0008,$1fff
	dc.w	$1801,$1fff
	dc.w	$16a8,$1fff
	dc.w	$0d55,$0fff
	dc.w	$1fba,$1fff
	dc.w	$3fef,$3fff
	dc.w	$1ffd,$7fff
	dc.w	$0fff,$7fff
	dc.w	$0fff,$ffff
	dc.w	$00ff,$ffff
	dc.w	$000f,$ffff
	dc.w	$0000,$fff1
	dc.w	$0000,$fc00
	dc.w	$0000,$7fc0
smallship1
	dc.w	$6100,$7000
	dc.w	$002a,$00d5
	dc.w	$0157,$0ea8
	dc.w	$07ff,$3800
	dc.w	$1f55,$60aa
	dc.w	$7aaa,$8555
	dc.w	$9040,$6fbf
	dc.w	$8200,$ffff
	dc.w	$e844,$ffff
	dc.w	$d510,$ffff
	dc.w	$7aaa,$7fff
	dc.w	$3f55,$3fff
	dc.w	$0fff,$0fff
	dc.w	$00ff,$00ff
	dc.w	$0000,$0000
	dc.w	$0000,$0000
tree1	dc.w	$72d8,$db00
	dc.w	$0000,$0003
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0100
	dc.w	$0000,$0080
	dc.w	$0000,$0080
	dc.w	$0000,$40c0
	dc.w	$0000,$2040
	dc.w	$0000,$2030
	dc.w	$0010,$101e
	dc.w	$0000,$187f
	dc.w	$0000,$0fc1
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0078
	dc.w	$0030,$003f
	dc.w	$001c,$001f
	dc.w	$000e,$000f
	dc.w	$000f,$000f
	dc.w	$004f,$005f
	dc.w	$007d,$007f
	dc.w	$0034,$003f
	dc.w	$000f,$000f
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$0000,$4000
	dc.w	$0000,$3000
	dc.w	$0000,$0c00
	dc.w	$0000,$0600
	dc.w	$0000,$0300
	dc.w	$0000,$0100
	dc.w	$0100,$0180
	dc.w	$0000,$00c0
	dc.w	$0040,$0060
	dc.w	$0060,$0070
	dc.w	$0030,$0038
	dc.w	$0018,$001c
	dc.w	$000c,$000f
	dc.w	$0003,$0003
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0003,$0003
	dc.w	$000f,$000e
	dc.w	$0008,$000f
	dc.w	$0008,$000e
	dc.w	$0018,$001e
	dc.w	$0010,$001c
	dc.w	$0010,$0010
	dc.w	$0000,$0010
	dc.w	$0070,$0078
	dc.w	$0080,$008c
	dc.w	$0100,$0104
	dc.w	$0200,$0206
	dc.w	$0400,$0402
	dc.w	$0800,$0802
	dc.w	$0800,$0802
	dc.w	$0000,$0002
	dc.w	$0000,$0002
	dc.w	$0000,$0002
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

energy2	dc.w	$2d5d,$3b00
	dc.w	$07f0,$0000
	dc.w	$0ffc,$0000
	dc.w	$1e3e,$0000
	dc.w	$307e,$0000
	dc.w	$007e,$0000
	dc.w	$00fc,$0000
	dc.w	$01f0,$0000
	dc.w	$03e0,$0000
	dc.w	$07c0,$0000
	dc.w	$0f00,$0000
	dc.w	$1e00,$0000
	dc.w	$3f00,$0000
	dc.w	$7ffc,$0000
	dc.w	$fff8,$0000
largeship2
	dc.w	$4000,$5b00
	dc.w	$0000,$007f
	dc.w	$0044,$0fbb
	dc.w	$022a,$fdd5
	dc.w	$155d,$eaa2
	dc.w	$2bf7,$d408
	dc.w	$7fff,$8000
	dc.w	$ffba,$0045
	dc.w	$d555,$2aaa
	dc.w	$aa22,$55dd
	dc.w	$4480,$bb7f
	dc.w	$1000,$efff
	dc.w	$0000,$ffff
	dc.w	$1210,$ffff
	dc.w	$4481,$ffff
	dc.w	$1114,$ffff
	dc.w	$8aa2,$ffff
	dc.w	$5555,$ffff
	dc.w	$aaaa,$ffff
	dc.w	$d555,$ffff
	dc.w	$7aee,$ffff
	dc.w	$efbb,$ffff
	dc.w	$fdef,$ffff
	dc.w	$ffff,$ffff
	dc.w	$fffd,$ffff
	dc.w	$ffff,$ffff
	dc.w	$0fff,$1fff
	dc.w	$003f,$007f
smallship2
	dc.w	$6100,$7000
	dc.w	$a800,$543e
	dc.w	$f400,$0b9f
	dc.w	$fe00,$01ff
	dc.w	$5fe0,$a01e
	dc.w	$aac0,$553c
	dc.w	$5400,$abfc
	dc.w	$0000,$fffc
	dc.w	$0000,$fffc
	dc.w	$4000,$fffe
	dc.w	$aab8,$ffff
	dc.w	$55e0,$ffff
	dc.w	$ff80,$ff9f
	dc.w	$f800,$f83e
	dc.w	$0000,$0000
	dc.w	$0000,$0000
tree2	dc.w	$72e0,$db00
	dc.w	$0000,$c010
	dc.w	$0000,$6408
	dc.w	$0000,$3608
	dc.w	$0000,$0f04
	dc.w	$0000,$07c4
	dc.w	$0000,$00e4
	dc.w	$0000,$003c
	dc.w	$0000,$001e
	dc.w	$000c,$000f
	dc.w	$0002,$0003
	dc.w	$0003,$0003
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$6000,$8000
	dc.w	$3800,$c400
	dc.w	$0e00,$3100
	dc.w	$1380,$1c00
	dc.w	$0ce0,$0f00
	dc.w	$0730,$07c8
	dc.w	$01df,$01e0
	dc.w	$4001,$bffe
	dc.w	$7200,$8dff
	dc.w	$0fac,$f053
	dc.w	$c07e,$ff85
	dc.w	$5007,$ffff
	dc.w	$c600,$ffff
	dc.w	$f8ee,$ffff
	dc.w	$ffe1,$ffff
	dc.w	$ffbe,$ffff
	dc.w	$00ff,$00ff
	dc.w	$0007,$0007
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0180
	dc.w	$0000,$00c0
	dc.w	$0000,$0070
	dc.w	$0020,$0038
	dc.w	$0008,$000e
	dc.w	$0008,$000e
	dc.w	$0000,$00ff
	dc.w	$0000,$0181
	dc.w	$0001,$0101
	dc.w	$0000,$c000
	dc.w	$c000,$b000
	dc.w	$5800,$6400
	dc.w	$3700,$8800
	dc.w	$c540,$3aa0
	dc.w	$0028,$ffd4
	dc.w	$3305,$3ffa
	dc.w	$0fd0,$0fff
	dc.w	$0032,$003f
	dc.w	$000e,$000f
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0001
	dc.w	$0000,$0001
	dc.w	$0000,$0003
	dc.w	$0001,$0007
	dc.w	$0000,$000f
	dc.w	$0000,$000f
	dc.w	$0004,$001d
	dc.w	$011c,$01fc
	dc.w	$0220,$03e0
	dc.w	$0320,$03e0
	dc.w	$0600,$07c0
	dc.w	$0440,$07c0
	dc.w	$0600,$0700
	dc.w	$0600,$0700
	dc.w	$0600,$0780
	dc.w	$0200,$0380
	dc.w	$0100,$01c0
	dc.w	$0080,$00f8
	dc.w	$0080,$00e6
	dc.w	$0000,$00a1
	dc.w	$0000,$0110
	dc.w	$0100,$0118
	dc.w	$0100,$010c
	dc.w	$0000,$0106
	dc.w	$0080,$0083
	dc.w	$00c0,$00c0
	dc.w	$0060,$0060
	dc.w	$0020,$0020
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

largeship3
	dc.w	$4000,$5b00
	dc.w	$0000,$ffc0
	dc.w	$4400,$bbfe
	dc.w	$aaa0,$555f
	dc.w	$d755,$28aa
	dc.w	$7df6,$8209
	dc.w	$ffff,$0000
	dc.w	$eabe,$1541
	dc.w	$5555,$aaaa
	dc.w	$220a,$ddf5
	dc.w	$0841,$f7be
	dc.w	$8000,$7fff
	dc.w	$0000,$ffff
	dc.w	$2110,$ffff
	dc.w	$0441,$ffff
	dc.w	$5114,$ffff
	dc.w	$a8a8,$ffff
	dc.w	$5555,$ffff
	dc.w	$aaaa,$ffff
	dc.w	$555d,$ffff
	dc.w	$abb7,$ffff
	dc.w	$feaf,$ffff
	dc.w	$6bfd,$ffff
	dc.w	$ffff,$ffff
	dc.w	$ffff,$ffff
	dc.w	$ffff,$ffff
	dc.w	$fffe,$ffff
	dc.w	$ff80,$ffc0
tree3	dc.w	$72e8,$db00
	dc.w	$0000,$0040
	dc.w	$0000,$0080
	dc.w	$0000,$0100
	dc.w	$0000,$1f00
	dc.w	$0000,$3e00
	dc.w	$0000,$3000
	dc.w	$0000,$6000
	dc.w	$0000,$e000
	dc.w	$0000,$e000
	dc.w	$4000,$a000
	dc.w	$2000,$d000
	dc.w	$9000,$e000
	dc.w	$d800,$e000
	dc.w	$6800,$7600
	dc.w	$3400,$3b00
	dc.w	$1a00,$1d80
	dc.w	$0d00,$0e80
	dc.w	$0680,$0740
	dc.w	$0260,$0380
	dc.w	$01a0,$01d0
	dc.w	$0190,$01e8
	dc.w	$00f8,$80e4
	dc.w	$c04c,$0072
	dc.w	$387a,$c075
	dc.w	$cc2a,$3235
	dc.w	$fb9b,$041e
	dc.w	$eef8,$d91f
	dc.w	$27cf,$fc3e
	dc.w	$96b7,$fb4e
	dc.w	$1b53,$fdaf
	dc.w	$f18b,$fef5
	dc.w	$bc44,$fffb
	dc.w	$ee91,$ffee
	dc.w	$3788,$3ff7
	dc.w	$1fc6,$1ffb
	dc.w	$078b,$07fd
	dc.w	$078c,$07ff
	dc.w	$03ca,$03ff
	dc.w	$017d,$01ff
	dc.w	$01ec,$01ff
	dc.w	$00fc,$00ff
	dc.w	$007d,$007f
	dc.w	$007c,$007f
	dc.w	$00fe,$0cff
	dc.w	$00ff,$10ff
	dc.w	$00ff,$10ff
	dc.w	$007f,$907f
	dc.w	$003f,$903f
	dc.w	$001f,$d01f
	dc.w	$0000,$f000
	dc.w	$8000,$f000
	dc.w	$7000,$6800
	dc.w	$4400,$7800
	dc.w	$3100,$3e00
	dc.w	$1500,$1e80
	dc.w	$08c0,$8f00
	dc.w	$7e20,$8fc0
	dc.w	$857c,$fa80
	dc.w	$605f,$ffa0
	dc.w	$c101,$fffe
	dc.w	$4e1c,$7fff
	dc.w	$1081,$7fff
	dc.w	$1468,$ffff
	dc.w	$07fc,$ffff
	dc.w	$3cff,$fcff
	dc.w	$701f,$f01f
	dc.w	$c007,$c007
	dc.w	$c001,$c001
	dc.w	$4000,$8000
	dc.w	$4000,$8000
	dc.w	$4000,$8000
	dc.w	$4000,$8000
	dc.w	$6000,$8000
	dc.w	$2000,$4000
	dc.w	$2000,$4000
	dc.w	$1000,$2000
	dc.w	$1000,$2000
	dc.w	$1000,$0000
	dc.w	$0800,$0000
	dc.w	$0000,$0800
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0800
	dc.w	$0000,$ff00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

largeship4
	dc.w	$4000,$5b00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$e000
	dc.w	$4000,$bc00
	dc.w	$e000,$1f00
	dc.w	$d800,$27c0
	dc.w	$fb00,$04e0
	dc.w	$7e80,$8178
	dc.w	$afe0,$501c
	dc.w	$0ab4,$f54a
	dc.w	$2458,$dba6
	dc.w	$008c,$ff73
	dc.w	$0012,$ffed
	dc.w	$1100,$ffff
	dc.w	$4449,$ffff
	dc.w	$a8b5,$ffff
	dc.w	$555e,$ffff
	dc.w	$abb6,$fffe
	dc.w	$bafc,$fffe
	dc.w	$6ff8,$fffc
	dc.w	$ffe0,$fff0
	dc.w	$ffc0,$ffe0
	dc.w	$ff00,$ff80
	dc.w	$fc00,$fe00
	dc.w	$e000,$f000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
tree4	dc.w	$72f0,$db00
	dc.w	$0000,$0008
	dc.w	$0000,$0008
	dc.w	$0000,$000c
	dc.w	$0008,$000c
	dc.w	$0006,$0006
	dc.w	$0002,$0003
	dc.w	$0000,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0200
	dc.w	$0000,$0e00
	dc.w	$0200,$0400
	dc.w	$0100,$4600
	dc.w	$5000,$7700
	dc.w	$7200,$7d00
	dc.w	$2a00,$3d80
	dc.w	$2880,$3f00
	dc.w	$3440,$3f80
	dc.w	$3c98,$3f60
	dc.w	$18e8,$1f14
	dc.w	$0f58,$0fa4
	dc.w	$0c68,$8f94
	dc.w	$849c,$47e0
	dc.w	$861c,$67e0
	dc.w	$c348,$23f4
	dc.w	$63c0,$93fe
	dc.w	$31a2,$c9fd
	dc.w	$b9f3,$45fc
	dc.w	$dcd2,$e2fd
	dc.w	$a642,$d97d
	dc.w	$0734,$f8bf
	dc.w	$2597,$fa5e
	dc.w	$9452,$fbbf
	dc.w	$66c8,$f93f
	dc.w	$70ed,$ff1f
	dc.w	$5a56,$efaf
	dc.w	$7d6a,$e397
	dc.w	$062b,$f9d7
	dc.w	$f7f4,$fe6b
	dc.w	$d1e2,$ffbd
	dc.w	$be31,$ffde
	dc.w	$c9b8,$ffdf
	dc.w	$e85c,$ffef
	dc.w	$df7d,$fcf7
	dc.w	$f40f,$fffb
	dc.w	$f4c7,$ff3f
	dc.w	$3263,$3f9f
	dc.w	$3a71,$3f8f
	dc.w	$183c,$3fc3
	dc.w	$1f2c,$1fdf
	dc.w	$0ffe,$0fc5
	dc.w	$0796,$0fef
	dc.w	$036d,$03f3
	dc.w	$03b4,$03fb
	dc.w	$017e,$01fd
	dc.w	$817b,$0096
	dc.w	$fff3,$000d
	dc.w	$06e9,$f916
	dc.w	$f840,$ffbf
	dc.w	$fe09,$dff6
	dc.w	$6fce,$df31
	dc.w	$d7c2,$effd
	dc.w	$cf21,$f0fe
	dc.w	$b631,$fffe
	dc.w	$ddfa,$ffff
	dc.w	$7a66,$7fff
	dc.w	$3dc2,$3fff
	dc.w	$0fa4,$0fff
	dc.w	$037c,$03ff
	dc.w	$01f6,$01ff
	dc.w	$00f1,$00ff
	dc.w	$0030,$003f
	dc.w	$001f,$001f
	dc.w	$000f,$000f
	dc.w	$0006,$0007
	dc.w	$0003,$0003
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0002,$0007
	dc.w	$0008,$000f
	dc.w	$000c,$000f
	dc.w	$000f,$000f
	dc.w	$000f,$000f
	dc.w	$000f,$000f
	dc.w	$0007,$0007
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$00a0,$0350
	dc.w	$0016,$1fe9
	dc.w	$01e1,$7ffe
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

bluepotion1
	dc.w	$2dc2,$3b00
	dc.w	$0280,$0380
	dc.w	$0280,$0380
	dc.w	$0280,$0180
	dc.w	$0280,$0180
	dc.w	$0280,$0180
	dc.w	$0680,$01c0
	dc.w	$0540,$0340
	dc.w	$0540,$0360
	dc.w	$0c60,$0330
	dc.w	$0c30,$0198
	dc.w	$0c50,$01d8
	dc.w	$0668,$00f0
	dc.w	$0390,$0060
	dc.w	$00c0,$0000
moon1	dc.w	$3ca0,$7100
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0001
	dc.w	$0000,$0003
	dc.w	$0000,$0007
	dc.w	$0000,$000e
	dc.w	$0000,$000a
	dc.w	$0000,$0014
	dc.w	$0000,$0018
	dc.w	$0000,$0020
	dc.w	$0000,$0010
	dc.w	$0000,$0000
	dc.w	$0000,$0040
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0080
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
tree5	dc.w	$72f8,$db00
	dc.w	$0000,$0000
	dc.w	$0000,$0100
	dc.w	$0000,$0200
	dc.w	$0000,$0200
	dc.w	$0000,$0400
	dc.w	$0000,$0400
	dc.w	$0001,$c400
	dc.w	$8002,$e805
	dc.w	$4004,$780b
	dc.w	$3010,$280f
	dc.w	$3000,$3c1e
	dc.w	$1000,$1c3e
	dc.w	$1063,$1c5c
	dc.w	$1801,$1e7e
	dc.w	$0840,$1e7f
	dc.w	$1843,$1e7f
	dc.w	$0849,$1e7f
	dc.w	$1868,$1e7e
	dc.w	$181a,$1c7e
	dc.w	$1058,$1cfc
	dc.w	$18d4,$1cfc
	dc.w	$12b0,$1ffc
	dc.w	$1320,$1ff8
	dc.w	$1068,$1ff8
	dc.w	$30c0,$3ff0
	dc.w	$02e0,$3fe0
	dc.w	$6280,$7fe0
	dc.w	$4080,$7fc0
	dc.w	$c600,$ffc0
	dc.w	$8700,$ff80
	dc.w	$0700,$ff00
	dc.w	$0a00,$fe00
	dc.w	$8c00,$7e00
	dc.w	$4000,$bc00
	dc.w	$0800,$fc00
	dc.w	$a800,$5400
	dc.w	$ec00,$1000
	dc.w	$4400,$b800
	dc.w	$ac00,$d000
	dc.w	$2400,$d800
	dc.w	$7400,$8800
	dc.w	$d400,$2800
	dc.w	$6c00,$9200
	dc.w	$ee00,$9000
	dc.w	$7a00,$c400
	dc.w	$bb00,$5c07
	dc.w	$7d81,$9e3e
	dc.w	$3e47,$cfb8
	dc.w	$be5b,$c3a4
	dc.w	$8f03,$f1fc
	dc.w	$c996,$f6e9
	dc.w	$f8d4,$f76b
	dc.w	$5a68,$fd97
	dc.w	$3cbd,$fb43
	dc.w	$bcd7,$7f2b
	dc.w	$5e58,$bfa7
	dc.w	$a73d,$dfc3
	dc.w	$509c,$ef63
	dc.w	$b15e,$4fa1
	dc.w	$d98e,$67f1
	dc.w	$ee56,$b1e9
	dc.w	$351a,$cae5
	dc.w	$1c9f,$e360
	dc.w	$2fcc,$d033
	dc.w	$346a,$cb95
	dc.w	$cb9f,$7460
	dc.w	$684f,$b7b0
	dc.w	$0036,$ffc9
	dc.w	$1993,$ef6c
	dc.w	$0ccb,$f7f4
	dc.w	$9736,$fae9
	dc.w	$0f1b,$fdf4
	dc.w	$cfd8,$f6f7
	dc.w	$ffee,$f339
	dc.w	$75f6,$fb9d
	dc.w	$03dd,$fdee
	dc.w	$b1de,$ffe1
	dc.w	$d8e0,$ff7f
	dc.w	$e24a,$ffb5
	dc.w	$f303,$fefe
	dc.w	$f189,$ff77
	dc.w	$f8c0,$ff3f
	dc.w	$7e8b,$fff7
	dc.w	$be4b,$fff7
	dc.w	$d70b,$fff7
	dc.w	$ffab,$fff7
	dc.w	$feab,$fff7
	dc.w	$ffd5,$fffb
	dc.w	$ffe5,$fffb
	dc.w	$7ff2,$7ffd
	dc.w	$3fea,$3ffd
	dc.w	$0ff6,$0ffd
	dc.w	$07f5,$07fe
	dc.w	$03e6,$03ff
	dc.w	$01f3,$01ff
	dc.w	$01f9,$01ff
	dc.w	$00f9,$00ff
	dc.w	$00f0,$00ff
	dc.w	$00fa,$00ff
	dc.w	$00f9,$00ff
	dc.w	$0071,$00ff
	dc.w	$00f8,$00ff
	dc.w	$4038,$a07f
	dc.w	$0000,$0003
	dc.w	$0000,$0000
	dc.w	$0000,$0000

bluepotion2
	dc.w	$2dc2,$3b80
	dc.w	$0200,$0200
	dc.w	$0200,$0200
	dc.w	$0380,$0000
	dc.w	$0380,$0000
	dc.w	$0380,$0000
	dc.w	$07c0,$0000
	dc.w	$0740,$0080
	dc.w	$0f60,$0080
	dc.w	$1e30,$01c0
	dc.w	$3e18,$03e0
	dc.w	$3e58,$03a0
	dc.w	$3ff8,$0100
	dc.w	$1ff0,$0000
	dc.w	$07c0,$0000
moon2	dc.w	$3ca8,$7100
	dc.w	$0003,$0004
	dc.w	$001f,$0020
	dc.w	$00fd,$0102
	dc.w	$03aa,$0455
	dc.w	$0d15,$12ea
	dc.w	$1040,$2db7
	dc.w	$0012,$7fed
	dc.w	$0001,$f558
	dc.w	$0000,$aaa3
	dc.w	$00d0,$1f00
	dc.w	$0000,$2748
	dc.w	$0000,$8087
	dc.w	$0000,$14a1
	dc.w	$0000,$02dc
	dc.w	$0000,$4006
	dc.w	$0000,$00b1
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0011
	dc.w	$0000,$0100
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0004
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0010
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0050
	dc.w	$0000,$0004
tree6	dc.w	$7200,$db00
	dc.w	$0000,$0000
	dc.w	$0000,$0040
	dc.w	$0000,$0043
	dc.w	$0000,$0042
	dc.w	$0004,$0082
	dc.w	$6c18,$9184
	dc.w	$0bf0,$f40c
	dc.w	$0000,$fff8
	dc.w	$0000,$0e00
	dc.w	$0100,$0200
	dc.w	$0000,$0100
	dc.w	$0080,$0000
	dc.w	$0040,$0000
	dc.w	$4021,$a000
	dc.w	$b800,$4001
	dc.w	$0406,$f801
	dc.w	$f998,$fe07
	dc.w	$3ca1,$3f5f
	dc.w	$0f4b,$0fff
	dc.w	$01fe,$01fe
	dc.w	$0030,$0030
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$1000
	dc.w	$0000,$1080
	dc.w	$0000,$0880
	dc.w	$0000,$0880
	dc.w	$0000,$0500
	dc.w	$0000,$0300
	dc.w	$0000,$0101
	dc.w	$0000,$0303
	dc.w	$0003,$030c
	dc.w	$000a,$0215
	dc.w	$0038,$0647
	dc.w	$0061,$079f
	dc.w	$01c5,$063f
	dc.w	$035f,$0cff
	dc.w	$0498,$7bf8
	dc.w	$11f0,$eff0
	dc.w	$7180,$8f80
	dc.w	$8700,$7f00
	dc.w	$8e00,$7e00
	dc.w	$3c00,$fc00
	dc.w	$5800,$f800
	dc.w	$3000,$f000
	dc.w	$f000,$f000
	dc.w	$e000,$e000
	dc.w	$6000,$e000
	dc.w	$4000,$c000
	dc.w	$c000,$c000
	dc.w	$8000,$8000
	dc.w	$8000,$8000
	dc.w	$0000,$8000
	dc.w	$8000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$8000,$0000
	dc.w	$8000,$4000
	dc.w	$0000,$c000
	dc.w	$2000,$c000
	dc.w	$f000,$0000
	dc.w	$4800,$b000
	dc.w	$8e00,$7000
	dc.w	$cb80,$3400
	dc.w	$59c0,$a600
	dc.w	$c4c0,$3b00
	dc.w	$eae0,$1500
	dc.w	$6360,$9c80
	dc.w	$5860,$af80
	dc.w	$39a0,$ce40
	dc.w	$dc60,$2780
	dc.w	$3c20,$c7c0
	dc.w	$0e60,$f380
	dc.w	$e320,$1dc0
	dc.w	$a310,$5ce0
	dc.w	$1190,$ee60
	dc.w	$ca90,$f560
	dc.w	$e6c8,$f930
	dc.w	$f528,$fad4
	dc.w	$f390,$fc6c
	dc.w	$f938,$fec6
	dc.w	$fc88,$ff77
	dc.w	$fe06,$fff9
	dc.w	$fe46,$d7b9
	dc.w	$ff33,$ffdc
	dc.w	$bf29,$7fde
	dc.w	$5fb9,$bfce
	dc.w	$5fb4,$bfcf
	dc.w	$2fda,$dfe7
	dc.w	$17d6,$efeb
	dc.w	$8bc5,$f7fb
	dc.w	$c6ef,$f9f1
	dc.w	$a1ed,$fe12
	dc.w	$94b2,$ff4d
	dc.w	$bd02,$fffd
	dc.w	$9f57,$ffe8
	dc.w	$0503,$fffc
	dc.w	$0000,$0000
	dc.w	$0000,$0000

redpotion1
	dc.w	$2dcc,$3b00
	dc.w	$0280,$0380
	dc.w	$0280,$0380
	dc.w	$0280,$0080
	dc.w	$0280,$0080
	dc.w	$0280,$0080
	dc.w	$06c0,$0080
	dc.w	$0400,$0100
	dc.w	$0520,$0b80
	dc.w	$0b90,$17c0
	dc.w	$07c8,$3fe0
	dc.w	$03a0,$3fe0
	dc.w	$0108,$3f80
	dc.w	$00d0,$1f00
	dc.w	$0040,$0780
moon3	dc.w	$3cb0,$7100
	dc.w	$fe00,$0100
	dc.w	$f7e0,$0810
	dc.w	$6fd8,$9024
	dc.w	$83fe,$7c01
	dc.w	$097e,$c681
	dc.w	$2bbf,$9440
	dc.w	$9467,$6b98
	dc.w	$063d,$b9c2
	dc.w	$007b,$c784
	dc.w	$1009,$6bb6
	dc.w	$2300,$580f
	dc.w	$060d,$e9c2
	dc.w	$0403,$73b4
	dc.w	$0404,$5ad3
	dc.w	$0601,$48a4
	dc.w	$0601,$59dc
	dc.w	$0300,$a834
	dc.w	$03dc,$0003
	dc.w	$00f8,$2801
	dc.w	$0000,$11d7
	dc.w	$0001,$043a
	dc.w	$0000,$8654
	dc.w	$0000,$4917
	dc.w	$0002,$2181
	dc.w	$0002,$026c
	dc.w	$0000,$000f
	dc.w	$0002,$20b0
	dc.w	$0000,$1907
	dc.w	$0000,$2431
	dc.w	$0000,$0027
	dc.w	$0000,$0085
	dc.w	$0000,$0001
	dc.w	$0000,$0004
	dc.w	$0009,$4124
	dc.w	$0000,$0009
	dc.w	$0000,$0431
	dc.w	$0000,$801f
	dc.w	$0000,$0003
	dc.w	$0000,$0019
	dc.w	$0001,$0080
	dc.w	$0000,$0105
	dc.w	$0000,$0004
	dc.w	$0000,$012b
	dc.w	$0002,$0005
	dc.w	$0000,$09f7
	dc.w	$0000,$000f
	dc.w	$0000,$0427
	dc.w	$0001,$04be
	dc.w	$0004,$023b
	dc.w	$000b,$02b4
	dc.w	$0004,$097a
	dc.w	$0000,$05f0
	dc.w	$0000,$af00
tree7	dc.w	$7208,$db20
	dc.w	$7000,$0020
	dc.w	$0000,$8020
	dc.w	$0000,$0020
	dc.w	$0000,$0021
	dc.w	$0080,$0061
	dc.w	$0200,$01c2
	dc.w	$0400,$027e
	dc.w	$1000,$0c00
	dc.w	$0000,$1000
	dc.w	$2000,$1000
	dc.w	$8000,$6000
	dc.w	$0000,$c000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0001
	dc.w	$0000,$0003
	dc.w	$0000,$0002
	dc.w	$0000,$000e
	dc.w	$0018,$0026
	dc.w	$0070,$018f
	dc.w	$01c1,$023f
	dc.w	$038f,$047f
	dc.w	$0300,$04e0
	dc.w	$0300,$04c0
	dc.w	$0000,$07c0
	dc.w	$0000,$07c0
	dc.w	$0000,$0fc0
	dc.w	$0300,$3f80
	dc.w	$0200,$ff80
	dc.w	$eb00,$1f00
	dc.w	$8a00,$7f00
	dc.w	$1800,$fe00
	dc.w	$3800,$fe00
	dc.w	$d000,$ff00
	dc.w	$fa00,$ff80
	dc.w	$0f00,$0fc0
	dc.w	$0380,$03e0
	dc.w	$0040,$0070
	dc.w	$0020,$0038
	dc.w	$0010,$001c
	dc.w	$0008,$000e
	dc.w	$0004,$0006
	dc.w	$0002,$0003
	dc.w	$0000,$0001
	dc.w	$0000,$0001
	dc.w	$0000,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0001
	dc.w	$0000,$0003
	dc.w	$0000,$0002
	dc.w	$0000,$0002
	dc.w	$0000,$0001
	dc.w	$0000,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$0000,$c000
	dc.w	$8000,$6000
	dc.w	$0000,$f000
	dc.w	$a000,$5800
	dc.w	$5000,$a800
	dc.w	$a000,$5e00
	dc.w	$6600,$9900
	dc.w	$3a80,$c540
	dc.w	$9800,$e7e0
	dc.w	$9b30,$e7c8
	dc.w	$c1c8,$fff6
	dc.w	$64e5,$fbfa
	dc.w	$7078,$ffff
	dc.w	$8000,$43c0
	dc.w	$0000,$0000
	dc.w	$0000,$0000

redpotion2
	dc.w	$2dcc,$3b80
	dc.w	$0200,$0200
	dc.w	$0200,$0200
	dc.w	$0300,$0380
	dc.w	$0300,$0380
	dc.w	$0300,$0380
	dc.w	$0740,$07c0
	dc.w	$06c0,$07c0
	dc.w	$0d60,$0ee0
	dc.w	$1bb0,$1c70
	dc.w	$37d8,$3838
	dc.w	$3b98,$3c78
	dc.w	$3d78,$3ef8
	dc.w	$1ef0,$1ff0
	dc.w	$07c0,$07c0
moon4	dc.w	$3cb8,$7100
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$8000,$4000
	dc.w	$e000,$0000
	dc.w	$f000,$0000
	dc.w	$f800,$0000
	dc.w	$fc00,$0000
	dc.w	$7e00,$8000
	dc.w	$ff00,$0000
	dc.w	$5b00,$a480
	dc.w	$3a80,$c500
	dc.w	$3780,$c840
	dc.w	$1ec0,$e100
	dc.w	$ebc0,$1400
	dc.w	$d7c0,$2820
	dc.w	$19e0,$e600
	dc.w	$0be0,$b400
	dc.w	$81a0,$7e40
	dc.w	$1be0,$e410
	dc.w	$0370,$3c80
	dc.w	$0b70,$7480
	dc.w	$d570,$2a80
	dc.w	$13f0,$2c00
	dc.w	$0970,$f480
	dc.w	$0570,$5a80
	dc.w	$6af0,$1500
	dc.w	$0070,$2f80
	dc.w	$05f0,$da00
	dc.w	$5270,$8980
	dc.w	$1870,$6780
	dc.w	$70f0,$0f00
	dc.w	$01e0,$fe10
	dc.w	$28e0,$d700
	dc.w	$10a0,$4f40
	dc.w	$18c0,$a720
	dc.w	$0540,$3aa0
	dc.w	$e7c0,$1800
	dc.w	$0180,$fe40
	dc.w	$9680,$6900
	dc.w	$1300,$ec80
	dc.w	$2700,$d800
	dc.w	$1600,$e800
	dc.w	$2c00,$d000
	dc.w	$7800,$8000
	dc.w	$7000,$8000
	dc.w	$e000,$0000
	dc.w	$8000,$4000
	dc.w	$0000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
tree8	dc.w	$7210,$db00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0020
	dc.w	$0000,$0030
	dc.w	$0000,$0014
	dc.w	$0000,$0018
	dc.w	$0000,$0010
	dc.w	$0000,$0030
	dc.w	$0000,$0020
	dc.w	$0000,$0020
	dc.w	$0000,$0060
	dc.w	$0000,$0040
	dc.w	$0000,$00f0
	dc.w	$0000,$3f8c
	dc.w	$0000,$c586
	dc.w	$0000,$8003
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$c000
	dc.w	$c000,$f000
	dc.w	$7000,$7800
	dc.w	$4000,$4c00
	dc.w	$8000,$8600
	dc.w	$8000,$8700
	dc.w	$8000,$86c0
	dc.w	$0000,$0220
	dc.w	$0000,$0018
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$6000
	dc.w	$0000,$b000
	dc.w	$0000,$8800
	dc.w	$0000,$8600
	dc.w	$0000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$0000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$e000,$1000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

pulse1a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0009,$8003
	dc.w	$4005,$c01b
	dc.w	$0001,$8013
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse1b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0009
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$3ffd,$401d
	dc.w	$7ffd,$0011
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse2a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0009,$8003
	dc.w	$2001,$a00f
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse2b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0009
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$5ffd,$600d
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse3a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0009,$8003
	dc.w	$5001,$9007
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse3b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0009
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$6ffd,$7005
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse4a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0809,$8803
	dc.w	$2801,$c807
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse4b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0009
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$77fd,$0801
	dc.w	$77fd,$7805
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse5a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0421,$8413
	dc.w	$0419,$840b
	dc.w	$0401,$840b
	dc.w	$0409,$8403
	dc.w	$1401,$e403
	dc.w	$0401,$8403
	dc.w	$0401,$8403
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0003,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse5b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7bf5,$0409
	dc.w	$7bfd,$0401
	dc.w	$7bfd,$0401
	dc.w	$7bfd,$0c01
	dc.w	$7bfd,$7c01
	dc.w	$7bfd,$0401
	dc.w	$7bfd,$0401
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0003,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse6a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0809,$8003
	dc.w	$0a01,$b203
	dc.w	$0201,$8203
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse6b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0409
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0c01
	dc.w	$7dfd,$3e01
	dc.w	$7dfd,$0601
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse7a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0421,$8013
	dc.w	$0419,$800b
	dc.w	$0401,$800b
	dc.w	$0409,$8803
	dc.w	$0501,$9903
	dc.w	$0401,$8003
	dc.w	$0401,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse7b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0409
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0c01
	dc.w	$7efd,$1f01
	dc.w	$7ffd,$0601
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse8a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8413
	dc.w	$0019,$840b
	dc.w	$0001,$840b
	dc.w	$0009,$8c03
	dc.w	$0281,$8c83
	dc.w	$0201,$8403
	dc.w	$0001,$8403
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse8b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0409
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0c01
	dc.w	$7f7d,$0f81
	dc.w	$7ffd,$0601
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse9a	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8413
	dc.w	$0019,$840b
	dc.w	$0001,$840b
	dc.w	$0049,$8443
	dc.w	$0141,$8643
	dc.w	$0001,$8603
	dc.w	$0001,$8403
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse9b	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0409
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0401
	dc.w	$7fbd,$0441
	dc.w	$7fbd,$07c1
	dc.w	$7ffd,$0601
	dc.w	$7ffd,$0401
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse10a
	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8033
	dc.w	$0039,$802b
	dc.w	$0021,$802b
	dc.w	$0029,$8023
	dc.w	$00a1,$8323
	dc.w	$0021,$8223
	dc.w	$0021,$8023
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0003,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse10b
	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7fd5,$0029
	dc.w	$7fdd,$0021
	dc.w	$7fdd,$0021
	dc.w	$7fdd,$0061
	dc.w	$7fdd,$03e1
	dc.w	$7fdd,$0221
	dc.w	$7fdd,$0021
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0003,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse11a
	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0001,$8013
	dc.w	$0019,$800b
	dc.w	$0001,$800b
	dc.w	$0049,$8003
	dc.w	$0051,$8193
	dc.w	$0011,$8013
	dc.w	$0001,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse11b
	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0029
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0061
	dc.w	$7fed,$01f1
	dc.w	$7fed,$0031
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse12a
	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0021,$8013
	dc.w	$0039,$800b
	dc.w	$0021,$800b
	dc.w	$0029,$8043
	dc.w	$0029,$80cb
	dc.w	$0021,$8003
	dc.w	$0021,$8003
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse12b
	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0029
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0061
	dc.w	$7ff5,$00f9
	dc.w	$7ffd,$0031
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse13a
	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0001,$8033
	dc.w	$0019,$802b
	dc.w	$0001,$802b
	dc.w	$0009,$8063
	dc.w	$0015,$8067
	dc.w	$0011,$8023
	dc.w	$0001,$8023
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse13b
	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0029
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0061
	dc.w	$7ff9,$007d
	dc.w	$7ffd,$0031
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse14a
	dc.w	$2c49,$3b00
	dc.w	$0280,$0380
	dc.w	$0000,$7ffc
	dc.w	$4004,$c006
	dc.w	$00a9,$8063
	dc.w	$0001,$8033
	dc.w	$0019,$802b
	dc.w	$0001,$802b
	dc.w	$0009,$8023
	dc.w	$0009,$8033
	dc.w	$0001,$8033
	dc.w	$0001,$8023
	dc.w	$0001,$8003
	dc.w	$4005,$c007
	dc.w	$0043,$7fff
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000

pulse14b
	dc.w	$2c49,$3b80
	dc.w	$0200,$0200
	dc.w	$0000,$0000
	dc.w	$7ffc,$4004
	dc.w	$7fe5,$0019
	dc.w	$7ff5,$0029
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$003d
	dc.w	$7ffd,$0031
	dc.w	$7ffd,$0021
	dc.w	$7ffd,$0001
	dc.w	$7ffd,$4005
	dc.w	$0043,$0053
	dc.w	$3ffe,$3ffe
	dc.w	$0000,$0000
