use <tubemesh.scad>;

//<params>
buttonDiameter = 11.7;
bottomBevel = 0.5;
buttonDepth = 5.45;
buttonWallThickness = 1;
buttonBottomThickness = 1.75;
attachmentSide1 = 3.81;
attachmentSide2 = 3.76;
attachmentHeight = 2.75;
attachmentSideTolerance = 0.35;
attachmentTopTolerance = 0.2;
snapWallThickness = 1.1;
snapSpacing = 0.25;
snapBump = 0.42;
snapBumpHeight = 0.4;
snapJoinedHeight = 0.1;
//</params>

nudge = 0.01;

module snap1(length0) {
    z1 = attachmentHeight+attachmentTopTolerance;
    length = length0 - 2*snapSpacing;
    
    function section(length,bump,z) = sectionZ([[-bump,-length/2],[snapWallThickness,-length/2],[snapWallThickness,length/2],[-bump,length/2]],z);
    
    tubeMesh([section(length0+2*snapWallThickness,0,0),
        section(length0+2*snapWallThickness,0,snapJoinedHeight),
        section(length,0,z1),
        section(length,snapBump,z1+snapBump),
        section(length,0,z1+snapBump*2)]);
}

module snaps() {
    for (a=[0,180])
        rotate([0,0,a]) translate([attachmentSide2/2+attachmentSideTolerance,0,0]) snap1(attachmentSide1);
    for (a=[90,270])
        rotate([0,0,a]) translate([attachmentSide1/2+attachmentSideTolerance,0,0]) snap1(attachmentSide2);
}

$fn = 36;

module beveledCylinder(h=10,d=10,bevel=1) {
    cylinder(h=bevel,d1=d-2*bevel,d2=d);
    translate([0,0,bevel-nudge]) cylinder(h=h-bevel+nudge,d=d);
}

module button() {
    difference() {
        beveledCylinder(h=buttonDepth,d=buttonDiameter,bevel=bottomBevel);
        translate([0,0,buttonBottomThickness]) cylinder(h=buttonDepth,d=buttonDiameter-2*buttonWallThickness);
    }
}

button();
translate([0,0,buttonBottomThickness-nudge]) snaps();
