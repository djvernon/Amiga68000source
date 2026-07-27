*"""""""""""""""""""""""""""""""""""""
*" CHUNKY TO PLANAR CONVERTER	     "
*" (4 bitplane double-pixel version) "
*" ATARI ST VERSION		     "
*"				     "
*"""""""""""""""""""""""""""""""""""""

*	68000 CPU cycles required: 76 + 472 per loop (outputting 32 pixels) + 16
*	= (76 + ((320*200)/32 * 472) + 16) = 944092 cycles for 320*200 display
*
*	= approx. 15 CPU cycles per output pixel (944092/(320*200))
*
*	Time taken for 500 calls to this routine: 68 seconds

c2p_double
	move.l	chunky_memory(pc),a0			16
	move.l	screen_memory(pc),a1			16
	move.w	#(SCREEN_WIDTH*SCREEN_HEIGHT)/32-1,d7	8

	move.l	#$00ff00ff,d4				12
	move.l	#$33333333,d5				12
	move.l	#$55555555,d6				12

;	nop		longword align to improve performance on 68020+

* read 16 chunky pixels per loop to give 32 output pixels
.next.32.pixels
	move.w	(a0)+,d0	.A.B		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	ACBD		8
	swap	d0				4

	move.w	(a0)+,d2	.E.F		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	EGFH		8
	swap	d2				4

	move.w	(a0)+,d0	.I.J		8
	lsl.w	#4,d0				14
	or.w	(a0)+,d0	IKJL		8

	move.w	(a0)+,d2	.M.N		8
	lsl.w	#4,d2				14
	or.w	(a0)+,d2	MONP		8 = total 128 cycles

* d0 = ACBDIKJL
* d2 = EGFHMONP

* 8-bit transpose ACBDIKJL and EGFHMONP
	move.l	d0,d1					4
	ror.l	#8,d2	NPEGFHMO			24
	eor.l	d2,d1					8
	and.l	d4,d1	(d1 ^ d2) & $00ff00ff = mask	8
	eor.l	d1,d0	ACEGIKMO			8
	eor.l	d1,d2	NPBDFHJL			8 = total 60 cycles

* 2-bit transpose ACEGIKMO and NPBDFHJL
*			d0 = A3A2A1A0C3C2C1C0E3E2E1E0G3G2G1G0I3I2I1I0K3K2K1K0M3M2M1M0O3O2O1O0
*			d2 = N3N2N1N0P3P2P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0
	move.l	d0,d1										4
	rol.l	#6,d2	P1P0B3B2B1B0D3D2D1D0F3F2F1F0H3H2H1H0J3J2J1J0L3L2L1L0N3N2N1N0P3P2	20
	eor.l	d2,d1										8
	and.l	d5,d1	(d1 ^ d2) & $33333333 = mask						8
	eor.l	d1,d0	A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2	8
	eor.l	d1,d2	P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0	8 = total 56 cycles

* 1-bit transpose bits 0 and 1
*			d2 = P1P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0
	rol.l	#1,d2										10
	move.l	d2,d1	P0A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1	4
	rol.l	#1,d2	A1A0B1B0C1C0D1D0E1E0F1F0G1G0H1H0I1I0J1J0K1K0L1L0M1M0N1N0O1O0P1P0	10
	move.l	d2,d3										4
	eor.l	d2,d1										8
	and.l	d6,d1	(d1 ^ d2) & $55555555 = mask						8
	eor.l	d1,d2	A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1	8
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0	8 = total 68 cycles

* 16-bit transpose bits 0 and 1
	swap	d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1
	move.w	d3,d1					I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0
	move.w	d2,d3	A0A0B0B0C0C0D0D0E0E0F0F0G0G0H0H0A1A1B1B1C1C1D1D1E1E1F1F1G1G1H1H1
	move.w	d1,d2	I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0
	swap	d2	I0I0J0J0K0K0L0L0M0M0N0N0O0O0P0P0I1I1J1J1K1K1L1L1M1M1N1N1O1O1P1P1
	move.l	d3,(a1)+		output plane 0 and 1 first word				total 32 cycles

* 1-bit transpose bits 2 and 3
*			d0 = A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3P2
	move.l	d0,d3										4
	move.l	d0,d1										4
	ror.l	#1,d1	P2A3A2B3B2C3C2D3D2E3E2F3F2G3G2H3H2I3I2J3J2K3K2L3L2M3M2N3N2O3O2P3	10
	eor.l	d0,d1										8
	and.l	d6,d1	(d1 ^ d0) & $55555555 = mask						8
	eor.l	d1,d0	A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3	8
	add.l	d1,d1	mask << 1								8
	eor.l	d1,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2	8 = total 58 cycles

