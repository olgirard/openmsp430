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
/*                        - Clock source selection.                          */
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

integer mclk_counter;
always @ (posedge mclk)
  mclk_counter <=  mclk_counter+1;

integer r5_counter;
always @ (posedge r5[0] or negedge r5[0])
  r5_counter <=  r5_counter+1;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // WATCHDOG TEST INTERVAL MODE /64 - SMCLK == MCLK/2
      //--------------------------------------------------------

      @(r15 === 16'h0001);
      @(posedge r5[0]);
      @(negedge mclk);
      mclk_counter = 0;
      r5_counter   = 0;
      repeat(1024) @(negedge mclk);
      if (mclk_counter !== 1024) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK =====");
      if (r5_counter   !== 8)    tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK =====");

      
      // WATCHDOG TEST INTERVAL MODE /64 - ACLK == LFXTCLK/1
      //--------------------------------------------------------

      @(r15 === 16'h1001);
      @(negedge r5[0]);
      @(negedge mclk);
      mclk_counter = 0;
      r5_counter   = 0;
      repeat(7813) @(negedge mclk);
      if (mclk_counter !== 7813) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK =====");
      if (r5_counter   !== 4)    tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK =====");

      

      stimulus_done = 1;
   end

