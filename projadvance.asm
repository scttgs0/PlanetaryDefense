;======================================
; Projectile advance handler
;======================================
PROADV          ldx #11                 ;do 8: 11..4
PADVLP          lda BOMACT,X            ;active?
                beq NXTPRO              ;No. skip next

                lda BOMBX,X             ;bomb X-coord
                sta PLOTX               ;plotter X
                lda BOMBY,X             ;bomb Y-coord
                sta PLOTY               ;plotter Y
                stx XHOLD               ;X-reg temporary
                jsr PLOT                ;calc plot addr

                lda (LO),Y              ;get plot byte
                and ERABIT,X            ;erase bit
                sta (LO),Y              ;replace byte
                ldx XHOLD               ;restore X
                jsr ADVIT               ;advance proj

                lda BOMBX,X             ;bomb X-coord
                cmp #160                ;off screen?
                bcs KILPRO              ;Yes. kill it

                sta PLOTX               ;plotter X
                lda BOMBY,X             ;bomb Y-coord
                cmp #96                 ;off screen?
                bcs KILPRO              ;Yes. kill it

                sta PLOTY               ;plotter Y
                jsr PLOT                ;calc plot addr

                lda PLOTBL,X            ;get plot mask
                and (LO),Y              ;chk collision
                beq PROJOK              ;No. plot it

                ldx XHOLD               ;restore X
                lda PLOTX               ;proj X-coord
                sta NEWX                ;explo X-coord
                lda PLOTY               ;proj Y-coord
                sta NEWY                ;explo Y-coord
                jsr NEWEXP              ;set off explo

KILPRO          lda #0                  ;get zero
                sta BOMACT,X            ;kill proj
                jmp NXTPRO              ;skip next

PROJOK          lda PLOTBL,X            ;plot mask
                ldx XHOLD               ;restore X
                and PROMSK,X            ;mask color
                ora (LO),Y              ;add playfield
                sta (LO),Y              ;replace byte
NXTPRO          dex                     ;next projectile
                cpx #3                  ;proj #3 yet?
                bne PADVLP              ;No. continue

                rts                     ;return
