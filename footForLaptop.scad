tolerance = 0.2;
d=20;
h=9;
angle = atan(h/220);
rubberStickyHeight = 2.09;
rubberInset = 0.75;
adjHeight = h - (rubberStickyHeight-rubberInset);

$fn = 36;

render(convexity=2)
intersection() {
    rotate([angle,0,0])
    difference() {
        translate([0,0,-10])
        cylinder(d=d-2*tolerance, h=adjHeight+10);
        translate([0,0,adjHeight-rubberInset])
        cylinder(d=8.45+2*tolerance, h=rubberInset+1);
    }
    cylinder(d=d+10, h=adjHeight+10);
}