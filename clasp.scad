use <Bezier.scad>;

//<params>
cleatWidth = 12.4;
cleatLength = 15;
cleatMinWidth = 1.1;
cleatHead = 2.9;
bezel = 2.5;
tolerance = 0.4;
headTolerance = 0.5;
neckDiameter = 5;
headDiameter = 12;
headHeight = 1;
thickness = 2.5;
slide = 15;
//</params>

module dummy(){}

$fn = 32;
nudge = 0.001;

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
            translate([-bezel,-width/2]) square([bezel,width]);
            translate([-width/2-extra,0]) circle(d=width);
        }
    }
}

module male() {
    linear_extrude(height=thickness) base();
    cylinder(d=neckDiameter,h=thickness+headHeight+thickness);
    
    angled = (headDiameter-neckDiameter)/2;
    
    translate([0,0,thickness+thickness]) cylinder(d1=neckDiameter,d2=headDiameter,h=angled);
    translate([0,0,thickness+thickness+angled-nudge]) cylinder(d=headDiameter,h=headHeight+nudge);
}

module female() {
    linear_extrude(height=thickness) 
    difference() {
        base(extra=slide+neckDiameter/2+tolerance-(width-headDiameter)/2);
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