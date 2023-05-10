`include "core/uarch.sv"

module core_prefetch
#(parameter ORDER=2)
(
	input  logic clk,
	             rst_n,
	             stall,
	             flush,
	             fetched,
	input  word  fetch_data,
	input  hptr  head,

	output hword hi_insn,
	             lo_insn,
	output hptr  hi_insn_pc,
	             lo_insn_pc,
	output ptr   pair_pc,
	output logic fetch
);

	localparam SIZE = (1 << ORDER) - 1;

	ptr next_pc, head_ptr;
	logic split_half, head_half;
	logic[31:0] prefetch[SIZE];
	logic[ORDER - 1:0] valid;

	assign fetch = !stall || ~&valid;
	assign next_pc = !stall && |valid ? pair_pc + 1 : pair_pc;

	assign {head_ptr, head_half} = head;

	always_comb begin
		hi_insn_pc = {pair_pc + 30'd1, 1'b0};
		lo_insn_pc = {pair_pc, 1'b1};
		{hi_insn, lo_insn} = prefetch[0];

		if(flush)
			{hi_insn, lo_insn} = `DNOP;
		else if(split_half) begin
			lo_insn = hi_insn;
			hi_insn = `NOP;
			lo_insn_pc = hi_insn_pc;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			valid <= 0;
			pair_pc <= 0;
			split_half <= 0;

			prefetch[SIZE - 1] <= `DNOP;
		end else begin
			pair_pc <= flush ? head_ptr : next_pc;

			if(flush)
				split_half <= head_half;
			else if(!stall && |valid)
				split_half <= 0;

			if(flush)
				prefetch[SIZE - 1] <= `DNOP;
			else if(fetched && valid == SIZE - 1 + {{(ORDER - 1){1'b0}}, !stall})
				prefetch[SIZE - 1] <= fetch_data;
			else if(!stall)
				prefetch[SIZE - 1] <= `DNOP;

			if(flush)
				valid <= 0;
			else if(fetched && ((stall && ~&valid) || ~|valid))
				valid <= valid + 1;
			else if(!stall && !fetched && |valid)
				valid <= valid - 1;
		end

	genvar i;
	generate
		for(i = 0; i < SIZE - 1; ++i) begin: prefetch_slots
			always_ff @(posedge clk or negedge rst_n)
				if(!rst_n)
					prefetch[i] <= `DNOP;
				else if(flush)
					prefetch[i] <= `DNOP;
				else if(fetched && (!(|i || |valid) || (valid == i + {{(ORDER - 1){1'b0}}, !stall})))
					prefetch[i] <= fetch_data;
				else if(!stall)
					prefetch[i] <= prefetch[i + 1];
		end
	endgenerate

endmodule
