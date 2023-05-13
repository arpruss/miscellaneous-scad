use <tubeMesh.scad>;
use <Bezier.scad>;

//<params>
filmWidth = 56;
filmHeight = 56;
filmTolerance = 1;
focalLength = 80;
glassDiameter = 23.2;
offsetFromGlass = 30;
angleStep = 2;
straightLength = 5;

wallThickness = 2;
mediumWallThickness = 1.75;
bottomWallThickness = 0.95;
thickerBehindTab = 0.5;

radialTolerance = 0; 
tabRadialSize = 0.7;
tabLength = 11.75;
tabThickness = 0.9;
tabTolerance = 0.1;
tabLowering = 1.5;
tabAngles = [90,210,-30];
distanceBehindTab = 2.25;
flangeRadialSize = 1.75;
flangeOverhangAngle = 50;
flangeTolerance = -.1;
flangeThickness = 1.5;
glassInset = 6.4;
bumpExtra = 0.3;
outerLensDiameter = 37.7;
//</params>

module dummy() {}

outerLensDiameter1 = outerLensDiameter+2*bumpExtra;
tabRadialSize1 = tabRadialSize + bumpExtra;
flangeRadialSize1 = flangeRadialSize + bumpExtra;

tabAngularSize = atan2(tabLength/2,outerLensDiameter/2)*2;

w = filmWidth + 2 * filmTolerance;
h = filmHeight + 2 * filmTolerance;

cornerAngle = atan2(h, w);

function hypot(x,y) = sqrt(x*x+y*y);

function filmRadiusAtAngle0(angle) = 
    (angle >= 360-cornerAngle || angle < cornerAngle) ? 
        hypot(w/2, w/2*tan(angle)) :    
        hypot(h/2 / tan(angle), h/2);
       
function filmRadiusAtAngle(angle) =
    angle >= 360-cornerAngle || angle < 180-cornerAngle ? filmRadiusAtAngle0(angle) : filmRadiusAtAngle0(angle < 180 ? angle + 180 : angle - 180);
    
function hoodRadiusAtAngle(angle) =    
    glassDiameter / 2 + offsetFromGlass * filmRadiusAtAngle(angle) / focalLength;
    
function hoodProfile(extra=0)=
    [for (angle=[0:angleStep:360-.000001]) (hoodRadiusAtAngle(angle)+extra)*[cos(angle),sin(angle)]];
        
function base(z,extra=0) = sectionZ(ngonPoints(n=floor(360/angleStep),r=(outerLensDiameter1/2+radialTolerance+tabRadialSize1)+extra),z);
function end(z,extra=0) = sectionZ(hoodProfile(extra=extra),z);

flangeDistance = distanceBehindTab + tabThickness + flangeTolerance;
flangeSlopeHeight = flangeRadialSize1 / tan(flangeOverhangAngle);

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
    
      end(offsetFromGlass+distanceBehindTab+tabThickness-glassInset+(inside?1:0),extra)
    ];
    
module cylindricalBump(topProfile,r1,r2) {
    echo(r1,r2);
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

module main() {        
    bumps();
    difference() {
        tubeMesh(sections(false));
        tubeMesh(sections(true));
    }
}

main();