
;======================================
; Bomb initializer
;======================================
BombInit        .proc
                lda zpBombWait          ; bomb wait time done?
                bne _XIT                ;   No

                lda zpBombCount         ; more bombs?
                bne _chkLive            ;   Yes

_XIT            rts

_chkLive        ldx #3                  ; find an available bomb?
_next1          lda isBombActive,X
                beq _gotBomb            ;   Yes

                dex                     ;   No
                bpl _next1

                rts

_gotBomb        lda #TRUE               ; this one is active now
                sta isBombActive,X
                dec zpBombCount         ; one less bomb

                lda #0                  ; zero out all..
                sta BXHOLD,X            ;   vector X hold
                sta BYHOLD,X            ;   vector Y hold

                lda GAMCTL              ; game control
                bmi _noSaucer           ; saucer possible?


; --------------
; Saucer handler
; --------------

                cpx #3                  ;   Yes. bomb #3?
                bne _noSaucer           ;   No. skip next

                .frsRandomByte
                cmp zpSaucerChance      ; compare chance to place saucer?
                bcs _noSaucer           ;   No

                lda #TRUE               ;   Yes. enable saucer
                sta isSaucerActive

                .frsRandomByte
                and #$03                ; range: 0..3
                tay
                lda SaucerStartX,Y      ; saucer start X
                cmp #NIL                ; random flag?
                bne _saveSauX           ;   No. use as X

                jsr SaucerRandom        ; random X-coord

                clc
                adc #35                 ; add X offset
_saveSauX       sta zpFromX             ; from X vector
                sta BombX,X             ; init X-coord

                lda SaucerStartY,Y      ; saucer start Y
                cmp #NIL                ; random flag?
                bne _saveSauY           ;   No. use as Y

                jsr SaucerRandom        ; random Y-coord

                clc
                adc #55                 ; add Y offset
_saveSauY       sta zpFromY             ; from Y vector
                sta BombY,X             ; init Y-coord

                lda SaucerEndX,Y        ; saucer end X
                cmp #NIL                ; random flag?
                bne _saveEndX           ;   No. use as X

                lda #230                ; screen right
                sec                     ; offset so not to hit planet
                sbc zpFromY
_saveEndX       sta zpTargetX           ; to X vector
                lda SaucerEndY,Y        ; saucer end Y
                cmp #NIL                ; random flag?
                bne _saveEndY           ;   No. use as Y

                lda zpFromX             ; use X for Y
_saveEndY       sta zpTargetY           ; to Y vector
                bra _getBombVec


; ------------
; Bomb handler
; ------------

_noSaucer       .frsRandomByte
                bmi _bombMaxX           ; coin flip

;   randX, maxY :: x=0..250, y=0|250
                .frsRandomByte
                and #1                  ; make 0..1
                tay
                lda BombLimits,Y        ; top/bottom tbl
                sta BombY,X             ; bomb Y-coord

_next2          .frsRandomByte
                cmp #250                ; compare w/250
                bcs _next2              ; less than? No.

                sta BombX,X             ; bomb X-coord
                bra _bombvec

;   maxX, randY :: x=0|250, y=0..250
_bombMaxX       .frsRandomByte
                and #1                  ; make 0..1
                tay                     ; use as index
                lda BombLimits,Y        ; 0 or 250
                sta BombX,X             ; bomb X-coord

_next3          .frsRandomByte
                cmp #250                ; compare w/250
                bcs _next3              ; less than? No.

                sta BombY,X             ; bomb Y-coord

_bombvec        lda BombX,X             ; bomb X-coord
                sta zpFromX             ; shot from X
                lda BombY,X             ; bomb Y-coord
                sta zpFromY             ; shot from Y

                lda #128                ; planet center
                sta zpTargetX           ; shot to X-coord
                sta zpTargetY           ; shot to Y-coord

_getBombVec     jsr CalcVector          ; calc shot vect


; ---------------------
; Store vector in table
; ---------------------

                lda LR                  ; bomb L/R flag
                sta lrBomb,X            ; bomb L/R table
                lda UD                  ; bomb U/D flag
                sta udBomb,X            ; bomb U/D table

                lda VXINC               ; velocity X inc
                sta BXINC,X             ; Vel X table
                lda VYINC               ; velocity Y inc
                sta BYINC,X             ; Vel Y table
                rts
                .endproc


;======================================
; Bomb advance handler
;======================================
BombAdvance     .proc
                lda zpBombTimer         ; bomb timer
                bne _XIT                ; time up? No.

                lda LIVES               ; any lives?
                bpl _regBombTraj        ;   Yes

                lda #1                  ; speed up bombs
                bne _setBombTraj        ; skip next

_regBombTraj    lda zpBombSpeedTime     ; get bomb speed
_setBombTraj    sta zpBombTimer         ; reset timer

                ldx #3                  ; check 4 bombs
_next1          lda isBombActive,X      ; bomb on?
                beq _nextbomb           ;   No. try next

                jsr AdvanceIt           ; advance bomb

                lda LIVES               ; any lives left?
                bpl _showbomb           ;   Yes. skip next

                jsr AdvanceIt           ;   No. move bombs 4 times
                jsr AdvanceIt           ;   faster than normal
                jsr AdvanceIt


