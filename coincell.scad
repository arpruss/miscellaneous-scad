cellThickness = 3.2;
cellDiameter = 20;
radialTolerance = 0.5;
sideTolerance = 0.1;
wireHoleDiameter = 1.75;
wireHoleSpacing = 3;
edgeWall = 1.5;
frontAndBackWall = 1;
heightFraction = 0.8;
baseFraction = 0.6;
graspDiameterFraction = 0.55;
wireVerticalOffset = 3;
labelSize = 4;

module dummy() {}

outerDiameter = cellDiameter+2*radialTolerance+2*edgeWall;

$fn = 32;
nudge = 0.001;

cy = outerDiameter/2;

module minus(size) {
    if (0<size)
        square([size,size*.3],center=true);
}

module outline(minusLabel=false) {
    bottom = baseFraction * outerDiameter;
    wy = outerDiameter*heightFraction - graspDiameterFraction*outerDiameter/2-wireVerticalOffset-wireHoleDiameter/2;
    wspace = wireHoleSpacing + wireHoleDiameter;
    difference() {
        intersection() {
            hull() {
                translate([0,cy]) circle(d=outerDiameter);
                translate([-bottom/2,0]) square([bottom,nudge]);
            }
            translate([-outerDiameter/2,0]) square([outerDiameter,outerDiameter*heightFraction]);
        }
        translate([0,outerDiameter*heightFraction]) circle(d=graspDiameterFraction*outerDiameter);
        for (s=[-1,1]) translate([s*wspace/2,wy]) circle(d=wireHoleDiameter);
        translate([0,(wy-wireHoleDiameter/2)/2]) 
        if (minusLabel)
            minus(labelSize);
    }
}

module holderEdge() {
    intersection() {
        difference() {
            hull() outline();
            translate([0,cy]) circle(d=cellDiameter+2*radialTolerance);
        }
        translate([-outerDiameter/2,0]) square([outerDiameter,outerDiameter/2]);
    }
}

module holder() {
    linear_extrude(height=frontAndBackWall+nudge) outline(minusLabel=true);
    translate([0,0,frontAndBackWall]) linear_extrude(height=cellThickness+2*sideTolerance+nudge) holderEdge();
    translate([0,0,frontAndBackWall+cellThickness+2*sideTolerance+nudge]) linear_extrude(height=frontAndBackWall) outline();
}

rotate([90,0,0]) holder();