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
// *File Name: ogfx_gpu_reg.v
//
// *Module Description:
//                      Configuration registers of the Graphic-Processing unit
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

module  ogfx_gpu_reg (

// OUTPUTs
    cfg_dst_addr_o,                               // Destination address configuration
    cfg_dst_cl_swp_o,                             // Destination Column/Line-Swap configuration
    cfg_dst_x_swp_o,                              // Destination X-Swap configuration
    cfg_dst_y_swp_o,                              // Destination Y-Swap configuration
    cfg_fill_color_o,                             // Fill color (for rectangle fill operation)
    cfg_pix_op_sel_o,                             // Pixel operation to be performed during the copy
    cfg_rec_width_o,                              // Rectangle width configuration
    cfg_rec_height_o,                             // Rectangle height configuration
    cfg_src_addr_o,                               // Source address configuration
    cfg_src_cl_swp_o,                             // Source Column/Line-Swap configuration
    cfg_src_x_swp_o,                              // Source X-Swap configuration
    cfg_src_y_swp_o,                              // Source Y-Swap configuration
    cfg_transparent_color_o,                      // Transparent color (for rectangle transparent copy operation)

    gpu_cmd_done_evt_o,                           // GPU command done event
    gpu_cmd_error_evt_o,                          // GPU command error event
    gpu_get_data_o,                               // GPU get next data

    exec_fill_o,                                  // Rectangle fill on going
    exec_copy_o,                                  // Rectangle copy on going
    exec_copy_trans_o,                            // Rectangle transparent copy on going
    trig_exec_o,                                  // Trigger rectangle execution

// INPUTs
    mclk,                                         // Main system clock
    puc_rst,                                      // Main system reset

    gpu_data_i,                                   // GPU data
    gpu_data_avail_i,                             // GPU data available
    gpu_enable_i,                                 // GPU enable

    gpu_exec_done_i                               // GPU execution done
);

// OUTPUTs
//=========
output [`VRAM_MSB:0] cfg_dst_addr_o;              // Destination address configuration
output               cfg_dst_cl_swp_o;            // Destination Column/Line-Swap configuration
output               cfg_dst_x_swp_o;             // Destination X-Swap configuration
output               cfg_dst_y_swp_o;             // Destination Y-Swap configuration
output        [15:0] cfg_fill_color_o;            // Fill color (for rectangle fill operation)
output         [3:0] cfg_pix_op_sel_o;            // Pixel operation to be performed during the copy
output [`LPIX_MSB:0] cfg_rec_width_o;             // Rectangle width configuration
output [`LPIX_MSB:0] cfg_rec_height_o;            // Rectangle height configuration
output [`VRAM_MSB:0] cfg_src_addr_o;              // Source address configuration
output               cfg_src_cl_swp_o;            // Source Column/Line-Swap configuration
output               cfg_src_x_swp_o;             // Source X-Swap configuration
output               cfg_src_y_swp_o;             // Source Y-Swap configuration
output        [15:0] cfg_transparent_color_o;     // Transparent color (for rectangle transparent copy operation)

output               gpu_cmd_done_evt_o;          // GPU command done event
output               gpu_cmd_error_evt_o;         // GPU command error event
output               gpu_get_data_o;              // GPU get next data

output               exec_fill_o;                 // Rectangle fill on going
output               exec_copy_o;                 // Rectangle copy on going
output               exec_copy_trans_o;           // Rectangle transparent copy on going
output               trig_exec_o;                 // Trigger rectangle execution

// INPUTs
//=========
input                mclk;                        // Main system clock
input                puc_rst;                     // Main system reset

input         [15:0] gpu_data_i;                  // GPU data
input                gpu_data_avail_i;            // GPU data available
input                gpu_enable_i;                // GPU enable

input                gpu_exec_done_i;             // GPU execution done

//=============================================================================
// 1)  WIRE, REGISTERS AND PARAMETER DECLARATION
//=============================================================================

