import uarch
from iced_x86 import *

cpu = uarch.Cpu()

fetch = None
decode = None
issue = None
serialize = False
fetch_rip = None
cycles = 0
next_rename = 0
wr_regs = {}
units = set()
cbd = {}

def iced2gdb(reg):
    match reg:
        case Register.RAX:
            return 0
        case Register.RBX:
            return 1
        case Register.RCX:
            return 2
        case Register.RDX:
            return 3
        case Register.RSI:
            return 4
        case Register.RDI:
            return 5
        case Register.RBP:
            return 6
        case Register.RSP:
            return 7
        case Register.R8:
            return 8
        case Register.R9:
            return 9
        case Register.R10:
            return 10
        case Register.R11:
            return 11
        case Register.R12:
            return 12
        case Register.R13:
            return 13
        case Register.R14:
            return 14
        case Register.R15:
            return 15
        case "flags":
            return 17
        case Register.FS:
            return 22
        case Register.GS:
            return 23
        case _:
            assert False, f'bad iced_x86 reg {reg} during OoOE'

class ReservedUnit:
    def __init__(self, insn, latency, *, rd, wr):
        self.insn = insn
        self.latency = latency
        self.rd = rd
        self.wr = wr
        self.ops_ready = False
        self.wr_values = {}
        self.rd_values = {}
        self.commit = set(self.wr)
    
    def uncommit(self, reg):
        if reg in self.commit:
            self.commit.remove(reg)

    def tick(self, cdb):
        if not self.ops_ready:
            self.ops_ready = True
            for reg, renamed in self.rd.items():
                if reg in self.rd_values:
                    continue

                if renamed is not None:
                    value = cdb.get(renamed)
                else:
                    value = cpu.master.rr(iced2gdb(reg))

                if value is not None:
                    self.rd_values[reg] = value
                else:
                    self.ops_ready = False

            if self.ops_ready:
                print('Ready', self.insn)

        if self.ops_ready and self.latency:
            self.latency -= 1
            return True

        if not self.latency:
            print('Writeback', self.insn)

            saved = {
                reg: cpu.master.rr(iced2gdb(reg)) for reg in list(self.rd) + list(self.wr) 
            }

            for reg, value in self.rd_values.items():
                cpu.master.wr(iced2gdb(reg), value)

            cpu.master.s(self.insn.ip)
            
            self.wr_values = {
                reg: cpu.master.rr(iced2gdb(reg)) for reg in self.wr 
            }

            for reg, value in saved.items():
                cpu.master.wr(iced2gdb(reg), value)
        
        return bool(self.latency)

try:
    while True:
        print(f'Start {cycles}')

        to_remove = set()
        to_commit = {}
        next_cbd = {}

        for unit in units:
            if not unit.tick(cbd):
                to_remove.add(unit)
                
                for reg, value in unit.wr_values.items():
                    next_cbd[unit.wr[reg]] = value

                    if reg in unit.commit:
                        to_commit[reg] = value

        for reg, value in to_commit.items():
            cpu.master.wr(iced2gdb(reg), value)
            wr_regs[reg] = None

        next_serialize = serialize
        if serialize and not units:
            print('Serial', issue)
            if not cpu.master.s(issue.ip):
                break

            issue = None
            next_serialize = False

        cbd = next_cbd
        units.difference_update(to_remove)
        
        stall_issue = serialize

        if issue and not serialize:
            key = uarch.gen_search_str(*cpu.master.get_insn_info(issue))
            info = cpu.insns.get(key)

            if not info or issue.flow_control != FlowControl.NEXT:
                fetch = decode = None
                fetch_rip = None

                stall_issue = True
                next_serialize = True
            else:
                unit, latency = info
                stall_issue = cpu.units.lock(unit)
                if not stall_issue:
                    rd = {}
                    wr = {}
                    for reg in InstructionInfoFactory().info(issue).used_registers():
                        num = RegisterInfo(reg.register).full_register
                        match reg.access:
                            case OpAccess.READ:
                                is_rd = True
                                is_wr = False

                            case OpAccess.WRITE | OpAccess.COND_WRITE:
                                is_rd = False
                                is_wr = True

                            case OpAccess.READ_WRITE | OpAccess.COND_READ_COND_WRITE:
                                is_rd = True
                                is_wr = True

                            case _:
                                continue

                        if is_rd:
                            rd[num] = wr_regs.get(num)

                        if is_wr:
                            wr[num] = None

                    if issue.rflags_read:
                        rd["flags"] = wr_regs.get("flags")

                    if issue.rflags_written:
                        wr["flags"] = None
                    
                    for reg in wr:
                        wr[reg] = wr_regs[reg] = next_rename
                        next_rename = (next_rename + 1) & 0xffff
                    
                        for unit in units:
                            unit.uncommit(reg)

                    units.add(ReservedUnit(issue, latency, rd=rd, wr=wr))

        if not serialize and not stall_issue:
            issue = decode
        
        if not serialize and (not stall_issue or not decode):
            decode = fetch
        
        if not serialize and (not stall_issue or not fetch or not decode):
            if not fetch_rip:
                fetch_rip = cpu.master.rip()

            fetch = cpu.master.get_insn(fetch_rip)
            fetch_rip += fetch.len

            print(f'Fetch', fetch)

        serialize = next_serialize
        if next_serialize:
            fetch = decode = None
            fetch_rip = None

        cycles += 1
finally:
    cpu.master.close()
    print("CPU with dynamic scheduler done.")
    print(f"Execution took: {cycles} cycles.")
