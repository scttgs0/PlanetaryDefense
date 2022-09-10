;--------------------------------------
; Setup Orbiter Coordinates
;--------------------------------------
SETUP           ldx #64                 ;do 65 bytes
                ldy #0                  ;quad 2/4 offset
SU1             clc                     ;clear carry
                lda #96                 ;center Y
                adc OYTBL,X             ;add offset Y
                sta ORBY+$40,Y          ;quad-2 Y
                sta ORBY+$80,X          ;quad-3 Y
                lda #80                 ;center X
                adc OXTBL,X             ;add offset X
                sta ORBX,X              ;quad-1 X
                sta ORBX+$40,Y          ;quad-2 X
                sec                     ;set carry
                lda #80                 ;center X
                sbc OXTBL,X             ;sub offset X
                sta ORBX+$80,X          ;quad-3 X
                sta ORBX+$C0,Y          ;quad-4 X
                lda #96                 ;center Y
                sbc OYTBL,X             ;sub offset Y
                sta ORBY,X              ;quad-1 Y
                sta ORBY+$C0,Y          ;quad-4 Y
                iny                     ;quad 2/4 offset
                dex                     ;quad 1/3 offset
                bpl SU1                 ;done? No.

                jmp INIT                ;continue

; ---------------------------
; Orbiter X,Y Coordinate Data
; ---------------------------

OXTBL           .byte 0,1,2,2,3
                .byte 4,5,5,6,7
                .byte 8,9,9,10,11
                .byte 12,12,13,14,14
                .byte 15,16,16,17,18
                .byte 18,19,20,20,21
                .byte 21,22,23,23,24
                .byte 24,25,25,26,26
                .byte 27,27,27,28,28
                .byte 29,29,29,30,30
                .byte 30,30,31,31,31
                .byte 31,31,32,32,32
                .byte 32,32,32,32,32

OYTBL           .byte 54,54,54,54,54
                .byte 54,54,54,53,53
                .byte 53,52,52,52,51
                .byte 51,50,50,49,49
                .byte 48,47,47,46,45
                .byte 44,44,43,42,41
                .byte 40,39,38,38,37
                .byte 36,35,33,32,31
                .byte 30,29,28,27,26
                .byte 24,23,22,21,20
                .byte 18,17,16,15,13
                .byte 12,11,9,8,7
                .byte 5,4,3,1,0
