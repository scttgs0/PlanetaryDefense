
; SPDX-FileName: platform_f256.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
; seed = quick and dirty
;--------------------------------------
; preserve      A
;======================================
RandomSeedQuick .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda RTC_MIN
                sta RNG_SEED+1

                lda RTC_SEC
                sta RNG_SEED

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; seed = elapsed seconds this hour
;--------------------------------------
; preserve      A
;======================================
RandomSeed      .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

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

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Convert BCD to Binary
;======================================
Bcd2Bin         .proc
                pha

;   upper-nibble * 10
                lsr
                pha                     ; n*2
                lsr
                lsr                     ; n*8
                sta _tmp

                pla                     ; A=n*2
                clc
                adc _tmp                ; A=n*8+n*2 := n*10
                sta _tmp

;   add the lower-nibble
                pla
                and #$0F
                clc
                adc _tmp

                rts

;--------------------------------------

_tmp            .byte $00

                .endproc


;======================================
; Convert BCD to Binary
;======================================
Bin2Bcd         .proc
                ldx #00
                ldy #00
_next1          cmp #10
                bcc _done

                sec
                sbc #10

                inx
                bra _next1

_done           tay
                txa
                asl
                asl
                asl
                asl
                and #$F0
                sta _tmp

                tya
                clc
                adc _tmp

                rts

;--------------------------------------

_tmp            .byte $00

                .endproc


;======================================
; Initialize SID
;--------------------------------------
; preserve      A, X
;======================================
InitSID         .proc
                pha
                phx

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #0                  ; reset the SID registers
                ldx #$1F
_next1          sta SID1_BASE,X
                sta SID2_BASE,X

                dex
                bpl _next1

                lda #sidAttack2ms|sidDecay750ms
                sta SID1_ATDCY1
                sta SID1_ATDCY2
                sta SID1_ATDCY3
                sta SID2_ATDCY1

                ; 0%|sidDecay6ms
                stz SID1_SUREL1         ; Sustain/Release = 0 [square wave]
                stz SID1_SUREL2
                stz SID1_SUREL3
                stz SID2_SUREL1

                lda #sidcSaw|sidcGate
                sta SID1_CTRL1
                sta SID1_CTRL2
                sta SID1_CTRL3
                sta SID2_CTRL1

                lda #$08                ; Volume = 8 (mid-range)
                sta SID1_SIGVOL
                sta SID2_SIGVOL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize PSG
;--------------------------------------
; preserve      A, X
;======================================
InitPSG         .proc
                pha
                phx

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #0                  ; reset the PSG registers
                ldx #$07
_next1          sta PSG1_BASE,X
                sta PSG2_BASE,X

                dex
                bpl _next1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize the text-color LUT
;--------------------------------------
; preserve      A, Y
;======================================
InitTextPalette .proc
                pha
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                ldy #$3F
_next1          lda _Text_CLUT,Y
                sta FG_CHAR_LUT_PTR,Y   ; same palette for foreground and background
                sta BG_CHAR_LUT_PTR,Y

                dey
                bpl _next1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

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
;--------------------------------------
; preserve      A, Y
;======================================
InitGfxPalette  .proc
                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to graphic map
                lda #$01
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
;   palette 0
                lda #<Palette
                sta zpSource
                lda #>Palette
                sta zpSource+1
                stz zpSource+2

                lda #<GRPH_LUT0_PTR
                sta zpDest
                lda #>GRPH_LUT0_PTR
                sta zpDest+1
                stz zpDest+2

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

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;--------------------------------------
; preserve      A
;======================================
InitSprites     .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   set sprites
                .frsSpriteInit SPR_Cursor,     scEnable|scLUT0|scDEPTH0|scSIZE_16, IDX_PLYR
                .frsSpriteInit SPR_SatelliteA, scEnable|scLUT0|scDEPTH0|scSIZE_16, IDX_SATE
                .frsSpriteInit SPR_Saucer,     scEnable|scLUT0|scDEPTH0|scSIZE_16, IDX_SAUC
                .frsSpriteInit SPR_BombL,      scEnable|scLUT0|scDEPTH0|scSIZE_16, IDX_BOMB

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Clear all Sprites
;======================================
ClearSprites    .proc
;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 0
                .frsSpriteClear 1
                .frsSpriteClear 3
                .frsSpriteClear 4
                .frsSpriteClear 5
                .frsSpriteClear 6
                .frsSpriteClear 7
                .frsSpriteClear 8
                .frsSpriteClear 9
                .frsSpriteClear 10
                .frsSpriteClear 11
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #<ScreenRAM         ; Set the destination address
                sta BITMAP2_ADDR
                lda #>ScreenRAM
                sta BITMAP2_ADDR+1
                lda #`ScreenRAM
                sta BITMAP2_ADDR+2

                lda #bmcEnable|bmcLUT0
                sta BITMAP2_CTRL

                lda #locLayer2_BM2
                sta LAYER_ORDER_CTRL_1

                stz BITMAP0_CTRL        ; disabled
                stz BITMAP1_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Clear Playfield
