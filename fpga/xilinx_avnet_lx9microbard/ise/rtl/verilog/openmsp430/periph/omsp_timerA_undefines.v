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
// *File Name: omsp_timerA_undefines.v
// 
// *Module Description:
//                      omsp_timerA Verilog `undef file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// SYSTEM CONFIGURATION
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
`ifdef TASSELx
`undef TASSELx
`endif
`ifdef TAIDx
`undef TAIDx
`endif
`ifdef TAMCx
`undef TAMCx
`endif
`ifdef TACLR
`undef TACLR
`endif
`ifdef TAIE
`undef TAIE
`endif
`ifdef TAIFG
`undef TAIFG
`endif

// Timer A: TACCTLx Capture/Compare Control Register
`ifdef TACMx
`undef TACMx
`endif
`ifdef TACCISx
`undef TACCISx
`endif
`ifdef TASCS
`undef TASCS
`endif
`ifdef TASCCI
`undef TASCCI
`endif
`ifdef TACAP
`undef TACAP
`endif
`ifdef TAOUTMODx
`undef TAOUTMODx
`endif
`ifdef TACCIE
`undef TACCIE
`endif
`ifdef TACCI
`undef TACCI
`endif
`ifdef TAOUT
`undef TAOUT
`endif
`ifdef TACOV
`undef TACOV
`endif
`ifdef TACCIFG
`undef TACCIFG
`endif
