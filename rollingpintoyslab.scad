use <bezier.scad>;

// NOTE: THIS IS TERRIBLE IN PRACTICE!

//<params>
tipDiameter = 20;
centerDiameter = 27;
height = 90;
// default 1.5
chamferSize = 0;
// fraction of total height occupied by each solid end cap 
endCapFraction = 0.12; 
// default 1.25
wallThickness = 1.25;
maxBridgeLength = 15;
// set to non-zero to print a slab version
slabWidth = 27;
squareCrossSection = true;

// height for weight capsule (if used, stop printing here and insert weights)
weightCapsuleHeight = 0; 
weightCapsuleDiameter = 15;
weightCapsuleNumberOfSides = 30;
weightCapsuleOffsetFromTip = 3;

module dummy() {}
//</params>

nudge = 0.01;
endCapSize = max(endCapFraction*height, weightCapsuleHeight > 0 ? weightCapsuleHeight+weightCapsuleOffsetFromTip+2 : 0);

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
    function flip(v) = [v[0],height-v[1]];
    fixedTop = DecodeSpecialBezierPoints(bezierPointsTop);
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
                translate([-maxDiameter/2,endCapSize+cylinderHeight]) square([maxDiameter,height-2*endCapSize-2*cylinderHeight]);
                translate([0,height-endCapSize-nudge])
                    antiBridgingCylinder();
                translate([0,endCapSize+nudge])
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

module oneSideSlab(slabWidth=slabWidth) {
    linear_extrude(height=wallThickness) pinCrossSection();
    linear_extrude(height = slabWidth)
        crossSection();
    translate([0,0,slabWidth-wallThickness])
    linear_extrude(height=wallThickness) pinCrossSection();
}

render(convexity=1)
if (squareCrossSection) {
    intersection() {
        translate([0,centerDiameter/2,0]) 
        rotate([90,0,0]) {
                oneSideSlab(slabWidth=centerDiameter);
                translate([nudge,0,0]) mirror([1,0,0]) oneSideSlab(slabWidth=centerDiameter);
        }
        translate([-centerDiameter/2,0,0]) 
        rotate([0,0,90]) rotate([90,0,0]) {
                oneSideSlab(slabWidth=centerDiameter);
                translate([nudge,0,0]) mirror([1,0,0]) oneSideSlab(slabWidth=centerDiameter);
        }
    }
}
else if (slabWidth>0) {
    rotate([90,0,0]) {
        oneSideSlab();
        translate([nudge,0,0]) mirror([1,0,0]) oneSideSlab();
    }
}
else {
    difference() {
        rotate_extrude($fn=60) crossSection();
        if (weightCapsuleHeight>0) {
            translate([0,0,weightCapsuleOffsetFromTip])
                cylinder(h=weightCapsuleHeight,d=weightCapsuleDiameter,$fn=weightCapsuleNumberOfSides);
            translate([0,0,height-weightCapsuleOffsetFromTip-weightCapsuleHeight])
                cylinder(h=weightCapsuleHeight,d=weightCapsuleDiameter,$fn=weightCapsuleNumberOfSides);
        }
    }
}