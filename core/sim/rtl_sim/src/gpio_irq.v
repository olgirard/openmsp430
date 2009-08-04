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
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface:                                           */
/*                                   - Interrupts.                           */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 17 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:15:39 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // PORT 1: TEST INTERRUPT FLAGS
      //--------------------------------------------------------

      @(r15==16'h0200) p1_din = 8'h01;
      @(r15==16'h0201) p1_din = 8'h03;
      @(r15==16'h0202) p1_din = 8'h07;
      @(r15==16'h0203) p1_din = 8'h0f;
      @(r15==16'h0204) p1_din = 8'h1f;
      @(r15==16'h0205) p1_din = 8'h3f;
      @(r15==16'h0206) p1_din = 8'h7f;
      @(r15==16'h0207) p1_din = 8'hff;
      @(r15==16'h0208);
      if (mem200 !== 16'h0201) tb_error("====== RISING EDGE TEST: P1IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== RISING EDGE TEST: P1IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== RISING EDGE TEST: P1IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== RISING EDGE TEST: P1IFG != 0x8040 =====");

      
      @(r15==16'h0210) p1_din = 8'h7f;
      @(r15==16'h0211) p1_din = 8'h3f;
      @(r15==16'h0212) p1_din = 8'h1f;
      @(r15==16'h0213) p1_din = 8'h0f;
      @(r15==16'h0214) p1_din = 8'h07;
      @(r15==16'h0215) p1_din = 8'h03;
      @(r15==16'h0216) p1_din = 8'h01;
      @(r15==16'h0217) p1_din = 8'h00;
      @(r15==16'h0218);
      if (mem210 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem212 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem214 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem216 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");

      
      @(r15==16'h0220) p1_din = 8'h01;
      @(r15==16'h0221) p1_din = 8'h03;
      @(r15==16'h0222) p1_din = 8'h07;
      @(r15==16'h0223) p1_din = 8'h0f;
      @(r15==16'h0224) p1_din = 8'h1f;
      @(r15==16'h0225) p1_din = 8'h3f;
      @(r15==16'h0226) p1_din = 8'h7f;
      @(r15==16'h0227) p1_din = 8'hff;
      @(r15==16'h0228);
      if (mem220 !== 16'h0301) tb_error("====== RISING EDGE TEST: P1IFG != 0x0301 =====");
      if (mem222 !== 16'h0f07) tb_error("====== RISING EDGE TEST: P1IFG != 0x0f07 =====");
      if (mem224 !== 16'h3f1f) tb_error("====== RISING EDGE TEST: P1IFG != 0x3f1f =====");
      if (mem226 !== 16'hff7f) tb_error("====== RISING EDGE TEST: P1IFG != 0xff7f =====");

   
      @(r15==16'h0230) p1_din = 8'h7f;
      @(r15==16'h0231) p1_din = 8'h3f;
      @(r15==16'h0232) p1_din = 8'h1f;
      @(r15==16'h0233) p1_din = 8'h0f;
      @(r15==16'h0234) p1_din = 8'h07;
      @(r15==16'h0235) p1_din = 8'h03;
      @(r15==16'h0236) p1_din = 8'h01;
      @(r15==16'h0237) p1_din = 8'h00;
      @(r15==16'h0238);
      if (mem230 !== 16'h4080) tb_error("====== FALLING EDGE TEST: P1IFG != 0x4080 =====");
      if (mem232 !== 16'h1020) tb_error("====== FALLING EDGE TEST: P1IFG != 0x1020 =====");
      if (mem234 !== 16'h0408) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0408 =====");
      if (mem236 !== 16'h0102) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0102 =====");

      @(r15==16'h0240) p1_din = 8'h01;
      @(r15==16'h0241) p1_din = 8'h03;
      @(r15==16'h0242) p1_din = 8'h07;
      @(r15==16'h0243) p1_din = 8'h0f;
      @(r15==16'h0244) p1_din = 8'h1f;
      @(r15==16'h0245) p1_din = 8'h3f;
      @(r15==16'h0246) p1_din = 8'h7f;
      @(r15==16'h0247) p1_din = 8'hff;
      @(r15==16'h0248);
      if (mem240 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem242 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem244 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem246 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");

      @(r15==16'h0250) p1_din = 8'h7f;
      @(r15==16'h0251) p1_din = 8'h3f;
      @(r15==16'h0252) p1_din = 8'h1f;
      @(r15==16'h0253) p1_din = 8'h0f;
      @(r15==16'h0254) p1_din = 8'h07;
      @(r15==16'h0255) p1_din = 8'h03;
      @(r15==16'h0256) p1_din = 8'h01;
      @(r15==16'h0257) p1_din = 8'h00;
      @(r15==16'h0258);
      if (mem250 !== 16'hc080) tb_error("====== FALLING EDGE TEST: P1IFG != 0xc080 =====");
      if (mem252 !== 16'hf0e0) tb_error("====== FALLING EDGE TEST: P1IFG != 0xf0e0 =====");
      if (mem254 !== 16'hfcf8) tb_error("====== FALLING EDGE TEST: P1IFG != 0xfcf8 =====");
      if (mem256 !== 16'hfffe) tb_error("====== FALLING EDGE TEST: P1IFG != 0xfffe =====");

      
      // PORT 2: TEST INTERRUPT FLAGS
      //--------------------------------------------------------

      @(r15==16'h0200) p2_din = 8'h01;
      @(r15==16'h0201) p2_din = 8'h03;
      @(r15==16'h0202) p2_din = 8'h07;
      @(r15==16'h0203) p2_din = 8'h0f;
      @(r15==16'h0204) p2_din = 8'h1f;
      @(r15==16'h0205) p2_din = 8'h3f;
      @(r15==16'h0206) p2_din = 8'h7f;
      @(r15==16'h0207) p2_din = 8'hff;
      @(r15==16'h0208);
      if (mem200 !== 16'h0201) tb_error("====== RISING EDGE TEST: P2IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== RISING EDGE TEST: P2IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== RISING EDGE TEST: P2IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== RISING EDGE TEST: P2IFG != 0x8040 =====");

      
      @(r15==16'h0210) p2_din = 8'h7f;
      @(r15==16'h0211) p2_din = 8'h3f;
      @(r15==16'h0212) p2_din = 8'h1f;
      @(r15==16'h0213) p2_din = 8'h0f;
      @(r15==16'h0214) p2_din = 8'h07;
      @(r15==16'h0215) p2_din = 8'h03;
      @(r15==16'h0216) p2_din = 8'h01;
      @(r15==16'h0217) p2_din = 8'h00;
      @(r15==16'h0218);
      if (mem210 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem212 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem214 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem216 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");

      
      @(r15==16'h0220) p2_din = 8'h01;
      @(r15==16'h0221) p2_din = 8'h03;
      @(r15==16'h0222) p2_din = 8'h07;
      @(r15==16'h0223) p2_din = 8'h0f;
      @(r15==16'h0224) p2_din = 8'h1f;
      @(r15==16'h0225) p2_din = 8'h3f;
      @(r15==16'h0226) p2_din = 8'h7f;
      @(r15==16'h0227) p2_din = 8'hff;
      @(r15==16'h0228);
      if (mem220 !== 16'h0301) tb_error("====== RISING EDGE TEST: P2IFG != 0x0301 =====");
      if (mem222 !== 16'h0f07) tb_error("====== RISING EDGE TEST: P2IFG != 0x0f07 =====");
      if (mem224 !== 16'h3f1f) tb_error("====== RISING EDGE TEST: P2IFG != 0x3f1f =====");
      if (mem226 !== 16'hff7f) tb_error("====== RISING EDGE TEST: P2IFG != 0xff7f =====");

   
      @(r15==16'h0230) p2_din = 8'h7f;
      @(r15==16'h0231) p2_din = 8'h3f;
      @(r15==16'h0232) p2_din = 8'h1f;
      @(r15==16'h0233) p2_din = 8'h0f;
      @(r15==16'h0234) p2_din = 8'h07;
      @(r15==16'h0235) p2_din = 8'h03;
      @(r15==16'h0236) p2_din = 8'h01;
      @(r15==16'h0237) p2_din = 8'h00;
      @(r15==16'h0238);
      if (mem230 !== 16'h4080) tb_error("====== FALLING EDGE TEST: P2IFG != 0x4080 =====");
      if (mem232 !== 16'h1020) tb_error("====== FALLING EDGE TEST: P2IFG != 0x1020 =====");
      if (mem234 !== 16'h0408) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0408 =====");
      if (mem236 !== 16'h0102) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0102 =====");

      @(r15==16'h0240) p2_din = 8'h01;
      @(r15==16'h0241) p2_din = 8'h03;
      @(r15==16'h0242) p2_din = 8'h07;
      @(r15==16'h0243) p2_din = 8'h0f;
      @(r15==16'h0244) p2_din = 8'h1f;
      @(r15==16'h0245) p2_din = 8'h3f;
      @(r15==16'h0246) p2_din = 8'h7f;
      @(r15==16'h0247) p2_din = 8'hff;
      @(r15==16'h0248);
      if (mem240 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem242 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem244 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem246 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");

      @(r15==16'h0250) p2_din = 8'h7f;
      @(r15==16'h0251) p2_din = 8'h3f;
      @(r15==16'h0252) p2_din = 8'h1f;
      @(r15==16'h0253) p2_din = 8'h0f;
      @(r15==16'h0254) p2_din = 8'h07;
      @(r15==16'h0255) p2_din = 8'h03;
      @(r15==16'h0256) p2_din = 8'h01;
      @(r15==16'h0257) p2_din = 8'h00;
      @(r15==16'h0258);
      if (mem250 !== 16'hc080) tb_error("====== FALLING EDGE TEST: P2IFG != 0xc080 =====");
      if (mem252 !== 16'hf0e0) tb_error("====== FALLING EDGE TEST: P2IFG != 0xf0e0 =====");
      if (mem254 !== 16'hfcf8) tb_error("====== FALLING EDGE TEST: P2IFG != 0xfcf8 =====");
      if (mem256 !== 16'hfffe) tb_error("====== FALLING EDGE TEST: P2IFG != 0xfffe =====");

      
      // PORT 1: TEST INTERRUPT VECTOR
      //--------------------------------------------------------

      @(r15==16'h0208);
      if (mem200 !== 16'h0201) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x8040 =====");

      
      // PORT 2: TEST INTERRUPT VECTOR
      //--------------------------------------------------------

      @(r15==16'h0218);
      if (mem210 !== 16'h0201) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0201 =====");
      if (mem212 !== 16'h0804) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0804 =====");
      if (mem214 !== 16'h2010) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x2010 =====");
      if (mem216 !== 16'h8040) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x8040 =====");


      stimulus_done = 1;
   end

