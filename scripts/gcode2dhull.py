import fileinput
import re
from collections import OrderedDict
from math import *
from numbers import Number
#from pyhull.convex_hull import ConvexHull
from scipy.spatial import ConvexHull 

xyMoveFeedRate = 500
xyz = (0.,0.,0.)
absolute = True
plane = (0, 1)
maxAngle = 5./180.*pi

path = [(0.,0.,0.)]

def fmt(v):
    if isinstance(v, Number):
        return "%.3f" % v
    else:
        return '[' + ','.join((fmt(x) for x in v )) + ']'
    
def parse(line):
    line = re.sub(r'\s', '', line.strip().lower())
    out = OrderedDict()
    pos = 0
    while pos < len(line) and line[pos] != ';':
        if 'a' <= line[pos] <= 'z':
            try:
                number = float(re.split('[a-z;]+', line[pos+1:])[0])
                out[line[pos]] = number
            except:
                pass
        pos += 1
    return out

def newXYZ(parsed):
    if absolute:
        x = parsed.get('x',xyz[0])
        y = parsed.get('y',xyz[1])
        z = parsed.get('z',xyz[2])
    else:
        x = xyz[0] + parsed.get('x',0)
        y = xyz[1] + parsed.get('y',0)
        z = xyz[2] + parsed.get('z',0)
    #print((x,y,z),parsed)
    return (x,y,z)

def getCenterFromRadius(r,endX,endY,ccw):
    if endX == 0 and endY == 0:
        raise Exception("when specifying radius in arc, endpoint must be different from starting point")
    if not ccw:
        c = getCenterFromRadius(r,-endX,-endY,True)
        return -c[0],-c[1]
    bigger = r<0
    r = abs(r)
    d = sqrt(endX*endX+endY*endY)
    nX = endX / d
    nY = endY / d
    raise Exception("radius-based arc is not yet supported")
    
def distance2(a,b):
    return sqrt(pow(a[0]-b[0],2)+pow(a[1]-b[1],2))
    
def first(x):
    return next(iter(parsed))
    
for line in fileinput.input():
    parsed = parse(line)
    if parsed:
        key = first(parsed)[0]
        if key == 'g':
            cmd = int(parsed[key])
            if cmd == 90:
                absolute = True
            elif cmd == 91:
                absolute = False
            elif cmd == 0 or cmd == 1:
                xyz = newXYZ(parsed)
                path.append(xyz)
            elif cmd == 17:
                plane = (0,1)
            elif cmd == 18:
                plane = (0,2)
            elif cmd == 19:
                plane = (1,2)
            elif cmd == 2 or cmd == 3:
                ccw = cmd == 3
                endp = newXYZ(parsed)
                delta = tuple( endp[plane[i]]-xyz[plane[i]] for i in (0,1) )
                if 'r' in parsed:
                    r = parsed['r']
                    center = getCenterFromRadius(r,delta,ccw)
                    r = abs(r)
                else:
                    center = (parsed.get('ijk'[plane[0]], 0),parsed.get('ijk'[plane[1]], 0))
                    r = distance2(center,delta)
                angle2 = atan2(delta[1]-center[1],delta[0]-center[0])
                angle1 = atan2(-center[1],-center[0])            

                centerXYZ = list(xyz)
                centerXYZ[plane[0]] += center[0]
                centerXYZ[plane[1]] += center[1]
                    
                def pointAtAngle(theta):
                    p = list(xyz)
                    p[plane[0]] = centerXYZ[plane[0]] + cos(theta)*r
                    p[plane[1]] = centerXYZ[plane[1]] + sin(theta)*r
                    return p
                    
                if ccw:
                    #print(angle1,angle2)
                    if angle2 < angle1:
                        angle2 += 2*pi
                    while angle1 < angle2:
                        path.append( pointAtAngle(angle1) )
                        angle1 += maxAngle
                else:
                    if angle1 < angle2:
                        angle1 += 2*pi
                    
                    while angle1 > angle2:
                        path.append( pointAtAngle(angle1) )
                        angle1 -= maxAngle

                path.append(endp)
                xyz = endp
        
points2D = [tuple(p[:2]) for p in path]
curX = 0.
curY = 0.

def moveXY(x,y):
    global curX, curY
    if curX == x and curY == y:
        return
    print('G00 F%.1f X%.5f Y%.5f' % (xyMoveFeedRate,x,y))
    curX = x
    curY = y


print('G90')
print('M03 S24000')
print('G92 X0 Y0 Z0')

for v in ConvexHull(points2D).vertices:
    moveXY(*points2D [v])

#for p in ConvexHull(points2D).points:
#    moveXY(*p)
    