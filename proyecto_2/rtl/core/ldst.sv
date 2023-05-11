`include "core/uarch.sv"

module core_ldst
(
	input  logic          clk,
	                      rst_n,

	input  insn_decode    dec,
	input  logic          start,
	                      data_ready,
	                      wb_stall,
	input  word           a,
	                      b,
	                      data_data_rd,

	output wb_line        wb,
	output hword          raw_mask,
	output ptr            data_addr,
	output word           data_data_wr,
	output logic          ldst_wait,
	                      data_start,
	                      data_write,
	output logic[3:0]     data_data_be
);

	word addr;
	logic data_wait, load, hold_wb;
	reg_num hold_rd;

	assign addr = load ? a : b;
	assign load = dec.data.writeback;
	assign raw_mask = raw_in | raw_hold;
	assign ldst_wait = data_wait || wb_stall;
	assign data_data_be = 4'b1111; // Solo soportamos ldw/stw

	hword raw_in;

	core_raw_mask in_mask
	(
		.r(dec.data.rd),
		.enable(start && load),
		.raw_mask(raw_in)
	);

	hword raw_hold;

	core_raw_mask hold_mask
	(
		.r(hold_rd),
		.enable(hold_wb),
		.raw_mask(raw_hold)
	);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			data_wait <= 0;
			data_start <= 0;

			wb <= {$bits(wb_line){1'bx}};
			wb.ready <= 0;

			hold_wb <= 0;
		end else begin
			data_start <= start;
			if(start) begin
				data_wait <= 1;
				hold_wb <= load;
			end

			if(data_wait && data_ready) begin
				data_wait <= 0;
				hold_wb <= 0;
			end

			if(!wb_stall) begin
				wb.rd <= hold_rd;
				wb.value <= data_data_rd;
				wb.ready <= hold_wb && data_wait && data_ready;
			end
		end

	// No necesitan rst
	always_ff @(posedge clk)
		if(start) begin
			data_addr <= addr[31:2];
			data_write <= !load;
			data_data_wr <= a;

			hold_rd <= dec.data.rd;
		end

endmodule