reg                exec_fill_o;
reg                exec_copy_o;
reg                exec_copy_trans_o;

reg          [1:0] src_offset_sel;
reg                src_x_swp;
reg                src_y_swp;
reg                src_cl_swp;
reg          [3:0] pix_op_sel;
reg          [1:0] dst_offset_sel;
reg                dst_x_swp;
reg                dst_y_swp;
reg                dst_cl_swp;

reg  [3:0]         reg_access;
wire [3:0]         reg_access_nxt;

reg  [15:0]        fill_color;
reg  [`LPIX_MSB:0] rec_width;
reg  [`LPIX_MSB:0] rec_height;
wire [`VRAM_MSB:0] src_addr;
wire [`VRAM_MSB:0] dst_addr;
wire [`VRAM_MSB:0] of0_addr;
wire [`VRAM_MSB:0] of1_addr;
wire [`VRAM_MSB:0] of2_addr;
wire [`VRAM_MSB:0] of3_addr;
reg  [15:0]        transparent_color;

wire [`VRAM_MSB:0] src_offset_addr;
wire [`VRAM_MSB:0] dst_offset_addr;


//=============================================================================
// 2)  GPU COMMAND STATE MACHINE
//=============================================================================
//
// EXEC_FILL        - Execute rectangle fill command
//                    {2'b00, reserved<4:0>,                                     pxop[3:0], dst_offset[1:0], dst_X-Swp, dst_Y-Swp, dst_CL-Swp}
//                    {fill_color[15:0]}
//
// EXEC_COPY        - Execute rectangle copy command
//                    {2'b01, src_offset[1:0], src_X-Swp, src_Y-Swp, src_CL-Swp, pxop[3:0], dst_offset[1:0], dst_X-Swp, dst_Y-Swp, dst_CL-Swp}
//
// EXEC_COPY_TRANS  - Execute rectangle copy with transparency command
//                    {2'b10, src_offset[1:0], src_X-Swp, src_Y-Swp, src_CL-Swp, pxop[3:0], dst_offset[1:0], dst_X-Swp, dst_Y-Swp, dst_CL-Swp}
//
// REC_WIDTH        - Set rectangle width
//                    {4'b1100, width[11:0]}
//
// REC_HEIGHT       - Set rectangle height
//                    {4'b1101, height[11:0]}
//
// SRC_ADDR         - Set source address
//                    {8'b1111_0000, addr[23:16]}
//                    {addr[15:0]}
//
// DST_ADDR         - Set destination address
//                    {8'b1111_0001, addr[23:16]}
//                    {addr[15:0]}
//
// OF0_ADDR         - Set address offset 0
//                    {8'b1111_1000, addr[23:16]}
//                    {addr[15:0]}
//
// OF1_ADDR         - Set address offset 1
//                    {8'b1111_1001, addr[23:16]}
//                    {addr[15:0]}
//
// OF2_ADDR         - Set address offset 2
//                    {8'b1111_1010, addr[23:16]}
//                    {addr[15:0]}
//
// OF3_ADDR         - Set address offset 3
//                    {8'b1111_1011, addr[23:16]}
//                    {addr[15:0]}
//
// SET_FILL         - Set fill color
//                    {16'b1111_1111_1111_1110}
//                    {fill_color[15:0]}
//
// SET_TRANSPARENT  - Set transparent color
//                    {16'b1111_1111_1111_1111}
//                    {transparent_color[15:0]}
//
//-----------------------------------------------------------------------------

// State definition
parameter  CMD_WAIT   = 3'h0;
parameter  CMD_READ   = 3'h1;
parameter  DATA_WAIT  = 3'h2;
parameter  DATA_READ  = 3'h3;
parameter  EXEC_START = 3'h4;
parameter  EXEC       = 3'h5;
parameter  ERROR      = 3'h6;

// State machine
reg  [2:0] gpu_state;
reg  [2:0] gpu_state_nxt;

// Arcs control
wire       cmd_available    =  gpu_data_avail_i;

