
;--------------------------------------
; Hardware Registers
;--------------------------------------

AVB             = $0040
ALMS            = $0040
AJMP            = $0001
AEMPTY2         = $0010
AEMPTY3         = $0020
AEMPTY5         = $0040
AEMPTY8         = $0070

ATRACT          = $004D                 ; attract flag

HPOSP0          = $D000                 ; P0 horizontal
HPOSM0          = $D004                 ; M0 horizontal
P0PF            = $D004                 ; P0-PField coll.
M0PL            = $D008                 ; M0-PLayer coll.
GRAFP0          = $D00D                 ; PM graphics
COLPF0          = $D016                 ; PF color 0
GRACTL          = $D01D                 ; graphic control
HITCLR          = $D01E                 ; clear hit reg
CONSOL          = $D01F                 ; console buttons

AUDF1           = $D200                 ; frequency 1
AUDC1           = $D201                 ; volume 1
AUDCTL          = $D208                 ; audio control
RANDOM          = $D20A                 ; random numbers

DMACTL          = $D400                 ; DMA control
PMBASE          = $D407                 ; PM base address
WSYNC           = $D40A                 ; wait hor. sync
NMIEN           = $D40E                 ; interrupt reg.

;--------------------------------------
; Operating System Vectors
;--------------------------------------

SETVBV          = $E45C                 ; set v.blank
XITVBV          = $E462                 ; exit v.blank
SIOINV          = $E465                 ; serial I/O init

;--------------------------------------
; Shadow Registers
;--------------------------------------

VDSLST          = $0200                 ; DLI vector
SDMCTL          = $022F                 ; DMA control
SDLSTL          = $0230                 ; DList pointer
GPRIOR          = $026F                 ; gr. priority
PADDL0          = $0270                 ; paddle 0
PADDL1          = $0271                 ; paddle 1
STICK0          = $0278                 ; joystick 0
PTRIG0          = $027C                 ; paddle trig 0
PTRIG1          = $027D                 ; paddle trig 1
STRIG0          = $0284                 ; stick trig 0
PCOLR0          = $02C0                 ; player colors
COLOR0          = $02C4                 ; playfield colors
CH              = $02FC                 ; keyboard char
