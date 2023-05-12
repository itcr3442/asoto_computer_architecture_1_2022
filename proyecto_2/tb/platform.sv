module platform
(
	input  wire         clk_clk,                          //                       clk.clk
	input  wire [29:0]  master_0_core_data_addr,             //                master_0_core.data_addr
	output wire [31:0]  master_0_core_data_data_rd,          //                             .data_data_rd
	input  wire [31:0]  master_0_core_data_data_wr,          //                             .data_data_wr
	output wire         master_0_core_data_ready,            //                             .data_ready
	input  wire         master_0_core_data_write,            //                             .data_write
	input  wire         master_0_core_data_start,            //                             .data_start
	output wire         master_0_core_irq,                   //                             .irq
	output wire         master_0_core_cpu_clk,               //                             .cpu_clk
	output wire         master_0_core_cpu_rst_n,             //                             .cpu_rst_n
	input  wire [3:0]   master_0_core_data_data_be,          //                             .data_data_be
	input  wire [27:0]  master_0_core_insn_addr,             //                             .insn_addr
	output wire [127:0] master_0_core_insn_data_rd,          //                             .insn_data_rd
	output wire         master_0_core_insn_ready,            //                             .insn_ready
	input  wire         master_0_core_insn_start,            //                             .insn_start
	output wire [12:0]  memory_mem_a,                     //                    memory.mem_a
	output wire [2:0]   memory_mem_ba,                    //                          .mem_ba
	output wire         memory_mem_ck,                    //                          .mem_ck
	output wire         memory_mem_ck_n,                  //                          .mem_ck_n
	output wire         memory_mem_cke,                   //                          .mem_cke
	output wire         memory_mem_cs_n,                  //                          .mem_cs_n
	output wire         memory_mem_ras_n,                 //                          .mem_ras_n
	output wire         memory_mem_cas_n,                 //                          .mem_cas_n
	output wire         memory_mem_we_n,                  //                          .mem_we_n
	output wire         memory_mem_reset_n,               //                          .mem_reset_n
	inout  wire [7:0]   memory_mem_dq,                    //                          .mem_dq
	inout  wire         memory_mem_dqs,                   //                          .mem_dqs
	inout  wire         memory_mem_dqs_n,                 //                          .mem_dqs_n
	output wire         memory_mem_odt,                   //                          .mem_odt
	output wire         memory_mem_dm,                    //                          .mem_dm
	input  wire         memory_oct_rzqin,                 //                          .oct_rzqin
	output wire [7:0]   pio_0_external_connection_export, // pio_0_external_connection.export
	input  wire [7:0]   switches_external_connection_export, // pio_1_external_connection.export
	input  wire [7:0]   buttons_external_connection_export, // pio_2_external_connection.export
	input  wire         pll_0_reset_reset,
	output wire         sys_sdram_pll_0_sdram_clk_clk,
	input  wire         reset_reset_n /*verilator public*/,//                     reset.reset_n
	output wire [12:0]  vram_wire_addr,                   //                 vram_wire.addr
	output wire [1:0]   vram_wire_ba,                     //                          .ba
	output wire         vram_wire_cas_n,                  //                          .cas_n
	output wire         vram_wire_cke,                    //                          .cke
	output wire         vram_wire_cs_n,                   //                          .cs_n
	inout  wire [15:0]  vram_wire_dq,                     //                          .dq
	output wire [1:0]   vram_wire_dqm,                    //                          .dqm
	output wire         vram_wire_ras_n,                  //                          .ras_n
	output wire         vram_wire_we_n,                   //                          .we_n
	output wire         vga_dac_CLK,                      //                   vga_dac.CLK
	output wire         vga_dac_HS,                       //                          .HS
	output wire         vga_dac_VS,                       //                          .VS
	output wire         vga_dac_BLANK,                    //                          .BLANK
	output wire         vga_dac_SYNC,                     //                          .SYNC
	output wire [7:0]   vga_dac_R,                        //                          .R
	output wire [7:0]   vga_dac_G,                        //                          .G
	output wire [7:0]   vga_dac_B                        //                          .B
);

	//! TODO: eliminar este bloque
	logic[31:0] avl_address /*verilator public*/;
	logic       avl_read /*verilator public*/;
	logic       avl_write /*verilator public*/;
	logic[31:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_writedata /*verilator public*/;
	logic       avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[3:0]  avl_byteenable /*verilator public*/;

	logic avl_irq /*verilator public_flat_rw @(negedge clk_clk)*/;

	logic[31:0] avl_data_address /*verilator public*/;
	logic       avl_data_read /*verilator public*/;
	logic       avl_data_write /*verilator public*/;
	logic[31:0] avl_data_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_data_writedata /*verilator public*/;
	logic       avl_data_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[3:0]  avl_data_byteenable /*verilator public*/;

	logic[31:0]  avl_insn_address /*verilator public*/;
	logic        avl_insn_read /*verilator public*/;
	logic[127:0] avl_insn_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic        avl_insn_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;

	bus_master master_0
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		
		.cpu_clk(master_0_core_cpu_clk),
		.cpu_rst_n(master_0_core_cpu_rst_n),
		.irq(master_0_core_irq),
		
		.data_addr(master_0_core_data_addr),
		.data_data_rd(master_0_core_data_data_rd),
		.data_data_wr(master_0_core_data_data_wr),
		.data_ready(master_0_core_data_ready),
		.data_write(master_0_core_data_write),
		.data_start(master_0_core_data_start),
		.data_data_be(master_0_core_data_data_be),
		.insn_addr(master_0_core_insn_addr),
		.insn_data_rd(master_0_core_insn_data_rd),
		.insn_ready(master_0_core_insn_ready),
		.insn_start(master_0_core_insn_start),

		.*
	);

	vga_domain vga
	(
		.*
	);

endmodule
