use <Zahnstange_und_ritzel.scad>;

includeDrawTube = 1;

printerTolerance=0.25;
axleDiameter=3;
drawTubeInnerDiameter=33;
drawTubeWallThickness=2.25;
drawTubeLength=50;
drawTubeLipThickness=2;
drawTubeLipHeight=5;
eyepieceSetScrewDiameter=3;
setScrewRightOfRack=true;
outerTubeLength=30;
focuserTubeTolerance=0.25;
telescopeTubeDiameter=200; // 0 for flat mount
slideWidth=10;
rackWidth=8;

module dummy() {}

rackColor = "red";
slideColor = "blue";

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

function diamondSize(baseWidth,male=true) = (baseWidth * 0.6) + (male ? -2*printerTolerance : 2*printerTolerance);

function diamondPositions(length,width) = [width/2,length/2,length-width/2];

module drawTube() {
    clearLength = drawTubeLength-drawTubeLipHeight;
    od = drawTubeInnerDiameter+2*drawTubeWallThickness-2*printerTolerance;
    
    render(convexity=2)
    difference() {
        union() {
            cylinder(d=od, h=drawTubeLength, $fn=50);
            translate([0,0,drawTubeLength-drawTubeLipHeight]) tube(id=drawTubeInnerDiameter, wall=drawTubeWallThickness+drawTubeLipThickness, h=drawTubeLipHeight, $fn=50);
            translate([-slideWidth/2+printerTolerance,0,0])
            cube([slideWidth-2*printerTolerance,od/2,clearLength]);
            rotate([0,0,180])
            translate([-rackWidth/2+printerTolerance,0,0])            
            cube([rackWidth-2*printerTolerance,od/2,clearLength]);
        }
        translate([0,0,-nudge])
        cylinder(d=drawTubeInnerDiameter+printerTolerance, h=drawTubeLength+2*nudge, $fn=50);
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

if (includeDrawTube)
    drawTube();