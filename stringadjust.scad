wall = .85;
height = 7;
innerDiameter = 3.5;

$fn=64;
linear_extrude(height=height) 
difference() {
    circle(d=innerDiameter+2*wall);
    circle(d=innerDiameter);
}