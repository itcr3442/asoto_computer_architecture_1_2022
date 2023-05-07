`include "core/uarch.sv"

module core_regs
(
	input  logic    clk,
	                rst_n,

	input  reg_num  rd_r_a,
	                rd_r_b,
	                rd_r_c,
	                rd_r_d,
	                wr_r_a,
	                wr_r_b,
	                wr_r_c,
	input  logic    wr_enable_a,
	                wr_enable_b,
	                wr_enable_c,
	input  word     wr_value_a,
	                wr_value_b,
	                wr_value_c,

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
			if(wr_enable_a)
				file[wr_r_a] <= wr_value_a;

			if(wr_enable_b)
				file[wr_r_b] <= wr_value_b;

			if(wr_enable_c)
				file[wr_r_c] <= wr_value_c;

			rd_value_a <= rd_r_a == `R0 ? 0 : file[rd_r_a];
			rd_value_b <= rd_r_b == `R0 ? 0 : file[rd_r_b];
			rd_value_c <= rd_r_c == `R0 ? 0 : file[rd_r_c];
			rd_value_d <= rd_r_d == `R0 ? 0 : file[rd_r_d];
		end

endmodule
