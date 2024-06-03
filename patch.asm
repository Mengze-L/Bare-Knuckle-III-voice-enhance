
ORIGIN_PUNCH_VOICE_LEVEL              set $00026209
ORIGIN_SCREAM_VOICE_LEVEL             set $000258D1
ORIGIN_VOICE_CONFLICTION              set $001A88A4
ORIGIN_VOICE_OVERWRITE                set $001A88AE
ORIGIN_CLEAN                          set $001A88E2

; Constants: -----------------------------------------------------------
NEXT_VOICE_CMD:                       equ $00FFF794

; Overrides: -----------------------------------------------------------
        org     ORIGIN_SCREAM_VOICE_LEVEL             ; F002
        dc.b    $D0

;        org     ORIGIN_PUNCH_VOICE_LEVEL
;        dc.b    $F0

        org     ORIGIN_VOICE_CONFLICTION
        jmp     CHECK_IF_SCREAM

; Ehance: ---------------------------------------------------------------
        org     $2EE600
CHECK_IF_SCREAM
        cmpi.b  #$33,D0
        beq     CHECK_IF_DELAY
        cmpi.b  #$12,D0
        beq     CHECK_IF_DELAY
        cmpi.b  #$34,D0
        beq     CHECK_IF_DELAY
        cmpi.b  #$4,D0
        beq     CHECK_IF_DELAY
        bra.w   COMPARE_VOICE_LEVEL
CHECK_IF_DELAY
        tst.l   (NEXT_VOICE_CMD)
        beq     DELAY_SCREAM

COMPARE_VOICE_LEVEL
        swap    D0
        cmp.b   $10(A5),D0
        bcs.w   GOTO_ORIGIN_CLEAN
        jmp     ORIGIN_VOICE_OVERWRITE

DELAY_SCREAM
        move.l  D0,(NEXT_VOICE_CMD)
GOTO_ORIGIN_CLEAN
        jmp     ORIGIN_CLEAN
