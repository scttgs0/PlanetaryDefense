
; SPDX-FileName: interrupt.asm
; SPDX-FileCopyrightText: Copyright 2025, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later

;--------------------------------------
; Intro Display List
;--------------------------------------

TitleDL         ;!! .byte AEMPTY8,AEMPTY8,AEMPTY8
                ; .byte AEMPTY8,AEMPTY8,AEMPTY8
                ; .byte AEMPTY8,AEMPTY8,AEMPTY8

                ; .byte $06+ALMS
                ;    .addr MAGMSG

                ; .byte AEMPTY8
                ; .byte 7

                ; .byte AEMPTY8
                ; .byte 6

                ; .byte AEMPTY2
                ; .byte 6

                ; .byte AEMPTY8,AEMPTY8
                ; .byte 6

                ; .byte AEMPTY3
                ; .byte 6

                ; .byte AEMPTY5
                ; .byte 6

                ; .byte AVB+AJMP
                ;    .addr TitleDL

;--------------------------------------
; Game Display List
;--------------------------------------

GameDL          ;!! .byte AEMPTY8,AEMPTY8

                ; .byte $06+ALMS
                ;    .addr SCOLIN

                ; .byte $0D+ALMS
                ;    .addr Playfield
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI,$0D+ADLI
                ; .byte $0D+ADLI,$0D+ADLI

                ; .byte AVB+AJMP
                ;    .addr GameDL


;--------------------------------------
; Intro Message Text
;--------------------------------------

MagMsg          .text "  ANALOG COMPUTING  "
TitleMsg        ;.text " PLANETARY  DEFENSE "   ; double-sized
;   top
                .byte $20,$20,$20
                .byte $CE,$CF,$C6,$C7,$B6,$B7,$CA,$CB,$BE,$BF,$DA,$DB,$B6,$B7,$D2,$D3,$DE,$DF
                .byte $20,$20
                .byte $BA,$BB,$BE,$BF,$C2,$C3,$BE,$BF,$CA,$CB,$D6,$D7,$BE,$BF
                .byte $20,$20,$20
;   bottom
                .byte $20,$20,$20
                .byte $D0,$D1,$C8,$C9,$B8,$B9,$CC,$CD,$C0,$C1,$DC,$DD,$B8,$B9,$D4,$D5,$E0,$E1
                .byte $20,$20
                .byte $BC,$BD,$C0,$C1,$C4,$C5,$C0,$C1,$CC,$CD,$D8,$D9,$C0,$C1
                .byte $20,$20,$20

AuthorMsg       .text " BY CHARLES BACHAND "
                .text "   AND TOM HUDSON   "
StartMsg        .text "  MOUSE ",$B4,$B4,$B4," SELECT  "
                .text "  JOYSTICK ",$B4," START  "
                .text "  OR PRESS TRIGGER  "


;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Main IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqMain         .proc
                pha
                phx
                phy

                cld

; - - - - - - - - - - - - - - - - - - -
;   switch to system map
                lda IOPAGE_CTRL
                pha                     ; preserve
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ;!! lda INT_PENDING_REG1
                ;!! bit #INT01_VIA1
                ;!! beq _1

                ;!! lda INT_PENDING_REG1
                ;!! sta INT_PENDING_REG1

                ;!! jsr KeyboardHandler

_1              lda INT_PENDING_REG0
                bit #INT00_SOF
                beq _2

                eor #INT00_SOF
                sta INT_PENDING_REG0

                jsr irqVBIHandler

_2              lda INT_PENDING_REG0
                bit #INT00_SOL
                beq _XIT

                eor #INT00_SOL
                sta INT_PENDING_REG0

                jsr DliHandler

; - - - - - - - - - - - - - - - - - - -
_XIT            pla                     ; restore
                sta IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ply
                plx
                pla