;====================================== ;;;
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
;====================================== ;;;
SetVideoRam     .proc
                php
                phx
                phy

                ;!!.m16
                ;!!lda #<>Video8K          ; Set the destination address
                ;!!sta zpDest
                ;!!lda #`Video8K
                ;!!sta zpDest+2
                ;!!.m8

                stz zpTemp2     ; HACK:

                ;!!.i16
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
                ;!!.m16
                tya
                clc
                ;!!adc #320
                tay
                ;!!.m8
                pla
                sta (zpDest),Y          ; double-height
                ply
;---

                iny
                sta (zpDest),Y          ; double-pixel

;   duplicate this in the next line down (double-height)
                phy
                pha
                ;!!.m16
                tya
                clc
                ;!!adc #320
                tay
                ;!!.m8
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

                ;!!.m16
                lda zpIndex2            ; we already processed the next line (double-height)...
                clc
                ;!!adc #320                ; so move down one additional line
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
                ;!!.m8

_checkEnd       ldx zpIndex1
                ;!!cpx #$1E0               ; 12 source lines... = 24 destination lines (~8K)
                bcs _XIT

                jmp _nextByte

_XIT            ;!!.i8

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
;====================================== ;;;
BlitVideoRam    .proc
                php
                pha

                ;!!.m16

                ;!!lda #$1E00              ; 24 lines (320 bytes/line)
                sta zpSize
                lda #0
                sta zpSize+2

                ;!!lda #<>Video8K          ; Set the source address
                ;!!sta zpSource
                ;!!lda #`Video8K
                ;!!sta zpSource+2

                ;!!.m8
                ;!!jsr Copy2VRAM

                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
; BlitPlayfield   .proc
;                 php
;                 pha
;                 phx
;                 phy

;                 ldy #8
;                 ldx #0
;                 stx SetVideoRam._lineCounter

; _nextBank       ;!!.m16
;                 lda _data_Source,X    ; Set the source address
;                 sta zpSource
;                 lda _data_Source+2,X
;                 and #$FF
;                 sta zpSource+2
;                 ;!!.m8

;                 jsr SetVideoRam

;                 ;!!.m16
;                 lda _data_Dest,X      ; Set the destination address
;                 sta zpDest
;                 lda _data_Dest+2,X
;                 and #$FF
;                 sta zpDest+2
;                 ;!!.m8

;                 phx
;                 phy
;                 jsr BlitVideoRam
;                 ply
;                 plx

;                 inx
;                 inx
;                 inx
;                 dey
;                 bpl _nextBank

;                 ply
;                 plx
;                 pla
;                 plp
;                 rts

; ;--------------------------------------

; _data_Source    .long Playfield+$0000,Playfield+$01E0,Playfield+$03C0
;                 .long Playfield+$05A0,Playfield+$0780,Playfield+$0960
;                 .long Playfield+$0B40,Playfield+$0D20,Playfield+$0F00

; _data_Dest      ;!!.long BITMAP0,BITMAP1,BITMAP2
;                 ;!!.long BITMAP3,BITMAP4,BITMAP5
;                 ;!!.long BITMAP6,BITMAP7,BITMAP8

                ; .endproc


