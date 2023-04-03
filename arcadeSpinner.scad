use <tubemesh.scad>;
use <roundedSquare.scad>;

includeTop = 0; //1:Yes, 0:No
includeKnob = 1; //1:Yes, 0:No
shaftOnly = 0; //1:Yes, 0:No
includeBottom = 0; //1:Yes, 0:No
includeNunchuckPort = 1;

bearingID = 8;
bearingThickness = 7;
bearingOD = 22;
bearingCollarHeight = 4;

pcbSizeX = 11.94;
pcbSizeY = 11.58;
pcbThickness = 1.6;
bottomBevel = 0.5;

icThickness = 1.54;

verticalOffset = 2.5;
pcbHolderBevel = 1.4;

magnetDiameter = 6;
//magnetThickness = 2.5;
magnetCollarHeight = 2; //2.25;
magnetCollarBevel = 0.25; //0.25;
shaftLength = 14+1;

tolerance = 0.2;
sensorPCBTolerance = 0.3;
shaftOuterTolerance = 0.065; // 0.05, 0.1;
magnetTolerance = 0.08; // 0.15;

topWall = 3;
bottomWall = 2.5;
length = 100;
width = 88;
roundingRadius = 10;

spinnerY = 80;
buttonY = 30;

supportSize = 7;

buttonSpacing = 38;
buttonBaseThickness = 3.7; 
buttonTolerance = 0.05;
holeDiameterMain = 28.88; 
snapThickness = 0.25;
snapThickening = 0.5;
snapWidth = 7.25;
antiRotation = 2.3; 

miniButtonSide = 6.04;
miniButtonHole = 3;
miniButtonX = 35;
miniButtonY1 = 60;
miniButtonY2 = 75;

screwOffset = 8;
screwHole = 4;
pillarScrewHole = 3;
pillarDiameter = 13;

knobDiameter = 31.75;
knurlingAngle = 5;
//knobTopThickness = 2;
//knobJoinThickness = 2;
//knobSideWallThickness = 1.75;
knobSideWallThickness = 1.75;
knobSideWallHeightBase = 17; // not exactly parametric -- must be tuned to fit and clear bearing holder
knobTopChamfer = 0.75;
knobClearance = 1.25;
knobDepressionFractionOfRadius = 0.4;
knobDepressionDepth = 1.7;
knobDepressionOffsetFromEdge = 0.5;
knobDepressionChamfer = 1.5;

lidTolerance = 0.2;
clearanceAbovePillPCB = 10.5;
clearanceAboveFloor = 21;
sideWall = 2.5;
topLip = 1.2;
pillPCBTopHeight = 5.65;
bottomScrewPillarDiameter = 10;
bottomScrewPillarHeight = 2;
bottomScrewHole = 3.75;
bottomScrewHead = 8;
bottomScrewInset = 2;
pillY = 65;
bottomScrew1DistanceFromFront = 5;
bottomScrew2DistanceFromFront = 50;
bottomScrewSpacing = 30.7;
usbHoleHeight = 7;
usbHoleWidth = 12;
usbPortHeight = 2.9;
//wall = 1.5;

nunchuckPortTolerance = 0.32;
nunchuckPortHeight = 7.36;
nunchuckPortWidth = 12.24;
nunchuckPortInsetDepth = 1.28;
nunchuckPortInsetWidth = 4.59;
nunchuckPortPillarTopFromCenter = 4.9;
nunchuckOffsetFromFloor = 7;




module dummy() {}


module nunchuckConnector() {
    h = nunchuckPortHeight + 2*nunchuckPortTolerance;
    w = nunchuckPortWidth + 2*nunchuckPortTolerance;
    insetDepth = nunchuckPortInsetDepth;
    insetWidth = nunchuckPortInsetWidth-2*nunchuckPortTolerance;
    rotate([0,90,0])
    translate([0,0,-sideWall-nudge])
    linear_extrude(height=sideWall*2+2*nudge)
    polygon([[-h/2,-w/2],[h/2,-w/2],[h/2,w/2],[-h/2,w/2],[-h/2,insetWidth/2],[-h/2+insetDepth,insetWidth/2],[-h/2+insetDepth,-insetWidth/2],[-h/2,-insetWidth/2]]);
}


bottomHeight = topWall+bottomWall+max(clearanceAboveFloor,bottomScrewPillarHeight+clearanceAbovePillPCB+pillPCBTopHeight);

knobSideWallHeight = knobSideWallHeightBase + 3 - topWall;

pcbThickness1 = pcbThickness+sensorPCBTolerance;

nudge = 0.001;
spinnerHolderHeight = bearingCollarHeight+verticalOffset+pcbThickness1;

// this is xy-centered for convenience
module topBeveledCube(size, bevel=1, bevelHeightToWidthRatio=1) {
    function section(xSize, ySize, zPos) = 
        [ [xSize/2,-ySize/2,zPos],
          [xSize/2,ySize/2,zPos],
          [-xSize/2,ySize/2,zPos],
          [-xSize/2,-ySize/2,zPos ] ];
    
