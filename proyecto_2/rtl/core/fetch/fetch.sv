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
	input  ptr   target /*verilator public*/ /*verilator forceable*/,
	             porch_insn_pc,
	input  word  fetch_data,

	output logic fetch,
	             flush,
	             nop,
	output word  insn,
	output ptr   insn_pc,
	             addr,
	             fetch_head
);

	ptr hold_addr;
	logic prefetch_ready, fetched_valid, discard, pending, next_pending;

	assign fetch = prefetch_ready && !discard;
	assign flush = branch || prefetch_flush;
	assign next_pending = fetch || (pending && !fetched);
	assign fetched_valid = fetched && !discard;

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
			fetch_head = porch_insn_pc;
		else
			fetch_head = {30{1'bx}};

		if(flush)
			addr = fetch_head;
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
