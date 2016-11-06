from sys import argv
import struct

def loadMesh(filename):
    triangles = []
    
    with open(filename, "rb") as f:
         header = f.read(5)
         
         if not header.startswith(b"solid"):
             triangle = None
             for line in f:
                line = line.strip()
                if line.startswith('endfacet'):
                    if triangle is not None:
                        triangles.append(tuple(triangle))
                        triangle = None
                elif line.startswith('facet'):
                    triangle = []
                elif triangle is not None and line.startswith('vertex'):
                    triangle.append(tuple(float(x) for x in line.split()[1:4]))
             if not triangles:
                f.seek(5)
         if not triangles:
             header = f.read(75)
             assert len(header) == 75
         
             numTriangles = struct.unpack("<I", f.read(4))[0]
             
             for i in range(numTriangles):
                assert len(f.read(12))==12 # skip normal
                triangles.append(tuple( struct.unpack("<3f", f.read(12)) for i in range(3)) )
                attribute = struct.unpack("<H", f.read(2))[0]
                if attribute & 0x8000:
                    r = int(( ( attribute >> 10 ) & 0x1F ) / 31. * 255)
                    g = int((( attribute >> 5 ) & 0x1F ) / 31. * 255)
                    b = int( ( attribute & 0x1F ) / 31. * 255)
                else:
                    r = 0
                    g = 0
                    b = 0

    return triangles
        
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
    