`include "types.sv"

module cache_l1d
(
	input  logic      clk,
	                  rst_n,

	input  logic      data_ready,
	                  ldst_start,
	                  ldst_write,
	input  ptr        ldst_addr,
	input  word       ldst_data_wr,
	input  qword      data_data_rd,

	output qptr       data_addr,
	output logic      data_start,
	                  data_write,
	                  ldst_ready,
	output word       ldst_data_rd,
	output qword      data_data_wr
);

	word in_address, in_writedata;
	logic in_wait, in_read, in_write, in_ready, in_readdata_valid, in_waitrequest, out_read, out_write;

	assign in_ready = (in_write && !in_waitrequest) || in_readdata_valid;
	assign ldst_ready = in_wait && in_ready;

	logic out_waitrequest;
    logic[25:0] bus_addr;

    assign data_addr = {5'b00000, bus_addr[25:3]};
	assign data_start = (out_read || out_write) && !out_wait;
	assign data_write = out_write;

    cache_4way #(.cache_entry(10)) cache
    (
        .i_p_addr(in_address[26:2]),
        .i_p_byte_en(4'b1111),
        .i_p_writedata(in_writedata),
        .i_p_read(in_read),
        .i_p_write(in_write),
        .o_p_readdata(ldst_data_rd),
        .o_p_readdata_valid(in_readdata_valid),
        .o_p_waitrequest(in_waitrequest),

        .o_m_addr(bus_addr),
        .o_m_byte_en(),
        .o_m_writedata(data_data_wr),
        .o_m_read(out_read),
        .o_m_write(out_write),
        .i_m_readdata(data_data_rd),
        .i_m_readdata_valid(out_wait && out_read && data_ready),
        .i_m_waitrequest((out_read || out_write) && (!out_wait || !data_ready)),

        .cnt_r(),
        .cnt_w(),
        .cnt_hit_r(),
        .cnt_hit_w(),
        .cnt_wb_r(),
        .cnt_wb_w(),

        .*
    );

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			in_wait <= 0;
			in_read <= 0;
			in_write <= 0;
			in_address <= 0;
			in_writedata <= 0;

			out_wait <= 0;
		end else begin
			if((!in_wait || in_ready) && ldst_start) begin
				in_wait <= 1;
				in_read <= !ldst_write;
				in_write <= ldst_write;
				in_address <= {ldst_addr, 2'b00};
				in_writedata <= ldst_data_wr;
			end else if(ldst_ready) begin
				in_wait <= 0;
				in_read <= 0;
				in_write <= 0;
			end

			out_wait <= out_wait ? !data_ready : out_read || out_write;
		end

endmodule
