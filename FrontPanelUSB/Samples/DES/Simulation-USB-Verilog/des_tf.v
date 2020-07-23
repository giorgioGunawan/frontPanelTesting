//------------------------------------------------------------------------
// des_tf.v
//
// A text fixture example that replicates many of the calls that the des
// PC applications make through FrontPanel.  You can simulate the full
// implementation of the design.
//
//------------------------------------------------------------------------
// Copyright (c) 2005-2010 Opal Kelly Incorporated
// $Rev$ $Date$
//------------------------------------------------------------------------
`timescale 1ns / 1ps
`default_nettype none

module DES_TEST;

reg   [7:0]   hi_in;
wire  [1:0]   hi_out;
wire  [15:0]  hi_inout;
wire          hi_aa;

reg           clk1;
wire  [7:0]   led;

destop des_conn (
	.hi_in(hi_in),
	.hi_out(hi_out),
	.hi_inout(hi_inout),
	.hi_aa(hi_aa),
	.clk1(clk1),
	.led(led)
	);
	
initial clk1 = 0;
always #10 clk1 = ~clk1;

//------------------------------------------------------------------------
// Begin okHostInterface simulation user configurable global data
//------------------------------------------------------------------------
parameter BlockDelayStates = 5;   // REQUIRED: # of clocks between blocks of pipe data
parameter ReadyCheckDelay = 5;    // REQUIRED: # of clocks before block transfer before
                                  //  host interface checks for ready (0-255)
parameter PostReadyDelay = 5;     // REQUIRED: # of clocks after ready is asserted and
                                  //  check that the block transfer begins (0-255)
parameter pipeInSize = 16;        // REQUIRED: byte (must be even) length of default
                                  //  PipeIn; Integer 0-2^32
parameter pipeOutSize = 16;       // REQUIRED: byte (must be even) length of default
                                  // PipeOut; Integer 0-2^32

integer k, e;
reg des_done;

// We will be piping in 8 random words for DES encrypting
reg [7:0] pipeIn [0:(pipeInSize-1)];
initial for (k=0; k<pipeInSize; k=k+1) pipeIn[k] = $random;

reg [7:0] pipeOut [0:(pipeOutSize-1)];
initial for (k=0; k<pipeOutSize; k=k+1) pipeOut[k] = 8'h00;

// DES keys; set to whatever the user wishes
reg	[15:0]	key [0:3];
initial begin
	key[0] = 16'hABCD;
	key[1] = 16'h1234;
	key[2] = 16'h3456;
	key[3] = 16'h4567;
end

// After the data is piped in, that random array will be stored here.
// Next, encrypted data will be piped out and copied back into pipeIn.
// Finally, the encrpyted data is piped in (this time to decrypt) and then
// compared to the values in pipetmp
reg	[7:0]	pipetmp [0:(pipeInSize-1)];
initial for (k=0; k<pipeInSize; k=k+1) pipetmp[k] = 8'h00;

//------------------------------------------------------------------------
//  Available User Task and Function Calls:
//    FrontPanelReset;                 // Always start routine with FrontPanelReset;
//    SetWireInValue(ep, val, mask);
//    UpdateWireIns;
//    UpdateWireOuts;
//    GetWireOutValue(ep);
//    ActivateTriggerIn(ep, bit);      // bit is an integer 0-15
//    UpdateTriggerOuts;
//    IsTriggered(ep, mask);           // Returns a 1 or 0
//    WriteToPipeIn(ep, length);       // passes pipeIn array data
//    ReadFromPipeOut(ep, length);     // passes data to pipeOut array
//    WriteToBlockPipeIn(ep, blockSize, length);   // pass pipeIn array data; blockSize and length are integers
//    ReadFromBlockPipeOut(ep, blockSize, length); // pass data to pipeOut array; blockSize and length are integers
//
//    *Pipes operate by passing arrays of data back and forth to the user's
//    design.  If you need multiple arrays, you can create a new procedure
//    above and connect it to a differnet array.  More information is
//    available in Opal Kelly documentation and online support tutorial.
//------------------------------------------------------------------------

