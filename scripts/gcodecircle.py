import sys
import math

bit = 0.125*25.4
passDepth = 2
zCutFeedRate = 180
zMoveFeedRate = 480
xyCutFeedRate = 900
xyMoveFeedRate = 2100
zClearance = 2
tabLength = 3.5
tabHeight = 2.5
nTabs = 2

r1 = 0.25*25.4
r2 = 60
thickness = 5

eps = 1e-5
curX = 0
curY = 0
curZ = 0

if len(sys.argv)==2:
    r1 = 0
    r2 = float(sys.argv[1])
elif len(sys.argv)>=3:
    r1 = min(float(sys.argv[1]),float(sys.argv[2]))
    r2 = max(float(sys.argv[1]),float(sys.argv[2]))    

def moveXY(x,y):
    global curX, curY
    if curX == x and curY == y:
        return
    print('G00 F%.1f X%.5f Y%.5f' % (xyMoveFeedRate,x,y))
    curX = x
    curY = y

def cutXY(x,y):
    global curX, curY
    if curX == x and curY == y:
        return
    print('G01 F%.1f X%.5f Y%.5f' % (xyCutFeedRate,x,y))
    curX = x
    curY = y

def moveZ(z):
    global curZ
    if curZ == z:
        return
    print('G00 F%.1f Z%.5f' % (zMoveFeedRate,z))
    curZ = z

def cutZ(z):
    global curZ
    if curZ == z:
        return
    print('G01 F%.1f Z%.5f' % (zCutFeedRate,z))
    curZ = z
    
def arc(radius,startAngle,endAngle,clockwise):
    global curX, curY
    print('; arc: %.5f %.5f' % (startAngle*180/math.pi,endAngle*180/math.pi))
    curX = radius*math.cos(endAngle)
    curY = radius*math.sin(endAngle)
    print('G0%d F%.1f X%.5f Y%.5f I%.5f J%.5f' % (2 if clockwise else 3, xyCutFeedRate, curX, curY, 
        -radius*math.cos(startAngle),-radius*math.sin(startAngle)))
    
    
def warn(s):
    sys.stderr.write(s+'\n')
    
def drill(x,y,depth):    
    print(';drill')
    moveZ(zClearance)
    moveXY(x,y)
    cutZ(0)
    z = 0
    done = depth <= 0
    while not done:
        if z <= -depth:
            done = True
            z = -depth
        cutZ(z)
        z -= passDepth
    
def circlePass(z,thickness,radius,tabs,clockwise):
    # assume start at (radius,0)
    sign = -1 if clockwise else 1
    print(';circle r=%.5f' % radius)
    if tabs:
        tabAngle = (tabLength + bit) / radius
        segmentAngle = 2 * math.pi / nTabs - tabAngle
        angle = 0
        for i in range(nTabs):
            cutZ(z)
            arc(radius,angle,angle+sign*segmentAngle,clockwise)
            moveZ(-thickness+tabHeight)
            arc(radius,angle+sign*segmentAngle,angle+sign*(segmentAngle+tabAngle),clockwise)
            angle += sign*(segmentAngle+tabAngle)
    else:
        cutZ(z)
        arc(radius,0,sign*math.pi,clockwise)
        arc(radius,sign*math.pi,sign*2*math.pi,clockwise)
        #print('G03 F%.1f I%.5f J0' % (xyCutFeedRate, -radius))
    
def makeCircle(radius,tabs,clockwise):
    if radius == 0:
        drill(0,0,thickness)
    else:
        moveZ(zClearance)
        moveXY(radius,0)
        cutZ(0)
        z = 0
        done = thickness <= 0
        while not done:
            if z <= -thickness:
                done = True
                z = -thickness
            circlePass(z,thickness,radius, tabs and z < -thickness+tabHeight,clockwise)
            z -= passDepth
    moveZ(zClearance)

print('G90')
print('M03 S24000')
print('G92 X0 Y0 Z0')
if r1 > 0:
    if r1 < bit/2:
        warn('hole too small for bit')
    makeCircle(max(0,r1-bit/2),False,True)
if r2 > 0:
    makeCircle(r2+bit/2,True,False)
moveZ(zClearance)
moveXY(0,0)
