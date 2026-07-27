
* Disassembly of Super Hang-On boot sectors



    MOVE.L    #$00048000,D0
    MOVE.L    #$00000002,D1
    MOVEA.L   $0004,A6
    JSR       -198(A6)			$48000 of chip memory

    MOVE.L    #$00060000,D0
    MOVEQ.L   #0,D1
    MOVEA.L   $0004,A6
    JSR       -198(A6)			$60000 of public memory
    TST.L     D0
    BEQ.S     no.extra.memory

    CMP.L     #$00080000,D0
    BCC.S     no.extra.memory

    MOVE.L    #$00080000,D0

no.extra.memory
    ANDI.L    #$FFF80000,D0
    MOVE.L    D0,D7

    MOVEA.L   $0004,A6
    JSR       -150(A6)			SuperState

    MOVE.W    #$2700,SR			no interrupts
    MOVE.W    #$3fff,$00DFF09A

    LEA.L     $00000180,A7
    LEA.L     $00000300,A0
    MOVE.L    A0,USP
    MOVE.L    D7,$00000180

    BSR       waitvbl

    MOVE.W    #$1ff,$00DFF096
    MOVE.W    #$200,$00DFF100
    CLR.W     $00DFF180

    LEA.L     L000002(PC),A0
    MOVE.L    A0,$00000010		illegal instruction

    MOVE.W    #$6800,$00000184		determine processor
    MOVEQ.L   #0,D0

    DC.W      $4E7B
    DC.W      $0002
    MOVE.W    #$6820,$00000184


L000002:
    LEA.L     $00000180,A7
    MOVE.W    L000013(PC),$00000100
    LEA.L     $00000008,A0
    MOVEQ.L   #61,D0
L000003:
    MOVE.L    #$00000100,(A0)+		set all to rte instruction
    DBF       D0,L000003

    CLR.W     $00DFF024			DSKLEN
    MOVE.B    #$7d,$00BFD100
    MOVE.B    #$75,$00BFD100
    MOVE.W    #$4489,$00DFF07E
    MOVE.W    #$8400,$00DFF09E		WORDSYNC
    MOVE.W    #$8100,$00DFF09E		MFM
    MOVE.W    #$8010,$00DFF096		enable copper DMA
    MOVE.W    #$0002,$00DFF09C		no DSKBLK interrupt

to.track0
    BTST.B    #4,$00BFE001		is head at track 0 ?
    BEQ.S     at.track0
    BSR       step.outwards
    BRA.S     to.track0

at.track0
    BSR       step.inwards

disk.not.ready
    BTST.B    #5,$00BFE001
    BNE.S     disk.not.ready

    LEA.L     $00072000,A0
    MOVE.L    A0,$00DFF020		DSKPTH

    TST.B     $00BFDD00			CIA-B ICR
index.wait
    BTST.B    #4,$00BFDD00		INDEX
    BEQ.S     index.wait

    MOVE.W    #$9013,$00DFF024		DSKLEN
    MOVE.W    #$9013,$00DFF024		4115 words

DMA.not.done
    MOVE.W    $00DFF01E,D0		INTREQR
    BTST.L    #1,D0			disk DMA transfer done
    BEQ.S     DMA.not.done

    CLR.W     $00DFF024			DSKLEN
    MOVE.W    #$0002,$00DFF09C		no DSKBLK interrupt

    MOVEQ.L   #9,D0
L000009:
    CMPI.W    #$4489,(A0)+
    BNE.S     not.sync.value
    CMPI.W    #$2aaa,(A0)
    BEQ.S     L00000B

not.sync.value
    DBF       D0,L000009
    BRA       to.track0			retry if sync value not found

L00000B:
    ADDQ.W    #2,A0

    MOVE.W    #$8440,$00DFF096		blitter DMA enabled
    BSR       blit.wait

    CLR.L     $00DFF060
    CLR.L     $00DFF064			no modulos

    MOVE.L    #$FFFFFFFF,$00DFF044	BLTAFWM

    MOVE.W    #$5555,$00DFF070		BLTCDAT

    LEA.L     $00072000,A1
    SUBQ.W    #4,A1
    MOVE.L    A1,$00DFF054		destination
    MOVE.L    A0,$00DFF050		source A
    ADDA.W    #4106,A0
    MOVE.L    A0,$00DFF04C		source B

    MOVE.L    #$0DE4F000,$00DFF040	USE A,B,D	B shifted left one

    MOVE.W    #513*64+4,$00DFF058	4104 bytes

    BSR       blit.wait

    TST.W     (A1)+
    BNE       to.track0

    MOVE.W    #1023,D1
    MOVEQ.L   #0,D0
    MOVE.W    (A1)+,D0
L00000C:
    ADD.L     (A1)+,D0
    DBF       D1,L00000C

    CMP.L     (A1),D0
    BEQ.S     L00000D

    BRA       to.track0

L00000D:
    CMPI.W    #1,$00071FFE
    BNE       to.track0

    JMP       $00072000




step.inwards
    MOVE.B    #$74,$00BFD100		drive 0, inward, diskstep low
    MOVE.B    #$75,$00BFD100		drive 0, inward, diskstep high
    BSR       waitvbl
    RTS       




step.outwards
    MOVE.B    #$76,$00BFD100		drive 0, outward, diskstep low
    MOVE.B    #$77,$00BFD100		drive 0, outward, diskstep high
    BSR       waitvbl
    RTS       




waitvbl
    MOVE.W    #$20,$00DFF09C		no vertical blank interrupt
L000011:
    MOVE.W    $00DFF01E,D0		intreqr
    BTST.L    #5,D0
    BEQ.S     L000011			wait for vertical blank

    MOVE.W    #$20,$00DFF09C		no vertical blank interrupt
    RTS       




blit.wait
    BTST.B    #6,$00DFF002
    BNE.S     blit.wait
    RTS




    ORI.W     #$2000,(A7)

L000013:
    RTE
