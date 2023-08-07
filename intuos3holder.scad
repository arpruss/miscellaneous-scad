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
hollowTopFraction = 0.5;
hollowTopWall = 3;

module dummy() {}

$fn = 80;
nudge = 0.01;

module basic(inset=0) {
    difference() 
    {
        union() {
          translate([0,0,bottomHeight-nudge+inset]) cylinder(d1=bottomDiameter-2*inset,d2=topDiameter-2*inset,h=height-bottomHeight-2*inset);
          translate([0,0,inset]) cylinder(d=bottomDiameter-2*inset,h=bottomHeight);
        }
        
        translate([0,0,height+penDiameter/2-incut]) rotate([0,90,0]) cylinder(d=penDiameter+2*inset,h=bottomDiameter,center=true);
        
        translate([0,0,height-incut-penTipHeight]) {
            translate([0,0,penTipHeight-nudge-inset])
            cylinder(d=2*inset+penHoleTopDiameter,h=height+inset);
            cylinder(d1=2*inset+penHoleBottomDiameter,d2=2*inset+penHoleTopDiameter,h=penTipHeight);
            translate([0,0,-nibHeight+nudge-inset]) cylinder(d=2*inset+penHoleBottomDiameter,h=nibHeight+inset);
        }
    }
}

difference() {
    basic();
    intersection() {
        basic(inset=hollowTopWall);
        difference() {
        translate([0,0,(1-hollowTopFraction)*height]) cylinder(d=bottomDiameter,h=hollowTopFraction*height);
           cube([2*height+2*bottomDiameter,penDiameter/2,2*height+2*bottomDiameter],center=true);
        }
    }
}