; --------------------------
; We've now got updated bomb
; coordinates for plotting!
; --------------------------

_showbomb       lda BombY,X             ; bomb Y-coord
                clc
                adc #2                  ; bomb center off
                sta INDX1               ; save it
                stz INDX1+1

                stx INDX2               ; X temp hold
                stz INDX2+1

                cpx #3                  ; saucer slot?
                bne _notSaucer          ;   No. skip next

                lda isSaucerActive      ; saucer active?
                bne _nextbomb           ;   Yes. skip bomb

_notSaucer      lda lrBomb,X            ; L/R flag
                asl                     ; *4
                asl
                clc
                adc #$0C
                sta SPR(sprite_t.ADDR+1, 4)

                ;!!.m16
;   set y position
                lda INDX2               ; restore X
                asl                     ; *8
                asl
                asl
                tax

                lda INDX1               ; bomb Y-coord
                and #$FF
                clc
                adc #32-8
                ;!!.frsSpriteSetY_ix
                ;!!sta SPR(sprite_t.Y, 4),X           ; player pos

;   set x position
                ldx INDX2               ; restore X
                lda BombX,X             ; bomb X-coord
                and #$FF
                ;asl                    ; *2
                clc
                adc #32+32
                phx
                pha
                txa
                and #$FF
                asl                     ; *8
                asl
                asl
                tax
                pla
                ;!!.frsSpriteSetX_ix
                ;!!sta SPR(sprite_t.X, 4),X            ; player pos
                plx
                ;!!.m8

_nextbomb       dex                     ; more bombs?
                bpl _next1              ;   yes!

_XIT            rts
                .endproc


;======================================
; Check for hits on bombs
;======================================
CheckHit        .proc
                ldx #3                  ; 4 bombs 0..3
                lda isSaucerActive      ; saucer active?
                beq _next1              ;   No. skip next

                lda #0
                sta zpBombCollCnt       ; collision count

                lda GAMCTL              ; game over?
                bmi _noscore            ;   Yes. skip next

                lda BombX+3             ; saucer X-coord
                cmp #39                 ; off screen lf?
                bcc _noscore            ;   Yes. kill it

                cmp #211                ; off screen rt?
                bcs _noscore            ;   Yes. kill it

                lda BombY+3             ; saucer Y-coord
                cmp #19                 ; off screen up?
                bcc _noscore            ;   Yes. kill it

                cmp #231                ; off screen dn?
                bcs _noscore            ;   Yes. kill it

_next1          lda #0
                sta zpBombCollCnt       ; clear collision count

                ;lda P0PF,X             ; playf collision
                ;and #$05               ; w/shot+planet
                ;beq _nobombhit         ; hit either? No.
                bra _nobombhit  ; HACK:

                inc zpBombCollCnt       ;   Yes. inc count
                and #$04                ; hit shot?
                beq _noscore            ;   No. skip next

                lda GAMCTL              ; game over?
                bmi _noscore            ;   Yes. skip next

                lda #2                  ; 1/30th second
                sta zpBombWait          ; bomb wait time

                cpx #3                  ; saucer player?
                bne _addBombScore       ;   No. skip this

                lda isSaucerActive      ; saucer active?
                beq _addBombScore       ;   No. skip this

                lda zpSaucerValue       ; saucer value
                sta SCOADD+1            ; point value
                bra _addit              ; add to score


; -----------------------
; Add bomb value to score
; -----------------------

_addBombScore   lda zpBombValueLO       ; bomb value low
                sta SCOADD+2            ; score inc low
                lda zpBombValueHI       ; bomb value high
                sta SCOADD+1            ; score inc high

_addit          stx XHOLD               ; save X register
                jsr AddScore

                ldx XHOLD               ; restore X
_noscore        lda #FALSE
                sta isBombActive,X      ; kill bomb

                ldy lrBomb,X            ; L/R flag
                lda BombX,X             ; bomb X-coord
                sec
                sbc BombOffsetX,Y       ; bomb X offset
                sta NEWX                ; plotter X-coord

                lda BombY,X             ; bomb Y-coord
                sec
                sbc #40                 ; bomb Y offset
                lsr                     ; 2 line res.
                sta NEWY                ; plotter Y-coord

                lda isSaucerActive      ; saucer active?
                beq _explode            ;   No. explode it

                cpx #3                  ; bomb player?
                bne _explode            ;   Yes. explode it

                lda #FALSE
                sta isSaucerActive      ; kill saucer
                jsr ClearPlayer

                lda GAMCTL              ; game over?
                bmi _nobombhit          ;   Yes. skip next

_explode        jsr ClearPlayer

                lda zpBombCollCnt       ; collisions?
                beq _nobombhit          ;   No. skip this

                jsr NewExplosion        ; init explosion

_nobombhit      dex                     ; dec index
                bpl _next1              ; done? No.

                ;sta HITCLR             ; reset collision
                rts
                .endproc
