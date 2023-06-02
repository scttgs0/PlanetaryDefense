
;======================================
; seed = quick and dirty
;======================================
RandomSeedQuick .proc
                lda RTC_MIN
                sta RNG_SEED_HI

                lda RTC_SEC
                sta RNG_SEED_LO

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL
                .endproc


;======================================
; seed = elapsed seconds this hour
;======================================
RandomSeed      .proc
                lda RTC_MIN
                jsr Bcd2Bin
                sta RND_MIN

                lda RTC_SEC
                jsr Bcd2Bin
                sta RND_SEC

;   elapsed minutes * 60
                lda RND_MIN
                asl
                asl
                pha
                asl
                pha
                asl
                pha
                asl
                sta RND_RESULT      ; *32

                pla
                clc
                adc RND_RESULT      ; *16
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *8
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *4
                sta RND_RESULT

;   add the elapsed seconds
                clc
                lda RND_SEC
                adc RND_RESULT

                sta RNG_SEED_LO
                stz RNG_SEED_HI

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL
                .endproc


;======================================
; Convert BCD to Binary
;======================================
Bcd2Bin         .proc
                pha

;   upper-nibble * 10
                lsr                     ; n*8
                pha
                lsr
                lsr
                sta zpTemp1             ; n*2

                pla
                clc
                adc zpTemp1
                sta zpTemp1

;   add the lower-nibble
                pla
                and #$0F
                clc
                adc zpTemp1

                .endproc


;======================================
; Initialize SID
;======================================
InitSID         .proc
                pha
                phx

                lda #0                  ; reset the SID registers
                ldx #$1F
_next1          sta SID1_BASE,X
                sta SID2_BASE,X

                dex
                bpl _next1

                lda #$09                ; Attack/Decay = 9
                sta SID1_ATDCY1
                sta SID1_ATDCY2
                sta SID1_ATDCY3
                sta SID2_ATDCY1

                stz SID1_SUREL1         ; Susatain/Release = 0 [square wave]
                stz SID1_SUREL2
                stz SID1_SUREL3
                stz SID2_SUREL1

                ;lda #$21
                ;sta SID1_CTRL1
                ;sta SID1_CTRL2
                ;sta SID1_CTRL3
                ;sta SID2_CTRL1

                lda #$08                ; Volume = 8 (mid-range)
                sta SID1_SIGVOL
                sta SID2_SIGVOL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize PSG
;======================================
InitPSG         .proc
                pha
                phx

                lda #0                  ; reset the PSG registers
                ldx #$07
_next1          sta PSG1_BASE,X
                sta PSG2_BASE,X

                dex
                bpl _next1

                plx
                pla
                rts
                .endproc


;======================================
; Initialize the text-color LUT
;======================================
InitTextPalette .proc
                pha
                phy

;   switch to system map
                stz IOPAGE_CTRL

                ldy #$3F
_next1          lda _Text_CLUT,Y
                sta FG_CHAR_LUT_PTR,Y   ; same palette for foreground and background
                sta BG_CHAR_LUT_PTR,Y

                dey
                bpl _next1

                ply
                pla
                rts

;--------------------------------------

_Text_CLUT      .dword $00282828        ; 0: Dark Jungle Green
                .dword $00DDDDDD        ; 1: Gainsboro
                .dword $00143382        ; 2: Saint Patrick Blue
                .dword $006B89D7        ; 3: Blue Gray
                .dword $00693972        ; 4: Indigo
                .dword $00B561C2        ; 5: Deep Fuchsia
                .dword $00352BB0        ; 6: Blue Pigment
                .dword $007A7990        ; 7: Fern Green
                .dword $0074D169        ; 8: Moss Green
                .dword $00E6E600        ; 9: Peridot
                .dword $00C563BD        ; A: Pastel Violet
                .dword $005B8B46        ; B: Han Blue
                .dword $00BC605E        ; C: Medium Carmine
                .dword $00C9A765        ; D: Satin Sheen Gold
                .dword $0004750E        ; E: Hookers Green
                .dword $00BC605E        ; F: Medium Carmine

                .endproc


;======================================
; Initialize the graphic-color LUT
;======================================
InitGfxPalette  .proc
                pha
                phx
                phy

