use <tubemesh.scad>;

//<params>
diameter = 125;
height = 100;
// Top to bottom size ratio
ratio = 1.25;
wallThickness = 2.81;
baseThickness = 4;
twistAngle = 60;
sides = 6;
holeSize = 8;
// Set to zero if you want a vase without holes
holes = 3;
//</params>

module dummy() {}

nudge = 0.002;

module solid(delta=0) {
    morphExtrude(ngonPoints(n=sides,d=diameter-delta*2),ngonPoints(n=sides,d=ratio*diameter-delta*2),twist=twistAngle,height=height,numSlices=100);
}

difference() {
    solid();
    difference() {
        translate([0,0,nudge]) solid(delta=wallThickness/cos(180/sides));
        cube([4*diameter,4*diameter,2*baseThickness],center=true);
    }
    for (i=[0:1:holes-1]) {
        rotate([0,0,360/holes*i]) translate([diameter*.5*.4,0,0]) cylinder(d=holeSize,h=baseThickness*4,center=true,$fn=16);
    }
}