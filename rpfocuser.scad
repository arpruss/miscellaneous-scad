use <Zahnstange_und_ritzel.scad>;

printerTolerance=0.25;
axleDiameter=3;
drawTubeInnerDiameter=33;
drawTubeWallThickness=2.25;
drawTubeLength=50;
drawTubeLipThickness=2;
drawTubeLipHeight=5;
eyepieceSetScrewDiameter=3;
outerTubeLength=30;
focuserTubeTolerance=0.25;
telescopeTubeDiameter=200; // 0 for flat mount

module dummy() {}

nudge = 0.001;

module tube(id=undef, od=undef, wall=undef, h=1) {
    innerDiameter = id==undef ? od-wall : id;
    outerDiameter = od==undef ? id+wall : od;

    render(convexity=2)
    difference() {
        cylinder(d=outerDiameter, h=h);
        translate([0,0,-nudge])
            cylinder(d=innerDiameter, h=h+2*nudge);
    }
}

module drawTube() {
    difference() {
        union() {
            tube(id=drawTubeInnerDiameter, wall=drawTubeWallThickness, h=drawTubeLength, $fn=50);
            translate([0,0,drawTubeLength-drawTubeLipHeight]) tube(id=drawTubeInnerDiameter, wall=drawTubeWallThickness+drawTubeLipThickness, h=drawTubeLipHeight, $fn=50);
        }
        translate([drawTubeInnerDiameter/2-drawTubeLipThickness,0,drawTubeLength-drawTubeLipHeight/2])
        rotate([0,90,0])
        cylinder(d=eyepieceSetScrewDiameter, h=4*drawTubeLipThickness,$fn=16);
    }
}

drawTube();