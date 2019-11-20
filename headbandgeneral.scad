use <bezier.scad>;
use <paths.scad>;

headbandWidth = 128;
headbandHeightRatio = 1.05;
headbandStripWidth = 20;
headbandStripThickness = 3.9; // 2.5;
toothedRatio = .7;
toothSpacing = 3;
toothThickness = 1;
toothLength = 1;
toothWidthRatio = 0.5;
bottomNarrowing = 0.35;
headbandBottomFlare = 1; // [0:no, 1:yes]

spikeThickness = 3.95;
spikeWidth = 10;
spikeLength = 14;
spikePosition = 0.25;
spikeAngle = 90;
secondarySpike = 1; //[0:no, 1:yes]
secondarySpikePosition = 0.45;
secondarySpikeAngle = 90;

module dummy() {}

nudge = 0.01;

headbandHeight = headbandWidth * headbandHeightRatio;

pointsRight = Bezier([
[0,headbandHeight], /*C*/POLAR(headbandWidth/3,0), /*C*/POLAR(headbandWidth/4,90), [headbandWidth/2,headbandHeight/2],
/*C*/SYMMETRIC(), /*C*/POLAR(headbandWidth/(headbandBottomFlare?6:4),headbandBottomFlare?90:60),[headbandWidth*bottomNarrowing,0]]);

interp = interpolationData(pointsRight);
length = totalLength(interp);

module rightSide() {
    segmentLength = headbandStripWidth/3;
    segments = floor(length / segmentLength);

    for(i=[0:segments-1]) {
        adjust = i < segments-1 ? 0 : (1/(2+sqrt(2)))* headbandStripWidth;
        a = interpolateByDistance(interp, i*segmentLength);
        b = interpolateByDistance(interp, (i+1)*segmentLength);
        hull() {
            translate(a) cylinder(d=headbandStripThickness,h=headbandStripWidth,$fn=16);
            translate([b[0],b[1],adjust]) cylinder(d=headbandStripThickness,h=headbandStripWidth-2*adjust,$fn=16);
        }
    }

    if (toothedRatio>0) {
        teeth = floor(length * toothedRatio / toothSpacing);
        for(i=[0:teeth-1]) {
            d = i * toothSpacing;
            tangent = getTangentByDistance(interp, d);
            normal = [tangent[1],-tangent[0]];
            a = interpolateByDistance(interp, d);
            hull() {
                translate(a) cylinder(h=toothWidthRatio*headbandStripWidth,d=toothThickness);
                translate(a+(toothLength+headbandStripThickness*0.5)*normal) cylinder(h=toothWidthRatio*headbandStripWidth,d=toothThickness);
            }
        }
    }

    spikes = secondarySpike ? [ [spikePosition,spikeAngle], [secondarySpikePosition,secondarySpikeAngle]] : [ [spikePosition,spikeAngle]];
    
    for (s=spikes) {
        spikePosition = s[0];
        spikeAngle = s[1];
        spikeCenter = interpolateByDistance(interp,spikePosition*length);
        tangent0 = interpolateByDistance(interp,spikePosition*length+0.01)-spikeCenter;
        tangent = tangent0 / norm(tangent0);
        tangentAngle = atan2(tangent[1],tangent[0]);
        spikeAngle1 = tangentAngle + spikeAngle;
        lengthAlongTangent = spikeThickness / cos(spikeAngle1+90-tangentAngle);
        spikeVector = [cos(spikeAngle1),sin(spikeAngle1)];
        spikeVectorPlus90 = [cos(spikeAngle1+90),sin(spikeAngle1+90)];
        p0 = spikeCenter-tangent/2*lengthAlongTangent;
        p1 = spikeCenter+tangent/2*lengthAlongTangent;
        delta = min(spikeThickness,headbandStripWidth)/2;
        linear_extrude(height=spikeWidth)
        polygon([p1,p0,p0+spikeVector*(spikeLength-delta),p0+spikeVector*spikeLength+spikeVectorPlus90*spikeThickness*0.5,p0+spikeVector*(spikeLength-delta)+spikeVectorPlus90*spikeThickness]);
    }
}

module headband() {
    rightSide();
    mirror([1,0,0]) rightSide();
}

headband();

