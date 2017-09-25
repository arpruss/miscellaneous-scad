use <bezier.scad>;
use <ribbon.scad>;

//<params>
cableDiameter=3.5;
tieThickness=1.5;
tieWidth=10;
tieLength=25;
screwHoleDiameter=2.5;
//</params>

module dummy() {}

cableDiameter1 = cableDiameter+2*tieThickness/2;

curve = [ [-tieLength/2,0], OFFSET([tieLength/4,0]),
          OFFSET([-tieLength/4,0]),
          [-cableDiameter1/2-cableDiameter1*.2,0],
          OFFSET([cableDiameter*.4,0]), 
          OFFSET([-cableDiameter1*.5,0]),
          [0,cableDiameter1/2],
          REPEAT_MIRRORED([1,0])];


render(convexity=2)
intersection() {
    difference() {
        linear_extrude(height=tieWidth) ribbon(Bezier(curve),tieThickness);           
        for(s=[-1:2:1])
           translate([s*tieLength*0.35,0,tieWidth/2]) 
               rotate([90,0,0]) translate([0,0,-tieThickness*2]) cylinder(d=screwHoleDiameter,h=tieThickness*4,$fn=32);
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