Opal Kelly DESTester Sample
---------------------------
This sample uses an OpenCores.org DES core to encrypt and decrypt a file sent
to the FPGA over the FrontPanel interface.


C# Build
--------
To build this sample, you will need to copy the following file from the 
API/Csharp directory where you installed FrontPanel to the directory where
the DESTester Visual Studio solution resides:

   libFrontPanel-csharp.dll
   
To run the sample after you've built it, you will need the following files
in the same directory:

   DESTester.exe                (the binary produced)
   libFrontPanel-csharp.dll     (from the FrontPanel/API/Csharp directory)
   libFrontPanel-pinv.dll       (from the FrontPanel/API/Csharp directory)
   destop.bit                   (appropriate bitfile from the FrontPanel/DES directory)


Command Line Interface
----------------------
The command line interface to the sample is simple and provides a way to 
encrypt or decrypt a given file using a user-provided key.  An example 
encryption and subsequent decryption of the encrypted output is:

============================================================================
C:\Work\destest>DESTester.exe e 1234567812345678 in out
------ DES Encrypt/Decrypt Tester in C# ------
Device firmware version: 3.1
Device serial number: 102200AA15
Device ID: Opal Kelly XEM3001
FrontPanel support is available.
Encrypting in ---> out

C:\Work\destest>DESTester.exe d 1234567812345678 out in.out
------ DES Encrypt/Decrypt Tester in C# ------
Device firmware version: 3.1
Device serial number: 102200AA15
Device ID: Opal Kelly XEM3001
FrontPanel support is available.
Decrypting out ---> in.out

C:\Work\destest>
============================================================================

The output file "in.out" will look similar to the input file "in".

