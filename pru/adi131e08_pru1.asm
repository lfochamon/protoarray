; Delay
INS_PER_US          .set    200
INS_PER_DELAY_LOOP  .set    2
DELAY_US            .set    119 * (INS_PER_US / INS_PER_DELAY_LOOP)

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


; Code starts here
    .text
    .retain
    .retainrefs
    .global         main


main:
; Setup fake data
    LDI r1,  0
    LDI r2,  1
    LDI r3,  2
    LDI r4,  3
    LDI r5,  4
    LDI r6,  5
    LDI r7,  6
    LDI r8,  7
    LDI r9,  8
    LDI r10, 9
    LDI r11, 10
    LDI r12, 11
    LDI r13, 12
    LDI r14, 13
    LDI r15, 14
    LDI r16, 15
    LDI r17, 16
    LDI r18, 17
    LDI r19, 18
    LDI r20, 19
    LDI r21, 20
    LDI r22, 21
    LDI r23, 22
    LDI r24, 23


; Start of main loop
mainloop:
    ; Wait 119 us
    LDI32   r25, DELAY_US
delay:
    SUB     r25, r25, 1
    QBNE    delay, r25, 0


    XOUT    XFR_BANK0, &r1, 96                           ; Send data to scratch pad
    LDI     r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Send interrupt to PRU0

    QBA mainloop        ; [TODO]: make loop conditional


; Stop PRU
    HALT
