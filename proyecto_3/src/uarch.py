from enum import Enum
import stub

def gen_search_str(mnemonic, op_types, op_kinds):
    return f"{mnemonic}, {op_types}, {op_kinds}"

class Functional_Units:
    def __init__(self, alus=2, branches=2, loads=2, stores=2) :
        self.alus = alus
        self.branches = branches
        self.loads = loads
        self.stores = stores

    def lock_unit(self, unit):
        match unit:
            case "alu":
                if self.alus < 0:
                    return False
                else:
                    self.alus -= 1
                    return True

            case "banch":
                if self.branches < 0:
                    return False
                else:
                    self.branches -= 1
                    return True

            case "load":
                if self.loads < 0:
                    return False
                else:
                    self.loads -= 1
                    return True

            case "store":
                if self.stores < 0:
                    return False
                else:
                    self.stores -= 1
                    return True

            case _:
                raise ValueError(f"No funcional unit: {unit}")

class Cpu:
    def __init__(self):
        self.master = stub.rsp()
        self.cycles = 0

        self.units = Functional_Units()

        self.insns = {
            "MOV, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 3),
            "CALL, ['BR64_4']"                     : ("alu", 3),
            "ENDBR64, []"                          : ("alu", 1), #?
            "PUSH, ['R64_OPCODE']"                 : ("store", 3),
            "SUB, ['R64_OR_MEM', 'IMM8SEX64']"     : ("alu", 7),
            "RDTSC, []"                            : ("alu", 1), #?
            "LEA, ['R64_REG', 'MEM']"              : ("alu", 1),
            "AND, ['R8_OR_MEM', 'IMM8']"           : ("alu", 7),
            "SHL, ['R64_OR_MEM', 'IMM8']"          : ("alu", 1),
            "OR, ['R64_OR_MEM', 'R64_REG']"        : ("alu", 7),
            "MOV, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 3),
            "TEST, ['R64_OR_MEM', 'R64_REG']"      : ("alu", 1),
            "JE, ['BR64_4']"                       : ("branch", 3),
            "MOV, ['R32_OPCODE', 'IMM32']"         : ("alu", 1),
            "JMP, ['BR64_1']"                      : ("alu", 3),
            "CMP, ['R64_OR_MEM', 'IMM8SEX64']"     : ("alu", 1),
            "JBE, ['BR64_1']"                      : ("alu", 1), #?
            "ADD, ['R64_OR_MEM', 'IMM8SEX64']"     : ("alu", 7),
            "JE, ['BR64_1']"                       : ("branch", 3),
            "SUB, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 7),
            "LEA, ['R32_REG', 'MEM']"              : ("alu", 1),
            "SAR, ['R32_OR_MEM', 'IMM8_CONST_1']"  : ("alu", 1),
            "CMP, ['R32_OR_MEM', 'IMM8SEX32']"     : ("alu", 1),
            "JA, ['BR64_4']"                       : ("branch", 3),
            "JMP, ['BR64_4']"                      : ("branch", 3),
            "MOVZX, ['R32_REG', 'R8_OR_MEM']"      : ("load", 3),
            "MOV, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 2),
            "AND, ['R32_OR_MEM', 'IMM8SEX32']"     : ("alu", 7),
            "JNE, ['BR64_4']"                      : ("branch", 3),
            "ADD, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 1),
            "TEST, ['R64_OR_MEM', 'IMM32SEX64']"   : ("alu", 1),
            "PXOR, ['XMM_REG', 'XMM_OR_MEM']"      : ("alu", 1),
            "MOVAPS, ['XMM_OR_MEM', 'XMM_REG']"    : ("store", 3),
            "TEST, ['R8_OR_MEM', 'R8_REG']"        : ("alu", 1),
            "CMOVNE, ['R64_REG', 'R64_OR_MEM']"    : ("alu", 1), #?
            "CMP, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 1),
            "JAE, ['BR64_1']"                      : ("branch", 3),
            "JA, ['BR64_1']"                       : ("branch", 3),
            "JBE, ['BR64_4']"                      : ("branch", 3), 
            "NOP, ['R32_OR_MEM']"                  : ("alu", 1), #?
            "SHR, ['R64_OR_MEM', 'IMM8']"          : ("alu", 1),
            "XOR, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 7),
            "MOVZX, ['R32_REG', 'R16_OR_MEM']"     : ("load", 3),
            "CMP, ['R16_OR_MEM', 'IMM8SEX16']"     : ("alu", 1),
            "ADD, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 1),
            "CMP, ['AL', 'IMM8']"                  : ("alu", 1),
            "MOVSXD, ['R64_REG', 'R32_OR_MEM']"    : ("load", 3),
            "JMP, ['R64_OR_MEM']"                  : ("alu", 1),
            "CMP, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 1),
            "OR, ['R8_OR_MEM', 'IMM8']"            : ("alu", 7),
            "RET, []"                              : ("alu", 3),
            "TEST, ['R8_OR_MEM', 'IMM8']"          : ("alu", 1),
            "JNE, ['BR64_1']"                      : ("branch", 3),
            "MOV, ['R32_REG', 'R32_OR_MEM']"       : ("alu", 1),
            "TEST, ['R32_OR_MEM', 'R32_REG']"      : ("alu", 1),
            "ADD, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 1),
            "SUB, ['R64_OR_MEM', 'IMM32SEX64']"    : ("alu", 7),
            "CDQE, []"                             : ("alu", 1),
            "STOSQ, ['ES_RDI', 'RAX']"             : ("alu", 1), #?
            "MOV, ['R64_OR_MEM', 'IMM32SEX64']"    : ("alu", 2),
            "NOP, []"                              : ("alu", 1), #?
            "MOV, ['R16_OR_MEM', 'R16_REG']"       : ("alu", 2),
            "ADD, ['R64_OR_MEM', 'IMM32SEX64']"    : ("alu", 7),
            "POP, ['R64_OPCODE']"                  : ("load", 3),
            "NOP, ['R16_OR_MEM']"                  : ("alu", 1), #?
            "CMP, ['R8_OR_MEM', 'IMM8']"           : ("alu", 1),
            "ADD, ['R32_OR_MEM', 'IMM8SEX32']"     : ("alu", 7),
            "CMP, ['R8_OR_MEM', 'R8_REG']"         : ("alu", 1),
            "SETNE, ['R8_OR_MEM']"                 : ("alu", 1), #?
            "SYSCALL, []"                          : ("alu", 1), #?
            "CPUID, []"                            : ("alu", 1), #?
            "MOV, ['R32_OR_MEM', 'IMM32']"         : ("alu", 2),
            "CMP, ['R32_OR_MEM', 'IMM32']"         : ("alu", 1),
            "SHR, ['R32_OR_MEM', 'IMM8']"          : ("alu", 1),
            "AND, ['R32_OR_MEM', 'IMM32']"         : ("alu", 7),
            "JLE, ['BR64_4']"                      : ("branch", 3),
            "JLE, ['BR64_1']"                      : ("branch", 3),
            "CMP, ['EAX', 'IMM32']"                : ("alu", 1),
            "AND, ['EAX', 'IMM32']"                : ("alu", 1),
            "OR, ['R32_REG', 'R32_OR_MEM']"        : ("alu", 1),
            "OR, ['R32_OR_MEM', 'R32_REG']"        : ("alu", 7),
            "TEST, ['R32_OR_MEM', 'IMM32']"        : ("alu", 1),
            "CMOVNE, ['R32_REG', 'R32_OR_MEM']"    : ("alu", 1),
            "XGETBV, []"                           : ("alu", 1),
            "OR, ['R32_OR_MEM', 'IMM32']"          : ("alu", 7),
            "OR, ['R32_OR_MEM', 'IMM8SEX32']"      : ("alu", 7),
            "TEST, ['AL', 'IMM8']"                 : ("alu", 1),
            "JG, ['BR64_1']"                       : ("branch", 3),
            "SUB, ['R32_OR_MEM', 'IMM32']"         : ("alu", 7),
            "SHL, ['R32_OR_MEM', 'IMM8']"          : ("alu", 1),
            "CMOVE, ['R64_REG', 'R64_OR_MEM']"     : ("alu", 1), #?
            "SHL, ['R32_OR_MEM', 'CL']"            : ("alu", 1),
            "CQO, []"                              : ("alu", 1),
            "IDIV, ['R64_OR_MEM']"                 : ("alu", 15),
            "CMOVNS, ['R64_REG', 'R64_OR_MEM']"    : ("alu", 1), #?
            "SAR, ['R64_OR_MEM', 'IMM8']"          : ("alu", 1),
            "SBB, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 7),
            "AND, ['R64_OR_MEM', 'IMM8SEX64']"     : ("alu", 1),
            "SBB, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 1),
            "ADD, ['R32_OR_MEM', 'IMM32']"         : ("alu", 7),
            "CMOVL, ['R32_REG', 'R32_OR_MEM']"     : ("alu", 1), #?
            "CMOVB, ['R64_REG', 'R64_OR_MEM']"     : ("alu", 1), #?
            "SETA, ['R8_OR_MEM']"                  : ("alu", 1), #?
            "MOV, ['R8_OR_MEM', 'IMM8']"           : ("alu", 2), 
            "MOV, ['R64_OPCODE', 'IMM64']"         : ("alu", 2),
            "TEST, ['EAX', 'IMM32']"               : ("alu", 1),
            "AND, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 7),
            "AND, ['R64_OR_MEM', 'IMM32SEX64']"    : ("alu", 7),
            "CMP, ['R64_OR_MEM', 'IMM32SEX64']"    : ("alu", 1),
            "MOVDQU, ['XMM_REG', 'XMM_OR_MEM']"    : ("alu", 1), #?
            "PCMPEQB, ['XMM_REG', 'XMM_OR_MEM']"   : ("alu", 1),
            "PMOVMSKB, ['R32_REG', 'XMM_RM']"      : ("alu", 2),
            "BSF, ['R32_REG', 'R32_OR_MEM']"       : ("alu", 3),
            "CALL, ['R64_OR_MEM']"                 : ("branch", 4),
            "IMUL, ['R64_REG', 'R64_OR_MEM']"      : ("alu", 3),
            "NEG, ['R64_OR_MEM']"                  : ("alu", 7),
            "JB, ['BR64_1']"                       : ("branch", 3),
            "JL, ['BR64_1']"                       : ("branch", 3),
            "MOV, ['R8_REG', 'R8_OR_MEM']"         : ("alu", 2),
            "MOV, ['R8_OR_MEM', 'R8_REG']"         : ("alu", 2),
            "SUB, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 1),
            "JAE, ['BR64_4']"                      : ("branch", 3),
            "SHR, ['R32_OR_MEM', 'IMM8_CONST_1']"  : ("alu", 1),
            "XOR, ['R32_OR_MEM', 'IMM8SEX32']"     : ("alu", 7),
            "CMP, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 1),
            "JB, ['BR64_4']"                       : ("branch", 3),
            "MOVLPD, ['XMM_REG', 'MEM']"           : ("alu", 1), #?
            "MOVHPD, ['XMM_REG', 'MEM']"           : ("alu", 1), #?
            "PSUBB, ['XMM_REG', 'XMM_OR_MEM']"     : ("alu", 1), #?
            "BSF, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 3),
            "SUB, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 7),
            "MOVSX, ['R32_REG', 'R8_OR_MEM']"      : ("load", 3),
            "SUB, ['R32_OR_MEM', 'IMM8SEX32']"     : ("alu", 7),
            "JS, ['BR64_4']"                       : ("branch", 3),
            "SETLE, ['R8_OR_MEM']"                 : ("alu", 1), #?
            "AND, ['R8_OR_MEM', 'R8_REG']"         : ("alu", 7),
            "AND, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 1),
            "MOVD, ['XMM_REG', 'R32_OR_MEM']"      : ("alu", 2),
            "PUNPCKLBW, ['XMM_REG', 'XMM_OR_MEM']" : ("alu", 1), #?
            "PUNPCKLWD, ['XMM_REG', 'XMM_OR_MEM']" : ("alu", 1),
            "JG, ['BR64_4']"                       : ("branch", 3),
            "MOVDQA, ['XMM_REG', 'XMM_OR_MEM']"    : ("store", 2),
            "POR, ['XMM_REG', 'XMM_OR_MEM']"       : ("alu", 1),
            "CMOVBE, ['R64_REG', 'R64_OR_MEM']"    : ("alu", 1), #?
            "BSWAP, ['R64_OPCODE']"                : ("alu", 2),
            "MOVUPS, ['XMM_OR_MEM', 'XMM_REG']"    : ("store", 3),
            "BT, ['R64_OR_MEM', 'R64_REG']"        : ("alu", 1),
            "SHL, ['R64_OR_MEM', 'CL']"            : ("alu", 1),
            "XOR, ['R64_OR_MEM', 'R64_REG']"       : ("alu", 7),
            "NEG, ['R32_OR_MEM']"                  : ("alu", 7),
            "CMOVA, ['R64_REG', 'R64_OR_MEM']"     : ("alu", 1), #?
            "MUL, ['R64_OR_MEM']"                  : ("alu", 3),
            "SAR, ['R64_OR_MEM', 'CL']"            : ("alu", 1),
            "PMINUB, ['XMM_REG', 'XMM_OR_MEM']"    : ("alu", 1), #?
            "MOVUPS, ['XMM_REG', 'XMM_OR_MEM']"    : ("store", 3),
            "SETE, ['R8_OR_MEM']"                  : ("alu", 1), #?
            "PAND, ['XMM_REG', 'XMM_OR_MEM']"      : ("alu", 1),
            "XOR, ['R64_REG', 'R64_OR_MEM']"       : ("alu", 1),
            "ROL, ['R64_OR_MEM', 'IMM8']"          : ("alu", 1),
            "RDSSPQ, ['R64_RM']"                   : ("alu", 1), #?
            "CMOVE, ['R32_REG', 'R32_OR_MEM']"     : ("alu", 1), #?
            "SHR, ['R8_OR_MEM', 'IMM8']"           : ("alu", 1),
            "SHR, ['R8_OR_MEM', 'IMM8_CONST_1']"   : ("alu", 1),
            "PUSH, ['IMM8SEX64']"                  : ("store", 3),
            "NOT, ['R64_OR_MEM']"                  : ("alu", 1),
            "CMP, ['R16_OR_MEM', 'R16_REG']"       : ("alu", 1),
            "TEST, ['RAX', 'IMM32SEX64']"          : ("alu", 1),
            "JS, ['BR64_1']"                       : ("branch", 3),
            "ADD, ['RAX', 'IMM32SEX64']"           : ("alu", 1),
            "SAR, ['R32_OR_MEM', 'CL']"            : ("alu", 1),
            "NOT, ['R32_OR_MEM']"                  : ("alu", 1),
            "CMPSB, ['SEG_RSI', 'ES_RDI']"         : ("alu", 1),
            "SBB, ['AL', 'IMM8']"                  : ("alu", 1),
            "CMP, ['RAX', 'IMM32SEX64']"           : ("alu", 1),
            "TEST, ['R16_OR_MEM', 'R16_REG']"      : ("alu", 1),
            "XCHG, ['R32_OPCODE', 'EAX']"          : ("alu", 2),
            "XCHG, ['R64_OR_MEM', 'R64_REG']"      : ("alu", 2),
            "PSLLDQ, ['XMM_RM', 'IMM8']"           : ("alu", 1),
            "SHR, ['R32_OR_MEM', 'CL']"            : ("alu", 1),
            "TEST, ['R16_OR_MEM', 'IMM16']"        : ("alu", 1),
            "CMP, ['R32_REG', 'R32_OR_MEM']"       : ("alu", 1),
            "CMOVB, ['R32_REG', 'R32_OR_MEM']"     : ("alu", 1), #?
            "PSRLDQ, ['XMM_RM', 'IMM8']"           : ("alu", 1),
            "AND, ['R16_OR_MEM', 'IMM16']"         : ("alu", 7),
            "CMOVAE, ['R32_REG', 'R32_OR_MEM']"    : ("alu", 1), #?
            "DIV, ['R64_OR_MEM']"                  : ("alu", 15),
            "XOR, ['R8_OR_MEM', 'R8_REG']"         : ("alu", 7),
            "AND, ['R32_OR_MEM', 'R32_REG']"       : ("alu", 7),
            "SETBE, ['R8_OR_MEM']"                 : ("alu", 1), #?
            "PUSH, ['R64_OR_MEM']"                 : ("store", 3),
            "AND, ['R32_REG', 'R32_OR_MEM']"       : ("alu", 1),
            "SHR, ['R64_OR_MEM', 'CL']"            : ("alu", 1),
            "SHR, ['R64_OR_MEM', 'IMM8_CONST_1']"  : ("alu", 1),
            "BT, ['R32_OR_MEM', 'R32_REG']"        : ("alu", 1),
            "SAR, ['R64_OR_MEM', 'IMM8_CONST_1']"  : ("alu", 1),
            "DIV, ['R32_OR_MEM']"                  : ("alu", 12),
            "VMOVDQU, ['YMM_REG', 'YMM_OR_MEM']"   : ("alu", 1), #?
            "VPMOVMSKB, ['R32_REG', 'YMM_RM']"     : ("alu", 1), #?
            "BLSMSK, ['R32_VVVV', 'R32_OR_MEM']"   : ("alu", 1),
            "VZEROUPPER, []"                       : ("alu", 1),
            "CMPXCHG, ['R32_OR_MEM', 'R32_REG']"   : ("alu", 1), #?
            "XCHG, ['R32_OR_MEM', 'R32_REG']"      : ("alu", 1), #?
            "IMUL, ['R32_REG', 'R32_OR_MEM']"      : ("alu", 3),
            "PUSH, ['IMM32SEX64']"                 : ("store", 3),
            "XSAVE, ['MEM']"                       : ("alu", 131),
            "XRSTOR, ['MEM']"                      : ("alu", 80),
            "VMOVD, ['XMM_REG', 'R32_OR_MEM']"     : ("alu", 1),
            "TZCNT, ['R32_REG', 'R32_OR_MEM']"     : ("alu", 3),
            "JGE, ['BR64_4']"                      : ("branch", 3),
            "CMOVS, ['R64_REG', 'R64_OR_MEM']"     : ("alu", 1), #?
            "SUB, ['EAX', 'IMM32']"                : ("alu", 1),
            "JNS, ['BR64_4']"                      : ("branch", 3),
            "ADD, ['EAX', 'IMM32']"                : ("alu", 1),
            "SETB, ['R8_OR_MEM']"                  : ("alu", 1),
            "JNS, ['BR64_1']"                      : ("branch", 3),
            "OR, ['R8_OR_MEM', 'R8_REG']"          : ("alu", 7),
            "OR, ['R64_OR_MEM', 'IMM8SEX64']"      : ("alu", 7),
            "LEAVE, []"                            : ("alu", 1), #?
            "ROR, ['R64_OR_MEM', 'IMM8']"          : ("alu", 1),
            "VPBROADCASTB, ['YMM_REG', 'XMM_OR_MEM']"         : ("alu", 1), #?
            "VPXOR, ['XMM_REG', 'XMM_VVVV', 'XMM_OR_MEM']"    : ("alu", 1), #?
            "VPCMPEQB, ['YMM_REG', 'YMM_VVVV', 'YMM_OR_MEM']" : ("alu", 1), #?
            "VPOR, ['YMM_REG', 'YMM_VVVV', 'YMM_OR_MEM']"     : ("alu", 1), #?
            "PSHUFD, ['XMM_REG', 'XMM_OR_MEM', 'IMM8']"       : ("alu", 1)
        }

    def attempt(self, unit, latency):
        if self.units.lock_unit(unit):
            self.cycles += latency
        else:
            pass
