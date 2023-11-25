width = 20;
length = 210;
inset = 4;
thickness = 9.5;
screwHole = 3.5;
headDiameter = 7;
headDepth = 3;
extraThickness = 1.5;
extraHoleDiameter = 7;
extraHoleDepth = 2.5;

$fn = 64;


module basic() {
linear_extrude(height=thickness-inset)
hull() {
    translate([-length/2,0]) circle(d=width);
    translate([length/2,0]) circle(d=width);
}

linear_extrude(height=thickness)
hull() {
    circle(d=width);
    translate([length/2,0]) circle(d=width);
}
cylinder(d=width,h=thickness+extraThickness);
}

difference() {
    basic();
    translate([0,0,-1])
    cylinder(d=screwHole,h=thickness+extraThickness+20);
    translate([0,0,-0.001]) cylinder(d=headDiameter,h=headDepth);
    translate([0,0,thickness+extraThickness-extraHoleDepth]) cylinder(d=extraHoleDiameter,h=extraHoleDepth+1);
}