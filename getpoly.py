import xml.etree.ElementTree as ET
import svgpath.parser as parser
import sys
import os

def getpoly(filename,precision=0.01,colorExtract=None):

    def colorMatches(c1,c2):
        if c1 is None or c2 is None:
            return c1 is c2
        return max(abs(c1[i]-c2[i]) for i in range(3)) < 0.5/255

    with open(filename) as f:
        data = f.read()
        
    svgTree = ET.fromstring(data)
    assert 'svg' in svgTree.tag
    
    paths = parser.getPathsFromSVG(svgTree)[0]

    if colorExtract is None:
        path = paths[0]
    else:
        path = None
        for p in paths:
            if colorMatches(p.svgState.stroke, colorExtract):
                path = p

    assert path != None
    
    approx = path.linearApproximation(error=precision)

    for i in range(len(approx)):
        l = approx[i]
        if i == 0:
            yield (l.start.real,l.start.imag)
        yield (l.end.real,l.end.imag)
    
if __name__=='__main__':
        
    name = os.path.splitext(os.path.basename(sys.argv[1]))[0]
    
    strPoints = ','.join(( ('[%.3f,%.3f]'%p) for p in getpoly(sys.argv[1])))

    print('poly_'+name+'=['+strPoints + '];');
