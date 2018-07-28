from struct import pack
from vector import *
from numbers import Number 
import os
import sys

try:
    basestring
except:
    basestring = str

def isColorTriangleList(polys):
    try:
        return isinstance(polys[0][1][0][0], Number)
    except:
        return False
    
def toPolyhedra(polys):
    if isColorTriangleList(polys):
        return [ (polys[0][0], list(face for rgb,face in polys)) ]
    else:
        return polys
        
def isSimpleTriangleMesh(data):
    try:
        return len(data[0]) == 3 and len(data[0][0]) == 3 and isinstance(data[0][0][0], Number)
    except:
        return False
        
def toMesh(polys):
    if isColorTriangleList(polys):
        return polys
    elif isSimpleTriangleMesh(polys):
        output = []
        for tri in polys:
            output.append((None,tri))
        return output
    else:
        output = []
        for rgb,polyhedron in polys:
            for face in polyhedron:
                output.append((rgb,face))
        return output

def describeColor(c):
    if c is None:
        return "undef";
    elif isinstance(c, str):
        return c
    else:
        return "[%.5f,%.5f,%.5f]" % tuple(c)

def toSCADModule(polys, moduleName, coordinateFormat="%.9f", colorOverride=None):
    """
    INPUT:
    polys: list of (color,polyhedra) pairs (counterclockwise triangles), or a list of (color,triangle) pairs (TODO: currently uses first color for all in latter case)
    moduleName: OpenSCAD module name
    
    OUTPUT: string with OpenSCAD code implementing the polys
    """
    
    polys = toPolyhedra(polys)
    
    scad = []
    scad.append("module " +moduleName+ "() {")
    for rgb,poly in polys:
        if colorOverride or rgb:
            line = "  color(%s) " % describeColor(colorOverride if colorOverride else tuple(min(max(c,0.),1.0) for c in rgb))
        else:
            line = "  "
        pointsDict = {}
        i = 0
        line += "polyhedron(points=["
        points = []
        for face in poly:
            for v in reversed(face):
                if tuple(v) not in pointsDict:
                    pointsDict[tuple(v)] = i
                    points.append( ("[" + coordinateFormat + "," + coordinateFormat + "," + coordinateFormat + "]") % tuple(v) )
                    i += 1
        line += ",".join(points)
        line += "], faces=["
        line += ",".join( "[" + ",".join(str(pointsDict[tuple(v)]) for v in reversed(face)) + "]" for face in poly ) + "]"
        line += ");"
        scad.append(line)
    scad.append("}\n")
    return "\n".join(scad)

def saveSCAD(filename, polys, moduleName="object1", quiet=False):
    """
    filename: filename to write OpenSCAD file
    polys: list of (color,polyhedra) pairs (counterclockwise triangles)
    moduleName: OpenSCAD module name
    quiet: give no status message if set
    """
    if not quiet: sys.stderr.write("Saving %s\n" % filename)
    if filename:
        with open(filename, "w") as f:
            f.write(toSCADModule(polys, moduleName))
            f.write("\n" + moduleName + "();\n")
    else:
        sys.stdout.write(toSCADModule(polys, moduleName))
        sys.stdout.write("\n" + moduleName + "();\n")

def saveSTL(filename, mesh, swapYZ=False, quiet=False, adjustCoordinates=False):
    """
    filename: filename to save STL file
    mesh: list of (color,triangle) pairs (counterclockwise)
    swapYZ: should Y/Z axes be swapped?
    quiet: give no status message if set
    """
    
    mesh = toMesh(mesh)
    
    if not quiet: sys.stderr.write("Saving %s\n" % filename)
    minY = float("inf")
    minVector = Vector(float("inf"),float("inf"),float("inf"))
    numTriangles = 0
    if swapYZ:
        matrix = Matrix( (1,0,0), (0,0,-1), (0,1,0) )
    else:
        matrix = Matrix.identity(3)
        
    mono = True
    for rgb,triangle in mesh:
        if rgb is not None:
            mono = False
        numTriangles += 1
        for vertex in triangle:
            vertex = matrix*vertex
            minVector = Vector(min(minVector[i], vertex[i]) for i in range(3))
    if adjustCoordinates:
        minVector -= Vector(0.001,0.001,0.001) # make sure all STL coordinates are strictly positive as per Wikipedia
    else:
        minVector = Vector(0,0,0)
    
    def writeSTL(write):
        write(pack("80s",b''))
        write(pack("<I",numTriangles))
        for rgb,tri in mesh:
            if mono:
                color = 0
            else:
                if rgb is None:
                    rgb = (255,255,255)
                else:
                    rgb = tuple(min(255,max(0,int(0.5 + 255 * comp))) for comp in rgb)
                color = 0x8000 | ( (rgb[0] >> 3) << 10 ) | ( (rgb[1] >> 3) << 5 ) | ( (rgb[2] >> 3) << 0 )
            try:
                normal = (Vector(tri[1])-Vector(tri[0])).cross(Vector(tri[2])-Vector(tri[0])).normalize()
                write(pack("<3f", *(matrix*normal)))
            except:
                continue
            for vertex in tri:
                write(pack("<3f", *(matrix*(vertex-minVector))))
            write(pack("<H", color))            

    if filename:
        with open(filename, "wb") as f:
            writeSTL(f.write)
    else:
        if sys.platform == "win32":
            import msvcrt
            msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)
        writeSTL(lambda data : os.write(sys.stdout.fileno(), data))
            