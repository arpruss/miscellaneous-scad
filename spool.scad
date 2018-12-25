nubToNubDistance = 50;
nubLength = 5;
nubThickness = 2;
endDiameter = 30;
endThickness = 2;
insideDiameter = 10;
pressFitTolerance = 0.2;
threadHoleDiameter = 3;

module dummy() {}

nudge = 0.001;
$fn = 64;

module end() {
    difference() {
        union() {
            cylinder(d=endDiameter,h=endThickness);
            cylinder(d1=insideDiameter+pressFitTolerance*2+2*endThickness,d2=insideDiameter+pressFitTolerance*2,h=endThickness*2);
        }
        translate([0,0,-nudge])
        cylinder(d=insideDiameter+pressFitTolerance*2,h=endThickness+nudge);
    }
    translate([0,0,2*endThickness-nudge])
    cylinder(d=nubThickness, h=nubLength+nudge);
}

module inside() {
    fullEndThickness = nubLength+2*endThickness;
    length = nubToNubDistance - 2*fullEndThickness + 2*endThickness;
    difference() {
        cylinder(d=insideDiameter,h=length);
        translate([0,0,(length-2*endThickness)*.75+endThickness]) rotate([90,0,0])
        cylinder(d=threadHoleDiameter,h=insideDiameter*2,center=true);
    }
}

end();
translate([-endDiameter/2-insideDiameter/2-5,0,0]) inside();
translate([endDiameter+5,0,0]) end();
