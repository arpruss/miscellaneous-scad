use <Bezier.scad>;
use <ribbon.scad>;

d1 = 20;
d3 = 80;
depth = 30;
extraDepth = 5;
angle1 = 10;
angle2 = 8;
thickness = 2;
height = 7;

noseB=[[-d3/2, -extraDepth],POLAR(d3/4,angle2),
    POLAR(depth/2,-90-angle1),  [-d1/2,depth*.7], SMOOTH_REL(.5), POLAR(d1*.1,180),[0,depth],REPEAT_MIRRORED([1,0])];

linear_extrude(height=5) ribbon(Bezier(noseB),thickness=1);
