;======================================
; Saucer random generator 0..99
;======================================
SAURND          lda RANDOM              ;random number
                and #$7F                ;0..127
                cmp #100                ;compare w/100
                bcs SAURND              ;less than? No.

                rts                     ;return


;======================================
; Saucer shoot routine
;======================================
SSHOOT          lda RANDOM              ;random number
                cmp #6                  ;2.3% chance?
                bcs NOSS                ;less than? No.

                ldx #7                  ;7 = index
                lda PROACT,X            ;projectile #7
                beq GOTSS               ;active? No.

                dex                     ;6 = index
                lda PROACT,X            ;projectile #6
                beq GOTSS               ;active? No.

NOSS            rts                     ;return, no shot


; --------------------
; Enable a saucer shot
; --------------------

GOTSS           lda #48                 ;PF center, Y
                sta TOY                 ;shot to Y-coord
                lda #80                 ;PF center X
                sta TOX                 ;shot to X-coord
                lda BOMBX+3             ;saucer x-coord
                sec                     ;set carry
                sbc #44                 ;PF offset
                sta FROMX               ;shot from X
                sta PROJX,X             ;X-coord table
                cmp #160                ;screen X limit
                bcs NOSS                ;on screen? No.

                lda BOMBY+3             ;saucer Y-coord
                sbc #37                 ;PF offset
                lsr A                   ;2 scan lines
                sta FROMY               ;shot from Y
                sta PROJY,X             ;Y-coord table
                cmp #95                 ;screen Y limit
                bcs NOSS                ;on screen? No.

                lda #13                 ;shot snd time
                sta ESSCNT              ;emeny snd count
                jmp PROVEC              ;continue
