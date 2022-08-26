use <bezier.scad>;
use <ribbon.scad>;
use <pointHull.scad>;

width = 124;
depth = 66;
thickness = 1.75;
height = 8;
centerNub=0.5;

path = [[-width/2,0],POLAR(depth/2,75),POLAR(depth/3,180),[0,depth],REPEAT_MIRRORED([1,0])];

intersection() {
    ribbon(Bezier(path,precision=0.1)) cylinder(d=thickness,h=height,$fn=8);
    p1 = [[-width/2-thickness,height/3-thickness/2,0],[-width/2-thickness,-thickness/2,height/3],[-width/2-thickness,-thickness/2,2/3*height],[-width/2-thickness,height/3-thickness/2,height],[-width/2-thickness,depth+thickness,0],[-width/2-thickness,depth+thickness,height]];    
    p = concat(p1,[for (p=p1) [-p[0],p[1],p[2]]]);
        echo(p);
    pointHull(p);
}

translate([0,depth+thickness/2,0]) cylinder(r=centerNub,h=height/3);
//BezierVisualize(Bezier(path));