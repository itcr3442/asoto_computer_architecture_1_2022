#include <climits>
#include <csignal>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vconspiracion.h"
#include "Vconspiracion_arm810.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"
#include "Vconspiracion_vga_domain.h"
#include "Vconspiracion_core_dispatch.h"
#include "Vconspiracion_core_regs.h"

#include "../args.hxx"

#include "../avalon.hpp"
#include "../const.hpp"
#include "../mem.hpp"
#include "../jtag_uart.hpp"
#include "../interval_timer.hpp"
#include "../null.hpp"
#include "../window.hpp"
#include "../vga.hpp"

namespace
{
	volatile sig_atomic_t async_halt = 0;

	constexpr const char *gp_regs[] =
	{
		"r0",
		"r1",
		"r2",
		"r3",
		"r4",
		"r5",
		"r6",
		"r7",
		"r8",
		"r9",
		"r10",
		"r11",
		"r12",
		"r13",
		"r14",
		"r15",
	};

	struct mem_region
	{
		std::size_t start;
		std::size_t length;
	};

	struct reg_init
	{
		std::size_t   index;
		std::uint32_t value;
	};

	struct mem_init
	{
		std::uint32_t addr;
		std::uint32_t value;
	};

	struct file_load
	{
		std::uint32_t addr;
		std::string   filename;
	};

