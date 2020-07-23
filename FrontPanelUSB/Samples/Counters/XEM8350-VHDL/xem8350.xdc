############################################################################
# XEM8350 - Xilinx constraints file
#
# Pin mappings for the XEM8350.  Use this as a template and comment out
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2019 Opal Kelly Incorporated
############################################################################

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## FrontPanel Host Interface - Primary
############################################################################
set_property PACKAGE_PIN AM12 [get_ports {okHU[0]}]
set_property PACKAGE_PIN AL13 [get_ports {okHU[1]}]
set_property PACKAGE_PIN AE12 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN AN13 [get_ports {okUH[0]}]
set_property PACKAGE_PIN AD14 [get_ports {okUH[1]}]
set_property PACKAGE_PIN AD13 [get_ports {okUH[2]}]
set_property PACKAGE_PIN AT15 [get_ports {okUH[3]}]
set_property PACKAGE_PIN AN14 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN AJ13 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN AH13 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN AK12 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN AK13 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN AH12 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN AG12 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN AG15 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN AF15 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN AF13 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN AE13 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN AG14 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN AF14 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN AF12 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN AR15 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN AL12 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN AV12 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN AM14 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN AP15 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN AM15 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN AT14 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN AW14 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN AW15 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN AV16 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN AU15 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN AT12 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN AW16 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN AU14 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN AW13 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN AT13 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN AU12 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN AP13 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN AR12 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN AE15 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS18 [get_ports {okAA}]


create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUH[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}] 10.000 [get_ports {okUH[*]}]
set_multicycle_path -setup -from [get_ports {okUH[*]}] 2

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUHU[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_multicycle_path -setup -from [get_ports {okUHU[*]}] 2

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]


############################################################################
## FrontPanel Host Interface - Secondary
############################################################################
set_property PACKAGE_PIN AP18 [get_ports {okHUs[0]}]
set_property PACKAGE_PIN AL17 [get_ports {okHUs[1]}]
set_property PACKAGE_PIN AG16 [get_ports {okHUs[2]}]
set_property SLEW FAST [get_ports {okHUs[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHUs[*]}]

set_property PACKAGE_PIN AN18 [get_ports {okUHs[0]}]
set_property PACKAGE_PIN AN17 [get_ports {okUHs[1]}]
set_property PACKAGE_PIN AH17 [get_ports {okUHs[2]}]
set_property PACKAGE_PIN AK17 [get_ports {okUHs[3]}]
set_property PACKAGE_PIN AP19 [get_ports {okUHs[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHs[*]}]

set_property PACKAGE_PIN AD16 [get_ports {okUHUs[0]}]
set_property PACKAGE_PIN AE17 [get_ports {okUHUs[1]}]
set_property PACKAGE_PIN AJ16 [get_ports {okUHUs[2]}]
set_property PACKAGE_PIN AF18 [get_ports {okUHUs[3]}]
set_property PACKAGE_PIN AF17 [get_ports {okUHUs[4]}]
set_property PACKAGE_PIN AE16 [get_ports {okUHUs[5]}]
set_property PACKAGE_PIN AE18 [get_ports {okUHUs[6]}]
set_property PACKAGE_PIN AG17 [get_ports {okUHUs[7]}]
set_property PACKAGE_PIN AF19 [get_ports {okUHUs[8]}]
set_property PACKAGE_PIN AH19 [get_ports {okUHUs[9]}]
set_property PACKAGE_PIN AG19 [get_ports {okUHUs[10]}]
set_property PACKAGE_PIN AJ18 [get_ports {okUHUs[11]}]
set_property PACKAGE_PIN AH18 [get_ports {okUHUs[12]}]
set_property PACKAGE_PIN AJ19 [get_ports {okUHUs[13]}]
set_property PACKAGE_PIN AL18 [get_ports {okUHUs[14]}]
set_property PACKAGE_PIN AH16 [get_ports {okUHUs[15]}]
set_property PACKAGE_PIN AT20 [get_ports {okUHUs[16]}]
set_property PACKAGE_PIN AT19 [get_ports {okUHUs[17]}]
set_property PACKAGE_PIN AU20 [get_ports {okUHUs[18]}]
set_property PACKAGE_PIN AU19 [get_ports {okUHUs[19]}]
set_property PACKAGE_PIN AT18 [get_ports {okUHUs[20]}]
set_property PACKAGE_PIN AV19 [get_ports {okUHUs[21]}]
set_property PACKAGE_PIN AW20 [get_ports {okUHUs[22]}]
set_property PACKAGE_PIN AV17 [get_ports {okUHUs[23]}]
set_property PACKAGE_PIN AR16 [get_ports {okUHUs[24]}]
set_property PACKAGE_PIN AW19 [get_ports {okUHUs[25]}]
set_property PACKAGE_PIN AM16 [get_ports {okUHUs[26]}]
set_property PACKAGE_PIN AT17 [get_ports {okUHUs[27]}]
set_property PACKAGE_PIN AN16 [get_ports {okUHUs[28]}]
set_property PACKAGE_PIN AU17 [get_ports {okUHUs[29]}]
set_property PACKAGE_PIN AP16 [get_ports {okUHUs[30]}]
set_property PACKAGE_PIN AW18 [get_ports {okUHUs[31]}]
set_property SLEW FAST [get_ports {okUHUs[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHUs[*]}]


create_clock -name okUH0s -period 9.920 [get_ports {okUHs[0]}]

set_input_delay -add_delay -max -clock [get_clocks {okUH0s}]  8.000 [get_ports {okUHs[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0s}] 10.000 [get_ports {okUHs[*]}]
set_multicycle_path -setup -from [get_ports {okUHs[*]}] 2

set_input_delay -add_delay -max -clock [get_clocks {okUH0s}]  8.000 [get_ports {okUHUs[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0s}]  2.000 [get_ports {okUHUs[*]}]
set_multicycle_path -setup -from [get_ports {okUHUs[*]}] 2

set_output_delay -add_delay -max -clock [get_clocks {okUH0s}]  2.000 [get_ports {okHUs[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0s}]  -0.500 [get_ports {okHUs[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0s}]  2.000 [get_ports {okUHUs[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0s}]  -0.500 [get_ports {okUHUs[*]}]


set_property PACKAGE_PIN AV18 [get_ports {ok_done}]
set_property IOSTANDARD LVCMOS18 [get_ports {ok_done}]

############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS [get_ports {sys_clkp}]
set_property PACKAGE_PIN AM22 [get_ports {sys_clkp}]

set_property IOSTANDARD LVDS [get_ports {sys_clkn}]
set_property PACKAGE_PIN AN22 [get_ports {sys_clkn}]

create_clock -name sys_clk -period 5 [get_ports sys_clkp]
set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {mmcm0_clk0}] -group [get_clocks {mmcm1_clk0}]


# LEDs #####################################################################
set_property PACKAGE_PIN AK22 [get_ports {led[0]}]
set_property PACKAGE_PIN AM20 [get_ports {led[1]}]
set_property PACKAGE_PIN AL22 [get_ports {led[2]}]
set_property PACKAGE_PIN AL20 [get_ports {led[3]}]
set_property PACKAGE_PIN AK23 [get_ports {led[4]}]
set_property PACKAGE_PIN AJ20 [get_ports {led[5]}]
set_property PACKAGE_PIN AL23 [get_ports {led[6]}]
set_property PACKAGE_PIN AJ21 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[*]}]

