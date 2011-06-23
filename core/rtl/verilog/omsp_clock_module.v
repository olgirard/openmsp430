//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
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
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
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
    puc_rst,                      // Main system reset
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
output              puc_rst;      // Main system reset
output              smclk_en;     // SMCLK enable

// INPUTs
//=========
input               cpu_en;       // Enable CPU code execution (asynchronous)
input               dbg_cpu_reset;// Reset CPU from debug interface
input               dbg_en;       // Debug interface enable (asynchronous)
input               dco_clk;      // Fast oscillator (fast clock)
input               lfxt_clk;     // Low frequency oscillator (typ 32kHz)
input               oscoff;       // Turns off LFXT1 clock input
input        [13:0] per_addr;     // Peripheral address
input        [15:0] per_din;      // Peripheral data input
input               per_en;       // Peripheral enable (high active)
input         [1:0] per_we;       // Peripheral write enable (high active)
input               reset_n;      // Reset Pin (low active, asynchronous)
input               scg1;         // System clock generator 1. Turns off the SMCLK
input               wdt_reset;    // Watchdog-timer reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0050;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  4;

// Register addresses offset
parameter [DEC_WD-1:0] BCSCTL1     =  'h7,
                       BCSCTL2     =  'h8;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  2**DEC_WD;
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] BCSCTL1_D   = (BASE_REG << BCSCTL1),
                       BCSCTL2_D   = (BASE_REG << BCSCTL2);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (BCSCTL1_D  &  {DEC_SZ{(reg_addr==(BCSCTL1 >>1))}}) |
                                 (BCSCTL2_D  &  {DEC_SZ{(reg_addr==(BCSCTL2 >>1))}});

// Read/Write probes
wire              reg_lo_write =  per_we[0] & reg_sel;
wire              reg_hi_write =  per_we[1] & reg_sel;
wire              reg_read     = ~|per_we   & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_hi_wr    = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr    = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd       = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// BCSCTL1 Register
//--------------
reg  [7:0] bcsctl1;
wire       bcsctl1_wr  = BCSCTL1[0] ? reg_hi_wr[BCSCTL1] : reg_lo_wr[BCSCTL1];
wire [7:0] bcsctl1_nxt = BCSCTL1[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          bcsctl1  <=  8'h00;
  else if (bcsctl1_wr)  bcsctl1  <=  bcsctl1_nxt & 8'h30; // Mask unused bits


// BCSCTL2 Register
//--------------
reg  [7:0] bcsctl2;
wire       bcsctl2_wr  = BCSCTL2[0] ? reg_hi_wr[BCSCTL2] : reg_lo_wr[BCSCTL2];
wire [7:0] bcsctl2_nxt = BCSCTL2[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          bcsctl2  <=  8'h00;
  else if (bcsctl2_wr)  bcsctl2  <=  bcsctl2_nxt & 8'h0e; // Mask unused bits


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] bcsctl1_rd   = {8'h00, (bcsctl1  & {8{reg_rd[BCSCTL1]}})}  << (8 & {4{BCSCTL1[0]}});
wire [15:0] bcsctl2_rd   = {8'h00, (bcsctl2  & {8{reg_rd[BCSCTL2]}})}  << (8 & {4{BCSCTL2[0]}});

wire [15:0] per_dout =  bcsctl1_rd   |
                        bcsctl2_rd;


//=============================================================================
// 5)  CLOCK GENERATION
//=============================================================================

// Synchronize CPU_EN signal
//---------------------------------------
`ifdef SYNC_CPU_EN
omsp_sync_cell sync_cell_cpu_en (
    .data_out (cpu_en_s),
    .clk      (mclk),
    .data_in  (cpu_en),
    .rst      (por)
);
`else
   assign cpu_en_s = cpu_en;
`endif

// Synchronize LFXT_CLK & edge detection
//---------------------------------------
wire lfxt_clk_s;

omsp_sync_cell sync_cell_lfxt_clk (
    .data_out (lfxt_clk_s),
    .clk      (mclk),
    .data_in  (lfxt_clk),
    .rst      (por)
);

reg  lfxt_clk_dly;
   
always @ (posedge mclk or posedge por)
  if (por) lfxt_clk_dly <=  1'b0;
  else     lfxt_clk_dly <=  lfxt_clk_s;    

wire lfxt_clk_en = (lfxt_clk_s & ~lfxt_clk_dly) & ~(oscoff & ~bcsctl2[`SELS]);
     
   
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

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)  aclk_en <=  1'b0;
  else          aclk_en <=  aclk_en_nxt & cpu_en_s;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                     aclk_div <=  3'h0;
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
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)  smclk_en <=  1'b0;
  else          smclk_en <=  smclk_en_nxt & cpu_en_s;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                  smclk_div <=  3'h0;
  else if ((bcsctl2[`DIVSx]!=2'b00) & smclk_in) smclk_div <=  smclk_div+3'h1;


// Generate DBG_CLK
//----------------------------

assign  dbg_clk = mclk;


//=============================================================================
// 6)  RESET GENERATION
//=============================================================================

// Generate synchronized POR
wire      por_n;
wire      por_reset_a  =  !reset_n;

omsp_sync_cell sync_cell_por (
    .data_out (por_n),
    .clk      (mclk),
    .data_in  (1'b1),
    .rst      (por_reset_a)
);

wire   por = ~por_n;


// Generate main system reset
wire      puc_rst_comb = por | wdt_reset | dbg_cpu_reset;
reg       puc_rst;
always @(posedge mclk or posedge puc_rst_comb)
  if (puc_rst_comb) puc_rst  <=  1'b1;
  else              puc_rst  <=  1'b0;


// Generate debug unit reset
`ifdef DBG_EN
wire   dbg_rst_n;

  `ifdef SYNC_DBG_EN
     omsp_sync_cell sync_cell_dbg_en (
        .data_out (dbg_rst_n),
        .clk      (mclk),
        .data_in  (dbg_en),
        .rst      (por)
    );
  `else
assign dbg_rst_n = dbg_en;
  `endif

`else
wire   dbg_rst_n  = 1'b0;
`endif

wire   dbg_en_s   =  dbg_rst_n;
wire   dbg_rst    = ~dbg_rst_n;


endmodule // omsp_clock_module

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_undefines.v"
`endif