wire       cmd_not_valid    = ((gpu_data_i[15:14]!= `OP_EXEC_FILL      ) &
                               (gpu_data_i[15:14]!= `OP_EXEC_COPY      ) &
                               (gpu_data_i[15:14]!= `OP_EXEC_COPY_TRANS) &
                               (gpu_data_i[15:12]!= `OP_REC_WIDTH      ) &
                               (gpu_data_i[15:12]!= `OP_REC_HEIGHT     ) &
                               (gpu_data_i[15:8] != `OP_SRC_ADDR       ) &
                               (gpu_data_i[15:8] != `OP_DST_ADDR       ) &
                               (gpu_data_i[15:8] != `OP_OF0_ADDR       ) &
                               (gpu_data_i[15:8] != `OP_OF1_ADDR       ) &
                               (gpu_data_i[15:8] != `OP_OF2_ADDR       ) &
                               (gpu_data_i[15:8] != `OP_OF3_ADDR       ) &
                               (gpu_data_i[15:0] != `OP_SET_FILL       ) &
                               (gpu_data_i[15:0] != `OP_SET_TRANSPARENT));

wire       cmd_has_data     =  (gpu_data_i[15:14]== `OP_EXEC_FILL      ) |
                               (gpu_data_i[15:8] == `OP_SRC_ADDR       ) |
                               (gpu_data_i[15:8] == `OP_DST_ADDR       ) |
                               (gpu_data_i[15:8] == `OP_OF0_ADDR       ) |
                               (gpu_data_i[15:8] == `OP_OF1_ADDR       ) |
                               (gpu_data_i[15:8] == `OP_OF2_ADDR       ) |
                               (gpu_data_i[15:8] == `OP_OF3_ADDR       ) |
                               (gpu_data_i[15:0] == `OP_SET_FILL       ) |
                               (gpu_data_i[15:0] == `OP_SET_TRANSPARENT);

wire       cmd_has_exec     =  exec_fill_o | exec_copy_o | exec_copy_trans_o;

wire       data_available   =  gpu_data_avail_i;


// State transition
always @(gpu_state or cmd_available or cmd_not_valid or cmd_has_data or cmd_has_exec or data_available or gpu_exec_done_i)
  case (gpu_state)
    CMD_WAIT   : gpu_state_nxt =  cmd_available   ? CMD_READ   : CMD_WAIT;
    CMD_READ   : gpu_state_nxt =  cmd_not_valid   ? ERROR      :
                                  cmd_has_data    ? DATA_WAIT  :
                                  cmd_has_exec    ? EXEC_START : CMD_WAIT;
    DATA_WAIT  : gpu_state_nxt =  data_available  ? DATA_READ  : DATA_WAIT;
    DATA_READ  : gpu_state_nxt =  cmd_has_exec    ? EXEC_START : CMD_WAIT;
    EXEC_START : gpu_state_nxt =  gpu_exec_done_i ? CMD_WAIT   : EXEC;
    EXEC       : gpu_state_nxt =  gpu_exec_done_i ? CMD_WAIT   : EXEC;
    ERROR      : gpu_state_nxt =  ERROR;
  // pragma coverage off
    default    : gpu_state_nxt =  CMD_WAIT;
  // pragma coverage on
  endcase


// State machine
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)            gpu_state <= CMD_WAIT;
  else if (~gpu_enable_i) gpu_state <= CMD_WAIT;
  else                    gpu_state <= gpu_state_nxt;


// Event generation, fifo data request
assign  gpu_cmd_done_evt_o     = (gpu_state!=ERROR) & (gpu_state!=CMD_WAIT) & (gpu_state_nxt==CMD_WAIT);
assign  gpu_cmd_error_evt_o    = (gpu_state==ERROR);
assign  gpu_get_data_o         = (gpu_state==CMD_READ) | (gpu_state==DATA_READ);

