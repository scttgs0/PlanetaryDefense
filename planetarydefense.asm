
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
;-------------------


                .include "equates_system_atari8.asm"
                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "atari-screen-inverse"
                .cdef " @",$C0
                .cdef "AZ",$A1
                .cdef "az",$E1
            .enc "none"


;--------------------------------------
;--------------------------------------
                * = TLDL-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00

                jmp PLANET


; -------------
; Start of game
; -------------

;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

; ------------------
; Intro Display List
; ------------------

TLDL            .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr MAGMSG

                .byte AEMPTY8
                .byte 7

                .byte AEMPTY8
                .byte 6

                .byte AEMPTY2
                .byte 6

                .byte AEMPTY8,AEMPTY8
                .byte 6

                .byte AEMPTY3
                .byte 6

                .byte AEMPTY5
                .byte 6

                .byte AVB+AJMP
                    .addr TLDL

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

; -----------------
; Game Display List
; -----------------

GLIST           .byte AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr SCOLIN

                .byte $0D+ALMS
                    .addr SCRN

                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D,$8D
                .byte $8D,$8D,$8D

                .byte AVB+AJMP
                    .addr GLIST


;--------------------------------------
; Display the Intro Screen
;--------------------------------------
PLANET          .frsGraphics mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                cld                     ;clear decimal

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


;--------------------------------------
; Setup Orbiter Coordinates
;--------------------------------------
SETUP           ldx #64                 ;do 65 bytes
                ldy #0                  ;quad 2/4 offset
SU1             clc                     ;clear carry
                lda #96                 ;center Y
                adc OYTBL,X             ;add offset Y
                sta ORBY+$40,Y          ;quad-2 Y
                sta ORBY+$80,X          ;quad-3 Y
                lda #80                 ;center X
                adc OXTBL,X             ;add offset X
                sta ORBX,X              ;quad-1 X
                sta ORBX+$40,Y          ;quad-2 X
                sec                     ;set carry
                lda #80                 ;center X
                sbc OXTBL,X             ;sub offset X
                sta ORBX+$80,X          ;quad-3 X
                sta ORBX+$C0,Y          ;quad-4 X
                lda #96                 ;center Y
                sbc OYTBL,X             ;sub offset Y
                sta ORBY,X              ;quad-1 Y
                sta ORBY+$C0,Y          ;quad-4 Y
                iny                     ;quad 2/4 offset
                dex                     ;quad 1/3 offset
                bpl SU1                 ;done? No.

                jmp INIT                ;continue

; ---------------------------
; Orbiter X,Y Coordinate Data
; ---------------------------

OXTBL           .byte 0,1,2,2,3
                .byte 4,5,5,6,7
                .byte 8,9,9,10,11
                .byte 12,12,13,14,14
                .byte 15,16,16,17,18
                .byte 18,19,20,20,21
                .byte 21,22,23,23,24
                .byte 24,25,25,26,26
                .byte 27,27,27,28,28
                .byte 29,29,29,30,30
                .byte 30,30,31,31,31
                .byte 31,31,32,32,32
                .byte 32,32,32,32,32

OYTBL           .byte 54,54,54,54,54
                .byte 54,54,54,53,53
                .byte 53,52,52,52,51
                .byte 51,50,50,49,49
                .byte 48,47,47,46,45
                .byte 44,44,43,42,41
                .byte 40,39,38,38,37
                .byte 36,35,33,32,31
                .byte 30,29,28,27,26
                .byte 24,23,22,21,20
                .byte 18,17,16,15,13
                .byte 12,11,9,8,7
                .byte 5,4,3,1,0


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

; ----------------
; Initialize Misc.
; ----------------

INIT            lda #0                  ;zero out..
                sta SCORE               ;score byte 0
                sta SCORE+1             ;score byte 1
                sta SCORE+2             ;score byte 2
                sta DEADTM              ;dead timer
                sta PAUSED              ;pause flag
                sta EXPCNT              ;expl. counter
                sta SAUCER              ;no saucer
                sta BLEVEL              ;bomb level
                ldx #11                 ;no bombs!
CLRACT          sta BOMACT,X            ;deactivate
                dex                     ;next bomb
                bpl CLRACT              ;done? No.

                ldx #19                 ;zero score line
INISLN          lda SCOINI,X            ;get byte
                sta SCOLIN,X            ;put score line
                dex                     ;next byte
                bpl INISLN              ;done? No.

                lda #$01                ;get one
                sta LEVEL               ;game level
                sta SATLIV              ;live satellite
                lda #4                  ;get 4
                sta LIVES               ;number of lives
                lda #$0C                ;set explosion
                sta COLOR0+2            ;brightness
                lda #$34                ;medium red
                sta PCOLR0              ;bomb 0 color
                sta PCOLR0+1            ;bomb 1 color
                sta PCOLR0+2            ;bomb 2 color
                lda #127                ;center screen X
                sta CURX                ;cursor X pos
                lda #129                ;center screen Y
                sta CURY                ;cursor Y pos
                lda #1                  ;get one
                sta GAMCTL              ;game control
                jsr SHOSCO              ;display score

                lda #$54                ;graphic-LF of
                sta SCRN+1939           ;planet center
                lda #$15                ;graphic-RT of
                sta SCRN+1940           ;planet center
                sta HITCLR              ;reset collision


;--------------------------------------
; Set up level variables
;--------------------------------------
SETLVL          jsr SHOLVL              ;show level

                ldx BLEVEL              ;bomb level
                lda INIBOM,X            ;bombs / level
                sta BOMBS               ;bomb count
                lda INIBS,X             ;bomb speed
                sta BOMTI               ;bomb timer
                lda INISC,X             ;% chance of
                sta SAUCHN              ;saucer in level
                lda INIPC,X             ;planet color
                cmp #$FF                ;level >14?
                bne SAVEPC              ;No. skip next

                lda RANDOM              ;random color
                and #$F0                ;mask off lum.
