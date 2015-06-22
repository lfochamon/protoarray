.origin 0                        // start of program in PRU memory

#define INS_PER_US 200
#define INS_PER_DELAY_LOOP 2
#define DELAY_US  119 * 1000 * (INS_PER_US / INS_PER_DELAY_LOOP)

/* Interrupt */
#define PRU_INT_VALID 32
#define PRU0_PRU1_INTERRUPT 1   // PRU_EVTOUT_
#define PRU1_PRU0_INTERRUPT 2   // PRU_EVTOUT_
#define PRU0_ARM_INTERRUPT 3    // PRU_EVTOUT_0
#define PRU1_ARM_INTERRUPT 4    // PRU_EVTOUT_1
#define ARM_PRU0_INTERRUPT 5    // PRU_EVTOUT_
#define ARM_PRU1_INTERRUPT 6    // PRU_EVTOUT_

/* Name PRU register banks */
#define XFR_BANK0 10
#define XFR_BANK1 11
#define XFR_BANK2 12
#define XFR_PRU 14

/* Start of main loop */
MAINLOOP:
    /* Wait and retrieve data */
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
    MOV r25, 25


    // Wait 119 ms
    MOV     r2, DELAY_US
    DELAY:
        SUB     r2, r2, 1
        QBNE    DELAY, r2, 0


    XOUT    XFR_BANK0, R1, 100                          // Send data to scratch pad
    MOV     R31.b0, PRU_INT_VALID | PRU1_PRU0_INTERRUPT // Send interrupt to PRU0

    QBA MAINLOOP        // [TODO]: make loop conditional


/* Send interrupt to host*/
MOV     R31.b0, PRU_INT_VALID | PRU1_ARM_INTERRUPT

/* Stop PRU */
HALT
