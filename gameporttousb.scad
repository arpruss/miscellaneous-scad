use <roundedsquare.scad>;

//<params>
includeBottom = 1; // [1:yes, 0:no]
includeTop = 1; // [1:yes, 0:no]
includeGamecubePort = 0; // [1:yes, 0:no]
includeEllipticalPort = 0; // [1:yes, 0:no]
includeNunchuckPort = 0; // [1:yes, 0:no]
includeDirectionSwitchPort = 0; // [1:yes, 0:no]
includeGameport = 1; // [1:yes, 0:no]
includeWashers = 0; // [1:yes, 0:no]
includeFeet = 0; // [1:yes, 0:no]
innerLength = 80;
extraWidth = 0; // 18;
extraWidth1 = 15; // 18;
sideWall = 1.5;
topWall = 1.6;
bottomWall = 2;
bottomScrewLength = 11.25; // 8;
topScrewLength = 5.7;
gameportWidth = 24.92;
gameportScrewSpacing = 33.78;
gameportScrewDiameter = 3;
gameportHeight = 9;
screwDiameter = 2.12;
screwHeadDiameter = 4.8;
thinPillarDiameter = 5.5;
fatPillarDiameter = 9;
stm32Width = 24.35;
stm32Length = 57.2;
tolerance = 0.2;
pcbThickness = 1.25;
bottomOverlap = 4;
topUnderlap = 4.8;
stm32ScrewYSpacing=18.8;
stm32ScrewXSpacing=52;
stm32ScrewOffset=2.4;
gcCableDiameter=3.7;
ellipticalCableMajorDiameter=5.32;
ellipticalCableMinorDiameter=2.66;
topOffset = 0; // 4.8;
topScrewX1 = 6;
topScrewXSpacing = 54.66;
buttonHoleDiameter = 0; // 5;
button1OffsetFromHole = 12.7;
button2OffsetFromHole = 5.78;
ledHoleDiameter = 0; // 4
led1XOffsetFromButton1 = 10.16;  
led1YOffsetFromButton1 = 1.27;  
ledSpacing = 5.08;
pcbToPCBSpacing = 12;
usbPortWidth = 10;
usbPortHeight = 4.5;
usbPortZOffsetDown = 1;
directionSwitchNeckDiameter = 5.8;
directionSwitchOuterDiameter = 11.12;
directionSwitchNeck = 1.1;
nunchuckPortTolerance = 0.25;
nunchuckPortHeight = 7.36;
nunchuckPortWidth = 12.24;
nunchuckPortInsetDepth = 1.28;
nunchuckPortInsetWidth = 4.59;
nunchuckPortPillarTopFromCenter = 4.9;
nunchuckPortZOffset = 2;
nunchuckScrewHoleYMinusFromCenterOfPort = 6.99;
nunchuckScrewHoleXMinusFromOutsideOfWall = 12.91;
stickyFootHoleSize = 8.85;
nunchuckScrewHoleYSpacing = 2.54*5;
nunchuckScrewHoleXSpacing = 2.54*6;
//</params>

module dummy() {}

includeSpacer = 0;
$fn = 32;
nudge = 0.001;

innerWidth = extraWidth+extraWidth1+stm32Width+fatPillarDiameter*2;
bottomOffset = bottomScrewLength-pcbThickness;
bottomHeight = bottomWall+bottomOffset+pcbThickness;
bottomFatPillarLength = bottomHeight+bottomOverlap;
topHeight = topWall + topOffset + pcbThickness + max(topUnderlap,pcbToPCBSpacing);
topFatPillarLength = topHeight-topUnderlap;
nunchuckPillarLength = bottomHeight + nunchuckPortZOffset - nunchuckPortPillarTopFromCenter;

fatPillarLocations = [
    [-sideWall+fatPillarDiameter/2,-sideWall+fatPillarDiameter/2,0],
    [-sideWall+fatPillarDiameter/2,innerWidth+sideWall-fatPillarDiameter/2,0],
    [innerLength+sideWall-fatPillarDiameter/2,-sideWall+fatPillarDiameter/2,0],
    [innerLength+sideWall-fatPillarDiameter/2,innerWidth+sideWall-fatPillarDiameter/2,0]
];
stm32ScrewX1 = stm32ScrewOffset;
stm32ScrewY1 = extraWidth1+fatPillarLocations[0][1]+fatPillarDiameter/2+thinPillarDiameter/2;