SAVEPC          sta PLNCOL              ;planet color
                lda INIBVL,X            ;bomb value low
                sta BOMVL               ;save it
                lda INIBVH,X            ;bomb value hi
                sta BOMVH               ;save it
                lda INISV,X             ;saucer value
                sta SAUVAL              ;save that too
                cpx #11                 ;at level 11?
                beq SAMLVL              ;Yes. skip next

                inc BLEVEL              ;inc bomb level
SAMLVL          sed                     ;decimal mode
                lda LEVEL               ;game level #
                clc                     ;clear carry
                adc #1                  ;add one
                sta LEVEL               ;save game level
                cld                     ;clear decimal


;--------------------------------------
; Main program loop
;--------------------------------------
LOOP            lda PAUSED              ;game paused?
                bne LOOP                ;Yes. loop here

                lda #0                  ;get zero
                sta ATRACT              ;attract mode
                lda GAMCTL              ;game done?
                bpl CKCORE              ;No. check core

                lda EXPCNT              ;Yes. expl count
                bne CKCORE              ;count done? No.

                jmp ENDGAM              ;The End!


; --------------------------
; Check planet core for hit!
; --------------------------

CKCORE          lda SCRN+1939           ;center LF
                and #$03                ;RT color clock
                cmp #$03                ;explosion colr?
                beq PLDEAD              ;Yes. go dead

                lda SCRN+1940           ;center RT
                and #$C0                ;LF color clock
                cmp #$C0                ;explosion colr?
                bne PLANOK              ;No. skip next


; ---------------
; Planet is Dead!
; ---------------

PLDEAD          lda #0                  ;get zero
                sta BOMBS               ;zero bombs
                sta SATLIV              ;satelite dead
                lda #$FF                ;get #$FF
                sta LIVES               ;no lives left
                sta GAMCTL              ;game control
                jsr SNDOFF              ;no sound


; -------------
; Check console
; -------------

PLANOK          lda CONSOL              ;get console
                cmp #7                  ;any pressed?
                beq NORST               ;No. skip next

                jmp PLANET              ;restart game!


; -----------------
; Projectile firing
; -----------------

NORST           jsr BOMINI              ;try new bomb

                lda SATLIV              ;satellite stat
                beq NOTRIG              ;alive? No.

                lda STRIG0              ;get trigger
                cmp LASTRG              ;same as last VB
                beq NOTRIG              ;Yes. skip next

                sta LASTRG              ;No. save trig
                cmp #0                  ;pressed?
                bne NOTRIG              ;No. skip next

                jsr PROINI              ;strt projectile
NOTRIG          jsr BOMADV              ;advance bombs

                lda EXPTIM              ;do explosion?
                bne NOEXP               ;no!

                jsr CHKSAT              ;satellite ok?
                jsr CHKHIT              ;any hits?
                jsr EXPHAN              ;handle expl.
                jsr PROADV              ;advance shots

                lda SAUCER              ;saucer flag
                beq RESTIM              ;saucer? No.

                jsr SSHOOT              ;Yes. let shoot

RESTIM          lda #1                  ;get one
                sta EXPTIM              ;reset timer
NOEXP           lda BOMBS               ;# bombs to go
                bne LOOP                ;any left? Yes.

                lda GAMCTL              ;game control
                bmi LOOP                ;dead? Yes.

                lda BOMACT              ;bomb 0 status
                ora BOMACT+1            ;bomb 1 status
                ora BOMACT+2            ;bomb 2 status
                ora BOMACT+3            ;bomb 3 status
                beq _JSL                ;any bombs? No.

                jmp LOOP                ;Yes. continue

_JSL            jmp SETLVL              ;setup new level


;======================================
; Initiate a new explosion
;======================================
NEWEXP          lda #64                 ;1.07 seconds
                sta EXSCNT              ;expl sound cnt
                inc EXPCNT              ;one more expl
                ldy EXPCNT              ;use as index
                lda NEWX                ;put X coord
                sta XPOS,Y              ;into X table
                lda NEWY                ;put Y coord
                sta YPOS,Y              ;into Y table
                lda #0                  ;init to zero
                sta CNT,Y               ;explosion image
RT1             rts                     ;return


;======================================
; Main explosion handler routine
;======================================
EXPHAN          lda #0                  ;init to zero
                sta COUNTR              ;zero counter


;--------------------------------------
;
;--------------------------------------
RUNLP           inc COUNTR              ;nxt explosion
                lda EXPCNT              ;get explosion #
                cmp COUNTR              ;any more expl?
                bmi RT1                 ;No. return

                ldx COUNTR              ;get index
                lda #0                  ;init plotclr
                sta PLOTCLR             ;0 = plot block
                lda CNT,X               ;expl counter
                cmp #37                 ;all drawn?
                bmi DOPLOT              ;No. do it

                inc PLOTCLR             ;1 = erase block
                sec                     ;set carry
                sbc #37                 ;erase cycle
                cmp #37                 ;erase done?
                bmi DOPLOT              ;No. erase block

                txa                     ;move index
                tay                     ;to Y register

; ---------------------------
; Repack explosion table, get
; rid of finished explosions
; ---------------------------

REPACK          inx                     ;next explosion
                cpx EXPCNT              ;done?
                beq RPK2                ;No. repack more

                bpl RPKEND              ;Yes. exit

RPK2            lda XPOS,X              ;get X position
                sta XPOS,Y              ;move back X
                lda YPOS,X              ;get Y position
                sta YPOS,Y              ;move back Y
                lda CNT,X               ;get count
                sta CNT,Y               ;move back count
                iny                     ;inc index
                bne REPACK              ;next repack

RPKEND          dec EXPCNT              ;dec pointers
                dec COUNTR              ;due to repack
                jmp RUNLP               ;continue

