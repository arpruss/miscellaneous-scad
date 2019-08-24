use <tubemesh.scad>;

d = 100;
h = 80;
ratio = 1.25;
width = 4;
angle = 45;
sides = 6;
holeSize = 8;
holes = 4;


module dummy() {}

nudge = 0.001;

module solid(delta=0) {
    morphExtrude(ngonPoints(n=sides,d=d-delta*2,rotate=delta>0 ? 0 : angle * width/h),ngonPoints(n=sides,d=ratio*d-delta*2),twist=angle,height=h,numSlices=40);
}

difference() {
    solid();
    difference() {
        translate([0,0,nudge]) solid(delta=width);
        cube([4*d,4*d,2*width],center=true);
    }
    for (i=[0:1:holes-1]) {
        rotate([0,0,360/holes*i]) translate([d*.5*.4,0,0]) cylinder(d=holeSize,h=width*4,center=true,$fn=16);
    }
}