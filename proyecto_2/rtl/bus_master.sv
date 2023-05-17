module bus_master
(
	input  logic        clk,
	                    rst_n,

	output logic        cpu_clk,
	                    cpu_rst_n,
	                    irq,

	output logic        insn_ready,
	                    data_ready,
`ifdef VERILATOR
	output logic[31:0]  insn_data_rd,
	                    data_data_rd,
`else
	output logic [127:0] insn_data_rd,
	output logic [31:0]  data_data_rd,
`endif

	input  logic[31:0]  data_data_wr,
`ifdef VERILATOR
	input  logic[29:0]  insn_addr,
	                    data_addr,
`else
	input  logic[27:0]  insn_addr,
	input  logic[29:0]  data_addr,
`endif
	input  logic        insn_start,
	                    data_start,
	                    data_write,

`ifndef VERILATOR
	input  logic        io_start,
	                    io_write,
	input  logic[29:0]  io_addr,
	input  logic[31:0]  io_data_wr,
	output logic        io_ready,
	output logic[31:0]  io_data_rd,
`endif

	output logic[31:0]  avl_data_address,
	output logic        avl_data_read,
	                    avl_data_write,
	input  logic        avl_data_waitrequest,
`ifdef VERILATOR
	input  logic[31:0]  avl_data_readdata,
	output logic[31:0]  avl_data_writedata,
`else
	input  logic[31:0] avl_data_readdata,
	output logic[31:0] avl_data_writedata,
`endif

	output logic[31:0]  avl_insn_address,
	output logic        avl_insn_read,
	input  logic        avl_insn_waitrequest,
`ifdef VERILATOR
	input  logic[31:0]  avl_insn_readdata,
`else
	input  logic[127:0] avl_insn_readdata,
`endif

`ifndef VERILATOR
	output logic[31:0]  avl_io_address,
	output logic        avl_io_read,
	                    avl_io_write,
	input  logic        avl_io_waitrequest,
	input  logic[31:0]  avl_io_readdata,
	output logic[31:0]  avl_io_writedata,
`endif

	input  logic        avl_irq
);

	enum int unsigned
	{
		IDLE,
		WAIT
	} d_state, i_state, p_state;

	assign irq = avl_irq;
	assign cpu_clk = clk;
	assign cpu_rst_n = rst_n;

`ifndef VERILATOR
	assign io_data_rd = avl_io_readdata;
`endif
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

`ifndef VERILATOR
		unique case(p_state)
			IDLE: io_ready = 0;
			WAIT: io_ready = !avl_io_waitrequest;
		endcase
`endif
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

			i_state <= IDLE;
			avl_insn_read <= 0;
			avl_insn_address <= 0;

`ifndef VERILATOR
			p_state <= IDLE;
			avl_io_read <= 0;
			avl_io_write <= 0;
			avl_io_address <= 0;
			avl_io_writedata <= 0;
`endif
		end else begin
			if((d_state == IDLE || !avl_data_waitrequest) && data_start) begin
				d_state <= WAIT;
				avl_data_read <= ~data_write;
				avl_data_write <= data_write;
				avl_data_address <= {data_addr, 2'b00};
				avl_data_writedata <= data_data_wr;
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

`ifndef VERILATOR
			if((p_state == IDLE || !avl_io_waitrequest) && io_start) begin
				p_state <= WAIT;
				avl_io_read <= ~io_write;
				avl_io_write <= io_write;
				avl_io_address <= {io_addr, 2'b00};
				avl_io_writedata <= io_data_wr;
			end else if(p_state == WAIT && !avl_io_waitrequest) begin
				p_state <= IDLE;
				avl_io_read <= 0;
				avl_io_write <= 0;
			end
`endif
		end

endmodule
