in = 25.4;
diameter = 4.0 * in;
totalTailLength = 16 * in;
insertLength = 1.5 * in;
strapWidth = 1 * in;
strapThickness = 4;
bottomWall = 2;
topWall = 2;
base = 1.25;

$fn = 64;
nudge = 0.01;
function d(h) = (1-h / totalTailLength) * diameter;

d2 = d(insertLength);

difference() {
    cylinder(d1=diameter,d2=d2,h=insertLength);
    translate([0,0,base])
    cylinder(d1=d(base)-2*bottomWall,d2=d(insertLength)-2*topWall,h=insertLength-base+nudge);
    translate([-diameter,-strapWidth/2,base])
    cube([2*diameter,strapWidth,strapThickness]);
}

intersection() {
    cylinder(d1=diameter,d2=d2,insertLength);
    for (angle=[45:90:360]) rotate([0,0,angle]) {
        hull() {
            translate([0.85*diameter/2,0,0]) sphere(5);
            translate([diameter/2,0,0]) sphere(5);
            translate([d2/2,0,insertLength]) sphere(5);
        }
    }
}