include <fontmetricsdata.scad>;

// begin MIT licensed code (c) 2018 Alexander Pruss
BOLD = 1;
ITALIC = 2;
CONDENSED = 32;
ASCENDER_TO_EM = 1510/2048; // mysterious factor to match OpenSCAD
METRICS_ADJUST = 1.0255; // this adjusts metrics a little bit to match OpenSCAD -- I don't know why this is needed

_XADVANCE = 1;
_LSB = 2;
_XMIN = 3;
_YMIN = 4;
_XMAX = 5;
_YMAX = 6;
_KERN = 7;

_FONTID = 0;
_ASCENDER = 1;
_DESCENDER = 2;
_LINEGAP = 3;
_UNITS_PER_EM = 4;
_GLYPHDATA = 5;

function fontScale(f) = 1 / (ASCENDER_TO_EM * f[_UNITS_PER_EM]);

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
    
function sublist(a,start,end=undef,soFar=[]) =
    start >= len(a) || (end != undef && start >= end) ? soFar :
    sublist(a,start+1,end=end,soFar=concat(soFar,[a[start]]));
    
function lowercaseChar(c) = 
    c < "A" || c > "Z" ? c :
    chr(search(c,"ABCDEFGHIJKLMNOPQRSTUVWXYZ")[0]+97);
    
function lowercase(s,start=0,soFar="") =
    start >= len(s) ? soFar :
    lowercase(s,start=start+1,soFar=str(soFar,lowercaseChar(s[start])));
    
function splitstring(s,delimiter=" ",offset=0,lastStart=0,soFar=[]) =
    len(s)==0 ? [] :
    offset >= len(s) ? concat(soFar,[substring(s,lastStart,end=offset)]) :
    s[offset] == delimiter ? splitstring(s,delimiter=delimiter,offset=offset+1,lastStart=offset+1,soFar=concat(soFar,[substring(s,lastStart,end=offset)])) :
    splitstring(s,delimiter=delimiter,offset=offset+1,lastStart=lastStart,soFar=soFar);
    

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
    let(g=findEntry(font[_GLYPHDATA],char))
    g == undef ? findEntry(font[_GLYPHDATA],"_") : g;
    
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
    
function getScaledOffsets(string, font, size=10., spacing=1.) = spacing * size * fontScale(font) * getOffsets(string, font);
    
function measureText(text="", font="Liberation Sans", size=10., spacing=1., fonts=FONTS) = 
    let(f=findFont(FONTS, font))
    spacing * size * fontScale(f) * measureWithFont(text, f);

function ascender(font="Liberation Sans", size=10., fonts=FONTS) =
    let(f=findFont(fonts, font))
    fontScale(f)*size*f[_ASCENDER]*METRICS_ADJUST;

function descender(font="Liberation Sans", size=10., fonts=FONTS) =
    let(f=findFont(fonts, font))
    fontScale(f)*size*f[_DESCENDER]*METRICS_ADJUST;
    
function linegap(font="Liberation Sans", size=10., fonts=FONTS) =     
    let(f=findFont(fonts, font))
    fontScale(f)*size*f[_LINEGAP]*METRICS_ADJUST;
    
function verticalAdvance(font="Liberation Sans", size=10., fonts=FONTS) = 
    let(f=findFont(fonts, font))
    fontScale(f)*size*(f[_ASCENDER]-f[_DESCENDER]+f[_LINEGAP])*METRICS_ADJUST;
    
function maximizeGlyphMetric(text,f,mult,index,offset=0,soFar=-1e100) =
    len(text) == 0 ? 0 :
    offset >= len(text) ? soFar :
    maximizeGlyphMetric(text,f,mult,index,offset=offset+1,
        soFar=max(soFar,mult*getGlyphInfo(f, text[offset])[index]));
    
