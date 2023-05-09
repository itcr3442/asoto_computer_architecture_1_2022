`include "core/uarch.sv"

module core_dispatch_hazards
(
	input  insn_decode dec_a,
	                   dec_b,

	output logic       b_wants_a
);

	always_comb begin
		b_wants_a = 0;

		if(dec_a.data.writeback)
			b_wants_a = (dec_b.data.uses_ra && dec_b.data.ra == dec_a.data.rd)
			         || (dec_b.data.uses_rb && dec_b.data.rb == dec_a.data.rd);

		// Riesgo estructural, solo tenemos una EU cada una de estas
		if(dec_a.ctrl.branch
		|| (dec_a.ctrl.mul && dec_b.ctrl.mul)
		|| (dec_a.ctrl.ldst && dec_b.ctrl.ldst))
			b_wants_a = 1;

		if(!dec_a.ctrl.execute || !dec_b.ctrl.execute)
			b_wants_a = 0;
	end

endmodule
