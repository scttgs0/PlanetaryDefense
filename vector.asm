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
