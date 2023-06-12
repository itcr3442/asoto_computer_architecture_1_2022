import uarch

cpu = uarch.cpu()

try:
    while True:
        rip, insn = cpu.scheduler.get_insn()
        print(f"0x{rip:016x}: {insn}")
        
        try:
            unit, latency = cpu.insns[insn]
            return value
        except KeyError:
            print("Invalid instruction: {insn}")
            break
        
        cpu.s()
finally:
    cpu.close()
