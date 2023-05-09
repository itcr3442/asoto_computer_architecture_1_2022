import sys

def reg(num, *, address=False):
    expr = f'r{num & 0xf}'
    if address:
        expr = f'[{expr}]'

    return expr

loc = 0
while half := sys.stdin.buffer.read(2):
    insn = int.from_bytes(half, 'little')

    add, comment = None, ''

    if not (insn & 0x00f0):
        op = 'bal'

        add = (insn >> 4) | (insn & 0xf)
        if add & 0x800:
            add -= 1 << 12

        add <<= 1
        args = [add]
    elif (insn & 0xf0ff) == 0x0080:
        op = 'ext'
        args = [insn >> 8]
    elif (insn & 0x0fff) == 0x0080:
        op = 'ext'
        args = [(insn >> 12) + 16]
    elif (insn & 0x00ff) == 0x0080:
        op = 'mul'
        args = [reg(insn >> 8), reg(insn >> 12)]
    elif (insn & 0xf0ff) == 0x0040:
        op = 'bin'
        args = [reg(insn >> 8)]
    elif (insn & 0xf0ff) == 0x00c0:
        op = 'sys'
        args = [insn >> 8]
    elif (insn & 0x007f) == 0x0040:
        op = 'imm'

        imm = (insn >> 7) & 0x1f
        if imm & 0x10:
            imm += 1 << 5

        args = [reg(insn >> 12), imm]
    elif not (insn & 0x000f):
        match (insn >> 4) & 0b11:
            case 0b01:
                op = 'blt'
            case 0b10:
                op = 'beq'
            case 0b11:
                op = 'bne'

        add = (insn >> 6) & 0x7f
        if add & 0x40:
            add -= 1 << 7

        add <<= 1
        ra = (insn >> 13) << 1
        args = [reg(ra), reg(ra + 1), add]
    elif (insn & 0x0030) == 0x0030:
        op = 'adr'

        add = (insn >> 6) & 0x3ff
        if add & 0x200:
            add -= 1 << 10

        add <<= 1
        args = [reg(insn), add]
    elif not (insn & 0x0010):
        match (insn >> 5) & 0b111:
            case 0b001:
                op = 'and'
            case 0b010:
                op = 'orr'
            case 0b011:
                op = 'xor'
            case 0b100:
                op = 'shl'
            case 0b101:
                op = 'shr'
            case 0b110:
                op = 'add'
            case 0b111:
                op = 'sub'

        args = [reg(insn), reg(insn >> 12), reg(insn >> 8)]
    elif (insn & 0xf830) == 0x0010:
        load = bool(insn & 0x0040)
        op = 'ldw' if load else 'stw'
        args = [reg(insn, address=not load), reg(insn >> 7, address=load)]
    elif (insn & 0x07b0) == 0x0010:
        op = 'dec' if insn & 0x0040 else 'inc'
        args = [reg(insn), insn >> 11]
    else:
        assert (insn & 0x0030) == 0x0010
        op = 'sri' if insn & 0x0040 else 'sli'
        args = [reg(insn), reg(insn >> 7), insn >> 11]

    if add is not None:
        comment = f'{hex(loc + 2 + add)}'

    if comment:
        comment = f'  ! {comment}'

    print(f'{loc:08x}:\t{insn:04x}\t{op} {", ".join(str(arg) for arg in args)}{comment}')
    loc += 2
