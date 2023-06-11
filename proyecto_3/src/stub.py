import socket

def csum(data):
    return to_bhex(sum(data) & 0xff)

def to_bhex(data):
    assert 0 <= data <= 0xff
    return hex(data)[2:].zfill(2).encode("ascii")

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
        return int.from_bytes((bytes.fromhex(str(r, "ascii"))), "little")

    def wr(self, reg, data):
        data = data.to_bytes(4, "little").hex().encode("ascii")
        self.ping_ok(b"P" + to_bhex(reg) + b"=" + data)
