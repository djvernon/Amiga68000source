*******************************************************************
*                                                                 *
*                                                                 *
*     DSM MC68000 Disassembler Version 1.0d (07/01/88).           *
*     Copyright (C) 1987, 1988 by OTG Software.                   *
*     All rights reserved.                                        *
*                                                                 *
*     Disassembly of :  aload                                     *
*                                                                 *
*                                                                 *
*******************************************************************


         clr.l    chip1024
         clr.l    chipmem
         clr.l    slowmem
         clr.l    fastmem
         clr.l    filehandle

* open DOS library

         movea.l  ($0004).w,a6
         movem.l  d0/a0,-(a7)
         lea      DOSname(pc),a1
         moveq    #$00,d0
         jsr      -$0228(a6)
         lea      DOSbase(pc),a0
         move.l   d0,(a0)

* process command line

         movem.l  (a7)+,d0/a0
         cmp.w    #$0001,d0
         beq      L16
         cmp.w    #$0002,d0
         bne      L1
         cmpi.b   #$3f,(a0)
         beq      L16
L1       cmpi.b   #$22,(a0)
         bne      L2
         subq.w   #$2,d0
         addq.l   #$1,a0
L2       clr.b    -$01(a0,d0.w)
         move.l   a0,cmdstart
         lea      -$01(a0,d0.w),a1
         move.l   a1,cmdend

* open file for reading

         move.l   a0,d1
         move.l   #$000003ed,d2		MODE_OLD (read)
         movea.l  DOSbase(pc),a6
         jsr      -$001e(a6)
         lea      filehandle(pc),a0
         move.l   d0,(a0)
         beq      L7

* read/check first 4 bytes, i.e. 'ARP3'
         lea      buff1(pc),a0
         move.l   filehandle(pc),d1
         move.l   a0,d2
         moveq    #$04,d3
         jsr      -$002a(a6)
         cmp.l    #$00000004,d0
         bne      L8

         lea      buff1(pc),a0
         cmpi.l   #$41525033,(a0)	'ARP3'
         bne      L9

* read 28 bytes
         lea      buff1(pc),a0
         move.l   filehandle(pc),d1
         move.l   a0,d2
         moveq    #$1c,d3
         jsr      -$002a(a6)
         cmp.l    #$0000001c,d0
         bne      L8

* allocate chip memory block
         movea.l  ($0004).w,a6
         move.l   buff1(pc),d0
         moveq    #$02,d1
         jsr      -$00c6(a6)
         lea      chipmem(pc),a0
         move.l   d0,(a0)
         beq      L11

* check chip memory end address is within range
         add.l    buff1(pc),d0
         sub.l    $003e(a6),d0		MaxLocMem - highest chip mem address
         cmp.l    #-$00000a00,d0
         bgt      L11

* allocate slow memory block
         move.l   L84(pc),d0
         beq      L3
         subi.l   #$00c00000,d0
         bsr      L40
         lea      slowmem(pc),a0
         move.l   d0,(a0)
         beq      L12

* allocate fast memory block
L3       move.l   L85(pc),d0
         beq      L4
         sub.l    L88(pc),d0
         bsr      L44
         lea      fastmem(pc),a0
         move.l   d0,(a0)
         beq      L13

* allocate 1024 bytes chip memory
L4       move.l   #$00000400,d0
         moveq    #$02,d1
         jsr      -$00c6(a6)
         lea      chip1024(pc),a0
         move.l   d0,(a0)
         beq      L11

* check chip1024 memory end address is within range
         addi.l   #$00000400,d0
         sub.l    $003e(a6),d0
         cmp.l    #-$00000a00,d0
         bgt      L11

* load file(s) into memory blocks
         bsr      L15
         jsr      L23(pc)
         tst.l    d0
         bmi      L14

* read last 1024 bytes into chip1024 memory
         movea.l  DOSbase(pc),a5
         move.l   filehandle(pc),d1
         move.l   chip1024(pc),d2
         move.l   #$00001000,d3		read up to 4096 bytes
         jsr      -$002a(a5)
         tst.l    d0
         bmi      L8

* switch CPU to Supervisor mode
         movea.l  ($0004).w,a6
         lea      L5,a5
         ;dv jsr      -$001e(a6)

L5       ;dv move.w   #$4000,$00dff09a	disable ints
         ;dv move.w   #$7fff,$00dff096	disable DMA
         ;dv move.b   #-$01,$00bfd100
         ;dv move.b   #-$79,$00bfd100
         ;dv move.b   #-$01,$00bfd100
         ;dv lea      $00100000,a7
         movea.l  chip1024(pc),a1
         bsr      L64			transfer hardware register values

* move next part of loader to required area (e.g. $7f600) then execute
         lea      L78(pc),a0
         movea.l  L86(pc),a1
         suba.w   #$0a00,a1
         move.w   #$09ff,d0
L6       move.b   (a0)+,(a1)+
         dbf      d0,L6
         movea.l  L86(pc),a1
         suba.w   #$0a00,a1

	 lea	mydelay(pc),a0
         lea	$7fc44,a1
         move.w	#(delaysize/2)-1,d0
copy	 move.w	(a0)+,(a1)+
	 dbra	d0,copy
	 
jump     jmp      (a1)

mydelay	move.b	#8,$bfde00
	move.b	#0,$bfd400
	move.b	#$c,$bfd500
loop	btst	#0,$bfdd00	wait for ICR bit to be set instead
	beq.s	loop
done	rts
delaysize	equ	*-mydelay

* output file not found
L7       lea      L48(pc),a0
         move.l   #$00000017,d3
         bsr      outtext
         bra      L17

* output file corrupt
L8       lea      L49(pc),a0
         move.l   #$00000015,d3
         bsr      outtext
         bra      L17

* output mkII file
L9       cmpi.l   #$41525046,(a0)	'ARPF'
         bne      L10
         lea      L54(pc),a0
         move.l   #$00000029,d3
         bsr      outtext
         bra      L17

