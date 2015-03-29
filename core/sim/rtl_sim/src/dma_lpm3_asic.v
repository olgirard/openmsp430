/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                  CPU LOW POWER MODES & DMA TRANSFER                       */
/*---------------------------------------------------------------------------*/
/* Test DMA transfer with the CPU Low Power modes:                           */
/*                                                                           */
/*                      - LPM0       <=>  CPUOFF                             */
/*                      - LPM1       <=>  CPUOFF + SCG0                      */
/*                      - LPM2       <=>  CPUOFF +        SCG1               */
/*                      - LPM3       <=>  CPUOFF + SCG0 + SCG1               */
/*                      - LPM4       <=>  CPUOFF + SCG0 + SCG1 + OSCOFF      */
/*                                                                           */
/*                                                                           */
/* Reminder about config registers:                                          */
/*                                                                           */
/*                      - CPUOFF     <=>  turns off CPU.                     */
/*                      - SCG0       <=>  turns off DCO.                     */
/*                      - SCG1       <=>  turns off SMCLK.                   */
/*                      - OSCOFF     <=>  turns off LFXT_CLK.                */
/*                                                                           */
/*                      - DMA_CPUOFF <=>  allow DMA to turn on MCLK          */
/*                      - DMA_SCG0   <=>  allow DMA to turn on DCO           */
/*                      - DMA_SCG1   <=>  allow DMA to turn on SMCLK         */
/*                      - DMA_OSCOFF <=>  allow DMA to turn on LFXT_CLK      */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/

`define VERY_LONG_TIMEOUT

reg     dma_loop_enable;
integer dma_loop_nr;

integer dco_clk_cnt;
always @(negedge dco_clk)
  dco_clk_cnt <= dco_clk_cnt+1;

integer mclk_dma_cnt;
always @(negedge mclk)
  mclk_dma_cnt <= mclk_dma_cnt+1;

integer mclk_cpu_cnt;
always @(negedge tb_openMSP430.dut.cpu_mclk)
  mclk_cpu_cnt <= mclk_cpu_cnt+1;
  
integer smclk_cnt;
always @(negedge smclk)
  smclk_cnt <= smclk_cnt+1;

integer aclk_cnt;
always @(negedge aclk)
  aclk_cnt <= aclk_cnt+1;

integer inst_cnt;
always @(inst_number)
  inst_cnt <= inst_cnt+1;

// Wakeup synchronizer to generate IRQ
reg [1:0] wkup2_sync;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) wkup2_sync <= 2'b00;
  else         wkup2_sync <= {wkup2_sync[0], wkup[2]};

always @(wkup2_sync)
  irq[`IRQ_NR-14] = wkup2_sync[1]; // IRQ-2

// Wakeup synchronizer to generate IRQ
reg [1:0] wkup3_sync;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) wkup3_sync <= 2'b00;
  else         wkup3_sync <= {wkup3_sync[0], wkup[3]};

