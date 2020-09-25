gap = 5;
id = 29.85;
od = 35.2;
gapTolerance = -.25;
radialTolerance = -.3;
outerRimThickness = 2.5; // increase!?
outerRimDiameter = 32.8;

module dummy(){}

$fn=72;

gap1 = gap+gapTolerance;
id1 = id-2*radialTolerance;

upperRimThickness = (od-id1)/2;
cylinder(d=id1,h=outerRimThickness+upperRimThickness+gap1);
cylinder(d=outerRimDiameter,h=outerRimThickness);
translate([0,0,outerRimThickness+gap1]) cylinder(d1=id1,d2=od,h=upperRimThickness);