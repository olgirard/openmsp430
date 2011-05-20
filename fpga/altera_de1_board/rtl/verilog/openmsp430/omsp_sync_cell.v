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
// *File Name: omsp_sync_cell.v
// 
// *Module Description:
//                       Generic synchronizer for the openMSP430
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------

module  omsp_sync_cell (

// OUTPUTs
    data_out,                      // Synchronized data output

// INPUTs
    clk,                           // Receiving clock
    data_in,                       // Asynchronous data input
    rst                            // Receiving reset (active high)
);

// OUTPUTs
//=========
output              data_out;      // Synchronized data output

// INPUTs
//=========
input               clk;          // Receiving clock
input               data_in;      // Asynchronous data input
input               rst;          // Receiving reset (active high)


//=============================================================================
// 1)  SYNCHRONIZER
//=============================================================================

reg  [1:0] data_sync;

always @(posedge clk or posedge rst)
  if (rst) data_sync <=  2'b00;
  else     data_sync <=  {data_sync[0], data_in};

assign     data_out   =   data_sync[1];


endmodule // omsp_sync_cell

