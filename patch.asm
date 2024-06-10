
ORIGIN_PUNCH_VOICE_LEVEL              set $00026209
ORIGIN_SCREAM_VOICE_LEVEL             set $000258D1
ORIGIN_VOICE_CONFLICTION              set $001A88A4
ORIGIN_VOICE_OVERWRITE                set $001A88AE
ORIGIN_CLEAN_RETURN                   set $001A88E2
ORIGIN_RETURN                         set $001A88E4
ORIGIN_DELAY_COUNTDOWN                set $00FFF52A
ORIGIN_RESET_DELAY_COUNTER            set $000041FC

; Constants: -----------------------------------------------------------
NEXT_VOICE_CMD:                       equ $00FFF794
MAX_DELAY_COUNT:                      equ $A

; Overrides: -----------------------------------------------------------
        org     ORIGIN_RESET_DELAY_COUNTER
        move.b  #MAX_DELAY_COUNT,(ORIGIN_DELAY_COUNTDOWN).w

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
        beq     CHECK_DELAY_COUNTER              ; delay the voice only if next voice is empty

COMPARE_VOICE_LEVEL
        swap    D0
        cmp.b   $10(A5),D0                       ; playing voice lvl in A5 is higher than current voice in D0
        bcs.w   SKIP_VOICE_AND_CLEAN
        jmp     ORIGIN_VOICE_OVERWRITE
SKIP_VOICE_AND_CLEAN
        jmp     ORIGIN_CLEAN_RETURN

CHECK_DELAY_COUNTER
        cmpi.b  #$01,(ORIGIN_DELAY_COUNTDOWN).w  ; delay countdown decrease by 1 until <=1
        ble     COMPARE_VOICE_LEVEL              ; no further delay
        jmp     ORIGIN_RETURN                    ; origin sub routine return without clean D0
