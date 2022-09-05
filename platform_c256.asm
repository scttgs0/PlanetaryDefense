VRAM            = $B00000               ; First byte of video RAM

SPRITES         = VRAM
BITMAP          = VRAM+$2000

BITMAP0         = $2000+$1E00
BITMAP1         = BITMAP0+$1E00
BITMAP2         = BITMAP1+$1E00
BITMAP3         = BITMAP2+$1E00
BITMAP4         = BITMAP3+$1E00
BITMAP5         = BITMAP4+$1E00
BITMAP6         = BITMAP5+$1E00
BITMAP7         = BITMAP6+$1E00
BITMAP8         = BITMAP7+$1E00


;======================================
; seed = elapsed seconds this hour
;======================================
Random_Seed     .proc
                .m8
                lda RTC_MIN
                sta RND_MIN
                lda RTC_SEC
                sta RND_SEC

                .m16
;   elapsed minutes * 60
                lda RND_MIN
                asl A
                asl A
                pha
                asl A
                pha
                asl A
                pha
                asl A
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

;   + elapsed seconds
                lda RND_SEC
                adc RND_RESULT

                sta GABE_RNG_SEED_LO

                .m8
                lda #grcEnable|grcDV
                sta GABE_RNG_CTRL
                lda #grcEnable
                sta GABE_RNG_CTRL
                .endproc


;======================================
; Initialize SID
;======================================
InitSID         .proc
                pha
                phx
                .m8i8

;   reset the SID
                lda #$00
                ldx #$18
_next1          sta $AF_E400,X
                dex
                bpl _next1

                lda #$09                ; Attack/Decay = 9
                sta SID_ATDCY1
                sta SID_ATDCY2
                sta SID_ATDCY3

                lda #$00                ; Susatain/Release = 0
                sta SID_SUREL1
                sta SID_SUREL2
                sta SID_SUREL3

                ;lda #$21
                ;sta SID_CTRL1
                ;sta SID_CTRL2
                ;sta SID_CTRL3

                lda #$0F                ; Volume = 15 (max)
                sta SID_SIGVOL

                plx
                pla
                rts
                .endproc


;======================================
; Create the lookup table (LUT)
;======================================
InitLUT         .proc
                php
                phb                     ; required for mvn
                pha
                phx
                phy

                .m16i16
                lda #Palette_end-Palette ; Copy the palette to LUT0
                ldx #<>Palette
                ldy #<>GRPH_LUT0_PTR
                mvn `Palette,`GRPH_LUT0_PTR

                .m8i8
                ply
                plx
                pla
                plb
                plp
                rts
                .endproc


;======================================
; Initialize the CHAR_LUT tables
;======================================
InitCharLUT     .proc
v_LUTSize       .var 64                 ; 4-byte color * 16 colors
;---

                pha
                phx
                .m8i8

                ldx #$00
_next1          lda Custom_LUT,x
                sta FG_CHAR_LUT_PTR,x
                sta BG_CHAR_LUT_PTR,x

                inx
                cpx #v_LUTSize
                bne _next1

                plx
                pla
                rts

;--------------------------------------

Custom_LUT      .dword $00282828        ; 0: Dark Jungle Green  [Editor Text bg]
                .dword $00DDDDDD        ; 1: Gainsboro          [Editor Text fg]
                .dword $00143382        ; 2: Saint Patrick Blue [Editor Info bg][Dialog bg]
                .dword $006B89D7        ; 3: Blue Gray          [Editor Info fg][Dialog fg]
                .dword $00693972        ; 4: Indigo             [Monitor Info bg]
                .dword $00B561C2        ; 5: Deep Fuchsia       [Monitor Info fg][Window Split]
                .dword $0076ADEB        ; 6: Maya Blue          [Reserved Word]
                .dword $007A7990        ; 7: Fern Green         [Comment]
                .dword $0074D169        ; 8: Moss Green         [Constant]
                .dword $00D5CD6B        ; 9: Medium Spring Bud  [String]
                .dword $00C563BD        ; A: Pastel Violet      [Loop Control]
                .dword $005B8B46        ; B: Han Blue           [ProcFunc Name]
                .dword $00BC605E        ; C: Medium Carmine     [Define]
                .dword $00C9A765        ; D: Satin Sheen Gold   [Type]
                .dword $0062C36B        ; E: Mantis Green       [Highlight]
                .dword $0003540A        ; F: Pakistan Green     [Warning]

                .endproc


