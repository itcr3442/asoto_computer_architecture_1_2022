`include "core/uarch.sv"
`include "core/decode/isa.sv"

module core_alu
#(parameter W=16)
(
	input  alu_op         op,
	input  logic[W - 1:0] a,
	                      b,

	output logic[W - 1:0] q
);

	always_comb
		unique case(op)
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
