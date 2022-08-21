;======================================
; Projectile initializer
;======================================
ProjectileInit  .proc
                ldx #5                  ; 6 projectiles
_next1          lda PROACT,X            ; get status
                beq _gotpro             ; active? No.

                dex                     ; Yes. try again
                bpl _next1              ; done? No.

                rts


; -----------------
; Got a projectile!
; -----------------

_gotpro         lda #13                 ; shot sound time
                sta PSSCNT              ; player shot sound
                lda zpSatelliteX        ; satellite X
                sta FROMX               ; shot from X
                sta PROJX,X             ; proj X table
                lda zpSatelliteY        ; satellite Y
                sta FROMY               ; shot from Y
                sta PROJY,X             ; proj Y table

                lda zpCursorX           ; cursor X-coord
                sec                     ; set carry
                sbc #48                 ; playfld offset
                sta zpTargetX           ; shot to X-coord

                lda zpCursorY           ; cursor Y-coord
                sec                     ; set carry
                sbc #32                 ; playfld offset
                lsr A                   ; 2 line res
                sta zpTargetY           ; shot to Y-coord

_PROVEC         jsr VECTOR              ; compute vect

                lda VXINC               ; X increment
                sta PXINC,X             ; X inc table
                lda VYINC               ; Y increment
                sta PYINC,X             ; Y inc table
                lda LR                  ; L/R flag
                sta PROJLR,X            ; L/R flag table
                lda UD                  ; U/D flag
                sta PROJUD,X            ; U/D flag table
                lda #1                  ; active
                sta PROACT,X            ; proj status
                rts
                .endproc


;======================================
; Projectile advance handler
;======================================
ProjectileAdvance .proc
                ldx #11                 ; do 8: 11..4
_next1          lda BOMACT,X            ; active?
                beq _nextProj           ; No. skip next

                lda BOMBX,X             ; bomb X-coord
                sta PLOTX               ; plotter X
                lda BOMBY,X             ; bomb Y-coord
                sta PLOTY               ; plotter Y
                stx XHOLD               ; X-reg temporary
                jsr PLOT                ; calc plot addr

                lda (LO),Y              ; get plot byte
                and EraseBits,X         ; erase bit
                sta (LO),Y              ; replace byte
                ldx XHOLD               ; restore X
                jsr AdvanceIt           ; advance proj

                lda BOMBX,X             ; bomb X-coord
                cmp #160                ; off screen?
                bcs _killProj           ; Yes. kill it

                sta PLOTX               ; plotter X
                lda BOMBY,X             ; bomb Y-coord
                cmp #96                 ; off screen?
                bcs _killProj           ; Yes. kill it

                sta PLOTY               ; plotter Y
                jsr PLOT                ; calc plot addr

                lda PlotBits,X          ; get plot mask
                and (LO),Y              ; chk collision
                beq _projOK             ; No. plot it

                ldx XHOLD               ; restore X
                lda PLOTX               ; proj X-coord
                sta NEWX                ; explo X-coord
                lda PLOTY               ; proj Y-coord
                sta NEWY                ; explo Y-coord
                jsr NewExplosion        ; set off explo

_killProj       lda #0                  ; get zero
                sta BOMACT,X            ; kill proj
                jmp _nextProj           ; skip next

_projOK         lda PlotBits,X          ; plot mask
                ldx XHOLD               ; restore X
                and PROMSK,X            ; mask color
                ora (LO),Y              ; add playfield
                sta (LO),Y              ; replace byte
_nextProj       dex                     ; next projectile
                cpx #3                  ; proj #3 yet?
                bne _next1              ; No. continue

                rts
                .endproc
