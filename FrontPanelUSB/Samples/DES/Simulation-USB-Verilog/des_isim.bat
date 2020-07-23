REM DES Simulation Batch File
REM $Rev$ $Date$

REM Edit path for settings32/64, depending on architecture
call %XILINX%\..\settings64.bat

fuse -intstyle ise ^
     -incremental ^
     -lib unisims_ver ^
     -lib unimacro_ver ^
     -lib xilinxcorelib_ver ^
     -i ./oksim ^
     -o des_isim.exe ^
     -prj des_isim.prj ^
     work.DES_TEST work.glbl
des_isim.exe -gui -tclbatch des_isim.tcl -wdb des_isim.wdb