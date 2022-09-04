;======================================
; Calculate target vector
;======================================
CalcVector      .proc
;   calculate delta X
                lda #0
                sta LR                  ; going left

                lda zpFromX             ; from X-coord
                cmp zpTargetX           ; w/to X-coord
                bcc _right              ; to right? Yes.

                sbc zpTargetX           ; get X-diff
                jmp _vecY

_right          inc LR                  ; going right
                lda zpTargetX           ; to X-coord
                sec
                sbc zpFromX             ; get X-diff

_vecY           sta VXINC               ; save difference

;   calculate delta Y
                lda #1
                sta UD                  ; going up flag

                lda zpFromY             ; from Y-coord
                cmp zpTargetY           ; w/to Y-coord
                bcc _down               ; down? Yes.

                sbc zpTargetY           ; get Y-diff
                jmp _vecSet

_down           dec UD                  ; going down flag
                lda zpTargetY           ; to Y-coord
                sec
                sbc zpFromY             ; get Y-diff

_vecSet         sta VYINC               ; are both distances 0?
                ora VXINC
                bne _next1              ;   No

                lda #$80                ; set x increment to default
                sta VXINC

_next1          lda VXINC               ; X vector increment >127?
                bmi _XIT                ;   Yes

                lda VYINC               ; Y vector increment >127?
                bmi _XIT                ;   Yes

                asl VXINC               ; times 2 until one is >127
                asl VYINC
                jmp _next1

_XIT            rts
                .endproc
