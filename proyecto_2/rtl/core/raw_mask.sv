`include "core/uarch.sv"

module core_raw_mask
(
	input  logic   enable,
	input  reg_num r,
	output hword   raw_mask
);

	hword mask_bit;
	assign mask_bit = 1 << (enable ? r : `R0);
	assign raw_mask = {mask_bit[$bits(hword) - 1:1], 1'b0};

endmodule
