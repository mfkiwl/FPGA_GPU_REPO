import random
import math
from pathlib import Path
from tkinter import Tk, Canvas, PhotoImage, mainloop

path_to_data = Path("C:\\Users\\MATEUSZ\\Desktop\\dziadostwo.txt")

width = 1920
height = 1080
window = Tk()
canvas = Canvas(window, width=width, height=height, bg="#000000")
canvas.pack()
img = PhotoImage(width=width, height=height)
canvas.create_image((width//2, height//2), image=img, state="normal")

f = open(path_to_data, "r")
print("drawing start")
for line in f.readlines():
	point_array = [str(s) for s in line.split(',')]
	img.put(point_array[2], (int(point_array[0]), int(point_array[1])))
print("drawing finish")	
f.close()	
mainloop()