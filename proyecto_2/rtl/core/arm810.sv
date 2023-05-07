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

	ptr insn_addr;
	hptr branch_target, hi_insn_pc, lo_insn_pc;
	hword hi_insn, lo_insn;
	logic explicit_branch, stall, stall_half, flush, prefetch_flush, insn_start;

	//TODO
	assign prefetch_flush = halt;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.addr(insn_addr),
		.fetch(insn_start),
		.branch(explicit_branch),
		.fetched(insn_ready),
		.fetch_data(insn_data_rd),
		.target(branch_target),
		.*
	);

	insn_decode dec, dec_hi, dec_lo;
	assign dec = dec_hi; //TODO

	core_decode decode_hi
	(
		.dec(dec_hi),
		.insn(hi_insn),
		.*
	);

	core_decode decode_lo
	(
		.dec(dec_lo),
		.insn(lo_insn),
		.*
	);

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

	word rd_value_a, rd_value_b, rd_value_c, rd_value_d,
	     wr_value_a, wr_value_b, wr_value_c;

	logic wr_enable_a, wr_enable_b, wr_enable_c;
	reg_num rd_r_a, rd_r_b, rd_r_c, rd_r_d,
	        wr_r_a, wr_r_b, wr_r_c;

	core_regs regs
	(
		.*
	);

	word alu_a, alu_b, q_alu;
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