ellipticalCableY = fatPillarLocations[1][1]-fatPillarDiameter-1.5*ellipticalCableMinorDiameter;
gcPortY = stm32ScrewY1+stm32ScrewYSpacing/2;

nunchuckPortY = innerWidth+sideWall-fatPillarDiameter-nunchuckPortWidth/2-nunchuckPortTolerance*2-2*sideWall;// (stm32ScrewY1+stm32ScrewYSpacing+thinPillarDiameter+innerWidth-fatPillarDiameter)*0.5;
nx0 = innerLength+sideWall-nunchuckScrewHoleXMinusFromOutsideOfWall;
ny0 = nunchuckPortY-nunchuckScrewHoleYMinusFromCenterOfPort;
nunchuckPillarLocations = [
    [nx0,ny0],
    [nx0-nunchuckScrewHoleXSpacing,ny0],
    [nx0-nunchuckScrewHoleXSpacing,ny0+nunchuckScrewHoleYSpacing],
    [nx0,ny0+nunchuckScrewHoleYSpacing]];
echo(nunchuckPillarLocations);

topScrewY = innerWidth-stm32ScrewY1-stm32ScrewYSpacing/2;
bottomThinPillarLocations = [
    [stm32ScrewX1,stm32ScrewY1,0],
    [stm32ScrewX1+stm32ScrewXSpacing,stm32ScrewY1,0],
    [stm32ScrewX1,stm32ScrewY1+stm32ScrewYSpacing,0],
    [stm32ScrewX1+stm32ScrewXSpacing,stm32ScrewY1+stm32ScrewYSpacing,0] ];

directionSwitchX = (topScrewX1+button1OffsetFromHole+topScrewX1+topScrewXSpacing-button2OffsetFromHole)/2;
directionSwitchY = topScrewY/2;

module base(inset=0) {
    translate([-sideWall+inset,-sideWall+inset])
    roundedSquare([innerLength+2*sideWall-2*inset,innerWidth+2*sideWall-2*inset], radius=fatPillarDiameter/2-inset);
}

module ellipticalCable() {
    rotate([0,90,0])
    translate([0,0,-nudge-sideWall])
    linear_extrude(height=3*sideWall+2*nudge)
    hull() {
        translate([-(ellipticalCableMajorDiameter-ellipticalCableMinorDiameter)/2-tolerance,0,0])
        circle(d=ellipticalCableMinorDiameter);
        translate([(ellipticalCableMajorDiameter-ellipticalCableMinorDiameter)/2+tolerance,0,0])
        circle(d=ellipticalCableMinorDiameter);
    }
}

nunchuckPortHeight = 7.36;
nunchuckPortWidth = 12.24;
nunchuckPortInsetDepth = 1.28;
nunchuckPortInsetWidth = 4.59;

module nunchuckConnector() {
    h = nunchuckPortHeight + 2*nunchuckPortTolerance;
    w = nunchuckPortWidth + 2*nunchuckPortTolerance;
    insetDepth = nunchuckPortInsetDepth;
    insetWidth = nunchuckPortInsetWidth+2*nunchuckPortTolerance;
    rotate([0,90,0])
    translate([0,0,-sideWall-nudge])
    linear_extrude(height=sideWall*2+2*nudge)
    polygon([[-h/2,-w/2],[h/2,-w/2],[h/2,w/2],[-h/2,w/2],[-h/2,insetWidth/2],[-h/2+insetDepth,insetWidth/2],[-h/2+insetDepth,-insetWidth/2],[-h/2,-insetWidth/2]]);
}

module sideWalls() {
    difference() {
        base();
        base(inset=sideWall);
    }
}

module tweakedSideWalls() {
    difference() {
        base(inset=-sideWall);
        base(inset=sideWall+tolerance);
    }
}

module fatPillar(hole=false,bottom=true) {
    fatPillarLength = bottom?bottomFatPillarLength:topFatPillarLength;
    if (!hole)
        cylinder(d=fatPillarDiameter,fatPillarLength);
    else {
        if (bottom)
            cylinder(d=screwHeadDiameter+2*tolerance,h=fatPillarLength-(bottom?bottomWall:topWall));
        cylinder(d=screwDiameter+2*tolerance,h=fatPillarLength+nudge);
    }
}

module thinPillar(hole=false,height=10) {
    if (!hole)
        cylinder(d=thinPillarDiameter,h=height);
    else {
        cylinder(d=screwDiameter+2*tolerance,h=height);
    }
}

