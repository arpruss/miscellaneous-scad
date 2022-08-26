outer = 197;
width = 4;

module post() {
    cylinder(d=width,h=40);
}

linear_extrude(height=5)
difference() {
    square(outer);
    translate([width-1,width-1])
    square(outer-width*2+2);
}

translate([width/2,width/2]) post();
translate([outer-width/2,width/2]) post();
translate([outer-width/2,outer-width/2]) post();
translate([width/2,outer-width/2]) post();
