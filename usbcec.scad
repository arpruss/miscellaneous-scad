use <roundedSquare.scad>;
use <pointHull.scad>;
use <overhang.scad>;

//<params>
width = 50;
length = 56;
corner = 3;
wall = 1.75;
hdmiHoleDiameter = 5;
hdmiHoleFromBase = 15;
usbHoleWidth = 11.3;
usbHoleHeight = 5.65;
usbHoleCenterOffsetFromBase = 6.1+5.65/2;
screwHole = 3.5;
screwBiggerHole = 4;
screwHeadDiameter = 8;
screwHeadInset = 2;
screwBearingWallMinimum = 3;
screwHoleWall = 2;
screwGrabLength = 6;
pcbScrewHorizontalSpacing = 30.7;
pcbScrew1DistanceFromFront = 5;
pcbScrew2DistanceFromFront = 50;
pcbScrewHole = 4;
pcbScrewHeadDiameter = 7;
pcbScrewHeadInset = 2;
lidTolerance = 0.2;
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

extraHeight = pcbScrewHeadInset+max(wall,screwBearingWallMinimum)-wall+wall+2;

bottomHeight = hdmiHoleFromBase+hdmiHoleDiameter+extraHeight;

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
    translate([0,0,h0+usbHoleCenterOffsetFromBase]) cube([usbHoleWidth,usbHoleHeight,wall*3],center=true);
}

hdmiZ = bottomHeight-hdmiHoleDiameter/2;

module hdmiOverhang() {
    translate([0,0,hdmiZ])
    rotate([-90,0,0])
    rotate([0,0,180])
    translate([0,0,-hdmiHoleDiameter*0.5])
    difference() {
        cylinder(d2=hdmiHoleDiameter*3,d1=hdmiHoleDiameter,h=hdmiHoleDiameter*0.5+nudge);
        cylinder(d=hdmiHoleDiameter,h=hdmiHoleDiameter*5,center=true);
        translate([-hdmiHoleDiameter*5,0+wall+hdmiHoleDiameter/2,-hdmiHoleDiameter*5]) cube([hdmiHoleDiameter*10,hdmiHoleDiameter*2,hdmiHoleDiameter*10]);
    }
}

module hdmiOverhangs() {
    translate([0,length+wall,0]) {
        //translate([0,-wall,0]) hdmiOverhang();
        rotate([0,0,180]) 
        hdmiOverhang();
    }

    {
        translate([0,-wall,0]) hdmiOverhang();
        //rotate([0,0,180]) 
        hdmiOverhang();
    }
}

module hdmiCutout() {
    translate([0,0,hdmiZ]) rotate([90,0,0]) {
        cylinder(d=hdmiHoleDiameter,h=length*3,center=true);
        translate([0,hdmiHoleDiameter/2,0]) cube([hdmiHoleDiameter+nudge,hdmiHoleDiameter+2*nudge,length*3],center=true);
    }
}


difference() {
    union() {
        hdmiOverhangs();
        bottom();
    }
    usbCutout();
    hdmiCutout();
}

//translate([width+wall+5,0,0]) lid();
