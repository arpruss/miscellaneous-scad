wall = 1.5;
sightHeight = 8;
frontSightLength = 20;
rearSightLength = 15;
rearSightGapToThicknessRatio = 1.1;
sightThickness = 2;
slope = -sightHeight/2000; // TODO
remoteLength = 160;

module profileFront() {
    h = sightHeight+slope*remoteLength;
    polygon([[-frontSightLength,-wall],[0,-wall],[0,h],[-0.2*frontSightLength,-0.2*frontSightLength*slope+h],[-frontSightLength,0]]);
}

module profileRear() {
    polygon([[0,-wall],[rearSightLength,-wall],[rearSightLength,0],[rearSightLength*0.2,sightHeight+rearSightLength*0.2*slope],[0,sightHeight]]);
}

//profileFront();
//profileRear();

module rearSight() {
    rotate([0,-90,0])
    translate([0,0,-0.5*sightThickness*(2+rearSightGapToThicknessRatio)]) {
        linear_extrude(height=sightThickness) profileRear();
        translate([0,0,sightThickness*(1+rearSightGapToThicknessRatio)])
        linear_extrude(height=sightThickness) profileRear();
    }
}

module frontSight() {
    rotate([0,90,0])
    translate([0,0,-0.5*sightThickness]) 
        linear_extrude(height=sightThickness) profileFront();
}

frontSight();