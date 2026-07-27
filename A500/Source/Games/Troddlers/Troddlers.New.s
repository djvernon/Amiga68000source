	section	Trodd,code_c

;******** Troddlers Sales Curve Software Scaling Intro ********

; Left mouse button to exit, right mouse button to pause

; Uncomment one of following lines to see just horizontal or vertical scale
;TEST_HORIZ_SCALE1	equ	1
;TEST_HORIZ_SCALE2	equ	1
;TEST_VERT_SCALE	equ	1

;DEBUG	equ	1

start	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		; turn multitasking off
	ENDC

	lea	graphics.library(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		; OpenLibrary
	tst.l	d0
	beq	finish_now

	move.l	d0,gfxbase
	move.l	d0,a6
	IFND	DEBUG
	jsr	-456(a6)		; OwnBlitter
	ENDC
	move.l	38(a6),saved_copper

	lea	$dff000,a0
	move.w	dmaconr(a0),saved_dmacon	; save system DMA status
	move.w	intenar(a0),saved_intena	; save system interrupt status
	IFND	DEBUG
	move.w	#$7fff,dmacon(a0)
	move.w	#$7fff,intena(a0)
	move.w	#$7fff,intreq(a0)
	move.w	#0,color0(a0)
	move.w	#$8210,dmacon(a0)	; enable disk DMA
	ENDC

	bsr	initialise
; set level 3 interrupt, which will start sprite scaling process
	clr.w	zoom_status
	move.l	$6c.w,saved_level3
	IFND	DEBUG
	move.l	#level3,$6c
	move.w	#$c020,$dff000+intena
	ENDC
;	bra	finish

; wait for left mouse button to be pressed (sprite shrunk by level 3 interrupt)
.wait	btst	#6,$bfe001
	bne.s	.wait
	move.w	#$ffff,zoom_status	; start sprite grow

; wait for sprite to be grown to maximum size
.wait2	tst.w	zoom_status
	bmi.s	.wait2

; exit routine
finish
	IFND	DEBUG
	lea	$dff000,a6
.wait	btst	#6,dmaconr(a6)		; wait for blitter to finish
	bne.s	.wait

	move.l	saved_level3(pc),$6c.w

	move.w	saved_dmacon(pc),d0
	or.w	#$8200,d0		; set SET and DMAEN bits
	move.w	d0,dmacon(a6)		; restore system DMA status

	move.w	saved_intena(pc),d0
	or.w	#$c000,d0		; set SET and INTEN bits
	move.w	d0,intena(a6)		; restore system interrupt status

	move.l	saved_copper(pc),cop1lch(a6)

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		; DisownBlitter
	ENDC

	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)		; CloseLibrary

finish_now
	move.l	4.w,a6
	IFND	DEBUG
	jsr	-138(a6)		; turn multitasking on
	ENDC

	moveq	#0,d0
	rts


level3	movem.l	d0-d7/a0-a6,-(sp)
	btst	#2,$dff000+potgor	; right mouse button
	beq.s	end_level3

	pea.l	end_level3
	tst.w	zoom_status
	beq	shrink_sprite
	bmi	grow_sprite
	rts
end_level3
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$20,$dff000+intreq
	rte


initialise
	bsr	convert_graphic_data
	bsr	create_division_lookup
	bsr	make_copper_list
	bsr	set_copper_and_dma
	move.w	#$000,$dff000+color0
	move.w	#$fff,$dff000+color1
	move.w	#$00c,$dff000+color2
	move.w	#$c00,$dff000+color3
	bsr	clear_buffers
	move.w	#197,zoom_value
	move.l	#$fffffffe,copper2A_mem
	move.l	#$fffffffe,copper2B_mem
	rts


clear_buffers
	lea	screen1_mem,a0		; destination address
	clr.w	d0			; destination modulo
	move.w	#83*64+22,d1		; blit size
	bsr	clear

	lea	screen2_mem,a0
	bsr	clear
clear_fill_source			; clear fill source planes 1 and 2
	lea	plane1_fill_source,a0
	clr.w	d0
	move.w	#2*83*64+22,d1
	bsr	clear
	rts


