import fileinput
import re
from collections import OrderedDict
from math import *
from numbers import Number

LIFT = 3
MOVE_SPEED = 2100
TOLERANCE = 0.5

xyz = (0,0,0)
startSkip = None
endSkip = None

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
    return (x,y,z)

def distance2(a,b):
    return sqrt(pow(a[0]-b[0],2)+pow(a[1]-b[1],2))
    
def finishSkip():
    global startSkip,endSkip
    if startSkip is None:
        return
    print(";;FIX** "+str(startSkip)+" "+str(endSkip))
    if tuple(startSkip) != tuple(endSkip):
        if not absolute:
            raise Exception("relative mode not supported yet")
        if startSkip[0] != endSkip[0] or startSkip[1] != endSkip[1]:
            print("G00 Z%.4F F%d ;; FIX0" % (LIFT, MOVE_SPEED))
            print("G00 X%.4F Y%.4F F%d ;; FIX1" % (endSkip[0], endSkip[1], MOVE_SPEED))
        print("G01 Z%.4F F%d ;; FIX2" % (endSkip[2], MOVE_SPEED))
    startSkip = None
    
for line in fileinput.input():
    line = line.strip()
    parsed = parse(line)
    if parsed and parsed.items()[0][0] == 'g':
        cmd = int(parsed.items()[0][1])
        if cmd == 90:
            finishSkip()
            print(line)
            absolute = True
        elif cmd == 91:
            finishSkip()
            print(line)
            raise Exception("relative mode not supported yet")
            absolute = False
        elif cmd == 0 or cmd == 1:
            if startSkip is not None:
                xyz = newXYZ(parsed)
                if 0 >= xyz[2] >= -TOLERANCE:
                    endSkip = xyz
                else:
                    finishSkip()
                    print(line)
            else:
                xyz = newXYZ(parsed)
                if 0 >= xyz[2] >= -TOLERANCE:
                    startSkip = xyz
                    endSkip = xyz
                print(line)
        else:
            finishSkip()
            print(line)
        
