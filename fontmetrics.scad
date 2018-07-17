include <fontmetricsdata.scad>;

// begin MIT licensed code (c) 2018 Alexander Pruss
BOLD = 1;
ITALIC = 2;
CONDENSED = 32;
ASCENDER_TO_EM = 1510/2048; 
METRICS_ADJUST = 1.0255; // this adjusts metrics a little bit to match OpenSCAD -- I don't know why this is needed

_XADVANCE = 1;
_LSB = 2;
_XMIN = 3;
_YMIN = 4;
_XMAX = 5;
_YMAX = 6;
_KERN = 7;


function fontScale(f) = 1 / (ASCENDER_TO_EM * f[3]);

function _isString(v) = v >= "";
function _isVector(v) = !(v>="") && len(v) != undef;
function _isFloat(v) = v+0 != undef;

function startswith(a,b,offset=0,position=0) =
    len(a)-offset < len(b) ? false : 
    position >= len(b) ? true :
    a[offset+position] != b[position] ? false :
    startswith(a,b,offset=offset,position=position+1);

function findsubstring(a,b,position=0) =
    len(a)-position < len(b) ? -1 :
    startswith(a,b,offset=position) ? position :
    findsubstring(a,b,position=position+1);
    
function style(a,b,n) =
    findsubstring(a,b) >= 0 ? n : 0;
    
function substring(a,start,end=undef,soFar="") =
    start >= len(a) || (end != undef && start >= end) ? soFar :
    substring(a,start+1,end=end,soFar=str(soFar,a[start]));
    
function lowercaseChar(c) = 
    c < "A" || c > "Z" ? c :
    chr(search(c,"ABCDEFGHIJKLMNOPQRSTUVWXYZ")[0]+97);
    
function lowercase(s,start=0,soFar="") =
    start >= len(s) ? soFar :
    lowercase(s,start=start+1,soFar=str(soFar,lowercaseChar(s[start])));
    
function styleNumber(s) = 
    style(s, "bold", BOLD) + 
    style(s, "italic", ITALIC) + 
    style(s, "oblique", ITALIC) +
    style(s, "condensed", CONDENSED);

function familyAndStyle(s) =
    let(lc=lowercase(s),
        n=findsubstring(lc,":style="))
    n < 0 ? [s, 0] :
    [substring(s,0,n), styleNumber(substring(lc,n+7))];
    
function findEntry(data, index) = data[search([index], data, 1, 0)[0]];
    
function findEntry_recursive(data, index, offset=0) =
    offset >= len(data) ? undef :
    data[offset][0] == index ? data[offset] :
    findEntry(data, index, offset=offset+1);
    
function findFont(fonts, s) = 
    _isString(s) ? findEntry(fonts, familyAndStyle(s)) : s;

function getGlyphInfo(font,char) =
    findEntry(font[4],char);

function measureWithFontAt(string,font,offset) =
    let(g=getGlyphInfo(font,string[offset]))
    g == undef ? 0 :
    offset + 1 >= len(string) ? g[1] : // at end of string
    let(kern=findEntry(g[_KERN], string[offset+1]))
    kern == undef ? g[1] :
    g[1] + kern[1];
    
function measureWithFont(string, font, offset=0, soFar=0) =
    offset >= len(string) ? soFar :
    measureWithFont(string,font,offset=offset+1,soFar=soFar+measureWithFontAt(string,font,offset));
    
function getOffsets(string, font, soFar=[0]) =
    len(soFar) >= len(string)+1 ? soFar :
    getOffsets(string, font, soFar=concat(soFar, [soFar[len(soFar)-1]+measureWithFontAt(string, font, offset=len(soFar)-1) ]));
    
function measureText(text="", font="Liberation Sans", size=10., spacing=1., fonts=FONTS) = 
    let(f=findFont(FONTS, font))
    spacing * size * fontScale(f) * measureWithFont(text, f);

function ascender(font="Liberation Sans", size=10., fonts=FONTS) =
    let(f=findFont(fonts, font))
    fontScale(f)*size*f[1]*METRICS_ADJUST;

