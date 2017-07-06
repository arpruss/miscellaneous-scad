use <tubemesh.scad>;
use <eval.scad>;

//<params>
// The bottom and top shape are given as polar graphs; the "angle" variable varies from 0 to 360 and the "theta" variable varies from 0 to 2*PI; lowercase trigonometric functions (e.g., cos()) are in degrees; all-caps trigonometric functions (e.g., COS()) are in radians.
topShape = "50*(1+0.4*cos(3*angle))";
bottomShape = "50*(1+0.4*cos(6*angle))";
// This function scales the diameter as t varies from 0 (bottom) to 1 (top). Set to 1 for constant diameter.
diameterAdjust = "1.5+0.15*sin(t*450)";
twist = 45;
pointsPerLayer = 80;
numberOfLayers = 30;
height = 150;
bottomThickness = 2;
wallThickness = 1;
//</params>

module dummy() {}

diameterAdjust1 = diameterAdjust == "" ? "1" : diameterAdjust;

sectionFunction = compileFunction(str( "((", bottomShape, ")*(1-t)+(", topShape, ")*t)*(", diameterAdjust1, ")" ));
bottom = compileFunction(bottomShape);
top = compileFunction(topShape);

function polarEval(rf,angle,t) =
    eval(rf,[["angle",angle], ["theta", angle*PI/180], ["t",t]]) * [cos(angle),sin(angle)];

function polarSection(rf,t) =
    [for(i=[0:pointsPerLayer-1]) polarEval(rf,i*360/pointsPerLayer,t)];

function mod(a,b) = let(c=a%b) c<0 ? a+b : c;
        
function innerSection(rf,t) =
    [for(i=[0:pointsPerLayer-1]) 
        let(angle = i*360/pointsPerLayer,
            v = polarEval(rf,mod(angle+0.1,360),t)-polarEval(rf,mod(angle-0.1,360),t),
            v1 = v/norm(v)) 
            polarEval(rf,angle,t) + wallThickness*[-v1[1],v1[0]]];

function rotate(p,angle) =
    [ p[0]*cos(angle)-p[1]*sin(angle),p[0]*sin(angle)+p[1]*cos(angle) ];
            
bottomPoints = polarSection(bottom);
topPoints = polarSection(top);    
    
function getMaxR(points) =
    max([for(p=points) norm(p)]);

maxR = max(getMaxR(bottomPoints,topPoints));
   
module cup(inner=false) {
    sections = [
        for (i=[0:numberOfLayers])
           let(t=i/numberOfLayers,
               h=t*height,
               section=inner?innerSection(sectionFunction,t):polarSection(sectionFunction,t))
            [for(p=section) 
                let(p1=rotate(p,twist*t))
                [p1[0],p1[1],h]]];
    data = pointsAndFaces(sections);
    polyhedron(points=data[0],faces=data[1]);
}

module hollowCup() {
    render(convexity=6)
    intersection() {
        cylinder(r=2*maxR+1,h=height-0.001);
        difference() {
            cup();
            intersection() {
                cup(inner=true);
                translate([0,0,bottomThickness]) cylinder(r=2*maxR+1,h=height);
            }
        }
    }
}

hollowCup();