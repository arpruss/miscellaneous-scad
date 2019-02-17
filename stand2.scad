rodDiameter = 0.75 * 25.4 - 1;

render(convexity=1) {
intersection() {
   // translate([0,0,-72]) sphere(d=200);
   // cylinder(d=130,h=50*4);
}

    translate([0,0,25])
difference() {
    union() {
    #cylinder(d=rodDiameter,h=52+20-3);
    translate([0,0,52+20-3.01]) cylinder(d1=rodDiameter,d2=rodDiameter-3,h=3);
    }
    cylinder(d=rodDiameter-3,h=52+20);
}
}

translate([0,-50,0])
rotate([30,0,0])
linear_extrude(height=13) 
text("Live Oak JCL", halign="center", size=6);