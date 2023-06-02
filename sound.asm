
;======================================
; Turn off sound regs 1 2 3
;======================================
SoundOff        .proc
                lda #0                  ; zero volume
                sta SID1_CTRL1          ; to sound #1
                sta SID1_CTRL2          ; sound #2
                sta SID1_CTRL3          ; sound #3
                rts
                .endproc
