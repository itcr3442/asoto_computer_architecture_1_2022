from enum import Enum
import stub

def gen_search_str(mnemonic, op_types, op_kinds):
    return f"{mnemonic}, {op_types}, {op_kinds}"

class Cpu:
    def __init__(self):
        self.master = stub.rsp()
        self.freq = 3.5e9

        self.cycles = 0
        self.power_total = 0

        self.units = {
            'alu': 4,
            'branch': 2,
            'load': 2,
            'store': 4,
            'mul': 3,
        }

        self.power_per = {
            'baseline': 3429,
            'fetch': 249,
            'decode': 1644,
            'issue': 548,
            'writeback': 274,

            'alu': 822,
            'branch': 2055,
            'load': 4110,
            'store': 4110,
            'mul': 8220,
        }

        self.insns = {
            "ADD, ['REGISTER', 'IMMEDIATE32TO64'], ['R64_OR_MEM', 'IMM32SEX64']" : ("alu", 1),
            "ADD, ['REGISTER', 'IMMEDIATE8TO32'], ['R32_OR_MEM', 'IMM8SEX32']"   : ("alu", 1),
            "ADD, ['REGISTER', 'IMMEDIATE8TO64'], ['R64_OR_MEM', 'IMM8SEX64']"   : ("alu", 1),
            "ADD, ['REGISTER', 'MEMORY'], ['R32_REG', 'R32_OR_MEM']"             : ("alu", 1),
            "ADD, ['REGISTER', 'MEMORY'], ['R64_REG', 'R64_OR_MEM']"             : ("alu", 1),
            "ADD, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1),
            "ADD, ['REGISTER', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"           : ("alu", 1),
            "ADD, ['MEMORY', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"             : ("alu", 7),
            "AND, ['REGISTER', 'IMMEDIATE32'], ['EAX', 'IMM32']"                 : ("alu", 1),
            "AND, ['REGISTER', 'IMMEDIATE8TO32'], ['R32_OR_MEM', 'IMM8SEX32']"   : ("alu", 1),
            "AND, ['REGISTER', 'IMMEDIATE8TO64'], ['R64_OR_MEM', 'IMM8SEX64']"   : ("alu", 1),
            "AND, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1),
            "BSWAP, ['REGISTER'], ['R64_OPCODE']"                                : ("alu", 2),
            "CALL, ['NEAR_BRANCH64'], ['BR64_4']"                                : ("branch", 3),
            "CMP, ['REGISTER', 'IMMEDIATE32TO64'], ['R64_OR_MEM', 'IMM32SEX64']" : ("alu", 1),
            "CMP, ['REGISTER', 'IMMEDIATE8TO32'], ['R32_OR_MEM', 'IMM8SEX32']"   : ("alu", 1),
            "CMP, ['REGISTER', 'IMMEDIATE8TO64'], ['R32_OR_MEM', 'IMM8SEX64']"   : ("alu", 1),
            "CMP, ['REGISTER', 'IMMEDIATE8'], ['AL', 'IMM8']"                    : ("alu", 1),
            "CMP, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1),
            "CMP, ['REGISTER', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"           : ("alu", 1),
            "CMP, ['REGISTER', 'IMMEDIATE8'], ['R8_OR_MEM', 'IMM8']"             : ("alu", 1),
            "CMP, ['MEMORY', 'IMMEDIATE8'], ['R8_OR_MEM', 'IMM8']"               : ("alu", 1),
            "CMP, ['MEMORY', 'IMMEDIATE8TO64'], ['R8_OR_MEM', 'IMM8SEX64']"      : ("alu", 1),
            "JAE, ['NEAR_BRANCH64'], ['BR64_1']"                                 : ("branch", 3),
            "JAE, ['NEAR_BRANCH64'], ['BR64_4']"                                 : ("branch", 3),
            "JA, ['NEAR_BRANCH64'], ['BR64_4']"                                  : ("branch", 3),
            "JA, ['NEAR_BRANCH64'], ['BR64_1']"                                  : ("branch", 3),
            "JB, ['NEAR_BRANCH64'], ['BR64_1']"                                  : ("branch", 3),
            "JB, ['NEAR_BRANCH64'], ['BR64_4']"                                  : ("branch", 3),
            "JE, ['NEAR_BRANCH64'], ['BR64_1']"                                  : ("branch", 3),
            "JE, ['NEAR_BRANCH64'], ['BR64_4']"                                  : ("branch", 3),
            "JMP, ['NEAR_BRANCH64'], ['BR64_4']"                                 : ("branch", 3),
            "JNE, ['NEAR_BRANCH64'], ['BR64_1']"                                 : ("branch", 3),
            "JNE, ['NEAR_BRANCH64'], ['BR64_4']"                                 : ("branch", 3),
            "LEA, ['REGISTER', 'MEMORY'], ['R32_REG', 'MEM']"                    : ("load", 1),
            "LEA, ['REGISTER', 'MEMORY'], ['R64_REG', 'MEM']"                    : ("load", 1),
            "MOV, ['MEMORY', 'IMMEDIATE32'], ['R32_OR_MEM', 'IMM32']"            : ("store", 2),
            "MOV, ['MEMORY', 'IMMEDIATE32TO64'], ['R64_OR_MEM', 'IMM32SEX64']"   : ("store", 2),
            "MOV, ['MEMORY', 'IMMEDIATE8'], ['R8_OR_MEM', 'IMM8']"               : ("store", 2),
            "MOV, ['MEMORY', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"             : ("store", 2),
            "MOV, ['MEMORY', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"             : ("store", 2),
            "MOV, ['MEMORY', 'REGISTER'], ['R8_OR_MEM', 'R8_REG']"               : ("store", 2),
            "MOV, ['REGISTER', 'IMMEDIATE32'], ['R32_OPCODE', 'IMM32']"          : ("alu", 1),
            "MOV, ['REGISTER', 'IMMEDIATE64'], ['R64_OPCODE', 'IMM64']"          : ("alu", 1),
            "MOV, ['REGISTER', 'MEMORY'], ['R32_REG', 'R32_OR_MEM']"             : ("load", 3),
            "MOV, ['REGISTER', 'MEMORY'], ['R64_REG', 'R64_OR_MEM']"             : ("load", 3),
            "MOV, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1),
            "MOV, ['REGISTER', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"           : ("alu", 1),
            "MOVZX, ['REGISTER', 'MEMORY'], ['R32_REG', 'R16_OR_MEM']"           : ("load", 3),
            "MOVZX, ['REGISTER', 'MEMORY'], ['R32_REG', 'R8_OR_MEM']"            : ("load", 3),
            "ENDBR64, [], []"                                                    : (None, 0),
            "NOP, [], []"                                                        : (None, 0),
            "NOP, ['MEMORY'], ['R32_OR_MEM']"                                    : (None, 0),
            "NOT, ['REGISTER'], ['R32_OR_MEM']"                                  : ("alu", 1),
            "OR, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"            : ("alu", 1),
            "POP, ['REGISTER'], ['R64_OPCODE']"                                  : ("load", 3),
            "PUSH, ['REGISTER'], ['R64_OPCODE']"                                 : ("store", 3),
            "RET, [], []"                                                        : ("branch", 3),
            "ROL, ['REGISTER', 'IMMEDIATE8'], ['R32_OR_MEM', 'IMM8']"            : ("alu", 1),
            "ROR, ['REGISTER', 'IMMEDIATE8'], ['R32_OR_MEM', 'IMM8']"            : ("alu", 1),
            "SHL, ['REGISTER', 'IMMEDIATE8'], ['R32_OR_MEM', 'IMM8']"            : ("alu", 1),
            "SHR, ['REGISTER', 'IMMEDIATE8'], ['R32_OR_MEM', 'IMM8']"            : ("alu", 1),
            "SUB, ['REGISTER', 'IMMEDIATE32TO64'], ['R64_OR_MEM', 'IMM32SEX64']" : ("alu", 1),
            "SUB, ['REGISTER', 'IMMEDIATE8TO64'], ['R64_OR_MEM', 'IMM8SEX64']"   : ("alu", 1),
            "SUB, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1),
            "SUB, ['REGISTER', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"           : ("alu", 1),
            "TEST, ['REGISTER', 'REGISTER'], ['R8_OR_MEM', 'R8_REG']"            : ("alu", 1),
            "TEST, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"          : ("alu", 1),
            "TEST, ['REGISTER', 'REGISTER'], ['R64_OR_MEM', 'R64_REG']"          : ("alu", 1),
            "TEST, ['REGISTER', 'IMMEDIATE'], ['AL', 'IMM8']"                    : ("alu", 1),
            "XOR, ['REGISTER', 'REGISTER'], ['R32_OR_MEM', 'R32_REG']"           : ("alu", 1)
        }


    def lock_unit(self, unit):
        if not self.units[unit]:
            return False

        self.units[unit] -= 1
        return True


    def unlock_unit(self, unit):
        self.units[unit] += 1


    def power(self, unit):
        self.power_total += self.power_per[unit]
