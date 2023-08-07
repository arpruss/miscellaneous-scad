use <tubeMesh.scad>;
use <Bezier.scad>;

//<params>
includeVisualizers = 0; // [0:no,1:yes]

includeFilterHolder = 1; // [0:no,1:yes]

filterHolderZ = 3.9;

filmWidth = 56;
filmHeight = 56;
filmTolerance = 1;
focalLength = 80;
focalRatio = 3.5;
// replace with focalLength/focalRatio for a slightly narrower hood
glassDiameter = 23.2;
offsetFromGlass = 30;
angleStep = 3;
straightLength = 5;
topMarkerDiameter = 3;
topMarkerDepth = 1;

wallThickness = 2;
mediumWallThickness = 1.75;
bottomWallThickness = 0.95;
thickerBehindTab = 0.5;

radialTolerance = 0; 
tabRadialSize = 0.7;
tabLength = 11.75;
tabThickness = 0.9;
tabLowering = 1.5;
tabAngles = [90,210,-30];
distanceBehindTab = 2.25;
flangeRadialSize = 1.2;
flangeOverhangAngle = 50;
flangeTolerance = -.2;
flangeThickness = 1.5;
glassInset = 6.4;
bumpExtra = .1;
outerLensDiameter = 37.7;
filterHolderWall = 2;
filterThreadedOD = 36.7;
filterThreadedHeight = 1.6;
filterHolderUnthreadedHeight = 2;
filterUnthreadedOD = 39;
filterID = 32;
filterThreadedTolerance = 0.18;
filterUnthreadedTolerance = 0.2;
filterHolderChamfer = 0.5;
filterHolderExtraHeight = -.5;
//</params>

module dummy() {}

module filterHolder() {
    translate([0,0,-filterHolderExtraHeight])
    rotate_extrude($fn=96) {
        polygon([
            [filterUnthreadedOD/2+filterHolderWall,0],
            [filterUnthreadedOD/2+filterHolderWall,filterThreadedHeight+filterHolderUnthreadedHeight+filterHolderExtraHeight],
            [filterUnthreadedOD/2,filterThreadedHeight+filterHolderUnthreadedHeight++filterHolderExtraHeight],
            [filterUnthreadedOD/2+filterUnthreadedTolerance,filterThreadedHeight++filterHolderExtraHeight],
            [filterThreadedOD/2+filterThreadedTolerance+filterHolderChamfer,filterThreadedHeight+filterHolderExtraHeight],
            [filterThreadedOD/2+filterThreadedTolerance,filterThreadedHeight-filterHolderChamfer+filterHolderExtraHeight],
        [filterThreadedOD/2+filterThreadedTolerance,0],
        
        ]);
    }
}

module filterModel(tolerant=0) {
    linear_extrude(height=filterThreadedHeight+filterHolderUnthreadedHeight) {
        difference() {
            circle(d=filterUnthreadedOD+(tolerant?filterUnthreadedTolerance*2:0),$fn=64);
            circle(d=filterID+(tolerant?filterThreadedTolerance*2:0),$fn=64);
        }
    }
}

outerLensDiameter1 = outerLensDiameter+2*bumpExtra;
tabRadialSize1 = tabRadialSize + bumpExtra;
flangeRadialSize1 = flangeRadialSize + bumpExtra;

tabAngularSize = atan2(tabLength/2,outerLensDiameter/2)*2;

function hypot(x,y) = sqrt(x*x+y*y);

