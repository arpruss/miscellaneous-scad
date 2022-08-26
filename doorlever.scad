spindleWidth = 8.38;
spindleHeight = 7.84;
spindleDepth = 28;
depthTolerance = 2;
spindleTolerance = 0.2;
spindleExpansion = 1.1;
extraDepth = 5;
mainDiameter = 64;
shaftDiameter = 25;
handleWidth = 25;
handleLength = 102;
minThickness = 6;
screwHoleDiameter = 4;

height = spindleDepth+spindleTolerance+extraDepth;

$fn = 72;

difference() {
union() {
cylinder(d1=shaftDiameter,d2=mainDiameter,h=height);
linear_extrude(height=handleWidth) {
    hull() {
        circle(d=shaftDiameter);
        translate([handleLength,0]) circle(d=minThickness);
    }
}
}
translate([0,0,extraDepth]) hull() {
translate([0,0,height-extraDepth])
cube([spindleWidth*spindleExpansion+spindleTolerance,spindleHeight*spindleExpansion+spindleTolerance,.01],center=true);
cube([spindleWidth+spindleTolerance,spindleHeight+spindleTolerance,.01],center=true);
}
translate([0,0,height/2])
rotate([90,0,0])
cylinder(d=screwHoleDiameter,h=2*mainDiameter,center=true);
}