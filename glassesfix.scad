use <roundedsquare.scad>;

tolerance = 0.22;
innerWidth = 7.2+2*tolerance;
innerHeight = 8.3+2*tolerance;
length = 20;
wall = 1.75;
innerWall = 1.25;
corner = 1.5;

rotate([90,0,0])
linear_extrude(height=length)
    difference() {
        roundedSquare([innerWidth+innerWall+wall, innerHeight+wall*2],radius=corner,$fn=16);
        translate([innerWall,wall])
        roundedSquare([innerWidth, innerHeight],radius=corner/3,$fn=32);
    }
