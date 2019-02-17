import math
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

    def __neg__(self):
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
        if isinstance(key, slice):
            return type(self)(tuple.__getitem__(self, key))
        elif key >= len(self):
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
        
    def perpendicular(self):
        """
        Return one normalized perpendicular vector.
        In 2D, that's enough for a basis.
        In 3D, you need another, but can generate via cross-product.
        In other dimensions, raise NotImplementedError
        """
        if len(self) == 2:
            return Vector(-self.y, self.x)
        elif len(self) == 3:
            if abs(self.x) <= min(abs(self.y),abs(self.z)):
                return Vector(0.,-self.z,self.y).normalize()
            elif abs(self.y) <= min(abs(self.x),abs(self.z)):
                return Vector(-self.z,0.,self.x).normalize()
            else:
                return Vector(-self.y,self.x,0.).normalize()
        else:
            raise NotImplementedError
            
    def toComplex(self):
        return complex(self[0], self[1])
        
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
        
    @staticmethod
    def rotate2D(theta):
        return Matrix([math.cos(theta),-math.sin(theta)],[math.sin(theta),math.cos(theta)])

