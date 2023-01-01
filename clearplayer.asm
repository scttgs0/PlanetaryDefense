;======================================
; Clear out player indicated
; by the X register!
;======================================
CLRPLR          lda #0                  ;move player...
                sta HPOSP0,X            ;off screen,
                tay                     ;init index
                txa                     ;get X
                ora #>PLR0              ;mask w/address
                sta HI                  ;plr addr high
                tya                     ;Acc = 0
                sta LO                  ;plr addr low
CLPLP           sta (LO),Y              ;zero player
                dey                     ;dec index
                bne CLPLP               ;done? No.

                rts                     ;return
