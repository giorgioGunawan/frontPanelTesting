//------------------------------------------------------------------------
// okPipeOut.v
//
// This module simulates the "Output Pipe" endpoint.
//
//------------------------------------------------------------------------
// Copyright (c) 2005-2010 Opal Kelly Incorporated
// $Rev$ $Date$
//------------------------------------------------------------------------
`default_nettype none
`timescale 1ns / 1ps

module okPipeOut(
	input  wire [112:0] okHE,
	output wire [64:0]  okEH,
	input  wire [7:0]   ep_addr,
	output wire         ep_read,
	input  wire [31:0]  ep_datain
	);

`include "parameters.v" 
`include "mappings.v"

assign okEH[okEH_DATAH:okEH_DATAL] = (ti_addr == ep_addr) ? (ep_datain) : (0);
assign okEH[okEH_READY]            = (ti_addr == ep_addr) ? (1) : (0);
assign ep_read                     = ((ti_read == 1) && (ti_addr == ep_addr)) ? (1) : (0);
assign okEH[okEH_REGREADDATAH:okEH_REGREADDATAL] = 32'b0;

initial begin
	if ((ep_addr < 8'hA0) || (ep_addr > 8'hBF)) begin
		$error("okPipeOut endpoint address outside valid range, must be between 0xA0 and 0xBF");
		$finish;
	end
end

endmodule

