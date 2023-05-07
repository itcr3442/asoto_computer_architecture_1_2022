`include "core/uarch.sv"

module core_control
(
	input  logic           clk,
	                       rst_n,

	input  logic           irq,
	                       halt,

	input  insn_decode     dec,
	input  word            rd_value_a,
	                       rd_value_b,
	input  logic           mem_ready,
	input  word            mem_data_rd,
	input  logic           mul_ready,
	input  word            mul_q_hi,
	                       mul_q_lo,

	output logic           halted,
	                       stall,
	                       branch,
	output alu_op          alu,
	output word            alu_a,
	                       alu_b,
	output ptr             mem_addr,
	output word            mem_data_wr,
	output logic[3:0]      mem_data_be,
	output logic           mem_start,
	                       mem_write,
	output word            mul_a,
	                       mul_b,
	                       mul_c_hi,
	                       mul_c_lo,
	output logic           mul_add,
	                       mul_long,
	                       mul_start,
	                       mul_signed
);

	//TODO

endmodule
