use <tubemesh.scad>;

w=16.06+0.4;
h=5;
troughDepth=3;
troughThickness=5;
length=10;
wings=4;
thickness=1.17;

screwHoleSize = 2.6;
screwLength = 10;
screwPillarDiameter = 7;

nudge = 0.01;

$fn=32;
render(convexity=3)
difference() {
    union() {
        cube([w,length+2,h]);
        prism(base=[[0,0,h-nudge],[0,0,h+thickness+2],[0,3.5,h+thickness+2],[0,2,h+thickness],[0,2,h-nudge]], vertical=[w,0,0]);
        translate([-2+nudge,0,0]) cube([2,length+2,h+thickness+2]);
        translate([w-nudge,0,0]) cube([2,length+2,h+thickness+2]);
        translate([-screwPillarDiameter-2,0,0])
        cube([w+4+screwPillarDiameter*2,screwPillarDiameter,4]);
    }
    translate([0,2,h-troughDepth]) cube([w,troughThickness,troughDepth+nudge]);
    translate([-screwPillarDiameter/2-2,screwPillarDiameter/2,-nudge]) cylinder(d=screwHoleSize,h=screwLength);
    translate([w+screwPillarDiameter/2+2,screwPillarDiameter/2,-nudge]) cylinder(d=screwHoleSize,h=screwLength);
}