import socket


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


class rsp:
    def __init__(self):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
        self.s.connect(("127.0.0.1", 1234))
        print(self.rcv())
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

    def close(self):
        self.ping_ok(b"D")
        self.s.close()

    def snd(self, data):
        packet = b"$" + data + b"#" + csum(data)
        self.s.sendall(packet)

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

    def ping(self, data):
        self.snd(data)
        return self.rcv()

    def ping_ok(self, data):
        assert self.ping(data) == b"OK"
        print(b"OK")

    def exp_byte(self, byte):
        data = self.rcv_byte()
        assert data == byte, f"{repr(data)} != {repr(byte)}"

    def rcv_byte(self):
        data = self.s.recv(1)
        return data

    def rr(self, reg):
        r = self.ping(b"p" + to_bhex(reg))
        assert r and r[:1] != b"E"
        return parse_hex(r)

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
                      b"," + to_qhex(length, False))
        assert (not length or r) and (not r or r[:1] != b"E")
        return r

    def wm(self, addr, data):
        self.ping_ok(
            b"M" +
            to_qhex(
                addr,
                False) +
            b"," +
            to_qhex(
                len(data),
                False) +
            b":" +
            data.hex().encode("ascii"))
