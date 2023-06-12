import stub

cpu = stub.rsp()
timer = 0

try:
    while True:
        rip, insn = cpu.get_insn()
        print(f"0x{rip:016x}: {insn}")
        cpu.s()
finally:
    cpu.close()