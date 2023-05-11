`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  logic       clk,
	                   rst_n,

	input  hword       insn,
	input  hptr        insn_pc,
	input  logic       stall,
	                   flush,

	output insn_decode dec
);

	alu_decode dec_alu;
	ext_decode dec_ext;
	sys_decode dec_sys;
	ctrl_decode dec_ctrl;
	data_decode dec_data;
	branch_decode dec_branch;

	insn_decode next_dec;
	assign next_dec.pc = insn_pc;
	assign next_dec.alu = dec_alu;
	assign next_dec.ext = dec_ext;
	assign next_dec.sys = dec_sys;
	assign next_dec.ctrl = dec_ctrl;
	assign next_dec.data = dec_data;
	assign next_dec.branch = dec_branch;

	assign dec_ctrl.alu = alu;
	assign dec_ctrl.ext = ext;
	assign dec_ctrl.mul = mul;
	assign dec_ctrl.sys = sys;
	assign dec_ctrl.ldst = ldst;
	assign dec_ctrl.branch = branch;
	assign dec_ctrl.execute = execute;

	logic alu, branch, execute, ext, ldst, mul, sys, load;

	always_comb begin
		alu = 0;
		ext = 0;
		mul = 0;
		sys = 0;
		ldst = 0;
		branch = 0;
		execute = 1;

		dec_data = {($bits(dec_data)){1'bx}};
		dec_data.uses_ra = 0;
		dec_data.uses_rb = 0;
		dec_data.uses_imm = 0;
		dec_data.writeback = 0;

		dec_branch = {($bits(dec_branch)){1'bx}};
		dec_branch.cond = `COND_ALWAYS;
		dec_branch.indirect = 0;

		dec_alu = {($bits(dec_alu)){1'bx}};
		dec_ext = {($bits(dec_ext)){1'bx}};
		dec_sys = {($bits(dec_sys)){1'bx}};

		// El orden de los casos es importante, NO CAMBIAR
		priority casez(insn)
			`GROUP_BAL: begin
				dec_branch.offset = {insn `FIELD_BAL_J_HI, insn `FIELD_BAL_J_LO};
				branch = 1;
			end

			`GROUP_EXT1: begin
				dec_ext.op = {1'b0, insn `FIELD_EXT1_I};
				ext = 1;
				execute = 0; //TODO
			end

			`GROUP_EXT2: begin
				dec_ext.op = {1'b1, insn `FIELD_EXT2_I};
				ext = 1;
				execute = 0;
			end

			`GROUP_MUL: begin
				dec_data.ra = insn `FIELD_MUL_A;
				dec_data.rd = insn `FIELD_MUL_Z;
				dec_data.rb = dec_data.rd;

				dec_data.uses_ra = 1;
				dec_data.uses_rb = 1;
				dec_data.writeback = 1;
				mul = 1;
			end

			`GROUP_BIN: begin
				dec_data.ra = insn `FIELD_BIN_A;

				dec_data.uses_ra = 1;
				dec_branch.indirect = 1;
				branch = 1;
			end

			`GROUP_SYS: begin
				dec_sys.op = insn `FIELD_SYS_I;
				sys = 1;
				execute = 0; //TODO
			end

			`GROUP_IMM: begin
				dec_alu.op = `ALU_ADD;
				dec_data.ra = `R0;
				dec_data.rd = insn `FIELD_IMM_D;
				dec_data.imm = insn `FIELD_IMM_I;

				dec_data.uses_imm = 1;
				dec_data.writeback = 1;
				alu = 1;
			end

			`GROUP_BCC: begin
				dec_data.ra = {insn `FIELD_BCC_P, 1'b0};
				dec_data.rb = {insn `FIELD_BCC_P, 1'b1};

				dec_branch.cond = insn `FIELD_BCC_C;
				dec_branch.offset = {{5{insn `FIELD_BCC_J_SGN}}, insn `FIELD_BCC_J};

				dec_data.uses_ra = 1;
				dec_data.uses_rb = 1;
				branch = 1;
			end

			`GROUP_ADR: begin
				dec_data.rd = insn `FIELD_ADR_D;
				dec_branch.offset = {{2{insn `FIELD_ADR_J_SGN}}, insn `FIELD_ADR_J};

				dec_data.writeback = 1;
				branch = 1;
			end

			`GROUP_ALU: begin
				dec_alu.op = insn `FIELD_ALU_O;
				dec_data.ra = insn `FIELD_ALU_A;
				dec_data.rb = insn `FIELD_ALU_B;
				dec_data.rd = insn `FIELD_ALU_D;

				dec_data.uses_ra = 1;
				dec_data.uses_rb = 1;
				dec_data.writeback = 1;
				alu = 1;
			end

			`GROUP_MEM: begin
				dec_data.ra = insn `FIELD_MEM_A;
				dec_data.rb = insn `FIELD_MEM_D;
				dec_data.rd = dec_data.rb;
				dec_data.writeback = insn `FIELD_MEM_L;

				dec_data.uses_ra = 1;
				dec_data.uses_rb = !dec_data.writeback;
				ldst = 1;
			end

			`GROUP_INC: begin
				dec_alu.op = {`ALU_PREFIX_ADDSUB, insn `FIELD_INC_S};
				dec_data.ra = insn `FIELD_INC_Z;
				dec_data.rd = dec_data.ra;
				dec_data.imm = insn `FIELD_INC_I;

				dec_data.uses_ra = 1;
				dec_data.uses_imm = 1;
				dec_data.writeback = 1;
				alu = 1;
			end

			`GROUP_SHI: begin
				dec_alu.op = {`ALU_PREFIX_SHLSHR, insn `FIELD_SHI_S};
				dec_data.ra = insn `FIELD_SHI_A;
				dec_data.rd = insn `FIELD_SHI_D;
				dec_data.imm = insn `FIELD_SHI_I;

				dec_data.uses_ra = 1;
				dec_data.uses_imm = 1;
				dec_data.writeback = 1;
				alu = 1;
			end
		endcase

		if(dec_data.ra == `R0)
			dec_data.uses_ra = 0;

		if(dec_data.rb == `R0)
			dec_data.uses_rb = 0;

		if(dec_data.rd == `R0)
			dec_data.writeback = 0;

		if(insn == `NOP)
			execute = 0;
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			dec <= {$bits(dec){1'b0}};
		else if(flush)
			// Equivalente de `NOP
			dec <= {$bits(dec){1'b0}};
		else if(!stall)
			dec <= next_dec;

endmodule
