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
                adc BYINC,X             ; add Y-increment
                sta BYHOLD,X            ; replace Y-sum
                lda #0
                rol A                   ; carry = 1
                sta DELTAY              ; Y-delta
                lda BOMBLR,X            ; bomb L/R flag
                beq _left               ; go left? Yes.

                lda BOMBX,X             ; bomb X-coord
                adc DELTAX              ; add X-delta
                jmp _advY               ; skip next

_left           lda BOMBX,X             ; bomb X-coord
                sec
                sbc DELTAX              ; sub X-delta
_advY           sta BOMBX,X             ; save X-coord
                lda BOMBUD,X            ; bomb U/D flag
                beq _down               ; go down? Yes.

                lda BOMBY,X             ; bomb Y-coord
                sec
                sbc DELTAY              ; sub Y-delta
                jmp _XIT                ; skip next

_down           lda BOMBY,X             ; bomb Y-coord
                clc
                adc DELTAY              ; add Y-delta
_XIT            sta BOMBY,X             ; save Y-coord
                rts
                .endproc
