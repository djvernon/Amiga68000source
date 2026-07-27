****  Kefrens Snake Bite Demo
***  Dot Pattern Routine
**  Ripped out By Jase
*  Tidied up By Dan



	section	Kefrens,code_c
	opt	o+,o3-



start	bset	#1,$bfe001		low pass filter off

	move.l	4.w,a6
	move.l	#1*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screenmem

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

	move.l	screenmem(pc),d0	set up bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h

	move.w	#$1200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#0,bpl1mod(a6)
	move.w	#0,bpl2mod(a6)
	move.w	#0,color0(a6)
	move.w	#$fff,color1(a6)



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
	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



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

loop	bsr	clear

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait

	move.l	a6,-(sp)
	bsr	dot.pattern.routine
	move.l	(sp)+,a6

	clr.w	nextframe
wait2	tst.w	nextframe
	beq.s	wait2

	btst	#6,$bfe001
	bne.s	loop



wait3	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait3

	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	olddbz(pc),$14.w   	restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)		turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#1*40*200,d0
	jsr	-210(a6)		FreeMem

	bclr	#1,$bfe001		low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	move.w	#$10,$dff000+intreq

	move.w	#1,nextframe

rteins	rte




clear	btst	#6,dmaconr(a6)
	bne.s	clear
	move.w	#40-28,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screenmem,a0
	add.l	#40*20+6,a0
	move.l	a0,bltdpth(a6)
	move.w	#143*64+14,bltsize(a6)	width = 20 words
	rts




dot.pattern.routine
    tst.w     count.zero                ; Has count Reached Zero
    bne.s     Get.pattern.type          ; No branch >- else

    move.w    #100,count.zero           ; Get counter for next pattern
    move.l    pattern.addr(pc),a5	; Get current pattern address
    add.l     #16,a5                    ; add 16 to it
    cmp.l     #pattern.data.end,a5      ; Have we reached last pattern
    bne.s     New.pattern.addr          ; No branch >- else
    lea       pattern.data(pc),a5       ; Reset pattern address

New.pattern.addr:

    move.l    a5,pattern.addr           ; Put new pattern address in a5

Get.pattern.type:

    subq.w    #1,count.zero             ; Subtract 1 from counter
    move.l    pattern.addr(pc),a5       ; Get Pattern address
    move.l    table.1a(pc),a0
    move.l    table.1b(pc),a1
    move.l    table.2a(pc),a2
    move.l    table.2b(pc),a3
    lea       unknown(pc),a6
    move.w    8(a5),d2                  ; Get pattern type
    move.w    10(a5),d3                 ;       ^
    move.w    12(a5),d4                 ;       |
    move.w    14(a5),d5                 ;       v
    move.w    #199,d7                   ; Number of dots
    movem.l   a0-a3,-(sp)               ; Save a0-a3 onto Stack

Do.pattern:

    move.w    (a0),d0
    bne.s     L000005
    sub.w     #400,a0
    move.w    (a0),d0

L000005:

    move.w    (a1),d6
    bne.s     L000006
    sub.w     #400,a1
    move.w    (a1),d6

L000006:

    add.w     d6,d0
    add.w     d2,a0
    add.w     d3,a1

    move.w    (a2),d1
    bne.s     L000007
    sub.w     #400,a2
    move.w    (a2),d1

L000007:

    move.w    (a3),d6
    bne.s     L000008
    sub.w     #400,a3
    move.w    (a3),d6

L000008:

    add.w     d6,d1
    adda.w    d4,a2
    adda.w    d5,a3

    lea       (a6,d0.w),a4
    add.w     (a4)+,d1
    move.w    (a4),d0

    move.l    screenmem(pc),a4
    add.w     d1,a4
    bset.b    d0,(a4)
    dbra      d7,Do.pattern

    movem.l   (sp)+,a0-a3
    add.w     (a5),a0
    add.w     2(a5),a1
    cmp.l     #table.1end,a0
    blt.s     L000009
    sub.l     #$190,a0

L000009:

    cmp.l     #table.1end,a1
    blt.s     L00000a
    sub.l     #$190,a1

L00000a:

    add.w     4(a5),a2
    add.w     6(a5),a3
    cmp.l     #table.2end,a2
    blt.s     L00000b
    sub.l     #$190,a2

L00000b:

    cmp.l     #table.2end,a3
    blt.s     L00000c
    sub.l     #$190,a3

L00000c:

    move.l    a0,table.1a
    move.l    a1,table.1b
    move.l    a2,table.2a
    move.l    a3,table.2b

    rts



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth			1 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

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
color4	equ	$188
color8	equ	$190
color16	equ	$1A0



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""


