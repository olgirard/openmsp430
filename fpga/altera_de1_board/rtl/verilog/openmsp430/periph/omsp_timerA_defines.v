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
// *File Name: omsp_timerA_defines.v
// 
// *Module Description:
//                      omsp_timerA Configuration file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------
//`define OMSP_TA_NO_INCLUDE
`ifdef OMSP_TA_NO_INCLUDE
`else
`include "omsp_timerA_undefines.v"
`endif

//----------------------------------------------------------------------------
// TIMER A CONFIGURATION
//----------------------------------------------------------------------------



//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//=====        SYSTEM CONSTANTS --- !!!!!!!! DO NOT EDIT !!!!!!!!      =====//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//

// Timer A: TACTL Control Register
`define TASSELx     9:8
`define TAIDx       7:6
`define TAMCx       5:4
`define TACLR       2
`define TAIE        1
`define TAIFG       0

// Timer A: TACCTLx Capture/Compare Control Register
`define TACMx      15:14
`define TACCISx    13:12
`define TASCS      11
`define TASCCI     10
`define TACAP       8
`define TAOUTMODx   7:5
`define TACCIE      4
`define TACCI       3
`define TAOUT       2
`define TACOV       1
`define TACCIFG     0