* 16-bit transpose bits 2 and 3
	swap	d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d3,d1					I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	move.w	d0,d3	A2A2B2B2C2C2D2D2E2E2F2F2G2G2H2H2A3A3B3B3C3C3D3D3E3E3F3F3G3G3H3H3
	move.w	d1,d0	I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2
	swap	d0	I2I2J2J2K2K2L2L2M2M2N2N2O2O2P2P2I3I3J3J3K3K3L3L3M3M3N3N3O3O3P3P3
	move.l	d3,(a1)+		output plane 2 and 3 first word				total 32 cycles

	move.l	d2,(a1)+		output plane 0 and 1 second word
	move.l	d0,(a1)+		output plane 2 and 3 second word			total 24 cycles

	dbra	d7,.next.32.pixels	14 (when branch taken)
	rts				16


*""""""""""""""""""""""""""""""""""""""""""""""""
*" Comparison routine from Tutorial:		"
*"  "Chunky-to-Planar for Dummies"		"
*"  (http://alive.atari.org/alive8/c2p.php)	"
*"						"
*""""""""""""""""""""""""""""""""""""""""""""""""

*	68000 CPU cycles required: 76 + (8 + (290 per inner loop) + 14 per outer loop) + 16
*	= (76 + (200 * (8 + (160/8 * 290) + 14)) + 16) = 1164492 cycles for 320*200 display
*
*	= approx. 18 CPU cycles per output pixel (1164492/(320*200))
*
*	Time taken for 500 calls to this routine: 86 seconds

* Note that the chunky pixels in the source picture MUST be multiplied by 4,
* because they are used to index into the longword c2p_pixeln tables below
* (and also to prevent address errors on 68000 systems)

c2p_alive
	lea	c2p_pixel0(pc),a0		;c2p table for pixel 0 to a0		8
	lea	c2p_pixel1(pc),a1		;c2p table for pixel 1 to a1		8
	lea	c2p_pixel2(pc),a2		;c2p table for pixel 2 to a2		8
	lea	c2p_pixel3(pc),a3		;c2p table for pixel 3 to a3		8
	move.l	chunky_memory(pc),a4		;the source picture			16
	move.l	screen_memory(pc),a5		;the target				16

	moveq	#0,d0				;clear work register			4

	move.w	#SCREEN_HEIGHT-1,d6		;number of lines			8
.outloop
;.next.line
	move.w	#CHUNKY_SCREEN_WIDTH/8-1,d7	;number of 8 pixel blocks per line	8
.inloop
* read 8 chunky pixels per loop to give 16 output pixels
;.next.8.pixels
	move.b	(a4)+,d0			;fetch chunky pixel 0			8
	move.l	0(a0,d0.w),d5			;convert to planar			18
	move.b	(a4)+,d0			;fetch chunky pixel 1			8
	or.l	0(a1,d0.w),d5			;convert to planar, combine with above	20
	move.b	(a4)+,d0			;fetch chunky pixel 2			8
	or.l	0(a2,d0.w),d5			;convert and combine			20
	move.b	(a4)+,d0			;fetch chunky pixel 3			8
	or.l	0(a3,d0.w),d5			;convert and combine			20
	movep.l	d5,0(a5)			;put to screen				24

	move.b	(a4)+,d0			;fetch chunky pixel 4			8
	move.l	0(a0,d0.w),d5			;convert to planar			18
	move.b	(a4)+,d0			;fetch chunky pixel 5			8
	or.l	0(a1,d0.w),d5			;convert to planar, combine with above	20
	move.b	(a4)+,d0			;fetch chunky pixel 6			8
	or.l	0(a2,d0.w),d5			;convert and combine			20
	move.b	(a4)+,d0			;fetch chunky pixel 7			8
	or.l	0(a3,d0.w),d5			;convert and combine			20
	movep.l	d5,1(a5)			;put to screen				24

	addq.l	#8,a5				;increase target pointer		8
	dbra	d7,.inloop			;loop through line			14 (when branch taken)

;	...					;add offsets to source and target
	dbra	d6,.outloop			;loop over lines			14 (when branch taken)
	rts										16


