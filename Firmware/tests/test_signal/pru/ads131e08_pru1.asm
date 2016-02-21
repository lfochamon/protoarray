; Pin definitions
SPI_SCLK            .set    5       ; PRU1_5 GPIO2_11 P8_42
SPI_MOSI            .set    0       ; PRU1_0 GPIO2_6  P8_45 (DIN)
SPI_MISO            .set    3       ; PRU1_3 GPIO2_9  P8_44 (DOUT)
SPI_CS              .set    7       ; PRU1_7 GPIO2_13 P8_40
ADS_START           .set    4       ; PRU1_4 GPIO2_10 P8_41
ADS_RESET           .set    2       ; PRU1_2 GPIO2_8  P8_43
ADS_DRDY            .set    1       ; PRU1_1 GPIO2_7  P8_46

; SPI_SCLK_DELAY = floor( (t_SCLK / 5 ns) / 4 ); SPI_SCLK_DELAY >= 3
SPI_SCLK_DELAY      .set    9

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

; Include ADS131 driver
    .include "ads131e08.inc"

main:
; Start up sequence for the ADS
    ADS_STARTUP

; Configure ADS
; Activate internal clock
    ADS_WRITE_REG   CONFIG3, CONFIG3_MASK + PDB_REFBUF
; Wait 20 us for the internal reference to start
    ADS_WAIT        2000
; 16 bits @ 32 kHz, daisy-chain, disable clock output
    ADS_WRITE_REG   CONFIG1, CONFIG1_MASK + DR_32K
; Internal test signal, gain 1x, fclk / 2^21
    ADS_WRITE_REG   CONFIG2, CONFIG2_MASK + INT_TEST + TEST_FREQ_21

; Channel 1-3, PGA gain 1x, test signal (square wave, 2.048 MHz/2^21 = 0.98 Hz)
    ADS_WRITE_REG   CH1SET, CH_GAIN_1 + CH_TEST
    ADS_WRITE_REG   CH2SET, CH_GAIN_4 + CH_TEST
    ADS_WRITE_REG   CH3SET, CH_GAIN_8 + CH_TEST
; Channel 4, PGA gain 1x, power supply (DVDD/4 = 0.825 V)
    ADS_WRITE_REG   CH4SET, CH_GAIN_1 + CH_VDD
; Channel 5, PGA gain 1x, power supply (AVDD/2 = 2.5 V)
    ADS_WRITE_REG   CH5SET, CH_GAIN_1 + CH_VDD
; Channel 6, PGA gain 1x, temperature sensor [(uV - 145300)/490 + 25 degC]
    ADS_WRITE_REG   CH6SET, CH_GAIN_1 + CH_TEMP
; Channel 7-8, PGA gain 1x, test signal (square wave, 2.048 MHz/2^21 = 0.98 Hz)
    ADS_WRITE_REG   CH7SET, CH_GAIN_12 + CH_TEST
    ADS_WRITE_REG   CH8SET, CH_GAIN_1 + CH_TEST

; Calibrate offset
    ADS_SEND_CMD    ADS_CMD_OFFSETCAL

; Put ADS back in continuous data conversion mode
    ADS_SEND_CMD    ADS_CMD_RDATAC

; START = 1
    SET     r30, r30, ADS_START

; Start of main loop
mainloop:
    ; Wait and retrieve data
    ADS_GET_DATA16  r1, r2, r3, r4, r5
    ADS_GET_DATA16  r1, r6, r7, r8, r9
    ADS_GET_DATA16  r1, r10, r11, r12, r13
    ADS_GET_DATA16  r1, r14, r15, r16, r17
    ADS_GET_DATA16  r1, r18, r19, r20, r21
    ADS_GET_DATA16  r1, r22, r23, r24, r25

    XOUT    XFR_BANK0, &r1, 100                         ; Save to scratch pad
    LDI     r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Signal PRU0

    JMP mainloop        ; [TODO]: make loop conditional

; Stop PRU
    HALT

; Setup function calls for ADS driver
    ADS_INIT
