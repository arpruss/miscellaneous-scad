use <tubemesh.scad>;

length = 140;
thickness = 8;
minWidth = 5;
maxWidth = 10;
plasticThicknessBelowScrew = 3;
sizeAroundCountersink = 2;
countersinkDiameter = 9;
countersinkDepth = 3;
screwHoleDiameter = 4.3;

module dummy() {}

nudge = 0.01;

module pull() {
    section0 = [ [0,0], [length,0], [length,minWidth], [0, minWidth] ];
    section1 = [ [0,0], [length,0], [length,maxWidth], [0, maxWidth] ];
    morphExtrude(section0,section1,thickness);
}

$fn = 36;
h1 = max(plasticThicknessBelowScrew+countersinkDepth,thickness);
module screwHole() {
    translate([0,0,-nudge]) {
        translate([0,0,plasticThicknessBelowScrew])
        cylinder(d=countersinkDiameter,h=countersinkDepth+2*nudge+thickness);
        cylinder(d=screwHoleDiameter,h=h1+nudge);
    }
}

render(convexity=2)
difference() {
    d1 = 2*sizeAroundCountersink+countersinkDiameter;
    union() {
        pull();
        for (i=[0:1])
            translate([i*length,d1/2,0])
        cylinder(d=d1,h1);
    }
    for (i=[0:1])
        translate([i*length,d1/2,0]) screwHole();

}