function measureTextDescender(text="", size=10, font="Liberation Sans", fonts=FONTS) = 
    let(f=findFont(fonts, font))
    -fontScale(f)*size*METRICS_ADJUST*maximizeGlyphMetric(text,f,-1,_YMIN);
    
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
    len(text)==0 ? [[0,0],[0,0]] : (
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
        [[lsb+dx,des+dy],[w-lsb+rsb,asc-des]]);
    
module drawText(text="", size=10, font="Liberation Sans", halign="left", valign="baseline", spacing=1, fonts=FONTS) {
    
    l = len(text);
    if (l>0) {
        sc = size < 20 ? size/20 : 1;
        adjSize = size < 20 ? 20 : size;
        f = findFont(fonts, font);
        offsetScale = spacing * adjSize * fontScale(f);
        offsets = getOffsets(text, f);
        w = offsets[l];
        dx = halign=="right" ? -w :
             halign=="center" ? -w / 2 : 0;
        dy = valign=="top" ? -measureTextAscender(text, size=size, font=font) :
             valign=="bottom" ? -measureTextDescender(text, size=size, font=font) : 
             valign=="center" ? -0.5*(measureTextAscender(text, size=size, font=font)+measureTextDescender(text,size=size,font=font)) : 0;
        
        scale(sc) {
            for (i=[0:l-1]) {
                translate([offsetScale*(dx+offsets[i]),dy]) text(findEntry(f[_GLYPHDATA],text[i])==undef?"_":text[i], size=adjSize, font=font);
            }
        }
    }
}

function whereToSplit(offsets,width,pos=0) =
    pos >= len(offsets)-1 ? pos : // shouldn't happen
    offsets[pos+1] > width && pos > 0 ? pos :
    whereToSplit(offsets,width,pos=pos+1);
    
// TODO: worry about splitting a kerning pair
function splitWord(word,f,width,size,spacing) =
    let(o=getScaledOffsets(word,f,size=size,spacing=spacing),
        i=whereToSplit(o,width),
        w1=substring(word,0,i),
        w2=substring(word,i))
    [[w1,o[i]],[w2,o[len(word)]-o[i]]];
    
function splitWordsAsNeeded(words,f,firstWidth,width,size,spacing,offset=0) =
    offset >= len(words) ? words :
    words[offset][1] <= (offset==0 ? firstWidth : width) ? splitWordsAsNeeded(words,f,firstWidth,width,size,spacing,offset=offset+1) :
    splitWordsAsNeeded(concat(sublist(words,0,offset),
        splitWord(words[offset][0],f,(offset==0?firstWidth:width),size,spacing),sublist(words,offset+1)),f,firstWidth,width,size,spacing,offset=offset+1);    

function addSizesToWords(words,f,firstWidth,width,size,spacing) =
    let(wordsAndSizes=[for(i=[0:len(words)-1]) [words[i],measureText(words[i],font=f,size=size,spacing=spacing)]]) 
    splitWordsAsNeeded(wordsAndSizes,f,firstWidth,width,size,spacing);
    
function wrapWordsToLines(words,space,width,x=0,offset=0,soFar=[],curLine=[]) =
    offset >= len(words) ? (len(curLine)>0 ? concat(soFar,[curLine]) : soFar ) :
    len(curLine) == 0 || x+words[offset][1] <= width ? wrapWordsToLines(words,space,width,x=x+words[offset][1]+space,offset=offset+1,soFar=soFar,curLine=concat(curLine,[words[offset]])) :
    wrapWordsToLines(words,space,width,x=words[offset][1]+space,offset=offset+1,soFar=concat(soFar,[curLine]),curLine=[words[offset]]);
    
function splitParaToLines(words,f,indent,width,size,spacing) =
    wrapWordsToLines(addSizesToWords(words,f,width-indent,width,size,spacing),measureText(" ",font=f,size=size,spacing=spacing),width,x=indent);
    
function formatLineNoJustify(words,x,y,space,offset=0,soFar=[]) =
    offset>=len(words) ? soFar :
    formatLineNoJustify(words,x+words[offset][1]+space,y,space,offset=offset+1,soFar=concat(soFar,[[[x,y],words[offset][0]]]));
    
