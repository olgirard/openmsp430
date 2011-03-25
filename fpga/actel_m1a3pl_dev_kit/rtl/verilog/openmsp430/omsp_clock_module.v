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
// *File Name: omsp_clock_module.v
// 
// *Module Description:
//                       Basic clock module implementation.
//                      Since the openMSP430 mainly targets FPGA and hobby
//                     designers. The clock structure has been greatly
//                     symplified in order to ease integration.
//                      See online wiki for more info.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 106 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-25 23:01:03 +0100 (Fri, 25 Mar 2011) $
//----------------------------------------------------------------------------
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module  omsp_clock_module (

// OUTPUTs
    aclk_en,                      // ACLK enable
    cpu_en_s,                     // Enable CPU code execution (synchronous)
    dbg_clk,                      // Debug unit clock
    dbg_en_s,                     // Debug interface enable (synchronous)
    dbg_rst,                      // Debug unit reset
    mclk,                         // Main system clock
    per_dout,                     // Peripheral data output
    por,                          // Power-on reset
    puc,                          // Main system reset
    smclk_en,                     // SMCLK enable
	     
// INPUTs
    cpu_en,                       // Enable CPU code execution (asynchronous)
    dbg_cpu_reset,                // Reset CPU from debug interface
    dbg_en,                       // Debug interface enable (asynchronous)
    dco_clk,                      // Fast oscillator (fast clock)
    lfxt_clk,                     // Low frequency oscillator (typ 32kHz)
    oscoff,                       // Turns off LFXT1 clock input
    per_addr,                     // Peripheral address
    per_din,                      // Peripheral data input
    per_en,                       // Peripheral enable (high active)
    per_we,                       // Peripheral write enable (high active)
    reset_n,                      // Reset Pin (low active, asynchronous)
    scg1,                         // System clock generator 1. Turns off the SMCLK
    wdt_reset                     // Watchdog-timer reset
);

// OUTPUTs
//=========
output              aclk_en;      // ACLK enable
output              cpu_en_s;     // Enable CPU code execution (synchronous)
output              dbg_clk;      // Debug unit clock
output              dbg_en_s;     // Debug unit enable (synchronous)
output              dbg_rst;      // Debug unit reset
output              mclk;         // Main system clock
output       [15:0] per_dout;     // Peripheral data output
output              por;          // Power-on reset
output              puc;          // Main system reset
output              smclk_en;     // SMCLK enable

// INPUTs
//=========
input               cpu_en;       // Enable CPU code execution (asynchronous)
input               dbg_cpu_reset;// Reset CPU from debug interface
input               dbg_en;       // Debug interface enable (asynchronous)
input               dco_clk;      // Fast oscillator (fast clock)
input               lfxt_clk;     // Low frequency oscillator (typ 32kHz)
input               oscoff;       // Turns off LFXT1 clock input
input         [7:0] per_addr;     // Peripheral address
input        [15:0] per_din;      // Peripheral data input
input               per_en;       // Peripheral enable (high active)
input         [1:0] per_we;       // Peripheral write enable (high active)
input               reset_n;      // Reset Pin (low active, asynchronous)
input               scg1;         // System clock generator 1. Turns off the SMCLK
input               wdt_reset;    // Watchdog-timer reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register addresses
parameter           BCSCTL1    = 9'h057;
parameter           BCSCTL2    = 9'h058;