	std::istream &operator>>(std::istream &stream, mem_region &region)
	{
		stream >> region.start;
		if(stream.get() == ',')
		{
			stream >> region.length;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	std::istream &operator>>(std::istream &stream, mem_init &init)
	{
		stream >> init.addr;
		if(stream.get() == ',')
		{
			stream >> init.value;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	std::istream &operator>>(std::istream &stream, file_load &load)
	{
		stream >> load.addr;
		if(stream.get() == ',')
		{
			stream >> load.filename;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	std::istream &operator>>(std::istream &stream, reg_init &init)
	{
		char name[16];
		stream.getline(name, sizeof name, '=');

		std::size_t index = 0;
		constexpr auto total_gp_regs = sizeof gp_regs / sizeof gp_regs[0];

		while(index < total_gp_regs && std::strcmp(name, gp_regs[index]))
		{
			++index;
		}

		if(stream && !stream.eof() && index < total_gp_regs)
		{
			init.index = index;
			stream >> init.value;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	void async_halt_handler(int)
	{
		async_halt = 1;
	}
}

int main(int argc, char **argv)
{
	using namespace taller::avalon;
	using namespace taller::vga;

	Verilated::commandArgs(argc, argv);

	for(char **arg = argv; *arg; ++arg)
	{
		if(**arg == '+')
		{
			*arg = NULL;
			argc = arg - argv;
			break;
		}
	}

	args::ArgumentParser parser("Simulador proyecto final CE3201");

	args::ValueFlagList<reg_init> init_regs
	(
		parser, "reg=val", "Initialize a register", {"init-reg"}
	);

	args::Flag dump_regs
	(
		parser, "dump-regs", "Dump all registers", {"dump-regs"}
	);

	args::Flag headless
	(
		parser, "headless", "Disable video output", {"headless"}
	);

	args::Flag accurate_video
	(
		parser, "accurate-video", "Enable signal-level video emulation", {"accurate-video"}
	);

	args::Flag no_tty
	(
		parser, "no-tty", "Disable TTY takeover", {"no-tty"}
	);

	args::Flag start_halted
	(
		parser, "start-halted", "Halt before running the first instruction", {"start-halted"}
	);

	args::Flag cli_trace
	(
		parser, "trace", "Dump trace.vcd", {"trace"}
	);

	args::ValueFlag<unsigned> cycles
	(
		parser, "cycles", "Max number of core cycles to run", {"cycles"}, 0
	);

	args::ValueFlag<int> control_fd
	(
		parser, "fd", "Control file descriptor", {"control-fd"}, -1
	);

	args::ValueFlagList<mem_region> dump_mem
	(
		parser, "addr,length", "Dump a memory region", {"dump-mem"}
	);

	args::ValueFlagList<mem_init> const_
	(
		parser, "addr,value", "Add a constant mapping", {"const"}
	);

	args::ValueFlagList<file_load> loads
	(
		parser, "addr,filename", "Load a file", {"load"}
	);

	args::Positional<std::string> image
	(
		parser, "image", "Executable image to run", args::Options::Required
	);

	try
	{
		parser.ParseCLI(argc, argv);
	} catch(args::Help)
	{
		std::cout << parser;
		return EXIT_SUCCESS;
	} catch(args::ParseError e)
	{
		std::cerr << e.what() << std::endl;
		std::cerr << parser;
		return EXIT_FAILURE;
	} catch(args::ValidationError e)
	{
		std::cerr << e.what() << std::endl;
		std::cerr << parser;
		return EXIT_FAILURE;
	}

	FILE *ctrl = stdout;
	if(*control_fd != -1)
	{
		if((ctrl = fdopen(*control_fd, "r+")) == nullptr)
		{
			std::perror("fdopen()");
			return EXIT_FAILURE;
		}

		dup2(*control_fd, STDERR_FILENO);
	}

	Vconspiracion top;
	VerilatedVcdC trace;

	bool enable_trace = cli_trace;
	if(enable_trace)
	{
		Verilated::traceEverOn(true);
		top.trace(&trace, 0);
		trace.open("trace.vcd");
	}

	mem<std::uint32_t> hps_ddr3(0x0000'0000, 512 << 20);
	jtag_uart ttyJ0(0x3000'0000);
	interval_timer timer(0x3002'0000);
	interrupt_controller intc(0x3007'0000);

	auto &irq_lines = intc.lines();
	irq_lines.jtaguart = &ttyJ0;
	irq_lines.timer = &timer;

	mem<std::uint32_t> vram(0x3800'0000, 64 << 20);
	null vram_null(0x3800'0000, 64 << 20, 2);
	window vram_window(vram, 0x0000'0000);

	display<Vconspiracion_vga_domain> vga
	(
		*top.conspiracion->plat->vga,
		0x3800'0000, 25'175'000, 50'000'000
	);

	interconnect<Vconspiracion_platform> avl(*top.conspiracion->plat);
	interconnect<Vconspiracion_vga_domain> avl_vga(*top.conspiracion->plat->vga);

	std::vector<const_map> consts;
	for(const auto &init : *const_)
	{
		consts.emplace_back(init.addr, init.value);
	}

	bool enable_fast_video = !headless && !accurate_video;
	bool enable_accurate_video = !headless && accurate_video;

	avl.attach(hps_ddr3);
	avl.attach(timer);
	avl.attach(ttyJ0);
	avl.attach_intc(intc);

	for(auto &slave : consts)
	{
		avl.attach(slave);
	}

	if(enable_fast_video)
	{
		avl.attach(vga);
	} else if(enable_accurate_video)
	{
		avl.attach(vram);
		avl_vga.attach(vram_window);
	} else
	{
		avl.attach(vram_null);
	}

	FILE *img_file = std::fopen(image->c_str(), "rb");
	if(!img_file)
	{
		std::perror("fopen()");
		return EXIT_FAILURE;
	}

	hps_ddr3.load([&](std::uint32_t *buffer, std::size_t words)
	{
		return std::fread(buffer, 4, words, img_file);
	});

	std::fclose(img_file);

	for(const auto &load : *loads)
	{
		FILE *img_file = std::fopen(load.filename.c_str(), "rb");
		if(!img_file)
		{
			std::perror("fopen()");
			return EXIT_FAILURE;
		}

		hps_ddr3.load([&](std::uint32_t *buffer, std::size_t words)
		{
			return std::fread(buffer, 4, words, img_file);
		}, load.addr);

		std::fclose(img_file);
	}

	auto &core = *top.conspiracion->core;
	for(const auto &init : init_regs)
	{
		core.regs->file[init.index] = init.value;
	}

	int time = 0;
	top.clk_clk = 1;

	bool failed = false;

	auto tick = [&]()
	{
		top.clk_clk = !top.clk_clk;
		top.eval();

		if(!avl.tick(top.clk_clk))
		{
			failed = true;
		}

		if(enable_accurate_video)
		{
			if(!avl_vga.tick(top.clk_clk))
			{
				failed = true;
			}

			vga.signal_tick(top.clk_clk);
		}

		if(enable_trace)
		{
			trace.dump(time++);
		}
	};

	auto cycle = [&]()
	{
		tick();
		tick();
	};

	if(!no_tty)
	{
		ttyJ0.takeover();
	}

	top.halt = start_halted;
	top.rst_n = 0;
	cycle();
	top.rst_n = 1;

	auto do_reg_dump = [&]()
	{
		std::fputs("=== dump-regs ===\n", ctrl);

		const auto &regfile = core.regs->file;

		std::fprintf(ctrl, "%08x pc\n", core.dispatch->pc);

		int i = 0;
		for(const auto *name : gp_regs)
		{
			std::fprintf(ctrl, "%08x %s\n", regfile[i++], name);
		}

		std::fputs("=== end-regs ===\n", ctrl);
	};

	auto pagewalk = [&](std::uint32_t &addr)
	{
		// Ya no tenemos mmu;
		return true;
	};

	auto do_mem_dump = [&](const mem_region *dumps, std::size_t count)
	{
		std::fputs("=== dump-mem ===\n", ctrl);
		for(std::size_t i = 0; i < count; ++i)
		{
			const auto &dump = dumps[i];

			std::fprintf(ctrl, "%08x ", static_cast<std::uint32_t>(dump.start));
			for(std::size_t i = 0; i < dump.length; ++i)
			{
				std::uint32_t at = dump.start + i;
				if(!pagewalk(at))
				{
					break;
				}

				std::uint32_t word;
				if(!avl.dump(at, word))
				{
					break;
				}

				word = (word & 0xff) << 24
					 | ((word >> 8) & 0xff) << 16
					 | ((word >> 16) & 0xff) << 8
					 | ((word >> 24) & 0xff);

				std::fprintf(ctrl, "%08x", word);
			}

			std::fputc('\n', ctrl);
		}

		std::fputs("=== end-mem ===\n", ctrl);
	};

	std::signal(SIGUSR1, async_halt_handler);

	auto maybe_halt = [&]()
	{
		if(async_halt)
		{
			top.halt = 1;
		}

		return top.halt;
	};

	auto loop_fast = [&]()
	{
		do
		{
			for(unsigned iters = 0; iters < 1024; ++iters)
			{
				top.clk_clk = 0;
				top.eval();
				avl.tick_falling();

				top.clk_clk = 1;
				top.eval();

				// This is free most of the time
				try
				{
					avl.tick_rising();
				} catch(const avl_bus_error&)
				{
					failed = true;
					break;
				}
			}
		} while(!maybe_halt());
	};

	unsigned i = 0;
	auto loop_accurate = [&]()
	{
		do
		{
			cycle();
			maybe_halt();
		} while(!failed && !top.cpu_halted && (*cycles == 0 || ++i < *cycles));
	};

	const bool slow_path = *cycles > 0 || enable_accurate_video || enable_trace;

	while(true)
	{
		if(slow_path || top.halt)
		{
			loop_accurate();
		} else
		{
			loop_fast();
		}

		if(failed || (*cycles > 0 && i >= *cycles))
		{
			break;
		}
	}

	if(!no_tty)
	{
		ttyJ0.release();
	}

	if(enable_trace)
	{
		trace.close();
	}

	if(dump_regs)
	{
		do_reg_dump();
	}

	const auto &dumps = *dump_mem;
	if(!dumps.empty())
	{
		do_mem_dump(dumps.data(), dumps.size());
	}

	top.final();
	if(ctrl != stdout)
	{
		std::fclose(ctrl);
	}

	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
