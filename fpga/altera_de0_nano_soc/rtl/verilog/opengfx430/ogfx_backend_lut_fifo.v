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
// *File Name: ogfx_backend_lut_fifo.v
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
`ifdef OGFX_NO_INCLUDE
`else
`include "openGFX430_defines.v"
`endif

module  ogfx_backend_lut_fifo (

// OUTPUTs
    frame_data_request_o,                        // Request for next frame data

    refresh_data_o,                              // Display Refresh data
    refresh_data_ready_o,                        // Display Refresh data ready

`ifdef WITH_PROGRAMMABLE_LUT
    lut_ram_addr_o,                              // LUT-RAM address
    lut_ram_cen_o,                               // LUT-RAM enable (active low)
`endif

// INPUTs
    mclk,                                        // Main system clock
    puc_rst,                                     // Main system reset

    frame_data_i,                                // Frame data
    frame_data_ready_i,                          // Frame data ready

    gfx_mode_i,                                  // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

`ifdef WITH_PROGRAMMABLE_LUT
    lut_ram_dout_i,                              // LUT-RAM data output
    lut_ram_dout_rdy_nxt_i,                      // LUT-RAM data output ready during next cycle
`endif

    refresh_active_i,                            // Display refresh on going
    refresh_data_request_i,                      // Request for next refresh data
    refresh_lut_select_i                         // Refresh LUT bank selection
);

// OUTPUTs
//=========
output               frame_data_request_o;       // Request for next frame data

output        [15:0] refresh_data_o;             // Display Refresh data
output               refresh_data_ready_o;       // Display Refresh data ready

