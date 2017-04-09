height = 55;
topDiameter = 50;
bottomDiameter = 30;
holeHorizontalSpacingAtBottom = 2.5;
numberOfHolesAround = 10;
topFlange = 1.75;
wallThickness = 1.5;
numberOfHolesVertically = 16;
numberOfHolesRadially = 2;
holeVerticalSpacing = 1.5;
holeRadialSpacing = 2;
bottomHoleRadialOffset = 6;

module dummy() {}

nudge = 0.01;

pi = 3.14159265358979;

holeWidthAtBottom = bottomDiameter * pi/numberOfHolesAround - holeHorizontalSpacingAtBottom;

holeHeight = (height - holeVerticalSpacings)/2;

maxDiameter = max(topDiameter, bottomDiameter) + 2 * topFlange;

function scaleByZ(z, x) = x * topDiameter/bottomDiameter * z/height + x * (height-z) / height;

function scaleByR(r, x) = x * r / (bottomDiameter/2);

holeHeight = (height-holeVerticalSpacing*(1+numberOfHolesVertically))/numberOfHolesVertically;
holeRadialSize = (bottomDiameter/2-holeRadialSpacing*(numberOfHolesRadially)-bottomHoleRadialOffset)/numberOfHolesRadially;

module sideHole(z1) {
    x1 =  scaleByZ(z1, holeWidthAtBottom);
    z2 = z1 + holeHeight;
    x2 =  scaleByZ(z2, holeWidthAtBottom);
    rotate([0,0,270])
    translate([0,maxDiameter,0]) rotate([90,0,0])
    linear_extrude(height=maxDiameter) polygon([[-x1/2,z1],[x1/2,z1],[x2/2,z2],[-x2/2,z2]]);
}

module bottomHole(r1) {
    x1 = scaleByR(r1, holeWidthAtBottom);
    r2 = r1 + holeRadialSize;
    x2 = scaleByR(r2, holeWidthAtBottom);
    rotate([0,0,270])
    translate([0,0,-nudge]) linear_extrude(height=wallThickness+2*nudge)
    polygon([[-x1/2,r1],[x1/2,r1],[x2/2,r2],[-x2/2,r2]]);
}

render(convexity=2)
difference() {
    union() {
        rotate([0,0,180/numberOfHolesAround])
        cylinder(d1=bottomDiameter,d2=topDiameter,h=height, $fn=numberOfHolesAround);
        translate([0,0,height-(topDiameter/2+topFlange)]) cylinder(d2=topDiameter+topFlange*2,d1=0,h=topDiameter/2+topFlange);
    }
    rotate([0,0,180/numberOfHolesAround])translate([0,0,wallThickness])
    cylinder(d1=scaleByZ(wallThickness,bottomDiameter)-2*wallThickness,d2=scaleByZ(height-wallThickness,bottomDiameter)-2*wallThickness,h=height-wallThickness, $fn=numberOfHolesAround);
    for(i=[0:numberOfHolesAround-1]) {
        rotate([0,0,360/numberOfHolesAround * i]) {
            for(j=[0:numberOfHolesVertically-1]) {
                sideHole(holeVerticalSpacing+j*(holeVerticalSpacing+holeHeight));
            }
            for(j=[0:numberOfHolesRadially-1]) {
                bottomHole(bottomHoleRadialOffset+j*(holeRadialSpacing+holeRadialSize));
            }
        }
    }
}
