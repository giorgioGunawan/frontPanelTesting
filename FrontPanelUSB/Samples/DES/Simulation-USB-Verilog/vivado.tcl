add_wave_divider "Toplevel"
add_wave /DES_TEST/clk1
add_wave /DES_TEST/hi_in(0)

add_wave_divider "Pipe Data"
add_wave -radix hex /DES_TEST/pipeIn
add_wave -radix hex /DES_TEST/pipeOut
add_wave -radix hex /DES_TEST/pipetmp

add_wave_divider "Wire/Trigger Data"
add_wave -radix hex /DES_TEST/WireIns
add_wave -radix hex /DES_TEST/WireOuts
add_wave -radix hex /DES_TEST/Triggered

run 250 us;