;======================================
; Clear the play area of the screen
;--------------------------------------
; preserve      A, X, Y
;======================================
ClearScreen     .proc
v_QtyPages      .var $05                ; 40x30 = $4B0... 4 pages + 176 bytes

v_EmptyText     .var $00
v_TextColor     .var $40
;---

                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

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

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
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
; Reset the CPU IRQ vectors
;--------------------------------------
; prior to calling this:
;   ensure MMU slot 7 is configured
;   ensure SEI is active
;--------------------------------------
; preserve      A
;======================================
InitCPUVectors  .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

                lda #<DefaultHandler
                sta vecABORT
                lda #>DefaultHandler
                sta vecABORT+1

                lda #<BOOT
                sta vecRESET
                lda #>BOOT
                sta vecRESET+1

                lda #<DefaultHandler
                sta vecIRQ_BRK
                lda #>DefaultHandler
                sta vecIRQ_BRK+1

                cli

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Default IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DefaultHandler  rti


;======================================
; Reset the MMU slots
;--------------------------------------
; prior to calling this:
;   ensure SEI is active
;--------------------------------------
; preserve      A
;               IOPAGE_CTRL
;               MMU_CTRL
;======================================
InitMMU         .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$00                ; [0000:1FFF]
                sta MMU_Block0
                inc A                   ; [2000:3FFF]
                sta MMU_Block1
                inc A                   ; [4000:5FFF]
                sta MMU_Block2
                inc A                   ; [6000:7FFF]
                sta MMU_Block3
                inc A                   ; [8000:9FFF]
                sta MMU_Block4
                inc A                   ; [A000:BFFF]
                sta MMU_Block5
                inc A                   ; [C000:DFFF]
                sta MMU_Block6
                inc A                   ; [E000:FFFF]
                sta MMU_Block7

;   restore MMU control
                pla
                sta MMU_CTRL

                cli

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Configure IRQ Handlers
;--------------------------------------
; prior to calling this:
;   ensure SEI is active
;--------------------------------------
; preserve      A
;======================================
InitIRQs        .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei                     ; disable IRQ

;   enable IRQ handler
                ;lda #<vecIRQ_BRK
                ;sta IRQ_PRIOR
                ;lda #>vecIRQ_BRK
                ;sta IRQ_PRIOR+1

                lda #<irqMain
                sta vecIRQ_BRK
                lda #>irqMain
                sta vecIRQ_BRK+1

;   initialize the console
                lda #$07
                sta CONSOL

;   initialize joystick/keyboard
                lda #$1F
                sta InputFlags
                ; sta InputFlags+1
                stz InputType           ; =joystick
                ; stz InputType+1

;   disable all IRQ
                lda #$FF
                sta INT_EDGE_REG0
                sta INT_EDGE_REG1
                sta INT_EDGE_REG2
                sta INT_MASK_REG0
                sta INT_MASK_REG1
                sta INT_MASK_REG2

;   clear pending interrupts
                lda INT_PENDING_REG0
                sta INT_PENDING_REG0
                lda INT_PENDING_REG1
                sta INT_PENDING_REG1
                lda INT_PENDING_REG2
                sta INT_PENDING_REG2

;   enable Start-of-Frame IRQ
                lda INT_MASK_REG0
                and #~INT00_SOF
                sta INT_MASK_REG0

;   enable Keyboard IRQ
                ; lda INT_MASK_REG1
                ; and #~INT01_VIA1
                ; sta INT_MASK_REG1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                cli                     ; enable IRQ
                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; preserve      A, X, Y
;======================================
SetFont         .proc
                pha
                phx
                phy

;   DEBUG: helpful if you need to see the trace
                ; bra _XIT

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to charset map
                lda #iopPage1
                sta IOPAGE_CTRL

;   Font #0
FONT0           lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                stz zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                stz zpDest+2

                ldx #$08                ; 8 pages
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

_XIT            ply
                plx
                pla
                rts
                .endproc
