import sys
from getpoly import getpoly

def makeWing(airfoil, chordScale, thicknessScale, span, slices=100, chordOffset=lambda x:0):
    points = []
    airfoil = list(airfoil)
    for slice in range(slices):
        x = span * slice / (slices-1.)
        ymult = chordScale(x)
        zmult = thicknessScale(x)
        yoffset = chordOffset(x)
        for p in airfoil:
            points.append( (x,ymult*p[0]+yoffset,zmult*p[1]) )
    faces = []
    na = len(airfoil)
    faces.append(range(na))
    for slice in range(slices-1):
        for i in range(na):
            faces.append([ slice*na+i, slice*na+(i+1)%na, (slice+1)*na+(i+1)%na, (slice+1)*na+i ]);
    faces.append(range((slices-1)*na, (slices)*na))
    return points,faces
    
def stringPoly(points,faces):
    out = 'polyhedron(points=[';
    out += ','.join((( '[%.3f,%.3f,%.3f]' % tuple(p)) for p in points))
    out += '],\n'
    out += 'faces=['
    out += ','.join((('['+','.join(str(p) for p in poly)+']') for poly in faces))
    out += ']);'
    return out
    
if __name__ == '__main__':
    span = 20
    def chordScale(x):
        return (x+5) * 4 / (span+5)
    def thicknessScale(x):
        if x < 1.05*span * .9:
            return 1
        else:
            return (1.05*span-x) / (1.05*span) / (1-.9)
    polyhedron = stringPoly(* makeWing(getpoly('airfoil.svg'), chordScale, thicknessScale, span))
    print('module wing() {\n' + polyhedron + '\n}\n wing();')
    