REM DES Simulation Batch File (Vivado)

call xelab work.tf work.glbl -prj isim.prj -L unisims_ver -L secureip -s sim_vivado -debug typical
xsim -g -t vivado.tcl -wdb des_vivado.wdb sim_vivado