;   switch to graphic map
                lda #$01
                sta IOPAGE_CTRL

                lda #<Palette
                sta zpSource
                lda #>Palette
                sta zpSource+1

                lda #<GRPH_LUT0_PTR
                sta zpDest
                lda #>GRPH_LUT0_PTR
                sta zpDest+1

                ldx #$02                ; 128 colors * 4 = 512 bytes
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                php
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   setup player sprites (sprite-00 & sprint-01)
                lda #<SPR_Cursor
                sta SP00_ADDR
                sta SP01_ADDR
                lda #>SPR_Cursor
                sta SP00_ADDR+1
                sta SP01_ADDR+1
                stz SP00_ADDR+2
                stz SP01_ADDR+2

                stz SP00_X
                stz SP00_X+1
                stz SP00_Y
                stz SP00_Y+1

                stz SP01_X
                stz SP01_X+1
                stz SP01_Y
                stz SP01_Y+1

;   setup bomb sprites (sprite-02 & sprint-03)
                lda #<SPR_BombL
                sta SP02_ADDR
                sta SP03_ADDR
                lda #>SPR_BombL
                sta SP02_ADDR+1
                sta SP03_ADDR+1
                stz SP02_ADDR+2
                stz SP03_ADDR+2

                stz SP02_X
                stz SP02_X+1
                stz SP02_Y
                stz SP02_Y+1

                stz SP03_X
                stz SP03_X+1
                stz SP03_Y
                stz SP03_Y+1

                lda #scEnable
                sta SP00_CTRL
                sta SP02_CTRL
                sta SP03_CTRL

                lda #scEnable|scLUT1
                sta SP01_CTRL

                pla
                plp
                rts
                .endproc


;======================================
; Clear all Sprites
;======================================
ClearSprites    .proc
                stz SP00_X
                stz SP00_X+1
                stz SP00_Y
                stz SP00_Y+1

                stz SP01_X
                stz SP01_X+1
                stz SP01_Y
                stz SP01_Y+1

                stz SP03_X
                stz SP03_X+1
                stz SP03_Y
                stz SP03_Y+1

                stz SP04_X
                stz SP04_X+1
                stz SP04_Y
                stz SP04_Y+1

                stz SP05_X
                stz SP05_X+1
                stz SP05_Y
                stz SP05_Y+1

                stz SP06_X
                stz SP06_X+1
                stz SP06_Y
                stz SP06_Y+1

                stz SP07_X
                stz SP07_X+1
                stz SP07_Y
                stz SP07_Y+1

                stz SP08_X
                stz SP08_X+1
                stz SP08_Y
                stz SP08_Y+1

                stz SP09_X
                stz SP09_X+1
                stz SP09_Y
                stz SP09_Y+1

                stz SP10_X
                stz SP10_X+1
                stz SP10_Y
                stz SP10_Y+1

                stz SP11_X
                stz SP11_X+1
                stz SP11_Y
                stz SP11_Y+1
                .endproc


;======================================
;
;======================================
CheckCollision  .proc
                pha
                phx
                phy

                ldx #1                  ; Given: SP02_Y=112
_nextBomb       lda zpBombDrop,X        ; A=112
                beq _nextPlayer

                cmp #132
                bcs _withinRange
                bra _nextPlayer

_withinRange    sec
                sbc #132                ; A=8
                lsr             ; /2    ; A=4
                lsr             ; /4    ; A=2
                lsr             ; /8    ; A=1
                sta zpTemp1             ; zpTemp1=1 (row)

                lda PlayerPosX,X
                lsr             ; /2
                lsr             ; /4
                sta zpTemp2             ; (column)

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

                ldy zpTemp1
_nextRow        beq _checkRock
                lda zpSource
                clc
                adc #40
                sta zpSource
                bcc _1

                inc zpSource+1
_1              dey
                bra _nextRow

_checkRock      ldy zpTemp2
                lda (zpSource),Y
                beq _nextPlayer

                ;cmp #4
                ;bcs _nextPlayer

                sta P2PF,X

                stz zpTemp1
                txa
                asl
                rol zpTemp1
                tay
                lda zpSource
                stz zpTemp2+1
                clc
                adc zpTemp2
                sta P2PFaddr,Y

