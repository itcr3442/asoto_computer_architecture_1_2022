module core_writeback
(
	input  logic   clk,
	               rst_n,

	input  wb_line wb_alu_a,
	               wb_alu_b,
	               wb_branch,
	//TODO: otros wb_line

	output wb_line wr_a,
	               wr_b,
	output logic   wb_stall_branch
);

	logic select_branch;

	assign wb_stall_branch = !select_branch && wb_branch.ready;

	always_comb begin
		wr_a = wb_branch;
		select_branch = 1;

		if(wb_alu_a.ready) begin
			wr_a = wb_alu_a;
			select_branch = 0;
		end

		wr_b = wb_branch;
		select_branch = 1;

		if(!select_branch || wb_alu_b.ready) begin
			wr_b = wb_alu_b;
			select_branch = 0;
		end
	end

endmodule
