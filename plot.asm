;======================================
; Dedicated multiply by 40
; with result in LO and HI
;======================================
PLOT            .proc
                lda PLOTY               ; get Y-coord
                asl A                   ; shift it left
                sta LO                  ; save low *2
                lda #0
                sta HI                  ; init high byte
                asl LO                  ; shift low byte
                rol HI                  ; rotate high *4
                asl LO                  ; shift low byte
                lda LO                  ; get low byte
                sta LOHLD               ; save low *8
                rol HI                  ; rotate high *8
                lda HI                  ; get high byte
                sta HIHLD               ; save high *8
                asl LO                  ; shift low byte
                rol HI                  ; rotate high *16
                asl LO                  ; shift low byte
                rol HI                  ; rotate high *32
                lda LO                  ; get low *32
                clc
                adc LOHLD               ; add low *8
                sta LO                  ; save low *40
                lda HI                  ; get high *32
                adc HIHLD               ; add high *8
                sta HI                  ; save high *40

; -----------------------------
; Get offset into screen memory
; -----------------------------

                lda #<Playfield         ; screen addr lo
                clc
                adc LO                  ; add low offset
                sta LO                  ; save addr low
                lda #>Playfield         ; screen addr hi
                adc HI                  ; add high offset
                sta HI                  ; save addr hi
                lda PLOTX               ; mask PLOTX for
                and #3                  ; the plot bits,
                tax                     ; place in X..
                lda PLOTX               ; get PLOTX and
                lsr A                   ; divide
                lsr A                   ; by 4
                clc                     ; and add to
                adc LO                  ; plot address
                sta LO                  ; for final plot
                bcc _1                  ; address.

                inc HI                  ; overflow? Yes.
_1              ldy #0                  ; zero Y register
                rts
                .endproc
