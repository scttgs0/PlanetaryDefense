;--------------------------------------
; Page Zero Registers
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

INDEX           .word ?                 ; temp index
INDX1           .word ?                 ; temp index
INDX2           .word ?                 ; temp index
COUNT           .byte ?                 ; temp register
TEMP            .byte ?                 ; temp register
SATEMP          .byte ?                 ; temp register
SCNT            .byte ?                 ; orbit index
LO              .byte ?                 ; plot low byte
HI              .byte ?                 ; plot high byte
DEADTM          .byte ?                 ; death timer
EXPTIM          .byte ?                 ; explosion timer
BOMTIM          .byte ?                 ; bomb timer
SATPIX          .byte ?                 ; sat. pic cntr
CURX            .byte ?                 ; cursor x
CURY            .byte ?                 ; cursor y
FROMX           .byte ?                 ; vector from X
FROMY           .byte ?                 ; vector from Y
zpTargetX       .byte ?                 ; vector to X
zpTargetY       .byte ?                 ; vector to Y
SATX            .byte ?                 ; satellite x
SATY            .byte ?                 ; satellite y
XHOLD           .byte ?                 ; x reg hold area
LASTRG          .byte ?                 ; last trigger
LEVEL           .byte ?                 ; level number
vBombLevel      .byte ?                 ; bomb level #
LIVES           .byte ?                 ; lives left
SCORE           .fill 3                 ; score digits
SCOADD          .fill 3                 ; score inc.
SHOBYT          .byte ?                 ; digit hold
SHCOLR          .byte ?                 ; digit color
SATLIV          .byte ?                 ; satellite flag
BOMVL           .byte ?                 ; bomb value low
BOMVH           .byte ?                 ; bomb value high
SAUVAL          .byte ?                 ; saucer value
GAMCTL          .byte ?                 ; game ctrl flag
DLICNT          .byte ?                 ; DLI counter
SAUCER          .byte ?                 ; saucer flag
SAUTIM          .byte ?                 ; image timer
SAUCHN          .byte ?                 ; saucer chance
BOMBWT          .byte ?                 ; bomb wait time
BOMCOL          .byte ?                 ; bomb collis flg
DEVICE          .byte ?                 ; koala pad sw
vPlanetColor    .byte ?
PAUSED          .byte ?                 ; pause flag
SSSCNT          .byte ?                 ; saucer snd cnt
EXSCNT          .byte ?                 ; expl. snd count
ESSCNT          .byte ?                 ; enemy shot snd
PSSCNT          .byte ?                 ; player shot snd
isTitleScreen   .byte ?                 ; title scrn flag
EXPCNT          .byte ?                 ; explosion counter
NEWX            .byte ?                 ; explosion x
NEWY            .byte ?                 ; explosion y
PLOTCLR         .byte ?                 ; plot/erase flag
COUNTR          .byte ?                 ; explosion index
PLOTX           .byte ?                 ; plot x coord
PLOTY           .byte ?                 ; plot y coord
HIHLD           .byte ?                 ; plot work area
LOHLD           .byte ?                 ; plot work area
BOMBS           .byte ?                 ; bombs to come
BOMTI           .byte ?                 ; bomb speeds
VXINC           .byte ?                 ; vector x hold
VYINC           .byte ?                 ; vector y hold
LR              .byte ?                 ; vector left/right hold
UD              .byte ?                 ; vector up/down hold
DELTAX          .byte ?                 ; vector work area
DELTAY          .byte ?                 ; vector work area

JIFFYCLOCK      .byte ?
InputFlags      .byte ?
InputType       .byte ?
itJoystick  = 0
itKeyboard  = 1
KEYCHAR         .byte ?                 ; last key pressed
CONSOL          .byte ?                 ; state of OPTION,SELECT,START

zpSource        .dword ?                ; Starting address for the source data (4 bytes)
zpDest          .dword ?                ; Starting address for the destination block (4 bytes)
zpSize          .dword ?                ; Number of bytes to copy (4 bytes)

zpTemp1         .byte ?
zpTemp2         .byte ?

zpIndex1        .word ?
zpIndex2        .word ?
zpIndex3        .word ?

RND_MIN         .byte ?
RND_SEC         .byte ?
RND_RESULT      .word ?
