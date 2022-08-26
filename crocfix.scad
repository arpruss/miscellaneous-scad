diameter = 23.73;
strapLength = 8;
strapWidth = 18.4;
depth = 5.5;
wall = 1.5;

$fn = 64;

module shape(offset=0) {
    w = strapWidth + 2*offset;
    translate([-strapLength-diameter/2-(offset>0?-.001:0),-w/2]) square([strapLength+diameter/2,w]);
    circle(d=diameter+2*offset);
}

linear_extrude(height=wall) shape(wall);
linear_extrude(height=wall+depth) difference() {
    shape(wall);
    shape();
}