tolerance = 0.2;
d=12.56;
h=12.63+5.03-1.5;
rubberStickyHeight = 2.09;
rubberInset = 0.75;
adjHeight = h - (rubberStickyHeight-rubberInset);

$fn = 36;

render(convexity=2)
difference() {
    cylinder(d=12.56-2*tolerance, h=adjHeight);
    translate([0,0,adjHeight-rubberInset])
    cylinder(d=8.45+2*tolerance, h=rubberInset+1);
}