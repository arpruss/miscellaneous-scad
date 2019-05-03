import sys
import math

bit = 0.125*25.4
passDepth = 2
zCutFeedRate = 180
zMoveFeedRate = 480
xyCutFeedRate = 900
xyMoveFeedRate = 2100
zClearance = 2
tabLength = 3
tabHeight = 2.5
nTabs = 2

r1 = 0.25*25.4
r2 = 60
thickness = 5

eps = 1e-5

if len(sys.argv)==2:
    r1 = 0
    r2 = float(sys.argv[1])
elif len(sys.argv)>=3:
    r1 = min(float(sys.argv[1]),float(sys.argv[2]))
    r2 = max(float(sys.argv[1]),float(sys.argv[2]))    

def moveXY(x,y):
    print('G00 F%.1f X%.5f Y%.5f' % (xyMoveFeedRate,x,y))

def cutXY(x,y):
    print('G01 F%.1f X%.5f Y%.5f' % (xyCutFeedRate,x,y))

def moveZ(z):
    print('G00 F%.1f Z%.5f' % (zMoveFeedRate,z))

def cutZ(z):
    print('G01 F%.1f Z%.5f' % (zCutFeedRate,z))
    
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
    
def arc(radius,startAngle,endAngle,clockwise):
    print('; arc: %.5f %.5f' % (startAngle*180/math.pi,endAngle*180/math.pi))
    print('G0%d F%.1f X%.5f Y%.5f I%.5f J%.5f' % (2 if clockwise else 3, xyCutFeedRate, radius*math.cos(endAngle), radius*math.sin(endAngle), 
        -radius*math.cos(startAngle),-radius*math.sin(startAngle)))
    
def circlePass(z,thickness,radius,tabs,clockwise):
    # assume start at (radius,0)
    cutZ(z)
    sign = -1 if clockwise else 1
    print(';circle r=%.5f' % radius)
    if tabs:
        tabAngle = (tabLength + 2*bit) / (2 * math.pi * radius)
        segmentAngle = 2 * math.pi / nTabs - tabAngle
        angle = 0
        for i in range(nTabs):
            arc(radius,angle,angle+sign*segmentAngle,clockwise)
            moveZ(-thickness+tabHeight)
            arc(radius,angle+sign*segmentAngle,angle+sign*(segmentAngle+tabAngle),clockwise)
            moveZ(z)
            angle += sign*(segmentAngle+tabAngle)
    else:
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