* output invalid freeze-file
L10      lea      L50(pc),a0
         move.l   #$0000001d,d3
         bsr      outtext
         bra      L17

* output out of chip memory
L11      lea      L51(pc),a0
         move.l   #$0000001b,d3
         bsr      outtext
         bra      L17

* output out of fast memory (actually slow memory)
L12      lea      L55(pc),a0
         move.l   #$0000001b,d3
         bsr      outtext
         bra      L17

* output out of expansion memory (actually fast memory)
L13      lea      L56(pc),a0
         move.l   #$0000001a,d3
         bsr      outtext
         bra      L17

* output loading error
L14      lea      L59(pc),a0
         move.l   #$00000016,d3
         bsr      outtext
         bra      L17

* output loading
L15      lea      L52(pc),a0
         move.l   #$00000027,d3
         bra      outtext

* output usage
L16      lea      L53(pc),a0
         move.l   #$00000016,d3
         bra      outtext

L17      movea.l  ($0004).w,a6
         move.l   chip1024,d0
         beq      L18
         movea.l  #$00000400,a1
         exg      d0,a1
         jsr      -$00d2(a6)
L18      move.l   chipmem,d0
         beq      L19
         movea.l  buff1,a1
         exg      d0,a1
         jsr      -$00d2(a6)
L19      move.l   slowmem,d0
         beq      L20
         movea.l  L84,a1
         suba.l   #$00c00000,a1
         exg      d0,a1
         jsr      -$00d2(a6)
L20      move.l   fastmem,d0
         beq      L21
         movea.l  L85,a1
         suba.l   L88,a1
         exg      d0,a1
         jsr      -$00d2(a6)
L21      move.l   DOSbase,d0
         beq      L22
         movea.l  d0,a5
         move.l   filehandle,d1
         jsr      -$0024(a5)
L22      rts      

* load from correct file(s) into required memory blocks
L23      movem.l  d6-d7/a1-a2,-(a7)
         move.l   #$000c8000,d7
         moveq    #$00,d6
         movea.l  chipmem(pc),a1
         move.l   a1,d0
         add.l    buff1(pc),d0
         movea.l  d0,a2
         jsr      L26(pc)
         bmi      L25

         tst.l    L84
         beq      L24
         movea.l  slowmem(pc),a1
         move.l   a1,d0
         add.l    L84(pc),d0
         subi.l   #$00c00000,d0
         movea.l  d0,a2
         jsr      L26(pc)
         bmi      L25

L24      tst.l    L85
         beq      L25
         movea.l  fastmem(pc),a1
         move.l   a1,d0
         add.l    L85(pc),d0
         sub.l    L88(pc),d0
         movea.l  d0,a2
         jsr      L26(pc)
L25      movem.l  (a7)+,d6-d7/a1-a2
         rts      

* load from correct file(s) into memory block
L26      movem.l  d5/a1-a2,-(a7)
         move.l   a2,d5
         sub.l    a1,d5
         movea.l  a1,a2
L27      cmp.l    d7,d5
         bls      L28
         move.l   d7,d0
         sub.l    d0,d5
         jsr      L30(pc)
         bmi      L29
         lea      $00(a2,d0.l),a2
         jsr      L32(pc)
         bmi      L29
         move.l   #$000c8000,d7
         bra.s    L27

L28      move.l   d5,d0
         sub.l    d0,d7
         jsr      L30(pc)
L29      movem.l  (a7)+,d5/a1-a2
         rts      

* read from current open file into memory block
L30      movem.l  d1-d4/a0-a6,-(a7)
         move.l   d0,d4
         movea.l  ($0004).w,a6
         move.l   filehandle(pc),d1
         move.l   a2,d2
         move.l   d0,d3
         movea.l  DOSbase(pc),a5
         jsr      -$002a(a5)
         tst.l    d0
         bmi      L31
         cmp.l    d0,d4
         beq      L31
         moveq    #-$01,d0
L31      movem.l  (a7)+,d1-d4/a0-a6
         rts      

* close current file, open new one
L32      movem.l  d1-d3/a0-a3,-(a7)
         movea.l  ($0004).w,a6
         movea.l  DOSbase(pc),a5
         move.l   filehandle(pc),d1
         jsr      -$0024(a5)
         addq.w   #$1,d6
L33      btst     #$06,$00bfe001
         beq.s    L33
         movea.l  cmdend(pc),a0
         move.b   #$2e,(a0)+
         move.w   d6,d0
         addi.w   #$0030,d0
         move.b   d0,(a0)+
         clr.b    (a0)+
         move.l   cmdstart(pc),d1
         move.l   #$000003ed,d2		MODE_OLD (read)
         jsr      -$001e(a5)
         move.l   d0,filehandle
         bne      L35
         movea.l  #L57,a0
         move.l   #$00000057,d3
         move.w   d6,d0
         addi.w   #$0030,d0
         move.b   d0,L58
         bsr      outtext
L34      btst     #$06,$00bfe001
         beq.s    L33
         btst     #$02,$00dff016
         bne.s    L34
         moveq    #-$01,d0
L35      movem.l  (a7)+,d1-d3/a0-a3
         rts      

* allocate memory at absolute location
L36      move.l   $0010(a0),d1
         beq      L38
         addq.l   #$8,d0
L37      movea.l  d1,a0
         cmp.l    $0004(a0),d0
         bls      L39
         move.l   (a0),d1
         bne.s    L37
L38      moveq    #$00,d0
         rts      

L39      subq.l   #$8,d0
         movea.l  a0,a1
         jsr      -$00cc(a6)
         rts      

* look at exec memlist, allocate slow memory at absolute location
L40      move.l   d0,-(a7)
         movea.l  $0142(a6),a0		MemList
