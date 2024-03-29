`include "types.sv"

module conspiracion
(
	input  wire        clk_clk,
	input  wire        rst_n,
	input  wire        halt,
	output wire        cpu_halted,

	output wire [12:0] memory_mem_a,
	output wire [2:0]  memory_mem_ba,
	output wire        memory_mem_ck,
	output wire        memory_mem_ck_n,
	output wire        memory_mem_cke,
	output wire        memory_mem_cs_n,
	output wire        memory_mem_ras_n,
	output wire        memory_mem_cas_n,
	output wire        memory_mem_we_n,
	output wire        memory_mem_reset_n,
	inout  wire [7:0]  memory_mem_dq,
	inout  wire        memory_mem_dqs,
	inout  wire        memory_mem_dqs_n,
	output wire        memory_mem_odt,
	output wire        memory_mem_dm,
	input  wire        memory_oct_rzqin,
	output wire        vram_wire_clk,
	output wire [12:0] vram_wire_addr,
	output wire [1:0]  vram_wire_ba,
	output wire        vram_wire_cas_n,
	output wire        vram_wire_cke,
	output wire        vram_wire_cs_n,
	inout  wire [15:0] vram_wire_dq,
	output wire [1:0]  vram_wire_dqm,
	output wire        vram_wire_ras_n,
	output wire        vram_wire_we_n,
	output wire [7:0]  pio_leds,
	input  wire 	   pio_buttons,
	input  wire [5:0]  pio_switches,
	output wire        vga_dac_clk,
	output wire        vga_dac_hsync,
	output wire        vga_dac_vsync,
	output wire        vga_dac_blank_n,
	output wire        vga_dac_sync_n,
	output wire [7:0]  vga_dac_r,
	output wire [7:0]  vga_dac_g,
	output wire [7:0]  vga_dac_b
);

	logic button, reset_reset_n, cpu_clk, cpu_rst_n, cpu_halt, irq,
	      fetch_ready, insn_ready, data_ready, fetch_start, insn_start, data_start, data_write;

	ptr fetch_addr, data_addr;
	word fetch_data_rd, data_data_rd, data_data_wr;
	nibble data_data_be;

	mar810 core
	(
		.clk(cpu_clk),
		.rst_n(cpu_rst_n),
		.halt(cpu_halt),
		.halted(cpu_halted),
		.*
	);

`ifdef VERILATOR
	assign cpu_halt = halt;
	assign reset_reset_n = rst_n;
	assign button = pio_buttons;

	ptr insn_addr;
	word insn_data_rd;

	assign insn_addr = fetch_addr;
	assign insn_start = fetch_start;
	assign fetch_ready = insn_ready;
	assign fetch_data_rd = insn_data_rd;
`else
	qptr insn_addr;
	qword insn_data_rd;

	debounce reset_debounce
	(
		.clk(clk_clk),
		.dirty(rst_n),
		.clean(reset_reset_n)
	);

	debounce halt_debounce
	(
		.clk(cpu_clk),
		.dirty(halt),
		.clean(cpu_halt)
	);

	debounce button_debounce
	(
		.clk(clk_clk),
		.dirty(pio_buttons),
		.clean(button)
	);

	cache_l1i l1i
	(
		.clk(cpu_clk),
		.rst_n(cpu_rst_n),
		.*
	);
`endif

	platform plat
	(
		.master_0_core_cpu_clk(cpu_clk),
		.master_0_core_cpu_rst_n(cpu_rst_n),
		.master_0_core_irq(irq),
		.master_0_core_insn_ready(insn_ready),
		.master_0_core_data_ready(data_ready),
		.master_0_core_insn_data_rd(insn_data_rd),
		.master_0_core_data_data_rd(data_data_rd),
		.master_0_core_data_data_wr(data_data_wr),
		.master_0_core_insn_addr(insn_addr),
		.master_0_core_data_addr(data_addr),
		.master_0_core_insn_start(insn_start),
		.master_0_core_data_start(data_start),
		.master_0_core_data_write(data_write),
		.master_0_core_data_data_be(data_data_be),
		.pll_0_reset_reset(0), //TODO: reset controller, algún día
		.pio_0_external_connection_export(pio_leds),
		.switches_external_connection_export({2'b00, pio_switches}),
		//TODO: glitch rst
		.buttons_external_connection_export({7'b0000000, !button}),
		.sys_sdram_pll_0_sdram_clk_clk(vram_wire_clk),
		.vga_dac_CLK(vga_dac_clk),
		.vga_dac_HS(vga_dac_hsync),
		.vga_dac_VS(vga_dac_vsync),
		.vga_dac_BLANK(vga_dac_blank_n),
		.vga_dac_SYNC(vga_dac_sync_n),
		.vga_dac_R(vga_dac_r),
		.vga_dac_G(vga_dac_g),
		.vga_dac_B(vga_dac_b),
		.*
	);

endmodule
