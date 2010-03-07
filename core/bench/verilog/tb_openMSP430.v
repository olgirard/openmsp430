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
// *File Name: tb_openMSP430.v
// 
// *Module Description:
//                      openMSP430 testbench
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


module  tb_openMSP430;

//
// Wire & Register definition
//------------------------------

// Data Memory interface
wire [`DMEM_MSB:0] dmem_addr;
wire               dmem_cen;
wire        [15:0] dmem_din;
wire         [1:0] dmem_wen;
wire        [15:0] dmem_dout;

// Program Memory interface
wire [`PMEM_MSB:0] pmem_addr;
wire               pmem_cen;
wire        [15:0] pmem_din;
wire         [1:0] pmem_wen;
wire        [15:0] pmem_dout;

// Peripherals interface
wire         [7:0] per_addr;
wire        [15:0] per_din;
wire        [15:0] per_dout;
wire         [1:0] per_wen;
wire               per_en;

// Digital I/O
wire               irq_port1;
wire               irq_port2;
wire        [15:0] per_dout_dio;
wire         [7:0] p1_dout;
wire         [7:0] p1_dout_en;
wire         [7:0] p1_sel;
wire         [7:0] p2_dout;
wire         [7:0] p2_dout_en;
wire         [7:0] p2_sel;
wire         [7:0] p3_dout;
wire         [7:0] p3_dout_en;
wire         [7:0] p3_sel;
wire         [7:0] p4_dout;
wire         [7:0] p4_dout_en;
wire         [7:0] p4_sel;
wire         [7:0] p5_dout;
wire         [7:0] p5_dout_en;
wire         [7:0] p5_sel;
wire         [7:0] p6_dout;
wire         [7:0] p6_dout_en;
wire         [7:0] p6_sel;
reg          [7:0] p1_din;
reg          [7:0] p2_din;
reg          [7:0] p3_din;
reg          [7:0] p4_din;
reg          [7:0] p5_din;
reg          [7:0] p6_din;

// Peripheral templates
wire        [15:0] per_dout_temp_8b;
wire        [15:0] per_dout_temp_16b;

// Timer A
wire               irq_ta0;
wire               irq_ta1;
wire        [15:0] per_dout_timerA;
reg                inclk;
reg                taclk;
reg                ta_cci0a;
reg                ta_cci0b;
reg                ta_cci1a;
reg                ta_cci1b;
reg                ta_cci2a;
reg                ta_cci2b;
wire               ta_out0;
wire               ta_out0_en;
wire               ta_out1;
wire               ta_out1_en;
wire               ta_out2;
wire               ta_out2_en;
   
// Clock / Reset & Interrupts
reg                dco_clk;
reg                lfxt_clk;
wire               mclk;
wire               aclk_en;
wire               smclk_en;
reg                reset_n;
wire               puc;
reg                nmi;
reg         [13:0] irq;
wire        [13:0] irq_acc;
wire        [13:0] irq_in;

// Debug interface
wire               dbg_freeze;
wire               dbg_uart_txd;
reg                dbg_uart_rxd;
reg         [15:0] dbg_uart_buf;

// Core testbench debuging signals
wire    [8*32-1:0] i_state;
wire    [8*32-1:0] e_state;
wire        [31:0] inst_cycle;
wire    [8*32-1:0] inst_full;
wire        [31:0] inst_number;
wire        [15:0] inst_pc;
wire    [8*32-1:0] inst_short;
   
// Testbench variables
integer            error;
reg                stimulus_done;


//
// Include files
//------------------------------

// CPU & Memory registers
`include "registers.v"

// Debug interface tasks
`include "dbg_uart_tasks.v"

