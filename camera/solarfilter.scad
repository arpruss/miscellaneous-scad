inset = 5.8;
outerDiameter = 65;
tabThickness = 1.5;
innerDepth = 15;
outerDepth = 10;
tabLength = 17;
tolerance = 0.25;
minimumThickness = 0.5;
thickness = 1.75;
rotatedTabDepth = 6.4;
chamfer = 0.5;

thickness1 = max(thickness, tabThickness+minimumThickness);
diameter1 = outerDiameter + 2 * tolerance;
diameter2 = diameter1 + thickness1 * 2 + 2 * tolerance;
diameter3 = diameter2 + 2 * tolerance;
diameter4 = diameter3 + 2 * thickness;

nudge = 0.01;
$fn = 72;
tabAngle = 2 * atan2(tabLength/2, diameter1/2);

module tab() {
    intersection() {
        difference() {
            circle(d=diameter1+tabThickness*2);
            circle(d=diameter1-5);
        }
        translate([0,-tabLength/2]) square([diameter1, tabLength]);
    }
}

module innerBase() {
    difference() {
        linear_extrude(height=innerDepth)
        difference() {
            circle(d=diameter2);
            circle(d=diameter1);
            for (a=[0:120:240]) rotate(a) tab();
        }
        linear_extrude(height=rotatedTabDepth)
            for (a=[0:120:240]) rotate(a-tabAngle+0.2) tab();
    }
    linear_extrude(height=thickness)
    difference() {
        circle(d=diameter2);
        circle(d=diameter2-inset*2);
    }
}

module inner() {
    intersection() {
        innerBase();
        cylinder(d1=diameter2-2*chamfer,d2=diameter2+innerDepth*2-2*chamfer,h=innerDepth*1.75);
    }
}

module outer() {
    linear_extrude(height=outerDepth)
    difference() {
        circle(d=diameter4);
        circle(d=diameter3);
    }
    linear_extrude(height=thickness)
    difference() {
        circle(d=diameter4);
        circle(d=diameter2-inset*2);
    }
}

inner();
//translate([diameter4+5,0,0]) outer();