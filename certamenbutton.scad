height = 50;
innerDiameter = 60;
label = "C4";
font = "Arial Black:style=Bold";
labelSize = 9;
textPositionAdjustment = 1;
baseThickness = 5.53; // FIX to fit wood disc
screwHoleSize = 2.5;
screwPillarDiameter = 12;
cablePortThickness = 3;

holeDiameterMain = 28.88;
tolerance = 0.25;
snapThickness = 1.5;
snapWidth = 7.25;
antiRotation = 2.3;

wallThickness = 2.5;
topThickness = 3;
textDepth = 2;
chamfer = 3;
cableHoleDiameter = 4.9; 
cableHoleBottomSquish = 1;
screwCountersinkDepth = 2;
screwCountersinkDiameter = 5;

includeBase = 1; // [1:yes, 0:no]
includeMain = 1; // [1:yes, 0:no]

module dummy() {}

baseThicknessAdj = baseThickness + tolerance;

outerDiameter = innerDiameter + 2*wallThickness + 2*tolerance; 
nudge = 0.01;

module chamferedCylinder(h=height, d=outerDiameter, chamfer=chamfer) {
    cylinder(h=chamfer*1.5+nudge, d1=d-2*chamfer, d2=d);
    translate([0,0,chamfer*1.5]) cylinder(h=h-chamfer*1.5, d=d);
}

module screws() {
    for(angle=[0:180:180]) rotate([0,0,angle]) {
            translate([-outerDiameter/2+wallThickness/2+screwPillarDiameter/2,-screwPillarDiameter/2-cableHoleDiameter/2-tolerance,-nudge]) children();
            translate([-outerDiameter/2+wallThickness/2+screwPillarDiameter/2,screwPillarDiameter/2+cableHoleDiameter/2+tolerance,-nudge]) children();
    }
}

module screwPillar() {
    difference() {
        cylinder(d=screwPillarDiameter, h=height-baseThicknessAdj,$fn=12);
        translate([0,0,height-baseThicknessAdj-15+nudge])
        cylinder(d=screwHoleSize+2*tolerance, h=15, $fn=12);
    }
}

module cable() {
    translate([0,0,height-cableHoleDiameter/2-tolerance-baseThicknessAdj+cableHoleBottomSquish])
rotate([0,90,0]) {
    translate([-cableHoleDiameter/2-tolerance-baseThicknessAdj/2,0,0])
    cube([cableHoleDiameter+2*tolerance+baseThicknessAdj,cableHoleDiameter+2*tolerance,1.5*outerDiameter+2*cablePortThickness], center=true);
    translate([0,0,-0.75*outerDiameter-cablePortThickness]) 
    cylinder(h=1.5*outerDiameter,d=cableHoleDiameter+2*tolerance);
}
}

module portCover() {
    translate([0,cableHoleDiameter/2+tolerance+cablePortThickness,height])
    rotate([90,0,0])
    linear_extrude(height=cableHoleDiameter+2*tolerance+2*cablePortThickness)
    polygon([[-cablePortThickness,0],[0,0],[0,-baseThicknessAdj-cableHoleDiameter+cableHoleBottomSquish-2*tolerance-cablePortThickness*2],[-cablePortThickness,-baseThicknessAdj-cableHoleDiameter-cablePortThickness+cableHoleBottomSquish-2*tolerance]]);
}


module mainCylinder() {
    render(convexity=4)
    difference() {
        union() {
            intersection() {
                chamferedCylinder();
                union() {
                    difference() {
                        chamferedCylinder();
                        translate([0,0,topThickness]) chamferedCylinder(h=height-topThickness+nudge, d=outerDiameter-wallThickness);
                    }
                    screws() screwPillar();
                }
            }
            for(angle=[0:180:180]) rotate([0,0,angle]) translate([-outerDiameter/2+wallThickness/2,0,0])  portCover();
        }
        cable();
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

$fn = 72;
if (includeMain)
 mainCylinder();

if (includeBase) 
{
    render(convexity=3)
    translate([outerDiameter+cablePortThickness,0,0]) {    difference() {
            cylinder(d=innerDiameter-2*tolerance, h=baseThickness);
            screws() {
                cylinder(d=screwHoleSize+2*tolerance,h=baseThicknessAdj+2*nudge,$fn=12);
                translate([0,0,baseThickness-screwCountersinkDepth-tolerance])
                cylinder(d=screwCountersinkDiameter+2*tolerance,h=screwCountersinkDepth+tolerance+nudge,$fn=12);
            }
        }
    }
}