always @(wkup3_sync)
  irq[`IRQ_NR-13] = wkup3_sync[1]; // IRQ-3

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DMA_IF_EN
      // Disable automatic DMA verification
      #10;
      dma_verif_on = 0;
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      irq[`IRQ_NR-14]  = 0; // IRQ-2
      wkup[2] = 0;

      irq[`IRQ_NR-13]  = 0; // IRQ-3
      wkup[3] = 0;


`ifdef ASIC_CLOCKING

      //--------------------------------------------------------
      // ACTIVE
      //--------------------------------------------------------
      @(r15==16'h1001);
      $display("");
      $display("\nACTIVE                  -  NO DMA");
        
      //           DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      clock_check(   100  ,   100   ,   100   ,  100 ,   4  ,  100 ,  60 ,   0    );


      @(r15==16'h3000);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 0, 0, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0  ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0  ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0  ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3001);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 0, 0, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3002);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 0, 1, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3003);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 0, 1, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,   100   ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3004);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 1, 0, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3005);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 1, 0, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3006);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 1, 1, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,    0    ,  100 ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3007);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={0, 1, 1, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,   100   ,  100 ,   4  ,  100 ,   0 ,  100   );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3008);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 0, 0, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h3009);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 0, 0, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300A);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 0, 1, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300B);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 0, 1, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,   100   ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300C);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 1, 0, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300D);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 1, 0, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300E);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 1, 1, 0}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,    0    ,  100 ,   4  ,  100 ,   0 ,   0    );  // WITH DMA, WITH WAKE-UP

      @(r15==16'h300F);
      $display("\nLPM3 (CPUOFF+SCG0+SCG1) -  {DMA_OSCOFF, DMA_SCG1, DMA_SCG0, DMA_CPUOFF}={1, 1, 1, 1}\n");

      //                     DCO_CLK, MCLK_CPU, MCLK_DMA, SMCLK, ACLK1, ACLK2, INST, DMA_NR
      full_lpm_clock_check (    0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // NO DMA
                                0   ,    0    ,    0    ,   0  ,   4  ,  100 ,   0 ,   0    ,   // WITH DMA, NO WAKE-UP
                               100  ,    0    ,   100   ,  100 ,   4  ,  100 ,   0 ,  100   );  // WITH DMA, WITH WAKE-UP

      
      $display("");
`else
      tb_skip_finish("|   (this test is not supported in FPGA mode)   |");
`endif
`else
       tb_skip_finish("|      (DMA interface support not included)    |");
`endif

      stimulus_done = 1;
   end

//------------------------------------------------------
// Clock check function
//------------------------------------------------------
task clock_check;

   input integer dco_val;
   input integer mclk_cpu_val;
   input integer mclk_dma_val;
   input integer smclk_val;
   input integer aclk_val1;
   input integer aclk_val2;
   input integer inst_val;
   input integer dma_val;

   begin
  `ifdef LFXT_DOMAIN
      if (aclk_val1 != 0) @(posedge aclk);
  `endif
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cpu_cnt = 0;
      mclk_dma_cnt = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      dma_loop_nr  = 0;
      #(100*50);
      if (dco_clk_cnt  !== dco_val)       tb_error("====== DCO_CLK   CHECK FAILED =====");
      if (mclk_cpu_cnt !== mclk_cpu_val)  tb_error("====== MCLK CPU  CHECK FAILED =====");
      if (mclk_dma_cnt !== mclk_dma_val)  tb_error("====== MCLK DMA  CHECK FAILED =====");
      if (smclk_cnt    !== smclk_val)     tb_error("====== SMCLK     CHECK FAILED =====");
  `ifdef LFXT_DOMAIN
      if (aclk_cnt     !== aclk_val1)     tb_error("====== ACLK1     CHECK FAILED =====");
  `else
      if (aclk_cnt     !== aclk_val2)     tb_error("====== ACLK2     CHECK FAILED =====");
  `endif
      if (inst_cnt     <   inst_val)      tb_error("====== INST_NR   CHECK FAILED =====");
      if (dma_loop_nr  !== dma_val)       tb_error("====== DMA_NR    CHECK FAILED =====");
      dco_clk_cnt  = 0;
      mclk_cpu_cnt = 0;
      mclk_dma_cnt = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      dma_loop_nr  = 0;
   end

endtask

//------------------------------------------------------
// Check Clocks for the whole LPM sequence
//------------------------------------------------------

task full_lpm_clock_check;
   input integer  nodma_dco,      nodma_mclk_cpu,      nodma_mclk_dma,      nodma_smclk,      nodma_aclk1,      nodma_aclk2,      nodma_inst,      nodma_dma_nr;
   input integer  dma_wkup_dco,   dma_wkup_mclk_cpu,   dma_wkup_mclk_dma,   dma_wkup_smclk,   dma_wkup_aclk1,   dma_wkup_aclk2,   dma_wkup_inst,   dma_wkup_dma_nr;
   input integer  dma_nowkup_dco, dma_nowkup_mclk_cpu, dma_nowkup_mclk_dma, dma_nowkup_smclk, dma_nowkup_aclk1, dma_nowkup_aclk2, dma_nowkup_inst, dma_nowkup_dma_nr;

   begin

      //---------- NO DMA                             - CHECK CLOCK STATUS  -------------//
      $display("                                      - NO DMA");
      clock_check(nodma_dco,      nodma_mclk_cpu,      nodma_mclk_dma,      nodma_smclk,      nodma_aclk1,      nodma_aclk2,      nodma_inst,      nodma_dma_nr      );

      //---------- PERFORM DMA TRANSFER NO WAKEUP     - CHECK CLOCK STATUS  -------------//
      $display("                                      - WITH DMA, NO WAKE-UP");      
      dma_wkup        = 0;
      dma_loop_enable = 1;
      clock_check(dma_wkup_dco,   dma_wkup_mclk_cpu,   dma_wkup_mclk_dma,   dma_wkup_smclk,   dma_wkup_aclk1,   dma_wkup_aclk2,   dma_wkup_inst,   dma_wkup_dma_nr   );
      dma_loop_enable = 0;
      dma_wkup        = 0;
      #100;
      dma_tfx_cancel  = 1;
      #100;
      dma_tfx_cancel  = 0;
      #100;

      //---------- NO DMA                             - CHECK CLOCK STATUS  -------------//
      $display("                                      - NO DMA");
      clock_check(nodma_dco,      nodma_mclk_cpu,      nodma_mclk_dma,      nodma_smclk,      nodma_aclk1,      nodma_aclk2,      nodma_inst,      nodma_dma_nr      );

      //---------- PERFORM DMA TRANSFER WITH WAKEUP   - CHECK CLOCK STATUS  -------------//
      $display("                                      - WITH DMA, WITH WAKE-UP");      
      dma_wkup        = 1;
      dma_loop_enable = 1;
      clock_check(dma_nowkup_dco, dma_nowkup_mclk_cpu, dma_nowkup_mclk_dma, dma_nowkup_smclk, dma_nowkup_aclk1, dma_nowkup_aclk2, dma_nowkup_inst, dma_nowkup_dma_nr );
      dma_loop_enable = 0;
      dma_wkup        = 0;
      #100;
      dma_tfx_cancel  = 1;
      #100;
      dma_tfx_cancel  = 0;
      #100;

      //---------- NO DMA                             - CHECK CLOCK STATUS  -------------//
      $display("                                      - NO DMA");
      clock_check(nodma_dco,      nodma_mclk_cpu,      nodma_mclk_dma,      nodma_smclk,      nodma_aclk1,      nodma_aclk2,      nodma_inst,      nodma_dma_nr      );
 
      //---------- PORT2 IRQ            - EXITING POWER MODE  -------------//
      irq_exit_lp_mode;
   end

endtask

//------------------------------------------------------
// ENABLE DISABLE DMA TRANSFERS
//------------------------------------------------------
// Note that we synchronize DMA transfer with SMCLK

reg [15:0] dma_loop_val;
initial
  begin
     dma_loop_enable=0;
     dma_loop_val=0;
     dma_loop_nr=0;
     forever
       begin
          if (~dma_loop_enable) @(posedge dma_loop_enable);
          @(negedge smclk or posedge dma_tfx_cancel);
          if (~dma_tfx_cancel) dma_write_16b(16'h0000-`PMEM_SIZE, dma_loop_val, 1'b0);
          if (~dma_tfx_cancel) dma_loop_nr=dma_loop_nr+1;
          if (~dma_tfx_cancel)
            begin
               if (~dma_loop_enable) @(posedge dma_loop_enable);
               @(negedge smclk or posedge dma_tfx_cancel);
               if (~dma_tfx_cancel) dma_read_16b(16'h0000-`PMEM_SIZE,  dma_loop_val, 1'b0);
               if (~dma_tfx_cancel) dma_loop_nr=dma_loop_nr+1;
            end
          dma_loop_val=dma_loop_val+1;
       end
  end
   
//------------------------------------------------------
// IRQ to exit Low Power Mode
//------------------------------------------------------
task irq_exit_lp_mode;

   begin
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(10*50);
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
   end

endtask


