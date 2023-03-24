#!/usr/bin/env python3

import subprocess, wx

input_path = 'katherine-johnson.txt'
with open(input_path) as input_file:
    start = input_file.tell()
    data_cipher = bytes(int(b) for line in input_file for b in line.split())

    input_file.seek(start)
    result = subprocess.run(('./img-decrypt', '5963', '1631'),
                            stdin=input_file, stdout=subprocess.PIPE, check=True)

    data_plain = result.stdout

WIDTH, HEIGHT = 320, 320

app = wx.App()
frame = wx.Frame(None, title='Proyecto 1', size=(WIDTH * 2, HEIGHT * 2))
frame.Show()

def img(width, height, data):
    data_rgb = b''.join(bytes((c, c, c)) for c in data)
    return wx.StaticBitmap(frame, bitmap=wx.Bitmap.FromBuffer(width, height, data_rgb))

print(len(data_cipher))
print(len(data_plain))
img_cipher = img(WIDTH, HEIGHT * 2, data_cipher)
img_plain = img(WIDTH, HEIGHT, data_plain)

layout = wx.GridBagSizer()
layout.Add(img_cipher, pos=(0, 0))
layout.Add(img_plain, pos=(0, 1))
frame.SetSizer(layout)

app.MainLoop()
