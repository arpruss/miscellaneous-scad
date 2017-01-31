rodDiameter = 0.75 * 25.4 - 1;

render(convexity=1) {
intersection() {
    translate([0,0,-72]) sphere(d=200);
    cylinder(d=130,h=50*4);
}

    translate([0,0,25])
difference() {
    #cylinder(d=rodDiameter,h=52+20);
    cylinder(d=rodDiameter-4,h=52+20);
}
}