use <tubeMesh.scad>;

//<params>
mode = 0; //[0:rectangular,1:round,2:tulip]

includeVisualizers = 0; // [0:no,1:yes]

sensorWidth = 36;
sensorHeight = 24;
// allow sensor and/or hood to be shifted over by this distance
sensorTolerance = 1.5;
focalLength = 50;
focalRatio = 1.8;
// how far down the hood extends above the top of lens housing
hoodLength = 26;
// how far down the hood extends below the top of lens housing
neck = 7;

// diameter of top of lens housing
outerLensDiameter = 59.75;
// how far is glass inset from top of lens housing (i.e., top of neck)
glassInset = 13; 

bump = 0.75;

wallThickness = 2;
fitTolerance = 0.28; 

angleStep = 3;
straightLength = 5;
topMarkerDiameter = 3;
topMarkerDepth = 1;

//</params>

module dummy() {}

circularModeRadius = mode == 0 ? 0 :
                       mode == 1 ? hypot(sensorWidth,sensorHeight) /2 :
                                   min(sensorWidth,sensorHeight) /2;

glassDiameter = focalLength/focalRatio;
offsetFromGlass = hoodLength + glassInset;
outerLensDiameter1 = outerLensDiameter+2*fitTolerance;

function hypot(x,y) = sqrt(x*x+y*y);

function cx(z=offsetFromGlass,tol=sensorTolerance) = (sensorWidth / 2 + tol) * z / focalLength;    
function right(z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) = cx(z,tol) + ap / 2;
function cy(z=offsetFromGlass,tol=sensorTolerance) = (sensorHeight / 2 + tol) * z / focalLength;
function top(z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) = cy(z,tol) + ap/ 2;

function startCircle(z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) = atan2(cy(z,tol), right(z,tol,ap));
function endCircle(z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) = atan2(top(z,tol,ap), cx(z,tol));

// distance to origin from intersection of line through (0,0) and (a,b) with circle of radius r at x,y  
// calculated by Mathematica
function circleIntersect(a,b,x,y,r) =
   (2*a*x + 2*b*y + sqrt(pow(-2*a*x - 2*b*y,2) - 
       4*(a*a + b*b)*
        (x*x + y*y - r*r)))/
   (2*(a*a + b*b));     
   
function hoodRadiusCircular(z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) =
    ap/2+(circularModeRadius+ tol) * z / focalLength;

function hoodRadiusAtAngleQuadI(angle,z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter) = 
    angle <= startCircle(z,tol,ap) ? hypot(right(z,tol), right(z,tol,ap)*tan(angle)) :
    angle >= endCircle(z,tol,ap) ? hypot(top(z,tol), top(z,tol,ap)/tan(angle)) :
       circleIntersect(cos(angle),sin(angle),cx(z,tol),cy(z,tol),ap/2);

function hoodRadiusAtAngle(angle,z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter,actual=false) =
    (!actual && mode!=0) ? hoodRadiusCircular(z,tol,ap) :
    angle <= 90 ? hoodRadiusAtAngleQuadI(angle,z,tol,ap) :
    angle <= 180 ? hoodRadiusAtAngleQuadI(180-angle,z,tol,ap) :
    angle <= 270 ? hoodRadiusAtAngleQuadI(angle-180,z,tol,ap) :
    hoodRadiusAtAngleQuadI(360-angle,z,tol,ap);
    
function hoodProfile(extra=0,z=offsetFromGlass,tol=sensorTolerance,ap=glassDiameter,actual=false)=
    [for (angle=[0:angleStep:360-.000001]) (hoodRadiusAtAngle(angle,z,tol,ap,actual=actual)+extra)*[cos(angle),sin(angle)]];
        
function base(z,extra=0) = sectionZ(ngonPoints(n=floor(360/angleStep),r=(outerLensDiameter1/2)+extra),z);
function end(z,extra=0) = sectionZ(hoodProfile(extra=extra),z);

topZ = offsetFromGlass-glassInset;
glassZ = -glassInset;

module topMark() {
    translate([0,top()+wallThickness-topMarkerDepth,topZ-straightLength/2]) rotate([-90,0,0]) cylinder(d=topMarkerDiameter,h=wallThickness+topMarkerDepth,$fn=16);
}

function sections(outside=true) = 
    let(extra=outside?wallThickness:0)
    [ 
      base((outside?0:-1)-neck,extra),
      base(0,extra),
      base(bump,extra+(outside?0:-bump)),
      base(bump+0.25,extra+(outside?0:-bump)),
      base(2*bump+0.25,extra),
      end(topZ-straightLength,extra),
      end(topZ+(outside?0:.001),extra)
    ];
    
module imageCone(tolerant=false) {
    bot = sectionZ(hoodProfile(extra=0,z=0,tol=tolerant?sensorTolerance:0,ap=focalLength/focalRatio,actual=true),glassZ);
    top = sectionZ(hoodProfile(extra=0,z=offsetFromGlass+10,tol=tolerant?sensorTolerance:0,ap=focalLength/focalRatio,actual=true),topZ+10);
    tubeMesh([bot,top]);
}
    
    
module main() {        
    difference() {
        tubeMesh(sections(true));
        tubeMesh(sections(false));
        topMark();
        if (mode != 1) rotate([0,0,180]) topMark();
        if (mode != 0)
           imageCone(tolerant=true);
    }
}

translate([0,0,neck]) {
    main();
    if (includeVisualizers) {
        %imageCone(tolerant=false);
    }
}