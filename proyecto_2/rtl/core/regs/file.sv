`include "core/uarch.sv"

module core_reg_file
(
	input  logic     clk,
	                 rst_n,

	input  psr_mode  rd_mode,
	input  reg_num   rd_r,
	                 wr_r,
	input  logic     wr_enable,
	                 wr_enable_file,
	input  word      wr_value,
	                 wr_current,
	                 pc_word,

	output word      rd_value
);

	// Ver comentario en uarch.sv
	word file[`NUM_GPREGS] /*verilator public*/;
	word rd_actual;
	logic forward;

	assign rd_value = forward ? wr_current : rd_actual;

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			forward <= 0;
			rd_actual <= 0;
		end else begin
			forward <= wr_enable && rd_r == wr_r;

			if(wr_enable_file)
				file[wr_r] <= wr_value;

			rd_actual <= file[rd_r];
		end

endmodule
