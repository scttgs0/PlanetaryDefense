
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
                ;!!sta SPR(sprite_t.X, IDX_PLYR),X
                ;!!.frsSpriteSetY_ix
                ;!!sta SPR(sprite_t.Y, IDX_PLYR),X
                ;!!.m8

                plx
                rts
                .endproc
