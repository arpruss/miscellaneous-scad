numberOfHooks = 5;
height = 30;
hookWidth = 11;
thickness = 2;
hookLength = 22;
hookAngle = 75;
supportRatio = 0.6;
nailHoleDiameter = 2.2;
nailHoleAngle = 70;
numberOfHooks = 5;
spacing = 35;

module dummy() {}

$fn = 12;

nudge = 0.01;

points = [for (i=[0:numberOfHooks-1]) [spacing*0.5+spacing*i,height/2]];

module base(h=thickness) 
{
    linear_extrude(height=h)
    offset(r=hookWidth/2)
    square([spacing*numberOfHooks,height]);
}

module hook()
{
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
    }
}

module hooks() {
    render(convexity=2)
    intersection() {
        union() {
            for (i=[0:numberOfHooks-1]) translate(points[i]) hook();
        }
        base(h=hookLength+hookWidth);
    }
}

module nailHole() {
    rotate([nailHoleAngle-90,0,0])
    translate([0,0,-thickness*5]) cylinder(h=thickness*10,d=nailHoleDiameter);
}

hooks();
render(convexity=4)
difference() {
    base();
    translate([0,0]) nailHole();
    translate([spacing*numberOfHooks,0]) nailHole();
    translate([spacing*numberOfHooks,height]) nailHole();
    translate([0,height]) nailHole();
}
