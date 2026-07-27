Comparison of chunky against bitplane texture mapping (4 bitplane)
------------------------------------------------------------------
- Just comparing the pixel plot section

Using extracts from TxWalls7.s (chunky) and TextureMap4.s (planar).
Also assuming TxWalls7.s uses FASTER_CHUNKY_TO_PLANAR

(Also assuming 68000 - need to also test both on 68020)




Planar - Plot 32 pixels, best case (offset0)
--------------------------------------------
READ_PIXEL 1		; 4 times
	move.l	(a3,d1.w),d6	; 18
-> total 4*18 = 72 CPU cycles

READ_PIXEL 0		; 28 times
	add.l	d6,d6			; 8
	or.l	(a3,d1.w),d6	; 20
-> total 28*28 = 784 CPU cycles

STORE_WHOLE_BYTE	; 4 times
	move.b	d6,(a0)+		; 8
	move.b	(a2,d6.w),(a4)+	; 18
	swap	d6				; 4
	move.b	d6,(a5)+		; 8
	move.b	(a2,d6.w),(a6)+	; 18
-> total 4*56 = 224 CPU cycles

total = 1080 cycles




Chunky - Plot 32 pixels, best case
----------------------------------
plot chunky pixel: (This code isn't in TxWalls7.s)
	move.b	(a5,d1.w),(a6)	; 18
	lea	SCREEN_WIDTH(a6),a6	; 8
-> total 26

Or removing the lea and just using one instruction with a displacement to get correct screen location:
	move.b	(a5,d1.w),d16(a6)	; 22

plot 32 chunky pixels - 32*22 = 704 CPU cycles
FASTER_CHUNKY_TO_PLANAR - 1096140/2000 = 548.07 CPU cycles

total = 1252.07 cycles

Think can get it down to 1126 using optimisations mentioned in TxWalls7.s
