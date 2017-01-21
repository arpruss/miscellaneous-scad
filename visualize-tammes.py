from visual import *
from sys import stdin,exit
scene2 = display(title='Tammes Solver',
     x=0, y=0, width=600, height=600,
     center=(0,0,0), background=(0,0,0))
balls = []
minD = 0
n = 0
centralBall = sphere(pos=(0,0,0), radius=1, color=color.blue)

while True:
    l = stdin.readline()
    if l == "":
#        scene2.caption = "Best"
        while True: sleep(1.)
    line = l.strip().split(' ')
    if line[0] == 'n':
        n = int(line[1])
        positions = [(0,0,0) for i in range(n)]
    elif line[0] == 'frame':
        rate(30)
        frame = int(line[1])
#        scene2.caption = "Frame %d" % frame
        if len(balls) != n:
            balls = []
            for i in range(n):
                balls.append(sphere(pos=positions[i], radius=minD/2., color=color.red));
        else:
            for i in range(n):
                balls[i].pos = positions[i]
                balls[i].radius = minD/2.
    elif line[0] == 'minD':
        minD = float(line[1])
    elif line[0] == 'pos':
        positions[int(line[1])] = tuple(map(float, line[2:5]))
              