`ifdef WITH_PROGRAMMABLE_LUT
output [`LRAM_MSB:0] lut_ram_addr_o;             // LUT-RAM address
output               lut_ram_cen_o;              // LUT-RAM enable (active low)
`endif

// INPUTs
//=========
input                mclk;                       // Main system clock
input                puc_rst;                    // Main system reset

input         [15:0] frame_data_i;               // Frame data
input                frame_data_ready_i;         // Frame data ready

input          [2:0] gfx_mode_i;                 // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

`ifdef WITH_PROGRAMMABLE_LUT
input         [15:0] lut_ram_dout_i;             // LUT-RAM data output
input                lut_ram_dout_rdy_nxt_i;     // LUT-RAM data output ready during next cycle
`endif

input                refresh_active_i;           // Display refresh on going
input                refresh_data_request_i;     // Request for next refresh data
input          [1:0] refresh_lut_select_i;       // Refresh LUT bank selection


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

// Video modes decoding
wire         gfx_mode_1_bpp    =  (gfx_mode_i == 3'b000);
wire         gfx_mode_2_bpp    =  (gfx_mode_i == 3'b001);
wire         gfx_mode_4_bpp    =  (gfx_mode_i == 3'b010);
wire         gfx_mode_8_bpp    =  (gfx_mode_i == 3'b011);
wire         gfx_mode_16_bpp   = ~(gfx_mode_8_bpp | gfx_mode_4_bpp |
                                   gfx_mode_2_bpp | gfx_mode_1_bpp);

// Others
reg    [2:0] fifo_counter;
wire   [2:0] fifo_counter_nxt;


//============================================================================
// 2) HARD CODED LOOKUP TABLE
//============================================================================

wire  [15:0] lut_hw_data_1_bpp = ({5'b00000, 6'b000000, 5'b00000} & {16{frame_data_i[0]  ==1'b0   }}) |                            // 1 bpp:  Black
                                 ({5'b11111, 6'b111111, 5'b11111} & {16{frame_data_i[0]  ==1'b1   }}) ;                            //         White

wire  [15:0] lut_hw_data_2_bpp = ({5'b00000, 6'b000000, 5'b00000} & {16{frame_data_i[0]  ==2'b00  }}) |                            // 2 bpp:  Black
                                 ({5'b01000, 6'b010000, 5'b01000} & {16{frame_data_i[0]  ==2'b01  }}) |                            //         Dark Gray
                                 ({5'b11000, 6'b110000, 5'b11000} & {16{frame_data_i[0]  ==2'b10  }}) |                            //         Light Gray
                                 ({5'b11111, 6'b111111, 5'b11111} & {16{frame_data_i[0]  ==2'b11  }}) ;                            //         White

wire  [15:0] lut_hw_data_4_bpp = ({5'b00000, 6'b000000, 5'b00000} & {16{frame_data_i[3:0]==4'b0000}}) |                            // 4 bpp:  Black
                                 ({5'b00000, 6'b000000, 5'b10000} & {16{frame_data_i[3:0]==4'b0001}}) |                            //         Dark Blue
                                 ({5'b10000, 6'b000000, 5'b00000} & {16{frame_data_i[3:0]==4'b0010}}) |                            //         Dark Red
                                 ({5'b10000, 6'b000000, 5'b10000} & {16{frame_data_i[3:0]==4'b0011}}) |                            //         Dark Magenta
                                 ({5'b00000, 6'b100000, 5'b00000} & {16{frame_data_i[3:0]==4'b0100}}) |                            //         Dark Green
                                 ({5'b00000, 6'b100000, 5'b10000} & {16{frame_data_i[3:0]==4'b0101}}) |                            //         Dark Cyan
                                 ({5'b10000, 6'b100000, 5'b00000} & {16{frame_data_i[3:0]==4'b0110}}) |                            //         Dark Yellow
                                 ({5'b10000, 6'b100000, 5'b10000} & {16{frame_data_i[3:0]==4'b0111}}) |                            //         Gray
                                 ({5'b00000, 6'b000000, 5'b00000} & {16{frame_data_i[3:0]==4'b1000}}) |                            //         Black
                                 ({5'b00000, 6'b000000, 5'b11111} & {16{frame_data_i[3:0]==4'b1001}}) |                            //         Blue
                                 ({5'b11111, 6'b000000, 5'b00000} & {16{frame_data_i[3:0]==4'b1010}}) |                            //         Red
                                 ({5'b11111, 6'b000000, 5'b11111} & {16{frame_data_i[3:0]==4'b1011}}) |                            //         Magenta
                                 ({5'b00000, 6'b111111, 5'b00000} & {16{frame_data_i[3:0]==4'b1100}}) |                            //         Green
                                 ({5'b00000, 6'b111111, 5'b11111} & {16{frame_data_i[3:0]==4'b1101}}) |                            //         Cyan
                                 ({5'b11111, 6'b111111, 5'b00000} & {16{frame_data_i[3:0]==4'b1110}}) |                            //         Yellow
                                 ({5'b11111, 6'b111111, 5'b11111} & {16{frame_data_i[3:0]==4'b1111}});                             //         White

wire  [15:0] lut_hw_data_8_bpp = {frame_data_i[7],frame_data_i[6],frame_data_i[5],frame_data_i[5],frame_data_i[5],                 // 8 bpp:  R = D<7,6,5,5,5>
                                  frame_data_i[4],frame_data_i[3],frame_data_i[2],frame_data_i[2],frame_data_i[2],frame_data_i[2], //         G = D<4,3,2,2,2,2>
                                  frame_data_i[1],frame_data_i[0],frame_data_i[0],frame_data_i[0],frame_data_i[0]};                //         B = D<1,0,0,0,0>

wire  [15:0] lut_hw_data       = (lut_hw_data_1_bpp & {16{gfx_mode_1_bpp}}) |
	                         (lut_hw_data_2_bpp & {16{gfx_mode_2_bpp}}) |
	                         (lut_hw_data_4_bpp & {16{gfx_mode_4_bpp}}) |
	                         (lut_hw_data_8_bpp & {16{gfx_mode_8_bpp}});

wire         lut_hw_enabled    = ~gfx_mode_16_bpp   & ~refresh_lut_select_i[0];
wire         lut_sw_enabled    = ~gfx_mode_16_bpp   &  refresh_lut_select_i[0];


//============================================================================
// 3) STATE MACHINE
//============================================================================

//--------------------------------
// States Transitions
//--------------------------------
always @(lut_state or refresh_active_i or frame_data_ready_i     or
`ifdef WITH_PROGRAMMABLE_LUT
                      lut_sw_enabled   or lut_ram_dout_rdy_nxt_i or
