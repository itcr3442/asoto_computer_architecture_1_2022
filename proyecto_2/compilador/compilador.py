import sys
import string

LABEL_CHARSET = string.ascii_letters

class Ins:
    def __init__(self, *args, name, line, addr):
        self.name = name
        self.line = line
        self.addr = addr
        self.args = iter(args)

    def length(self):
        return 1

    def stop(self):
        try:
            next(self.args)
        except StopIteration:
            pass
        else:
            self.error(f"Too many arguments")

    def next(self):
        try:
            return next(self.args)
        except StopIteration:
            self.error(f"Missing arguments")

    def error(self, msg):
        fail(self.line, f"{self.name}: {msg}")
        
    def parse_addr(self, *, zero=True):
        arg = self.next()

        if len(arg) < 2 or arg[0] != '[' or arg[-1] != ']':
            self.error(f"Invalid syntax: bad addressing mode: {repr(arg)}")

        return self.parse_reg(arg=arg[1:-1], zero=zero)

    def parse_imm(self, *, zero=True):
        arg = self.next()
        try:
            imm = int(arg, 0)
            
        except ValueError:
            self.error(f"Invalid immediate value: {repr(arg)}")

        if not zero and not imm:
            self.error("Immediate value must not be 0.")

        return imm

    def parse_reg(self, *, zero=True, arg=None):
        if not arg:
            arg = self.next()

        arg = arg.lower()

        try:
            if not arg or arg[0] != "r":
                raise ValueError()

            reg = int(arg[1:], 10)
            
            if not (0 <= reg <= 15):
                raise ValueError()
            
        except ValueError:
            self.error(f"Invalid register: {repr(arg)}")

        if not zero and not reg:
            self.error("Register must not be r0.")

        return reg

    def parse_target(self):
        arg = self.next()

        if not arg or any(c not in LABEL_CHARSET for c in arg):
            self.error(f"Invalid label: {repr(arg)}")
        
        return arg

    def encode_reg(self, reg):
        return self.encode_unsigned(reg, 4)

    def encode_rel(self, labels, label, size):
        addr = labels.get(label)

        if addr is None:
            self.error(f"Undefined reference to {repr(label)}")

        return self.encode_signed(addr - self.addr - 1, size, tag="Jump")

    def encode_signed(self, val, size, *, tag="Value"):
        lo, hi = -(1 << (size-1)), (1 << (size-1)) - 1
        if not (lo <= val <= hi):
            self.error(f"{tag} out of range [{lo}, {hi}]: {val}")

        elif val < 0:
            val += 1 << size

        return self.encode_unsigned(val, size)

    def encode_unsigned(self, val, size):
        hi = (1 << size) - 1
        if not (0 <= val <= hi):
            self.error(f"Value out of range [0, {hi}]: {val}")

        return bin(val)[2:].zfill(size)

