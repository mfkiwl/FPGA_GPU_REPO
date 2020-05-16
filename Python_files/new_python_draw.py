import random
import math
import sys
import os
from pathlib import Path
from tkinter import Tk, Canvas, PhotoImage, mainloop

my_path = os.path.abspath(os.path.dirname(__file__))
path_to_data = os.path.join(my_path, "..\\Other_data\\disp_data.txt")

width = 1000
height = 600
window = Tk()
canvas = Canvas(window, width=width, height=height, bg="#000000")
canvas.pack()
img = PhotoImage(width=width, height=height)
canvas.create_image((width//2, height//2), image=img, state="normal")

f = open(path_to_data, "r")

for line in f.readlines():
	point_array = [str(s) for s in line.split(',')]
	img.put(point_array[2], (int(point_array[0]), int(point_array[1])))
	#img.put("#ffffff", (point_array[0], point_array[1]))
	
f.close()	
mainloop()