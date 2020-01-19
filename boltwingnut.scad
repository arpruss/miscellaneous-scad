use <Bezier.scad>;
use <tubemesh.scad>;

//<params>
screwDiameter = 12.49;
nutAcrossFlats = 18.78;
nutThickness = 7.91;
nutTolerance = 0.1;
screwTolerance = 0.2;
minWallVertical = 2.5;
minWallHorizontal = 5;
outerDiameter = 70;
neckLength = 0;
wingTipSize = 8;
wingThickness = 10;
wings = 3; // [3:3, 4:4, 5:5, 6:6, 7:7, 8:8]
captive = 0; // [0:No, 1:Yes]
throughHole = 1; // [0:No, 1:Yes]
bezierTensionInside = 0.5;
bezierTensionFromOutside = 0.5;
chamfer = 1;
//</params>

module dummy() {
}

nudge = 0.01;
R = outerDiameter / 2;
nutDiameter = nutAcrossFlats / cos(180/6) + 2 * nutTolerance;
r = nutAcrossFlats/2 + minWallHorizontal;
w = wingTipSize;
angle = 360/wings;

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
    if (neckLength>0) translate([0,0,chamfer])
    cylinder(r=r, h=neckLength+wingThickness-chamfer);
}

nt = nutThickness+.1;
z0 = neckLength+wingThickness-(captive?minWallVertical:-nudge)-nt;
difference() {
    solid();
    translate([0,0,z0])
    rotate([0,0,360/12])
    cylinder(d=nutDiameter,h=nt,$fn=6);
    translate([0,0,throughHole?-nudge:minWallVertical]) cylinder(d=screwDiameter+2*screwTolerance,h=neckLength+wingThickness+2*nudge,$fn=16);

echo("Nut ends at ", z0+nt);

}