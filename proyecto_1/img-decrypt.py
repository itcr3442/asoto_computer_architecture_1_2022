#!/usr/bin/env python3

import argparse, subprocess, sys, wx

def main():
    parser = argparse.ArgumentParser(
        prog='Proyecto 1 CE4301',
        description='Decrypt and show an image using 16-bit RSA')

    parser.add_argument('input_path')
    parser.add_argument('param_path')
    args = parser.parse_args()

    try:
        input_file = open(args.input_path)
        param_file = open(args.param_path)
    except OSError as exc:
        print('Fatal: I/O error:', exc, file=sys.stderr)
        return 1

    params = {}
    with param_file as param_file:
        for i, line in enumerate(param_file):
            try:
                key, value = line.split('=', 1)
                params[key.strip()] = int(value.strip())
            except ValueError:
                print(f'Fatal: syntax error at {repr(args.param_path)}:{i + 1}', file=sys.stderr)
                return 1

    def expect(key):
        value = params.get(key)
        if value is None:
            print(f'Fatal: missing param:', repr(key), file=sys.stderr)
            sys.exit(1)

        return value

    n, d = expect('n'), expect('d')
    width, height = expect('width'), expect('height')

    with input_file as input_file:
        start = input_file.tell()
        data_cipher = bytes(int(b) for line in input_file for b in line.split())

        input_file.seek(start)
        try:
            result = subprocess.run(
                    ('./img-decrypt', str(width * height), str(n), str(d)),
                    stdin=input_file, stdout=subprocess.PIPE, check=True)
        except subprocess.CalledProcessError as exc:
            print('Fatal: img-decrypt failed with exit code', exc.returncode, file=sys.stderr)
            return 1

        data_plain = result.stdout

    app = wx.App()
    frame = wx.Frame(None, title='Proyecto 1', size=(width * 2, height * 2))
    frame.Show()

    def img(width, height, data):
        data_rgb = b''.join(bytes((c, c, c)) for c in data)
        return wx.StaticBitmap(frame, bitmap=wx.Bitmap.FromBuffer(width, height, data_rgb))

    img_cipher = img(width, height * 2, data_cipher)
    img_plain = img(width, height, data_plain)

    layout = wx.GridBagSizer()
    layout.Add(img_cipher, pos=(0, 0))
    layout.Add(img_plain, pos=(0, 1))
    frame.SetSizer(layout)

    app.MainLoop()
    return 0

if __name__ == '__main__':
    sys.exit(main())
