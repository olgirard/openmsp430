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
/*                            DEBUG INTERFACE:  UART                         */
/*---------------------------------------------------------------------------*/
/* Test the UART debug interface:                                            */
/*                        - Check RD/WR access to debugg registers.          */
/*                        - Check RD Bursts.                                 */
/*                        - Check WR Bursts.                                 */
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

reg [15:0] dbg_id_pmem;
reg [15:0] dbg_id_dmem;
reg [31:0] dbg_id;
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      #1 dbg_en = 1;
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

      // SEND UART SYNCHRONIZATION FRAME
      dbg_uart_tx(DBG_SYNC);

   `ifdef DBG_RST_BRK_EN
      dbg_uart_wr(CPU_CTL,  16'h0002);  // RUN
   `endif

      // TEST CPU REGISTERS
      //--------------------------------------------------------
      dbg_id_pmem = `PMEM_SIZE;
      dbg_id_dmem = `DMEM_SIZE;
      dbg_id      = {dbg_id_pmem, dbg_id_dmem};

      dbg_uart_wr(CPU_ID_LO  ,  16'hffff);
      dbg_uart_rd(CPU_ID_LO);
      if (dbg_uart_buf !== dbg_id[15:0])  tb_error("====== CPU_ID_LO uncorrect =====");
      dbg_uart_wr(CPU_ID_LO  ,  16'h0000);
      dbg_uart_rd(CPU_ID_LO);
      if (dbg_uart_buf !== dbg_id[15:0])  tb_error("====== CPU_ID_LO uncorrect =====");
     
      dbg_uart_wr(CPU_ID_HI  ,  16'hffff);
      dbg_uart_rd(CPU_ID_HI);
      if (dbg_uart_buf !== dbg_id[31:16]) tb_error("====== CPU_ID_HI uncorrect =====");
      dbg_uart_wr(CPU_ID_HI  ,  16'h0000);
      dbg_uart_rd(CPU_ID_HI);
      if (dbg_uart_buf !== dbg_id[31:16]) tb_error("====== CPU_ID_HI uncorrect =====");

      dbg_uart_wr(CPU_STAT   ,  16'hffff);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== CPU_STAT uncorrect =====");
      dbg_uart_wr(CPU_STAT   ,  16'h0000);
      dbg_uart_rd(CPU_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== CPU_STAT uncorrect =====");

      dbg_uart_wr(CPU_CTL    ,  16'hffff);
      dbg_uart_rd(CPU_CTL);
      if (dbg_uart_buf !== 16'h0078)      tb_error("====== CPU_CTL uncorrect =====");
      dbg_uart_wr(CPU_CTL    ,  16'h0000);
      dbg_uart_rd(CPU_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== CPU_CTL uncorrect =====");

      
      // TEST MEMORY CONTROL REGISTERS
      //--------------------------------------------------------

      dbg_uart_wr(MEM_CTL    ,  16'hfffe);
      dbg_uart_rd(MEM_CTL);
      if (dbg_uart_buf !== 16'h000E)      tb_error("====== MEM_CTL uncorrect =====");
      dbg_uart_wr(MEM_CTL    ,  16'h0000);
      dbg_uart_rd(MEM_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== MEM_CTL uncorrect =====");

      dbg_uart_wr(MEM_ADDR   ,  16'hffff);
      dbg_uart_rd(MEM_ADDR);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== MEM_ADDR uncorrect =====");
      dbg_uart_wr(MEM_ADDR   ,  16'h0000);
      dbg_uart_rd(MEM_ADDR);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== MEM_ADDR uncorrect =====");

      dbg_uart_wr(MEM_DATA   ,  16'hffff);
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== MEM_DATA uncorrect =====");
      dbg_uart_wr(MEM_DATA   ,  16'h0000);
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== MEM_DATA uncorrect =====");

      dbg_uart_wr(MEM_CNT    ,  16'hffff);
      dbg_uart_rd(MEM_CNT);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== MEM_CNT uncorrect =====");
      dbg_uart_wr(MEM_CNT    ,  16'h0000);
      dbg_uart_rd(MEM_CNT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== MEM_CNT uncorrect =====");


      // TEST HARDWARE BREAKPOINT 0 REGISTERS
      //--------------------------------------------------------

      dbg_uart_wr(BRK0_CTL   ,  16'hffff);
      dbg_uart_rd(BRK0_CTL);
      if (`HWBRK_RANGE)
	begin
	   if (dbg_uart_buf !== 16'h001F)      tb_error("====== BRK0_CTL uncorrect =====");
	end
      else
	begin
	   if (dbg_uart_buf !== 16'h000F)      tb_error("====== BRK0_CTL uncorrect =====");
	end
      dbg_uart_wr(BRK0_CTL   ,  16'h0000);
      dbg_uart_rd(BRK0_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK0_CTL uncorrect =====");

      dbg_uart_wr(BRK0_STAT  ,  16'hffff);
      dbg_uart_rd(BRK0_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK0_STAT uncorrect =====");
      dbg_uart_wr(BRK0_STAT  ,  16'h0000);
      dbg_uart_rd(BRK0_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK0_STAT uncorrect =====");

      dbg_uart_wr(BRK0_ADDR0 ,  16'hffff);
      dbg_uart_rd(BRK0_ADDR0);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK0_ADDR0 uncorrect =====");
      dbg_uart_wr(BRK0_ADDR0 ,  16'h0000);
      dbg_uart_rd(BRK0_ADDR0);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK0_ADDR0 uncorrect =====");

      dbg_uart_wr(BRK0_ADDR1 ,  16'hffff);
      dbg_uart_rd(BRK0_ADDR1);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK0_ADDR1 uncorrect =====");
      dbg_uart_wr(BRK0_ADDR1 ,  16'h0000);
      dbg_uart_rd(BRK0_ADDR1);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK0_ADDR1 uncorrect =====");


      // TEST HARDWARE BREAKPOINT 1 REGISTERS
      //--------------------------------------------------------

      dbg_uart_wr(BRK1_CTL   ,  16'hffff);
      dbg_uart_rd(BRK1_CTL);
      if (`HWBRK_RANGE)
	begin
	   if (dbg_uart_buf !== 16'h001F)      tb_error("====== BRK1_CTL uncorrect =====");
	end
      else
	begin
	   if (dbg_uart_buf !== 16'h000F)      tb_error("====== BRK1_CTL uncorrect =====");
	end
      dbg_uart_wr(BRK1_CTL   ,  16'h0000);
      dbg_uart_rd(BRK1_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK1_CTL uncorrect =====");

      dbg_uart_wr(BRK1_STAT  ,  16'hffff);
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK1_STAT uncorrect =====");
      dbg_uart_wr(BRK1_STAT  ,  16'h0000);
      dbg_uart_rd(BRK1_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK1_STAT uncorrect =====");

      dbg_uart_wr(BRK1_ADDR0 ,  16'hffff);
      dbg_uart_rd(BRK1_ADDR0);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK1_ADDR0 uncorrect =====");
      dbg_uart_wr(BRK1_ADDR0 ,  16'h0000);
      dbg_uart_rd(BRK1_ADDR0);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK1_ADDR0 uncorrect =====");

      dbg_uart_wr(BRK1_ADDR1 ,  16'hffff);
      dbg_uart_rd(BRK1_ADDR1);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK1_ADDR1 uncorrect =====");
      dbg_uart_wr(BRK1_ADDR1 ,  16'h0000);
      dbg_uart_rd(BRK1_ADDR1);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK1_ADDR1 uncorrect =====");


      // TEST HARDWARE BREAKPOINT 2 REGISTERS
      //--------------------------------------------------------

      dbg_uart_wr(BRK2_CTL   ,  16'hffff);
      dbg_uart_rd(BRK2_CTL);
      if (`HWBRK_RANGE)
	begin
	   if (dbg_uart_buf !== 16'h001F)      tb_error("====== BRK2_CTL uncorrect =====");
	end
      else
	begin
	   if (dbg_uart_buf !== 16'h000F)      tb_error("====== BRK2_CTL uncorrect =====");
	end
      dbg_uart_wr(BRK2_CTL   ,  16'h0000);
      dbg_uart_rd(BRK2_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK2_CTL uncorrect =====");

      dbg_uart_wr(BRK2_STAT  ,  16'hffff);
      dbg_uart_rd(BRK2_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK2_STAT uncorrect =====");
      dbg_uart_wr(BRK2_STAT  ,  16'h0000);
      dbg_uart_rd(BRK2_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK2_STAT uncorrect =====");

      dbg_uart_wr(BRK2_ADDR0 ,  16'hffff);
      dbg_uart_rd(BRK2_ADDR0);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK2_ADDR0 uncorrect =====");
      dbg_uart_wr(BRK2_ADDR0 ,  16'h0000);
      dbg_uart_rd(BRK2_ADDR0);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK2_ADDR0 uncorrect =====");

      dbg_uart_wr(BRK2_ADDR1 ,  16'hffff);
      dbg_uart_rd(BRK2_ADDR1);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK2_ADDR1 uncorrect =====");
      dbg_uart_wr(BRK2_ADDR1 ,  16'h0000);
      dbg_uart_rd(BRK2_ADDR1);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK2_ADDR1 uncorrect =====");

      
      // TEST HARDWARE BREAKPOINT 3 REGISTERS
      //--------------------------------------------------------

      dbg_uart_wr(BRK3_CTL   ,  16'hffff);
      dbg_uart_rd(BRK3_CTL);
      if (`HWBRK_RANGE)
	begin
	   if (dbg_uart_buf !== 16'h001F)      tb_error("====== BRK3_CTL uncorrect =====");
	end
      else
	begin
	   if (dbg_uart_buf !== 16'h000F)      tb_error("====== BRK3_CTL uncorrect =====");
	end
      dbg_uart_wr(BRK3_CTL   ,  16'h0000);
      dbg_uart_rd(BRK3_CTL);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK3_CTL uncorrect =====");

      dbg_uart_wr(BRK3_STAT  ,  16'hffff);
      dbg_uart_rd(BRK3_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK3_STAT uncorrect =====");
      dbg_uart_wr(BRK3_STAT  ,  16'h0000);
      dbg_uart_rd(BRK3_STAT);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK3_STAT uncorrect =====");

      dbg_uart_wr(BRK3_ADDR0 ,  16'hffff);
      dbg_uart_rd(BRK3_ADDR0);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK3_ADDR0 uncorrect =====");
      dbg_uart_wr(BRK3_ADDR0 ,  16'h0000);
      dbg_uart_rd(BRK3_ADDR0);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK3_ADDR0 uncorrect =====");

      dbg_uart_wr(BRK3_ADDR1 ,  16'hffff);
      dbg_uart_rd(BRK3_ADDR1);
      if (dbg_uart_buf !== 16'hffff)      tb_error("====== BRK3_ADDR1 uncorrect =====");
      dbg_uart_wr(BRK3_ADDR1 ,  16'h0000);
      dbg_uart_rd(BRK3_ADDR1);
      if (dbg_uart_buf !== 16'h0000)      tb_error("====== BRK3_ADDR1 uncorrect =====");


      // TEST 16B WRITE BURSTS (MEMORY)
      //--------------------------------------------------------

      dbg_uart_wr(MEM_ADDR, 16'h0200); // select @0x0200
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
 
      dbg_uart_wr(MEM_CTL,  16'h0003); // Start burst to 16 bit memory write
      dbg_uart_tx16(16'h1234);         // write 1st data
      repeat(12) @(posedge mclk);
      if (mem200 !== 16'h1234)      tb_error("====== 16B WRITE BURSTS (MEMORY) WR ERROR: 1st DATA =====");
      dbg_uart_tx16(16'h5678);         // write 2nd data
      repeat(12) @(posedge mclk);
      if (mem202 !== 16'h5678)      tb_error("====== 16B WRITE BURSTS (MEMORY) WR ERROR: 2nd DATA =====");
      dbg_uart_tx16(16'h9abc);         // write 3rd data
      repeat(12) @(posedge mclk);
      if (mem204 !== 16'h9abc)      tb_error("====== 16B WRITE BURSTS (MEMORY) WR ERROR: 3rd DATA =====");
      dbg_uart_tx16(16'hdef0);         // write 4th data
      repeat(12) @(posedge mclk);
      if (mem206 !== 16'hdef0)      tb_error("====== 16B WRITE BURSTS (MEMORY) WR ERROR: 4th DATA =====");
      dbg_uart_tx16(16'h0fed);         // write 5th data
      repeat(12) @(posedge mclk);
      if (mem208 !== 16'h0fed)      tb_error("====== 16B WRITE BURSTS (MEMORY) WR ERROR: 5th DATA =====");
      
      dbg_uart_wr(MEM_ADDR, 16'h0200); // select @0x0200
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
      
      dbg_uart_wr(MEM_CTL,  16'h0001); // Start burst to 16 bit registers read
      dbg_uart_rx16();                 // read 1st data
      if (dbg_uart_buf !== 16'h1234)      tb_error("====== 16B WRITE BURSTS (MEMORY) RD ERROR: 1st DATA =====");
      dbg_uart_rx16();                 // read 2nd data
      if (dbg_uart_buf !== 16'h5678)      tb_error("====== 16B WRITE BURSTS (MEMORY) RD ERROR: 2nd DATA =====");
      dbg_uart_rx16();                 // read 3rd data
      if (dbg_uart_buf !== 16'h9abc)      tb_error("====== 16B WRITE BURSTS (MEMORY) RD ERROR: 3rd DATA =====");
      dbg_uart_rx16();                 // read 4th data
      if (dbg_uart_buf !== 16'hdef0)      tb_error("====== 16B WRITE BURSTS (MEMORY) RD ERROR: 4th DATA =====");
      dbg_uart_rx16();                 // read 5th data
      if (dbg_uart_buf !== 16'h0fed)      tb_error("====== 16B WRITE BURSTS (MEMORY) RD ERROR: 5th DATA =====");


      // TEST 16B WRITE BURSTS (CPU REGISTERS)
      //--------------------------------------------------------

      dbg_uart_wr(MEM_ADDR, 16'h0005); // select R5
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
 
      dbg_uart_wr(MEM_CTL,  16'h0007); // Start burst to 16 bit cpu register write
      dbg_uart_tx16(16'hcba9);         // write 1st data
      repeat(12) @(posedge mclk);
      if (r5 !== 16'hcba9)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) WR ERROR: 1st DATA =====");
      dbg_uart_tx16(16'h8765);         // write 2nd data
      repeat(12) @(posedge mclk);
      if (r6 !== 16'h8765)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) WR ERROR: 2nd DATA =====");
      dbg_uart_tx16(16'h4321);         // write 3rd data
      repeat(12) @(posedge mclk);
      if (r7 !== 16'h4321)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) WR ERROR: 3rd DATA =====");
      dbg_uart_tx16(16'h0123);         // write 4th data
      repeat(12) @(posedge mclk);
      if (r8 !== 16'h0123)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) WR ERROR: 4th DATA =====");
      dbg_uart_tx16(16'h4567);         // write 5th data
      repeat(12) @(posedge mclk);
      if (r9 !== 16'h4567)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) WR ERROR: 5th DATA =====");
      
      dbg_uart_wr(MEM_ADDR, 16'h0005); // select @0x0200
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
      
      dbg_uart_wr(MEM_CTL,  16'h0005); // Start burst to 16 bit cpu registers read
      dbg_uart_rx16();                 // read 1st data
      if (dbg_uart_buf !== 16'hcba9)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) RD ERROR: 1st DATA =====");
      dbg_uart_rx16();                 // read 2nd data
      if (dbg_uart_buf !== 16'h8765)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) RD ERROR: 2nd DATA =====");
      dbg_uart_rx16();                 // read 3rd data
      if (dbg_uart_buf !== 16'h4321)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) RD ERROR: 3rd DATA =====");
      dbg_uart_rx16();                 // read 4th data
      if (dbg_uart_buf !== 16'h0123)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) RD ERROR: 4th DATA =====");
      dbg_uart_rx16();                 // read 5th data
      if (dbg_uart_buf !== 16'h4567)      tb_error("====== 16B WRITE BURSTS (CPU REGISTERS) RD ERROR: 5th DATA =====");


      // TEST 8B WRITE BURSTS (MEMORY)
      //--------------------------------------------------------

      dbg_uart_wr(MEM_ADDR, 16'h0200); // select @0x0210
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
 
      dbg_uart_wr(MEM_CTL,  16'h000b); // Start burst to 8 bit memory write
      dbg_uart_tx(8'h91);         // write 1st data
      repeat(12) @(posedge mclk);
      if (mem200 !== 16'h1291)      tb_error("====== 8B WRITE BURSTS (MEMORY) WR ERROR: 1st DATA =====");
      dbg_uart_tx(8'h82);         // write 2nd data
      repeat(12) @(posedge mclk);
      if (mem200 !== 16'h8291)      tb_error("====== 8B WRITE BURSTS (MEMORY) WR ERROR: 2nd DATA =====");
      dbg_uart_tx(8'h73);         // write 3rd data
      repeat(12) @(posedge mclk);
      if (mem202 !== 16'h5673)      tb_error("====== 8B WRITE BURSTS (MEMORY) WR ERROR: 3rd DATA =====");
      dbg_uart_tx(8'h64);         // write 4th data
      repeat(12) @(posedge mclk);
      if (mem202 !== 16'h6473)      tb_error("====== 8B WRITE BURSTS (MEMORY) WR ERROR: 4th DATA =====");
      dbg_uart_tx(8'h55);         // write 5th data
      repeat(12) @(posedge mclk);
      if (mem204 !== 16'h9a55)      tb_error("====== 8B WRITE BURSTS (MEMORY) WR ERROR: 5th DATA =====");
      
      dbg_uart_wr(MEM_ADDR, 16'h0200); // select @0x0200
      dbg_uart_wr(MEM_CNT,  16'h0004); // 5 consecutive access
      
      dbg_uart_wr(MEM_CTL,  16'h0009); // Start burst to 8 bit registers read
      dbg_uart_rx8();                 // read 1st data
      if (dbg_uart_buf !== 16'h0091)      tb_error("====== 8B WRITE BURSTS (MEMORY) RD ERROR: 1st DATA =====");
      dbg_uart_rx8();                 // read 2nd data
      if (dbg_uart_buf !== 16'h0082)      tb_error("====== 8B WRITE BURSTS (MEMORY) RD ERROR: 2nd DATA =====");
      dbg_uart_rx8();                 // read 3rd data
      if (dbg_uart_buf !== 16'h0073)      tb_error("====== 8B WRITE BURSTS (MEMORY) RD ERROR: 3rd DATA =====");
      dbg_uart_rx8();                 // read 4th data
      if (dbg_uart_buf !== 16'h0064)      tb_error("====== 8B WRITE BURSTS (MEMORY) RD ERROR: 4th DATA =====");
      dbg_uart_rx8();                 // read 5th data
      if (dbg_uart_buf !== 16'h0055)      tb_error("====== 8B WRITE BURSTS (MEMORY) RD ERROR: 5th DATA =====");




      
      dbg_uart_wr(CPU_CTL    ,  16'h0002); 
      repeat(10) @(posedge mclk);

      stimulus_done = 1;
   end

