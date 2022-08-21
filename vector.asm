;======================================
; Calculate target vector
;======================================
VECTOR          .proc
                lda #0
                sta LR                  ; going left
                lda FROMX               ; from X-coord
                cmp zpTargetX           ; w/to X-coord
                bcc _right              ; to right? Yes.

                sbc zpTargetX           ; get X-diff
                jmp _vecY               ; skip next

_right          inc LR                  ; going right
                lda zpTargetX           ; to X-coord
                sec
                sbc FROMX               ; get X-diff
_vecY           sta VXINC               ; save difference
                lda #1
                sta UD                  ; going up flag
                lda FROMY               ; from Y-coord
                cmp zpTargetY           ; w/to Y-coord
                bcc _down               ; down? Yes.

                sbc zpTargetY           ; get Y-diff
                jmp _vecSet             ; skip next

_down           dec UD                  ; going down flag
                lda zpTargetY           ; to Y-coord
                sec
                sbc FROMY               ; get Y-diff
_vecSet         sta VYINC               ; are both
                ora VXINC               ; distances 0?
                bne _next1              ;   No. skip next

                lda #$80                ; set x increment
                sta VXINC               ; to default.
_next1          lda VXINC               ; X vector incre
                bmi _XIT                ; >127? Yes.

                lda VYINC               ; Y vector incre
                bmi _XIT                ; >127? Yes.

                asl VXINC               ; times 2 until
                asl VYINC               ; one is >127
                jmp _next1

_XIT            rts
                .endproc
