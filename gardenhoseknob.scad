use <tubeMesh.scad>;
use <Bezier.scad>;

//<params>
nutDistanceAcrossFlats = 29.64;
nutHeight = 14.38;
extraHeight = 5;
lipHeight = 1.5;
lipInset = 1;
tolerance = .17;
minWallThickness = 2.5;
wings = 4;
wingSize = 18;
chamfer = 1.5;
wingTipSize = 8;
bezierTensionInside = 0.5;
bezierTensionFromOutside = 0.5;
//</params>

module dummy() {}

nudge = 0.002;

innerRadius = 0.5*(nutDistanceAcrossFlats)/cos(180/8) + tolerance;
outerRadius = innerRadius+minWallThickness;

module inside(lip=0) {
    rotate(360/wings/2) rotate(360/8/2)
    circle(r=innerRadius-lip,$fn=8);
}

r = outerRadius;
R = r + wingSize;
w = wingTipSize;
angle = 360/wings;
wingThickness = lipHeight+extraHeight+nutHeight;

function trimVector(path,n) =
    n <= 0 ? [] :
    [for(i=[0:n-1]) path[i]];
     
// trim a path to only wind once around origin    
function trimPath360(path,pos=0,crossedXAxis=false) 
    = pos >= len(path) || 
      (crossedXAxis && atan2(path[pos][1],path[pos][0]) >= 0) ? trimVector(path,pos) :
      trimPath360(path,pos=pos+1,crossedXAxis=crossedXAxis || atan2(path[pos][1],path[pos][0]) < 0);
           
function getPath(r,R,w) = trimPath360(Bezier(
    [ [ R,0 ], SHARP(), SHARP(), [R, w/2-chamfer],
      SHARP(), SHARP(), [R-chamfer, w/2],
      POLAR(r*bezierTensionFromOutside,180), POLAR(r*bezierTensionInside,angle/2-90), r*[cos(angle/2),sin(angle/2)],
     REPEAT_MIRRORED([cos(90+angle/2),sin(90+angle/2)]),
     REPEAT_MIRRORED([cos(90+angle),sin(90+angle)]),
     REPEAT_MIRRORED([cos(90+2*angle),sin(90+2*angle)]),
     REPEAT_MIRRORED([cos(90+4*angle),sin(90+4*angle)]),
     ]));
    
path = getPath(r,R,w);   

module solid() {
    tubeMesh(
        [
         sectionZ(getPath(r-chamfer,R-chamfer,w-chamfer*2),0),
         sectionZ(getPath(r,R,w),chamfer),
         sectionZ(getPath(r,R,w),wingThickness-chamfer),
         sectionZ(getPath(r-chamfer,R-chamfer,w-chamfer*2),wingThickness)]);
}

difference() {
    solid();
    linear_extrude(height=wingThickness*3,center=true) inside(lip=lipInset);
    translate([0,0,lipHeight])
        linear_extrude(height=wingThickness) inside();
}
