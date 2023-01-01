
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
;-------------------


                .include "equates_system_atari8.inc"
                .include "equates_zeropage.inc"
                .include "equates_game.inc"


            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "atari-screen-inverse"
                .cdef " @",$C0
                .cdef "AZ",$A1
                .cdef "az",$E1
            .enc "none"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                .include "interruptdata.asm"

                .include "planet.asm"
                .include "orbiter.asm"

                .include "interrupt.asm"
                .include "main.asm"
                .include "explosion.asm"
                .include "plot.asm"
                .include "bomb.asm"
                .include "saucer.asm"
                .include "projectile.asm"
                .include "bombadvance.asm"
                .include "projadvance.asm"
                .include "checkorbiter.asm"
                .include "endgame.asm"
                .include "sound.asm"
                .include "checkhit.asm"
                .include "advance.asm"
                .include "clearplayer.asm"
                .include "vector.asm"
                .include "score.asm"
                .include "koala.asm"
                .include "data.asm"


;--------------------------------------
;--------------------------------------
                * = $0000
;--------------------------------------
                .byte $00
;--------------------------------------
;--------------------------------------
                * = $0000
;--------------------------------------
                .byte $00
;--------------------------------------
;--------------------------------------
                * = $0000
;--------------------------------------
                .byte $00
;--------------------------------------
;--------------------------------------
                * = $0000
;--------------------------------------
                .byte $00
;--------------------------------------
;--------------------------------------
                * = $0000
;--------------------------------------
                .byte $00


;--------------------------------------
;--------------------------------------
                * = $02E0
;--------------------------------------

                .addr PLANET

                .end
