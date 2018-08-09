topDiameter = 36.4;
bottomDiameter = 57.1;
incut = 5;
height = 32.5;
bottomHeight = 2.5;
penDiameter = 13;
penHoleTopDiameter = 15.5;
penHoleBottomDiameter = 4;
penTipHeight = 23;
nibHeight = 3.5;

module dummy() {}

$fn = 80;
nudge = 0.01;

difference() 
{
   union() {
      translate([0,0,bottomHeight-nudge]) cylinder(d1=bottomDiameter,d2=topDiameter,h=height-bottomHeight);
      cylinder(d=bottomDiameter,h=bottomHeight);
    }
    
    translate([0,0,height+penDiameter/2-incut]) rotate([0,90,0]) cylinder(d=penDiameter,h=bottomDiameter,center=true);
    
    translate([0,0,height-incut-penTipHeight]) {
        translate([0,0,penTipHeight-nudge])
        cylinder(d=penHoleTopDiameter,h=height);
        cylinder(d1=penHoleBottomDiameter,d2=penHoleTopDiameter,h=penTipHeight);
        translate([0,0,-nibHeight+nudge]) cylinder(d=penHoleBottomDiameter,h=nibHeight);
    }
}