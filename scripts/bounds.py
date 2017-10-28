from loadmesh import *
from exportmesh import *
from sys import argv
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
    
def getBounds(triangles):
    minBounds = tuple( min(min(v[i] for v in t) for t in triangles) for i in range(3) )
    maxBounds = tuple( max(max(v[i] for v in t) for t in triangles) for i in range(3) )
    return (minBounds,maxBounds)
    

base,ext = os.path.splitext(argv[1])
outName = base + ".bounds" + ext
triangles = loadMesh(argv[1])
bounds = getBounds(triangles)
mesh = makePrism(bounds)
print(bounds)
print(bounds[1][0]-bounds[0][0],bounds[1][1]-bounds[0][1])
saveSTL(outName, mesh, adjustCoordinates=False)
