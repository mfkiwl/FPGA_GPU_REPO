import random
import math
from pathlib import Path
from tkinter import Tk, Canvas, PhotoImage, mainloop

path_to_data = Path("C:\\Users\\Karol\\Desktop\\dziadostwo.txt")

width = 1000
height = 600
window = Tk()
canvas = Canvas(window, width=width, height=height, bg="#000000")
canvas.pack()
img = PhotoImage(width=width, height=height)
canvas.create_image((width//2, height//2), image=img, state="normal")

f = open(path_to_data, "r")

for line in f.readlines():
	print(line);
	point_array = [int(s) for s in line.split(',')]
	img.put("#ffffff", (point_array[0], point_array[1]))
	
f.close()	
mainloop()