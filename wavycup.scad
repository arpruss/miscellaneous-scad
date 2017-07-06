use <tubemesh.scad>;
use <eval.scad>;

bottomShape = "10*(1+0.4*cos(3*angle))";
topShape = "20*(1+0.4*cos(6*angle))";
numberOfPoints = 60;
twist = 45;
numberOfLayers = 30;
height = 30;
bottomThickness = 2;
wallThickness = 1;

bottom = compileFunction(bottomShape);
top = compileFunction(topShape);

function polarSection(rf) =
    [for(i=[0:numberOfPoints-1])
        let(angle=i*360/numberOfPoints,
            theta=i*2*PI/numberOfPoints,
            r=eval(rf,[["angle", angle], ["theta", theta]]))
        r*[cos(angle),sin(angle)]];

bottomPoints = polarSection(bottom);
topPoints = polarSection(top);

function getMaxR(points) =
    max([for(p=points) norm(p)]);
maxR = max(getMaxR(bottomPoints,topPoints));
   
module cup() {
    morphExtrude(bottomPoints,topPoints,numSlices=numberOfLayers,twist=0,height=height,twist=45);
}

module negativeCup() {
    difference() {
        cylinder(r=maxR+1,h=height);
        cup();
    }
}

module insideCup() {
    difference() {
        cylinder(r=maxR+1,h=height);
        minkowski() {
            negativeCup();
            cylinder(d=wallThickness,h=0.001,$fn=12);
        }
    }
}

render(convexity=5)
difference() {
    cup();
    insideCup();
}
intersection() {
    cup();
    cylinder(r=maxR+1,h=bottomThickness);
}