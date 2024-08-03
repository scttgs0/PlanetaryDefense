
;======================================
; Turn off sound regs 1 2 3
;======================================
SoundOff        .proc
                stz SID1_CTRL1          ; zero-volume for sound #1
                stz SID1_CTRL2          ; ... sound #2
                stz SID1_CTRL3          ; ... sound #3

                rts
                .endproc
