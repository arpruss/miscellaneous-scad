use <roundedSquare.scad>;

holeSpacing = 525;

height = 525 * 36/90 + 20;
rounding = 20;
hmargin = 35;
bottomExtra = 10;
shelfThickness = 2.5;
shelfFront = 20;
shelfSupports = 3;
shelfExtraAngle = 8;
wireHole = 5.4;
wireHolderLength = 90;
wireHolderRim = 5;
wireHolderThickness = 2;

wireHolderWidth = wireHole+2*wireHolderThickness+2*wireHolderRim;
beyondHoles = wireHolderWidth/2;
hmargin = wireHolderWidth;

//TODO: shelf screw holes

$fn = 128;
nudge = 0.01;

module back() {
	difference() {
		hull() {
			translate([0,-bottomExtra]) square(10);
			translate([width-10,-bottomExtra]) square(10);
			translate([rounding,height-rounding]) circle(rounding);
			translate([width-rounding,height-rounding]) circle(rounding);
		}
        translate([hmargin,vmargin]) 
        roundedSquare([width-2*hmargin,(height-3*vmargin)/2]);
	    translate([hmargin,2*vmargin+(height-3*vmargin)/2]) 
        roundedSquare([width-2*hmargin,(height-3*vmargin)/2]);
	}
}

module shelfHalf() {
    cube([width/2,bottomExtra+vmargin,shelfThickness]);
    hull() {
        translate([0,bottomExtra,0]) cube([width/2,shelfThickness,shelfFront]);
        translate([0,bottomExtra,0]) rotate([-shelfExtraAngle,0,0]) cube([width/2,shelfThickness,shelfFront]);
    }
        
    for (i=[0:shelfSupports-1])
        translate([(width/2-shelfThickness)/(shelfSupports-1)*i,0,0]) hull() {
            cube([shelfThickness,bottomExtra+shelfThickness,shelfThickness]);
            translate([0,bottomExtra,0]) cube([shelfThickness,shelfThickness,shelfFront]);
        }
}

module wireHolder() {
    linear_extrude(h=wireHolderLength) 
    {
        difference() {
            union() {
                hull() {
                    intersection() {
                    translate([0,wireHole/2]) circle(d=wireHole+wireHolderThickness*2);
                    translate([-wireHole/2-wireHolderThickness,0]) square([wireHole+2*wireHolderThickness,wireHole+wireHolderThickness]);
                        }
                    translate([-wireHole/2-wireHolderThickness,0]) square([wireHole+2*wireHolderThickness,wireHole/2]);
                }
               translate([-wireHolderWidth/2,0]) square([wireHolderWidth,wireHolderThickness]);
            }
            hull() {
                    translate([0,wireHole/2]) circle(d=wireHole);
                translate([-wireHole/2,-nudge]) square([wireHole,wireHole/2+nudge]);
            }
                }
    }
}

//back();
//shelfHalf();
wireHolder();