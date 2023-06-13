import socket
from iced_x86 import *
from typing import Dict, Sequence
from types import ModuleType

def csum(data):
    return to_bhex(sum(data) & 0xff)


def to_nhex(num, size, little=True):
    return num.to_bytes(
        size, "little" if little else "big").hex().encode("ascii")


def to_bhex(num, little=True):
    return to_nhex(num, 1, little)


def to_qhex(num, little=True):
    return to_nhex(num, 8, little)


def parse_hex(data):
    return int.from_bytes((bytes.fromhex(str(data, "ascii"))), "little")

"""
Estos tres métodos de abajo fueron tomados de:
https://github.com/icedland/iced/blob/master/src/rust/iced-x86-py/README.md#get-instruction-info-eg-readwritten-regsmem-control-flow-info-etc
"""
def create_enum_dict(module: ModuleType) -> Dict[int, str]:
    return {module.__dict__[key]:key for key in module.__dict__ if isinstance(module.__dict__[key], int)}

MNEMONIC_TO_STRING: Dict[Mnemonic_, str] = create_enum_dict(Mnemonic)
def mnemonic_to_string(value: Mnemonic_) -> str:
    s = MNEMONIC_TO_STRING.get(value)
    if s is None:
        return str(value) + " /*Mnemonic enum*/"
    return s

OP_KIND_TO_STRING: Dict[OpKind_, str] = create_enum_dict(OpKind)
def op_kind_to_string(value: OpKind_) -> str:
    s = OP_KIND_TO_STRING.get(value)
    if s is None:
        return str(value) + " /*OpKind enum*/"
    return s

OP_CODE_OPERAND_KIND_TO_STRING: Dict[OpCodeOperandKind_, str] = create_enum_dict(OpCodeOperandKind)
def op_code_operand_kind_to_string(value: OpCodeOperandKind_) -> str:
    s = OP_CODE_OPERAND_KIND_TO_STRING.get(value)
    if s is None:
        return str(value) + " /*OpCodeOperandKind enum*/"
    return s

OP_ACCESS_TO_STRING: Dict[OpAccess_, str] = create_enum_dict(OpAccess)
def op_access_to_string(value: OpAccess_) -> str:
    s = OP_ACCESS_TO_STRING.get(value)
    if s is None:
        return str(value) + " /*OpAccess enum*/"
    return s

class rsp:
    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
        self.sock.connect(("127.0.0.1", 1234))
        """
        Se manda este mensaje porque en handle_set/get_reg:
        Older gdb are really dumb, and don't use 'G/g' if 'P/p' is available.
        This works, but can be very slow. Anything new enough to understand
        XML also knows how to use this properly. However to use this we
        need to define a local XML file as well as be talking to a
        reasonably modern gdb. Responding with an empty packet will cause
        the remote gdb to fallback to older methods.

        ver: https://github.com/qemu/qemu/blob/master/gdbstub/gdbstub.c
        """
        print(self.ping(b"qXfer:features:read:target.xml:0,1048576"))

    def close(self, *, detach=True):
        if self.sock:
            if detach:
                self.ping_ok(b"D")

            self.sock.close()
            self.sock = None

    def snd(self, data):
        packet = b"+$" + data + b"#" + csum(data)
        self.sock.sendall(packet)

    def rcv(self):
        while True:
            match self.rcv_byte():
                case b"":
                    assert False
                case b"$":
                    break
        data = bytearray()
        while True:
            match self.rcv_byte():
                case b"#":
                    break
                case b"":
                    assert False
                case byte:
                    data.extend(byte)

        ck = csum(data)
        self.exp_byte(ck[:1])
        self.exp_byte(ck[1:])

        return bytes(data)

    def ping(self, data, *, check_err=False):
        self.snd(data)
        r = self.rcv()
        assert not check_err or (r and r[:1] != b"E")
        return r

    def ping_ok(self, data):
        assert self.ping(data) == b"OK"
        print(b"OK")

    def exp_byte(self, byte):
        data = self.rcv_byte()
        assert data == byte, f"{repr(data)} != {repr(byte)}"

    def rcv_byte(self):
        data = self.sock.recv(1)
        return data

    def rr(self, reg):
        return parse_hex(self.ping(b"p" + to_bhex(reg), check_err=True))

    def wr(self, reg, data):
        data = to_qhex(data)
        self.ping_ok(b"P" + to_bhex(reg) + b"=" + data)

    def r(self):
        r = self.ping(b"g")
        for i, reg in enumerate(parse_hex(r[n:n + 16])
                                for n in range(0, len(r), 16)):
            print(f"{i}: {reg}")

    def rm(self, addr, length):
        r = self.ping(b"m" + to_qhex(addr, False) +
                         b"," + to_qhex(length, False), check_err=bool(length))
        return bytes.fromhex(str(r, "ascii"))

    def wm(self, addr, data):
        self.ping_ok(b"M" + to_qhex(addr, False) + b"," +
                     to_qhex(len(data), False) + b":" + data.hex().encode("ascii"))

    def s(self, addr=None):
        r = self.ping(b"s" + (to_qhex(addr, False)
                      if addr is not None else b""), check_err=True)
        exited = r[:1] == b"W"
        if exited:
            self.close(detach=False)
        return not exited

    def rip(self):
        return self.rr(16)

    def get_insn(self):
        rip = self.rip()
        """
        El fetch es de tamaño 15 porque:
        The AVX instructions described in this document (including VEX and 
        ignoring other prefixes) do not exceed 11 bytes in length, but may 
        increase in the future. The maximum length of an Intel 64 and IA-32 
        instruction remains 15 bytes.

        ver: https://cdrdv2.intel.com/v1/dl/getContent/671200 sección 2.3.11 
        """
        insn = next(Decoder(64, self.rm(rip, 15), ip=rip))
        return rip, insn   

    def dbg_step(self):
        rip, insn = self.get_insn()
        print(f"0x{rip:016x}: {insn}")
        return self.s()


    def get_insn_info(self, instr):
        op_code = instr.op_code()
        ops = [op_kind_to_string(instr.op_kind(i)) for i in range(instr.op_count)]
        return mnemonic_to_string(instr.mnemonic), ops
