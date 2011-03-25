//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: driver_7segment.v
//
// *Module Description:
//                      Driver for the four-digit, seven-segment LED display.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------


module  driver_7segment (

// OUTPUTs
    per_dout,                       // Peripheral data output

	hex0, // outputs to the segments
	hex1,
	hex2,
	hex3,

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc                             // Main system reset
);

// OUTPUTs
//=========
output      [15:0] per_dout;        // Peripheral data output

output [7:0] hex0,hex1,hex2,hex3;


// INPUTs
//=========
input              mclk;            // Main system clock
input        [7:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc;             // Main system reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register addresses
parameter          DIGIT0    = 9'h090;
parameter          DIGIT1    = 9'h091;
parameter          DIGIT2    = 9'h092;
parameter          DIGIT3    = 9'h093;


// Register one-hot decoder
parameter          DIGIT0_D  = (256'h1 << (DIGIT0 /2));
parameter          DIGIT1_D  = (256'h1 << (DIGIT1 /2));
parameter          DIGIT2_D  = (256'h1 << (DIGIT2 /2));
parameter          DIGIT3_D  = (256'h1 << (DIGIT3 /2));


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [255:0]  reg_dec;
always @(per_addr)
  case (per_addr)
    (DIGIT0 /2):   reg_dec   = DIGIT0_D;
    (DIGIT1 /2):   reg_dec   = DIGIT1_D;
    (DIGIT2 /2):   reg_dec   = DIGIT2_D;
    (DIGIT3 /2):   reg_dec   = DIGIT3_D;
    default    :   reg_dec   = {256{1'b0}};
  endcase

// Read/Write probes
wire         reg_lo_write =  per_we[0] & per_en;
wire         reg_hi_write =  per_we[1] & per_en;
wire         reg_read     = ~|per_we   & per_en;

// Read/Write vectors
wire [255:0] reg_hi_wr    = reg_dec & {256{reg_hi_write}};
wire [255:0] reg_lo_wr    = reg_dec & {256{reg_lo_write}};
wire [255:0] reg_rd       = reg_dec & {256{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// DIGIT0 Register
//-----------------
reg  [7:0] digit0;

wire       digit0_wr  = DIGIT0[0] ? reg_hi_wr[DIGIT0/2] : reg_lo_wr[DIGIT0/2];
wire [7:0] digit0_nxt = DIGIT0[0] ? per_din[15:8]       : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            digit0 <=  8'h00;
  else if (digit0_wr) digit0 <=  digit0_nxt;


// DIGIT1 Register
//-----------------
reg  [7:0] digit1;

wire       digit1_wr  = DIGIT1[0] ? reg_hi_wr[DIGIT1/2] : reg_lo_wr[DIGIT1/2];
wire [7:0] digit1_nxt = DIGIT1[0] ? per_din[15:8]       : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            digit1 <=  8'h00;
  else if (digit1_wr) digit1 <=  digit1_nxt;


// DIGIT2 Register
//-----------------
reg  [7:0] digit2;

wire       digit2_wr  = DIGIT2[0] ? reg_hi_wr[DIGIT2/2] : reg_lo_wr[DIGIT2/2];
wire [7:0] digit2_nxt = DIGIT2[0] ? per_din[15:8]       : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            digit2 <=  8'h00;
  else if (digit2_wr) digit2 <=  digit2_nxt;


// DIGIT3 Register
//-----------------
reg  [7:0] digit3;

wire       digit3_wr  = DIGIT3[0] ? reg_hi_wr[DIGIT3/2] : reg_lo_wr[DIGIT3/2];
wire [7:0] digit3_nxt = DIGIT3[0] ? per_din[15:8]       : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            digit3 <=  8'h00;
  else if (digit3_wr) digit3 <=  digit3_nxt;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] digit0_rd   = (digit0  & {8{reg_rd[DIGIT0/2]}})  << (8 & {4{DIGIT0[0]}});
wire [15:0] digit1_rd   = (digit1  & {8{reg_rd[DIGIT1/2]}})  << (8 & {4{DIGIT1[0]}});
wire [15:0] digit2_rd   = (digit2  & {8{reg_rd[DIGIT2/2]}})  << (8 & {4{DIGIT2[0]}});
wire [15:0] digit3_rd   = (digit3  & {8{reg_rd[DIGIT3/2]}})  << (8 & {4{DIGIT3[0]}});

wire [15:0] per_dout  =  digit0_rd  |
                         digit1_rd  |
                         digit2_rd  |
                         digit3_rd;


//============================================================================
// 5) FOUR-DIGIT, SEVEN-SEGMENT LED DISPLAY DRIVER
//============================================================================


// Segment selection
//----------------------------

//////
//////
////// changed by Vadim Akimov, lvd.mhm@gmail.com
////// because altera DE1 has non-multiplexed 7seg display


bit_reverse revhex0 ( .in(~digit0), .out(hex0) );
bit_reverse revhex1 ( .in(~digit1), .out(hex1) );
bit_reverse revhex2 ( .in(~digit2), .out(hex2) );
bit_reverse revhex3 ( .in(~digit3), .out(hex3) );


endmodule // driver_7segment



module bit_reverse(
	input [7:0] in,
	output [7:0] out
);

	assign out[7:0] = { in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7] };

endmodule

