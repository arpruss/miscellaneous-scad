railTolerance = 0.63;

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


module nerfRail(positive=false,length=40,tolerance=0.25) {
    outerWidth = 18.25;
    outerThickness = 2.87;
    valleyDepth = 1.43;
    shoulderWidth = 5.41;
    nubDistanceFromFront = 15;
    nubSize=1.81;
    nubThickness=.9;
    overhang = 2.94;
    outerDepth = 3.56;
    nudge = 0.01;
        
    // positive tolerance makes it larger
    module positiveRailProfile(tolerance=0) {
    points=[[-outerWidth/2-tolerance+overhang,0],
        [-outerWidth/2-tolerance+overhang,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance+valleyDepth,
        outerDepth+outerThickness+tolerance-valleyDepth+tolerance],
        [nudge,
        outerDepth+outerThickness+tolerance-valleyDepth+tolerance],
        [nudge,0]    
        ];

        union() {
            polygon(points=points);
            scale([-1,1,1]) polygon(points=points);
        }
    }

    module negativeRailProfile(tolerance=0.25) {
        translate([0,-outerDepth/2+tolerance])
        render(convexity=3) difference() {
            translate([-tolerance-outerWidth/2-outerDepth/2,outerDepth/2-tolerance]) square([outerWidth+outerDepth+2*tolerance,overhang+outerDepth+2*tolerance]);
            positiveRailProfile(tolerance=tolerance);
        }
        
        
    }
    
    module nub() {
        hull() {
        translate([-outerWidth/2+shoulderWidth+tolerance+valleyDepth+nubSize/2,0,0])
        rotate([90,0,0])
        linear_extrude(height=nubThickness,scale=0.25)
        square(nubSize,center=true);
        translate(-[-outerWidth/2+shoulderWidth+tolerance+valleyDepth+nubSize/2,0,0])
        rotate([90,0,0])
        linear_extrude(height=nubThickness,scale=0.25)
        square(nubSize,center=true);
        }
    }
        
    if (positive) {
        linear_extrude(height=length)
        positiveRailProfile(tolerance=-tolerance);
    }
    else {
        translate(-[0,overhang+outerDepth+2*tolerance,0]) {
        linear_extrude(height=length)
        negativeRailProfile(tolerance=tolerance);
        translate([0,(outerDepth+outerThickness+3*tolerance-valleyDepth)-outerDepth/2+nudge,length-nubDistanceFromFront+tolerance])
        nub();
        }
    }
  
}


tube();
translate([0,tubeInnerRadius+wallThickness-clipWallThickness,0])
rotate([0,0,180])
nerfRail(tolerance=railTolerance);