screenmem	dc.l	0
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
nextframe	dc.w	0
count.zero	dc.w	0
pattern.addr	dc.l	pattern.data
table.1a	dc.l	table1
table.1b	dc.l	table1+64
table.2a	dc.l	table2
table.2b	dc.l	table2+128



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""


pattern.data:
	dc.w	$0004,$0004,$0004,$0004,$0002,$0006,$0006,$0002
	dc.w	$0002,$0002,$0004,$0000,$0004,$0000,$0004,$0002
	dc.w	$0004,$0000,$0002,$0000,$0006,$0008,$0004,$0008
	dc.w	$0000,$0000,$0002,$0002,$0006,$0008,$0004,$0002
	dc.w	$0008,$0004,$0008,$0004,$0002,$0002,$0002,$0002
	dc.w	$0004,$0004,$0002,$0002,$0006,$0002,$0004,$0002
	dc.w	$0000,$0002,$0002,$0000,$0006,$0002,$0004,$0000
	dc.w	$0004,$0004,$0000,$0000,$0006,$0002,$0004,$0008
	dc.w	$0002,$0000,$0004,$0000,$0002,$0064,$0002,$0064
	dc.w	$0004,$0000,$0002,$0000,$0002,$0002,$0004,$000a
pattern.data.end


table1:
	dc.w	$0144,$0148,$0150,$0158,$015c,$0164,$016c,$0174
	dc.w	$0178,$0180,$0188,$018c,$0194,$0198,$01a0,$01a4
	dc.w	$01ac,$01b4,$01b8,$01bc,$01c4,$01c8,$01d0,$01d4
	dc.w	$01d8,$01dc,$01e4,$01e8,$01ec,$01f0,$01f4,$01f8
	dc.w	$01fc,$0200,$0204,$0208,$0208,$020c,$0210,$0210
	dc.w	$0214,$0214,$0218,$0218,$021c,$021c,$021c,$021c
	dc.w	$021c,$021c,$021c,$021c,$021c,$021c,$021c,$021c
	dc.w	$021c,$0218,$0218,$0214,$0214,$0210,$0210,$020c
	dc.w	$0208,$0204,$0204,$0200,$01fc,$01f8,$01f4,$01f0
	dc.w	$01ec,$01e8,$01e4,$01dc,$01d8,$01d4,$01d0,$01c8
	dc.w	$01c4,$01bc,$01b8,$01b0,$01ac,$01a4,$01a0,$0198
	dc.w	$0194,$018c,$0184,$0180,$0178,$0170,$016c,$0164
	dc.w	$015c,$0158,$0150,$0148,$0140,$013c,$0134,$012c
	dc.w	$0128,$0120,$0118,$0110,$010c,$0104,$00fc,$00f8
	dc.w	$00f0,$00ec,$00e4,$00dc,$00d8,$00d0,$00cc,$00c8
	dc.w	$00c0,$00bc,$00b4,$00b0,$00ac,$00a8,$00a0,$009c
	dc.w	$0098,$0094,$0090,$008c,$0088,$0084,$0080,$007c
	dc.w	$007c,$0078,$0074,$0074,$0070,$0070,$006c,$006c
	dc.w	$0068,$0068,$0068,$0068,$0068,$0068,$0068,$0068
	dc.w	$0068,$0068,$0068,$0068,$0068,$006c,$006c,$0070
	dc.w	$0070,$0074,$0074,$0078,$007c,$0080,$0080,$0084
	dc.w	$0088,$008c,$0090,$0094,$0098,$009c,$00a0,$00a8
	dc.w	$00ac,$00b0,$00b8,$00bc,$00c0,$00c8,$00cc,$00d4
	dc.w	$00d8,$00e0,$00e4,$00ec,$00f0,$00f8,$0100,$0104
	dc.w	$010c,$0114,$0118,$0120,$0128,$012c,$0134,$013c
table.1end
	dcb.w	100,0


