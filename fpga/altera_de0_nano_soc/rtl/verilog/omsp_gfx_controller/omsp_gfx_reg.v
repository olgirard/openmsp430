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
// *File Name: omsp_gfx_reg.v
//
// *Module Description:
//                      Registers for oMSP programming.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------

module  omsp_gfx_reg (

// OUTPUTs
    irq_gfx_o,                               // Graphic Controller interrupt

    lt24_reset_n_o,                          // LT24 Reset (Active Low)
    lt24_on_o,                               // LT24 on/off
    lt24_cfg_clk_o,                          // LT24 Interface clock configuration
    lt24_cfg_refr_o,                         // LT24 Interface refresh configuration
    lt24_cfg_refr_sync_en_o,                 // LT24 Interface refresh sync enable configuration
    lt24_cfg_refr_sync_val_o,                // LT24 Interface refresh sync value configuration
    lt24_cmd_refr_o,                         // LT24 Interface refresh command
    lt24_cmd_val_o,                          // LT24 Generic command value
    lt24_cmd_has_param_o,                    // LT24 Generic command has parameters
    lt24_cmd_param_o,                        // LT24 Generic command parameter value
    lt24_cmd_param_rdy_o,                    // LT24 Generic command trigger
    lt24_cmd_dfill_o,                        // LT24 Data fill value
    lt24_cmd_dfill_wr_o,                     // LT24 Data fill trigger

    display_width_o,                         // Display width
    display_height_o,                        // Display height
    display_size_o,                          // Display size (number of pixels)
    display_y_swap_o,                        // Display configuration: swap Y axis (horizontal symmetry)
    display_x_swap_o,		             // Display configuration: swap X axis (vertical symmetry)
    display_cl_swap_o,		             // Display configuration: swap column/lines
    gfx_mode_o,                              // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

    per_dout_o,                              // Peripheral data output

    refresh_frame_addr_o,                    // Refresh frame base address

    lut_ram_addr_o,                          // LUT-RAM address
    lut_ram_din_o,                           // LUT-RAM data
    lut_ram_wen_o,                           // LUT-RAM write strobe (active low)
    lut_ram_cen_o,                           // LUT-RAM chip enable (active low)

    vid_ram_addr_o,                          // Video-RAM address
    vid_ram_din_o,                           // Video-RAM data
    vid_ram_wen_o,                           // Video-RAM write strobe (active low)
    vid_ram_cen_o,                           // Video-RAM chip enable (active low)

// INPUTs
    lt24_status_i,                           // LT24 FSM Status
    lt24_start_evt_i,                        // LT24 FSM is starting
    lt24_done_evt_i,                         // LT24 FSM is done
    mclk,                                    // Main system clock
    per_addr_i,                              // Peripheral address
    per_din_i,                               // Peripheral data input
    per_en_i,                                // Peripheral enable (high active)
    per_we_i,                                // Peripheral write enable (high active)
    puc_rst,                                 // Main system reset
    lut_ram_dout_i,                          // LUT-RAM data input
    vid_ram_dout_i                           // Video-RAM data input
);

// OUTPUTs
//=========
output             irq_gfx_o;                // Graphic Controller interrupt

output             lt24_reset_n_o;           // LT24 Reset (Active Low)
output             lt24_on_o;                // LT24 on/off
output       [2:0] lt24_cfg_clk_o;           // LT24 Interface clock configuration
output      [11:0] lt24_cfg_refr_o;          // LT24 Interface refresh configuration
output             lt24_cfg_refr_sync_en_o;  // LT24 Interface refresh sync configuration
output       [9:0] lt24_cfg_refr_sync_val_o; // LT24 Interface refresh sync value configuration
output             lt24_cmd_refr_o;          // LT24 Interface refresh command
output       [7:0] lt24_cmd_val_o;           // LT24 Generic command value
output             lt24_cmd_has_param_o;     // LT24 Generic command has parameters
output      [15:0] lt24_cmd_param_o;         // LT24 Generic command parameter value
output             lt24_cmd_param_rdy_o;     // LT24 Generic command trigger
output      [15:0] lt24_cmd_dfill_o;         // LT24 Data fill value
output             lt24_cmd_dfill_wr_o;      // LT24 Data fill trigger

output      [15:0] display_width_o;          // Display width
output      [15:0] display_height_o;         // Display height
output      [31:0] display_size_o;           // Display size (number of pixels)
output             display_y_swap_o;         // Display configuration: swap Y axis (horizontal symmetry)
output             display_x_swap_o;         // Display configuration: swap X axis (vertical symmetry)
output             display_cl_swap_o;        // Display configuration: swap column/lines
output       [2:0] gfx_mode_o;               // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

output      [15:0] per_dout_o;               // Peripheral data output

output      [31:0] refresh_frame_addr_o;     // Refresh frame base address

output      [31:0] lut_ram_addr_o;           // LUT-RAM address
output      [15:0] lut_ram_din_o;            // LUT-RAM data
output       [1:0] lut_ram_wen_o;            // LUT-RAM write strobe (active low)
output             lut_ram_cen_o;            // LUT-RAM chip enable (active low)

output      [31:0] vid_ram_addr_o;           // Video-RAM address
output      [15:0] vid_ram_din_o;            // Video-RAM data
output       [1:0] vid_ram_wen_o;            // Video-RAM write strobe (active low)
output             vid_ram_cen_o;            // Video-RAM chip enable (active low)

// INPUTs
//=========
input        [4:0] lt24_status_i;            // LT24 FSM Status
input              lt24_start_evt_i;         // LT24 FSM is starting
input              lt24_done_evt_i;          // LT24 FSM is done
input              mclk;                     // Main system clock
input       [13:0] per_addr_i;               // Peripheral address
input       [15:0] per_din_i;                // Peripheral data input
input              per_en_i;                 // Peripheral enable (high active)
input        [1:0] per_we_i;                 // Peripheral write enable (high active)
input              puc_rst;                  // Main system reset
input       [15:0] lut_ram_dout_i;           // LUT-RAM data input
input       [15:0] vid_ram_dout_i;           // Video-RAM data input


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR           = 15'h0200;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD              =  7;

