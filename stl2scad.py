from stl2svg import loadMesh
from sys import argv

def toSCAD(polygons):
    scad = []
    scad.append('module stlObject1() {polyhedron(')
    scad.append(' points=[')
    points = []
    for polygon in polygons:
        for v in polygon:
            vv = tuple(v)
            if vv not in points:
                points.append(vv)
                scad.append('  [%f,%f,%f],' % vv)
    scad.append(' ],')
    scad.append(' faces=[')
    for polygon in polygons:
        p = '  ['
        for v in polygon:
            vv = tuple(v)
            p += '%d,' % (points.index(vv),)
        scad.append(p+'],')
    scad.append(' ]);')
    scad.append('}')
    scad.append('stlObject1();')
    return '\n'.join(scad)
    
if __name__ == '__main__':
    print(toSCAD(loadMesh(argv[1])))
       