import xml.etree.ElementTree as ET
from makewing import *
    
if __name__ == '__main__':
    svgTree = ET.parse(sys.argv[1]).getroot()

    span = 100

    airfoil = getPoly(svgTree, colorExtract=(0,0,0), precision=.1)
    topView = getPoly(svgTree, colorExtract=(1,0,0), precision=.1)
    sideView = getPoly(svgTree, colorExtract=(0,0,1), precision=.1)
    print('count=3;')
    print('hubRadius = 8;')
    print('hubFeather = 3;')
    print('hollowOutFraction=0.5;')
    print('skinThickness=2;')
    print('span = %.3f;\n' % span)
    print('inwardOffset = 0;\n')
    print('module dummy(){}\n')
    points,faces = makeWingFromPolys(airfoil, topView, sideView, span, slices=30)
    print(('points = span/%.3f * '+stringPointArray(points)+';\n') % span)
    print('faces = '+stringFaceArray(faces)+';\n')
    print("""

module wing() {
  polyhedron(points=points, faces=faces);
}

function getMaxZWithin(p, hubRadius) = max([ for(i=[0:len(p)]) if (p[i][0]*p[i][0]+p[i][1]*p[i][1] <= hubRadius*hubRadius) p[i][2]]);

module boom() {
  for(i=[0:count-1]) {
    rotate([0,0,360.*i/count]) translate([-inwardOffset,0,0]) wing();
  }
  cylinder(h=getMaxZWithin(points,hubRadius+inwardOffset),r1=hubRadius+hubFeather,r2=hubRadius);
}

module insideBoom(offset=1) {
    intersection() {
        deltas = [[0,0,0],[-1,0,0],[1,0,0],[0,-1,0],[0,1,0],[0,0,-1],[0,0,1]];
        intersection_for(i=[0:len(deltas)-1]) translate(deltas[i]) boom();
    }
}
    
height = getMaxZWithin(points, 1.25*span);

if (hollowOutFraction>0) {
    difference() {
        boom();
        intersection() {
            insideBoom(offset=skinThickness);
            cylinder(r=hollowOutFraction*(span-inwardOffset),h=height);
        }
    }
}
else {
    boom();
}

""")
    
  