function descender(font="Liberation Sans", size=10., fonts=FONTS) =
    let(f=findFont(fonts, font))
    fontScale(f)*size*f[2]*METRICS_ADJUST;
    
function maximizeGlyphMetric(text,f,mult,index,offset=0,soFar=-1e100) =
    len(text) == 0 ? 0 :
    offset >= len(text) ? soFar :
    maximizeGlyphMetric(text,f,mult,index,offset=offset+1,
        soFar=max(soFar,mult*getGlyphInfo(f, text[offset])[index]));
    
function measureTextDescender(text="", size=10, font="Liberation Sans", fonts=FONTS) = 
    let(f=findFont(fonts, font))
    -fontScale(f)*size*METRICS_ADJUST*maximizeGlyphMetric(text,f,-1,_YMIN);
    
//echo(getGlyphInfo(f, "a")[_

function measureTextAscender(text="", size=10, font="Liberation Sans", fonts=FONTS) = 
    let(f=findFont(fonts, font))
    fontScale(f)*size*METRICS_ADJUST*maximizeGlyphMetric(text,f,1,_YMAX);

function measureTextLeftBearing(text="", size=10, font="Liberation Sans", fonts=FONTS) = 
    len(text)==0 ? 0 : (
    let(f=findFont(fonts,font), 
        g=getGlyphInfo(f, text[0]))
    g == undef ? 0 : fontScale(f)*size*(METRICS_ADJUST*(g[_LSB]-g[_XMIN])+g[_XMIN]) );
    
function measureTextRightBearing(text="", size=10, font="Liberation Sans", fonts=FONTS) = 
    len(text)==0 ? 0 : (
    let(f=findFont(fonts, font),
        g=getGlyphInfo(findFont(fonts, font), text[len(text)-1]))
    g == undef ? 0 : fontScale(f)*size*(METRICS_ADJUST*(g[_XMAX]-g[_XMIN])+g[_XMIN]-g[_XADVANCE]) );
    
//returns [leftX,bottomY,width,height]
function measureTextBounds(text="", size=10, font="Liberation Sans",spacing=1,valign="left",halign="baseline",fonts=FONTS) = 
    len(text)==0 ? [0,0,0,0] : (
        let(f=findFont(fonts,font),
            w=measureText(text,size=size,font=f,spacing=spacing),
            asc=measureTextAscender(text,size=size,font=f),
            des=measureTextDescender(text,size=size,font=f),
            lsb=measureTextLeftBearing(text,size=size,font=f),
            rsb=measureTextRightBearing(text,size=size,font=f),
            dx=halign=="right"?-w:
               halign=="center"?-w/2:
               0,
            dy=valign=="top"?-asc:
               valign=="bottom"?-des:
               valign=="center"?-0.5*(asc+des):
               0)
        [lsb+dx,des+dy,w-lsb+rsb,asc-des]);
    
module drawText(text="", size=10, font="Liberation Sans", halign="left", valign="baseline", spacing=1, fonts=FONTS) {
    
    l = len(text);
    if (l>0) {
        sc = size < 20 ? size/20 : 1;
        adjSize = size < 20 ? 20 : size;
        f = findFont(fonts, font);
        offsetScale = spacing * adjSize * fontScale(f);
        offsets = getOffsets(text, f, size=adjSize);
        w = offsets[l];
        dx = halign=="right" ? -w :
             halign=="center" ? -w / 2 : 0;
        dy = valign=="top" ? -measureTextAscender(text, size=size, font=font) :
             valign=="bottom" ? -measureTextDescender(text, size=size, font=font) : 
             valign=="center" ? -0.5*(measureTextAscender(text, size=size, font=font)+measureTextDescender(text,size=size,font=font)) : 0;
        
        scale(sc) {
            for (i=[0:l-1]) {
                translate([offsetScale*(dx+offsets[i]),dy]) text(text[i], size=adjSize, font=font);
            }
        }
    }
}
// end MIT licensed code

