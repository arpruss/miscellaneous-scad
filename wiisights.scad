use <bezier.scad>

//<params>
wall = 2.25;
sightHeight = 3.25;
frontRingWidth = 12;
frontSightLength = 8;
rearRingWidth = 12;
rearSightLength = 8;
rearSightGapToThicknessRatio = 1.2;
sightThickness = 2;
frontTolerance = 0.12;
rearTolerance = 0.09;
distanceToTV = 2438;
// set to 9.5 to adjust for camera offset from sight-base
extraSightAdjust = -0;
sightSpacing = 140;
//</params>
slope = (-sightHeight-wall+extraSightAdjust)/distanceToTV;
echo(slope);

positionRear = [18.120254167,15.155849271];
sizeRear = [36.240508333,30.311698542];
// paths for svg_1
bezierRear = [/*N*/[-6.340977708,15.155849271],/*CP*/POLAR(11.334146358,-170.935122965),/*CP*/POLAR(0,0),/*N*/[-17.668927917,4.716211146],LINE(),LINE(),/*N*/[-18.120254167,-5.586161146],LINE(),LINE(),/*N*/[-18.120254167,-13.599040937],/*CP*/POLAR(1.0531475,-90),/*CP*/POLAR(0,0),/*N*/[-16.45396125,-15.155849271],LINE(),LINE(),/*N*/[-0.157929792,-15.155849271],LINE(),LINE(),/*N*/[0.158009167,-15.155849271],LINE(),LINE(),/*N*/[16.454040625,-15.155849271],/*CP*/POLAR(0,0),/*CP*/POLAR(1.0531475,-90),/*N*/[18.120254167,-13.599040937],LINE(),LINE(),/*N*/[18.120254167,-5.586161146],LINE(),LINE(),/*N*/[17.668954375,4.716211146],/*CP*/POLAR(0,0),/*CP*/POLAR(11.334172486,-9.064855963),/*N*/[6.340977708,15.155849271],LINE(),LINE(),/*N*/[0.158009167,15.155849271],LINE(),LINE(),/*N*/[-0.157929792,15.155849271],LINE(),LINE(),/*N*/[-6.340977708,15.155849271]];

module wiiRear() {
    linear_extrude(height=rearRingWidth)
    translate([0,-wall-positionRear[1]-rearTolerance])
    rotate(180) difference() {
        offset(r=wall+rearTolerance) polygon(Bezier(bezierRear));
        offset(r=rearTolerance)
        polygon(Bezier(bezierRear));
        translate([0,positionRear[1]])
        square([15,10],center=true);
    }
}

module wiiFront() {
    b = Bezier([[0,0],LINE(),LINE(),[18.08-1.5,0],POLAR(1,0),POLAR(1,-90),[18.08,1.5],LINE(),LINE(),[18.08,17],POLAR(5,150),POLAR(9,0),[0,20.6],REPEAT_MIRRORED([1,0])]);
    linear_extrude(height=frontRingWidth)
    translate([0,-wall-frontTolerance]) rotate(180) difference() {
        offset(r=frontTolerance+wall)
    polygon(b);
        offset(r=frontTolerance)
    polygon(b);
        translate([0,20])
        square([15,10],center=true);
    }
}

module profileFront() {
    h = sightHeight+slope*sightSpacing;
    polygon([[-frontSightLength,-wall],[0,-wall],[0,h],[-0.35*frontSightLength,-0.35*frontSightLength*slope+h],[-frontSightLength,0]]);
}

module profileRear() {
    polygon([[0,-wall],[rearSightLength,-wall],[rearSightLength,0],[rearSightLength*0.35,sightHeight+rearSightLength*0.35*slope],[0,sightHeight]]);
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
    wiiRear();
}

module frontSight() {
    rotate([0,90,0])
    translate([0,0,-0.5*sightThickness]) 
        linear_extrude(height=sightThickness) profileFront();
    wiiFront();
}

rearSight();
translate([0,21+2*wall+sightHeight,0]) frontSight();