;======================================
; Initialize the Title Screen layer
;======================================
InitTitleScreen .proc
                php
                phb

                jsr RefreshTitleScreen

                .m16
                lda #<>(TILEMAP-VRAM)   ; Set the pointer to the tile map
                sta TILE3_START_ADDR
                .m8
                lda #`(TILEMAP-VRAM)
                sta TILE3_START_ADDR+2

                .m16
                lda #MAPWIDTH                ; Set the size of the tile map
                sta TILE3_X_SIZE
                lda #MAPHEIGHT
                sta TILE3_Y_SIZE

                lda #$00
                sta TILE3_WINDOW_X_POS
                sta TILE3_WINDOW_Y_POS

                .m8
                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE3_CTRL

                plb
                plp
                rts
                .endproc


;======================================
;
;======================================
RefreshTitleScreen .proc
                php
                .setbank `TitleScreenData

                .m8i16
                ldx #0
                ldy #0
_nextTile       lda TitleScreenData,Y   ; Get the tile code
                and #$7F
                sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAP,X

                inx                     ; move to the next tile
                iny
                cpy #MAPWIDTH*18        ; top 18 lines are graphic
                bne _nextTile

_nextGlyph      lda TitleScreenData,Y   ; Get the tile code
                ora #$80
                sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAP,X

                inx                     ; move to the next tile
                iny
                cpy #MAPWIDTH*MAPHEIGHT-18  ; bottom lines are text
                bne _nextGlyph

                .setbank $00
                plp
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                php
                phb

                .m16i16
                lda #Stamps_end-Stamps  ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>Stamps           ; Set the source address
                sta zpSource
                lda #`Stamps
                sta zpSource+2

                lda #`(SPRITES-VRAM)
                sta zpDest+2
                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta zpDest

;   cursor
                sta SP00_ADDR           ; And set the Vicky register

;   satellite/orbiter
                clc
                adc #$400               ; 1024
                sta SP01_ADDR

;   bomb left
                clc
                adc #$800               ; 1024*2
                sta SP04_ADDR
                sta SP05_ADDR
                sta SP06_ADDR
                sta SP07_ADDR

;   bomb right
                clc
                adc #$400               ; 1024
                sta SP08_ADDR
                sta SP09_ADDR
                sta SP10_ADDR
                sta SP11_ADDR

;   saucer
                clc
                adc #$400               ; 1024
                sta SP03_ADDR

                .m8
                lda #0
                sta SP00_ADDR+2
                sta SP01_ADDR+2
                sta SP03_ADDR+2
                sta SP04_ADDR+2
                sta SP05_ADDR+2
                sta SP06_ADDR+2
                sta SP07_ADDR+2
                sta SP08_ADDR+2
                sta SP09_ADDR+2
                sta SP10_ADDR+2
                sta SP11_ADDR+2

                jsr Copy2VRAM

                .m16
                lda #$40
                sta SP00_X_POS
                lda #$60
                sta SP01_X_POS
                lda #$80
                sta SP03_X_POS
                lda #$A0
                sta SP04_X_POS
                lda #$C0
                sta SP08_X_POS

                lda #$40
                sta SP00_Y_POS
                sta SP01_Y_POS
                sta SP03_Y_POS
                sta SP04_Y_POS
                sta SP05_Y_POS
                sta SP06_Y_POS
                sta SP07_Y_POS
                sta SP08_Y_POS
                sta SP09_Y_POS
                sta SP10_Y_POS
                sta SP11_Y_POS

                .m8
                lda #scEnable
                sta SP00_CTRL
                sta SP01_CTRL
                sta SP03_CTRL
                sta SP04_CTRL
                sta SP05_CTRL
                sta SP06_CTRL
                sta SP07_CTRL
                sta SP08_CTRL
                sta SP09_CTRL
                sta SP10_CTRL
                sta SP11_CTRL

                plb
                plp
                rts
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                php
                phx

                .m16
                lda #<>(BITMAP-VRAM)   ; Set the destination address
                sta BITMAP0_START_ADDR ; And set the Vicky register

                .m8
                lda #`(BITMAP-VRAM)
                sta BITMAP0_START_ADDR+2

                lda #bmcEnable
                sta BITMAP0_CTRL

                plx
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

                .m16
                lda #<>Video8K          ; Set the destination address
                sta zpDest
                lda #`Video8K
                sta zpDest+2
                .m8

                stz zpTemp2     ; HACK:

                .i16
                ldx #0
                stx zpIndex1
                stx zpIndex2
                stx zpIndex3