L41      move.l   $0014(a0),d0
         andi.l   #-$00080000,d0
         cmp.l    #$00c00000,d0
         bls      L43
L42      move.l   (a0),d0
         movea.l  d0,a0
         tst.l    d0
         bne.s    L41
         move.l   (a7)+,d0
         moveq    #$00,d0
         rts      

L43      move.l   $0018(a0),d0
         addi.l   #$0007ffff,d0
         andi.l   #-$00080000,d0
         cmp.l    L87(pc),d0
         bcs.s    L42
         move.l   (a7)+,d0
         jsr      L36(pc)
         rts      

* look at exec memlist, allocate fast memory at absolute location
L44      move.l   d0,-(a7)
         movea.l  $0142(a6),a0
L45      move.l   $0014(a0),d0
         andi.l   #-$00008000,d0
         cmp.l    L88(pc),d0
         bls      L47
L46      move.l   (a0),d0
         movea.l  d0,a0
         tst.l    d0
         bne.s    L45
         move.l   (a7)+,d0
         moveq    #$00,d0
         rts      

L47      move.l   $0018(a0),d0
         addi.l   #$00007fff,d0
         andi.l   #-$00008000,d0
         cmp.l    L89(pc),d0
         bcs.s    L46
         move.l   (a7)+,d0
         jsr      L36(pc)
         rts      

L48      dc.b     'ERROR - file not found'
         dc.b     $0a
L49      dc.b     'ERROR - file corrupt'
         dc.b     $0a
L50      dc.b     'ERROR - no valid freeze-file'
         dc.b     $0a
L51      dc.b     'ERROR - out of chip-memory'
         dc.b     $0a
L52      dc.b     $0a
         dc.b     ' - loading Action Replay freezed file'
         dc.b     $0a
L53      dc.b     'USAGE: aload filename'
         dc.b     $0a
L54      dc.b     'ERROR - AAR Mk II file: use proper aload'
         dc.b     $0a
L55      dc.b     'ERROR - out of fast-memory'
         dc.b     $0a
L56      dc.b     'ERROR - out of exp-memory'
         dc.b     $0a
L57      dc.b     $0a
         dc.b     'Insert disk with file nr '
L58      dc.b     $00
         dc.b     ' in same drive'
         dc.b     $0a
         dc.b     'and press left mousebutton or right to abort'
         dc.b     $0a
L59      dc.b     'ERROR - while loading'
         dc.b     $0a

outtext  move.l   a0,d2
         movem.l  d2-d3,-(a7)
         movea.l  ($0004).w,a6
         movea.l  DOSbase(pc),a5
         jsr      -$003c(a5)		Output
         move.l   d0,d1
         movem.l  (a7)+,d2-d3
         jsr      -$0030(a5)		Write
         moveq    #$00,d0
         rts      

DOSname      dc.b     'dos.library',$00
DOSbase      dcb.b    4,$00
filehandle   dcb.b    4,$00

* transfer values from chip1024 memory to within this program, set up usp
L64      lea      L67(pc),a2
L65      movea.l  (a2)+,a3
         move.l   (a2)+,d0
         subq.w   #$1,d0
L66      move.b   (a1)+,(a3)+
         dbf      d0,L66
         tst.w    (a2)
         bpl.s    L65

         move.l   a1,d0
         addq.l   #$1,d0
         andi.w   #-$0002,d0
         movea.l  d0,a1
         movea.l  (a1)+,a0
         ;dv move     a0,usp
         movea.l  a1,a0
         jsr      L68		prepare hardware register values
         movea.l  a0,a1
         moveq    #$00,d0
         rts      

         dc.b     $70,$ff,$60,$fa

L67      dc.l     L131
         dc.b     $00,$00,$00,$02
         dc.l     L130
         dc.b     $00,$00,$00,$02,$00,$fc
         dc.b     $00,$00,$00,$00,$00,$04
         dc.l     L82
         dc.b     $00,$00,$00,$04
         dc.l     L145
         dc.b     $00,$00,$00,$40
         dc.l     L80
         dc.b     $00,$00,$00,$02
         dc.l     L81
         dc.b     $00,$00,$00,$04,$00,$fc
         dc.b     $00,$00,$00,$00,$00,$04
         dc.b     $00,$fc,$00,$00,$00,$00
         dc.b     $00,$04,$00,$fc,$00,$00
         dc.b     $00,$00,$00,$02,$00,$fc
         dc.b     $00,$00,$00,$00,$00,$04
         dc.l     L79
         dc.b     $00,$00,$00,$30
         dc.l     L91
         dc.b     $00,$00,$00,$04
         dc.l     L90
         dc.b     $00,$00,$00,$04,$00,$fc
         dc.b     $00,$00,$00,$00,$00,$04
         dc.b     $00,$fc,$00,$00,$00,$00
         dc.b     $00,$78
         dc.l     L132
         dc.b     $00,$00,$00,$04,$00,$fc
         dc.b     $00,$00,$00,$00,$00,$02
         dc.b     $00,$fc,$00,$00,$00,$00
         dc.b     $00,$02,$00,$fc,$00,$00
         dc.b     $00,$00,$00,$01
         dc.l     L138
         dc.b     $00,$00,$00,$04
         dc.l     L137
         dc.b     $00,$00,$00,$04
         dc.l     L140
         dc.b     $00,$00,$00,$04
         dc.l     L141
         dc.b     $00,$00,$00,$01,$ff,$ff
         dc.b     $ff,$ff

* prepare hardware register values
L68      movem.l  d0/a1-a2,-(a7)
         lea      $0020(a0),a0
         lea      L72(pc),a2
         moveq    #$20,d0
L69      cmp.w    (a2),d0
         bne.s    L70
         addq.l   #$2,a2
         addq.l   #$2,a0
         bra.s    L71

L70      bsr      L73
         move.w   (a0)+,(a1)