    tubeMesh([
        section(size[0],size[1],0),
        section(size[0],size[1],size[2]-bevel*bevelHeightToWidthRatio),
        section(size[0]-bevel*2,size[1]-bevel*2,size[2])]);
}

// this is xy-centered for convenience
module flaredCylinder(d=10, r=undef, h=10, flare=1) {
    $fn = 64;
    diameter = (r==undef)?d:(2*r);
    tubeMesh([ngonPoints(n=$fn,d=diameter,z=0),
        ngonPoints(n=$fn,d=diameter,z=h-flare),
        ngonPoints(n=$fn,d=diameter+2*flare,z=h)]);
}

module spinnerHolder() {
    $fn = 64;
    difference() {
        cylinder(d=bearingOD+2*wall+2*tolerance, h=spinnerHolderHeight);
        translate([0,0,pcbThickness1+pcbHolderBevel]) cylinder(d=bearingOD+2*tolerance-2*wall, h=spinnerHolderHeight);
        translate([0,0,spinnerHolderHeight-bearingCollarHeight]) flaredCylinder(d=bearingOD+2*tolerance, h=bearingCollarHeight+nudge, flare=0.5);
        translate([0,0,-nudge])
        topBeveledCube([pcbSizeX+2*sensorPCBTolerance,pcbSizeY+2*sensorPCBTolerance,pcbThickness1+pcbHolderBevel+2*nudge], bevel=pcbHolderBevel);
    }
}

module spinnerCutout() {
    $fn = 64;
    circle(d=bearingOD+2*wall+2*tolerance-nudge);
}

module knobBasic(supports=false) {
    $fn = 64;
    od = bearingID-2*shaftOuterTolerance;
    difference() {
        cylinder(d=od,h=shaftLength+magnetCollarHeight);
        translate([0,0,shaftLength])
            flaredCylinder(d=magnetDiameter+2*magnetTolerance,h=magnetCollarHeight+nudge,flare=magnetCollarBevel);
    }
    cylinder(h=shaftLength+magnetCollarHeight-bearingThickness,d=od+1);
    if (supports && supportSize>0) {
        x = od/2;
        for (angle=[0:90:360-90]) rotate([0,0,angle]) {
            
            morphExtrude([ 
                [ x-.05, 0, 0],
                [ x+.6, -.4, 0],
                [ x+supportSize, -.4, 0],
                [ x+supportSize, .4, 0],
                [ x+.6, .4, 0] ],
                [ [ x-.05, 0, shaftLength-5],
                  [ x+.6, -.4, shaftLength-5],
                  [ x+.6, .4, shaftLength-5] ]);                
        }
    }

    //knobSideWallThickness = (knobDiameter - ( bearingOD+2*knobSideWall+2*tolerance + 2 * knobClearance))/2;
    if (! shaftOnly) {
        intersection() {
            union() {
            linear_extrude(height=shaftLength+magnetCollarHeight-bearingThickness-knobClearance) {
                knobProfile();
            }
            linear_extrude(height=knobSideWallHeight) {
                difference() {
                    knobProfile();
                    circle(d=knobDiameter-knobSideWallThickness*2);
                }
                }
            }
            cylinder(r1=knobDiameter/2-knobTopChamfer,r2=knobDiameter/2-knobTopChamfer+(knobSideWallHeight+1),h=knobSideWallHeight+1,$fn=128);
        }
            
        /*
            for(angle=[0,90]) rotate([0,0,angle]) translate([0,0,(shaftLength+magnetCollarHeight-bearingThickness-knobClearance)/2]) cube([knobDiameter-knobSideWallThickness*2+nudge*2,knobJoinThickness,shaftLength+magnetCollarHeight-bearingThickness-knobClearance],center=true); 
        */

    }
    
}

module knob(supports=false) {
    difference() {
        knobBasic(supports=supports);
            r = knobDiameter/2-knobTopChamfer;
            d2 = knobDepressionFractionOfRadius * r;
            d1 = d2 + knobDepressionChamfer*2;
            
    translate([r-d1/2-knobDepressionOffsetFromEdge ,0,-nudge]) cylinder(d1=d1,d2=d2,h=knobDepressionDepth+nudge,$fn=128);
        }
}

module arcadeButtonCylinder() {
    rotate([0,0,90]) {
        translate([0,0,-nudge]) cylinder(h=buttonBaseThickness+2*nudge+snapThickening, d=holeDiameterMain+2*buttonTolerance);
        for (angle=[0:180:180]) 
            rotate([0,0,angle]) 
                translate([0,-snapWidth/2,-nudge])
                cube([holeDiameterMain/2+buttonTolerance+snapThickness,snapWidth,2*nudge+buttonBaseThickness+snapThickening]);
        for (angle=[45:90:360-45]) rotate([0,0,angle]) translate([holeDiameterMain/2+buttonTolerance,0,-nudge]) cylinder(d=antiRotation+2*tolerance,h=buttonBaseThickness+2*nudge,$fn=12);
    }
}

