import fileinput
import re
from collections import OrderedDict
from math import *

xyz = (0.,0.,0.)
absolute = True
plane = (0, 1)
maxAngle = 0.1/180*pi

path = [(0.,0.,0.)]

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
    raise Exception("radius-based arc is not supported")
    
def distance2(a,b):
    return sqrt(pow(a[0]-b[0],2)+pow(a[1]-b[1],2))
    
for line in fileinput.input():
    parsed = parse(line)
    if parsed and parsed.items()[0][0] == 'g':
        cmd = int(parsed.items()[0][1])
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
        elif cmd == 2 or cmd == 2:
            ccw = cmd == 3
            endp = newXYZ(parsed)
            delta = tuple( endp[plane[i]]-xyz[plane[i]] for i in (0,1) )
            if 'r' in parsed:
                r = parsed['r']
                center = getCenterFromRadius(r,delta,ccw)
            else:
                center = (parsed.get('ijk'[plane[0]], 0),parsed.get('ijk'[plane[1]], 0))
                r = distance2(center,delta)
            angle2 = atan2(delta[1]-center[0],delta[1]-center[1])
            angle1 = atan2(-center[0],-center[1])            

            def pointAtAngle(theta):
                p = list(xyz)
                p[plane[0]] = center[plane[0]] + cos(theta)*r
                p[plane[1]] = center[plane[1]] + sin(theta)*r
                return p
                
            if ccw:
                if angle2 < angle1:
                    angle2 += 2*pi
                while angle1 < angle2:
                    path.append( pointAtAngle(angle1) )
                    angle1 += maxAngle
                path.append( pointAtAngle(angle2) )
            else:
                if angle1 < angle2:
                    angle1 += 2*pi
                while angle1 > angle2:
                    path.append( pointAtAngle(angle1) )
                    angle1 -= maxAngle
                path.append( pointAtAngle(angle2) )
            
print('gcodepath = [' + ','.join(('[%.4f,%.4f,%.4f]' % tuple(p) for p in path)) + '];')
print("""module trace(path) {
    for (i=[0:1:len(path)-2]) {
        hull() {
            translate(path[i]) children();
            translate(path[i+1]) children();
        }
    }
}

trace(gcodepath) cylinder(d=3.175,h=20);
""")