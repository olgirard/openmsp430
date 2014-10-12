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
// *File Name: dbg_uart_tasks.v
// 
// *Module Description:
//                      openMSP430 debug interface UART tasks
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 17 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-04 23:15:39 +0200 (Tue, 04 Aug 2009) $
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// UART COMMUNICATION DATA RATE CONFIGURATION
//----------------------------------------------------------------------------
integer uart_cnt  = ((20000000/115200)-1);

task uart_baudrate;
      input integer baudrate;

   begin
      uart_cnt  = ((20000000/baudrate)-1);
   end
endtask


//----------------------------------------------------------------------------
// Receive UART frame (8N1)
//----------------------------------------------------------------------------
task uart_rx;
      output [7:0] rxbuf;
      
      reg [7:0] rxbuf;
      reg [7:0] temp;
      integer   rxcnt;
      begin
	 @(negedge uart_txd);  
	 rxbuf = 0;      
	 temp = 0;      
	 repeat((uart_cnt+1)/2) @(posedge mclk);
	 for (rxcnt = 0; rxcnt < 8; rxcnt = rxcnt + 1)
	   begin
	      repeat(uart_cnt+1) @(posedge mclk);	   
	      temp = {uart_txd, temp[7:1]};
	   end
	 rxbuf = temp;	 
      end
endtask


//----------------------------------------------------------------------------
// Transmit UART frame (8N1)
//----------------------------------------------------------------------------
task uart_tx;
      input  [7:0] txbuf;

      reg [9:0] txbuf_full;
      integer   txcnt;
      begin
	 dbg_uart_rxd = 1'b1;
	 txbuf_full   = {1'b1, txbuf, 1'b0};
	 for (txcnt = 0; txcnt < 10; txcnt = txcnt + 1)
	   begin
	      repeat(uart_cnt+1) @(posedge mclk);	   
	      uart_rxd =  txbuf_full[txcnt];
	   end
      end
endtask
