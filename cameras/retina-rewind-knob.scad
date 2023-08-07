//<params>
knobDiameter = 24.2;
knurlingAngle = 6;
height = 4.5;
bevel = 0.75;
screwShaftDiameter = 3; // M3 screw
screwHeadDiameter = 5.77;
screwHeadThickness = 2.12;
screwTolerance = 0.05;
screwHeadNarrowing = 0.6;

//</params>

module dummy(){}

nudge = 0.001;
$fn = 128;

module knobProfile() {
    innerDiameter = knobDiameter / (1+  knurlingAngle / 180 * PI / 2);
    kd = knurlingAngle / 180 * PI * innerDiameter / 2;
    circle(d=innerDiameter,$fn=128);
    for (angle = [0:knurlingAngle:360]) rotate(angle) translate([innerDiameter/2,0]) circle(d=kd,$fn=16);
}

module basicKnob() {
    intersection() {
        linear_extrude(height=height)
            knobProfile();
        cylinder(d1=knobDiameter-2*bevel,d2=2*height+knobDiameter-2*bevel,h=height);
        cylinder(d2=knobDiameter-2*bevel,d1=2*height+knobDiameter-2*bevel,h=height);
    }
}

module screwHeadHole() {
    d = screwHeadDiameter + 2 * screwTolerance;
    intersection() {
        circle(d=d);
        square([d,d-2*screwHeadNarrowing],center=true);
    }
}

module knob() {
    t = screwHeadThickness - screwTolerance;
    difference() {
        basicKnob();
        translate([0,0,-nudge])
        cylinder(d=screwShaftDiameter+screwTolerance*2,h=height+2*nudge);
        translate([0,0,height-t])  linear_extrude(height=t+nudge)
            screwHeadHole();
    }
}

knob();