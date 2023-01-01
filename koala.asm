;======================================
; KOALA PAD interface
;--------------------------------------
; The following filtering
; algorithm is used:
;
; Given 5 points S1,S2,S3,S4,S5
;
; R1=S1+S2+S2+S3
; R2=S2+S3+S3+S4
; R3=S3+S4+S4+S5
;
; AVG=(R1+R2+R2+R3)/16
;
; This reduces to:
;
; AVG=(S1+S2*4+S3*6+S4*4+S5)/16
;
; ---------------------------
; Rotate points through queue
; ---------------------------
;======================================
KOALA           ldx #4                  ;do 5 bytes
ROT             lda XQ-1,X              ;move X queue
                sta XQ,X                ;up one byte
                lda YQ-1,X              ;move Y queue
                sta YQ,X                ;up one byte
                dex                     ;dec count
                bne ROT                 ;done? No.


; --------------------
; Clear out the cursor
; --------------------

                ldy CURY                ;get Y coord
                ldx #5                  ;do 6 bytes
CCURS           lda MISL,Y              ;get missiles
                and #$F0                ;mask off low
                sta MISL,Y              ;put back
                dex                     ;dec count
                bpl CCURS               ;done? No.


; ---------------------------
; Insert new point into queue
; ---------------------------

                lda #1                  ;pen up flag
                sta PENFLG              ;set pen up
                lda PADDL0              ;X input
                sta XQ                  ;put in queue
                cmp #5                  ;screen boundary
                bcc KOALAX              ;on screen? No.

                lda PADDL1              ;Y input
                sta YQ                  ;put in queue
                cmp #5                  ;screen boundary
                bcc KOALAX              ;on screen? No.


; ---------------------
; Filter the X-Y queues
; ---------------------

                lda #<XQ                ;queue addr low
                sta PTR                 ;pointer low
                lda #>XQ                ;queue addr high
                sta PTR+1               ;pointer high
                jsr FILTER              ;filter X data

                bcs KOALAX              ;good data? No.

                adc #16                 ;X offset
                cmp #48                 ;far left?
                bcs FLF                 ;No. skip

                lda #48                 ;screen left
FLF             cmp #208                ;far right?
                bcc FRT                 ;No. skip

                lda #207                ;screen right
FRT             sta CURX                ;put X coord
                lda #<YQ                ;queue addr low
                sta PTR                 ;pointer low
                lda #>YQ                ;queue addr high
                sta PTR+1               ;pointer high
                jsr FILTER              ;filter Y data

                bcs KOALAX              ;good data? No.

                adc #16                 ;Y offset
                cmp #32                 ;above top?
                bcs FUP                 ;No. skip

                lda #32                 ;screen top
FUP             cmp #224                ;below bottom?
                bcc FDN                 ;No. skip

                lda #223                ;screen bottom
FDN             sta CURY                ;put Y coord

; ----------------------
; Paddle trigger handler
; ----------------------

                lda PTRIG0              ;paddle trig 0
                eor PTRIG1              ;EOR w/PTRIG1
                eor #1                  ;inverse data
                sta STRIG0              ;put in STRIG0
                lda #0                  ;pen down flag
                sta PENFLG              ;set pen down
KOALAX          rts                     ;continue


;======================================
; Filter algorithm, initialize
;======================================
FILTER          lda #0                  ;get zero
                ldx #4                  ;do 5 bytes
FILC            sta SH,X                ;high byte table
                dex                     ;dec count
                bpl FILC                ;done? No.

                sta AVG                 ;average low
                sta AVG+1               ;average high
                tay                     ;xero in Y
                ldx #1                  ;one in X

; -----------------------
; Process the X-Y samples
; -----------------------

                lda (PTR),Y             ;get S1
                sta SL,Y                ;save low byte
                iny                     ;inc pointer
                jsr MUL4                ;process S2

                lda (PTR),Y             ;get S3
                asl A                   ;times 2
                rol SH,X                ;rotate carry
                adc (PTR),Y             ;add = times 3
                bcc FIL2                ;overflow? No.

                inc SH,X                ;inc high byte
FIL2            asl A                   ;times 6
                rol SH,X                ;rotate carry
                sta SL,X                ;save low byte
                inx                     ;inc pointer
                iny                     ;inc pointer
                jsr MUL4                ;process S4

                lda (PTR),Y             ;get S5
                sta SL,Y                ;save low byte

; -------------
; Total samples
; -------------

                ldx #4                  ;add 5 elements
ALOOP           lda SL,X                ;get low byte
                adc AVG                 ;add to average
                sta AVG                 ;save low byte
                lda SH,X                ;get high byte
                adc AVG+1               ;add to average
                sta AVG+1               ;save high byte
                dex                     ;dec pointer
                bpl ALOOP               ;done? No.


; ------------------
; Divide total by 16
; ------------------

                ldx #4                  ;shift 4 bits
                lda AVG                 ;get lo byte
DIV16           lsr AVG+1               ;rotate high
                ror A                   ;rotate low
                dex                     ;dec count
                bne DIV16               ;done? No.

                tax                     ;save Acc

; --------------------------
; Compare average with DELTA
; --------------------------

                ldy #4                  ;5 byte table
MEAN            sec                     ;set carry
                sbc (PTR),Y             ;compare points
                bcs POSI                ;negative? No.

                eor #$FF                ;negate byte and
                adc #1                  ;+1 = ABS value
POSI            cmp #24                 ;within DELTA?
                bcs FAIL                ;No. abort

                txa                     ;get Acc again
                dey                     ;dec pointer
                bpl MEAN                ;done? No.

FAIL            rts                     ;exit


;======================================
; Multply Acc by 4
;======================================
MUL4            lda (PTR),Y             ;get S2
                asl A                   ;times 2
                rol SH,X                ;rotate carry
                asl A                   ;times 4
                rol SH,X                ;rotate carry
                sta SL,X                ;save low byte
                inx                     ;inc pointer
                iny                     ;inc pointer
                rts                     ;return
