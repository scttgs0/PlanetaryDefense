; -------------------------------------
; Initialize Misc.
; -------------------------------------
INIT            .proc
                lda #0                  ; zero out..
                sta SCORE               ; score byte 0
                sta SCORE+1             ; score byte 1
                sta SCORE+2             ; score byte 2
                sta DEADTM              ; dead timer
                sta PAUSED              ; pause flag
                sta EXPCNT              ; expl. counter
                sta SAUCER              ; no saucer
                sta vBombLevel

                ldx #11                 ; no bombs!
_next1          sta BOMACT,X            ; deactivate
                dex                     ; next bomb
                bpl _next1              ; done? No.

                ldx #19                 ; zero score line
_next2          lda ScoreINI,X          ; get byte
                ;sta SCOLIN,X            ; put score line       HACK:
                dex                     ; next byte
                bpl _next2              ; done? No.

                lda #$01
                sta LEVEL               ; game level
                sta SATLIV              ; live satellite

                lda #4
                sta LIVES               ; number of lives

                lda #$0C                ; set explosion brightness
                ;sta COLOR2

                lda #$34                ; medium red
                ;sta PCOLR0             ; bomb 0 color
                ;sta PCOLR1             ; bomb 1 color
                ;sta PCOLR2             ; bomb 2 color

                lda #127                ; center screen X
                sta CURX                ; cursor X pos
                lda #129                ; center screen Y
                sta CURY                ; cursor Y pos

                lda #1
                sta GAMCTL              ; game control
                jsr ShowScore

                lda #$54                ; graphic-LF of planet center
                sta Playfield+1939
                lda #$15                ; graphic-RT of planet center
                sta Playfield+1940

                ;sta HITCLR             ; reset collision

                .endproc

                ;[fall-through]


;-------------------------------------
; Set up level variables
;-------------------------------------
SetLevel        .proc
                jsr ShowLevel

                ldx vBombLevel
                lda INIBOM,X            ; bombs / level
                sta BOMBS               ; bomb count
                lda INIBS,X             ; bomb speed
                sta BOMTI               ; bomb timer
                lda INISC,X             ; % chance of
                sta SAUCHN              ; saucer in level

                lda INIPC,X             ; planet color
                cmp #$FF                ; level >14?
                bne _savePC             ;   No. skip next

                .randomByte             ; random color
                and #$F0                ; mask off lum.
_savePC         sta vPlanetColor

                lda INIBVL,X            ; bomb value low
                sta BOMVL               ; save it
                lda INIBVH,X            ; bomb value hi
                sta BOMVH               ; save it
                lda INISV,X             ; saucer value
                sta SAUVAL              ; save that too
                cpx #11                 ; at level 11?
                beq _sameLevel          ;   Yes. skip next

                inc vBombLevel

_sameLevel      sed                     ; decimal mode
                lda LEVEL               ; game level #
                clc                     ; clear carry
                adc #1                  ; add one
                sta LEVEL               ; save game level
                cld                     ; clear decimal

                .endproc

                ;[fall-through]


;-------------------------------------
; Main program loop
;-------------------------------------
MainLoop        .proc
                lda PAUSED              ; game paused?
                bne MainLoop            ;   Yes. loop here

                lda GAMCTL              ; game done?
                bpl _checkCore          ;   No. check core

                lda EXPCNT              ;   Yes. expl count
                bne _checkCore          ; count done? No.

                jmp EndGame             ; The End!


; --------------------------
; Check planet core for hit!
; --------------------------

_checkCore      lda Playfield+1939      ; center LF
                and #$03                ; RT color clock
                cmp #$03                ; explosion colr?
                beq _planetDead         ;   Yes. go dead

                lda Playfield+1940      ; center RT
                and #$C0                ; LF color clock
                cmp #$C0                ; explosion colr?
                bne _planetOK           ;   No. skip next


; ---------------
; Planet is Dead!
; ---------------

_planetDead     lda #0                  ; get zero
                sta BOMBS               ; zero bombs
                sta SATLIV              ; satelite dead

                lda #NIL
                sta LIVES               ; no lives left
                sta GAMCTL              ; game control
                jsr SoundOff


; -------------
; Check console
; -------------

_planetOK       lda CONSOL              ; get console
                cmp #7                  ; any pressed?
                beq _noRestart          ;   No. skip next

                jmp Planet              ; restart game!


; -----------------
; Projectile firing
; -----------------

_noRestart      jsr BombInit            ; try new bomb

                lda SATLIV              ; satellite stat
                beq _noTrig             ; alive? No.

                lda InputFlags          ; get trigger
                and #$10
                cmp LASTRG              ; same as last VB
                beq _noTrig             ;   Yes. skip next

                sta LASTRG              ;   No. save trig
                cmp #0                  ; pressed?
                bne _noTrig             ;   No. skip next

                jsr ProjectileInit      ; start projectile
_noTrig         jsr BombAdvance         ; advance bombs

                lda EXPTIM              ; do explosion?
                bne _noExplode          ;   no!

                jsr CheckSatellite      ; satellite ok?
                jsr CheckHit            ; any hits?
                jsr HandleExplosion
                jsr ProjectileAdvance   ; advance shots

                lda SAUCER              ; saucer flag
                beq _resetTimer         ; saucer? No.

                jsr SaucerShoot         ;   Yes. let shoot

_resetTimer     lda #1                  ; get one
                sta EXPTIM              ; reset timer

_noExplode      lda BOMBS               ; # bombs to go
                bne MainLoop            ; any left? Yes.

                lda GAMCTL              ; game control
                bmi MainLoop            ; dead? Yes.

                lda BOMACT              ; bomb 0 status
                ora BOMACT+1            ; bomb 1 status
                ora BOMACT+2            ; bomb 2 status
                ora BOMACT+3            ; bomb 3 status
                beq _doSetLevel         ; any bombs? No.

                jmp MainLoop

_doSetLevel     jmp SetLevel            ; setup new level

                .endproc
