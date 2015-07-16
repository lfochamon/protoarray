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
    .include "../../ads_driver/ads131e08.inc"

main:
; Start up sequence for the ADS
    ADS_STARTUP

; Read in all ADS registers
    ADS_READ_ALL    r0.b3, r0.b2, r0.b1, r0.b0, r1.b3, r1.b2, r1.b1, r1.b0, r2.b3, r2.b2, r2.b1, r2.b0, r3.b3, r3.b2, r3.b1, r3.b0

    XOUT            XFR_BANK0, &r0, 4*4                         ; Save to scratch pad
    LDI             r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Signal PRU0

    ADS_WAIT        5*1000*1000                                 ; Wait 50 ms

; Write to registers
    ADS_WRITE_REG   CONFIG1, 0x95
    ADS_WRITE_REG   CONFIG2, 0xE3
    ADS_WRITE_REG   CONFIG3, 0xC0
    ADS_WRITE_REG   CH1SET,  0x13
    ADS_WRITE_REG   CH2SET,  0x23
    ADS_WRITE_REG   CH3SET,  0x13
    ADS_WRITE_REG   CH4SET,  0x23
    ADS_WRITE_REG   CH5SET,  0x13
    ADS_WRITE_REG   CH6SET,  0x23
    ADS_WRITE_REG   CH7SET,  0x13
    ADS_WRITE_REG   CH8SET,  0x23

; Read back all ADS registers
    ADS_READ_ALL r0.b3, r0.b2, r0.b1, r0.b0, r1.b3, r1.b2, r1.b1, r1.b0, r2.b3, r2.b2, r2.b1, r2.b0, r3.b3, r3.b2, r3.b1, r3.b0

    XOUT            XFR_BANK0, &r0, 4*4                         ; Save to scratch pad
    LDI             r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Signal PRU0

; Stop PRU
    HALT
