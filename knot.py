# TODO:
#   1. open curves
#   2. non-convex sections (need triangulation code)

from struct import pack
import sys
import math
import cmath
from numbers import Number 

class Vector(tuple):
    """
    Three ways of initializing:
        Vector(a,b,c,...) -> vector with components a,b,c,...
        Vector(iterable) -> vector whose components are given by the iterable
        Vector(cx) -> 2D vector with components cx.real,cx.imag where cx is complex numbers
    """
    def __new__(cls, *a):
        if len(a) == 1 and hasattr(a[0], '__iter__'):
            return tuple.__new__(cls, a[0])
        elif len(a) == 1 and isinstance(a[0], complex):
            return tuple.__new__(cls, (a[0].real,a[0].imag))
        else:
            return tuple.__new__(cls, a)
            
    def __add__(self,b):
        if isinstance(b, Number):
            if b==0.:
                return self
            else:
                raise NotImplementedError
        else:
            return type(self)(self[i]+b[i] for i in range(max(len(self),len(b))))

    def __radd__(self,b):
        if isinstance(b, Number):
            if b==0.:
                return self
            else:
                raise NotImplementedError
        else:
            return type(self)(self[i]+b[i] for i in range(max(len(self),len(b))))

    def __sub__(self,b):
        return type(self)(self[i]-b[i] for i in range(max(len(self),len(b))))

    def __rsub__(self,b):
        return type(self)(b[i]-self[i] for i in range(max(len(self),len(b))))

    def __neg__(self,b):
        return type(self)(-comp for comp in self)

    def __mul__(self,b):
        if isinstance(b, Number):
            return type(self)(comp*b for comp in self)
        elif hasattr(b, '__getitem__'):
            return sum(self[i] * b[i] for i in range(min(len(self),len(b))))
        else:
            raise NotImplementedError

    def __rmul__(self,b):
        if isinstance(b, Number):
            return type(self)(comp*b for comp in self)
        else:
            raise NotImplementedError
            
    def __div__(self,b):
        return self*(1./b)
            
    def __getitem__(self,key):
        if key >= len(self):
            if len(self)>0 and hasattr(self[0],'__getitem__'):
                return type(self[0])(0. for i in range(len(self[0])))
            else:
                return 0.
        else:
            return tuple.__getitem__(self, key)
            
    def norm(self):
        return math.sqrt(sum(comp*comp for comp in self))
        
    def normalize(self):
        n = self.norm()
        return type(self)(comp/n for comp in self)
            
    def cross(self,b):
        return Vector(self.y * b.z - self.z * b.y, self.z * b.x - self.x * b.z, self.x * b.y - self.y * b.x)
        
    @property
    def x(self):
        if len(self) < 1:
            return 0
        return self[0]
            
    @property
    def y(self):
        if len(self) < 2:
            return 0
        return self[1]

    @property
    def z(self):
        if len(self) < 3:
            return 0
        return self[2]
        
class Matrix(Vector):
    """
    a Matrix is a Vector of Vectors.
    Two ways of initializing:
        Matrix(iterable1,iterable2,...)
        Matrix((iterable1,iterable2,...))
    where each iterable is a row. This could be ambiguous if setting a one-row matrix.
    In that case, use the second notation: Matrix(((x,y,z))).
    """
    def __new__(cls, *a):
        if len(a) == 1 and hasattr(a[0], '__iter__'):
            return Vector.__new__(cls, tuple(Vector(row) for row in a[0]))
        else:
            return Vector.__new__(cls, tuple(Vector(row) for row in a))
            
    @property
    def rows(self):
        return len(self)
        
    @property
    def cols(self):
        return len(self[0])
        
    def __mul__(self,b):
        if isinstance(b,Number):
            return Matrix(self[i] * b for i in range(self.rows))
        elif isinstance(b,Matrix):
            return Matrix((sum(self[i][j]*b[j][k] for j in range(self.cols)) for k in range(b.cols)) for i in range(self.rows))
        elif hasattr(b,'__getitem__'):
            return Vector(sum(self[i][j]*b[j] for j in range(self.cols)) for i in range(self.rows))
        else:
            raise NotImplementedError
            
    def __rmul__(self,b):
        if isinstance(b,Number):
            return Matrix(self[i] * b for i in range(self.rows))
        elif hasattr(b,'__getitem__'):
            return Vector(sum(b[i]*self[j][i] for i in range(self.rows)) for j in range(self.cols))
        else:
            raise NotImplementedError

    @staticmethod
    def identity(n):
        return Matrix(Vector(1 if i==j else 0 for i in range(n)) for j in range(n))

    @staticmethod
    def rotateVectorToVector(a,b):
        """
        inputs must be normalized
        """
        # http://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
        v = Vector(a).cross(b)
        s = v.norm()
        c = a*b # dot product
        if c == -1:
            # todo: handle close to -1 cases
            return Matrix((-1,0,0),(0,-1,0),(0,0,-1))
        vx = Matrix((0,-v.z,v.y),(v.z,0,-v.x),(-v.y,v.x,0))
        return Matrix.identity(3) + vx + (1./(1+c)) * vx * vx

