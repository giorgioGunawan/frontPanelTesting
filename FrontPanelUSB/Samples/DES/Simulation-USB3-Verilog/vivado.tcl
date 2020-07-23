add_wave_divider "Toplevel"
add_wave /tf/sys_clkp
add_wave /tf/dut/okClk

add_wave_divider "Pipe Data"
add_wave -radix hex /tf/pipeIn
add_wave -radix hex /tf/pipeOut
add_wave -radix hex /tf/pipetmp

add_wave_divider "Wire/Trigger Data"
add_wave -radix hex /tf/WireIns
add_wave -radix hex /tf/WireOuts
add_wave -radix hex /tf/Triggered

run 250 us;
