radius = 20;
numberOfHooks = 3;
width = 11;
thickness = 3.25;
hookLength = 22;
hookAngle = 75;
supportRatio = 0.6;
nailHoleDiameter = 2.2;
nailHoleAngle = 70;

module dummy() {}

$fn = 12;

innerRadius = radius * cos(180/numberOfHooks);

nudge = 0.01;

points = [for (i=[0:numberOfHooks-1]) let(a=270+i*360/numberOfHooks) radius*[cos(a),sin(a)]];

module base() 
{
    linear_extrude(height=thickness)     
    for (i=[0:numberOfHooks-1]) {
        hull() {
            translate(points[i]) circle(d=width);
            translate(points[(i+1)%numberOfHooks]) circle(d=width);
        }
    }
}

module hook()
{
    rotate([0,0,180])
    rotate([90-hookAngle,0,0])
    translate([-width/2,0,thickness/2]) 
    rotate([0,0,180])
    rotate([0,-90,0]) {    
        hull() {
            translate([-width,-width*supportRatio,width/2])
            sphere(d=thickness);
            translate([hookLength,0,width/2]) sphere(d=thickness);
            translate([0,0,width/2]) sphere(d=thickness);
        }
        
        hull() {
            translate([0,0,thickness/2]) sphere(d=thickness);
            translate([0,0,width-thickness/2]) sphere(d=thickness);
            translate([hookLength,0,thickness/2]) sphere(d=thickness);
            translate([hookLength,0,width-thickness/2]) sphere(d=thickness);
        }
    }
}

module hooks() {
    render(convexity=2)
    intersection() {
        union() {
            for (i=[0:numberOfHooks-1]) translate(points[i]) hook();
        }
        translate([0,0,thickness-nudge])
        cylinder(r=10*radius,h=thickness+hookLength, $fn=4);
    }
}

module nailHole() {
    rotate([nailHoleAngle-90,0,0])
    translate([0,0,-thickness*5]) cylinder(h=thickness*10,d=nailHoleDiameter);
}

hooks();
render(convexity=2)
difference() {
    base();
    if (numberOfHooks % 2 == 1) {
        translate([0,innerRadius,0]) nailHole();
    }
    else {
        translate(innerRadius*[cos(90+180/numberOfHooks),sin(90+180/numberOfHooks)]) nailHole();
        translate(innerRadius*[-cos(90+180/numberOfHooks),sin(90+180/numberOfHooks)]) nailHole();
    }
}