# triangulation algorithm based on https://www.geometrictools.com/Documentation/TriangulationByEarClipping.pdf
# minus all the double-linked list stuff that would be great but I am not bothering with it

def cross_z(a,b):
    # z-component of cross product
    return a.x * b.y - a.y * b.x

def pointInside(p,a,b,c):
    c1 = cross_z(p-a, b-a)
    c2 = cross_z(p-b, c-b)
    if c1 * c2 < 0:
        return False
    c3 = cross_z(p-c, a-c)
    return c1 * c3 >= 0 and c2 * c3 >= 0
    
def triangulate(polygon):
    # assume input polygon is counterclockwise
    n = len(polygon)

    if n < 3:
        raise Exception
    
    # two efficient special cases
    if n == 3:
        return [(0,1,2)]
    elif n == 4:
        return [(0,1,2),(2,3,0)]
    
    triangles = []
    polygon = [Vector(v) for v in polygon]
    
    index = list(range(n))
    
    def isReflex(i):
        return cross_z(polygon[i]-polygon[i-1], polygon[(i+1) % n]-polygon[i]) < 0
        
    reflex = [isReflex(i) for i in range(n)]
    
    def isEar(i):
        if reflex[i]:
            return False
        a,b,c = polygon[i-1],polygon[i],polygon[(i+1) % n]
        j = i+2
        while j % n != (i-1) % n:
            if reflex[j % n] and pointInside(polygon[j % n],a,b,c):
                return False
            j += 1
        return True
        
    ear = [isEar(i) for i in range(n)]
    
    while n >= 3:
        i = 0
        foundEar = False
        for i in range(n):
            if ear[i]:
                triangles.append((index[i-1],index[i],index[(i+1) % n]))
                # TODO: less deleting!
                del polygon[i]
                del reflex[i]
                del ear[i]
                del index[i]
                n -= 1
                if reflex[i-1]:
                    reflex[i-1] = isReflex(i-1)
                if reflex[i % n]:
                    reflex[i % n] = isReflex(i)
                if not reflex[i-1]:
                    ear[i-1] = isEar(i-1)
                if not reflex[i % n]:
                    ear[i % n] = isEar(i)
                foundEar = True
                break
            
        assert foundEar
        
    return triangles

def polygonsToSVG(vertices, polys):
    vertices = tuple(Vector(v) for v in vertices)
    minX = min(v.x for v in vertices)
    minY = min(v.y for v in vertices)
    maxX = max(v.x for v in vertices)
    maxY = max(v.y for v in vertices)

    svgArray = []
    svgArray.append('<?xml version="1.0" standalone="no"?>')
    svgArray.append('<svg width="%fmm" height="%fmm" viewBox="0 0 %f %f" xmlns="http://www.w3.org/2000/svg" version="1.1">'%(maxX-minX,maxY-minY,maxX-minX,maxY-minY))
    svgArray.append('\n')
    for p in polys:
        for i in range(len(p)):
            svgArray.append('<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="black" stroke-width="0.15px"/>' % 
                (vertices[p[i-1]].x-minX,vertices[p[i-1]].y-minY,vertices[p[i]].x-minX,vertices[p[i]].y-minY))
    svgArray.append('</svg>')
    return '\n'.join(svgArray)
    
