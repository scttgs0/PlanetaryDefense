;-------------------------------------
; Display the Intro Screen
;-------------------------------------
Planet          .proc
                jsr Random_Seed

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcBitmapOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

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

                jsr InitLUT
                jsr InitCharLUT

                jsr SetFont
                jsr ClearScreen

                jsr InitSID             ; init sound

                jsr InitBitmap
                jsr InitSprites

                ldx #$7F                ; set index
_next1          sta $80,X               ; clear top of page-0
                dex                     ; dec pointer
                bne _next1

                inc isTitleScreen       ; title on flag

                lda #NIL
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

                ;lda #$C0               ; enable DLI
                ;sta NMIEN

                ldx #4                  ; 5 PM registers
_next2          ;sta GRAFP0,X           ; clear register
                dex
                bpl _next2

                jsr InitIRQs

;   render title screen
                jsr RenderPublisher
                jsr RenderTitle
                jsr RenderAuthor
                jsr RenderSelect

                ;ldx #>Interrupt_VBI
                ;ldy #<Interrupt_VBI
                ;lda #7                 ; deferred
                ;jsr SETVBV             ; set vblank

                ;lda #60                 ; one second dead time
                lda #0      ; HACK:
                sta DEADTM

; --------------------------
; Check console and triggers
; --------------------------

_wait1          lda DEADTM              ; look dead time
                bne _wait1              ; alive? No.

_next3          ;lda PTRIG0             ; paddle trig 0
                ;eor PTRIG1             ; mask w/PTRIG1
                ;bne _pdev              ; pushed? Yes.

                lda InputFlags          ; stick trig
                and #$10
                beq _pdev               ; pushed? Yes.

                lda CONSOL              ; get console
                and #3                  ; do START/SELECT
                cmp #3                  ; test buttons
                beq _next3              ; any pushed? No.

                and #1                  ; mask off START
_pdev           sta DEVICE              ; device switch

_next4          ;lda #10                 ; 1/6 second dead time
                lda #0      ; HACK:
                sta DEADTM
_wait2          lda DEADTM              ; debounce!
                bne _wait2

                lda CONSOL              ; get console keys
                cmp #7                  ; released?
                bne _next4


; ---------------------------
; Clear PM Area and Playfield
; ---------------------------

                lda #>Playfield         ; scrn addr high
                sta INDEX+1             ; pointer high
                lda #<Playfield         ; get addr low
                sta INDEX               ; pointer low

                ldx #15                 ; 16 pages 0..15
                tay                     ; use as index
_next5          sta (INDEX),Y           ; clear ram
                iny                     ; next byte
                bne _next5              ; page done? No.

                inc INDEX+1             ; next page
                dex                     ; page counter
                bpl _next5              ; scrn done? No.

;                ldx #0                  ; now clear P/m
;_next6          sta MISL,X              ; clear missiles
;                sta PLR0,X              ; clear plyr 0
;                sta PLR1,X              ; clear plyr 1
;                sta PLR2,X              ; clear plyr 2
;                sta PLR3,X              ; clear plyr 3
;                dex                     ; done 256 bytes?
;                bne _next6

                jsr ClearScreen
                jsr RenderScoreLine

                ;lda #>PM               ; PM address high
                ;sta PMBASE             ; into hardware

                lda #FALSE              ; title off
                sta isTitleScreen

; ---------------
; Draw The Planet
; ---------------

                lda #<PPOS              ; planet pos low
                sta INDX1               ; pointer #1 low
                sta INDX2               ; pointer #2 low

                lda #>PPOS              ; planet pos high
                sta INDX1+1             ; pointer #1 high
                sta INDX2+1             ; pointer #2 high

                ldx #0                  ; table pointer
_next7          ldy #0                  ; index pointer
_next8          lda _tblDrawPlanet,X    ; table value
                bne _dp2                ; done? No.

                jsr BlitPlayfield

                jmp SetupOrbiter

_dp2            bmi _dpRepeat           ; repeat? Yes.

                sta (INDX1),Y           ; put values onto screen
                sta (INDX2),Y
                iny
                inx
                bra _next8


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

; ----------------
; Planet Draw Data
; ----------------

_tblDrawPlanet  ;.byte $EA,$EA,$EA,$EA
                ;.byte $EA,$15,$A8,$54
                ;.byte $C1,$15,$A8,$54
                ;.byte $C1,$05,$A8,$50
                ;.byte $C1,$05,$A8,$50
                ;.byte $C1,$01,$A8,$40
                ;.byte $C1,$81,$E8,$81
                ;.byte $15,$A6,$54,$C1
                ;.byte $81,$05,$A6,$50
                ;.byte $C1,$81,$01,$A6
                ;.byte $40,$C1,$82,$E6
                ;.byte $82,$05,$A4,$50
                ;.byte $C1,$83,$E4,$84
                ;.byte $E2,0

                .byte %11101010         ; ###  .#.#.
                .byte %11101010         ; ###  .#.#.
                .byte %11101010         ; ###  .#.#.
                .byte %11101010         ; ###  .#.#.
                .byte %11101010         ; ###  .#.#.

                .byte %00010101         ; ...  #.#.#
                .byte %10101000         ; #.#  .#...
                .byte %01010100         ; .#.  #.#..
                .byte %11000001         ; ##.  ....#

                .byte %00010101         ; ...  #.#.#
                .byte %10101000         ; #.#  .#...
                .byte %01010100         ; .#.  #.#..
                .byte %11000001         ; ##.  ....#

                .byte %00000101         ; ...  ..#.#
                .byte %10101000         ; #.#  .#...
                .byte %01010000         ; .#.  #....
                .byte %11000001         ; ##.  ....#

                .byte %00000101         ; ...  ..#.#
                .byte %10101000         ; #.#  .#...
                .byte %01010000         ; .#.  #....
                .byte %11000001         ; ##.  ....#

                .byte %00000001         ; ...  ....#
                .byte %10101000         ; #.#  .#...
                .byte %01000000         ; .#.  .....
                .byte %11000001         ; ##.  ....#
                .byte %10000001         ; #..  ....#
                .byte %11101000         ; ###  .#...
                .byte %10000001         ; #..  ....#

                .byte %00010101         ; ...  #.#.#
                .byte %10100110         ; #.#  ..##.
                .byte %01010100         ; .#.  #.#..
                .byte %11000001         ; ##.  ....#
                .byte %10000001         ; #..  ....#

                .byte %00000101         ; ...  ..#.#
                .byte %10100110         ; #.#  ..##.
                .byte %01010000         ; .#.  #....
                .byte %11000001         ; ##.  ....#
                .byte %10000001         ; #..  ....#

                .byte %00000001         ; ...  ....#
                .byte %10100110         ; #.#  ..##.
                .byte %01000000         ; .#.  .....
                .byte %11000001         ; ##.  ....#
                .byte %10000010         ; #..  ...#.
                .byte %11100110         ; ###  ..##.
                .byte %10000010         ; #..  ...#.

                .byte %00000101         ; ...  ..#.#
                .byte %10100100         ; #.#  ..#..
                .byte %01010000         ; .#.  #....
                .byte %11000001         ; ##.  ....#
                .byte %10000011         ; #..  ...##
                .byte %11100100         ; ###  ..#..
                .byte %10000100         ; #..  ..#..
                .byte %11100010         ; ###  ...#.
                .byte $00

                .endproc
