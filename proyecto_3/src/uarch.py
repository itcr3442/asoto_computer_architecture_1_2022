from enum import Enum
import stub

def gen_search_str(mnemonic, op_kinds):
    return f"{mnemonic}, {op_kinds}"

class cpu:
    def __init__(self):
        self.master = stub.rsp()
        self.cycles = 0

        self.alus = 2
        self.branches = 2
        self.stacks = 2
        self.noops = 2
        self.specials = 2

        self.insns = {
            "sub r,r/i"     : ("alu", 1),
            "sub r,m"       : ("alu", 1),
            "sub m,r/i "    : ("alu", 7),
            "mov r,i"       : ("alu", 1),
            "mov r,i"       : ("alu", 2),
            "mov r8/16,m"   : ("alu", 2),
            "mov r32/64,m"  : ("alu", 3),
            "mov m,r"       : ("alu", 2),
            "mov m,i"       : ("alu", 2),
            "test r,r/i"    : ("alu", 1),
            "test m,r/i"    : ("alu", 1),
            "add"    : ("alu", 1), #Mismas que sub
            "ret"           : ("alu", 3),
            "ret i"         : ("alu", 3),
            "xor r,r/i"     : ("alu", 1),
            "xor r,m"       : ("alu", 7),
            "xor m,r/i "    : ("alu", 7),
            "and"    : ("alu", 1), #Mismas que xor
            "lea r16,m"     : ("alu", 2),
            "lea r32/64,m"  : ("alu", 1),
            "cmp r,r/i"     : ("alu", 1),
            "cmp m,r/i"     : ("alu", 1),
            "shr r,i"       : ("alu", 1),
            "shr m,i"       : ("alu", 1),
            "shr r,cl"      : ("alu", 1),
            "shr m,cl"      : ("alu", 1),
            "sar"    : ("alu", 1), #Mismas que shr
            "cmpb"   : ("alu", 1), #?
            "cmpq"   : ("alu", 1), #?
            "movb"   : ("alu", 1), #?
            "movl"   : ("alu", 1), #?
            "pxor"   : ("alu", 1), #?
            "movaps" : ("alu", 1), #?
            "imul r,r"      : ("alu", 3),
            "imul r16,r16,i": ("alu", 4),
            "imul r32,r32,i": ("alu", 3),
            "imul r64,r64,i": ("alu", 3),
            "je"            : ("branch", 3),
            "call near"     : ("branch", 2),
            "call r"        : ("branch", 3),
            "call m"        : ("branch", 4),
            "jmp near"      : ("branch", 3),
            "jmp r"         : ("branch", 3),
            "jmp m"         : ("branch", 3),
            "jne"           : ("branch", 3),
            "push r"        : ("stack", 3),
            "push i"        : ("stack", 3),
            "push m"        : ("stack", 3),
            "push sp"       : ("stack", 3),
            "pop r"         : ("stack", 3),
            "pop sp"        : ("stack", 3),
            "pop m"         : ("stack", 3),
            "leav"   : ("stack", 2),    #?
            "nopl"   : ("noop", 1),     #?
            "cs nopw": ("noop", 1),     #?
            "nopw"   : ("noop", 1),     #?
            "hl"     : ("special", 1),  #?
            "data16" : ("special", 1),  #?
        }
