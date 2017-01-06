import svgpath.parser as parser
import sys
import os

def getPoly(svgTree,precision=0.01,colorExtract=None):

    def colorMatches(c1,c2):
        if c1 is None or c2 is None:
            return c1 is c2
        return max(abs(c1[i]-c2[i]) for i in range(3)) < 0.5/255
        
    def findHorizon(paths, y0, y1):
        bestDistance = float("inf")
        bestY = 0
        for path in paths:
            if colorMatches(path.svgState.stroke, (0,1,0)):
                start = path.point(0)
                if y0 <= start.imag <= y1 or y1 <= start.imag <= y0:
                    return start.imag
                distance = min(abs(start.imag-y0),abs(start.imag-y1))
                if distance < bestDistance:
                    bestDistance = distance
                    bestY = start.imag
        assert bestDistance < float("inf")
        return bestY

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
    
    x0 = min(min(l.start.real,l.end.real) for l in approx)
    y0 = min(min(l.start.imag,l.end.imag) for l in approx)
    y1 = max(max(l.start.imag,l.end.imag) for l in approx)
    try:
        horizon = findHorizon(paths, y0, y1)
    except AssertionError:
        horizon = 0.5 * (y0 + y1)

    for i in range(len(approx)):
        l = approx[i]
        if i == 0:
            yield (l.start.real-x0,l.start.imag-horizon)
        yield (l.end.real-x0,l.end.imag-horizon)
    
if __name__=='__main__':
        
    name = os.path.splitext(os.path.basename(sys.argv[1]))[0]
    
    svgTree = ET.parse(sys.argv[1]).getroot()
    strPoints = ','.join(( ('[%.3f,%.3f]'%p) for p in getPoly(svgTree)))

    print('poly_'+name+'=['+strPoints + '];');
