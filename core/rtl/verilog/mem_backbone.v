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
// *File Name: mem_backbone.v
// 
// *Module Description:
//                       Memory interface backbone (decoder + arbiter)
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
`timescale 1ns / 100ps

module  mem_backbone (

// OUTPUTs
    dbg_mem_din,                    // Debug unit Memory data input
    eu_mdb_in,                      // Execution Unit Memory data bus input
    fe_mdb_in,                      // Frontend Memory data bus input
    fe_rom_wait,                    // Frontend wait for ROM
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_wen,                        // Peripheral write enable (high active)
    per_en,                         // Peripheral enable (high active)
    ram_addr,                       // RAM address
    ram_cen,                        // RAM chip enable (low active)
    ram_din,                        // RAM data input
    ram_wen,                        // RAM write enable (low active)
    rom_addr,                       // ROM address
    rom_cen,                        // ROM chip enable (low active)
    rom_din_dbg,                    // ROM data input --FOR DEBUG INTERFACE--
    rom_wen_dbg,                    // ROM write enable (low active) --FOR DBG IF--

// INPUTs
    dbg_halt_st,                    // Halt/Run status from CPU
    dbg_mem_addr,                   // Debug address for rd/wr access
    dbg_mem_dout,                   // Debug unit data output
    dbg_mem_en,                     // Debug unit memory enable
    dbg_mem_wr,                     // Debug unit memory write
    eu_mab,                         // Execution Unit Memory address bus
    eu_mb_en,                       // Execution Unit Memory bus enable
    eu_mb_wr,                       // Execution Unit Memory bus write transfer
    eu_mdb_out,                     // Execution Unit Memory data bus output
    fe_mab,                         // Frontend Memory address bus
    fe_mb_en,                       // Frontend Memory bus enable
    mclk,                           // Main system clock
    per_dout,                       // Peripheral data output
    puc,                            // Main system reset
    ram_dout,                       // RAM data output
    rom_dout                        // ROM data output
);

// OUTPUTs
//=========
output       [15:0] dbg_mem_din;    // Debug unit Memory data input
output       [15:0] eu_mdb_in;      // Execution Unit Memory data bus input
output       [15:0] fe_mdb_in;      // Frontend Memory data bus input
output              fe_rom_wait;    // Frontend wait for ROM
output        [7:0] per_addr;       // Peripheral address
output       [15:0] per_din;        // Peripheral data input
output        [1:0] per_wen;        // Peripheral write enable (high active)
output              per_en;         // Peripheral enable (high active)
output [`RAM_MSB:0] ram_addr;       // RAM address
output              ram_cen;        // RAM chip enable (low active)
output       [15:0] ram_din;        // RAM data input
output        [1:0] ram_wen;        // RAM write enable (low active)
output [`ROM_MSB:0] rom_addr;       // ROM address
output              rom_cen;        // ROM chip enable (low active)
output       [15:0] rom_din_dbg;    // ROM data input --FOR DEBUG INTERFACE--
output        [1:0] rom_wen_dbg;    // ROM write enable (low active) --FOR DBG IF--

// INPUTs
//=========
input               dbg_halt_st;    // Halt/Run status from CPU
input        [15:0] dbg_mem_addr;   // Debug address for rd/wr access
input        [15:0] dbg_mem_dout;   // Debug unit data output
input               dbg_mem_en;     // Debug unit memory enable
input         [1:0] dbg_mem_wr;     // Debug unit memory write
input        [14:0] eu_mab;         // Execution Unit Memory address bus
input               eu_mb_en;       // Execution Unit Memory bus enable
input         [1:0] eu_mb_wr;       // Execution Unit Memory bus write transfer
input        [15:0] eu_mdb_out;     // Execution Unit Memory data bus output
input        [14:0] fe_mab;         // Frontend Memory address bus
input               fe_mb_en;       // Frontend Memory bus enable
input               mclk;           // Main system clock
input        [15:0] per_dout;       // Peripheral data output
input               puc;            // Main system reset
input        [15:0] ram_dout;       // RAM data output
input        [15:0] rom_dout;       // ROM data output


//=============================================================================
// 1)  DECODER
//=============================================================================

// RAM Interface
//------------------

// Execution unit access
wire              eu_ram_cen    = ~(eu_mb_en & (eu_mab>=(`RAM_BASE>>1)) &
                                               (eu_mab<((`RAM_BASE+`RAM_SIZE)>>1)));
wire       [15:0] eu_ram_addr   = eu_mab-(`RAM_BASE>>1);

// Debug interface access
wire              dbg_ram_cen   = ~(dbg_mem_en & (dbg_mem_addr[15:1]>=(`RAM_BASE>>1)) &
                                                 (dbg_mem_addr[15:1]<((`RAM_BASE+`RAM_SIZE)>>1)));
wire       [15:0] dbg_ram_addr  = dbg_mem_addr[15:1]-(`RAM_BASE>>1);

   
// RAM Interface
wire [`RAM_MSB:0] ram_addr      = ~dbg_ram_cen ? dbg_ram_addr[`RAM_MSB:0] : eu_ram_addr[`RAM_MSB:0];
wire              ram_cen       = dbg_ram_cen & eu_ram_cen;
wire        [1:0] ram_wen       = ~(dbg_mem_wr | eu_mb_wr);
wire       [15:0] ram_din       = ~dbg_ram_cen ? dbg_mem_dout : eu_mdb_out;


