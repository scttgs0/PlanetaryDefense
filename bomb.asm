;======================================
; Bomb initializer
;======================================
BombInit        .proc
                lda BOMBWT              ; bomb wait time
                bne _XIT                ; done? No.

                lda BOMBS               ; more bombs?
                bne _chkLive            ; Yes. skip RTS

_XIT            rts

_chkLive        ldx #3                  ; find..
_next1          lda BOMACT,X            ; an available..
                beq _gotBomb            ; bomb? Yes.

                dex                     ; No. dec index
                bpl _next1              ; done? No.

                rts

_gotBomb        lda #1                  ; this one is..
                sta BOMACT,X            ; active now
                dec BOMBS               ; one less bomb
                lda #0                  ; zero out all..
                sta BXHOLD,X            ; vector X hold
                sta BYHOLD,X            ; vector Y hold
                lda GAMCTL              ; game control
                bmi _noSauser           ; saucer possible?


; --------------
; Saucer handler
; --------------

                cpx #3                  ; Yes. bomb #3?
                bne _noSauser           ; No. skip next

                lda RANDOM              ; random number
                cmp SAUCHN              ; compare chances
                bcs _noSauser           ; put saucer? No.

                lda #1                  ; Yes. get one
                sta SAUCER              ; enable saucer
                lda RANDOM              ; random number
                and #$03                ; range: 0..3
                tay                     ; use as index
                lda STARTX,Y            ; saucer start X
                cmp #$FF                ; random flag?
                bne _saveSauX           ; No. use as X

                jsr SauserRandom        ; random X-coord

                adc #35                 ; add X offset
_saveSauX       sta FROMX               ; from X vector
                sta BOMBX,X             ; init X-coord
                lda STARTY,Y            ; saucer start Y
                cmp #$FF                ; random flag?
                bne _saveSauY           ; No. use as Y

                jsr SauserRandom        ; random Y-coord

                adc #55                 ; add Y offset
_saveSauY       sta FROMY               ; from Y vector
                sta BOMBY,X             ; init Y-coord
                lda ENDX,Y              ; saucer end X
                cmp #$FF                ; random flag?
                bne _saveEndX           ; No. use as X

                lda #230                ; screen right
                sec                     ; offset so not
                sbc FROMY               ; to hit planet
_saveEndX       sta TOX                 ; to X vector
                lda ENDY,Y              ; saucer end Y
                cmp #$FF                ; random flag?
                bne _saveEndY           ; No. use as Y

                lda FROMX               ; use X for Y
_saveEndY       sta TOY                 ; to Y vector
                jmp _getBombVec         ; skip next


; ------------
; Bomb handler
; ------------

_noSauser       lda RANDOM              ; random number
                bmi _bombMaxX           ; coin flip

                lda RANDOM              ; random number
                and #1                  ; make 0..1
                tay                     ; use as index
                lda BMAXS,Y             ; top/bottom tbl
                sta BOMBY,X             ; bomb Y-coord
_next2          lda RANDOM              ; random number
                cmp #250                ; compare w/250
                bcs _next2              ; less than? No.

                sta BOMBX,X             ; bomb X-coord
                jmp _bombvec            ; skip next

_bombMaxX       lda RANDOM              ; random number
                and #1                  ; make 0..1
                tay                     ; use as index
                lda BMAXS,Y             ; 0 or 250
                sta BOMBX,X             ; bomb X-coord
_next3          lda RANDOM              ; random number
                cmp #250                ; compare w/250
                bcs _next3              ; less than? No.

                sta BOMBY,X             ; bomb Y-coord
_bombvec        lda BOMBX,X             ; bomb X-coord
                sta FROMX               ; shot from X
                lda BOMBY,X             ; bomb Y-coord
                sta FROMY               ; shot from Y
                lda #128                ; planet center
                sta TOX                 ; shot to X-coord
                sta TOY                 ; shot to Y-coord

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
                bpl _regBombTraj        ; Yes. skip next

                lda #1                  ; speed up bombs
                bne _setBombTraj        ; skip next

_regBombTraj    lda BOMTI               ; get bomb speed
_setBombTraj    sta BOMTIM              ; reset timer
                ldx #3                  ; check 4 bombs
_next1          lda BOMACT,X            ; bomb on?
                beq _nextbomb           ; No. try next

                jsr AdvanceIt           ; advance bomb

                lda LIVES               ; any lives left?
                bpl _showbomb           ; Yes. skip next

                jsr AdvanceIt           ; No. move bombs
                jsr AdvanceIt           ; 4 times faster
                jsr AdvanceIt           ; than normal


