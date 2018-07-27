#
# Make a flat single sided stl file aligned parallel to the xy plane into a solid slab
#
# python slabify.py filename.stl [thickness]

from loadmesh import loadMesh
from sys import argv, stderr
from exportmesh import *

mesh = loadMesh(argv[1], reverseTriangles=False)
out = argv[1] + "-slab.stl" if not argv[1].lower().endswith(".stl") else argv[1][:-4]+"-slab.stl"
if len(argv) > 2:
    thickness = float(argv[2])
else:
    thickness = 10

def triedges(tri):
    yield (tri[0],tri[1])
    yield (tri[1],tri[2])
    yield (tri[2],tri[0])

mesh2 = []
edges = {}
for tri in mesh:
    for edge in triedges(tri):
        sedge = tuple(sorted(edge))
        if sedge in edges:
            edges[sedge] += 1
        else:
            edges[sedge] = 1

minZ = min(v[2] for v in tri for tri in mesh)
            
for tri in mesh:
    mesh2.append((None,tri))
    def proj(v):
        return tuple((v[0],v[1],minZ-thickness))
    projected = tuple(reversed(tuple(proj(v) for v in tri)))
    mesh2.append((None,projected))
    for edge in triedges(tri):
        if edges[tuple(sorted(edge))] == 1:
            tri2 = (edge[1],edge[0],proj(edge[1]))
            tri3 = (proj(edge[0]),proj(edge[1]),edge[0])
            mesh2.append((None,tri2))
            mesh2.append((None,tri3))

saveSTL(out, mesh2)                       