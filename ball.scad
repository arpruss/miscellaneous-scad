sphereDiameter=16.54;
horizontalTolerance = 0.3;
verticalTolerance = 1.2; // 0.6;
chamfer = 0.5;

module half() {
    d1 = sphereDiameter*.4+2*horizontalTolerance;
    render(convexity=1)
    difference() {
        sphere(d=sphereDiameter, $fn=40);
        translate([0,0,-sphereDiameter]) cube(size=sphereDiameter*2,center=true);
        translate([0,0,-sphereDiameter*.25-verticalTolerance])
        cylinder(d=d1, h=sphereDiameter*.5+2*verticalTolerance, $fn=40);
        translate([0,0,-0.001])
        cylinder(d1=d1+2*chamfer, d2=d1, h=chamfer);
    }
}

half();
translate([-8-sphereDiameter,0,0]) half();
translate([10+sphereDiameter/2,0,0])
render(convexity=0)
intersection() {
    cylinder(d=sphereDiameter*.4,h=sphereDiameter*.5, $fn=40);
    cylinder(d1=sphereDiameter*.4-2*chamfer+2*sphereDiameter*.5,d2=sphereDiameter*.4-2*chamfer, h=sphereDiameter*.5, $fn=40);
}
