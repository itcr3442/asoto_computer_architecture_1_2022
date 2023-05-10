`include "core/uarch.sv"

module core_regs
(
	input  logic    clk,
	                rst_n,

	input  reg_num  rd_r_a,
	                rd_r_b,
	                rd_r_c,
	                rd_r_d,
	input  wb_line  wr_a,
	                wr_b,

	output word     rd_value_a,
	                rd_value_b,
	                rd_value_c,
	                rd_value_d
);

	word file[`NUM_GPREGS] /*verilator public*/;
	word rd_hold_a, rd_hold_b, rd_hold_c, rd_hold_d, wr_hold_a, wr_hold_b;
	reg_num wr_hold_r_a, wr_hold_r_b;

	core_regs_forward fwd_a
	(
		.rd(rd_value_a),
		.rd_r(rd_r_a),
		.rd_hold(rd_hold_a),
		.*
	);

	core_regs_forward fwd_b
	(
		.rd(rd_value_b),
		.rd_r(rd_r_b),
		.rd_hold(rd_hold_b),
		.*
	);

	core_regs_forward fwd_c
	(
		.rd(rd_value_c),
		.rd_r(rd_r_c),
		.rd_hold(rd_hold_c),
		.*
	);

	core_regs_forward fwd_d
	(
		.rd(rd_value_d),
		.rd_r(rd_r_d),
		.rd_hold(rd_hold_d),
		.*
	);

	// No necesita rst
	always_ff @(posedge clk) begin
		if(wr_a.ready)
			file[wr_a.rd] <= wr_a.value;

		if(wr_b.ready)
			file[wr_b.rd] <= wr_b.value;

		rd_hold_a <= file[rd_r_a];
		rd_hold_b <= file[rd_r_b];
		rd_hold_c <= file[rd_r_c];
		rd_hold_d <= file[rd_r_d];

		wr_hold_a <= wr_a.value;
		wr_hold_b <= wr_a.value;
		wr_hold_r_a <= wr_a.ready ? wr_a.rd : `R0;
		wr_hold_r_b <= wr_b.ready ? wr_b.rd : `R0;
	end

endmodule
