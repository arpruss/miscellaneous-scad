use <tubemesh.scad>;

h = 4.5*25.4;
w = 2.75*25.4;
spacing = 3.25*25.4;
thickness = 5;
taper = 5;
screwDiameter = 4;
screwHead = 8.25;
screwHeadDepth = 2.25;
nudge = 0.01;

function slice(taper,z) = [ [ -w/2+taper,-h/2+taper,z ],[ w/2-taper,-h/2+taper,z], [w/2-taper,h/2-taper,z], [-w/2+taper,h/2-taper,z]];

$fn = 32;
difference() {
    tubeMesh([for(t=[0:0.025:1]) slice(taper*asin(t)/90,t*thickness)]);
    translate([0,0,-nudge])
    for (s=[-1,1]) {
        translate([0,s*spacing/2,0]) {
        cylinder(d=screwDiameter,h=thickness+2*nudge);
        translate([0,0,thickness-screwHeadDepth]) cylinder(d=screwHead,h=screwHeadDepth+nudge*2);
        }
    }
}