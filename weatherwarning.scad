use <roundedsquare.scad>;

wall = 1;
boxWidth = 76; 
boxDepth = 52;
boxHeight = 52;
screenWidth = 47;
screenHeight = 35;
speakerDiameter = 39.2;
speakerMountYStickout = 1.86; 
speakerMountXStickout = 5; 
speakerMountThickness = 1.5;
grilleSolidWidth = 2;
grilleHoleWidth = 2.5;
rounded = 5;
tolerance = 0.4;
includeBox = 1;
includeLid = 0;
screenHoleDiameter = 3.6;
screenPCBThickness = 1.63;
screenPCBWidth = 58.1;
screenScrewDiameter = 2.3;  
screenScrewXSpacing = 52; 
screenScrewYSpacing = 28.8; 
screenScrewLength = 3.42; 
pcbWidth=55;
pcbHeight=45.64;
pcbThickness=1.57;
pcbMountLip=4.9;
lidThickness = 2.5;
ledHole=3.07; 
buttonHole=6.86; 
pcbMountLength=10;
lidMountHole=1.3;
lidMountHoleOffset=3; 
lidScrewHeadThickness=1.2; 
lidScrewHeadDiameter=4.6; 
lidSolderInset=1.75;
usbZOffsetFromPCBBase=12.5;
usbThickness=3.5;
usbWidth=8.3;
usbYOffsetFromLip=8.7;
usbTolerance=1;
ventHeight=20;
ventWidth=50;
ventSpacing=2;

module dummy() {}

usbWidth1=usbWidth+2*usbTolerance;
usbThickness1=usbThickness+2*usbTolerance;
speakerDiameter1 = speakerDiameter + 2 * tolerance;
speakerMountXStickout1 = speakerMountXStickout+tolerance;
screenWidth1 = screenWidth + 2 * tolerance;
screenHeight1 = screenHeight + 2 * tolerance;
screenHoleDiameter1 = screenHoleDiameter - 2 * tolerance;
screenHolderStripThickness = max(0, screenScrewLength - (wall-0.5+screenPCBThickness));
controlStripSize = boxDepth-2*wall-screenHeight1;
controlY = boxDepth-wall-controlStripSize/2;


nudge = 0.01;

module mainBox(solid=false) {
    roundedOpenTopBox(size=[boxWidth,boxDepth,boxHeight], radius=rounded, solid=solid);
}

module screenScrew() {
    difference() {
        if (!$holeOnly) 
            cylinder(h=screenHolderStripThickness+wall+screenPCBThickness,d=screenHoleDiameter1,$fn=16);
        translate([0,0,screenHolderStripThickness+wall+screenPCBThickness-screenScrewLength])
        cylinder(d=screenScrewDiameter,h=screenScrewLength+nudge,$fn=16);
    }
}

module screenStrip() {
    if (!$holeOnly)
        cube([screenHoleDiameter1,screenHeight1,wall+screenHolderStripThickness]);
    translate([screenHoleDiameter1/2,0,0]) {
        translate([0,screenHeight1/2-screenScrewYSpacing/2,0]) screenScrew();
        translate([0,screenHeight1/2+screenScrewYSpacing/2,0]) screenScrew();
    }
}

module screenMount() {
    translate([boxWidth/2-screenScrewXSpacing/2-screenHoleDiameter1/2,wall,0]) screenStrip();
    translate([boxWidth/2+screenScrewXSpacing/2-screenHoleDiameter1/2,wall,0]) screenStrip();
}

module speakerMount() {
    height = wall+speakerDiameter*0.5+10;
    module strip() {
        cube([wall+speakerMountXStickout+speakerMountThickness,speakerMountThickness,height]);
        translate([wall+speakerMountXStickout,0,0])
        cube([speakerMountThickness,speakerMountYStickout+speakerMountThickness,height]);
    }
    translate([0,boxDepth/2-speakerDiameter1/2-speakerMountThickness,0]) strip();
    translate([0,boxDepth/2+speakerDiameter1/2+speakerMountThickness,0]) mirror(v=[0,1,0]) strip();
}

