`include "types.sv"

module bus_arbiter
(
	input  logic  clk,
	              rst_n,

	input  logic  avl_waitrequest,
	              avl_insn_read,
	              avl_data_read,
	              avl_data_write,
	input  word   avl_readdata,
	              avl_data_writedata,
	              avl_insn_address,
	              avl_data_address,
	input  nibble avl_data_byteenable,

	output word   avl_writedata,
	              avl_address,
	              avl_insn_readdata,
	              avl_data_readdata,
	output logic  avl_read,
	              avl_write,
	              avl_insn_waitrequest,
	              avl_data_waitrequest,
	output nibble avl_byteenable
);

	enum int unsigned
	{
		INSN,
		DATA
	} master, next_master;

	word hold_addr, hold_data_wr;
	logic active, hold_start, hold_write, hold_issue, hold_free, transition;
	nibble hold_data_be;

	assign avl_insn_readdata = avl_readdata;
	assign avl_data_readdata = avl_readdata;

	always_comb begin
		next_master = master;
		if(!avl_waitrequest || !active)
			unique case(master)
				DATA: next_master = (avl_data_read || avl_data_write) ? DATA : INSN;
				INSN: next_master = !avl_data_read && !avl_data_write && !hold_start ? INSN : DATA;
			endcase

		// Causa UNOPTFLAT en Verilator con assign
		transition = master != next_master;
		hold_issue = transition && hold_start;
		hold_free = transition || !hold_start;

		avl_insn_waitrequest = 1;
		avl_data_waitrequest = 1;

		unique case(master)
			INSN: avl_insn_waitrequest = avl_waitrequest;
			DATA: avl_data_waitrequest = avl_waitrequest;
		endcase

		avl_writedata = avl_data_writedata;
		unique case(next_master)
			INSN: begin
				avl_address = avl_insn_address;
				avl_read = avl_insn_read;
				avl_write = 0;
				avl_byteenable = 4'b1111;
			end

			DATA: begin
				avl_address = avl_data_address;
				avl_read = avl_data_read;
				avl_write = avl_data_write;
				avl_byteenable = avl_data_byteenable;
			end
		endcase

		if(hold_issue) begin
			avl_address = hold_addr;
			avl_write = hold_write;
			avl_read = !hold_write;
			avl_writedata = hold_data_wr;
			avl_byteenable = hold_data_be;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			master <= INSN;
			active <= 0;

			hold_addr <= 0;
			hold_start <= 0;
			hold_write <= 0;
			hold_data_wr <= 0;
			hold_data_be <= 0;
		end else begin
			master <= next_master;
			active <= avl_read || avl_write || (active && avl_waitrequest);

			if(hold_free)
				unique case(next_master)
					INSN: begin
						hold_addr <= avl_data_address;
						hold_start <= avl_data_read || avl_data_write;
						hold_write <= avl_data_write;
						hold_data_wr <= avl_data_writedata;
						hold_data_be <= avl_data_byteenable;
					end

					DATA: begin
						hold_addr <= avl_insn_address;
						hold_start <= avl_insn_read;
						hold_write <= 0;
						hold_data_be <= 4'b1111;
					end
				endcase
		end

endmodule