irqMain_END     ;jmp IRQ_PRIOR
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Key Notifications
;--------------------------------------
;   ESC         $01/$81  press/release
;   R-Ctrl      $1D/$9D
;   Space       $39/$B9
;   F2          $3C/$BC
;   F3          $3D/$BD
;   F4          $3E/$BE
;   Up          $48/$C8
;   Left        $4B/$CB
;   Right       $4D/$CD
;   Down        $50/$D0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KeyboardHandler .proc
KEY_F2          = $3C                   ; Option
KEY_F3          = $3D                   ; Select
KEY_F4          = $3E                   ; Start
KEY_UP          = $48                   ; joystick alternative
KEY_LEFT        = $4B
KEY_RIGHT       = $4D
KEY_DOWN        = $50
KEY_CTRL        = $1D                   ; fire button
;---

                pha
                phx
                phy

                lda PS2_KEYBD_IN
                pha
                sta KEYCHAR

                and #$80                ; is it a key release?
                bne _1r                 ;   yes

_1              pla                     ;   no
                pha
                cmp #KEY_F2
                bne _2

                lda CONSOL
                eor #$04
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #joyUP
                beq _4a

                eor #joyUP
                ora #joyDOWN            ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #joyUP
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #joyDOWN
                beq _5a

                eor #joyDOWN
                ora #joyUP              ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #joyDOWN
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #joyLEFT
                beq _6a

                eor #joyLEFT
                ora #joyRIGHT           ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #joyLEFT
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #joyRIGHT
                beq _7a

                eor #joyRIGHT
                ora #joyLEFT            ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #joyRIGHT
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #joyButton0
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #joyButton0
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     stz KEYCHAR
                pla

_XIT            ply
                plx
                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Display list interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DliHandler      .proc
                pha
                phx

;   preserve zpSource
                ldx #3
_nextA          lda zpSource,X
                sta saveSource,X
                dex
                bpl _nextA

                inc DLICNT              ; inc counter
                lda DLICNT              ; get counter
                and #$07                ; only 3 bits
                asl                     ; *2

                tax                     ; use as index
                ;!!.m16
                ;!!lda _BrightnessBase,X   ; planet brightness
                sta zpSource
                stz zpSource+2
                stz zpSource+3
                ;!!.m8

                lda vPlanetColor
                lsr                     ; /4 :: ignore luminance ( val / 16 * 4 == /4 )
                lsr
                ;!!sta _temp1

                lda zpSource
                clc
                ;!!adc _temp1
                sta zpSource

                ;!!.setbank $AF
                ldy #3
_next1          lda (zpSource),Y
                sta GRPH_LUT0_PTR+4,Y   ; color planet  (COLPF0)
                dey
                bpl _next1

                ldx #3
_next2          ;!!lda _Color8C,X          ; bright blue
                sta GRPH_LUT0_PTR+8,X   ; shot color    (COLPF1)
                dex
                bpl _next2

                ;!!.setbank $00

;   restore zpSource
                ldx #3
_nextB          lda saveSource,X
                sta zpSource,X
                dex
                bpl _nextB

                plx
                pla
                rts

;-------------------------------------

_Color8C        .dword $00b0acfc

_BrightnessBase .addr Palette+$068,Palette+$084
                .addr Palette+$0C4,Palette+$104
                .addr Palette+$144,Palette+$104
                .addr Palette+$0C4,Palette+$084

_Brightness     .byte 0,2,4,6,8,6,4,2

saveSource      .dword ?
_temp1          .byte ?

                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vertical Blank Interrupt (SOF)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqVBIHandler   .proc
                pha
                phx
                phy

                inc JIFFYCLOCK          ; increment the jiffy clock each VBI

;   when already in joystick mode, bypass the override logic
                lda InputType
                cmp #itJoystick
                beq _joyModeP1

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _2                  ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType

                bra _2

_joyModeP1      lda JOYSTICK0           ; read joystick0
                sta InputFlags

