`include "core/uarch.sv"

module core_dispatch
(
	input  logic        clk,
	                    rst_n,

	input  insn_decode  dec_a,
	                    dec_b,
	input  word         rd_value_a,
	                    rd_value_b,
	                    rd_value_c,
	                    rd_value_d,
	input  hword        mask_alu_a,
	                    mask_alu_b,
	                    mask_branch,
	input  logic        flush,
	                    branch_stall,
	                    ldst_wait,
	                    wb_stall_branch,

	output logic        stall,
	                    start_alu_a,
	                    start_alu_b,
	                    start_mul,
	                    start_branch,
	                    start_ldst,
	output reg_num      rd_r_a,
	                    rd_r_b,
	                    rd_r_c,
	                    rd_r_d,
	output insn_decode  dec_alu_a,
	                    dec_alu_b,
	                    dec_single,
	output word         single_rd_value_a,
	                    single_rd_value_b
);

`ifdef VERILATOR
	word pc /*verilator public*/;
	assign pc = {dec_a.pc > dec_b.pc ? dec_a.pc : dec_b.pc, 1'b0};
`endif

	//TODO: dispatch_a, dispatch_b, b_wants_a

	logic holding, dispatch_a, dispatch_b, last_dispatch_b;
	insn_decode hold, cur_a, cur_b;

	assign stall = !dispatch_a || (holding && !dispatch_b);

	assign rd_r_a = cur_a.data.ra;
	assign rd_r_b = cur_a.data.rb;
	assign rd_r_c = cur_b.data.ra;
	assign rd_r_d = cur_b.data.rb;

	core_dispatch_hazards hazards
	(
		.*
	);

	hword mask_a_ra, mask_a_rb;

	core_raw_mask raw_a_ra
	(
		.r(cur_a.data.ra),
		.enable(cur_a.data.uses_ra),
		.raw_mask(mask_a_ra)
	);

	core_raw_mask raw_a_rb
	(
		.r(cur_a.data.rb),
		.enable(cur_a.data.uses_rb),
		.raw_mask(mask_a_rb)
	);

	hword mask_b_ra, mask_b_rb;

	core_raw_mask raw_b_ra
	(
		.r(cur_b.data.ra),
		.enable(cur_b.data.uses_ra),
		.raw_mask(mask_b_ra)
	);

	core_raw_mask raw_b_rb
	(
		.r(cur_b.data.rb),
		.enable(cur_b.data.uses_rb),
		.raw_mask(mask_b_rb)
	);

	always_comb begin
		if(holding) begin
			cur_a = hold;
			cur_b = dec_a;
		end else begin
			cur_a = dec_a;
			cur_b = dec_b;
		end

		// Esto opera en el siguiente ciclo respecto al dispatch que lo generó
		if(last_dispatch_b) begin
			single_rd_value_a = rd_value_c;
			single_rd_value_b = rd_value_d;
		end else begin
			single_rd_value_a = rd_value_a;
			single_rd_value_b = rd_value_b;
		end
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			holding <= 0;
			start_mul <= 0;
			start_ldst <= 0;
			start_branch <= 0;
			start_alu_a <= 0;
			start_alu_b <= 0;
		end else begin
			if(dispatch_a && !dispatch_b)
				holding <= !holding;

			if(flush)
				holding <= 0;

			start_alu_a <= dispatch_a && cur_a.ctrl.alu;
			start_alu_b <= dispatch_b && cur_b.ctrl.alu;

			start_mul <= (dispatch_a && cur_a.ctrl.execute && cur_a.ctrl.mul)
			          || (dispatch_b && cur_b.ctrl.execute && cur_b.ctrl.mul);

			start_ldst <= (dispatch_a && cur_a.ctrl.execute && cur_a.ctrl.ldst)
			           || (dispatch_b && cur_b.ctrl.execute && cur_b.ctrl.ldst);

			start_branch <= (dispatch_a && cur_a.ctrl.execute && cur_a.ctrl.branch)
			             || (dispatch_b && cur_b.ctrl.execute && cur_b.ctrl.branch);
		end

	// No necesitan reset
	always @(posedge clk) begin
		if(dispatch_a)
			hold <= dec_b;

		dec_alu_a <= cur_a;
		dec_alu_b <= cur_b;
		dec_single <= (dispatch_b && cur_b.ctrl.execute) ? cur_b : cur_a;
		last_dispatch_b <= dispatch_b;
	end

endmodule
