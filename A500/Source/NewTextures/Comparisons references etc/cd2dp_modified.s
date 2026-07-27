;
; Chunky to planar double-to-double pixel
; by The Paranoid 2012
; Exclusively for Daniel Vulcan
; (With minor modifications made for assembly by DV)
;


c2pdp
    lea source_buffer,A0
    lea target_buffer,A6

    lea        cd2dp_01,A3
    lea        cd2dp_23,A4
;    move.w     #scr_h-1,D6
    move.w  #(SCREEN_HEIGHT*CHUNKY_SCREEN_WIDTH)/32-1,D7

xy_loop:
    movem.w       (A0)+,D0-D5/A1-A2    ;  44 cycles
    move.l   0(A3,D0.w),D0             ;  18 cycles
    or.l     0(A4,D1.w),D0             ;  20 cycles
    movep.l          D0,0(A6)          ;  24 cycles
    move.l   0(A3,D2.w),D0             ;  18 cycles
    or.l     0(A4,D3.w),D0             ;  20 cycles
    movep.l          D0,1(A6)          ;  24 cycles
    move.l   0(A3,D4.w),D0             ;  18 cycles
    or.l     0(A4,D5.w),D0             ;  20 cycles
    movep.l          D0,8(A6)          ;  24 cycles
    move.l   0(A3,A1.w),D0             ;  18 cycles
    or.l     0(A4,A2.w),D0             ;  20 cycles
    movep.l          D0,9(A6)          ;  24 cycles = 292 cycles

    movem.w       (A0)+,D0-D5/A1-A2    ;  44 cycles
    move.l   0(A3,D0.w),D0             ;  18 cycles
    or.l     0(A4,D1.w),D0             ;  20 cycles
    movep.l          D0,16(A6)         ;  24 cycles
    move.l   0(A3,D2.w),D0             ;  18 cycles
    or.l     0(A4,D3.w),D0             ;  20 cycles
    movep.l          D0,17(A6)         ;  24 cycles
    move.l   0(A3,D4.w),D0             ;  18 cycles
    or.l     0(A4,D5.w),D0             ;  20 cycles
    movep.l          D0,24(A6)         ;  24 cycles
    move.l   0(A3,A1.w),D0             ;  18 cycles
    or.l     0(A4,A2.w),D0             ;  20 cycles
    movep.l          D0,25(A6)         ;  24 cycles = 584 cycles
    lea          32(A6),A6             ;   8 cycles
    dbra             D7,xy_loop        ;  14 cycles = 606 cycles for 64 planar pixels
    rts

;
; cd2dp-tables are usually being generated from the initial table
; from the tutorial for two pixels at once:
;
; Bit 15 14 13 12 11 10  9  8    7  6  5  4  3  2  1  0
;           |_________|               |_________|
;           left pixel                right pixel
;
; Requires 4096 entries per table = 16384 bytes
; Two tables required             = 32768 bytes
;
; Let's summarize: 606 cycles for 64 pixels at 320 pixels a line = 3030 cycles
; For 200 lines, that makes                                      = 606000 cycles
; Calculating net number of cycles per pixel (/64000)            = 9,46875 cycles
;

gen_c2pdp_tables
    lea      c2p_pixel0(pc),a0
    lea      c2p_pixel1(pc),a1
    lea      cd2dp_01,a2
    bsr.s    gen_c2pdp_table

    lea      c2p_pixel2(pc),a0
    lea      c2p_pixel3(pc),a1
    lea      cd2dp_23,a2
;    bra.s    gen_c2pdp_table

; a0 = source first pixel table
; a1 = source second pixel table
; a2 = target double pixel table
gen_c2pdp_table
    moveq    #0,d0           ; first pixel

.nextp1
    moveq    #0,d1           ; second pixel

.nextp2
    move.l   (a0,d0.w),d2
    or.l     (a1,d1.w),d2

    move.w   d0,d3
    lsl.l    #8,d3
    or.w     d1,d3
    move.l   d2,(a2,d3.w)

    addq.w   #4,d1
    cmp.w    #64,d1
    bne.s    .nextp2

    addq.w   #4,d0
    cmp.w    #64,d0
    bne.s    .nextp1
    rts


; lookup tables (2-dimensional arrays) for converting two pixels at once
cd2dp_01
    ds.l     64*64
cd2dp_23
    ds.l     64*64
