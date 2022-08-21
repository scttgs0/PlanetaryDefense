;======================================
; Bomb initializer
;======================================
BombInit        .proc
                lda BOMBWT              ; bomb wait time
                bne _XIT                ; done? No.

                lda BOMBS               ; more bombs?
                bne _chkLive            ;   Yes. skip RTS

_XIT            rts

_chkLive        ldx #3                  ; find an available bomb?
_next1          lda BOMACT,X
                beq _gotBomb            ;   Yes

                dex                     ;   No
                bpl _next1

                rts

_gotBomb        lda #1                  ; this one is active now
                sta BOMACT,X
                dec BOMBS               ; one less bomb
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

                .randomByte
                cmp SAUCHN              ; compare chances
                bcs _noSaucer           ; put saucer? No.

                lda #1                  ;   Yes. get one
                sta SAUCER              ; enable saucer
                .randomByte
                and #$03                ; range: 0..3
                tay
                lda SaucerStartX,Y      ; saucer start X
                cmp #NIL                ; random flag?
                bne _saveSauX           ;   No. use as X

                jsr SaucerRandom        ; random X-coord

                adc #35                 ; add X offset
_saveSauX       sta FROMX               ; from X vector
                sta BOMBX,X             ; init X-coord
                lda SaucerStartY,Y      ; saucer start Y
                cmp #NIL                ; random flag?
                bne _saveSauY           ;   No. use as Y

                jsr SaucerRandom        ; random Y-coord

                adc #55                 ; add Y offset
_saveSauY       sta FROMY               ; from Y vector
                sta BOMBY,X             ; init Y-coord
                lda SaucerEndX,Y        ; saucer end X
                cmp #NIL                ; random flag?
                bne _saveEndX           ;   No. use as X

                lda #230                ; screen right
                sec                     ; offset so not to hit planet
                sbc FROMY
_saveEndX       sta zpTargetX           ; to X vector
                lda SaucerEndY,Y        ; saucer end Y
                cmp #NIL                ; random flag?
                bne _saveEndY           ;   No. use as Y

                lda FROMX               ; use X for Y
_saveEndY       sta zpTargetY           ; to Y vector
                jmp _getBombVec


; ------------
; Bomb handler
; ------------

_noSaucer       .randomByte
                bmi _bombMaxX           ; coin flip

                .randomByte
                and #1                  ; make 0..1
                tay
                lda BombLimits,Y        ; top/bottom tbl
                sta BOMBY,X             ; bomb Y-coord
_next2          .randomByte
                cmp #250                ; compare w/250
                bcs _next2              ; less than? No.

                sta BOMBX,X             ; bomb X-coord
                jmp _bombvec

_bombMaxX       .randomByte
                and #1                  ; make 0..1
                tay                     ; use as index
                lda BombLimits,Y        ; 0 or 250
                sta BOMBX,X             ; bomb X-coord
_next3          .randomByte
                cmp #250                ; compare w/250
                bcs _next3              ; less than? No.

                sta BOMBY,X             ; bomb Y-coord
_bombvec        lda BOMBX,X             ; bomb X-coord
                sta FROMX               ; shot from X
                lda BOMBY,X             ; bomb Y-coord
                sta FROMY               ; shot from Y
                lda #128                ; planet center
                sta zpTargetX           ; shot to X-coord
                sta zpTargetY           ; shot to Y-coord

_getBombVec     jsr VECTOR              ; calc shot vect


; ---------------------
; Store vector in table
; ---------------------

                lda LR                  ; bomb L/R flag
                sta BOMBLR,X            ; bomb L/R table
                lda UD                  ; bomb U/D flag
                sta BOMBUD,X            ; bomb U/D table

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
                lda BOMTIM              ; bomb timer
                rts                     ; time up? No.

                lda LIVES               ; any lives?
                bpl _regBombTraj        ;   Yes. skip next

                lda #1                  ; speed up bombs
                bne _setBombTraj        ; skip next

_regBombTraj    lda BOMTI               ; get bomb speed
_setBombTraj    sta BOMTIM              ; reset timer
                ldx #3                  ; check 4 bombs
_next1          lda BOMACT,X            ; bomb on?
                beq _nextbomb           ;   No. try next

                jsr AdvanceIt           ; advance bomb

                lda LIVES               ; any lives left?
                bpl _showbomb           ;   Yes. skip next

                jsr AdvanceIt           ;   No. move bombs
                jsr AdvanceIt           ; 4 times faster than normal
                jsr AdvanceIt


; --------------------------
; We've now got updated bomb
; coordinates for plotting!
; --------------------------

