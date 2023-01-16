//todo;block left end of LCD holders

use <Bezier.scad>;
use <roundedSquare.scad>;

//<params>
lcdPCBHeight = 60.21;
lcdPCBLength = 98.15;
lcdPCBThickness = 1.69;
lcdHeight = 39.74;
lcdFrontStickout = 10.2;
lcdBackStickout = 7.5;
lcdHolderTopLip = 1.2;
lcdHolderBottomLip = 1.75;
lcdBezelInset = 2;

espPCBHeight = 25.73;
espPCBLength = 48.2;
espPCBThickness = 1.65;
espHolderLip = 1;
espBackSpacing = 4;
espFrontSpacing = 7;
usbWidth = 7.8;
usbHeight = 2.8;
usbMargin = 3;

pcbSideTolerance = 0.5;
holderThickness = 1.5;
holderStickout = 1.5;
holderTolerance = 0.1;
holderSlope = 0.3;

buttonSide = 6.04;
buttonSpacing = 25;
buttonArea = 20;
buttonHole = 3;

sensorHoleSize = 6;

bridgeOutside = 41;
bridgeOffset = 3;
bridgeHeight = 15;
cornerSize = 4;

wall = 1.75;

lidOverlap = 10;
lidTolerance = 0.22;

screwHoleSmall = 3;
screwHoleLarge = 5;
//</params>

nudge = 0.001;

frontHeight = lcdPCBHeight + 2 * pcbSideTolerance;
frontDepth = espPCBThickness + lcdFrontStickout + lcdBackStickout;
bridgeDepth = bridgeOutside + 2 * wall;
backHeight = espPCBHeight + 2 * pcbSideTolerance;
backDepth = espPCBThickness + espBackSpacing + espFrontSpacing;

module genericProfile(extra=0) {
    corner = cornerSize + extra;
    cornerStrength = cornerSize/1.5 + extra;
    frontDepth = frontDepth + extra;
    frontHeight = frontHeight + extra;
    backHeight = backHeight + 2 * extra;
    bridgeDepth = bridgeDepth - 2 * extra;
    bridgeHeight = bridgeHeight + 2 * extra;
    backDepth = backDepth + 3 * extra;
    profileCurve = [
        [-extra,-extra],LINE(),LINE(),[frontDepth-corner,-extra],POLAR(cornerStrength,0),POLAR(cornerStrength,-90),[frontDepth,corner],LINE(),LINE(),[frontDepth,frontHeight-corner],POLAR(cornerStrength,90),POLAR(cornerStrength,0),[frontDepth-corner,frontHeight],LINE(),LINE(),[-extra,frontHeight],LINE(),LINE(),[-extra,frontHeight-bridgeOffset],LINE(),LINE(),
    [-backDepth-bridgeDepth+corner,frontHeight-bridgeOffset],POLAR(cornerStrength,180),POLAR(cornerStrength,90),[-backDepth-bridgeDepth,frontHeight-bridgeOffset-corner],
        LINE(),LINE(),[-backDepth-bridgeDepth,frontHeight-bridgeOffset-backHeight+corner],POLAR(cornerStrength,-90),POLAR(cornerStrength,180),[-backDepth-bridgeDepth+corner,frontHeight-bridgeOffset-backHeight],LINE(),LINE(),[-bridgeDepth-extra,frontHeight-bridgeOffset-backHeight],LINE(),LINE(),[-bridgeDepth-extra,frontHeight-bridgeHeight-bridgeOffset],LINE(),LINE(),[-extra,frontHeight-bridgeHeight-bridgeOffset],LINE(),LINE(),[-extra,-extra]
        ];
    polygon(Bezier(profileCurve));    
}

module holder() {
    polygon([ [0,-nudge], [holderThickness,-nudge],
        [holderThickness,holderStickout],
        [holderSlope * holderStickout,holderStickout] ]);
}

module espHolder1() {
    x = -backDepth-bridgeDepth+espBackSpacing;
    
    translate([x,frontHeight-backHeight-bridgeOffset]) mirror([1,0]) holder();
    translate([x+espPCBThickness+holderTolerance,frontHeight-backHeight-bridgeOffset]) holder();
}

module espHolder2() {
    x = -backDepth-bridgeDepth+espBackSpacing;
    translate([0,frontHeight-bridgeOffset]) mirror([0,1]) {
        translate([x,0]) mirror([1,0]) holder();
        translate([x+espPCBThickness+holderTolerance,0]) holder();
    }
}

