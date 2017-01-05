import xml.etree.ElementTree as ET
import svgpath.parser as parser
import sys

with open(sys.argv[1]) as f:
    data = f.read()
    
svgTree = None    
    
svgTree = ET.fromstring(data)
assert 'svg' in svgTree.tag

path = parser.getPathsFromSVG(svgTree)[0][0]
approx = path.linearApproximation(error=0.01)

left = min(min(l.start.real,l.end.real) for l in approx)
right = max(max(l.start.real,l.end.real) for l in approx)
bottom = min(min(l.start.imag,l.end.imag) for l in approx)

sx = 1./(right-left)

points = []

out = 'poly=[';

def scale(z):
    return (z.real-left)*sx,z.imag-bottom

for i in range(len(approx)):
    l = approx[i]
    if i == 0:
        out += '[%.2f,%.2f],' % scale(l.start)
    out += '[%.2f,%.2f],' % scale(l.end)
    
out += '];\n'
print(out);
