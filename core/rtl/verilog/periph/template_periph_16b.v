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
// *File Name: template_periph_16b.v
// 
// *Module Description:
//                       16 bit peripheral template.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------
`timescale 1ns / 100ps

module  template_periph_16b (

// OUTPUTs
    per_dout,                       // Peripheral data output

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_wen,                        // Peripheral write enable (high active)
    puc                             // Main system reset
);

// OUTPUTs
//=========
output       [15:0] per_dout;       // Peripheral data output

// INPUTs
//=========
input               mclk;           // Main system clock
input         [7:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_wen;        // Peripheral write enable (high active)
input               puc;            // Main system reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register addresses
parameter           CNTRL1     = 9'h190;
parameter           CNTRL2     = 9'h192;
parameter           CNTRL3     = 9'h194;
parameter           CNTRL4     = 9'h196;


// Register one-hot decoder
parameter           CNTRL1_D   = (512'h1 << CNTRL1);
parameter           CNTRL2_D   = (512'h1 << CNTRL2);
parameter           CNTRL3_D   = (512'h1 << CNTRL3);
parameter           CNTRL4_D   = (512'h1 << CNTRL4);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [511:0]  reg_dec; 
always @(per_addr)
  case ({per_addr,1'b0})
    CNTRL1 :     reg_dec  =  CNTRL1_D;
    CNTRL2 :     reg_dec  =  CNTRL2_D;
    CNTRL3 :     reg_dec  =  CNTRL3_D;
    CNTRL4 :     reg_dec  =  CNTRL4_D;
    default:     reg_dec  =  {512{1'b0}};
  endcase

// Read/Write probes
wire         reg_write =  |per_wen   & per_en;
wire         reg_read  = ~|per_wen   & per_en;

// Read/Write vectors
wire [511:0] reg_wr    = reg_dec & {512{reg_write}};
wire [511:0] reg_rd    = reg_dec & {512{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// CNTRL1 Register
//-----------------   
reg  [15:0] cntrl1;

wire        cntrl1_wr = reg_wr[CNTRL1];

always @ (posedge mclk or posedge puc)
  if (puc)            cntrl1 <=  16'h0000;
  else if (cntrl1_wr) cntrl1 <=  per_din;

   
// CNTRL2 Register
//-----------------   
reg  [15:0] cntrl2;

wire        cntrl2_wr = reg_wr[CNTRL2];

always @ (posedge mclk or posedge puc)
  if (puc)            cntrl2 <=  16'h0000;
  else if (cntrl2_wr) cntrl2 <=  per_din;

   
// CNTRL3 Register
//-----------------   
reg  [15:0] cntrl3;

wire        cntrl3_wr = reg_wr[CNTRL3];

always @ (posedge mclk or posedge puc)
  if (puc)            cntrl3 <=  16'h0000;
  else if (cntrl3_wr) cntrl3 <=  per_din;

   
// CNTRL4 Register
//-----------------   
reg  [15:0] cntrl4;

wire        cntrl4_wr = reg_wr[CNTRL4];

always @ (posedge mclk or posedge puc)
  if (puc)            cntrl4 <=  16'h0000;
  else if (cntrl4_wr) cntrl4 <=  per_din;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] cntrl1_rd  = cntrl1  & {16{reg_rd[CNTRL1]}};
wire [15:0] cntrl2_rd  = cntrl2  & {16{reg_rd[CNTRL2]}};
wire [15:0] cntrl3_rd  = cntrl3  & {16{reg_rd[CNTRL3]}};
wire [15:0] cntrl4_rd  = cntrl4  & {16{reg_rd[CNTRL4]}};

wire [15:0] per_dout   =  cntrl1_rd  |
                          cntrl2_rd  |
                          cntrl3_rd  |
                          cntrl4_rd;


endmodule // template_periph_16b






