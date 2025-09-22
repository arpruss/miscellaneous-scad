lensDiameter = 27;
lensTolerance = .15;
mountThickness = 3.5;
mountOuterDiameter = 32.22;
mountTolerance = -0.05;
lensEdge = 1.66;

insetDiameter = 25.8;
insertGap = 1;
insertExtraRadius = 2;

extraStretch = 4;

$fn = 128;

insetHeight = (mountThickness - lensEdge)/2;

module stretchedCircle(d=10,extra=extraStretch) {
    hull() {
        translate([-extra/2,0,0]) circle(d=d);
        translate([extra/2,0,0]) circle(d=d);
    }
}

linear_extrude(height=insetHeight)
difference() {
    stretchedCircle(d=mountOuterDiameter-2*mountTolerance);
    circle(d=insetDiameter);
}

d2 = mountOuterDiameter-2*mountTolerance;
d1 = lensDiameter+2*lensTolerance;

linear_extrude(height=mountThickness)
difference() {
    stretchedCircle(d=d2);
    circle(d=d1);
}

/*
h =insertGap+PI*(d1-insetDiameter);

translate([mountOuterDiameter+insertExtraRadius+5,0,0])
linear_extrude(height=insetHeight) difference() {
    circle(d=d1+insertExtraRadius*2);
    circle(d=insetDiameter+insertExtraRadius*2);
    translate([0,-h/2]) square([100,h]);
}
*/