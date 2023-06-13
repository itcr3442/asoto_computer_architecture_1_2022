import uarch

cpu = uarch.Cpu()

try:
    while True:
        rip, insn = cpu.master.get_insn()
        print(f"0x{rip:016x}: {insn}")

        key = uarch.gen_search_str(*cpu.master.get_insn_info(insn))

        try:
            unit, latency = cpu.insns[key]
            cpu.attempt(unit, latency)
        except KeyError:
            print(f"Invalid instruction: {insn}")
            break

        cpu.master.s()
finally:
    cpu.master.close()
    print("CPU without dynamic scheduler done.")
    print(f"Execution took: {cpu.cycles} cycles")
