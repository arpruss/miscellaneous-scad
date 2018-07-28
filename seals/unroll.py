from sys import *
from math import *
from random import *
import subprocess

thickness = 10
maxR = 0
minR = float("inf")
sumR = 0
count = 0
points = []

out = argv[1] + "-unroll" if not argv[1].lower().endswith(".txt") else argv[1][:-4]+"-unroll"

with open(argv[1]) as f:
    for line in f:
        try:
            v = tuple(float(x) for x in line.split(";")[:3])
            if len(v) < 3:
                raise Error()
            points.append(v)
            r = sqrt(v[0]*v[0]+v[1]*v[1])
            sumR += r
            if r > maxR:
                maxR = r
            if r < minR:
                minR = r
        except:
            pass
        
avgR = sumR / len(points)

minZ = min(v[2] for v in points)
maxZ = max(v[2] for v in points)

stderr.write("Min Z = %.2f, max Z = %.2f\n" % (minZ,maxZ))
stderr.write("Average R = %.2f, min R = %.2f, max R = %.2f\n" % (avgR,minR,maxR))

with open(out+".txt", "w") as f: 
    for v in points:
        try:
            angle = atan2(v[1],v[0])
        except:
            continue
        r = sqrt(v[0]*v[0]+v[1]*v[1])
        x,y,z=angle*avgR,v[2],thickness+maxR-r
        if x < 0:
            x += 2*pi*avgR
        x1 = x + 2*pi*avgR
        f.write("%.5f;%.5f;%.5f\n" % (x,y,z))
        f.write("%.5f;%.5f;%.5f\n" % (x1,y,z))

stderr.write("0<=x && x<=%.5f && %.5f<=y && y<=%.5f\n" % (4*pi*avgR,minZ,maxZ))
subprocess.call(["meshlabserver", "-i", out+".txt", "-s", "process_unroll.mlx", "-o", out+".stl"])
subprocess.call(["pypy", "../scripts/slabify.py", out+".stl", "4", "0", str(minZ), str(4*pi*avgR), str(maxZ)])
