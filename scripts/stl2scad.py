from loadmesh import loadMesh
from sys import argv, stderr

def toSCAD(polygons):
    scad = []
    scad.append('module stlObject1() {polyhedron(')
    scad.append(' points=[')
    
    minDimension = min( max(max(v[i] for v in polygon) for polygon in polygons) - 
        min(min(v[i] for v in polygon) for polygon in polygons) for i in range(3))
        
    def fix3(v):
        return tuple(x if abs(x) > 1e-7 * minDimension else 0. for x in v)
    
    stderr.write("Getting points.\n" )
    pointDict = {}
    points = []
    for polygon in polygons:
        for v in polygon:
            vv = fix3(v)
            if vv not in pointDict:
                pointDict[vv] = len(points)
                points.append(vv)
    m = [min((v[i] for v in points)) for i in range(3)]
    M = [max((v[i] for v in points)) for i in range(3)]
    sizes = [M[i]-m[i] for i in range(3)]
    m[0] = .5*(m[0]+M[0]) # center x
    for v in points:
        scad.append('  [%.7g,%.7g,%.7g],' % tuple((v[i]-m[i] for i in range(3))))

    scad.append(' ],')
    scad.append(' faces=[')
    stderr.write("Getting faces.\n" )
    for polygon in polygons:
        p = '  ['
        for v in polygon:
            vv = fix3(v)
            p += '%d,' % pointDict[vv]
        scad.append(p+'],')
    scad.append(' ]);')
    scad.append('}')
    scad.append('stlObject1_size=[%.7g,%.7g,%.7g];' % tuple(sizes))
    scad.append('stlObject1();')
    stderr.write("Joining.\n" )
    return '\n'.join(scad)
    
if __name__ == '__main__':
    print(toSCAD(loadMesh(argv[1], reverseTriangles=True)))
       