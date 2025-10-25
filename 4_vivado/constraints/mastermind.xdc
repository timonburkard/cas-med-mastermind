# Pinout
set_property PACKAGE_PIN K17 [get_ports { clk }];
set_property PACKAGE_PIN Y16 [get_ports { rst }];
set_property PACKAGE_PIN K18 [get_ports { guess_enter }];

# LEDs
set_property PACKAGE_PIN M14 [get_ports { round[0] }];
set_property PACKAGE_PIN M15 [get_ports { round[1] }];
set_property PACKAGE_PIN G14 [get_ports { round[2] }];

# Pmod Header JC
set_property PACKAGE_PIN V15 [get_ports { digit[0] }];
set_property PACKAGE_PIN W15 [get_ports { digit[1] }];
set_property PACKAGE_PIN T11 [get_ports { digit[2] }];
set_property PACKAGE_PIN T10 [get_ports { digit[3] }];
set_property PACKAGE_PIN W14 [get_ports { digit[4] }];
set_property PACKAGE_PIN Y14 [get_ports { digit[5] }];
set_property PACKAGE_PIN T12 [get_ports { digit[6] }];
set_property PACKAGE_PIN U12 [get_ports { digit_sel }];

# IO standard
set_property IOSTANDARD LVCMOS33 [get_ports *];

# Clock frequency
create_clock -name clk -add -period 8.00 [get_ports { clk }];

# I/O Timings
set_false_path -from [get_ports {rst}]
set_false_path -from [get_ports {guess_enter}]
set_false_path -to   [get_ports {*digit[*]}]
set_false_path -to   [get_ports {*round[*]}]
