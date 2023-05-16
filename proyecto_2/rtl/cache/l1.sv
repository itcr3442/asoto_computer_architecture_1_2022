
module cache_l1(clk,
                 rst_n,
                 p_addr,
                 p_writedata,
                 p_read,
                 p_write,
                 p_readdata,
                 p_readdata_valid,
                 p_waitrequest,

                 m_addr,
                 m_writedata,
                 m_read,
                 m_write,
                 m_readdata,
                 m_readdata_valid,
                 m_waitrequest);

	parameter cache_entry = 14;

	input  wire         clk, rst_n;
    input  wire [31:0]  p_addr;
    input  wire [31:0]  p_writedata;
    input  wire         p_read, p_write;
    output reg  [31:0]  p_readdata;
    output reg          p_readdata_valid;
    output wire         p_waitrequest;

    output reg  [31:0]  m_addr;
    output reg  [127:0] m_writedata;
    output reg          m_read, m_write;
    input  wire [127:0] m_readdata;
    input  wire         m_readdata_valid;
    input  wire         m_waitrequest;

    logic [25:0] bus_addr;
    assign m_addr = {5'b00000, bus_addr[25:3], 4'b0000};

	cache_4way #(.cache_entry(cache_entry)) l1(
		.o_m_addr(bus_addr),
        .i_p_addr(p_addr[24:0]),
        .o_m_byte_en(),
		.i_p_byte_en(4'b1111),
		.cnt_r(),
		.cnt_w(),
		.cnt_hit_r(),
		.cnt_hit_w(),
		.cnt_wb_r(),
		.cnt_wb_w(),
        .i_p_writedata(p_writedata),
        .i_p_read(p_read),
        .i_p_write(p_write),
        .o_p_readdata(p_readdata),
        .o_p_readdata_valid(p_readdata_valid),
        .o_p_waitrequest(p_waitrequest),
        .o_m_writedata(m_writedata),
        .o_m_read(m_read),
        .o_m_write(m_write),
        .i_m_readdata(m_readdata),
        .i_m_readdata_valid(m_readdata_valid),
        .i_m_waitrequest(m_waitrequest),
        .*
	);



endmodule