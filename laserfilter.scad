filterDiameter = 9.7;
laserDiameter = 14.13;
thickness = 1;
holeDiameter = 6.5;
height = 9;
tolerance = 0.3;

module dummy(){}

$fn = 36;
nudge = 0.001;

difference() {
    cylinder(d=laserDiameter+2*thickness+2*tolerance,h=height);
    translate([0,0,thickness*2])
        cylinder(d=laserDiameter+2*tolerance,h=height);
    translate([0,0,-nudge])
    cylinder(d=holeDiameter+2*tolerance,h=height+nudge);
    translate([0,0,thickness])
    cylinder(d=filterDiameter+2*tolerance,h=height+nudge);
}