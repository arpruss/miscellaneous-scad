use <roundedSquare.scad>;
use <pointHull.scad>;
use <db9male-for-genesis.scad>;

//<params>
width = 66;
length = 63;
corner = 3;
wall = 1.5;

includeLid = 0;

usbHoleWidth = 11.3;
usbHoleHeight = 5.65;
usbHoleCenterOffsetFromEndOfPillars = 1.16;
bigScrewHole = 3.5;
screwHole = 2.5;
screwHeadDiameter = 8;
screwHeadInset = 2;
screwBearingWallMinimum = 3;
screwHoleWall = 2;
screwGrabLength = 6;
pcbScrewHorizontalSpacing = 34.7;
pcbScrew1DistanceFromFront = 5;
pcbScrew2DistanceFromFront = 50;
pcbScrewHole = 4;
pcbScrewHeadDiameter = 7;
pcbScrewHeadInset = 2;
lidTolerance = 0.2;
wireHoleDiameter = 1.75;
wireHoleCount = 2;
wireHoleSpacing = 3;
frontPCBScrewHoleWall = 0.75;

pillarHeight = 9;
heightAbovePillar = 24;

pillars = [ [0,0], [25, 0], [0,51.77+.4], [25, 51.77+0.4], [35, 5], [35+21.5, 5], [35, 5+38.22], [35+21.5, 5+38.22] ];

minX = min([for(p=pillars) p[0]]);
maxX = max([for(p=pillars) p[0]]);
pillarShift = [-(minX+maxX)/2,2.19];
usbX = pillarShift[0] + (pillars[0][0]+pillars[1][0])/2;
wireX = pillarShift[0] + (pillars[5][0]+pillars[6][0])/2;

//</params>

wireHeight = heightAbovePillar / 2;
module dummy() {}

nudge = 0.001;
$fn = 32;

lidPillar=bigScrewHole+2*screwHoleWall;

lidScrews = [[-width/2+lidPillar/2,lidPillar/2],[width/2-lidPillar/2,lidPillar/2],[-width/2+lidPillar/2,length-lidPillar/2],[width/2-lidPillar/2,length-lidPillar/2]];
lidScrewAngles = [45,135,-45,-135];

extraHeight = pcbScrewHeadInset+max(wall,screwBearingWallMinimum)-wall+wall;

bottomHeight = heightAbovePillar+pillarHeight;

module base(wall) {
    roundedSquare([width+2*wall,length+2*wall],radius=lidPillar/2,center=true);
}

module lid() {
    difference() {
        union() {
            translate([0,length/2,0])
            linear_extrude(height=wall) base(-lidTolerance);
            linear_extrude(height=screwBearingWallMinimum) intersection() {
                for(s=lidScrews) translate(s) circle(d=bigScrewHole+2*screwHoleWall);
                translate([0,length/2,0]) base(-lidTolerance);
            }
        }
        for(s=lidScrews) translate(s) translate([0,0,-nudge]) cylinder(d=bigScrewHole,h=max(screwBearingWallMinimum,wall)+2*nudge);
    }
}

module box(height) {
    translate([0,length/2,0]) {
        linear_extrude(height=wall) base(wall);
        linear_extrude(height=height+wall)
        difference() {
            base(wall);
            base(0);
        }
    }        
}

module screwHead(positive,headDiameter,headInset,hole) {
    h = headInset+max(wall,screwBearingWallMinimum);
    if (positive) {
        cylinder(d=headDiameter+2*screwHoleWall,h=h);
    }
    else {
        translate([0,0,-nudge]) {
            cylinder(d=headDiameter,h=headInset);
            cylinder(d=hole,h=h+2*nudge);
        }
    }
}

module pillar(small) {
    cylinder(d1=screwHoleWall*2+screwHole,d2=(small?frontPCBScrewHoleWall:screwHoleWall)*2+screwHole,h=pillarHeight);
}

module pillarHole() {
    translate([0,0,-nudge]) cylinder(d=screwHole,h=pillarHeight+2*nudge);
}

module bottom() {
    
    
    difference() {
        union() {
            box(bottomHeight);
            for (i=[0:len(pillars)-1]) let(p=pillars[i])
                translate(pillarShift+p)pillar(i<2);
        }
        for (p=pillars)
            translate(pillarShift+p) pillarHole();
    }
    for(i=[0:1:len(lidScrews)-1])
        translate(lidScrews[i]) rotate([0,0,lidScrewAngles[i]]) screwHolder();
}

module screwHolder() {
    d = lidPillar;
    h = screwGrabLength+d;
    translate([0,0,bottomHeight-max(wall,screwBearingWallMinimum )-h+wall])
    difference() {
        intersection() {
            cylinder(d=bigScrewHole+2*screwHoleWall+nudge,h=h);
            pointHull([[-d/2,-d/2,0],[-d/2,d/2,0],[d,-d/2,d],[d,d/2,d],[-d/2,-d/2,h],[-d/2,d/2,h],[d/2,d/2,h],[d/2,-d/2,h]]);
        }
        translate([0,0,-h]) cylinder(d=bigScrewHole,h=3*h);
    }
}

module usbCutout() {
    h0 = pcbScrewHeadInset+max(wall,screwBearingWallMinimum);
    translate([usbX,0,-usbHoleCenterOffsetFromEndOfPillars+pillarHeight]) cube([usbHoleWidth,usbHoleHeight,wall*3],center=true);
}

module wire() {
    rotate([90,0,0]) translate([0,0,-wall]) cylinder(d=wireHoleDiameter,h=wall*3);
}

module wireCutout() {
    wireX0 = wireX - wireHoleSpacing * wireHoleCount / 2;
    for (i=[0:wireHoleCount-1]) {
        translate([wireX0+i*wireHoleSpacing, length,wireHeight]) wire();
    }
}


//screwHolder();
difference() {
    bottom();
    usbCutout();
    wireCutout();
}

if (includeLid)
translate([width+wall+5,0,0]) lid();