DOPLOT          inc CNT,X               ;inc pointer
                tay                     ;exp phase in Y
                lda XPOS,X              ;get X-coord
                clc                     ;clear carry
                adc COORD1,Y            ;add X offset
                sta PLOTX               ;save it
                cmp #160                ;off screen?
                bcs RUNLP               ;Yes. don't plot

                lda YPOS,X              ;get Y-coord
                adc COORD2,Y            ;add Y offset
                sta PLOTY               ;save it
                cmp #96                 ;off screen?
                bcs RUNLP               ;Yes. don't plot

                jsr PLOT                ;get plot addr

                lda PLOTCLR             ;erase it?
                bne CLEARIT             ;Yes. clear it

                lda PLOTBL,X            ;get plot bits
                ora (LO),Y              ;alter display
PUTIT           sta (LO),Y              ;and replot it!
                jmp RUNLP               ;exit

CLEARIT         lda ERABIT,X            ;erase bits
                and (LO),Y              ;turn off pixel
                jmp PUTIT               ;put it back


;======================================
; Dedicated multiply by 40
; with result in LO and HI
;======================================
PLOT            lda PLOTY               ;get Y-coord
                asl A                   ;shift it left
                sta LO                  ;save low *2
                lda #0                  ;get zero
                sta HI                  ;init high byte
                asl LO                  ;shift low byte
                rol HI                  ;rotate high *4
                asl LO                  ;shift low byte
                lda LO                  ;get low byte
                sta LOHLD               ;save low *8
                rol HI                  ;rotate high *8
                lda HI                  ;get high byte
                sta HIHLD               ;save high *8
                asl LO                  ;shift low byte
                rol HI                  ;rotate high *16
                asl LO                  ;shift low byte
                rol HI                  ;rotate high *32
                lda LO                  ;get low *32
                clc                     ;clear carry
                adc LOHLD               ;add low *8
                sta LO                  ;save low *40
                lda HI                  ;get high *32
                adc HIHLD               ;add high *8
                sta HI                  ;save high *40

; -----------------------------
; Get offset into screen memory
; -----------------------------

                lda #<SCRN              ;screen addr lo
                clc                     ;clear carry
                adc LO                  ;add low offset
                sta LO                  ;save addr low
                lda #>SCRN              ;screen addr hi
                adc HI                  ;add high offset
                sta HI                  ;save addr hi
                lda PLOTX               ;mask PLOTX for
                and #3                  ;the plot bits,
                tax                     ;place in X..
                lda PLOTX               ;get PLOTX and
                lsr A                   ;divide
                lsr A                   ;by 4
                clc                     ;and add to
                adc LO                  ;plot address
                sta LO                  ;for final plot
                bcc PLOT1               ;address.

                inc HI                  ;overflow? Yes.
PLOT1           ldy #0                  ;zero Y register
                rts                     ;return


;======================================
; Bomb initializer
;======================================
BOMINI          lda BOMBWT              ;bomb wait time
                bne NOBINI              ;done? No.

                lda BOMBS               ;more bombs?
                bne CKLIVE              ;Yes. skip RTS

NOBINI          rts                     ;No. return

CKLIVE          ldx #3                  ;find..
CKLVLP          lda BOMACT,X            ;an available..
                beq GOTBOM              ;bomb? Yes.

                dex                     ;No. dec index
                bpl CKLVLP              ;done? No.

                rts                     ;return

GOTBOM          lda #1                  ;this one is..
                sta BOMACT,X            ;active now
                dec BOMBS               ;one less bomb
                lda #0                  ;zero out all..
                sta BXHOLD,X            ;vector X hold
                sta BYHOLD,X            ;vector Y hold
                lda GAMCTL              ;game control
                bmi NOSAUC              ;saucer possible?


; --------------
; Saucer handler
; --------------

                cpx #3                  ;Yes. bomb #3?
                bne NOSAUC              ;No. skip next

                lda RANDOM              ;random number
                cmp SAUCHN              ;compare chances
                bcs NOSAUC              ;put saucer? No.

                lda #1                  ;Yes. get one
                sta SAUCER              ;enable saucer
                lda RANDOM              ;random number
                and #$03                ;range: 0..3
                tay                     ;use as index
                lda STARTX,Y            ;saucer start X
                cmp #$FF                ;random flag?
                bne SAVESX              ;No. use as X

                jsr SAURND              ;random X-coord

                adc #35                 ;add X offset
SAVESX          sta FROMX               ;from X vector
                sta BOMBX,X             ;init X-coord
                lda STARTY,Y            ;saucer start Y
                cmp #$FF                ;random flag?
                bne SAVESY              ;No. use as Y

                jsr SAURND              ;random Y-coord

                adc #55                 ;add Y offset
SAVESY          sta FROMY               ;from Y vector
                sta BOMBY,X             ;init Y-coord
                lda ENDX,Y              ;saucer end X
                cmp #$FF                ;random flag?
                bne SAVEEX              ;No. use as X

                lda #230                ;screen right
                sec                     ;offset so not
                sbc FROMY               ;to hit planet
SAVEEX          sta TOX                 ;to X vector
                lda ENDY,Y              ;saucer end Y
                cmp #$FF                ;random flag?
                bne SAVEEY              ;No. use as Y

                lda FROMX               ;use X for Y
SAVEEY          sta TOY                 ;to Y vector
                jmp GETBV               ;skip next


; ------------
; Bomb handler
; ------------

NOSAUC          lda RANDOM              ;random number
                bmi BXMAX               ;coin flip

                lda RANDOM              ;random number
                and #1                  ;make 0..1
                tay                     ;use as index
                lda BMAXS,Y             ;top/bottom tbl
                sta BOMBY,X             ;bomb Y-coord
SETRBX          lda RANDOM              ;random number
                cmp #250                ;compare w/250
                bcs SETRBX              ;less than? No.

                sta BOMBX,X             ;bomb X-coord
                jmp BOMVEC              ;skip next

BXMAX           lda RANDOM              ;random number
                and #1                  ;make 0..1
                tay                     ;use as index
                lda BMAXS,Y             ;0 or 250
                sta BOMBX,X             ;bomb X-coord
SETRBY          lda RANDOM              ;random number
                cmp #250                ;compare w/250
                bcs SETRBY              ;less than? No.

                sta BOMBY,X             ;bomb Y-coord
