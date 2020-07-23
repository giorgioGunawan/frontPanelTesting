REM DES Simulation Batch File (Vivado)

call xelab work.DES_TEST work.glbl -prj des_isim.prj -L unisims_ver -L secureip -s sim_vivado -debug typical
xsim -g -t vivado.tcl -wdb des_vivado.wdb sim_vivado