_nextByte       ldy zpIndex1
                lda [zpSource],Y

                inc zpIndex1            ; increment the byte counter (source pointer)
                bne _1
                inc zpIndex1+1
_1              inc zpIndex3            ; increment the column counter

                ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl A
                rol zpTemp1
                asl A
                rol zpTemp1
                pha

                lda zpTemp1
                ldy zpIndex2
                sta [zpDest],Y

;   duplicate this in the next line down (double-height)
                phy
                pha
                .m16
                tya
                clc
                adc #320
                tay
                .m8
                pla
                sta [zpDest],Y          ; double-height
                ply
;---

                iny
                sta [zpDest],Y          ; double-pixel

;   duplicate this in the next line down (double-height)
                phy
                pha
                .m16
                tya
                clc
                adc #320
                tay
                .m8
                pla
                sta [zpDest],Y          ; double-height
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

                inc zpTemp2     ; HACK:
                lda zpTemp2
                cmp #12
                beq _XIT

                .m16
                lda zpIndex2            ; we already processed the next line (double-height)...
                clc
                adc #320                ; so move down one additional line
                sta zpIndex2

                lda #0
                sta zpIndex3            ; reset the column counter
                .m8

_checkEnd       ldx zpIndex1
                cpx #$1E0               ; 12 source lines... = 24 destination lines (~8K)
                bcc _nextByte 

_XIT            .i8

                ply
                plx
                plp
                rts
                .endproc


;======================================
; 
;======================================
BlitVideoRam    .proc
                php
                pha

                .m16

                lda #$1E00              ; 24 lines (320 bytes/line)
                sta zpSize
                lda #0
                sta zpSize+2

                lda #<>Video8K          ; Set the source address
                sta zpSource
                lda #`Video8K
                sta zpSource+2

                .m8
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

_nextBank       .m16
                lda _data_Source,X    ; Set the source address
                sta zpSource
                lda _data_Source+2,X
                and #$FF
                sta zpSource+2
                .m8

                jsr SetVideoRam

                .m16
                lda _data_Dest,X      ; Set the destination address
                sta zpDest
                lda _data_Dest+2,X
                and #$FF
                sta zpDest+2
                .m8

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
                .m8i8

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_next1C         sta [zpDest],Y

                iny
                bne _next1C

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageC

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_next1T         sta [zpDest],Y

                iny
                bne _next1T

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageT

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
;---

                php
                .m8i8

                lda #<CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

                lda #<CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

                plp
                rts
                .endproc


;======================================
; Render Publisher
;======================================
RenderPublisher .proc
                php
                .m8i8

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
RenderTitle     .proc
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
RenderAuthor    .proc
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
RenderSelect    .proc
v_displayLine   .var 19*CharResX
;---

                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$28
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
                cpy #$14
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
                .m8i8

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
                asl A
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
; Blit bitmap text to VRAM
;--------------------------------------
; on entry:
;   zpDest      set by caller
;======================================
BlitText        .proc
                php
                phb
                .m16i16

                lda #640*16             ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>Text2Bitmap      ; Set the source address
                sta zpSource
                lda #`Text2Bitmap
                sta zpSource+2

                jsr Copy2VRAM

                plb
                plp
                rts
                .endproc


