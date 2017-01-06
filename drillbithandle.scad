diameter=8;
length=30;
drillBitInHandle=15;
drillBitDiameter=0.4;

module dummy() {}

nudge = 0.001;

module handle() {
    linear_extrude(height=length)
    rotate([0,0,22.5]) circle($fn=8,d=diameter);
}

module wedge() {
    linear_extrude(height=drillBitInHandle)
    circle($fn=4,d=diameter);
}

render(convexity=2)
translate([0,0,length])
rotate([180,0,0])
difference() {
    handle();
    translate([-diameter/2+drillBitDiameter/2,0,-nudge]) wedge();
}

render(convexity=2)
translate([1.5*diameter,0,0])
intersection() {
    handle();
    translate([-drillBitDiameter/2-diameter,-diameter/2,0]) cube([diameter,diameter,drillBitInHandle]);
    translate([-diameter/2+drillBitDiameter/4,0,-nudge]) wedge();
}