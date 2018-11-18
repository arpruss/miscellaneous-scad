use <tubemesh.scad>;

//<params>
h = 114.3;
w = 69.85;
screwSpacing = 82.55;
thickness = 5;
taper = 5;
screwDiameter = 4;
screwHeadDiameter = 8.25;
screwHeadDepth = 2.25;
taperFormula = "asin(t)/90";
//</params>

module dummy() {}

nudge = 0.01;

slice0 = [ [ -w/2,-h/2 ],[ w/2,-h/2], [w/2,h/2], [-w/2,h/2]];
slice1 = [ [ -w/2+taper,-h/2+taper],[ w/2-taper,-h/2+taper], [w/2-taper,h/2-taper], [-w/2+taper,h/2-taper]];

$fn = 32;
difference() {
    morphExtrude(slice0,slice1,height=thickness,curve=taperFormula,numSlices=40);
    translate([0,0,-nudge])
    for (s=[-1,1]) {
        translate([0,s*screwSpacing/2,0]) {
        cylinder(d=screwDiameter,h=thickness+2*nudge);
        translate([0,0,thickness-screwHeadDepth]) cylinder(d=screwHeadDiameter,h=screwHeadDepth+nudge*2);
        }
    }
}