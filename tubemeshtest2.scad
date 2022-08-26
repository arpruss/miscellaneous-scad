use <tubemesh.scad>;
use <triangulation.scad>;

function arc(r=10,arcAngle=230,steps=64) =
        [for (i=[0:steps]) let(angle=-arcAngle/2*(steps-i)/steps+arcAngle/2*i/steps) 
            r*[cos(angle),sin(angle)]];

section = concat(arc(),_reverse(arc(r=8)));

morphExtrude(section,section,height=10,triangulateEnds=true);