class Icond_rel_j(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.target = self.parse_target()
    
    def encode(self, labels):
        j = self.encode_rel(labels, self.target, 12)
        return (j[:8], "0000", j[8:])

class Ext_space(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.imm5 = self.parse_imm()

    def encode(self, labels):
        if self.imm5 < 32:
            i = self.encode_unsigned(self.imm5, 4)
            return ("0000", i, "10000000")
        else:
            i = self.encode_unsigned(self.imm5 - 31, 4)
            return (i, "000010000000")

class Mul(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rz = self.parse_reg(zero=False)
        self.ra = self.parse_reg(zero=False)

    def encode(self, labels):
        a = self.encode_reg(self.ra)
        z = self.encode_reg(self.rz)
        return (a, z, "10000000")

class Icond_ind_j(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.ra = self.parse_reg()

    def encode(self, labels):
        a = self.encode_reg(self.ra)
        return ("0000", a, "01000000")

class Cont_space(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.imm4 = self.parse_imm()

    def encode(self, labels):
        i = self.encode_unsigned(self.imm4, 4)
        return ("0000", i, "11000000")

class Load_imm(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rd = self.parse_reg(zero=False)
        self.imm = self.parse_imm()

    def length(self):
        return 1 if -16 <= self.imm <= 15 else 2

    def imm_pool(self, pool):
        if self.length() == 2:
            self.imm_label = pool(self.imm)

    def encode(self, labels):

        d = self.encode_reg(self.rd)

        match self.length():
            case 1:
                i = self.encode_signed(self.imm, 5)
                return (d, i, "1000000")
            case 2:
                j = self.encode_rel(labels, self.imm_label, 10)
                return [(j, "11", d), ("00000", d, "101", d)]


class Cond_j(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.ra = self.parse_reg()
        self.rb = self.parse_reg()
        self.target = self.parse_target()
        match self.name:
            case 'beq':
                self.c = '10'
            case 'bne':
                self.c = '11'
            case 'blt':
                self.c = '01'

        if (self.ra & 1) or self.rb != (self.ra + 1):
            self.error(f'Not a valid reg-pair: r{self.ra}, r{self.rb}')

    def encode(self, labels):
        p = self.encode_unsigned(self.ra >> 1, 3)
        j = self.encode_rel(labels, self.target, 7)
        c = self.c
        return (p, j, c, "0000")

class Rel_addr(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rd = self.parse_reg(zero=False)
        self.target = self.parse_target()

    def encode(self, labels):
        j = self.encode_rel(labels, self.target, 10)
        d = self.encode_reg(self.rd)
        return (j, "11", d)

class Alu_reg_reg(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rd = self.parse_reg(zero=False)
        self.ra = self.parse_reg()
        self.rb = self.parse_reg()
        match self.name:
            case 'and':
                self.o = '001'
            case 'orr':
                self.o = '010'
            case 'xor':
                self.o = '011'
            case 'shl':
                self.o = '100'
            case 'shr':
                self.o = '101'
            case 'add':
                self.o = '110'
            case 'sub':
                self.o = '111'

    def encode(self, labels):
        a = self.encode_reg(self.ra)
        b = self.encode_reg(self.rb)
        o = self.o
        d = self.encode_reg(self.rd)
        return (a, b, o, "0", d)

class Ls(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        match self.name:
            case 'ldw':
                self.l = "1"
                self.rd = self.parse_reg(zero=False)
                self.ra = self.parse_addr()
            case 'stw':
                self.l = "0"
                self.rd = self.parse_addr(zero=False)
                self.ra = self.parse_reg()

    def encode(self, labels):
        a = self.encode_reg(self.ra)
        l = self.l
        d = self.encode_reg(self.rd)
        return ("00000", a, l, "01", d)

class Alu_reg_inc_dec_imm5(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rz = self.parse_reg(zero=False)
        self.imm5 = self.parse_imm(zero=False)
        match self.name:
            case 'inc':
                self.s = '0'
            case 'dec':
                self.s = '1'

    def encode(self, labels):
        i = self.encode_unsigned(self.imm5, 5)
        s = self.s
        z = self.encode_reg(self.rz)
        return (i, "0000", s, "01", z)

class Alu_reg_imm5(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.rd = self.parse_reg(zero=False)
        self.ra = self.parse_reg(zero=False)
        self.imm5 = self.parse_imm(zero=False)
        match self.name:
            case 'sli':
                self.s = '0'
            case 'sri':
                self.s = '1'
        
    def encode(self, labels):
        i = self.encode_unsigned(self.imm5, 5)
        a = self.encode_reg(self.ra)
        s = self.s
        d = self.encode_reg(self.rd)
        return (i, a, s, "01", d)

ISA = {
    "bal":Icond_rel_j,
    "ext":Ext_space,
    "mul":Mul,
    "bin":Icond_ind_j,
    "sys":Cont_space,
    "imm":Load_imm,
    "beq":Cond_j,
    "bne":Cond_j,
    "blt":Cond_j,
    "adr":Rel_addr,
    "and":Alu_reg_reg,
    "orr":Alu_reg_reg,
    "xor":Alu_reg_reg,
    "ldw":Ls,
    "stw":Ls,
    "shl":Alu_reg_reg,
    "shr":Alu_reg_reg,
    "sli":Alu_reg_imm5,
    "sri":Alu_reg_imm5,
    "add":Alu_reg_reg,
    "sub":Alu_reg_reg,
    "inc":Alu_reg_inc_dec_imm5,
    "dec":Alu_reg_inc_dec_imm5
}

def fail(line, msg):
    print("At line ", line, ": ", msg, sep="", file=sys.stderr)
    sys.exit(1)

def compile(file):
    pc = 0
    insns = []
    labels = {}

    with open(file, 'r') as src:
        for lineno, line in enumerate(src, start=1):
            ## comments
            if(i := line.find("!")) != -1:
                line = line[:i]

            line = line.strip()

            if len(line) > 1 and line[-1] == ":":
                label = line[:-1]
            
                if any(c not in LABEL_CHARSET for c in label):
                    fail(lineno, f"Invalid label: {repr(label)}")
                elif label in labels:
                    fail(lineno, f"Label already in use: {repr(label)}")

                labels[label] = pc

                continue

            line = line.split(maxsplit=1)
            
            ## empty lines
            if not line:
                continue

            args = (arg.strip() for arg in line[1].split(",")) if len(line) > 1 else ()
            name = line[0].lower()

            ctor = ISA.get(name)

            if not ctor:
                fail(lineno, f"Unknown instruction: {repr(name)}")

            insn = ctor(*args, name=name, line=lineno, addr=pc)
            insn.stop()
            pc += insn.length()

            insns.append(insn)

    output = bytearray()

    for insn in insns:
        encs = insn.encode(labels)
        
        if type(encs) is not list:
            encs = [encs]
    
        assert len(encs) == insn.length()

        for enc in encs:
            enc = "".join(enc)
            assert len(enc) == 16 and all(c in ("0", "1") for c in enc)

            output.extend(int(enc, 2).to_bytes(2, "little"))

    return output

def main():
    sys.stdout.buffer.write(compile(sys.argv[1]))

if __name__ == "__main__":
    main()