`ifndef CORE_ISA_SV
`define CORE_ISA_SV

`define FIELD_COND [31:28]
`define FIELD_OP   [27:0]

`define COND_EQ 4'b0000
`define COND_NE 4'b0001
`define COND_HS 4'b0010
`define COND_LO 4'b0011
`define COND_MI 4'b0100
`define COND_PL 4'b0101
`define COND_VS 4'b0110
`define COND_VC 4'b0111
`define COND_HI 4'b1000
`define COND_LS 4'b1001
`define COND_GE 4'b1010
`define COND_LT 4'b1011
`define COND_GT 4'b1100
`define COND_LE 4'b1101
`define COND_AL 4'b1110
`define COND_UD 4'b1111 // Indefnido antes de ARMv5

// Segundo operando de varios grupos de instrucciones

`define FIELD_SND_ROR8      [11:8]
`define FIELD_SND_IMM8      [7:0]
`define FIELD_SND_SHIFTIMM  [11:7]
`define FIELD_SND_RS        [11:8]
`define FIELD_SND_ZEROIFREG [7]
`define FIELD_SND_SHIFT     [6:5]
`define FIELD_SND_RM        [3:0]

`define SHIFT_LSL 2'b00
`define SHIFT_LSR 2'b01
`define SHIFT_ASR 2'b10
`define SHIFT_ROR 2'b11

// Instrucciones de salto

`define INSN_B  28'b101_0_????????????????????????
`define INSN_BL 28'b101_1_????????????????????????

`define GROUP_B 28'b101_?_????????????????????????

`define FIELD_B_L      [24]
`define FIELD_B_OFFSET [23:0]

// Instrucciones de procesamiento de datos (aritmético-lógicas y MOV)

`define INSN_AND 28'b00_?_0000_?_????_????_????????????
`define INSN_EOR 28'b00_?_0001_?_????_????_????????????
`define INSN_SUB 28'b00_?_0010_?_????_????_????????????
`define INSN_RSB 28'b00_?_0011_?_????_????_????????????
`define INSN_ADD 28'b00_?_0100_?_????_????_????????????
`define INSN_ADC 28'b00_?_0101_?_????_????_????????????
`define INSN_SBC 28'b00_?_0110_?_????_????_????????????
`define INSN_RSC 28'b00_?_0111_?_????_????_????????????
`define INSN_TST 28'b00_?_1000_1_????_0000_????????????
`define INSN_TEQ 28'b00_?_1001_1_????_0000_????????????
`define INSN_CMP 28'b00_?_1010_1_????_0000_????????????
`define INSN_CMN 28'b00_?_1011_1_????_0000_????????????
`define INSN_ORR 28'b00_?_1100_?_????_????_????????????
`define INSN_MOV 28'b00_?_1101_?_0000_????_????????????
`define INSN_BIC 28'b00_?_1110_?_????_????_????????????
`define INSN_MVN 28'b00_?_1111_?_0000_????_????????????

`define GROUP_ALU 28'b00_?_????_?_????_????_????????????

`define FIELD_DATA_IMM      [25]
`define FIELD_DATA_OPCODE   [24:21]
`define FIELD_DATA_S        [20]
`define FIELD_DATA_RN       [19:16]
`define FIELD_DATA_RD       [15:12]
`define FIELD_DATA_REGSHIFT [4]

// Instrucciones de multiplicación

`define INSN_MUL   28'b0000000_?_????_0000_????_1001_????
`define INSN_MLA   28'b0000001_?_????_????_????_1001_????
`define INSN_UMULL 28'b0000100_?_????_????_????_1001_????
`define INSN_UMLAL 28'b0000101_?_????_????_????_1001_????
`define INSN_SMULL 28'b0000110_?_????_????_????_1001_????
`define INSN_SMLAL 28'b0000111_?_????_????_????_1001_????

// No incluye INSN_MUL por el SBZ del medio
`define GROUP_BIGMUL 28'b0000???_?_????_????_????_1001_????

`define FIELD_MUL_LONG      [23]
`define FIELD_MUL_SIGNED    [22]
`define FIELD_MUL_ACC       [21]
`define FIELD_MUL_SET_FLAGS [20]
`define FIELD_MUL_RD        [19:16]
`define FIELD_MUL_RN        [15:12]
`define FIELD_MUL_RS        [11:8]
`define FIELD_MUL_RM        [3:0]

// Instrucciones de load/store

