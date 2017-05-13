height = 50;
outerDiameter = 65; // FIX to fit wood disc
label = "C4";
font = "Arial Black:style=Bold";
labelSize = 9;
textPositionAdjustment = 1;

holeDiameterMain = 28.88;
tolerance = 0.25;
snapThickness = 1.5;
snapWidth = 7.25;
antiRotation = 2.3;

wallThickness = 2.5;
topThickness = 3;
textDepth = 2;
chamfer = 3;
cableThickness = 5; //FIX


module dummy() {}

nudge = 0.01;

module chamferedCylinder(h=height, d=outerDiameter, chamfer=chamfer) {
    cylinder(h=chamfer*1.5+nudge, d1=d-2*chamfer, d2=d);
    translate([0,0,chamfer*1.5]) cylinder(h=h-chamfer*1.5, d=d);
}

module mainCylinder() {
    render(convexity=4)
    difference() {
        chamferedCylinder(h=height, d=outerDiameter);
        translate([0,0,topThickness]) chamferedCylinder(h=height-topThickness+nudge, d=outerDiameter-wallThickness);
        rotate([0,0,90]) {
            translate([0,0,-nudge]) cylinder(h=2*nudge+topThickness, d=holeDiameterMain+2*tolerance);
            for (angle=[0:180:180]) 
                rotate([0,0,angle]) 
                    translate([0,-snapWidth/2,-nudge])
                    cube([holeDiameterMain/2+tolerance+snapThickness,snapWidth,2*nudge+topThickness]);
            for (angle=[45:90:360-45]) rotate([0,0,angle]) translate([holeDiameterMain/2+tolerance,0,-nudge]) cylinder(d=antiRotation+2*tolerance,h=topThickness+2*nudge);
        }
        translate([0,holeDiameterMain/4+(outerDiameter/4-chamfer/2)-.08*labelSize+textPositionAdjustment,textDepth-nudge]) rotate([180,0,0]) linear_extrude(height=textDepth) text(label, font=font, size=labelSize, halign="center", valign="center");
    }
}

$fn = 70;
mainCylinder();
