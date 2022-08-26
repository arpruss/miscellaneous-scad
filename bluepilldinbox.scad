use <roundedSquare.scad>;

pcbThickness = 1.55;
pcbWidth = 22.7;
pcbLength = 52.8;
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

boxHeight = 20;

usbHoleWidth = 12;
usbHoleHeight = 6;
usbHoleRounding = 1;
usbHoleCenterOffsetFromPCBTop = 3; //TODO: check

// TODO: DIN cutout
// TODO: screwholes
// TODO: check if blue

boxInnerWidth = pcbWidth+2*pcbWidthTolerance;

module baseProfile(extra=0) {
    roundedSquare([boxInnerWidth+2*extra,boxHeight+2*extra],radius=innerRadius+extra,center=true,$fn=24);
}

nudge = 0.01;

extraBoxOuter = wallThickness;
extraLidInner = extraBoxOuter+lidTolerance;
extraLidOuter = extraLidInner+wallThickness;

railBottom = -boxHeight/2+max(-pcbThicknessTolerance-railThickness+pcbMinOffsetFromBase,innerRadius);
pcbTop = railBottom + railThickness+2*pcbThicknessTolerance+pcbThickness;

module leftRail() {
    translate([-boxInnerWidth/2-1,0]) {
       roundedSquare([railRounding+railWidth,railThickness],radius=railRounding);
       translate([0,2*pcbThicknessTolerance+pcbThickness+railThickness])
       roundedSquare([railRounding+railWidth,railThickness],radius=railRounding);
   }   
}

module box() {
    linear_extrude(height=wallThickness) {  
        difference() {
            baseProfile(extraBoxOuter);
            translate([0,pcbTop+usbHoleCenterOffsetFromPCBTop]) roundedSquare([usbHoleWidth,usbHoleHeight],radius=usbHoleRounding,center=true);
        }
    }
    linear_extrude(height=wallThickness+pcbLength+2*pcbLengthTolerance) difference() {
            baseProfile(extraBoxOuter);
            baseProfile(0);
        }
    linear_extrude(height=wallThickness+lidOverlap) difference() {
            baseProfile(extraLidOuter);
            baseProfile(0);
        }
    linear_extrude(height=wallThickness+pcbLength+2*pcbLengthTolerance) {
        translate([0,railBottom]) {
            leftRail();
            mirror([1,0]) leftRail();
        }
    }
}

module lid() {
    linear_extrude(height=wallThickness) baseProfile(extraLidOuter);
    linear_extrude(height=wallThickness+lidOverlap) difference() {
            baseProfile(extraLidOuter);
            baseProfile(extraLidInner);
        }
    
}

box();
translate([pcbWidth+15,0,0]) lid();