module lcdHolder1() {
    translate([lcdBackStickout,0]) mirror([1,0]) holder();
    translate([lcdBackStickout+lcdPCBThickness+holderTolerance,0]) holder();
}

module lcdHolder2() {
    translate([0,frontHeight]) mirror([0,1]) {
        translate([lcdBackStickout,0]) mirror([1,0]) holder();
        translate([lcdBackStickout+lcdPCBThickness+holderTolerance,0]) holder();
    }
}

module profile() {
    difference() {
        genericProfile(wall);
        genericProfile();
    }
    lcdHolder1();
    lcdHolder2();

    espHolder1();
    espHolder2();
}

length = lcdPCBLength + buttonArea + 2 * lidOverlap;
lcdCutoutZ = length-lidOverlap-lcdPCBLength+lcdBezelInset;

module lcdCutout() {
   translate([frontDepth+wall+nudge,frontHeight/2-lcdHeight/2+lcdBezelInset,lcdCutoutZ]) rotate([0,-90,0]) 
    linear_extrude(height=wall+2*nudge) roundedSquare([lcdPCBLength-2*lcdBezelInset,lcdHeight-2*lcdBezelInset],radius=cornerSize,$fn=4);
}

module button() {
    x = frontDepth - nudge;
    y = frontHeight/2 - buttonSpacing/2;
    z = buttonArea/2 + lidOverlap;
    translate([x,0,z]) rotate([0,90,0]) for (i=[-1,1]) for(j=[-1,1]) translate([i*buttonSide/2,y+j*buttonSide/2]) cylinder(d=buttonHole,h=wall+2*nudge,$fn=16);
}

module usbCutout() {
    translate([-backDepth-bridgeDepth+espBackSpacing+usbMargin,frontHeight-bridgeOffset-backHeight/2+espPCBThickness]) square([usbHeight+2*usbMargin,usbWidth+2*usbMargin],center=true);
}

module lcdPushUp() {
    translate([lcdBackStickout+lcdPCBThickness/2,0]) {
        translate([0,frontHeight/3,0]) cylinder(d1=10, d2=3, h=length-lidOverlap-lcdPCBLength+lcdBezelInset+wall);
        translate([0,2*frontHeight/3,0]) cylinder(d1=10, d2=3, h=length-lidOverlap-lcdPCBLength+lcdBezelInset+wall);
    }
}

module lid(tolerance=0, usb= false, pushUp=false, screwHoles=false,sensorHole=false) {
    difference() {
        linear_extrude(height=lidOverlap+wall)
        difference() {
            genericProfile(2*wall);
            genericProfile(wall+tolerance);
        }
        translate([0,0,wall]) screws(screwHoleLarge);
    }
    linear_extrude(height=wall+nudge) difference() {
        genericProfile(2*wall);
        if (usb) usbCutout();
            if (sensorHole) translate([-bridgeDepth/2,frontHeight-bridgeOffset-bridgeHeight/2]) circle(d=sensorHoleSize);
        }
    if (pushUp) lcdPushUp();
}

module screws(d) {
    module screw() {
    translate([0,0,lidOverlap/2]) 
        rotate([90,0,0]) cylinder(d=d,h=5*wall,center=true,$fn=16);
    }
    
    translate([lcdBackStickout/2,0,0]) screw();
    translate([lcdBackStickout/2,frontHeight,0]) screw();
    translate([-bridgeDepth*3/4,frontHeight,0]) screw();
    translate([-bridgeDepth*3/4,frontHeight-bridgeOffset,0]) screw();
    translate([-bridgeDepth*3/4,frontHeight-bridgeOffset-bridgeHeight,0]) screw();
}

module main() {
    difference() 
    {
        linear_extrude(height=length) profile();
        lcdCutout();
        button();
        translate([0,buttonSpacing,0]) button();
        screws(screwHoleSmall);
    }
    translate([0,0,length+wall])
    mirror([0,0,1])
    lid(tolerance = -nudge, usb=false);
    translate([0,0,espPCBLength]) linear_extrude(height=length-2*pcbSideTolerance-espPCBLength) {
        hull() espHolder1();
        hull() espHolder2();
    }
    translate([0,0,length-lidOverlap]) linear_extrude(height=lidOverlap) {
        hull() lcdHolder1();
        hull() lcdHolder2();
    }
}

translate([0,0,length+wall])
rotate([0,180,0]) 
main();
translate([0,100,0]) lid(tolerance=lidTolerance, usb=true,pushUp=true,sensorHole=true);
