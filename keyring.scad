include <hershey.scad>;

//<params>
name = "NAME";
font=3; // [0:GothicEnglish, 1:GothicGerman, 2:GothicItalian, 3:Sans, 4:SansBold, 5:SansBoldOblique, 6:Script, 7:ScriptBold, 8:Serif, 9:SerifBold, 10:SerifBoldItalic, 11:SerifItalic]
textSize = 30;
// how thick the letters are
lineHeight = 8; 
// how wide the line the letters are drawn with is
lineWidth = 10;
// you can increase chamfer up to half of line width to make the ridges sharper if rounded top mode is off
lineChamfer = 4;
roundedTop = 0; // [1:yes, 0:no]
smartOverlap = 1; // [1:yes, 0:no]
// increase to make letters be more squashed together; in smart overlap mode, this is the number of millimeters letters overlap by
letterSquish = 3.5;
// set to 0 not to include ring
ringOuterDiameter = 14; 
ringLineWidth = 3.5;
ringHeight = 5;
// 0.5 is vertically centered; 0 is at the bottom and 1 is at the top
ringPosition = 0.5; 
//</params>

// for rounded top variant
module chamferedCylinder(d=10,r=undef,h=10,chamfer=1) {
    diameter = r==undef ? d : 2*r;
    cylinder(d=diameter,h=h-chamfer+0.001);

    if (roundedTop) {
        translate([0,0,h-chamfer])
            scale([1,1,chamfer/(diameter/2)]) 
                intersection() {
                    sphere(d=diameter);
                    translate([-diameter,-diameter,0]) cube([2*diameter,2*diameter,diameter]);
                }
    }
    else {
        translate([0,0,h-chamfer])
        cylinder(d1=diameter,d2=diameter-chamfer*2,h=chamfer);
    }
}

module doText() {
    drawHersheyText(name, font=hersheyFontNames[font], size=textSize, extraSpacing=smartOverlap ? 0 : -letterSquish, forceMinimumDistance=smartOverlap ? max(0,lineWidth-letterSquish) : undef) chamferedCylinder(d=lineWidth,h=lineHeight,chamfer=lineChamfer, $fn=24);
}

ringInnerDiameter = ringOuterDiameter - 2*ringLineWidth;

module ring() {
    render(convexity=2)
    difference() {
        cylinder(d=ringOuterDiameter,h=ringHeight);
        translate([0,0,-1])
        cylinder(d=ringInnerDiameter,h=ringHeight+2);
    }
}

module doRing() {
    $fn = 24;
    f = findHersheyFont(hersheyFontNames[font]);
    firstGlyph = findHersheyGlyph(name[0],f);
    if (firstGlyph == undef || len(firstGlyph[2])==0) {
        translate([-ringInnerDiameter/2,textSize*ringPosition,0]) ring();
    }
    else {
        center = [[[ringOuterDiameter/2,textSize*ringPosition],[ringOuterDiameter/2,textSize*ringPosition]]];
        desiredDistance = ringInnerDiameter/2+max(lineWidth/2,ringLineWidth);
        shift = iterateToAutoDistance(center, textSize*firstGlyph[2], desiredDistance+0.02, ringOuterDiameter, precision=0.02);
        d = shiftDrawing([14,0],textSize*firstGlyph[2]);
        translate([center[0][0][0]-shift,ringPosition*textSize]) ring();
    }
}

doText();
if (ringOuterDiameter>0) doRing();
 