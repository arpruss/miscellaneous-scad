innerDiameter = 34.5;
slitWidth = 2;
topDiameter = 30;
lengthToHole = 25.4*1;
lengthPastHole = 25.4*0.25;
holderLength = 25.4*1.5;
holeDiameter = 4;
narrowLength = lengthPastHole+10;
secondaryDiameter = 34+2*1.5+0.5+1.75;
secondaryLength = 45;
wall = 2.25;
secondaryWall = 2.25;

nudge = 0.01;

od = innerDiameter + 2*wall;
length = lengthToHole+lengthPastHole+holderLength;

$fn = 36;

od2 = secondaryDiameter + 2*secondaryWall;

difference() {
    union() {
    cylinder(d1=topDiameter,d2=od,h=narrowLength+nudge);
    translate([0,0,narrowLength]) cylinder(d=od,h=length-narrowLength);
        translate([0,0,length-nudge]) {
         cylinder(d1=od,d2=od2,h=od2-od);
            translate([0,0,od2-od-nudge]) cylinder(d=od2,h=secondaryLength);
        }
    }
    translate([0,0,lengthPastHole+lengthToHole]) cylinder(d=innerDiameter,h=holderLength+nudge);
    translate([0,0,lengthPastHole])
    rotate([90,0,0])
    cylinder(d=holeDiameter,h=2*(od),center=true);
    translate([0,-slitWidth/2,lengthPastHole+lengthToHole])
    cube([od,slitWidth,holderLength+nudge+od2-od+15]);
    translate([0,0,length-wall])
    cylinder(d1=innerDiameter,d2=od,h=wall+nudge);
        translate([0,0,length-nudge]) {
         cylinder(d1=innerDiameter,d2=secondaryDiameter,h=od2-od);
            translate([0,0,od2-od-nudge]) cylinder(d=secondaryDiameter,h=secondaryLength+2*nudge);
        }
}