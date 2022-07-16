
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
; ------------------


                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "atari-screen-inverse"
                .cdef " @",$C0
                .cdef "AZ",$A1
                .cdef "az",$E1
            .enc "none"


;-------------------------------------
;-------------------------------------
                * = TitleDL-40
;-------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00

                jmp Planet


;-------------------------------------
;-------------------------------------
                * = $2000
;-------------------------------------

                .include "interrupt.asm"
                .include "planet.asm"
                .include "orbiter.asm"
                .include "main.asm"
                .include "explosion.asm"
                .include "plot.asm"
                .include "bomb.asm"
                .include "sauser.asm"
                .include "projectile.asm"
                .include "console.asm"
                .include "sound.asm"
                .include "advance.asm"
                .include "clearplayer.asm"
                .include "vector.asm"
                .include "score.asm"
                .include "data.asm"

;--------------------------------------

                .end