table2:
	dc.w	$0730,$0758,$0780,$07a8,$07d0,$07f8,$0820,$0848
	dc.w	$0870,$08c0,$08e8,$0910,$0938,$0960,$0988,$09b0
	dc.w	$09d8,$0a00,$0a28,$0a50,$0a78,$0aa0,$0aa0,$0ac8
	dc.w	$0af0,$0b18,$0b40,$0b68,$0b68,$0b90,$0bb8,$0bb8
	dc.w	$0be0,$0be0,$0c08,$0c30,$0c30,$0c58,$0c58,$0c58
	dc.w	$0c80,$0c80,$0c80,$0ca8,$0ca8,$0ca8,$0ca8,$0ca8
	dc.w	$0ca8,$0ca8,$0ca8,$0ca8,$0ca8,$0ca8,$0ca8,$0ca8
	dc.w	$0ca8,$0ca8,$0c80,$0c80,$0c80,$0c58,$0c58,$0c58
	dc.w	$0c30,$0c30,$0c08,$0be0,$0be0,$0bb8,$0bb8,$0b90
	dc.w	$0b68,$0b40,$0b40,$0b18,$0af0,$0ac8,$0aa0,$0aa0
	dc.w	$0a78,$0a50,$0a28,$0a00,$09d8,$09b0,$0988,$0960
	dc.w	$0938,$0910,$08e8,$08c0,$0870,$0848,$0820,$07f8
	dc.w	$07d0,$07a8,$0780,$0758,$0708,$06e0,$06b8,$0690
	dc.w	$0668,$0640,$0618,$05f0,$05a0,$0578,$0550,$0528
	dc.w	$0500,$04d8,$04b0,$0488,$0460,$0438,$0410,$03e8
	dc.w	$03c0,$0398,$0398,$0370,$0348,$0320,$02f8,$02d0
	dc.w	$02d0,$02a8,$0280,$0280,$0258,$0230,$0230,$0208
	dc.w	$0208,$01e0,$01e0,$01e0,$01b8,$01b8,$01b8,$0190
	dc.w	$0190,$0190,$0190,$0190,$0190,$0190,$0190,$0190
	dc.w	$0190,$0190,$0190,$0190,$0190,$0190,$01b8,$01b8
	dc.w	$01b8,$01e0,$01e0,$01e0,$0208,$0208,$0230,$0258
	dc.w	$0258,$0280,$0280,$02a8,$02d0,$02f8,$02f8,$0320
	dc.w	$0348,$0370,$0398,$0398,$03c0,$03e8,$0410,$0438
	dc.w	$0460,$0488,$04b0,$04d8,$0500,$0528,$0550,$05a0
	dc.w	$05c8,$05f0,$0618,$0640,$0668,$0690,$06b8,$06e0
table.2end
	dcb.w	100,0


