use <roundedSquare.scad>;
use <pointHull.scad>;

//<params>
topButtons = false;
includeBottom = true;
includeLid = false;
addToHeight = 15;
width = 55;
length = 56;
corner = 3;
wall = 1.25;
cableCutout = 6;
usbHoleWidth = 11.3;
usbHoleHeight = 5.65;
usbHoleCenterOffsetFromBase = 6.1;
screwHole = 3;
screwBiggerHole = 4;
screwHeadDiameter = 8;
screwHeadInset = 2;
screwBearingWallMinimum = 3;
screwHoleWall = 2;
screwGrabLength = 6;
pcbScrewHorizontalSpacing = 30.7; // pcbholdernarrower
pcbScrew1DistanceFromFront = 5;
pcbScrew2DistanceFromFront = 50;
pcbScrewHole = 4;
pcbScrewHeadDiameter = 7;
pcbScrewHeadInset = 2;
lidTolerance = 0.2;
buttonWellWidth = 6.5;
buttonWellLength = 6.5;
buttonWellHeight = 2.75;
buttonLegHoleDiameter = 1.75;
buttonLegXSpacing = 4.6;
buttonLegYSpacing = 6.21;
buttonSpacing = 16;
buttonColumns = 2;
buttonRows = 2;
//</params>

module dummy() {}

nudge = 0.001;
$fn = 32;

pcbScrews = [ [pcbScrewHorizontalSpacing/2, pcbScrew1DistanceFromFront ],
    [-pcbScrewHorizontalSpacing/2, pcbScrew1DistanceFromFront ],
    [pcbScrewHorizontalSpacing/2, pcbScrew2DistanceFromFront ],
    [-pcbScrewHorizontalSpacing/2, pcbScrew2DistanceFromFront ]
];

lidPillar=screwHole+2*screwHoleWall;

lidScrews = [[-width/2+lidPillar/2,lidPillar/2],[width/2-lidPillar/2,lidPillar/2],[-width/2+lidPillar/2,length-lidPillar/2],[width/2-lidPillar/2,length-lidPillar/2]];
lidScrewAngles = [45,135,-45,-135];

extraHeight = pcbScrewHeadInset+max(wall,screwBearingWallMinimum)-wall+wall;

bottomHeight = addToHeight+extraHeight;

module base(wall) {
    roundedSquare([width+2*wall,length+2*wall],radius=lidPillar/2,center=true);
}

module buttonBezel(positive=true) {
    if (positive)  {
        h = buttonWellHeight+nudge;
    translate([0,0,wall-nudge]) {
        difference() {
            pointHull(
                [for (w=[0,h]) for (i=[-1,1]) for(j=[-1,1]) [i*(buttonWellWidth/2+w),j*(buttonWellLength/2+w),h-w]]);
            cube([buttonWellWidth,buttonWellLength,h*3],center=true);
            }
        }
    }
    else {
        translate([0,0,-nudge]) {
            h = buttonWellHeight+wall+2*nudge;
            for (i=[-1,1]) for(j=[-1,1]) translate([i*buttonLegXSpacing/2,j*buttonLegYSpacing/2,0]) cylinder(d=buttonLegHoleDiameter,h=h);
        }
    }
}

module doTopButtons(positive=true) {
    if (topButtons) {
        for (i=[0:buttonColumns-1]) for (j=[0:buttonRows-1]) translate([-(buttonColumns-1)*buttonSpacing/2+buttonSpacing*i,length/2-(buttonRows-1)*buttonSpacing/2+buttonSpacing*j,0]) buttonBezel(positive);
    }
}

module lid() {
    difference() {
        union() {
            translate([0,length/2,0])
            linear_extrude(height=wall) base(-lidTolerance);
            if (!topButtons) linear_extrude(height=screwBearingWallMinimum) intersection() {
                for(s=lidScrews) translate(s) circle(d=screwHole+2*screwHoleWall);
                translate([0,length/2,0]) base(-lidTolerance);
            }
            doTopButtons(positive=true);
        }
        for(s=lidScrews) translate(s) translate([0,0,-nudge]) cylinder(d=screwBiggerHole,h=(topButtons ? wall : max(screwBearingWallMinimum,wall))+2*nudge);            
        doTopButtons(positive=false);
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
            for (p=pcbScrews)
                translate(p) screwHead(true,pcbScrewHeadDiameter,pcbScrewHeadInset,pcbScrewHole);
        }
        for (p=pcbScrews)
            translate(p) screwHead(false,pcbScrewHeadDiameter,pcbScrewHeadInset,pcbScrewHole);
    }
    for(i=[0:1:len(lidScrews)-1])
        translate(lidScrews[i]) rotate([0,0,lidScrewAngles[i]]) screwHolder();
}

module screwHolder() {
    d = lidPillar;
    h = screwGrabLength+d;
    translate([0,0,bottomHeight-(topButtons ? wall : max(wall,screwBearingWallMinimum ))-h+wall])
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
    translate([0,0,h0+usbHoleCenterOffsetFromBase]) cube([usbHoleWidth,usbHoleHeight,wall*3],center=true);
}


if (includeBottom)
difference() {
    bottom();
    usbCutout();
    translate([0,length,bottomHeight-cableCutout/2])
    rotate([270,0,0])
    translate([0,0,-5]) 
    rotate([0,0,180])
    {
    cylinder(d=cableCutout,h=100);
    translate([-cableCutout/2,0,0]) cube([cableCutout,cableCutout+100,100]);
    }
}

if (includeLid) translate([width+wall+5,0,0]) lid();

