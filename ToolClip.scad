plateThickness = 3.5;

// for meshing with remixed penholder
//  http://www.thingiverse.com/thing:1873991
// The penholder should have mounting_bump_thickness = 3.5
// and mounting_bump_diameter = 8


mountingBumpDiameter = 0; //8.5;
mountingBumpPairsCount = 2;
mountingBumpVerticalSpacing = 42;
mountingBumpHorizontalSpacing = 20;

screwHorizontalSpacing = 51; // matches springtool.scad
screwVerticalSpacing = 22;
firstScrewHeight = 16;
screw_hole_diameter = 2.9; // M3
screw_countersink_diameter = 6.3;
screw_countersink_depth = 1.5; // 2.17;
screw_countersink_sides = 16;

module dummy() {}
upperArmThickness = 3;
lowerArmThickness = 7;
upperArmSpacing = 58.8;
upperArmHorizontalSpacing = 58.9;
upperCatchLength = 3.1;
upperCatchThickness = 1.75;
upperShelfLength = 24;
upperShelfThickness = 2;
lowerArmHorizontalSpacing = 39.5;
upperArmMainLength = 45;
upperArmGusset = 2;

rodDiameter = 8.15;
rodCatchDiameter = 19;
rodInset = 6 + rodCatchDiameter/2;
lowerArmLength = rodInset+rodCatchDiameter/2;
lowerArmHeight = 2*6.5+rodCatchDiameter;
rodTopZ = lowerArmHeight - rodCatchDiameter / 2 + rodDiameter / 2;
rightUpperArmStartFromRod = 16;
leftUpperArmStartFromRod = 23.2;
rightUpperArmHeight = 28;
leftUpperArmHeight = 16.4;

plateHeight = rodTopZ+rightUpperArmStartFromRod+rightUpperArmHeight+upperShelfThickness;
mountingBumpsHeight = lowerArmHeight/2-rodCatchDiameter/2;

nudge = 0.01;
plateWidth = upperArmHorizontalSpacing + 2 * upperArmThickness;

screw_positions = [[-screwHorizontalSpacing/2., firstScrewHeight],
[screwHorizontalSpacing/2., firstScrewHeight],
[-screwHorizontalSpacing/2., firstScrewHeight+screwVerticalSpacing],
[screwHorizontalSpacing/2., firstScrewHeight+screwVerticalSpacing]];


module clip() {

// backplate
difference() {
    translate([nudge,-plateWidth/2,0]) rotate([0,-90,0]) linear_extrude(height=plateThickness) difference() {
       corner = (plateWidth - lowerArmHorizontalSpacing)/2-lowerArmThickness;
       square([plateHeight,plateWidth]);
       polygon(points=[[0,0],[0,corner],[corner,0]]);
       polygon(points=[[0,plateWidth],[0,plateWidth-corner],[corner,plateWidth]]);
    }
    for (z = [0:mountingBumpPairsCount-1]) {
        for (sign = [-1:2:1]) {
        verticalAdjust = z%2 != 0 ? mountingBumpDiameter : 0;
        translate([-plateThickness-nudge,sign*mountingBumpHorizontalSpacing/2,mountingBumpsHeight+z*mountingBumpVerticalSpacing+verticalAdjust])
        rotate([90,180*((z%2)),90])
        linear_extrude(height=2*nudge+plateThickness)
         union() {
            translate([0,mountingBumpDiameter/2,0])
            circle(d=mountingBumpDiameter);
            translate([-mountingBumpDiameter/2,0,0]) square([mountingBumpDiameter,mountingBumpDiameter/2]); 
         } 
     } 

    } 
}


// loop over two sides
for (i=[0:1]) {
    sign = i * 2 - 1;
    left = (i==0);
    // left: i = 0, sign = -1
    // right: i = 1, sign = 1
    upperArmStartZ = rodTopZ + (left ? leftUpperArmStartFromRod : rightUpperArmStartFromRod);
    upperArmHeight = ( left ? leftUpperArmHeight : rightUpperArmHeight );

    shelfAreaHeightAdjust = left ? (rightUpperArmStartFromRod+rightUpperArmHeight)-(leftUpperArmStartFromRod+leftUpperArmHeight) : 0;

    // upper arms
    translate([0,sign*(plateWidth/2-upperArmThickness/2),nudge+upperArmStartZ+upperArmHeight/2]) 
    rotate([-sign*90,0,0]) 
        translate([0,-upperArmHeight/2,-upperArmThickness/2]) 
        union() {
        linear_extrude(height=upperArmThickness) 
            union() {
                if (left) {
                square([upperShelfLength, upperArmHeight+shelfAreaHeightAdjust]);
                }
                else {
                square([upperArmMainLength+upperCatchThickness, upperArmHeight]);
                }
            }
        if (!left) { 
            translate([upperArmMainLength,0,0])
                rotate([-90,0,0])
                linear_extrude(height=upperArmHeight)
                translate([0,-upperArmThickness])
                square([upperCatchThickness,upperCatchLength+upperArmThickness]);
        }
        rotate([-90,0,0])
            linear_extrude(height=upperArmHeight+shelfAreaHeightAdjust)
            polygon(points=[[-nudge,upperArmGusset],[upperArmGusset,-nudge],[-nudge,-nudge]]);
        }
        
        
    // lower arms
    armHeightAdjustment = (i==0) ? (6.5-2.7) : 0;
    translate([0,sign*(lowerArmHorizontalSpacing/2+lowerArmThickness/2),0]) rotate([90,0,0]) translate([0,0,-lowerArmThickness/2]) linear_extrude(height=lowerArmThickness) 
    difference() {
        square([lowerArmLength, lowerArmHeight-armHeightAdjustment]);
        translate([rodInset,lowerArmHeight/2]) union() {
            circle(r=rodCatchDiameter/2);
            translate([rodCatchDiameter/2,0]) square([rodCatchDiameter,rodCatchDiameter],center=true);
        }
    } 
}  

translate([0,-plateWidth/2,rodTopZ+rightUpperArmStartFromRod+rightUpperArmHeight]) linear_extrude(height=upperShelfThickness) square([upperShelfLength,plateWidth]); 

}

render(convexity=10)
difference() {
    rotate([0,-90,-90])
        clip();
    for (i=[0:len(screw_positions)-1]) {
        translate([screw_positions[i][0],screw_positions[i][1],-screw_countersink_depth]) {
            cylinder(h=30, d=screw_countersink_diameter, $fn=16);
            translate([0,0,-10]) cylinder(h=30, d=screw_hole_diameter, $fn=16);        
    }
}
}