module speakerGrille() {
    r = speakerDiameter/2-speakerMountYStickout;
    for (y=[-r:grilleSolidWidth+grilleHoleWidth:r]) {
        y1 = y+grilleHoleWidth/2;
        h = sqrt(r*r-y1*y1);
        translate([-nudge, boxDepth/2 + y, wall+speakerDiameter1/2-h])
        cube([wall+2*nudge, grilleHoleWidth, 2*h]);
    }
}

module ventilation() {
    translate([boxWidth/2-ventWidth/2,-nudge,boxHeight/2-ventHeight/2])
    for (x=[0:2*ventSpacing:ventWidth]) {
        translate([x,0,0])
        cube([ventSpacing,boxDepth+2*nudge,ventHeight]);
    }
}

module ledHole() {
    translate([boxWidth/2-screenWidth/2+ledHole/2,controlY,-nudge]) cylinder(h=wall+2*nudge,d=ledHole+2*tolerance);
}

module buttonHole() {
    translate([boxWidth/2+screenWidth/2-buttonHole/2,controlY,-nudge]) cylinder(h=wall+2*nudge,d=buttonHole+2*tolerance);
}

pcbMountYSize = (boxDepth-pcbHeight)/2+pcbMountLip;

module pcbMount() {
    ySize = pcbMountYSize;
    zPosition = boxHeight-lidThickness-pcbThickness-lidScrewHeadThickness;
    stripLength = boxWidth;
    module strip() {
        difference() {
            if (!$holeOnly) translate([0,0,zPosition])
            rotate([0,90,0]) linear_extrude(height=stripLength) polygon([[0,0],[0,ySize],[ySize,0]]);
            union() {
                translate([wall+lidMountHoleOffset,wall+lidMountHoleOffset,zPosition-ySize+nudge])
                cylinder(d=lidMountHole,h=ySize,$fn=16);
                translate([boxWidth-wall-lidMountHoleOffset,wall+lidMountHoleOffset,zPosition-ySize+nudge])
                cylinder(d=lidMountHole,h=ySize,$fn=16);
            }
        }
    }
    strip();
    translate([0,boxDepth,0]) mirror(v=[0,1,0]) strip();
}

module usbHole() {
    translate([boxWidth-wall-nudge,boxHeight-pcbMountYSize-usbYOffsetFromLip-usbWidth1,boxHeight-lidThickness-lidScrewHeadThickness-usbZOffsetFromPCBBase-usbThickness1])
    cube([wall+2*nudge,usbWidth1,usbThickness1]);
}

module box() {
    render(convexity=5)
    intersection() {
        mainBox(solid=true);
        difference() {
            union() {
                difference() {
                    mainBox();
                    ventilation();
                }
                screenMount();
                speakerMount();
                pcbMount();                
            }
            translate([boxWidth/2-screenWidth1/2,wall,-nudge]) cube([screenWidth1,screenHeight1,wall+2*nudge]);
            screenMount($holeOnly=true);
            speakerGrille();
            ledHole();
            buttonHole();
            usbHole();
        }
    }
}


module lid() {
    render(convexity=3)
    difference() {
        translate([tolerance+wall,tolerance+wall,0])
        roundedOpenTopBox([boxWidth-2*tolerance-2*wall,boxHeight-2*tolerance-2*wall,lidThickness], solid=true);
        translate([wall+lidMountHoleOffset,wall+lidMountHoleOffset,-nudge]) cylinder(h=lidThickness+2*nudge,d=lidMountHole,$fn=16);
        translate([boxWidth-(wall+lidMountHoleOffset),wall+lidMountHoleOffset,-nudge]) cylinder(h=lidThickness+2*nudge,d=lidMountHole,$fn=16);
        translate([wall+lidMountHoleOffset,boxHeight-(wall+lidMountHoleOffset),-nudge]) cylinder(h=lidThickness+2*nudge,d=lidMountHole,$fn=16);
        translate([boxWidth-(wall+lidMountHoleOffset),boxHeight-(wall+lidMountHoleOffset),-nudge]) cylinder(h=lidThickness+2*nudge,d=lidMountHole,$fn=16);
    }
}

if (includeBox) box();
if (includeLid) translate([boxWidth+10,0,0]) lid();
    