
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

; Enhance: ---------------------------------------------------------------
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
        beq     CHECK_DELAY_COUNT
        and.l   #$00FFFFFF,D0

COMPARE_VOICE_LEVEL
        swap    D0
        cmp.b   $10(A5),D0
        bcs.w   GOTO_ORIGIN_CLEAN
        jmp     ORIGIN_VOICE_OVERWRITE

CHECK_DELAY_COUNT
        move.l  D1,-(SP)
        move.l  D0,D1
        and.l   #$FF000000,D1
        swap    D1
        addi.w  #$0100,D1               ; delay step
        cmpi.w  #$0C00,D1               ; max delay count
        bge     MAX_DELAY_COUNT
        swap    D1
        and.l   #$00FFFFFF,D0
        or.l    D1,D0
        move.l  D0,(NEXT_VOICE_CMD)
        move.l  (SP)+,D1
GOTO_ORIGIN_CLEAN
        jmp     ORIGIN_CLEAN

MAX_DELAY_COUNT
        move.l  (SP)+,D1
        and.l   #$00FFFFFF,D0
        bra.w   COMPARE_VOICE_LEVEL