module spacer() {
    linear_extrude(height=0.75) {
        difference() {
            hull() {
                circle(d=thinPillarDiameter);
                translate([0,stm32ScrewYSpacing]) circle(d=thinPillarDiameter);
            }
            circle(d=screwDiameter+5*tolerance);
            translate([0,stm32ScrewYSpacing]) circle(d=screwDiameter+5*tolerance);
        }
    }
}

module gameport() {
    module gameportScrewHole() {
        rotate([0,90,0]) cylinder(d=gameportScrewDiameter+2*tolerance,$fn=16,h=sideWall+2*nudge);
    }
    
   translate([innerLength-nudge,innerWidth/2-gameportWidth/2-tolerance,bottomHeight-gameportHeight]) cube([sideWall+2*nudge,gameportWidth+tolerance,gameportHeight+nudge]);
   translate([innerLength-nudge,innerWidth/2-gameportScrewSpacing/2,bottomHeight-gameportHeight/2]) gameportScrewHole();
   translate([innerLength-nudge,innerWidth/2+gameportScrewSpacing/2,bottomHeight-gameportHeight/2]) gameportScrewHole();
}

module bottom() {
    render(convexity=2)
    difference() {
        union() {
            linear_extrude(height=bottomWall+nudge) base();
            for (p=fatPillarLocations)
                translate(p) fatPillar();
            linear_extrude(height=bottomHeight+nudge) sideWalls();
            for (p=bottomThinPillarLocations)
                translate(p) thinPillar(height=bottomWall+bottomOffset);
            if (includeNunchuckPort)
            for (p=nunchuckPillarLocations)
                translate(p) thinPillar(height=nunchuckPillarLength);
       if (includeGamecubePort) 
            translate([innerLength-2*sideWall,gcPortY-gcCableDiameter*1.5,0]) cube([2*sideWall+nudge,3*gcCableDiameter,bottomHeight]);
       if (includeNunchuckPort) 
            translate([innerLength-sideWall,nunchuckPortY-nunchuckPortWidth/2-2*sideWall,0])
       cube([2*sideWall,nunchuckPortWidth+4*sideWall,bottomHeight]);
       if (includeEllipticalPort) 
            translate([-nudge,ellipticalCableY-ellipticalCableMinorDiameter*1.5,0]) cube([2*sideWall+nudge,3*ellipticalCableMinorDiameter,bottomHeight]);
        }
        for (p=fatPillarLocations)
            translate(p) fatPillar(hole=true);
        translate([0,0,bottomHeight]) linear_extrude(height=bottomOverlap+nudge) tweakedSideWalls();
            if (includeNunchuckPort)
            for (p=nunchuckPillarLocations)
                translate([0,0,bottomWall]) translate(p) thinPillar(height=nunchuckPillarLength,hole=true);
        for (p=bottomThinPillarLocations)
            translate([0,0,bottomWall]) translate(p) thinPillar(hole=true,height=bottomHeight+nudge);
       if (includeNunchuckPort)
           translate([innerLength,nunchuckPortY,bottomHeight+nunchuckPortZOffset]) nunchuckConnector();
        translate([-sideWall-nudge,(stm32ScrewY1+stm32ScrewYSpacing/2)-usbPortWidth/2,bottomHeight-usbPortZOffsetDown]) cube([sideWall+2*nudge,usbPortWidth,usbPortHeight+nudge]);
       if (includeGamecubePort) 
       translate([innerLength-2*sideWall,gcPortY,bottomHeight]) rotate([0,90,0]) cylinder(d=gcCableDiameter,h=3*sideWall+2*nudge);
       if (includeEllipticalPort)
        translate([0,ellipticalCableY,bottomHeight]) ellipticalCable();
       if (includeGameport) gameport();
    }
}

module pairOfFeet() {
    stripSize = 2*sideWall+innerWidth;
    d2 = stickyFootHoleSize+2;
    d1 = d2;
    $fn=16;
    
    module foot() {
        render(convexity=2)
        difference() {
            cylinder(d1=d1,d2=d2,h=2.5+1);
            translate([0,0,2.5+0.01]) cylinder(d=stickyFootHoleSize,h=1);
        }
    }
    
    linear_extrude(height=0.75)
    hull() {
        circle(d=d1);
        translate([0,stripSize-d2,0])
        circle(d=d1);
    }
    foot();
    translate([0,stripSize-d2,0])
    foot();
}

