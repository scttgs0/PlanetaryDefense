
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
; ------------------

;   MISL        cursor
;   SP00        player
;   SP03        saucer
;   SP04        satellite
;   SP05        satellite

;   Graphics    160x120                 ; 96 graphic; 16 blanks; 8 text
;       ours    320x240                 ; 76,800 bytes [$12C00 = 300 pages]
;   Playfield   320x216                 ; 9 vertical sections of 24-lines/each


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


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.asm"
Stamps_end

Playfield       .fill 96*40,$00

;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

Video8K         .fill 8192,$00

                .end
