;======================================
; Clear out player indicated
; by the X register!
;======================================
ClearPlayer     .proc
                .m16
                lda #0                  ; move player...
                plx
                asl A                   ; *8
                asl A
                asl A
                sta SP00_X_POS,X        ; off screen,
                plx
                .m8

                tay                     ; init index
                txa                     ; get X
                ora #>PLR0              ; mask w/address
                sta HI                  ; plr addr high
                tya                     ; Acc = 0
                sta LO                  ; plr addr low

_next1          sta (LO),Y              ; zero player
                dey
                bne _next1

                rts
                .endproc
