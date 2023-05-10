`include "core/uarch.sv"

module arm810
(
	input  logic      clk,
	                  rst_n,

	input  logic      irq,
	                  halt,

	output ptr        bus_addr,
	output logic      bus_start,
	                  bus_write,
	input  logic      bus_ready,
	input  word       bus_data_rd,
	output word       bus_data_wr,
	output logic[3:0] bus_data_be,

	output logic      halted
);

	ptr insn_addr;
	hptr branch_target, hi_insn_pc, lo_insn_pc;
	hword hi_insn, lo_insn;
	logic explicit_branch, flush, prefetch_flush, insn_start;

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
		.insn_pc(hi_insn_pc),
		.*
	);

	core_decode decode_lo
	(
		.dec(dec_lo),
		.insn(lo_insn),
		.insn_pc(lo_insn_pc),
		.*
	);

	word single_rd_value_a, single_rd_value_b;
	logic stall, start_alu_a, start_alu_b, start_mul, start_ldst, start_branch;
	insn_decode dec_alu_a, dec_alu_b, dec_single;

	core_dispatch dispatch
	(
		.dec_a(dec_lo),
		.dec_b(dec_hi),
		.*
	);

	core_control control
	(
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

	word rd_value_a, rd_value_b, rd_value_c, rd_value_d;
	wb_line wr_a, wr_b;
	reg_num rd_r_a, rd_r_b, rd_r_c, rd_r_d;

	core_regs regs
	(
		.*
	);

	hword mask_alu_a;
	wb_line wb_alu_a;

	core_alu #(.W(32)) alu_a
	(
		.a(rd_value_a),
		.b(rd_value_b),
		.wb(wb_alu_a),
		.dec(dec_alu_a),
		.start(start_alu_a),
		.raw_mask(mask_alu_a),
		.*
	);

	hword mask_alu_b;
	wb_line wb_alu_b;

	core_alu #(.W(32)) alu_b
	(
		.a(rd_value_c),
		.b(rd_value_d),
		.wb(wb_alu_b),
		.dec(dec_alu_b),
		.start(start_alu_b),
		.raw_mask(mask_alu_b),
		.*
	);

	logic branch_stall;

	logic mul_add, mul_long, mul_signed, mul_ready;
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
		.start(start_mul),
		.q_hi(mul_q_hi),
		.q_lo(mul_q_lo),
		.ready(mul_ready),
		.*
	);

	core_writeback wb
	(
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
