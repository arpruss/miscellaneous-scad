n = 2;

chamber_wall_thickness = 1.05;
guide_thickness = 1.5;

nudge = 0.001;

chamber_spacing = 84.95/5;

module guide(upper) {
    translate([0,0.89-2.36,0])
    linear_extrude(height=guide_thickness) {
        difference() {
            union() {
                circle(d=18.4);
                translate([(n-1)*chamber_spacing,0,0]) circle(d=18.4);
                translate([0,-18.4/2,0]) square([(n-1)*chamber_spacing, 18.4]);
            }
            if (upper)
            square([(n-1)*chamber_spacing,18.4/2]);
        }
    }
}

module pusher() {
   translate([0,15.4/2,4.29]) rotate([90,0,0]) translate([-5.13/2,0,-3.02]) linear_extrude(height=5.02) polygon(points=[[0,0],[5.13,0],[5.13,5.38],[0,9.45]]);
}

module chamberShape(i, inward) {
    translate([i*chamber_spacing,0,inward]) union() {
        cylinder(h=20.5, d=15.4-inward*2);
        translate([0,0,20.5-nudge]) cylinder(h=1.25+2*nudge, d1=15.4-inward*2, d2=16.4-inward*2);
        translate([0,0,20.5+1.25-nudge]) cylinder(h=21.5+nudge, d=16.4-inward*2);
    }
}

module side_hole() {
    translate([0,15.4/2,18.5])
    rotate([90,0,0])
    translate([0,0,-1.5*chamber_wall_thickness])
    linear_extrude(height=3*chamber_wall_thickness) {
        circle(d=2.5);
        translate([0,6-2.5,0]) circle(d=2.5, $fn=8);
        translate([-2.5/2,0,0]) square([2.5, 6-2.5]);
    }
}

module bump_hole() {
    translate([0,-(15.4/2-0.6+0.53),0]) rotate([90,0,0])
    linear_extrude(height=0.6+nudge, scale=5.03/1.91) circle(d=1.91, $fn=10);
}

module bump_guides() {
    translate([-5.03/2,0,0]) rotate([90,0,0])
    linear_extrude(height=0.53+15.4/2) square([chamber_spacing*(n-1)+5.03,24.24+nudge]);
}

module chambers() {
    render(convexity=10)
    difference() {
        union() {
            difference() {
                union() {
                    bump_guides();
                    guide(false);
                    translate([0,0,24.24])
                        guide(true);
                    linear_extrude(height=20.5+21.5) square([(n-1)*chamber_spacing,chamber_wall_thickness]);
                    for (i=[0:n-1]) {
                        chamberShape(i,0);
                        translate([i*chamber_spacing,0,0]) pusher();
                    }
                }
                for (i=[0:n-1]) {
                    chamberShape(i,chamber_wall_thickness);
                    translate([i*chamber_spacing,0,0]) side_hole();
                    translate([i*chamber_spacing,0,6.6]) bump_hole();
                    translate([i*chamber_spacing,0,19.7]) bump_hole();
                }
            }
            for (i=[0:n-1]) {
                translate([i*chamber_spacing,0,0]) cylinder(h=19.5, d=3.9+2*chamber_wall_thickness, $fn=8);
            }
        }
        for (i=[0:n-1])                     translate([i*chamber_spacing,0,-nudge]) cylinder(h=19.5+2*nudge, d=3.9, $fn=8);

    }
}
//pusher();
chambers();