L71      addq.w   #$2,d0
         cmp.w    #$01be,d0
         bne.s    L69
         addq.l   #$2,a0
         movem.l  (a7)+,d0/a1-a2
         rts      

L72      dc.b     $00,$26,$00,$28,$00,$2a
         dc.b     $00,$2c,$00,$38,$00,$3a
         dc.b     $00,$3c,$00,$3e,$00,$58
         dc.b     $00,$5a,$00,$5c,$00,$5e
         dc.b     $00,$68,$00,$6a,$00,$6c
         dc.b     $00,$6e,$00,$76,$00,$78
         dc.b     $00,$7a,$00,$7c,$00,$88
         dc.b     $00,$8a,$00,$ac,$00,$ae
         dc.b     $00,$bc,$00,$be,$00,$cc
         dc.b     $00,$ce,$00,$dc,$00,$de
         dc.b     $00,$f8,$00,$fa,$00,$fc
         dc.b     $00,$fe,$01,$06,$01,$0c
         dc.b     $01,$0e,$01,$1c,$01,$1e
         dc.b     $ff,$ff

L73      bsr      L74
         rts      

         dc.b     $b3,$fc,$00,$df,$f0,$00
         dc.b     $65,$0e,$b3,$fc,$00,$df
         dc.b     $f0,$1e,$62,$06,$93,$fc
         dc.b     $00,$df,$f0,$00,$4e,$75

L74      lea      L77(pc),a1
L75      cmp.w    (a1)+,d0
         beq.s    L76
         addq.l   #$4,a1
         tst.w    (a1)
         bpl.s    L75
         lea      $00dff000,a1
         lea      $00(a1,d0.w),a1
         rts      

L76      movea.l  (a1),a1
         rts      

L77      dc.b     $00,$02
         dc.l     L144
         dc.b     $00,$10
         dc.l     L107
         dc.b     $00,$1c
         dc.l     L143
         dc.b     $00,$1e
         dc.l     L142
         dc.b     $00,$28
         dc.l     L129
         dc.b     $00,$2a
         dc.l     L129
         dc.b     $00,$2c
         dc.l     L129
         dc.b     $00,$38
         dc.l     L129
         dc.b     $00,$3a
         dc.l     L129
         dc.b     $00,$3c
         dc.l     L129
         dc.b     $00,$3e
         dc.l     L129
         dc.b     $00,$40
         dc.l     L108
         dc.b     $00,$42
         dc.l     L109
         dc.b     $00,$44
         dc.l     L110
         dc.b     $00,$46
         dc.l     L111
         dc.b     $00,$48
         dc.l     L112
         dc.b     $00,$4a
         dc.l     L113
         dc.b     $00,$4c
         dc.l     L114
         dc.b     $00,$4e
         dc.l     L115
         dc.b     $00,$50
         dc.l     L116
         dc.b     $00,$52
         dc.l     L117
         dc.b     $00,$54
         dc.l     L118
         dc.b     $00,$56
         dc.l     L119
         dc.b     $00,$58
         dc.l     L127
         dc.b     $00,$60
         dc.l     L120
         dc.b     $00,$62
         dc.l     L121
         dc.b     $00,$64
         dc.l     L122
         dc.b     $00,$66
         dc.l     L123
         dc.b     $00,$70
         dc.l     L124
         dc.b     $00,$72
         dc.l     L125
         dc.b     $00,$74
         dc.l     L126
         dc.b     $00,$7e
         dc.l     L128
         dc.b     $00,$80
         dc.l     L138
         dc.b     $00,$82
         dc.l     L139
         dc.b     $00,$88
         dc.l     L129
         dc.b     $00,$8a
         dc.l     L129
         dc.b     $00,$8e
         dc.l     L99
         dc.b     $00,$90
         dc.l     L100
         dc.b     $00,$92
         dc.l     L101
         dc.b     $00,$94
         dc.l     L102
         dc.b     $00,$96
         dc.l     L144
         dc.b     $00,$9a
         dc.l     L143
         dc.b     $00,$9c
         dc.l     L142
         dc.b     $00,$9e
         dc.l     L107
         dc.b     $00,$e0
         dc.l     L103
         dc.b     $00,$e2
         dc.l     L104
         dc.b     $01,$00
         dc.l     L92
         dc.b     $01,$02
         dc.l     L93
         dc.b     $01,$04
         dc.l     L94
         dc.b     $01,$08
         dc.l     L95
         dc.b     $01,$0a
         dc.l     L96
         dc.b     $01,$80
         dc.l     L97
         dc.b     $01,$82
         dc.l     L98
         dc.b     $ff,$ff

