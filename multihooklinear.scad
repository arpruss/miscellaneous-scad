numberOfHooks = 6;
height = 15;
hookWidth = 9;
thickness = 6;
baseThickness = 2;
hookLength = 38;
hookAngle = 65;
supportRatio = 0.8;
nailHoleDiameter = 2.2;
nailHoleAngle = 70;
spacing = 46;
endSpacing = 8;
tipBallDiameter = 12;
centralHoles = 1; //[1:yes, 0:no]

module dummy() {}

$fn = 12;

nudge = 0.01;

width = spacing*(numberOfHooks-1) + 2*endSpacing;

points = [for (i=[0:numberOfHooks-1]) [endSpacing+spacing*i,height/2]];
 
module base(h=baseThickness) 
{
    linear_extrude(height=h)
    offset(r=hookWidth/2)
    square([width,height]);
}

module hook()
{
    render(convexity=2)
    rotate([0,0,180])
    rotate([90-hookAngle,0,0])
    translate([-hookWidth/2,0,thickness/2]) 
    rotate([0,0,180])
    rotate([0,-90,0]) {    
        hull() {
            translate([-hookWidth,-hookWidth*supportRatio,hookWidth/2])
            sphere(d=thickness);
            translate([hookLength,0,hookWidth/2]) sphere(d=thickness);
            translate([0,0,hookWidth/2]) sphere(d=thickness);
        }
        
        hull() {
            translate([0,0,thickness/2]) sphere(d=thickness);
            translate([0,0,hookWidth-thickness/2]) sphere(d=thickness);
            translate([hookLength,0,thickness/2]) sphere(d=thickness);
            translate([hookLength,0,hookWidth-thickness/2]) sphere(d=thickness);
        }
        translate([hookLength,0,thickness*.75]) sphere(d=tipBallDiameter);
    }
}

module hooks() {
    render(convexity=2)
    intersection() {
        union() {
            for (i=[0:numberOfHooks-1]) translate(points[i]) hook();
        }
        cube([width,height+hookLength,hookLength+hookWidth]);
    }
}

module nailHole() {
    rotate([nailHoleAngle-90,0,0])
    translate([0,0,-baseThickness*5]) cylinder(h=baseThickness*10,d=nailHoleDiameter);
}

module all() {
    hooks();
    render(convexity=4)
    difference() {
        base();
        translate([0,0]) nailHole();
        translate([width,0]) nailHole();
        translate([width,height]) nailHole();
        translate([0,height]) nailHole();
        if (centralHoles) {
            if (numberOfHooks % 2 == 1) {
                translate([width/2-spacing/2,height/2]) nailHole();
                translate([width/2+spacing/2,height/2]) nailHole();
            }
            else {
                translate([width/2,height/2]) nailHole();
            }
        }
    }
}

all();