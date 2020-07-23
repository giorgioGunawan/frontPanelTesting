# This is a Modelsim simulation script.
# To use:
#  + Start Modelsim
#  + At the command-line, CD to the directory where this file is.
#  + Type: "do thisfilename.do"
# $Rev$ $Date$

set PATH ./oksim

# Source files and testfixture
vlib work
vlog +incdir+$PATH des_tf.v

vlog destop.v
vlog crp.v
vlog des.v
vlog key_sel.v
vlog sbox1.v
vlog sbox2.v
vlog sbox3.v
vlog sbox4.v
vlog sbox5.v
vlog sbox6.v
vlog sbox7.v
vlog sbox8.v

vlog +incdir+$PATH $PATH/glbl.v
vlog +incdir+$PATH $PATH/okHost.v
vlog +incdir+$PATH $PATH/okPipeIn.v
vlog +incdir+$PATH $PATH/okPipeOut.v
vlog +incdir+$PATH $PATH/okTriggerIn.v
vlog +incdir+$PATH $PATH/okTriggerOut.v
vlog +incdir+$PATH $PATH/okWireIn.v
vlog +incdir+$PATH $PATH/okWireOR.v

vsim -L unisims_ver -t ps DES_TEST work.glbl -novopt +acc

#Setup waveforms
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider Toplevel
add wave -noupdate -format Logic /DES_TEST/clk1
add wave -noupdate -format Logic {/DES_TEST/hi_in[0]}

add wave -noupdate -divider {Pipe Data}
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/pipeIn
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/pipeOut
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/pipetmp

add wave -noupdate -divider {Wire/Trigger Data}
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/WireIns
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/WireOuts
add wave -noupdate -format Literal -radix hexadecimal /DES_TEST/Triggered

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 261
configure wave -valuecolwidth 58
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0

run 250us

WaveRestoreZoom 0us 250us
