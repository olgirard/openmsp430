
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
// *File Name: omsp_multiplier.v
// 
// *Module Description:
//                       16x16 Hardware multiplier.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------
`include "timescale.v"
`include "openMSP430_defines.v"

module  omsp_multiplier (

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
// 1)  PARAMETER/REGISTERS & WIRE DECLARATION
//=============================================================================

// Register addresses
parameter           OP1_MPY    = 9'h130;
parameter           OP1_MPYS   = 9'h132;
parameter           OP1_MAC    = 9'h134;
parameter           OP1_MACS   = 9'h136;
parameter           OP2        = 9'h138;
parameter           RESLO      = 9'h13A;
parameter           RESHI      = 9'h13C;
parameter           SUMEXT     = 9'h13E;


// Register one-hot decoder
parameter           OP1_MPY_D  = (512'h1 << OP1_MPY);
parameter           OP1_MPYS_D = (512'h1 << OP1_MPYS);
parameter           OP1_MAC_D  = (512'h1 << OP1_MAC);
parameter           OP1_MACS_D = (512'h1 << OP1_MACS);
parameter           OP2_D      = (512'h1 << OP2);
parameter           RESLO_D    = (512'h1 << RESLO);
parameter           RESHI_D    = (512'h1 << RESHI);
parameter           SUMEXT_D   = (512'h1 << SUMEXT);


// Wire pre-declarations
wire  result_wr;
wire  result_clr;
wire  early_read;


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [511:0]  reg_dec; 
always @(per_addr)
  case ({per_addr,1'b0})
    OP1_MPY  :  reg_dec  =  OP1_MPY_D;
    OP1_MPYS :  reg_dec  =  OP1_MPYS_D;
    OP1_MAC  :  reg_dec  =  OP1_MAC_D;
    OP1_MACS :  reg_dec  =  OP1_MACS_D;
    OP2      :  reg_dec  =  OP2_D;
    RESLO    :  reg_dec  =  RESLO_D;
    RESHI    :  reg_dec  =  RESHI_D;
    SUMEXT   :  reg_dec  =  SUMEXT_D;
    default  :  reg_dec  =  {512{1'b0}};
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

// OP1 Register
//-----------------   
reg  [15:0] op1;

wire        op1_wr = reg_wr[OP1_MPY]  |
                     reg_wr[OP1_MPYS] |
                     reg_wr[OP1_MAC]  |
                     reg_wr[OP1_MACS];

always @ (posedge mclk or posedge puc)
  if (puc)          op1 <=  16'h0000;
  else if (op1_wr)  op1 <=  per_din;
   
wire [15:0] op1_rd  = op1;

   
// OP2 Register
//-----------------   
reg  [15:0] op2;

wire        op2_wr = reg_wr[OP2];

always @ (posedge mclk or posedge puc)
  if (puc)          op2 <=  16'h0000;
  else if (op2_wr)  op2 <=  per_din;

wire [15:0] op2_rd  = op2;

   
// RESLO Register
//-----------------   
reg  [15:0] reslo;

wire [15:0] reslo_nxt;
wire        reslo_wr = reg_wr[RESLO];

always @ (posedge mclk or posedge puc)
  if (puc)             reslo <=  16'h0000;
  else if (reslo_wr)   reslo <=  per_din;
  else if (result_clr) reslo <=  16'h0000;
  else if (result_wr)  reslo <=  reslo_nxt;

wire [15:0] reslo_rd = early_read ? reslo_nxt : reslo;


// RESHI Register
//-----------------   
reg  [15:0] reshi;

wire [15:0] reshi_nxt;
wire        reshi_wr = reg_wr[RESHI];

always @ (posedge mclk or posedge puc)
  if (puc)             reshi <=  16'h0000;
  else if (reshi_wr)   reshi <=  per_din;
  else if (result_clr) reshi <=  16'h0000;
  else if (result_wr)  reshi <=  reshi_nxt;

wire [15:0] reshi_rd = early_read ? reshi_nxt  : reshi;

 
// SUMEXT Register
//-----------------   
reg  [1:0] sumext_s;

wire [1:0] sumext_s_nxt;

always @ (posedge mclk or posedge puc)
  if (puc)             sumext_s <=  2'b00;
  else if (op2_wr)     sumext_s <=  2'b00;
  else if (result_wr)  sumext_s <=  sumext_s_nxt;

wire [15:0] sumext_nxt = {{14{sumext_s_nxt[1]}}, sumext_s_nxt};
wire [15:0] sumext     = {{14{sumext_s[1]}},     sumext_s};
wire [15:0] sumext_rd  = early_read ? sumext_nxt : sumext;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] op1_mux    = op1_rd     & {16{reg_rd[OP1_MPY]  |
                                          reg_rd[OP1_MPYS] |
                                          reg_rd[OP1_MAC]  |
                                          reg_rd[OP1_MACS]}};
wire [15:0] op2_mux    = op2_rd     & {16{reg_rd[OP2]}};
wire [15:0] reslo_mux  = reslo_rd   & {16{reg_rd[RESLO]}};
wire [15:0] reshi_mux  = reshi_rd   & {16{reg_rd[RESHI]}};
wire [15:0] sumext_mux = sumext_rd  & {16{reg_rd[SUMEXT]}};

wire [15:0] per_dout   = op1_mux    |
                         op2_mux    |
                         reslo_mux  |
                         reshi_mux  |
                         sumext_mux;


//============================================================================
// 5) HARDWARE MULTIPLIER FUNCTIONAL LOGIC
//============================================================================

// Multiplier configuration
//--------------------------

// Detect signed mode
reg sign_sel;
always @ (posedge mclk or posedge puc)
  if (puc)         sign_sel <=  1'b0;
  else if (op1_wr) sign_sel <=  reg_wr[OP1_MPYS] | reg_wr[OP1_MACS];


// Detect accumulate mode
reg acc_sel;
always @ (posedge mclk or posedge puc)
  if (puc)         acc_sel  <=  1'b0;
  else if (op1_wr) acc_sel  <=  reg_wr[OP1_MAC]  | reg_wr[OP1_MACS];


// Detect whenever the RESHI and RESLO registers should be cleared
assign      result_clr = op2_wr & ~acc_sel;

// Combine RESHI & RESLO 
wire [31:0] result     = {reshi, reslo};

   
// 16x16 Multiplier (result computed in 1 clock cycle)
//-----------------------------------------------------
`ifdef MPY_16x16

// Detect start of a multiplication
reg cycle;
always @ (posedge mclk or posedge puc)
  if (puc) cycle <=  1'b0;
  else     cycle <=  op2_wr;

assign result_wr = cycle;

// Expand the operands to support signed & unsigned operations
wire signed [16:0] op1_xp = {sign_sel & op1[15], op1};
wire signed [16:0] op2_xp = {sign_sel & op2[15], op2};


// 17x17 signed multiplication
wire signed [33:0] product = op1_xp * op2_xp;

// Accumulate
wire [32:0] result_nxt = {1'b0, result} + {1'b0, product[31:0]};


// Next register values
assign reslo_nxt    = result_nxt[15:0];
assign reshi_nxt    = result_nxt[31:16];
assign sumext_s_nxt =  sign_sel ? {2{result_nxt[31]}} :
                                  {1'b0, result_nxt[32]};


// Since the MAC is completed within 1 clock cycle,
// an early read can't happen.
assign early_read   = 1'b0;


// 16x8 Multiplier (result computed in 2 clock cycles)
//-----------------------------------------------------
`else
  
// Detect start of a multiplication
reg [1:0] cycle;
always @ (posedge mclk or posedge puc)
  if (puc) cycle <=  2'b00;
  else     cycle <=  {cycle[0], op2_wr};

assign result_wr = |cycle;


// Expand the operands to support signed & unsigned operations
wire signed [16:0] op1_xp    = {sign_sel & op1[15], op1};
wire signed  [8:0] op2_hi_xp = {sign_sel & op2[15], op2[15:8]};
wire signed  [8:0] op2_lo_xp = {              1'b0, op2[7:0]};
wire signed  [8:0] op2_xp    = cycle[0] ? op2_hi_xp : op2_lo_xp;

     
// 17x9 signed multiplication
wire signed [25:0] product    = op1_xp * op2_xp;

wire        [31:0] product_xp = cycle[0] ? {product[23:0], 8'h00} :
                                           {{8{sign_sel & product[23]}}, product[23:0]};
   
// Accumulate
wire [32:0] result_nxt  = {1'b0, result} + {1'b0, product_xp[31:0]};


// Next register values
assign reslo_nxt    = result_nxt[15:0];
assign reshi_nxt    = result_nxt[31:16];
assign sumext_s_nxt =  sign_sel ? {2{result_nxt[31]}} :
                                  {1'b0, result_nxt[32] | sumext_s[0]};

// Since the MAC is completed within 2 clock cycle,
// an early read can happen during the second cycle.
assign early_read   = cycle[1];

`endif


endmodule // omsp_multiplier

`include "openMSP430_undefines.v"
