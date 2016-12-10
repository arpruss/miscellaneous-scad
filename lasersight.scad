laserDiameter = 10;
wallThickness = 1.5;
lowerLipThickness = 1.5;
laserButtonStickout = 1.85; // distance button sticks out of tube
laserButtonDistanceFromBottomOfLaser = 29.3;
laserButtonScrewDiameter = 3.06; 
backStickout = 2; // how far laser will stick out of tube
clipLength = 30; 
clipWallThickness = 1;
blowgunDiameter = 15.9;

adjustmentRatio = 0.072;
adjustmentScrewDistance = 44.5;
adjustmentScrewDiameter = 2.4; 

laserButtonDistance = laserButtonDistanceFromBottomOfLaser - backStickout;
totalLength = adjustmentScrewDistance + 6;

tubeInnerRadius = laserDiameter/2 + laserButtonStickout + laserButtonDistance * adjustmentRatio;


nudge = 0.01;

module screw(height, angle, diameter, positive) {
    translate([0,0,height]) rotate([90,0,angle]) translate([0,0,tubeInnerRadius-wallThickness])
    if(positive) {
        rotate([0,0,45])
        cylinder(d2=diameter*2.5,d1=diameter*2.5+6*wallThickness,h=3*wallThickness,$fn=4);
    }
    else {
        rotate([0,0,22.5])
        translate([0,0,-nudge]) cylinder(d=diameter*1.082,h=3*wallThickness+2*nudge,$fn=8);
    }
}

module tube() {
    render(convexity=8)
    difference() {
        union() {
            cylinder(h=totalLength+nudge, r=tubeInnerRadius+wallThickness);
            screw(laserButtonDistance, 0, laserButtonScrewDiameter,true);
            screw(adjustmentScrewDistance, 0, adjustmentScrewDiameter,true);
            screw(adjustmentScrewDistance, 120, adjustmentScrewDiameter,true);
            screw(adjustmentScrewDistance, -120, adjustmentScrewDiameter,true);
        }
        translate([0,0,-nudge]) cylinder(h=totalLength+2*nudge, r=tubeInnerRadius);
            screw(laserButtonDistance, 0, laserButtonScrewDiameter,false);
            screw(adjustmentScrewDistance, 0, adjustmentScrewDiameter,false);
            screw(adjustmentScrewDistance, 120, adjustmentScrewDiameter,false);
            screw(adjustmentScrewDistance, -120, adjustmentScrewDiameter,false);
            translate([0,0,totalLength]) cylinder(h=30, r=tubeInnerRadius+wallThickness);
    } 

    render(convexity=8)
    difference() {
        cylinder(h=lowerLipThickness, r=tubeInnerRadius+nudge);
        translate([0,0,-nudge]) cylinder(h=lowerLipThickness+2*nudge, d=laserDiameter);
    }
}

module clip() {
    render(convexity=5)
    translate([0,blowgunDiameter/2+clipWallThickness,0])
    difference() {
                cylinder(h=clipLength,d=blowgunDiameter+2*clipWallThickness);
        translate([0,blowgunDiameter*.85,clipLength]) rotate([-45,0,0])
        cube(center=true,blowgunDiameter+2*clipWallThickness);
translate([0,0,clipLength-clipWallThickness+nudge]) cylinder(h=clipWallThickness,d1=blowgunDiameter,d2=blowgunDiameter+2*clipWallThickness);
        translate([0,0,-nudge]) {
            cylinder(h=clipLength+2*nudge,d=blowgunDiameter);
            translate([0,1.5*(clipWallThickness+blowgunDiameter/2),0]) linear_extrude(height=clipLength+2*nudge) square(center=true, blowgunDiameter+2*clipWallThickness+2*nudge);
        }
    }
}

tube();
translate([0,tubeInnerRadius+wallThickness-clipWallThickness,0])
clip();
