use <bezier.scad>;
use <roundedSquare.scad>;
use <ribbon.scad>;

//<params>
corner=5;
cableDiameter=5;
tieThickness=2;
tieWidth=25.9;
tieLength=35;
screwHoleDiameter=4;
cableExtraWidth=4.76;
//</params>

module dummy() {}

$fn=32;

curve = [ [-tieLength/2,0], OFFSET([tieLength/4,0]),
          OFFSET([-tieLength/4,0]),
          [-cableDiameter/2-cableDiameter*.2-tieThickness/2-cableExtraWidth/2,0],
          OFFSET([cableDiameter*.2,0]), 
          OFFSET([-cableDiameter*.8,0]),
          [-cableExtraWidth/2,cableDiameter],
          LINE(),
          LINE(),
          [0,cableDiameter],
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
    linear_extrude(height=(tieThickness+cableDiameter)*4)
    roundedSquare([tieLength,tieWidth],radius=corner,center=true,$fn=64);
}