// Verilog stimulus
`include "stimulus.v"

   
//
// Initialize ROM
//------------------------------
initial
  begin
     $readmemh("./pmem.mem", pmem_0.mem);
  end

//
// Generate Clock & Reset
//------------------------------
initial
  begin
     dco_clk = 1'b0;
     forever #25 dco_clk <= ~dco_clk;   // 20 MHz
  end
initial
  begin
     lfxt_clk = 1'b0;
     forever #763 lfxt_clk <= ~lfxt_clk; // 655 kHz
  end

initial
  begin
     reset_n       = 1'b1;
     #100;
     reset_n       = 1'b0;
     #600;
     reset_n       = 1'b1;
  end

initial
  begin
     error         = 0;
     stimulus_done = 1;
     irq           = 14'b0000;
     nmi           = 1'b0;
     dbg_uart_rxd  = 1'b1;
     dbg_uart_buf  = 16'h0000;
     p1_din        = 8'h00;
     p2_din        = 8'h00;
     p3_din        = 8'h00;
     p4_din        = 8'h00;
     p5_din        = 8'h00;
     p6_din        = 8'h00;
     inclk         = 1'b0;
     taclk         = 1'b0;
     ta_cci0a      = 1'b0;
     ta_cci0b      = 1'b0;
     ta_cci1a      = 1'b0;
     ta_cci1b      = 1'b0;
     ta_cci2a      = 1'b0;
     ta_cci2b      = 1'b0;
  end

   
//
// Program Memory
//----------------------------------

ram #(`PMEM_MSB) pmem_0 (

// OUTPUTs
    .ram_dout    (pmem_dout),          // Program Memory data output

// INPUTs
    .ram_addr    (pmem_addr),          // Program Memory address
    .ram_cen     (pmem_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),               // Program Memory clock
    .ram_din     (pmem_din),           // Program Memory data input
    .ram_wen     (pmem_wen)            // Program Memory write enable (low active)
);


//
// Data Memory
//----------------------------------

ram #(`DMEM_MSB) dmem_0 (

// OUTPUTs
    .ram_dout    (dmem_dout),          // Data Memory data output

// INPUTs
    .ram_addr    (dmem_addr),          // Data Memory address
    .ram_cen     (dmem_cen),           // Data Memory chip enable (low active)
    .ram_clk     (mclk),               // Data Memory clock
    .ram_din     (dmem_din),           // Data Memory data input
    .ram_wen     (dmem_wen)            // Data Memory write enable (low active)
);


//
// openMSP430 Instance
//----------------------------------

openMSP430 dut (

// OUTPUTs
    .aclk_en      (aclk_en),           // ACLK enable
    .dbg_freeze   (dbg_freeze),        // Freeze peripherals
    .dbg_uart_txd (dbg_uart_txd),      // Debug interface: UART TXD
    .dmem_addr    (dmem_addr),         // Data Memory address
    .dmem_cen     (dmem_cen),          // Data Memory chip enable (low active)
    .dmem_din     (dmem_din),          // Data Memory data input
    .dmem_wen     (dmem_wen),          // Data Memory write enable (low active)
    .irq_acc      (irq_acc),           // Interrupt request accepted (one-hot signal)
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_wen      (per_wen),           // Peripheral write enable (high active)
    .per_en       (per_en),            // Peripheral enable (high active)
    .pmem_addr    (pmem_addr),         // Program Memory address
    .pmem_cen     (pmem_cen),          // Program Memory chip enable (low active)
    .pmem_din     (pmem_din),          // Program Memory data input (optional)
    .pmem_wen     (pmem_wen),          // Program Memory write enable (low active) (optional)
    .puc          (puc),               // Main system reset
    .smclk_en     (smclk_en),          // SMCLK enable

// INPUTs
    .dbg_uart_rxd (dbg_uart_rxd),      // Debug interface: UART RXD
    .dco_clk      (dco_clk),           // Fast oscillator (fast clock)
    .dmem_dout    (dmem_dout),         // Data Memory data output
    .irq          (irq_in),            // Maskable interrupts
    .lfxt_clk     (lfxt_clk),          // Low frequency oscillator (typ 32kHz)
    .nmi          (nmi),               // Non-maskable interrupt (asynchronous)
    .per_dout     (per_dout),          // Peripheral data output
    .pmem_dout    (pmem_dout),         // Program Memory data output
    .reset_n      (reset_n)            // Reset Pin (low active)
);

