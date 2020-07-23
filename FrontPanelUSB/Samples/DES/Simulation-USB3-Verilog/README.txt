DES Simulation README
$Rev$ $Date$

Setup for simulation:
1. Copy simulation files from the Frontpanel installation directory ($FRONTPANEL) to a working directory ($WORKDIRECTORY).
2. Copy verilog simulation sources from $FRONTPANEL/Simulation/Verilog to $WORKDIRECTORY/oksim

Running the Simulation:
  iSim
  1. Open 'ISE Design Suite Command Prompt' or 'Command Prompt'
  2. CD to $WORKDIRECTORY
  3. Type: "isim.bat" to execute the simulation script.

  Vivado
  1. Open a Windows command prompt
  2. CD to $WORKDIRECTORY
  3. Run: $XILINX/Vivado/$VIVADO_VERSION/settings64.bat, adjust for your Vivado version and CPU architecture
  4. Run "vivado.bat" to execute the simulation script.

Notes:
 isim.bat:
  This is the iSim batch file for compiling the source listed in des_isim.prj and running the simulation. 
  Make sure to edit line containing the correct path and architecture for the Xilinx run time environment variables 
  if running from Windows 'Command Prompt'. Default path uses %Xilinx% environment variable, if set.
  (e.g. C:\Xilinx\12.2\ISE_DS\settings64) 

 isim.prj:
  iSim project file. Lists source files for iSim simulation. 
  
 isim.tcl:
  iSim command script for issuing commands to the simulatior. For example waveform setup.

 vivado.bat:
  This is the batch file used to compile the sources listed in isim.prj and then run the simulation.

 vivado.tcl:
  Vivado TCL script to set up the waveform display
