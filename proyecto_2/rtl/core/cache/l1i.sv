`include "core/uarch.sv"

module core_cache_l1i
(
	input  logic      clk,
	                  rst_n,

	input  logic      insn_ready,
	input  qword      insn_data_rd,
	input  ptr        fetch_addr,
	input  logic      fetch_start,

	output qptr       insn_addr,
	output logic      insn_start,
	                  fetch_ready,
	output word       fetch_data_rd
);

    logic[25:0] bus_addr;
    assign insn_addr = {5'b00000, bus_addr[25:3]};

    core_cache_4way #(.cache_entry(8)) cache
    (
        .i_p_addr(fetch_addr[24:0]),
        .i_p_byte_en(4'b1111),
        .i_p_writedata(),
        .i_p_read(fetch_start),
        .i_p_write(0),
        .o_p_readdata(fetch_data_rd),
        .o_p_readdata_valid(fetch_ready),
        .o_p_waitrequest(),

        .o_m_addr(bus_addr),
        .o_m_byte_en(),
        .o_m_writedata(),
        .o_m_read(insn_start),
        .o_m_write(),
        .i_m_readdata(insn_data_rd),
        .i_m_readdata_valid(insn_ready),
        .i_m_waitrequest(!insn_ready),

        .cnt_r(),
        .cnt_w(),
        .cnt_hit_r(),
        .cnt_hit_w(),
        .cnt_wb_r(),
        .cnt_wb_w(),

        .*
    );

endmodule