// Register addresses offset
parameter [DEC_WD-1:0] GFX_CTRL            = 'h00,  // General control/status/irq
                       GFX_STATUS          = 'h08,
                       GFX_IRQ             = 'h0A,

                       DISPLAY_WIDTH       = 'h10,  // Display configuration
                       DISPLAY_HEIGHT      = 'h12,
                       DISPLAY_SIZE_HI     = 'h14,
                       DISPLAY_SIZE_LO     = 'h16,
                       DISPLAY_CFG         = 'h18,

                       LT24_CFG            = 'h20,  // LT24 configuration and Generic command sending
                       LT24_REFRESH        = 'h22,
                       LT24_REFRESH_SYNC   = 'h24,
                       LT24_CMD            = 'h26,
                       LT24_CMD_PARAM      = 'h28,
                       LT24_CMD_DFILL      = 'h2A,
                       LT24_STATUS         = 'h2C,

                       LUT_RAM_ADDR_HI     = 'h30,  // LUT Memory Access Gate
                       LUT_RAM_ADDR_LO     = 'h32,
                       LUT_RAM_DATA        = 'h34,

                       FRAME_SELECT        = 'h3E,  // Frame pointers and selection
                       FRAME0_PTR_HI       = 'h40,
                       FRAME0_PTR_LO       = 'h42,
                       FRAME1_PTR_HI       = 'h44,
                       FRAME1_PTR_LO       = 'h46,
                       FRAME2_PTR_HI       = 'h48,
                       FRAME2_PTR_LO       = 'h4A,
                       FRAME3_PTR_HI       = 'h4C,
                       FRAME3_PTR_LO       = 'h4E,

                       VID_RAM0_ADDR_HI    = 'h50,  // First Video Memory Access Gate
                       VID_RAM0_ADDR_LO    = 'h52,
                       VID_RAM0_DATA       = 'h54,

                       VID_RAM1_ADDR_HI    = 'h58,  // Second Video Memory Access Gate
                       VID_RAM1_ADDR_LO    = 'h5A,
                       VID_RAM1_DATA       = 'h5C,

                       PIX0_WIDTH          = 'h60,  // First Pixel Access Gate to Video memory
                       PIX0_HEIGHT         = 'h62,
                       PIX0_X              = 'h64,
                       PIX0_Y              = 'h66,
                       PIX0_DATA           = 'h68,

                       PIX1_WIDTH          = 'h70,  // Second Pixel Access Gate to Video memory
                       PIX1_HEIGHT         = 'h72,
                       PIX1_X              = 'h74,
                       PIX1_Y              = 'h76,
                       PIX1_DATA           = 'h78;


// Register one-hot decoder utilities
parameter              DEC_SZ              =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG            =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] GFX_CTRL_D          = (BASE_REG << GFX_CTRL          ),
                       GFX_STATUS_D        = (BASE_REG << GFX_STATUS        ),
                       GFX_IRQ_D           = (BASE_REG << GFX_IRQ           ),

                       DISPLAY_WIDTH_D     = (BASE_REG << DISPLAY_WIDTH     ),
                       DISPLAY_HEIGHT_D    = (BASE_REG << DISPLAY_HEIGHT    ),
                       DISPLAY_SIZE_HI_D   = (BASE_REG << DISPLAY_SIZE_HI   ),
                       DISPLAY_SIZE_LO_D   = (BASE_REG << DISPLAY_SIZE_LO   ),
                       DISPLAY_CFG_D       = (BASE_REG << DISPLAY_CFG       ),

                       LT24_CFG_D          = (BASE_REG << LT24_CFG          ),
                       LT24_REFRESH_D      = (BASE_REG << LT24_REFRESH      ),
                       LT24_REFRESH_SYNC_D = (BASE_REG << LT24_REFRESH_SYNC ),
                       LT24_CMD_D          = (BASE_REG << LT24_CMD          ),
                       LT24_CMD_PARAM_D    = (BASE_REG << LT24_CMD_PARAM    ),
                       LT24_CMD_DFILL_D    = (BASE_REG << LT24_CMD_DFILL    ),
                       LT24_STATUS_D       = (BASE_REG << LT24_STATUS       ),

                       LUT_RAM_ADDR_HI_D   = (BASE_REG << LUT_RAM_ADDR_HI   ),
                       LUT_RAM_ADDR_LO_D   = (BASE_REG << LUT_RAM_ADDR_LO   ),
                       LUT_RAM_DATA_D      = (BASE_REG << LUT_RAM_DATA      ),

                       FRAME_SELECT_D      = (BASE_REG << FRAME_SELECT      ),
                       FRAME0_PTR_HI_D     = (BASE_REG << FRAME0_PTR_HI     ),
                       FRAME0_PTR_LO_D     = (BASE_REG << FRAME0_PTR_LO     ),
                       FRAME1_PTR_HI_D     = (BASE_REG << FRAME1_PTR_HI     ),
                       FRAME1_PTR_LO_D     = (BASE_REG << FRAME1_PTR_LO     ),
                       FRAME2_PTR_HI_D     = (BASE_REG << FRAME2_PTR_HI     ),
                       FRAME2_PTR_LO_D     = (BASE_REG << FRAME2_PTR_LO     ),
                       FRAME3_PTR_HI_D     = (BASE_REG << FRAME3_PTR_HI     ),
                       FRAME3_PTR_LO_D     = (BASE_REG << FRAME3_PTR_LO     ),

                       VID_RAM0_ADDR_HI_D  = (BASE_REG << VID_RAM0_ADDR_HI  ),
                       VID_RAM0_ADDR_LO_D  = (BASE_REG << VID_RAM0_ADDR_LO  ),
                       VID_RAM0_DATA_D     = (BASE_REG << VID_RAM0_DATA     ),

                       VID_RAM1_ADDR_HI_D  = (BASE_REG << VID_RAM1_ADDR_HI  ),
                       VID_RAM1_ADDR_LO_D  = (BASE_REG << VID_RAM1_ADDR_LO  ),
                       VID_RAM1_DATA_D     = (BASE_REG << VID_RAM1_DATA     ),

                       PIX0_WIDTH_D        = (BASE_REG << PIX0_WIDTH        ),
                       PIX0_HEIGHT_D       = (BASE_REG << PIX0_HEIGHT       ),
                       PIX0_X_D            = (BASE_REG << PIX0_X            ),
                       PIX0_Y_D            = (BASE_REG << PIX0_Y            ),
                       PIX0_DATA_D         = (BASE_REG << PIX0_DATA         ),

                       PIX1_WIDTH_D        = (BASE_REG << PIX1_WIDTH        ),
                       PIX1_HEIGHT_D       = (BASE_REG << PIX1_HEIGHT       ),
                       PIX1_X_D            = (BASE_REG << PIX1_X            ),
                       PIX1_Y_D            = (BASE_REG << PIX1_Y            ),
                       PIX1_DATA_D         = (BASE_REG << PIX1_DATA         );


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en_i & (per_addr_i[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr_i[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (GFX_CTRL_D          &  {DEC_SZ{(reg_addr == GFX_CTRL          )}})  |
                               (GFX_STATUS_D        &  {DEC_SZ{(reg_addr == GFX_STATUS        )}})  |
                               (GFX_IRQ_D           &  {DEC_SZ{(reg_addr == GFX_IRQ           )}})  |

                               (DISPLAY_WIDTH_D     &  {DEC_SZ{(reg_addr == DISPLAY_WIDTH     )}})  |
                               (DISPLAY_HEIGHT_D    &  {DEC_SZ{(reg_addr == DISPLAY_HEIGHT    )}})  |
                               (DISPLAY_SIZE_HI_D   &  {DEC_SZ{(reg_addr == DISPLAY_SIZE_HI   )}})  |
                               (DISPLAY_SIZE_LO_D   &  {DEC_SZ{(reg_addr == DISPLAY_SIZE_LO   )}})  |
                               (DISPLAY_CFG_D       &  {DEC_SZ{(reg_addr == DISPLAY_CFG       )}})  |

                               (LT24_CFG_D          &  {DEC_SZ{(reg_addr == LT24_CFG          )}})  |
                               (LT24_REFRESH_D      &  {DEC_SZ{(reg_addr == LT24_REFRESH      )}})  |
                               (LT24_REFRESH_SYNC_D &  {DEC_SZ{(reg_addr == LT24_REFRESH_SYNC )}})  |
                               (LT24_CMD_D          &  {DEC_SZ{(reg_addr == LT24_CMD          )}})  |
                               (LT24_CMD_PARAM_D    &  {DEC_SZ{(reg_addr == LT24_CMD_PARAM    )}})  |
                               (LT24_CMD_DFILL_D    &  {DEC_SZ{(reg_addr == LT24_CMD_DFILL    )}})  |
                               (LT24_STATUS_D       &  {DEC_SZ{(reg_addr == LT24_STATUS       )}})  |

                               (LUT_RAM_ADDR_HI_D   &  {DEC_SZ{(reg_addr == LUT_RAM_ADDR_HI   )}})  |
                               (LUT_RAM_ADDR_LO_D   &  {DEC_SZ{(reg_addr == LUT_RAM_ADDR_LO   )}})  |
                               (LUT_RAM_DATA_D      &  {DEC_SZ{(reg_addr == LUT_RAM_DATA      )}})  |

                               (FRAME_SELECT_D      &  {DEC_SZ{(reg_addr == FRAME_SELECT      )}})  |
                               (FRAME0_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME0_PTR_HI     )}})  |
                               (FRAME0_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME0_PTR_LO     )}})  |
                               (FRAME1_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME1_PTR_HI     )}})  |
                               (FRAME1_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME1_PTR_LO     )}})  |
                               (FRAME2_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME2_PTR_HI     )}})  |
                               (FRAME2_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME2_PTR_LO     )}})  |
                               (FRAME3_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME3_PTR_HI     )}})  |
                               (FRAME3_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME3_PTR_LO     )}})  |

                               (VID_RAM0_ADDR_HI_D  &  {DEC_SZ{(reg_addr == VID_RAM0_ADDR_HI  )}})  |
                               (VID_RAM0_ADDR_LO_D  &  {DEC_SZ{(reg_addr == VID_RAM0_ADDR_LO  )}})  |
                               (VID_RAM0_DATA_D     &  {DEC_SZ{(reg_addr == VID_RAM0_DATA     )}})  |

                               (VID_RAM1_ADDR_HI_D  &  {DEC_SZ{(reg_addr == VID_RAM1_ADDR_HI  )}})  |
                               (VID_RAM1_ADDR_LO_D  &  {DEC_SZ{(reg_addr == VID_RAM1_ADDR_LO  )}})  |
                               (VID_RAM1_DATA_D     &  {DEC_SZ{(reg_addr == VID_RAM1_DATA     )}})  |

                               (PIX0_WIDTH_D        &  {DEC_SZ{(reg_addr == PIX0_WIDTH        )}})  |
                               (PIX0_HEIGHT_D       &  {DEC_SZ{(reg_addr == PIX0_HEIGHT       )}})  |
                               (PIX0_X_D            &  {DEC_SZ{(reg_addr == PIX0_X            )}})  |
                               (PIX0_Y_D            &  {DEC_SZ{(reg_addr == PIX0_Y            )}})  |
                               (PIX0_DATA_D         &  {DEC_SZ{(reg_addr == PIX0_DATA         )}})  |

                               (PIX1_WIDTH_D        &  {DEC_SZ{(reg_addr == PIX1_WIDTH        )}})  |
                               (PIX1_HEIGHT_D       &  {DEC_SZ{(reg_addr == PIX1_HEIGHT       )}})  |
                               (PIX1_X_D            &  {DEC_SZ{(reg_addr == PIX1_X            )}})  |
                               (PIX1_Y_D            &  {DEC_SZ{(reg_addr == PIX1_Y            )}})  |
                               (PIX1_DATA_D         &  {DEC_SZ{(reg_addr == PIX1_DATA         )}});

