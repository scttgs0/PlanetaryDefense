;--------------------------------------
; Screen + Player/Missile Area
;--------------------------------------

SCRN            = $3000                 ; screen area
PPOS            = SCRN+1935             ; planet pos

PM              = $00
MISL            = PM+$0300              ; missiles
PLR0            = MISL+$0100            ; player 0
PLR1            = PLR0+$0100            ; player 1
PLR2            = PLR1+$0100            ; player 2
PLR3            = PLR2+$0100            ; player 3

ORBX            = $1E00                 ; orbit X
ORBY            = $1F00                 ; orbit Y

CharResX        = 40
CharResY        = 30
