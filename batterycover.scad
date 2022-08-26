use <roundedsquare.scad>;

l = 25-1;
w = 57-1;
d = 1.8;

linear_extrude(height=d) 
    roundedSquare([l,w],radius=2.5);
    