L78      dc.b     $60,$00,$01,$36,$20,$3c
         dc.b     $00,$00,$02,$66,$22,$10
         dc.b     $20,$d1,$22,$c1,$51,$c8
         dc.b     $ff,$f8,$60,$00,$06,$e6
         dc.b     $f3,$80,$00,$00,$01,$82
         dc.b     $0f,$ff,$00,$8e,$05,$81
         dc.b     $01,$00,$02,$00,$00,$90
         dc.b     $40,$c1,$00,$92,$00,$38
         dc.b     $00,$94,$00,$d0,$01,$02
         dc.b     $00,$00,$01,$08,$00,$00
         dc.b     $00,$e0,$00,$00,$00,$e2
         dc.b     $00,$00,$2e,$01,$ff,$fe
         dc.b     $01,$00,$12,$00,$33,$01
         dc.b     $ff,$fe,$ff,$00,$02,$00
         dc.b     $34,$01,$ff,$fe,$01,$80
         dc.b     $0f,$00,$fe,$09,$ff,$fe
         dc.b     $01,$80,$00,$f0,$ff,$09
         dc.b     $ff,$fe,$01,$80,$00,$00
         dc.b     $ff,$ff,$ff,$fe,$07,$c7
         dc.b     $c7,$e7,$e7,$ce,$60,$0f
         dc.b     $cf,$ef,$cc,$07,$cc,$30
         dc.b     $07,$c8,$27,$e7,$c7,$c0
         dc.b     $01,$c7,$c3,$87,$e0,$0f
         dc.b     $e7,$ce,$67,$cf,$ef,$c0
         dc.b     $07,$c0,$0f,$c7,$cf,$ec
         dc.b     $68,$20,$0c,$6c,$01,$81
         dc.b     $8c,$6f,$60,$0c,$6c,$0c
         dc.b     $6c,$0c,$66,$60,$0c,$6c
         dc.b     $61,$8c,$0c,$60,$03,$0c
         dc.b     $00,$c0,$60,$00,$cc,$6f
         dc.b     $6c,$0c,$0c,$60,$0c,$60
         dc.b     $0c,$6c,$6c,$0c,$6c,$60
         dc.b     $0f,$ec,$01,$81,$8c,$6d
         dc.b     $e0,$0f,$cf,$8f,$cc,$0f
         dc.b     $e3,$c0,$0f,$ee,$e1,$8d
         dc.b     $ef,$e0,$03,$0c,$00,$c0
         dc.b     $60,$01,$8f,$ed,$ed,$ef
         dc.b     $8f,$c0,$0c,$60,$0f,$cc
         dc.b     $6f,$8f,$ee,$e0,$0c,$6c
         dc.b     $01,$81,$8c,$6c,$e0,$0c
         dc.b     $cc,$0c,$0c,$0c,$61,$80
         dc.b     $0c,$6f,$e1,$8c,$6c,$60
         dc.b     $03,$0c,$00,$c0,$60,$07
         dc.b     $0c,$6c,$ec,$6c,$0c,$c0
         dc.b     $0c,$60,$0c,$6c,$6c,$0c
         dc.b     $6f,$e0,$0c,$67,$c1,$87
         dc.b     $e7,$cc,$60,$0c,$6f,$ec
         dc.b     $0f,$cc,$61,$80,$0c,$6d
         dc.b     $67,$e7,$ec,$60,$01,$c7
         dc.b     $c3,$87,$c1,$8f,$ec,$6c
         dc.b     $67,$ef,$ec,$61,$87,$c1
         dc.b     $8f,$c7,$cf,$ec,$6d,$60
         dc.b     $41,$fa,$ff,$36,$20,$08
         dc.b     $41,$fa,$ff,$02,$30,$80
         dc.b     $48,$40,$41,$fa,$fe,$f6
         dc.b     $30,$80,$41,$fa,$fe,$ca
         dc.b     $23,$c8,$00,$df,$f0,$80
         dc.b     $13,$c0,$00,$df,$f0,$88
         dc.b     $33,$fc,$83,$80,$00,$df
         dc.b     $f0,$96,$20,$3a,$02,$80
         dc.b     $e5,$98,$48,$40,$22,$3a
         dc.b     $02,$7c,$67,$00,$00,$0e
         dc.b     $04,$81,$00,$c0,$00,$00
         dc.b     $e5,$99,$48,$41,$d0,$41
         dc.b     $22,$3a,$02,$70,$67,$00
         dc.b     $00,$0c,$92,$ba,$02,$64
         dc.b     $e5,$99,$48,$41,$d0,$41
         dc.b     $36,$00,$e5,$4b,$32,$3c
         dc.b     $4e,$71,$41,$fa,$01,$4c
         dc.b     $b0,$7c,$00,$20,$67,$00
         dc.b     $00,$16,$e2,$4b,$32,$3c
         dc.b     $e2,$59,$b0,$7c,$00,$40
         dc.b     $67,$00,$00,$08,$e2,$4b
         dc.b     $32,$3c,$e4,$59,$30,$81
         dc.b     $34,$3c,$00,$fe,$94,$43
         dc.b     $41,$fa,$fe,$90,$10,$82
         dc.b     $34,$3c,$00,$fe,$94,$40
         dc.b     $41,$fa,$01,$10,$e5,$4a
         dc.b     $30,$82,$41,$fa,$02,$06
         dc.b     $4a,$90,$67,$00,$00,$5c
         dc.b     $41,$f9,$00,$c0,$00,$00
         dc.b     $22,$7a,$05,$08,$20,$3a
         dc.b     $01,$f2,$04,$80,$00,$c0
         dc.b     $00,$00,$e4,$88,$20,$d9
         dc.b     $53,$80,$66,$fa,$41,$fa
         dc.b     $04,$ea,$20,$bc,$00,$c0
         dc.b     $00,$00,$41,$fa,$04,$dc
         dc.b     $20,$ba,$01,$d2,$3f,$3a
         dc.b     $00,$d0,$41,$fa,$00,$cc
         dc.b     $72,$00,$04,$50,$0c,$00
         dc.b     $20,$3a,$01,$c8,$d0,$ba
         dc.b     $01,$d0,$90,$ba,$01,$c8
         dc.b     $e5,$98,$48,$40,$e5,$48
         dc.b     $d1,$50,$61,$00,$00,$72
         dc.b     $41,$fa,$00,$aa,$30,$9f
         dc.b     $41,$fa,$01,$a6,$4a,$90
         dc.b     $67,$00,$00,$56,$20,$7a
         dc.b     $01,$a8,$22,$7a,$04,$aa
         dc.b     $20,$3a,$01,$94,$90,$88
         dc.b     $e4,$88,$20,$d9,$53,$80
         dc.b     $66,$fa,$41,$fa,$04,$8c
         dc.b     $20,$ba,$01,$8e,$41,$fa
         dc.b     $04,$80,$20,$ba,$01,$7a
         dc.b     $3f,$3a,$00,$74,$41,$fa
         dc.b     $00,$70,$72,$00,$22,$3a
         dc.b     $01,$78,$e5,$89,$48,$41
         dc.b     $e5,$49,$93,$50,$72,$00
         dc.b     $20,$3a,$01,$62,$e5,$98
         dc.b     $48,$40,$e5,$48,$d1,$50
         dc.b     $61,$00,$00,$14,$41,$fa
         dc.b     $00,$4c,$30,$9f,$61,$00
         dc.b     $03,$2a,$61,$00,$02,$e2
         dc.b     $60,$00,$01,$7e,$20,$7a
         dc.b     $04,$3e,$22,$7a,$04,$3e
         dc.b     $24,$60,$d5,$c9,$2a,$20
         dc.b     $20,$20,$b1,$85,$e2,$88
         dc.b     $66,$04,$61,$00,$00,$be
         dc.b     $65,$62,$72,$08,$76,$01
         dc.b     $e2,$88,$66,$04,$61,$00
         dc.b     $00,$b0,$65,$00,$00,$80
         dc.b     $72,$03,$42,$44,$48,$e7
         dc.b     $c0,$80,$20,$0a,$e9,$98
         dc.b     $48,$40,$d0,$7c,$00,$de
         dc.b     $32,$3c,$03,$f8,$92,$40
         dc.b     $00,$00,$44,$41,$06,$41
         dc.b     $00,$fe,$41,$fa,$fd,$6a
         dc.b     $10,$81,$4c,$df,$01,$03
         dc.b     $61,$00,$00,$8a,$36,$02
         dc.b     $d6,$44,$72,$07,$e2,$88
         dc.b     $66,$04,$61,$00,$00,$70
         dc.b     $e3,$92,$51,$c9,$ff,$f4
         dc.b     $15,$02,$51,$cb,$ff,$ec
         dc.b     $60,$00,$00,$42,$72,$08
         dc.b     $78,$08,$60,$b2,$72,$02
         dc.b     $61,$00,$00,$60,$b4,$3c
         dc.b     $00,$02,$6d,$16,$b4,$3c
         dc.b     $00,$03,$67,$e8,$72,$08
         dc.b     $61,$00,$00,$4e,$36,$02
         dc.b     $32,$3c,$00,$0c,$60,$00
         dc.b     $00,$0c,$32,$3c,$00,$09
         dc.b     $d2,$42,$54,$42,$36,$02
         dc.b     $61,$00,$00,$36,$53,$4a
         dc.b     $14,$b2,$20,$00,$51,$cb
         dc.b     $ff,$f8,$b3,$ca,$6d,$00
         dc.b     $ff,$56,$4a,$85,$66,$02
         dc.b     $4e,$75,$20,$3c,$00,$00
         dc.b     $ff,$ff,$33,$c0,$00,$df
         dc.b     $f1,$82,$53,$80,$66,$f6
         dc.b     $4e,$75,$20,$20,$b1,$85
         dc.b     $44,$fc,$00,$10,$e2,$90
         dc.b     'NuSABB'
         dc.b     $e2,$88,$66,$0a,$20,$20
         dc.b     $b1,$85,$44,$fc,$00,$10
         dc.b     $e2,$90,$e3,$92,$51,$c9
         dc.b     $ff,$ee,$4e,$75
