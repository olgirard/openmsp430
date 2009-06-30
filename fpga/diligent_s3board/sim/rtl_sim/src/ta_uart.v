/*===========================================================================*/
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface.                                           */
/*===========================================================================*/

reg [32*8-1:0] rx_chain;
integer        rx_offset;


reg [7:0] rxbuf;
integer   rxcnt;
`define   BAUD    140

task uart_rx;
      begin
	 @(negedge UART_TXD);  
	 rxbuf = 0;      
	 repeat(`BAUD*3/2) @(posedge mclk);
	 for (rxcnt = 0; rxcnt < 8; rxcnt = rxcnt + 1)
	   begin
	      rxbuf = {UART_TXD, rxbuf[7:1]};
	      repeat(`BAUD) @(posedge mclk);	   
	end
      end
endtask

task uart_tx;
      input [7:0] txbuf;

      reg [9:0] txbuf_full;
      integer   txcnt;
      begin
	 UART_RXD = 1'b1;
	 txbuf_full = {1'b1, txbuf, 1'b0};
	 repeat(`BAUD) @(posedge mclk);
	 for (txcnt = 0; txcnt < 10; txcnt = txcnt + 1)
	   begin
	      UART_RXD   =  txbuf_full[txcnt];
//	      txbuf_full = {txbuf_full[8:1], 1'b0};
	      repeat(`BAUD) @(posedge mclk);	   
	   end
      end
endtask



initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge CLK_50MHz);
      stimulus_done = 0;
      rx_chain = 0;
      rx_offset = 0;

      while (rx_offset<1)
	begin
	   uart_rx;
	   rx_chain = rx_chain | (rxbuf << (31*8-(8*rx_offset)));
	   rx_offset = rx_offset+1;
	end

      repeat(50) @(posedge CLK_50MHz);
      uart_tx("a");
      
//      repeat(5000) @(posedge mclk);
//      UART_RXD = 1;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 0;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 1;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 0;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 1;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 0;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 1;
//      repeat(160) @(posedge mclk);
//      UART_RXD = 0;
//      repeat(160) @(posedge mclk);


      stimulus_done = 1;
      //repeat(1000) @(posedge mclk);
      //$finish();

   end

