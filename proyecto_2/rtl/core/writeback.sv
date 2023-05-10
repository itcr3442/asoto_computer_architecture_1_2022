module core_writeback
(
	input  logic   clk,
	               rst_n,

	input  wb_line wb_alu_a,
	               wb_alu_b,
	//TODO: otros wb_line

	output wb_line wr_a,
	               wr_b
);

	always_comb begin
		//TODO
		wr_a = wb_alu_a;
		wr_b = wb_alu_b;
	end

endmodule
