; Delay
    INS_PER_US          .set    200
    INS_PER_DELAY_LOOP  .set    2
    DELAY_US            .set    125 * (INS_PER_US / INS_PER_DELAY_LOOP)

; Interrupt
    PRU_INT_VALID       .set    32
    PRU0_PRU1_INTERRUPT .set    1       ; PRU_EVTOUT_
    PRU1_PRU0_INTERRUPT .set    2       ; PRU_EVTOUT_
    PRU0_ARM_INTERRUPT  .set    3       ; PRU_EVTOUT_0
    PRU1_ARM_INTERRUPT  .set    4       ; PRU_EVTOUT_1
    ARM_PRU0_INTERRUPT  .set    5       ; PRU_EVTOUT_
    ARM_PRU1_INTERRUPT  .set    6       ; PRU_EVTOUT_

; Name PRU register banks
    XFR_BANK0           .set    10
    XFR_BANK1           .set    11
    XFR_BANK2           .set    12
    XFR_PRU             .set    14

; Setup fake data
    MOV r1,  1
    MOV r2,  2
    MOV r3,  3
    MOV r4,  4
    MOV r5,  5
    MOV r6,  6
    MOV r7,  7
    MOV r8,  8
    MOV r9,  9
    MOV r10, 10
    MOV r11, 11
    MOV r12, 12
    MOV r13, 13
    MOV r14, 14
    MOV r15, 15
    MOV r16, 16
    MOV r17, 17
    MOV r18, 18
    MOV r19, 19
    MOV r20, 20
    MOV r21, 21
    MOV r22, 22
    MOV r23, 23
    MOV r24, 24


; Start of main loop
MAINLOOP:
    ; Wait 119 ms
    MOV     r25, DELAY_US
    DELAY:
        SUB     r25, r25, 1
        QBNE    DELAY, r25, 0


    XOUT    XFR_BANK0, r1, 96                           ; Send data to scratch pad
    MOV     R31.b0, PRU_INT_VALID | PRU1_PRU0_INTERRUPT ; Send interrupt to PRU0

    QBA MAINLOOP        ; [TODO]: make loop conditional


; Stop PRU
    HALT
