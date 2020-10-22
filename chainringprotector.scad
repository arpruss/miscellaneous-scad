outerDiameter = 205;
outerInset = 10;
stickout = 5;
standoffLength = 5.5;
standoffDiameter = 6;
standoffConnectorMinimumHeight = 3;
screwHole = 3;
screwSpacing1 = 119.5;
screwSpacing2 = 109.4;
crankGap = 40;
chamfer = 1;

flatWall = 2;
curvedWall = 2;

module dummy() {}

standoffR = norm([screwSpacing1,screwSpacing2])/2;
standoffAngle1 = 2*asin(screwSpacing1/(2*standoffR));
standoffAngle2 = 2*asin(screwSpacing2/(2*standoffR));
standoffAngles = [0,standoffAngle1,standoffAngle1+standoffAngle2,standoffAngle1+standoffAngle2+standoffAngle1];
echo(standoffR,standoffAngle1,standoffAngle2);

nudge = 0.01;

$fn = 128;

module hollowCylinder(id,od,height,arc=360) {
    linear_extrude(height=height) {
        intersection() {
            difference() {
                circle(d=od);
                circle(d=id);
            }
            if (arc<360) {
                polygon(concat([[0,0]], [for(i=[0:1:$fn]) let(angle=-arc/2+arc*i/$fn) (od+id)/4 * [cos(angle),sin(angle)]]));
            }
        }
}
}

d1 = outerDiameter-2*outerInset-2*curvedWall;
d2 = outerDiameter-2*outerInset;
d3 = outerDiameter;

module main() {
    hollowCylinder(d1,d3,flatWall);
    hollowCylinder(d1,d2,flatWall+stickout);
    translate([0,0,flatWall-nudge])
    rotate_extrude() {
        translate([d2/2-nudge,0]) polygon([[0,0],[chamfer,0],[0,chamfer]]);
    }
}

module standoffs() {
    for(angle=standoffAngles) rotate([0,0,angle]) {
        difference() {
            hull() 
            {
                translate([standoffR,0,0]) hollowCylinder(screwHole,standoffDiameter,standoffLength+flatWall+stickout);
                hollowCylinder(d1,d1+nudge,standoffConnectorMinimumHeight,arc=25);
            }
            translate([standoffR,0,-5]) cylinder(d=screwHole,h=standoffLength+flatWall+stickout+10);
        }
    }
}


difference() {
    union() {
        main();
        standoffs();
    }

/*    rotate([0,0,45]) 
    
    translate([0,-crankGap/2,flatWall]) cube([outerDiameter+1,crankGap,standoffLength+flatWall+stickout+10]);
    */
}