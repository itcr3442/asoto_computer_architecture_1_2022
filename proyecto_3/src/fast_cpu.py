import uarch

cpu = uarch.Cpu()

try:
    while True:
        rip, insn = cpu.master.get_insn()
        key = uarch.gen_search_str(*cpu.master.get_insn_info(insn))

        # solo imprimir nuestro programa
        if (0x0000000000401080 <= rip < 0x00000000004011a0) or (0x0000000000401290 <= rip < 0x0000000000401d64):
            print(f"0x{rip:016x}: {insn}")

        try:
            unit, latency = cpu.insns[key]
            if cpu.units.lock(unit):
                cpu.cycles += latency
            else:
                cpu.wait_for(unit)
        except KeyError:
            print(f"Invalid instruction: {insn}")
            break

        if not cpu.master.s():
            break

finally:
    cpu.master.close()
    print("CPU without dynamic scheduler done.")
    print(f"Execution took: {cpu.cycles} cycles.")
