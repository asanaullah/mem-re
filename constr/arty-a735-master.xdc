## This file is a general .xdc for the Arty A7-35 Rev. D
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports i_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]

## Switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports i_btn]
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports { sel[0] }]; #IO_L13P_T2_MRCC_16 Sch=sw[1]
set_property -dict { PACKAGE_PIN C10 IOSTANDARD LVCMOS33 } [get_ports { sel[1] }]; #IO_L13N_T2_MRCC_16 Sch=sw[2]
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports { sel[2] }]; #IO_L14P_T2_SRCC_16 Sch=sw[3]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tristate_dqs[0].io/O]

## RGB LEDs
#set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L18N_T2_35 Sch=led0_b
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {o_led[4]}]
#set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L19P_T3_35 Sch=led0_r
#set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { led1_b }]; #IO_L20P_T3_35 Sch=led1_b
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {o_led[5]}]
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { led1_r }]; #IO_L20N_T3_35 Sch=led1_r
#set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { led2_b }]; #IO_L21N_T3_DQS_35 Sch=led2_b
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {o_led[6]}]
#set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { led2_r }]; #IO_L22P_T3_35 Sch=led2_r
#set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { led3_b }]; #IO_L23P_T3_35 Sch=led3_b
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {o_led[7]}]
#set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { led3_r }]; #IO_L23N_T3_35 Sch=led3_r

