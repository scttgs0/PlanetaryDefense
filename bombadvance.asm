;======================================
; Bomb advance handler
;======================================
BOMADV          lda BOMTIM              ;bomb timer
                bne RT2                 ;time up? No.

                lda LIVES               ;any lives?
                bpl REGBT               ;Yes. skip next

                lda #1                  ;speed up bombs
                bne SETBTM              ;skip next

REGBT           lda BOMTI               ;get bomb speed
SETBTM          sta BOMTIM              ;reset timer
                ldx #3                  ;check 4 bombs
ADVBLP          lda BOMACT,X            ;bomb on?
                beq NXTBOM              ;No. try next

                jsr ADVIT               ;advance bomb

                lda LIVES               ;any lives left?
                bpl SHOBOM              ;Yes. skip next

                jsr ADVIT               ;No. move bombs
                jsr ADVIT               ;4 times faster
                jsr ADVIT               ;than normal


; --------------------------
; We've now got updated bomb
; coordinates for plotting!
; --------------------------

SHOBOM          lda BOMBY,X             ;bomb Y-coord
                clc                     ;clear carry
                adc #2                  ;bomb center off
                sta INDX1               ;save it
                lda #0                  ;get zero
                sta LO                  ;init low byte
                txa                     ;index to Acc
                ora #>PLR0              ;mask w/address
                sta HI                  ;init high byte
                stx INDX2               ;X temp hold
                cpx #3                  ;saucer slot?
                bne NOTSAU              ;No. skip next

                lda SAUCER              ;saucer in slot?
                bne NXTBOM              ;Yes. skip bomb

NOTSAU          ldy BOMBLR,X            ;L/R flag
                lda #17                 ;do 17 bytes
                sta TEMP                ;set counter
                ldx BPSTRT,Y            ;start position
                ldy INDX1               ;bomb Y pos
BDRAW           cpy #32                 ;off screen top?
                bcc NOBDRW              ;Yes. skip next

                cpy #223                ;screen bottom?
                bcs NOBDRW              ;Yes. skip next

                lda BOMPIC,X            ;bomb picture
                sta (LO),Y              ;put in PM area
NOBDRW          dey                     ;PM index
                dex                     ;picture index
                dec TEMP                ;dec count
                bne BDRAW               ;done? No.

                ldx INDX2               ;restore X
                lda BOMBX,X             ;bomb X-coord
                sta HPOSP0,X            ;player pos
NXTBOM          dex                     ;more bombs?
                bpl ADVBLP              ;yes!

                rts                     ;all done!
