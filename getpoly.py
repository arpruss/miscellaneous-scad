import xml.etree.ElementTree as ET
import svgpath.parser as parser
import sys
import os

def getpoly(filename,precision=0.01):
    with open(filename) as f:
        data = f.read()
        
    svgTree = ET.fromstring(data)
    assert 'svg' in svgTree.tag

    path = parser.getPathsFromSVG(svgTree)[0][0]
    approx = path.linearApproximation(error=precision)

    left = min(min(l.start.real,l.end.real) for l in approx)
    right = max(max(l.start.real,l.end.real) for l in approx)
    bottom = min(min(l.start.imag,l.end.imag) for l in approx)

    sx = 1./(right-left)

    def scale(z):
        return ((z.real-left)*sx,(z.imag-bottom)*sx)

    for i in range(len(approx)):
        l = approx[i]
        if i == 0:
            yield scale(l.start)
        yield scale(l.end)
    
if __name__=='__main__':
        
    name = os.path.splitext(os.path.basename(sys.argv[1]))[0]
    
    strPoints = ','.join(( ('[%.3f,%.3f]'%p) for p in getpoly(sys.argv[1])))

    print('poly_'+name+'=['+strPoints + '];');
