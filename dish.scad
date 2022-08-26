od = 53.2;
h = 14;
wall = 1.5;

$fn = 136;

difference() {
    cylinder(d=od,h=h);
    translate([0,0,wall]) cylinder(d=od-2*wall,h=h);
}