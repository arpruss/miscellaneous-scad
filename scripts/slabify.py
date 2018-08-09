#
# Make a flat single sided stl file aligned parallel to the xy plane into a solid slab
# omits all non-upward-facing triangles
#
# python slabify.py filename.stl [thickness [xmin ymin xmax ymax]]

from loadmesh import loadMesh
from sys import argv, stderr
from exportmesh import *

mesh = loadMesh(argv[1], reverseTriangles=False)
out = argv[1] + "-slab.stl" if not argv[1].lower().endswith(".stl") else argv[1][:-4]+"-slab.stl"
if len(argv) > 2:
    thickness = float(argv[2])
else:
    thickness = 10
xMin = float("-inf")
yMin = float("-inf")
xMax = float("inf")
yMax = float("inf")
if len(argv) > 3:
    xMin = float(argv[3])
if len(argv) > 4:
    yMin = float(argv[4])
if len(argv) > 5:
    xMax = float(argv[5])
if len(argv) > 6:
    yMax = float(argv[6])

def triedges(tri):
    yield (tri[0],tri[1])
    yield (tri[1],tri[2])
    yield (tri[2],tri[0])
    
def upwardFacing(tri):
    a = (tri[1][0]-tri[0][0],tri[1][1]-tri[0][1])
    b = (tri[2][0]-tri[0][0],tri[2][1]-tri[0][1])
    return a[0]*b[1]-a[1]*b[0] > 0
    
def inRange(tri):
    for v in tri:
        if v[0] < xMin or v[0] > xMax or v[1] < yMin or v[1] > yMax:
            return False
    return True
    
pruned = []    
for tri in mesh:
    if upwardFacing(tri) and inRange(tri) and not (tri[1][0] == tri[2][0] and tri[1][1] == tri[2][1]):
        pruned.append(tri)
        
mesh = pruned

mesh2 = []
edges = {}
for tri in mesh:
    for edge in triedges(tri):
        sedge = tuple(sorted(edge))
        if sedge in edges:
            edges[sedge] += 1
        else:
            edges[sedge] = 1
            
print(len(mesh))
minZ = min(v[2] for tri in mesh for v in tri)
            
for tri in mesh:
    mesh2.append(tri)
    def proj(v):
        return tuple((v[0],v[1],minZ-thickness))
    projected = tuple(reversed(tuple(proj(v) for v in tri)))
    mesh2.append(projected)
    for edge in triedges(tri):
        if edges[tuple(sorted(edge))] == 1:
            tri2 = (edge[1],edge[0],proj(edge[1]))
            tri3 = (proj(edge[0]),proj(edge[1]),edge[0])
            mesh2.append(tri2)
            mesh2.append(tri3)

saveSTL(out, mesh2)                       