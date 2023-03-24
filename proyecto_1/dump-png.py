#!/usr/bin/env python3

import sys, PIL.Image
sys.stdout.buffer.write(bytes(PIL.Image.open(sys.argv[1]).getdata()))
