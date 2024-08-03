
;--------------------------------------
; Data areas
;--------------------------------------

BombLimits      .byte 0,250             ; top/bottom limits

SHAPE_Bomb      .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................

                .byte $DC    ; ####..######....
                .byte $3E    ; ....##########..
                .byte $7E    ; ..############..
                .byte $3E    ; ....##########..
                .byte $DC    ; ####..######....

                .byte $00    ; ................         ; <- top row of left bomb
                .byte $00    ; ................
                .byte $00    ; ................

                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................         ; <- bottom row of right bomb

                .byte $76    ; ..######..####..
                .byte $F8    ; ##########......
                .byte $FC    ; ############....
                .byte $F8    ; ##########......
                .byte $76    ; ..######..####..

                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................
                .byte $00    ; ................

BombPosStart    .byte 27,16             ; bottom row pointer
BombOffsetX     .byte 47,42

;--------------------------------------

SaucerColor     .byte $34,$F8

SHAPE_Saucer    .byte $00    ; ........
                .byte $00    ; ........
                .byte $18    ; ...##...
                .byte $7E    ; .######.
                .byte $00    ; ........
                .byte $00    ; ........
                .byte $7E    ; .######.
                .byte $18    ; ...##...
                .byte $00    ; ........
                .byte $00    ; ........

SaucerMiddle    .byte $92    ; #..#..#.
                .byte $49    ; .#..#..#
                .byte $24    ; ..#..#..
                .byte $92    ; #..#..#.

SaucerStartX    .byte 40,$FF,210,$FF
SaucerStartY    .byte $FF,20,$FF,230
SaucerEndX      .byte $FF,210,$FF,40
SaucerEndY      .byte 20,$FF,230,$FF

;--------------------------------------
; Explosion data tables
;--------------------------------------

PlotBits        .byte $C0,$30,$0C,$03
EraseBits       .byte $3F,$CF,$F3,$FC

PROMSK          .byte 0,0,0,0
                .byte $FF,$FF,$FF,$FF
                .byte $FF,$FF,$AA,$AA

COORD1          .byte 0,1,255,0,255,1
                .byte 0,2,255,254,0,1
                .byte 0,254,2,1,1,255
                .byte 0,2,254,255,3,0
                .byte 253,254,3,2,255,254
                .byte 1,255,3,253,1,253,2

COORD2          .byte 0,0,1,255,0,1
                .byte 1,0,255,1,2,255
                .byte 254,255,1,2,254,2
                .byte 3,255,0,254,1,253
                .byte 0,254,255,2,3,2
                .byte 253,253,0,1,3,255,254

;--------------------------------------
; Initial score line
;--------------------------------------

ScoreINI        .byte $00,$00,$00,$00   ; '        '
                .byte $00,$00,$00,$00
                .byte $4C,$56,$4C,$00   ; 'LVL '
                .byte $00,$00,$2A,$2A   ; '  ***** '
                .byte $2A,$2A,$2A,$00

ScoreColor      .byte $00
                .byte $80,$80,$80,$80,$80,$80
                .byte $00
                .byte $20,$20,$20,$20,$20   ; 'LVL '
                .byte $00
                .byte $30,$30,$30,$30,$30
                .byte $00

;--------------------------------------
; Level tables
;--------------------------------------

INIBOM          .byte 10,15,20,25,20,25         ; bombs/level
                .byte 15,20,25,20,25,30
INIBS           .byte 12,11,10,9,8,7            ; bomb speed
                .byte 7,6,5,5,4,3
INISC           .byte 0,10,50,90,50,80          ; saucer chance
                .byte 40,60,100,80,120,125
INIPC           .byte $20,$30,$40,$50,$60       ; planet color
                .byte $70,$80,$A0,$B0,$C0
                .byte $D0,$FF
INIBVH          .byte 0,0,0,0,0,0               ; bomb value high
                .byte 0,0,0,$01,$01,$01
INIBVL          .byte $10,$20,$30,$40,$50       ; bomb value low
                .byte $60,$70,$80,$90,$00
                .byte $10,$20
INISV           .byte 0,1,1,1,2,2               ; saucer value
                .byte 3,3,3,4,4,4

;--------------------------------------
; Sound data
;--------------------------------------

PLSHOT          .byte 244,254,210,220
                .byte 176,186,142,152,108
                .byte 118,74,84,40,50
ENSHOT          .byte 101,96,85,80,69,64
                .byte 53,48,37,32,21,16,5,0
SAUSND          .byte 10,11,12,14,16,17
                .byte 18,17,16,14,12,11


;--------------------------------------
; Program variables
;--------------------------------------

ExplosionX      .fill 20                ; all expl. x's
ExplosionY      .fill 20                ; all expl. y's
ExplosionCount  .fill 20                ; all expl. counts

isBombActive    .fill 4                 ; bomb active flags
isProjActive    .fill 8                 ; proj. active flags

BombX           .fill 4                 ; bomb x positions
ProjX           .fill 8                 ; proj. x positions
BombY           .fill 4                 ; bomb y positions
ProjY           .fill 8                 ; proj. y positions

BXINC           .fill 4                 ; bomb x vectors
PXINC           .fill 8                 ; proj. x vectors
BYINC           .fill 4                 ; bomb y vectors
PYINC           .fill 8                 ; proj. y vectors

BXHOLD          .fill 12                ; b/p hold areas
BYHOLD          .fill 12                ; b/p hold areas

lrBomb          .fill 4                 ; bomb left/right
lrProj          .fill 8                 ; proj. left/right
udBomb          .fill 4                 ; bomb up/down
udProj          .fill 8                 ; proj. up/down

SCOLIN          .fill 20                ; score line
