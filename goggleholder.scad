use <quickthread.scad>;

diameter = 47;
innerHole = 20;
height = 190;
lidHeight = 15;
wall = 1.5;
threadPitch = 5;
threadTolerance = 1.2;
cylinderTolerance = 0.7;

module dummy(){}

$fn =64;

nudge = 0.001;

module thread(internal=false) {
isoThread(d=diameter+(internal?cylinderTolerance*2:0)+2*wall-nudge*2, h=lidHeight-wall, pitch=threadPitch, angle=50, starts=2, internal=internal, minorD = true, clipBottom=internal, bottomShrinkAngle=internal?0:180);
}

module lid() {
    difference() {
        cylinder(d=diameter+cylinderTolerance*2+6*wall,h=lidHeight);
        translate([0,0,wall+nudge]) thread(internal=true);
    translate([0,0,-5])cylinder(d=innerHole,h=lidHeight+10); translate([0,0,wall]) cylinder(d=diameter,h=height);

    }
}

module box() {
    difference() {
        union() {
            cylinder(d=diameter+2*wall,h=height-(lidHeight-wall));
            translate([0,0,height-(lidHeight-wall)]) thread(internal=false);
        }
    translate([0,0,-5])cylinder(d=innerHole,h=height+10);
    translate([0,0,wall]) cylinder(d=diameter,h=height);
    }
}

lid();
translate([4*wall+diameter+10,0,0]) box();