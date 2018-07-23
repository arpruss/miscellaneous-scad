import struct

def loadMesh(filename, reverseTriangles=False):
    triangles = []
    
    with open(filename, "rb") as f:
         header = f.read(5)
         if header.startswith(b"solid"):
             triangle = None
             for line in f:
                line = line.strip()
                if line.startswith(b'endfacet'):
                    if triangle is not None:
                        triangles.append(tuple(triangle))
                        triangle = None
                elif line.startswith(b'facet'):
                    triangle = []
                elif triangle is not None and line.startswith(b'vertex'):
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
                    
    # reverse triangles for openSCAD benefit
    
    if reverseTriangles:
        return [(t[2],t[1],t[0]) for t in triangles]
    else:
        return triangles
