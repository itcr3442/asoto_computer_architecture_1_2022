import sys

def reg(num, *, address=False):
    num = num & 0xf
    match num:
        case 0:
            expr = 'zero'
        case 14:
            expr = 'sp'
        case 15:
            expr = 'lr'
        case _:
            expr = f'r{num}'

    if address:
        expr = f'[{expr}]'

    return expr

def out_line(loc, insn, disas, comment=''):
    if comment:
        comment = f'! {comment}'

    print(f'{loc:08x}: \t{insn:04x} \t{disas:<20}{comment}')

loc = 0
buffer = sys.stdin.buffer.read()
pool_start = len(buffer)

next_comment = ''
while loc + 2 <= pool_start:
    insn = int.from_bytes(buffer[loc:loc + 2], 'little')

    add, comment, next_comment, args = None, next_comment, '', []

    if not (insn & 0x00f0):
        arg = (insn >> 4) | (insn & 0xf)
        if arg & 0x800:
            arg -= 1 << 12

        match arg:
            case -1:
                op = 'hlt'
                comment = 'bal .'

            case 0:
                op = 'nop'

            case _:
                op = 'bal'

                add = arg << 1
                args = [add]
    elif (insn & 0xf0ff) == 0x0080:
        op = 'ext'
        args = [insn >> 8]
    elif (insn & 0x0fff) == 0x0080:
        op = 'ext'
        args = [(insn >> 12) + 16]
    elif (insn & 0x00ff) == 0x0080:
        op = 'mul'
        rz = reg(insn >> 8)
        args = [rz, rz, reg(insn >> 12)]
    elif (insn & 0xf0ff) == 0x0040:
        rd = (insn >> 8) & 0xf
        match rd:
            case 0:
                op = 'rst'
                comment = 'bin zero'
            case 15:
                op = 'ret'
                comment = 'bin lr'
            case _:
                op = 'bin'
                args = [reg(rd)]
    elif (insn & 0xf0ff) == 0x00c0:
        op = 'sys'
        args = [insn >> 8]
    elif (insn & 0x007f) == 0x0040:
        op = 'imm'

        imm = (insn >> 7) & 0x1f
        if imm & 0x10:
            imm -= 1 << 5

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

        rd = insn & 0xf
        add <<= 1

        target = loc + 2 + add
        args = [reg(rd), add]

        if not (target & 0b11) and loc < target <= len(buffer) - 4 and loc + 4 <= pool_start:
            load_insn = rd << 7 | 0b101 << 4 | rd
            if int.from_bytes(buffer[loc + 2:loc + 4], 'little') == load_insn:
                comment = '...'
                next_comment = f'imm {reg(rd)}, {hex(int.from_bytes(buffer[target:target + 4], "little"))}'

                pool_start = min(pool_start, target)

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

        rd, ra, rb = insn & 0xf, (insn >> 12) & 0xf, (insn >> 8) & 0xf
        nrd, nra, nrb = reg(rd), reg(ra), reg(rb)

        mov, show_true = None, False
        true_op = op
        true_args = args = [nrd, nra, nrb]

        match op:
            case 'add' | 'orr' | 'xor':
                if not ra:
                    mov = rb
                elif not rb:
                    mov = ra

            case 'and':
                if not ra or not rb:
                    mov = 0

            case 'shl' | 'shl':
                if not rb:
                    mov = ra

            case 'sub':
                if not rb:
                    mov = ra
                elif not ra:
                    op = 'neg'
                    args = [nrd, nrb]
                    show_true = True

        if mov is not None:
            op = 'mov'
            args = [nrd, reg(mov)]
            show_true = True

        if show_true:
            comment = f'{true_op} {nrd}, {nra}, {nrb}'
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

    if add is not None and not comment:
        comment = f'{hex(loc + 2 + add)}'

    disas = op + ' ' + ', '.join(str(arg) for arg in args)
    out_line(loc, insn, disas, comment)

    loc += 2

while loc + 4 <= len(buffer):
    word = int.from_bytes(buffer[loc:loc + 4], 'little')
    out_line(loc, word & 0xffff, f'...')
    out_line(loc, word >> 16, f'word {hex(word)}')
    loc += 4
