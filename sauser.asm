;======================================
; Saucer random generator 0..99
;======================================
SauserRandom    .proc
                .randomByte             ; random number
                and #$7F                ; 0..127
                cmp #100                ; compare w/100
                bcs SauserRandom        ; less than? No.

                rts
                .endproc


;======================================
; Saucer shoot routine
;======================================
SauserShoot     .proc
                .randomByte             ; random number
                cmp #6                  ; 2.3% chance?
                bcs _XIT                ; less than? No.

                ldx #7                  ; 7 = index
                lda PROACT,X            ; projectile #7
                beq _gotSauShot         ; active? No.

                dex                     ; 6 = index
                lda PROACT,X            ; projectile #6
                beq _gotSauShot         ; active? No.

_XIT            rts                     ; return, no shot

;-------------------
; Enable a saucer shot
;-------------------

_gotSauShot     lda #48                 ; PF center, Y
                sta TOY                 ; shot to Y-coord
                lda #80                 ; PF center X
                sta TOX                 ; shot to X-coord
                lda BOMBX+3             ; saucer x-coord
                sec                     ; set carry
                sbc #44                 ; PF offset
                sta FROMX               ; shot from X
                sta PROJX,X             ; X-coord table
                cmp #160                ; screen X limit
                bcs _XIT                ; on screen? No.

                lda BOMBY+3             ; saucer Y-coord
                sbc #37                 ; PF offset
                lsr A                   ; 2 scan lines
                sta FROMY               ; shot from Y
                sta PROJY,X             ; Y-coord table
                cmp #95                 ; screen Y limit
                bcs _XIT                ; on screen? No.

                lda #13                 ; shot snd time
                sta ESSCNT              ; emeny snd count

                jmp ProjectileInit._PROVEC

                .endproc
