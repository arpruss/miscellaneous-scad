use <tubemesh.scad>;
use <eval.scad>;

//<params>
// The bottom and top shape are given as polar graphs; the "angle" variable varies from 0 to 360 and the "theta" variable varies from 0 to 2*PI; lowercase trigonometric functions (e.g., cos()) are in degrees; all-caps trigonometric functions (e.g., COS()) are in radians.
topShape = "30*(1+0.4*cos(6*angle))";
bottomShape = "20*(1+0.4*abs(cos(6*angle)))";
// This function scales the diameter as t varies from 0 (bottom) to 1 (top). Set to 1 for constant diameter.
diameterAdjust = "1.5+0.3*sin(t*450)";
twist = 90;
pointsPerLayer = 90;
numberOfLayers = 30;
height = 170;
bottomThickness = 2;
wallThickness = 1.5;
// If you have sharper overhangs, the default 2D-based wall calculation will generate walls that are too thin. Turning on this parameter will greatly increase generation time, but may help.
slowWalls = 0; // [0:no, 1:yes]
mode = 0; // [0:walls, 1:solid shape (fast), 2:inside-only]
//</params>

/* Some things to try:
topShape = "30*(2+(((abs(cos(angle*3)))+(0.25-(abs(cos(angle*3+90))))*2)/(2+abs(cos(angle*6+90))*8)))"; // lotus cup; works with slowWalls or 150 points per layer */

module dummy() {}

diameterAdjust1 = diameterAdjust == "" ? "1" : diameterAdjust;

sectionFunction = compileFunction(str( "((", bottomShape, ")*(1-t)+(", topShape, ")*t)*(", diameterAdjust1, ")" ));
bottom = compileFunction(bottomShape);
top = compileFunction(topShape);

function polarEval(rf,angle,t) =
    eval(rf,[["angle",angle], ["theta", angle*PI/180], ["t",t]]) * [cos(angle),sin(angle)];

function polarSection(rf,t) =
    [for(i=[0:pointsPerLayer-1]) polarEval(rf,i*360/pointsPerLayer,t)];

function mod(a,b) = let(c=a%b) c<0 ? c+b : c;
        
function innerSection(rf,t) =
    let(delta = 0.5*360/pointsPerLayer)
    [for(i=[0:pointsPerLayer-1]) 
        let(angle = i*360/pointsPerLayer,
            v = polarEval(rf,mod(angle+delta,360),t)-polarEval(rf,mod(angle-delta,360),t),
            v1 = v/norm(v)) 
            polarEval(rf,angle,t) + wallThickness*[-v1[1],v1[0]]];
    
function rotate(p,angle) =
    [ p[0]*cos(angle)-p[1]*sin(angle),p[0]*sin(angle)+p[1]*cos(angle) ];
            
bottomPoints = polarSection(bottom);
topPoints = polarSection(top);    
    
function getMaxR(points) =
    max([for(p=points) norm(p)]);

daf = compileFunction(diameterAdjust1);
maxR = max(getMaxR(bottomPoints,topPoints))*max([for (i=[0:numberOfLayers]) eval(daf,[["t",i/numberOfLayers]])]);
   
module cup(inner=false,extendedTop=0) {
    sections = [
        for (i=[0:numberOfLayers])
           let(t=i/numberOfLayers,
               h=t*height,
               section=inner?innerSection(sectionFunction,t):polarSection(sectionFunction,t))
            [for(p=section) 
                let(p1=rotate(p,twist*t))
                [p1[0],p1[1],h]]];
    extSections = extendedTop>0 ? concat(sections,[[
            for(p=sections[numberOfLayers]) [p[0],p[1],height+extendedTop]]]) : sections;
    data = pointsAndFaces(extSections);
    polyhedron(points=data[0],faces=data[1]);
}

function spherePoints(n) = 
      n==8 ? 
      [for(x=[-1:2:1]) for(y=[-1:2:1]) for(z=[-1:2:1]) [x,y,z]*sqrt(1/3)]
      :
      let(GA = 2.39996322972865332 * 180 / PI)
      [for(i=[0:n-1])
      let(t = i/(n-1),
          z = (-1+1/n)*t + (1-1/n)*(1-t),
          r=sqrt(1-z*z),
          angle = GA*i)
      [r*cos(angle),r*sin(angle),z]];

module innerize(quality=8) {    
    radius = wallThickness;
    n = quality;
    points = spherePoints(quality);
    
    intersection() {
        intersection_for(p=points)
            translate(p) children();
    }
}

module hollowCup() {
    render(convexity=6)
    difference() {
        cup();
        intersection() {
            cup(inner=true,extendedTop=1);
            translate([0,0,bottomThickness]) cylinder(r=2*maxR+1,h=height);
        }
    }
}

module hollowCup2(quality=8) {
    render(convexity=6)
    difference() {
        cup();
        difference() {
            innerize(quality=quality) cup(extendedTop=wallThickness+1);
            cylinder(r=2*maxR+1,h=bottomThickness);
        }
    }
}

if (mode==0) {
    if (slowWalls) 
        hollowCup2(quality=8);
    else
        hollowCup();
}
else if (mode==1) {
    cup();
}
else if (mode==2) {
    if (slowWalls) 
        innerize(quality=8) cup(extendedTop=wallThickness+1);
    else
        cup(inner=true);
}
else {
    %cup();
    cup(inner=true,extendedTop=1);
}