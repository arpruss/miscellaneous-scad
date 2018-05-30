innerWidth=8.34;
innerThickness=2.87;
connectorLength=29;
tolerance=0.3;
outerDiameter=14.11;
nudge = 0.001;

difference() {
    union() {
    cylinder(d=outerDiameter-2*tolerance,h=connectorLength);
        translate([0,0,connectorLength-nudge])
    cylinder(d1=outerDiameter-2*tolerance,d2=0,h=outerDiameter/2);
    }
    translate([0,0,-nudge]) {
        cube([innerWidth+2*tolerance,innerThickness+2*tolerance,3*connectorLength], center=true);
    }
}