grow_sprite
	bsr	render_sprite
	addq.w	#2,zoom_value
	cmp.w	#197,zoom_value
	blt.s	.end
	move.w	#0,$dff000+color1
	subq.w	#2,zoom_value
	move.w	#1,zoom_status
.end	rts


shrink_sprite
	bsr	render_sprite
	subq.w	#1,zoom_value
	tst.w	zoom_value
	bpl.s	.end
	move.w	#0,zoom_value
	move.w	#1,zoom_status
.end	rts



render_sprite
	bsr	update_copper_list1	; update copper to show current image
	bsr	set_display_ptrs	; update pointers for use when drawing next image
	bsr	clear_fill_source	; clear the areas used as sources of the blitter fill operations

	bsr	scale_vertically	; create copper list to set bitplane ptrs on required raster lines
	bsr	blit_wait

	lea	plane1_data,a1
	lea	plane1_fill_source,a2
	bsr	plot_fill_dots
	bsr	fill_plane1

	lea	plane2_data,a1
	lea	plane2_fill_source,a2
	bsr	plot_fill_dots
	bsr	blit_wait
	bra	fill_plane2


set_display_ptrs
	not.w	screen_number
	beq.s	.other
	move.l	#screen1_mem,screen2
	move.l	#screen2_mem,screen1
	move.l	#copper2A_mem,copper_list2B
	move.l	#copper2B_mem,copper_list2A
	rts

.other	move.l	#screen2_mem,screen2
	move.l	#screen1_mem,screen1
	move.l	#copper2B_mem,copper_list2B
	move.l	#copper2A_mem,copper_list2A
	rts


; create division lookup table
;
; pseudo code:-
;short division_lookup[201];
;
;	i = 0;
;	for (d0 = 0; d0 >= -200; d0--)
;		{
;		d1 = -200 - d0;
;		val = 0;
;		if (d1 != 0)
;			{
;			val = (d0 * 128) / d1;
;			}
;		division_lookup[i++] = val;
;		}
;
;gives table contents:
;0:	   (0 * 128) / -200 = 0
;1:	  (-1 * 128) / -199 = 0
;2:	  (-2 * 128) / -198 = 1
;...
;198:	(-198 * 128) / -2   = 12672
;199:	(-199 * 128) / -1   = 25472
;200:	(-200 * 128) / 0    = 0 (division by zero prevented)
;
create_division_lookup
	lea	division_lookup,a0
	move.w	#0,d0

.next	move.w	#-200,d1
	clr.w	d2
	sub.w	d0,d1
	beq.s	.store
	move.w	d0,d2
	muls	#128,d2
	divs	d1,d2

.store	move.w	d2,(a0)+
	sub.w	#1,d0
	cmp.w	#-200,d0
	bge.s	.next
	rts


; convert graphic definition for both bitplanes into more efficient runtime format
;
; this basically sorts the data by x position ascending (i.e. left to right)
; so that each x only has to be calculated once by the scaling routine
;
; for each x position the routine stores the bitplane offset of each row requiring a set pixel at that x position
; e.g.
; -50,0,44,88,$ffff	x pos -50, bitplane offset 0,44 and 88 (i.e. lines 0,1 and 2)
; -49,44,88,132,$ffff	x pos -49, bitplane offset 44,88 and 132 (i.e. lines 1,2 and 3)
; $4000			end marker
convert_graphic_data
	lea	plane1_data,a2
	lea	plane1_definition,a1
	bsr	.convert_plane_data

	lea	plane2_data,a2
	lea	plane2_definition,a1

.convert_plane_data
	move.w	#-50,d0		; start at minimum allowable x position

.next_x	move.l	a1,-(sp)	; save definition start address
	move.w	d0,(a2)+	; store x position
	move.w	#$ffff,(a2)
	move.w	(a1)+,d1	; number of rows
	subq.w	#1,d1
	moveq	#0,d3		; start bitplane offset

.next_row
	move.w	(a1)+,d2	; number of x values for this row
	subq.w	#1,d2

.compare
	cmp.w	(a1)+,d0
	beq.s	.store_row	; store row if x value matches
