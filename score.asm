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
