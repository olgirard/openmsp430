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
// *File Name: openMSP430_defines.v
// 
// *Module Description:
//                      openMSP430 Configuration file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------
//`define OMSP_NO_INCLUDE
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_undefines.v"
`endif

//============================================================================
//============================================================================
// BASIC SYSTEM CONFIGURATION
//============================================================================
//============================================================================
//
// Note: the sum of program, data and peripheral memory spaces must not
//      exceed 64 kB
//

// Program Memory Size:
//                     Uncomment the required memory size
//-------------------------------------------------------
//`define PMEM_SIZE_59_KB
//`define PMEM_SIZE_55_KB
//`define PMEM_SIZE_54_KB
//`define PMEM_SIZE_51_KB
//`define PMEM_SIZE_48_KB
//`define PMEM_SIZE_41_KB
//`define PMEM_SIZE_32_KB
//`define PMEM_SIZE_24_KB
//`define PMEM_SIZE_16_KB
//`define PMEM_SIZE_12_KB
//`define PMEM_SIZE_8_KB
`define PMEM_SIZE_4_KB
//`define PMEM_SIZE_2_KB
//`define PMEM_SIZE_1_KB


// Data Memory Size:
//                     Uncomment the required memory size
//-------------------------------------------------------
//`define DMEM_SIZE_32_KB
//`define DMEM_SIZE_24_KB
//`define DMEM_SIZE_16_KB
//`define DMEM_SIZE_10_KB
//`define DMEM_SIZE_8_KB
//`define DMEM_SIZE_5_KB
//`define DMEM_SIZE_4_KB
//`define DMEM_SIZE_2p5_KB
//`define DMEM_SIZE_2_KB
//`define DMEM_SIZE_1_KB
//`define DMEM_SIZE_512_B
`define DMEM_SIZE_256_B
//`define DMEM_SIZE_128_B


// Include/Exclude Hardware Multiplier
//`define MULTIPLIER


// Include/Exclude Serial Debug interface
`define DBG_EN


//============================================================================
//============================================================================
// ADVANCED SYSTEM CONFIGURATION (FOR EXPERIENCED USERS)
//============================================================================
//============================================================================

//-------------------------------------------------------
// Peripheral Memory Space:
//-------------------------------------------------------
// The original MSP430 architecture map the peripherals
// from 0x0000 to 0x01FF (i.e. 512B of the memory space).
// The following defines allow you to expand this space
// up to 32 kB (i.e. from 0x0000 to 0x7fff).
// As a consequence, the data memory mapping will be
// shifted up and a custom linker script will therefore
// be required by the GCC compiler.
//-------------------------------------------------------
//`define PER_SIZE_32_KB
//`define PER_SIZE_16_KB
//`define PER_SIZE_8_KB
//`define PER_SIZE_4_KB
//`define PER_SIZE_2_KB
//`define PER_SIZE_1_KB
`define PER_SIZE_512_B


//-------------------------------------------------------
// Defines the debugger CPU_CTL.RST_BRK_EN reset value
// (CPU break on PUC reset)
//-------------------------------------------------------
// When defined, the CPU will automatically break after
// a PUC occurrence by default. This is typically usefull
// when the program memory can only be initialized through
// the serial debug interface.
//-------------------------------------------------------
//`define DBG_RST_BRK_EN


//-------------------------------------------------------
// Custom user version number
//-------------------------------------------------------
// This 5 bit field can be freely used in order to allow
// custom identification of the system where the openMSP430
// is included through the debug interface.
// (see CPU_ID.USER_VERSION field in the documentation)
//-------------------------------------------------------
`define USER_VERSION 5'b00011


//============================================================================
//============================================================================
// EXPERT SYSTEM CONFIGURATION ( !!!! EXPERTS ONLY !!!! )
//============================================================================
//============================================================================
//
// IMPORTANT NOTE:  Please update following configuration options ONLY if
//                 you have a good reason to do so... and if you know what
//                 you are doing :-P
//
//============================================================================

//-------------------------------------------------------
// Number of hardware breakpoint units (each unit contains
// two hardware address breakpoints):
//   - DBG_HWBRK_0 -> Include hardware breakpoints unit 0
//   - DBG_HWBRK_1 -> Include hardware breakpoints unit 1
//   - DBG_HWBRK_2 -> Include hardware breakpoints unit 2
//   - DBG_HWBRK_3 -> Include hardware breakpoints unit 3
//-------------------------------------------------------
// Please keep in mind that hardware breakpoints only
// make sense whenever the program memory is not an SRAM
// (i.e. Flash/OTP/ROM/...) or when you are interested
// in data breakpoints (btw. not supported by GDB).
//-------------------------------------------------------
//`define  DBG_HWBRK_0
//`define  DBG_HWBRK_1
//`define  DBG_HWBRK_2
//`define  DBG_HWBRK_3


