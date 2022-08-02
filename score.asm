;======================================
; Add to score
;======================================
AddScore        .proc
                ldy #0                  ; init index
                sed                     ; decimal mode
                clc                     ; clear carry
                ldx #2                  ; do 3 bytes
_next1          lda SCORE,X             ; get score
                adc SCOADD,X            ; add bomb value
                sta SCORE,X             ; save score
                sty SCOADD,X            ; zero value
                dex                     ; next byte
                bpl _next1

                cld                     ; clear decimal
                .endproc


;======================================
; Show score
;======================================
ShowScore       .proc
                lda #$10                ; put color 0
                sta SHCOLR              ; in hold area
                ldx #1                  ; 2nd line char
                ldy #0                  ; digits 1,2
_next1          lda SCORE,Y             ; get digits
                jsr ShowBCD             ; show 'em

                inx                     ; advance score
                inx                     ; line pointer
                iny                     ; next 2 digits
                cpy #3                  ; done 6?
                bne _next1              ; no!

                rts
                .endproc


;======================================
; Show level number
;======================================
ShowLevel       .proc
                ldy #$50                ; use color 2
                sty SHCOLR              ; save it
                lda LEVEL               ; get level #
                ldx #11                 ; 12th char on line

                .endproc

                ;[fall-through]


;======================================
; Show 2-digit BCD
;======================================
ShowBCD         .proc
                sta SHOBYT              ; save digits
                and #$0F                ; get lower digit
                ora SHCOLR              ; add color
                ;sta SCOLIN+1,X          ; show it      HACK:
                lda SHOBYT              ; get both again
                lsr A                   ; mask...
                lsr A                   ; off...
                lsr A                   ; upper...
                lsr A                   ; digit
                ora SHCOLR              ; add color
                ;sta SCOLIN,X            ; show it!     HACK:
                rts
                .endproc