def toColorSCAD(polys, moduleName="object1"):
    def polyToSCAD(poly):
        pointsDict = {}
        i = 0
        out = "polyhedron(points=["
        points = []
        for face in poly:
            for v in face:
                if tuple(v) not in pointsDict:
                    pointsDict[tuple(v)] = i
                    points.append( "[%.9f,%.9f,%.9f]" % tuple(v) )
                    i += 1
        out += ",".join(points)
        out += "], faces=["
        out += ",".join( "[" + ",".join(str(pointsDict[tuple(v)]) for v in face) + "]" for face in poly ) + "]"
        out += ");"
        return out

    out = "module " +moduleName+ "() {\n"
    for rgb,monoPolys in polys:
        for poly in monoPolys:
            out += "  color([%.3f,%.3f,%.3f]) " % ( rgb[0]/255., rgb[1]/255., rgb[2]/255. ) 
            out += "%s\n" % polyToSCAD(poly)
    out += "}\n"
    return out
        
def saveColorSCAD(filename, polys, moduleName="object1"):
    with open(filename, "w") as f:
        f.write(toColorSCAD(polys, moduleName=moduleName))
        f.write("\n" + moduleName + "();")

def saveColorSTL(filename, mesh, swapYZ=False):
    minY = float("inf")
    minVector = Vector(float("inf"),float("inf"),float("inf"))
    numTriangles = 0
    if swapYZ:
        matrix = Matrix( (1,0,0), (0,0,-1), (0,1,0) )
    else:
        matrix = Matrix.identity(3)
    for rgb,monoMesh in mesh:
        for triangle in monoMesh:
            numTriangles += 1
            for vertex in triangle:
                vertex = matrix*vertex
                minVector = Vector(min(minVector[i], vertex[i]) for i in range(3))
    minVector -= Vector(0.001,0.001,0.001) # make sure all STL coordinates are strictly positive as per Wikipedia
     
    with open(filename, "wb") as f:
        f.write(pack("80s",''))
        f.write(pack("<I",numTriangles))
        for rgb,monoMesh in mesh:
            color = 0x8000 | ( (rgb[0] >> 3) << 10 ) | ( (rgb[1] >> 3) << 5 ) | ( (rgb[2] >> 3) << 0 )
            for tri in monoMesh:
                normal = (Vector(tri[1])-Vector(tri[0])).cross(Vector(tri[2])-Vector(tri[0])).normalize()
                f.write(pack("<3f", *(matrix*normal)))
                for vertex in tri:
                    f.write(pack("<3f", *(matrix*(vertex-minVector))))
                f.write(pack("<H", color))            
                
class SectionAligner(object):
    def __init__(self, upright=Vector(0,0,1)):
        self.upright = upright.normalize()
        
        # perp will be perpendicular to upright, and serve as a default direction for the cross-section's normal
        m = min(abs(comp) for comp in upright)
        if self.upright.x == m:
            self.perp1 = (1,0,0) - self.upright.x*self.upright
        elif upright.y == m:
            self.perp1 = (0,1,0) - self.upright.y*self.upright
        else:
            self.perp1 = (0,0,1) - self.upright.z*self.upright
        self.perp2 = self.upright.cross(self.perp1)
        
    # First, the cross-section will be stood up with x-axis going to perp2, y-axis going to upright and normal going to perp1
        self.m1 = Matrix( (self.perp2.x, self.upright.x, 0), (self.perp2.y, self.upright.y, 0), (self.perp2.z, self.upright.z, 0) )
    
    def align(self, sectionPoints, direction, position):
        out = []
        direction = direction.normalize()
        projDirection = (direction - (direction*self.upright)*self.upright).normalize()
        
        # Then it will be rotated to match horizontal angle of the knot direction (which had better not be straight up or down along upright) 
        m2 = Matrix.rotateVectorToVector(self.perp1, projDirection)
        
        # Finally, we will tilt it to match the direction
        m3 = Matrix.rotateVectorToVector(projDirection, direction)
        
        m = m3 * m2 * self.m1
        
        for v in sectionPoints:
            out.append( m * Vector(v) + position )

        return out
                