//-------------------------------------------------------
// Enable/Disable the hardware breakpoint RANGE mode
//-------------------------------------------------------
// When enabled this feature allows the hardware breakpoint
// units to stop the cpu whenever an instruction or data
// access lays within an address range.
// Note that this feature is not supported by GDB.
//-------------------------------------------------------
//`define DBG_HWBRK_RANGE


//-------------------------------------------------------
// Input synchronizers
//-------------------------------------------------------
// In some cases, the asynchronous input ports might
// already be synchronized externally.
// If an extensive CDC design review showed that this
// is really the case,  the individual synchronizers
// can be disabled with the following defines.
//
// Notes:
//        - the dbg_en signal will reset the debug interface
//         when 0. Therefore make sure it is glitch free.
//
//        - the dbg_uart_rxd synchronizer must be set to 1
//          when its reset is active.
//-------------------------------------------------------
`define SYNC_CPU_EN
`define SYNC_DBG_EN
`define SYNC_DBG_UART_RXD
`define SYNC_NMI



//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//=====        SYSTEM CONSTANTS --- !!!!!!!! DO NOT EDIT !!!!!!!!      =====//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//

//
// PROGRAM, DATA & PERIPHERAL MEMORY CONFIGURATION
//==================================================

// Program Memory Size
`ifdef PMEM_SIZE_59_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     60416
`endif
`ifdef PMEM_SIZE_55_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     56320
`endif
`ifdef PMEM_SIZE_54_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     55296
`endif
`ifdef PMEM_SIZE_51_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     52224
`endif
`ifdef PMEM_SIZE_48_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     49152
`endif
`ifdef PMEM_SIZE_41_KB
  `define PMEM_AWIDTH      15
  `define PMEM_SIZE     41984
`endif
`ifdef PMEM_SIZE_32_KB
  `define PMEM_AWIDTH      14
  `define PMEM_SIZE     32768
`endif
`ifdef PMEM_SIZE_24_KB
  `define PMEM_AWIDTH      14
  `define PMEM_SIZE     24576
`endif
`ifdef PMEM_SIZE_16_KB
  `define PMEM_AWIDTH      13
  `define PMEM_SIZE     16384
`endif
`ifdef PMEM_SIZE_12_KB
  `define PMEM_AWIDTH      13
  `define PMEM_SIZE     12288
`endif
`ifdef PMEM_SIZE_8_KB
  `define PMEM_AWIDTH      12
  `define PMEM_SIZE      8192
`endif
`ifdef PMEM_SIZE_4_KB
  `define PMEM_AWIDTH      11
  `define PMEM_SIZE      4096
`endif
`ifdef PMEM_SIZE_2_KB
  `define PMEM_AWIDTH      10
  `define PMEM_SIZE      2048
`endif
`ifdef PMEM_SIZE_1_KB
  `define PMEM_AWIDTH       9
  `define PMEM_SIZE      1024
`endif