BOMVEC          lda BOMBX,X             ;bomb X-coord
                sta FROMX               ;shot from X
                lda BOMBY,X             ;bomb Y-coord
                sta FROMY               ;shot from Y
                lda #128                ;planet center
                sta TOX                 ;shot to X-coord
                sta TOY                 ;shot to Y-coord


;--------------------------------------
;
;--------------------------------------
GETBV           jsr VECTOR              ;calc shot vect


; ---------------------
; Store vector in table
; ---------------------

                lda LR                  ;bomb L/R flag
                sta BOMBLR,X            ;bomb L/R table
                lda UD                  ;bomb U/D flag
                sta BOMBUD,X            ;bomb U/D table
                lda VXINC               ;velocity X inc
                sta BXINC,X             ;Vel X table
                lda VYINC               ;velocity Y inc
                sta BYINC,X             ;Vel Y table
                rts                     ;return


;======================================
; Saucer random generator 0..99
;======================================
SAURND          lda RANDOM              ;random number
                and #$7F                ;0..127
                cmp #100                ;compare w/100
                bcs SAURND              ;less than? No.

                rts                     ;return


;======================================
; Saucer shoot routine
;======================================
SSHOOT          lda RANDOM              ;random number
                cmp #6                  ;2.3% chance?
                bcs NOSS                ;less than? No.

                ldx #7                  ;7 = index
                lda PROACT,X            ;projectile #7
                beq GOTSS               ;active? No.

                dex                     ;6 = index
                lda PROACT,X            ;projectile #6
                beq GOTSS               ;active? No.

NOSS            rts                     ;return, no shot


; --------------------
; Enable a saucer shot
; --------------------

GOTSS           lda #48                 ;PF center, Y
                sta TOY                 ;shot to Y-coord
                lda #80                 ;PF center X
                sta TOX                 ;shot to X-coord
                lda BOMBX+3             ;saucer x-coord
                sec                     ;set carry
                sbc #44                 ;PF offset
                sta FROMX               ;shot from X
                sta PROJX,X             ;X-coord table
                cmp #160                ;screen X limit
                bcs NOSS                ;on screen? No.

                lda BOMBY+3             ;saucer Y-coord
                sbc #37                 ;PF offset
                lsr A                   ;2 scan lines
                sta FROMY               ;shot from Y
                sta PROJY,X             ;Y-coord table
                cmp #95                 ;screen Y limit
                bcs NOSS                ;on screen? No.

                lda #13                 ;shot snd time
                sta ESSCNT              ;emeny snd count
                jmp PROVEC              ;continue


;======================================
; Projectile initializer
;======================================
PROINI          ldx #5                  ;6 projectiles
PSCAN           lda PROACT,X            ;get status
                beq GOTPRO              ;active? No.

                dex                     ;Yes. try again
                bpl PSCAN               ;done? No.

                rts                     ;return


; -----------------
; Got a projectile!
; -----------------

GOTPRO          lda #13                 ;shot snd time
                sta PSSCNT              ;player sht snd
                lda SATX                ;satellite X
                sta FROMX               ;shot from X
                sta PROJX,X             ;proj X table
                lda SATY                ;satellite Y
                sta FROMY               ;shot from Y
                sta PROJY,X             ;proj Y table
                lda CURX                ;cursor X-coord
                sec                     ;set carry
                sbc #48                 ;playfld offset
                sta TOX                 ;shot to X-coord
                lda CURY                ;cursor Y-coord
                sec                     ;set carry
                sbc #32                 ;playfld offset
                lsr A                   ;2 line res
                sta TOY                 ;shot to Y-coord


;--------------------------------------
;
;--------------------------------------
PROVEC          jsr VECTOR              ;compute vect

                lda VXINC               ;X increment
                sta PXINC,X             ;X inc table
                lda VYINC               ;Y increment
                sta PYINC,X             ;Y inc table
                lda LR                  ;L/R flag
                sta PROJLR,X            ;L/R flag table
                lda UD                  ;U/D flag
                sta PROJUD,X            ;U/D flag table
                lda #1                  ;active
                sta PROACT,X            ;proj status
RT2             rts                     ;return


;======================================
; Bomb advance handler
;======================================
BOMADV          lda BOMTIM              ;bomb timer
                bne RT2                 ;time up? No.

                lda LIVES               ;any lives?
                bpl REGBT               ;Yes. skip next

                lda #1                  ;speed up bombs
                bne SETBTM              ;skip next

REGBT           lda BOMTI               ;get bomb speed
SETBTM          sta BOMTIM              ;reset timer
                ldx #3                  ;check 4 bombs
ADVBLP          lda BOMACT,X            ;bomb on?
                beq NXTBOM              ;No. try next

                jsr ADVIT               ;advance bomb

                lda LIVES               ;any lives left?
                bpl SHOBOM              ;Yes. skip next

                jsr ADVIT               ;No. move bombs
                jsr ADVIT               ;4 times faster
                jsr ADVIT               ;than normal


; --------------------------
; We've now got updated bomb
; coordinates for plotting!
; --------------------------

SHOBOM          lda BOMBY,X             ;bomb Y-coord
                clc                     ;clear carry
                adc #2                  ;bomb center off
                sta INDX1               ;save it
                lda #0                  ;get zero
                sta LO                  ;init low byte
                txa                     ;index to Acc
                ora #>PLR0              ;mask w/address
                sta HI                  ;init high byte
                stx INDX2               ;X temp hold
                cpx #3                  ;saucer slot?
                bne NOTSAU              ;No. skip next

                lda SAUCER              ;saucer in slot?
                bne NXTBOM              ;Yes. skip bomb

NOTSAU          ldy BOMBLR,X            ;L/R flag
                lda #17                 ;do 17 bytes
                sta TEMP                ;set counter
                ldx BPSTRT,Y            ;start position
                ldy INDX1               ;bomb Y pos
