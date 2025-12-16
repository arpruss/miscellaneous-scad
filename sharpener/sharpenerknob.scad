use <../Bezier.scad>; 

//<params>
holeDiameter = 16;
holeHeight = 5.5;
tolerance = 0.35;
thickness = 10;
holeBumpInset = 0.5;
holeBumps = 40;
punchHole = 6;
outerDiameter = 27;
minimumThickness = 2;
wingtipSize = 5;
wings = 5;
bezierTensionInside = 0.15;
bezierTensionFromOutside = 0.35;
chamfer = 1;
//</params>

module dummy(){}

angle = 360/wings;
function trimVector(path,n) =
    n <= 0 ? [] :
    [for(i=[0:n-1]) path[i]];
     
// trim a path to only wind once around origin    
function trimPath360(path,pos=0,crossedXAxis=false) 
    = pos >= len(path) || 
      (crossedXAxis && atan2(path[pos][1],path[pos][0]) >= 0) ? trimVector(path,pos) :
      trimPath360(path,pos=pos+1,crossedXAxis=crossedXAxis || atan2(path[pos][1],path[pos][0]) < 0);
           
function getPath(r,R,w) = ((
    [ [ R,0 ], SHARP(), SHARP(), [R, w/2-chamfer],
      SHARP(), SHARP(), [R-chamfer, w/2],
      POLAR(r*bezierTensionFromOutside,180), POLAR(r*bezierTensionInside,angle/2-90), r*[cos(angle/2),sin(angle/2)],
     REPEAT_MIRRORED([cos(90+angle/2),sin(90+angle/2)]),
     REPEAT_MIRRORED([cos(90+angle),sin(90+angle)]),
     REPEAT_MIRRORED([cos(90+2*angle),sin(90+2*angle)]),
     REPEAT_MIRRORED([cos(90+4*angle),sin(90+4*angle)]),
     ]));
    
module hole() {
    D = holeDiameter + 2 * tolerance;
    bumpDiameter = PI * D / holeBumps * 0.8;
    difference() {
        circle(d=D,$fn=128);
        for (i=[0:holeBumps-1]) rotate(i*360/holeBumps) translate([D/2,0]) circle(d = bumpDiameter,$fn=12);
    }
}

difference() {
    linear_extrude(height=thickness)
    polygon(trimPath360(Bezier(getPath(holeDiameter/2+tolerance+minimumThickness,outerDiameter/2,wingtipSize))));
    translate([0,0,thickness-holeHeight]) linear_extrude(height=thickness) hole();
    cylinder(d=punchHole, h=100,$fn=100,center=true);
    }