c2p_pixel0
	dc.b %00000000,%00000000,%00000000,%00000000 ;Colour 0
	dc.b %11000000,%00000000,%00000000,%00000000 ;Colour 1
	dc.b %00000000,%11000000,%00000000,%00000000 ;Colour 2
	dc.b %11000000,%11000000,%00000000,%00000000 ;Colour 3
	dc.b %00000000,%00000000,%11000000,%00000000 ;Colour 4
	dc.b %11000000,%00000000,%11000000,%00000000 ;Colour 5
	dc.b %00000000,%11000000,%11000000,%00000000 ;Colour 6
	dc.b %11000000,%11000000,%11000000,%00000000 ;Colour 7
	dc.b %00000000,%00000000,%00000000,%11000000 ;Colour 8
	dc.b %11000000,%00000000,%00000000,%11000000 ;Colour 9
	dc.b %00000000,%11000000,%00000000,%11000000 ;Colour 10
	dc.b %11000000,%11000000,%00000000,%11000000 ;Colour 11
	dc.b %00000000,%00000000,%11000000,%11000000 ;Colour 12
	dc.b %11000000,%00000000,%11000000,%11000000 ;Colour 13
	dc.b %00000000,%11000000,%11000000,%11000000 ;Colour 14
	dc.b %11000000,%11000000,%11000000,%11000000 ;Colour 15

c2p_pixel1
	dc.b %000000,%000000,%000000,%000000 ;Colour 0
	dc.b %110000,%000000,%000000,%000000 ;Colour 1
	dc.b %000000,%110000,%000000,%000000 ;Colour 2
	dc.b %110000,%110000,%000000,%000000 ;Colour 3
	dc.b %000000,%000000,%110000,%000000 ;Colour 4
	dc.b %110000,%000000,%110000,%000000 ;Colour 5
	dc.b %000000,%110000,%110000,%000000 ;Colour 6
	dc.b %110000,%110000,%110000,%000000 ;Colour 7
	dc.b %000000,%000000,%000000,%110000 ;Colour 8
	dc.b %110000,%000000,%000000,%110000 ;Colour 9
	dc.b %000000,%110000,%000000,%110000 ;Colour 10
	dc.b %110000,%110000,%000000,%110000 ;Colour 11
	dc.b %000000,%000000,%110000,%110000 ;Colour 12
	dc.b %110000,%000000,%110000,%110000 ;Colour 13
	dc.b %000000,%110000,%110000,%110000 ;Colour 14
	dc.b %110000,%110000,%110000,%110000 ;Colour 15

c2p_pixel2
	dc.b %0000,%0000,%0000,%0000 ;Colour 0
	dc.b %1100,%0000,%0000,%0000 ;Colour 1
	dc.b %0000,%1100,%0000,%0000 ;Colour 2
	dc.b %1100,%1100,%0000,%0000 ;Colour 3
	dc.b %0000,%0000,%1100,%0000 ;Colour 4
	dc.b %1100,%0000,%1100,%0000 ;Colour 5
	dc.b %0000,%1100,%1100,%0000 ;Colour 6
	dc.b %1100,%1100,%1100,%0000 ;Colour 7
	dc.b %0000,%0000,%0000,%1100 ;Colour 8
	dc.b %1100,%0000,%0000,%1100 ;Colour 9
	dc.b %0000,%1100,%0000,%1100 ;Colour 10
	dc.b %1100,%1100,%0000,%1100 ;Colour 11
	dc.b %0000,%0000,%1100,%1100 ;Colour 12
	dc.b %1100,%0000,%1100,%1100 ;Colour 13
	dc.b %0000,%1100,%1100,%1100 ;Colour 14
	dc.b %1100,%1100,%1100,%1100 ;Colour 15

c2p_pixel3
	dc.b %00,%00,%00,%00 ;Colour 0
	dc.b %11,%00,%00,%00 ;Colour 1
	dc.b %00,%11,%00,%00 ;Colour 2
	dc.b %11,%11,%00,%00 ;Colour 3
	dc.b %00,%00,%11,%00 ;Colour 4
	dc.b %11,%00,%11,%00 ;Colour 5
	dc.b %00,%11,%11,%00 ;Colour 6
	dc.b %11,%11,%11,%00 ;Colour 7
	dc.b %00,%00,%00,%11 ;Colour 8
	dc.b %11,%00,%00,%11 ;Colour 9
	dc.b %00,%11,%00,%11 ;Colour 10
	dc.b %11,%11,%00,%11 ;Colour 11
	dc.b %00,%00,%11,%11 ;Colour 12
	dc.b %11,%00,%11,%11 ;Colour 13
	dc.b %00,%11,%11,%11 ;Colour 14
	dc.b %11,%11,%11,%11 ;Colour 15