BDRAW           cpy #32                 ;off screen top?
                bcc NOBDRW              ;Yes. skip next

                cpy #223                ;screen bottom?
                bcs NOBDRW              ;Yes. skip next

                lda BOMPIC,X            ;bomb picture
                sta (LO),Y              ;put in PM area
NOBDRW          dey                     ;PM index
                dex                     ;picture index
                dec TEMP                ;dec count
                bne BDRAW               ;done? No.

                ldx INDX2               ;restore X
                lda BOMBX,X             ;bomb X-coord
                sta HPOSP0,X            ;player pos
NXTBOM          dex                     ;more bombs?
                bpl ADVBLP              ;yes!

                rts                     ;all done!


;======================================
; Projectile advance handler
;======================================
PROADV          ldx #11                 ;do 8: 11..4
PADVLP          lda BOMACT,X            ;active?
                beq NXTPRO              ;No. skip next

                lda BOMBX,X             ;bomb X-coord
                sta PLOTX               ;plotter X
                lda BOMBY,X             ;bomb Y-coord
                sta PLOTY               ;plotter Y
                stx XHOLD               ;X-reg temporary
                jsr PLOT                ;calc plot addr

                lda (LO),Y              ;get plot byte
                and ERABIT,X            ;erase bit
                sta (LO),Y              ;replace byte
                ldx XHOLD               ;restore X
                jsr ADVIT               ;advance proj

                lda BOMBX,X             ;bomb X-coord
                cmp #160                ;off screen?
                bcs KILPRO              ;Yes. kill it

                sta PLOTX               ;plotter X
                lda BOMBY,X             ;bomb Y-coord
                cmp #96                 ;off screen?
                bcs KILPRO              ;Yes. kill it

                sta PLOTY               ;plotter Y
                jsr PLOT                ;calc plot addr

                lda PLOTBL,X            ;get plot mask
                and (LO),Y              ;chk collision
                beq PROJOK              ;No. plot it

                ldx XHOLD               ;restore X
                lda PLOTX               ;proj X-coord
                sta NEWX                ;explo X-coord
                lda PLOTY               ;proj Y-coord
                sta NEWY                ;explo Y-coord
                jsr NEWEXP              ;set off explo

KILPRO          lda #0                  ;get zero
                sta BOMACT,X            ;kill proj
                jmp NXTPRO              ;skip next

PROJOK          lda PLOTBL,X            ;plot mask
                ldx XHOLD               ;restore X
                and PROMSK,X            ;mask color
                ora (LO),Y              ;add playfield
                sta (LO),Y              ;replace byte
NXTPRO          dex                     ;next projectile
                cpx #3                  ;proj #3 yet?
                bne PADVLP              ;No. continue

                rts                     ;return


;======================================
; Check satellite status
;======================================
CHKSAT          lda DEADTM              ;satellite ok?
                beq LIVE                ;No. skip next

CHKSX           rts                     ;return

LIVE            lda LIVES               ;lives left?
                bmi CHKSX               ;No. exit

                lda #1                  ;get one
                sta SATLIV              ;set alive flag
                lda M0PL                ;did satellite
                ora M0PL+1              ;hit any bombs?
                beq CHKSX               ;No. exit

                lda #0                  ;get zero
                sta SATLIV              ;kill satellite
                sta SCNT                ;init orbit
                ldx LIVES               ;one less life
                sta SCOLIN+14,X         ;erase life
                dec LIVES               ;dec lives count
                bpl MORSAT              ;any left? Yes.

                lda #255                ;lot of bombs
                sta BOMBS               ;into bomb count
                sta GAMCTL              ;end game
                jsr SNDOFF              ;no sound 1 2 3

MORSAT          lda SATX                ;sat X-coord
                sta NEWX                ;explo X-coord
                lda SATY                ;sat Y-coord
                sta NEWY                ;explo Y-coord
                jsr NEWEXP              ;set off explo

                lda #80                 ;init sat X
                sta SATX                ;sat X-coord
                lda #21                 ;init sat Y
                sta SATY                ;sat Y-coord
                ldx #0                  ;don't show the
CLRSAT          lda MISL,X              ;satellite pic
                and #$F0                ;mask off sat
                sta MISL,X              ;restore data
                dex                     ;dec index
                bne CLRSAT              ;done? No.

                lda #$FF                ;4.25 seconds
                sta DEADTM              ;till next life!
                rts                     ;return


;--------------------------------------
; Check console keys
;--------------------------------------
ENDGAM          jsr SNDOFF              ;no sound 123

ENDGLP          lda STRIG0              ;stick trigger
                and PTRIG0              ;mask w/paddle 0
                and PTRIG1              ;mask w/paddle 1
                beq ENDGL1              ;any pushed? No.

                lda CONSOL              ;chk console
                cmp #7                  ;any pushed?
                beq ENDGLP              ;No. loop here

ENDGL1          jmp PLANET              ;restart game


;======================================
; Turn off sound regs 1 2 3
;======================================
SNDOFF          lda #0                  ;zero volume
                sta AUDC1               ;to sound #1
                sta AUDC1+2             ;sound #2
                sta AUDC1+4             ;sound #3
                rts                     ;return


;======================================
; Check for hits on bombs
;======================================
CHKHIT          ldx #3                  ;4 bombs 0..3
                lda SAUCER              ;saucer enabled?
                beq CHLOOP              ;No. skip next

                lda #0                  ;get zero
                sta BOMCOL              ;collision count
                lda GAMCTL              ;game over?
                bmi NOSCOR              ;Yes. skip next

                lda BOMBX+3             ;saucer X-coord
                cmp #39                 ;off screen lf?
                bcc NOSCOR              ;Yes. kill it

                cmp #211                ;off screen rt?
                bcs NOSCOR              ;Yes. kill it

                lda BOMBY+3             ;saucer Y-coord
                cmp #19                 ;off screen up?
                bcc NOSCOR              ;Yes. kill it

                cmp #231                ;off screen dn?
                bcs NOSCOR              ;Yes. kill it