unknown:
	dc.w	$0000,$0007,$0000,$0006,$0000,$0005,$0000,$0004
	dc.w	$0000,$0003,$0000,$0002,$0000,$0001,$0000,$0000
	dc.w	$0001,$0007,$0001,$0006,$0001,$0005,$0001,$0004
	dc.w	$0001,$0003,$0001,$0002,$0001,$0001,$0001,$0000
	dc.w	$0002,$0007,$0002,$0006,$0002,$0005,$0002,$0004
	dc.w	$0002,$0003,$0002,$0002,$0002,$0001,$0002,$0000
	dc.w	$0003,$0007,$0003,$0006,$0003,$0005,$0003,$0004
	dc.w	$0003,$0003,$0003,$0002,$0003,$0001,$0003,$0000
	dc.w	$0004,$0007,$0004,$0006,$0004,$0005,$0004,$0004
	dc.w	$0004,$0003,$0004,$0002,$0004,$0001,$0004,$0000
	dc.w	$0005,$0007,$0005,$0006,$0005,$0005,$0005,$0004
	dc.w	$0005,$0003,$0005,$0002,$0005,$0001,$0005,$0000
	dc.w	$0006,$0007,$0006,$0006,$0006,$0005,$0006,$0004
	dc.w	$0006,$0003,$0006,$0002,$0006,$0001,$0006,$0000
	dc.w	$0007,$0007,$0007,$0006,$0007,$0005,$0007,$0004
	dc.w	$0007,$0003,$0007,$0002,$0007,$0001,$0007,$0000
	dc.w	$0008,$0007,$0008,$0006,$0008,$0005,$0008,$0004
	dc.w	$0008,$0003,$0008,$0002,$0008,$0001,$0008,$0000
	dc.w	$0009,$0007,$0009,$0006,$0009,$0005,$0009,$0004
	dc.w	$0009,$0003,$0009,$0002,$0009,$0001,$0009,$0000
	dc.w	$000a,$0007,$000a,$0006,$000a,$0005,$000a,$0004
	dc.w	$000a,$0003,$000a,$0002,$000a,$0001,$000a,$0000
	dc.w	$000b,$0007,$000b,$0006,$000b,$0005,$000b,$0004
	dc.w	$000b,$0003,$000b,$0002,$000b,$0001,$000b,$0000
	dc.w	$000c,$0007,$000c,$0006,$000c,$0005,$000c,$0004
	dc.w	$000c,$0003,$000c,$0002,$000c,$0001,$000c,$0000
	dc.w	$000d,$0007,$000d,$0006,$000d,$0005,$000d,$0004
	dc.w	$000d,$0003,$000d,$0002,$000d,$0001,$000d,$0000
	dc.w	$000e,$0007,$000e,$0006,$000e,$0005,$000e,$0004
	dc.w	$000e,$0003,$000e,$0002,$000e,$0001,$000e,$0000
	dc.w	$000f,$0007,$000f,$0006,$000f,$0005,$000f,$0004
	dc.w	$000f,$0003,$000f,$0002,$000f,$0001,$000f,$0000
	dc.w	$0010,$0007,$0010,$0006,$0010,$0005,$0010,$0004
	dc.w	$0010,$0003,$0010,$0002,$0010,$0001,$0010,$0000
	dc.w	$0011,$0007,$0011,$0006,$0011,$0005,$0011,$0004
	dc.w	$0011,$0003,$0011,$0002,$0011,$0001,$0011,$0000
	dc.w	$0012,$0007,$0012,$0006,$0012,$0005,$0012,$0004
	dc.w	$0012,$0003,$0012,$0002,$0012,$0001,$0012,$0000
	dc.w	$0013,$0007,$0013,$0006,$0013,$0005,$0013,$0004
	dc.w	$0013,$0003,$0013,$0002,$0013,$0001,$0013,$0000
	dc.w	$0014,$0007,$0014,$0006,$0014,$0005,$0014,$0004
	dc.w	$0014,$0003,$0014,$0002,$0014,$0001,$0014,$0000
	dc.w	$0015,$0007,$0015,$0006,$0015,$0005,$0015,$0004
	dc.w	$0015,$0003,$0015,$0002,$0015,$0001,$0015,$0000
	dc.w	$0016,$0007,$0016,$0006,$0016,$0005,$0016,$0004
	dc.w	$0016,$0003,$0016,$0002,$0016,$0001,$0016,$0000
	dc.w	$0017,$0007,$0017,$0006,$0017,$0005,$0017,$0004
	dc.w	$0017,$0003,$0017,$0002,$0017,$0001,$0017,$0000
	dc.w	$0018,$0007,$0018,$0006,$0018,$0005,$0018,$0004
	dc.w	$0018,$0003,$0018,$0002,$0018,$0001,$0018,$0000
	dc.w	$0019,$0007,$0019,$0006,$0019,$0005,$0019,$0004
	dc.w	$0019,$0003,$0019,$0002,$0019,$0001,$0019,$0000
	dc.w	$001a,$0007,$001a,$0006,$001a,$0005,$001a,$0004
	dc.w	$001a,$0003,$001a,$0002,$001a,$0001,$001a,$0000
	dc.w	$001b,$0007,$001b,$0006,$001b,$0005,$001b,$0004
	dc.w	$001b,$0003,$001b,$0002,$001b,$0001,$001b,$0000
	dc.w	$001c,$0007,$001c,$0006,$001c,$0005,$001c,$0004
	dc.w	$001c,$0003,$001c,$0002,$001c,$0001,$001c,$0000
	dc.w	$001d,$0007,$001d,$0006,$001d,$0005,$001d,$0004
	dc.w	$001d,$0003,$001d,$0002,$001d,$0001,$001d,$0000
	dc.w	$001e,$0007,$001e,$0006,$001e,$0005,$001e,$0004
	dc.w	$001e,$0003,$001e,$0002,$001e,$0001,$001e,$0000
	dc.w	$001f,$0007,$001f,$0006,$001f,$0005,$001f,$0004
	dc.w	$001f,$0003,$001f,$0002,$001f,$0001,$001f,$0000
	dc.w	$0020,$0007,$0020,$0006,$0020,$0005,$0020,$0004
	dc.w	$0020,$0003,$0020,$0002,$0020,$0001,$0020,$0000
	dc.w	$0021,$0007,$0021,$0006,$0021,$0005,$0021,$0004
	dc.w	$0021,$0003,$0021,$0002,$0021,$0001,$0021,$0000
	dc.w	$0022,$0007,$0022,$0006,$0022,$0005,$0022,$0004
	dc.w	$0022,$0003,$0022,$0002,$0022,$0001,$0022,$0000
	dc.w	$0023,$0007,$0023,$0006,$0023,$0005,$0023,$0004
	dc.w	$0023,$0003,$0023,$0002,$0023,$0001,$0023,$0000
	dc.w	$0024,$0007,$0024,$0006,$0024,$0005,$0024,$0004
	dc.w	$0024,$0003,$0024,$0002,$0024,$0001,$0024,$0000
	dc.w	$0025,$0007,$0025,$0006,$0025,$0005,$0025,$0004
	dc.w	$0025,$0003,$0025,$0002,$0025,$0001,$0025,$0000
	dc.w	$0026,$0007,$0026,$0006,$0026,$0005,$0026,$0004
	dc.w	$0026,$0003,$0026,$0002,$0026,$0001,$0026,$0000
	dc.w	$0027,$0007,$0027,$0006,$0027,$0005,$0027,$0004
	dc.w	$0027,$0003,$0027,$0002,$0027,$0001,$0027,$0000


grafname	dc.b	'graphics.library',0
		even

