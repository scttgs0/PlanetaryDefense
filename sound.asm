;======================================
; Turn off sound regs 1 2 3
;======================================
SoundOff        .proc
                lda #0                  ; zero volume
                ;sta AUDC1              ; to sound #1
                ;sta AUDC2              ; sound #2
                ;sta AUDC3              ; sound #3
                rts
                .endproc
