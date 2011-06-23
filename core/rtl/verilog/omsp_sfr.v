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
// *File Name: omsp_sfr.v
// 
// *Module Description:
//                       Processor Special function register
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

module  omsp_sfr (

// OUTPUTs
    nmie,                         // Non-maskable interrupt enable
    per_dout,                     // Peripheral data output
    wdt_irq,                      // Watchdog-timer interrupt
    wdt_reset,                    // Watchdog-timer reset
    wdtie,                        // Watchdog-timer interrupt enable

// INPUTs
    mclk,                         // Main system clock
    nmi_acc,                      // Non-Maskable interrupt request accepted
    per_addr,                     // Peripheral address
    per_din,                      // Peripheral data input
    per_en,                       // Peripheral enable (high active)
    per_we,                       // Peripheral write enable (high active)
    por,                          // Power-on reset
    puc_rst,                      // Main system reset
    wdtifg_clr,                   // Clear Watchdog-timer interrupt flag
    wdtifg_set,                   // Set Watchdog-timer interrupt flag
    wdtpw_error,                  // Watchdog-timer password error
    wdttmsel                      // Watchdog-timer mode select
);

// OUTPUTs
//=========
output              nmie;         // Non-maskable interrupt enable
output       [15:0] per_dout;     // Peripheral data output
output              wdt_irq;      // Watchdog-timer interrupt
output              wdt_reset;    // Watchdog-timer reset
output              wdtie;        // Watchdog-timer interrupt enable

// INPUTs
//=========
input               mclk;         // Main system clock
input               nmi_acc;      // Non-Maskable interrupt request accepted
input        [13:0] per_addr;     // Peripheral address
input        [15:0] per_din;      // Peripheral data input
input               per_en;       // Peripheral enable (high active)
input         [1:0] per_we;       // Peripheral write enable (high active)
input               por;          // Power-on reset
input               puc_rst;      // Main system reset
input               wdtifg_clr;   // Clear Watchdog-timer interrupt flag
input               wdtifg_set;   // Set Watchdog-timer interrupt flag
input               wdtpw_error;  // Watchdog-timer password error
input               wdttmsel;     // Watchdog-timer mode select


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0000;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  2;

// Register addresses offset
parameter [DEC_WD-1:0] IE1         =  'h0,
                       IFG1        =  'h2;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  2**DEC_WD;
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] IE1_D       = (BASE_REG << IE1),
                       IFG1_D      = (BASE_REG << IFG1);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (IE1_D   &  {DEC_SZ{(reg_addr==(IE1  >>1))}})  |
                                 (IFG1_D  &  {DEC_SZ{(reg_addr==(IFG1 >>1))}});

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

// IE1 Register
//--------------
wire [7:0] ie1;
wire       ie1_wr  = IE1[0] ? reg_hi_wr[IE1] : reg_lo_wr[IE1];
wire [7:0] ie1_nxt = IE1[0] ? per_din[15:8]  : per_din[7:0];

reg        nmie;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)      nmie  <=  1'b0;
  else if (nmi_acc) nmie  <=  1'b0; 
  else if (ie1_wr)  nmie  <=  ie1_nxt[4];    

reg        wdtie;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)      wdtie <=  1'b0;
  else if (ie1_wr)  wdtie <=  ie1_nxt[0];    

assign  ie1 = {3'b000, nmie, 3'b000, wdtie};


// IFG1 Register
//---------------
wire [7:0] ifg1;
wire       ifg1_wr  = IFG1[0] ? reg_hi_wr[IFG1] : reg_lo_wr[IFG1];
wire [7:0] ifg1_nxt = IFG1[0] ? per_din[15:8]   : per_din[7:0];

reg        nmiifg;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       nmiifg <=  1'b0;
  else if (nmi_acc)  nmiifg <=  1'b1;
  else if (ifg1_wr)  nmiifg <=  ifg1_nxt[4];

reg        wdtifg;
always @ (posedge mclk or posedge por)
  if (por)                        wdtifg <=  1'b0;
  else if (wdtifg_set)            wdtifg <=  1'b1;
  else if (wdttmsel & wdtifg_clr) wdtifg <=  1'b0;
  else if (ifg1_wr)               wdtifg <=  ifg1_nxt[0];

assign  ifg1 = {3'b000, nmiifg, 3'b000, wdtifg};


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] ie1_rd   = {8'h00, (ie1  & {8{reg_rd[IE1]}})}  << (8 & {4{IE1[0]}});
wire [15:0] ifg1_rd  = {8'h00, (ifg1 & {8{reg_rd[IFG1]}})} << (8 & {4{IFG1[0]}});

wire [15:0] per_dout =  ie1_rd   |
                        ifg1_rd;


//=============================================================================
// 5)  WATCHDOG INTERRUPT & RESET
//=============================================================================

// Watchdog interrupt generation
//---------------------------------
wire    wdt_irq      = wdttmsel & wdtifg & wdtie;

   
// Watchdog reset generation
//-----------------------------
reg     wdt_reset;

always @ (posedge mclk or posedge por)
  if (por) wdt_reset <= 1'b0;
  else     wdt_reset <= wdtpw_error | (wdtifg_set & ~wdttmsel);


endmodule // omsp_sfr

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_undefines.v"
`endif
