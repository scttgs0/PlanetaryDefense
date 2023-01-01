; ----------------
; Initialize Misc.
; ----------------

INIT            lda #0                  ;zero out..
                sta SCORE               ;score byte 0
                sta SCORE+1             ;score byte 1
                sta SCORE+2             ;score byte 2
                sta DEADTM              ;dead timer
                sta PAUSED              ;pause flag
                sta EXPCNT              ;expl. counter
                sta SAUCER              ;no saucer
                sta BLEVEL              ;bomb level
                ldx #11                 ;no bombs!
CLRACT          sta BOMACT,X            ;deactivate
                dex                     ;next bomb
                bpl CLRACT              ;done? No.

                ldx #19                 ;zero score line
INISLN          lda SCOINI,X            ;get byte
                sta SCOLIN,X            ;put score line
                dex                     ;next byte
                bpl INISLN              ;done? No.

                lda #$01                ;get one
                sta LEVEL               ;game level
                sta SATLIV              ;live satellite
                lda #4                  ;get 4
                sta LIVES               ;number of lives
                lda #$0C                ;set explosion
                sta COLOR0+2            ;brightness
                lda #$34                ;medium red
                sta PCOLR0              ;bomb 0 color
                sta PCOLR0+1            ;bomb 1 color
                sta PCOLR0+2            ;bomb 2 color
                lda #127                ;center screen X
                sta CURX                ;cursor X pos
                lda #129                ;center screen Y
                sta CURY                ;cursor Y pos
                lda #1                  ;get one
                sta GAMCTL              ;game control
                jsr SHOSCO              ;display score

                lda #$54                ;graphic-LF of
                sta SCRN+1939           ;planet center
                lda #$15                ;graphic-RT of
                sta SCRN+1940           ;planet center
                sta HITCLR              ;reset collision


;--------------------------------------
; Set up level variables
;--------------------------------------
SETLVL          jsr SHOLVL              ;show level

                ldx BLEVEL              ;bomb level
                lda INIBOM,X            ;bombs / level
                sta BOMBS               ;bomb count
                lda INIBS,X             ;bomb speed
                sta BOMTI               ;bomb timer
                lda INISC,X             ;% chance of
                sta SAUCHN              ;saucer in level
                lda INIPC,X             ;planet color
                cmp #$FF                ;level >14?
                bne SAVEPC              ;No. skip next

                lda RANDOM              ;random color
                and #$F0                ;mask off lum.
SAVEPC          sta PLNCOL              ;planet color
                lda INIBVL,X            ;bomb value low
                sta BOMVL               ;save it
                lda INIBVH,X            ;bomb value hi
                sta BOMVH               ;save it
                lda INISV,X             ;saucer value
                sta SAUVAL              ;save that too
                cpx #11                 ;at level 11?
                beq SAMLVL              ;Yes. skip next

                inc BLEVEL              ;inc bomb level
SAMLVL          sed                     ;decimal mode
                lda LEVEL               ;game level #
                clc                     ;clear carry
                adc #1                  ;add one
                sta LEVEL               ;save game level
                cld                     ;clear decimal


;--------------------------------------
; Main program loop
;--------------------------------------
LOOP            lda PAUSED              ;game paused?
                bne LOOP                ;Yes. loop here

                lda #0                  ;get zero
                sta ATRACT              ;attract mode
                lda GAMCTL              ;game done?
                bpl CKCORE              ;No. check core

                lda EXPCNT              ;Yes. expl count
                bne CKCORE              ;count done? No.

                jmp ENDGAM              ;The End!


; --------------------------
; Check planet core for hit!
; --------------------------

CKCORE          lda SCRN+1939           ;center LF
                and #$03                ;RT color clock
                cmp #$03                ;explosion colr?
                beq PLDEAD              ;Yes. go dead

                lda SCRN+1940           ;center RT
                and #$C0                ;LF color clock
                cmp #$C0                ;explosion colr?
                bne PLANOK              ;No. skip next


; ---------------
; Planet is Dead!
; ---------------

PLDEAD          lda #0                  ;get zero
                sta BOMBS               ;zero bombs
                sta SATLIV              ;satelite dead
                lda #$FF                ;get #$FF
                sta LIVES               ;no lives left
                sta GAMCTL              ;game control
                jsr SNDOFF              ;no sound


; -------------
; Check console
; -------------

PLANOK          lda CONSOL              ;get console
                cmp #7                  ;any pressed?
                beq NORST               ;No. skip next

                jmp PLANET              ;restart game!


; -----------------
; Projectile firing
; -----------------

NORST           jsr BOMINI              ;try new bomb

                lda SATLIV              ;satellite stat
                beq NOTRIG              ;alive? No.

                lda STRIG0              ;get trigger
                cmp LASTRG              ;same as last VB
                beq NOTRIG              ;Yes. skip next

                sta LASTRG              ;No. save trig
                cmp #0                  ;pressed?
                bne NOTRIG              ;No. skip next

                jsr PROINI              ;strt projectile
NOTRIG          jsr BOMADV              ;advance bombs

                lda EXPTIM              ;do explosion?
                bne NOEXP               ;no!

                jsr CHKSAT              ;satellite ok?
                jsr CHKHIT              ;any hits?
                jsr EXPHAN              ;handle expl.
                jsr PROADV              ;advance shots

                lda SAUCER              ;saucer flag
                beq RESTIM              ;saucer? No.

                jsr SSHOOT              ;Yes. let shoot

RESTIM          lda #1                  ;get one
                sta EXPTIM              ;reset timer
NOEXP           lda BOMBS               ;# bombs to go
                bne LOOP                ;any left? Yes.

                lda GAMCTL              ;game control
                bmi LOOP                ;dead? Yes.

                lda BOMACT              ;bomb 0 status
                ora BOMACT+1            ;bomb 1 status
                ora BOMACT+2            ;bomb 2 status
                ora BOMACT+3            ;bomb 3 status
                beq JSL                 ;any bombs? No.

                jmp LOOP                ;Yes. continue

JSL             jmp SETLVL              ;setup new level
