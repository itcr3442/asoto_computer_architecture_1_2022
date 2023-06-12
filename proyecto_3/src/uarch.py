from enum import Enum
import stub

class cpu:
    def __init__(self):
        scheduler = stub.rsp()
        cycles = 0
        alus = 2
        branches = 2
        stacks = 2
        noops = 2
        specials = 2
        insns = {
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
            "leav"   : ("stack", 2)
            "nopl"   : ("noop", 1),
            "cs nopw": ("noop", 1),
            "nopw"   : ("noop", 1),
            "hl"     : ("special", 1),
            "data16" : ("special", 1),
        }
