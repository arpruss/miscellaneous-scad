height = 3.2;
thick_height = 3;
diameter = 11;
thick_diameter = 18;

hole_diameter_tolerance = 0;
hole_diameter_base_size = 0;
nut_thickness = 2.74;
nut_width_tolerance = 0.35;
nut_width_base_size = 7.85;

module dummy() {}

hole_diameter = hole_diameter_base_size + hole_diameter_tolerance;
nut_width = nut_width_base_size + nut_width_tolerance;

nudge = 0.001;

pi = 3.141592653589793;

module knurledCylinder(h=10,r1=5,r2=1.5) {
    n = ceil(2 * pi * r1 / (2 * r2));
    cylinder(h=h,r=r1,$fn=n);
    for (i=[0:n-1]) {
        x = r1*cos(360./n*i);
        y = r1*sin(360./n*i);
        translate([x,y,0]) cylinder(h=h,r=r2,$fn=12);
    }
}

render(convexity=10)
difference() {
    union() {
        cylinder(h=height,r=diameter/2,$fn=24);
        knurledCylinder(h=thick_height,r1=thick_diameter/2);
    }
    translate([0,0,-nudge]) cylinder(h=height+2*nudge,d=hole_diameter,$fn=12);
    translate([0,0,height-nut_thickness])
    cylinder(h=nut_thickness+nudge,d=nut_width*2/sqrt(3), $fn=6);
}