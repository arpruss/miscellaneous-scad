import fileinput
import re
from collections import OrderedDict
from math import *

minXYZ = (100000,100000,100000)
maxXYZ = (-100000,-100000,-100000)
xyz = (0.,0.,0.)
absolute = True
plane = (0, 1)
maxAngle = 5./180.*pi

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

print("""workWidth = 1000; // x dimension of work, set to 0 to see the cuts only
workDepth = 1000; // y
workHeight = 6; // z
startX = 0;
startY = 0;
startZ = 0;

bitDiameter = 3.175;
bitHeight = 15;
bitAngle = 180; // 180=flat bottom
bitSides = 6; // more looks better but is slower

nudge = 0.001;
""")
print('gcodepath = [' + ',\n'.join(('[%.4f,%.4f,%.4f]' % tuple(p) for p in path)) + '];')
print("""
module trace(path) {
    l = len(path)-2;
    for (i=[0:100:l]) 
        for (j=[0:min(99,l-i)])
            hull() {
                translate(path[i+j]) children();
                translate(path[i+j+1]) children();
            }
}

module bit() {
    if (bitAngle == 180) {
        cylinder($fn=bitSides,d=bitDiameter,h=bitHeight);
    }
    else {
        coneHeight = (bitDiameter/2) * tan(90-bitAngle/2);
        cylinder($fn=bitSides,d1=0, d2=bitDiameter, h=coneHeight);
        translate([0,0,coneHeight-nudge]) cylinder($fn=bitSides,d=bitDiameter, h=bitHeight-coneHeight);
    }
}

difference() {
    if (workWidth > 0 && workDepth >0 && workHeight > 0) translate([0,0,-workHeight+nudge]) cube([workWidth,workDepth,workHeight]);
    trace(gcodepath) bit();
}
""")