_nextPlayer     dex
                bpl _nextBomb

                ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                pha

                lda #<Playfield         ; Set the destination address
                sta BITMAP0_ADDR
                lda #>Playfield
                sta BITMAP0_ADDR+1
                stz BITMAP0_ADDR+2

                lda #bmcEnable|bmcLUT0
                sta BITMAP0_CTRL

                stz BITMAP1_CTRL        ; disabled
                stz BITMAP2_CTRL

                pla
                rts
                .endproc


;======================================
; Clear Playfield
;======================================
ClearPlayfield  .proc
                ; .as
                ; .xs
                php
                pha
                phx

                lda #0
                ldx #0
_nextByte       sta Playfield,X
                sta Playfield+$100,X
                sta Playfield+$200,X
                sta Playfield+$300,X
                sta Playfield+$400,X
                sta Playfield+$500,X
                sta Playfield+$600,X
                sta Playfield+$700,X
                sta Playfield+$800,X
                sta Playfield+$900,X
                sta Playfield+$A00,X
                sta Playfield+$B00,X
                sta Playfield+$C00,X
                sta Playfield+$D00,X
                sta Playfield+$E00,X

                inx
                bne _nextByte

                plx
                pla
                plp
                rts
                .endproc


;======================================
; BlitPlayfield
;======================================
SetVideoRam     .proc
                php
                phx
                phy

                ; .m16
                lda #<>Video8K          ; Set the destination address
                sta zpDest
                lda #`Video8K
                sta zpDest+2
                ; .m8

                stz zpTemp2     ; HACK:

                ; .i16
                ldx #0
                stx zpIndex1            ; source pointer
                stx zpIndex2            ; destination pointer
                stx zpIndex3            ; column counter [0-39]

_nextByte       ldy zpIndex1
                lda (zpSource),Y

                inc zpIndex1            ; increment the byte counter (source pointer)
                bne _1
                inc zpIndex1+1
_1              inc zpIndex3            ; increment the column counter

                ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha

                lda zpTemp1
                beq _noColor
                cmp #1
                bne _noColor

                lda _planetColor
_noColor        ldy zpIndex2
                sta (zpDest),Y

;   duplicate this in the next line down (double-height)
                phy
                pha
                ; .m16
                tya
                clc
                adc #320
                tay
                ; .m8
                pla
                sta (zpDest),Y          ; double-height
                ply
;---

                iny
                sta (zpDest),Y          ; double-pixel

;   duplicate this in the next line down (double-height)
                phy
                pha
                ; .m16
                tya
                clc
                adc #320
                tay
                ; .m8
                pla
                sta (zpDest),Y          ; double-height
                ply
;---

                iny
                sty zpIndex2
                pla

                dex
                bpl _nextPixel

                ldx zpIndex3
                cpx #40
                bcc _checkEnd

                ;inc zpTemp2     ; HACK:
                ;lda zpTemp2
                ;cmp #12
                ;beq _XIT

                ; .m16
                lda zpIndex2            ; we already processed the next line (double-height)...
                clc
                adc #320                ; so move down one additional line
                sta zpIndex2

                inc _lineCounter
                lda _lineCounter
                ;lsr                   ; /2
                and #7
                tax
                lda _colorTable,X
                sta _planetColor

                lda #0
                sta zpIndex3            ; reset the column counter
                ; .m8

_checkEnd       ldx zpIndex1
                cpx #$1E0               ; 12 source lines... = 24 destination lines (~8K)
                bcs _XIT

                jmp _nextByte 

_XIT            ; .i8

                ply
                plx
                plp
                rts

;--------------------------------------

_lineCounter    .byte 0
_planetColor    .byte 3
_colorTable     .byte 6,7,8,7,6,5,4,5

                .endproc


;======================================
; 
;======================================
BlitVideoRam    .proc
                php
                pha

                ; .m16

                lda #$1E00              ; 24 lines (320 bytes/line)
                sta zpSize
                lda #0
                sta zpSize+2

                lda #<>Video8K          ; Set the source address
                sta zpSource
                lda #`Video8K
                sta zpSource+2

                ; .m8
                jsr Copy2VRAM

                pla
                plp
                rts
                .endproc


;======================================
; 
;======================================
BlitPlayfield   .proc
                php
                pha
                phx
                phy

                ldy #8
                ldx #0
                stx SetVideoRam._lineCounter

