from sys import argv
from loadmesh import *

def project(polygons, xAxis, yAxis):
    return [tuple( (v[xAxis], v[yAxis]) for v in polygon ) for polygon in polygons]

def toSVG(polygons, axis):
    svgArray = []
    if axis == 'x':
        axis = 0
    elif axis == 'y':
        axis = 1
    elif axis == 'z':
        axis = 2
    xAxis = (axis+1) % 3
    yAxis = (axis+2) % 3
    polygons = project(polygons, xAxis, yAxis)
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
    svgArray.append('<svg width="%fmm" height="%fmm" viewBox="0 0 %f %f" xmlns="http://www.w3.org/2000/svg" version="1.1">'%(maxX-minX,maxY-minY,maxX-minX,maxY-minY))
    svgArray.append('\n')
    for polygon in polygons:
        n = len(polygon)
        for i in range(n):
            v1 = polygon[i]
            v2 = polygon[(i+1)%n]
            svgArray.append('<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="black" stroke-width="0.15"/>\n' % (v1[0]-minX,v1[1]-minY,v2[0]-minX,v2[1]-minY))
    svgArray.append('</svg>')
    return ''.join(svgArray)

if __name__ == '__main__':
    print(toSVG(loadMesh(argv[1]), 'z' if len(argv) < 3 else argv[2]))
    