// User configurable block of called FrontPanel operations.
initial begin
	des_done = 0;
	FrontPanelReset;              // Start routine with FrontPanelReset;

	// Assert then deassert RESET
	SetWireInValue(8'h10, 16'hffff, 16'h0001);
	UpdateWireIns;
	SetWireInValue(8'h10, 16'h0000, 16'h0001);
	UpdateWireIns;
	$display("Reset at:                             %dns", $time);

	// Set the DES key value (WireIns)
	for (k=0; k<4; k=k+1) SetWireInValue((8'h0b - k), key[k], 16'hffff);
	$display("Set DES key at:                       %dns", $time);
	
	// Set the encrypt bit
	SetWireInValue(8'h10, 16'h0000, 16'h0010);
	UpdateWireIns;
	$display("Encrypt bit set at:                   %dns", $time);
	
	// Reset the RAM address pointer
	ActivateTriggerIn(8'h41, 0);
  $display("Reset the RAM address pointer at:     %dns", $time);
  
	// Write a block of data
	WriteToPipeIn(8'h80, pipeInSize);
	$display("Write data block to encrypt at:       %dns", $time);
	
	// Perform DES encrypting on the block
	ActivateTriggerIn(8'h40, 0);
	$display("Begin DES encrypting at:              %dns", $time);
	
	// Wait for a trigger indicating that the DES is done
	des_done=0;
	
	while (des_done==0) begin
		UpdateTriggerOuts;
		des_done = IsTriggered(8'h60, 16'h0001);
	end
	$display("DES encrypting complete at:           %dns", $time);
	
	// Pull out encrypted data into pipeOut array
	ReadFromPipeOut(8'ha0, pipeOutSize);
	$display("Read encrypted data block at:         %dns", $time);

	// Store the pipeIn data into a tmp array
	for (k=0; k<pipeInSize; k=k+1) pipetmp[k] = pipeIn[k];

	// Transfer the encrypted data (in pipeOut array) into the pipeIn array
	for (k=0; k<pipeInSize; k=k+1) pipeIn[k] = pipeOut[k];

	// Set the decrypt bit setting
	SetWireInValue(8'h10, 16'hffff, 16'h0010);
	UpdateWireIns;
	$display("Decrypt bit set at:                   %dns", $time);

	// Reset the RAM address pointer
	ActivateTriggerIn(8'h41, 0);
	$display("Reset the RAM address pointer at:     %dns", $time);

	// Write the encrypted data back for decrypting (now in pipeIn array)
	WriteToPipeIn(8'h80, pipeInSize);
	$display("Write encrypted data block at:        %dns", $time);
	
	// Perform DES decrypting on the block
	ActivateTriggerIn(8'h40, 0);
	$display("Begin DES decrypting at:              %dns", $time);
	
	// Wait for a trigger indicating that the DES is done
	des_done=0;
	while (des_done==0) begin
		UpdateTriggerOuts;
		des_done = IsTriggered(8'h60, 16'h0001);
	end
	$display("DES decrypting complete at:           %dns", $time);
	
	// Pull decrypted data out
	ReadFromPipeOut(8'ha0, pipeOutSize);
	$display("Read decrypted data block at:         %dns", $time);

	// We stored the original data in pipetmp array.  Test to see if the data
	// was successfully encrypted and then decrypted by comparing pipetmp to pipeOut
	e=0;
	for (k=0; k<pipeInSize; k=k+1) begin
		if (pipeOut[k] != pipetmp[k]) begin
			e=e+1;	// Keep track of the number of errors
			$display(" ");
			$display("Error! %d value not encrypted/decrypted properly!", k);
		end
	end
	
	if (e == 0) begin
		$display(" ");
		$display("Success! All data encoded and decoded properly.");
		$display("Keys[0-3]: 0x%04h, 0x%04h, 0x%04h, and 0x%04h, decoded and encoded the following data:", key[0], key[1], key[2], key[3]);
		for (k=0; k<pipeInSize; k=k+2)
		$display("%d 0x%02h%02h encoded as 0x%02h%02h", k, pipeOut[k+1], pipeOut[k], pipeIn[k+1], pipeIn[k]);
	end

	$display("Simulation done at: %dns", $time);
	
end

`include "./oksim/okHostCalls.v"   // Do not remove!  The tasks, functions, and data stored
                                   // in okHostCalls.v must be included here.

endmodule
