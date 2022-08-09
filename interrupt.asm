; ------------------
; Intro Display List
; ------------------

TitleDL         ; .byte AEMPTY8,AEMPTY8,AEMPTY8
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

; -----------------
; Game Display List
; -----------------

GameDL          ; .byte AEMPTY8,AEMPTY8

                ; .byte $06+ALMS
                ;    .addr SCOLIN

                ; .byte $0D+ALMS
                ;    .addr SCRN
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


; ------------------
; Intro Message Text
; ------------------

MagMsg          .text "  ANALOG COMPUTING  "
TitleMsg        ;.text " PLANETARY  DEFENSE "
;   top
                .byte $20,$20,$20
                .byte $CE,$CF,$C6,$C7,$B6,$B7,$CA,$CB,$BE,$BF,$DA,$DB,$B6,$B7,$D2,$D3,$DE,$DF
                .byte $20,$20
                .byte $BA,$BB,$BE,$BF,$C2,$C3,$BE,$BF,$CA,$CB,$D6,$D7,$BE,$BF
                .byte $20,$20,$20
;   top
                .byte $20,$20,$20
                .byte $D0,$D1,$C8,$C9,$B8,$B9,$CC,$CD,$C0,$C1,$DC,$DD,$B8,$B9,$D4,$D5,$E0,$E1
                .byte $20,$20
                .byte $BC,$BD,$C0,$C1,$C4,$C5,$C0,$C1,$CC,$CD,$D8,$D9,$C0,$C1
                .byte $20,$20,$20

AuthorMsg       .text " BY CHARLES BACHAND "
                .text "   AND TOM HUDSON   "
StartMsg        .text "  JOYSTICK - START  "
                .text "  OR PRESS TRIGGER  "


;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HandleIrq       .m16i16
                pha
                phx
                phy

                .m8i8
                lda @l INT_PENDING_REG1
                and #FNX1_INT00_KBD
                cmp #FNX1_INT00_KBD
                bne _1

                jsl KeyboardHandler

                lda @l INT_PENDING_REG1
                sta @l INT_PENDING_REG1

_1              lda @l INT_PENDING_REG0
                and #FNX0_INT00_SOF
                cmp #FNX0_INT00_SOF
                bne _XIT

                jsl VbiHandler

                lda @l INT_PENDING_REG0
                sta @l INT_PENDING_REG0

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
HandleIrq_END   rti
                ;jmp IRQ_PRIOR


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Handle Key notifications
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

                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $00

                lda KBD_INPT_BUF
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

_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #$01
                beq _4a

                eor #$01
                ora #$02                ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #$01
                sta InputFlags

                jmp _CleanUpXIT

_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #$02
                beq _5a

                eor #$02
                ora #$01                ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #$02
                sta InputFlags

                jmp _CleanUpXIT

_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #$04
                beq _6a

                eor #$04
                ora #$08                ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #$04
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #$08
                beq _7a

                eor #$08
                ora #$04                ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #$08
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #$10
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #$10
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     ;stz KEYCHAR    HACK:
                pla

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Display list interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI   .proc
                pha                     ; save Acc
                txa                     ; X --> Acc
                pha                     ; save X register

                inc DLICNT              ; inc counter
                lda DLICNT              ; get counter
                and #$07                ; only 3 bits

                tax                     ; use as index
                ;lda _Brightness,X      ; planet brightness
                ;ora vPlanetColor
                ;sta WSYNC              ; start of scan
                ;sta COLPF0             ; color planet

                ;lda #$8C               ; bright blue
                ;sta COLPF0+1           ; shot color

                pla                     ; restore X
                tax                     ; Acc --> X
                pla                     ; restore Acc
                rti

;-------------------------------------

_Brightness     .byte 0,2,4,6,8,6,4,2

                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VERTICAL BLANK ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VbiHandler      .proc
                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $00

                lda JIFFYCLOCK
                inc A
                sta JIFFYCLOCK

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _1                  ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType
                bra _1

_1              ldx InputType
                bne _XIT                ; keyboard, move on

                sta InputFlags

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl

