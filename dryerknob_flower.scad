use <paths.scad>;
use <tubeMesh.scad>;

shaftLength = 14.65;
wellDiameter = 20.33;
wellDepth = 9.82;

height = 34;

shaftDiameter = 6;
shaftDiameterAcrossFlat = 4.8;

generousTolerance = 1.5;
tolerance = 0.11;

knobDiameter = 63;
numberOfPetals = 7;
petalDepth = 7;

knurlingAngle = 4;

outerWall = 2.5;
bottomWall = 2.5;
ribThickness = 2.5;
pointerAngle = 10;
pointerLength = 6;
dotDepth = 2;
dotDiameter = 4;

chamfer = 2;

module dummy() {}

nudge = 0.01; 
outerHeight = height-wellDepth-generousTolerance;

module knobProfile0() {
    circle(d=knobDiameter,$fn=128);
    kd = knurlingAngle / 180 * PI * knobDiameter / 2;
    for (angle = [0:knurlingAngle:360]) rotate(angle) translate([knobDiameter/2,0]) circle(d=kd,$fn=16);
}

function knobProfile(delta=0) = let(p=[for(i=[0:359]) [cos(i),sin(i)]*(knobDiameter/2-petalDepth*(1-cos(i*numberOfPetals))/2)])
        delta==0 ? p : insetPath(p,distance=delta);

module knobProfile(delta=0) {
    points = knobProfile(delta=delta);
    if (delta ==0)
        polygon(points);
    else
        polygon(insetPath(points,distance=delta));
}

module knobProfile3D(delta=0) {
    profile = [ 
        sectionZ(knobProfile(delta+chamfer),0),
        sectionZ(knobProfile(delta),chamfer),
        sectionZ(knobProfile(delta),outerHeight) 
    ];
    tubeMesh(profile);
}

module shaftHole() {
    shaftIncut = shaftDiameter - shaftDiameterAcrossFlat;
    intersection() {
        circle(d=shaftDiameter+2*tolerance,$fn=32);
        translate([-shaftIncut,0]) square(shaftDiameter+tolerance,center=true);
    }
}

module pointer() {
    intersection() {
       
        linear_extrude(height=outerHeight)
            polygon([
            knobDiameter/2*[cos(pointerAngle/2),-sin(pointerAngle/2)]-[outerWall+chamfer,0],
            knobDiameter/2*[cos(pointerAngle/2),-sin(pointerAngle/2)],
            [knobDiameter/2+pointerLength,0],
            knobDiameter/2*[cos(pointerAngle/2),sin(pointerAngle/2)],
            knobDiameter/2*[cos(pointerAngle/2),sin(pointerAngle/2)]
            -[outerWall+chamfer,0]]);
        cylinder(r1=knobDiameter/2-chamfer,r2=knobDiameter/2+outerHeight,$fn=128,h=outerHeight);
    }
}

module main() {
    difference() {
        union() {
            pointer();
            difference() {
                knobProfile3D();
                translate([0,0,bottomWall]) knobProfile3D(outerWall);
            }
            for (i=[0:numberOfPetals-1]) let(angle=i/numberOfPetals*360) rotate([0,0,angle]) translate([0,-ribThickness/2,bottomWall-nudge]) cube([knobDiameter/2-outerWall/2,ribThickness,height-wellDepth-generousTolerance-bottomWall+nudge]);
            linear_extrude(height=height) circle(d=wellDiameter-generousTolerance*2);
                
        }
        translate([0,0,height-shaftLength]) { 
            linear_extrude(height=shaftLength+nudge) shaftHole();
        }
    }
}

module test() {
    h = 17;
    linear_extrude(height=h)
    difference() {
        circle(d=wellDiameter-2*generousTolerance);
        shaftHole();
    }
    linear_extrude(height=h-wellDepth-generousTolerance) {
        difference() {
            circle(d=40,$fn=4);
            shaftHole();
        }
    }
}

difference() {
    main();
    translate([knobDiameter/2-petalDepth,0,0]) cylinder(d=dotDiameter,h=dotDepth,$fn=32,center=true);
}

