
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

                ; .m16
                txa
                and #$FF
                asl                     ; *8
                asl
                asl
                tax
                lda #0                  ; move player off screen
                sta SP00_X,X
                sta SP00_Y,X
                ; .m8

                plx
                rts
                .endproc
