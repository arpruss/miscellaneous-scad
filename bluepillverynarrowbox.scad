use <roundedSquare.scad>;
use <ngcsocket.scad>;

//<params>
pcbThickness = 1.55;
pcbWidth = 22.7;
pcbLength = 52.4;
pcbLengthExtra = 2;
pcbMinOffsetFromBase = 2.6;
pcbLengthTolerance = 0.2;
cordSlitDepth = 16;
cordSlitWidth = 1.75;

innerRadius = 3;

railThickness = 1.4;
railWidth = 1.5;
railRounding = 0.5;

pcbWidthTolerance = 0.28;
pcbThicknessTolerance = 0.12;

lidTolerance = 0.25;
lidToleranceVertical = 0.4;

lidOverlap = 8;

wallThickness = 1.1;

boxHeight = 13+pcbThickness+pcbMinOffsetFromBase;

usbHoleWidth = 12.25;
usbHoleHeight = 6.75;
usbHoleRounding = 1;
usbHoleCenterOffsetFromPCBTop = 1.4;

ngcHoleTolerance = 0.27;
ngcHoleBottomOffsetFromPCBTop = 5;
ngcHoleRadius = getMainProfileRadius(ngcHoleTolerance);
ngcHoleDepth = 10;

screwHoleDiameterTight = 1.75;
screwHoleDiameterLoose = 3.5;
//</params>

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

ngcHoleY = pcbTop + ngcHoleBottomOffsetFromPCBTop + ngcHoleRadius;
length = wallThickness+pcbLength+pcbLengthExtra+2*pcbLengthTolerance;

module basicBox() {
    /*linear_extrude(height=wallThickness) {  
            baseProfile(extraBoxOuter);
    } */
    linear_extrude(height=length) difference() {
            baseProfile(extraBoxOuter);
            baseProfile(0);
        } 
/*    linear_extrude(height=wallThickness+lidOverlap) difference() {
            baseProfile(extraLidOuter);
            baseProfile(0);
        } */
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
}

module screwHoleRight(z,d) {
    translate([boxInnerWidth/2-nudge,ngcHoleY,z]) rotate([0,90,0]) cylinder(d=d,h=extraLidOuter+2*nudge);
}

/*
module label() {
    if (label != "") 
        rotate([0,0,90])
        rotate([0,90,0])
        rotate([0,0,180])
    drawHersheyText(label, font="Sans", valign="center", halign="center", size=labelFontSize,extraSpacing=-1.5) cylinder(d1=2,d2=0.5,h=1,$fn=8);
}
*/

module box() {
    difference() {
        basicBox();
        translate([0,boxHeight/2,length/2]) rotate([90,0,0]) linear_extrude(height=wallThickness*3,center=true) mainProfile(tolerance=ngcHoleTolerance);

        for (z=[length-lidOverlap/2+lidToleranceVertical,lidOverlap/2-lidToleranceVertical]) {
        screwHoleRight(z,screwHoleDiameterTight);
        mirror([1,0,0]) screwHoleRight(z,screwHoleDiameterTight);
        }
            translate([0,ngcHoleY,-nudge]) linear_extrude(height=ngcHoleDepth) mainProfile(tolerance=ngcHoleTolerance);
    }
    //translate([0,boxHeight/2+extraBoxOuter,length/2]) label();
}

module lid(ngc=false) {
    
    difference() {
        union() {
                linear_extrude(height=wallThickness) {
            difference() {
                baseProfile(extraLidOuter);    
                if (ngc) {
                    translate([0,ngcHoleY]) 
                    mainProfile(ngcHoleTolerance);
                }
                else 
            translate([0,pcbTop+usbHoleCenterOffsetFromPCBTop]) roundedSquare([usbHoleWidth,usbHoleHeight],radius=usbHoleRounding,center=true);
            }
                }
                linear_extrude(height=wallThickness+lidOverlap) difference() {
                baseProfile(extraLidOuter);
                baseProfile(extraLidInner);
            }
        }
        screwHoleRight(wallThickness+lidOverlap/2,screwHoleDiameterLoose);
            mirror([1,0,0]) screwHoleRight(wallThickness+lidOverlap/2,screwHoleDiameterLoose);
    }
    
        
}

/*
box();
translate([pcbWidth+15,0,0]) lid(false);
translate([-pcbWidth-15,0,0]) lid(true);
*/

difference() {
   basicBox();
   translate([-cordSlitWidth/2,0,length-cordSlitDepth+nudge]) 
    cube([cordSlitWidth,100,cordSlitDepth]);
}
linear_extrude(height=wallThickness) baseProfile(0);
