`include "core/uarch.sv"

/* Latencia de 4 ciclos, ver doc/mul.txt
 *
 * Las etapas son:
 * - mul_ab: Productos acelerados de permutaciones a0-a3 con b0-b3
 * - mul_pp: Recombinación de productos parciales
 * - mul_lo: Mitad baja del resultado y una parte de la alta
 * - mul_hi: Mitad alta del resultado
 */
module core_mul
(
	input  logic          clk,
	                      rst_n,

	input  insn_decode    dec,
	input  logic          start,
	                      wb_stall,
	input  word           a,
	                      b,

	output wb_line        wb,
	output hword          raw_mask,
	output logic          ab_stall
);

	hword raw_ab, raw_pp, raw_lo, raw_hi;
	reg_num pp_rd, lo_rd, hi_rd, wb_rd;

	logic pp, pp_stall, lo, lo_stall, hi, hi_stall, ready;

	logic[7:0] a3, a2, a1, a0, b3, b2, b1, b0, a3_b0, a2_b1, a1_b2, a0_b3,
			   a0_b2_hi, a0_b2_lo, a0_b1_hi, a0_b1_lo, a0_b0_hi, a0_b0_lo,
               q_b_hi, q_b_lo, q_d_lo, q_a;

	logic[15:0] a2_b0, a1_b0, a1_b1, a0_b0, a0_b1, a0_b2, q_b, q_ab, q_cd_hi, q_cd_lo;
	logic[23:0] q_c, q_d_hi;
	logic[31:0] q, q_d, q_cd;

	assign {a3, a2, a1, a0} = a;
	assign {b3, b2, b1, b0} = b;

	assign {a0_b2_hi, a0_b2_lo} = a0_b2;
	assign {a0_b1_hi, a0_b1_lo} = a0_b1;
	assign {a0_b0_hi, a0_b0_lo} = a0_b0;

	assign {q_b_hi, q_b_lo} = q_b;
	assign {q_d_hi, q_d_lo} = q_d;
	assign {q_cd_hi, q_cd_lo} = q_cd;

	assign ab_stall = pp_stall && start;
	assign pp_stall = lo_stall && pp;
	assign lo_stall = hi_stall && lo;
	assign hi_stall = wb_stall && hi;

	assign wb.rd = wb_rd;
	assign wb.ready = ready;
	assign wb.value = q;
	assign raw_mask = raw_ab | raw_pp | raw_lo | raw_hi;

	core_raw_mask ab_mask
	(
		.r(dec.data.rd),
		.enable(start),
		.raw_mask(raw_ab)
	);

	core_raw_mask pp_mask
	(
		.r(pp_rd),
		.enable(pp),
		.raw_mask(raw_pp)
	);

	core_raw_mask lo_mask
	(
		.r(lo_rd),
		.enable(lo),
		.raw_mask(raw_lo)
	);

	core_raw_mask hi_mask
	(
		.r(hi_rd),
		.enable(hi),
		.raw_mask(raw_hi)
	);

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pp <= 0;
			lo <= 0;
			hi <= 0;
			ready <= 0;
		end else begin
			if(!pp_stall)
				pp <= start;

			if(!lo_stall)
				lo <= pp;

			if(!hi_stall)
				hi <= lo;

			if(!wb_stall)
				ready <= hi;
		end

	always @(posedge clk) begin
		if(!pp_stall) begin
			/* Como los operandos son pequeños (8 bits), esto no se sintetiza,
			 * sino que se enruta a través de los bloques de DSP más cercanos en la
			 * fábrica
			 */
			a2_b0 <= a2 * b0;
			a1_b0 <= a1 * b0;
			a1_b1 <= a1 * b1;
			a0_b0 <= a0 * b0;
			a0_b1 <= a0 * b1;
			a0_b2 <= a0 * b2;

			a3_b0 <= a3 * b0;
			a2_b1 <= a2 * b1;
			a1_b2 <= a1 * b2;
			a0_b3 <= a0 * b3;

			pp_rd <= dec.data.rd;
		end

		if(!lo_stall) begin
			q_a <= a0_b3;
			q_b <= {a1_b2 + a0_b2_hi, a0_b2_lo};
			q_c <= {{a2_b1, a0_b1_hi} + a1_b1, a0_b1_lo};
			q_d <= {{a3_b0, a1_b0} + {a2_b0, a0_b0_hi}, a0_b0_lo};

			lo_rd <= pp_rd;
		end

		if(!hi_stall) begin
			q_ab <= {q_a + q_b_hi, q_b_lo};
			q_cd <= {q_c + q_d_hi, q_d_lo};

			hi_rd <= lo_rd;
		end

		if(!wb_stall) begin
			q <= {q_ab + q_cd_hi, q_cd_lo};
			wb_rd <= hi_rd;
		end
	end

endmodule
