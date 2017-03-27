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

module pinCrossSection(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height) {
    tipR = tipDiameter / 2;
    centerR = centerDiameter / 2;

    bezierPointsTop = [
      [0,height],/*C*/OFFSET([1,0]),OFFSET([-1,0]), 
      /*N*/[tipR-chamferSize,height],
      /*C*/SMOOTH_ABS(chamferSize*0.5), 
      /*C*/SMOOTH_ABS(chamferSize*0.5), 
      /*N*/[tipR,height-chamferSize], 
      [tipR*0.25+centerR*0.75,0.75*height], [centerR,0.625*height], [centerR,0.5*height]];
    function flip(v) = POINT_IS_SPECIAL(v) ? v : [v[0],height-v[1]];
    fixedTop = DecodeBezierOffsets(bezierPointsTop);
    bezierPointsBottom = [ for(i=[1:len(fixedTop)-1]) let(j=len(fixedTop)-1-i) flip(fixedTop[j]) ];
    bezierPoints = concat(bezierPointsTop,bezierPointsBottom);
    polygon(Bezier(bezierPoints));
}

module pin(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height, $fn=$fn) {
    rotate_extrude() crossSection(tipDiameter=tipDiameter, centerDiameter=centerDiameter, height=height);
}

module insidePinCrossSection() {
    $fn = 16;
    
    maxDiameter = max(tipDiameter,centerDiameter);

    cylinderHeight = maxBridgeLength < maxDiameter ? 0.5*(maxDiameter-maxBridgeLength) : 0;
    
    module antiBridgingCylinder() {
        if (maxBridgeLength < maxDiameter) {
            translate([0,-cylinderHeight])
            polygon([[0,0],[maxDiameter/2,0],[maxBridgeLength/2,cylinderHeight],[0,cylinderHeight]]);
        }
    }
    
        intersection() {
            pinCrossSection(tipDiameter=tipDiameter-2*wallThickness, centerDiameter=centerDiameter-2*wallThickness);
            union() {
                translate([-maxDiameter/2,height*endCapFraction+cylinderHeight]) square([maxDiameter,height*(1-2*endCapFraction)-2*cylinderHeight]);
                translate([0,(1-endCapFraction)*height-nudge])
                    antiBridgingCylinder();
                translate([0,endCapFraction*height+nudge])
                mirror([0,1]) antiBridgingCylinder();
            }
        }
}

module crossSection() {
    $fn = 60;
    difference() {
        pinCrossSection();
        insidePinCrossSection();
    }
}

render(convexity=1)
rotate_extrude($fn=60) 
crossSection();
