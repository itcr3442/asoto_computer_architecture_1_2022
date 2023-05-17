`include "types.sv"

module ldst_switch
(
	input  logic      clk,
	                  rst_n,

	input  logic      io_ready,
	                  data_ready,
	                  ldst_start,
	                  ldst_write,
	input  ptr        ldst_addr,
	input  word       ldst_data_wr,
	                  io_data_rd,
	                  data_data_rd,

	output ptr        io_addr,
	                  data_addr,
	output logic      io_start,
	                  io_write,
	                  data_start,
	                  data_write,
	                  ldst_ready,
	output word       ldst_data_rd,
	                  io_data_wr,
	                  data_data_wr
);

	logic dec_data, current_data, active;
	assign dec_data = !(|ldst_addr[29:27]); // Primeros 512MiB van para L1d

	assign io_addr = ldst_addr;
	assign data_addr = ldst_addr;
	assign io_start = ldst_start && !dec_data && (!active || ldst_ready);
	assign io_write = ldst_write;
	assign data_start = ldst_start && dec_data && (!active || ldst_ready);
	assign data_write = ldst_write;
	assign ldst_data_rd = current_data ? data_data_rd : io_data_rd;
	assign io_data_wr = ldst_data_wr;
	assign data_data_wr = ldst_data_wr;
	assign ldst_ready = active && (current_data ? data_ready : io_ready);

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			active <= 0;
			current_data <= 0;
		end else if(!active || ldst_ready) begin
			active <= ldst_start;
			current_data <= dec_data;
		end

endmodule
