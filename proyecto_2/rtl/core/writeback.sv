module core_writeback
(
	input  logic   clk,
	               rst_n,

	input  wb_line wb_alu_a,
	               wb_alu_b,
	               wb_branch,
	               wb_ldst,
	//TODO: otros wb_line

	output wb_line wr_a,
	               wr_b,
	output logic   wb_stall_branch,
	               wb_stall_ldst
);

	logic select_branch, select_ldst, prev_select_branch, prev_select_ldst;

	assign wb_stall_branch = !select_branch && wb_branch.ready;
	assign wb_stall_ldst = !select_ldst && wb_ldst.ready;

	always_comb begin
		wr_a = wb_branch;
		select_branch = 1;
		select_ldst = 0;

		if(!wb_branch.ready) begin
			wr_a = wb_ldst;
			select_branch = 0;
			select_ldst = 1;
		end

		if(wb_alu_a.ready) begin
			wr_a = wb_alu_a;
			select_branch = 0;
			select_ldst = 0;
		end

		prev_select_branch = select_branch;
		prev_select_ldst = select_ldst;

		wr_b = wb_branch;
		select_branch = 1;

		if(prev_select_branch) begin
			wr_b = wb_ldst;

			select_ldst = 1;
			select_branch = prev_select_branch;
		end

		if(wb_alu_b.ready) begin
			wr_b = wb_alu_b;

			select_ldst = prev_select_ldst;
			select_branch = prev_select_branch;
		end
	end

endmodule
