;======================================
; Advance bombs/projectiles
;======================================
ADVIT           lda BXHOLD,X            ;bomb X-sum
                clc                     ;clear carry
                adc BXINC,X             ;add X-increment
                sta BXHOLD,X            ;replace X-sum
                lda #0                  ;get zero
                rol A                   ;carry = 1
                sta DELTAX              ;X-delta
                lda BYHOLD,X            ;bomb Y-sum
                adc BYINC,X             ;add Y-increment
                sta BYHOLD,X            ;replace Y-sum
                lda #0                  ;get zero
                rol A                   ;carry = 1
                sta DELTAY              ;Y-delta
                lda BOMBLR,X            ;bomb L/R flag
                beq ADVLFT              ;go left? Yes.

                lda BOMBX,X             ;bomb X-coord
                adc DELTAX              ;add X-delta
                jmp ADVY                ;skip next

ADVLFT          lda BOMBX,X             ;bomb X-coord
                sec                     ;set carry
                sbc DELTAX              ;sub X-delta
ADVY            sta BOMBX,X             ;save X-coord
                lda BOMBUD,X            ;bomb U/D flag
                beq ADVDN               ;go down? Yes.

                lda BOMBY,X             ;bomb Y-coord
                sec                     ;set carry
                sbc DELTAY              ;sub Y-delta
                jmp ADVEND              ;skip next

ADVDN           lda BOMBY,X             ;bomb Y-coord
                clc                     ;clear carry
                adc DELTAY              ;add Y-delta
ADVEND          sta BOMBY,X             ;save Y-coord
                rts                     ;return
