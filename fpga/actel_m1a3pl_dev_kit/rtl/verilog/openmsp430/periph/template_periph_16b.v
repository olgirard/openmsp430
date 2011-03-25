//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
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
// $Rev: 106 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-25 23:01:03 +0100 (Fri, 25 Mar 2011) $
//----------------------------------------------------------------------------

module  template_periph_16b (

// OUTPUTs
    per_dout,                       // Peripheral data output

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
output       [15:0] per_dout;       // Peripheral data output

// INPUTs
//=========
input               mclk;           // Main system clock
input         [7:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
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
wire         reg_write =  |per_we & per_en;
wire         reg_read  = ~|per_we & per_en;

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