`endif
                      fifo_counter_nxt)
    case(lut_state)

      STATE_IDLE           :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       : STATE_FRAME_DATA ;

      STATE_FRAME_DATA     :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       :
                                              ~frame_data_ready_i           ? STATE_FRAME_DATA :
`ifdef WITH_PROGRAMMABLE_LUT
                                               lut_sw_enabled               ? STATE_LUT_DATA   :
`endif
                                                                                                 STATE_HOLD       ;

`ifdef WITH_PROGRAMMABLE_LUT
      STATE_LUT_DATA       :  lut_state_nxt = ~refresh_active_i             ? STATE_IDLE       :
                                               lut_ram_dout_rdy_nxt_i       ? STATE_HOLD       : STATE_LUT_DATA   ;
`endif

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
// 4) LUT MEMORY INTERFACE
//============================================================================

//--------------------------------
// Enable
//--------------------------------
`ifdef WITH_PROGRAMMABLE_LUT
   assign lut_ram_cen_o  = ~(lut_state == STATE_LUT_DATA);
`endif

//--------------------------------
// Address
//--------------------------------
// Mask with chip enable to save power

`ifdef WITH_PROGRAMMABLE_LUT
  `ifdef WITH_EXTRA_LUT_BANK
    // Allow LUT bank switching only when the refresh is not on going
    reg refresh_lut_bank_select_sync;
    always @(posedge mclk or posedge puc_rst)
      if (puc_rst)                refresh_lut_bank_select_sync  <=  1'b0;
      else if (~refresh_active_i) refresh_lut_bank_select_sync  <=  refresh_lut_select_i[1];

    assign lut_ram_addr_o = {refresh_lut_bank_select_sync, frame_data_i[7:0]} & {9{~lut_ram_cen_o}};
  `else
    assign lut_ram_addr_o = frame_data_i[7:0] & {8{~lut_ram_cen_o}};
  `endif
`endif

//--------------------------------
// Data Ready
//--------------------------------
// When filling the FIFO, the data is available on the bus
// one cycle after the rdy_nxt signal
reg            lut_ram_dout_ready;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_dout_ready  <=  1'b0;
`ifdef WITH_PROGRAMMABLE_LUT
  else         lut_ram_dout_ready  <=  lut_sw_enabled ? lut_ram_dout_rdy_nxt_i :
                                                        (frame_data_ready_i & (lut_state == STATE_FRAME_DATA));
`else
  else         lut_ram_dout_ready  <=  (frame_data_ready_i & (lut_state == STATE_FRAME_DATA));
`endif


//============================================================================
// 5) FIFO COUNTER
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
// 6) FIFO MEMORY & RD/WR POINTERS
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
       fifo_mem[0]      <=  16'h0000;
       fifo_mem[1]      <=  16'h0000;
       fifo_mem[2]      <=  16'h0000;
       fifo_mem[3]      <=  16'h0000;
       fifo_mem[4]      <=  16'h0000;
    end
  else if (fifo_push)
    begin
       fifo_mem[wr_ptr] <=  lut_hw_enabled ? lut_hw_data    :
`ifdef WITH_PROGRAMMABLE_LUT
                            lut_sw_enabled ? lut_ram_dout_i :
`endif
                                             frame_data_i;
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
// 7) REFRESH_DATA
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


endmodule // ogfx_backend_lut_fifo

`ifdef OGFX_NO_INCLUDE
`else
`include "openGFX430_undefines.v"
`endif
