;--------------------------------------
; Check console keys
;--------------------------------------
ENDGAM          jsr SNDOFF              ;no sound 123

ENDGLP          lda STRIG0              ;stick trigger
                and PTRIG0              ;mask w/paddle 0
                and PTRIG1              ;mask w/paddle 1
                beq ENDGL1              ;any pushed? No.

                lda CONSOL              ;chk console
                cmp #7                  ;any pushed?
                beq ENDGLP              ;No. loop here

ENDGL1          jmp PLANET              ;restart game
