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
// *File Name: omsp_gpio.v
// 
// *Module Description:
//                       Digital I/O interface
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 106 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-25 23:01:03 +0100 (Fri, 25 Mar 2011) $
//----------------------------------------------------------------------------

module  omsp_gpio (

// OUTPUTs
    irq_port1,                      // Port 1 interrupt
    irq_port2,                      // Port 2 interrupt
    p1_dout,                        // Port 1 data output
    p1_dout_en,                     // Port 1 data output enable
    p1_sel,                         // Port 1 function select
    p2_dout,                        // Port 2 data output
    p2_dout_en,                     // Port 2 data output enable
    p2_sel,                         // Port 2 function select
    p3_dout,                        // Port 3 data output
    p3_dout_en,                     // Port 3 data output enable
    p3_sel,                         // Port 3 function select
    p4_dout,                        // Port 4 data output
    p4_dout_en,                     // Port 4 data output enable
    p4_sel,                         // Port 4 function select
    p5_dout,                        // Port 5 data output
    p5_dout_en,                     // Port 5 data output enable
    p5_sel,                         // Port 5 function select
    p6_dout,                        // Port 6 data output
    p6_dout_en,                     // Port 6 data output enable
    p6_sel,                         // Port 6 function select
    per_dout,                       // Peripheral data output

// INPUTs
    mclk,                           // Main system clock
    p1_din,                         // Port 1 data input
    p2_din,                         // Port 2 data input
    p3_din,                         // Port 3 data input
    p4_din,                         // Port 4 data input
    p5_din,                         // Port 5 data input
    p6_din,                         // Port 6 data input
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc                             // Main system reset
);

// PARAMETERs
//============
parameter           P1_EN = 1'b1;   // Enable Port 1
parameter           P2_EN = 1'b1;   // Enable Port 2
parameter           P3_EN = 1'b0;   // Enable Port 3
parameter           P4_EN = 1'b0;   // Enable Port 4
parameter           P5_EN = 1'b0;   // Enable Port 5
parameter           P6_EN = 1'b0;   // Enable Port 6


// OUTPUTs
//=========
output              irq_port1;      // Port 1 interrupt
output              irq_port2;      // Port 2 interrupt
output        [7:0] p1_dout;        // Port 1 data output
output        [7:0] p1_dout_en;     // Port 1 data output enable
output        [7:0] p1_sel;         // Port 1 function select
output        [7:0] p2_dout;        // Port 2 data output
output        [7:0] p2_dout_en;     // Port 2 data output enable
output        [7:0] p2_sel;         // Port 2 function select
output        [7:0] p3_dout;        // Port 3 data output
output        [7:0] p3_dout_en;     // Port 3 data output enable
output        [7:0] p3_sel;         // Port 3 function select
output        [7:0] p4_dout;        // Port 4 data output
output        [7:0] p4_dout_en;     // Port 4 data output enable
output        [7:0] p4_sel;         // Port 4 function select
output        [7:0] p5_dout;        // Port 5 data output
output        [7:0] p5_dout_en;     // Port 5 data output enable
output        [7:0] p5_sel;         // Port 5 function select
output        [7:0] p6_dout;        // Port 6 data output
output        [7:0] p6_dout_en;     // Port 6 data output enable
output        [7:0] p6_sel;         // Port 6 function select
output       [15:0] per_dout;       // Peripheral data output