function totalWidthWords(words,space=0,offset=0,soFar=0) =
    offset>=len(words) ? soFar :
    totalWidthWords(words,space,offset=offset+1,soFar=soFar + words[offset][1] + (offset>0?space:0));
        
function formatLine(words,x,y,space,width,halign) =
    halign=="justify" ? formatLineNoJustify(words,x,y,len(words)<=1 ? 0 : (width-totalWidthWords(words))/(len(words)-1)) :
    halign=="right" ? formatLineNoJustify(words,x-totalWidthWords(words,space=space),y,space) :
    halign=="center" ? formatLineNoJustify(words,x-totalWidthWords(words,space=space)/2,y,space) :
    formatLineNoJustify(words,x,y,space);

function formatParaLines(lines,indent,space,width,b2b,halign) = [for(i=[0:len(lines)-1]) for(w=formatLine(lines[i],i==0?indent:0,-i*b2b,space,width,halign=="justify" && i+1==len(lines) ? "left" : halign )) w];
    
function lastYInPara(para) =
    len(para) == 0 ? 0 : para[len(para)-1][0][1];

function shiftPara(delta,para) =
    len(para) == 0 ? [] : 
    [for(i=[0:len(para)-1]) [delta+para[i][0],para[i][1]]];
    
function joinFormattedParas(paras,b2b,y=0,offset=0,soFar=[]) =
    offset >= len(paras) ? soFar :
    joinFormattedParas(paras,b2b,y=y-b2b+lastYInPara(paras[offset]),offset=offset+1,soFar=concat(soFar,shiftPara([0,y],paras[offset])));
    
function formatParagraphText(s,f,indent,width,size,spacing,b2b,halign) =
    let(words=splitstring(s))
    len(words)==0 ? [] :
    let(lines=splitParaToLines(words,f,indent,width,size,spacing))
        formatParaLines(lines,indent,measureText(" ",size=size,spacing=spacing,font=f),width,b2b,halign); 

function wrapText(s,font="Liberation Sans",size=10,spacing=1,linespacing=1,indent=0,width=800,halign="left",fonts=FONTS) =
    let(paras = splitstring(s,delimiter="\n"),
        f = findFont(FONTS,font),
        b2b = verticalAdvance(f,size=size)*linespacing,
        formattedParas = [ for(p=paras) formatParagraphText(p,f,indent,width,size,spacing,b2b,halign) ])
    joinFormattedParas(formattedParas,b2b);
        
function measureWrappedTextBounds(s,font="Liberation Sans",size=10,spacing=1,linespacing=1,indent=0,width=800,halign="left",fonts=FONTS) =
    let(f=findFont(fonts,font),
        formatted=wrapText(s,font=font,size=size,spacing=spacing,linespacing=linespacing,indent=indent,width=width,halign=halign,fonts=FONTS),
        corners=[for(w=formatted) let(b=measureTextBounds(w[1],font=font,size=size,spacing=spacing,fonts=FONTS)) for(xy=[w[0]+b[0],w[0]+b[0]+b[1]]) xy],
        xCorners=[for(c=corners) c[0]],
        yCorners=[for(c=corners) c[1]],
        x0=min(xCorners),
        y0=min(yCorners))
        [[x0,y0],[max(xCorners)-x0,max(yCorners)-y0]];
    
module drawWrappedText(s,font="Liberation Sans",size=10,spacing=1,linespacing=1,indent=0,width=800,halign="left",fonts=FONTS) {
    f=findFont(fonts,font);
    formatted = wrapText(s,font=f,size=size,spacing=spacing,indent=indent,width=width,halign=halign,fonts=fonts);
    for(w=formatted)
        translate(w[0]) drawText(w[1],font=font,size=size,spacing=spacing,fonts=FONTS);    /**/
} 