// Execution triggers
assign  trig_exec_o            = (exec_fill_o      |
                                  exec_copy_o      |
                                  exec_copy_trans_o) & (gpu_state==EXEC_START);


//=============================================================================
// 3)  CONFIGURATION REGISTERS
//=============================================================================

// Detect execution commands
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                                    exec_fill_o       <= 1'b0;
  else if ((gpu_state==CMD_WAIT) & cmd_available) exec_fill_o       <= (gpu_data_i[15:14]==`OP_EXEC_FILL);
  else if ((gpu_state_nxt==CMD_WAIT)            ) exec_fill_o       <= 1'b0;

always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                                    exec_copy_o       <= 1'b0;
  else if ((gpu_state==CMD_WAIT) & cmd_available) exec_copy_o       <= (gpu_data_i[15:14]==`OP_EXEC_COPY);
  else if ((gpu_state_nxt==CMD_WAIT)            ) exec_copy_o       <= 1'b0;

always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                                    exec_copy_trans_o <= 1'b0;
  else if ((gpu_state==CMD_WAIT) & cmd_available) exec_copy_trans_o <= (gpu_data_i[15:14]==`OP_EXEC_COPY_TRANS);
  else if ((gpu_state_nxt==CMD_WAIT)            ) exec_copy_trans_o <= 1'b0;

// Detect register accesses
parameter REG_EXEC_FILL       = 4'h1;
parameter REG_REC_WIDTH       = 4'h2;
parameter REG_REC_HEIGHT      = 4'h3;
parameter REG_SRC_ADDR        = 4'h4;
parameter REG_DST_ADDR        = 4'h5;
parameter REG_OF0_ADDR        = 4'h6;
parameter REG_OF1_ADDR        = 4'h7;
parameter REG_OF2_ADDR        = 4'h8;
parameter REG_OF3_ADDR        = 4'h9;
parameter REG_SET_FILL        = 4'hA;
parameter REG_SET_TRANSPARENT = 4'hB;

assign    reg_access_nxt      = ({4{gpu_data_i[15:14]== `OP_EXEC_FILL      }} & REG_EXEC_FILL      ) |
                                ({4{gpu_data_i[15:12]== `OP_REC_WIDTH      }} & REG_REC_WIDTH      ) |
                                ({4{gpu_data_i[15:12]== `OP_REC_HEIGHT     }} & REG_REC_HEIGHT     ) |
                                ({4{gpu_data_i[15:8] == `OP_SRC_ADDR       }} & REG_SRC_ADDR       ) |
                                ({4{gpu_data_i[15:8] == `OP_DST_ADDR       }} & REG_DST_ADDR       ) |
                                ({4{gpu_data_i[15:8] == `OP_OF0_ADDR       }} & REG_OF0_ADDR       ) |
                                ({4{gpu_data_i[15:8] == `OP_OF1_ADDR       }} & REG_OF1_ADDR       ) |
                                ({4{gpu_data_i[15:8] == `OP_OF2_ADDR       }} & REG_OF2_ADDR       ) |
                                ({4{gpu_data_i[15:8] == `OP_OF3_ADDR       }} & REG_OF3_ADDR       ) |
                                ({4{gpu_data_i[15:0] == `OP_SET_FILL       }} & REG_SET_FILL       ) |
                                ({4{gpu_data_i[15:0] == `OP_SET_TRANSPARENT}} & REG_SET_TRANSPARENT) ;

always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                      reg_access <= 4'h0;
  else if (gpu_state==CMD_READ)     reg_access <= reg_access_nxt;
  else if (gpu_state_nxt==CMD_WAIT) reg_access <= 4'h0;


//=============================================================================
// 4)  CONFIGURATION REGISTERS
//=============================================================================

//------------------------------------------------
// EXECUTION CONFIG Register
//------------------------------------------------

