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
// *File Name: omsp_timerA.v
// 
// *Module Description:
//                       Timer A top-level
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------
`include "timescale.v"
`include "openMSP430_defines.v"

module  omsp_timerA (

// OUTPUTs
    irq_ta0,                        // Timer A interrupt: TACCR0
    irq_ta1,                        // Timer A interrupt: TAIV, TACCR1, TACCR2
    per_dout,                       // Peripheral data output
    ta_out0,                        // Timer A output 0
    ta_out0_en,                     // Timer A output 0 enable
    ta_out1,                        // Timer A output 1
    ta_out1_en,                     // Timer A output 1 enable
    ta_out2,                        // Timer A output 2
    ta_out2_en,                     // Timer A output 2 enable

// INPUTs
    aclk_en,                        // ACLK enable (from CPU)
    dbg_freeze,                     // Freeze Timer A counter
    inclk,                          // INCLK external timer clock (SLOW)
    irq_ta0_acc,                    // Interrupt request TACCR0 accepted
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_wen,                        // Peripheral write enable (high active)
    puc,                            // Main system reset
    smclk_en,                       // SMCLK enable (from CPU)
    ta_cci0a,                       // Timer A capture 0 input A
    ta_cci0b,                       // Timer A capture 0 input B
    ta_cci1a,                       // Timer A capture 1 input A
    ta_cci1b,                       // Timer A capture 1 input B
    ta_cci2a,                       // Timer A capture 2 input A
    ta_cci2b,                       // Timer A capture 2 input B
    taclk                           // TACLK external timer clock (SLOW)
);

// OUTPUTs
//=========
output              irq_ta0;        // Timer A interrupt: TACCR0
output              irq_ta1;        // Timer A interrupt: TAIV, TACCR1, TACCR2
output       [15:0] per_dout;       // Peripheral data output
output              ta_out0;        // Timer A output 0
output              ta_out0_en;     // Timer A output 0 enable
output              ta_out1;        // Timer A output 1
output              ta_out1_en;     // Timer A output 1 enable
output              ta_out2;        // Timer A output 2
output              ta_out2_en;     // Timer A output 2 enable

