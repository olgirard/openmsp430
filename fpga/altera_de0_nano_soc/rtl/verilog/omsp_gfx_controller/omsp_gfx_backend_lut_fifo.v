//----------------------------------------------------------------------------
// Copyright (C) 2015 Authors
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
// *File Name: omsp_gfx_backend_lut_fifo.v
//
// *Module Description:
//                      Mini-cache memory for the LUT memory accesses.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------
`ifdef OMSP_GFX_CONTROLLER_NO_INCLUDE
`else
`include "omsp_gfx_controller_defines.v"
`endif

module  omsp_gfx_backend_lut_fifo (

// OUTPUTs
    frame_data_request_o,                        // Request for next frame data

    refresh_data_o,                              // Display Refresh data
    refresh_data_ready_o,                        // Display Refresh data ready

    lut_ram_addr_o,                              // LUT-RAM address
    lut_ram_cen_o,                               // LUT-RAM enable (active low)

// INPUTs
    mclk,                                        // Main system clock
    puc_rst,                                     // Main system reset

    frame_data_i,                                // Frame data
    frame_data_needs_lut_i,                      // Frame data needs LUT
    frame_data_ready_i,                          // Frame data ready

    refresh_active_i,                            // Display refresh on going
    refresh_data_request_i,                      // Request for next refresh data
    refresh_lut_select_i,                        // Refresh LUT bank selection

    lut_ram_dout_i,                              // LUT-RAM data output
    lut_ram_dout_rdy_nxt_i                       // LUT-RAM data output ready during next cycle
);

// OUTPUTs
//=========
output               frame_data_request_o;       // Request for next frame data

output        [15:0] refresh_data_o;             // Display Refresh data
output               refresh_data_ready_o;       // Display Refresh data ready