module top() {
    render(convexity=2)
    difference() {
        union() {
            linear_extrude(height=topWall+nudge) base();
            for (p=fatPillarLocations)
                translate(p) fatPillar(bottom=false);
            linear_extrude(height=topHeight+nudge) sideWalls();
            translate([topScrewX1,topScrewY,0])
                thinPillar(height=topWall+topOffset);
            translate([topScrewX1+topScrewXSpacing,topScrewY,0])
                thinPillar(height=topWall+topOffset);
       if (includeNunchuckPort) 
            translate([innerLength-sideWall,innerWidth-nunchuckPortY-nunchuckPortWidth/2-2*sideWall,0])
       cube([2*sideWall,nunchuckPortWidth+4*sideWall,topHeight]);
       if (includeGamecubePort) 
            translate([innerLength-2*sideWall,innerWidth-gcPortY-gcCableDiameter*1.5,0]) cube([2*sideWall+nudge,3*gcCableDiameter,topHeight]);
       if (includeEllipticalPort) 
            translate([-nudge,innerWidth-ellipticalCableY-ellipticalCableMinorDiameter*1.5,0]) cube([2*sideWall+nudge,3*ellipticalCableMinorDiameter,topHeight]);
        }
        for (p=fatPillarLocations)
            translate([0,0,topWall]) translate(p) fatPillar(hole=true,bottom=false);
            translate([topScrewX1,topScrewY,0.5])
                thinPillar(height=topWall+topOffset,hole=true);
            translate([topScrewX1+topScrewXSpacing,topScrewY,0.5])
                thinPillar(height=topWall+topOffset,hole=true);

    y0=innerWidth-(stm32ScrewY1+stm32ScrewYSpacing/2);
       if (includeNunchuckPort)
           translate([innerLength,innerWidth-nunchuckPortY,topHeight-nunchuckPortZOffset]) rotate([180,0,0]) nunchuckConnector();
       if (includeGamecubePort) 
       translate([innerLength-2*sideWall,innerWidth-gcPortY,topHeight]) rotate([0,90,0]) cylinder(d=gcCableDiameter,h=3*sideWall+2*nudge);
       if (includeEllipticalPort)
        translate([0,innerWidth-ellipticalCableY,topHeight]) ellipticalCable();
        translate([-sideWall-nudge,y0-usbPortWidth/2,topHeight-usbPortHeight+usbPortZOffsetDown]) cube([sideWall+2*nudge,usbPortWidth,usbPortHeight+nudge]);
        translate([-sideWall*0.25-tolerance,y0-(stm32Width+2*tolerance)/2,topHeight-pcbThickness-tolerance]) cube([sideWall*0.25+tolerance+nudge,stm32Width+2*tolerance,pcbThickness+tolerance+nudge]);
        translate([topScrewX1+button1OffsetFromHole,topScrewY,-nudge]) cylinder(d=buttonHoleDiameter,h=topWall+2*nudge);
        translate([topScrewX1+topScrewXSpacing-button2OffsetFromHole,topScrewY,-nudge]) cylinder(d=buttonHoleDiameter,h=topWall+2*nudge);
        for(i=[0:3]) translate([topScrewX1+button1OffsetFromHole+led1XOffsetFromButton1+i*ledSpacing,topScrewY+led1YOffsetFromButton1,-nudge]) cylinder(d=ledHoleDiameter,h=topWall+2*nudge);
    if (includeDirectionSwitchPort)
    translate([directionSwitchX,directionSwitchY,-nudge]) { cylinder(d=directionSwitchNeckDiameter+4*tolerance,h=topWall+2*nudge);
     translate([0,0,directionSwitchNeck])
    cylinder(d=directionSwitchOuterDiameter+4*tolerance,h=topWall);
     }
    }
}

if (includeBottom)
    bottom();
if (includeTop)
    translate([0,innerWidth+sideWall+8,0])
    top();
if (includeWashers) 
    render(convexity=2)
    translate([-30,0,0]) {
        for (i=[0:3])
            translate([0,i*15,0])
                scale([1.25,1.25,0])
                difference() {
                    thinPillar(hole=false,height=2);
                    translate([0,0,-nudge]) thinPillar(hole=true,height=2+2*nudge);
                }
    }
 if (includeSpacer) 
    translate([-50,0,0]) spacer();
 if (includeFeet) {
    translate([-70,0,0]) 
        pairOfFeet();
    translate([-90,0,0]) 
        pairOfFeet();
 }
