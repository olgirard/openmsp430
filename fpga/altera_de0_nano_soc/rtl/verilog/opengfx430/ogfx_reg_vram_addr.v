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
// *File Name: ogfx_reg_vram_addr.v
//
// *Module Description:
//                      Compute Video-Ram address for software accesses
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

module  ogfx_reg_vram_addr (

// OUTPUTs
    vid_ram_addr_nxt_o,                     // Next Video-RAM address

// INPUTs
    mclk,                                   // Main system clock
    puc_rst,                                // Main system reset
    display_width_i,                        // Display width
    vid_ram_addr_i,                         // Video-RAM address
    vid_ram_addr_init_i,                    // Video-RAM address initialization
    vid_ram_addr_step_i,                    // Video-RAM address step
    vid_ram_width_i,                        // Video-RAM width
    vid_ram_win_mode_i,                     // Video-RAM Windows mode enable
    vid_ram_win_x_swap_i,                   // Video-RAM X-Swap configuration
    vid_ram_win_y_swap_i,                   // Video-RAM Y-Swap configuration
    vid_ram_win_cl_swap_i                   // Video-RAM CL-Swap configuration
);

// OUTPUTs
//=========
output [`VRAM_MSB:0] vid_ram_addr_nxt_o;    //  Next Video-RAM address

// INPUTs
//=========
input                mclk;                  // Main system clock
input                puc_rst;               // Main system reset
input  [`LPIX_MSB:0] display_width_i;       // Display width
input  [`VRAM_MSB:0] vid_ram_addr_i;        // Video-RAM address
input                vid_ram_addr_init_i;   // Video-RAM address initialization
input                vid_ram_addr_step_i;   // Video-RAM address step
input  [`LPIX_MSB:0] vid_ram_width_i;       // Video-RAM width
input                vid_ram_win_mode_i;    // Video-RAM Windows mode enable
input                vid_ram_win_x_swap_i;  // Video-RAM X-Swap configuration
input                vid_ram_win_y_swap_i;  // Video-RAM Y-Swap configuration
input                vid_ram_win_cl_swap_i; // Video-RAM CL-Swap configuration


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================
reg    [`VRAM_MSB:0] vid_ram_line_addr;
reg    [`LPIX_MSB:0] vid_ram_column_count;

// Detect when the current line refresh is done
wire                 vid_ram_line_done  = vid_ram_addr_step_i & (vid_ram_column_count==(vid_ram_width_i-{{`LPIX_MSB{1'b0}}, 1'b1}));

// Zero extension for LINT cleanup
wire [`VRAM_MSB*3:0] vid_ram_width_norm =  vid_ram_addr_init_i ? {{`VRAM_MSB*3-`LPIX_MSB{1'b0}}, vid_ram_width_i} :
                                                                 {{`VRAM_MSB*3-`LPIX_MSB{1'b0}}, display_width_i} ;

wire   [`VRAM_MSB:0] next_base_addr     =  (vid_ram_addr_init_i | ~vid_ram_line_done | ~vid_ram_win_mode_i) ? vid_ram_addr_i    :
                                                                                                              vid_ram_line_addr ;

wire   [`VRAM_MSB:0] next_addr          =   next_base_addr
                                          + (vid_ram_width_norm[`VRAM_MSB:0] & {`VRAM_MSB+1{(~vid_ram_addr_init_i & vid_ram_win_mode_i) ? (~vid_ram_win_y_swap_i &  (vid_ram_win_cl_swap_i ^ vid_ram_line_done)) : 1'b0}})
                                          - (vid_ram_width_norm[`VRAM_MSB:0] & {`VRAM_MSB+1{(~vid_ram_addr_init_i & vid_ram_win_mode_i) ? ( vid_ram_win_y_swap_i &  (vid_ram_win_cl_swap_i ^ vid_ram_line_done)) : 1'b0}})
                                          + ({{`VRAM_MSB{1'b0}}, 1'b1}       & {`VRAM_MSB+1{(~vid_ram_addr_init_i & vid_ram_win_mode_i) ? (~vid_ram_win_x_swap_i & ~(vid_ram_win_cl_swap_i ^ vid_ram_line_done)) : (~vid_ram_win_mode_i & ~vid_ram_addr_init_i)}})
                                          - ({{`VRAM_MSB{1'b0}}, 1'b1}       & {`VRAM_MSB+1{(~vid_ram_addr_init_i & vid_ram_win_mode_i) ? ( vid_ram_win_x_swap_i & ~(vid_ram_win_cl_swap_i ^ vid_ram_line_done)) : 1'b0}});

wire                 update_line_addr   =  (vid_ram_addr_init_i | vid_ram_line_done) & vid_ram_win_mode_i;
wire                 update_pixel_addr  =   update_line_addr    | vid_ram_addr_step_i;

// Start RAM address of currentely refreshed line
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)               vid_ram_line_addr  <=  {`VRAM_MSB+1{1'b0}};
  else if (update_line_addr) vid_ram_line_addr  <=  next_addr;

// Current RAM address of the currentely refreshed pixel
wire [`VRAM_MSB:0] vid_ram_addr_nxt_o = update_pixel_addr ? next_addr : vid_ram_addr_i;

// Count the pixel number in the current line
// (used to detec the end of a line)
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram_column_count  <=  {`LPIX_MSB+1{1'b0}};
  else if (vid_ram_addr_init_i)  vid_ram_column_count  <=  {`LPIX_MSB+1{1'b0}};
  else if (vid_ram_line_done)    vid_ram_column_count  <=  {`LPIX_MSB+1{1'b0}};
  else if (vid_ram_addr_step_i)  vid_ram_column_count  <=  vid_ram_column_count + {{`LPIX_MSB{1'b0}}, 1'b1};


endmodule // ogfx_reg_vram_addr

`ifdef OGFX_NO_INCLUDE
`else
`include "openGFX430_undefines.v"
`endif
