clipAngle = atan(5/(66*2.54));
echo(clipAngle);
clipLength = 48; 
clipWallThickness = 1.55;
clipBottomStickout = 30;
clipAttachmentThickness = 8;
poleDiameter = 19.14;
screwHoleSize = 3;
screwHoleCountersinkDiameter = 8;
screwHoleCountersinkDepth = 3;

hangerWidth = 40;
hangerThickness = 8;

nudge = 0.01;

module clip() {
    render(convexity=5)
    translate([0,poleDiameter/2+clipWallThickness,])
    difference() {
        union() {
            translate([-clipAttachmentThickness/2,-clipBottomStickout-poleDiameter/2,0])
            cube([clipAttachmentThickness,clipBottomStickout,clipLength]);
                cylinder(h=clipLength,d=poleDiameter+2*clipWallThickness);
        }
        translate([0,poleDiameter*.85,clipLength]) rotate([-45,0,0])
        cube(center=true,poleDiameter+2*clipWallThickness);
translate([0,0,clipLength-clipWallThickness+nudge]) cylinder(h=clipWallThickness,d1=poleDiameter,d2=poleDiameter+2*clipWallThickness);
        translate([0,0,-nudge]) {
            cylinder(h=clipLength+2*nudge,d=poleDiameter);
            translate([0,1.5*(clipWallThickness+poleDiameter/2),0]) linear_extrude(height=clipLength+2*nudge) square(center=true, poleDiameter+2*clipWallThickness+2*nudge);
        }
    }
}

module screwHole() {
rotate([90,0,0])
translate([0,0,-nudge]) {
    cylinder(d=screwHoleSize, $fn=4, h=hangerThickness+2*nudge); 
    cylinder(d=screwHoleCountersinkDiameter, $fn=16, h=screwHoleCountersinkDepth);
    }
}

module wallAttachment() {
    render(convexity=2)
    intersection() {
    translate([-250,-250,0]) cube([500,500,clipLength]);
    rotate([clipAngle,0,0])
    {
    translate([0,-clipBottomStickout-hangerThickness,0]) difference() {
    translate([-hangerWidth/2,0,-clipLength])
        cube([hangerWidth, hangerThickness, 3*clipLength]);
        translate([hangerWidth*.35,clipAttachmentThickness,clipLength*.3]) screwHole();
        translate([hangerWidth*.35,clipAttachmentThickness,clipLength*.8]) screwHole();
        translate([-hangerWidth*.35,clipAttachmentThickness,clipLength*.3]) screwHole();
        translate([-hangerWidth*.35,clipAttachmentThickness,clipLength*.8]) screwHole();
    }
    translate([-hangerWidth/2,0,-clipLength])
        translate([hangerWidth/2-clipAttachmentThickness/2,-clipBottomStickout,0])
        cube([clipAttachmentThickness,clipBottomStickout,3*clipLength]);
    }
    }
}

clip();
wallAttachment();
