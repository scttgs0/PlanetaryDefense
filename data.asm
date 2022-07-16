; ----------
; Data areas
; ----------

BMAXS           .byte 0,250             ; bomb limits
BOMPIC          .byte 0,0,0,0,0,0,$DC,$3E
                .byte $7E,$3E,$DC,0,0,0,0
                .byte 0,0,$76,$F8,$FC
                .byte $F8,$76,0,0,0,0,0,0
BPSTRT          .byte 27,16
BXOF            .byte 47,42
P3COLR          .byte $34,$F8
SAUPIC          .byte 0,0,$18,$7E,0,0
                .byte $7E,$18,0,0
SAUMID          .byte $92,$49,$24,$92
STARTX          .byte 40,$FF,210,$FF
STARTY          .byte $FF,20,$FF,230
ENDX            .byte $FF,210,$FF,40
ENDY            .byte 20,$FF,230,$FF

; ---------------------
; Explosion data tables
; ---------------------

PLOTBL          .byte $C0,$30,$0C,$03
ERABIT          .byte $3F,$CF,$F3,$FC
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

; ------------------
; Initial score line
; ------------------

SCOINI          .byte $00,$00,$00,$00
                .byte $00,$00,$00,$00
                .byte $6C,$76,$6C,$00
                .byte $00,$00,$CA,$CA
                .byte $CA,$CA,$CA,$00

; ------------
; Level tables
; ------------

INIBOM          .byte 10,15,20,25,20,25
                .byte 15,20,25,20,25,30
INIBS           .byte 12,11,10,9,8,7
                .byte 7,6,5,5,4,3
INISC           .byte 0,10,50,90,50,80
                .byte 40,60,100,80,120,125
INIPC           .byte $20,$30,$40,$50,$60
                .byte $70,$80,$A0,$B0,$C0
                .byte $D0,$FF
INIBVH          .byte 0,0,0,0,0,0
                .byte 0,0,0,$01,$01,$01
INIBVL          .byte $10,$20,$30,$40,$50
                .byte $60,$70,$80,$90,$00
                .byte $10,$20
INISV           .byte 0,1,1,1,2,2
                .byte 3,3,3,4,4,4

; ----------
; Sound data
; ----------

PLSHOT          .byte 244,254,210,220
                .byte 176,186,142,152,108
                .byte 118,74,84,40,50
ENSHOT          .byte 101,96,85,80,69,64
                .byte 53,48,37,32,21,16,5,0
SAUSND          .byte 10,11,12,14,16,17
                .byte 18,17,16,14,12,11


; -----------------
; Program variables
; -----------------

XPOS            .fill 20                ; all expl. x's
YPOS            .fill 20                ; all expl. y's
CNT             .fill 20                ; all expl. counts
BOMACT          .fill 4                 ; bomb active flags
PROACT          .fill 8                 ; proj. active flags
BOMBX           .fill 4                 ; bomb x positions
PROJX           .fill 8                 ; proj. x positions
BOMBY           .fill 4                 ; bomb y positions
PROJY           .fill 8                 ; proj. y positions
BXINC           .fill 4                 ; bomb x vectors
PXINC           .fill 8                 ; proj. x vectors
BYINC           .fill 4                 ; bomb y vectors
PYINC           .fill 8                 ; proj. y vectors
BXHOLD          .fill 12                ; b/p hold areas
BYHOLD          .fill 12                ; b/p hold areas
BOMBLR          .fill 4                 ; bomb left/right
PROJLR          .fill 8                 ; proj. left/right
BOMBUD          .fill 4                 ; bomb up/down
PROJUD          .fill 8                 ; proj. up/down
SCOLIN          .fill 20                ; score line
