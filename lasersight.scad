adjustmentRatio = 1/14.;
laserDiameter = 10;
laserButtonStickout = 1.85;
auxButtonStickout = 1.19;
laserButtonDistanceFromBottomOfLaser = 29.3;
auxButtonDistanceFromBottomOfLaser = 22.65;
adjustmentScrewDistance = 44.5;
wallThickness = 1.5;
attachmentLength = 30;
attachmentWallThickness = 1;
blowgunDiameter = 15.9;
bottomStickout = 2;
adjustmentScrewDiameter = 2.4; 
laserButtonScrewDiameter = 3.06; 
auxButtonScrewDiameter = 0; // FIX?

laserButtonDistance = laserButtonDistanceFromBottomOfLaser - bottomStickout;
auxButtonDistance = auxButtonDistanceFromBottomOfLaser - bottomStickout;
totalLength = adjustmentScrewDistance + 6;
lowerLipThickness = 1.5;

tubeInnerRadius = laserDiameter/2 + max(laserButtonStickout + laserButtonDistance * adjustmentRatio, auxButtonStickout + auxButtonDistance * adjustmentRatio);


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

module attachment() {
    render(convexity=5)
    translate([0,blowgunDiameter/2+attachmentWallThickness,0])
    difference() {
                cylinder(h=attachmentLength,d=blowgunDiameter+2*attachmentWallThickness);
        #cube(center=true,blowgunDiameter+2*attachmentWallThickness);
translate([0,0,attachmentLength-attachmentWallThickness+nudge]) cylinder(h=attachmentWallThickness,d1=blowgunDiameter,d2=blowgunDiameter+2*attachmentWallThickness);
        translate([0,0,-nudge]) {
            cylinder(h=attachmentLength+2*nudge,d=blowgunDiameter);
            translate([0,1.4*(attachmentWallThickness+blowgunDiameter/2),0]) linear_extrude(height=attachmentLength+2*nudge) square(center=true, blowgunDiameter+2*attachmentWallThickness+2*nudge);
        }
    }
}

tube();
translate([0,tubeInnerRadius+wallThickness-attachmentWallThickness,0])
attachment();
