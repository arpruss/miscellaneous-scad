use <threads.scad>;

includeDrawTube = 1;
includeOuterTube = 1;
includeThread = 1;
nominalDrawTubeDiameter = 31.75;
eyepieceTolerance = 1.5;
drawTubeWall = 4;
drawTubeLength = 15;
outerTubeLength = 15;
outerTubeWall = 3.5;
threadTolerance = 0;
collarHeight = 3;
collarWall = 2;
knurlSize = 3;
pitch = 4;
setScrewDiameter = 3;
flangeSize = 15;
flangeScrewHeadSize = 5;
flangeScrewDiameter = 3;

module dummy() {}

nudge = 0.001;
drawTubeID = nominalDrawTubeDiameter + eyepieceTolerance;
drawTubeOD = drawTubeID + drawTubeWall * 2;
outerTubeID = drawTubeOD + 2*threadTolerance;

module knurledCircle(d=10, knurlSize=knurlSize) {
    circumference = d * 3.141592653;
    n = ceil(circumference/knurlSize);
    for (i=[0:n-1]) {
        rotate(360/n*i) translate([d/2,0]) circle(d=circumference/n, $fn=12);
    }
    rotate(180/n) circle(d=d, $fn=n);
}

if (includeDrawTube) {
    render(convexity=2)
    difference() {
        union() {
            if (includeThread) 
                metric_thread(drawTubeOD, pitch=pitch, length=drawTubeLength);
            else 
                cylinder(d=drawTubeOD,h=drawTubeLength);
            linear_extrude(height=collarHeight) knurledCircle(d=drawTubeOD+collarWall*2);
        }
        translate([0,0,-nudge]) cylinder(d=drawTubeID, h=drawTubeLength+2*nudge);
        translate([0,0,collarHeight/2])
        rotate([0,-90,0]) cylinder(d=setScrewDiameter,h=drawTubeOD+2*knurlSize, $fn=16);
    }
}

if (includeOuterTube) {
    render(convexity=2)
    translate([outerTubeID+20+flangeSize,0,0])
    difference() {
        cylinder(d=outerTubeID+outerTubeWall*2, h=outerTubeLength);
        translate([0,0,-nudge]) if (includeThread)
metric_thread(outerTubeID, pitch=pitch, length=outerTubeLength+2*nudge);
            else cylinder(d=outerTubeID, h=outerTubeLength+2*nudge);
    }
}
