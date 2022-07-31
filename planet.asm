;-------------------------------------
; Display the Intro Screen
;-------------------------------------
Planet          .proc
                .frsGraphics mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                jsr InitCharLUT

                lda #<CharResX
                sta COLS_PER_LINE
                lda #>CharResX
                sta COLS_PER_LINE+1
                lda #CharResX
                sta COLS_VISIBLE

                lda #<CharResY
                sta LINES_MAX
                lda #>CharResY
                sta LINES_MAX+1
                lda #CharResY
                sta LINES_VISIBLE

                jsr SetFont
                jsr ClearScreen

                cld                     ; clear decimal

                lda #$00                ; get zero
                ;sta NMIEN              ; display off

                ldx #$7F                ; set index
_next1          sta $80,X               ; clr top page 0
                dex                     ; dec pointer
                bne _next1

                inc TITLE               ; title on flag
                lda #$FF                ; get $FF
                sta LIVES               ; set dead
                sta GAMCTL              ; game control
                sta ESSCNT              ; no enemy shots
                sta PSSCNT              ; no player shots
                jsr SoundOff            ; no sound on 123

                ;sta AUDC4              ; turn off snd 4
                ;lda #$C4               ; medium green
                ;sta COLOR0             ; score color
                ;lda #$84               ; medium blue
                ;sta COLOR1             ; text color
                ;lda #$0A               ; bright white
                ;sta COLOR2             ; shot color
                ;lda #$98               ; light blue
                ;sta COLOR3             ; text color

                ;lda #<Interrupt_DLI
                ;sta VDSLST
                ;lda #>Interrupt_DLI
                ;sta VDSLST+1

                ;lda #$C0               ; enable Display
                ;sta NMIEN              ; List Interrupts

                ;lda #$32               ; PM DMA off
                ;sta DMACTL             ; DMA control
                ;sta SDMCTL             ; and shadow reg

                lda #0                  ; get zero
                ;sta GRACTL             ; graphics ctrl -- disable sprites
                ;sta AUDCTL             ; reset audio

                ldx #4                  ; 5 PM registers
_next2          ;sta GRAFP0,X           ; clr register
                dex                     ; dec index
                bpl _next2

                jsr InitSID             ; init sound

                ;lda #<TitleDL
                ;sta SDLSTL
                ;lda #>TitleDL
                ;sta SDLSTL+1

                ;ldx #>Interrupt_VBI
                ;ldy #<Interrupt_VBI
                ;lda #7                 ; deferred
                ;jsr SETVBV             ; set vblank

                lda #60                 ; one second
                sta DEADTM              ; dead time

; --------------------------
; Check console and triggers
; --------------------------

_wait1          lda DEADTM              ; look dead time
                bne _wait1              ; alive? No.

_next3          ;lda PTRIG0             ; paddle trig 0
                ;eor PTRIG1             ; mask w/PTRIG1
                ;bne _pdev              ; pushed? Yes.

                lda JOYSTICK0           ; stick trig
                and #$10
                beq _pdev               ; pushed? Yes.

                lda CONSOL              ; get console
                and #3                  ; do START/SELECT
                cmp #3                  ; test buttons
                beq _next3              ; any pushed? No.

                and #1                  ; mask off START
_pdev           sta DEVICE              ; device switch

_next4          lda #10                 ; 1/6 second
                sta DEADTM              ; dead time
_wait2          lda DEADTM              ; debounce!
                bne _wait2

                lda CONSOL              ; get console
                cmp #7                  ; keys released?
                bne _next4


; ---------------------------
; Clear PM Area and Playfield
; ---------------------------

                lda #>SCRN              ; scrn addr high
                sta INDEX+1             ; pointer high
                lda #0                  ; get zero
                sta INDEX               ; pointer low
                ldx #15                 ; 16 pages 0..15
                tay                     ; use as index
