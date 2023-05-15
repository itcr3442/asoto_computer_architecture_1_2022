`ifndef CORE_DECODE_ISA_SV
`define CORE_DECODE_ISA_SV

// Salto incondicional relativo

`define GROUP_BAL 16'b????_????_0000_????

`define FIELD_BAL_J_HI [15:8]
`define FIELD_BAL_J_LO [3:0]

// Espacios de extensión

`define GROUP_EXT1   16'b0000_????_1000_0000
`define GROUP_EXT2   16'b????_0000_1000_0000
`define FIELD_EXT1_I [11:8]
`define FIELD_EXT2_I [15:12]

// Multiplicación

`define GROUP_MUL   16'b????_????_1000_0000
`define FIELD_MUL_A [15:12]
`define FIELD_MUL_Z [11:8]

// Salto incondicional indirecto

`define GROUP_BIN   16'b0000_????_0100_0000
`define FIELD_BIN_A [11:8]

// Espacio de control

`define GROUP_SYS   16'b0000_????_1100_0000
`define FIELD_SYS_I [11:8]

// Carga de inmediato pequeño

`define GROUP_IMM        16'b????_????_?100_0000
`define FIELD_IMM_D      [15:12]
`define FIELD_IMM_I      [11:7]
`define FIELD_IMM_I_SIGN [11]

// Salto condicional relativo

`define GROUP_BCC       16'b????_????_????_0000
`define FIELD_BCC_P     [15:13]
`define FIELD_BCC_J     [12:6]
`define FIELD_BCC_J_SGN [12]
`define FIELD_BCC_C     [5:4]

// Direccionado relativo a PC

`define GROUP_ADR       16'b????_????_??11_????
`define FIELD_ADR_J     [15:6]
`define FIELD_ADR_J_SGN [15]
`define FIELD_ADR_D     [3:0]

// ALU reg-reg

`define GROUP_ALU   16'b????_????_???0_????
`define FIELD_ALU_A [15:12]
`define FIELD_ALU_B [11:8]
`define FIELD_ALU_O [7:5]
`define FIELD_ALU_D [3:0]

// Load/store

`define GROUP_MEM   16'b0000_0???_??01_????
`define FIELD_MEM_A [10:7]
`define FIELD_MEM_L [6]
`define FIELD_MEM_D [3:0]

// ALU reg-imm con inmediato de 5 bits, add/sub

`define GROUP_INC   16'b????_?000_0?01_????
`define FIELD_INC_I [15:11]
`define FIELD_INC_S [6]
`define FIELD_INC_Z [3:0]

// ALU reg-imm con inmediato de 5 bits, shl/shr

`define GROUP_SHI   16'b????_????_??01_????
`define FIELD_SHI_I [15:11]
`define FIELD_SHI_A [10:7]
`define FIELD_SHI_S [6]
`define FIELD_SHI_D [3:0]

`endif
