`include "core/uarch.sv"

module arm810
(
	input  logic      clk,
	                  rst_n,

	input  logic      irq,
	                  halt,
	                  step,

	output ptr        bus_addr,
	output logic      bus_start,
	                  bus_write,
	input  logic      bus_ready,
	input  word       bus_data_rd,
	output word       bus_data_wr,
	output logic[3:0] bus_data_be,

	output logic      halted,
	                  breakpoint
);

	ptr branch_target, fetch_insn_pc, fetch_head, insn_addr;
	word fetch_insn;
	logic explicit_branch, fetch_nop, stall,
		  flush, prefetch_flush, insn_start;

	//TODO
	assign prefetch_flush = halt;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.nop(fetch_nop),
		.addr(insn_addr),
		.insn(fetch_insn),
		.fetch(insn_start),
		.fetched(insn_ready),
		.insn_pc(fetch_insn_pc),
		.fetch_data(insn_data_rd),
		.porch_insn_pc(insn_pc),
		.*
	);

	insn_decode fetch_dec, fetch_dec_hi, fetch_dec_lo;
	assign fetch_dec = fetch_dec_hi; //TODO

	core_decode decode_hi
	(
		.dec(fetch_dec_hi),
		.insn(fetch_insn[31:16]),
		.*
	);

	core_decode decode_lo
	(
		.dec(fetch_dec_lo),
		.insn(fetch_insn[15:0]),
		.*
	);

	ptr insn_pc;
	word insn;
	insn_decode dec;

	assign dec = fetch_dec;
	assign insn = fetch_insn;
	assign insn_pc = fetch_insn_pc;

	core_control control
	(
		.alu(alu_ctrl),
		.branch(explicit_branch),
		.mem_addr(data_addr),
		.mem_start(data_start),
		.mem_write(data_write),
		.mem_ready(data_ready),
		.mem_data_rd(data_data_rd),
		.mem_data_wr(data_data_wr),
		.mem_data_be(data_data_be),
		.*
	);

	word rd_value_a, rd_value_b, wr_current, wr_value;
	logic wr_pc, writeback;
	reg_num rd, ra, rb;

	core_regs regs
	(
		.rd_r_a(ra),
		.rd_r_b(rb),
		.wr_r(rd),
		.wr_enable(writeback),
		.branch(wr_pc),
		.*
	);

	word alu_a, alu_b, q_alu;
	logic c_logic, alu_v_valid;
	alu_op alu_ctrl;

	core_alu #(.W(32)) alu
	(
		.op(alu_ctrl),
		.a(alu_a),
		.b(alu_b),
		.q(q_alu)
	);

	logic mul_start, mul_add, mul_long, mul_signed, mul_ready;
	word mul_a, mul_b, mul_c_hi, mul_c_lo, mul_q_hi, mul_q_lo;

	core_mul mult
	(
		.a(mul_a),
		.b(mul_b),
		.c_hi(mul_c_hi),
		.c_lo(mul_c_lo),
		.long_mul(mul_long),
		.add(mul_add),
		.sig(mul_signed),
		.start(mul_start),
		.q_hi(mul_q_hi),
		.q_lo(mul_q_lo),
		.ready(mul_ready),
		.*
	);

	ptr data_addr;
	word data_data_rd, data_data_wr, insn_data_rd;
	logic[3:0] data_data_be;

	logic data_start, data_write, data_ready, insn_ready;

	core_arbiter arbiter
	(
		.*
	);

endmodule
