use <box.scad>;
use <roundedSquare.scad>;

insideHeight = 32;
thickness = 3.125;
insideWidth = 42;
insideLength = 54;
usbFromTop = 10;
usbHeight = 7.5;
usbWidth = 14;
screwSpacingX = 34.15;
screwSpacingY = 44;
screwOffsetFromFront = 4.6;
screwDiameter = 3.25;
ventHoleSpacing = 3.5;
ventHoleWidth = 2;
ventHoleFromTop = 2;
ventHoleLength = 10;
ventHoleShortLength = 4;
buttonSide = 6.04;
buttonHole = 2;
cableHole = 4.5;



$fn = 32;

module vent(length,height) {
    for (x=[ventHoleSpacing:ventHoleSpacing:length-ventHoleSpacing-ventHoleWidth]) translate([x+thickness,thickness+insideHeight-ventHoleFromTop-ventHoleLength]) square([ventHoleWidth,height]);
}

module screwHoles() {
    for (s=[-1,1]) {
        translate([thickness+insideWidth/2+s*screwSpacingX/2,thickness+screwOffsetFromFront]) circle(d=screwDiameter);
        translate([thickness+insideWidth/2+s*screwSpacingX/2,thickness+screwOffsetFromFront+screwSpacingY]) circle(d=screwDiameter);
    }
}

box(insideWidth+2*thickness,insideHeight+2*thickness,insideLength+2*thickness,thickness,open=false,kerf=.08,assemble=false)
{
    screwHoles(); // bottom
    union() {
        screwHoles(); // top
        translate([thickness+insideWidth/2,thickness+insideLength/2]) for (i=[-1,1]) for(j=[-1,1]) translate([i*buttonSide/2,j*buttonSide/2]) circle(d=buttonHole);
    };
    translate([thickness+insideWidth/2,thickness+insideHeight-usbFromTop]) roundedSquare([usbWidth,usbHeight],radius=2,center=true); // front
    union() {
        vent(insideWidth,ventHoleShortLength); // back
        hull() {
            translate([thickness+insideWidth/2,thickness+insideHeight-cableHole/2]) circle(d=cableHole);
            translate([thickness+insideWidth/2,thickness+insideHeight+thickness]) circle(d=cableHole);
        }
    }
    vent(insideLength,ventHoleLength); // left
    vent(insideLength,ventHoleLength); // right 
}