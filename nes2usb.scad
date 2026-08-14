// use pcbholdernarrower.scad
use <roundedSquare.scad>;
use <pointHull.scad>;
use <overhang.scad>;

//<params>
numberOfNESSlots=1;
includeLid=1; // [0:no,1:yes]
includeMain=1; // [0:no,1:yes]
pcbAreaWidth = 55;
width = 90;
length = 56;
corner = 3;
wall = 1.75;
internalHeightReserve = 15;
usbHoleWidth = 11.3;
usbHoleHeight = 8;
usbHoleCenterOffsetFromBase = 8.5;
screwHole = 2.5;
screwBiggerHole = 4;
screwHeadDiameter = 8;
screwHeadInset = 2;
screwBearingWallMinimum = 3;
screwHoleWall = 2;
screwGrabLength = 4;
pcbScrewHorizontalSpacing = 30.7;
pcbScrew1DistanceFromFront = 5;
pcbScrew2DistanceFromFront = 50;
pcbScrewHole = 4;
pcbScrewHeadDiameter = 7;
pcbScrewHeadInset = 2;
lidTolerance = 0.2;
nesWidth = 25.12+.15;
nesHeight = 16.39+.3;
nesDepth = 8;
nesWall = 1.75;
//</params>

module dummy() {}

nudge = 0.001;
$fn = 32;


nesX = -width/2 + pcbAreaWidth + (nesWidth+2*nesWall)/2;
pcbXOffset = (width-pcbAreaWidth)/2;

pcbScrews = [ [pcbScrewHorizontalSpacing/2, pcbScrew1DistanceFromFront ],
    [-pcbScrewHorizontalSpacing/2, pcbScrew1DistanceFromFront ],
    [pcbScrewHorizontalSpacing/2, pcbScrew2DistanceFromFront ],
    [-pcbScrewHorizontalSpacing/2, pcbScrew2DistanceFromFront ]
];

lidPillar=screwHole+2*screwHoleWall;

lidScrews = [[-width/2+lidPillar/2,lidPillar/2],[width/2-lidPillar/2,lidPillar/2],[-width/2+lidPillar/2,length-lidPillar/2],[width/2-lidPillar/2,length-lidPillar/2]];
lidScrewAngles = [45,135,-45,-135];

extraHeight = pcbScrewHeadInset+max(wall,screwBearingWallMinimum)-wall+wall+2;

bottomHeight = internalHeightReserve+extraHeight;

echo("bottom height", bottomHeight);

module base(wall) {
    roundedSquare([width+2*wall,length+2*wall],radius=lidPillar/2,center=true);
}

module lid() {
    difference() {
        union() {
            translate([0,length/2,0])
            linear_extrude(height=wall) base(-lidTolerance);
            linear_extrude(height=screwBearingWallMinimum) intersection() {
                for(s=lidScrews) translate(s) circle(d=screwHole+2*screwHoleWall);
                translate([0,length/2,0]) base(-lidTolerance);
            }
        }
        for(s=lidScrews) translate(s) translate([0,0,-nudge]) cylinder(d=screwBiggerHole,h=max(screwBearingWallMinimum,wall)+2*nudge);
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

module bottom() {
    difference() {
        union() {
            box(bottomHeight);
    translate([-pcbXOffset,0,0]) 
            for (p=pcbScrews)
                translate(p) screwHead(true,pcbScrewHeadDiameter,pcbScrewHeadInset,pcbScrewHole);
        }
    translate([-pcbXOffset,0,0]) 
        for (p=pcbScrews)
            translate(p) screwHead(false,pcbScrewHeadDiameter,pcbScrewHeadInset,pcbScrewHole);
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
            cylinder(d=screwHole+2*screwHoleWall+nudge,h=h);
            pointHull([[-d/2,-d/2,0],[-d/2,d/2,0],[d,-d/2,d],[d,d/2,d],[-d/2,-d/2,h],[-d/2,d/2,h],[d/2,d/2,h],[d/2,-d/2,h]]);
        }
        translate([0,0,-h]) cylinder(d=screwHole,h=3*h);
    }
}

module usbCutout() {
    h0 = pcbScrewHeadInset+max(wall,screwBearingWallMinimum);
        translate([-pcbXOffset,0,0]) 
    translate([0,0,h0+usbHoleCenterOffsetFromBase]) cube([usbHoleWidth,wall*3,usbHoleHeight],center=true);
}

module nesCutout() {
    translate([nesX-nesWidth/2,length-10,wall]) cube([nesWidth,20,nesHeight]);
}

module nesCage() {
    translate([nesX-nesWidth/2-nesWall,length-nesDepth,0]) cube([nesWidth+2*nesWall,nesDepth,nesHeight+wall+nesWall]);
}

module main() {
    difference() {
        union() {
            bottom();
            nesCage();
            if (numberOfNESSlots > 1) translate([0,length,0]) mirror([0,1,0]) nesCage();
        }
        usbCutout();
        nesCutout();
        if (numberOfNESSlots > 1) translate([0,length,0]) mirror([0,1,0]) nesCutout();
    }
}

if (includeMain)
main();

if (includeLid)
translate([0,5+length+wall,0]) lid();
