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
// *File Name: registers.v
// 
// *Module Description:
//                      Direct connections to internal registers & memory.
//
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------

// CPU registers
//======================

wire       [15:0] r0    = dut.execution_unit_0.register_file_0.r0;
wire       [15:0] r1    = dut.execution_unit_0.register_file_0.r1;
wire       [15:0] r2    = dut.execution_unit_0.register_file_0.r2;
wire       [15:0] r3    = dut.execution_unit_0.register_file_0.r3;
wire       [15:0] r4    = dut.execution_unit_0.register_file_0.r4;
wire       [15:0] r5    = dut.execution_unit_0.register_file_0.r5;
wire       [15:0] r6    = dut.execution_unit_0.register_file_0.r6;
wire       [15:0] r7    = dut.execution_unit_0.register_file_0.r7;
wire       [15:0] r8    = dut.execution_unit_0.register_file_0.r8;
wire       [15:0] r9    = dut.execution_unit_0.register_file_0.r9;
wire       [15:0] r10   = dut.execution_unit_0.register_file_0.r10;
wire       [15:0] r11   = dut.execution_unit_0.register_file_0.r11;
wire       [15:0] r12   = dut.execution_unit_0.register_file_0.r12;
wire       [15:0] r13   = dut.execution_unit_0.register_file_0.r13;
wire       [15:0] r14   = dut.execution_unit_0.register_file_0.r14;
wire       [15:0] r15   = dut.execution_unit_0.register_file_0.r15;


// RAM cells
//======================

wire       [15:0] mem200 = ram_0.mem[0];
wire       [15:0] mem202 = ram_0.mem[1];
wire       [15:0] mem204 = ram_0.mem[2];
wire       [15:0] mem206 = ram_0.mem[3];
wire       [15:0] mem208 = ram_0.mem[4];
wire       [15:0] mem20A = ram_0.mem[5];
wire       [15:0] mem20C = ram_0.mem[6];
wire       [15:0] mem20E = ram_0.mem[7];
wire       [15:0] mem210 = ram_0.mem[8];
wire       [15:0] mem212 = ram_0.mem[9];
wire       [15:0] mem214 = ram_0.mem[10];
wire       [15:0] mem216 = ram_0.mem[11];
wire       [15:0] mem218 = ram_0.mem[12];
wire       [15:0] mem21A = ram_0.mem[13];
wire       [15:0] mem21C = ram_0.mem[14];
wire       [15:0] mem21E = ram_0.mem[15];
wire       [15:0] mem220 = ram_0.mem[16];
wire       [15:0] mem222 = ram_0.mem[17];
wire       [15:0] mem224 = ram_0.mem[18];
wire       [15:0] mem226 = ram_0.mem[19];
wire       [15:0] mem228 = ram_0.mem[20];
wire       [15:0] mem22A = ram_0.mem[21];
wire       [15:0] mem22C = ram_0.mem[22];
wire       [15:0] mem22E = ram_0.mem[23];
wire       [15:0] mem230 = ram_0.mem[24];
wire       [15:0] mem232 = ram_0.mem[25];
wire       [15:0] mem234 = ram_0.mem[26];
wire       [15:0] mem236 = ram_0.mem[27];
wire       [15:0] mem238 = ram_0.mem[28];
wire       [15:0] mem23A = ram_0.mem[29];
wire       [15:0] mem23C = ram_0.mem[30];
wire       [15:0] mem23E = ram_0.mem[31];
wire       [15:0] mem240 = ram_0.mem[32];
wire       [15:0] mem242 = ram_0.mem[33];
wire       [15:0] mem244 = ram_0.mem[34];
wire       [15:0] mem246 = ram_0.mem[35];
wire       [15:0] mem248 = ram_0.mem[36];
wire       [15:0] mem24A = ram_0.mem[37];
wire       [15:0] mem24C = ram_0.mem[38];
wire       [15:0] mem24E = ram_0.mem[39];
wire       [15:0] mem250 = ram_0.mem[40];
wire       [15:0] mem252 = ram_0.mem[41];
wire       [15:0] mem254 = ram_0.mem[42];
wire       [15:0] mem256 = ram_0.mem[43];
wire       [15:0] mem258 = ram_0.mem[44];
wire       [15:0] mem25A = ram_0.mem[45];
wire       [15:0] mem25C = ram_0.mem[46];
wire       [15:0] mem25E = ram_0.mem[47];
wire       [15:0] mem260 = ram_0.mem[48];
wire       [15:0] mem262 = ram_0.mem[49];
wire       [15:0] mem264 = ram_0.mem[50];
wire       [15:0] mem266 = ram_0.mem[51];
wire       [15:0] mem268 = ram_0.mem[52];
wire       [15:0] mem26A = ram_0.mem[53];
wire       [15:0] mem26C = ram_0.mem[54];
wire       [15:0] mem26E = ram_0.mem[55];
wire       [15:0] mem270 = ram_0.mem[56];
wire       [15:0] mem272 = ram_0.mem[57];
wire       [15:0] mem274 = ram_0.mem[58];
wire       [15:0] mem276 = ram_0.mem[59];
wire       [15:0] mem278 = ram_0.mem[60];
wire       [15:0] mem27A = ram_0.mem[61];
wire       [15:0] mem27C = ram_0.mem[62];
wire       [15:0] mem27E = ram_0.mem[63];
wire       [15:0] mem280 = ram_0.mem[64];


// Interrupt vectors
//======================

wire       [15:0] irq_vect_15 = rom_0.mem[(1<<(`ROM_MSB+1))-1];  // RESET Vector
wire       [15:0] irq_vect_14 = rom_0.mem[(1<<(`ROM_MSB+1))-2];  // NMI
wire       [15:0] irq_vect_13 = rom_0.mem[(1<<(`ROM_MSB+1))-3];  // IRQ 13
wire       [15:0] irq_vect_12 = rom_0.mem[(1<<(`ROM_MSB+1))-4];  // IRQ 12
wire       [15:0] irq_vect_11 = rom_0.mem[(1<<(`ROM_MSB+1))-5];  // IRQ 11
wire       [15:0] irq_vect_10 = rom_0.mem[(1<<(`ROM_MSB+1))-6];  // IRQ 10
wire       [15:0] irq_vect_09 = rom_0.mem[(1<<(`ROM_MSB+1))-7];  // IRQ  9
wire       [15:0] irq_vect_08 = rom_0.mem[(1<<(`ROM_MSB+1))-8];  // IRQ  8
wire       [15:0] irq_vect_07 = rom_0.mem[(1<<(`ROM_MSB+1))-9];  // IRQ  7
wire       [15:0] irq_vect_06 = rom_0.mem[(1<<(`ROM_MSB+1))-10]; // IRQ  6
wire       [15:0] irq_vect_05 = rom_0.mem[(1<<(`ROM_MSB+1))-11]; // IRQ  5
wire       [15:0] irq_vect_04 = rom_0.mem[(1<<(`ROM_MSB+1))-12]; // IRQ  4
wire       [15:0] irq_vect_03 = rom_0.mem[(1<<(`ROM_MSB+1))-13]; // IRQ  3
wire       [15:0] irq_vect_02 = rom_0.mem[(1<<(`ROM_MSB+1))-14]; // IRQ  2
wire       [15:0] irq_vect_01 = rom_0.mem[(1<<(`ROM_MSB+1))-15]; // IRQ  1
wire       [15:0] irq_vect_00 = rom_0.mem[(1<<(`ROM_MSB+1))-16]; // IRQ  0
