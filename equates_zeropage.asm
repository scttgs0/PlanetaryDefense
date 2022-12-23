
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
zpExplosionTimer .byte ?                ; explosion timer
zpBombTimer     .byte ?                 ; bomb timer
zpSatPix        .byte ?                 ; sat. pic cntr
zpCursorX       .byte ?                 ; cursor x/y
zpCursorY       .byte ?
zpFromX         .byte ?                 ; vector from X
zpFromY         .byte ?                 ; vector from Y
zpTargetX       .byte ?                 ; vector to x/y
zpTargetY       .byte ?
zpSatelliteX    .byte ?                 ; satellite x/y
zpSatelliteY    .byte ?
XHOLD           .byte ?                 ; x reg hold area
zpLastTrigger   .byte ?                 ; last trigger
LEVEL           .byte ?                 ; level number
vBombLevel      .byte ?                 ; bomb level #
LIVES           .byte ?                 ; lives left
SCORE           .fill 3                 ; score digits
SCOADD          .fill 3                 ; score inc.
SHOBYT          .byte ?                 ; digit hold
SHCOLR          .byte ?                 ; digit color
isSatelliteAlive .byte ?                 ; satellite flag
zpBombValueLO   .byte ?                 ; bomb value low
zpBombValueHI   .byte ?                 ; bomb value high
zpSaucerValue   .byte ?                 ; saucer value
GAMCTL          .byte ?                 ; game ctrl flag    1=game in progress; -1=game over
DLICNT          .byte ?                 ; DLI counter
isSaucerActive  .byte ?                 ; saucer flag
SAUTIM          .byte ?                 ; image timer
zpSaucerChance  .byte ?                 ; saucer chance
zpBombWait      .byte ?                 ; bomb wait time
zpBombCollCnt   .byte ?                 ; bomb collis flg
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
zpBombCount     .byte ?                 ; bombs to come
zpBombSpeedTime .byte ?                 ; bomb speeds
VXINC           .byte ?                 ; vector x hold
VYINC           .byte ?                 ; vector y hold
LR              .byte ?                 ; vector left/right hold    0=left, 1=right
UD              .byte ?                 ; vector up/down hold       1=up, 0=down
DELTAX          .byte ?                 ; vector work area
DELTAY          .byte ?                 ; vector work area

isDirtyPlayfield    .byte ?

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
