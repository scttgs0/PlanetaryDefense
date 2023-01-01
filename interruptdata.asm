; ------------------
; Intro Display List
; ------------------

TLDL            .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr MAGMSG

                .byte AEMPTY8
                .byte 7

                .byte AEMPTY8
                .byte 6

                .byte AEMPTY2
                .byte 6

                .byte AEMPTY8,AEMPTY8
                .byte 6

                .byte AEMPTY3
                .byte 6

                .byte AEMPTY5
                .byte 6

                .byte AVB+AJMP
                    .addr TLDL

; ------------------
; Intro Message Text
; ------------------

MAGMSG
            .enc "atari-screen"
                .text " ANALOG COMPUTING'S "
                .text $40,"planetary",$40,$40,"defense",$40
            .enc "atari-screen-inverse"
                .text $80,"BY",$80,"CHARLES",$80,"BACHAND",$80
                .text "   and tom hudson   "
            .enc "atari-screen"
                .text $40,"koala",$40,"pad",$40,$4D,$40,"select",$40
            .enc "atari-screen-inverse"
                .text " joystick --- start "
            .enc "atari-screen"
                .text "  OR PRESS TRIGGER  "
            .enc "none"

; -----------------
; Game Display List
; -----------------

GLIST           .byte AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr SCOLIN

                .byte $0D+ALMS
                    .addr SCRN

                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D

                .byte AVB+AJMP
                    .addr GLIST
