use <Bezier.scad>;
use <tubeMesh.scad>;

bottomDiameter = 21.97;
topDiameter = 19.44;
tightTolerance = .13;
looseTolerance = .27;
restrictorHeight = 7;
baseHeight = 6;
neckHeight = 3;
neckExpansion = .5;
outerDiameter = 34;
holeDiameter = 4.11;
holeSpacing = 27.06;
flowerCircleRatio = .5*.5;
inset = 1;
lowerCircle = 1; //[0:no,1:yes]

nudge = .01;

slope = (bottomDiameter-topDiameter)/2/restrictorHeight;

$fn = 64;

module outerShape() {
    linear_extrude(height=baseHeight) {
        difference() {
            circle(d=outerDiameter);
            for (s=[-1,1]) translate([holeSpacing/2*s,0]) circle(d=holeDiameter+2*looseTolerance);
        }
    }
    translate([0,0,baseHeight-nudge]) cylinder($fn=8,d2=topDiameter-2*tightTolerance,d1=bottomDiameter-2*tightTolerance,h=restrictorHeight);

    translate([0,0,baseHeight-nudge]) cylinder($fn=8,d1=topDiameter-2*tightTolerance,d2=topDiameter-2*tightTolerance+neckExpansion*2,h=restrictorHeight+neckHeight);
}

function innerOutlineBezier(r1,ratio=flowerCircleRatio) = let(b=Bezier([[0,1],
        POLAR(1/4,0),
        POLAR(1/4,135),[PI/4-PI/24,1-ratio/2],POLAR(1/12/2,135+180), 
    POLAR(1/16/2,180), 
    [PI/4,1-ratio/2-.05],
    REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0])]))
    [for(tr=b) let(angle=tr[0]*180/PI,r=r1*tr[1]) r*[cos(angle),sin(angle)]];

module innerOutline(d) {
    for (a=[0:90:270]) rotate(a) translate([d/2-flowerCircleRatio*d/2,0]) circle(flowerCircleRatio*d/2);
}

module innerShapeBezier() {
    section1 = sectionZ(innerOutlineBezier(bottomDiameter/2+slope*baseHeight-inset),-nudge);
    nPoints = len(section1);
    section2 = sectionZ(lowerCircle ? ngonPoints(r=topDiameter/2-inset,n=nPoints) :  innerOutlineBezier(topDiameter/2-inset),baseHeight+restrictorHeight);
    section3 = sectionZ(ngonPoints(r=topDiameter/2-inset+neckExpansion,n=8),baseHeight+restrictorHeight+neckHeight+nudge);
    tubeMesh([section1, section2, section3]);
}

module innerShape() {
    scale = (topDiameter/2+slope*(restrictorHeight+baseHeight))/(bottomDiameter/2);
    
    translate([0,0,-nudge])
    linear_extrude(scale=1/scale,height=restrictorHeight+baseHeight+2*nudge) innerOutline((topDiameter-2*inset)*scale);
    translate([0,0,restrictorHeight+baseHeight-nudge])
    linear_extrude(height=neckHeight+2*nudge) scale(1/scale) innerOutline(topDiameter-2*inset); 
}

difference() {
    outerShape();
    innerShapeBezier();
}

/*
difference() {
    zzzcircle($fn=8,d=topDiameter-2*tightTolerance);    innerOutlineBezier(topDiameter);
}
*/

//translate([0,0,1]) linear_extrude(height=1)
//innerOutlineBezier(topDiameter-2*inset);
//linear_extrude(height=1) innerOutline(topDiameter-2*inset);