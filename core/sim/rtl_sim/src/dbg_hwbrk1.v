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
/*                            DEBUG INTERFACE                                */
/*---------------------------------------------------------------------------*/
/* Test the debug interface:                                                 */
/*                        - Check Hardware breakpoint unit 1.                */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev$                                                                */
/* $LastChangedBy$                                          */
/* $LastChangedDate$          */
/*===========================================================================*/

`define LONG_TIMEOUT
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

      // SEND UART SYNCHRONIZATION FRAME
      dbg_uart_tx(DBG_SYNC);

      
      // HARDWARE BREAKPOINTS: INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES
      //----------------------------------------------------------------------

      // RESET & BREAK
      dbg_uart_wr(CPU_CTL, 16'h0060);
      dbg_uart_wr(CPU_CTL, 16'h0020);

      // CONFIGURE BREAKPOINT (DISABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'hf804);
      dbg_uart_wr(BRK1_ADDR1, 16'hf818);
      dbg_uart_wr(BRK1_CTL,   16'h000C);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RESET & BREAK
      dbg_uart_wr(CPU_CTL,  16'h0060);
      dbg_uart_wr(CPU_CTL,  16'h0020);
      dbg_uart_wr(CPU_STAT, 16'h00ff);

      // CHECK
      if (mem200 === 16'h0000)  tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 1 =====");
      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'hf804);
      dbg_uart_wr(BRK1_ADDR1, 16'hf818);
      dbg_uart_wr(BRK1_CTL,   16'h000D);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf804)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 2 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 3 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 4 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 5 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0001);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 6 =====");
     
      // RE-RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0000);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf818)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 7 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 8 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 9 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0004) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 10 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0004);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES: test 11 =====");



      // HARDWARE BREAKPOINTS: INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE
      //----------------------------------------------------------------------
     
      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      // CONFIGURE BREAKPOINT(ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'hf700);
      dbg_uart_wr(BRK1_ADDR1, 16'hf820);
      dbg_uart_wr(BRK1_CTL,   16'h001D);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf800)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE: test 1 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0010) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0010);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE: test 5 =====");

      
     
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ
      //----------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0204);
      dbg_uart_wr(BRK1_ADDR1, 16'h0208);
      dbg_uart_wr(BRK1_CTL,   16'h0005);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf818)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 1 =====");
      if (mem200 !== 16'h0001)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0001);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf81C)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ: test 6 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0004) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0004);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ: test 10 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf818)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 11 =====");
      if (mem200 !== 16'h0002)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 12 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 13 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 14 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0001);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ: test 15 =====");
     
     
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE
      //-----------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0204);
      dbg_uart_wr(BRK1_ADDR1, 16'h0208);
      dbg_uart_wr(BRK1_CTL,   16'h0006);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf83a)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 1 =====");
      if (mem200 !== 16'h0000)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0002) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0002);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf844)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 6 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0008) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0008);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 10 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf80c)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 11 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 12 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 13 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0002) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 14 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0002);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 15 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf814)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 16 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 17 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 18 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0008) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 19 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0008);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 20 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf80c)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 21 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 22 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 23 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0002) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 24 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0002);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 25 =====");

      
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE
      //----------------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0204);
      dbg_uart_wr(BRK1_ADDR1, 16'h0208);
      dbg_uart_wr(BRK1_CTL,   16'h0007);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf83a)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 1 =====");
      if (mem200 !== 16'h0000)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0002) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0002);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf844)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 6 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0008) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0008);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 10 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf80c)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 11 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 12 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 13 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0002) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 14 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0002);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 15 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf814)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 16 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 17 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 18 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0008) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 19 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0008);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 20 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf818)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 21 =====");
      if (mem200 !== 16'h0001)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 22 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 23 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 24 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0001);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - READ/WRITE: test 25 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf81C)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 26 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 27 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 28 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0004) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 29 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0004);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - READ/WRITE: test 30 =====");

      
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ
      //----------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0201);
      dbg_uart_wr(BRK1_ADDR1, 16'h0205);
      dbg_uart_wr(BRK1_CTL,   16'h0015);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf818)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ: test 1 =====");
      if (mem200 !== 16'h0001)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0010) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0010);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf818)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ: test 6 =====");
      if (mem200 !== 16'h0002)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0010) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0010);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ: test 10 =====");

      
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE
      //-----------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0201);
      dbg_uart_wr(BRK1_ADDR1, 16'h0205);
      dbg_uart_wr(BRK1_CTL,   16'h0016);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf836)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 1 =====");
      if (mem200 !== 16'h0000)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - SINGLE ADDRESSES - WRITE: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf83a)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 6 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 10 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf808)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 11 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 12 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 13 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 14 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 15 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf80C)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 16 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 17 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 18 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 19 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 20 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf808)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 21 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 22 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 23 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 24 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - SINGLE ADDRESSES - WRITE: test 25 =====");

 
      // HARDWARE BREAKPOINTS: DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE
      //----------------------------------------------------------------------------------

      // RESET, BREAK & CLEAR STATUS
      dbg_uart_wr(CPU_CTL,    16'h0060);
      dbg_uart_wr(CPU_CTL,    16'h0020);
      dbg_uart_wr(BRK1_STAT,  16'h00ff);
      dbg_uart_wr(CPU_STAT,   16'h00ff);

      
      // CONFIGURE BREAKPOINT (ENABLED) & RUN
      dbg_uart_wr(BRK1_ADDR0, 16'h0201);
      dbg_uart_wr(BRK1_ADDR1, 16'h0205);
      dbg_uart_wr(BRK1_CTL,   16'h0017);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf836)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 1 =====");
      if (mem200 !== 16'h0000)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 2 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 3 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 4 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 5 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf83a)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 6 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 7 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 8 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 9 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 10 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf808)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 11 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 12 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 13 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 14 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 15 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf80C)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 16 =====");
      if (mem200 !== 16'h0000)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 17 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 18 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 19 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 20 =====");

      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // CHECK
      if (r0 !== 16'hf818)           tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 21 =====");
      if (mem200 !== 16'h0001)       tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 22 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 23 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0010) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 24 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0010);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== DATA FLOW (EXECUTION-UNIT) - ADDRESS RANGE - READ/WRITE: test 25 =====");
     
      // RE-RUN
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

      // RE-CHECK
      if (r0 !== 16'hf808)           tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 26 =====");
      if (mem200 !== 16'h0001)       tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 27 =====");
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0021) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 28 =====");
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0020) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 29 =====");
      dbg_uart_wr(BRK1_STAT, 16'h0020);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0001) tb_error("====== INSTRUCTION FLOW (FRONTEND) - ADDRESS RANGE - READ/WRITE: test 30 =====");


       // RE-RUN UNTIL END OF PATTERN
      dbg_uart_wr(BRK1_CTL,   16'h0000);
      dbg_uart_wr(CPU_CTL,    16'h0002);
      repeat(100) @(posedge mclk);

     
      stimulus_done = 1;
   end