// Data Memory Size
`ifdef DMEM_SIZE_32_KB
  `define DMEM_AWIDTH       14
  `define DMEM_SIZE      32768
`endif
`ifdef DMEM_SIZE_24_KB
  `define DMEM_AWIDTH       14
  `define DMEM_SIZE      24576
`endif
`ifdef DMEM_SIZE_16_KB
  `define DMEM_AWIDTH       13
  `define DMEM_SIZE      16384
`endif
`ifdef DMEM_SIZE_10_KB
  `define DMEM_AWIDTH       13
  `define DMEM_SIZE      10240
`endif
`ifdef DMEM_SIZE_8_KB
  `define DMEM_AWIDTH       12
  `define DMEM_SIZE       8192
`endif
`ifdef DMEM_SIZE_5_KB
  `define DMEM_AWIDTH       12
  `define DMEM_SIZE       5120
`endif
`ifdef DMEM_SIZE_4_KB
  `define DMEM_AWIDTH       11
  `define DMEM_SIZE       4096
`endif
`ifdef DMEM_SIZE_2p5_KB
  `define DMEM_AWIDTH       11
  `define DMEM_SIZE       2560
`endif
`ifdef DMEM_SIZE_2_KB
  `define DMEM_AWIDTH       10
  `define DMEM_SIZE       2048
`endif
`ifdef DMEM_SIZE_1_KB
  `define DMEM_AWIDTH        9
  `define DMEM_SIZE       1024
`endif
`ifdef DMEM_SIZE_512_B
  `define DMEM_AWIDTH        8
  `define DMEM_SIZE        512
`endif
`ifdef DMEM_SIZE_256_B
  `define DMEM_AWIDTH        7
  `define DMEM_SIZE        256
`endif
`ifdef DMEM_SIZE_128_B
  `define DMEM_AWIDTH        6
  `define DMEM_SIZE        128
`endif

// Peripheral Memory Size
`ifdef PER_SIZE_32_KB
  `define PER_AWIDTH        14
  `define PER_SIZE       32768
`endif
`ifdef PER_SIZE_16_KB
  `define PER_AWIDTH        13
  `define PER_SIZE       16384
`endif
`ifdef PER_SIZE_8_KB
  `define PER_AWIDTH        12
  `define PER_SIZE        8192
`endif
`ifdef PER_SIZE_4_KB
  `define PER_AWIDTH        11
  `define PER_SIZE        4096
`endif
`ifdef PER_SIZE_2_KB
  `define PER_AWIDTH        10
  `define PER_SIZE        2048
`endif
`ifdef PER_SIZE_1_KB
  `define PER_AWIDTH         9
  `define PER_SIZE        1024
`endif
`ifdef PER_SIZE_512_B
  `define PER_AWIDTH         8
  `define PER_SIZE         512
`endif

// Data Memory Base Adresses
`define DMEM_BASE  `PER_SIZE

// Program & Data Memory most significant address bit (for 16 bit words)
`define PMEM_MSB   `PMEM_AWIDTH-1
`define DMEM_MSB   `DMEM_AWIDTH-1
`define PER_MSB    `PER_AWIDTH-1

//
// STATES, REGISTER FIELDS, ...
//======================================

// Instructions type
`define INST_SO  0
`define INST_JMP 1
`define INST_TO  2

// Single-operand arithmetic
`define RRC    0
`define SWPB   1
`define RRA    2
`define SXT    3
`define PUSH   4
`define CALL   5
`define RETI   6
`define IRQ    7

// Conditional jump
`define JNE    0
`define JEQ    1
`define JNC    2
`define JC     3
`define JN     4
`define JGE    5
`define JL     6
`define JMP    7

// Two-operand arithmetic
`define MOV    0
`define ADD    1
`define ADDC   2
`define SUBC   3
`define SUB    4
`define CMP    5
`define DADD   6
`define BIT    7
`define BIC    8
`define BIS    9
`define XOR   10
`define AND   11

// Addressing modes
`define DIR      0
`define IDX      1
`define INDIR    2
`define INDIR_I  3
`define SYMB     4
`define IMM      5
`define ABS      6
`define CONST    7

// Instruction state machine
`define I_IRQ_FETCH 3'h0
`define I_IRQ_DONE  3'h1
`define I_DEC       3'h2
`define I_EXT1      3'h3
`define I_EXT2      3'h4
`define I_IDLE      3'h5

// Execution state machine
`define E_IRQ_0     4'h0
`define E_IRQ_1     4'h1
`define E_IRQ_2     4'h2
`define E_IRQ_3     4'h3
`define E_IRQ_4     4'h4
`define E_SRC_AD    4'h5
`define E_SRC_RD    4'h6
`define E_SRC_WR    4'h7
`define E_DST_AD    4'h8
`define E_DST_RD    4'h9
`define E_DST_WR    4'hA
`define E_EXEC      4'hB
`define E_JUMP      4'hC
`define E_IDLE      4'hD

// ALU control signals
`define ALU_SRC_INV   0
`define ALU_INC       1
`define ALU_INC_C     2
`define ALU_ADD       3
`define ALU_AND       4
`define ALU_OR        5
`define ALU_XOR       6
`define ALU_DADD      7
`define ALU_STAT_7    8
`define ALU_STAT_F    9
`define ALU_SHIFT    10
`define EXEC_NO_WR   11

// Debug interface
`define DBG_UART_WR   18
`define DBG_UART_BW   17
`define DBG_UART_ADDR 16:11

