include <fontdata.scad>;

function cp1252Decode(c) = let(found = search(c, cp1252)) len(found) > 0 ? found[0]+32 : 32;

function toGlyphArray(font,s) = [for (i=[0:len(s)-1]) font[cp1252Decode(s[i])-32]];
    
function sumTo(array,n) = n <= 0 ? 0 : array[n-1] + sumTo(array,n-1);

function sum(array) = sumTo(array,len(array));

function getBit(x, n) = floor(x / pow(2,n)) % 2 == 1;

function getFontHeight(font) = len(font[0][3]);

module renderGlyph(width, bitmap, invert=false, size=10) {
    height = len(bitmap);
    pixel = size/height;
    for (y=[0:height-1]) for(x=[0:width-1]) {
        if (getBit(bitmap[height-1-y],width-1-x) != invert) translate([pixel*(x+0.5),pixel*(y+0.5)]) children();
    }
}   

function getGlyphArrayWidth(glyphArray,spacing=1,size=10) = let(pixelSize = size / len(glyphArray[0][3]), n=len(glyphArray))
    sum([for (i=[0:n-1]) (glyphArray[i][1]+glyphArray[i][2])*pixelSize*spacing]);

function getStringWidth(string,font=font_8x8,spacing=1,size=10) = getGlyphArrayWidth(toGlyphArray(font,string),spacing=spacing,size=size);
    
module renderGlyphArray(glyphArray,halign="left",valign="bottom",invert=false,spacing=1,size=10) {
    n = len(glyphArray);
    pixelSize = size / len(glyphArray[0][3]);
    sizes = [for (i=[0:n-1]) (glyphArray[i][1]+glyphArray[i][2])*pixelSize*spacing];
    leftOffset = halign == "left" ? 0 : (halign == "right" ? -sum(sizes) : -sum(sizes)/2);
//    numRows = len(glyphArray[0][0][3]);
    bottomOffset = valign == "top" ? -size : (valign == "center" ? -size/2 : 0);
    for (i=[0:n-1]) translate([leftOffset + sumTo(sizes,i) + spacing*glyphArray[i][1], bottomOffset]) 
        renderGlyph(glyphArray[i][0], glyphArray[i][3], invert=invert, size=size) children();
}

module renderString(string,font=font_8x8,halign="left",valign="bottom",invert=false,spacing=1,size=10,pixelScale=1.01,height=0) {
    glyphArray = toGlyphArray(font,string);
    pixel = pixelScale * size / getFontHeight(font);
    
    module render(inv) {
        renderGlyphArray(glyphArray,halign=halign,valign=valign,invert=inv?!invert:invert,spacing=spacing,size=size) children();
    }
    
    if ($children==2) {
        render(false) children(0);
        render(true) children(1);
    }
    else if ($children>0) {
        render() children();
    }
    else {
        render() if(height>0) translate([-pixel/2,-pixel/2,0]) cube([pixel,pixel,height]); else square([pixel,pixel],center=true);
    } 
}

/*
pixel = 10/getFontHeight(font_8x8);
render(convexity=2) renderString("abc") {
    circle(d=1*pixel, $fn=10);
    difference() {
        circle(d=1*pixel, $fn=10);
        circle(d=0.9*pixel, $fn=10);
    }
}
*/