_showbomb       lda BOMBY,X             ; bomb Y-coord
                clc
                adc #2                  ; bomb center off
                sta INDX1               ; save it
                lda #0
                sta LO                  ; init low byte
                txa
                ora #>PLR0              ; mask w/address
                sta HI                  ; init high byte
                stx INDX2               ; X temp hold
                cpx #3                  ; saucer slot?
                bne _notSaucer          ;   No. skip next

                lda SAUCER              ; saucer in slot?
                bne _nextbomb           ;   Yes. skip bomb

_notSaucer      ldy BOMBLR,X            ; L/R flag
                lda #17                 ; do 17 bytes
                sta TEMP                ; set counter
                ldx BombPosStart,Y      ; start position
                ldy INDX1               ; bomb Y pos
_bombdraw       cpy #32                 ; off screen top?
                bcc _nobombdraw         ;   Yes. skip next

                cpy #223                ; screen bottom?
                bcs _nobombdraw         ;   Yes. skip next

                lda SHAPE_Bomb,X        ; bomb stamp put in PM area
                sta (LO),Y
_nobombdraw     dey                     ; PM index
                dex                     ; stamp index
                dec TEMP                ; dec count
                bne _bombdraw           ; done? No.

                .m16
                ldx INDX2               ; restore X
                lda BOMBX,X             ; bomb X-coord
                plx
                asl A                   ; *8
                asl A
                asl A
                sta SP00_X_POS,X        ; player pos
                plx
                .m8

_nextbomb       dex                     ; more bombs?
                bpl _next1              ;   yes!

                rts
                .endproc


;======================================
; Check for hits on bombs
;======================================
CheckHit        .proc
                ldx #3                  ; 4 bombs 0..3
                lda SAUCER              ; saucer enabled?
                beq _next1              ;   No. skip next

                lda #0
                sta BOMCOL              ; collision count
                lda GAMCTL              ; game over?
                bmi _noscore            ;   Yes. skip next

                lda BOMBX+3             ; saucer X-coord
                cmp #39                 ; off screen lf?
                bcc _noscore            ;   Yes. kill it

                cmp #211                ; off screen rt?
                bcs _noscore            ;   Yes. kill it

                lda BOMBY+3             ; saucer Y-coord
                cmp #19                 ; off screen up?
                bcc _noscore            ;   Yes. kill it

                cmp #231                ; off screen dn?
                bcs _noscore            ;   Yes. kill it

_next1          lda #0
                sta BOMCOL              ; collision count

                ;lda P0PF,X             ; playf collision
                ;and #$05               ; w/shot+planet
                ;beq _nobombhit         ; hit either? No.
                bra _nobombhit  ; HACK:

                inc BOMCOL              ;   Yes. inc count
                and #$04                ; hit shot?
                beq _noscore            ;   No. skip next

                lda GAMCTL              ; game over?
                bmi _noscore            ;   Yes. skip next

                lda #2                  ; 1/30th second
                sta BOMBWT              ; bomb wait time
                cpx #3                  ; saucer player?
                bne _addBombScore       ;   No. skip this

                lda SAUCER              ; saucer on?
                beq _addBombScore       ;   No. this this

                lda SAUVAL              ; saucer value
                sta SCOADD+1            ; point value
                jmp _addit              ; add to score


; -----------------------
; Add bomb value to score
; -----------------------

_addBombScore   lda BOMVL               ; bomb value low
                sta SCOADD+2            ; score inc low
                lda BOMVH               ; bomb value high
                sta SCOADD+1            ; score inc high

_addit          stx XHOLD               ; save X register
                jsr AddScore

                ldx XHOLD               ; restore X
_noscore        lda #0
                sta BOMACT,X            ; kill bomb
                ldy BOMBLR,X            ; L/R flag
                lda BOMBX,X             ; bomb X-coord
                sec
                sbc BombOffsetX,Y       ; bomb X offset
                sta NEWX                ; plotter X-coord
                lda BOMBY,X             ; bomb Y-coord
                sec
                sbc #40                 ; bomb Y offset
                lsr A                   ; 2 line res.
                sta NEWY                ; plotter Y-coord
                lda SAUCER              ; saucer?
                beq _explode            ;   No. explode it

                cpx #3                  ; bomb player?
                bne _explode            ;   Yes. explode it

                lda #0
                sta SAUCER              ; kill saucer
                jsr ClearPlayer

                lda GAMCTL              ; game over?
                bmi _nobombhit          ;   Yes. skip next

_explode        jsr ClearPlayer

                lda BOMCOL              ; collisions?
                beq _nobombhit          ;   No. skip this

                jsr NewExplosion        ; init explosion

_nobombhit      dex                     ; dec index
                bpl _next1              ; done? No.

                ;sta HITCLR             ; reset collision
                rts
                .endproc
