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

; Program start
main:

; Start of main loop
mainloop:
    ; Wait and retrieve data
    LDI r1,  1
    LDI r2,  2
    LDI r3,  3
    LDI r4,  4
    LDI r5,  5
    LDI r6,  6
    LDI r7,  7
    LDI r8,  8
    LDI r9,  9
    LDI r10, 10
    LDI r11, 11
    LDI r12, 12
    LDI r13, 13
    LDI r14, 14
    LDI r15, 15
    LDI r16, 16
    LDI r17, 17
    LDI r18, 18
    LDI r19, 19
    LDI r20, 20
    LDI r21, 21
    LDI r22, 22
    LDI r23, 23
    LDI r24, 24
    LDI r25, 25


    ; Wait 119 us
    LDI32   r0, DELAY_US
delay:
    SUB     r2, r0, 1
    QBNE    delay, r0, 0


    XOUT    XFR_BANK0, &r1, 100                          ; Send data to scratch pad
    LDI     r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Send interrupt to PRU0

    QBA mainloop            ; [TODO]: make loop conditional

    ; Stop PRU
    HALT
