`include "core/uarch.sv"

module core_dispatch_hazards
(
	input  insn_decode cur_a,
	                   cur_b,
	input  hword       mask_a_ra,
	                   mask_a_rb,
	                   mask_b_ra,
	                   mask_b_rb,
	                   mask_alu_a,
	                   mask_alu_b,
	                   mask_branch,
	input  logic       branch_stall,
	                   ldst_wait,
	                   wb_stall_branch,

	output logic       dispatch_a,
	                   dispatch_b
);

	hword mask_a, mask_b, mask_wr;
	logic a_permits_b;

	assign mask_a = mask_a_ra | mask_a_rb;
	assign mask_b = mask_b_ra | mask_b_rb;
	assign mask_wr = mask_alu_a | mask_alu_b | mask_branch; //TODO: más EUs

	always_comb begin
		a_permits_b = 1;

		if(cur_a.data.writeback)
			a_permits_b = (!cur_b.data.uses_ra || cur_b.data.ra != cur_a.data.rd)
			           && (!cur_b.data.uses_rb || cur_b.data.rb != cur_a.data.rd);

		// Riesgo estructural, solo tenemos una EU cada una de estas
		if(cur_a.ctrl.branch
		|| (cur_a.ctrl.mul && cur_b.ctrl.mul)
		|| (cur_a.ctrl.ldst && cur_b.ctrl.ldst))
			a_permits_b = 0;

		if(!cur_a.ctrl.execute || !cur_b.ctrl.execute)
			a_permits_b = 1;

		dispatch_a = !branch_stall && !|(mask_a & mask_wr);

		if(dispatch_a) begin
			if(cur_a.ctrl.branch)
				dispatch_a = !wb_stall_branch;

			if(cur_a.ctrl.ldst)
				dispatch_a = !ldst_wait;
		end

		if(!cur_a.ctrl.execute)
			dispatch_a = 1;

		dispatch_b = dispatch_a && a_permits_b && !|(mask_b & mask_wr);
		if(dispatch_b) begin
			if(cur_b.ctrl.branch)
				dispatch_b = !wb_stall_branch;

			if(cur_b.ctrl.ldst)
				dispatch_b = !ldst_wait;
		end

		if(dispatch_a && !cur_b.ctrl.execute)
			dispatch_b = 1;
	end

endmodule
