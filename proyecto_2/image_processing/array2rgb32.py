#!/usr/bin/env python3

import sys
import numpy as np
from numpy import asarray
from PIL import Image
import matplotlib.pyplot as plt

def load_png(filename):
    img = Image.open(filename + '.png')
    #data = np.array(img, dtype='uint8')
    data = asarray(img)
    return data.tolist()

def rgba2bgra(matrix):
    for row in matrix:
        for pixel in row:
            pixel[0], pixel[2] = pixel[2], pixel[0]
    return matrix

def get_base_image(image):
    image = Image.fromarray(np.uint8(image))
    image = image.convert(mode="RGBA", colors=256)

    if image.size != (640, 480): # width, height
        image = image.resize(size=(640, 480))
    
    return image

def show_image(image):
    plt.imshow(image)
    plt.show()

image = get_base_image(rgba2bgra(load_png("test_image")))
image_bytes = image.tobytes()

#show_image(image)

out_file, = sys.argv[1:]

with open(out_file, 'wb') as f:
    f.write(image_bytes)
