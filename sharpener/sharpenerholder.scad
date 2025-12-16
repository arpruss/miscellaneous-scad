use <roundedSquare.scad>;

//<params>
stoneWidth = 20.14;
tolerance = .23;
toleranceWidth = 0.31;
height = 16.16;
length = 17;
thickness = 2;
holeOffset = 4.5;
holeDiameter = 4.05;
//<params>

module dummy(){}

difference() {
    linear_extrude(height=length)
    difference() {
            roundedSquare([stoneWidth+2*toleranceWidth+2*thickness,height+2*tolerance+2*thickness],center=true,radius=2);
    square([stoneWidth+2*toleranceWidth,height+2*tolerance],center=true);
    }
    translate([0,0,holeOffset])
    rotate([90,0,0])
    cylinder(d=holeDiameter,$fn=16,h=100);
}