use <Zahnstange_und_ritzel.scad>;

includeDrawTube = 1;
includeDrawTubeSlide = 1;
includeOuterTubeSlide = 1;
includeOuterTube = 1;

tolerance=0.25; // it is assumed that a part won't stick out more than this beyond its nominal size in any direction
gap=1; // use where gaps are needed, e.g., between draw tube and outer tube
axleDiameter=3;
drawTubeInnerDiameter=33;
drawTubeWallThickness=2.25;
drawTubeLength=80;
drawTubeLipThickness=2;
drawTubeLipHeight=5;
outerTubeWallThickness=3;
eyepieceSetScrewDiameter=3;
setScrewRightOfRack=true;
outerTubeLength=30;
focuserTubeTolerance=0.25;
telescopeTubeDiameter=200; // 0 for flat mount
slideWidth=10;
rackWidth=8;
slideThickness=2;

module dummy() {}

$fn=60;

nudge = 0.001;

drawTubeOD = drawTubeInnerDiameter+drawTubeWallThickness*2-2*tolerance;
outerTubeID = drawTubeOD+2*gap+4*tolerance;

module diamondCylinder(d=1,h=1) {
    cylinder(d=d, h=h, $fn=4);
}

module tube(id=undef, od=undef, wall=undef, h=1) {
    innerDiameter = id==undef ? od-2*wall : id;
    outerDiameter = od==undef ? id+2*wall : od;

    render(convexity=2)
    difference() {
        cylinder(d=outerDiameter, h=h);
        translate([0,0,-nudge])
            cylinder(d=innerDiameter, h=h+2*nudge);
    }
}

function diamondSize(baseWidth,male=true) = (baseWidth * 0.6) + (male ? -2*tolerance : 2*tolerance);

function diamondPositions(length,width) = [width/2,length/2,length-width/2];

module drawTube() {
    clearLength = drawTubeLength-drawTubeLipHeight;
    od = drawTubeOD;
    
    render(convexity=2)
    difference() {
        union() {
            cylinder(d=od, h=drawTubeLength, $fn=50);
            translate([0,0,drawTubeLength-drawTubeLipHeight]) tube(id=drawTubeInnerDiameter, wall=drawTubeWallThickness+drawTubeLipThickness, h=drawTubeLipHeight, $fn=50);
            translate([-slideWidth/2+tolerance,0,0])
            cube([slideWidth-2*tolerance,od/2,clearLength]);
            rotate([0,0,180])
            translate([-rackWidth/2+tolerance,0,0])            
            cube([rackWidth-2*tolerance,od/2,clearLength]);
        }
        translate([0,0,-nudge])
        cylinder(d=drawTubeInnerDiameter+tolerance, h=drawTubeLength+2*nudge, $fn=50);
        rotate([0,0,setScrewRightOfRack ? 0 : 180])
        translate([drawTubeInnerDiameter/2-drawTubeLipThickness,0,drawTubeLength-drawTubeLipHeight/2])
        rotate([0,90,0])
        cylinder(d=eyepieceSetScrewDiameter, h=4*drawTubeLipThickness,$fn=16);        
        for (z=diamondPositions(clearLength,slideWidth)) {
            translate([0,0,z])
            rotate([-90,0,0])
            diamondCylinder(d=diamondSize(slideWidth,male=false),h=od+nudge);
        }
        for (z=diamondPositions(clearLength,rackWidth)) {
            translate([0,0,z])
            rotate([0,0,180])
            rotate([-90,0,0])
            diamondCylinder(d=diamondSize(rackWidth,male=false),h=od+nudge);
        }
    }
}

module slide(width, length, diamondHeight) {
    translate([0,-width/2,0]) cube([length,width,slideThickness]);
    for (x=diamondPositions(length,width)) {
        translate([x,0,slideThickness-nudge])
        diamondCylinder(d=diamondSize(width,male=false,male=true),h=diamondHeight);
    }
}

module outerTube() {
    wall = drawTubeWallThickness;
    id = drawTubeInnerDiameter+2*wall+2*gap+2*tolerance;
    od = id + outerTubeWallThickness;
    slideInsetLeftEdge = drawTubeOD/2 + slideThickness + 2*tolerance;
    slideInsetRightEdge = slideInsetLeftEdge + slideThickness+2*tolerance;
    slideInsetWidth = slideWidth+2*gap+2*tolerance;

    // TODO: gearbox
    // TODO: attachment area
    render(convexity=2)
    difference() {
        union() {
            cylinder(d=od, h=outerTubeLength);
            translate([-slideInsetWidth/2-wall,0,0]) cube([slideInsetWidth+2*wall, slideInsetRightEdge+wall, outerTubeLength]);
        }
        translate([0,0,-nudge]) cylinder(d=id, h=outerTubeLength+2*nudge);
        translate([-slideInsetWidth/2,0,-nudge]) cube([slideInsetWidth,slideInsetRightEdge, outerTubeLength+2*nudge]);
        for (z=diamondPositions(outerTubeLength,slideWidth+2*gap)) {
            translate([0,0,z])
            rotate([-90,0,0])
            diamondCylinder(d=diamondSize(slideWidth+2*gap,male=false),h=slideInsetRightEdge+wall+nudge);
        }
    }
}

row0 = [ 0,
    [[includeDrawTube, drawTubeInnerDiameter/2+drawTubeWallThickness + drawTubeLipThickness, 0, 0],
    [includeDrawTubeSlide, slideWidth, 0, -drawTubeLength/2],
    [includeOuterTubeSlide, slideWidth+2*gap, 0, -outerTubeLength/2],
    [includeOuterTube, outerTubeID , outerTubeID/2, 0]]];

module location(positions, index) {
    x = positions[0];
    function pos(s,n) = (n==0) ? 0 : pos(s,n-1) + (s[n-1][0] ? s[n-1][1] : 0) + 10;


    y = pos(positions[1], index);
    
    translate([x+positions[1][index][3],y+positions[1][index][2],0]) children();
}

if (includeDrawTube) {
    location(row0, 0)
    translate([0,0,drawTubeLength])
    rotate([180,0,0])
    drawTube();
}

if (includeDrawTubeSlide) {
    location(row0, 1)
    slide(slideWidth, drawTubeLength-drawTubeLipHeight, drawTubeWallThickness);
}

if (includeOuterTubeSlide) {
    location(row0, 2)
    slide(slideWidth+2*gap, outerTubeLength, outerTubeWallThickness);
}

if (includeOuterTube) {
    location(row0, 3) outerTube();
}