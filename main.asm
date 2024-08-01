
; -------------------------------------
; Initialize the Platform
; -------------------------------------
InitHardware    .proc
                jsr RandomSeedQuick

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcBitmapOn|mcSpriteOn,mcVideoMode240|mcTextDoubleX|mcTextDoubleY
                .frsMouse_off
                .frsCursor 0
                .frsBorder_off

                jsr InitTextPalette
                jsr SetFont

                jsr InitSID

                jsr InitGfxPalette
                jsr InitBitmap
                jsr InitSprites

                jmp Planet

                .endproc


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
                sta isSaucerActive      ; no saucer
                sta vBombLevel

                ldx #11                 ; no bombs!
_next1          sta isBombActive,X      ; deactivate

                dex                     ; next bomb
                bpl _next1              ; done? No.

                ldx #19                 ; zero score line
_next2          lda ScoreINI,X          ; get byte
                sta SCOLIN,X            ; put score line

                dex                     ; next byte
                bpl _next2              ; done? No.

                lda #$01
                sta LEVEL               ; game level
                sta isSatelliteAlive    ; live satellite

                lda #4
                sta LIVES               ; number of lives

                lda #$0C                ; set explosion brightness
                ;sta COLOR2

                lda #$34                ; medium red
                ;sta PCOLR0             ; bomb 0 color
                ;sta PCOLR1             ; bomb 1 color
                ;sta PCOLR2             ; bomb 2 color

                lda #128                ; center screen X/Y
                sta zpCursorX           ; cursor X pos
                sta zpCursorY           ; cursor Y pos

                ;!!.m16
                lda zpCursorX
                and #$FF
                asl                     ; *2
                sec
                sbc #96
                clc
                adc #32-3
                sta SPR(sprite_t.X, 0)

                lda zpCursorY
                and #$FF
                clc
                adc #32-8-3
                sta SPR(sprite_t.Y, 0)
                ;!!.m8

                lda #1
                sta GAMCTL              ; game control
                ;jsr ShowScore

                lda #$54                ; graphic-LF of planet center
                sta Playfield+1939
                lda #$15                ; graphic-RT of planet center
                sta Playfield+1940

                lda #TRUE
                sta isDirtyPlayfield

                ;sta HITCLR             ; reset collision

                .endproc

                ;[fall-through]


;-------------------------------------
; Set up level variables
;-------------------------------------
SetLevel        .proc
                jsr ShowLevel
                jsr ShowScore

                ldx vBombLevel

                lda INIBOM,X            ; bombs / level
                sta zpBombCount         ; bomb count

                lda INIBS,X             ; bomb speed into
                sta zpBombSpeedTime     ; bomb time

                lda INISC,X             ; % chance of
                sta zpSaucerChance      ; saucer in level

                lda INIPC,X             ; planet color
                cmp #$FF                ; level >14?
                bne _savePC             ;   No. skip next

                .frsRandomByte          ; random color
                and #$F0                ; mask off lum.
_savePC         sta vPlanetColor

                lda INIBVL,X            ; bomb value low
                sta zpBombValueLO       ; save it
                lda INIBVH,X            ; bomb value hi
                sta zpBombValueHI       ; save it
                lda INISV,X             ; saucer value
                sta zpSaucerValue       ; save that too

                cpx #11                 ; at level 11?
                beq _sameLevel          ;   Yes. skip next

                inc vBombLevel

_sameLevel      sed                     ; decimal mode
                lda LEVEL               ; game level #
                clc
                adc #1
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

                lda isDirtyPlayfield
                beq _1

                jsr BlitPlayfield

                lda #FALSE
                sta isDirtyPlayfield

_1              lda GAMCTL              ; game done?
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

_planetDead     lda #0
                sta zpBombCount         ; zero bombs
                sta isSatelliteAlive    ; satelite dead

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

                lda isSatelliteAlive    ; satellite alive?
                beq _noTrig             ;   No.

                lda InputFlags          ; get trigger
                and #$10
                cmp zpLastTrigger       ; same as last VB
                beq _noTrig             ;   Yes. skip next

                sta zpLastTrigger       ;   No. save trig
                cmp #0                  ; pressed?
                bne _noTrig             ;   No. skip next

                jsr ProjectileInit      ; start projectile

_noTrig         jsr BombAdvance         ; advance bombs

                lda zpExplosionTimer    ; do explosion?
                bne _noExplode          ;   no!

                jsr CheckSatellite      ; satellite ok?
                jsr CheckHit            ; any hits?
                jsr HandleExplosion
                jsr ProjectileAdvance   ; advance shots

                lda isSaucerActive      ; saucer active?
                beq _resetTimer         ;   No

                jsr SaucerShoot         ;   Yes. let shoot

_resetTimer     lda #1
                sta zpExplosionTimer    ; reset timer

_noExplode      lda zpBombCount         ; # bombs to go
                bne MainLoop            ; any left? Yes.

                lda GAMCTL              ; game control
                bpl _chkBombs           ; dead? No.

                jmp MainLoop

_chkBombs       lda isBombActive        ; bomb 0 status
                ora isBombActive+1      ; bomb 1 status
                ora isBombActive+2      ; bomb 2 status
                ora isBombActive+3      ; bomb 3 status
                beq _doSetLevel         ; any bombs? No.

                jmp MainLoop

_doSetLevel     jmp SetLevel            ; setup new level

                .endproc
