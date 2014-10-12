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
/*                  Simple full duplex UART (8N1 protocol)                   */
/*---------------------------------------------------------------------------*/
/* Test the UART peripheral.                                                 */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 85 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-01-28 22:05:37 +0100 (Fri, 28 Jan 2011) $          */
/*===========================================================================*/
    

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      uart_baudrate(2000000);
      
      // WATCHDOG TEST INTERVAL MODE /64 - SMCLK == MCLK/2
      //--------------------------------------------------------
      @(r15 === 16'h0001);

      uart_tx(8'ha5);
      repeat(100) @(negedge mclk);
      uart_tx(8'h34);
      repeat(100) @(negedge mclk);
      uart_tx(8'h56);
      uart_tx(8'h78);
 

      @(negedge mclk);
//      mclk_counter = 0;
      repeat(200) @(negedge mclk);

//      if (mclk_counter !== 1024) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK =====");
//      if (r5_counter   !== 8)    tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK =====");

      
      // WATCHDOG TEST INTERVAL MODE /64 - ACLK == LFXTCLK/1
      //--------------------------------------------------------

      repeat(10000) @(negedge mclk);


      
      stimulus_done = 1;
   end