_2              ;!!jmp _XIT    ; HACK:

                ldx isSaucerActive      ; saucer flag as
                lda SaucerColor,X       ; index 0 or 1
                ;!!sta PCOLR3             ; saucer color

                lda #5
                sta DLICNT              ; reset DLI count

                ;!!lda #$C0               ; enable VBI+DLI
                ;!!sta NMIEN

                lda KEYCHAR             ; keyboard char
                cmp #$39                ; space bar?
                bne _3                  ;   No. skip it

                lda PAUSED              ; pause flag
                eor #$FF                ; invert it
                sta PAUSED              ; save pause flag

                lda #0
                sta KEYCHAR             ; reset keyboard

_3              lda PAUSED              ; pause flag
                beq _nopau              ; paused? No.

                lda #0
                ldx #7                  ; do 8 bytes
_next1          ;!!sta AUDF1,X            ; zero sound
                dex                     ; dec index
                bpl _next1              ; done? No.

                jmp _XIT

_nopau          lda isTitleScreen       ; title flag
                bne _nocyc              ; title? Yes.

                ;!!lda COLOR2             ;   No. get color
                clc
                adc #$10                ; next color
                ;!!sta COLOR2             ; explosion col.

_nocyc          lda EXSCNT              ; explosion cnt
                beq _4                  ; any? No.

                lsr                     ; count/2
                lsr                     ; count/4
                ;!!sta AUDC4              ; explo volume
                lda #40                 ; explosion
                ;!!sta AUDC4              ; explo frequency
                dec EXSCNT              ; dec count

_4              lda GAMCTL              ; game control
                bpl _cursor             ; cursor? Yes.

                jmp _timers             ;   No. skip

; - - - - - - - - - - - - - - - - - - -
; Cursor handler
; - - - - - - - - - - - - - - - - - - -

_cursor         lda InputFlags          ; read joystick
                and #$0F
                ldx zpCursorX           ; get X value
                ldy zpCursorY           ; get Y value
                lsr                     ; shift right
                bcs _notN               ; North? No.

                dey                     ; move cursor up
                dey                     ; two scan lines
_notN           lsr                     ; shift right
                bcs _notS               ; South? No.

                iny                     ; cursor down
                iny                     ; two scan lines
_notS           lsr                     ; shift right
                bcs _notW               ; West? No.

                dex                     ; cursor left
_notW           lsr                     ; shift right
                bcs _notE               ; East? No.

                inx                     ; cursor right
_notE           cpx #52                 ; too far left?
                bcc _badX               ;   Yes. skip next

                cpx #205                ; too far right?
                bcs _badX               ;   Yes. skip next

                stx zpCursorX           ;   No. it's ok!

                ;!!.m16
                lda zpCursorX
                and #$FF
                asl                     ; *2
                sec
                sbc #96
                clc
                adc #32-3
                sta SPR(sprite_t.X, IDX_PLYR)
                ;!!.m8

_badX           cpy #32                 ; too far up?
                bcc _timers             ;   Yes. skip next

                cpy #224                ; too far down?
                bcs _timers             ;   Yes. skip next

                sty zpCursorY           ;   No. it's ok!

                ;!!.m16
                lda zpCursorY
                and #$FF
                clc
                adc #32-8-3
                sta SPR(sprite_t.Y, IDX_PLYR)
                ;!!.m8

; - - - - - - - - - - - - - - - - - - -
; Handle timers and orbit
; - - - - - - - - - - - - - - - - - - -

_timers         lda zpBombWait          ; bomb wait cnt -  wait over?
                beq _5                  ;   Yes

                dec zpBombWait          ; dec count

_5              lda DEADTM              ; death timer - zero?
                beq _6                  ;   Yes

                dec DEADTM              ; decrement it!

_6              lda zpExplosionTimer    ; exp timer zero?
                beq _7                  ;   Yes

                dec zpExplosionTimer    ; decrement it!

_7              lda zpBombTimer         ; get bomb time - zero?
                beq _8                  ;   Yes

                dec zpBombTimer         ; dec bomb time

_8              lda GAMCTL              ; game control - game over?
                bpl _notGameOver        ;   No

                jmp _XIT                ; exit VBLANK

