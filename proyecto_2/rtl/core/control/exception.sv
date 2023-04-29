`include "core/uarch.sv"

module core_control_exception
(
	input  logic       clk,
	                   rst_n,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  insn_decode dec,
	input  logic       intmask,
	input  logic       issue,
	                   irq,
	                   high_vectors,
	                   undefined,

	output logic       escalating,
	                   exception,
	output word        exception_vector
);

	logic pending_irq;
	logic[2:0] vector_offset;

	//TODO: fiq

	assign exception = undefined || pending_irq;
	assign escalating = cycle.escalate;
	assign exception_vector = {{16{high_vectors}}, 11'b0, vector_offset, 2'b00};

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pending_irq <= 0;
			vector_offset <= 0;
		end else begin
			if(next_cycle.issue)
				pending_irq <= issue && irq && !intmask;

			if(pending_irq)
				vector_offset <= 3'b110;
			else if(undefined)
				vector_offset <= 3'b001;
		end

endmodule
