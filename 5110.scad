width = 12;
height = 6;
thickness = 1;
connectorWidth = 9.5;
connectorLength = 3;
numPins = 9;
holeSize = 0.65;

$fn = 16;

module pins() {
    x0 = -connectorWidth/2;
    dx = connectorWidth / numPins;
    for (i=[0:numPins-1])
        translate([x0+dx*i+0.5*dx,0]) children();
}

difference() {
    linear_extrude(height=thickness)
    difference() {
        square([width,height],center=true);
        translate([0,connectorLength/2]) pins() circle(d=holeSize);
        translate([0,-connectorLength/2]) pins() circle(d=holeSize);
    };
    translate([0,connectorLength/2]) pins() translate([0,0,thickness]) rotate([-90,0,0]) cylinder(d=holeSize,h=height);
    translate([0,-connectorLength/2]) pins() translate([0,0,thickness]) rotate([90,0,0]) cylinder(d=holeSize,h=height);
}