FMCConfig - FMC Carrier Configuration Utility
=============================================
This is the command-line utility fmcconfig that is used to setup and query
the FMC system controller on the XEM6006 (Shuttle LX1).  With this utility,
you can:

   1. Write a binary image to an attached I2C EEPROM on the FMC module.
   2. Read a binary image from an attached I2C EEPROM on the FMC module.
   3. Configure the FMC carrier's startup parameters.


The FMC (VITA 57) specification contains provisions for FMC modules to have
a formatted I2C EEPROM which may be queried by the FMC carrier to configure
the connector's adjustable voltage (Vadj).  On the XEM6006, this adjustable
voltage is provided by a switching regulator with a selectable voltage.
The system controller sets this voltage in a manner determined by the 
startup parameters and the formatted I2C EEPROM on the carrier module.

According to the FMC specification, the EEPROM should be formatted in 
accordance with the IPMI specification.  It is the customer's responsibility
to format this EEPROM appropriately, but Opal Kelly provides two utilities 
to assist.  The first is the FMC IPMI EEPROM Generator available online 
through our website:

   http://www.opalkelly.com/tools/FMCEepromGenerator.php

This web form takes a number of inputs and generates a formatted I2C EEPROM
image that can be stored on the FMC module's EEPROM.  The second utility
provided by Opal Kelly is fmcconfig which can be used to transfer the 
EEPROM binary to the FMC module.



Using fmcconfig
---------------
To use fmcconfig, place the executable, the FMCConfig bitfile (fmcconfig.bit),
and (optionally) an EEPROM binary in the same folder.  The XEM6006 must be
attached to your PC, recognized by Windows, and not be in use by any other
applications.



Writing an EEPROM
-----------------
fmcconfig -write-eeprom image.bin 8192

This command will write "image.bin" to EEPROM as a 8192-byte (64kbit) EEPROM
image.



Reading an EEPROM
-----------------
fmcconfig -read-eeprom image.bin 8192

This command will read the 8192-byte EEPROM image and store it to the file
image.bin.



Setting Startup Parameters
--------------------------
Available startup parameters are:

  + FMC Geographical Address     (0, 1, 2, 3)
    This determines the value of the pins at GA1:GA0.  Typically, these pins
    are used to set an I2C address for devices on the FMC module.  The
    FMC System Controller will force I2C command addresses to be consistent
    with the current geographical address configured.

  + Vadj Boot Mode     (auto, fallback, manual)
    MANUAL - Vadj is always set according to these startup parameters.  Any 
             IPMI EEPROM present is ignored for Vadj settings.
    AUTO - The IPMI EEPROM is queried for Vadj setting.  If Vadj cannot be
           determined from the EEPROM or if no EEPROM is present, Vadj will
           be disabled.
    FALLBACK - The IPMI EEPROM is queried for Vadj setting.  If Vadj cannot
               be determined from the EEPROM or if no EEPROM is present, 
               Vadj will be set according to these startup parameters.

  + EEPROM Size     (typically 128, 256, ... 8192)
    The size determines how many address bytes are used to communicate with
    the EEPROM.  If the size is 256 or smaller, a single byte is used.  
    Otherwise, two bytes are used.

  + Vadj     (0.8, 1.2, 1.25, 1.5, 1.8, 2.5, 3.3)
    Sets the voltage to use in MANUAL or FALLBACK Vadj Boot Modes.

  + Vadj Enable     (0, 1)
    Deterines if the Vadj regulator is enabled for MANUAL or FALLBACK modes.


Examples:
fmcconfig 0 fallback 8192 3.3 1      [Factory Default]
   GA1:GA0 = 0:0
   Vadj set according to IPMI, if available, otherwise 3.3v.
   EEPROM size is 8192  (24LC64, e.g.)


fmcconfig 2 manual 8192 2.5 1
   GA1:GA0 = 1:0
   Vadj will be set to 2.5.  Any present IPMI EEPROM is ignored.
   EEPROM size is 8192  (24LC64, e.g.)


fmcconfig 0 auto 256 3.3 0
   GA1:GA0 = 0:0
   Vadj set according to IPMI, if available, otherwise disabled.
   EEPROM size is 256  (24LC02, e.g.)