// Register one-hot decoder
parameter           BCSCTL1_D  = (256'h1 << (BCSCTL1 /2));
parameter           BCSCTL2_D  = (256'h1 << (BCSCTL2 /2)); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [255:0]  reg_dec; 
always @(per_addr)
  case (per_addr)
    (BCSCTL1 /2):     reg_dec  =  BCSCTL1_D;
    (BCSCTL2 /2):     reg_dec  =  BCSCTL2_D;
    default     :     reg_dec  =  {256{1'b0}};
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

// BCSCTL1 Register
//--------------
reg  [7:0] bcsctl1;
wire       bcsctl1_wr  = BCSCTL1[0] ? reg_hi_wr[BCSCTL1/2] : reg_lo_wr[BCSCTL1/2];
wire [7:0] bcsctl1_nxt = BCSCTL1[0] ? per_din[15:8]        : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)              bcsctl1  <=  8'h00;
  else if (bcsctl1_wr)  bcsctl1  <=  bcsctl1_nxt & 8'h30; // Mask unused bits


// BCSCTL2 Register
//--------------
reg  [7:0] bcsctl2;
wire       bcsctl2_wr  = BCSCTL2[0] ? reg_hi_wr[BCSCTL2/2] : reg_lo_wr[BCSCTL2/2];
wire [7:0] bcsctl2_nxt = BCSCTL2[0] ? per_din[15:8]        : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)              bcsctl2  <=  8'h00;
  else if (bcsctl2_wr)  bcsctl2  <=  bcsctl2_nxt & 8'h0e; // Mask unused bits


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] bcsctl1_rd   = {8'h00, (bcsctl1  & {8{reg_rd[BCSCTL1/2]}})}  << (8 & {4{BCSCTL1[0]}});
wire [15:0] bcsctl2_rd   = {8'h00, (bcsctl2  & {8{reg_rd[BCSCTL2/2]}})}  << (8 & {4{BCSCTL2[0]}});

wire [15:0] per_dout =  bcsctl1_rd   |
                        bcsctl2_rd;


//=============================================================================
// 5)  CLOCK GENERATION
//=============================================================================

// Synchronize CPU_EN signal
//---------------------------------------
reg  [1:0] cpu_en_sync;
always @ (posedge mclk or posedge por)
  if (por) cpu_en_sync <=  2'b00;
  else     cpu_en_sync <=  {cpu_en_sync[0], cpu_en};    

assign     cpu_en_s     =   cpu_en_sync[1];
   

// Synchronize LFXT_CLK & edge detection
//---------------------------------------
reg  [2:0] lfxt_clk_s;
   
always @ (posedge mclk or posedge por)
  if (por) lfxt_clk_s <=  3'b000;
  else     lfxt_clk_s <=  {lfxt_clk_s[1:0], lfxt_clk};    

wire lfxt_clk_en = (lfxt_clk_s[1] & ~lfxt_clk_s[2]) & ~(oscoff & ~bcsctl2[`SELS]);
     
   
// Generate main system clock
//----------------------------

wire  mclk   =  dco_clk;
wire  mclk_n = !dco_clk;


// Generate ACLK
//----------------------------

reg       aclk_en;
reg [2:0] aclk_div;

wire      aclk_en_nxt = lfxt_clk_en & ((bcsctl1[`DIVAx]==2'b00) ?  1'b1          :
                                       (bcsctl1[`DIVAx]==2'b01) ?  aclk_div[0]   :
                                       (bcsctl1[`DIVAx]==2'b10) ? &aclk_div[1:0] :
                                                                  &aclk_div[2:0]);

always @ (posedge mclk or posedge puc)
  if (puc)  aclk_en <=  1'b0;
  else      aclk_en <=  aclk_en_nxt & cpu_en_s;

always @ (posedge mclk or posedge puc)
  if (puc)                                         aclk_div <=  3'h0;
  else if ((bcsctl1[`DIVAx]!=2'b00) & lfxt_clk_en) aclk_div <=  aclk_div+3'h1;


// Generate SMCLK
//----------------------------

reg       smclk_en;
reg [2:0] smclk_div;

wire      smclk_in     = ~scg1 & (bcsctl2[`SELS] ? lfxt_clk_en : 1'b1);

wire      smclk_en_nxt = smclk_in & ((bcsctl2[`DIVSx]==2'b00) ?  1'b1           :
                                     (bcsctl2[`DIVSx]==2'b01) ?  smclk_div[0]   :
                                     (bcsctl2[`DIVSx]==2'b10) ? &smclk_div[1:0] :
                                                                &smclk_div[2:0]);
   
always @ (posedge mclk or posedge puc)
  if (puc)  smclk_en <=  1'b0;
  else      smclk_en <=  smclk_en_nxt & cpu_en_s;

always @ (posedge mclk or posedge puc)
  if (puc)                                      smclk_div <=  3'h0;
  else if ((bcsctl2[`DIVSx]!=2'b00) & smclk_in) smclk_div <=  smclk_div+3'h1;


// Generate DBG_CLK
//----------------------------

assign  dbg_clk = mclk;


//=============================================================================
// 6)  RESET GENERATION
//=============================================================================

// Generate synchronized POR
wire      por_reset_a  =  !reset_n;

reg [1:0] por_s;
always @(posedge mclk or posedge por_reset_a)
  if (por_reset_a) por_s  <=  2'b11;
  else             por_s  <=  {por_s[0], 1'b0};
wire   por = por_s[1];


// Generate main system reset
wire      puc_reset  = por | wdt_reset | dbg_cpu_reset;

reg [1:0] puc_s;
always @(posedge mclk or posedge puc_reset)
  if (puc_reset) puc_s  <=  2'b11;
  else           puc_s  <=  {puc_s[0], 1'b0};
wire   puc = puc_s[1];


// Generate debug unit reset
`ifdef DBG_EN   
reg [1:0] dbg_rst_s;
always @(posedge mclk or posedge por)
  if (por) dbg_rst_s  <=  2'b11;
  else     dbg_rst_s  <=  {dbg_rst_s[0], ~dbg_en};

`else
wire [1:0] dbg_rst_s   = 2'b11;
`endif

wire   dbg_en_s = ~dbg_rst_s[1];
wire   dbg_rst  =  dbg_rst_s[1];


endmodule // omsp_clock_module

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_undefines.v"
`endif
