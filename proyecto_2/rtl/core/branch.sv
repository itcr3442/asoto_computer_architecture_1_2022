`include "core/uarch.sv"

module core_branch
(
	input  logic          clk,
	                      rst_n,

	input  insn_decode    dec,
	input  logic          start,
	                      wb_stall,
	input  word           a,
	                      b,

	output wb_line        wb,
	output hword          raw_mask,
	output hptr           target,
	output logic          stall,
	                      branch
);

	hword raw_in, raw_hold;
	logic hold_start, taken;
	insn_decode hold_dec;

	assign stall = (start && !dec.data.writeback) || branch;
	assign raw_mask = raw_in | raw_hold;

	core_raw_mask in_mask
	(
		.r(dec.data.rd),
		.enable(start && dec.data.writeback),
		.raw_mask(raw_in),
		.*
	);

	core_raw_mask hold_mask
	(
		.r(hold_dec.data.rd),
		.enable(hold_start && hold_dec.data.writeback),
		.raw_mask(raw_hold),
		.*
	);

	always_comb begin
		unique case(hold_dec.branch.cond)
			`COND_ALWAYS:
				taken = 1;

			`COND_LT:
				taken = a < b;

			`COND_EQ:
				taken = a == b;

			`COND_NE:
				taken = a != b;
		endcase
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			wb <= {$bits(wb_line){1'bx}};
			wb.ready <= 0;
			hold_start <= 0;

			// Vector de reset
			branch <= 1;
			target <= 0;
		end else begin
			if(!wb_stall) begin
				wb.rd <= dec.data.rd;
				wb.value <= {target, 1'b0};
				wb.ready <= hold_start && hold_dec.data.writeback;

				hold_start <= start;
			end

			branch <= stall && taken;

			if(dec.branch.indirect)
				target <= a[31:1];
			else
				target <= dec.pc + {{(31 - 12){dec.branch.offset[11]}}, dec.branch.offset};
		end

	// No necesita rst
	always @(posedge clk)
		if(!wb_stall)
			hold_dec <= dec;

endmodule