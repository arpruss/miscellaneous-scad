from knot import Vector

# triangulation algorithm based on https://www.geometrictools.com/Documentation/TriangulationByEarClipping.pdf
# minus all the double-linked list stuff that would be great but I am not bothering with it

def cross_z(a,b):
    # z-component of cross product
    return a.x * b.y - a.y * b.x

def pointInside(p,a,b,c):
    c1 = cross_z(p-a, b-a)
    c2 = cross_z(p-b, c-b)
    if c1 * c2 < 0:
        return False
    c3 = cross_z(p-c, a-c)
    return c1 * c3 >= 0 and c2 * c3 >= 0
    
def triangulate(polygon):
    # assume input polygon is counterclockwise
    n = len(polygon)

    if n < 3:
        raise Exception
    
    # two efficient special cases
    if n == 3:
        return [[0,1,2]]
    elif n == 4:
        return [[0,1,2],[1,2,3]]
    
    triangles = []
    polygon = polygon[:]
    
    index = list(range(n))
    
    def isReflex(i):
        return cross_z(polygon[i]-polygon[i-1], polygon[(i+1) % n]-polygon[i]) < 0
        
    reflex = [isReflex(i) for i in range(n)]
    
    def isEar(i):
        if reflex[i]:
            return False
        a,b,c = polygon[i-1],polygon[i],polygon[(i+1) % n]
        j = i+2
        while j % n != (i-1) % n:
            if reflex[j % n] and pointInside(polygon[j % n],a,b,c):
                return False
            j += 1
        return True
        
    ear = [isEar(i) for i in range(n)]
    
    while n >= 3:
        i = 0
        foundEar = False
        for i in range(n):
            if ear[i]:
                triangles.append([index[i-1],index[i],index[(i+1) % n]])
                # TODO: less deleting!
                del polygon[i]
                del reflex[i]
                del ear[i]
                del index[i]
                n -= 1
                if reflex[i-1]:
                    reflex[i-1] = isReflex(i-1)
                if reflex[i % n]:
                    reflex[i % n] = isReflex(i)
                if not reflex[i-1]:
                    ear[i-1] = isEar(i-1)
                if not reflex[i % n]:
                    ear[i % n] = isEar(i)
                foundEar = True
                break
            
        assert foundEar
        
    return triangles
    
def polygonsToSVG(vertices, polys):
    minX = min(v.x for v in vertices)
    minY = min(v.y for v in vertices)
    maxX = max(v.x for v in vertices)
    maxY = max(v.y for v in vertices)

    svgArray = []
    svgArray.append('<?xml version="1.0" standalone="no"?>')
    svgArray.append('<svg width="%fmm" height="%fmm" viewBox="0 0 %f %f" xmlns="http://www.w3.org/2000/svg" version="1.1">'%(maxX-minX,maxY-minY,maxX-minX,maxY-minY))
    svgArray.append('\n')
    for p in polys:
        for i in range(len(p)):
            svgArray.append('<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="black" stroke-width="0.15px"/>' % 
                (vertices[p[i-1]].x-minX,vertices[p[i-1]].y-minY,vertices[p[i]].x-minX,vertices[p[i]].y-minY))
    svgArray.append('</svg>')
    return '\n'.join(svgArray)
    
if __name__ == '__main__':
    poly = [Vector(0,0),Vector(50,80),Vector(100,0),Vector(100,100),Vector(0,100)]
    print polygonsToSVG( poly, triangulate(poly) )
    