.next_val
	dbra	d2,.compare

	add.w	#44,d3		; next row offset
	dbra	d1,.next_row

	tst.w	(a2)
	beq.s	.mark_end
	subq.w	#2,a2		; no need to store any data for unused x position
	bra.s	.marked

.mark_end
	move.w	#$ffff,(a2)+	; end marker for this x position

.marked	addq.w	#1,d0		; next x position
	cmp.w	#50,d0		; maximum x position
	move.l	(sp)+,a1	; restore definition start address
	blt.s	.next_x
	move.w	#$4000,(a2)+	; data end marker
	rts

.store_row
	move.w	d3,(a2)+
	clr.w	(a2)
	bra.s	.next_val


; plot dots that will be used as input to blitter fill operation
; a1 = data to plot
; a2 = destination bitplane start address
plot_fill_dots
	lea	division_lookup,a0
	lea	pixel_plot_lookup,a4
	move.l	#352/2,d2		; sprite x centre
	move.w	zoom_value,d0
	IFD	TEST_VERT_SCALE
	moveq	#0,d0
	ENDC
	add.w	d0,d0
	move.w	(a0,d0.w),d4

.next_x	move.w	(a1)+,d1		; get next x position
	cmp.w	#$4000,d1		; check for end marker
	beq	.done
; calculate screen x
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	.plus			; limit to screen edges
	clr.w	d3
.plus	cmp.w	#352,d3
	blt.s	.on_screen
	move.w	#351,d3
.on_screen
	move.l	a2,a3			; bitplane start address
	move.b	(a4,d3.w),d6		; get pixel mask
	asr.w	#3,d3
	add.w	d3,a3			; address of column requiring pixel (first line of bitplane)

.next_offset
	move.w	(a1)+,d3		; get next bitplane offset (i.e. offset to required line)
	bmi.s	.next_x
	eor.b	d6,(a3,d3.w)		; plot pixel
	bra.s	.next_offset
.done	rts


fill_plane1
	lea	plane1_fill_source+(83*44)-2,a0
	move.l	screen1,a1
	add.l	#(83*44)-2,a1		; point to last word of bitplane 1
	bra.s	fill_plane

fill_plane2
	lea	plane2_fill_source+(83*44)-2,a0
	move.l	screen1,a1
	add.l	#(2*83*44)-2,a1		; point to last word of bitplane 2

fill_plane
	clr.w	d0
	move.w	#83*64+22,d2
	bsr	blit_wait
	move.l	#$ffffffff,$dff000+bltafwm
	move.w	d0,$dff000+bltamod
	move.w	d0,$dff000+bltdmod
	move.l	a0,$dff000+bltapth
	move.l	a1,$dff000+bltdpth
	move.w	#$9f0,$dff000+bltcon0
	move.w	#$12,$dff000+bltcon1
	move.w	d2,$dff000+bltsize
	rts


scale_vertically
	move.l	copper_list2A,a2
	lea	division_lookup,a0
	move.l	#169,d2			; sprite y centre
	move.w	#83-1,d6		; row count

	move.w	#-42,d1			; -sprite_height/2
	move.w	zoom_value,d0
	IFD	TEST_HORIZ_SCALE1
	moveq	#0,d0
	ENDC
	add.w	d0,d0
	move.w	(a0,d0.w),d4

; calculate sprite start y
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	subq.w	#1,d3
	cmp.w	#26,d3			; display minimum y
	bge.s	.set_diwstrt
	move.w	#26,d3

.set_diwstrt
	lsl.w	#8,d3
	or.w	#$71,d3
	move.w	#diwstrt,(a2)+
	move.w	d3,(a2)+

; calculate sprite end y
	move.w	d4,d3
	muls	#42,d3			; sprite_height/2
	asr.l	#7,d3
	add.w	d2,d3
	add.w	#42,d3			; sprite_height/2
	cmp.w	#312,d3			; display maximum y
	ble.s	.set_diwstop
	move.w	#312,d3

.set_diwstop
	lsl.w	#8,d3
	or.w	#$d1,d3
	move.w	#diwstop,(a2)+
	move.w	d3,(a2)+

	move.l	screen1,d5		; start of plane 1
	move.l	d5,d7
	add.l	#83*44,d7		; start of plane 2
	clr.w	pal_flag

