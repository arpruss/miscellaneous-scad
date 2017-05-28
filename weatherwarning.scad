use <roundedsquare.scad>;

wall = 1;
boxWidth = 72;
boxDepth = 52;
boxHeight = 52;
screenWidth = 47;
screenHeight = 35;
speakerDiameter = 40; // TODO
speakerMountHorizontalStickout = 5; // TODO
speakerMountVerticalStickout = 5; // TODO
speakerMountThickness = 2;
rounded = 5;
tolerance = 0.4;
includeBox = 1;
includeLid = 1;
screenHoleDiameter = 4; // TODO
screenPCBThickness = 1.5; // TODO
screenScrewDiameter = 1.25; // TODO 
screenScrewHorizontalSpacing = 52; // TODO
screenScrewVerticalSpacing = 28; // TODO
screenScrewLength = 3; // TODO
pcbWidth=5.5;

module dummy() {}

speakerDiameter1 = speakerDiameter + 2 * tolerance;
speakerMountHorizontalStickout1 = speakerMountHorizontalStickout+tolerance;
screenWidth1 = screenWidth + 2 * tolerance;
screenHeight1 = screenHeight + 2 * tolerance;
screenHoleDiameter1 = screenHoleDiameter - 2 * tolerance;
screenHolderStripThickness = max(0, screenScrewLength - (wall-0.5+screenPCBThickness));
echo(screenHolderStripThickness);

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
        translate([0,screenHeight1/2-screenScrewVerticalSpacing/2,0]) screenScrew();
        translate([0,screenHeight1/2+screenScrewVerticalSpacing/2,0]) screenScrew();
    }
}

module screenMount() {
    translate([boxWidth/2-screenScrewHorizontalSpacing/2-screenHoleDiameter1/2,wall,0]) screenStrip();
    translate([boxWidth/2+screenScrewHorizontalSpacing/2-screenHoleDiameter1/2,wall,0]) screenStrip();
}

module speakerMount() {
    module strip() {
        cube([wall+speakerMountHorizontalStickout+speakerMountThickness,speakerMountThickness,speakerDiameter*0.75]);
        translate([wall+speakerMountHorizontalStickout,0,0])
        cube([speakerMountThickness,speakerMountVerticalStickout+speakerMountThickness,speakerDiameter*0.75]);
    }
    translate([0,boxDepth/2-speakerDiameter1/2-speakerMountThickness,0]) strip();
    translate([0,boxDepth/2+speakerDiameter1/2-speakerMountThickness,0]) translate([0,speakerMountThickness,0]) mirror(v=[0,1,0]) strip();
}

#speakerMount();

module box() {
    render(convexity=5)
    intersection() {
        mainBox(solid=true);
        difference() {
            union() {
                mainBox();
                screenMount();            
            }
            translate([boxWidth/2-screenWidth1/2,wall,-nudge]) cube([screenWidth1,screenHeight1,wall+2*nudge]);
            screenMount($holeOnly=true);
        }
    }
}

module lid() {
}

if (includeBox) box();
if (includeLid) translate([boxWidth+10,0,0]) lid();