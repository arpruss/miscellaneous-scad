use <Bezier.scad>;

//<params>
cleatWidth = 12.4;
cleatLength = 19.5;
cleatMinWidth = 1.1;
cleatHead = 2.9;
bezel = 3;
tolerance = 0.6;
headTolerance = 1.5;
neckDiameter = 5;
headDiameter = 10;
headHeight = 3;
thickness = 3;
slide = 15;
//</params>

module dummy(){}

$fn = 32;

width = cleatWidth + 2*bezel;

module cleat() {
    inside = Bezier([[0,0],LINE(),LINE(),[0,cleatWidth/2],LINE(),LINE(),[cleatHead,cleatWidth/2],POLAR(cleatWidth/2,-90),POLAR(cleatLength/2,180),[cleatLength,cleatMinWidth/2],LINE(),LINE(),[cleatLength,0],REPEAT_MIRRORED([0,1])]);
    difference() {
        offset(r=bezel) polygon(inside);
        polygon(inside);
    }
}

module base(extra=0) {
    translate([width/2+extra,0]) {
        cleat();
        hull() {
            translate([-cleatHead,-width/2]) square([cleatHead,width]);
            translate([-width/2-extra,0]) circle(d=width);
        }
    }
}

module male() {
    linear_extrude(height=thickness) base();
    cylinder(d=neckDiameter,h=thickness+headHeight+tolerance+thickness);
    translate([0,0,thickness+thickness+tolerance]) cylinder(d=headDiameter,h=headHeight);
}

module male() {
    linear_extrude(height=thickness) base();
    cylinder(d=neckDiameter,h=thickness+headHeight+tolerance+thickness);
    translate([0,0,thickness+thickness+tolerance]) cylinder(d=headDiameter,h=headHeight);
}

module female() {
    linear_extrude(height=thickness) 
    difference() {
        base(extra=slide+neckDiameter/2+tolerance);
        hull() {
            circle(d=neckDiameter+2*tolerance);
            translate([slide,0,0]) circle(d=neckDiameter+2*tolerance);
        }
        translate([slide,0,0]) circle(d=headDiameter+2*headTolerance);
    }
}


translate([0,width+2,0])
male();
female();