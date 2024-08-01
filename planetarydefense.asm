
; ------------------
; ANALOG Computing's
; PLANETARY  DEFENSE
; ------------------
; by Charles Bachand
;   and Tom Hudson
; ------------------

;   SP00        player/cursor
;   SP01        satellite
;   SP02        <unused>
;   SP03        saucer
;   SP04-07     bomb left
;   SP08-11     bomb right

;   Graphics    160x120                 ; 96 graphic; 16 blanks; 8 text
;       ours    320x240                 ; 76,800 bytes [$12C00 = 300 pages]
;   Playfield   320x216                 ; 9 vertical sections of 24-lines/each

;   PF          256x256
;   PF cursor   (48,32)(208,224)    (8,26)(311-6,225-6)
;   PF bomb     (0,0)(250,250)
;   PF saucer   (39,19)(211,231)

;   planet      (160,120)

                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/f256_text.mac"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

.if PGX=1
                .text "PGX"
                .byte $03
                .dword BOOT
;--------------------------------------
.else
                .byte $F2,$56               ; signature
                .byte $02                   ; block count
                .byte $01                   ; start at block1
                .addr BOOT                  ; execute address
                .word $0001                 ; version
                .word $0000                 ; kernel
                .null 'Planetary Defense'   ; binary name
.endif

;--------------------------------------

BOOT            cld
                ldx #$FF                ; initialize the stack
                txs
                jmp InitHardware

;-------------------------------------
;-------------------------------------

START
                .include "main.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_f256.asm"
                .include "facade.asm"


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

                .include "DATA.inc"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.inc"
GameFont_end

Palette         .include "PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.inc"
Stamps_end

Playfield       .fill 96*40,$00

;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

;Video8K         .fill 8192,$00

                .end
