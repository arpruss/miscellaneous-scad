from struct import pack
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
        return type(self)(self[i]+b[i] for i in range(max(len(self),len(b))))

    def __sub__(self,b):
        return type(self)(self[i]-b[i] for i in range(max(len(self),len(b))))

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

def saveColorSTL(filename, mesh, swapYZ=False):
    minY = float("inf")
    numTriangles = 0
    for rgb,monoMesh in mesh:
        for normal,triangle in monoMesh:
            numTriangles += 1
            for vertex in triangle:
                if vertex[1] < minY:
                    minY = vertex[1]
    with open(filename, "wb") as f:
        f.write(pack("80s",''))
        f.write(pack("<I",numTriangles))
        for rgb,monoMesh in mesh:
            color = 0x8000 | ( (rgb[0] >> 3) << 10 ) | ( (rgb[1] >> 3) << 5 ) | ( (rgb[2] >> 3) << 0 )
            for normal,triangle in monoMesh:
                if swapYZ:
                    f.write(pack("<3f", normal[0], -normal[2], normal[1]))
                    for vertex in triangle:
                        f.write(pack("<3f", vertex[0], -vertex[2], vertex[1]-minY))
                else:
                    f.write(pack("<3f", normal[0], normal[1], normal[2]))
                    for vertex in triangle:
                        f.write(pack("<3f", vertex[0], vertex[1]-minY, vertex[2]))
                f.write(pack("<H", color))            
                
def face3(a,b,c):
    return (Vector(b)-Vector(a)).cross(Vector(c)-Vector(a)).normalize(),(a,b,c)
                
def knotMesh(mainPath, section, t1, t2, tstep, baseVector=Vector(0,0,1)):
    def getCrossSection(t):
        out = []
        f1 = Vector(mainPath(t))
        f2 = Vector(mainPath(t+tstep))
        direction = (f2-f1).normalize()
        xyDirection = Vector(direction.x, direction.y, 0).normalize()
        
        # First, the cross-section will be stood upright, in the yz plane via (x,y) -> (0,x,y)
        m1 = Matrix( (0,0,0), (1,0,0), (0,1,0) )
        
        # Then it will be rotated to match horizontal angle of the knot direction (which had better not be straight up or down) 
        m2 = Matrix.rotateVectorToVector(Vector(1,0,0), xyDirection)
        
        # Finally, we will tilt it to match the direction
        m3 = Matrix.rotateVectorToVector(xyDirection, direction)
        
        m = m3 * m2 * m1
        
        for v in section(t):
            out.append( m * Vector(v) + f1 )
        return out

    monoMesh = []
    nextCrossSection = None
    t = t1
    while t < t2:
        if nextCrossSection is not None:
            curCrossSection = nextCrossSection
        else:
            curCrossSection = getCrossSection(t)
        nextCrossSection = getCrossSection( t+tstep if t+tstep < t2 else t1 )
        n = min(len(curCrossSection),len(nextCrossSection))
        for i in range(n):
            monoMesh.append( face3(curCrossSection[i], nextCrossSection[i], nextCrossSection[(i+1)%n]) )
            monoMesh.append( face3(nextCrossSection[(i+1)%n], curCrossSection[(i+1)%n], curCrossSection[i]) )
        t += tstep
        
    return monoMesh

r = math.sqrt(3)/3.
scale = 5
path1 = lambda t: scale*Vector( math.cos(t), math.sin(t)+r, -math.cos(3*t)/3.  )
path2 = lambda t: scale*Vector( math.cos(t)+0.5, math.sin(t)-r/2., -math.cos(3*t)/3. )
path3 = lambda t: scale*Vector( math.cos(t)-0.5, math.sin(t)-r/2, -math.cos(3*t)/3. )
spin = 4
section = lambda t : [cmath.exp(spin*1j*t) * (0+0j),cmath.exp(spin*1j*t) * (0+1j),cmath.exp(spin*1j*t) * (1+1j),cmath.exp(spin*1j*t) * (1+0j)]

rings = []
rings.append( ( (255,0,0), knotMesh(path1, section, 0, 2*math.pi, .02, baseVector=Vector(0,0,1)) ) )
rings.append( ( (0,255,0), knotMesh(path2, section, 0, 2*math.pi, .02, baseVector=Vector(0,0,1)) ) )
rings.append( ( (0,0,255), knotMesh(path3, section, 0, 2*math.pi, .02, baseVector=Vector(0,0,1)) ) )

#rings.append( ( (0,0,0), knotMesh( lambda t: (10*math.cos(t),10*math.sin(t),0), section, 0, 2*math.pi, 0.05 ) ) )
#rings.append( ( (0,0,0), knotMesh( lambda t: (0,20+math.cos(t),2*math.sin(t)), section, 0, 2*math.pi, 0.05 ) ) )

saveColorSTL("rings.stl", rings)
