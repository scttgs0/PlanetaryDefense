
;-------------------------------------
; Check console keys
;-------------------------------------
EndGame         .proc
                jsr SoundOff            ; no sound 123

_next1          lda InputFlags          ; stick trigger
                and $10
                ;and PTRIG0             ; mask w/paddle 0
                ;and PTRIG1             ; mask w/paddle 1
                beq _1                  ; any pushed? No.

                lda CONSOL              ; chk console
                cmp #7                  ; any pushed?
                beq _next1              ;   no. loop here

_1              jmp Planet              ; restart game

                .endproc
