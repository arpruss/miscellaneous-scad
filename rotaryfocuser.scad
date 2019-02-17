//use <threads.scad>;
use <quickthread.scad>;
use <bezier.scad>;
use <paths.scad>;

//<params>
includeDrawTube = 1; //[1:yes, 0:no]
includeOuterTube = 1; //[1:yes, 0:no]
includeTubeAdapter = 1; //[1:yes, 0:no]
includeThread = 1; //[1:yes, 0:no]
crossSection = 0; //[1:yes, 0:no]
nominalDrawTubeDiameter = 31.75;
eyepieceTolerance = 0.75;
drawTubeLength = 60;
outerTubeLength = 20;
drawTubeWall = 2.5;
outerTubeWall = 2.5;
threadTolerance = 0.75;
threadPitch = 4;
threadAngle = 40;
collarHeight = 5;
collarWall = 1;
knurlSize = 2.5;
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
telescopeTubeDiameter = 150; // only needed if printing tube adapter
//</params>

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

profile = [ [0,flangeHeight], OFFSET([0,-flangeHeight/2]),
        OFFSET([-flangeSize/2,0]), [flangeSize, flangeOuterThickness], SHARP(), SHARP(), [flangeSize,0], SHARP(), SHARP(), [0,0] ];
profilePath = Bezier(profile);
screwR = outerTubeOD/2 - nudge + flangeSize/2;
screwZ = findCoordinateIntersections(profilePath,0,flangeSize/2+screwHeadDiameter/2)[0][1];

module screws(countersink=true) {
    for (i=[0:screwCount-1]) {
        rotate([0,0,360*i/screwCount]) {
            translate([screwR,0,0]) {
                cylinder(h=max(flangeHeight,telescopeTubeDiameter),d=screwDiameter,$fn=12);
                if(countersink) translate([0,0,screwZ-screwCountersink]) cylinder(h=flangeHeight,d=screwHeadDiameter,$fn=12);
            }
        }
    }
}

module flange() {
    difference() {
        rotate_extrude() translate([outerTubeOD/2-nudge,0,0]) polygon(profilePath);
        screws(countersink=true);
    }
}

module drawTube(upright=false) {
    render(convexity=2)
    difference() {
        union() {
            if (includeThread) 
                //metric_thread(drawTubeOD, threadPitch=threadPitch, length=drawTubeLength);
                isoThread(d=drawTubeOD,pitch=threadPitch,h=drawTubeLength,angle=threadAngle);
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
//metric_thread(outerTubeID, threadPitch=threadPitch, length=outerTubeLength+2*nudge,internal=true);
        isoThread(d=outerTubeID, pitch=threadPitch, h=outerTubeLength+2*nudge,internal=true, angle=threadAngle);
            else cylinder(d=outerTubeID, h=outerTubeLength+2*nudge);
    }
    flange();
}

module tubeAdapter() {
    d = outerTubeOD+2*flangeSize-2*nudge;
    render(convexity=2)
    difference() {
        cylinder(d=d, h=telescopeTubeDiameter/2, $fn=72);
        translate([0,0,telescopeTubeDiameter/2+2]) rotate([0,90,0]) translate([0,0,-d]) cylinder(d=telescopeTubeDiameter, h=2*d, $fn=120);
        screws(countersink=false);
        cylinder(d=outerTubeID+threadPitch*(.25+cos(threadAngle)), h=telescopeTubeDiameter/2);
    }
}

module cut() {
    render(convexity=2)
    difference() {
        rotate([0,0,90]) children();
        translate([-outerTubeOD,0,-100]) cube([outerTubeOD*2,outerTubeOD*2,outerTubeLength+drawTubeLength+100]);
    }
}

if (crossSection) {
    color("red") cut() translate([0,0,-2*threadPitch])drawTube(upright=true);
    color("blue") cut() outerTube();
    color("green") cut() rotate([180,0,0]) tubeAdapter();
}
else {
    if (includeDrawTube) {
        drawTube();
    }

    if (includeOuterTube) {
        translate([outerTubeID+20+flangeSize,0,0]) outerTube();
    }

    if (includeTubeAdapter) {
        translate(-[outerTubeID+20+flangeSize,0,0]) tubeAdapter();
    }
}
