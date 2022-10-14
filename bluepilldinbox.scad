// TODO: fix PCBTOP

use <roundedSquare.scad>;
use <hershey.scad>;

pcbThickness = 1.55;
pcbWidth = 22.7;
pcbLength = 52.8;
pcbLengthExtra = 10;
pcbMinOffsetFromBase = 2.6;
pcbLengthTolerance = 0.2;

innerRadius = 3;

railThickness = 1.4;
railWidth = 1.5;
railRounding = 0.5;

pcbWidthTolerance = 0.25;
pcbThicknessTolerance = 0.15;

lidTolerance = 0.25;

lidOverlap = 8;

wallThickness = 1.5;

boxHeight = 25;

usbHoleWidth = 12.25;
usbHoleHeight = 6.75;
usbHoleRounding = 1;
usbHoleCenterOffsetFromPCBTop = 1.4;

dinHoleDiameter = 10; 
dinHoleDepth = 8;
dinHoleWallThin = 1;
dinHoleWallThick = 3;
dinHoleTolerance = 0.27;
dinHoleBottomOffsetFromPCBTop = 5;

screwHoleDiameterTight = 1.75;
screwHoleDiameterLoose = 3.5;

label = "ABD2USB";
labelFontSize = 6.5;

boxInnerWidth = pcbWidth+2*pcbWidthTolerance;

module baseProfile(extra=0) {
    roundedSquare([boxInnerWidth+2*extra,boxHeight+2*extra],radius=innerRadius+extra,center=true,$fn=24);
}

nudge = 0.01;

extraBoxOuter = wallThickness;
extraLidInner = extraBoxOuter+lidTolerance;
extraLidOuter = extraLidInner+wallThickness;

railBottom = -boxHeight/2+max(-pcbThicknessTolerance-railThickness+pcbMinOffsetFromBase,innerRadius);
pcbTop = railBottom+railThickness+2*pcbThicknessTolerance+pcbThickness;

module leftRail(extra=0) {
    translate([-boxInnerWidth/2-1,0]) {
       roundedSquare([railRounding+railWidth+extra,railThickness],radius=railRounding);
       translate([0,2*pcbThicknessTolerance+pcbThickness+railThickness])
       roundedSquare([railRounding+railWidth+extra,railThickness],radius=railRounding);
   }   
}

dinHoleY = pcbTop + dinHoleBottomOffsetFromPCBTop + (dinHoleDiameter+2*dinHoleTolerance)/2;
length = wallThickness+pcbLength+pcbLengthExtra+2*pcbLengthTolerance;

module basicBox() {
    linear_extrude(height=wallThickness) {  
            baseProfile(extraBoxOuter);
    }
    linear_extrude(height=length) difference() {
            baseProfile(extraBoxOuter);
            baseProfile(0);
        }
    linear_extrude(height=wallThickness+lidOverlap) difference() {
            baseProfile(extraLidOuter);
            baseProfile(0);
        }
    linear_extrude(height=wallThickness+pcbLength+2*pcbLengthTolerance+pcbLengthExtra) {
        translate([0,railBottom]) {
            leftRail();
            mirror([1,0]) leftRail();
        }
    }

    linear_extrude(height=wallThickness+pcbLengthExtra) {
        translate([0,railBottom]) {
            hull() leftRail(1);
            mirror([1,0]) hull() leftRail(1);
        }
    }
    translate([0,dinHoleY,0]) cylinder(d1=dinHoleDiameter+2*dinHoleTolerance+2*dinHoleWallThick,d2=dinHoleDiameter+2*dinHoleTolerance+2*dinHoleWallThin,h=dinHoleDepth);
}

module screwHoleRight(z,d) {
    translate([boxInnerWidth/2-nudge,dinHoleY,z]) rotate([0,90,0]) cylinder(d=d,h=extraLidOuter+2*nudge);
}

module label() {
    if (label != "") 
        rotate([0,0,90])
        rotate([0,90,0])
        rotate([0,0,180])
    drawHersheyText(label, font="Sans", valign="center", halign="center", size=labelFontSize,extraSpacing=-1.5) cylinder(d1=2,d2=0.5,h=1,$fn=8);
}

module box() {
    difference() {
        basicBox();
        screwHoleRight(length-lidOverlap/2,screwHoleDiameterTight);
        mirror([1,0,0]) screwHoleRight(length-lidOverlap/2,screwHoleDiameterTight);
            translate([0,dinHoleY,-nudge]) cylinder(d=dinHoleDiameter+2*dinHoleTolerance,h=dinHoleDepth+2*nudge);
    }
    translate([0,boxHeight/2+extraBoxOuter,length/2]) label();
}

module lid() {
    
    difference() {
        union() {
                linear_extrude(height=wallThickness) {
            difference() {
                baseProfile(extraLidOuter);    
            translate([0,pcbTop+usbHoleCenterOffsetFromPCBTop]) roundedSquare([usbHoleWidth,usbHoleHeight],radius=usbHoleRounding,center=true);
            }
                }linear_extrude(height=wallThickness+lidOverlap) difference() {
                baseProfile(extraLidOuter);
                baseProfile(extraLidInner);
            }
        }
        screwHoleRight(wallThickness+lidOverlap/2,screwHoleDiameterLoose);
            mirror([1,0,0]) screwHoleRight(wallThickness+lidOverlap/2,screwHoleDiameterLoose);
    }
    
        
}

box();
translate([pcbWidth+15,0,0]) lid();