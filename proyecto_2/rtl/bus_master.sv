`include "types.sv"

module bus_master
(
	input  logic  clk,
	              rst_n,

	output logic  cpu_clk,
	              cpu_rst_n,
	              irq,

	output logic  insn_ready,
	              data_ready,
`ifdef VERILATOR
	output word   insn_data_rd,
`else
	output qword  insn_data_rd,
`endif
	output word   data_data_rd,

	input  word   data_data_wr,
`ifdef VERILATOR
	input  ptr    insn_addr,
`else
	input  qptr   insn_addr,
`endif
	input  ptr    data_addr,
	input  logic  insn_start,
	              data_start,
	              data_write,
	input  nibble data_data_be,

	output word   avl_data_address,
	output logic  avl_data_read,
	              avl_data_write,
	input  word   avl_data_readdata,
	output word   avl_data_writedata,
	input  logic  avl_data_waitrequest,
	output nibble avl_data_byteenable,

	output word   avl_insn_address,
	output logic  avl_insn_read,
`ifdef VERILATOR
	input  word   avl_insn_readdata,
`else
	input  qword  avl_insn_readdata,
`endif
	input  logic  avl_insn_waitrequest,

	input  logic  avl_irq
);

	enum int unsigned
	{
		IDLE,
		WAIT
	} d_state, i_state;

	assign irq = avl_irq;
	assign cpu_clk = clk;
	assign cpu_rst_n = rst_n;

	assign data_data_rd = avl_data_readdata;
	assign insn_data_rd = avl_insn_readdata;

	always_comb begin
		unique case(d_state)
			IDLE: data_ready = 0;
			WAIT: data_ready = !avl_data_waitrequest;
		endcase

		unique case(i_state)
			IDLE: insn_ready = 0;
			WAIT: insn_ready = !avl_insn_waitrequest;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		/* P. 16:
		 * A host must make no assumption about the assertion state of
		 * waitrequest when the host is idle: waitrequest may be high or
		 * low, depending on system properties. When waitrequest is asserted,
		 * host control signals to the agent must remain constant except for
		 * beginbursttransfer.
		 */
		if(!rst_n) begin
			d_state <= IDLE;
			avl_data_read <= 0;
			avl_data_write <= 0;
			avl_data_address <= 0;
			avl_data_writedata <= 0;
			avl_data_byteenable <= 0;
			
			i_state <= IDLE;
			avl_insn_read <= 0;
			avl_insn_address <= 0;
		end else begin
			if((d_state == IDLE || !avl_data_waitrequest) && data_start) begin
				d_state <= WAIT;
				avl_data_read <= ~data_write;
				avl_data_write <= data_write;
				avl_data_address <= {data_addr, 2'b00};
				avl_data_writedata <= data_data_wr;
				avl_data_byteenable <= data_write ? data_data_be : 4'b1111;
			end else if(d_state == WAIT && !avl_data_waitrequest) begin
				d_state <= IDLE;
				avl_data_read <= 0;
				avl_data_write <= 0;
			end

			if((i_state == IDLE || !avl_insn_waitrequest) && insn_start) begin
				i_state <= WAIT;
				avl_insn_read <= 1;
				avl_insn_address <= {insn_addr, {($bits(avl_insn_address) - $bits(insn_addr)){1'b0}}};
			end else if(i_state == WAIT && !avl_insn_waitrequest) begin
				i_state <= IDLE;
				avl_insn_read <= 0;
			end
		end

endmodule
