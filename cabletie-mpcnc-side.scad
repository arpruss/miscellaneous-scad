use <bezier.scad>;
use <ribbon.scad>;

thickness = 1.5;
width = 16;
tabLength = 18.5;
wood = 25.4*.75;
incutH = 6;
incutV = 8.5;

b = [ [-thickness/2-thickness*2,tabLength-thickness/2],
      SHARP(),
      SHARP(),
      [-thickness/2-thickness*2,incutH],
      POLAR(tabLength*.25,-90),
      POLAR(tabLength*.25,180),
      [incutH, 0],
      SHARP(),
      SHARP(),
      [wood-incutV-incutH,0],
      POLAR(tabLength*.25,0),
      POLAR(tabLength*.125,-90),
      [wood-incutV,incutH/2],
      POLAR(tabLength*.125,90),
      POLAR(tabLength*.125,180),
      [wood-incutV/2,incutH],
      SHARP(),
      SHARP(),
      [wood,incutH]
      ];
      
$fn = 18;      
difference() {      
    ribbon(Bezier(b)) cylinder(d=thickness,h=width);
    translate([-thickness*1.5,tabLength-thickness/2-screwHole,width/2]) rotate([0,90,0]) cylinder(d=screwHole,h=3*thickness);
    translate([wood-screwHole*0.75,0,width/2]) rotate([-90,0,0]) cylinder(d=screwHole,h=100);
}

/*BezierVisualize(b);      

square([thickness,tabLength]);
//square([wood+2*thickness,thickness]);
square([wood-incutV+2*thickness,thickness]);
translate([wood-incutV+thickness,0]) square([thickness,incutH+thickness]);
translate([wood-incutV+thickness,incutH]) square([incutV+thickness,thickness]);*/

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

/*
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
*/