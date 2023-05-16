`include "types.sv"

module ldst_switch
(
	input  logic      clk,
	                  rst_n,

	input  logic      io_ready,
	                  l1d_ready,
	                  ldst_start,
	                  ldst_write,
	input  ptr        ldst_addr,
	input  word       ldst_data_wr,
	                  io_data_rd,
	                  l1d_data_rd,

	output ptr        io_addr,
	                  l1d_addr,
	output logic      io_start,
	                  io_write,
	                  l1d_start,
	                  l1d_write,
	                  ldst_ready,
	output word       ldst_data_rd,
	                  io_data_wr,
	                  l1d_data_wr
);

	logic dec_data, current_data, active;
	assign dec_data = !(|ldst_addr[29:27]); // Primeros 512MiB van para L1d

	assign io_addr = ldst_addr;
	assign l1d_addr = ldst_addr;
	assign io_start = ldst_start && !dec_data;
	assign io_write = ldst_write;
	assign l1d_start = ldst_start && dec_data;
	assign l1d_write = ldst_write;
	assign ldst_data_rd = current_data ? l1d_data_rd : io_data_rd;
	assign io_data_wr = ldst_data_wr;
	assign l1d_data_wr = ldst_data_wr;
	assign ldst_ready = active && (current_data ? l1d_ready : io_ready);

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			active <= 0;
			current_data <= 0;
		end else begin
			active <= !ldst_ready || ldst_start;
			if(ldst_start)
				current_data <= dec_data;
		end

endmodule