## LEDs
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {o_led[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {o_led[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {o_led[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {o_led[3]}]


##USB-UART Interface

set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { uart_out }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { uart_in }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in


## DDR3 Interface

set_property PACKAGE_PIN R2 [get_ports {a[0]}]
set_property SLEW FAST [get_ports {a[0]}]
set_property IOSTANDARD SSTL135 [get_ports {a[0]}]
# ### ddram:0.a
set_property PACKAGE_PIN M6 [get_ports {a[1]}]
set_property SLEW FAST [get_ports {a[1]}]
set_property IOSTANDARD SSTL135 [get_ports {a[1]}]
# ### ddram:0.a
set_property PACKAGE_PIN N4 [get_ports {a[2]}]
set_property SLEW FAST [get_ports {a[2]}]
set_property IOSTANDARD SSTL135 [get_ports {a[2]}]
# ### ddram:0.a
set_property PACKAGE_PIN T1 [get_ports {a[3]}]
set_property SLEW FAST [get_ports {a[3]}]
set_property IOSTANDARD SSTL135 [get_ports {a[3]}]
# ### ddram:0.a
set_property PACKAGE_PIN N6 [get_ports {a[4]}]
set_property SLEW FAST [get_ports {a[4]}]
set_property IOSTANDARD SSTL135 [get_ports {a[4]}]
# ### ddram:0.a
set_property PACKAGE_PIN R7 [get_ports {a[5]}]
set_property SLEW FAST [get_ports {a[5]}]
set_property IOSTANDARD SSTL135 [get_ports {a[5]}]
# ### ddram:0.a
set_property PACKAGE_PIN V6 [get_ports {a[6]}]
set_property SLEW FAST [get_ports {a[6]}]
set_property IOSTANDARD SSTL135 [get_ports {a[6]}]
# ### ddram:0.a
set_property PACKAGE_PIN U7 [get_ports {a[7]}]
set_property SLEW FAST [get_ports {a[7]}]
set_property IOSTANDARD SSTL135 [get_ports {a[7]}]
# ### ddram:0.a
set_property PACKAGE_PIN R8 [get_ports {a[8]}]
set_property SLEW FAST [get_ports {a[8]}]
set_property IOSTANDARD SSTL135 [get_ports {a[8]}]
# ### ddram:0.a
set_property PACKAGE_PIN V7 [get_ports {a[9]}]
set_property SLEW FAST [get_ports {a[9]}]
set_property IOSTANDARD SSTL135 [get_ports {a[9]}]
# ### ddram:0.a
set_property PACKAGE_PIN R6 [get_ports {a[10]}]
set_property SLEW FAST [get_ports {a[10]}]
set_property IOSTANDARD SSTL135 [get_ports {a[10]}]
# ### ddram:0.a
set_property PACKAGE_PIN U6 [get_ports {a[11]}]
set_property SLEW FAST [get_ports {a[11]}]
set_property IOSTANDARD SSTL135 [get_ports {a[11]}]
# ### ddram:0.a
set_property PACKAGE_PIN T6 [get_ports {a[12]}]
set_property SLEW FAST [get_ports {a[12]}]
set_property IOSTANDARD SSTL135 [get_ports {a[12]}]
# ### ddram:0.a
set_property LOC T8 [get_ports {aa} ]
set_property SLEW FAST [get_ports {aa} ]
set_property IOSTANDARD SSTL135 [get_ports {aa} ]
# ### ddram:0.ba
set_property PACKAGE_PIN R1 [get_ports {ba[0]}]
set_property SLEW FAST [get_ports {ba[0]}]
set_property IOSTANDARD SSTL135 [get_ports {ba[0]}]
# ### ddram:0.ba
set_property PACKAGE_PIN P4 [get_ports {ba[1]}]
set_property SLEW FAST [get_ports {ba[1]}]
set_property IOSTANDARD SSTL135 [get_ports {ba[1]}]
# ### ddram:0.ba
set_property PACKAGE_PIN P2 [get_ports {ba[2]}]
set_property SLEW FAST [get_ports {ba[2]}]
set_property IOSTANDARD SSTL135 [get_ports {ba[2]}]
# ### ddram:0.ras_n
set_property PACKAGE_PIN P3 [get_ports ras_n]
set_property SLEW FAST [get_ports ras_n]
set_property IOSTANDARD SSTL135 [get_ports ras_n]
# ### ddram:0.cas_n
set_property PACKAGE_PIN M4 [get_ports cas_n]
set_property SLEW FAST [get_ports cas_n]
set_property IOSTANDARD SSTL135 [get_ports cas_n]
# ### ddram:0.we_n
set_property PACKAGE_PIN P5 [get_ports we_n]
set_property SLEW FAST [get_ports we_n]
set_property IOSTANDARD SSTL135 [get_ports we_n]
# ### ddram:0.cs_n
set_property PACKAGE_PIN U8 [get_ports cs_n]
set_property SLEW FAST [get_ports cs_n]
set_property IOSTANDARD SSTL135 [get_ports cs_n]
# ### ddram:0.dm
set_property PACKAGE_PIN L1 [get_ports {dm[0]}]
set_property SLEW FAST [get_ports {dm[0]}]
set_property IOSTANDARD SSTL135 [get_ports {dm[0]}]
# ### ddram:0.dm
set_property PACKAGE_PIN U1 [get_ports {dm[1]}]
set_property SLEW FAST [get_ports {dm[1]}]
set_property IOSTANDARD SSTL135 [get_ports {dm[1]}]
# ### ddram:0.dq
set_property PACKAGE_PIN K5 [get_ports {dq[0]}]
set_property SLEW FAST [get_ports {dq[0]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[0]}]
#set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[0]} ]
# ### ddram:0.dq
set_property PACKAGE_PIN L3 [get_ports {dq[1]}]
set_property SLEW FAST [get_ports {dq[1]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[1]}]
# ### ddram:0.dq
set_property PACKAGE_PIN K3 [get_ports {dq[2]}]
set_property SLEW FAST [get_ports {dq[2]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[2]}]
# ### ddram:0.dq
set_property PACKAGE_PIN L6 [get_ports {dq[3]}]
set_property SLEW FAST [get_ports {dq[3]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[3]}]
# ### ddram:0.dq
set_property PACKAGE_PIN M3 [get_ports {dq[4]}]
set_property SLEW FAST [get_ports {dq[4]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[4]}]
# ### ddram:0.dq
set_property PACKAGE_PIN M1 [get_ports {dq[5]}]
set_property SLEW FAST [get_ports {dq[5]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[5]}]
# ### ddram:0.dq
set_property PACKAGE_PIN L4 [get_ports {dq[6]}]
set_property SLEW FAST [get_ports {dq[6]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[6]}]
# ### ddram:0.dq
set_property PACKAGE_PIN M2 [get_ports {dq[7]}]
set_property SLEW FAST [get_ports {dq[7]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[7]}]
# ### ddram:0.dq
set_property PACKAGE_PIN V4 [get_ports {dq[8]}]
set_property SLEW FAST [get_ports {dq[8]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[8]}]
# ### ddram:0.dq
set_property PACKAGE_PIN T5 [get_ports {dq[9]}]
set_property SLEW FAST [get_ports {dq[9]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[9]}]
# ### ddram:0.dq
set_property PACKAGE_PIN U4 [get_ports {dq[10]}]
set_property SLEW FAST [get_ports {dq[10]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[10]}]
# ### ddram:0.dq
set_property PACKAGE_PIN V5 [get_ports {dq[11]}]
set_property SLEW FAST [get_ports {dq[11]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[11]}]
# ### ddram:0.dq
set_property PACKAGE_PIN V1 [get_ports {dq[12]}]
set_property SLEW FAST [get_ports {dq[12]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[12]}]
# ### ddram:0.dq
set_property PACKAGE_PIN T3 [get_ports {dq[13]}]
set_property SLEW FAST [get_ports {dq[13]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[13]}]
# ### ddram:0.dq
set_property PACKAGE_PIN U3 [get_ports {dq[14]}]
set_property SLEW FAST [get_ports {dq[14]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[14]}]
# ### ddram:0.dq
set_property PACKAGE_PIN R3 [get_ports {dq[15]}]
set_property SLEW FAST [get_ports {dq[15]}]
set_property IOSTANDARD SSTL135 [get_ports {dq[15]}]
# ### ddram:0.dqs_p
#set_property SLEW FAST [get_ports {dqs_p[0]} ]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {dqs_p[1]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {dqs_n[1]}]
# ### ddram:0.dqs_n
set_property PACKAGE_PIN N1 [get_ports {dqs_n[0]}]
set_property PACKAGE_PIN N2 [get_ports {dqs_p[0]}]
# ### ddram:0.dqs_n
set_property PACKAGE_PIN V2 [get_ports {dqs_n[1]}]
set_property PACKAGE_PIN U2 [get_ports {dqs_p[1]}]


create_clock -period 2.500 -name dqs_clk_0_pin -waveform {0.937 2.188} -add [get_ports dqs_p[0]]
create_clock -period 2.500 -name dqs_clk_1_pin -waveform {0.937 2.188} -add [get_ports dqs_p[1]]


# ### ddram:0.clk_p
set_property IOSTANDARD DIFF_SSTL135 [get_ports clk_400M_p]
# ### ddram:0.clk_n
set_property PACKAGE_PIN U9 [get_ports clk_400M_p]
set_property PACKAGE_PIN V9 [get_ports clk_400M_n]
set_property IOSTANDARD DIFF_SSTL135 [get_ports clk_400M_n]
# ### ddram:0.cke
set_property PACKAGE_PIN N5 [get_ports cke]
set_property SLEW FAST [get_ports cke]
set_property IOSTANDARD SSTL135 [get_ports cke]
# ### ddram:0.odt
set_property PACKAGE_PIN R5 [get_ports odt]
set_property SLEW FAST [get_ports odt]
set_property IOSTANDARD SSTL135 [get_ports odt]
# ### ddram:0.reset_n
set_property PACKAGE_PIN K6 [get_ports rst_n]
set_property SLEW FAST [get_ports rst_n]
set_property IOSTANDARD SSTL135 [get_ports rst_n]

set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[15]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[14]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[13]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[12]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[11]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[10]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[9]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[8]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[7]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[6]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[5]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[4]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[3]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[2]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[1]}]
set_property IN_TERM UNTUNED_SPLIT_40 [get_ports {dq[0]}]
set_property INTERNAL_VREF 0.675 [get_iobanks 34]