wire  exec_all_cfg_wr = (exec_fill_o | exec_copy_o | exec_copy_trans_o) & (gpu_state==CMD_READ);
wire  exec_src_cfg_wr = (              exec_copy_o | exec_copy_trans_o) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       src_offset_sel <= 2'b00;
       src_x_swp      <= 1'b0;
       src_y_swp      <= 1'b0;
       src_cl_swp     <= 1'b0;
    end
  else if (exec_src_cfg_wr)
    begin
       src_offset_sel <= gpu_data_i[13:12];
       src_x_swp      <= gpu_data_i[11];
       src_y_swp      <= gpu_data_i[10];
       src_cl_swp     <= gpu_data_i[9];
    end

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       pix_op_sel     <= 4'b0000;
       dst_offset_sel <= 2'b00;
       dst_x_swp      <= 1'b0;
       dst_y_swp      <= 1'b0;
       dst_cl_swp     <= 1'b0;
    end
  else if (exec_all_cfg_wr)
    begin
       pix_op_sel     <= gpu_data_i[8:5];
       dst_offset_sel <= gpu_data_i[4:3];
       dst_x_swp      <= gpu_data_i[2];
       dst_y_swp      <= gpu_data_i[1];
       dst_cl_swp     <= gpu_data_i[0];
    end

assign cfg_src_x_swp_o  = src_x_swp;
assign cfg_src_y_swp_o  = src_y_swp;
assign cfg_src_cl_swp_o = src_cl_swp;
assign cfg_pix_op_sel_o = pix_op_sel;
assign cfg_dst_x_swp_o  = dst_x_swp;
assign cfg_dst_y_swp_o  = dst_y_swp;
assign cfg_dst_cl_swp_o = dst_cl_swp;

//------------------------------------------------
// FILL_COLOR Register
//------------------------------------------------

wire  fill_color_wr = ((reg_access==REG_EXEC_FILL) |
                       (reg_access==REG_SET_FILL ) ) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            fill_color <=  16'h0000;
  else if (fill_color_wr) fill_color <=  gpu_data_i;

assign cfg_fill_color_o = fill_color;

//------------------------------------------------
// REC_WIDTH Register
//------------------------------------------------

wire               rec_width_wr = (reg_access_nxt==REG_REC_WIDTH) & (gpu_state==CMD_READ);