CHLOOP          lda #0                  ;get zero
                sta BOMCOL              ;collision count
                lda P0PF,X              ;playf collision
                and #$05                ;w/shot+planet
                beq NOBHIT              ;hit either? No.

                inc BOMCOL              ;Yes. inc count
                and #$04                ;hit shot?
                beq NOSCOR              ;No. skip next

                lda GAMCTL              ;game over?
                bmi NOSCOR              ;Yes. skip next

                lda #2                  ;1/30th second
                sta BOMBWT              ;bomb wait time
                cpx #3                  ;saucer player?
                bne ADDBS               ;No. skip this

                lda SAUCER              ;saucer on?
                beq ADDBS               ;No. this this

                lda SAUVAL              ;saucer value
                sta SCOADD+1            ;point value
                jmp ADDIT               ;add to score


; -----------------------
; Add bomb value to score
; -----------------------

ADDBS           lda BOMVL               ;bomb value low
                sta SCOADD+2            ;score inc low
                lda BOMVH               ;bomb value high
                sta SCOADD+1            ;score inc high


;--------------------------------------
;
;--------------------------------------
ADDIT           stx XHOLD               ;save X register
                jsr ADDSCO              ;add to score

                ldx XHOLD               ;restore X
NOSCOR          lda #0                  ;get zero
                sta BOMACT,X            ;kill bomb
                ldy BOMBLR,X            ;L/R flag
                lda BOMBX,X             ;bomb X-coord
                sec                     ;set carry
                sbc BXOF,Y              ;bomb X offset
                sta NEWX                ;plotter X-coord
                lda BOMBY,X             ;bomb Y-coord
                sec                     ;set carry
                sbc #40                 ;bomb Y offset
                lsr A                   ;2 line res.
                sta NEWY                ;plotter Y-coord
                lda SAUCER              ;saucer?
                beq EXPBOM              ;No. explode it

                cpx #3                  ;bomb player?
                bne EXPBOM              ;Yes. explode it

                lda #0                  ;get zero
                sta SAUCER              ;kill saucer
                jsr CLRPLR              ;clear player

                lda GAMCTL              ;game over?
                bmi NOBHIT              ;Yes. skip next

EXPBOM          jsr CLRPLR              ;clear player

                lda BOMCOL              ;collisions?
                beq NOBHIT              ;No. skip this

                jsr NEWEXP              ;init explosion

NOBHIT          dex                     ;dec index
                bpl CHLOOP              ;done? No.

                sta HITCLR              ;reset collision
                rts                     ;return


;======================================
; Advance bombs/projectiles
;======================================
ADVIT           lda BXHOLD,X            ;bomb X-sum
                clc                     ;clear carry
                adc BXINC,X             ;add X-increment
                sta BXHOLD,X            ;replace X-sum
                lda #0                  ;get zero
                rol A                   ;carry = 1
                sta DELTAX              ;X-delta
                lda BYHOLD,X            ;bomb Y-sum
                adc BYINC,X             ;add Y-increment
                sta BYHOLD,X            ;replace Y-sum
                lda #0                  ;get zero
                rol A                   ;carry = 1
                sta DELTAY              ;Y-delta
                lda BOMBLR,X            ;bomb L/R flag
                beq ADVLFT              ;go left? Yes.

                lda BOMBX,X             ;bomb X-coord
                adc DELTAX              ;add X-delta
                jmp ADVY                ;skip next

ADVLFT          lda BOMBX,X             ;bomb X-coord
                sec                     ;set carry
                sbc DELTAX              ;sub X-delta
ADVY            sta BOMBX,X             ;save X-coord
                lda BOMBUD,X            ;bomb U/D flag
                beq ADVDN               ;go down? Yes.

                lda BOMBY,X             ;bomb Y-coord
                sec                     ;set carry
                sbc DELTAY              ;sub Y-delta
                jmp ADVEND              ;skip next

ADVDN           lda BOMBY,X             ;bomb Y-coord
                clc                     ;clear carry
                adc DELTAY              ;add Y-delta
ADVEND          sta BOMBY,X             ;save Y-coord
                rts                     ;return


;======================================
; Clear out player indicated
; by the X register!
;======================================
CLRPLR          lda #0                  ;move player...
                sta HPOSP0,X            ;off screen,
                tay                     ;init index
                txa                     ;get X
                ora #>PLR0              ;mask w/address
                sta HI                  ;plr addr high
                tya                     ;Acc = 0
                sta LO                  ;plr addr low
CLPLP           sta (LO),Y              ;zero player
                dey                     ;dec index
                bne CLPLP               ;done? No.

                rts                     ;return


;======================================
; Calculate target vector
;======================================
VECTOR          lda #0                  ;get zero
                sta LR                  ;going left
                lda FROMX               ;from X-coord
                cmp TOX                 ;w/to X-coord
                bcc RIGHT               ;to right? Yes.

                sbc TOX                 ;get X-diff
                jmp VECY                ;skip next

RIGHT           inc LR                  ;going right
                lda TOX                 ;to X-coord
                sec                     ;set carry
                sbc FROMX               ;get X-diff
VECY            sta VXINC               ;save difference
                lda #1                  ;get one
                sta UD                  ;going up flag
                lda FROMY               ;from Y-coord
                cmp TOY                 ;w/to Y-coord
                bcc DOWN                ;down? Yes.

                sbc TOY                 ;get Y-diff
                jmp VECSET              ;skip next

DOWN            dec UD                  ;going down flag
                lda TOY                 ;to Y-coord
                sec                     ;set carry
                sbc FROMY               ;get Y-diff
VECSET          sta VYINC               ;are both
                ora VXINC               ;distances 0?
                bne VECLP               ;No. skip next

                lda #$80                ;set x increment
                sta VXINC               ;to default.
VECLP           lda VXINC               ;X vector incre
                bmi VECEND              ;>127? Yes.

                lda VYINC               ;Y vector incre
                bmi VECEND              ;>127? Yes.

                asl VXINC               ;times 2 until
                asl VYINC               ;one is >127
                jmp VECLP               ;continue

VECEND          rts                     ;return


