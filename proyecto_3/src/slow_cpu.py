import uarch
import stub

scheduler = stub.rsp()
cpu = uarch.cpu()

try:
    while True:
        rip, insn = scheduler.get_insn()
        print(f"0x{rip:016x}: {insn}")
        
        try:
            unit, latency = cpu.insns[insn]
        except KeyError:
            print(f"Invalid instruction: {insn}")
            break
        
        scheduler.s()
finally:
    scheduler.close()