_nextBank       ;.m16
                lda _data_Source,X    ; Set the source address
                sta zpSource
                lda _data_Source+2,X
                and #$FF
                sta zpSource+2
                ; .m8

                jsr SetVideoRam

                ; .m16
                lda _data_Dest,X      ; Set the destination address
                sta zpDest
                lda _data_Dest+2,X
                and #$FF
                sta zpDest+2
                ; .m8

                phx
                phy
                jsr BlitVideoRam
                ply
                plx

                inx
                inx
                inx
                dey
                bpl _nextBank

                ply
                plx
                pla
                plp
                rts

;--------------------------------------

_data_Source    .long Playfield+$0000,Playfield+$01E0,Playfield+$03C0
                .long Playfield+$05A0,Playfield+$0780,Playfield+$0960
                .long Playfield+$0B40,Playfield+$0D20,Playfield+$0F00

_data_Dest      .long BITMAP0,BITMAP1,BITMAP2
                .long BITMAP3,BITMAP4,BITMAP5
                .long BITMAP6,BITMAP7,BITMAP8

                .endproc


;======================================
; Render Publisher
;======================================
RenderPublisher .proc
                php
                ; .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda MagMsg,Y
                cmp #$20
                beq _space

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+9*CharResX,X
                sta CS_TEXT_MEM_PTR+9*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+9*CharResX,X
                sta CS_TEXT_MEM_PTR+9*CharResX,X

                bra _nextChar

_letter         pha
                phx
                lda #$40
                sta CS_COLOR_MEM_PTR+9*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+9*CharResX,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+9*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+9*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle_obsolete .proc
                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda #$60
                sta CS_COLOR_MEM_PTR+11*CharResX,X
                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+11*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor_obsolete    .proc
                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$28
                beq _XIT

                lda AuthorMsg,Y
                cmp #$20
                beq _space

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+14*CharResX,X
                sta CS_TEXT_MEM_PTR+14*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+14*CharResX,X
                sta CS_TEXT_MEM_PTR+14*CharResX,X

                bra _nextChar

_letter         pha
                phx

                cpy #$14
                bcc _topLine

                lda #$30
                bra _cont
_topLine        lda #$10
_cont           sta CS_COLOR_MEM_PTR+14*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+14*CharResX,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+14*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+14*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect_obsolete    .proc
v_displayLine   .var 19*CharResX
;---

                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$3C
                beq _XIT

                lda StartMsg,Y
                cmp #$20
                beq _space

                cmp #$2D
                beq _dash

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar

_dash           lda #$C0
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                lda #$B4
                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                lda #$C0
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                lda #$B5
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar
_letter         pha
                phx
                cpy #$28
                bcc _topLine

                lda #$40
                bra _cont
_topLine        lda #$C0
_cont           sta CS_COLOR_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Score Line
;======================================
RenderScoreLine .proc
v_displayLine   .var 2*CharResX
;---
                php
                ; .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT2

                lda SCOLIN,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$2A
                beq _symbol

                cmp #$41
                bcc _number
                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar

_symbol         phx
                lda #$30
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                plx

                lda #$9E
                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar

_XIT2           bra _XIT

;   (ascii-30)*2+$A0
_number         pha
                cpy #$07
                bcs _lvl

_score          lda #$F0
                bra _cont

_lvl            lda #$20
_cont           phx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                plx
                pla

                sec
                sbc #$30
                asl
                clc
                adc #$A0

                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                bra _nextChar

_letter         pha

                phx
                lda #$20
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_displayLine,X
                plx
                pla

                sta CS_TEXT_MEM_PTR+v_displayLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_displayLine,X

                jmp _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Clear the play area of the screen
;======================================
ClearScreen     .proc
v_QtyPages      .var $04                ; 40x30 = $4B0... 4 pages + 176 bytes
                                        ; remaining 176 bytes cleared via ClearGamePanel

v_EmptyText     .var $00
v_TextColor     .var $40
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                stz zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_nextByteC      sta (zpDest),Y

                iny
                bne _nextByteC

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageC

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_nextByteT      sta (zpDest),Y

                iny
                bne _nextByteT

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageT

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Clear the bottom of the screen
;======================================
ClearGamePanel  .proc
v_EmptyText     .var $00
v_TextColor     .var $40
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   text color
                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore   .proc
