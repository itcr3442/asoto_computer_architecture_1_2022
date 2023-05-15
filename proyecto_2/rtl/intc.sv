`include "types.sv"

module intc
(
	input  logic clk,
	             rst_n,

	input  logic irq_timer,
	             irq_jtaguart,

	input logic  avl_address,
	             avl_read,
	             avl_write,
	input  word  avl_writedata,

	output logic avl_irq,
	output word  avl_readdata
);

	word status, mask;

	assign status = {30'b0, irq_jtaguart, irq_timer} & mask;
	assign avl_irq = |status;
	assign avl_readdata = avl_address ? mask : status;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			mask <= 0;
		else if(avl_write && avl_address)
			mask <= avl_writedata;

endmodule