;======================================
; Add to score
;======================================
ADDSCO          ldy #0                  ;init index
                sed                     ;decimal mode
                clc                     ;clear carry
                ldx #2                  ;do 3 bytes
ASCLP           lda SCORE,X             ;get score
                adc SCOADD,X            ;add bomb value
                sta SCORE,X             ;save score
                sty SCOADD,X            ;zero value
                dex                     ;next byte
                bpl ASCLP               ;done? No.

                cld                     ;clear decimal


;======================================
; Show score
;======================================
SHOSCO          lda #$10                ;put color 0
                sta SHCOLR              ;in hold area
                ldx #1                  ;2nd line char
                ldy #0                  ;digits 1,2
SSCOLP          lda SCORE,Y             ;get digits
                jsr SHOBCD              ;show 'em

                inx                     ;advance score
                inx                     ;line pointer
                iny                     ;next 2 digits
                cpy #3                  ;done 6?
                bne SSCOLP              ;no!

                rts                     ;all done!


;======================================
; Show level number
;======================================
SHOLVL          ldy #$50                ;use color 2
                sty SHCOLR              ;save it
                lda LEVEL               ;get level #
                ldx #11                 ;12th char on line


;======================================
; Show 2 BCD digits
;======================================
SHOBCD          sta SHOBYT              ;save digits
                and #$0F                ;get lower digit
                ora SHCOLR              ;add color
                sta SCOLIN+1,X          ;show it
                lda SHOBYT              ;get both again
                lsr A                   ;mask...
                lsr A                   ;off...
                lsr A                   ;upper...
                lsr A                   ;digit
                ora SHCOLR              ;add color
                sta SCOLIN,X            ;show it!
                rts                     ;and exit.


;======================================
; KOALA PAD interface
;--------------------------------------
; The following filtering
; algorithm is used:
;
; Given 5 points S1,S2,S3,S4,S5
;
; R1=S1+S2+S2+S3
; R2=S2+S3+S3+S4
; R3=S3+S4+S4+S5
;
; AVG=(R1+R2+R2+R3)/16
;
; This reduces to:
;
; AVG=(S1+S2*4+S3*6+S4*4+S5)/16
;
; ---------------------------
; Rotate points through queue
; ---------------------------
;======================================
KOALA           ldx #4                  ;do 5 bytes
ROT             lda XQ-1,X              ;move X queue
                sta XQ,X                ;up one byte
                lda YQ-1,X              ;move Y queue
                sta YQ,X                ;up one byte
                dex                     ;dec count
                bne ROT                 ;done? No.


; --------------------
; Clear out the cursor
; --------------------

                ldy CURY                ;get Y coord
                ldx #5                  ;do 6 bytes
CCURS           lda MISL,Y              ;get missiles
                and #$F0                ;mask off low
                sta MISL,Y              ;put back
                dex                     ;dec count
                bpl CCURS               ;done? No.


; ---------------------------
; Insert new point into queue
; ---------------------------

                lda #1                  ;pen up flag
                sta PENFLG              ;set pen up
                lda PADDL0              ;X input
                sta XQ                  ;put in queue
                cmp #5                  ;screen boundary
                bcc KOALAX              ;on screen? No.

                lda PADDL1              ;Y input
                sta YQ                  ;put in queue
                cmp #5                  ;screen boundary
                bcc KOALAX              ;on screen? No.


; ---------------------
; Filter the X-Y queues
; ---------------------

                lda #<XQ                ;queue addr low
                sta PTR                 ;pointer low
                lda #>XQ                ;queue addr high
                sta PTR+1               ;pointer high
                jsr FILTER              ;filter X data

                bcs KOALAX              ;good data? No.

                adc #16                 ;X offset
                cmp #48                 ;far left?
                bcs FLF                 ;No. skip

                lda #48                 ;screen left
FLF             cmp #208                ;far right?
                bcc FRT                 ;No. skip

                lda #207                ;screen right
FRT             sta CURX                ;put X coord
                lda #<YQ                ;queue addr low
                sta PTR                 ;pointer low
                lda #>YQ                ;queue addr high
                sta PTR+1               ;pointer high
                jsr FILTER              ;filter Y data

                bcs KOALAX              ;good data? No.

                adc #16                 ;Y offset
                cmp #32                 ;above top?
                bcs FUP                 ;No. skip

                lda #32                 ;screen top
FUP             cmp #224                ;below bottom?
                bcc FDN                 ;No. skip

                lda #223                ;screen bottom
FDN             sta CURY                ;put Y coord

; ----------------------
; Paddle trigger handler
; ----------------------

                lda PTRIG0              ;paddle trig 0
                eor PTRIG1              ;EOR w/PTRIG1
                eor #1                  ;inverse data
                sta STRIG0              ;put in STRIG0
                lda #0                  ;pen down flag
                sta PENFLG              ;set pen down
KOALAX          rts                     ;continue


;======================================
; Filter algorithm, initialize
;======================================
FILTER          lda #0                  ;get zero
                ldx #4                  ;do 5 bytes
FILC            sta SH,X                ;high byte table
                dex                     ;dec count
                bpl FILC                ;done? No.

                sta AVG                 ;average low
                sta AVG+1               ;average high
                tay                     ;xero in Y
                ldx #1                  ;one in X

; -----------------------
; Process the X-Y samples
; -----------------------

                lda (PTR),Y             ;get S1
                sta SL,Y                ;save low byte
                iny                     ;inc pointer
                jsr MUL4                ;process S2

                lda (PTR),Y             ;get S3
                asl A                   ;times 2
                rol SH,X                ;rotate carry
                adc (PTR),Y             ;add = times 3
                bcc FIL2                ;overflow? No.

                inc SH,X                ;inc high byte
FIL2            asl A                   ;times 6
                rol SH,X                ;rotate carry
                sta SL,X                ;save low byte
                inx                     ;inc pointer
                iny                     ;inc pointer
                jsr MUL4                ;process S4

                lda (PTR),Y             ;get S5
                sta SL,Y                ;save low byte

