;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Display list interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI             pha                     ;save Acc
                txa                     ;X --> Acc
                pha                     ;save X register
                inc DLICNT              ;inc counter
                lda DLICNT              ;get counter
                and #$07                ;only 3 bits
                tax                     ;use as index
                lda DLIBRT,X            ;planet bright
                ora PLNCOL              ;planet color
                sta WSYNC               ;start of scan
                sta COLPF0              ;color planet
                lda #$8C                ;bright blue
                sta COLPF0+1            ;shot color
                pla                     ;restore X
                tax                     ;Acc --> X
                pla                     ;restore Acc
                rti                     ;return

;--------------------------------------

DLIBRT          .byte 0,2,4,6           ;planet
                .byte 8,6,4,2           ;brightness


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vertical blank routine
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VBLANK          cld                     ;clear decimal
                ldx SAUCER              ;saucer flag as
                lda P3COLR,X            ;index 0 or 1
                sta PCOLR0+3            ;saucer color
                lda #5                  ;get 5
                sta DLICNT              ;reset DLI count
                lda #$C0                ;enable
                sta NMIEN               ;DLI's
                lda CH                  ;keyboard char
                cmp #$21                ;space bar?
                bne PCHK                ;No. skip it

                lda PAUSED              ;pause flag
                eor #$FF                ;invert it
                sta PAUSED              ;save pause flag
                lda #$FF                ;get $FF
                sta CH                  ;reset keyboard
PCHK            lda PAUSED              ;pause flag
                beq NOPAU               ;paused? No.

                lda #0                  ;get zero
                ldx #7                  ;do 8 bytes
NOSND           sta AUDF1,X             ; zero sound
                dex                     ;dec index
                bpl NOSND               ;done? No.

                jmp XITVBV              ;exit VBLANK

NOPAU           lda TITLE               ;title flag
                bne NOCYC               ;title? Yes.

                lda COLOR0+2            ; No. get color
                clc                     ;clear carry
                adc #$10                ;next color
                sta COLOR0+2            ;explosion col.
NOCYC           lda EXSCNT              ;explosion cnt
                beq NOPAU2              ;any? No.

                lsr A                   ;count/2
                lsr A                   ;count/4
                sta AUDC1+6             ;explo volume
                lda #40                 ;explosion
                sta AUDF1+6             ;explo frequency
                dec EXSCNT              ;dec count
NOPAU2          lda GAMCTL              ;game control
                bpl CURSOR              ;cursor? Yes.

                jmp TIMERS              ;No. skip


; --------------
; Cursor handler
; --------------

CURSOR          ldy CURY                ;get y pos
                ldx #5                  ;clear 6 bytes
ERACUR          lda #$0F                ;now clear out
                and MISL-3,Y            ;old cursor
                sta MISL-3,Y            ;graphics,
                iny                     ;next Y position
                dex                     ;dec count
                bpl ERACUR              ;loop until done

                lda STICK0              ;read joystick
                ldx CURX                ;get X value
                ldy CURY                ;get Y value
                lsr A                   ;shift right
                bcs NOTN                ;North? No.

                dey                     ;move cursor up
                dey                     ;two scan lines
NOTN            lsr A                   ;shift right
                bcs NOTS                ;South? No.

                iny                     ;cursor down
                iny                     ;two scan lines
NOTS            lsr A                   ;shift right
                bcs NOTW                ;West? No.

                dex                     ;cursor left
NOTW            lsr A                   ;shift right
                bcs NOTE                ;East? No.

                inx                     ;cursor right
NOTE            cpx #48                 ;too far left?
                bcc BADX                ;Yes. skip next

                cpx #208                ;too far right?
                bcs BADX                ;Yes. skip next

                stx CURX                ;No. it's ok!
BADX            cpy #32                 ;too far up?
                bcc BADY                ;Yes. skip next

                cpy #224                ;too far down?
                bcs BADY                ;Yes. skip next

                sty CURY                ;No. it's ok!
BADY            lda DEVICE              ;KOALA switch
                beq NKOALA              ;KOALA PAD?

                jsr KOALA               ;Yes. do it

NKOALA          lda PENFLG              ;koala pen flg
                bne TIMERS              ;pen up? Yes.

                ldx #5                  ;6 bytes...
                ldy CURY                ;get cursor Y
SHOCUR          lda CURPIC,X            ;cursor pic
                ora MISL-3,Y            ;mask missiles
                sta MISL-3,Y            ;store missiles
                iny                     ;next scan line
                dex                     ;dec count
                bpl SHOCUR              ;done? No.

                ldx CURX                ;get x position,
                dex                     ;1 less for...
                stx HPOSM0+3            ;missile 3
                inx                     ;2 more for...
                inx                     ;missile 2
                stx HPOSM0+2            ;save position


;--------------------------------------
; Handle timers and orbit
;--------------------------------------
TIMERS          lda BOMBWT              ;bomb wait cnt
                beq NOBWT               ;wait over? Yes.

                dec BOMBWT              ;dec count