; for each sprite row, work out display y value,
; then create a copper wait for this line followed by a set of the bitplane pointers
.next_row
	move.w	d4,d3
	muls	d1,d3
	asr.l	#7,d3
	add.w	d2,d3
	add.w	d1,d3
	bpl.s	.plus
	clr.w	d3

.plus	cmp.w	#312,d3
	blt.s	.in_range
	bra.s	.end_copper

.in_range
	lsl.w	#8,d3
	bcc.s	.pal_split_ok
	tst.w	pal_flag
	bne.s	.pal_split_ok
	not.w	pal_flag
	move.l	#$ffe1fffe,(a2)+	; PAL enable

.pal_split_ok
	or.w	#1,d3
	move.w	d3,(a2)+
	move.w	#$fffe,(a2)+		; store copper wait

; original version only set bitplane pointer low words
	move.w	#bpl1pth,(a2)+
	swap	d5
	move.w	d5,(a2)+
	move.w	#bpl1ptl,(a2)+
	swap	d5
	move.w	d5,(a2)+

	move.w	#bpl2pth,(a2)+
	swap	d7
	move.w	d7,(a2)+
	move.w	#bpl2ptl,(a2)+
	swap	d7
	move.w	d7,(a2)+

	add.l	#44,d5			; to next row of bitplane data
	add.l	#44,d7
	addq.w	#1,d1
	dbra	d6,.next_row

.end_copper
	move.l	#$fffffffe,(a2)+
	rts

pal_flag
	dc.w	0


make_copper_list
	lea	copper_list1,a2
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
; set bitplane modulos so that lines are repeated
; (copper list then updates bitplane pointers as necessary)
	move.w	#bpl1mod,(a2)+
	move.w	#-44,(a2)+
	move.w	#bpl2mod,(a2)+
	move.w	#-44,(a2)+
	move.w	#bplcon1,(a2)+
	clr.w	(a2)+
	move.l	a2,copper_list1_dynamic
	pea.l	end_initial_copper

update_copper_list1
	move.l	copper_list1_dynamic,a2

	move.w	#bpl1pth,d0
	move.l	screen2,d1
	bsr	write_copper

	move.w	#bpl2pth,d0
	move.l	screen2,d1
	add.l	#83*44,d1		; start of plane 2
	bsr	write_copper

	move.w	#cop2lch,d0
	move.l	copper_list2B,d1
	bsr	write_copper
	rts


end_initial_copper
	move.w	#spr0pth,d0
	clr.l	zero_sprite_pointers
	move.l	#zero_sprite_pointers,d1
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper
	bsr	write_copper

	IFND	TEST_HORIZ_SCALE2
	move.w	#copjmp2,(a2)+
	move.w	#0,(a2)+
	move.l	#$fffffffe,(a2)+
	ENDC

	IFD	TEST_HORIZ_SCALE2
	move.w	#$1e01,d0
	moveq	#83-1,d1
.next_row
	move.w	d0,(a2)+
	move.w	#$fffe,(a2)+
	move.w	#bpl1mod,(a2)+
	move.w	#-44,(a2)+
	move.w	#bpl2mod,(a2)+
	move.w	#-44,(a2)+
	add.w	#$300,d0
	bcc.s	.pal_split_ok
	move.w	#$ffe1,(a2)+
	move.w	#$fffe,(a2)+
.pal_split_ok
	move.w	d0,(a2)+
	move.w	#$fffe,(a2)+
	move.w	#bpl1mod,(a2)+
	move.w	#0,(a2)+
	move.w	#bpl2mod,(a2)+
	move.w	#0,(a2)+
	add.w	#$100,d0
	bcc.s	.pal_split_ok2
	move.w	#$ffe1,(a2)+
	move.w	#$fffe,(a2)+
.pal_split_ok2
	dbra	d1,.next_row
	move.l	#$fffffffe,(a2)+
	ENDC
	rts


write_copper
	move.w	d0,(a2)+
	swap	d1
	move.w	d1,(a2)+
	addq.w	#2,d0
	move.w	d0,(a2)+
	swap	d1
	move.w	d1,(a2)+
	addq.w	#2,d0
	rts


