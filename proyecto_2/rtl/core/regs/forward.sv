`include "core/uarch.sv"

module core_regs_forward
(
	input  logic   clk,
	               rst_n,

	input  word    rd_hold,
	               wr_hold_a,
	               wr_hold_b,
	input  reg_num rd_r,
	               wr_hold_r_a,
	               wr_hold_r_b,

	output word    rd
);

	reg_num rd_hold_r;

	always_comb begin
		rd = rd_hold;

		if(rd_hold_r == wr_hold_r_a)
			rd = wr_hold_a;

		if(rd_hold_r == wr_hold_r_b)
			rd = wr_hold_b;

		if(rd_hold_r == `R0)
			rd = 0;
	end

	// No necesita rst
	always @(posedge clk)
		rd_hold_r <= rd_r;

endmodule
