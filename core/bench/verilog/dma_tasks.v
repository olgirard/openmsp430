//----------------------------------------------------------------------------
// Copyright (C) 2014 Authors
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
// *File Name: dma_tasks.v
//
// *Module Description:
//                      generic tasks for using the Direct Memory Access interface
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------

//============================================================================
// DMA Write access
//============================================================================

//---------------------
// Generic write task
//---------------------
task dma_write;
   input  [15:0] addr;   // Address
   input  [15:0] data;   // Data
   input         size;   // Access size (0: 8-bit / 1: 16-bit)

   begin
      dma_addr = addr[15:1];
      dma_en   = 1'b1;
      dma_we   = size    ? 2'b11  :
                 addr[0] ? 2'b10  :  2'b01;
      dma_din  = data;
      @(posedge mclk);
      while(~dma_ready) @(posedge mclk);
      dma_en   = 1'b0;
      dma_we   = 2'b00;
      dma_addr = 15'h0000;
      dma_din  = 16'h0000;
   end
endtask

//---------------------
// Write 16b task
//---------------------
task dma_write_16b;
   input  [15:0] addr;   // Address
   input  [15:0] data;   // Data

   begin
      dma_write(addr, data, 1'b1);
   end
endtask

//---------------------
// Write 8b task
//---------------------
task dma_write_8b;
   input  [15:0] addr;   // Address
   input   [7:0] data;   // Data

   begin
      if (addr[0]) dma_write(addr, {data,  8'h00}, 1'b0);
      else         dma_write(addr, {8'h00, data }, 1'b0);
   end
endtask


//============================================================================
// DMA read access
//============================================================================

//---------------------
// Read check process
//---------------------
reg        dma_read_check_active;
reg [15:0] dma_read_check_addr;
reg [15:0] dma_read_check_data;
reg [15:0] dma_read_check_mask;
integer    dma_wr_error;
integer    dma_rd_error;

initial
  begin
     dma_read_check_active =  1'b0;
     dma_read_check_addr   = 16'h0000;
     dma_read_check_data   = 16'h0000;
     dma_read_check_mask   = 16'h0000;
     forever
       begin
	  @(negedge (mclk & dma_read_check_active));
	  if ((dma_read_check_data !== (dma_read_check_mask & dma_dout)) & ~puc_rst)
	    begin
	       $display("ERROR: DMA interface read check -- address: 0x%h -- read: 0x%h / expected: 0x%h (%t ns)", dma_read_check_addr, (dma_read_check_mask & dma_dout), dma_read_check_data, $time);
	       dma_rd_error = dma_rd_error+1;
	    end
	  dma_read_check_active =  1'b0;
       end
  end

//---------------------
// Generic read task
//---------------------
task dma_read;
   input  [15:0] addr;   // Address
   input  [15:0] data;   // Data to check against
   input         size;   // Access size (0: 8-bit / 1: 16-bit)

   begin
      // Perform read transfer
      dma_addr = addr[15:1];
      dma_en   = 1'b1;
      dma_we   = 2'b00;
      dma_din  = 16'h0000;
      @(posedge mclk);
      while(~dma_ready) @(posedge mclk);
      dma_en   = 1'b0;
      dma_addr = 15'h0000;

      // Trigger read check
      dma_read_check_active =  1'b1;
      dma_read_check_addr   =  addr;
      dma_read_check_data   =  data;
      dma_read_check_mask   =  size    ? 16'hFFFF :
                              (addr[0] ? 16'hFF00 : 16'h00FF);
   end
endtask

//---------------------
// Read 16b task
//---------------------
task dma_read_16b;
   input  [15:0] addr;   // Address
   input  [15:0] data;   // Data to check against

   begin
      dma_read(addr, data, 1'b1);
   end
endtask

//---------------------
// Read 8b task
//---------------------
task dma_read_8b;
   input  [15:0] addr;   // Address
   input   [7:0] data;   // Data to check against

   begin
      if (addr[0]) dma_read(addr, {data,  8'h00}, 1'b0);
      else         dma_read(addr, {8'h00, data }, 1'b0);
   end
endtask


//============================================================================
// Ramdom DMA access process
//============================================================================

integer    dma_rand_wait;
reg        dma_rand_rdwr;
integer	   dma_rand_data;
integer	   dma_rand_addr;
integer    dma_mem_ref_idx;
reg [15:0] dma_pmem_reference[0:255];
reg [15:0] dma_dmem_reference[0:255];
reg	   dma_verif_on;
reg	   dma_verif_verbose;
integer    dma_cnt_wr;
integer    dma_cnt_rd;

initial
  begin
     // Initialize
   `ifdef NO_DMA_VERIF
     dma_verif_on      = 0;
   `else
     dma_verif_on      = 1;
   `endif
     dma_verif_verbose = 0;
     dma_cnt_wr        = 0;
     dma_cnt_rd        = 0;
     dma_wr_error      = 0;
     dma_rd_error      = 0;
     #1;
     dma_rand_wait     = $urandom;
     for (dma_mem_ref_idx=0; dma_mem_ref_idx < 256; dma_mem_ref_idx=dma_mem_ref_idx+1)
       begin
	  dma_pmem_reference[dma_mem_ref_idx] = 16'h0000;
	  dma_dmem_reference[dma_mem_ref_idx] = 16'h0000;
       end

     // Wait for reset release
     repeat(1) @(posedge dco_clk);
     @(negedge puc_rst);

     // Perform random read/write 16b memory accesses
     if (dma_verif_on && (`PMEM_SIZE>=4092) && (`DMEM_SIZE>=512))
       begin
	  forever
	    begin
	       // Randomize 1 or 0 wait states between accesses
	       // (1/3 proba of getting 1 wait state)
	       dma_rand_wait = ($urandom_range(2,0)==0);
	       repeat(dma_rand_wait) @(posedge mclk);

	       // Randomize read/write accesses
	       // (1/3 proba of getting a read access)
	       dma_rand_rdwr = ($urandom_range(2,0)==0);
	       dma_rand_addr = $urandom & 'hFE;
	       if (dma_rand_rdwr)
		 begin
		    if (dma_verif_verbose)
		      $display("READ  DMA interface -- address: 0x%h -- expected data: 0x%h", 16'hFE00+dma_rand_addr, dma_pmem_reference[dma_rand_addr]);
		    dma_cnt_rd = dma_cnt_rd+1;
		    dma_read_16b(16'hFE00+dma_rand_addr,  dma_pmem_reference[dma_rand_addr]);
		 end
	       else
		 begin
		    dma_rand_data = $urandom;
		    if (dma_verif_verbose)
		      $display("WRITE DMA interface -- address: 0x%h -- data: 0x%h", 16'hFE00+dma_rand_addr, dma_rand_data[15:0]);
		    dma_cnt_wr = dma_cnt_wr+1;
		    dma_write_16b(16'hFE00+dma_rand_addr, dma_rand_data[15:0]);
		    dma_pmem_reference[dma_rand_addr] = dma_rand_data[15:0];
		    #1;
		    if (pmem_0.mem[(`PMEM_SIZE-512+dma_rand_addr)/2] !== dma_rand_data[15:0])
		      begin
			 $display("ERROR: DMA interface write -- address: 0x%h -- wrote: 0x%h / expected: 0x%h (%t ns)", 16'hFE00+dma_rand_addr, dma_rand_data[15:0], pmem_0.mem[(`PMEM_SIZE-512+dma_rand_addr)/2], $time);
			 dma_wr_error = dma_wr_error+1;
		      end
		 end
	    end
       end
  end