// INPUTs
//=========
input               mclk;           // Main system clock
input         [7:0] p1_din;         // Port 1 data input
input         [7:0] p2_din;         // Port 2 data input
input         [7:0] p3_din;         // Port 3 data input
input         [7:0] p4_din;         // Port 4 data input
input         [7:0] p5_din;         // Port 5 data input
input         [7:0] p6_din;         // Port 6 data input
input         [7:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc;            // Main system reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Masks
parameter           P1_EN_MSK   = {8{P1_EN[0]}};
parameter           P2_EN_MSK   = {8{P2_EN[0]}};
parameter           P3_EN_MSK   = {8{P3_EN[0]}};
parameter           P4_EN_MSK   = {8{P4_EN[0]}};
parameter           P5_EN_MSK   = {8{P5_EN[0]}};
parameter           P6_EN_MSK   = {8{P6_EN[0]}};

// Register addresses
parameter           P1IN        = 9'h020;                  // Port 1
parameter           P1OUT       = 9'h021;
parameter           P1DIR       = 9'h022;
parameter           P1IFG       = 9'h023;
parameter           P1IES       = 9'h024;
parameter           P1IE        = 9'h025;
parameter           P1SEL       = 9'h026;
parameter           P2IN        = 9'h028;                  // Port 2
parameter           P2OUT       = 9'h029;
parameter           P2DIR       = 9'h02A;
parameter           P2IFG       = 9'h02B;
parameter           P2IES       = 9'h02C;
parameter           P2IE        = 9'h02D;
parameter           P2SEL       = 9'h02E;
parameter           P3IN        = 9'h018;                  // Port 3
parameter           P3OUT       = 9'h019;
parameter           P3DIR       = 9'h01A;
parameter           P3SEL       = 9'h01B;
parameter           P4IN        = 9'h01C;                  // Port 4
parameter           P4OUT       = 9'h01D;
parameter           P4DIR       = 9'h01E;
parameter           P4SEL       = 9'h01F;
parameter           P5IN        = 9'h030;                  // Port 5
parameter           P5OUT       = 9'h031;
parameter           P5DIR       = 9'h032;
parameter           P5SEL       = 9'h033;
parameter           P6IN        = 9'h034;                  // Port 6
parameter           P6OUT       = 9'h035;
parameter           P6DIR       = 9'h036;
parameter           P6SEL       = 9'h037;

   
// Register one-hot decoder
parameter           P1IN_D      = (256'h1 << (P1IN  /2));  // Port 1
parameter           P1OUT_D     = (256'h1 << (P1OUT /2)); 
parameter           P1DIR_D     = (256'h1 << (P1DIR /2)); 
parameter           P1IFG_D     = (256'h1 << (P1IFG /2)); 
parameter           P1IES_D     = (256'h1 << (P1IES /2)); 
parameter           P1IE_D      = (256'h1 << (P1IE  /2)); 
parameter           P1SEL_D     = (256'h1 << (P1SEL /2)); 
parameter           P2IN_D      = (256'h1 << (P2IN  /2));  // Port 2
parameter           P2OUT_D     = (256'h1 << (P2OUT /2)); 
parameter           P2DIR_D     = (256'h1 << (P2DIR /2)); 
parameter           P2IFG_D     = (256'h1 << (P2IFG /2)); 
parameter           P2IES_D     = (256'h1 << (P2IES /2)); 
parameter           P2IE_D      = (256'h1 << (P2IE  /2)); 
parameter           P2SEL_D     = (256'h1 << (P2SEL /2)); 
parameter           P3IN_D      = (256'h1 << (P3IN  /2));  // Port 3
parameter           P3OUT_D     = (256'h1 << (P3OUT /2)); 
parameter           P3DIR_D     = (256'h1 << (P3DIR /2)); 
parameter           P3SEL_D     = (256'h1 << (P3SEL /2)); 
parameter           P4IN_D      = (256'h1 << (P4IN  /2));  // Port 4
parameter           P4OUT_D     = (256'h1 << (P4OUT /2)); 
parameter           P4DIR_D     = (256'h1 << (P4DIR /2)); 
parameter           P4SEL_D     = (256'h1 << (P4SEL /2)); 
parameter           P5IN_D      = (256'h1 << (P5IN  /2));  // Port 5
parameter           P5OUT_D     = (256'h1 << (P5OUT /2)); 
parameter           P5DIR_D     = (256'h1 << (P5DIR /2)); 
parameter           P5SEL_D     = (256'h1 << (P5SEL /2)); 
parameter           P6IN_D      = (256'h1 << (P6IN  /2));  // Port 6
parameter           P6OUT_D     = (256'h1 << (P6OUT /2)); 
parameter           P6DIR_D     = (256'h1 << (P6DIR /2)); 
parameter           P6SEL_D     = (256'h1 << (P6SEL /2)); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [255:0]  reg_dec; 
always @(per_addr)
  case (per_addr)
    (P1IN  /2):   reg_dec  =  P1IN_D   & {256{P1_EN[0]}};
    (P1OUT /2):   reg_dec  =  P1OUT_D  & {256{P1_EN[0]}};
    (P1DIR /2):   reg_dec  =  P1DIR_D  & {256{P1_EN[0]}};
    (P1IFG /2):   reg_dec  =  P1IFG_D  & {256{P1_EN[0]}};
    (P1IES /2):   reg_dec  =  P1IES_D  & {256{P1_EN[0]}};
    (P1IE  /2):   reg_dec  =  P1IE_D   & {256{P1_EN[0]}};
    (P1SEL /2):   reg_dec  =  P1SEL_D  & {256{P1_EN[0]}};
    (P2IN  /2):   reg_dec  =  P2IN_D   & {256{P2_EN[0]}};
    (P2OUT /2):   reg_dec  =  P2OUT_D  & {256{P2_EN[0]}};
    (P2DIR /2):   reg_dec  =  P2DIR_D  & {256{P2_EN[0]}};
    (P2IFG /2):   reg_dec  =  P2IFG_D  & {256{P2_EN[0]}};
    (P2IES /2):   reg_dec  =  P2IES_D  & {256{P2_EN[0]}};
    (P2IE  /2):   reg_dec  =  P2IE_D   & {256{P2_EN[0]}};
    (P2SEL /2):   reg_dec  =  P2SEL_D  & {256{P2_EN[0]}};
    (P3IN  /2):   reg_dec  =  P3IN_D   & {256{P3_EN[0]}};
    (P3OUT /2):   reg_dec  =  P3OUT_D  & {256{P3_EN[0]}};
    (P3DIR /2):   reg_dec  =  P3DIR_D  & {256{P3_EN[0]}};
    (P3SEL /2):   reg_dec  =  P3SEL_D  & {256{P3_EN[0]}};
    (P4IN  /2):   reg_dec  =  P4IN_D   & {256{P4_EN[0]}};
    (P4OUT /2):   reg_dec  =  P4OUT_D  & {256{P4_EN[0]}};
    (P4DIR /2):   reg_dec  =  P4DIR_D  & {256{P4_EN[0]}};
    (P4SEL /2):   reg_dec  =  P4SEL_D  & {256{P4_EN[0]}};
    (P5IN  /2):   reg_dec  =  P5IN_D   & {256{P5_EN[0]}};
    (P5OUT /2):   reg_dec  =  P5OUT_D  & {256{P5_EN[0]}};
    (P5DIR /2):   reg_dec  =  P5DIR_D  & {256{P5_EN[0]}};
    (P5SEL /2):   reg_dec  =  P5SEL_D  & {256{P5_EN[0]}};
    (P6IN  /2):   reg_dec  =  P6IN_D   & {256{P6_EN[0]}};
    (P6OUT /2):   reg_dec  =  P6OUT_D  & {256{P6_EN[0]}};
    (P6DIR /2):   reg_dec  =  P6DIR_D  & {256{P6_EN[0]}};
    (P6SEL /2):   reg_dec  =  P6SEL_D  & {256{P6_EN[0]}};
    default   :   reg_dec  =  {256{1'b0}};
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

// P1IN Register
//---------------
reg  [7:0] p1in_s;
reg  [7:0] p1in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p1in_s <=  8'h00;
       p1in   <=  8'h00;
    end
  else
    begin
       p1in_s <=  p1_din & P1_EN_MSK;
       p1in   <=  p1in_s & P1_EN_MSK;
    end


// P1OUT Register
//----------------
reg  [7:0] p1out;

wire       p1out_wr  = P1OUT[0] ? reg_hi_wr[P1OUT/2] : reg_lo_wr[P1OUT/2];
wire [7:0] p1out_nxt = P1OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p1out <=  8'h00;
  else if (p1out_wr)  p1out <=  p1out_nxt & P1_EN_MSK;

assign p1_dout = p1out;


// P1DIR Register
//----------------
reg  [7:0] p1dir;

wire       p1dir_wr  = P1DIR[0] ? reg_hi_wr[P1DIR/2] : reg_lo_wr[P1DIR/2];
wire [7:0] p1dir_nxt = P1DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p1dir <=  8'h00;
  else if (p1dir_wr)  p1dir <=  p1dir_nxt & P1_EN_MSK;

assign p1_dout_en = p1dir;

   
// P1IFG Register
//----------------
reg  [7:0] p1ifg;

wire       p1ifg_wr  = P1IFG[0] ? reg_hi_wr[P1IFG/2] : reg_lo_wr[P1IFG/2];
wire [7:0] p1ifg_nxt = P1IFG[0] ? per_din[15:8]      : per_din[7:0];
wire [7:0] p1ifg_set;
       
always @ (posedge mclk or posedge puc)
  if (puc)            p1ifg <=  8'h00;
  else if (p1ifg_wr)  p1ifg <=  (p1ifg_nxt | p1ifg_set) & P1_EN_MSK;
  else                p1ifg <=  (p1ifg     | p1ifg_set) & P1_EN_MSK;

// P1IES Register
//----------------
reg  [7:0] p1ies;

wire       p1ies_wr  = P1IES[0] ? reg_hi_wr[P1IES/2] : reg_lo_wr[P1IES/2];
wire [7:0] p1ies_nxt = P1IES[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p1ies <=  8'h00;
  else if (p1ies_wr)  p1ies <=  p1ies_nxt & P1_EN_MSK;

   
// P1IE Register
//----------------
reg  [7:0] p1ie;

wire       p1ie_wr  = P1IE[0] ? reg_hi_wr[P1IE/2] : reg_lo_wr[P1IE/2];
wire [7:0] p1ie_nxt = P1IE[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p1ie <=  8'h00;
  else if (p1ie_wr)  p1ie <=  p1ie_nxt & P1_EN_MSK;


// P1SEL Register
//----------------
reg  [7:0] p1sel;

wire       p1sel_wr  = P1SEL[0] ? reg_hi_wr[P1SEL/2] : reg_lo_wr[P1SEL/2];
wire [7:0] p1sel_nxt = P1SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p1sel <=  8'h00;
  else if (p1sel_wr) p1sel <=  p1sel_nxt & P1_EN_MSK;

assign p1_sel = p1sel;

   
// P2IN Register
//---------------
reg  [7:0] p2in_s;
reg  [7:0] p2in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p2in_s <=  8'h00;
       p2in   <=  8'h00;
    end
  else
    begin
       p2in_s <=  p2_din & P2_EN_MSK;
       p2in   <=  p2in_s & P2_EN_MSK;
    end


// P2OUT Register
//----------------
reg  [7:0] p2out;

wire       p2out_wr  = P2OUT[0] ? reg_hi_wr[P2OUT/2] : reg_lo_wr[P2OUT/2];
wire [7:0] p2out_nxt = P2OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p2out <=  8'h00;
  else if (p2out_wr)  p2out <=  p2out_nxt & P2_EN_MSK;

assign p2_dout = p2out;


// P2DIR Register
//----------------
reg  [7:0] p2dir;

wire       p2dir_wr  = P2DIR[0] ? reg_hi_wr[P2DIR/2] : reg_lo_wr[P2DIR/2];
wire [7:0] p2dir_nxt = P2DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p2dir <=  8'h00;
  else if (p2dir_wr)  p2dir <=  p2dir_nxt & P2_EN_MSK;

assign p2_dout_en = p2dir;

   
// P2IFG Register
//----------------
reg  [7:0] p2ifg;

wire       p2ifg_wr  = P2IFG[0] ? reg_hi_wr[P2IFG/2] : reg_lo_wr[P2IFG/2];
wire [7:0] p2ifg_nxt = P2IFG[0] ? per_din[15:8]      : per_din[7:0];
wire [7:0] p2ifg_set;

always @ (posedge mclk or posedge puc)
  if (puc)            p2ifg <=  8'h00;
  else if (p2ifg_wr)  p2ifg <=  (p2ifg_nxt | p2ifg_set) & P2_EN_MSK;
  else                p2ifg <=  (p2ifg     | p2ifg_set) & P2_EN_MSK;

   
// P2IES Register
//----------------
reg  [7:0] p2ies;

wire       p2ies_wr  = P2IES[0] ? reg_hi_wr[P2IES/2] : reg_lo_wr[P2IES/2];
wire [7:0] p2ies_nxt = P2IES[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p2ies <=  8'h00;
  else if (p2ies_wr)  p2ies <=  p2ies_nxt & P2_EN_MSK;

   
// P2IE Register
//----------------
reg  [7:0] p2ie;

wire       p2ie_wr  = P2IE[0] ? reg_hi_wr[P2IE/2] : reg_lo_wr[P2IE/2];
wire [7:0] p2ie_nxt = P2IE[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p2ie <=  8'h00;
  else if (p2ie_wr)  p2ie <=  p2ie_nxt & P2_EN_MSK;

   
// P2SEL Register
//----------------
reg  [7:0] p2sel;

wire       p2sel_wr  = P2SEL[0] ? reg_hi_wr[P2SEL/2] : reg_lo_wr[P2SEL/2];
wire [7:0] p2sel_nxt = P2SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p2sel <=  8'h00;
  else if (p2sel_wr) p2sel <=  p2sel_nxt & P2_EN_MSK;

assign p2_sel = p2sel;

   
// P3IN Register
//---------------
reg  [7:0] p3in_s;
reg  [7:0] p3in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p3in_s <=  8'h00;
       p3in   <=  8'h00;
    end
  else
    begin
       p3in_s <=  p3_din & P3_EN_MSK;
       p3in   <=  p3in_s & P3_EN_MSK;
    end


// P3OUT Register
//----------------
reg  [7:0] p3out;

wire       p3out_wr  = P3OUT[0] ? reg_hi_wr[P3OUT/2] : reg_lo_wr[P3OUT/2];
wire [7:0] p3out_nxt = P3OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p3out <=  8'h00;
  else if (p3out_wr)  p3out <=  p3out_nxt & P3_EN_MSK;

assign p3_dout = p3out;


// P3DIR Register
//----------------
reg  [7:0] p3dir;

wire       p3dir_wr  = P3DIR[0] ? reg_hi_wr[P3DIR/2] : reg_lo_wr[P3DIR/2];
wire [7:0] p3dir_nxt = P3DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p3dir <=  8'h00;
  else if (p3dir_wr)  p3dir <=  p3dir_nxt & P3_EN_MSK;

assign p3_dout_en = p3dir;


// P3SEL Register
//----------------
reg  [7:0] p3sel;

wire       p3sel_wr  = P3SEL[0] ? reg_hi_wr[P3SEL/2] : reg_lo_wr[P3SEL/2];
wire [7:0] p3sel_nxt = P3SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p3sel <=  8'h00;
  else if (p3sel_wr) p3sel <=  p3sel_nxt & P3_EN_MSK;

assign p3_sel = p3sel;

   
// P4IN Register
//---------------
reg  [7:0] p4in_s;
reg  [7:0] p4in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p4in_s <=  8'h00;
       p4in   <=  8'h00;
    end
  else
    begin
       p4in_s <=  p4_din & P4_EN_MSK;
       p4in   <=  p4in_s & P4_EN_MSK;
    end


// P4OUT Register
//----------------
reg  [7:0] p4out;

wire       p4out_wr  = P4OUT[0] ? reg_hi_wr[P4OUT/2] : reg_lo_wr[P4OUT/2];
wire [7:0] p4out_nxt = P4OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p4out <=  8'h00;
  else if (p4out_wr)  p4out <=  p4out_nxt & P4_EN_MSK;

assign p4_dout = p4out;


// P4DIR Register
//----------------
reg  [7:0] p4dir;

wire       p4dir_wr  = P4DIR[0] ? reg_hi_wr[P4DIR/2] : reg_lo_wr[P4DIR/2];
wire [7:0] p4dir_nxt = P4DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p4dir <=  8'h00;
  else if (p4dir_wr)  p4dir <=  p4dir_nxt & P4_EN_MSK;

assign p4_dout_en = p4dir;


// P4SEL Register
//----------------
reg  [7:0] p4sel;

wire       p4sel_wr  = P4SEL[0] ? reg_hi_wr[P4SEL/2] : reg_lo_wr[P4SEL/2];
wire [7:0] p4sel_nxt = P4SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p4sel <=  8'h00;
  else if (p4sel_wr) p4sel <=  p4sel_nxt & P4_EN_MSK;

assign p4_sel = p4sel;

   
// P5IN Register
//---------------
reg  [7:0] p5in_s;
reg  [7:0] p5in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p5in_s <=  8'h00;
       p5in   <=  8'h00;
    end
  else
    begin
       p5in_s <=  p5_din & P5_EN_MSK;
       p5in   <=  p5in_s & P5_EN_MSK;
    end


// P5OUT Register
//----------------
reg  [7:0] p5out;

wire       p5out_wr  = P5OUT[0] ? reg_hi_wr[P5OUT/2] : reg_lo_wr[P5OUT/2];
wire [7:0] p5out_nxt = P5OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p5out <=  8'h00;
  else if (p5out_wr)  p5out <=  p5out_nxt & P5_EN_MSK;

assign p5_dout = p5out;


// P5DIR Register
//----------------
reg  [7:0] p5dir;

wire       p5dir_wr  = P5DIR[0] ? reg_hi_wr[P5DIR/2] : reg_lo_wr[P5DIR/2];
wire [7:0] p5dir_nxt = P5DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p5dir <=  8'h00;
  else if (p5dir_wr)  p5dir <=  p5dir_nxt & P5_EN_MSK;

assign p5_dout_en = p5dir;

   
// P5SEL Register
//----------------
reg  [7:0] p5sel;

wire       p5sel_wr  = P5SEL[0] ? reg_hi_wr[P5SEL/2] : reg_lo_wr[P5SEL/2];
wire [7:0] p5sel_nxt = P5SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p5sel <=  8'h00;
  else if (p5sel_wr) p5sel <=  p5sel_nxt & P5_EN_MSK;

assign p5_sel = p5sel;

   
// P6IN Register
//---------------
reg  [7:0] p6in_s;
reg  [7:0] p6in;

always @ (posedge mclk or posedge puc)
  if (puc)
    begin
       p6in_s <=  8'h00;
       p6in   <=  8'h00;
    end
  else
    begin
       p6in_s <=  p6_din & P6_EN_MSK;
       p6in   <=  p6in_s & P6_EN_MSK;
    end


// P6OUT Register
//----------------
reg  [7:0] p6out;

wire       p6out_wr  = P6OUT[0] ? reg_hi_wr[P6OUT/2] : reg_lo_wr[P6OUT/2];
wire [7:0] p6out_nxt = P6OUT[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p6out <=  8'h00;
  else if (p6out_wr)  p6out <=  p6out_nxt & P6_EN_MSK;

assign p6_dout = p6out;


// P6DIR Register
//----------------
reg  [7:0] p6dir;

wire       p6dir_wr  = P6DIR[0] ? reg_hi_wr[P6DIR/2] : reg_lo_wr[P6DIR/2];
wire [7:0] p6dir_nxt = P6DIR[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)            p6dir <=  8'h00;
  else if (p6dir_wr)  p6dir <=  p6dir_nxt & P6_EN_MSK;

assign p6_dout_en = p6dir;

   
// P6SEL Register
//----------------
reg  [7:0] p6sel;

wire       p6sel_wr  = P6SEL[0] ? reg_hi_wr[P6SEL/2] : reg_lo_wr[P6SEL/2];
wire [7:0] p6sel_nxt = P6SEL[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc)
  if (puc)           p6sel <=  8'h00;
  else if (p6sel_wr) p6sel <=  p6sel_nxt & P6_EN_MSK;

assign p6_sel = p6sel;

   

//============================================================================
// 4) INTERRUPT GENERATION
//============================================================================

// Port 1 interrupt
//------------------

// Delay input
reg    [7:0] p1in_dly;
always @ (posedge mclk or posedge puc)
  if (puc)      p1in_dly <=  8'h00;
  else          p1in_dly <=  p1in & P1_EN_MSK;    

// Edge detection
wire   [7:0] p1in_re   =   p1in & ~p1in_dly;
wire   [7:0] p1in_fe   =  ~p1in &  p1in_dly;

// Set interrupt flag
assign       p1ifg_set = {p1ies[7] ? p1in_fe[7] : p1in_re[7],
                          p1ies[6] ? p1in_fe[6] : p1in_re[6],
                          p1ies[5] ? p1in_fe[5] : p1in_re[5],
                          p1ies[4] ? p1in_fe[4] : p1in_re[4],
                          p1ies[3] ? p1in_fe[3] : p1in_re[3],
                          p1ies[2] ? p1in_fe[2] : p1in_re[2],
                          p1ies[1] ? p1in_fe[1] : p1in_re[1],
                          p1ies[0] ? p1in_fe[0] : p1in_re[0]} & P1_EN_MSK;

// Generate CPU interrupt
assign       irq_port1 = |(p1ie & p1ifg) & P1_EN[0];


// Port 1 interrupt
//------------------

// Delay input
reg    [7:0] p2in_dly;
always @ (posedge mclk or posedge puc)
  if (puc)      p2in_dly <=  8'h00;
  else          p2in_dly <=  p2in & P2_EN_MSK;    

// Edge detection
wire   [7:0] p2in_re   =   p2in & ~p2in_dly;
wire   [7:0] p2in_fe   =  ~p2in &  p2in_dly;

// Set interrupt flag
assign       p2ifg_set = {p2ies[7] ? p2in_fe[7] : p2in_re[7],
                          p2ies[6] ? p2in_fe[6] : p2in_re[6],
                          p2ies[5] ? p2in_fe[5] : p2in_re[5],
                          p2ies[4] ? p2in_fe[4] : p2in_re[4],
                          p2ies[3] ? p2in_fe[3] : p2in_re[3],
                          p2ies[2] ? p2in_fe[2] : p2in_re[2],
                          p2ies[1] ? p2in_fe[1] : p2in_re[1],
                          p2ies[0] ? p2in_fe[0] : p2in_re[0]} & P2_EN_MSK;

// Generate CPU interrupt
assign      irq_port2 = |(p2ie & p2ifg) & P2_EN[0];


//============================================================================
// 5) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] p1in_rd   = {8'h00, (p1in  & {8{reg_rd[P1IN/2]}})}  << (8 & {4{P1IN[0]}});
wire [15:0] p1out_rd  = {8'h00, (p1out & {8{reg_rd[P1OUT/2]}})} << (8 & {4{P1OUT[0]}});
wire [15:0] p1dir_rd  = {8'h00, (p1dir & {8{reg_rd[P1DIR/2]}})} << (8 & {4{P1DIR[0]}});
wire [15:0] p1ifg_rd  = {8'h00, (p1ifg & {8{reg_rd[P1IFG/2]}})} << (8 & {4{P1IFG[0]}});
wire [15:0] p1ies_rd  = {8'h00, (p1ies & {8{reg_rd[P1IES/2]}})} << (8 & {4{P1IES[0]}});
wire [15:0] p1ie_rd   = {8'h00, (p1ie  & {8{reg_rd[P1IE/2]}})}  << (8 & {4{P1IE[0]}});
wire [15:0] p1sel_rd  = {8'h00, (p1sel & {8{reg_rd[P1SEL/2]}})} << (8 & {4{P1SEL[0]}});
wire [15:0] p2in_rd   = {8'h00, (p2in  & {8{reg_rd[P2IN/2]}})}  << (8 & {4{P2IN[0]}});
wire [15:0] p2out_rd  = {8'h00, (p2out & {8{reg_rd[P2OUT/2]}})} << (8 & {4{P2OUT[0]}});
wire [15:0] p2dir_rd  = {8'h00, (p2dir & {8{reg_rd[P2DIR/2]}})} << (8 & {4{P2DIR[0]}});
wire [15:0] p2ifg_rd  = {8'h00, (p2ifg & {8{reg_rd[P2IFG/2]}})} << (8 & {4{P2IFG[0]}});
wire [15:0] p2ies_rd  = {8'h00, (p2ies & {8{reg_rd[P2IES/2]}})} << (8 & {4{P2IES[0]}});
wire [15:0] p2ie_rd   = {8'h00, (p2ie  & {8{reg_rd[P2IE/2]}})}  << (8 & {4{P2IE[0]}});
wire [15:0] p2sel_rd  = {8'h00, (p2sel & {8{reg_rd[P2SEL/2]}})} << (8 & {4{P2SEL[0]}});
wire [15:0] p3in_rd   = {8'h00, (p3in  & {8{reg_rd[P3IN/2]}})}  << (8 & {4{P3IN[0]}});
wire [15:0] p3out_rd  = {8'h00, (p3out & {8{reg_rd[P3OUT/2]}})} << (8 & {4{P3OUT[0]}});
wire [15:0] p3dir_rd  = {8'h00, (p3dir & {8{reg_rd[P3DIR/2]}})} << (8 & {4{P3DIR[0]}});
wire [15:0] p3sel_rd  = {8'h00, (p3sel & {8{reg_rd[P3SEL/2]}})} << (8 & {4{P3SEL[0]}});
wire [15:0] p4in_rd   = {8'h00, (p4in  & {8{reg_rd[P4IN/2]}})}  << (8 & {4{P4IN[0]}});
wire [15:0] p4out_rd  = {8'h00, (p4out & {8{reg_rd[P4OUT/2]}})} << (8 & {4{P4OUT[0]}});
wire [15:0] p4dir_rd  = {8'h00, (p4dir & {8{reg_rd[P4DIR/2]}})} << (8 & {4{P4DIR[0]}});
wire [15:0] p4sel_rd  = {8'h00, (p4sel & {8{reg_rd[P4SEL/2]}})} << (8 & {4{P4SEL[0]}});
wire [15:0] p5in_rd   = {8'h00, (p5in  & {8{reg_rd[P5IN/2]}})}  << (8 & {4{P5IN[0]}});
wire [15:0] p5out_rd  = {8'h00, (p5out & {8{reg_rd[P5OUT/2]}})} << (8 & {4{P5OUT[0]}});
wire [15:0] p5dir_rd  = {8'h00, (p5dir & {8{reg_rd[P5DIR/2]}})} << (8 & {4{P5DIR[0]}});
wire [15:0] p5sel_rd  = {8'h00, (p5sel & {8{reg_rd[P5SEL/2]}})} << (8 & {4{P5SEL[0]}});
wire [15:0] p6in_rd   = {8'h00, (p6in  & {8{reg_rd[P6IN/2]}})}  << (8 & {4{P6IN[0]}});
wire [15:0] p6out_rd  = {8'h00, (p6out & {8{reg_rd[P6OUT/2]}})} << (8 & {4{P6OUT[0]}});
wire [15:0] p6dir_rd  = {8'h00, (p6dir & {8{reg_rd[P6DIR/2]}})} << (8 & {4{P6DIR[0]}});
wire [15:0] p6sel_rd  = {8'h00, (p6sel & {8{reg_rd[P6SEL/2]}})} << (8 & {4{P6SEL[0]}});

wire [15:0] per_dout  =  p1in_rd   |
                         p1out_rd  |
                         p1dir_rd  |
                         p1ifg_rd  |
                         p1ies_rd  |
                         p1ie_rd   |
                         p1sel_rd  |
                         p2in_rd   |
                         p2out_rd  |
                         p2dir_rd  |
                         p2ifg_rd  |
                         p2ies_rd  |
                         p2ie_rd   |
                         p2sel_rd  |
                         p3in_rd   |
                         p3out_rd  |
                         p3dir_rd  |
                         p3sel_rd  |
                         p4in_rd   |
                         p4out_rd  |
                         p4dir_rd  |
                         p4sel_rd  |
                         p5in_rd   |
                         p5out_rd  |
                         p5dir_rd  |
                         p5sel_rd  |
                         p6in_rd   |
                         p6out_rd  |
                         p6dir_rd  |
                         p6sel_rd;

endmodule // omsp_gpio