; -------------
; Total samples
; -------------

                ldx #4                  ;add 5 elements
ALOOP           lda SL,X                ;get low byte
                adc AVG                 ;add to average
                sta AVG                 ;save low byte
                lda SH,X                ;get high byte
                adc AVG+1               ;add to average
                sta AVG+1               ;save high byte
                dex                     ;dec pointer
                bpl ALOOP               ;done? No.


; ------------------
; Divide total by 16
; ------------------

                ldx #4                  ;shift 4 bits
                lda AVG                 ;get lo byte
DIV16           lsr AVG+1               ;rotate high
                ror A                   ;rotate low
                dex                     ;dec count
                bne DIV16               ;done? No.

                tax                     ;save Acc

; --------------------------
; Compare average with DELTA
; --------------------------

                ldy #4                  ;5 byte table
MEAN            sec                     ;set carry
                sbc (PTR),Y             ;compare points
                bcs POSI                ;negative? No.

                eor #$FF                ;negate byte and
                adc #1                  ;+1 = ABS value
POSI            cmp #24                 ;within DELTA?
                bcs FAIL                ;No. abort

                txa                     ;get Acc again
                dey                     ;dec pointer
                bpl MEAN                ;done? No.

FAIL            rts                     ;exit


;======================================
; Multply Acc by 4
;======================================
MUL4            lda (PTR),Y             ;get S2
                asl A                   ;times 2
                rol SH,X                ;rotate carry
                asl A                   ;times 4
                rol SH,X                ;rotate carry
                sta SL,X                ;save low byte
                inx                     ;inc pointer
                iny                     ;inc pointer
                rts                     ;return


; ----------
; Data areas
; ----------

BMAXS           .byte 0,250             ;bomb limits
BOMPIC          .byte 0,0,0,0,0,0,$DC,$3E
                .byte $7E,$3E,$DC,0,0,0,0
                .byte 0,0,$76,$F8,$FC
                .byte $F8,$76,0,0,0,0,0,0
BPSTRT          .byte 27,16
BXOF            .byte 47,42
CURPIC          .byte $40,$40,$A0,$A0
                .byte $40,$40
P3COLR          .byte $34,$F8
SAUPIC          .byte 0,0,$18,$7E,0,0
                .byte $7E,$18,0,0
SAUMID          .byte $92,$49,$24,$92
STARTX          .byte 40,$FF,210,$FF
STARTY          .byte $FF,20,$FF,230
ENDX            .byte $FF,210,$FF,40
ENDY            .byte 20,$FF,230,$FF

; ---------------------
; Explosion data tables
; ---------------------

PLOTBL          .byte $C0,$30,$0C,$03
ERABIT          .byte $3F,$CF,$F3,$FC
PROMSK          .byte 0,0,0,0
                .byte $FF,$FF,$FF,$FF
                .byte $FF,$FF,$AA,$AA
COORD1          .byte 0,1,255,0,255,1
                .byte 0,2,255,254,0,1
                .byte 0,254,2,1,1,255
                .byte 0,2,254,255,3,0
                .byte 253,254,3,2,255,254
                .byte 1,255,3,253,1,253,2
COORD2          .byte 0,0,1,255,0,1
                .byte 1,0,255,1,2,255
                .byte 254,255,1,2,254,2
                .byte 3,255,0,254,1,253
                .byte 0,254,255,2,3,2
                .byte 253,253,0,1,3,255,254

; ------------------
; Initial score line
; ------------------

SCOINI          .byte $00,$00,$00,$00
                .byte $00,$00,$00,$00
                .byte $6C,$76,$6C,$00
                .byte $00,$00,$CA,$CA
                .byte $CA,$CA,$CA,$00

; ------------
; Level tables
; ------------

INIBOM          .byte 10,15,20,25,20,25
                .byte 15,20,25,20,25,30
INIBS           .byte 12,11,10,9,8,7
                .byte 7,6,5,5,4,3
INISC           .byte 0,10,50,90,50,80
                .byte 40,60,100,80,120,125
INIPC           .byte $20,$30,$40,$50,$60
                .byte $70,$80,$A0,$B0,$C0
                .byte $D0,$FF
INIBVH          .byte 0,0,0,0,0,0
                .byte 0,0,0,$01,$01,$01
INIBVL          .byte $10,$20,$30,$40,$50
                .byte $60,$70,$80,$90,$00
                .byte $10,$20
INISV           .byte 0,1,1,1,2,2
                .byte 3,3,3,4,4,4

; ----------
; Sound data
; ----------

PLSHOT          .byte 244,254,210,220
                .byte 176,186,142,152,108
                .byte 118,74,84,40,50
ENSHOT          .byte 101,96,85,80,69,64
                .byte 53,48,37,32,21,16,5,0
SAUSND          .byte 10,11,12,14,16,17
                .byte 18,17,16,14,12,11


; -----------------
; Program variables
; -----------------

XPOS            .fill 20                ;all expl. x's
YPOS            .fill 20                ;all expl. y's
CNT             .fill 20                ;all expl. counts
BOMACT          .fill 4                 ;bomb active flags
PROACT          .fill 8                 ;proj. active flags
BOMBX           .fill 4                 ;bomb x positions
PROJX           .fill 8                 ;proj. x positions
BOMBY           .fill 4                 ;bomb y positions
PROJY           .fill 8                 ;proj. y positions
BXINC           .fill 4                 ;bomb x vectors
PXINC           .fill 8                 ;proj. x vectors
BYINC           .fill 4                 ;bomb y vectors
PYINC           .fill 8                 ;proj. y vectors
BXHOLD          .fill 12                ;b/p hold areas
BYHOLD          .fill 12                ;b/p hold areas
BOMBLR          .fill 4                 ;bomb left/right
PROJLR          .fill 8                 ;proj. left/right
BOMBUD          .fill 4                 ;bomb up/down
PROJUD          .fill 8                 ;proj. up/down
SCOLIN          .fill 20                ;score line

; --------------
; End of program
; --------------

                .end
