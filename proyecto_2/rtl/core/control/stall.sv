`include "core/uarch.sv"

module core_control_stall
(
	input  logic       clk,
	                   rst_n,
	                   halt,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       final_update_flags,	//!
	                   final_restore_spsr,	//!
	                   final_psr_write,		//!
	                   final_writeback,		//!
	input  reg_num     final_rd,			//!

	output logic       halted,
	                   stall,
	                   bubble,
	                   next_bubble
);

	logic pc_rd_hazard, pc_wr_hazard, rn_pc_hazard, snd_pc_hazard, psr_hazard, flags_hazard;

	assign stall = !next_cycle.issue || next_bubble || halt;
	assign halted = halt && !next_bubble && next_cycle.issue;
	assign next_bubble = 0;

	//FIXME: pc_rd_hazard no debería definirse sin final_writeback?
	assign psr_hazard = 0;
	assign pc_rd_hazard = 0;
	assign pc_wr_hazard = 0;
	assign rn_pc_hazard = 0;
	assign flags_hazard = 0;
	assign snd_pc_hazard = 0;

	always_ff @(posedge clk or negedge rst_n)
		bubble <= !rst_n ? 0 : next_cycle.issue && next_bubble;

	endmodule
