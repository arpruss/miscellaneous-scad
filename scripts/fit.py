from loadmesh import *
from exportmesh import *
from sys import argv
import math
import os.path

def makePrism(b):
    mesh = []
    
    cubeVertices = ( (0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 0, 1), (0, 0, 1) )
    cubeTriangles = ( (0, 2, 1), (0, 3, 2), (2, 3, 4), (2, 4, 5), (1, 2, 5), (1, 5, 6), (0, 7, 4), (0, 4, 3), (5, 4, 7), (5, 7, 6), (0, 6, 7), (0, 1, 6) )

    def cubeVertexToPrismVertex(v):
        return tuple( b[v[i]][i] for i in range(3) )
    
    for t in cubeTriangles:
        mesh.append( (None, tuple( cubeVertexToPrismVertex(cubeVertices[i]) for i in t) ) )
        
    return mesh
    
def getBounds(points):
    minBounds = tuple( min(v[i] for v in points) for i in range(2) )
    maxBounds = tuple( max(v[i] for v in points) for i in range(2) )
    return (minBounds,maxBounds)

def apply(m,v):
    return (m[0][0] * v[0] + m[0][1] * v[1], m[1][0] * v[0] + m[1][1] * v[1])    

base,ext = os.path.splitext(argv[1])
outName = base + ".bounds" + ext
triangles = loadMesh(argv[1])
points = tuple(set(v for t in triangles for v in t))

bestSize = float("inf")
bestAngle = 0

for i in range(0,900):
    angle = i/10.
    t = angle * math.pi / 180.
    matrix = ( (math.cos(t), -math.sin(t)), (math.sin(t), math.cos(t)) )
    rotPoints = tuple(apply(matrix,v) for v in points)
    minBounds,maxBounds = getBounds(rotPoints)
    size = max(maxBounds[0]-minBounds[0],maxBounds[1]-minBounds[1])
    if size < bestSize:
        bestSize = size
        bestAngle = angle

print("""Best angle: %.1f
Dimension: %.2f
Scale to 200x200: %.2f""" % (bestAngle, bestSize, 200./bestSize))
