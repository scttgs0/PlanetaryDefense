
;======================================
; Advance bombs/projectiles
;======================================
AdvanceIt       .proc
                lda BXHOLD,X            ; bomb X-sum
                clc
                adc BXINC,X             ; add X-increment
                sta BXHOLD,X            ; replace X-sum

                lda #0
                rol A                   ; carry = 1
                sta DELTAX              ; X-delta

                lda BYHOLD,X            ; bomb Y-sum
                clc
                adc BYINC,X             ; add Y-increment
                sta BYHOLD,X            ; replace Y-sum

                lda #0
                rol A                   ; carry = 1
                sta DELTAY              ; Y-delta

                lda lrBomb,X            ; bomb L/R flag
                beq _left               ; go left? Yes.

                lda BombX,X             ; bomb X-coord
                adc DELTAX              ; add X-delta
                bra _advY               ; skip next

_left           lda BombX,X             ; bomb X-coord
                sec
                sbc DELTAX              ; subtract X-delta

_advY           sta BombX,X             ; save X-coord

                lda udBomb,X            ; bomb U/D flag
                beq _down               ; go down? Yes.

                lda BombY,X             ; bomb Y-coord
                sec
                sbc DELTAY              ; subtract Y-delta
                bra _XIT                ; skip next

_down           lda BombY,X             ; bomb Y-coord
                clc
                adc DELTAY              ; add Y-delta

_XIT            sta BombY,X             ; save Y-coord

                rts
                .endproc