`define INSN_LDR   28'b01_?_?_?_0_?_1_????_????_????????????
`define INSN_LDRB  28'b01_?_?_?_1_?_1_????_????_????????????
`define INSN_LDRBT 28'b01_?_0_?_1_1_1_????_????_????????????
`define INSN_LDRT  28'b01_?_0_?_0_1_1_????_????_????????????
`define INSN_STR   28'b01_?_?_?_0_?_0_????_????_????????????
`define INSN_STRB  28'b01_?_?_?_1_?_0_????_????_????????????
`define INSN_STRBT 28'b01_?_0_?_1_1_0_????_????_????????????
`define INSN_STRT  28'b01_?_0_?_0_1_0_????_????_????????????

`define INSN_LDRH  28'b000_?_?_?_?_1_????_????_????_1011_????
`define INSN_LDRSB 28'b000_?_?_?_?_1_????_????_????_1101_????
`define INSN_LDRSH 28'b000_?_?_?_?_1_????_????_????_1111_????
`define INSN_STRH  28'b000_?_?_?_?_0_????_????_????_1011_????

`define INSN_LDM_CUR 28'b100_?_?_0_?_1_????_????????????????
`define INSN_LDM_USR 28'b100_?_?_1_0_1_????_0_???????????????
`define INSN_LDM_RFE 28'b100_?_?_1_?_1_????_1_???????????????
`define INSN_STM_CUR 28'b100_?_?_0_?_0_????_????????????????
`define INSN_STM_USR 28'b100_?_?_1_0_0_????_????????????????

`define GROUP_LDST_MISC 28'b000_?_?_?_?_?_????_????_????_1_?_?_1_????
`define GROUP_LDST_MULT 28'b100_?_?_?_?_?_????_????????????????

`define FIELD_LDST_LD          [20]
`define FIELD_LDST_SINGLE_BYTE [22]
`define FIELD_LDST_MISC_P      [24]
`define FIELD_LDST_MISC_U      [23]
`define FIELD_LDST_MISC_W      [21]
`define FIELD_LDST_MISC_RN     [19:16]
`define FIELD_LDST_MISC_RD     [15:12]
`define FIELD_LDST_MISC_IMM_HI [11:8]
`define FIELD_LDST_MISC_S      [6]
`define FIELD_LDST_MISC_H      [5]
`define FIELD_LDST_MISC_IMM_LO [3:0]
`define FIELD_LDST_MULT_P      [24]
`define FIELD_LDST_MULT_U      [23]
`define FIELD_LDST_MULT_S      [22]
`define FIELD_LDST_MULT_W      [21]
`define FIELD_LDST_MULT_RN     [19:16]
`define FIELD_LDST_MULT_LIST   [15:0]

// Instrucciones atómicas de intercambio registro-memoria

`define INSN_SWP  28'b00010000_????_????_0000_1001_????
`define INSN_SWPB 28'b00010100_????_????_0000_1001_????

`define GROUP_SWP 28'b00010?00_????_????_0000_1001_????

`define FIELD_SWP_BYTE [22]
`define FIELD_SWP_RN   [19:16]
`define FIELD_SWP_RD   [15:12]
`define FIELD_SWP_RM   [3:0]

// Instrucciones de coprocesador

`define INSN_MCR 28'b1110_???_0_????_????_????_???_1_????
`define INSN_MRC 28'b1110_???_1_????_????_????_???_1_????

`define GROUP_CP 28'b1110_???_?_????_????_????_???_1_????

`define FIELD_CP_OPCODE  [23:21]
`define FIELD_CP_LOAD    [20]
`define FIELD_CP_CRN     [19:16]
`define FIELD_CP_RD      [15:12]
`define FIELD_CP_NUM     [11:8]
`define FIELD_CP_OPCODE2 [7:5]
`define FIELD_CP_CRM     [3:0]

// Instrucciones de CPSR/SPSR

`define INSN_MRS     28'b0_0_0_1_0_?_0_0_1111_????_000000000000
`define INSN_MSR_IMM 28'b0_0_1_1_0_?_1_0_????_1111_????_????????
`define INSN_MSR_REG 28'b0_0_0_1_0_?_1_0_????_1111_0000_0000_????

`define GROUP_MSR 28'b0_0_?_1_0_?_1_0_????_1111_0000_0000_????

`define FIELD_MRS_R      [24]
`define FIELD_MRS_RD     [15:12]
`define FIELD_MSR_I      [25]
`define FIELD_MSR_R      [22]
`define FIELD_MSR_F      [19]
`define FIELD_MSR_S      [18]
`define FIELD_MSR_X      [17]
`define FIELD_MSR_C      [16]
`define FIELD_MSR_ROTATE [11:8]
`define FIELD_MSR_IMM    [7:0]
`define FIELD_MSR_RM     [3:0]

// System call

`define INSN_SWI 28'b1111_????????????????????????

`define FIELD_SWI_IMM [23:0]

`endif
