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
/*                            WATCHDOG TIMER                                 */
/*---------------------------------------------------------------------------*/
/* Test the Watdog timer:                                                    */
/*                        - Interval timer mode.                             */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 17 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:15:39 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/
    
`define LONG_TIMEOUT

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // WATCHDOG TEST:  RD/WR ACCESS
      //--------------------------------------------------------

      @(r15==16'h1000);
      if (r4 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 =====");
      if (r5 !== 16'h69d7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69d3 =====");
      if (r6 !== 16'h6955) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6951 =====");
      if (r7 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 =====");
      if (r8 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 =====");

  
      // WATCHDOG TEST:  INTERVAL MODE /64
      //--------------------------------------------------------

      @(r15==16'h2000);
      if (r5 !== 16'h3401) tb_error("====== WATCHDOG INTERVAL MODE /64: R5 != 0x3401 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64: R6 != 0x0000 =====");
      if (r7 !== 16'h000D) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x000D =====");
    
      @(r15==16'h2001);
      if (r5 !== 16'h0002) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R5 != 0x0002 =====");
      if (r6 !== 16'h0001) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R6 != 0x0001 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R7 != 0x0000 =====");
      if (r8 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R8 != 0x0000 =====");

      @(r15==16'h2002);
      if (r5 !== 16'h0022) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R5 != 0x0022 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R6 != 0x0000 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R7 != 0x0000 =====");

      @(r15==16'h2003);
      if (r4 !== 16'h0033) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R4 != 0x0033 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R6 != 0x0000 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R7 != 0x0000 =====");
      if (r8 !== 16'h0001) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R8 != 0x0001 =====");

      $display("Interval mode /64 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /512
      //--------------------------------------------------------

      @(r15==16'h3000);
      if (r5 !== 16'h3403) tb_error("====== WATCHDOG INTERVAL MODE /512: R5 != 0x3403 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /512: R6 != 0x0000 =====");
      if (r7 !== 16'h0067) tb_error("====== WATCHDOG INTERVAL MODE /512: R7 != 0x0067 =====");

      $display("Interval mode /512 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /8192
      //--------------------------------------------------------

      @(r15==16'h4000);
      if (r5 !== 16'h3404) tb_error("====== WATCHDOG INTERVAL MODE /8192: R5 != 0x3404 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /8192: R6 != 0x0000 =====");
      if (r7 !== 16'h0667) tb_error("====== WATCHDOG INTERVAL MODE /8192: R7 != 0x0667 =====");

      $display("Interval mode /8192 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /32768
      //--------------------------------------------------------

      @(r15==16'h5000);
      if (r5 !== 16'h3405) tb_error("====== WATCHDOG INTERVAL MODE /32768: R5 != 0x3405 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /32768: R6 != 0x0000 =====");
      if (r7 !== 16'h199a) tb_error("====== WATCHDOG INTERVAL MODE /32768: R7 != 0x199A =====");

      $display("Interval mode /32768 mode test completed...");


      stimulus_done = 1;
   end

