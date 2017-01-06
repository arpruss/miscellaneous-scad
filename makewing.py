import xml.etree.ElementTree as ET
import sys
from getpoly import getPoly

def getRange(poly):
    minCoord = tuple(min((p[i] for p in poly)) for i in range(2))
    maxCoord = tuple(max((p[i] for p in poly)) for i in range(2))
    return minCoord,maxCoord

def makeWingFromFormulas(airfoil, y, z, span, slices=100, shave=0.):
    points = []
    airfoil = list(airfoil)
    minCoord,maxCoord = getRange(airfoil)
    
    na = len(airfoil)
    for i in range(len(airfoil)):
        airfoil[i] = tuple( (airfoil[i][j] - minCoord[j]) / (maxCoord[j] - minCoord[j])  for j in range(2) )
    
    for slice in range(slices):
        x = span * slice / (slices-1.)
        yMinus,yPlus = y(x)
        zMinus,zPlus = z(x)
        for p in airfoil:
            points.append( (x,(yPlus-yMinus)*p[0]+yMinus,(zPlus-zMinus)*p[1]+zMinus) )
            
    centerStart = (0,sum((points[i][1] for i in range(na)))/float(na), sum((points[i][2] for i in range(na)))/float(na))
    centerStartIndex = len(points)
    points.append(centerStart)
    centerEnd = (span,sum((points[i][1] for i in range((slices-1)*na, (slices)*na)))/float(na), sum((points[i][2] for i in range((slices-1)*na, (slices)*na)))/float(na))
    centerEndIndex = len(points)
    points.append(centerEnd)

    faces = []
    for i in range(na):
        faces.append([ i,centerStartIndex,(i+1)%na ]); 
    for slice in range(slices-1):
        for i in range(na):
            faces.append([ slice*na+i, slice*na+(i+1)%na, (slice+1)*na+(i+1)%na]);
            faces.append([(slice+1)*na+(i+1)%na,(slice+1)*na+i, slice*na+i]);
    for i in range(na):
        faces.append([ centerEndIndex, (slices-1)*na+i,(slices-1)*na+(i+1)%na ]); 
    return points,faces
    
def stringPointArray(points):
    return '['+','.join((( '[%.3f,%.3f,%.3f]' % tuple(p)) for p in points))+']'
    
def stringFaceArray(faces):
    return '['+','.join((('['+','.join(str(p) for p in poly)+']') for poly in faces))+']'
    
def stringPoly(points,faces):
    return 'polyhedron(points='+stringPointArray(points)+',\n faces='+stringFaceArray(faces)+');\n'
    
def toFormula(poly, span):
    poly = list(poly)
    minCoord,maxCoord = getRange(poly)
    
    scale = float(span)/(maxCoord[0]-minCoord[0])

    def getRangeAtX(x):
        return min(scale*(p[1]-minCoord[1]) for p in poly if p[0] == x),max(scale*(p[1]-minCoord[1]) for p in poly if p[0] == x)
    
    for i in range(len(poly)):
        poly[i] = tuple( poly[i][j]*scale for j in range(2) )
        
    def findAtX(x,span=span,poly=poly):
        x = min(max(x,span*.0001),span*.9999)
        
        minY = float("inf")
        maxY = float("-inf")
        n = len(poly)
        for i,p in enumerate(poly):
            next = poly[(i+1)%n]
            if p[0] <= x <= next[0] or next[0] <= x <= p[0]:
                if p[0] == next[0]:
                    minY = min(minY, p[1], next[1])
                    maxY = max(maxY, p[1], next[1])
                else:
                    slope = (next[1]-p[1])/(next[0]-p[0])
                    y = p[1] + slope * (x - p[0])
                    minY = min(minY, y)
                    maxY = max(maxY, y)
        assert minY <= maxY
        return (minY,maxY)

    return findAtX
    
def makeWingFromPolys(airfoil, topView, sideView, span, slices=100, shave=1.):
    return makeWingFromFormulas(airfoil, toFormula(topView, span), toFormula(sideView, span), span, slices=100)
    
if __name__ == '__main__':
    svgTree = ET.parse(sys.argv[1]).getroot()

    span = 20

    airfoil = getPoly(svgTree, colorExtract=(0,0,0))
    topView = getPoly(svgTree, colorExtract=(1,0,0))
    sideView = getPoly(svgTree, colorExtract=(0,0,1))
    polyhedron = stringPoly(* makeWingFromPolys(airfoil, topView, sideView, span))
    print('module wing() {\n' + polyhedron + '\n}\n wing();')
    