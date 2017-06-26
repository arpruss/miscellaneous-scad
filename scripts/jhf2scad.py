class JHFGlyph(object):
    def __init__(self, jhfGlyph):
        self.vertexCount = int(jhfGlyph[5:8].strip()) - 1
        self.left = JHFGlyph.toNumeric(jhfGlyph[8])
        self.right = JHFGlyph.toNumeric(jhfGlyph[9])
        self.width = self.right-self.left
        self.lines = []
        line = []
        for i in range(self.vertexCount):
            vv = jhfGlyph[10+2*i:10+2*i+2]
            if vv == ' R':
                self.lines.append(line)
                line = []
            else:
                line.append((-self.left+JHFGlyph.toNumeric(vv[0]), -JHFGlyph.toNumeric(vv[1])))
        if line:
            self.lines.append(line)

    @staticmethod
    def toNumeric(c):
        return ord(c)-ord('R')

def loadJHF(name):
    glyphs = {}
    with open(name) as f:
        for i in range(32,127):
            glyphs[chr(i)] = JHFGlyph(f.readline())
    return glyphs

if __name__ == '__main__':
    import sys
    import os
    
    fonts = []

    for fname in sys.argv[1:]:
        font = loadJHF(fname)
        name = os.path.splitext(fname)[0]
        fonts.append(name)

        Tsize = max(max(point[1] for point in stroke) for stroke in font['T'].lines)-min(min(point[1] for point in stroke) for stroke in font['T'].lines)
        
        scale=1./Tsize
        
        out = []
        for i in range(32,127):
            c = chr(i)
            try:
                glyph = font[c]
            except:
                glyph = font[' ']
            if c=='"' or c=='\\':
                outGlyph = '["\\%s",' % c 
            else:
                outGlyph = '["%s",' % c 
            outGlyph += '%.3f,[' % (glyph.width*scale)
            
            outLines = []
            for stroke in glyph.lines:
                prev = None
                for point in stroke:
                    if prev is not None:
                        outLines.append( '[[%.3f,%.3f],[%.3f,%.3f]]' % tuple(scale*x for x in (prev+point)) )
                    prev = point
            outGlyph += ','.join(outLines) + ']]'
            out.append(outGlyph)
            
        print('%s=[\n%s\n];\n' % (name, ',\n'.join(out)))
        
    fonts = tuple(sorted(fonts));
    print('hersheyFonts=[' + ','.join('["%s", %s]' % (f,f) for f in fonts) +'];\n');
    print('hersheyFontNames=[' + ','.join('"'+f+'"' for f in fonts) +'];\n');
    print('// Use the following in customizers:')
    print('//hersheyFont=0; // [' + ', '.join("%d:%s" % (i,f) for i,f in enumerate(fonts)) + ']')
    
    with open('hersheyrender.scad') as f:
        for line in f:
            print(line.rstrip())
    