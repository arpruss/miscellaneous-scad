use <bezier.scad>;

tipDiameter = 20;
centerDiameter = 27;
height = 90;
chamferSize = 1.5;
endCapFraction = 0.12; /* fraction of total height occupied by each end cap */
wallThickness = 1.25;
maxBridgeLength = 15;

module dummy() {}
nudge = 0.01;

module crossSection(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height) {
    tipR = tipDiameter / 2;
    centerR = centerDiameter / 2;

    bezierPointsTop = [
      [0,height],[tipR,height], [0,height], 
      /*N*/[tipR-chamferSize,height],
      /*C*/[tipR-chamferSize*0.5,height], 
      /*C*/[tipR,height-chamferSize*0.5], 
      /*N*/[tipR,height-chamferSize], 
      [tipR*0.25+centerR*0.75,0.75*height], [centerR,0.625*height], [centerR,0.5*height]];
    bezierPointsBottom = [ for(i=[1:len(bezierPointsTop)-1]) let(j=len(bezierPointsTop)-1-i) [bezierPointsTop[j][0],height-bezierPointsTop[j][1]] ];
    bezierPoints = concat(bezierPointsTop,bezierPointsBottom);
    polygon(Bezier(bezierPoints));
}

module pin(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height) {
    rotate_extrude() crossSection(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height);
}

module insidePin() {
    maxDiameter = max(tipDiameter,centerDiameter);

    cylinderHeight = maxBridgeLength < maxDiameter ? 0.5*(maxDiameter-maxBridgeLength) : 0;
    
    module antiBridgingCylinder() {
        if (maxBridgeLength < maxDiameter) {
            translate([0,0,-cylinderHeight])
            cylinder(d2=maxBridgeLength, d1=maxDiameter, h=cylinderHeight);
        }
    }
    
        intersection() {
            pin(tipDiameter=tipDiameter-2*wallThickness, centerDiameter=centerDiameter-2*wallThickness);
            union() {
                translate([-maxDiameter,-maxDiameter,height*endCapFraction+cylinderHeight]) cube([maxDiameter*2,maxDiameter*2,height*(1-2*endCapFraction)-2*cylinderHeight]);
                translate([0,0,(1-endCapFraction)*height-nudge])
                    antiBridgingCylinder();
                translate([0,0,endCapFraction*height+nudge])
                rotate([0,180,0]) antiBridgingCylinder();
            }
        }
}

module hollowPin() {
    difference() {
        pin();
        insidePin();
    }
}

$fn=60;
hollowPin();

//crossSection();