thickness = 2.5;
handleDiameter = 10;
length = 77;

cylinder(d=handleDiameter,h=thickness,$fn=32);
translate([0,0,thickness/2])
rotate([0,90,0]) rotate([0,0,360/16]) cylinder(d=thickness/cos(180/8),h=length-handleDiameter/2,$fn=8);
translate([length-handleDiameter/2,0,thickness/2])
sphere(d=thickness,$fn=16);
