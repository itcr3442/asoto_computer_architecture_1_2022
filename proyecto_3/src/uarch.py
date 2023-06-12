from enum import Enum

class cpu:
    def __init__(self):
        self.cycles = 0
        self.alus = 2
        self.branches = 2
        self.stacks = 2
        self.noops = 2
        self.specials = 2
        self.insns = {
            "sub"    : ("alu", 1),
            "mov"    : ("alu", 1),
            "test"   : ("alu", 1),
            "add"    : ("alu", 1),
            "re"     : ("alu", 1),
            "xor"    : ("alu", 1),
            "and"    : ("alu", 1),
            "lea"    : ("alu", 1),
            "cmp"    : ("alu", 1),
            "shr"    : ("alu", 1),
            "sar"    : ("alu", 1),
            "cmpb"   : ("alu", 1),
            "cmpq"   : ("alu", 1),
            "movb"   : ("alu", 1),
            "movl"   : ("alu", 1),
            "pxor"   : ("alu", 1),
            "movaps" : ("alu", 1),
            "imul"   : ("alu", 3),
            "je"     : ("branch", 3),
            "call"   : ("branch", 5),
            "jmp"    : ("branch", 3),
            "jne"    : ("branch", 3),
            "push"   : ("stack", 1),
            "pop"    : ("stack", 1),
            "leav"   : ("stack", 2),
            "nopl"   : ("noop", 1),
            "cs nopw": ("noop", 1),
            "nopw"   : ("noop", 1),
            "hl"     : ("special", 1),
            "data16" : ("special", 1),
        }
