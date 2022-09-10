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
