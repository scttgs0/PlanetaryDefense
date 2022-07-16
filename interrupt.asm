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

MAGMSG
            .enc "atari-screen"
                .text " ANALOG COMPUTING'S "
                .text $40,"planetary",$40,$40,"defense",$40
            .enc "atari-screen-inverse"
                .text $80,"BY",$80,"CHARLES",$80,"BACHAND",$80
                .text "   and tom hudson   "
            .enc "atari-screen"
                .text $40,"koala",$40,"pad",$40,$4D,$40,"select",$40
            .enc "atari-screen-inverse"
                .text " joystick --- start "
            .enc "atari-screen"
                .text "  OR PRESS TRIGGER  "
            .enc "none"


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
                lda _Brightness,X       ; planet brightness
                ora vPlanetColor
                sta WSYNC               ; start of scan
                sta COLPF0              ; color planet

                lda #$8C                ; bright blue
                sta COLPF0+1            ; shot color

                pla                     ; restore X
                tax                     ; Acc --> X
                pla                     ; restore Acc
                rti

;-------------------------------------

_Brightness     .byte 0,2,4,6,8,6,4,2

                .endproc


; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vertical blank routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_VBI   .proc
                cld                     ; clear decimal

                ldx SAUCER              ; saucer flag as
                lda P3COLR,X            ; index 0 or 1
                sta PCOLR0+3            ; saucer color
                lda #5                  ; get 5
                sta DLICNT              ; reset DLI count
                lda #$C0                ; enable
                sta NMIEN               ; DLI's
                lda CH                  ; keyboard char
                cmp #$21                ; space bar?
                bne _1                 ; No. skip it

                lda PAUSED              ; pause flag
                eor #$FF                ; invert it
                sta PAUSED              ; save pause flag

                lda #$FF                ; get $FF
                sta CH                  ; reset keyboard

_1              lda PAUSED              ; pause flag
                beq _nopau              ; paused? No.

                lda #0                  ; get zero
                ldx #7                  ; do 8 bytes
_next1          sta AUDF1,X             ; zero sound
                dex                     ; dec index
                bpl _next1              ; done? No.

                rti

_nopau          lda TITLE               ; title flag
                bne _nocyc              ; title? Yes.

                lda COLOR0+2            ; No. get color
                clc                     ; clear carry
                adc #$10                ; next color
                sta COLOR0+2            ; explosion col.
_nocyc          lda EXSCNT              ; explosion cnt
                beq _2                  ; any? No.

                lsr A                   ; count/2
                lsr A                   ; count/4
                sta AUDC1+6             ; explo volume
                lda #40                 ; explosion
                sta AUDF1+6             ; explo frequency
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

                lda STICK0              ; read joystick
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
                sta HPOSM0+1            ; horizontal pos
                adc #2                  ; +2 offset for
                sta HPOSM0              ; right side
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

                lda SAUPIC,X            ; saucer image
                sta PLR3,Y              ; store player 3
_nxtsp          dey                     ; next scan line
                dex                     ; dec index
                bpl _next5              ; done? No.

                lda BOMBX+3             ; saucer X pos
                sta HPOSP0+3            ; move it
                inc SAUTIM              ; saucer time
                lda SAUTIM              ; get counter
                lsr A                   ; /2
                and #$03                ; use only 0..3
                tax                     ; as X index
                lda SAUMID,X            ; saucer middle
                sta SAUPIC+4            ; put in
                sta SAUPIC+5            ; saucer image

_sounds         ldx PSSCNT              ; shot sound
                bpl _doSnd1             ; shot? Yes.

                lda #0                  ; No. get zero
                sta AUDC1               ; volume for shot
                beq _trySnd2            ; skip next

_doSnd1         lda #$A6                ; shot sound vol
                sta AUDC1               ; set hardware
                lda PLSHOT,X            ; shot sound
                sta AUDF1               ; frequency
                dec PSSCNT              ; dec shot snd
_trySnd2        ldx ESSCNT              ; enemy shots
                bpl _doSnd2             ; shots? Yes.

                lda #0                  ; No. get zero
                sta AUDC1+2             ; into volume
                beq _trySnd3            ; skip rest

_doSnd2         lda #$A6                ; shot sound vol
                sta AUDC1+2             ; set hardware
                lda ENSHOT,X            ; shot sound
                sta AUDF1+2             ; frequency
                dec ESSCNT              ; dec shot snd
_trySnd3        lda SAUCER              ; saucer flag
                beq _noSnd3             ; saucer? No.

                lda BOMBY+3             ; saucer Y pos
                cmp #36                 ; above top?
                bcc _noSnd3             ; Yes. skip

                cmp #231                ; below bottom?
                bcc _doSnd3             ; No. make sound

_noSnd3         lda #0                  ; get zero
                sta AUDC1+4             ; no saucer snd
                beq _XIT                ; skip next

_doSnd3         inc SSSCNT              ; inc saucer cnt
                ldx SSSCNT              ; saucer count
                cpx #12                 ; at limit?
                bmi _setSnd3            ; No. skip next

                ldx #0                  ; get zero
                stx SSSCNT              ; zero saucer cnt
_setSnd3        lda #$A8                ; saucer volume
                sta AUDC1+4             ; set hardware
                lda SAUSND,X            ; saucer sound
                sta AUDF1+4             ; set hardware
_XIT            rti
                .endproc
