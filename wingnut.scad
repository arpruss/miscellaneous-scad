use <Bezier.scad>;

screwDiameter = 6.35;
nutAcrossFlats = 11.1125;
nutThickness = 5.55625;
nutTolerance = 0.1;
screwTolerance = 0.4;
minWall = 2.5;
outerDiameter = 45;
neckLength = 4;
wingTipSize = 6;
wingThickness = 10;
captive = true;

module dummy() {
}

nudge = 0.01;
R = outerDiameter / 2;
nutDiameter = nutAcrossFlats / cos(180/6) + 2 * nutTolerance;
r = nutDiameter/2 + minWall;
w = wingTipSize;

    echo(nutAcrossFlats/cos(180/6));

function trimVector(path,n) =
    n <= 0 ? [] :
    [for(i=[0:n-1]) path[i]];
     
// trim a path to only wind once around origin    
function trimPath360(path,pos=0,crossedXAxis=false) 
    = pos >= len(path) || 
      (crossedXAxis && atan2(path[pos][1],path[pos][0]) >= 0) ? trimVector(path,pos) :
      trimPath360(path,pos=pos+1,crossedXAxis=crossedXAxis || atan2(path[pos][1],path[pos][0]) < 0);
           
path = trimPath360(Bezier(
    [ [ R,0 ], SHARP(), SHARP(), [R, w/2],
      POLAR(r/2,180), POLAR(r/2,60-90), r*[cos(60),sin(60)],
     REPEAT_MIRRORED([cos(90+60),sin(90+60)]),
     REPEAT_MIRRORED([cos(90+120),sin(90+120)]),
     REPEAT_MIRRORED([cos(90+240),sin(90+240)]),
     ]));

module solid() {
    linear_extrude(height = wingThickness)     
    polygon(path);
    translate([0,0,wingThickness-nudge])
    cylinder(r=r, h=neckLength+nudge);
}

nt = nutThickness+.1;
difference() {
    solid();
    translate([0,0,neckLength+wingThickness-(captive?minWall:-nudge)-nt])
    cylinder(d=nutDiameter,h=nt,$fn=6);
    translate([0,0,-nudge]) cylinder(d=screwDiameter+2*screwTolerance,h=neckLength+wingThickness+2*nudge,$fn=16);
}