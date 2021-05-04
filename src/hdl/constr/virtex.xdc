#set_property PACKAGE_PIN AK62 [get_ports clk]
#create_clock -period 1.000 -name sys_clk_pin -waveform {0.000 0.500} -add [get_ports clk]

#set_property PACKAGE_PIN H45 [get_ports {dataout[0]}]
#set_property PACKAGE_PIN J45 [get_ports {dataout[1]}]
#set_property PACKAGE_PIN G42 [get_ports {dataout[2]}]
#set_property PACKAGE_PIN G41 [get_ports {dataout[3]}]

set_property PACKAGE_PIN AW31 [get_ports clk]
create_clock -period 1.000 -name sys_clk_pin -waveform {0.000 0.500} -add [get_ports clk]

set_property PACKAGE_PIN AK13 [get_ports {dataout[0]}]
set_property PACKAGE_PIN AK14 [get_ports {dataout[1]}]
set_property PACKAGE_PIN AM12 [get_ports {dataout[2]}]
set_property PACKAGE_PIN AM13 [get_ports {dataout[3]}]

#set_switching_activity -toggle_rate 0.000 -type {bram_enable} -static_probability 1.000 -all 
#set_switching_activity -toggle_rate 0.000 -type {bram_wr_enable} -static_probability 1.000 -all 