;======================================
; Copying data from system RAM to VRAM
;--------------------------------------
; Inputs (pushed to stack, listed top down)
;   zpSource = address of source data (should be system RAM)
;   zpDest = address of destination (should be in video RAM)
;   zpSize = number of bytes to transfer
;
; Outputs:
;   None
;======================================
Copy2VRAM       .proc
                php
                phb
                .setbank `SDMA_SRC_ADDR
                .setdp zpSource
                .m8i8

    ; Set SDMA to go from system to video RAM, 1D copy
                lda #sdcSysRAM_Src|sdcEnable
                sta SDMA0_CTRL

    ; Set VDMA to go from system to video RAM, 1D copy
                lda #vdcSysRAM_Src|vdcEnable
                sta VDMA_CTRL

                .m16i8
                lda zpSource            ; Set the source address
                sta SDMA_SRC_ADDR
                ldx zpSource+2
                stx SDMA_SRC_ADDR+2

                lda zpDest              ; Set the destination address
                sta VDMA_DST_ADDR
                ldx zpDest+2
                stx VDMA_DST_ADDR+2

                lda zpSize              ; Set the size of the block
                sta SDMA_SIZE
                sta VDMA_SIZE
                lda zpSize+2
                sta SDMA_SIZE+2
                sta VDMA_SIZE+2

                .m8
                lda VDMA_CTRL           ; Start the VDMA
                ora #vdcStart_TRF
                sta VDMA_CTRL

                lda SDMA0_CTRL          ; Start the SDMA
                ora #sdcStart_TRF
                sta SDMA0_CTRL

                nop                     ; VDMA involving system RAM will stop the processor
                nop                     ; These NOPs give Vicky time to initiate the transfer and pause the processor
                nop                     ; Note: even interrupt handling will be stopped during the DMA
                nop

wait_vdma       lda VDMA_STATUS         ; Get the VDMA status
                bit #vdsSize_Err|vdsDst_Add_Err|vdsSrc_Add_Err
                bne vdma_err            ; Go to monitor if there is a VDMA error
                bit #vdsVDMA_IPS        ; Is it still in process?
                bne wait_vdma           ;   Yes: keep waiting

                lda #0                  ; Make sure DMA registers are cleared
                sta SDMA0_CTRL
                sta VDMA_CTRL

                .setdp $0000
                .setbank $00
                .m8i8
                plb
                plp
                rts

vdma_err        lda #0                  ; Make sure DMA registers are cleared
                sta SDMA0_CTRL
                sta VDMA_CTRL

                .setdp $0000
                .setbank $00
                .m8i8
                plb
                plp

                jmp Copy2VRAM           ; retry
                .endproc


;======================================
;
;======================================
InitIRQs        .proc
                pha

;   enable vertical blank interrupt
                .m8i8
                ldx #HandleIrq.HandleIrq_END-HandleIrq
_relocate       ;lda @l $024000,X        ; HandleIrq address
                ;sta @l $002000,X        ; new address within Bank 00
                ;dex
                ;bpl _relocate

                sei                     ; disable IRQ

                .m16
                ;lda @l vecIRQ
                ;sta IRQ_PRIOR

                lda #<>HandleIrq
                sta @l vecIRQ

                .m8
                lda #$07                ; reset consol
                sta CONSOL

                lda #$1F
                sta InputFlags
                stz InputType           ; joystick

;   enable Start-of-Frame + Start-of-Line IRQs
                lda #160
                sta DLI_LINE0_LO
                lda #1
                sta DLI_CTRL

                lda @l INT_MASK_REG0
                and #~(FNX0_INT00_SOF|FNX0_INT01_SOL)
                ;and #~FNX0_INT01_SOL
                sta @l INT_MASK_REG0

;   enable Keyboard IRQ
                lda @l INT_MASK_REG1
                and #~FNX1_INT00_KBD
                sta @l INT_MASK_REG1

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

                .m8i8
                lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                lda #`GameFont
                sta zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                lda #`FONT_MEMORY_BANK0
                sta zpDest+2

                ldx #$08                ; 8 pages
_nextPage       ldy #$00
_next1          lda [zpSource],Y
                sta [zpDest],Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc
