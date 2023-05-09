`include "core/uarch.sv"

module core_alu
#(parameter W=16)
(
	input  logic          clk,
	                      rst_n,

	input  insn_decode    dec,
	input  logic          start,
	input  logic[W - 1:0] a,
	                      b
);

	logic[W - 1:0] q; //TODO

	always_comb
		unique case(dec.alu.op)
			`ALU_AND:
				q = a & b;

			`ALU_ORR:
				q = a | b;

			`ALU_XOR:
				q = a ^ b;

			`ALU_SHL:
				q = a << b;

			`ALU_SHR:
				q = a >> b;

			`ALU_ADD:
				q = a + b;

			`ALU_SUB:
				q = a - b;

`ifdef VERILATOR
			0: ;
`endif
		endcase

endmodule