// Debug interface CPU_CTL register
`define HALT        0
`define RUN         1
`define ISTEP       2
`define SW_BRK_EN   3
`define FRZ_BRK_EN  4
`define RST_BRK_EN  5
`define CPU_RST     6

// Debug interface CPU_STAT register
`define HALT_RUN    0
`define PUC_PND     1
`define SWBRK_PND   3
`define HWBRK0_PND  4
`define HWBRK1_PND  5

// Debug interface BRKx_CTL register
`define BRK_MODE_RD 0
`define BRK_MODE_WR 1
`define BRK_MODE    1:0
`define BRK_EN      2
`define BRK_I_EN    3
`define BRK_RANGE   4

// Basic clock module: BCSCTL1 Control Register
`define DIVAx       5:4

// Basic clock module: BCSCTL2 Control Register
`define SELS        3
`define DIVSx       2:1


//
// DEBUG INTERFACE EXTRA CONFIGURATION
//======================================

// Debug interface: CPU version
`define CPU_VERSION   3'h1

// Debug interface: Software breakpoint opcode
`define DBG_SWBRK_OP 16'h4343

// Debug UART interface auto data synchronization
// If the following define is commented out, then
// the DBG_UART_BAUD and DBG_DCO_FREQ need to be properly
// defined.
`define DBG_UART_AUTO_SYNC

// Debug UART interface data rate
//      In order to properly setup the UART debug interface, you
//      need to specify the DCO_CLK frequency (DBG_DCO_FREQ) and
//      the chosen BAUD rate from the UART interface.
//
//`define DBG_UART_BAUD    9600
//`define DBG_UART_BAUD   19200
//`define DBG_UART_BAUD   38400
//`define DBG_UART_BAUD   57600
//`define DBG_UART_BAUD  115200
//`define DBG_UART_BAUD  230400
//`define DBG_UART_BAUD  460800
//`define DBG_UART_BAUD  576000
//`define DBG_UART_BAUD  921600
`define DBG_UART_BAUD 2000000
`define DBG_DCO_FREQ  20000000
`define DBG_UART_CNT ((`DBG_DCO_FREQ/`DBG_UART_BAUD)-1)

// Debug interface selection
//             `define DBG_UART -> Enable UART (8N1) debug interface
//             `define DBG_JTAG -> DON'T UNCOMMENT, NOT SUPPORTED
//
`define DBG_UART
//`define DBG_JTAG

// Enable/Disable the hardware breakpoint RANGE mode
`ifdef DBG_HWBRK_RANGE
 `define HWBRK_RANGE 1'b1
`else
 `define HWBRK_RANGE 1'b0
`endif

// Counter width for the debug interface UART
`define DBG_UART_XFER_CNT_W 16

// Check configuration
`ifdef DBG_EN
 `ifdef DBG_UART
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG AND UART DEBUG INTERFACE ARE BOTH ENABLED
   `endif
 `else
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG INTERFACE NOT SUPPORTED
   `else
CONFIGURATION ERROR: JTAG OR UART DEBUG INTERFACE SHOULD BE ENABLED
   `endif
 `endif
`endif

//
// MULTIPLIER CONFIGURATION
//======================================

// If uncommented, the following define selects
// the 16x16 multiplier (1 cycle) instead of the
// default 16x8 multplier (2 cycles)
//`define MPY_16x16
  