NOBWT           lda DEADTM              ;death timer
                beq NOTIM0              ;zero? yes.

                dec DEADTM              ;decrement it!
NOTIM0          lda EXPTIM              ;exp timer
                beq NOTIM1              ;zero? Yes.

                dec EXPTIM              ;decrement it!
NOTIM1          lda BOMTIM              ;get bomb time
                beq NOTIM2              ;zero? Yes.

                dec BOMTIM              ;dec bomb time
NOTIM2          lda GAMCTL              ;game control
                bpl NOTOVR              ;game over? No.

                jmp XITVBV              ;exit VBLANK

NOTOVR          lda SATLIV              ;get satellite
                beq NOSAT               ;alive? No.

                inc SCNT                ;inc count
                ldy SCNT                ;orbit index
                clc                     ;clear carry
                lda ORBX,Y              ;get X coord
                sta SATX                ;save Pfield x
                adc #47                 ;X offset
                sta HPOSM0+1            ;horizontal pos
                adc #2                  ;+2 offset for
                sta HPOSM0              ;right side
                lda ORBY,Y              ;get Y coord
                lsr A                   ;divide by 2
                sta SATY                ;for playfield
                rol A                   ;restore for PM
                adc #36                 ;screen offset
                tax                     ;use as index
                inc SATPIX              ;next sat. image
                lda SATPIX              ;get number
                and #$08                ;use bit 3
                tay                     ;use as index
                lda #8                  ;do 8 bytes
                sta SATEMP              ;save count
SSAT            lda MISL,X              ;missile graphic
                and #$F0                ;mask off 1,2
                ora SATSH,Y             ;add sat shape
                sta MISL,X              ;put player #1
                dex                     ;dec position
                iny                     ;dec index
                dec SATEMP              ;dec count
                bne SSAT                ;done? No.

NOSAT           lda SAUCER              ;saucer flag
                beq SOUNDS              ;saucer? No.

                ldy BOMBY+3             ;saucer Y pos
                dey                     ;-1
                dey                     ;-2
                ldx #9                  ;10 scan lines
SSAULP          cpy #32                 ;above top?
                bcc NXTSP               ;Yes. skip it

                cpy #223                ;below bottom?
                bcs NXTSP               ;Yes. skip it

                lda SAUPIC,X            ;saucer image
                sta PLR3,Y              ;store player 3
NXTSP           dey                     ;next scan line
                dex                     ;dec index
                bpl SSAULP              ;done? No.

                lda BOMBX+3             ;saucer X pos
                sta HPOSP0+3            ;move it
                inc SAUTIM              ;saucer time
                lda SAUTIM              ;get counter
                lsr A                   ;/2
                and #$03                ;use only 0..3
                tax                     ;as X index
                lda SAUMID,X            ;saucer middle
                sta SAUPIC+4            ;put in
                sta SAUPIC+5            ;saucer image
SOUNDS          ldx PSSCNT              ;shot sound
                bpl DOS1                ;shot? Yes.

                lda #0                  ;No. get zero
                sta AUDC1               ;volume for shot
                beq TRYS2               ;skip next

DOS1            lda #$A6                ;shot sound vol
                sta AUDC1               ;set hardware
                lda PLSHOT,X            ;shot sound
                sta AUDF1               ;frequency
                dec PSSCNT              ;dec shot snd
TRYS2           ldx ESSCNT              ;enemy shots
                bpl DOS2                ;shots? Yes.

                lda #0                  ;No. get zero
                sta AUDC1+2             ;into volume
                beq TRYS3               ;skip rest

DOS2            lda #$A6                ;shot sound vol
                sta AUDC1+2             ;set hardware
                lda ENSHOT,X            ;shot sound
                sta AUDF1+2             ;frequency
                dec ESSCNT              ;dec shot snd
TRYS3           lda SAUCER              ;saucer flag
                beq NOS3                ;saucer? No.

                lda BOMBY+3             ;saucer Y pos
                cmp #36                 ;above top?
                bcc NOS3                ;Yes. skip

                cmp #231                ;below bottom?
                bcc DOS3                ;No. make sound

NOS3            lda #0                  ;get zero
                sta AUDC1+4             ;no saucer snd
                beq VBDONE              ;skip next

DOS3            inc SSSCNT              ;inc saucer cnt
                ldx SSSCNT              ;saucer count
                cpx #12                 ;at limit?
                bmi SETS3               ;No. skip next

                ldx #0                  ;get zero
                stx SSSCNT              ;zero saucer cnt
SETS3           lda #$A8                ;saucer volume
                sta AUDC1+4             ;set hardware
                lda SAUSND,X            ;saucer sound
                sta AUDF1+4             ;set hardware
VBDONE          jmp XITVBV              ;continue


; ---------------------
; Satellite shape table
; ---------------------

SATSH           .byte 0,0,0,$0A
                .byte $04,$0A,0,0
                .byte 0,0,0,$04
                .byte $0A,$04,0,0