output [`LRAM_MSB:0] lut_ram_addr_o;             // LUT-RAM address
output               lut_ram_cen_o;              // LUT-RAM enable (active low)

// INPUTs
//=========
input                mclk;                       // Main system clock
input                puc_rst;                    // Main system reset

input         [15:0] frame_data_i;               // Frame data
input                frame_data_needs_lut_i;     // Frame data needs LUT
input                frame_data_ready_i;         // Frame data ready

input                refresh_active_i;           // Display refresh on going
input                refresh_data_request_i;     // Request for next refresh data
input                refresh_lut_select_i;       // Refresh LUT bank selection

input         [15:0] lut_ram_dout_i;             // LUT-RAM data output
input                lut_ram_dout_rdy_nxt_i;     // LUT-RAM data output ready during next cycle


//=============================================================================
// 1)  WIRE, REGISTERS AND PARAMETER DECLARATION
//=============================================================================

// State machine registers
reg    [1:0] lut_state;
reg    [1:0] lut_state_nxt;

// State definition
parameter    STATE_IDLE        =   0,
             STATE_FRAME_DATA  =   1,
             STATE_LUT_DATA    =   2,
             STATE_HOLD        =   3;

// Some parameter(s)
parameter    FIFO_EMPTY        =  3'h0,
             FIFO_FULL         =  3'h5;

// Others
reg          lut_ram_dout_ready;
reg    [2:0] fifo_counter;
wire   [2:0] fifo_counter_nxt;


//============================================================================
// 2) STATE MACHINE
//============================================================================

//--------------------------------
// States Transitions
//--------------------------------
always @(lut_state or refresh_active_i or frame_data_needs_lut_i or frame_data_ready_i or lut_ram_dout_rdy_nxt_i or fifo_counter_nxt)
    case(lut_state)

      STATE_IDLE           :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       : STATE_FRAME_DATA ;

      STATE_FRAME_DATA     :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       :
                                              ~frame_data_ready_i           ? STATE_FRAME_DATA :
                                               frame_data_needs_lut_i       ? STATE_LUT_DATA   : STATE_HOLD       ;

      STATE_LUT_DATA       :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       :
                                               lut_ram_dout_rdy_nxt_i       ? STATE_HOLD       : STATE_LUT_DATA   ;

      STATE_HOLD           :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       :
                                              (fifo_counter_nxt!=FIFO_FULL) ? STATE_FRAME_DATA : STATE_HOLD       ;

    // pragma coverage off
      default              :  lut_state_nxt =  STATE_IDLE;
    // pragma coverage on
    endcase

//--------------------------------
// State machine
//--------------------------------
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) lut_state  <= STATE_IDLE;
  else         lut_state  <= lut_state_nxt;


// Request for the next frame data
assign frame_data_request_o = (lut_state == STATE_FRAME_DATA);


//============================================================================
// 3) LUT MEMORY INTERFACE
//============================================================================

//--------------------------------
// Enable
//--------------------------------

assign lut_ram_cen_o  = ~(lut_state == STATE_LUT_DATA);

//--------------------------------
// Address
//--------------------------------
// Mask with chip enable to save power

`ifdef WITH_EXTRA_LUT_BANK
assign lut_ram_addr_o = {refresh_lut_select_i, frame_data_i[7:0]} & {9{~lut_ram_cen_o}};
`else
assign lut_ram_addr_o = frame_data_i[7:0] & {8{~lut_ram_cen_o}};
`endif

//--------------------------------
// Data Ready
//--------------------------------
// When filling the FIFO, the data is available on the bus
// one cycle after the rdy_nxt signal
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_dout_ready  <=  1'b0;
  else         lut_ram_dout_ready  <=  frame_data_needs_lut_i ? lut_ram_dout_rdy_nxt_i :
                                                                (frame_data_ready_i & (lut_state == STATE_FRAME_DATA));


//============================================================================
// 4) FIFO COUNTER
//============================================================================

// Control signals
wire      fifo_push =  lut_ram_dout_ready     & (fifo_counter != FIFO_FULL);
wire      fifo_pop  =  refresh_data_request_i & (fifo_counter != FIFO_EMPTY);

// Fifo counter
assign fifo_counter_nxt = ~refresh_active_i      ?  FIFO_EMPTY          : // Initialize
                          (fifo_push & fifo_pop) ?  fifo_counter        : // Keep value (pop & push at the same time)
                           fifo_push             ?  fifo_counter + 3'h1 : // Push
                           fifo_pop              ?  fifo_counter - 3'h1 : // Pop
			                            fifo_counter;         // Hold

always @(posedge mclk or posedge puc_rst)
  if (puc_rst) fifo_counter <= FIFO_EMPTY;
  else         fifo_counter <= fifo_counter_nxt;


//============================================================================
// 5) FIFO MEMORY & RD/WR POINTERS
//============================================================================

// Write pointer
reg [2:0] wr_ptr;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                    wr_ptr  <=  3'h0;
  else if (~refresh_active_i)     wr_ptr  <=  3'h0;
  else if (fifo_push)
    begin
       if (wr_ptr==(FIFO_FULL-1)) wr_ptr  <=  3'h0;
       else                       wr_ptr  <=  wr_ptr + 3'h1;
    end

// Memory
reg [15:0] fifo_mem [0:4];
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       fifo_mem[0]	<=  16'h0000;
       fifo_mem[1]	<=  16'h0000;
       fifo_mem[2]	<=  16'h0000;
       fifo_mem[3]	<=  16'h0000;
       fifo_mem[4]	<=  16'h0000;
    end
  else if (fifo_push)
    begin
       fifo_mem[wr_ptr] <=  frame_data_needs_lut_i ? lut_ram_dout_i : frame_data_i;
    end

// Read pointer
reg [2:0] rd_ptr;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                    rd_ptr  <=  3'h0;
  else if (~refresh_active_i)     rd_ptr  <=  3'h0;
  else if (fifo_pop)
    begin
       if (rd_ptr==(FIFO_FULL-1)) rd_ptr  <=  3'h0;
       else                       rd_ptr  <=  rd_ptr + 3'h1;
    end

//============================================================================
// 6) REFRESH_DATA
//============================================================================

// Refresh Data is ready
reg        refresh_data_ready_o;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                refresh_data_ready_o <=  1'h0;
  else if (~refresh_active_i) refresh_data_ready_o <=  1'h0;
  else                        refresh_data_ready_o <=  fifo_pop;

// Refresh Data
reg [15:0] refresh_data_o;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                refresh_data_o <= 16'h0000;
  else if (fifo_pop)          refresh_data_o <= fifo_mem[rd_ptr];


endmodule // omsp_gfx_backend_lut_fifo

`ifdef OMSP_GFX_CONTROLLER_NO_INCLUDE
`else
`include "omsp_gfx_controller_undefines.v"
`endif
