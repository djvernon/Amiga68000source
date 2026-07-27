                  incdir "DH0:include/"
                  include "hardware/custom.i"
                  ;
custom equ $dff000
                  ;
_main             lea custom,a0
                  move.w #$03a0,dmacon(a0)
                  ;
                  move.l #52,d0
                  move.l #2,d1
                  move.l 4,a6
                  jsr -198(a6)
                  move.l d0,coppermem
                  beq done
                  lea hamplanes,a0
hploop            move.l a0,hpcnt
                  move.l #13536,d0
                  move.l #2,d1
                  move.l 4,a6
                  jsr -198(a6)
                  move.l hpcnt,a0
                  move.l d0,(a0)+
                  beq done
                  lea coppermem,a1
                  cmp.l a1,a0
                  bne hploop
                  ;
                  lea copperl,a0
                  addq.l #2,a0
                  lea hamplanes,a1
prepcoplist       move.w (a1)+,d0
                  move.w d0,(a0)
                  addq.l #4,a0
                  lea coppermem,a2
                  cmp.l a2,a1
                  bne prepcoplist
                  ;
                  lea custom,a0
                  move.w #$6a00,bplcon0(a0)
                  move.w #0,bplcon1(a0)
                  move.w #0,bpl1mod(a0)
                  move.w #0,bpl2mod(a0)
                  move.w #$28,ddfstrt(a0)
                  move.w #$e0,ddfstop(a0)
                  move.w #$1c51,diwstrt(a0)
                  move.w #$36c9,diwstop(a0)
                  ;
                  move.w #32,d0
                  lea custom,a1
                  add.l #color,a1
cregloop          move.w #$0000,(a1)+
                  subq.w #1,d0
                  bne cregloop
                  ;
                  move.w #3384,d0
                  movem.l hamplanes,a1-a6
fplloop           move.l #$55555555,(a1)+
                  move.l #$33333333,(a2)+
                  move.l #$0f0f0f0f,(a3)+
                  move.l #$00ff00ff,(a4)+
                  move.l #$00000000,(a5)+
                  move.l #$7fff7fff,(a6)+
                  subq.w #1,d0
                  bne fplloop
                  ;
                  move.l coppermem,a1
                  lea copperl,a2
cloop             move.l (a2),(a1)+
                  cmpi.l #$fffffffe,(a2)+
                  bne cloop
                  ;
                  move.l coppermem,a1
                  move.l a1,cop1lc(a0)
                  move.w copjmp1(a0),d0
                  move.w #$8380,dmacon(a0)
done              bra.s done
                  ;
hpcnt             dc.l 0
copperl           dc.w $e0,$0,$e2,$0,$e4,$0,$e6,$0,$e8,$0
                  dc.w $ea,$0,$ec,$0,$ee,$0,$f0,$0,$f2,$0
                  dc.w $f4,$0,$f6,$0,$ffff,$fffe
hamplanes         ds.l 6
coppermem         dc.l 0
                  ;
                  end