//
// Digital I/O
//----------------------------------

omsp_gpio #(.P1_EN(1),
            .P2_EN(1),
            .P3_EN(1),
            .P4_EN(1),
            .P5_EN(1),
            .P6_EN(1)) gpio_0 (

// OUTPUTs
    .irq_port1    (irq_port1),         // Port 1 interrupt
    .irq_port2    (irq_port2),         // Port 2 interrupt
    .p1_dout      (p1_dout),           // Port 1 data output
    .p1_dout_en   (p1_dout_en),        // Port 1 data output enable
    .p1_sel       (p1_sel),            // Port 1 function select
    .p2_dout      (p2_dout),           // Port 2 data output
    .p2_dout_en   (p2_dout_en),        // Port 2 data output enable
    .p2_sel       (p2_sel),            // Port 2 function select
    .p3_dout      (p3_dout),           // Port 3 data output
    .p3_dout_en   (p3_dout_en),        // Port 3 data output enable
    .p3_sel       (p3_sel),            // Port 3 function select
    .p4_dout      (p4_dout),           // Port 4 data output
    .p4_dout_en   (p4_dout_en),        // Port 4 data output enable
    .p4_sel       (p4_sel),            // Port 4 function select
    .p5_dout      (p5_dout),           // Port 5 data output
    .p5_dout_en   (p5_dout_en),        // Port 5 data output enable
    .p5_sel       (p5_sel),            // Port 5 function select
    .p6_dout      (p6_dout),           // Port 6 data output
    .p6_dout_en   (p6_dout_en),        // Port 6 data output enable
    .p6_sel       (p6_sel),            // Port 6 function select
    .per_dout     (per_dout_dio),      // Peripheral data output
			     
// INPUTs
    .mclk         (mclk),              // Main system clock
    .p1_din       (p1_din),            // Port 1 data input
    .p2_din       (p2_din),            // Port 2 data input
    .p3_din       (p3_din),            // Port 3 data input
    .p4_din       (p4_din),            // Port 4 data input
    .p5_din       (p5_din),            // Port 5 data input
    .p6_din       (p6_din),            // Port 6 data input
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_wen      (per_wen),           // Peripheral write enable (high active)
    .puc          (puc)                // Main system reset
);

//
// Timers
//----------------------------------

omsp_timerA timerA_0 (

// OUTPUTs
    .irq_ta0      (irq_ta0),           // Timer A interrupt: TACCR0
    .irq_ta1      (irq_ta1),           // Timer A interrupt: TAIV, TACCR1, TACCR2
    .per_dout     (per_dout_timerA),   // Peripheral data output
    .ta_out0      (ta_out0),           // Timer A output 0
    .ta_out0_en   (ta_out0_en),        // Timer A output 0 enable
    .ta_out1      (ta_out1),           // Timer A output 1
    .ta_out1_en   (ta_out1_en),        // Timer A output 1 enable
    .ta_out2      (ta_out2),           // Timer A output 2
    .ta_out2_en   (ta_out2_en),        // Timer A output 2 enable

// INPUTs
    .aclk_en      (aclk_en),           // ACLK enable (from CPU)
    .dbg_freeze   (dbg_freeze),        // Freeze Timer A counter
    .inclk        (inclk),             // INCLK external timer clock (SLOW)
    .irq_ta0_acc  (irq_acc[9]),        // Interrupt request TACCR0 accepted
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_wen      (per_wen),           // Peripheral write enable (high active)
    .puc          (puc),               // Main system reset
    .smclk_en     (smclk_en),          // SMCLK enable (from CPU)
    .ta_cci0a     (ta_cci0a),          // Timer A compare 0 input A
    .ta_cci0b     (ta_cci0b),          // Timer A compare 0 input B
    .ta_cci1a     (ta_cci1a),          // Timer A compare 1 input A
    .ta_cci1b     (ta_cci1b),          // Timer A compare 1 input B
    .ta_cci2a     (ta_cci2a),          // Timer A compare 2 input A
    .ta_cci2b     (ta_cci2b),          // Timer A compare 2 input B
    .taclk        (taclk)              // TACLK external timer clock (SLOW)
);
   
