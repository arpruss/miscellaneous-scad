use <tubeMesh.scad>;

height = 15;
r1 = 18;
r2 = 36;
lobes = 3;
nutFlatToFlat = 15.32;
nutHeight = 8.5;
nutTolerance = 0.18;
upperHoleDiameter = 13;

module dummy() {}

nudge = 0.001;

nutDiameter = nutFlatToFlat / cos(180/6);

function mod(x,y) = x%y;

function point(z, angle, r1, r2, t, lobes) =
    let(
    sector = 360/lobes,
    _angle = min(lobes * (abs(mod(angle+sector/2, 360/lobes)-sector/2) / t), 180),
    r = r1+(r2-r1)*(1+cos(_angle))/2 
    )
    [r*cos(angle),r*sin(angle),z];

function tprofile(t) = let (u=2*(t-0.5)/sqrt(2)) 1-sqrt(1-u*u);

function profile(z, r1, r2, t, lobes, delta=2) =
    [for(a=[0:delta:360-delta]) point(z,a,r1,r2,t,lobes)];
    
module basic() {    
tubeMesh([for (t=[0:.025:1])
        let(t2=tprofile(t))
        profile(t*height, r1-t2*height, r2-t2*height, 1-t2, lobes)]);
}

difference() {
    basic();
    translate([0,0,height-nutHeight+nudge]) 
        cylinder(d=nutDiameter+nutTolerance*2,h=nutHeight,$fn=6);
    translate([0,0,-nudge])
    cylinder(d=upperHoleDiameter,h=height+2*nudge,$fn=64);
}
