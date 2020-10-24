use <tubemesh.scad>;

angleToGround = 68;
kickstandDiameter = 14.1;
minimumThickness = 2;
tolerance = 0.22;
length = 38;
bottomDiameter = 28;
bottomDistance = 15;
bottomRim = 3;

$fn = 60;

id = kickstandDiameter + 2*tolerance;

function translate(z,p) = [for(q=p) z+q];
    
function tiltXZ(angle,p) = [for(q=p) [cos(angle)*q[0]-sin(angle)*q[2],q[1],sin(angle)*q[0]+cos(angle)*q[2]]];

topSection0 = sectionZ(ngonPoints(n=$fn,r=(id+minimumThickness)/2),0);

z1 = [cos(angleToGround),0,sin(angleToGround)];
topSection = translate(z1*length, tiltXZ(angleToGround-90,topSection0));

sections = 
    [ sectionZ(ngonPoints(n=$fn,r=bottomDiameter/2),0),
      sectionZ(ngonPoints(n=$fn,r=bottomDiameter/2),bottomRim),
      topSection ];

difference() {
    tubeMesh(sections);
    translate(z1*bottomDistance) rotate([0,90-angleToGround,0]) cylinder(h=2*length,d=id);
}
      