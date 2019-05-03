use <quickthread.scad>;

diameter = 40;
height = 100;
lidHeight = 15;
wall = 1.5;
threadPitch = 5;
threadTolerance = 1.2;
cylinderTolerance = 0.7;

module dummy(){}

$fn =64;

nudge = 0.001;

module thread(internal=false) {
isoThread(d=diameter+(internal?cylinderTolerance*2:0)+2*wall-nudge*2, h=lidHeight-wall, pitch=threadPitch, angle=50, starts=2, internal=internal, minorD = true, clipBottom=false, bottomShrinkAngle=90);
}

module lid() {
    difference() {
        cylinder(d=diameter+cylinderTolerance*2+6*wall,h=lidHeight);
        translate([0,0,wall+nudge]) thread(internal=true);

    }
}

module box() {
    difference() {
        union() {
            cylinder(d=diameter+2*wall,h=height-(lidHeight-wall));
            translate([0,0,height-(lidHeight-wall)]) thread(internal=false);
        }
        translate([0,0,wall]) cylinder(d=diameter,h=height);
    }
}

lid();
translate([4*wall+diameter+10,0,0]) box();