;======================================
; Check satellite status
;======================================
CHKSAT          lda DEADTM              ;satellite ok?
                beq LIVE                ;No. skip next

CHKSX           rts                     ;return

LIVE            lda LIVES               ;lives left?
                bmi CHKSX               ;No. exit

                lda #1                  ;get one
                sta SATLIV              ;set alive flag
                lda M0PL                ;did satellite
                ora M0PL+1              ;hit any bombs?
                beq CHKSX               ;No. exit

                lda #0                  ;get zero
                sta SATLIV              ;kill satellite
                sta SCNT                ;init orbit
                ldx LIVES               ;one less life
                sta SCOLIN+14,X         ;erase life
                dec LIVES               ;dec lives count
                bpl MORSAT              ;any left? Yes.

                lda #255                ;lot of bombs
                sta BOMBS               ;into bomb count
                sta GAMCTL              ;end game
                jsr SNDOFF              ;no sound 1 2 3

MORSAT          lda SATX                ;sat X-coord
                sta NEWX                ;explo X-coord
                lda SATY                ;sat Y-coord
                sta NEWY                ;explo Y-coord
                jsr NEWEXP              ;set off explo

                lda #80                 ;init sat X
                sta SATX                ;sat X-coord
                lda #21                 ;init sat Y
                sta SATY                ;sat Y-coord
                ldx #0                  ;don't show the
CLRSAT          lda MISL,X              ;satellite pic
                and #$F0                ;mask off sat
                sta MISL,X              ;restore data
                dex                     ;dec index
                bne CLRSAT              ;done? No.

                lda #$FF                ;4.25 seconds
                sta DEADTM              ;till next life!
                rts                     ;return
