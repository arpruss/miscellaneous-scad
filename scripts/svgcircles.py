from svgwrite import *
from sys import argv

d = Drawing(argv[1], profile='tiny')

for arg in argv[2:]:
    if arg[0] == 'r':
        d.add(shapes.Circle(center=(0,0),r=eval(arg[1:])))
    elif arg[0] == 'd':
        d.add(shapes.Circle(center=(0,0),r=0.5*eval(arg[1:])))
    else:
        d.add(shapes.Circle(center=(0,0),r=0.5*eval(arg)))
d.save()
