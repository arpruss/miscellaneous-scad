/* Remixed from:
Ball Bearing Spool Holder for Monoprice Select Mini (Malyan M200) byandymandiasis licensed under theCreative Commons - Attributionlicense.
By downloading this thing, you agree to abide by the license: Creative Commons - Attribution - Non-Commercial - No Derivatives
https://www.thingiverse.com/thing:2095432/files
*/

part = 1; // 0:Holder, 1:Cone, 2:Spacer
inch = 25.4;
carriageBolt = true;
boltHeadTolerance = 0.2;
boltShaftTolerance = 0.05;
boltShaftDiameter = 0.25*inch;
boltHexHeadDiameter = 0.505*inch;
boltHexHeadHeight = 0.163*inch;
boltCarriageHeadDiameter = 0.547*inch;
boltCarriageHeadHeight = 0.15*inch;
boltCarriageSquareSide = 0.26*inch;
boltCarriageSquareHeight = 0.136*inch;
boltOffsetFromFastener = 4;
fastenerHeight = 20;
fastenerExtraWidth = .9;
fastenerThinner = .15;
extraHeight = 19;
coneWidth = 30;
coneLength = 9;

nudge = 0.001;

$fn = 32;

miniCrossSection0 = [ [-7.5,-15],[7.5,-15],[7.5,15],[-7.5,15],[-7.5,12+fastenerExtraWidth],[-5,12+fastenerExtraWidth],[-4,11+fastenerExtraWidth],[-4,5.5],[-6-fastenerThinner,5.5],[-6-fastenerThinner,8],[-7,9],[-7.5,9],[-7.5,-9],[-7,-9],[-6-fastenerThinner,-8],[-6-fastenerThinner,-5.5],[-4,-5.5],[-4,-11-fastenerExtraWidth],[-5,-12-fastenerExtraWidth],[-7.5,-12-fastenerExtraWidth],[-7.5,-15] ];
xMin = min([for (xy=miniCrossSection0) xy[0]]);
thickness = abs(xMin)*2;
miniCrossSection = [for (xy=miniCrossSection0) [xy[0]-xMin,xy[1]]];

module boltHole() {
    if (carriageBolt) {
        cylinder(h=boltCarriageHeadHeight+boltHeadTolerance,d=boltCarriageHeadDiameter+2*boltHeadTolerance);
        cylinder(h=boltCarriageSquareHeight+boltCarriageHeadHeight+boltHeadTolerance*2,d=boltCarriageSquareSide*sqrt(2),$fn=4);
    }
    else {
        cylinder(h=boltHexHeadHeight+boltHeadTolerance,d=boltHexHeadDiameter+2*boltHeadTolerance,$fn=6);
    }
    linear_extrude(height=50) circle(d=boltShaftDiameter+2*boltShaftTolerance,$fn=32);
}

module cone() {
    cylinder(d1=coneWidth,d2=boltShaftDiameter+2*boltShaftTolerance,h=coneLength,$fn=32);
}

module main() {
    difference() {
        union() {
            linear_extrude(height=fastenerHeight) polygon(miniCrossSection);
            translate([0,0,fastenerHeight-nudge]) linear_extrude(height=extraHeight) hull() polygon(miniCrossSection);
            translate([thickness,0,fastenerHeight+boltOffsetFromFastener]) rotate([0,90,0]) translate([0,0,-nudge]) cone();
        }
        translate([0,0,fastenerHeight+boltOffsetFromFastener]) rotate([0,90,0]) translate([0,0,-nudge]) boltHole();
    }
}

if (part==0) 
    rotate([180,0,0]) main();
else if (part == 1) {
    difference() {
        cone();
        cylinder(d=boltShaftDiameter+2*boltShaftTolerance,h=100,center=true,$fn=32);
    }
}
else if (part == 2) {
    linear_extrude(height=12) 
        difference() {
            circle(d=boltShaftDiameter+0.75+1.5);
            circle(d=boltShaftDiameter+0.75);
        }
}
//            linear_extrude(height=8) polygon(miniCrossSection);
