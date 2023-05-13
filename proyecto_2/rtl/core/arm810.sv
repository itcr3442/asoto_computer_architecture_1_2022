`include "core/uarch.sv"

module arm810
(
	input  logic      clk,
	                  rst_n,

	input  logic      irq,
	                  halt,

	input  logic      insn_ready,
					  data_ready,
	input  qword      insn_data_rd,
	input  word		  data_data_rd,

	output word       data_data_wr,
	output qptr       insn_addr,
	output ptr        data_addr,
	output logic      insn_start,
					  data_start,
					  data_write,
	output logic[3:0] data_data_be,

	output logic      halted
);

	word fetch_data_rd;
	logic fetch_ready;

	core_cache_l1i l1i
	(
		.*
	);


	ptr fetch_addr;
	hptr hi_insn_pc, lo_insn_pc;
	hword hi_insn, lo_insn;
	logic flush, fetch_start;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.addr(fetch_addr),
		.fetch(fetch_start),
		.fetched(fetch_ready),
		.fetch_data(fetch_data_rd),
		.prefetch_flush(halt),
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

	word rd_value_a, rd_value_b, rd_value_c, rd_value_d;
	wb_line wr_a, wr_b;
	reg_num rd_r_a, rd_r_b, rd_r_c, rd_r_d;

	core_regs regs
	(
		.*
	);

	hword mask_alu_a;
	wb_line wb_alu_a;

	core_alu #(.W(32)) ex_alu_a
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

	core_alu #(.W(32)) ex_alu_b
	(
		.a(rd_value_c),
		.b(rd_value_d),
		.wb(wb_alu_b),
		.dec(dec_alu_b),
		.start(start_alu_b),
		.raw_mask(mask_alu_b),
		.*
	);

	hptr target;
	hword mask_branch;
	logic branch, branch_stall;
	wb_line wb_branch;

	core_branch ex_branch
	(
		.a(single_rd_value_a),
		.b(single_rd_value_b),
		.wb(wb_branch),
		.dec(dec_single),
		.stall(branch_stall),
		.start(start_branch),
		.raw_mask(mask_branch),
		.wb_stall(wb_stall_branch),
		.*
	);

	logic ldst_wait;
	hword mask_ldst;
	wb_line wb_ldst;

	core_ldst ex_ldst
	(
		.a(single_rd_value_a),
		.b(single_rd_value_b),
		.wb(wb_ldst),
		.dec(dec_single),
		.start(start_ldst),
		.raw_mask(mask_ldst),
		.wb_stall(wb_stall_branch),
		.*
	);

	logic mul_ab_stall;
	hword mask_mul;
	wb_line wb_mul;

	core_mul ex_mul
	(
		.a(single_rd_value_a),
		.b(single_rd_value_b),
		.wb(wb_mul),
		.dec(dec_single),
		.start(start_mul),
		.raw_mask(mask_mul),
		.ab_stall(mul_ab_stall),
		.wb_stall(wb_stall_mul),
		.*
	);

	logic wb_stall_branch, wb_stall_ldst, wb_stall_mul;

	core_writeback wb
	(
		.*
	);

endmodule
