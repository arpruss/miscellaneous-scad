tieThickness = 1.5;
tieWidth = 16;
materialThickness = 25.4*.75;
screwHole = 4;
wireThickness = 5;
margin = 4;

d = wireThickness+2*margin+screwHole+tieThickness;
h = tieThickness*2+materialThickness;
w = tieWidth;
nudge = 0.01;

rotate([90,0,0])
difference() {
    cube([w,d,h]);
    translate([-nudge,tieThickness,tieThickness])
    cube([w+2*nudge,d,materialThickness]);
    translate([w/2-screwHole/2-1,wireThickness+tieThickness+screwHole/2+margin,-nudge])
    cylinder(d=screwHole,h=tieThickness+2*nudge,$fn=12);
    translate([w/2+screwHole/2+1,wireThickness+tieThickness+screwHole/2+margin,h-tieThickness-nudge])
    cylinder(d=screwHole,h=tieThickness+2*nudge,$fn=12);
}