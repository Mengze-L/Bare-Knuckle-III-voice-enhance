
ORIGIN_PUNCH_VOICE_LEVEL              set $00026209
ORIGIN_SCREAM_VOICE_LEVEL             set $000258D1
ORIGIN_VOICE_CONFLICTION              set $001A88A4
ORIGIN_VOICE_OVERWRITE                set $001A88AE
ORIGIN_CLEAN_RETURN                   set $001A88E2
ORIGIN_RETURN_TO_DECREASE_COUNTER     set $001A88E4
ORIGIN_DELAY_COUNTDOWN                set $00FFF52A
ORIGIN_RESET_DELAY_COUNTER            set $000041FC
ORIGIN_REMOVE_CURRENT_VOICE           set $00002140

; Constants: -----------------------------------------------------------
CURRENT_VOICE_CMD:                    equ $00FFF790
NEXT_VOICE_CMD:                       equ $00FFF794
MAX_DELAY_COUNT:                      equ $9
PUNCH_21_DELAY_END_COUNT:             equ $2

; Overrides: -----------------------------------------------------------
        org     ORIGIN_RESET_DELAY_COUNTER
        move.b  #MAX_DELAY_COUNT,(ORIGIN_DELAY_COUNTDOWN).w

        org     ORIGIN_SCREAM_VOICE_LEVEL          ; F002
        dc.b    $D0

;        org     ORIGIN_PUNCH_VOICE_LEVEL
;        dc.b    $F0

        ; Call flow: 41E0 -> sub_1A8004 -> loc_1A826E, D0 has voice to play
        ;                               -> loc_1A82C4 -> loc_1A886E. Finally rts from sub_1A8004 to 41E6
        org     ORIGIN_VOICE_CONFLICTION
        jmp     CHECK_IF_SCREAM

; Enhance: ---------------------------------------------------------------
        org     $2EE600
CHECK_IF_SCREAM
        cmpi.b  #$33,D0
        beq     CHECK_PUNCH_21_COUNTER
        cmpi.b  #$12,D0
        beq     CHECK_PUNCH_21_COUNTER
        cmpi.b  #$34,D0
        beq     CHECK_PUNCH_21_COUNTER
        cmpi.b  #$4,D0
        beq     CHECK_PUNCH_21_COUNTER
COMPARE_VOICE_LEVEL
        swap    D0
        cmp.b   $10(A5),D0                         ; Play voice in D0 if its level is higher than or equal to A5. Otherwise, skip D0 voice.
        bcs.w   SKIP_VOICE_AND_CLEAN
        jmp     ORIGIN_VOICE_OVERWRITE
SKIP_VOICE_AND_CLEAN
        jmp     ORIGIN_CLEAN_RETURN

CHECK_PUNCH_21_COUNTER
        cmpi.b  #$21,$79(A6)
        bne     CHECK_DELAY_COUNTER
        cmpi.b  #PUNCH_21_DELAY_END_COUNT,(ORIGIN_DELAY_COUNTDOWN).w
        bgt     CONTINUE_DELAYING
        move.b  #1,(ORIGIN_DELAY_COUNTDOWN).w      ; Make the punch 21 "delay counter" 1 frame faster than other punch.
        jmp     DELAY_COUNTER_ENDED

CHECK_DELAY_COUNTER
        cmpi.b  #1,(ORIGIN_DELAY_COUNTDOWN).w      ; Check the "delay counter" decreased until <=1.
        ble     DELAY_COUNTER_ENDED                ; No more delay. Go to check voice level and play it if level is higher.
CONTINUE_DELAYING
        tst.l   (NEXT_VOICE_CMD)
        beq     RETURN_DECREASE_COUNTER            ; Delay the scream voice only if next voice is empty. Otherwise, remove the scream.
        lea     (CURRENT_VOICE_CMD).w,A2
        lea     (NEXT_VOICE_CMD).w,A1
        jsr     (ORIGIN_REMOVE_CURRENT_VOICE).l
        clr.l   -4(A2)
RETURN_DECREASE_COUNTER
        jmp     ORIGIN_RETURN_TO_DECREASE_COUNTER  ; Origin sub routine return to without clean D0. So the test at 41E6 will go to 4204 to decrease counter by 1.

DELAY_COUNTER_ENDED
        tst.l   (NEXT_VOICE_CMD)
        beq     COMPARE_VOICE_LEVEL
        jmp     ORIGIN_RETURN_TO_DECREASE_COUNTER  ; Leverage the existed code to decrease the counter to 0 and clean the current voice cmd.