v_RenderLine    .var 2*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore2  .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for two 40-char lines
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$50
                beq _processText

                lda TitleMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                bra _nextColor

;   process the text
_processText
;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
v_RenderLine    .var 26*CharResX
;---

                php

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda AuthorColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda AuthorMsg,Y
                beq _space
                cmp #$20
                beq _space

                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlyrQtyColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlyrQtyMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderPlayers   .proc
v_RenderLine    .var 26*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlayersMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlayersMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserves:
;   X Y
;======================================
RenderScore     .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy

;   if game is not in progress then exit
                lda zpWaitForPlay
                bne _XIT

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda ScoreMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda ScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$9B
                beq _bomb

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Canyon
;======================================
RenderCanyon    .proc
v_RenderLine    .var 13*CharResX
;---

                php
                pha
                phx
                phy

                ;ldx #$FFFF         ; TODO:
                ;ldy #$FFFF
                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                ;cpy #440           ; TODO:
                beq _XIT

                lda CANYON,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$84
                bcc _boulder

_earth          eor #$80
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$E0
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                pla
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_space

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$00
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_boulder

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                phy
                tay
                lda CanyonColors,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                ply

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #$01
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
InitSystemVectors .proc
                pha
                sei

                cld                     ; clear decimal

                ; lda #<DefaultHandler
                ; sta vecCOP
                ; lda #>DefaultHandler
                ; sta vecCOP+1

                lda #<DefaultHandler
                sta vecABORT
                lda #>DefaultHandler
                sta vecABORT+1

                ; lda #<DefaultHandler
                ; sta vecNMI
                ; lda #>DefaultHandler
                ; sta vecNMI+1

                ; lda #<INIT
                ; sta vecRESET
                ; lda #>INIT
                ; sta vecRESET+1

                lda #<DefaultHandler
                sta vecIRQ_BRK
                lda #>DefaultHandler
                sta vecIRQ_BRK+1

                cli
                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Default IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DefaultHandler  rti


;======================================
;
;======================================
InitMMU         .proc
                pha
                sei

                lda #mmuEditMode|mmuEditPage0|mmuPage0
                sta MMU_CTRL

                lda #$00                ; [0000:1FFF]
                sta MMU_Block0
                lda #$20                ; [2000:3FFF]
                sta MMU_Block1
                lda #$40                ; [4000:5FFF]
                sta MMU_Block2
                lda #$60                ; [6000:7FFF]
                sta MMU_Block3
                lda #$80                ; [8000:9FFF]
                sta MMU_Block4
                lda #$A0                ; [A000:BFFF]
                sta MMU_Block5
                lda #$C0                ; [C000:DFFF]
                sta MMU_Block6
                lda #$E0                ; [E000:FFFF]
                sta MMU_Block7

                lda #mmuPage0
                sta MMU_CTRL

                cli
                pla
                rts
                .endproc


;======================================
;
;======================================
InitIRQs        .proc
                pha

                sei                     ; disable IRQ

;   enable IRQ handler
                ;lda #<vecIRQ_BRK
                ;sta IRQ_PRIOR
                ;lda #>vecIRQ_BRK
                ;sta IRQ_PRIOR+1

                lda #<HandleIrq
                sta vecIRQ_BRK
                lda #>HandleIrq
                sta vecIRQ_BRK+1

;   initialize the console
                lda #$07
                sta CONSOL

;   initialize joystick/keyboard
                lda #$1F
                sta InputFlags
                stz InputType

;   enable Start-of-Frame IRQ
                lda INT_MASK_REG0
                and #~FNX0_INT00_SOF    
                sta INT_MASK_REG0

;   enable Keyboard IRQ
                lda INT_MASK_REG1
                and #~FNX1_INT00_KBD    
                sta INT_MASK_REG1

                cli                     ; enable IRQ
                pla
                rts
                .endproc


;======================================
;
;======================================
SetFont         .proc
                php
                pha
                phx
                phy

;   DEBUG: helpful if you need to see the trace
                ; bra _XIT

                lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1

;   switch to charset map
                lda #iopPage1
                sta IOPAGE_CTRL

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                stz zpDest+2

                ldx #$07                ; 7 pages
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   switch to system map
                stz IOPAGE_CTRL

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc
