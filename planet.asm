;--------------------------------------
; Display the Intro Screen
;--------------------------------------
PLANET          cld                     ;clear decimal
                lda #$00                ;get zero
                sta NMIEN               ;display off
                ldx #$7F                ;set index
CLPG0           sta $80,X               ;clr top page 0
                dex                     ;dec pointer
                bne CLPG0               ;done? No.

                inc TITLE               ;title on flag
                lda #$FF                ;get $FF
                sta LIVES               ;set dead
                sta GAMCTL              ;game control
                sta ESSCNT              ;no enemy shots
                sta PSSCNT              ;no player shots
                jsr SNDOFF              ;no sound on 123

                sta AUDC1+6             ;turn off snd 4
                lda #$C4                ;medium green
                sta COLOR0              ;score color
                lda #$84                ;medium blue
                sta COLOR0+1            ;text color
                lda #$0A                ;bright white
                sta COLOR0+2            ;shot color
                lda #$98                ;light blue
                sta COLOR0+3            ;text color
                lda #<DLI               ;set DLI vector
                sta VDSLST              ;low byte
                lda #>DLI               ;set DLI vector
                sta VDSLST+1            ;high byte
                lda #$C0                ;enable Display
                sta NMIEN               ;List Interrupts
                lda #$32                ;PM DMA off
                sta DMACTL              ;DMA control
                sta SDMCTL              ;and shadow reg
                lda #0                  ;get zero
                sta GRACTL              ;graphics ctrl
                sta AUDCTL              ;reset audio
                ldx #4                  ;5 PM registers
NOPM            sta GRAFP0,X            ;clr register
                dex                     ;dec index
                bpl NOPM                ;done? No.

                jsr SIOINV              ;init sound

                lda #<TLDL              ;DL addr low
                sta SDLSTL              ;DL pntr low
                lda #>TLDL              ;DL addr high
                sta SDLSTL+1            ;DL pntr high
                ldx #>VBLANK            ;vblank high
                ldy #<VBLANK            ;vblank low
                lda #7                  ;deferred
                jsr SETVBV              ;set vblank

                lda #60                 ;one second
                sta DEADTM              ;dead time

; --------------------------
; Check console and triggers
; --------------------------

START           lda DEADTM              ;look dead time
                bne START               ;alive? No.

CCHK            lda PTRIG0              ;paddle trig 0
                eor PTRIG1              ;mask w/PTRIG1
                bne PDEV                ;pushed? Yes.

                lda STRIG0              ;stick trig
                beq PDEV                ;pushed? Yes.

                lda CONSOL              ;get console
                and #3                  ;do START/SELECT
                cmp #3                  ;test buttons
                beq CCHK                ;any pushed? No.

                and #1                  ;mask off START
PDEV            sta DEVICE              ;device switch
RELWT           lda #10                 ;1/6 second
                sta DEADTM              ;dead time
RELWT2          lda DEADTM              ;debounce!
                bne RELWT2              ;time up? No.

                lda CONSOL              ;get console
                cmp #7                  ;keys released?
                bne RELWT               ;No. loop until


; ---------------------------
; Clear PM Area and Playfield
; ---------------------------

                lda #>SCRN              ;scrn addr high
                sta INDEX+1             ;pointer high
                lda #0                  ;get zero
                sta INDEX               ;pointer low
                ldx #15                 ;16 pages 0..15
                tay                     ;use as index
CL0             sta (INDEX),Y           ;clear ram
                iny                     ;next byte
                bne CL0                 ;page done? No.

                inc INDEX+1             ;next page
                dex                     ;page counter
                bpl CL0                 ;scrn done? No.

                ldx #0                  ;now clear P/m
CLPM            sta MISL,X              ;clear missiles
                sta PLR0,X              ;clear plyr 0
                sta PLR1,X              ;clear plyr 1
                sta PLR2,X              ;clear plyr 2
                sta PLR3,X              ;clear plyr 3
                dex                     ;done 256 bytes?
                bne CLPM                ;no, loop back!

                lda #<GLIST             ;Point to the
                sta SDLSTL              ;game display
                lda #>GLIST             ;list to show
                sta SDLSTL+1            ;the playfield.
                lda #>PM                ;PM address high
                sta PMBASE              ;into hardware
                lda #$3E                ;enable single
                sta SDMCTL              ;line resolution
                sta DMACTL              ;DMA control
                lda #3                  ;enable player
                sta GRACTL              ;and missile DMA
                lda #$11                ;set up
                sta GPRIOR              ;P/M priority
                lda #0                  ;get zero
                sta TITLE               ;title off

; ---------------
; Draw The Planet
; ---------------

                lda #<PPOS              ;planet pos high
                sta INDX1               ;pointer #1 low
                sta INDX2               ;pointer #2 low
                lda #>PPOS              ;planet pos high
                sta INDX1+1             ;pointer #1 high
                sta INDX2+1             ;pointer #2 high
                ldx #0                  ;table pointer
DP0             ldy #0                  ;index pointer
DP1             lda DPTBL,X             ;table value
                bne DP2                 ;done? No.

                jmp SETUP               ;continue

DP2             bmi DPRPT               ;repeat? Yes.

                sta (INDX1),Y           ;put values
                sta (INDX2),Y           ;onto screen
                iny                     ;inc index pntr
                inx                     ;inc table pntr
                jmp DP1                 ;continue


; -------------------
; Repeat Byte Handler
; -------------------

DPRPT           asl A                   ;shift byte
                sta TEMP                ;new line flag
                asl A                   ;NL bit -> carry
                asl A                   ;color -> carry
                lda #$55                ;color 1 bits
                bcs FILL1               ;color 1? Yes.

                lda #0                  ;get background
FILL1           pha                     ;save color byte
                lda DPTBL,X             ;table value
                and #$0F                ;mask 4 bits
                sta COUNT               ;save as count
                pla                     ;restore color
FILL2           sta (INDX1),Y           ;put bytes
                sta (INDX2),Y           ;onto screen
                iny                     ;inc index
                dec COUNT               ;dec byte count
                bne FILL2               ;done? No.

                inx                     ;inc table index
                lda TEMP                ;get flag
                bpl DP1                 ;new line? No.

                sec                     ;set carry
                lda INDX1               ;Yes. get low
                sbc #40                 ;subtract 40
                sta INDX1               ;new low
                bcs DPN1                ;overflow? No.

                dec INDX1+1             ;decrement high
DPN1            clc                     ;clear carry
                lda INDX2               ;get low
                adc #40                 ;add 40
                sta INDX2               ;new low
                bcc DP0                 ;overflow? No.

                inc INDX2+1             ;increment high
                jmp DP0                 ;continue


; ----------------
; Planet Draw Data
; ----------------

DPTBL           .byte $EA,$EA,$EA,$EA
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
