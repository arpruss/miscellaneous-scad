use <bezier.scad>;
use <paths.scad>;

//<params>
tipDiameter = 20;
centerDiameter = 27;
height = 90;
chamferSize = 1.5;
// fraction of total height occupied by each solid end cap 
endCapFraction = 0.12; 
wallThickness = 1.25;
maxBridgeLength = 15;

// height for weight capsule (if used, stop printing here and insert weights)
weightCapsuleHeight = 0; 
weightCapsuleDiameter = 15;
weightCapsuleNumberOfSides = 30;
weightCapsuleOffsetFromTip = 3;

module dummy() {}
//</params>

nudge = 0.01;
endCapSize = max(endCapFraction*height, weightCapsuleHeight > 0 ? weightCapsuleHeight+weightCapsuleOffsetFromTip+2 : 0);

function getProfile(tipDiameter=tipDiameter,  centerDiameter=centerDiameter, height=height) = 
    let(
        tipR = tipDiameter / 2,
        centerR = centerDiameter / 2,
        bezierPointsTop = [
      /*N*/[tipR-chamferSize,height],
      OFFSET([chamferSize*0.5,0]), 
      /*C*/SMOOTH_ABS(chamferSize*0.5), 
      /*N*/[tipR,height-chamferSize], 
      [tipR*0.25+centerR*0.75,0.75*height], [centerR,0.625*height], [centerR,0.5*height]],
    pointsTop = DecodeSpecialBezierPoints(bezierPointsTop))
    reverseArray(Bezier(stitchPaths(pointsTop, transformPath(mirrorMatrix([0,1]), reverseArray(pointsTop)))));

module extrudeWithScalingPath(path, scale=1.) {
    for (i=[0:len(path)-2]) {
        echo(s1,z1,s2,z2);
        s1 = path[i][0]*scale;
        z1 = path[i][1];
        s2 = path[i+1][0]*scale;
        z2 = path[i+1][1];
        translate([0,0,z1]) linear_extrude(height=z2-z1, convexity=10, scale=s2/s1) scale(s1) children();
    }
}

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
    pointsTop = DecodeSpecialBezierPoints(bezierPointsTop);
    points = stitchPaths(pointsTop, transformPath(mirrorMatrix([0,1]), reverseArray(pointsTop)));
    polygon(Bezier(points));
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

render(convexity=1)
/*
difference() {
    rotate_extrude($fn=60) crossSection();
    if (weightCapsuleHeight>0) {
        translate([0,0,weightCapsuleOffsetFromTip])
            cylinder(h=weightCapsuleHeight,d=weightCapsuleDiameter,$fn=weightCapsuleNumberOfSides);
        translate([0,0,height-weightCapsuleOffsetFromTip-weightCapsuleHeight])
            cylinder(h=weightCapsuleHeight,d=weightCapsuleDiameter,$fn=weightCapsuleNumberOfSides);
    }
}
*/
extrudeWithScalingPath(getProfile(),scale=1./90) 
    polygon([for (angle=[0:5:355]) 30*(2+cos(angle*8))*[cos(angle),sin(angle)]]);
