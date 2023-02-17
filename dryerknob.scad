shaft = 14.65;
wellDiameter = 20.33;
wellDepth = 9.82;
shaftRing = 10;

height = 34;

shaftDiameter = 7;
shaftIncut = 1;

generousTolerance = 1.5;
tolerance = 0.22; 

knobDiameter = 63;
knurlingAngle = 4;

outerWall = 4;
bottomWall = 3;
ribs = 8;
ribThickness = 3;
pointerAngle = 10;
pointerLength = 4;

chamfer = 2;

nudge = 0.01;

module knobProfile() {
    circle(d=knobDiameter,$fn=128);
    kd = knurlingAngle / 180 * PI * knobDiameter / 2;
    for (angle = [0:knurlingAngle:360]) rotate(angle) translate([knobDiameter/2,0]) circle(d=kd,$fn=16);
}

module shaftHole(constrict=0) {
    intersection() {
        circle(d=shaftDiameter+tolerance-constrict,$fn=32);
        translate([-shaftIncut-constrict*shaftIncut/shaftDiameter,0]) square(shaftDiameter+tolerance,center=true);
    }
}

module main() {
    outerHeight = height-wellDepth-generousTolerance;
    intersection() {
                    cylinder(r1=knobDiameter/2-chamfer,r2=knobDiameter/2-chamfer+height,h=height,$fn=128);
    difference() {
        union() {
            difference() {
                linear_extrude(height=outerHeight) knobProfile();
                translate([0,0,bottomWall]) intersection() 
                { 
                    cylinder(d=knobDiameter-outerWall*2,h=height+nudge-bottomWall);
                    cylinder(d1=knobDiameter-outerWall*2-chamfer,d2=knobDiameter-outerWall*2-chamfer+height, h=height);
                }
            }
            linear_extrude(height=height-wellDepth-generousTolerance)
            polygon([knobDiameter/2*[cos(pointerAngle/2),-sin(pointerAngle/2)],
            [knobDiameter/2+pointerLength,0],
            knobDiameter/2*[cos(pointerAngle/2),sin(pointerAngle/2)]]);
            linear_extrude(height=height) circle(d=wellDiameter-generousTolerance*2);
            for (i=[0:ribs-1]) let(angle=i/ribs*360) rotate([0,0,angle]) translate([0,-ribThickness/2,0]) cube([knobDiameter/2,ribThickness,height-wellDepth-generousTolerance]);
        }
        translate([0,0,height+nudge-shaft]) { linear_extrude(height=shaft) shaftHole(constrict=0.65);
            translate([0,0,shaft-shaftRing]) linear_extrude(height=shaftRing+nudge) shaftHole(0);
        }
    }
}
}

module test() {
    h = 20;
    linear_extrude(height=20)
    difference() {
        circle(d=wellDiameter-2*generousTolerance);
        shaftHole();
    }
    linear_extrude(height=h-wellDepth-generousTolerance) {
        difference() {
            circle(d=40,$fn=6);
            shaftHole();
        }
    }
}

main();
//test();