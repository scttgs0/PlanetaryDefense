;======================================
; Check for hits on bombs
;======================================
CHKHIT          ldx #3                  ;4 bombs 0..3
                lda SAUCER              ;saucer enabled?
                beq CHLOOP              ;No. skip next

                lda #0                  ;get zero
                sta BOMCOL              ;collision count
                lda GAMCTL              ;game over?
                bmi NOSCOR              ;Yes. skip next

                lda BOMBX+3             ;saucer X-coord
                cmp #39                 ;off screen lf?
                bcc NOSCOR              ;Yes. kill it

                cmp #211                ;off screen rt?
                bcs NOSCOR              ;Yes. kill it

                lda BOMBY+3             ;saucer Y-coord
                cmp #19                 ;off screen up?
                bcc NOSCOR              ;Yes. kill it

                cmp #231                ;off screen dn?
                bcs NOSCOR              ;Yes. kill it

CHLOOP          lda #0                  ;get zero
                sta BOMCOL              ;collision count
                lda P0PF,X              ;playf collision
                and #$05                ;w/shot+planet
                beq NOBHIT              ;hit either? No.

                inc BOMCOL              ;Yes. inc count
                and #$04                ;hit shot?
                beq NOSCOR              ;No. skip next

                lda GAMCTL              ;game over?
                bmi NOSCOR              ;Yes. skip next

                lda #2                  ;1/30th second
                sta BOMBWT              ;bomb wait time
                cpx #3                  ;saucer player?
                bne ADDBS               ;No. skip this

                lda SAUCER              ;saucer on?
                beq ADDBS               ;No. this this

                lda SAUVAL              ;saucer value
                sta SCOADD+1            ;point value
                jmp ADDIT               ;add to score


; -----------------------
; Add bomb value to score
; -----------------------

ADDBS           lda BOMVL               ;bomb value low
                sta SCOADD+2            ;score inc low
                lda BOMVH               ;bomb value high
                sta SCOADD+1            ;score inc high


;--------------------------------------
;
;--------------------------------------
ADDIT           stx XHOLD               ;save X register
                jsr ADDSCO              ;add to score

                ldx XHOLD               ;restore X
NOSCOR          lda #0                  ;get zero
                sta BOMACT,X            ;kill bomb
                ldy BOMBLR,X            ;L/R flag
                lda BOMBX,X             ;bomb X-coord
                sec                     ;set carry
                sbc BXOF,Y              ;bomb X offset
                sta NEWX                ;plotter X-coord
                lda BOMBY,X             ;bomb Y-coord
                sec                     ;set carry
                sbc #40                 ;bomb Y offset
                lsr A                   ;2 line res.
                sta NEWY                ;plotter Y-coord
                lda SAUCER              ;saucer?
                beq EXPBOM              ;No. explode it

                cpx #3                  ;bomb player?
                bne EXPBOM              ;Yes. explode it

                lda #0                  ;get zero
                sta SAUCER              ;kill saucer
                jsr CLRPLR              ;clear player

                lda GAMCTL              ;game over?
                bmi NOBHIT              ;Yes. skip next

EXPBOM          jsr CLRPLR              ;clear player

                lda BOMCOL              ;collisions?
                beq NOBHIT              ;No. skip this

                jsr NEWEXP              ;init explosion

NOBHIT          dex                     ;dec index
                bpl CHLOOP              ;done? No.

                sta HITCLR              ;reset collision
                rts                     ;return
