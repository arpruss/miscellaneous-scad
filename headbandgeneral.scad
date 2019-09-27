use <bezier.scad>;
use <paths.scad>;

includeHeadband = 1; // [0:no, 1:yes]

headbandWidth = 123;
headbandHeightRatio = 1.1;
headbandStripWidth = 10;
headbandStripThickness = 2.5;
toothedRatio = .7;
toothSpacing = 3;
toothThickness = 1;
toothLength = 1;
toothWidthRatio = 0.5;
headbandBottomFlare = 1; // [0:no, 1:yes]

spikeThickness = 4;
spikeLength = 20;
spikePosition = 0.35;
spikeAngle = 90;

/*stalkHolderPosition = 0.25;
stalkThickness = 5;
stalkHolderBackingThickness = 1;
stalkHolderSize = 30;
stalkWidth = 4;
stalkSocketDiameter = 6;
stalkTolerance = 0.5;
stalkAngle = 75;

stalkBallDiameter = 20;
stalkLength = 126;
stalkBallFlat = 1; // [0:no, 1:yes] */

spacing = 5; /* spacing between parts */

module dummy() {}



nudge = 0.01;

headbandHeight = headbandWidth * headbandHeightRatio;

pointsRight = Bezier([
[0,headbandHeight], /*C*/POLAR(headbandWidth/4,0), /*C*/POLAR(headbandWidth/4,90), [headbandWidth/2,headbandHeight/2],
/*C*/SYMMETRIC(), /*C*/POLAR(headbandWidth/(headbandBottomFlare?6:4),headbandBottomFlare?90:60),[headbandWidth/4,0]]);

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

    spikeCenter = interpolateByDistance(interp,spikePosition*length);
    tangent0 = interpolateByDistance(interp,spikePosition*length+0.01)-spikeCenter;
    echo(tangent0);
    tangent = tangent0 / norm(tangent0);
    tangentAngle = atan2(tangent[1],tangent[0]);
    spikeAngle1 = tangentAngle + spikeAngle;
    lengthAlongTangent = spikeThickness / cos(spikeAngle1+90-tangentAngle);
    spikeVector = [cos(spikeAngle1),sin(spikeAngle1)];
    spikeVectorPlus90 = [cos(spikeAngle1+90),sin(spikeAngle1+90)];
    echo(spikeVectorPlus90);
    p0 = spikeCenter-tangent/2*lengthAlongTangent;
    p1 = spikeCenter+tangent/2*lengthAlongTangent;
    linear_extrude(height=headbandStripWidth)
    polygon([p1,p0,p0+spikeVector*spikeLength,p0+spikeVector*spikeLength+spikeVectorPlus90*spikeThickness]);
}

module headband() {
    rightSide();
    mirror([1,0,0]) rightSide();
}

headband();

