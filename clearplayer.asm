;======================================
; Move the player indicated off-screen
;--------------------------------------
; on entry:
;   X           player index to move
; perserves:
;   X
;======================================
ClearPlayer     .proc
                phx

                .m16
                txa
                and #$FF
                asl A                   ; *8
                asl A
                asl A
                tax
                lda #0                  ; move player...
                sta SP00_X_POS,X        ; off screen
                sta SP00_Y_POS,X
                .m8

                plx
                rts
                .endproc
