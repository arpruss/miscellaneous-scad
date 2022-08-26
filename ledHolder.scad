ledWrapThickness = 1;
baseThickness = 1.5;
ledDiameter = 5;
ledTolerance = 0.14;
ledLengthToHold = 5.2;
stripWidth = 8;
screwHole = 3;
screwHoleDistanceFromEnd = 5;
length = 28;

$fn = 32;

module main() {
    cy = ledDiameter/2+ledTolerance+2*ledWrapThickness-ledWrapThickness;
    difference() {
        linear_extrude(height=stripWidth)
        difference() {
            union() {
                polygon([[-length/2,0],[length/2,0],[length/2-baseThickness*2,baseThickness],[-length/2+baseThickness*2,baseThickness]]);
                translate([0,cy]) circle(d=ledDiameter+2*ledTolerance+2*ledWrapThickness);
            }
            translate([0,ledDiameter/2+ledTolerance+2*ledWrapThickness-ledWrapThickness]) 
        circle(d=ledDiameter+2*ledTolerance);
        }
        translate([0,cy,ledLengthToHold])
        cylinder(d=ledDiameter+2*ledTolerance+4*ledWrapThickness,h=stripWidth);
        if (screwHole) {
            x = length/2 - screwHoleDistanceFromEnd;
            for (i=[-1,1]) 
                #translate([i*x,0,stripWidth/2]) rotate([90,0,0]) cylinder(d=screwHole,h=4*baseThickness,center=true);
        }
    }
}

main();