set_copper_and_dma
	lea	$dff000,a0
	move.l	#copper_list1,cop1lch(a0)
	move.w	copjmp1(a0),d0
	move.w	#$87e0,dmacon(a0)
	rts


blit_wait
	btst	#6,$dff000+dmaconr
	bne.s	blit_wait
	rts


clear	btst	#6,$dff000+dmaconr
	bne.s	clear

	move.w	d0,$dff000+bltdmod
	move.l	a0,$dff000+bltdpth
	move.w	#$100,$dff000+bltcon0
	move.w	#0,$dff000+bltcon1
	move.w	d1,$dff000+bltsize
	rts


graphics.library
	dc.b	'graphics.library',0
	even
saved_dmacon	dc.w	0
saved_intena	dc.w	0
saved_copper	dc.l	0
saved_level3	dc.l	0
gfxbase	dc.l	0

screen1	dc.l	screen1_mem
screen2	dc.l	screen2_mem

copper_list2A
	dc.l	copper2A_mem
copper_list2B
	dc.l	copper2B_mem

copper_list1_dynamic
	dc.l	0	; ptr to the part of the copper list that changes (cop2lc is the required bit)

screen_number
	dc.w	0	; 0 or -1, for double buffering

zoom_status
	dc.w	0
zoom_value
	dc.w	0