L79      dcb.b    48,$00
L80      dcb.b    2,$00
L81      dcb.b    4,$00
L82      dcb.b    4,$00
buff1      dcb.b    4,$00
L84      dcb.b    4,$00
L85      dcb.b    4,$00
L86      dcb.b    4,$00
L87      dcb.b    4,$00
L88      dcb.b    4,$00
L89      dcb.b    4,$00
L90      dcb.b    4,$00
L91      dcb.b    4,$00
L92      dcb.b    2,$00
L93      dcb.b    2,$00
L94      dcb.b    2,$00
L95      dcb.b    2,$00
L96      dcb.b    2,$00
L97      dcb.b    2,$00
L98      dcb.b    2,$00
L99      dcb.b    2,$00
L100     dcb.b    2,$00
L101     dcb.b    2,$00
L102     dcb.b    2,$00
L103     dcb.b    2,$00
L104     dcb.b    2,$00

cmdstart dcb.b    3,$00
         dc.b     $01

cmdend   dc.b     $00,$00,$00,$01

	 dc.b     $41,$f8
         dc.b     $00,$00,$22,$7a,$02,$c6
         dc.b     $20,$3a,$ff,$b0,$e4,$88
         dc.b     $20,$d9,$53,$80,$66,$fa
         dc.b     $41,$fa,$02,$b2,$42,$90
         dc.b     $41,$fa,$02,$a8,$20,$ba
         dc.b     $ff,$9a,$61,$00,$fe,$60
         dc.b     $4b,$f9,$00,$df,$f0,$00
         dc.b     $3b,$7c,$02,$00,$00,$96
         dc.b     $2b,$7a,$04,$76,$00,$80
         dc.b     $2b,$7a,$ff,$b2,$00,$8e
         dc.b     $2b,$7a,$ff,$b0,$00,$92
         dc.b     $2b,$7a,$ff,$a2,$01,$80
         dc.b     $2b,$7a,$ff,$92,$01,$00
         dc.b     $3b,$7a,$ff,$90,$01,$04
         dc.b     $2b,$7a,$ff,$8c,$01,$08
         dc.b     $41,$fa,$fb,$82,$70,$19
         dc.b     $22,$7a,$ff,$76,$22,$10
         dc.b     $20,$d1,$22,$c1,$51,$c8
         dc.b     $ff,$f8,$24,$7a,$ff,$68
         dc.b     $4e,$ea,$00,$04,$10,$91
         dc.b     $11,$69,$00,$01,$01,$00
         dc.b     $11,$69,$00,$02,$02,$00
         dc.b     $11,$69,$00,$03,$03,$00
         dc.b     $11,$7c,$00,$20,$0e,$00
         dc.b     $11,$7c,$00,$60,$0f,$00
         dc.b     $11,$69,$00,$04,$04,$00
         dc.b     $11,$69,$00,$05,$05,$00
         dc.b     $11,$69,$00,$06,$06,$00
         dc.b     $11,$69,$00,$07,$07,$00
         dc.b     $08,$e8,$00,$00,$0e,$00
         dc.b     $08,$e8,$00,$00,$0f,$00
         dc.b     $11,$69,$00,$10,$04,$00
         dc.b     $11,$69,$00,$11,$05,$00
         dc.b     $11,$69,$00,$12,$06,$00
         dc.b     $11,$69,$00,$13,$07,$00
         dc.b     $42,$28,$0e,$00,$42,$28
         dc.b     $0f,$00,$11,$69,$00,$0a
         dc.b     $0a,$00,$11,$69,$00,$09
         dc.b     $09,$00,$11,$69,$00,$08
         dc.b     $08,$00,$08,$29,$00,$00
         dc.b     $00,$14,$67,$00,$00,$2a
         dc.b     $11,$69,$00,$17,$0a,$00
         dc.b     $11,$69,$00,$16,$09,$00
         dc.b     $11,$69,$00,$15,$08,$00
         dc.b     $4a,$28,$0a,$00,$11,$69
         dc.b     $00,$0a,$0a,$00,$11,$69
         dc.b     $00,$09,$09,$00,$11,$69
         dc.b     $00,$08,$08,$00,$08,$29
         dc.b     $00,$01,$00,$14,$67,$00
         dc.b     $00,$08,$11,$68,$0a,$00
         dc.b     $0a,$00,$11,$69,$00,$0c
         dc.b     $0c,$00,$11,$7c,$00,$7b
         dc.b     $0d,$00,$11,$69,$00,$0d
         dc.b     $0d,$00,$42,$28,$0e,$00
         dc.b     $42,$28,$0f,$00,$13,$fc
         dc.b     $00,$90,$00,$bf,$ed,$01
         dc.b     $4a,$39,$00,$bf,$ed,$01
         dc.b     $4a,$39,$00,$bf,$dd,$00
         dc.b     $4e,$d5,$41,$f9,$00,$df
         dc.b     $f0,$00,$31,$7a,$01,$44
         dc.b     $00,$74,$21,$7a,$01,$3a
         dc.b     $00,$70,$21,$7a,$01,$30
         dc.b     $00,$64,$21,$7a,$01,$26
         dc.b     $00,$60,$21,$7a,$01,$1c
         dc.b     $00,$54,$21,$7a,$01,$12
         dc.b     $00,$50,$21,$7a,$01,$08
         dc.b     $00,$4c,$21,$7a,$00,$fe
         dc.b     $00,$48,$21,$7a,$00,$f4
         dc.b     $00,$44,$21,$7a,$00,$ea
         dc.b     $00,$40,$4e,$75,$41,$f9
         dc.b     $00,$bf,$d1,$00,$08,$90
         dc.b     $00,$03,$08,$39,$00,$04
         dc.b     $00,$bf,$e0,$01,$67,$00
         dc.b     $00,$0c,$08,$d0,$00,$03
         dc.b     $61,$00,$00,$aa,$60,$e6
         dc.b     $43,$fa,$00,$fa,$70,$00
         dc.b     $10,$11,$e2,$48,$53,$40
         dc.b     $6b,$00,$00,$0a,$61,$00
         dc.b     $00,$78,$51,$c8,$ff,$fa
         dc.b     $08,$90,$00,$02,$08,$11
         dc.b     $00,$00,$66,$00,$00,$06
         dc.b     $08,$d0,$00,$02,$33,$fa
         dc.b     $00,$c2,$00,$df,$f0,$7e
         dc.b     $41,$fa,$00,$90,$08,$d0
         dc.b     $00,$07,$33,$fc,$7f,$ff
         dc.b     $00,$df,$f0,$9e,$33,$fa
         dc.b     $00,$80,$00,$df,$f0,$9e
         dc.b     $70,$00,$30,$3a,$00,$a6
         dc.b     $02,$40,$3f,$ff,$e3,$88
         dc.b     $d0,$ba,$00,$98,$23,$c0
         dc.b     $00,$df,$f0,$20,$4e,$75
         dc.b     $13,$fc,$00,$08,$00,$bf
         dc.b     $de,$00,$13,$fc,$00,$00
         dc.b     $00,$bf,$d4,$00,$13,$fc
         dc.b     $00,$0c,$00,$bf,$d5,$00
         dc.b     $08,$f9,$00,$00,$00,$bf
         dc.b     $de,$00,$4a,$39,$00,$bf
         dc.b     $d5,$00,$66,$f8,$4e,$75
         dc.b     $08,$90,$00,$03,$08,$90
         dc.b     $00,$01,$08,$90,$00,$00
         dc.b     $4e,$71,$4e,$71,$08,$d0
         dc.b     $00,$00,$08,$d0,$00,$03
         dc.b     $61,$bc,$4e,$75,$08,$90
         dc.b     $00,$03,$08,$d0,$00,$01
         dc.b     $08,$90,$00,$00,$4e,$71
         dc.b     $4e,$71,$08,$d0,$00,$00
         dc.b     $08,$d0,$00,$03,$61,$a0
         dc.b     $4e,$75
