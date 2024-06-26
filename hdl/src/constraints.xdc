# input: Level Shifter --> FPGA
# output FPGA --> Level Shifter

# 12 MHz Clock Signal
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports i_CLK]
create_clock -period 83.330 -name i_CLK_pin -waveform {0.000 41.660} -add [get_ports i_CLK]

# LEDs
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { led_0 }]; #IO_L12N_T1_MRCC_16 Sch=led[1]
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { led_1 }]; #IO_L13P_T2_MRCC_16 Sch=led[2]

# RGB LED
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L14N_T2_SRCC_16 Sch=led0_b
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports led0_g]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports led0_r]

## Buttons
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports i_btn0]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports i_btn1]; #IO_L19P_T3_16 Sch=btn[1]




## Analog XADC Pins
## Only declare these if you want to use pins 15 and 16 as single ended analog inputs. pin 15 -> vaux4, pin16 -> vaux12


## Pmod Header JA
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports o_Z_STEP]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports o_E0_DIR]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports i_E0_DIR]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports i_Z_STEP]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports o_Z_DIR]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports o_X_EN]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports i_X_EN]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports i_Z_DIR]

## GPIO Pins
# Pins 15 and 16 should remain commented if using them as analog inputs
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports o_E0_STEP]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports o_E0_EN]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports i_Z_MAX]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports i_Z_MIN]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports o_Z_EN]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports i_Y_MAX]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports i_Y_MIN]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports o_Y_DIR]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports o_Y_STEP]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports i_UART_RX]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports o_UART_TX]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports i_X_MAX]
#set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports { pio13 }]; #IO_L6N_T0_VREF_35 Sch=pio[13]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports o_THERM_EN]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports o_Y_EN]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports o_X_MIN]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports o_X_DIR]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports o_X_STEP]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports o_D8]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports o_D9]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports o_D10]

set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports i_D10]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports i_D9]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports i_D8]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports i_X_STEP]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports i_X_DIR]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports i_X_MIN]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports i_Y_EN]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports i_THERM0_SCL]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports i_THERM0_SDA]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports i_THERM1_SCL]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports i_THERM1_SDA]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports o_X_MAX]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports i_UART_TX]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports o_UART_RX]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports i_Y_STEP]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports i_Y_DIR]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports o_Y_MIN]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports o_Y_MAX]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports i_Z_EN]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports o_Z_MIN]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports o_Z_MAX]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports i_E0_EN]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports i_E0_STEP]

## UART
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_out }]; #IO_L7N_T1_D10_14 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in  }]; #IO_L7P_T1_D09_14 Sch=uart_txd_in

set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { o_UART_TXD }]; #IO_L7N_T1_D10_14 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in  }]; #IO_L7P_T1_D09_14 Sch=uart_txd_in

## Crypto 1 Wire Interface
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }]; #IO_0_14 Sch=crypto_sda

## QSPI
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs    }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]

## Cellular RAM
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[0]  }]; #IO_L11P_T1_SRCC_14 Sch=sram- a[0]
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[1]  }]; #IO_L11N_T1_SRCC_14 Sch=sram- a[1]
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[2]  }]; #IO_L12N_T1_MRCC_14 Sch=sram- a[2]
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[3]  }]; #IO_L13P_T2_MRCC_14 Sch=sram- a[3]
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[4]  }]; #IO_L13N_T2_MRCC_14 Sch=sram- a[4]
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[5]  }]; #IO_L14P_T2_SRCC_14 Sch=sram- a[5]
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[6]  }]; #IO_L14N_T2_SRCC_14 Sch=sram- a[6]
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[7]  }]; #IO_L16N_T2_A15_D31_14 Sch=sram- a[7]
#set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[8]  }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=sram- a[8]
#set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[9]  }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=sram- a[9]
#set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[10] }]; #IO_L16P_T2_CSI_B_14 Sch=sram- a[10]
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[11] }]; #IO_L17P_T2_A14_D30_14 Sch=sram- a[11]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[12] }]; #IO_L17N_T2_A13_D29_14 Sch=sram- a[12]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[13] }]; #IO_L18P_T2_A12_D28_14 Sch=sram- a[13]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[14] }]; #IO_L18N_T2_A11_D27_14 Sch=sram- a[14]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[15] }]; #IO_L19P_T3_A10_D26_14 Sch=sram- a[15]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[16] }]; #IO_L20P_T3_A08_D24_14 Sch=sram- a[16]
#set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[17] }]; #IO_L20N_T3_A07_D23_14 Sch=sram- a[17]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { MemAdr[18] }]; #IO_L21P_T3_DQS_14 Sch=sram- a[18]
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { MemDB[0]   }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=sram-dq[0]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { MemDB[1]   }]; #IO_L22P_T3_A05_D21_14 Sch=sram-dq[1]
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { MemDB[2]   }]; #IO_L22N_T3_A04_D20_14 Sch=sram-dq[2]
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { MemDB[3]   }]; #IO_L23P_T3_A03_D19_14 Sch=sram-dq[3]
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { MemDB[4]   }]; #IO_L23N_T3_A02_D18_14 Sch=sram-dq[4]
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { MemDB[5]   }]; #IO_L24P_T3_A01_D17_14 Sch=sram-dq[5]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { MemDB[6]   }]; #IO_L24N_T3_A00_D16_14 Sch=sram-dq[6]
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { MemDB[7]   }]; #IO_25_14 Sch=sram-dq[7]
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { RamOEn     }]; #IO_L10P_T1_D14_14 Sch=sram-oe
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { RamWEn     }]; #IO_L10N_T1_D15_14 Sch=sram-we
#set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports { RamCEn     }]; #IO_L9N_T1_DQS_D13_14 Sch=sram-ce

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
