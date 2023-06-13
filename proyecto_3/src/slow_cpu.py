import uarch

cpu = uarch.Cpu()

cycles = 0
retired = 0

try:
    while True:
        rip = cpu.master.rip()
        insn = cpu.master.get_insn(rip)
        key = uarch.gen_search_str(*cpu.master.get_insn_info(insn))

        # solo imprimir nuestro programa
        if (0x0000000000401080 <= rip < 0x00000000004011a0) or (0x0000000000401290 <= rip < 0x0000000000401d64):
            print(f"0x{rip:016x}: {insn}")

        if info := cpu.insns.get(key):
            _, latency = info
            cycles += latency
        else:
            cycles += 1

        retired += 1
        if not cpu.master.s():
            break
finally:
    cpu.master.close()
    print("CPU without dynamic scheduler done.")
    print(f"Executed {retired} insns in {cycles} cycles.")