//
// Peripheral templates
//----------------------------------

template_periph_8b template_periph_8b_0 (

// OUTPUTs
    .per_dout     (per_dout_temp_8b),  // Peripheral data output

// INPUTs
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_wen      (per_wen),           // Peripheral write enable (high active)
    .puc          (puc)                // Main system reset
);

template_periph_16b template_periph_16b_0 (

// OUTPUTs
    .per_dout     (per_dout_temp_16b), // Peripheral data output

// INPUTs
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_wen      (per_wen),           // Peripheral write enable (high active)
    .puc          (puc)                // Main system reset
);


//
// Combine peripheral data bus
//----------------------------------

assign per_dout = per_dout_dio       |
                  per_dout_timerA    |
                  per_dout_temp_8b   |
                  per_dout_temp_16b;


//
// Map peripheral interrupts
//----------------------------------------

assign irq_in = irq | {1'b0,           // Vector 13  (0xFFFA)
                       1'b0,           // Vector 12  (0xFFF8)
                       1'b0,           // Vector 11  (0xFFF6)
                       1'b0,           // Vector 10  (0xFFF4) - Watchdog -
                       irq_ta0,        // Vector  9  (0xFFF2)
                       irq_ta1,        // Vector  8  (0xFFF0)
                       1'b0,           // Vector  7  (0xFFEE)
                       1'b0,           // Vector  6  (0xFFEC)
                       1'b0,           // Vector  5  (0xFFEA)
                       1'b0,           // Vector  4  (0xFFE8)
                       irq_port2,      // Vector  3  (0xFFE6)
                       irq_port1,      // Vector  2  (0xFFE4)
                       1'b0,           // Vector  1  (0xFFE2)
                       1'b0};          // Vector  0  (0xFFE0)


//
// Debug utility signals
//----------------------------------------
msp_debug msp_debug_0 (

// OUTPUTs
    .e_state      (e_state),           // Execution state
    .i_state      (i_state),           // Instruction fetch state
    .inst_cycle   (inst_cycle),        // Cycle number within current instruction
    .inst_full    (inst_full),         // Currently executed instruction (full version)
    .inst_number  (inst_number),       // Instruction number since last system reset
    .inst_pc      (inst_pc),           // Instruction Program counter
    .inst_short   (inst_short),        // Currently executed instruction (short version)

// INPUTs
    .mclk         (mclk),              // Main system clock
    .puc          (puc)                // Main system reset
);


//
// Generate Waveform
//----------------------------------------
initial
  begin
   `ifdef NODUMP
   `else
     `ifdef VPD_FILE
        $vcdplusfile("tb_openMSP430.vpd");
        $vcdpluson();
     `else
        $dumpfile("tb_openMSP430.vcd");
        $dumpvars(0, tb_openMSP430);
     `endif
   `endif
  end

//
// End of simulation
//----------------------------------------

initial // Timeout
  begin
   `ifdef NO_TIMEOUT
   `else
     `ifdef LONG_TIMEOUT
       #5000000;
     `else     
       #500000;
     `endif
       $display(" ===============================================");
       $display("|               SIMULATION FAILED               |");
       $display("|              (simulation Timeout)             |");
       $display(" ===============================================");
       $finish;
   `endif
  end

initial // Normal end of test
  begin
     @(inst_pc===16'hffff)
     $display(" ===============================================");
     if (error!=0)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (some verilog stimulus checks failed)     |");
       end
     else if (~stimulus_done)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (the verilog stimulus didn't complete)    |");
       end
     else 
       begin
	  $display("|               SIMULATION PASSED               |");
       end
     $display(" ===============================================");
     $finish;
  end


//
// Tasks Definition
//------------------------------

   task tb_error;
      input [65*8:0] error_string;
      begin
	 $display("ERROR: %s %t", error_string, $time);
	 error = error+1;
      end
   endtask


endmodule
