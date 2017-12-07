use <tubemesh.scad>;
use <bezier.scad>;

rounding = .01;
diameter = 8;
height = 30;
twists = 1;
lobes = 4;
lobeHeight = 2;

module dummy() {}

r = diameter/2;

function base(twistAngle) = [ for(i=[0:5:360]) (r+lobeHeight*abs(cos((i)*lobes/2)))*[cos(i-twistAngle),sin(i-twistAngle)]];
    
edge = [ [r,0],SHARP(),SHARP(),
         [height*rounding,height-1.5*height*rounding],SMOOTH_ABS(1),OFFSET([height*rounding,0]),
        [0,height] ];

profile = Bezier(edge,precision=0.02,optimize=false);
sections = [for(p=profile) sectionZ(p[0]/r*base(p[1]/height*360*twists),p[1])];
//BezierVisualize(edge);    
tubeMesh(sections);