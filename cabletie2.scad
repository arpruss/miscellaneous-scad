use <bezier.scad>;
use <roundedSquare.scad>;
use <ribbon.scad>;

//<params>
corner=5;
cableDiameter=5;
tieThickness=2;
tieWidth=23;
tieLength=25;
screwHoleDiameter=4;
//</params>

module dummy() {}

$fn=32;

cableDiameter1 = cableDiameter;

curve = [ [-tieLength/2,0], OFFSET([tieLength/4,0]),
          OFFSET([-tieLength/4,0]),
          [-cableDiameter1/2-cableDiameter1*.2-tieThickness/2,0],
          OFFSET([cableDiameter*.2,0]), 
          OFFSET([-cableDiameter1*.8,0]),
          [0,cableDiameter1],
          REPEAT_MIRRORED([1,0])];


render(convexity=2)
intersection() {
    difference() {
        linear_extrude(height=tieWidth) ribbon(Bezier(curve),tieThickness);           
        for(h=[0.25,0.75]) translate([0,0,h*tieWidth])
        for(s=[-1:2:1])
           translate([s*tieLength*0.35,0,0]) 
               rotate([90,0,0]) translate([0,0,-tieThickness*2]) cylinder(d=screwHoleDiameter,h=tieThickness*4);
    }
    translate([0,0,tieWidth/2])
    rotate([90,0,0])
    translate([0,0,-(tieThickness+cableDiameter)*2])
    linear_extrude(h=(tieThickness+cableDiameter)*4)
    roundedSquare([tieLength,tieWidth],radius=corner,center=true,$fn=64);
}