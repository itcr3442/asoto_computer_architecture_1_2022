`include "core/uarch.sv"

module core_alu
#(parameter W=16)
(
	input  logic          clk,
	                      rst_n,

	input  insn_decode    dec,
	input  logic          start,
	input  logic[W - 1:0] a,
	                      b,

	output wb_line        wb
);

	logic[W - 1:0] b_or_imm, q;

	assign b_or_imm = dec.data.uses_imm ? {{(W - $bits(dec.data.imm)){1'b0}}, dec.data.imm} : b;

	always_comb
		unique case(dec.alu.op)
			`ALU_AND:
				q = a & b;

			`ALU_ORR:
				q = a | b;

			`ALU_XOR:
				q = a ^ b;

			`ALU_SHL:
				q = a << b_or_imm;

			`ALU_SHR:
				q = a >> b_or_imm;

			`ALU_ADD:
				q = a + b_or_imm;

			`ALU_SUB:
				q = a - b_or_imm;

`ifdef VERILATOR
			0: ;
`endif
		endcase

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			wb <= {$bits(wb_line){1'bx}};
			wb.ready <= 0;
		end else begin
			wb.rd <= dec.data.rd;
			wb.value <= q;
			wb.ready <= 0;
		end

endmodule
