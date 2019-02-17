from loadmesh import *
from exportmesh import *
import os.path
import sys

def toMonoMesh(triangles):
    return [(None,t) for t in triangles]

def getBounds(triangles):
    minBounds = tuple( min(min(v[i] for v in t) for t in triangles) for i in range(3) )
    maxBounds = tuple( max(max(v[i] for v in t) for t in triangles) for i in range(3) )
    return (minBounds,maxBounds)
    
def intersects(mesh, poly):
    for v1 in poly:
        for poly2 in mesh:
            for v2 in poly2:
                if (Vector(v1)-v2).norm() <= EPS:
                    return True
    return False

    
class MeshData(list):
    def __init__(self):
        self.mesh = []
        self.points = set()
        self.minBounds = [float("inf"),float("inf"),float("inf")]
        self.maxBounds = [float("-inf"),float("-inf"),float("-inf")]
        
    def addPoly(self, poly):
        self.mesh.append(poly)
        for v in poly:
            self.points.add(Vector(v))
            for i in range(3):
                self.minBounds[i] = min(self.minBounds[i], v[i])
                self.maxBounds[i] = max(self.maxBounds[i], v[i])
            
    def contains(self, point, eps=1e-6):
        for i in range(3):
            if point[i] < self.minBounds[i] - eps or point[i] > self.maxBounds[i] + eps:
                return False
        if tuple(point) in self.points:
            return True
        if 0 < eps:
            for p in self.points:
                if (p-point).norm() <= eps:
                    return True
        return False
    
def splitMesh(polygons, eps=1e-6):
    meshes = []

    for i,poly in enumerate(polygons):
        matches = []
        for j,m in enumerate(meshes):
            for v in poly:
                if m.contains(v, eps=eps):
                    matches.append(j)
                    break
        if len(matches) == 0:
            newMesh = MeshData()
            newMesh.addPoly(poly)
            meshes.append(newMesh)
        else:
            for j in range(len(matches)-1, 0, -1):
                for oldPoly in meshes[matches[j]].mesh:
                    meshes[matches[0]].addPoly(oldPoly)
                del meshes[matches[j]]
            meshes[matches[0]].addPoly(poly)
        if i % 100 == 0:
            sys.stderr.write("[%d/%d]\r" % (i,len(polygons)))
    return [m.mesh for m in meshes]
    
if __name__ == '__main__':
    base,_ = os.path.splitext(sys.argv[1])
    triangles = loadMesh(sys.argv[1])
    
    eps = 0
    if len(sys.argv) > 2:
        eps = float(sys.argv[2])

    meshes = splitMesh(triangles, eps=eps)
    meshes = sorted(meshes, key=getBounds)

    for i,m in enumerate(meshes):
        saveSTL("%s-%03d.stl" % (base, i), toMonoMesh(m), adjustCoordinates=False)
