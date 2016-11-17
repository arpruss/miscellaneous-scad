n = 15;
lockable = false;
pusher_width_correction = 0.21;
guide_upper_thickness_correction = 0.5;
guide_lower_thickness_correction = 0.2;
cylinder_diameter_correction = 0.35;
chamber_wall_correction = 0.13;
pusher_lower_height_correction = 0.4;

// The corrections are for printing with:
// 0.4mm nozzle, using 0.3mm layers, 
// bottom layer squashed down a bit with a z-offset adjustment.

module dummy() {}

center_guide_height = 0; // should be 16;

chamber_wall_thickness = 1.05-chamber_wall_correction; //should be 1.05 ideally
guide_thickness = 1.5;

nudge = 0.001;

chamber_spacing = 84.95/5;
total_height = 50.3;

module guide(upper) {
    h = upper ? guide_thickness - guide_upper_thickness_correction : guide_thickness - guide_lower_thickness_correction;
    translate([0,0.89-2.36,0])
    linear_extrude(height=h) {
        difference() {
            union() {
                translate([1,0,0]) circle(d=18.4);
                translate([(n-1)*chamber_spacing-1.,0,0]) circle(d=18.4);
                translate([0,-18.4/2,0]) square([(n-1)*chamber_spacing, 18.4]);
            }
            if (upper)
            square([(n-1)*chamber_spacing,18.4/2]);
        }
    }
}

module pusher(first) {
    dh = (first && lockable) ? 2.36 : 0;
   extra_width = 2.5;
   width = extra_width + 5.06 - pusher_width_correction;
    // dz = 4.66, dx = 4.98
   translate([-extra_width,15.4/2,4.29-dh]) rotate([90,0,0]) translate([-width/2,0,(0.5+0.2-3.02)]) linear_extrude(height=5.02+3) polygon(points=[[0,0],[width,0],[width,dh+5.19-pusher_lower_height_correction-extra_width*1.25],[0,dh+9.45]]);
}

module chamberShape(i, inward) {
    translate([i*chamber_spacing,0,inward]) union() {
        cylinder(h=20.5, d=15.4-.2-inward*2);
        translate([0,0,20.5-nudge]) 
        cylinder(h=1.25+2*nudge, d1=15.4-.2-inward*2, d2=16.4-inward*2);
        translate([0,0,20.5+1.25-nudge]) cylinder(h=total_height-(20.5+1.25)+2*nudge, d=16.4-inward*2);
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
    translate([0,-(15.4/2-1.16+0.53+0.35),0]) rotate([90,0,0])
    linear_extrude(height=1.16+nudge, scale=5.03/2.4) circle(d=2.4, $fn=10);
}

module bump_guides() {
    translate([-5.03/2,0,0]) rotate([90,0,0])
    linear_extrude(height=0.53+0.35+15.4/2) 
        square([chamber_spacing*(n-1)+5.03,24.24+nudge]);
}

module blocker() {
    // 3.03 vs 6.13
    // diameter is 16.3
    translate([chamber_spacing*(n-1)-7.1/2+(6.13-3.03)/2,-2.22-16.4/2,total_height-14.73+1]) cube([7.1, 6-1, 5.35-.5]);
}

module chambers() {
    render(convexity=10)
    difference() {
        union() {
            difference() {
                union() {
                    blocker();
                    bump_guides();
                    guide(false);
                    translate([0,0,24.24])
                        guide(true);
                    linear_extrude(height=total_height) square([(n-1)*chamber_spacing,chamber_wall_thickness]);
                    for (i=[0:n-1]) {
                        chamberShape(i,0);
                        translate([i*chamber_spacing,0,0]) pusher(i==0);
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
                translate([i*chamber_spacing,0,0]) cylinder(h=19.5+center_guide_height, d=3.9+2*chamber_wall_thickness, $fn=8);
            }
        }
        for (i=[0:n-1]) {                    translate([i*chamber_spacing,0,-nudge]) cylinder(h=19.5+center_guide_height+2*nudge, d=3.9+0.35, $fn=8);
            translate([i*chamber_spacing,0,19.5+center_guide_height/2]) cube(size=[3.9+2*chamber_wall_thickness,3,center_guide_height+nudge*2], center=true);
        }
    }
}
//pusher();
rotate([0,0,-45])
chambers();
