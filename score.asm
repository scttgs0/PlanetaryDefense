
;======================================
; Add to score
;======================================
AddScore        .proc
                ldy #0                  ; init index
                sed                     ; decimal mode
                clc

                ldx #2                  ; do 3 bytes
_next1          lda SCORE,X             ; get score
                adc SCOADD,X            ; add bomb value
                sta SCORE,X             ; save score
                sty SCOADD,X            ; zero value

                dex                     ; next byte
                bpl _next1

                cld                     ; clear decimal

                .endproc

                ;[fall-through]


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
                bne _next1              ;   no!

                jsr RenderScoreLine

                rts
                .endproc


;======================================
; Show level number
;======================================
ShowLevel       .proc
                ldy #$30                ; use color 2
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
                ;!!ora SHCOLR              ; add color
                ora #$30
                sta SCOLIN+1,X          ; show it

                lda SHOBYT              ; get both again
                lsr                     ; /16 (get upper nibble)
                lsr
                lsr
                lsr
                ;!!ora SHCOLR              ; add color
                ora #$30
                sta SCOLIN,X            ; show it!

                rts
                .endproc
