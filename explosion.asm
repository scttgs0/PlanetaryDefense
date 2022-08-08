;======================================
; Initiate a new explosion
;======================================
NewExplosion    .proc
                lda #64                 ; 1.07 seconds
                sta EXSCNT              ; expl sound cnt
                inc EXPCNT              ; one more expl
                ldy EXPCNT              ; use as index
                lda NEWX                ; put X coord
                sta XPOS,Y              ; into X table
                lda NEWY                ; put Y coord
                sta YPOS,Y              ; into Y table
                lda #0                  ; init to zero
                sta CNT,Y               ; explosion image
_XIT            rts
                .endproc


;======================================
; Main explosion handler routine
;======================================
HandleExplosion .proc
                lda #0                  ; init to zero
                sta COUNTR              ; zero counter

_next1          inc COUNTR              ; nxt explosion
                lda EXPCNT              ; get explosion #
                cmp COUNTR              ; any more expl?
                bmi NewExplosion._XIT   ; No. return

                ldx COUNTR              ; get index
                lda #0                  ; init plotclr
                sta PLOTCLR             ; 0 = plot block
                lda CNT,X               ; expl counter
                cmp #37                 ; all drawn?
                bmi _doPlot             ; No. do it

                inc PLOTCLR             ; 1 = erase block
                sec                     ; set carry
                sbc #37                 ; erase cycle
                cmp #37                 ; erase done?
                bmi _doPlot             ; No. erase block

                txa                     ; move index
                tay                     ; to Y register

; ---------------------------
; Repack explosion table, get
; rid of finished explosions
; ---------------------------

_next2          inx                     ; next explosion
                cpx EXPCNT              ; done?
                beq _rpk2               ; No. repack more

                bpl _rpkEnd             ; Yes. exit

_rpk2           lda XPOS,X              ; get X position
                sta XPOS,Y              ; move back X
                lda YPOS,X              ; get Y position
                sta YPOS,Y              ; move back Y
                lda CNT,X               ; get count
                sta CNT,Y               ; move back count
                iny                     ; inc index
                bne _next2              ; next repack

_rpkEnd         dec EXPCNT              ; dec pointers
                dec COUNTR              ; due to repack
                jmp _next1

_doPlot         inc CNT,X               ; inc pointer
                tay                     ; exp phase in Y
                lda XPOS,X              ; get X-coord
                clc                     ; clear carry
                adc COORD1,Y            ; add X offset
                sta PLOTX               ; save it
                cmp #160                ; off screen?
                bcs _next1              ; Yes. don't plot

                lda YPOS,X              ; get Y-coord
                adc COORD2,Y            ; add Y offset
                sta PLOTY               ; save it
                cmp #96                 ; off screen?
                bcs _next1              ; Yes. don't plot

                jsr PLOT                ; get plot addr

                lda PLOTCLR             ; erase it?
                bne _clearIt            ; Yes. clear it

                lda PlotBits,X          ; get plot bits
                ora (LO),Y              ; alter display
_next3          sta (LO),Y              ; and replot it!
                jmp _next1

_clearIt        lda EraseBits,X         ; erase bits
                and (LO),Y              ; turn off pixel
                jmp _next3              ; put it back

                .endproc
