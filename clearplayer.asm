
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

                ;!!.m16
                txa
                and #$FF
                asl                     ; *8
                asl
                asl
                tax
                lda #0                  ; move player off screen
                ;!!.frsSpriteSetX_ix
                ;!!sta SPR(sprite_t.X, 0),X
                ;!!.frsSpriteSetY_ix
                ;!!sta SPR(sprite_t.Y, 0),X
                ;!!.m8

                plx
                rts
                .endproc
