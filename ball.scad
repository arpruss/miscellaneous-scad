sphereDiameter=16.54;
horizontalTolerance = 0.3;
verticalTolerance = 1.2; // 0.6;

module half() {
    difference() {
        sphere(d=sphereDiameter, $fn=40);
        translate([0,0,-sphereDiameter]) cube(size=sphereDiameter*2,center=true);
        translate([0,0,-sphereDiameter*.25-verticalTolerance])
        cylinder(d=sphereDiameter*.4+2*horizontalTolerance, h=sphereDiameter*.5+2*verticalTolerance, $fn=40);
    }
}

half();
translate([-8-sphereDiameter,0,0]) half();
translate([10+sphereDiameter/2,0,0])
cylinder(d=sphereDiameter*.4,h=sphereDiameter*.5, $fn=40);