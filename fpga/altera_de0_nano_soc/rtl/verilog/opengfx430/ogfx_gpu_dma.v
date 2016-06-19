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
// *File Name: ogfx_gpu_dma.v
//
// *Module Description:
//                      Graphic-Processing unit 2D-DMA.
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

module  ogfx_gpu_dma (

// OUTPUTs
    gpu_exec_done_o,                              // GPU execution done

    vid_ram_addr_o,                               // Video-RAM address
    vid_ram_din_o,                                // Video-RAM data
    vid_ram_wen_o,                                // Video-RAM write strobe (active low)
    vid_ram_cen_o,                                // Video-RAM chip enable (active low)

// INPUTs
    mclk,                                         // Main system clock
    puc_rst,                                      // Main system reset

    cfg_dst_addr_i,                               // Destination address configuration
    cfg_dst_cl_swp_i,                             // Destination Column/Line-Swap configuration
    cfg_dst_x_swp_i,                              // Destination X-Swap configuration
    cfg_dst_y_swp_i,                              // Destination Y-Swap configuration
    cfg_fill_color_i,                             // Fill color (for rectangle fill operation)
    cfg_pix_op_sel_i,                             // Pixel operation to be performed during the copy
    cfg_rec_width_i,                              // Rectangle width configuration
    cfg_rec_height_i,                             // Rectangle height configuration
    cfg_src_addr_i,                               // Source address configuration
    cfg_src_cl_swp_i,                             // Source Column/Line-Swap configuration
    cfg_src_x_swp_i,                              // Source X-Swap configuration
    cfg_src_y_swp_i,                              // Source Y-Swap configuration
    cfg_transparent_color_i,                      // Transparent color (for rectangle transparent copy operation)

    display_width_i,                              // Display width
    display_height_i,                             // Display height

    gfx_mode_i,                                   // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

    gpu_enable_i,                                 // GPU enable

    trig_exec_fill_i,                             // Trigger rectangle fill execution
    trig_exec_copy_i,                             // Trigger rectangle copy execution
    trig_exec_copy_trans_i,                       // Trigger rectangle transparent copy execution

    vid_ram_dout_i,                               // Video-RAM data input
    vid_ram_dout_rdy_nxt_i                        // Video-RAM data output ready during next cycle
);

// OUTPUTs
//=========
output               gpu_exec_done_o;             // GPU execution done

output [`VRAM_MSB:0] vid_ram_addr_o;              // Video-RAM address
output        [15:0] vid_ram_din_o;               // Video-RAM data
output         [1:0] vid_ram_wen_o;               // Video-RAM write strobe (active low)
output               vid_ram_cen_o;               // Video-RAM chip enable (active low)

// INPUTs
//=========
input                mclk;                        // Main system clock
input                puc_rst;                     // Main system reset

input  [`VRAM_MSB:0] cfg_dst_addr_i;              // Destination address configuration
input                cfg_dst_cl_swp_i;            // Destination Column/Line-Swap configuration
input                cfg_dst_x_swp_i;             // Destination X-Swap configuration
input                cfg_dst_y_swp_i;             // Destination Y-Swap configuration
input         [15:0] cfg_fill_color_i;            // Fill color (for rectangle fill operation)
input          [3:0] cfg_pix_op_sel_i;            // Pixel operation to be performed during the copy
input  [`LPIX_MSB:0] cfg_rec_width_i;             // Rectangle width configuration
input  [`LPIX_MSB:0] cfg_rec_height_i;            // Rectangle height configuration
input  [`VRAM_MSB:0] cfg_src_addr_i;              // Source address configuration
input                cfg_src_cl_swp_i;            // Source Column/Line-Swap configuration
input                cfg_src_x_swp_i;             // Source X-Swap configuration
input                cfg_src_y_swp_i;             // Source Y-Swap configuration
input         [15:0] cfg_transparent_color_i;     // Transparent color (for rectangle transparent copy operation)

input  [`LPIX_MSB:0] display_width_i;             // Display width
input  [`LPIX_MSB:0] display_height_i;            // Display height

input          [2:0] gfx_mode_i;                  // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

input                gpu_enable_i;                // GPU enable

input                trig_exec_fill_i;            // Trigger rectangle fill execution
input                trig_exec_copy_i;            // Trigger rectangle copy execution
input                trig_exec_copy_trans_i;      // Trigger rectangle transparent copy execution

input         [15:0] vid_ram_dout_i;              // Video-RAM data input
input                vid_ram_dout_rdy_nxt_i;      // Video-RAM data output ready during next cycle


//=============================================================================
// 1)  WIRE, REGISTERS AND PARAMETER DECLARATION
//=============================================================================

// Video modes decoding
wire        gfx_mode_1_bpp    =  (gfx_mode_i == 3'b000);
wire        gfx_mode_2_bpp    =  (gfx_mode_i == 3'b001);
wire        gfx_mode_4_bpp    =  (gfx_mode_i == 3'b010);
wire        gfx_mode_8_bpp    =  (gfx_mode_i == 3'b011);
wire        gfx_mode_16_bpp   = ~(gfx_mode_8_bpp | gfx_mode_4_bpp |
                                  gfx_mode_2_bpp | gfx_mode_1_bpp);

assign    gpu_exec_done_o = 1'b1;

assign    vid_ram_addr_o  = {`VRAM_AWIDTH{1'b0}};
assign    vid_ram_din_o   = 16'h0000;
assign    vid_ram_wen_o   = 2'b11;
assign    vid_ram_cen_o   = 1'b1;


//=============================================================================
// 2)  SOURCE ADDRESS GENERATION
//=============================================================================



//=============================================================================
// 3)  DESTINATION ADDRESS GENERATION
//=============================================================================



endmodule // ogfx_gpu_dma

`ifdef OGFX_NO_INCLUDE
`else
`include "openGFX430_undefines.v"
`endif