L107     dcb.b    2,$00
L108     dcb.b    2,$00
L109     dcb.b    2,$00
L110     dcb.b    2,$00
L111     dcb.b    2,$00
L112     dcb.b    2,$00
L113     dcb.b    2,$00
L114     dcb.b    2,$00
L115     dcb.b    2,$00
L116     dcb.b    2,$00
L117     dcb.b    2,$00
L118     dcb.b    2,$00
L119     dcb.b    2,$00
L120     dcb.b    2,$00
L121     dcb.b    2,$00
L122     dcb.b    2,$00
L123     dcb.b    2,$00
L124     dcb.b    2,$00
L125     dcb.b    2,$00
L126     dcb.b    2,$00
L127     dcb.b    2,$00
L128     dcb.b    8,$00
L129     dcb.b    4,$00
L130     dcb.b    2,$00
L131     dcb.b    2,$00
L132     dcb.b    12,$00
chipmem     dcb.b    4,$00
slowmem     dcb.b    4,$00
fastmem     dcb.b    4,$00
chip1024    dcb.b    4,$00

         dc.b     $41,$fa,$fc,$bb,$08,$10
         dc.b     $00,$07,$66,$00,$00,$54
         dc.b     $13,$fc,$00,$7f,$00,$bf
         dc.b     $d1,$00,$10,$3a,$fc,$a7
         dc.b     $4e,$71,$4e,$71,$13,$c0
         dc.b     $00,$bf,$d1,$00,$4e,$71
         dc.b     $4e,$71,$13,$fc,$00,$7f
         dc.b     $00,$bf,$d1,$00,$30,$3c
         dc.b     $00,$7d,$13,$fc,$00,$08
         dc.b     $00,$bf,$de,$00,$13,$fc
         dc.b     $00,$00,$00,$bf,$d4,$00
         dc.b     $13,$fc,$00,$0c,$00,$bf
         dc.b     $d5,$00,$08,$f9,$00,$00
         dc.b     $00,$bf,$de,$00,$4a,$39
         dc.b     $00,$bf,$d5,$00,$66,$f8
         dc.b     $51,$c8,$ff,$d6,$41,$f9
         dc.b     $00,$bf,$e0,$01,$43,$fa
         dc.b     $fc,$3e,$4b,$fa,$00,$06
         dc.b     $60,$00,$fd,$2e,$41,$f9
         dc.b     $00,$bf,$d0,$00,$43,$fa
         dc.b     $fc,$44,$4b,$fa,$00,$06
         dc.b     $60,$00,$fd,$1c,$41,$fa
         dc.b     $01,$9e,$30,$fa,$fc,$2a
         dc.b     $30,$fa,$fc,$3e,$40,$c0
         dc.b     $00,$40,$07,$00,$46,$c0
         dc.b     $4c,$fa,$ff,$ff,$01,$48
         dc.b     $3e,$ba,$fc,$36,$2f,$7a
         dc.b     $fc,$34,$00,$02,$41,$fa
         dc.b     $01,$34,$08,$d0,$00,$07
         dc.b     $41,$fa,$01,$2e,$08,$d0
         dc.b     $00,$07,$4b,$f9,$00,$df
         dc.b     $f0,$00,$3b,$7c,$7f,$ff
         dc.b     $00,$9a,$41,$fa,$01,$1c
         dc.b     $08,$d0,$00,$07,$3b,$7c
         dc.b     $7f,$ff,$00,$96,$3b,$7c
         dc.b     $00,$20,$00,$9c,$08,$2d
         dc.b     $00,$05,$00,$1f,$67,$f8
         dc.b     $3b,$7c,$00,$20,$00,$9c
         dc.b     $08,$28,$00,$07,$00,$01
         dc.b     $67,$10,$41,$fa,$00,$e8
         dc.b     $4a,$90,$6a,$00,$00,$8e
         dc.b     $3b,$7c,$83,$80,$00,$96
         dc.b     $20,$3a,$fb,$dc,$02,$80
         dc.b     $00,$01,$ff,$ff,$22,$2d
         dc.b     $00,$04,$02,$81,$00,$01
         dc.b     $ff,$ff,$b0,$81,$64,$f2
         dc.b     $20,$7a,$fb,$e8,$20,$3a
         dc.b     $fb,$e0,$43,$fa,$ff,$f6
         dc.b     $20,$c0,$b1,$c9,$63,$fa
         dc.b     $41,$fa,$00,$fa,$13,$d8
         dc.b     $00,$bf,$ee,$01,$13,$d8
         dc.b     $00,$bf,$ef,$01,$13,$d8
         dc.b     $00,$bf,$de,$00,$13,$d8
         dc.b     $00,$bf,$df,$00,$4c,$fa
         dc.b     $ff,$ff,$00,$9c,$33,$fc
         dc.b     $03,$80,$00,$df,$f0,$96
         dc.b     $33,$fa,$00,$8e,$00,$df
         dc.b     $f0,$96,$33,$fa,$00,$84
         dc.b     $00,$df,$f0,$9a,$23,$fa
         dc.b     $00,$6c,$00,$df,$f0,$80
         dc.b     $23,$fa,$00,$60,$00,$df
         dc.b     $f0,$84,$33,$fc,$7f,$ff
         dc.b     $00,$df,$f0,$9c,$33,$fa
         dc.b     $00,$62,$00,$df,$f0,$9c
         dc.b     $4e,$73,$41,$fa,$00,$56
         dc.b     $4a,$10,$67,$00,$00,$24
         dc.b     $41,$fa,$00,$44,$20,$b8
         dc.b     $00,$00,$21,$fc,$ff,$ff
         dc.b     $ff,$fe,$00,$00,$23,$f8
         dc.b     $00,$00,$00,$df,$f0,$80
         dc.b     $21,$fa,$00,$2c,$00,$00
         dc.b     $60,$00,$00,$12,$23,$fa
         dc.b     $00,$26,$00,$df,$f0,$80
         dc.b     $33,$fc,$00,$00,$00,$df
         dc.b     $f0,$88,$23,$fa,$fb,$1a
         dc.b     $00,$df,$f0,$2a,$60,$00
         dc.b     $ff,$5e
L137     dcb.b    4,$00
L138     dcb.b    2,$00
L139     dcb.b    6,$00
L140     dcb.b    4,$00
L141     dcb.b    2,$00
L142     dcb.b    2,$00
L143     dcb.b    2,$00
L144     dcb.b    2,$00
L145     dcb.b    70,$00
