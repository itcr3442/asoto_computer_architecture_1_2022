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

	// TODO: rst
	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
		end else begin
			if(wr_a.ready)
				file[wr_a.rd] <= wr_a.value;

			if(wr_b.ready)
				file[wr_b.rd] <= wr_b.value;

			rd_value_a <= rd_r_a == `R0 ? 0 : file[rd_r_a];
			rd_value_b <= rd_r_b == `R0 ? 0 : file[rd_r_b];
			rd_value_c <= rd_r_c == `R0 ? 0 : file[rd_r_c];
			rd_value_d <= rd_r_d == `R0 ? 0 : file[rd_r_d];
		end

endmodule