// INPUTs
//=========
input               aclk_en;        // ACLK enable (from CPU)
input               dbg_freeze;     // Freeze Timer A counter
input               inclk;          // INCLK external timer clock (SLOW)
input               irq_ta0_acc;    // Interrupt request TACCR0 accepted
input               mclk;           // Main system clock
input         [7:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_wen;        // Peripheral write enable (high active)
input               puc;            // Main system reset
input               smclk_en;       // SMCLK enable (from CPU)
input               ta_cci0a;       // Timer A capture 0 input A
input               ta_cci0b;       // Timer A capture 0 input B
input               ta_cci1a;       // Timer A capture 1 input A
input               ta_cci1b;       // Timer A capture 1 input B
input               ta_cci2a;       // Timer A capture 2 input A
input               ta_cci2b;       // Timer A capture 2 input B
input               taclk;          // TACLK external timer clock (SLOW)


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register addresses
parameter           TACTL      = 9'h160;
parameter           TAR        = 9'h170;
parameter           TACCTL0    = 9'h162;
parameter           TACCR0     = 9'h172;
parameter           TACCTL1    = 9'h164;
parameter           TACCR1     = 9'h174;
parameter           TACCTL2    = 9'h166;
parameter           TACCR2     = 9'h176;
parameter           TAIV       = 9'h12E;


// Register one-hot decoder
parameter           TACTL_D    = (512'h1 << TACTL);
parameter           TAR_D      = (512'h1 << TAR);
parameter           TACCTL0_D  = (512'h1 << TACCTL0);
parameter           TACCR0_D   = (512'h1 << TACCR0);
parameter           TACCTL1_D  = (512'h1 << TACCTL1);
parameter           TACCR1_D   = (512'h1 << TACCR1);
parameter           TACCTL2_D  = (512'h1 << TACCTL2);
parameter           TACCR2_D   = (512'h1 << TACCR2);
parameter           TAIV_D     = (512'h1 << TAIV);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [511:0]  reg_dec; 
always @(per_addr)
  case ({per_addr,1'b0})
    TACTL  :     reg_dec  =  TACTL_D;
    TAR    :     reg_dec  =  TAR_D;
    TACCTL0:     reg_dec  =  TACCTL0_D;
    TACCR0 :     reg_dec  =  TACCR0_D;
    TACCTL1:     reg_dec  =  TACCTL1_D;
    TACCR1 :     reg_dec  =  TACCR1_D;
    TACCTL2:     reg_dec  =  TACCTL2_D;
    TACCR2 :     reg_dec  =  TACCR2_D;
    TAIV   :     reg_dec  =  TAIV_D;
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

// TACTL Register
//-----------------   
reg   [9:0] tactl;

wire        tactl_wr = reg_wr[TACTL];
wire        taclr    = tactl_wr & per_din[`TACLR];
wire        taifg_set;
wire        taifg_clr;
   
always @ (posedge mclk or posedge puc)
  if (puc)           tactl <=  10'h000;
  else if (tactl_wr) tactl <=  ((per_din[9:0] & 10'h3f3) | {9'h000, taifg_set}) & {9'h1ff, ~taifg_clr};
  else               tactl <=  (tactl                    | {9'h000, taifg_set}) & {9'h1ff, ~taifg_clr};


// TAR Register
//-----------------   
reg  [15:0] tar;

wire        tar_wr = reg_wr[TAR];

wire        tar_clk;
wire        tar_clr;
wire        tar_inc;
wire        tar_dec;
wire [15:0] tar_add  = tar_inc ? 16'h0001 :
                       tar_dec ? 16'hffff : 16'h0000;
wire [15:0] tar_nxt  = tar_clr ? 16'h0000 : (tar+tar_add);
  
always @ (posedge mclk or posedge puc)
  if (puc)                         tar <=  16'h0000;
  else if  (tar_wr)                tar <=  per_din;
  else if  (taclr)                 tar <=  16'h0000;
  else if  (tar_clk & ~dbg_freeze) tar <=  tar_nxt;


// TACCTL0 Register
//------------------   
reg  [15:0] tacctl0;

wire        tacctl0_wr = reg_wr[TACCTL0];
wire        ccifg0_set;
wire        cov0_set;   

always @ (posedge mclk or posedge puc)
  if (puc)             tacctl0  <=  16'h0000;
  else if (tacctl0_wr) tacctl0  <=  ((per_din & 16'hf9f7) | {14'h0000, cov0_set, ccifg0_set}) & {15'h7fff, ~irq_ta0_acc};
  else                 tacctl0  <=  (tacctl0              | {14'h0000, cov0_set, ccifg0_set}) & {15'h7fff, ~irq_ta0_acc};

wire        cci0;
reg         scci0;
wire [15:0] tacctl0_full = tacctl0 | {5'h00, scci0, 6'h00, cci0, 3'h0};

   
// TACCR0 Register
//------------------   
reg  [15:0] taccr0;

wire        taccr0_wr = reg_wr[TACCR0];
wire        cci0_cap;

always @ (posedge mclk or posedge puc)
  if (puc)            taccr0 <=  16'h0000;
  else if (taccr0_wr) taccr0 <=  per_din;
  else if (cci0_cap)  taccr0 <=  tar;

   
// TACCTL1 Register
//------------------   
reg  [15:0] tacctl1;

wire        tacctl1_wr = reg_wr[TACCTL1];
wire        ccifg1_set;
wire        ccifg1_clr;
wire        cov1_set;   
   
always @ (posedge mclk or posedge puc)
  if (puc)             tacctl1 <=  16'h0000;
  else if (tacctl1_wr) tacctl1 <=  ((per_din & 16'hf9f7) | {14'h0000, cov1_set, ccifg1_set}) & {15'h7fff, ~ccifg1_clr};
  else                 tacctl1 <=  (tacctl1              | {14'h0000, cov1_set, ccifg1_set}) & {15'h7fff, ~ccifg1_clr};

wire        cci1;
reg         scci1;
wire [15:0] tacctl1_full = tacctl1 | {5'h00, scci1, 6'h00, cci1, 3'h0};

   
// TACCR1 Register
//------------------   
reg  [15:0] taccr1;

wire        taccr1_wr = reg_wr[TACCR1];
wire        cci1_cap;

always @ (posedge mclk or posedge puc)
  if (puc)            taccr1 <=  16'h0000;
  else if (taccr1_wr) taccr1 <=  per_din;
  else if (cci1_cap)  taccr1 <=  tar;


// TACCTL2 Register
//------------------   
reg  [15:0] tacctl2;

wire        tacctl2_wr = reg_wr[TACCTL2];
wire        ccifg2_set;
wire        ccifg2_clr;
wire        cov2_set;   
   
always @ (posedge mclk or posedge puc)
  if (puc)             tacctl2 <=  16'h0000;
  else if (tacctl2_wr) tacctl2 <=  ((per_din & 16'hf9f7) | {14'h0000, cov2_set, ccifg2_set}) & {15'h7fff, ~ccifg2_clr};
  else                 tacctl2 <=  (tacctl2              | {14'h0000, cov2_set, ccifg2_set}) & {15'h7fff, ~ccifg2_clr};

wire        cci2;
reg         scci2;
wire [15:0] tacctl2_full = tacctl2 | {5'h00, scci2, 6'h00, cci2, 3'h0};

   
// TACCR2 Register
//------------------   
reg  [15:0] taccr2;

wire        taccr2_wr = reg_wr[TACCR2];
wire        cci2_cap;

always @ (posedge mclk or posedge puc)
  if (puc)            taccr2 <=  16'h0000;
  else if (taccr2_wr) taccr2 <=  per_din;
  else if (cci2_cap)  taccr2 <=  tar;

   
// TAIV Register
//------------------   

wire [3:0] taiv = (tacctl1[`TACCIFG] & tacctl1[`TACCIE]) ? 4'h2 : 
                  (tacctl2[`TACCIFG] & tacctl2[`TACCIE]) ? 4'h4 : 
                  (tactl[`TAIFG]     & tactl[`TAIE])     ? 4'hA : 
                                                           4'h0;

assign     ccifg1_clr = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'h2);
assign     ccifg2_clr = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'h4);
assign     taifg_clr  = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'hA);


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] tactl_rd   = {6'h00, tactl}  & {16{reg_rd[TACTL]}};
wire [15:0] tar_rd     = tar             & {16{reg_rd[TAR]}};
wire [15:0] tacctl0_rd = tacctl0_full    & {16{reg_rd[TACCTL0]}};
wire [15:0] taccr0_rd  = taccr0          & {16{reg_rd[TACCR0]}};
wire [15:0] tacctl1_rd = tacctl1_full    & {16{reg_rd[TACCTL1]}};
wire [15:0] taccr1_rd  = taccr1          & {16{reg_rd[TACCR1]}};
wire [15:0] tacctl2_rd = tacctl2_full    & {16{reg_rd[TACCTL2]}};
wire [15:0] taccr2_rd  = taccr2          & {16{reg_rd[TACCR2]}};
wire [15:0] taiv_rd    = {12'h000, taiv} & {16{reg_rd[TAIV]}};

wire [15:0] per_dout   =  tactl_rd   |
                          tar_rd     |
                          tacctl0_rd |
                          taccr0_rd  |
                          tacctl1_rd |
                          taccr1_rd  |
                          tacctl2_rd |
                          taccr2_rd  |
                          taiv_rd;

   
//============================================================================
// 5) Timer A counter control
//============================================================================

// Clock input synchronization (TACLK & INCLK)
//-----------------------------------------------------------
reg  [2:0] taclk_s;
   
always @ (posedge mclk or posedge puc)
  if (puc) taclk_s <=  3'b000;
  else     taclk_s <=  {taclk_s[1:0], taclk};    

wire taclk_en = taclk_s[1] & ~taclk_s[2];

   
reg  [2:0] inclk_s;
   
always @ (posedge mclk or posedge puc)
  if (puc) inclk_s <=  3'b000;
  else     inclk_s <=  {inclk_s[1:0], inclk};    

wire inclk_en = inclk_s[1] & ~inclk_s[2];

   
// Timer clock input mux
//-----------------------------------------------------------

wire sel_clk = (tactl[`TASSELx]==2'b00) ? taclk_en :
               (tactl[`TASSELx]==2'b01) ?  aclk_en :
               (tactl[`TASSELx]==2'b10) ? smclk_en : inclk_en;

     
// Generate update pluse for the counter (<=> divided clock)
//-----------------------------------------------------------
reg [2:0] clk_div;

assign    tar_clk = sel_clk & ((tactl[`TAIDx]==2'b00) ?  1'b1         :
                               (tactl[`TAIDx]==2'b01) ?  clk_div[0]   :
                               (tactl[`TAIDx]==2'b10) ? &clk_div[1:0] :
                                                        &clk_div[2:0]);
	  
always @ (posedge mclk or posedge puc)
  if (puc)                                   clk_div <=  3'h0;
  else if  (tar_clk | taclr)                 clk_div <=  3'h0;
  else if ((tactl[`TAMCx]!=2'b00) & sel_clk) clk_div <=  clk_div+3'h1;

  
// Time counter control signals
//-----------------------------------------------------------

assign  tar_clr   = ((tactl[`TAMCx]==2'b01) & (tar>=taccr0))         |
                    ((tactl[`TAMCx]==2'b11) & (taccr0==16'h0000));

assign  tar_inc   =  (tactl[`TAMCx]==2'b01) | (tactl[`TAMCx]==2'b10) | 
                    ((tactl[`TAMCx]==2'b11) & ~tar_dec);

reg tar_dir;
always @ (posedge mclk or posedge puc)
  if (puc)                            tar_dir <=  1'b0;
  else if (taclr)                     tar_dir <=  1'b0;
  else if (tactl[`TAMCx]==2'b11)
    begin
       if (tar_clk & (tar==16'h0001)) tar_dir <=  1'b0;
       else if       (tar>=taccr0)    tar_dir <=  1'b1;
    end
  else                                tar_dir <=  1'b0;
   
assign tar_dec = tar_dir | ((tactl[`TAMCx]==2'b11) & (tar>=taccr0));

   
//============================================================================
// 6) Timer A comparator
//============================================================================

wire equ0 = (tar_nxt==taccr0) & (tar!=taccr0);
wire equ1 = (tar_nxt==taccr1) & (tar!=taccr1);
wire equ2 = (tar_nxt==taccr2) & (tar!=taccr2);


//============================================================================
// 7) Timer A capture logic
//============================================================================

// Input selection
//------------------
assign cci0 = (tacctl0[`TACCISx]==2'b00) ? ta_cci0a :
              (tacctl0[`TACCISx]==2'b01) ? ta_cci0b :
              (tacctl0[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

assign cci1 = (tacctl1[`TACCISx]==2'b00) ? ta_cci1a :
              (tacctl1[`TACCISx]==2'b01) ? ta_cci1b :
              (tacctl1[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

assign cci2 = (tacctl2[`TACCISx]==2'b00) ? ta_cci2a :
              (tacctl2[`TACCISx]==2'b01) ? ta_cci2b :
              (tacctl2[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

// Register CCIx for synchronization and edge detection
reg [2:0] cci_s;
always @ (posedge mclk or posedge puc)
  if (puc) cci_s <=  3'h0;
  else     cci_s <=  {cci2, cci1, cci0};
reg [2:0] cci_ss;
always @ (posedge mclk or posedge puc)
  if (puc) cci_ss <=  3'h0;
  else     cci_ss <=  cci_s;
reg [2:0] cci_sss;
always @ (posedge mclk or posedge puc)
  if (puc) cci_sss <=  3'h0;
  else     cci_sss <=  cci_ss;

   
// Generate SCCIx
//------------------

always @ (posedge mclk or posedge puc)
  if (puc)                 scci0 <=  1'b0;
  else if (tar_clk & equ0) scci0 <=  cci_ss[0];

always @ (posedge mclk or posedge puc)
  if (puc)                 scci1 <=  1'b0;
  else if (tar_clk & equ1) scci1 <=  cci_ss[1];

always @ (posedge mclk or posedge puc)
  if (puc)                 scci2 <=  1'b0;
  else if (tar_clk & equ2) scci2 <=  cci_ss[2];


// Capture mode
//------------------
wire cci0_evt = (tacctl0[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl0[`TACMx]==2'b01) ? ( cci_ss[0] & ~cci_sss[0]) :   // Rising edge
                (tacctl0[`TACMx]==2'b10) ? (~cci_ss[0] &  cci_sss[0]) :   // Falling edge
                                           ( cci_ss[0] ^  cci_sss[0]);    // Both edges

wire cci1_evt = (tacctl1[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl1[`TACMx]==2'b01) ? ( cci_ss[1] & ~cci_sss[1]) :   // Rising edge
                (tacctl1[`TACMx]==2'b10) ? (~cci_ss[1] &  cci_sss[1]) :   // Falling edge
                                           ( cci_ss[1] ^  cci_sss[1]);    // Both edges

wire cci2_evt = (tacctl2[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl2[`TACMx]==2'b01) ? ( cci_ss[2] & ~cci_sss[2]) :   // Rising edge
                (tacctl2[`TACMx]==2'b10) ? (~cci_ss[2] &  cci_sss[2]) :   // Falling edge
                                           ( cci_ss[2] ^  cci_sss[2]);    // Both edges

// Event Synchronization
//-----------------------

reg cci0_evt_s;
always @ (posedge mclk or posedge puc)
  if (puc)           cci0_evt_s <=  1'b0;
  else if (tar_clk)  cci0_evt_s <=  1'b0;
  else if (cci0_evt) cci0_evt_s <=  1'b1;

reg cci1_evt_s;
always @ (posedge mclk or posedge puc)
  if (puc)           cci1_evt_s <=  1'b0;
  else if (tar_clk)  cci1_evt_s <=  1'b0;
  else if (cci1_evt) cci1_evt_s <=  1'b1;

reg cci2_evt_s;
always @ (posedge mclk or posedge puc)
  if (puc)           cci2_evt_s <=  1'b0;
  else if (tar_clk)  cci2_evt_s <=  1'b0;
  else if (cci2_evt) cci2_evt_s <=  1'b1;

reg cci0_sync;
always @ (posedge mclk or posedge puc)
  if (puc) cci0_sync <=  1'b0;
  else     cci0_sync <=  (tar_clk & cci0_evt_s) | (tar_clk & cci0_evt & ~cci0_evt_s);

reg cci1_sync;
always @ (posedge mclk or posedge puc)
  if (puc) cci1_sync <=  1'b0;
  else     cci1_sync <=  (tar_clk & cci1_evt_s) | (tar_clk & cci1_evt & ~cci1_evt_s);

reg cci2_sync;
always @ (posedge mclk or posedge puc)
  if (puc) cci2_sync <=  1'b0;
  else     cci2_sync <=  (tar_clk & cci2_evt_s) | (tar_clk & cci2_evt & ~cci2_evt_s);

   
// Generate final capture command
//-----------------------------------

assign cci0_cap  = tacctl0[`TASCS] ? cci0_sync : cci0_evt;
assign cci1_cap  = tacctl1[`TASCS] ? cci1_sync : cci1_evt;
assign cci2_cap  = tacctl2[`TASCS] ? cci2_sync : cci2_evt;

   
// Generate capture overflow flag
//-----------------------------------

reg  cap0_taken;
wire cap0_taken_clr = reg_rd[TACCR0] | (tacctl0_wr & tacctl0[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc)
  if (puc)                 cap0_taken <=  1'b0;
  else if (cci0_cap)       cap0_taken <=  1'b1;
  else if (cap0_taken_clr) cap0_taken <=  1'b0;
   
reg  cap1_taken;
wire cap1_taken_clr = reg_rd[TACCR1] | (tacctl1_wr & tacctl1[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc)
  if (puc)                 cap1_taken <=  1'b0;
  else if (cci1_cap)       cap1_taken <=  1'b1;
  else if (cap1_taken_clr) cap1_taken <=  1'b0;
      
reg  cap2_taken;
wire cap2_taken_clr = reg_rd[TACCR2] | (tacctl2_wr & tacctl2[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc)
  if (puc)                 cap2_taken <=  1'b0;
  else if (cci2_cap)       cap2_taken <=  1'b1;
  else if (cap2_taken_clr) cap2_taken <=  1'b0;

   
assign cov0_set = cap0_taken & cci0_cap & ~reg_rd[TACCR0];
assign cov1_set = cap1_taken & cci1_cap & ~reg_rd[TACCR1];   
assign cov2_set = cap2_taken & cci2_cap & ~reg_rd[TACCR2];
  
      
//============================================================================
// 8) Timer A output unit
//============================================================================

// Output unit 0
//-------------------
reg  ta_out0;

wire ta_out0_mode0 = tacctl0[`TAOUT];                // Output
wire ta_out0_mode1 = equ0 ?  1'b1    : ta_out0;      // Set
wire ta_out0_mode2 = equ0 ? ~ta_out0 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out0;
wire ta_out0_mode3 = equ0 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out0;
wire ta_out0_mode4 = equ0 ? ~ta_out0 : ta_out0;      // Toggle
wire ta_out0_mode5 = equ0 ?  1'b0    : ta_out0;      // Reset
wire ta_out0_mode6 = equ0 ? ~ta_out0 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out0;
wire ta_out0_mode7 = equ0 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out0;

wire ta_out0_nxt   = (tacctl0[`TAOUTMODx]==3'b000) ? ta_out0_mode0 :
                     (tacctl0[`TAOUTMODx]==3'b001) ? ta_out0_mode1 :
                     (tacctl0[`TAOUTMODx]==3'b010) ? ta_out0_mode2 :
                     (tacctl0[`TAOUTMODx]==3'b011) ? ta_out0_mode3 :
                     (tacctl0[`TAOUTMODx]==3'b100) ? ta_out0_mode4 :
                     (tacctl0[`TAOUTMODx]==3'b101) ? ta_out0_mode5 :
                     (tacctl0[`TAOUTMODx]==3'b110) ? ta_out0_mode6 :
                                                     ta_out0_mode7;

always @ (posedge mclk or posedge puc)
  if (puc)                                         ta_out0 <=  1'b0;
  else if ((tacctl0[`TAOUTMODx]==3'b001) & taclr)  ta_out0 <=  1'b0;
  else if (tar_clk)                                ta_out0 <=  ta_out0_nxt;

assign  ta_out0_en = ~tacctl0[`TACAP];

   
// Output unit 1
//-------------------
reg  ta_out1;

wire ta_out1_mode0 = tacctl1[`TAOUT];                // Output
wire ta_out1_mode1 = equ1 ?  1'b1    : ta_out1;      // Set
wire ta_out1_mode2 = equ1 ? ~ta_out1 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out1;
wire ta_out1_mode3 = equ1 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out1;
wire ta_out1_mode4 = equ1 ? ~ta_out1 : ta_out1;      // Toggle
wire ta_out1_mode5 = equ1 ?  1'b0    : ta_out1;      // Reset
wire ta_out1_mode6 = equ1 ? ~ta_out1 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out1;
wire ta_out1_mode7 = equ1 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out1;

wire ta_out1_nxt   = (tacctl1[`TAOUTMODx]==3'b000) ? ta_out1_mode0 :
                     (tacctl1[`TAOUTMODx]==3'b001) ? ta_out1_mode1 :
                     (tacctl1[`TAOUTMODx]==3'b010) ? ta_out1_mode2 :
                     (tacctl1[`TAOUTMODx]==3'b011) ? ta_out1_mode3 :
                     (tacctl1[`TAOUTMODx]==3'b100) ? ta_out1_mode4 :
                     (tacctl1[`TAOUTMODx]==3'b101) ? ta_out1_mode5 :
                     (tacctl1[`TAOUTMODx]==3'b110) ? ta_out1_mode6 :
                                                     ta_out1_mode7;

always @ (posedge mclk or posedge puc)
  if (puc)                                         ta_out1 <=  1'b0;
  else if ((tacctl1[`TAOUTMODx]==3'b001) & taclr)  ta_out1 <=  1'b0;
  else if (tar_clk)                                ta_out1 <=  ta_out1_nxt;

assign  ta_out1_en = ~tacctl1[`TACAP];

   
// Output unit 2
//-------------------
reg  ta_out2;

wire ta_out2_mode0 = tacctl2[`TAOUT];                // Output
wire ta_out2_mode1 = equ2 ?  1'b1    : ta_out2;      // Set
wire ta_out2_mode2 = equ2 ? ~ta_out2 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out2;
wire ta_out2_mode3 = equ2 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out2;
wire ta_out2_mode4 = equ2 ? ~ta_out2 : ta_out2;      // Toggle
wire ta_out2_mode5 = equ2 ?  1'b0    : ta_out2;      // Reset
wire ta_out2_mode6 = equ2 ? ~ta_out2 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out2;
wire ta_out2_mode7 = equ2 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out2;

wire ta_out2_nxt   = (tacctl2[`TAOUTMODx]==3'b000) ? ta_out2_mode0 :
                     (tacctl2[`TAOUTMODx]==3'b001) ? ta_out2_mode1 :
                     (tacctl2[`TAOUTMODx]==3'b010) ? ta_out2_mode2 :
                     (tacctl2[`TAOUTMODx]==3'b011) ? ta_out2_mode3 :
                     (tacctl2[`TAOUTMODx]==3'b100) ? ta_out2_mode4 :
                     (tacctl2[`TAOUTMODx]==3'b101) ? ta_out2_mode5 :
                     (tacctl2[`TAOUTMODx]==3'b110) ? ta_out2_mode6 :
                                                     ta_out2_mode7;

always @ (posedge mclk or posedge puc)
  if (puc)                                         ta_out2 <=  1'b0;
  else if ((tacctl2[`TAOUTMODx]==3'b001) & taclr)  ta_out2 <=  1'b0;
  else if (tar_clk)                                ta_out2 <=  ta_out2_nxt;

assign  ta_out2_en = ~tacctl2[`TACAP];

   
//============================================================================
// 9) Timer A interrupt generation
//============================================================================


assign   taifg_set   = tar_clk & (((tactl[`TAMCx]==2'b01) & (tar==taccr0))                  |
                                  ((tactl[`TAMCx]==2'b10) & (tar==16'hffff))                |
                                  ((tactl[`TAMCx]==2'b11) & (tar_nxt==16'h0000) & tar_dec));

assign   ccifg0_set  = tacctl0[`TACAP] ? cci0_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ0));
assign   ccifg1_set  = tacctl1[`TACAP] ? cci1_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ1));
assign   ccifg2_set  = tacctl2[`TACAP] ? cci2_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ2));

  
wire     irq_ta0    = (tacctl0[`TACCIFG] & tacctl0[`TACCIE]);

wire     irq_ta1    = (tactl[`TAIFG]     & tactl[`TAIE])     |
                      (tacctl1[`TACCIFG] & tacctl1[`TACCIE]) |
                      (tacctl2[`TACCIFG] & tacctl2[`TACCIE]);
   

endmodule // omsp_timerA

`include "openMSP430_undefines.v"