; --------------------------
; We've now got updated bomb
; coordinates for plotting!
; --------------------------

_showbomb       lda BOMBY,X             ; bomb Y-coord
                clc                     ; clear carry
                adc #2                  ; bomb center off
                sta INDX1               ; save it
                lda #0                  ; get zero
                sta LO                  ; init low byte
                txa                     ; index to Acc
                ora #>PLR0              ; mask w/address
                sta HI                  ; init high byte
                stx INDX2               ; X temp hold
                cpx #3                  ; saucer slot?
                bne _notSauser          ; No. skip next

                lda SAUCER              ; saucer in slot?
                bne _nextbomb           ; Yes. skip bomb

_notSauser      ldy BOMBLR,X            ; L/R flag
                lda #17                 ; do 17 bytes
                sta TEMP                ; set counter
                ldx BPSTRT,Y            ; start position
                ldy INDX1               ; bomb Y pos
_bombdraw       cpy #32                 ; off screen top?
                bcc _nobombdraw         ; Yes. skip next

                cpy #223                ; screen bottom?
                bcs _nobombdraw         ; Yes. skip next

                lda BOMPIC,X            ; bomb picture
                sta (LO),Y              ; put in PM area
_nobombdraw     dey                     ; PM index
                dex                     ; picture index
                dec TEMP                ; dec count
                bne _bombdraw           ; done? No.

                ldx INDX2               ; restore X
                lda BOMBX,X             ; bomb X-coord
                sta HPOSP0,X            ; player pos
_nextbomb       dex                     ; more bombs?
                bpl _next1              ; yes!

                rts
                .endproc


;======================================
; Check for hits on bombs
;======================================
CheckHit        .proc
                ldx #3                  ; 4 bombs 0..3
                lda SAUCER              ; saucer enabled?
                beq _next1              ; No. skip next

                lda #0                  ; get zero
                sta BOMCOL              ; collision count
                lda GAMCTL              ; game over?
                bmi _noscore            ; Yes. skip next

                lda BOMBX+3             ; saucer X-coord
                cmp #39                 ; off screen lf?
                bcc _noscore            ; Yes. kill it

                cmp #211                ; off screen rt?
                bcs _noscore            ; Yes. kill it

                lda BOMBY+3             ; saucer Y-coord
                cmp #19                 ; off screen up?
                bcc _noscore            ; Yes. kill it

                cmp #231                ; off screen dn?
                bcs _noscore            ; Yes. kill it

_next1          lda #0                  ; get zero
                sta BOMCOL              ; collision count
                lda P0PF,X              ; playf collision
                and #$05                ; w/shot+planet
                beq _nobombhit          ; hit either? No.

                inc BOMCOL              ; Yes. inc count
                and #$04                ; hit shot?
                beq _noscore            ; No. skip next

                lda GAMCTL              ; game over?
                bmi _noscore            ; Yes. skip next

                lda #2                  ; 1/30th second
                sta BOMBWT              ; bomb wait time
                cpx #3                  ; saucer player?
                bne _addBombScore       ; No. skip this

                lda SAUCER              ; saucer on?
                beq _addBombScore       ; No. this this

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
_noscore        lda #0                  ; get zero
                sta BOMACT,X            ; kill bomb
                ldy BOMBLR,X            ; L/R flag
                lda BOMBX,X             ; bomb X-coord
                sec                     ; set carry
                sbc BXOF,Y              ; bomb X offset
                sta NEWX                ; plotter X-coord
                lda BOMBY,X             ; bomb Y-coord
                sec                     ; set carry
                sbc #40                 ; bomb Y offset
                lsr A                   ; 2 line res.
                sta NEWY                ; plotter Y-coord
                lda SAUCER              ; saucer?
                beq _explode            ; No. explode it

                cpx #3                  ; bomb player?
                bne _explode            ; Yes. explode it

                lda #0                  ; get zero
                sta SAUCER              ; kill saucer
                jsr ClearPlayer

                lda GAMCTL              ; game over?
                bmi _nobombhit          ; Yes. skip next

_explode        jsr ClearPlayer

                lda BOMCOL              ; collisions?
                beq _nobombhit          ; No. skip this

                jsr NewExplosion        ; init explosion

_nobombhit      dex                     ; dec index
                bpl _next1              ; done? No.

                sta HITCLR              ; reset collision
                rts
                .endproc