; graphic definition (both bitplanes)
; this is lists of x start/end pairs which represent horizontal spans to be filled
; plane 1
plane1_definition	dc.w	$0053	; number of rows
	dc.w	$0002,$ffe0,$001f	; row 1, count 2 - x start $ffe0, x end $001f
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f	; row 2, count 4 - etc.
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f,$000c,$ffe0
	dc.w	$ffe1,$ffe6,$ffeb,$ffed,$fff5,$fff9,$fffe,$0004,$000a,$001e,$001f,$0016,$ffe0,$ffe1,$ffe5,$ffe7
	dc.w	$ffea,$ffec,$fff0,$fff2,$fff7,$fff9,$fffe,$0000,$0004,$0006,$0009,$000c,$000f,$0011,$0018,$001b
	dc.w	$001e,$001f,$0016,$ffe0,$ffe1,$ffe4,$ffe6,$ffeb,$ffec,$fff0,$fff2,$fff6,$fff8,$ffff,$0001,$0004
	dc.w	$0006,$000a,$000c,$000f,$0011,$0018,$001b,$001e,$001f,$0014,$ffe0,$ffe1,$ffe4,$ffe6,$fff0,$fff2
	dc.w	$fff6,$fff8,$ffff,$0001,$0004,$0006,$000a,$000d,$000f,$0013,$0016,$001b,$001e,$001f,$0014,$ffe0
	dc.w	$ffe1,$ffe4,$ffe7,$fff0,$fff2,$fff5,$fff8,$ffff,$0002,$0004,$0006,$000a,$000d,$000f,$0013,$0016
	dc.w	$001b,$001e,$001f,$0016,$ffe0,$ffe1,$ffe4,$ffe9,$fff0,$fff2,$fff5,$fff8,$ffff,$0002,$0004,$0006
	dc.w	$000a,$000c,$000f,$0010,$0012,$0017,$0019,$001b,$001e,$001f,$0016,$ffe0,$ffe1,$ffe5,$ffeb,$fff0
	dc.w	$fff2,$fff5,$fff8,$ffff,$0002,$0004,$0006,$0009,$000c,$000f,$0010,$0012,$0017,$0019,$001b,$001e
	dc.w	$001f,$0014,$ffe0,$ffe1,$ffe7,$ffec,$fff0,$fff2,$fff5,$fff8,$ffff,$0002,$0004,$000a,$000f,$0010
	dc.w	$0013,$0016,$0019,$001b,$001e,$001f,$0016,$ffe0,$ffe1,$ffe9,$ffed,$fff0,$fff2,$fff5,$fff8,$ffff
	dc.w	$0002,$0004,$0006,$0008,$000a,$000f,$0010,$0013,$0016,$0019,$001b,$001e,$001f,$0016,$ffe0,$ffe1
	dc.w	$ffea,$ffed,$fff0,$fff2,$fff6,$fff8,$ffff,$0001,$0004,$0006,$0008,$000b,$000f,$0010,$0013,$0016
	dc.w	$0019,$001b,$001e,$001f,$0018,$ffe0,$ffe1,$ffe4,$ffe5,$ffea,$ffed,$fff0,$fff2,$fff6,$fff8,$ffff
	dc.w	$0001,$0004,$0006,$0009,$000b,$000f,$0010,$0014,$0015,$0019,$001b,$001e,$001f,$0018,$ffe0,$ffe1
	dc.w	$ffe4,$ffe7,$ffe9,$ffec,$fff0,$fff2,$fff7,$fff9,$fffe,$0000,$0004,$0006,$0009,$000c,$000f,$0010
	dc.w	$0014,$0015,$0019,$001b,$001e,$001f,$0012,$ffe0,$ffe1,$ffe6,$ffea,$fff0,$fff2,$fff9,$fffe,$0004
	dc.w	$0006,$000a,$000c,$000f,$0010,$0019,$001b,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0
	dc.w	$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0006,$ffe0,$ffe1,$fffa,$0005,$001e,$001f,$0006
	dc.w	$ffe0,$ffe1,$fff7,$0008,$001e,$001f,$0006,$ffe0,$ffe1,$fff4,$000b,$001e,$001f,$0006,$ffe0,$ffe1
	dc.w	$fff2,$000d,$001e,$001f,$0006,$ffe0,$ffe1,$fff1,$000e,$001e,$001f,$0006,$ffe0,$ffe1,$ffef,$0010
	dc.w	$001e,$001f,$0008,$ffe0,$ffe1,$ffee,$fff0,$0005,$0011,$001e,$001f,$0008,$ffe0,$ffe1,$ffed,$fff8
	dc.w	$0007,$0012,$001e,$001f,$0006,$ffe0,$ffe1,$ffec,$0013,$001e,$001f,$0008,$ffe0,$ffe1,$ffeb,$ffed
	dc.w	$000a,$0014,$001e,$001f,$0008,$ffe0,$ffe1,$ffea,$fff5,$000b,$0015,$001e,$001f,$0006,$ffe0,$ffe1
	dc.w	$ffea,$0015,$001e,$001f,$0008,$ffe0,$ffe1,$ffe9,$ffeb,$000c,$0016,$001e,$001f,$0008,$ffe0,$ffe1
	dc.w	$ffe8,$fff2,$000d,$0017,$001e,$001f,$0006,$ffe0,$ffe1,$ffe8,$0017,$001e,$001f,$0006,$ffe0,$ffe1
	dc.w	$ffe7,$0018,$001e,$001f,$0006,$ffe0,$ffe1,$ffe7,$0018,$001e,$001f,$0006,$ffe0,$ffe1,$ffe7,$0018
	dc.w	$001e,$001f,$0008,$ffe0,$ffe1,$ffe6,$ffe8,$000f,$0019,$001e,$001f,$0008,$ffe0,$ffe1,$ffe6,$fff0
	dc.w	$0010,$0019,$001e,$001f,$0006,$ffe0,$ffe1,$ffe6,$0019,$001e,$001f,$0008,$ffe0,$ffe1,$ffe5,$ffe7
	dc.w	$0012,$001a,$001e,$001f,$0008,$ffe0,$ffe1,$ffe5,$ffef,$0013,$001a,$001e,$001f,$0006,$ffe0,$ffe1
	dc.w	$ffe5,$001a,$001e,$001f,$0008,$ffe0,$ffe1,$ffe5,$ffe7,$0013,$001a,$001e,$001f,$0008,$ffe0,$ffe1
	dc.w	$ffe5,$ffef,$0012,$001a,$001e,$001f,$0006,$ffe0,$ffe1,$ffe5,$001a,$001e,$001f,$0008,$ffe0,$ffe1
	dc.w	$ffe5,$ffe7,$0011,$001a,$001e,$001f,$0008,$ffe0,$ffe1,$ffe5,$ffef,$0012,$001a,$001e,$001f,$0006
	dc.w	$ffe0,$ffe1,$ffe5,$001a,$001e,$001f,$0008,$ffe0,$ffe1,$ffe5,$ffe7,$0012,$001a,$001e,$001f,$0008
	dc.w	$ffe0,$ffe1,$ffe5,$fff0,$0012,$001a,$001e,$001f,$0006,$ffe0,$ffe1,$ffe6,$0019,$001e,$001f,$0008
	dc.w	$ffe0,$ffe1,$ffe6,$ffe8,$0012,$0019,$001e,$001f,$0008,$ffe0,$ffe1,$ffe7,$fff1,$0013,$0019,$001e
	dc.w	$001f,$0006,$ffe0,$ffe1,$ffe7,$0018,$001e,$001f,$0008,$ffe0,$ffe1,$ffe7,$ffe9,$0010,$0018,$001e
	dc.w	$001f,$0008,$ffe0,$ffe1,$ffe8,$fff2,$000e,$0018,$001e,$001f,$0006,$ffe0,$ffe1,$ffe8,$0017,$001e
	dc.w	$001f,$0008,$ffe0,$ffe1,$ffe9,$ffeb,$000c,$0017,$001e,$001f,$0008,$ffe0,$ffe1,$ffea,$fff4,$000c
	dc.w	$0016,$001e,$001f,$0006,$ffe0,$ffe1,$ffea,$0015,$001e,$001f,$0008,$ffe0,$ffe1,$ffeb,$ffed,$000c
	dc.w	$0015,$001e,$001f,$0008,$ffe0,$ffe1,$ffec,$fff7,$000c,$0014,$001e,$001f,$0006,$ffe0,$ffe1,$ffec
	dc.w	$0013,$001e,$001f,$0006,$ffe0,$ffe1,$ffed,$0012,$001e,$001f,$0006,$ffe0,$ffe1,$ffee,$0011,$001e
	dc.w	$001f,$0006,$ffe0,$ffe1,$ffef,$0010,$001e,$001f,$0006,$ffe0,$ffe1,$fff1,$000e,$001e,$001f,$0006
	dc.w	$ffe0,$ffe1,$fff2,$000d,$001e,$001f,$0006,$ffe0,$ffe1,$fff4,$000b,$001e,$001f,$0006,$ffe0,$ffe1
	dc.w	$fff6,$0008,$001e,$001f,$0006,$ffe0,$ffe1,$fff9,$0005,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$001c,$ffe0,$ffe1,$ffe5,$ffe7,$ffea
	dc.w	$ffec,$ffef,$fff0,$fff4,$fff7,$fffa,$fffc,$0001,$0003,$0005,$0006,$0008,$0009,$000b,$000e,$0011
	dc.w	$0012,$0015,$0016,$0018,$001b,$001e,$001f,$0020,$ffe0,$ffe1,$ffe4,$ffe5,$ffe9,$ffea,$ffec,$ffed
	dc.w	$ffef,$fff0,$fff4,$fff5,$fff9,$fffa,$0000,$0001,$0005,$0006,$0008,$0009,$000b,$000c,$000e,$000f
	dc.w	$0011,$0012,$0015,$0016,$0018,$0019,$001e,$001f,$001c,$ffe0,$ffe1,$ffe5,$ffe6,$ffe9,$ffed,$ffef
	dc.w	$fff0,$fff4,$fff6,$fffa,$fffb,$0000,$0001,$0005,$0006,$0008,$0009,$000b,$000e,$0011,$0012,$0014
	dc.w	$0015,$0018,$001a,$001e,$001f,$0020,$ffe0,$ffe1,$ffe6,$ffe7,$ffe9,$ffea,$ffec,$ffed,$ffef,$fff0
	dc.w	$fff4,$fff5,$fffb,$fffc,$0000,$0001,$0005,$0006,$0008,$0009,$000b,$000c,$000e,$000f,$0011,$0012
	dc.w	$0014,$0015,$0018,$0019,$001e,$001f,$001c,$ffe0,$ffe1,$ffe4,$ffe6,$ffe9,$ffea,$ffec,$ffed,$ffef
	dc.w	$fff2,$fff4,$fff7,$fff9,$fffb,$0001,$0003,$0006,$0008,$000b,$000c,$000e,$000f,$0012,$0014,$0018
	dc.w	$001b,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0002,$ffe0,$001f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