wire [`LPIX_MSB:0] rec_w_h_nxt  = (|gpu_data_i[`LPIX_MSB:0]) ? gpu_data_i[`LPIX_MSB:0] :
                                                               {{`LPIX_MSB{1'b0}}, 1'b1};


always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)           rec_width <=  {{`LPIX_MSB{1'b0}}, 1'b1};
  else if (rec_width_wr) rec_width <=  rec_w_h_nxt;

assign cfg_rec_width_o = rec_width;

//------------------------------------------------
// REC_HEIGHT Register
//------------------------------------------------

wire  rec_height_wr = (reg_access_nxt==REG_REC_HEIGHT) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            rec_height <=  {{`LPIX_MSB{1'b0}}, 1'b1};
  else if (rec_height_wr) rec_height <=  rec_w_h_nxt;

assign cfg_rec_height_o = rec_height;

//------------------------------------------------
// SRC_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] src_addr_hi;

wire                 src_addr_hi_wr = (reg_access_nxt==REG_SRC_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             src_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (src_addr_hi_wr) src_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// SRC_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] src_addr_lo;

wire                 src_addr_lo_wr = (reg_access==REG_SRC_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             src_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (src_addr_lo_wr) src_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      src_addr  = {src_addr_hi[`VRAM_HI_MSB:0], src_addr_lo};
`else
assign      src_addr  = {src_addr_lo[`VRAM_LO_MS:0]};
`endif

assign cfg_src_addr_o = src_addr + src_offset_addr;

//------------------------------------------------
// DST_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] dst_addr_hi;

wire                 dst_addr_hi_wr = (reg_access_nxt==REG_DST_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             dst_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (dst_addr_hi_wr) dst_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// DST_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] dst_addr_lo;

wire                 dst_addr_lo_wr = (reg_access==REG_DST_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             dst_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (dst_addr_lo_wr) dst_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      dst_addr  = {dst_addr_hi[`VRAM_HI_MSB:0], dst_addr_lo};
`else
assign      dst_addr  = {dst_addr_lo[`VRAM_LO_MS:0]};
`endif

assign cfg_dst_addr_o = dst_addr + dst_offset_addr;

//------------------------------------------------
// OF0_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] of0_addr_hi;

wire                 of0_addr_hi_wr = (reg_access_nxt==REG_OF0_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of0_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (of0_addr_hi_wr) of0_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// OF0_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] of0_addr_lo;

wire                 of0_addr_lo_wr = (reg_access==REG_OF0_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of0_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (of0_addr_lo_wr) of0_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      of0_addr  = {of0_addr_hi[`VRAM_HI_MSB:0], of0_addr_lo};
`else
assign      of0_addr  = {of0_addr_lo[`VRAM_LO_MS:0]};
`endif

//------------------------------------------------
// OF1_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] of1_addr_hi;

wire                 of1_addr_hi_wr = (reg_access_nxt==REG_OF1_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of1_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (of1_addr_hi_wr) of1_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// OF1_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] of1_addr_lo;

wire                 of1_addr_lo_wr = (reg_access==REG_OF1_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of1_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (of1_addr_lo_wr) of1_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      of1_addr  = {of1_addr_hi[`VRAM_HI_MSB:0], of1_addr_lo};
`else
assign      of1_addr  = {of1_addr_lo[`VRAM_LO_MS:0]};
`endif

//------------------------------------------------
// OF2_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] of2_addr_hi;

wire                 of2_addr_hi_wr = (reg_access_nxt==REG_OF2_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of2_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (of2_addr_hi_wr) of2_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// OF2_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] of2_addr_lo;

wire                 of2_addr_lo_wr = (reg_access==REG_OF2_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of2_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (of2_addr_lo_wr) of2_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      of2_addr  = {of2_addr_hi[`VRAM_HI_MSB:0], of2_addr_lo};
`else
assign      of2_addr  = {of2_addr_lo[`VRAM_LO_MS:0]};
`endif

//------------------------------------------------
// OF3_ADDR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] of3_addr_hi;

wire                 of3_addr_hi_wr = (reg_access_nxt==REG_OF3_ADDR) & (gpu_state==CMD_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of3_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (of3_addr_hi_wr) of3_addr_hi <=  gpu_data_i[`VRAM_HI_MSB:0];
`endif

//------------------------------------------------
// OF3_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] of3_addr_lo;

wire                 of3_addr_lo_wr = (reg_access==REG_OF3_ADDR) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             of3_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (of3_addr_lo_wr) of3_addr_lo <=  gpu_data_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      of3_addr  = {of3_addr_hi[`VRAM_HI_MSB:0], of3_addr_lo};
`else
assign      of3_addr  = {of3_addr_lo[`VRAM_LO_MS:0]};
`endif

// Offset address selection
assign src_offset_addr = (src_offset_sel==2'h0) ? of0_addr :
                         (src_offset_sel==2'h1) ? of1_addr :
			 (src_offset_sel==2'h2) ? of2_addr : of3_addr;

assign dst_offset_addr = (dst_offset_sel==2'h0) ? of0_addr :
			 (dst_offset_sel==2'h1) ? of1_addr :
			 (dst_offset_sel==2'h2) ? of2_addr : of3_addr;


//------------------------------------------------
// TRANSPARENT_COLOR Register
//------------------------------------------------

wire  transparent_color_wr = (reg_access==REG_SET_TRANSPARENT) & (gpu_state==DATA_READ);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   transparent_color <=  16'h0000;
  else if (transparent_color_wr) transparent_color <=  gpu_data_i;

assign cfg_transparent_color_o = transparent_color;

endmodule // ogfx_gpu_reg

`ifdef OGFX_NO_INCLUDE
`else
`include "openGFX430_undefines.v"
`endif
