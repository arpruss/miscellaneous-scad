use <tubemesh.scad>;
use <bezier.scad>;

//<params>
rounding = .05;
diameter = 4;
height = 15;
twists = 1;
lobes = 4;
lobeHeight = 2;
precision = 0.025;
//</params>

module dummy() {}

r = diameter/2;

function base(twistAngle) = [ for(i=[0:5:360]) (r+lobeHeight*abs(cos((i)*lobes/2)))*[cos(i-twistAngle),sin(i-twistAngle)]];
    
edge = [ [r,0],SHARP(),SHARP(),
         [height*rounding,height-1.5*height*rounding],SMOOTH_ABS(.25*rounding*height),OFFSET([height*rounding,0]),
        [0,height] ];

profile = Bezier(edge,precision=precision,optimize=false);
sections = [for(p=profile) sectionZ(p[0]/r*base(p[1]/height*360*twists),p[1])];
//echo(profile);
//BezierVisualize(edge,nodeSize=0.4);    
tubeMesh(sections);