use <Zahnstange_und_ritzel.scad>;

includeDrawTube = 1;
includeDrawTubeSlide = 1;
includeOuterTubeSlide = 1;

tolerance=0.25; // it is assumed that a part won't stick out more than this beyond its nominal size in any direction
gap=1; // use where gaps are needed, e.g., between draw tube and outer tube
axleDiameter=3;
drawTubeInnerDiameter=33;
drawTubeWallThickness=2.25;
drawTubeLength=80;
drawTubeLipThickness=2;
drawTubeLipHeight=5;
outerTubeWallThickness=2.25;
eyepieceSetScrewDiameter=3;
setScrewRightOfRack=true;
outerTubeLength=30;
focuserTubeTolerance=0.25;
telescopeTubeDiameter=200; // 0 for flat mount
slideWidth=10;
rackWidth=8;
slideThickness=1;

module dummy() {}

nudge = 0.001;

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
    od = drawTubeInnerDiameter+2*drawTubeWallThickness-2*tolerance;
    
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
        diamondCylinder(d=diamondSize(rackWidth,male=false,male=true),h=diamondHeight);
    }
}

row0 = [ 0,
    [[includeDrawTube, drawTubeInnerDiameter/2+drawTubeWallThickness + drawTubeLipThickness, 0],
    [includeDrawTubeSlide, slideWidth, -drawTubeLength/2],
    [includeOuterTubeSlide, slideWidth+2*gap, -outerTubeLength/2]]];

module location(positions, index) {
    x = positions[0];
    function pos(s,n) = (n==0) ? 0 : pos(s,n-1) + (s[n-1][0] ? s[n-1][1] : 0) + 10;


    y = pos(positions[1], index);
    echo(positions[1],y,index);
    
    translate([x+positions[1][index][2],y,0]) children();
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
