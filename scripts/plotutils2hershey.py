from os import popen
from math import floor

map="""HersheySerif-Bold SerifBold timesrb rowmant
HersheySerif Serif timesr
HersheySerif-BoldItalic SerifBoldItalic timesib 
HersheySerif-Italic SerifItalic timesi
HersheySans Sans futural rowmans
HersheySans-Bold SansBold futuram rowmand
HersheySans-BoldOblique SansBoldOblique SansBoldItalic
HersheyScript Script scripts cursive
HersheyScript-Bold ScriptBold scriptc
HersheyGothicEnglish GothicEnglish gothiceng gothgbt
HersheyGothicItalian GothicItalian gothicita gothitt
HersheyGothicGerman GothicGerman gothicger gothgrt"""

synonyms = {}
fonts = {}
prefix = "hershey"
testChar = 'T'
scale = 1000

def floatFormat(x,precision=3):
    s = "%.*f" % (precision,x)
    if "e" in s or "." not in s:
        return s
    s = s.rstrip("0").rstrip(".")
    if s[:2] == "0.":
        return s[1:]
    elif s[:2] == "-0.":
        return "-"+s[1:]
    elif s == "-0":
        return "0"
    else:
        return s

def scaleFormat(x):
    return "%.0f" % (scale*x)
        
def parseFig(files):

    def getNumbers(n):
        numbers = []
        while len(numbers) < n:
            numbers += (float(x) for x in f.readline().rstrip().split())
        return numbers

    def getSegments(n, closed):
        data = getNumbers(2*n)
        segments = []
        for i in range(n-1):
            segments.append(((data[2*i],data[2*i+1]),(data[2*i+2],data[2*i+3])))
        if closed:
            segments.append(((data[-2],data[-1]),(data[0],data[1])))
        return segments

    data = {}
    charNumbers = []
    charSegments = []
    charExtents = []
    curSegments = []
    
    for f in files:
        haveNumber = False
        header = 8
        while True:
            line = f.readline()
            if not line:
                break
            line = line.rstrip()
            if line[0] == '#' or line[0] == ' ':
                continue
            if header:
                header -= 1
                continue
            d = line.split()
            if d[0] == "4":
                label = d[13].split("\\")[0]
                if label[0].isdigit():
                    charNumbers.append(int(label))
                    haveNumber = True
            elif haveNumber and d[0] == "2" and (d[1] == "1" or d[1] == "3"):
                n = int(d[15])
                segments = getSegments(n, d[1] == "3")
                if d[1] == "1" and d[2] == "2" and n == 2:
                    if charExtents and len(charExtents[-1]) == 1:
                        charExtents[-1].append(segments[0][1])
                        charSegments.append(curSegments)
                        curSegments = []
                    else:
                        charExtents.append([segments[0][0]])
                else:
                    curSegments += segments

    assert(len(charNumbers) == len(charExtents) == len(charSegments))
    testIndex = charNumbers.index(ord(testChar))
    minY,maxY = ((func(s[i][1] for s in charSegments[testIndex] for i in range(2)) for func in (min,max)))
    baseline = maxY - charExtents[testIndex][0][1]
    scale = 1. / (maxY - minY)
    
    def mapSegments(f,segments):
        return tuple( (f(s[0]),f(s[1])) for s in segments )
       
    for i in range(len(charNumbers)):
        data[charNumbers[i]] = ((charExtents[i][1][0]-charExtents[i][0][0])*scale, mapSegments(
                        lambda p : (scale*(p[0]-charExtents[i][0][0]),scale*(baseline-(p[1]-charExtents[i][0][1]))), charSegments[i]))                        
                        
    return data
                        
def dumpFont(data):
    def describeChar(c):
        if c < 127:
            c = chr(c)
            if c == '"' or c == '\\':
                return '"\\' + c + '"'
            else:
                return '"' + c + '"'
        else:
            return '"\\u%04x"' % c
            
    def describeSegments(segments):
        out = ""
        lastPoint = None
        ss = []
        curSeg = []
        for s in segments:
            if tuple(s[0]) != lastPoint:
                if curSeg:
                    ss.append("["+(",".join(curSeg))+"]")
                    curSeg = []
                curSeg.append("%s,%s" % (scaleFormat(s[0][0]),scaleFormat(s[0][1])))
            curSeg.append("%s,%s" % (scaleFormat(s[1][0]),scaleFormat(s[1][1])))
            lastPoint = tuple(s[1])
        if curSeg:
            ss.append("["+(",".join(curSeg))+"]")
        return ",".join(ss)
                            
    out = []
    for c in sorted(data):
        width,segments = data[c]
        out.append( "[%s,%s,_segmentUnpack([%s])]" % (describeChar(c),floatFormat(width),describeSegments(segments)) )
    print( ",\n". join(out))

