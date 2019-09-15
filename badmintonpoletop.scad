innerDiameter = 34;
slitWidth = 2;
topDiameter = 30;
lengthToHole = 25.4*1;
lengthPastHole = 25.4*0.25;
holderLength = 25.4*1.5;
holeDiameter = 4;
narrowLength = lengthPastHole+10;
wall = 1.5;

nudge = 0.01;

od = innerDiameter + 2*wall;
length = lengthToHole+lengthPastHole+holderLength;

$fn = 36;

difference() {
    union() {
    cylinder(d1=topDiameter,d2=od,h=narrowLength+nudge);
    translate([0,0,narrowLength]) cylinder(d=od,h=length-narrowLength);
    }
    translate([0,0,lengthPastHole+lengthToHole]) cylinder(d=innerDiameter,h=holderLength+nudge);
    translate([0,0,lengthPastHole])
    rotate([90,0,0])
    cylinder(d=holeDiameter,h=2*(od),center=true);
    translate([0,-slitWidth/2,lengthPastHole+lengthToHole])
    cube([od,slitWidth,holderLength+nudge]);
    translate([0,0,length-wall])
    cylinder(d1=innerDiameter,d2=od,h=wall+nudge);
}