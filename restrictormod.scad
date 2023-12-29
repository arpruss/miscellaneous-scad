use <Bezier.scad>;

bottomDiameter = 21.97;
topDiameter = 19.44;
tightTolerance = .15;
looseTolerance = .3;
restrictorHeight = 7;
extraHeight = 6;
extraUpperHeight = 2;
outerDiameter = 33;
holeDiameter = 4.11;
holeSpacing = 27.06;
flowerCircleRatio = .55;
inset = 0.5;

nudge = .01;

slope = (bottomDiameter-topDiameter)/2/restrictorHeight;

$fn = 64;

module outerShape() {
    linear_extrude(height=extraHeight) {
        difference() {
            circle(d=outerDiameter);
            for (s=[-1,1]) translate([holeSpacing/2*s,0]) circle(d=holeDiameter+2*looseTolerance);
        }
    }
    translate([0,0,extraHeight-nudge]) cylinder($fn=8,d2=topDiameter-2*tightTolerance,d1=bottomDiameter-2*tightTolerance,h=restrictorHeight);
    translate([0,0,extraHeight-nudge]) cylinder($fn=8,d=topDiameter-2*tightTolerance,h=restrictorHeight+extraUpperHeight);
}

module innerOutlineBezier(d) {
    b = [[0,1],
        POLAR(1/4,0),
        POLAR(1/4,135),[PI/4-PI/24,1-flowerCircleRatio/2],POLAR(1/12/2,135+180), 
    POLAR(1/16/2,180), 
    [PI/4,1-flowerCircleRatio/2-.05],
    REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0])];

    path = Bezier(b);
    polygon([for(tr=path) let(theta=tr[0]*180/PI,r=(d/2)*tr[1]) r*[cos(theta),sin(theta)]]);
}

module innerOutline(d) {
    for (a=[0:90:270]) rotate(a) translate([d/2-flowerCircleRatio*d/2,0]) circle(flowerCircleRatio*d/2);
}

module innerShape() {
    scale = (topDiameter/2+slope*(restrictorHeight+extraHeight))/(bottomDiameter/2);
    translate([0,0,-nudge])
    linear_extrude(scale=1/scale,height=restrictorHeight+extraHeight+2*nudge) innerOutlineBezier(topDiameter-2*inset);
    translate([0,0,restrictorHeight+extraHeight-nudge])
    linear_extrude(height=extraUpperHeight+2*nudge) scale(1/scale) innerOutlineBezier(topDiameter-2*inset);
}

difference() {
    outerShape();
    innerShape();
}

//translate([0,0,1]) linear_extrude(height=1)
//innerOutlineBezier(topDiameter-2*inset);
//linear_extrude(height=1) innerOutline(topDiameter-2*inset);