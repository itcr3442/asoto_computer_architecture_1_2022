`include "core/uarch.sv"

module core_mmu
(
	input  logic          clk,
	                      rst_n,

	input  logic          bus_ready,
	input  word           bus_data_rd,
	                      data_data_wr,
	input  ptr            insn_addr,
	                      data_addr,
	input  logic          insn_start,
	                      data_start,
	                      data_write,
	input  logic[3:0]     data_data_be,

	output word           bus_data_wr,
	output logic[3:0]     bus_data_be,
	output ptr            bus_addr,
	output logic          bus_start,
	                      bus_write,
	                      insn_ready,
	                      data_ready,
	output word           insn_data_rd,
	                      data_data_rd
);

	ptr iphys_addr, dphys_addr;
	word iphys_data_rd, dphys_data_rd, dphys_data_wr;
	logic iphys_start, dphys_start, iphys_ready, dphys_ready, dphys_write;
	logic[3:0] dphys_data_be;

	assign iphys_addr = insn_addr;
	assign iphys_start = insn_start;
	assign insn_ready = iphys_ready;
	assign insn_data_rd = iphys_data_rd;

	assign dphys_addr = data_addr;
	assign dphys_start = data_start;
	assign dphys_write = data_write;
	assign dphys_data_wr = data_data_wr;
	assign dphys_data_be = data_data_be;
	assign data_ready = dphys_ready;
	assign data_data_rd = dphys_data_rd;

	core_mmu_arbiter arbiter
	(
		.insn_addr(iphys_addr),
		.insn_start(iphys_start),
		.insn_ready(iphys_ready),
		.insn_data_rd(iphys_data_rd),

		.data_addr(dphys_addr),
		.data_start(dphys_start),
		.data_write(dphys_write),
		.data_ready(dphys_ready),
		.data_data_wr(dphys_data_wr),
		.data_data_be(dphys_data_be),
		.data_data_rd(dphys_data_rd),

		.*
	);

endmodule
