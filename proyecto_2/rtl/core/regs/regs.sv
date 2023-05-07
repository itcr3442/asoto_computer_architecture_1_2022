`include "core/uarch.sv"

module core_regs
(
	input  logic    clk,
	                rst_n,

	input  reg_num  rd_r_a,
	                rd_r_b,
	                wr_r,
	input  logic    wr_enable,
	input  word     wr_value,

	output word     rd_value_a,
	                rd_value_b,
	                wr_current,
	output logic    branch
);

	/* Las Cyclone V no tienen bloques de memoria con al menos dos puertos de
	 * lectura y uno de escritura (tres puertos), lo más que tienen son bloques
	 * de dos puertos en total. Podemos ponerle cinta a esto con dos copias
	 * sincronizadas del archivo de registros.
	 */

	word pc_word;
	logic wr_enable_file;

	assign branch = 0; // cagada
	assign wr_enable_file = wr_enable;

	core_reg_file a
	(
		.rd_r(rd_r_a),
		.rd_value(rd_value_a),
		.*
	);

	core_reg_file b
	(
		.rd_r(rd_r_b),
		.rd_value(rd_value_b),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n)
			wr_current <= 0;
		else if(wr_enable)
			wr_current <= wr_value;

endmodule
