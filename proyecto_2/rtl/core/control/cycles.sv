`include "core/uarch.sv"

module core_control_cycles
(
	input  logic      clk,
	                  mul,
	                  ldst,
	                  bubble,
	                  exception,
	                  mem_ready,
	                  mul_ready,
	                  pop_valid,
	                  trivial_shift,
	                  ldst_writeback,
	                  data_snd_shift_by_reg,

	output ctrl_cycle cycle,
	                  next_cycle
);

	always_comb begin
		next_cycle = ISSUE;

		unique case(cycle)
			ISSUE:
				if(exception)
					next_cycle = EXCEPTION;
				else if(data_snd_shift_by_reg)
					next_cycle = RD_INDIRECT_SHIFT;
				else if(!trivial_shift)
					next_cycle = WITH_SHIFT;

			RD_INDIRECT_SHIFT:
				if(!trivial_shift)
					next_cycle = WITH_SHIFT;

			TRANSFER:
				if(!mem_ready || pop_valid)
					next_cycle = TRANSFER;
				else if(ldst_writeback)
					next_cycle = BASE_WRITEBACK;

			MUL:
				if(!mul_ready)
					next_cycle = MUL;

			default: ;
		endcase

		if(bubble)
			next_cycle = ISSUE;
		else if(next_cycle == ISSUE) begin
			if(ldst)
				next_cycle = TRANSFER;
			else if(mul)
				next_cycle = MUL;
		end
	end

	always_ff @(posedge clk)
		cycle <= next_cycle;

	initial
		cycle = ISSUE;

endmodule
