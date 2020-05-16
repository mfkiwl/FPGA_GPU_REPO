import random
import math
import sys
import os
from pathlib import Path
from tkinter import Tk, Canvas, PhotoImage, mainloop

#path_to_data = Path("..\\Other_data\\disp_data.txt")

my_path = os.path.abspath(os.path.dirname(__file__))
path_to_data = os.path.join(my_path, "..\\Other_data\\disp_data.txt")

data_xy = open(path_to_data, "r")
x_string = data_xy.readline()
y_string = data_xy.readline()
data_xy.close()

point_array_x = [int(s) for s in x_string.split(',')]
point_array_y = [int(s) for s in y_string.split(',')]

width = 1000
height = 600
window = Tk()
canvas = Canvas(window, width=width, height=height, bg="#000000")
canvas.pack()
img = PhotoImage(width=width, height=height)
canvas.create_image((width//2, height//2), image=img, state="normal")

def plot_x_y():
    for x in range(0, len(point_array_x)):
        img.put("#ffffff", (point_array_x[x], point_array_y[x]))

plot_x_y()
mainloop()