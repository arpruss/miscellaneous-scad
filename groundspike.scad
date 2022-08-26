od = 12;
id = 8;
length = 100;
pointDiameter = 4;
thickness = 8;
minThickness = 3;

$fn = 32;

difference() {
    hull() {
        cylinder(d=od,h=thickness);
        translate([length,0]) cylinder(d=pointDiameter,h=minThickness);
    }
    cylinder(d=id,h=3*thickness,center=true);
}