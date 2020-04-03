use <tubemesh.scad>;
use <bezier.scad>;

//<params>
inchesAcrossFlats = 0.25;
tolerance = 0.25; 
handleDiameter = 18;
handleGrooveSize = 2;
handleLength = 20;
driverHoleLength = 16;
ejectionHoleDiameter = 5;
numberOfLevers = 2;
sideLeverMaximumHeight = 18;
sideLeverMinimumHeight = 14;
sideLeverMaximumThickness = 10;
sideLeverMinimumThickness = 8;
sideLeverLengthFromCenter = 40;
//</params>

module dummy() {}

hexDiameter = inchesAcrossFlats * 25.4 / cos(180/6) + 2*tolerance;

R = handleDiameter/2-handleGrooveSize/2;
r = handleGrooveSize/2;
crossSection = [for (i=[0:2.5:359]) (R+r*cos(i*6))*[cos(i),sin(i)]];

//polygon(points=crossSection);

profile = Bezier([ 
              [1,0], SHARP(), SHARP(), [1,1.5],
              OFFSET([0,0.25]), OFFSET([0.5,0]), [0,2] ]);

sections = [for(p=profile) [for(c=crossSection) [p[0]*c[0],p[0]*c[1],p[1]/2*handleLength]]];

data = pointsAndFaces(sections);

module sideLever() {
    $fn = 36;
    module end(height,thickness) {
        cylinder(d=thickness,height-thickness/2);
        translate([0,0,height-thickness/2]) sphere(d=thickness);
    }
    
    hull() {
        end(sideLeverMaximumHeight,sideLeverMaximumThickness);
        translate([sideLeverLengthFromCenter,0,0]) end(sideLeverMinimumHeight,sideLeverMinimumThickness);
    }
}

render(convexity=2)
difference() {
    union() {
        polyhedron(points=data[0], faces=data[1]);
        for (i=[0:1:numberOfLevers-1]) rotate([0,0,i*360/(numberOfLevers)])sideLever();
    }
    translate([0,0,handleLength-driverHoleLength]) cylinder(h=driverHoleLength+0.01, d=hexDiameter, $fn=6);
    if(ejectionHoleDiameter>0)
    translate([0,0,-0.01])
    cylinder(h=handleLength-driverHoleLength+0.02, d1=ejectionHoleDiameter, d2=ejectionHoleDiameter, $fn=32);
}