// ROM Interface
//------------------
parameter         ROM_OFFSET    = (16'hFFFF-`ROM_SIZE+1);

// Execution unit access (only read access are accepted)
wire              eu_rom_cen    = ~(eu_mb_en & ~|eu_mb_wr & (eu_mab>=(ROM_OFFSET>>1)));
wire       [15:0] eu_rom_addr   = eu_mab-(ROM_OFFSET>>1);

// Front-end access
wire              fe_rom_cen    = ~(fe_mb_en & (fe_mab>=(ROM_OFFSET>>1)));
wire       [15:0] fe_rom_addr   = fe_mab-(ROM_OFFSET>>1);

// Debug interface access
wire              dbg_rom_cen   = ~(dbg_mem_en & (dbg_mem_addr[15:1]>=(ROM_OFFSET>>1)));
wire       [15:0] dbg_rom_addr  = dbg_mem_addr[15:1]-(ROM_OFFSET>>1);

   
// ROM Interface (Execution unit has priority)
wire [`ROM_MSB:0] rom_addr      = ~dbg_rom_cen ? dbg_rom_addr[`ROM_MSB:0] :
                                  ~eu_rom_cen  ? eu_rom_addr[`ROM_MSB:0]  : fe_rom_addr[`ROM_MSB:0];
wire              rom_cen       = fe_rom_cen & eu_rom_cen & dbg_rom_cen;
wire        [1:0] rom_wen_dbg   = ~dbg_mem_wr;
wire       [15:0] rom_din_dbg   =  dbg_mem_dout;

wire              fe_rom_wait   = (~fe_rom_cen & ~eu_rom_cen);


// Peripherals
//--------------------
wire         dbg_per_en    =  dbg_mem_en & (dbg_mem_addr[15:9]==7'h00);
wire         eu_per_en     =  eu_mb_en   & (eu_mab[14:8]==7'h00);

wire   [7:0] per_addr      =  dbg_mem_en ? dbg_mem_addr[8:1] : eu_mab[7:0];
wire  [15:0] per_din       =  dbg_mem_en ? dbg_mem_dout      : eu_mdb_out;
wire   [1:0] per_wen       =  dbg_mem_en ? dbg_mem_wr        : eu_mb_wr;
wire         per_en        =  dbg_mem_en ? dbg_per_en        : eu_per_en;

reg   [15:0] per_dout_val;
always @ (posedge mclk or posedge puc)
  if (puc)      per_dout_val <= 16'h0000;
  else          per_dout_val <= per_dout;


// Frontend data Mux
//---------------------------------
// Whenever the frontend doesn't access the ROM,  backup the data

// Detect whenever the data should be backuped and restored
reg 	    fe_rom_cen_dly;
always @(posedge mclk or posedge puc)
  if (puc)     fe_rom_cen_dly <=  1'b0;
  else         fe_rom_cen_dly <=  fe_rom_cen;

wire fe_rom_save    = ( fe_rom_cen & ~fe_rom_cen_dly) & ~dbg_halt_st;
wire fe_rom_restore = (~fe_rom_cen &  fe_rom_cen_dly) |  dbg_halt_st;
   
reg  [15:0] rom_dout_bckup;
always @(posedge mclk or posedge puc)
  if (puc)              rom_dout_bckup     <=  16'h0000;
  else if (fe_rom_save) rom_dout_bckup     <=  rom_dout;

// Mux between the ROM data and the backup
reg         rom_dout_bckup_sel;
always @(posedge mclk or posedge puc)
  if (puc)                 rom_dout_bckup_sel <=  1'b0;
  else if (fe_rom_save)    rom_dout_bckup_sel <=  1'b1;
  else if (fe_rom_restore) rom_dout_bckup_sel <=  1'b0;
    
assign fe_mdb_in = rom_dout_bckup_sel ? rom_dout_bckup : rom_dout;


// Execution-Unit data Mux
//---------------------------------

// Select between peripherals, RAM and ROM
reg [1:0] eu_mdb_in_sel;
always @(posedge mclk or posedge puc)
  if (puc)  eu_mdb_in_sel <= 2'b00;
  else      eu_mdb_in_sel <= {~eu_rom_cen, per_en};

// Mux
assign      eu_mdb_in      = eu_mdb_in_sel[1] ? rom_dout     :
                             eu_mdb_in_sel[0] ? per_dout_val : ram_dout;

// Debug interface  data Mux
//---------------------------------

// Select between peripherals, RAM and ROM
reg [1:0] dbg_mem_din_sel;
always @(posedge mclk or posedge puc)
  if (puc)  dbg_mem_din_sel <= 2'b00;
  else      dbg_mem_din_sel <= {~dbg_rom_cen, dbg_per_en};

// Mux
assign      dbg_mem_din  = dbg_mem_din_sel[1] ? rom_dout     :
                           dbg_mem_din_sel[0] ? per_dout_val : ram_dout;

   
endmodule // mem_backbone




