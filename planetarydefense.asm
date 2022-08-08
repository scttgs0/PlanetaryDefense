
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
; ------------------

;   SP00        player
;   SP03        saucer
;   SP04        satellite

                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"
                .include "macros_frs_random.asm"


;-------------------------------------
;-------------------------------------
                * = INIT-40
;-------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00
                cld

                jmp Planet


;-------------------------------------
;-------------------------------------
                * = $2000
;-------------------------------------
                .include "main.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_c256.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "planet.asm"
                .include "orbiter.asm"
                .include "explosion.asm"
                .include "plot.asm"
                .include "bomb.asm"
                .include "saucer.asm"
                .include "projectile.asm"
                .include "console.asm"
                .include "sound.asm"
                .include "advance.asm"
                .include "clearplayer.asm"
                .include "vector.asm"
                .include "score.asm"
                .include "data.asm"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.asm"
GameFont_end

Palette         .include "PALETTE.asm"
Palette_end

                .end
