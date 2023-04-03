use <quickthread.scad>;

//<params>
screwSizeInches = 0.375;
screwTPI = 16;

tolerance = 0.11;
screwLength = 7;
headThickness = 2;
headRadius = 13;
headCircle = 14;
knobSize = 5;
symmetry = 3;
taperLength = 1;
//</params>

module dummy() {}

d = screwSizeInches * 25.4 - tolerance*2;

translate([0,0,headThickness-0.01]) intersection() {
    isoThread(d=d, h=screwLength, tpi=16, internal=false,$fn=24);
    union() {
        cylinder(d=d, h=screwLength-taperLength, $fn=24);
        translate([0,0,screwLength-taperLength-0.01]) cylinder(d1=d,d2=d-2*taperLength,h=taperLength+0.01, $fn=24);
    }
}
linear_extrude(height=headThickness) {
    for (i=[0:symmetry-1]) hull() {
        circle(d=headCircle,$fn=64);
        rotate(360/symmetry*i) translate([headRadius-knobSize/2,0]) circle(knobSize,$fn=64);
    }
}