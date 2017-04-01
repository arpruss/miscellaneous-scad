use <bezier.scad>;
use <interpolate.scad>;

//<params>
includeHeadband = true;
stalkCount = 0;

headbandWidth = 123;
headbandHeightRatio = 1.1;
headbandStripWidth = 10;
headbandStripThickness = 2.5;
toothedRatio = .7;
toothSpacing = 3;
toothThickness = 1;
toothLength = 1;
toothWidthRatio = 0.5;
headbandBottomFlare = true;

stalkHolderPosition = 0.25;
stalkThickness = 5;
stalkHolderBackingThickness = 1;
stalkHolderSize = 30;
stalkWidth = 4;
stalkSocketDiameter = 6;
stalkTolerance = 0.5;
stalkAngle = 75;

stalkBallDiameter = 20;
stalkLength = 126;
stalkBallFlat = true;

spacing = 5; /* spacing between parts */

module dummy() {}
//</params>

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

    if (stalkHolderSize>0) {    
        stalkHolderStart = stalkHolderPosition * length - stalkHolderSize / 2;
        stalkHolderEnd = stalkHolderPosition * length + stalkHolderSize / 2;
        stalkHolderPoints0 = [for (d=[stalkHolderStart:1:stalkHolderEnd]) interpolateByDistance(interp,d)];
        a = interpolateByDistance(interp,stalkHolderStart);
        b = interpolateByDistance(interp,stalkHolderEnd);
        stalkHolderAngle = atan2(b[1]-a[1],b[0]-a[0]);
        c = (a+b)/2;
        r = distance(a,c);
        stalkHolderPoints1 = [for (angle=[0:10:180]) c+r*[cos(angle+stalkHolderAngle),sin(angle+stalkHolderAngle)]];
        stalkHolderPoints = concat(stalkHolderPoints0,stalkHolderPoints1);
        stalkHolderCenterPoint = interpolateByDistance(interp,(stalkHolderStart+stalkHolderEnd)/2);
        stalkHolderTangent = getTangentByDistance(interp,(stalkHolderStart+stalkHolderEnd)/2);
        stalkHolderNormal = [-stalkHolderTangent[1],stalkHolderTangent[0]];
        socketCenter = stalkHolderCenterPoint+(stalkTolerance+stalkSocketDiameter/2+headbandStripThickness/2)*stalkHolderNormal;
        linear_extrude(height=stalkThickness+stalkHolderBackingThickness)
        difference() {
            polygon(stalkHolderPoints);
            translate(socketCenter) circle(r=stalkTolerance+stalkSocketDiameter/2);
            translate(socketCenter) rotate([0,0,stalkAngle])    translate([0,-(stalkWidth/2+stalkTolerance)]) square([r,stalkWidth+stalkTolerance*2]);
        }
        linear_extrude(height=stalkHolderBackingThickness)
            polygon(stalkHolderPoints);
    }
}

module headband() {
    rightSide();
    mirror([1,0,0]) rightSide();
}

module stalk() {
    translate([-stalkWidth/2,0,0]) cube([stalkWidth,stalkLength,stalkThickness]);
    linear_extrude(height=stalkThickness)
    circle(d=stalkSocketDiameter);
    render(convexity=2)
    translate([0,stalkLength,0])
    if (stalkBallFlat) {
        linear_extrude(height=stalkThickness) circle(d=stalkBallDiameter);
    }
    else {
        intersection() {
            union() {
                translate([0,0,stalkThickness/2]) sphere(d=stalkBallDiameter);
                translate([0,stalkBallDiameter+spacing,-stalkThickness/2]) sphere(d=stalkBallDiameter);
            }
            translate([-stalkBallDiameter/2,-stalkBallDiameter/2,0]) cube([stalkBallDiameter,stalkBallDiameter*2+spacing,stalkBallDiameter]);
        }
    }
}

if (includeHeadband)
    headband();

x0 = includeHeadband ? headbandWidth/2 + stalkHolderSize/2 + spacing : 0;

if (stalkCount>0)
    for (i=[0:stalkCount-1]) 
        translate([x0+i*(stalkBallDiameter+spacing),0,0])
            stalk();
