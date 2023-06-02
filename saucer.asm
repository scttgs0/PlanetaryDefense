
;======================================
; Saucer random generator 0..99
;======================================
SaucerRandom    .proc
_tryAgain       .randomByte             ; random number
                and #$7F                ; 0..127
                cmp #100                ; compare w/100
                bcs _tryAgain           ; less than? No.

                rts
                .endproc


;======================================
; Saucer shoot routine
;======================================
SaucerShoot     .proc
                .randomByte             ; random number
                cmp #6                  ; 2.3% chance?
                bcs _XIT                ; less than? No.

                ldx #7                  ; 7 = index
                lda isProjActive,X      ; projectile #7
                beq _gotSauShot         ; active? No.

                dex                     ; 6 = index
                lda isProjActive,X      ; projectile #6
                beq _gotSauShot         ; active? No.

_XIT            rts                     ; return, no shot


;-------------------
; Enable a saucer shot
;-------------------

_gotSauShot     lda #48                 ; PF center, Y
                sta zpTargetY           ; shot to Y-coord
                lda #80                 ; PF center X
                sta zpTargetX           ; shot to X-coord
                lda BombX+3             ; saucer x-coord
                sec
                sbc #44                 ; PF offset
                sta zpFromX             ; shot from X
                sta ProjX,X             ; X-coord table
                cmp #160                ; screen X limit
                bcs _XIT                ; on screen? No.

                lda BombY+3             ; saucer Y-coord
                sbc #37                 ; PF offset
                lsr                     ; 2 scan lines
                sta zpFromY             ; shot from Y
                sta ProjY,X             ; Y-coord table
                cmp #95                 ; screen Y limit
                bcs _XIT                ; on screen? No.

                lda #13                 ; shot snd time
                sta ESSCNT              ; emeny snd count

                jmp ProjectileInit._PROVEC

                .endproc