_notGameOver    lda isSatelliteAlive    ; get satellite
                beq _noSat              ; alive? No.

                inc SCNT                ; inc count
                ldy SCNT                ; orbit index

                lda ORBX,Y              ; get X coord
                asl
                sta zpSatelliteX        ; save Pfield x
                clc
                adc #28                 ; X offset
                sta SPR(sprite_t.X, IDX_SATE)  ; horizontal pos

                lda ORBY,Y              ; get Y coord
                sta zpSatelliteY
                clc
                adc #52
                sta SPR(sprite_t.Y, IDX_SATE)

;   toggle between satellite A & B
                inc zpSatPix            ; next sat. image
                lda zpSatPix            ; get number
                and #$08                ; use bit 3

                ;!!.m16
                and #$FF
                bne _pixB

                ;!!lda #$400
                bra _setPix

_pixB           ;!!lda #$800

_setPix         ;!!sta SPR(sprite_t.ADDR, IDX_SATE)
                ;!!.m8

_noSat          lda isSaucerActive      ; saucer active?
                beq _sounds             ;   No

                ldy BombY+3             ; saucer Y pos
                dey                     ; 1
                dey                     ; 2
                ldx #9                  ; 10 scan lines
_next5          cpy #32                 ; above top?
                bcc _nxtsp              ;   Yes. skip it

                cpy #223                ; below bottom?
                bcs _nxtsp              ;   Yes. skip it

; saucer y-pos
                lda SHAPE_Saucer,X      ; saucer image
                ;!!sta PLR3,Y              ; store player 3
_nxtsp          dey                     ; next scan line
                dex                     ; dec index
                bpl _next5              ; done? No.

                ;!!.m16
                lda BombX+3             ; saucer X pos
                and #$FF
                sta SPR(sprite_t.X, IDX_SAUC) ; move it
                ;!!.m8

                inc SAUTIM              ; saucer time
                lda SAUTIM              ; get counter
                lsr                     ; /2
                and #$03                ; use only 0..3
                tax                     ; as X index
                lda SaucerMiddle,X      ; saucer middle
                sta SHAPE_Saucer+4      ; put in
                sta SHAPE_Saucer+5      ; saucer image

_sounds         ldx PSSCNT              ; shot sound
                bpl _doSnd1             ; shot? Yes.

                lda #0                  ;   No
                sta SID1_CTRL1          ; volume for shot
                beq _trySnd2            ; skip next

_doSnd1         lda #$A6                ; shot sound vol
                sta SID1_CTRL1          ; set hardware
                lda PLSHOT,X            ; shot sound
                sta SID1_FREQ1          ; frequency
                dec PSSCNT              ; dec shot snd
_trySnd2        ldx ESSCNT              ; enemy shots
                bpl _doSnd2             ; shots? Yes.

                lda #0                  ;   No
                sta SID1_CTRL2          ; into volume
                beq _trySnd3            ; skip rest

_doSnd2         lda #$A6                ; shot sound vol
                sta SID1_CTRL2          ; set hardware
                lda ENSHOT,X            ; shot sound
                sta SID1_FREQ2          ; frequency
                dec ESSCNT              ; dec shot snd
_trySnd3        lda isSaucerActive      ; saucer active?
                beq _noSnd3             ;   No

                lda BombY+3             ; saucer Y pos
                cmp #36                 ; above top?
                bcc _noSnd3             ;   Yes. skip

                cmp #231                ; below bottom?
                bcc _doSnd3             ;   No. make sound

_noSnd3         lda #0
                sta SID1_CTRL3          ; no saucer snd
                beq _XIT                ; skip next

_doSnd3         inc SSSCNT              ; inc saucer cnt
                ldx SSSCNT              ; saucer count
                cpx #12                 ; at limit?
                bmi _setSnd3            ;   No. skip next

                ldx #0
                stx SSSCNT              ; zero saucer cnt
_setSnd3        lda #$A8                ; saucer volume
                sta SID1_CTRL3          ; set hardware
                lda SAUSND,X            ; saucer sound
                sta SID1_FREQ3          ; set hardware

_XIT            ply
                plx
                pla
                rts
                .endproc
