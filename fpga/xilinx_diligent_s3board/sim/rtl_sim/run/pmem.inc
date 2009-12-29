




































`include "openMSP430_undefines.v"












`define PMEM_AWIDTH   11











`define DMEM_AWIDTH    9






`define DBG_EN





`define DBG_UART








`define  DBG_HWBRK_0
















`define PMEM_SIZE  (2 << `PMEM_AWIDTH)
`define DMEM_SIZE  (2 << `DMEM_AWIDTH)


`define DMEM_BASE  16'h0200


`define PMEM_MSB   `PMEM_AWIDTH-1
`define DMEM_MSB   `DMEM_AWIDTH-1



`define INST_SO  0
`define INST_JMP 1
`define INST_TO  2


`define RRC    0
`define SWPB   1
`define RRA    2
`define SXT    3
`define PUSH   4
`define CALL   5
`define RETI   6
`define IRQ    7


`define JNE    0
`define JEQ    1
`define JNC    2
`define JC     3
`define JN     4
`define JGE    5
`define JL     6
`define JMP    7


`define MOV    0
`define ADD    1
`define ADDC   2
`define SUBC   3
`define SUB    4
`define CMP    5
`define DADD   6
`define BIT    7
`define BIC    8
`define BIS    9
`define XOR   10
`define AND   11


`define DIR      0
`define IDX      1
`define INDIR    2
`define INDIR_I  3
`define SYMB     4
`define IMM      5
`define ABS      6
`define CONST    7


`define E_IRQ_0    4'h0
`define E_IRQ_1    4'h1
`define E_IRQ_2    4'h2
`define E_IRQ_3    4'h3
`define E_IRQ_4    4'h4
`define E_SRC_AD   4'h5
`define E_SRC_RD   4'h6
`define E_SRC_WR   4'h7
`define E_DST_AD   4'h8
`define E_DST_RD   4'h9
`define E_DST_WR   4'hA
`define E_EXEC     4'hB
`define E_JUMP     4'hC
`define E_IDLE     4'hD


`define ALU_SRC_INV   0
`define ALU_INC       1
`define ALU_INC_C     2
`define ALU_ADD       3
`define ALU_AND       4
`define ALU_OR        5
`define ALU_XOR       6
`define ALU_DADD      7
`define ALU_STAT_7    8
`define ALU_STAT_F    9
`define ALU_SHIFT    10
`define EXEC_NO_WR   11


`define DBG_UART_WR   18
`define DBG_UART_BW   17
`define DBG_UART_ADDR 16:11


`define HALT        0
`define RUN         1
`define ISTEP       2
`define SW_BRK_EN   3
`define FRZ_BRK_EN  4
`define RST_BRK_EN  5
`define CPU_RST     6


`define HALT_RUN    0
`define PUC_PND     1
`define SWBRK_PND   3
`define HWBRK0_PND  4
`define HWBRK1_PND  5


`define BRK_MODE_RD 0
`define BRK_MODE_WR 1
`define BRK_MODE    1:0
`define BRK_EN      2
`define BRK_I_EN    3
`define BRK_RANGE   4


`define DIVAx       5:4


`define SELS        3
`define DIVSx       2:1


`define TASSELx     9:8
`define TAIDx       7:6
`define TAMCx       5:4
`define TACLR       2
`define TAIE        1
`define TAIFG       0


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






`define DBG_SWBRK_OP 16'h4343


`define DBG_ID  24'h4D5350





`define DBG_UART_AUTO_SYNC















`define DBG_UART_BAUD 2000000
`define DBG_DCO_FREQ  20000000
`define DBG_UART_CNT ((`DBG_DCO_FREQ/`DBG_UART_BAUD)-1)


`ifdef DBG_EN
 `ifdef DBG_UART
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG AND UART DEBUG INTERFACE ARE BOTH ENABLED
   `endif
 `else
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG INTERFACE NOT SUPPORTED
   `else
CONFIGURATION ERROR: JTAG OR UART DEBUG INTERFACE SHOULD BE ENABLED
   `endif
 `endif
`endif
