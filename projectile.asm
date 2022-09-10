;======================================
; Projectile initializer
;======================================
PROINI          ldx #5                  ;6 projectiles
PSCAN           lda PROACT,X            ;get status
                beq GOTPRO              ;active? No.

                dex                     ;Yes. try again
                bpl PSCAN               ;done? No.

                rts                     ;return


; -----------------
; Got a projectile!
; -----------------

GOTPRO          lda #13                 ;shot snd time
                sta PSSCNT              ;player sht snd
                lda SATX                ;satellite X
                sta FROMX               ;shot from X
                sta PROJX,X             ;proj X table
                lda SATY                ;satellite Y
                sta FROMY               ;shot from Y
                sta PROJY,X             ;proj Y table
                lda CURX                ;cursor X-coord
                sec                     ;set carry
                sbc #48                 ;playfld offset
                sta TOX                 ;shot to X-coord
                lda CURY                ;cursor Y-coord
                sec                     ;set carry
                sbc #32                 ;playfld offset
                lsr A                   ;2 line res
                sta TOY                 ;shot to Y-coord


;--------------------------------------
;
;--------------------------------------
PROVEC          jsr VECTOR              ;compute vect

                lda VXINC               ;X increment
                sta PXINC,X             ;X inc table
                lda VYINC               ;Y increment
                sta PYINC,X             ;Y inc table
                lda LR                  ;L/R flag
                sta PROJLR,X            ;L/R flag table
                lda UD                  ;U/D flag
                sta PROJUD,X            ;U/D flag table
                lda #1                  ;active
                sta PROACT,X            ;proj status
RT2             rts                     ;return
