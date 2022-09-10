;-------------------------------------
; Setup Orbiter Coordinates
;-------------------------------------
SetupOrbiter    .proc
                ldx #64                 ; do 65 bytes               ;               |
                ldy #0                  ; quad 2/4 offset           ;    quad-4     |    quad-1
_next1          clc                                                 ;               |
                lda #96                 ; center Y                  ; ----------------------------
                adc _tblOrbiterY,X      ; add offset Y              ;               |
                sta ORBY+$40,Y          ; quad-2 Y                  ;    quad-3     |    quad-2
                sta ORBY+$80,X          ; quad-3 Y                  ;               |

                lda #80                 ; center X
                adc _tblOrbiterX,X      ; add offset X
                sta ORBX,X              ; quad-1 X                  ; ORBX/Y :=     [00-3F]:quad-1  [40-7F]:quad-2  [80-BF]:quad-3  [C0-FF]:quad-4
                sta ORBX+$40,Y          ; quad-2 X

                sec
                lda #80                 ; center X
                sbc _tblOrbiterX,X      ; sub offset X
                sta ORBX+$80,X          ; quad-3 X
                sta ORBX+$C0,Y          ; quad-4 X

                lda #96                 ; center Y
                sbc _tblOrbiterY,X      ; sub offset Y
                sta ORBY,X              ; quad-1 Y
                sta ORBY+$C0,Y          ; quad-4 Y

                iny                     ; quad 2/4 offset
                dex                     ; quad 1/3 offset
                bpl _next1

                jmp INIT                ; continue

;--------------------------------------

_tblOrbiterX    .byte 0,1,2,2,3         ; ---------------------------
                .byte 4,5,5,6,7         ; Orbiter X,Y Coordinate Data
                .byte 8,9,9,10,11       ; ---------------------------
                .byte 12,12,13,14,14
                .byte 15,16,16,17,18
                .byte 18,19,20,20,21
                .byte 21,22,23,23,24
                .byte 24,25,25,26,26
                .byte 27,27,27,28,28
                .byte 29,29,29,30,30
                .byte 30,30,31,31,31
                .byte 31,31,32,32,32
                .byte 32,32,32,32,32

_tblOrbiterY    .byte 54,54,54,54,54
                .byte 54,54,54,53,53
                .byte 53,52,52,52,51
                .byte 51,50,50,49,49
                .byte 48,47,47,46,45
                .byte 44,44,43,42,41
                .byte 40,39,38,38,37
                .byte 36,35,33,32,31
                .byte 30,29,28,27,26
                .byte 24,23,22,21,20
                .byte 18,17,16,15,13
                .byte 12,11,9,8,7
                .byte 5,4,3,1,0

                .endproc


;======================================
; Check satellite status
;======================================
CheckSatellite  .proc
                lda DEADTM              ; satellite ok?
                beq _live               ;   No. skip next

_XIT            rts

_live           lda LIVES               ; lives left?
                bmi _XIT                ;   No. exit

                lda #TRUE
                sta isSatelliteAlive    ; set alive flag

                ;lda M0PL               ; did satellite
                ;ora M0PL+1             ; hit any bombs?
                ;beq _XIT               ;   No. exit
                bra _XIT    ; HACK:

                lda #0
                sta isSatelliteAlive    ; kill satellite
                sta SCNT                ; init orbit
                ldx LIVES               ; one less life
                sta SCOLIN+14,X         ; erase life
                dec LIVES               ; dec lives count
                bpl _moreSats           ; any left? Yes.

                lda #NIL
                sta zpBombCount         ; lot of bombs into bomb count
                sta GAMCTL              ; end game
                jsr SoundOff            ; no sound 1 2 3

_moreSats       lda zpSatelliteX        ; sat X-coord
                sta NEWX                ; explo X-coord
                lda zpSatelliteY        ; sat Y-coord
                sta NEWY                ; explo Y-coord
                jsr NewExplosion        ; set off explo

                lda #80                 ; init sat X
                sta zpSatelliteX        ; sat X-coord
                lda #21                 ; init sat Y
                sta zpSatelliteY        ; sat Y-coord

                ;ldx #0                  ; don't show the
;_clearSat       ;lda MISL,X              ; satellite pic
                ;and #$F0                ; mask off sat
                ;sta MISL,X              ; restore data
                ;dex                     ; dec index
                ;bne _clearSat           ; done? No.

                lda #$FF                ; 4.25 seconds
                sta DEADTM              ; till next life!
                rts
                .endproc
