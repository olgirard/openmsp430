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
// *File Name: omsp_watchdog.v
// 
// *Module Description:
//                       Watchdog Timer
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module  omsp_watchdog (

// OUTPUTs
    nmi_evt,                        // NMI Event
    per_dout,                       // Peripheral data output
    wdtifg_set,                     // Set Watchdog-timer interrupt flag
    wdtpw_error,                    // Watchdog-timer password error
    wdttmsel,                       // Watchdog-timer mode select

// INPUTs
    aclk_en,                        // ACLK enable
    dbg_freeze,                     // Freeze Watchdog counter
    mclk,                           // Main system clock
    nmi,                            // Non-maskable interrupt (asynchronous)
    nmie,                           // Non-maskable interrupt enable
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                        // Main system reset
    smclk_en,                       // SMCLK enable
    wdtie                           // Watchdog timer interrupt enable
);

// OUTPUTs
//=========
output              nmi_evt;        // NMI Event
output       [15:0] per_dout;       // Peripheral data output
output              wdtifg_set;     // Set Watchdog-timer interrupt flag
output              wdtpw_error;    // Watchdog-timer password error
output              wdttmsel;       // Watchdog-timer mode select

// INPUTs
//=========
input               aclk_en;        // ACLK enable
input               dbg_freeze;     // Freeze Watchdog counter
input               mclk;           // Main system clock
input               nmi;            // Non-maskable interrupt (asynchronous)
input               nmie;           // Non-maskable interrupt enable
input        [13:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset
input               smclk_en;       // SMCLK enable
input               wdtie;          // Watchdog timer interrupt enable


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0120;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  2;

// Register addresses offset
parameter [DEC_WD-1:0] WDTCTL      = 'h0;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  2**DEC_WD;
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] WDTCTL_D    = (BASE_REG << WDTCTL);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (WDTCTL_D & {DEC_SZ{(reg_addr==WDTCTL)}});

// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// WDTCTL Register
//-----------------
// WDTNMI & WDTSSEL are not implemented and therefore masked
   
reg  [7:0] wdtctl;

wire       wdtctl_wr = reg_wr[WDTCTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        wdtctl <=  8'h00;
  else if (wdtctl_wr) wdtctl <=  per_din[7:0] & 8'hd7;

wire       wdtpw_error = wdtctl_wr & (per_din[15:8]!=8'h5a);
wire       wdttmsel    = wdtctl[4];


//============================================================================
// 3) REGISTERS
//============================================================================

// Data output mux
wire [15:0] wdtctl_rd  = {8'h69, wdtctl}  & {16{reg_rd[WDTCTL]}};

wire [15:0] per_dout   =  wdtctl_rd;


//=============================================================================
// 4)  NMI GENERATION
//=============================================================================

// Synchronization
wire   nmi_s;
`ifdef SYNC_NMI
omsp_sync_cell sync_cell_nmi (
    .data_out (nmi_s),
    .clk      (mclk),
    .data_in  (nmi),
    .rst      (puc_rst)
);
`else
assign nmi_s = nmi;
`endif
   
// Delay
reg  nmi_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) nmi_dly <= 1'b0;
  else         nmi_dly <= nmi_s;

// Edge detection
wire        nmi_re    = ~nmi_dly &  nmi_s & nmie;
wire        nmi_fe    =  nmi_dly & ~nmi_s & nmie;

// NMI event
wire        nmi_evt   = wdtctl[6] ? nmi_fe : nmi_re;


//=============================================================================
// 5)  WATCHDOG TIMER
//=============================================================================

// Watchdog clock source selection
//---------------------------------
wire  clk_src_en = wdtctl[2] ? aclk_en : smclk_en;


// Watchdog 16 bit counter
//--------------------------
reg [15:0] wdtcnt;

wire       wdtcnt_clr = (wdtctl_wr & per_din[3]) | wdtifg_set;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                    wdtcnt <= 16'h0000;
  else if (wdtcnt_clr)                            wdtcnt <= 16'h0000;
  else if (~wdtctl[7] & clk_src_en & ~dbg_freeze) wdtcnt <= wdtcnt+16'h0001;

   
// Interval selection mux
//--------------------------
reg        wdtqn;

always @(wdtctl or wdtcnt)
    case(wdtctl[1:0])
      2'b00  : wdtqn =  wdtcnt[15];
      2'b01  : wdtqn =  wdtcnt[13];
      2'b10  : wdtqn =  wdtcnt[9];
      default: wdtqn =  wdtcnt[6];
    endcase


// Watchdog event detection
//-----------------------------
reg        wdtqn_dly;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) wdtqn_dly <= 1'b0;
  else         wdtqn_dly <= wdtqn;

wire       wdtifg_set =  (~wdtqn_dly & wdtqn) | wdtpw_error;


endmodule // omsp_watchdog

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_undefines.v"
`endif
