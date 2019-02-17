use <tubemesh.scad>;
use <bezier.scad>;
use <eval.scad>;

inchesAcrossFlats = 0.25;
tolerance = 0.35; // 0.5 loose
handleDiameter = 18;
handleGrooveSize = 2;
handleLength = 20;
driverHoleLength = 8;
ejectionHoleLowerDiameter = 10.5;

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

render(convexity=2)
difference() {
    polyhedron(points=data[0], faces=data[1]);
    translate([0,0,handleLength-driverHoleLength]) cylinder(h=driverHoleLength+0.01, d=hexDiameter, $fn=6);
    if(ejectionHoleLowerDiameter>0)
    translate([0,0,-0.01])
    cylinder(h=handleLength-driverHoleLength+0.02, d1=ejectionHoleLowerDiameter, d2=hexDiameter*0.7, $fn=32);
}