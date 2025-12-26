use <../roundedSquare.scad>;

//<params>

innerWidth = 14.8;
innerThickness = 6.12;
tolerance = 0.2;
length = 9;
thickness = 3.5;
//</params>

module dummy(){}

linear_extrude(height=length)
difference() {
        roundedSquare([innerWidth+2*tolerance+2*thickness,innerThickness+2*tolerance+2*thickness],center=true,radius=2);
square([innerWidth+2*tolerance,innerThickness+2*tolerance],center=true);
}
    