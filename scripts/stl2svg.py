from sys import argv
from loadmesh import *

def project(polygons, xAxis, yAxis, zAxis, z, eps=1e-6):
    out = []
    for polygon in polygons:
        if z is None or all( ( abs(v[zAxis]-z)<=eps for v in polygon) ):
            out.append(tuple( (v[xAxis], v[yAxis]) for v in polygon ))
    return out
    
def signedAreaTriangle(p):
    x1 = p[1][0]-p[0][0]
    y1 = p[1][1]-p[0][1]
    x2 = p[2][0]-p[0][0]
    y2 = p[2][1]-p[0][1]
    return (x1*y2-x2*y1)/2.
    
def rotateTo(polygon,startIndex):
    out = []
    for i in range(len(polygon)):
        out.append(polygon[mod(startIndex+i,len(polygon))])
    return tuple(out)
    
def mod(x,y):
    z = x % y
    if z < 0:
        return z + y
    else:
        return z
        
    
def mergePolygons(polygons):
    out = set()
    for p in polygons:
        if signedAreaTriangle(p)>0:
            merged = True
            while merged:
                merged = False
                for q in out:
                    for i in range(len(p)):
                        for j in range(len(q)):
                            matchCount = 0
                            for k in range(len(q)):
                                if p[mod(i+k,len(p))] == q[mod(j-k,len(q))]:
                                    matchCount += 1
                                else:
                                    break
                            if matchCount >= 2:
                                p = rotateTo(p,i+matchCount-1)[:len(p)-matchCount+1] + rotateTo(q,j-matchCount+1)[matchCount-1:]
                                out.remove(q)
                                merged = True
                                break
                        if merged:
                            break
                    if merged:
                        break
            out.add(tuple(p))
    return out

def toSVG(polygons3D, axis, eps=1e-6):
    svgArray = []
    layered = "l" in axis
    if axis[0] == 'x':
        zAxis = 0
    elif axis[0] == 'y':
        zAxis = 1
    elif axis[0] == 'z':
        zAxis = 2
    xAxis = (zAxis+1) % 3
    yAxis = (zAxis+2) % 3
    
    zValues = set()
    if layered:
        for polygon in polygons3D:
            for v in polygon:
                z1 = v[zAxis]
                for z in zValues:
                    if abs(z1-z)<=eps:
                        break
                else:
                    zValues.add(z1)
    else:
        zValues.add(None)
        
    polygons = project(polygons3D, xAxis, yAxis, zAxis, None, eps=eps)
    minX = min(min(v[0] for v in polygon) for polygon in polygons)
    minY = min(min(v[1] for v in polygon) for polygon in polygons)
    maxX = max(max(v[0] for v in polygon) for polygon in polygons)
    maxY = max(max(v[1] for v in polygon) for polygon in polygons)
    minX -= 10
    minY -= 10
    maxX += 10
    maxY += 10
    
    svgArray.append('<?xml version="1.0" standalone="no"?>')
#    svgArray.append('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">')
    svgArray.append('<svg width="%fmm" height="%fmm" viewBox="%f %f %f %f" xmlns="http://www.w3.org/2000/svg" version="1.1">'%(maxX-minX,maxY-minY,minX,minY,maxX-minX,maxY-minY))

    for z in zValues:
        polygons = project(polygons3D, xAxis, yAxis, zAxis, z, eps=eps)
        
        if layered:
            polygons = mergePolygons(polygons)
        
        if z is not None:
            svgArray.append('<!-- %f -->' % z)
            
        for polygon in polygons:
            points = " ".join(("%f,%f" % v for v in polygon))
            svgArray.append('<polygon points="%s" fill="none" stroke="black" stroke-width="0.1"/>' % points)
                
    svgArray.append('</svg>')
    return '\n'.join(svgArray)

if __name__ == '__main__':
    print(toSVG(loadMesh(argv[1]), 'z' if len(argv) < 3 else argv[2]))
    