use <bezier.scad>;
use <paths.scad>;

//<params>
headbandWidth = 140; 
headbandHeightRatio = 1.1;
headbandStripWidth = 10;
headbandStripThickness = 2.5;
toothedRatio = .7;
toothSpacing = 3;
toothThickness = 1;
toothLength = 1;
toothWidthRatio = 0.5;
headbandBottomFlare = 1; // [0:no, 1:yes]

earPosition = 0.3;
earAngle1FromVertical = -10;
earAngle2FromVertical = 10;
earStickoutForce1 = 2.2;
earStickoutForce2 = 2.2;
earThickness = 5;
earBackingThickness = 1;
earSize = 70;
earInnerRatio = 0.5;

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
    
    module ear(earSize) {
        earStart = earPosition * length - earSize / 2;
        earEnd = earPosition * length + earSize / 2;
        earPoints0 = [for (d=[earStart:1:earEnd]) interpolateByDistance(interp,d)];
        a = interpolateByDistance(interp,earStart);
        b = interpolateByDistance(interp,earEnd);
        earAngle = atan2(b[1]-a[1],b[0]-a[0]);
        c = (a+b)/2;
        r = norm(c-a);
        rot = [ [ cos(earAngle), -sin(earAngle) ],
                [ sin(earAngle), cos(earAngle) ] ];
        earPoints1a = Bezier( [[-1,0], POLAR(earStickoutForce1,90-earAngle1FromVertical), POLAR(earStickoutForce2,90+earAngle2FromVertical), [1,0]]); // ,  
        earPoints1 = [for (v=r*earPoints1a) c+rot*v];
        earPoints = concat(earPoints0,earPoints1);
        earCenterPoint = interpolateByDistance(interp,(earStart+earEnd)/2);
        earTangent = getTangentByDistance(interp,(earStart+earEnd)/2);
        earNormal = [-earTangent[1],earTangent[0]];
        linear_extrude(height=earThickness+earBackingThickness)
            polygon(earPoints);
        linear_extrude(height=earBackingThickness)
            polygon(earPoints);
    }
    
    difference() {
        ear(earSize);
        translate([0,0,(earThickness+earBackingThickness)/2])
        ear(earSize*earInnerRatio);
    }
}

module headband() {
    rightSide();
    mirror([1,0,0]) rightSide();
}

render(convexity=2)
    headband();