function cx(z=offsetFromGlass,tol=filmTolerance) = (filmWidth / 2 + tol) * z / focalLength;    
function right(z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = cx(z,tol) + ap / 2;
function cy(z=offsetFromGlass,tol=filmTolerance) = (filmHeight / 2 + tol) * z / focalLength;
function top(z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = cy(z,tol) + ap/ 2;

function startCircle(z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = atan2(cy(z,tol), right(z,tol,ap));
function endCircle(z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = atan2(top(z,tol,ap), cx(z,tol));

// distance to origin from intersection of line through (0,0) and (a,b) with circle of radius r at x,y  
// calculated by Mathematica
function circleIntersect(a,b,x,y,r) =
   (2*a*x + 2*b*y + sqrt(pow(-2*a*x - 2*b*y,2) - 
       4*(a*a + b*b)*
        (x*x + y*y - r*r)))/
   (2*(a*a + b*b));     

function hoodRadiusAtAngleQuadI(angle,z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = 
    angle <= startCircle(z,tol,ap) ? hypot(right(z,tol), right(z,tol,ap)*tan(angle)) :
    angle >= endCircle(z,tol,ap) ? hypot(top(z,tol), top(z,tol,ap)/tan(angle)) :
       circleIntersect(cos(angle),sin(angle),cx(z,tol),cy(z,tol),ap/2);

function hoodRadiusAtAngle(angle,z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter) = 
    angle <= 90 ? hoodRadiusAtAngleQuadI(angle,z,tol,ap) :
    angle <= 180 ? hoodRadiusAtAngleQuadI(180-angle,z,tol,ap) :
    angle <= 270 ? hoodRadiusAtAngleQuadI(angle-180,z,tol,ap) :
    hoodRadiusAtAngleQuadI(360-angle,z,tol,ap);
    
function hoodProfile(extra=0,z=offsetFromGlass,tol=filmTolerance,ap=glassDiameter)=
    [for (angle=[0:angleStep:360-.000001]) (hoodRadiusAtAngle(angle,z,tol,ap)+extra)*[cos(angle),sin(angle)]];
        
function base(z,extra=0) = sectionZ(ngonPoints(n=floor(360/angleStep),r=(outerLensDiameter1/2+radialTolerance+tabRadialSize1)+extra),z);
function end(z,extra=0) = sectionZ(hoodProfile(extra=extra),z);

flangeDistance = distanceBehindTab + tabThickness + flangeTolerance;
flangeSlopeHeight = flangeRadialSize1 / tan(flangeOverhangAngle);
topZ = offsetFromGlass+distanceBehindTab+tabThickness-glassInset;
glassZ = topZ - offsetFromGlass;

function sections(inside=false) = 
    let(extra=inside?0:wallThickness)
    [ 
      base(inside?-1:0,extra-(inside?0:(wallThickness-bottomWallThickness))), 
      base(distanceBehindTab-0.5,extra-(inside?0:(wallThickness-bottomWallThickness))), 
      base(distanceBehindTab,extra-(inside?0:(wallThickness-mediumWallThickness))), 
      base(flangeDistance,extra),
      base(flangeDistance+flangeSlopeHeight,extra+(inside?-flangeRadialSize1:0)),
      base(flangeDistance+flangeSlopeHeight+flangeThickness,extra+(inside?-flangeRadialSize1:0)),
      base(flangeDistance+flangeSlopeHeight+flangeThickness+.01,extra),
      end(offsetFromGlass+distanceBehindTab+tabThickness-glassInset-straightLength,extra),
    
      end(topZ+(inside?1:0),extra)
    ];
    
module cylindricalBump(topProfile,r1,r2) {
    sections = [for (theta_z=topProfile) 
        let(theta = theta_z[0], z = theta_z[1]) 
            [ [r1*cos(theta),r1*sin(theta),0],
              [r2*cos(theta),r2*sin(theta),0],
              [r2*cos(theta),r2*sin(theta),z],
              [r1*cos(theta),r1*sin(theta),z] ]
    ];
    tubeMesh(sections);
}

module bump(startAngle=0,endAngle=45,endHeight=2,topHeight=10,r1=15,r2=17) {
    midAngle = (startAngle+endAngle)/2;
    cylindricalBump(Bezier([[startAngle,endHeight],POLAR(10,0),POLAR(18,180),[midAngle,topHeight],SYMMETRIC(),POLAR(10,180),[endAngle,endHeight]]),r1,r2);
}

module bumps() {
    for (angle = tabAngles) {
        rotate([0,0,angle])
            bump(startAngle=-tabAngularSize/2,endAngle=tabAngularSize/2,endHeight=distanceBehindTab-tabLowering,topHeight=distanceBehindTab,r1=outerLensDiameter1/2+radialTolerance,r2=outerLensDiameter1/2+radialTolerance+tabRadialSize1+bottomWallThickness/2);
    }
}

module imageCone() {
    bot = sectionZ(hoodProfile(extra=0,z=0,tol=0,ap=focalLength/focalRatio),glassZ);
    top = sectionZ(hoodProfile(extra=0,z=offsetFromGlass,tol=0,ap=focalLength/focalRatio),topZ);
    tubeMesh([bot,top]);
}

module topMark() {
    translate([0,top()+wallThickness-topMarkerDepth,topZ-straightLength/2]) rotate([-90,0,0]) cylinder(d=topMarkerDiameter,h=wallThickness+topMarkerDepth,$fn=16);
}

module main() {        
    bumps();
    difference() {
        tubeMesh(sections(false));
        tubeMesh(sections(true));
        topMark();
        translate([0,0,filterHolderZ]) filterModel(tolerant=true);
    }
    color("blue") if (includeFilterHolder) {
        intersection() {
            tubeMesh(sections(false));
            translate([0,0,filterHolderZ]) filterHolder();
        }
    }
}


main();
if (includeVisualizers) {
    %imageCone();
    if (includeFilterHolder) translate([0,0,filterHolderZ]) color("red") filterModel();
}