; plane 2
plane2_definition
	dc.w	$0053
	dc.w	$0002,$ffe0,$001f
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0
	dc.w	$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1
	dc.w	$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e
	dc.w	$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f
	dc.w	$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004
	dc.w	$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0
	dc.w	$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$fff4,$000b,$001c,$001e
	dc.w	$001f,$0008,$ffe0,$ffe1,$ffe3,$fff2,$000d,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$fff1,$000e
	dc.w	$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffef,$0010,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3
	dc.w	$ffee,$0011,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffed,$0012,$001c,$001e,$001f,$0008,$ffe0
	dc.w	$ffe1,$ffe3,$ffec,$0013,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffeb,$0014,$001c,$001e,$001f
	dc.w	$0008,$ffe0,$ffe1,$ffe3,$ffea,$0015,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffea,$0015,$001c
	dc.w	$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe9,$0016,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe8
	dc.w	$0017,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe8,$0017,$001c,$001e,$001f,$000a,$ffe0,$ffe1
	dc.w	$ffe3,$ffe7,$ffe9,$000d,$0018,$001c,$001e,$001f,$000a,$ffe0,$ffe1,$ffe3,$ffe7,$fff1,$000e,$0018
	dc.w	$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe7,$0018,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3
	dc.w	$ffe6,$0019,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe6,$0019,$001c,$001e,$001f,$0008,$ffe0
	dc.w	$ffe1,$ffe3,$ffe6,$0019,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f
	dc.w	$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c
	dc.w	$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5
	dc.w	$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1
	dc.w	$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008
	dc.w	$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e
	dc.w	$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe5,$001a,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe6,$0019
	dc.w	$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe6,$0019,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3
	dc.w	$ffe7,$0019,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe7,$0018,$001c,$001e,$001f,$0008,$ffe0
	dc.w	$ffe1,$ffe3,$ffe7,$0018,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe8,$0018,$001c,$001e,$001f
	dc.w	$0008,$ffe0,$ffe1,$ffe3,$ffe8,$0017,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffe9,$0017,$001c
	dc.w	$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffea,$0016,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffea
	dc.w	$0015,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffeb,$0015,$001c,$001e,$001f,$0008,$ffe0,$ffe1
	dc.w	$ffe3,$ffec,$0014,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffec,$0013,$001c,$001e,$001f,$0008
	dc.w	$ffe0,$ffe1,$ffe3,$ffed,$0012,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$ffee,$0011,$001c,$001e
	dc.w	$001f,$0008,$ffe0,$ffe1,$ffe3,$ffef,$0010,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$fff1,$000e
	dc.w	$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3,$fff2,$000d,$001c,$001e,$001f,$0008,$ffe0,$ffe1,$ffe3
	dc.w	$fff4,$000b,$001c,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004
	dc.w	$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0
	dc.w	$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1
	dc.w	$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e,$001f,$0004,$ffe0,$ffe1,$001e
	dc.w	$001f,$0002,$ffe0,$001f,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000


pixel_plot_lookup	; 352 values
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


	section	data,bss_c

;was $400
screen1_mem
	ds.w	83*22	;plane 1
	ds.w	83*22	;plane 2
;was $2088
screen2_mem
	ds.w	83*22	;plane 1
	ds.w	83*22	;plane 2
;was $3d10
plane1_fill_source
	ds.w	83*22
plane2_fill_source
	ds.w	83*22

;graphic definition in runtime format
;was $5998
plane1_data
	ds.w	1500
;was $6550
plane2_data
	ds.w	1500

;was $7108
division_lookup
	ds.w	201
;	ds.w	3000-201

;was $8878
copper2A_mem
	ds.w	2000
;was $9818
copper2B_mem
	ds.w	2000

zero_sprite_pointers
	ds.w	2

copper_list1
	ds.w	100


;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""
;http://www.winnicki.net/amiga/memmap/DMACON.html
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
