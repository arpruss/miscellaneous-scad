use <roundedsquare.scad>;

innerWidth = 13.7;
innerHeight = 4;
length = 7; // was 9
tolerance = 0.25;
wall = 1;

render(convexity=2)
linear_extrude(height=length)
difference() {
    roundedSquare([tolerance*2+innerWidth+2*wall,tolerance*2+innerHeight+2*wall]);
    translate([wall,wall,-1])
    roundedSquare([tolerance*2+innerWidth,tolerance*2+innerHeight]);
}
