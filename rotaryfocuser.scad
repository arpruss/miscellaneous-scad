//use <threads.scad>;
use <quickthread.scad>;
use <bezier.scad>;
use <paths.scad>;

includeDrawTube = 1;
includeOuterTube = 1;
includeThread = 1;
crossSection = 0;
nominalDrawTubeDiameter = 31.75;
eyepieceTolerance = 0.75;
drawTubeWall = 2.5;
drawTubeLength = 20;
outerTubeLength = 15;
outerTubeWall = 2.5;
threadTolerance = 0.75;
collarHeight = 5;//6;
collarWall = 1;
knurlSize = 2.5;
pitch = 4;
threadAngle = 40;
setScrewDiameter = 2.3;
flangeSize = 15;
flangeScrewHeadSize = 5;
flangeScrewDiameter = 3;
flangeOuterThickness = 2;
flangeHeight = 6;
screwDiameter = 3.5;
screwHeadDiameter = 8;
screwCountersink = 1;
screwCount = 3;

module dummy() {}

nudge = 0.001;
drawTubeID = nominalDrawTubeDiameter + eyepieceTolerance;
drawTubeOD = drawTubeID + drawTubeWall * 2;
outerTubeID = drawTubeOD + 2*threadTolerance;
outerTubeOD = outerTubeID + outerTubeWall * 2;

module knurledCircle(d=10, knurlSize=knurlSize) {
    circumference = d * 3.141592653;
    n = ceil(circumference/knurlSize);
    for (i=[0:n-1]) {
        rotate(360/n*i) translate([d/2,0]) circle(d=circumference/n, $fn=12);
    }
    rotate(180/n) circle(d=d, $fn=n);
}

module flange() {
    profile = [ [0,flangeHeight], OFFSET([0,-flangeHeight/2]),
            OFFSET([-flangeSize/2,0]), [flangeSize, flangeOuterThickness], SHARP(), SHARP(), [flangeSize,0], SHARP(), SHARP(), [0,0] ];
    profilePath = Bezier(profile);
    screwR = outerTubeOD/2 - nudge + flangeSize/2;
    screwZ = findCoordinateIntersections(profilePath,0,flangeSize/2+screwHeadDiameter/2)[0][1];
    difference() {
        rotate_extrude() translate([outerTubeOD/2-nudge,0,0]) polygon(Bezier(profile));
        for (i=[0:screwCount-1]) {
            rotate([0,0,360*i/screwCount]) {
                translate([screwR,0,0]) {
                    cylinder(h=flangeHeight,d=screwDiameter,$fn=12);
                    translate([0,0,screwZ-screwCountersink]) cylinder(h=flangeHeight,d=screwHeadDiameter,$fn=12);
                }
            }
        }
    }
}

module drawTube(upright=false) {
    render(convexity=2)
    difference() {
        union() {
            if (includeThread) 
                //metric_thread(drawTubeOD, pitch=pitch, length=drawTubeLength);
                isoMetricThread(d=drawTubeOD,pitch=pitch,h=drawTubeLength,angle=threadAngle);
            else 
                cylinder(d=drawTubeOD,h=drawTubeLength);
            translate([0,0, upright?drawTubeLength-collarHeight:0]) linear_extrude(height=collarHeight) knurledCircle(d=drawTubeOD+collarWall*2);
        }
        translate([0,0,-nudge]) cylinder(d=drawTubeID, h=drawTubeLength+2*nudge);
        translate([0,0,upright?drawTubeLength-collarHeight/2 : collarHeight/2])
        rotate([0,-90,0]) cylinder(d=setScrewDiameter,h=drawTubeOD+2*knurlSize, $fn=16);
    }
}

module outerTube() {
    render(convexity=2)
    difference() {
        cylinder(d=outerTubeOD, h=outerTubeLength);
        translate([0,0,-nudge]) if (includeThread)
//metric_thread(outerTubeID, pitch=pitch, length=outerTubeLength+2*nudge,internal=true);
        isoMetricThread(d=outerTubeID, pitch=pitch, h=outerTubeLength+2*nudge,internal=true, angle=threadAngle);
            else cylinder(d=outerTubeID, h=outerTubeLength+2*nudge);
    }
    flange();
}

module cut() {
    render(convexity=2)
    difference() {
        children();
        translate([-outerTubeOD,0,0]) cube([outerTubeOD*2,outerTubeOD*2,outerTubeLength+drawTubeLength]);
    }
}

if (crossSection) {
    color("red") cut() drawTube(upright=true);
    color("blue") cut() outerTube();
}
else {
    if (includeDrawTube) {
        drawTube();
    }

    if (includeOuterTube) {
        translate([outerTubeID+20+flangeSize,0,0]) outerTube();
    }
}