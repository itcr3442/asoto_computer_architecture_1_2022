`ifndef CORE_UARCH_SV
`define CORE_UARCH_SV

// Decodifica como 'bal 0'
`define NOP  16'd0
`define DNOP {`NOP, `NOP}

typedef logic[2:0]  cp_opcode;
typedef logic[15:0] reg_list;
typedef logic[15:0] hword;
typedef logic[31:0] word;
typedef logic[63:0] dword;
typedef logic[29:0] ptr;
typedef logic[30:0] hptr;

`define R0 4'b0000

// `COND_ALWAYS no existe en ISA, es una conveniencia de microarquitectura
`define COND_ALWAYS 2'b00
`define COND_LT     2'b01
`define COND_EQ     2'b10
`define COND_NE     2'b11

`define NUM_GPREGS 16
typedef logic[$clog2(`NUM_GPREGS) - 1:0] reg_num;

typedef logic[2:0] alu_op;

// Coincide con campo respectivo en codificación
`define ALU_AND 3'b001
`define ALU_ORR 3'b010
`define ALU_XOR 3'b011
`define ALU_SHL 3'b100
`define ALU_SHR 3'b101
`define ALU_ADD 3'b110
`define ALU_SUB 3'b111

`define ALU_PREFIX_SHLSHR 2'b10
`define ALU_PREFIX_ADDSUB 2'b11

typedef struct packed
{
	logic execute,
	      alu,
	      branch,
	      ext,
	      ldst,
	      mul,
	      sys;
} ctrl_decode;

typedef struct packed
{
	reg_num    ra,
	           rb,
	           rd;

	logic[4:0] imm;

	logic      uses_ra,
	           uses_rb,
	           uses_imm,
	           writeback;
} data_decode;

typedef struct packed
{
	alu_op op;
} alu_decode;

typedef struct packed
{
	logic[11:0] offset;
	logic[1:0]  cond;
	logic       indirect;
} branch_decode;

typedef struct packed
{
	logic[4:0] op;
} ext_decode;

typedef struct packed
{
	logic[3:0] op;
} sys_decode;

//TODO: Esto debería ser una union
typedef struct packed
{
	hptr          pc;
	ctrl_decode   ctrl;
	data_decode   data;
	alu_decode    alu;
	branch_decode branch;
	ext_decode    ext;
	sys_decode    sys;
} insn_decode;

typedef struct packed
{
	word    value;
	logic   ready;
	reg_num rd;
} wb_line;

// Ver comentario en cycles.sv, este diseño es más óptimo
typedef struct packed
{
	logic issue,
	      rd_indirect_shift,
	      with_shift,
	      transfer,
	      base_writeback,
	      escalate,
	      exception,
	      mul,
	      mul_acc_ld,
	      mul_hi_wb,
	      psr,
	      coproc;
} ctrl_cycle;

`endif