_next5          sta (INDEX),Y           ; clear ram
                iny                     ; next byte
                bne _next5              ; page done? No.

                inc INDEX+1             ; next page
                dex                     ; page counter
                bpl _next5              ; scrn done? No.

                ldx #0                  ; now clear P/m
_next6          sta MISL,X              ; clear missiles
                sta PLR0,X              ; clear plyr 0
                sta PLR1,X              ; clear plyr 1
                sta PLR2,X              ; clear plyr 2
                sta PLR3,X              ; clear plyr 3
                dex                     ; done 256 bytes?
                bne _next6

                ;lda #<GameDL
                ;sta SDLSTL
                ;lda #>GameDL
                ;sta SDLSTL+1

                ;lda #>PM               ; PM address high
                ;sta PMBASE             ; into hardware

                ;lda #$3E               ; enable single
                ;sta SDMCTL             ; line resolution
                ;sta DMACTL             ; DMA control

                ;lda #3                 ; enable player
                ;sta GRACTL             ; and missile DMA

                ;lda #$11               ; set up
                ;sta GPRIOR             ; P/M priority

                lda #0                  ; get zero
                sta TITLE               ; title off

; ---------------
; Draw The Planet
; ---------------

                lda #<PPOS              ; planet pos high
                sta INDX1               ; pointer #1 low
                sta INDX2               ; pointer #2 low
                lda #>PPOS              ; planet pos high
                sta INDX1+1             ; pointer #1 high
                sta INDX2+1             ; pointer #2 high
                ldx #0                  ; table pointer
_next7          ldy #0                  ; index pointer
_next8          lda _tblDrawPlanet,X    ; table value
                bne _dp2                ; done? No.

                jmp SetupOrbiter

_dp2            bmi _dpRepeat           ; repeat? Yes.

                sta (INDX1),Y           ; put values
                sta (INDX2),Y           ; onto screen
                iny                     ; inc index pntr
                inx                     ; inc table pntr
                jmp _next8


; -------------------
; Repeat Byte Handler
; -------------------

_dpRepeat       asl A                   ; shift byte
                sta TEMP                ; new line flag
                asl A                   ; NL bit -> carry
                asl A                   ; color -> carry
                lda #$55                ; color 1 bits
                bcs _fill1              ; color 1? Yes.

                lda #0                  ; get background
_fill1          pha                     ; save color byte
                lda _tblDrawPlanet,X    ; table value
                and #$0F                ; mask 4 bits
                sta COUNT               ; save as count
                pla                     ; restore color
_next9          sta (INDX1),Y           ; put bytes
                sta (INDX2),Y           ; onto screen
                iny                     ; inc index
                dec COUNT               ; dec byte count
                bne _next9

                inx                     ; inc table index
                lda TEMP                ; get flag
                bpl _next8              ; new line? No.

                sec                     ; set carry
                lda INDX1               ; Yes. get low
                sbc #40                 ; subtract 40
                sta INDX1               ; new low
                bcs _dpN1               ; overflow? No.

                dec INDX1+1             ; decrement high
_dpN1           clc                     ; clear carry
                lda INDX2               ; get low
                adc #40                 ; add 40
                sta INDX2               ; new low
                bcc _next7              ; overflow? No.

                inc INDX2+1
                jmp _next7

;--------------------------------------

; ---------------
; Planet Draw Data
; ---------------

_tblDrawPlanet  .byte $EA,$EA,$EA,$EA
                .byte $EA,$15,$A8,$54
                .byte $C1,$15,$A8,$54
                .byte $C1,$05,$A8,$50
                .byte $C1,$05,$A8,$50
                .byte $C1,$01,$A8,$40
                .byte $C1,$81,$E8,$81
                .byte $15,$A6,$54,$C1
                .byte $81,$05,$A6,$50
                .byte $C1,$81,$01,$A6
                .byte $40,$C1,$82,$E6
                .byte $82,$05,$A4,$50
                .byte $C1,$83,$E4,$84
                .byte $E2,0

                .endproc
