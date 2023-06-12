import uarch

cpu = uarch.cpu()

try:
    while True:
        rip, insn = cpu.master.get_insn()
        print(f"0x{rip:016x}: {insn}")

        print(cpu.master.get_insn_opkinds(insn))

        #try:
        #    unit, latency = cpu.insns[insn.mnemonic]
        #    cpu.cycles += latency
#
        #except KeyError:
        #    print(f"Invalid instruction: {insn}")
        #    break

        cpu.master.s()
finally:
    print(cpu.cycles)
    cpu.master.close()
