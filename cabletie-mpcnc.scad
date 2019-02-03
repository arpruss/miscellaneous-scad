use <bezier.scad>;
use <ribbon.scad>;

//<params>
cableDiameter=8;
cableWidth=13;
tieThickness=1.5;
tieWidth=12;
tieLength=25;
screwHoleDiameter=3;
//</params>

module dummy() {}

$fn=32;

cableDiameter1 = cableDiameter+2*tieThickness/2;
cableWidth1 = cableWidth+2*tieThickness/2;

curve = [ [-tieLength/2,0], OFFSET([tieLength/4,0]),
          OFFSET([-tieLength/4,0]),
          [-cableWidth1/2-cableWidth1*.2,0],
          OFFSET([cableWidth*.4,0]), 
          OFFSET([-cableWidth1*.5,0]),
          [0,cableDiameter1/2],
          REPEAT_MIRRORED([1,0])];


render(convexity=2)
intersection() {
    difference() {
        linear_extrude(height=tieWidth) ribbon(Bezier(curve),tieThickness);           
        for(s=[-1:2:1])
           translate([s*tieLength*0.35,0,tieWidth/2]) 
               rotate([90,0,0]) translate([0,0,-tieThickness*2]) cylinder(d=screwHoleDiameter,h=tieThickness*4);
    }
    translate([0,0,tieWidth/2])
    rotate([90,0,0])
    translate([0,0,-(tieThickness+cableDiameter)*2])
    linear_extrude(h=(tieThickness+cableDiameter)*4)
    hull() {
        translate([-tieLength/2+tieWidth/2,0]) circle(d=tieWidth);
        translate([tieLength/2-tieWidth/2,0]) circle(d=tieWidth);        
    }
}