// Read/Write probes
wire              reg_write =  |per_we_i & reg_sel;
wire              reg_read  = ~|per_we_i & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};

// Other wire declarations
wire       [31:0] frame0_ptr;
wire       [31:0] frame1_ptr;
wire       [31:0] frame2_ptr;
wire       [31:0] frame3_ptr;
wire       [31:0] vid_ram0_base_addr;
wire       [31:0] vid_ram1_base_addr;

//============================================================================
// 3) REGISTERS
//============================================================================

//------------------------------------------------
// GFX_CTRL Register
//------------------------------------------------
reg  [15:0] gfx_ctrl;

wire        gfx_ctrl_wr = reg_wr[GFX_CTRL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          gfx_ctrl <=  16'h0000;
  else if (gfx_ctrl_wr) gfx_ctrl <=  per_din_i;

// Bitfield assignments
wire        gfx_irq_done_en  =  gfx_ctrl[0];
wire        gfx_irq_start_en =  gfx_ctrl[0];
assign      gfx_mode_o       =  gfx_ctrl[10:8]; // 1xx: 16 bits-per-pixel
                                                // 011:  8 bits-per-pixel
                                                // 010:  4 bits-per-pixel
                                                // 001:  2 bits-per-pixel
                                                // 000:  1 bits-per-pixel

//------------------------------------------------
// GFX_STATUS Register
//------------------------------------------------
wire  [15:0] gfx_status;

assign       gfx_status[0]    = lt24_status_i[2]; // Screen Refresh is busy
assign       gfx_status[15:1] = 15'h0000;

//------------------------------------------------
// GFX_IRQ Register
//------------------------------------------------
wire [15:0] gfx_irq;

// Clear IRQ when 1 is written. Set IRQ when FSM is done
wire        gfx_irq_screen_done_clr   = per_din_i[0] & reg_wr[GFX_IRQ];
wire        gfx_irq_screen_done_set   = lt24_done_evt_i;

wire        gfx_irq_screen_start_clr  = per_din_i[1] & reg_wr[GFX_IRQ];
wire        gfx_irq_screen_start_set  = lt24_start_evt_i;

reg         gfx_irq_screen_done;
reg         gfx_irq_screen_start;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       gfx_irq_screen_done  <=  1'b0;
       gfx_irq_screen_start <=  1'b0;
    end
  else
    begin
       gfx_irq_screen_done  <=  (gfx_irq_screen_done_set  | (~gfx_irq_screen_done_clr  & gfx_irq_screen_done)) ; // IRQ set has priority over clear
       gfx_irq_screen_start <=  (gfx_irq_screen_start_set | (~gfx_irq_screen_start_clr & gfx_irq_screen_start)); // IRQ set has priority over clear
    end

assign  gfx_irq   = {14'h0000, gfx_irq_screen_start, gfx_irq_screen_done};

assign  irq_gfx_o = (gfx_irq_screen_done  & gfx_irq_done_en) |
                    (gfx_irq_screen_start & gfx_irq_start_en);    // Graphic Controller interrupt

//------------------------------------------------
// DISPLAY_WIDTH Register
//------------------------------------------------
reg  [15:0] display_width_o;

wire        display_width_wr = reg_wr[DISPLAY_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               display_width_o <=  16'h0000;
  else if (display_width_wr) display_width_o <=  per_din_i;

//------------------------------------------------
// DISPLAY_HEIGHT Register
//------------------------------------------------
reg  [15:0] display_height_o;

wire        display_height_wr = reg_wr[DISPLAY_HEIGHT];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                display_height_o <=  16'h0000;
  else if (display_height_wr) display_height_o <=  per_din_i;

//------------------------------------------------
// DISPLAY_SIZE_HI Register
//------------------------------------------------
reg  [15:0] display_size_hi;

wire        display_size_hi_wr = reg_wr[DISPLAY_SIZE_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 display_size_hi <=  16'h0000;
  else if (display_size_hi_wr) display_size_hi <=  per_din_i;

//------------------------------------------------
// DISPLAY_SIZE_LO Register
//------------------------------------------------
reg  [15:0] display_size_lo;

wire        display_size_lo_wr = reg_wr[DISPLAY_SIZE_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 display_size_lo <=  16'h0000;
  else if (display_size_lo_wr) display_size_lo <=  per_din_i;

assign display_size_o = {display_size_hi, display_size_lo};

//------------------------------------------------
// DISPLAY_CFG Register
//------------------------------------------------
reg   display_x_swap_o;
reg   display_y_swap_o;
reg   display_cl_swap_o;

wire  display_cfg_wr = reg_wr[DISPLAY_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       display_x_swap_o  <=  1'b0;
       display_y_swap_o  <=  1'b0;
       display_cl_swap_o <=  1'b0;
    end
  else if (display_cfg_wr)
    begin
       display_x_swap_o  <=  per_din_i[0];
       display_y_swap_o  <=  per_din_i[1];
       display_cl_swap_o <=  per_din_i[2];
    end

wire [15:0] display_cfg = {13'h0000,
                           display_cl_swap_o,
                           display_y_swap_o,
                           display_x_swap_o};

//------------------------------------------------
// LT24_CFG Register
//------------------------------------------------
reg  [15:0] lt24_cfg;

wire        lt24_cfg_wr = reg_wr[LT24_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          lt24_cfg <=  16'h0000;
  else if (lt24_cfg_wr) lt24_cfg <=  per_din_i;

// Bitfield assignments
assign     lt24_cfg_clk_o  =  lt24_cfg[6:4];
assign     lt24_reset_n_o  = ~lt24_cfg[1];
assign     lt24_on_o       =  lt24_cfg[0];

//------------------------------------------------
// LT24_REFRESH Register
//------------------------------------------------
reg        lt24_cmd_refr_o;
reg [11:0] lt24_cfg_refr_o;

wire      lt24_refresh_wr   = reg_wr[LT24_REFRESH];
wire      lt24_cmd_refr_clr = lt24_done_evt_i & lt24_status_i[2] & (lt24_cfg_refr_o==8'h00); // Auto-clear in manual refresh mode when done

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cmd_refr_o      <=  1'h0;
  else if (lt24_refresh_wr)   lt24_cmd_refr_o      <=  per_din_i[0];
  else if (lt24_cmd_refr_clr) lt24_cmd_refr_o      <=  1'h0;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cfg_refr_o      <=  12'h000;
  else if (lt24_refresh_wr)   lt24_cfg_refr_o      <=  per_din_i[15:4];

wire [15:0] lt24_refresh = {lt24_cfg_refr_o, 3'h0, lt24_cmd_refr_o};

//------------------------------------------------
// LT24_REFRESH Register
//------------------------------------------------
reg        lt24_cfg_refr_sync_en_o;
reg  [9:0] lt24_cfg_refr_sync_val_o;

wire       lt24_refresh_sync_wr   = reg_wr[LT24_REFRESH_SYNC];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   lt24_cfg_refr_sync_en_o  <=  1'h0;
  else if (lt24_refresh_sync_wr) lt24_cfg_refr_sync_en_o  <=  per_din_i[15];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   lt24_cfg_refr_sync_val_o <=  10'h000;
  else if (lt24_refresh_sync_wr) lt24_cfg_refr_sync_val_o <=  per_din_i[9:0];

wire [15:0] lt24_refresh_sync = {lt24_cfg_refr_sync_en_o, 5'h00, lt24_cfg_refr_sync_val_o};


//------------------------------------------------
// LT24_CMD Register
//------------------------------------------------
reg  [15:0] lt24_cmd;

wire        lt24_cmd_wr = reg_wr[LT24_CMD];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          lt24_cmd <=  16'h0000;
  else if (lt24_cmd_wr) lt24_cmd <=  per_din_i;

assign     lt24_cmd_val_o       = lt24_cmd[7:0];
assign     lt24_cmd_has_param_o = lt24_cmd[8];

//------------------------------------------------
// LT24_CMD_PARAM Register
//------------------------------------------------
reg  [15:0] lt24_cmd_param_o;

wire        lt24_cmd_param_wr = reg_wr[LT24_CMD_PARAM];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cmd_param_o <=  16'h0000;
  else if (lt24_cmd_param_wr) lt24_cmd_param_o <=  per_din_i;

reg lt24_cmd_param_rdy_o;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lt24_cmd_param_rdy_o <=  1'b0;
  else         lt24_cmd_param_rdy_o <=  lt24_cmd_param_wr;

//------------------------------------------------
// LT24_CMD_DFILL Register
//------------------------------------------------
reg  [15:0] lt24_cmd_dfill_o;

assign      lt24_cmd_dfill_wr_o = reg_wr[LT24_CMD_DFILL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                  lt24_cmd_dfill_o <=  16'h0000;
  else if (lt24_cmd_dfill_wr_o) lt24_cmd_dfill_o <=  per_din_i;

//------------------------------------------------
// LT24_STATUS Register
//------------------------------------------------
wire  [15:0] lt24_status;

assign       lt24_status[0]    = lt24_status_i[0]; // FSM_BUSY
assign       lt24_status[1]    = lt24_status_i[1]; // WAIT_PARAM
assign       lt24_status[2]    = lt24_status_i[2]; // REFRESH_BUSY
assign       lt24_status[3]    = lt24_status_i[3]; // WAIT_FOR_SCANLINE
assign       lt24_status[4]    = lt24_status_i[4]; // DATA_FILL_BUSY
assign       lt24_status[15:5] = 11'h000;


//------------------------------------------------
// LUT_RAM_ADDR_HI Register
//------------------------------------------------
// LUT RAM size:
//                - Text-Mode (8x8 per char) : 1024 x 16-bit
//                - 16 bits-per-pixel        :    0 x 16-bit
//                -  8 bits-per-pixel        :  256 x 16-bit
//                -  4 bits-per-pixel        :                16 x 16-bit
//                -  2 bits-per-pixel        :                 4 x 16-bit
//                -  1 bits-per-pixel        :                 2 x 16-bit
//                                            ----------------------------
//                                             1280 x 16-bit

reg  [15:0] lut_ram_addr_hi;
wire [31:0] lut_ram_addr_inc;
wire        lut_ram_addr_inc_wr;

wire        lut_ram_addr_hi_wr = reg_wr[LUT_RAM_ADDR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                  lut_ram_addr_hi <=  16'h0000;
  else if (lut_ram_addr_hi_wr)  lut_ram_addr_hi <=  per_din_i;
  else if (lut_ram_addr_inc_wr) lut_ram_addr_hi <=  lut_ram_addr_inc[31:16];

//------------------------------------------------
// LUT_RAM_ADDR_LO Register
//------------------------------------------------
reg  [15:0] lut_ram_addr_lo;

wire        lut_ram_addr_lo_wr = reg_wr[LUT_RAM_ADDR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                  lut_ram_addr_lo <=  16'h0000;
  else if (lut_ram_addr_lo_wr)  lut_ram_addr_lo <=  per_din_i;
  else if (lut_ram_addr_inc_wr) lut_ram_addr_lo <=  lut_ram_addr_inc[15:0];

assign lut_ram_addr_o      = {lut_ram_addr_hi, lut_ram_addr_lo};
assign lut_ram_addr_inc    = lut_ram_addr_o + 32'h00000001;

//------------------------------------------------
// LUT_RAM_DATA Register
//------------------------------------------------

// Update the LUT_RAM_DATA register with regular register write access
wire        lut_ram_data_wr  = reg_wr[LUT_RAM_DATA];
wire        lut_ram_data_rd  = reg_rd[LUT_RAM_DATA];
reg         lut_ram_dout_rdy;

// LUT-RAM data Register
reg  [15:0] lut_ram_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               lut_ram_data <=  16'h0000;
  else if (lut_ram_data_wr)  lut_ram_data <=  per_din_i;
  else if (lut_ram_dout_rdy) lut_ram_data <=  lut_ram_dout_i;

// Increment the address after a write or read access to the LUT_RAM_DATA register
assign lut_ram_addr_inc_wr = lut_ram_data_wr | lut_ram_data_rd;

// Apply peripheral data bus % write strobe during VID_RAMx_DATA write access
assign lut_ram_din_o       =   per_din_i & {16{lut_ram_data_wr}};
assign lut_ram_wen_o       = ~(per_we_i  & { 2{lut_ram_data_wr}});

// Trigger a LUT-RAM read access immediately after:
//   - a LUT-RAM_ADDR_LO register write access
//   - a LUT-RAM_DATA register read access
reg lut_ram_addr_lo_wr_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_addr_lo_wr_dly <= 1'b0;
  else         lut_ram_addr_lo_wr_dly <= lut_ram_addr_lo_wr;

reg  lut_ram_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_data_rd_dly    <= 1'b0;
  else         lut_ram_data_rd_dly    <= lut_ram_data_rd;

// Chip enable.
// Note: we perform a data read access:
//       - one cycle after a VID_RAM_DATA register read access (so that the address has been incremented)
//       - one cycle after a VID_RAM_ADDR_LO register write
assign lut_ram_cen_o = ~(lut_ram_addr_lo_wr_dly | lut_ram_data_rd_dly | // Read access
                         lut_ram_data_wr);                              // Write access

// Update the VRAM_DATA register one cycle after each memory access
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_dout_rdy <= 1'b0;
  else         lut_ram_dout_rdy <= ~lut_ram_cen_o;

//------------------------------------------------
// FRAME_SELECT Register
//------------------------------------------------
reg  [15:0] frame_select;

wire        frame_select_wr = reg_wr[FRAME_SELECT];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)              frame_select <=  16'h0000;
  else if (frame_select_wr) frame_select <=  per_din_i;

// Frame pointer selections
assign refresh_frame_addr_o  = (frame_select[1:0]==0) ? frame0_ptr :
                               (frame_select[1:0]==1) ? frame1_ptr :
                               (frame_select[1:0]==2) ? frame2_ptr :
                                                        frame3_ptr;

assign vid_ram0_base_addr    = (frame_select[5:4]==0) ? frame0_ptr :
                               (frame_select[5:4]==1) ? frame1_ptr :
                               (frame_select[5:4]==2) ? frame2_ptr :
                                                        frame3_ptr;

assign vid_ram1_base_addr    = (frame_select[7:6]==0) ? frame0_ptr :
                               (frame_select[7:6]==1) ? frame1_ptr :
                               (frame_select[7:6]==2) ? frame2_ptr :
                                                        frame3_ptr;

//------------------------------------------------
// FRAME0_PTR_HI Register
//------------------------------------------------
reg  [15:0] frame0_ptr_hi;

wire        frame0_ptr_hi_wr = reg_wr[FRAME0_PTR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame0_ptr_hi <=  16'h0000;
  else if (frame0_ptr_hi_wr) frame0_ptr_hi <=  per_din_i;

//------------------------------------------------
// FRAME0_PTR_LO Register
//------------------------------------------------
reg  [15:0] frame0_ptr_lo;

wire        frame0_ptr_lo_wr = reg_wr[FRAME0_PTR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame0_ptr_lo <=  16'h0000;
  else if (frame0_ptr_lo_wr) frame0_ptr_lo <=  per_din_i;

assign frame0_ptr = {frame0_ptr_hi, frame0_ptr_lo};

//------------------------------------------------
// FRAME1_PTR_HI Register
//------------------------------------------------
reg  [15:0] frame1_ptr_hi;

wire        frame1_ptr_hi_wr = reg_wr[FRAME1_PTR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame1_ptr_hi <=  16'h0000;
  else if (frame1_ptr_hi_wr) frame1_ptr_hi <=  per_din_i;

//------------------------------------------------
// FRAME1_PTR_LO Register
//------------------------------------------------
reg  [15:0] frame1_ptr_lo;

wire        frame1_ptr_lo_wr = reg_wr[FRAME1_PTR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame1_ptr_lo <=  16'h0000;
  else if (frame1_ptr_lo_wr) frame1_ptr_lo <=  per_din_i;

assign frame1_ptr = {frame1_ptr_hi, frame1_ptr_lo};

//------------------------------------------------
// FRAME2_PTR_HI Register
//------------------------------------------------
reg  [15:0] frame2_ptr_hi;

wire        frame2_ptr_hi_wr = reg_wr[FRAME2_PTR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame2_ptr_hi <=  16'h0000;
  else if (frame2_ptr_hi_wr) frame2_ptr_hi <=  per_din_i;

//------------------------------------------------
// FRAME2_PTR_LO Register
//------------------------------------------------
reg  [15:0] frame2_ptr_lo;

wire        frame2_ptr_lo_wr = reg_wr[FRAME2_PTR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame2_ptr_lo <=  16'h0000;
  else if (frame2_ptr_lo_wr) frame2_ptr_lo <=  per_din_i;

assign frame2_ptr = {frame2_ptr_hi, frame2_ptr_lo};

//------------------------------------------------
// FRAME3_PTR_HI Register
//------------------------------------------------
reg  [15:0] frame3_ptr_hi;

wire        frame3_ptr_hi_wr = reg_wr[FRAME3_PTR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame3_ptr_hi <=  16'h0000;
  else if (frame3_ptr_hi_wr) frame3_ptr_hi <=  per_din_i;

//------------------------------------------------
// FRAME3_PTR_LO Register
//------------------------------------------------
reg  [15:0] frame3_ptr_lo;

wire        frame3_ptr_lo_wr = reg_wr[FRAME3_PTR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame3_ptr_lo <=  16'h0000;
  else if (frame3_ptr_lo_wr) frame3_ptr_lo <=  per_din_i;

assign frame3_ptr = {frame3_ptr_hi, frame3_ptr_lo};

//------------------------------------------------
// VID_RAM0_ADDR_HI Register
//------------------------------------------------
reg  [15:0] vid_ram0_addr_hi;
wire [31:0] vid_ram0_addr;
wire [31:0] vid_ram0_addr_inc;
wire        vid_ram0_addr_inc_wr;

wire        vid_ram0_addr_hi_wr = reg_wr[VID_RAM0_ADDR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram0_addr_hi <=  16'h0000;
  else if (vid_ram0_addr_hi_wr)  vid_ram0_addr_hi <=  per_din_i;
  else if (vid_ram0_addr_inc_wr) vid_ram0_addr_hi <=  vid_ram0_addr_inc[31:16];

//------------------------------------------------
// VID_RAM0_ADDR_LO Register
//------------------------------------------------
reg  [15:0] vid_ram0_addr_lo;

wire        vid_ram0_addr_lo_wr = reg_wr[VID_RAM0_ADDR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram0_addr_lo <=  16'h0000;
  else if (vid_ram0_addr_lo_wr)  vid_ram0_addr_lo <=  per_din_i;
  else if (vid_ram0_addr_inc_wr) vid_ram0_addr_lo <=  vid_ram0_addr_inc[15:0];

assign vid_ram0_addr        = {vid_ram0_addr_hi, vid_ram0_addr_lo};
assign vid_ram0_addr_inc    = vid_ram0_addr + 32'h00000001;

//------------------------------------------------
// VID_RAM0_DATA Register
//------------------------------------------------

// Update the VID_RAM0_DATA register with regular register write access
wire        vid_ram0_data_wr     = reg_wr[VID_RAM0_DATA];
wire        vid_ram0_data_rd     = reg_rd[VID_RAM0_DATA];
wire        vid_ram0_dout_rdy;

// VIDEO-RAM data Register
reg  [15:0] vid_ram0_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                vid_ram0_data <=  16'h0000;
  else if (vid_ram0_data_wr)  vid_ram0_data <=  per_din_i;
  else if (vid_ram0_dout_rdy) vid_ram0_data <=  vid_ram_dout_i;

//------------------------------------------------
// VID_RAM1_ADDR_HI Register
//------------------------------------------------
reg  [15:0] vid_ram1_addr_hi;
wire [31:0] vid_ram1_addr;
wire [31:0] vid_ram1_addr_inc;
wire        vid_ram1_addr_inc_wr;

wire        vid_ram1_addr_hi_wr = reg_wr[VID_RAM1_ADDR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram1_addr_hi <=  16'h0000;
  else if (vid_ram1_addr_hi_wr)  vid_ram1_addr_hi <=  per_din_i;
  else if (vid_ram1_addr_inc_wr) vid_ram1_addr_hi <=  vid_ram1_addr_inc[31:16];

//------------------------------------------------
// VID_RAM1_ADDR_LO Register
//------------------------------------------------
reg  [15:0] vid_ram1_addr_lo;

wire        vid_ram1_addr_lo_wr = reg_wr[VID_RAM1_ADDR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram1_addr_lo <=  16'h0000;
  else if (vid_ram1_addr_lo_wr)  vid_ram1_addr_lo <=  per_din_i;
  else if (vid_ram1_addr_inc_wr) vid_ram1_addr_lo <=  vid_ram1_addr_inc[15:0];

assign vid_ram1_addr        = {vid_ram1_addr_hi, vid_ram1_addr_lo};
assign vid_ram1_addr_inc    = vid_ram1_addr + 32'h00000001;

//------------------------------------------------
// VID_RAM1_DATA Register
//------------------------------------------------

// Update the VID_RAM0_DATA register with regular register write access
wire        vid_ram1_data_wr  = reg_wr[VID_RAM1_DATA];
wire        vid_ram1_data_rd  = reg_rd[VID_RAM1_DATA];
wire        vid_ram1_dout_rdy;

// VIDEO-RAM data Register
reg  [15:0] vid_ram1_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 vid_ram1_data <=  16'h0000;
  else if (vid_ram1_data_wr)   vid_ram1_data <=  per_din_i;
  else if (vid_ram1_dout_rdy)  vid_ram1_data <=  vid_ram_dout_i;

//------------------------------------------------
// PIX0_WIDTH Register
//------------------------------------------------
reg  [15:0] pix0_width;

wire        pix0_width_wr = reg_wr[PIX0_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            pix0_width <=  16'h0000;
  else if (pix0_width_wr) pix0_width <=  per_din_i;

//------------------------------------------------
// PIX0_HEIGHT Register
//------------------------------------------------
reg  [15:0] pix0_height;

wire        pix0_height_wr = reg_wr[PIX0_HEIGHT];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             pix0_height <=  16'h0000;
  else if (pix0_height_wr) pix0_height <=  per_din_i;

//------------------------------------------------
// PIX0_X Register
//------------------------------------------------
reg  [15:0] pix0_x;

wire        pix0_x_wr = reg_wr[PIX0_X];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        pix0_x <=  16'h0000;
  else if (pix0_x_wr) pix0_x <=  per_din_i;

//------------------------------------------------
// PIX0_Y Register
//------------------------------------------------
reg  [15:0] pix0_y;

wire        pix0_y_wr = reg_wr[PIX0_Y];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        pix0_y <=  16'h0000;
  else if (pix0_y_wr) pix0_y <=  per_din_i;

//------------------------------------------------
// PIX0_DATA Register
//------------------------------------------------
reg  [15:0] pix0_data;

wire        pix0_data_wr = reg_wr[PIX0_DATA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)           pix0_data <=  16'h0000;
  else if (pix0_data_wr) pix0_data <=  per_din_i;

//------------------------------------------------
// PIX1_WIDTH Register
//------------------------------------------------
reg  [15:0] pix1_width;

wire        pix1_width_wr = reg_wr[PIX1_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            pix1_width <=  16'h0000;
  else if (pix1_width_wr) pix1_width <=  per_din_i;

//------------------------------------------------
// PIX1_HEIGHT Register
//------------------------------------------------
reg  [15:0] pix1_height;

wire        pix1_height_wr = reg_wr[PIX1_HEIGHT];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             pix1_height <=  16'h0000;
  else if (pix1_height_wr) pix1_height <=  per_din_i;

//------------------------------------------------
// PIX1_X Register
//------------------------------------------------
reg  [15:0] pix1_x;

wire        pix1_x_wr = reg_wr[PIX1_X];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        pix1_x <=  16'h0000;
  else if (pix1_x_wr) pix1_x <=  per_din_i;

//------------------------------------------------
// PIX1_Y Register
//------------------------------------------------
reg  [15:0] pix1_y;

wire        pix1_y_wr = reg_wr[PIX1_Y];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        pix1_y <=  16'h0000;
  else if (pix1_y_wr) pix1_y <=  per_din_i;

//------------------------------------------------
// PIX1_DATA Register
//------------------------------------------------
reg  [15:0] pix1_data;

wire        pix1_data_wr = reg_wr[PIX1_DATA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)           pix1_data <=  16'h0000;
  else if (pix1_data_wr) pix1_data <=  per_din_i;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] gfx_ctrl_read          = gfx_ctrl          & {16{reg_rd[GFX_CTRL          ]}};
wire [15:0] gfx_status_read        = gfx_status        & {16{reg_rd[GFX_STATUS        ]}};
wire [15:0] gfx_irq_read           = gfx_irq           & {16{reg_rd[GFX_IRQ           ]}};

wire [15:0] display_width_read     = display_width_o   & {16{reg_rd[DISPLAY_WIDTH     ]}};
wire [15:0] display_height_read    = display_height_o  & {16{reg_rd[DISPLAY_HEIGHT    ]}};
wire [15:0] display_size_hi_read   = display_size_hi   & {16{reg_rd[DISPLAY_SIZE_HI   ]}};
wire [15:0] display_size_lo_read   = display_size_lo   & {16{reg_rd[DISPLAY_SIZE_LO   ]}};
wire [15:0] display_cfg_read       = display_cfg       & {16{reg_rd[DISPLAY_CFG       ]}};

wire [15:0] lt24_cfg_read          = lt24_cfg          & {16{reg_rd[LT24_CFG          ]}};
wire [15:0] lt24_refresh_read      = lt24_refresh      & {16{reg_rd[LT24_REFRESH      ]}};
wire [15:0] lt24_refresh_sync_read = lt24_refresh_sync & {16{reg_rd[LT24_REFRESH_SYNC ]}};
wire [15:0] lt24_cmd_read          = lt24_cmd          & {16{reg_rd[LT24_CMD          ]}};
wire [15:0] lt24_cmd_param_read    = lt24_cmd_param_o  & {16{reg_rd[LT24_CMD_PARAM    ]}};
wire [15:0] lt24_cmd_dfill_read    = lt24_cmd_dfill_o  & {16{reg_rd[LT24_CMD_DFILL    ]}};
wire [15:0] lt24_status_read       = lt24_status       & {16{reg_rd[LT24_STATUS       ]}};

wire [15:0] lut_ram_addr_hi_read   = lut_ram_addr_hi   & {16{reg_rd[LUT_RAM_ADDR_HI   ]}};
wire [15:0] lut_ram_addr_lo_read   = lut_ram_addr_lo   & {16{reg_rd[LUT_RAM_ADDR_LO   ]}};
wire [15:0] lut_ram_data_read      = lut_ram_data      & {16{reg_rd[LUT_RAM_DATA      ]}};

wire [15:0] frame_select_read      = frame_select      & {16{reg_rd[FRAME_SELECT      ]}};
wire [15:0] frame0_ptr_hi_read     = frame0_ptr_hi     & {16{reg_rd[FRAME0_PTR_HI     ]}};
wire [15:0] frame0_ptr_lo_read     = frame0_ptr_lo     & {16{reg_rd[FRAME0_PTR_LO     ]}};
wire [15:0] frame1_ptr_hi_read     = frame1_ptr_hi     & {16{reg_rd[FRAME1_PTR_HI     ]}};
wire [15:0] frame1_ptr_lo_read     = frame1_ptr_lo     & {16{reg_rd[FRAME1_PTR_LO     ]}};
wire [15:0] frame2_ptr_hi_read     = frame2_ptr_hi     & {16{reg_rd[FRAME2_PTR_HI     ]}};
wire [15:0] frame2_ptr_lo_read     = frame2_ptr_lo     & {16{reg_rd[FRAME2_PTR_LO     ]}};
wire [15:0] frame3_ptr_hi_read     = frame3_ptr_hi     & {16{reg_rd[FRAME3_PTR_HI     ]}};
wire [15:0] frame3_ptr_lo_read     = frame3_ptr_lo     & {16{reg_rd[FRAME3_PTR_LO     ]}};

wire [15:0] vid_ram0_addr_hi_read  = vid_ram0_addr_hi  & {16{reg_rd[VID_RAM0_ADDR_HI  ]}};
wire [15:0] vid_ram0_addr_lo_read  = vid_ram0_addr_lo  & {16{reg_rd[VID_RAM0_ADDR_LO  ]}};
wire [15:0] vid_ram0_data_read     = vid_ram0_data     & {16{reg_rd[VID_RAM0_DATA     ]}};

wire [15:0] vid_ram1_addr_hi_read  = vid_ram1_addr_hi  & {16{reg_rd[VID_RAM1_ADDR_HI  ]}};
wire [15:0] vid_ram1_addr_lo_read  = vid_ram1_addr_lo  & {16{reg_rd[VID_RAM1_ADDR_LO  ]}};
wire [15:0] vid_ram1_data_read     = vid_ram1_data     & {16{reg_rd[VID_RAM1_DATA     ]}};

wire [15:0] pix0_width_read        = pix0_width        & {16{reg_rd[PIX0_WIDTH        ]}};
wire [15:0] pix0_height_read       = pix0_height       & {16{reg_rd[PIX0_HEIGHT       ]}};
wire [15:0] pix0_x_read            = pix0_x            & {16{reg_rd[PIX0_X            ]}};
wire [15:0] pix0_y_read            = pix0_y            & {16{reg_rd[PIX0_Y            ]}};
wire [15:0] pix0_data_read         = pix0_data         & {16{reg_rd[PIX0_DATA         ]}};

wire [15:0] pix1_width_read        = pix1_width        & {16{reg_rd[PIX1_WIDTH        ]}};
wire [15:0] pix1_height_read       = pix1_height       & {16{reg_rd[PIX1_HEIGHT       ]}};
wire [15:0] pix1_x_read            = pix1_x            & {16{reg_rd[PIX1_X            ]}};
wire [15:0] pix1_y_read            = pix1_y            & {16{reg_rd[PIX1_Y            ]}};
wire [15:0] pix1_data_read         = pix1_data         & {16{reg_rd[PIX1_DATA         ]}};

wire [15:0] per_dout_o             = gfx_ctrl_read          |
                                     gfx_status_read        |
                                     gfx_irq_read           |

                                     display_width_read     |
                                     display_height_read    |
                                     display_size_hi_read   |
                                     display_size_lo_read   |
                                     display_cfg_read       |

                                     lt24_cfg_read          |
                                     lt24_refresh_read      |
                                     lt24_refresh_sync_read |
                                     lt24_cmd_read          |
                                     lt24_cmd_param_read    |
                                     lt24_cmd_dfill_read    |
                                     lt24_status_read       |

                                     lut_ram_addr_hi_read   |
                                     lut_ram_addr_lo_read   |
                                     lut_ram_data_read      |

                                     frame_select_read      |
                                     frame0_ptr_hi_read     |
                                     frame0_ptr_lo_read     |
                                     frame1_ptr_hi_read     |
                                     frame1_ptr_lo_read     |
                                     frame2_ptr_hi_read     |
                                     frame2_ptr_lo_read     |
                                     frame3_ptr_hi_read     |
                                     frame3_ptr_lo_read     |

                                     vid_ram0_addr_hi_read  |
                                     vid_ram0_addr_lo_read  |
                                     vid_ram0_data_read     |

                                     vid_ram1_addr_hi_read  |
                                     vid_ram1_addr_lo_read  |
                                     vid_ram1_data_read     |

                                     pix0_width_read        |
                                     pix0_height_read       |
                                     pix0_x_read            |
                                     pix0_y_read            |
                                     pix0_data_read         |

                                     pix1_width_read        |
                                     pix1_height_read       |
                                     pix1_x_read            |
                                     pix1_y_read            |
                                     pix1_data_read;


//============================================================================
// 5) VIDEO MEMORY INTERFACE
//============================================================================
//
// Trigger a VIDEO-RAM write access after:
//   - a VID_RAMx_DATA register write access
//
// Trigger a VIDEO-RAM read access immediately after:
//   - a VID_RAMx_ADDR_LO register write access
//   - a VID_RAMx_DATA register read access
//

//--------------------------------------------------
// VID_RAM0: Delay software read and write strobes
//--------------------------------------------------

// Strobe writing to VID_RAMx_ADDR_LO register
reg        vid_ram0_addr_lo_wr_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_addr_lo_wr_dly <= 1'b0;
  else         vid_ram0_addr_lo_wr_dly <= vid_ram0_addr_lo_wr;

// Strobe reading from VID_RAMx_DATA register
reg        vid_ram0_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_data_rd_dly    <= 1'b0;
  else         vid_ram0_data_rd_dly    <= vid_ram0_data_rd;

// Strobe writing to VID_RAMx_DATA register
reg  [1:0] vid_ram0_data_wr_dly;
wire [1:0] vid_ram0_data_wr_nodly = per_we_i & {2{vid_ram0_data_wr}};
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_data_wr_dly    <= 2'b00;
  else         vid_ram0_data_wr_dly    <= vid_ram0_data_wr_nodly;

//--------------------------------------------------
// VID_RAM1: Delay software read and write strobes
//--------------------------------------------------

// Strobe writing to VID_RAMx_ADDR_LO register
reg        vid_ram1_addr_lo_wr_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_addr_lo_wr_dly <= 1'b0;
  else         vid_ram1_addr_lo_wr_dly <= vid_ram1_addr_lo_wr;

// Strobe reading from VID_RAMx_DATA register
reg        vid_ram1_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_data_rd_dly    <= 1'b0;
  else         vid_ram1_data_rd_dly    <= vid_ram1_data_rd;

// Strobe writing to VID_RAMx_DATA register
reg  [1:0] vid_ram1_data_wr_dly;
wire [1:0] vid_ram1_data_wr_nodly = per_we_i & {2{vid_ram1_data_wr}};
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_data_wr_dly    <= 2'b00;
  else         vid_ram1_data_wr_dly    <= vid_ram1_data_wr_nodly;

//------------------------------------------------
// Compute VIDEO-RAM Strobes & Data
//------------------------------------------------

// Write access strobe
//       - one cycle after a VID_RAM_DATA register write access
assign vid_ram_wen_o  = ~(vid_ram0_data_wr_dly | vid_ram1_data_wr_dly);

// Chip enable.
// Note: we perform a data read access:
//       - one cycle after a VID_RAM_DATA register read access (so that the address has been incremented)
//       - one cycle after a VID_RAM_ADDR_LO register write
wire    vid_ram0_ce_early = (vid_ram0_addr_lo_wr_dly | vid_ram0_data_rd_dly | // Read access
                             vid_ram0_data_wr);                               // Write access

wire    vid_ram1_ce_early = (vid_ram1_addr_lo_wr_dly | vid_ram1_data_rd_dly | // Read access
                             vid_ram1_data_wr);                               // Write access

reg [1:0] vid_ram0_ce;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_ce <= 2'b00;
  else	       vid_ram0_ce <= {vid_ram0_ce[0], vid_ram0_ce_early};

reg [1:0] vid_ram1_ce;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_ce <= 2'b00;
  else	       vid_ram1_ce <= {vid_ram1_ce[0], vid_ram1_ce_early};

assign vid_ram_cen_o  = ~(vid_ram0_ce[0] | vid_ram1_ce[0]);

// Data to be written
assign vid_ram_din_o  = vid_ram1_ce[0] ? vid_ram1_data : vid_ram0_data;

// Update the VRAM_DATA register one cycle after each memory access
assign vid_ram0_dout_rdy = vid_ram0_ce[1];
assign vid_ram1_dout_rdy = vid_ram1_ce[1];

//------------------------------------------------
// Compute VIDEO-RAM Address
//------------------------------------------------

// Add frame pointer offset
wire [31:0] vid_ram0_addr_offset = vid_ram0_base_addr + vid_ram0_addr;
wire [31:0] vid_ram1_addr_offset = vid_ram1_base_addr + vid_ram1_addr;

// Detect memory accesses for ADDR update
wire        vid_ram0_access   = vid_ram0_data_wr | vid_ram0_data_rd_dly | vid_ram0_addr_lo_wr_dly;
wire        vid_ram1_access   = vid_ram1_data_wr | vid_ram1_data_rd_dly | vid_ram1_addr_lo_wr_dly;

// Generate Video RAM address
reg [31:0] vid_ram_addr_o;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)              vid_ram_addr_o <= {32{1'b0}};
  else if (vid_ram0_access) vid_ram_addr_o <= vid_ram0_addr_offset;
  else if (vid_ram1_access) vid_ram_addr_o <= vid_ram1_addr_offset;

// Increment the address when accessing the VID_RAMx_DATA register:
// - one clock cycle after a write access
// - with the read access
assign vid_ram0_addr_inc_wr = (|vid_ram0_data_wr_dly) | vid_ram0_data_rd;
assign vid_ram1_addr_inc_wr = (|vid_ram1_data_wr_dly) | vid_ram1_data_rd;


endmodule