for line in map.split("\n"):
    s = line.strip().split()
    fonts[s[1]] = s[0]
    synonyms[s[1]] = s[2:]
            
sfonts = sorted(fonts)            
for font in sfonts:
    with popen("plotfont --box -T fig -1 %s" % fonts[font]) as lower:
        with popen("plotfont --box -T fig -2 %s" % fonts[font]) as upper:
            data = parseFig((lower,upper))
            print(prefix + font + " = [")
            dumpFont(data)
            print("];\n")

print('hersheyFonts=[' + ','.join('["%s", %s]' % (f,prefix+f) for f in sfonts) + "];\n");
print('hersheyFontsWithSynonyms=[' + ','.join('["%s", %s]' % (g,prefix+f) for f in sfonts for g in [f]+synonyms[f]) +'];\n');
print('hersheyFontNames=[' + ','.join('"%s"' % f for f in sfonts) +'];\n');
print('// Use the following in customizers:')
print((('//hersheyFont=%d; // [') % sfonts.index("Sans")) + ', '.join("%d:%s" % (i,f) for i,f in enumerate(sfonts)) + ']')
print("""
function _isString(s) = s >= "";

function findHersheyGlyph(c, font) =
    let(g=font[search(c, font, 1, 0)[0]])
    g==undef?font[0]:g;

function findHersheyFont(name) =
    _isString(name) ? (
    let(f1 = hersheyFontsWithSynonyms[search([name], hersheyFontsWithSynonyms, index_col_num=0)[0][0]][1])
    f1 == undef ? hersheySerif : f1 ) : name;

function widthHersheyText(text,font=font,size=10,extraSpacing=0,start=0,soFar=0) =
    _isString(font) ? widthHersheyText(text,font=findHersheyFont(font),size=size,extraSpacing=extraSpacing) :
    start<len(text) ? widthHersheyText(text,font=font,size=size,extraSpacing=extraSpacing, start=start+1,soFar=soFar+extraSpacing+size*findHersheyGlyph(text[start],font=font)[1]) : soFar;
    
function subdivideLine(line,subdivisions=0) =
    let(delta=line[1]-line[0],
        l=norm(delta))
    l*subdivisions <= 1 ? [line] :
    let(n=ceil(l*subdivisions)) 
    [for(i=[1:n]) 
        let(t0=(i-1)/n, t=i/n)
        [(1-t0)*line[0]+t0*line[1],(1-t)*line[0]+t*line[1]]];
    
function getHersheyGlyphLines(glyph,size=10,subdivisions=0) =
    size*[for(line=glyph[2]) 
        for(sub=subdivideLine(line,subdivisions=subdivisions))
            [sub[0],sub[1]]];      
        
module drawHersheyGlyph(glyph,size=10) {
    for (line=glyph[2]) {
        hull() {
            translate(size*line[0]+size*[0,.5]) children();
            translate(size*line[1]+size*[0,.5]) children();
        }
    }
}

function _segmentUnpack(data) =
    [for(seg=data) let(i=0)for(i=[0:2:len(seg)-3]) [[seg[i],seg[i+1]],[seg[i+2],seg[i+3]]]]/%.0f;

function cross2D(a,b) = a[0]*b[1]-a[1]*b[0];

function pointLeftOfLineSegment2D(v,line) =
    cross2D(line[1]-line[0],v-line[0]) > 0;

// do the two lines meet in a plus sign?
function plusSignish2D(line1,line2) =
    pointLeftOfLineSegment2D(line1[0],line2) !=
      pointLeftOfLineSegment2D(line1[1],line2) &&
    pointLeftOfLineSegment2D(line2[0],line1) !=
      pointLeftOfLineSegment2D(line2[1],line1);
      
function pointToLineDistance(v,line) =
    let(dir = line[1]-line[0],
        l = norm(dir))
        l == 0 ? norm(v-line[0]) :
            let(p = (v-line[0])*dir/(l*l))
            p <= 0 ? norm(v-line[0]) :
            p >= 1 ? norm(v-line[1]) :
            norm(v-(line[0]+p*dir));
             
function distanceBetweenLineSegments2D(line1,line2)
    = plusSignish2D(line1,line2) ? 0 :
        min(pointToLineDistance(line1[0],line2),
            pointToLineDistance(line1[1],line2),
            pointToLineDistance(line2[0],line1),
            pointToLineDistance(line2[1],line1));

function infinity() = 1e200 * 1e200;

function distanceBetweenStrokes2D(s1,s2) =
    min( [for(i=[1:len(s1)-1]) for(j=[1:len(s2)-1]) distanceBetweenLineSegments2D([s1[i-1],s1[i]],[s2[i-1],s2[i]])] );

function distanceBetweenLineDrawings2D(d1,d2)
    = 
    len(d1) == 0 || len(d2) == 0 ? infinity() :
    min( [for(s1=d1) for(s2=d2) distanceBetweenStrokes2D(s1,s2)] );

function shiftDrawing(vector,drawing) =
    [for(stroke=drawing) [for(p=stroke) vector+p]];

// tail recursion
function iterateToAutoDistance(drawing1,drawing2,minimumDistance,w,precision=0.1) =
    w <= 0 ? 0 :
    distanceBetweenLineDrawings2D(drawing1,shiftDrawing([w,0],drawing2)) <= minimumDistance ? w : iterateToAutoDistance(drawing1,drawing2,minimumDistance,w-precision,precision=precision);

function getAutoDistance(glyph,nextGlyph,minimumDistance,precision=0.1) =
    len(glyph[2]) == 0 || len(nextGlyph[2]) == 0 ? glyph[1] :
    iterateToAutoDistance(glyph[2],nextGlyph[2],minimumDistance,glyph[1],precision=precision);
    
function cumulativeSums(data,soFar=[]) =
    len(soFar)>=len(data)+1 ? soFar :
    len(soFar)==0 ? cumulativeSums(data,soFar=[0]) :
    cumulativeSums(data,
        concat(soFar,[ data[len(soFar)-1]+soFar[len(soFar)-1] ]));
        
function translateLines(delta,list) = [for (a=list) [delta+a[0],delta+a[1]]];
    
function getLinesBounds(lines,coordinate) = 
    let(yy=[for(line=lines) for(i=[0:1]) line[i][coordinate]]) [min(yy),max(yy)];
        
function getHersheyTextLines(text,font="timesr",halign="left",valign="baseline",size=10,extraSpacing=0,forceMinimumDistance=undef,minimumDistancePrecision=0.1,subdivisions=0) =
    let(f = findHersheyFont(font),
    glyphs=[for (i=[0:len(text)-1]) findHersheyGlyph(text[i],f)],
    widths=
        forceMinimumDistance==undef ? [for (g=glyphs) g[1]*size+extraSpacing] :
            [for (i=[0:len(glyphs)-1]) 
                extraSpacing + (
                    i==len(glyphs)-1 ? glyphs[i][1]*size :
                    size*getAutoDistance(glyphs[i],glyphs[i+1],forceMinimumDistance/size,precision=minimumDistancePrecision/size) )],

    cWidths=cumulativeSums(widths),
    width=cWidths[len(cWidths)-1],
    offsetX =
        halign=="center" ? -0.5*width :
        halign=="right" ? -width :
        0,
    glyphLines = [for(i=[0:len(text)-1]) for(line=translateLines([offsetX+cWidths[i],0],getHersheyGlyphLines(glyphs[i],size=size,subdivisions=subdivisions))) line],
    vertBounds = getLinesBounds(glyphLines,1),
    offsetY =
        valign=="bottom" ? -vertBounds[0] :
        valign=="top" ? -vertBounds[1] :
        valign=="center" ? -0.5*(vertBounds[0]+vertBounds[1]) :
                0 // baseline
    ) translateLines([0,offsetY],glyphLines);
    
module drawHersheyText(text,font="Serif",halign="left",valign="baseline",size=10,extraSpacing=0,forceMinimumDistance=undef,minimumDistancePrecision=0.1) {
    lines=getHersheyTextLines(text,font=font,halign=halign,valign=valign,size=size,extraSpacing=extraSpacing,forceMinimumDistance=forceMinimumDistance,minimumDistancePrecision=minimumDistancePrecision,subdivisions=0);
    for (line=lines) 
        hull() {
            translate(line[0]) children();
            translate(line[1]) children();
        }
}

module demo() {
    for (i=[0:len(hersheyFonts)-1]) {
        translate([0,15*i])
        drawHersheyText(hersheyFontNames[i], font=hersheyFontNames[i], extraSpacing=0.5,valign="baseline")
    cylinder(r1=0.5,r2=0,h=2,$fn=8);
    }
}

//demo();
""" % scale)