;//////////
HACK
                cld                     ; clear decimal

                ldx SAUCER              ; saucer flag as
                lda SaucerColor,X       ; index 0 or 1
                ;sta PCOLR3             ; saucer color

                lda #5                  ; get 5
                sta DLICNT              ; reset DLI count

                ;lda #$C0               ; enable VBI+DLI
                ;sta NMIEN

                lda KEYCHAR             ; keyboard char
                cmp #$21                ; space bar?
                bne _1                  ; No. skip it

                lda PAUSED              ; pause flag
                eor #$FF                ; invert it
                sta PAUSED              ; save pause flag

                lda #NIL
                sta KEYCHAR             ; reset keyboard

_1              lda PAUSED              ; pause flag
                beq _nopau              ; paused? No.

                lda #0                  ; get zero
                ldx #7                  ; do 8 bytes
_next1          ;sta AUDF1,X            ; zero sound
                dex                     ; dec index
                bpl _next1              ; done? No.

                rti

_nopau          lda isTitleScreen       ; title flag
                bne _nocyc              ; title? Yes.

                ;lda COLOR2             ; No. get color
                clc                     ; clear carry
                adc #$10                ; next color
                ;sta COLOR2             ; explosion col.
_nocyc          lda EXSCNT              ; explosion cnt
                beq _2                  ; any? No.

                lsr A                   ; count/2
                lsr A                   ; count/4
                ;sta AUDC4              ; explo volume
                lda #40                 ; explosion
                ;sta AUDC4              ; explo frequency
                dec EXSCNT              ; dec count

_2              lda GAMCTL              ; game control
                bpl _cursor             ; cursor? Yes.

                jmp _timers             ; No. skip


; --------------
; Cursor handler
; --------------

_cursor         ldy CURY                ; get y pos
                ldx #5                  ; clear 6 bytes
_next2          lda #$0F                ; now clear out
                and MISL-3,Y            ; old cursor
                sta MISL-3,Y            ; graphics,
                iny                     ; next Y position
                dex                     ; dec count
                bpl _next2              ; loop until done

                lda JOYSTICK0           ; read joystick
                and $0F
                ldx CURX                ; get X value
                ldy CURY                ; get Y value
                lsr A                   ; shift right
                bcs _notN               ; North? No.

                dey                     ; move cursor up
                dey                     ; two scan lines
_notN           lsr A                   ; shift right
                bcs _notS               ; South? No.

                iny                     ; cursor down
                iny                     ; two scan lines
_notS           lsr A                   ; shift right
                bcs _notW               ; West? No.

                dex                     ; cursor left
_notW           lsr A                   ; shift right
                bcs _notE               ; East? No.

                inx                     ; cursor right
_notE           cpx #48                 ; too far left?
                bcc _badX               ; Yes. skip next

                cpx #208                ; too far right?
                bcs _badX               ; Yes. skip next

                stx CURX                ; No. it's ok!
_badX           cpy #32                 ; too far up?
                bcc _timers             ; Yes. skip next

                cpy #224                ; too far down?
                bcs _timers             ; Yes. skip next

                sty CURY                ; No. it's ok!

;-------------------------------------
; Handle timers and orbit
;-------------------------------------
_timers         lda BOMBWT              ; bomb wait cnt
                beq _3                  ; wait over? Yes.

                dec BOMBWT              ; dec count
_3              lda DEADTM              ; death timer
                beq _4                  ; zero? yes.

                dec DEADTM              ; decrement it!
_4              lda EXPTIM              ; exp timer
                beq _5                  ; zero? Yes.

                dec EXPTIM              ; decrement it!
_5              lda BOMTIM              ; get bomb time
                beq _6                  ; zero? Yes.

                dec BOMTIM              ; dec bomb time
_6              lda GAMCTL              ; game control
                bpl _notGameOver        ; game over? No.

                rti                     ; exit VBLANK

