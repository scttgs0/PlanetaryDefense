;======================================
; Turn off sound regs 1 2 3
;======================================
SoundOff        .proc
                lda #0                  ; zero volume
                sta SID_CTRL1           ; to sound #1
                sta SID_CTRL2              ; sound #2
                sta SID_CTRL3              ; sound #3
                rts
                .endproc
