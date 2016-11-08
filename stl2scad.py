from stl2svg import loadMesh
from sys import argv

def toSCAD(polygons):

    scad = []
    scad.append('module stlObject1() {polyhedron(')
    scad.append(' points=[')
    
    minDimension = min( max(max(v[i] for v in polygon) for polygon in polygons) - 
        min(min(v[i] for v in polygon) for polygon in polygons) for i in range(3))
        
    def fix3(v):
        return tuple(x if abs(x) > 1e-7 * minDimension else 0. for x in v)
    
    points = []
    for polygon in polygons:
        for v in polygon:
            vv = fix3(v)
            if vv not in points:
                points.append(vv)
                scad.append('  [%.7g,%.7g,%.7g]' % vv)
    scad.append(' ],')
    scad.append(' faces=[')
    for polygon in polygons:
        p = '  ['
        for v in polygon:
            vv = fix3(v)
            p += '%d,' % points.index(vv)
        scad.append(p+'],')
    scad.append(' ]);')
    scad.append('}')
    scad.append('stlObject1();')
    return '\n'.join(scad)
    
if __name__ == '__main__':
    print(toSCAD(loadMesh(argv[1])))
       