module arcadeButtonCutout(inset=0) {
    circle(d=holeDiameterMain+2*buttonTolerance+2*snapWidth-inset);
}

module arcadeButtonProfile() {
    $fn = 128;
    rotate([0,0,90]) {
        translate([0,0,-nudge]) circle(d=holeDiameterMain+2*buttonTolerance);
        for (angle=[0:180:180]) 
            rotate(angle) 
                translate([0,-snapWidth/2])
                square([holeDiameterMain/2+buttonTolerance+snapThickness,snapWidth]);
        for (angle=[45:90:360-45]) rotate(angle) translate([holeDiameterMain/2+buttonTolerance,0]) circle(d=antiRotation+2*buttonTolerance,$fn=12);
    }
}

module arcadeButton() {
    linear_extrude(height=buttonBaseThickness+snapThickening) {
        difference() {
            arcadeButtonCutout();
            arcadeButtonProfile();
        }
    }
}

module knobProfile() {
    circle(d=knobDiameter,$fn=128);
    kd = knurlingAngle / 180 * PI * knobDiameter / 2;
    for (angle = [0:knurlingAngle:360]) rotate(angle) translate([knobDiameter/2,0]) circle(d=kd,$fn=16);
}

module miniButton() {
    for (x=[-1/2,1/2]) for(y=[-1/2,1/2]) 
        translate(miniButtonSide*[x,y])
            circle(d=miniButtonHole,$fn=12);
}

module plate(inset=0) {
    translate([-width/2,0]) translate([inset,inset]) roundedSquare([width-2*inset,length-2*inset],radius=roundingRadius-inset,$fn=32);
}

module topScrews() {
            for (x=[-width/2+screwOffset,width/2-screwOffset]) for (y=[screwOffset,length-screwOffset]) translate([x,y]) children();
}

module topPlate() {
    linear_extrude(height=topWall) {
        difference() {
            plate(inset=0);
            translate([0,spinnerY]) spinnerCutout();
            translate([buttonSpacing/2,buttonY]) arcadeButtonCutout(inset=nudge);
            translate([-buttonSpacing/2,buttonY]) arcadeButtonCutout(inset=nudge);
            translate([miniButtonX,miniButtonY1]) miniButton();
            translate([miniButtonX,miniButtonY2]) miniButton();
            topScrews() circle(d=screwHole,$fn=12);
        }        
    }
    for (s=[-1,1]) translate([s*buttonSpacing/2,buttonY,0]) arcadeButton();
    translate([0,spinnerY]) spinnerHolder();
}

module bottomScrews() {
    translate([-topLip-lidTolerance+sideWall,0])
    translate([-width/2,pillY])
        for (dy=[-bottomScrewSpacing/2,bottomScrewSpacing/2]) for (dx=[bottomScrew1DistanceFromFront,bottomScrew2DistanceFromFront]) translate([dx,dy]) children();
}

module bottomMain() {
    difference() {
        union() {
            linear_extrude(height=bottomWall+bottomScrewPillarHeight) bottomScrews() difference() {
                circle(d=bottomScrewPillarDiameter,$fn=16);
                circle(d=bottomScrewHole,$fn=12);
            }
            linear_extrude(height=bottomWall) plate(inset=-topLip-lidTolerance);
        }
        translate([0,0,-nudge]) {
            linear_extrude(height=bottomWall+2*nudge) bottomScrews() circle(d=bottomScrewHole,$fn=12);
            linear_extrude(height=bottomScrewInset+nudge) bottomScrews() circle(d=bottomScrewHead,$fn=16);
        }
    }
    linear_extrude(height=bottomHeight-topWall) difference() {
        plate(inset=-topLip-lidTolerance-nudge);
        plate(inset=-topLip-lidTolerance+sideWall+nudge);
    }
    
    linear_extrude(height=bottomHeight) difference() {
        plate(inset=-topLip-lidTolerance);
        plate(inset=-lidTolerance);
    }
    linear_extrude(height=bottomHeight-topWall)
    topScrews() difference() {
        circle(d=pillarDiameter,$fn=16);
        circle(d=pillarScrewHole,$fn=12);
    }
    
    
}

module bottom() {
    difference() {
        bottomMain();
        translate([-width/2,pillY,bottomWall+bottomScrewPillarHeight+pillPCBTopHeight+usbPortHeight/2]) cube([sideWall+10,usbHoleWidth,usbHoleHeight],center=true);
        translate([0,0,nunchuckOffsetFromFloor+bottomWall]) rotate([180,0,0]) rotate([0,0,90]) nunchuckConnector();
    }
}

if (includeTop)
translate([0,0,0*(bottomHeight-topWall)]) topPlate();
if (includeKnob)
translate([00,-knobDiameter/2-10,0]) knob();
if (includeBottom)
translate([width+20,0,0]) 
bottom();