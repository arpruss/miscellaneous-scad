use <hershey.scad>;

//<params>
name = "NAME";
font = "rowmans";
textSize = 30;
lineHeight = 8;
lineWidth = 10;
lineChamfer = 4;
letterSquish = 5;
ringOuterDiameter = 14; // set to 0 not to include ring
ringLineWidth = 3.5;
ringHeight = 5;

//</params>
module chamferedCylinder(d=10,r=undef,h=10,chamfer=1) {
    diameter = r==undef ? d : 2*r;
    cylinder(d=diameter,h=h-chamfer+0.001);
    translate([0,0,h-chamfer])
    cylinder(d1=diameter,d2=diameter-chamfer*2,h=chamfer);
}

drawHersheyText("NAME", font="rowmans", size=textSize, extraSpacing=-letterSquish) chamferedCylinder(d=lineWidth,h=lineHeight,chamfer=lineChamfer, $fn=24);

ringInnerDiameter = ringOuterDiameter - 2*ringLineWidth;

if (ringOuterDiameter) {
    render(convexity=2)
    translate([-ringInnerDiameter/2,textSize/2,0])
    difference() {
        cylinder(d=ringOuterDiameter,h=ringHeight);
        translate([0,0,-1])
        cylinder(d=ringInnerDiameter,h=ringHeight+2);
    }
}