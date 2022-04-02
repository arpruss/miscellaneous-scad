use <Bezier.scad>;
use <ribbon.scad>;

//<params>
d1 = 24+0.5;
d3 = 78;
depth = 27-1;
extraDepth = 7.5+2;
angle1 = 10;
angle2 = 22;
thickness = 2;
height = 10;
//</params>

noseB=[[-d3/2, -extraDepth],POLAR(d3/4,angle2),
    POLAR(depth/2,-90-angle1),  [-d1*0.5,depth*.7], SMOOTH_REL(.5-.05*1), POLAR(d1*(.1+.07*1),180),[0,depth],REPEAT_MIRRORED([1,0])];
    
module rounder() {
    translate([0,-extraDepth-thickness/2,height/2])
    rotate([-90,0,0])
    linear_extrude(height=depth+extraDepth+thickness*2)
    hull() {
        translate([-d3/2+height/2,0]) circle(d=height,$fn=16);
        translate([d3/2-height/2,0]) circle(d=height,$fn=16);
    }
}

intersection() {
linear_extrude(height=height) ribbon(Bezier(noseB),thickness=thickness);
    rounder();
}
