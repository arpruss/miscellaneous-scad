fanThickness = 25;
fanOuterDiameter = 72;
fanInnerDiameter = 25;

bladeAngle = 60;
bladeThickness = 2;
numberOfBlades = 7;

fanNubSideWall = 3;
fanNubBottomWall = 3;
motorShaftDiameter = 6;
motorShaftMountWall = 2;
motorShaftMountHeight = 6;
motorShaftTolerance = 0.2;

module dummy() {} 

nudge = 0.01;
bigNudge = 0.1;
$fn = 128;


module blade() {
    bladeSize = fanOuterDiameter;
        translate([0,0,fanThickness/2])
        rotate([(90-bladeAngle),0,0]) translate([bladeSize/2,0,0]) cube([bladeSize,bladeThickness,2*bladeThickness+fanThickness/cos(90-bladeAngle)],center=true);
}

module fan() {
    difference() {
        union() {
            cylinder(d=fanInnerDiameter+nudge, h=fanThickness);
            intersection() {
                for (i=[0:numberOfBlades-1]) rotate([0,0,360/numberOfBlades*i]) blade();
                cylinder(d=fanOuterDiameter,h=fanThickness);
            }
        }
        translate([0,0,fanNubBottomWall+nudge])
        cylinder(d=fanInnerDiameter-fanNubSideWall*2,h=fanThickness-fanNubBottomWall);
    }
}

difference() {
    union() {
        fan();
        cylinder(d=motorShaftDiameter+2*motorShaftTolerance+2*motorShaftMountWall,h=motorShaftMountHeight);
    }
    translate([0,0,-nudge]) cylinder(d=motorShaftDiameter+2*motorShaftTolerance,h=motorShaftMountHeight+2*nudge);
}

