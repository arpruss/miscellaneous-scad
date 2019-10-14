in = 25.4;
diameter = 4.02 * in;
totalTailLength = 16 * in;
insertLength = 1.25 * in;
strapWidth = 1 * in;
strapThickness = 4;
bottomWall = 2;
topWall = 1;
base = 1.25;

$fn = 64;
nudge = 0.01;
function d(h) = (1-h / totalTailLength) * diameter;
difference() {
    cylinder(d1=diameter,d2=d(insertLength),h=insertLength);
    translate([0,0,base])
    cylinder(d1=d(base)-2*bottomWall,d2=d(insertLength)-2*topWall,h=insertLength-base+nudge);
    translate([-diameter,-strapWidth/2,base])
    cube([2*diameter,strapWidth,strapThickness]);
}