_notGameOver    lda SATLIV              ; get satellite
                beq _noSat              ; alive? No.

                inc SCNT                ; inc count
                ldy SCNT                ; orbit index
                clc                     ; clear carry
                lda ORBX,Y              ; get X coord
                sta SATX                ; save Pfield x
                adc #47                 ; X offset
                sta SP05_X_POS          ; horizontal pos
                adc #2                  ; +2 offset for
                sta SP04_X_POS          ; right side
                lda ORBY,Y              ; get Y coord
                lsr A                   ; divide by 2
                sta SATY                ; for playfield
                rol A                   ; restore for PM
                adc #36                 ; screen offset
                tax                     ; use as index
                inc SATPIX              ; next sat. image
                lda SATPIX              ; get number
                and #$08                ; use bit 3
                tay                     ; use as index

; satellite y-pos
                lda #8                  ; do 8 bytes
                sta SATEMP              ; save count
_next4          lda MISL,X              ; missile graphic
                and #$F0                ; mask off 1,2
                ora SHAPE_Satellite,Y   ; add sat shape
                sta MISL,X              ; put player #1
                dex                     ; dec position
                iny                     ; dec index
                dec SATEMP              ; dec count
                bne _next4              ; done? No.

_noSat          lda SAUCER              ; saucer flag
                beq _sounds             ; saucer? No.

                ldy BOMBY+3             ; saucer Y pos
                dey                     ; 1
                dey                     ; 2
                ldx #9                  ; 10 scan lines
_next5          cpy #32                 ; above top?
                bcc _nxtsp              ; Yes. skip it

                cpy #223                ; below bottom?
                bcs _nxtsp              ; Yes. skip it

; saucer y-pos
                lda SHAPE_Saucer,X      ; saucer image
                sta PLR3,Y              ; store player 3
_nxtsp          dey                     ; next scan line
                dex                     ; dec index
                bpl _next5              ; done? No.

                .m16
                lda BOMBX+3             ; saucer X pos
                sta SP03_X_POS          ; move it
                .m8

                inc SAUTIM              ; saucer time
                lda SAUTIM              ; get counter
                lsr A                   ; /2
                and #$03                ; use only 0..3
                tax                     ; as X index
                lda SaucerMiddle,X      ; saucer middle
                sta SHAPE_Saucer+4      ; put in
                sta SHAPE_Saucer+5      ; saucer image

_sounds         ldx PSSCNT              ; shot sound
                bpl _doSnd1             ; shot? Yes.

                lda #0                  ; No. get zero
                sta SID_CTRL1           ; volume for shot
                beq _trySnd2            ; skip next

_doSnd1         lda #$A6                ; shot sound vol
                sta SID_CTRL1           ; set hardware
                lda PLSHOT,X            ; shot sound
                sta SID_FREQ1           ; frequency
                dec PSSCNT              ; dec shot snd
_trySnd2        ldx ESSCNT              ; enemy shots
                bpl _doSnd2             ; shots? Yes.

                lda #0                  ; No. get zero
                sta SID_CTRL2           ; into volume
                beq _trySnd3            ; skip rest

_doSnd2         lda #$A6                ; shot sound vol
                sta SID_CTRL2           ; set hardware
                lda ENSHOT,X            ; shot sound
                sta SID_FREQ2           ; frequency
                dec ESSCNT              ; dec shot snd
_trySnd3        lda SAUCER              ; saucer flag
                beq _noSnd3             ; saucer? No.

                lda BOMBY+3             ; saucer Y pos
                cmp #36                 ; above top?
                bcc _noSnd3             ; Yes. skip

                cmp #231                ; below bottom?
                bcc _doSnd3             ; No. make sound

_noSnd3         lda #0                  ; get zero
                sta SID_CTRL3           ; no saucer snd
                beq _XIT                ; skip next

_doSnd3         inc SSSCNT              ; inc saucer cnt
                ldx SSSCNT              ; saucer count
                cpx #12                 ; at limit?
                bmi _setSnd3            ; No. skip next

                ldx #0                  ; get zero
                stx SSSCNT              ; zero saucer cnt
_setSnd3        lda #$A8                ; saucer volume
                sta SID_CTRL3           ; set hardware
                lda SAUSND,X            ; saucer sound
                sta SID_FREQ3           ; set hardware
_XIT            rti
                .endproc
