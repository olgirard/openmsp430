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
/*                        - Watchdog mode.                                   */
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
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // WATCHDOG TEST:  RD/WR ACCESS
      //--------------------------------------------------------

      @(mem250===16'h1000);
      if (mem200 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 =====");
      if (mem202 !== 16'h69d7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69d3 =====");
      if (mem204 !== 16'h6955) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6951 =====");
      if (mem206 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 =====");
      if (mem208 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 =====");

  
      // WATCHDOG TEST:  WATCHDOG MODE /64
      //--------------------------------------------------------

      @(mem250===16'h2000);
      if (mem200 !== 16'h000A) tb_error("====== WATCHDOG MODE /64: @0x200 != 0x000A =====");
    
      $display("Watchdog mode /64 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /512
      //--------------------------------------------------------

      @(mem250===16'h3000);
      if (mem202 !== 16'h0055) tb_error("====== WATCHDOG MODE /512: @0x202 != 0x0055 =====");

      $display("Watchdog mode /512 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /8192
      //--------------------------------------------------------

      @(mem250===16'h4000);
      if (mem204 !== 16'h0555) tb_error("====== WATCHDOG MODE /8192: @0x204 != 0x0555 =====");

      $display("Watchdog mode /8192 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /32768
      //--------------------------------------------------------

      @(mem250===16'h5000);
      if (mem206 !== 16'h1555) tb_error("====== WATCHDOG MODE /32768: @0x206 != 0x1555 =====");

      $display("Watchdog mode /32768 mode test completed...");


      stimulus_done = 1;
   end

