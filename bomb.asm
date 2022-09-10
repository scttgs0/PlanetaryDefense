;======================================
; Bomb initializer
;======================================
BOMINI          lda BOMBWT              ;bomb wait time
                bne NOBINI              ;done? No.

                lda BOMBS               ;more bombs?
                bne CKLIVE              ;Yes. skip RTS

NOBINI          rts                     ;No. return

CKLIVE          ldx #3                  ;find..
CKLVLP          lda BOMACT,X            ;an available..
                beq GOTBOM              ;bomb? Yes.

                dex                     ;No. dec index
                bpl CKLVLP              ;done? No.

                rts                     ;return

GOTBOM          lda #1                  ;this one is..
                sta BOMACT,X            ;active now
                dec BOMBS               ;one less bomb
                lda #0                  ;zero out all..
                sta BXHOLD,X            ;vector X hold
                sta BYHOLD,X            ;vector Y hold
                lda GAMCTL              ;game control
                bmi NOSAUC              ;saucer possible?


; --------------
; Saucer handler
; --------------

                cpx #3                  ;Yes. bomb #3?
                bne NOSAUC              ;No. skip next

                lda RANDOM              ;random number
                cmp SAUCHN              ;compare chances
                bcs NOSAUC              ;put saucer? No.

                lda #1                  ;Yes. get one
                sta SAUCER              ;enable saucer
                lda RANDOM              ;random number
                and #$03                ;range: 0..3
                tay                     ;use as index
                lda STARTX,Y            ;saucer start X
                cmp #$FF                ;random flag?
                bne SAVESX              ;No. use as X

                jsr SAURND              ;random X-coord

                adc #35                 ;add X offset
SAVESX          sta FROMX               ;from X vector
                sta BOMBX,X             ;init X-coord
                lda STARTY,Y            ;saucer start Y
                cmp #$FF                ;random flag?
                bne SAVESY              ;No. use as Y

                jsr SAURND              ;random Y-coord

                adc #55                 ;add Y offset
SAVESY          sta FROMY               ;from Y vector
                sta BOMBY,X             ;init Y-coord
                lda ENDX,Y              ;saucer end X
                cmp #$FF                ;random flag?
                bne SAVEEX              ;No. use as X

                lda #230                ;screen right
                sec                     ;offset so not
                sbc FROMY               ;to hit planet
SAVEEX          sta TOX                 ;to X vector
                lda ENDY,Y              ;saucer end Y
                cmp #$FF                ;random flag?
                bne SAVEEY              ;No. use as Y

                lda FROMX               ;use X for Y
SAVEEY          sta TOY                 ;to Y vector
                jmp GETBV               ;skip next


; ------------
; Bomb handler
; ------------

NOSAUC          lda RANDOM              ;random number
                bmi BXMAX               ;coin flip

                lda RANDOM              ;random number
                and #1                  ;make 0..1
                tay                     ;use as index
                lda BMAXS,Y             ;top/bottom tbl
                sta BOMBY,X             ;bomb Y-coord
SETRBX          lda RANDOM              ;random number
                cmp #250                ;compare w/250
                bcs SETRBX              ;less than? No.

                sta BOMBX,X             ;bomb X-coord
                jmp BOMVEC              ;skip next

BXMAX           lda RANDOM              ;random number
                and #1                  ;make 0..1
                tay                     ;use as index
                lda BMAXS,Y             ;0 or 250
                sta BOMBX,X             ;bomb X-coord
SETRBY          lda RANDOM              ;random number
                cmp #250                ;compare w/250
                bcs SETRBY              ;less than? No.

                sta BOMBY,X             ;bomb Y-coord
BOMVEC          lda BOMBX,X             ;bomb X-coord
                sta FROMX               ;shot from X
                lda BOMBY,X             ;bomb Y-coord
                sta FROMY               ;shot from Y
                lda #128                ;planet center
                sta TOX                 ;shot to X-coord
                sta TOY                 ;shot to Y-coord


;--------------------------------------
;
;--------------------------------------
GETBV           jsr VECTOR              ;calc shot vect


; ---------------------
; Store vector in table
; ---------------------

                lda LR                  ;bomb L/R flag
                sta BOMBLR,X            ;bomb L/R table
                lda UD                  ;bomb U/D flag
                sta BOMBUD,X            ;bomb U/D table
                lda VXINC               ;velocity X inc
                sta BXINC,X             ;Vel X table
                lda VYINC               ;velocity Y inc
                sta BYINC,X             ;Vel Y table
                rts                     ;return
