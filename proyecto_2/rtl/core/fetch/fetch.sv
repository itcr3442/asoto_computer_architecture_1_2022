`include "core/uarch.sv"

module core_fetch
#(parameter PREFETCH_ORDER=2)
(
	input  logic clk,
	             rst_n,
	             stall,
	             fetched,
	             branch /*verilator public*/ /*verilator forceable*/,
	             prefetch_flush,
	input  hptr  target /*verilator public*/ /*verilator forceable*/,
	input  word  fetch_data,

	output logic fetch,
	             flush,
	output hword hi_insn,
	             lo_insn,
	output hptr  hi_insn_pc,
	             lo_insn_pc,
	output ptr   addr
);

	ptr hold_addr, pair_pc, fetch_ptr;
	hptr fetch_head;
	logic fetch_half, prefetch_ready, fetched_valid, discard, pending, next_pending;

	assign fetch = prefetch_ready && !discard;
	assign flush = branch || prefetch_flush;
	assign next_pending = fetch || (pending && !fetched);
	assign fetched_valid = fetched && !discard;
	assign {fetch_ptr, fetch_half} = fetch_head;

	core_prefetch #(.ORDER(PREFETCH_ORDER)) prefetch
	(
		.head(fetch_head),
		.fetched(fetched_valid),
		.fetch(prefetch_ready),
		.*
	);

	always_comb begin
		if(branch)
			fetch_head = target;
		else if(prefetch_flush)
			fetch_head = {pair_pc, 1'b0};
		else
			fetch_head = {31{1'bx}};

		if(flush)
			addr = fetch_ptr;
		else if(fetch && fetched_valid)
			addr = hold_addr + 1;
		else
			addr = hold_addr;
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pending <= 0;
			discard <= 0;
			hold_addr <= 0;
		end else begin
			pending <= next_pending;
			discard <= next_pending && (discard || flush);
			hold_addr <= addr;
		end

endmodule
