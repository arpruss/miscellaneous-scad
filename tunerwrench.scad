cylinder_height = 35;
wall_thickness = 2.4;

handle_height = 13;
handle_length = 24;
handle_thickness = 10;

hole_desired_height = 20.4;
hole_desired_width = 22.69;
hole_desired_middle_thickness = 8.24;
hole_desired_outer_thickness = 4.52;

tolerance = 0.5;

hole_height = hole_desired_height + tolerance;
hole_width = hole_desired_width + 2*tolerance;
hole_middle_thickness = hole_desired_middle_thickness + 2*tolerance;
hole_outer_thickness = hole_desired_outer_thickness + 2*tolerance;

cylinder_radius = wall_thickness + sqrt(pow(hole_outer_thickness / 2,2) +pow(hole_width/2,2));

module dummy(){}

nudge = 0.01;

module main() {
    cylinder(h=cylinder_height, r=cylinder_radius);
    translate([-handle_length-cylinder_radius,-handle_thickness/2,0]) cube([2*handle_length+2*cylinder_radius,handle_thickness,handle_height]);
    translate([-handle_length-cylinder_radius,0,0]) cylinder(h=handle_height, d=handle_thickness);
    translate([handle_length+cylinder_radius,0,0]) cylinder(h=handle_height, d=handle_thickness);
}

module hole() {
    delta = (hole_middle_thickness - hole_outer_thickness)/2;
    a = hole_width / 2;
    r = (a*a+delta*delta)/(2*delta);
    render(convexity=5)
    translate([0,0,cylinder_height-hole_height]) 
    intersection() {
    translate([r-delta-hole_outer_thickness/2,0,0]) cylinder(r=r, h=hole_height+nudge,$fn=60);
    translate([-r+delta+hole_outer_thickness/2,0,0]) cylinder(r=r, h=hole_height+nudge,$fn=60);
    translate([0,0,hole_height/2]) cube(center=true,[hole_middle_thickness,hole_width,hole_height+nudge]);
    }
}

difference() {
render(convexity=15)
    main();
render(convexity=15)
    hole();
}