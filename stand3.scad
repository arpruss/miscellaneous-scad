baseDiameter = 40;
thickness = 1.5;
innerSpace = 3.1;
height = 18;
topWidth = 15;


module vertical() {
    hull() {
        translate([-baseDiameter/2,-thickness/2,0]) cube([thickness,thickness,thickness]);
        translate([baseDiameter/2-thickness,-thickness/2,0]) cube([thickness,thickness,thickness]);
        translate([-topWidth/2,-thickness/2,height]) cube([thickness,thickness,thickness]);
        translate([topWidth/2-thickness,-thickness/2,height]) cube([thickness,thickness,thickness]);
    }
    
}
cylinder(d=baseDiameter,h=thickness);
translate([0,thickness/2+innerSpace/2,0])
vertical();
translate([0,-thickness/2-innerSpace/2,0])
vertical();
