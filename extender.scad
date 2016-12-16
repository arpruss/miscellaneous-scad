scale = 1;
thumbAngularWidth = 90;
otherFingerAngularWidth = 40;
thumbDistanceRatio = 0.6;
outerRadius = scale*50;

spacing=3;
thickness=2;
centralPostHoleDepth=1.5;
innerPostHoleDepth=2.1;
outerPostHoleDepth=1.5;
tolerance=0.5;
postDiameter=scale*5;

includeTop = true;
includeBottom = true;

inset1 = 1.5;
inset2 = inset1 + 1.5;

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

module bottom() {
    linear_extrude(height=thickness) base();
    linear_extrude(height=thickness+spacing+outerPostHoleDepth) posts(postDiameter*inset1,thumbTweak=8);
    linear_extrude(height=thickness+spacing+innerPostHoleDepth) posts(postDiameter*inset2,thumbTweak=28);
    linear_extrude(height=thickness+spacing+centralPostHoleDepth) translate([-outerRadius*.4/2,0,0]) circle(d=outerRadius*0.4); 
}

module top() {
    translate([0,0,thickness])
    rotate([180,0,0])
    mirror([1,0,0]) 
    {
        difference() {
            linear_extrude(height=thickness) base();
            translate([0,0,-nudge]) {
                linear_extrude(height=outerPostHoleDepth+nudge) posts(postDiameter*inset1,thumbTweak=8,tolerance=tolerance);
                linear_extrude(height=innerPostHoleDepth+nudge) posts(postDiameter*inset2,thumbTweak=28,tolerance=tolerance);
                linear_extrude(height=centralPostHoleDepth+nudge) translate([-outerRadius*.4/2,0,0]) circle(d=outerRadius*0.4+tolerance*2);
            }
        }
    }
}

if (includeTop) {
    render(convexity=5)
    top();
}

if (includeBottom) {
    render(convexity=5)
    translate([includeTop ? -outerRadius : 0,0,0])
    bottom();
}
