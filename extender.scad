thumbAngularWidth = 90;
otherFingerAngularWidth = 40;
thumbDistanceRatio = 0.6;
outerRadius = 60;

spacing=3;
thickness=2;
innerPostHoleDepth=1.5;
outerPostHoleDepth=1;
tolerance=0.5;
postDiameter=6;

inset1 = 1.5;
inset2 = inset1 + 1.5;

bottom = false;

nudge = 0.001;

angularWidths = [thumbAngularWidth, otherFingerAngularWidth, otherFingerAngularWidth, otherFingerAngularWidth, otherFingerAngularWidth];
holeAngles = [0, 180-1.5*otherFingerAngularWidth, 180-.5*otherFingerAngularWidth, 180+.5*otherFingerAngularWidth, 180+1.5*otherFingerAngularWidth];
radii = outerRadius*[thumbDistanceRatio, 1, 1, 1, 1];

poly = [for (ii = [0:9]) let(i=floor(ii/2),sign=ii%2*2-1) radii[i] * [cos(holeAngles[i]+sign*angularWidths[i]/2), sin(holeAngles[i]+sign*angularWidths[i]/2)]];
    
function norm2D(v) = sqrt(pow(v[0],2)+pow(v[1],2));

function distance2D(a,b) = norm2D(a-b);
    
module base() {
    render(convexity=6)
    difference() {
        polygon(points=poly);
        for (i = [0:4]) {
            a=poly[i*2];
            b=poly[i*2+1];
            translate(.5*(a+b))
                rotate(holeAngles[i])
                scale([1.4,1.]) circle(d=0.6*distance2D(a,b));
        }
    }
}

module posts(inset,tolerance=0,thumbTweak=0) {
    for(i=[0:9]) {
        r = norm2D(poly[i]);
        r1 = r - inset;
        rotate = i==0 ? -thumbTweak : (i==1 ? thumbTweak : 0);
        rotate(rotate) translate(poly[i]/r*r1) circle(d=postDiameter+tolerance*2,$fn=16);
    }
}

render(convexity=10)
if (bottom) {
    linear_extrude(height=thickness) base();
    linear_extrude(height=thickness+spacing+outerPostHoleDepth) posts(postDiameter*inset1,thumbTweak=8);
    linear_extrude(height=thickness+spacing+innerPostHoleDepth) posts(postDiameter*inset2,thumbTweak=28);
    linear_extrude(height=thickness+spacing+innerPostHoleDepth) translate([-outerRadius*.35/2,0,0]) circle(d=outerRadius*0.35);
}
else {
    scale([-1,-1,-1]) {
        difference() {
            linear_extrude(height=thickness) base();
            translate([0,0,-nudge]) {
                linear_extrude(height=outerPostHoleDepth+nudge) posts(postDiameter*inset1,thumbTweak=8,tolerance=tolerance);
                linear_extrude(height=innerPostHoleDepth+nudge) posts(postDiameter*inset2,thumbTweak=28,tolerance=tolerance);
                linear_extrude(height=innerPostHoleDepth+nudge) translate([-outerRadius*.35/2,0,0]) circle(d=outerRadius*0.35+tolerance*2);
            }
        }
    }
}