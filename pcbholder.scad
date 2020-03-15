use <pointhull.scad>;
use <roundedSquare.scad>;

// <params>
pcbThickness = 1.55;
pcbWidth = 22.7;
pcbLength = 52.8;
pcbOffsetFromBase = 2.6;
tolerance = 0.05;
wall = 1.5;
ridge = 1.5;
screwSize = 3.5;
screwHoleWall = 2;
screwButtressWall = 3;
screw1DistanceFromFront = 5;
screw2DistanceFromFront = 50;
screwDistanceFromPCB = 1;
rearHole = 10;
holeDistanceFromWall = 4;
// </params>

module pcbHolder(pcbThickness=pcbThickness, pcbWidth=pcbWidth, pcbLength=pcbLength, pcbOffsetFromBase=pcbOffsetFromBase, tolerance=tolerance, wall=wall, ridge=ridge, screwSize=screwSize, screwHoleWall=screwHoleWall, screwButtressWall=screwButtressWall, screw1DistanceFromFront=screw1DistanceFromFront,screw2DistanceFromFront=screw2DistanceFromFront,screwDistanceFromPCB=screwDistanceFromPCB,rearHole=rearHole,holeDistanceFromWall=holeDistanceFromWall) {
$fn = 32;

nudge = 0.001;

h = wall+pcbOffsetFromBase+pcbThickness+ridge;

echo("height", h);
echo("screwSpacing", screwDistanceFromPCB*2 + pcbWidth);

module screw() {
    d = screwSize + screwHoleWall*2;
    translate([screwDistanceFromPCB+pcbWidth/2,0,0]) {
        difference() {
            union() {
            cylinder(d=d, h=h);
            translate([-screwDistanceFromPCB+tolerance,-screwButtressWall/2,0]) cube([screwDistanceFromPCB-tolerance,screwButtressWall,h]);
            }
            translate([0,0,-h]) cylinder(d=screwSize,h=3*h);
        }
    }
}

module half() {
    x = pcbWidth/2+tolerance;
    difference() {
    cube ([x+wall,pcbLength+wall+tolerance,wall]);
    translate([0,0,-wall])
    linear_extrude(height=wall*3)
    translate([-(x-holeDistanceFromWall),holeDistanceFromWall,0])
    roundedSquare([2*x-2*holeDistanceFromWall,pcbLength-2*holeDistanceFromWall],radius=holeDistanceFromWall);
    }
    translate([x-nudge,0,0]) cube([wall+nudge,pcbLength+wall+tolerance,h]);
    module vridge(h) {
    pointHull([[x,0,h-ridge],
        [x,0,h],[x-ridge,0,h],
        [x,pcbLength+nudge,h-ridge],
        [x,pcbLength+nudge,h],[x-ridge,pcbLength+nudge,h]]);
    }
    vridge(h);
    vridge(h-ridge-pcbThickness);
    translate([rearHole/2,pcbLength+tolerance,0])
    cube([x+wall-rearHole/2,wall,h]);
    translate([0,screw1DistanceFromFront,0])
    screw();
    translate([0,screw2DistanceFromFront,0])
    screw();
}

half();
translate([nudge,0,0]) mirror([1,0,0]) half();
}

pcbHolder();