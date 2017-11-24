tolerance = 0.45;
outer = 39.2767;
inner =  17.9267;
height = 22.9;
circleR = 19.4/2;
circleCenter = outer-circleR;
wall = 1;

$fn = 50;
render(convexity=2)
difference() {
    cylinder(h=height+wall,r=outer+tolerance+wall);
    translate([0,0,wall])
    cylinder(h=height+wall,r=outer+tolerance);
}
render(convexity=2)
difference() {
    cylinder(h=12,r=inner-tolerance);
    translate([0,0,-1]) cylinder(h=14,r=inner-tolerance-wall);
}

linear_extrude(height=wall+2)
for (i=[0:7]) {
    angle = i*360/8;
    rotate(angle) translate([circleCenter,0]) circle(r=circleR-tolerance);
}
