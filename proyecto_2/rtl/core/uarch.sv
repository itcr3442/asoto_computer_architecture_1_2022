`ifndef CORE_UARCH_SV
`define CORE_UARCH_SV

// Decodifica como andeq r0, r0, r0
`define NOP 32'd0

typedef logic[2:0]  cp_opcode;
typedef logic[15:0] reg_list;
typedef logic[15:0] hword;
typedef logic[31:0] word;
typedef logic[63:0] dword;
typedef logic[29:0] ptr;

`define R0 4'b0000

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
	logic n,
	      z,
	      c,
	      v;
} psr_flags;

typedef struct packed
{
	logic i;
} psr_intmask;

typedef struct packed
{
	logic f,
	      s,
	      x,
	      c;
} msr_mask;

typedef logic[4:0] psr_mode;

`define MODE_USR 5'b10000
`define MODE_FIQ 5'b10001
`define MODE_IRQ 5'b10010
`define MODE_SVC 5'b10011
`define MODE_ABT 5'b10111
`define MODE_UND 5'b11011
`define MODE_SYS 5'b11111

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
	logic load;
} ldst_decode;

typedef struct packed
{
	logic[3:0] op;
} sys_decode;

//TODO: Esto debería ser una union
typedef struct packed
{
	ctrl_decode   ctrl;
	data_decode   data;
	alu_decode    alu;
	branch_decode branch;
	ext_decode    ext;
	ldst_decode   ldst;
	sys_decode    sys;
} insn_decode;

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

typedef struct packed
{
	logic shr,
	      ror,
	      put_carry,
	      sign_extend;
} shifter_control;

`endif
