l = 100;

cube([l,10,10]);
cube([10,l,10]);
translate([0,l-10,0]) cube([l,10,10]);
translate([l-10,0,0]) cube([10,l,10]);
cube([10,l,10]);
cube([10,10,l]);
translate([0,l-10,10]) linear_extrude(height=2) text("Y");
translate([l-10,0,10]) linear_extrude(height=2) text("X");
translate([0,0,l]) linear_extrude(height=2) text("Z");
