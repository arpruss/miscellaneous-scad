clipAngle = 1.71;
clipLength = 48; 
poleDiameter = 19.14;

webThickness = 1.55;
clipBottomStickout = 30;
clipAttachmentThickness = 8;

screwHoleSize = 3;
screwHoleCountersinkDiameter = 8;
screwHoleCountersinkDepth = 3;

flangeWidth = 40;
flangeThickness = 8;

bottomScrewsHeightFactor = 0.3; // this is weirdly dependent on the angle -- just experiment 
topScrewsHeightFactor = 0.8; // this is weirdly dependent on the angle -- just experiment

nudge = 0.01;

module clip() {
    render(convexity=5)
    translate([0,poleDiameter/2+webThickness,])
    difference() {
        union() {
            translate([-clipAttachmentThickness/2,-clipBottomStickout-poleDiameter/2,0])
            cube([clipAttachmentThickness,clipBottomStickout,clipLength]);
                cylinder(h=clipLength,d=poleDiameter+2*webThickness);
        }
        translate([0,poleDiameter*.85,clipLength]) rotate([-45,0,0])
        cube(center=true,poleDiameter+2*webThickness);
translate([0,0,clipLength-webThickness+nudge]) cylinder(h=webThickness,d1=poleDiameter,d2=poleDiameter+2*webThickness);
        translate([0,0,-nudge]) {
            cylinder(h=clipLength+2*nudge,d=poleDiameter);
            translate([0,1.5*(webThickness+poleDiameter/2),0]) linear_extrude(height=clipLength+2*nudge) square(center=true, poleDiameter+2*webThickness+2*nudge);
        }
    }
}

module screwHole() {
rotate([90,0,0])
translate([0,0,-nudge]) {
    cylinder(d=screwHoleSize, $fn=4, h=flangeThickness+2*nudge); 
    cylinder(d=screwHoleCountersinkDiameter, $fn=16, h=screwHoleCountersinkDepth);
    }
}

module wallAttachment() {
    render(convexity=2)
    intersection() {
    translate([-250,-250,0]) cube([500,500,clipLength]);
    rotate([clipAngle,0,0])
    {
    translate([0,-clipBottomStickout-flangeThickness,0]) difference() {
    translate([-flangeWidth/2,0,-clipLength])
        cube([flangeWidth, flangeThickness, 3*clipLength]);
        translate([flangeWidth*.35,clipAttachmentThickness,clipLength*bottomScrewsHeightFactor]) screwHole();
        translate([flangeWidth*.35,clipAttachmentThickness,clipLength*topScrewsHeightFactor]) screwHole();
        translate([-flangeWidth*.35,clipAttachmentThickness,clipLength*bottomScrewsHeightFactor]) screwHole();
        translate([-flangeWidth*.35,clipAttachmentThickness,clipLength*topScrewsHeightFactor]) screwHole();
    }
    translate([-flangeWidth/2,0,-clipLength])
        translate([flangeWidth/2-clipAttachmentThickness/2,-clipBottomStickout,0])
        cube([clipAttachmentThickness,clipBottomStickout,3*clipLength]);
    }
    }
}

clip();
wallAttachment();
