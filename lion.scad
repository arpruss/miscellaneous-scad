use <roundedsquare.scad>;

w=30;
rounded=4;
h=5;

$fn = 16;
linear_extrude(height=h) roundedSquare(w, radius=rounded);