def knotMesh(mainPath, section, t1, t2, tstep, upright=Vector(0,0,1), solid=False, clockwise=False, scad=False, cacheTriangulation=False, closed=True):
    """
    The upright vector specifies the preferred pointing direction for the y-axis in the input sections.
    The tangent to the mainPain should never be close to parallel to the upright vector. E.g., for a mainly
    horizontal knot, the default (0,0,1) setting should work.
    
    In polyhedron mode, each little piece of the knot is a separate polyhedron, appropriate for dumping into OpenSCAD.
    """
    
    if scad:
        solid = True
        clockwise = True
        
    def orderPolys(polys):
        if clockwise:
            return [tuple(reversed(p)) for p in polys]
        else:
            return polys
    
    cachedTriangulation = None

    aligner = SectionAligner(upright=upright)
    
    def getCrossSection(s, t):
        f1 = mainPath(t)
        direction = mainPath( (t-t1+tstep/2.)%(t2-t1) + t1 ) - f1
        return aligner.align(s, direction, f1)
        
    def getTriangulation(s):
        if cacheTriangulation:
            if cachedTriangulation is None:
                cachedTriangulation = triangulate(s)
                return cachedTriangulation
            else:
                return cachedTriangulation
        else:
            return triangulate(s)
        
    output = []
    nextCrossSection = None
    t = t1
    while t < t2:
        if nextCrossSection is not None:
            curCrossSection,curTriangulation = nextCrossSection,nextTriangulation
        else:
            s = section(t)
            curCrossSection,curTriangulation = getCrossSection(s, t), not solid or getTriangulation(s)
        nextT = t+tstep if t+tstep < t2 else t1
        s = section(nextT)
        nextCrossSection,nextTriangulation = getCrossSection( s, nextT ), not solid or getTriangulation(s)
        
        n = len(curCrossSection)
        assert n == len(nextCrossSection)
        
        def triangulateTube(i):
            return orderPolys( [ ( curCrossSection[i], nextCrossSection[i], nextCrossSection[(i+1)%n] ), 
                     ( nextCrossSection[(i+1)%n], curCrossSection[(i+1)%n], curCrossSection[i] ) ] )
                     
        def applyTriangulation(points,tr,clockwise=False):
            if clockwise:
                return [ tuple(reversed( (points[t[0]],points[t[1]],points[t[2]]))) for t in tr ]
            else:
                return [ (points[t[0]],points[t[1]],points[t[2]]) for t in tr ]

        if solid:
            polyhedron = applyTriangulation(curCrossSection, curTriangulation, clockwise=clockwise)
            polyhedron += applyTriangulation(nextCrossSection, nextTriangulation, clockwise=not clockwise)
            for i in range(len(curCrossSection)):
                polyhedron += triangulateTube(i)
            output.append(polyhedron)
        else:
            for i in range(n):
                output += triangulateTube(i)
        t += tstep
        
    return output
    
if __name__ == '__main__':    
    r = math.sqrt(3)/3.
    scale = 5
    path1 = lambda t: scale*Vector( math.cos(t), math.sin(t)+r, -math.cos(3*t)/3.  )
    path2 = lambda t: scale*Vector( math.cos(t)+0.5, math.sin(t)-r/2., -math.cos(3*t)/3. )
    path3 = lambda t: scale*Vector( math.cos(t)-0.5, math.sin(t)-r/2, -math.cos(3*t)/3. )
    spin = 1
    
    #baseSection = Vector( (-.5-.5j),(-.5+.5j),(.5+.5j),(.5-.5j) )
    baseSection = Vector( cmath.exp(2j*math.pi*k/10) * (1 if k%2 else 0.5) for k in range(10) )
    section = lambda t : cmath.exp(spin*1j*t) * baseSection

    rings = []
    rings.append( ( (255,0,0), knotMesh(path1, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=True) ) )
    rings.append( ( (0,255,0), knotMesh(path2, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=True) ) )
    rings.append( ( (0,0,255), knotMesh(path3, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=True) ) )

    saveColorSCAD("rings.scad", rings)

    rings = []
    rings.append( ( (255,0,0), knotMesh(path1, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=False) ) )
    rings.append( ( (0,255,0), knotMesh(path2, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=False) ) )
    rings.append( ( (0,0,255), knotMesh(path3, section, 0, 2*math.pi, .1, upright=Vector(0,.1,1), scad=False) ) )

    saveColorSTL("rings.stl", rings)
