#
# magnify relief to an engraved cylinder
#
# python relief.py filename.stl factor
#

from loadmesh import loadMesh
from sys import argv, stderr
from exportmesh import *
from math import *

mesh = loadMesh(argv[1], reverseTriangles=False)
relief = float(argv[2])
rlf = "-relief%g.stl" % relief
out = argv[1] + rlf if not argv[1].lower().endswith(".stl") else argv[1][:-4] + rlf

def radius(v):
    return sqrt(v[0]*v[0]+v[1]*v[1])
    
print(len(mesh))
avgR = sum(radius(v) for tri in mesh for v in tri) / (3*len(mesh))
stderr.write("avgR = %.2f\n" % avgR)

mesh2 = []

for tri in mesh:
    def fixVertex(v):
        a = (radius(v)/avgR)**(relief-1)
        return (v[0]*a,v[1]*a,v[2])
    mesh2.append(tuple( fixVertex(v) for v in tri ))

saveSTL(out, mesh2)                       