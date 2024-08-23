wall = 1.25;
slit = 2.3;
depth = 7;
height = 4;
hole = 2;

$fn = 16;

difference() {
    cube([2*wall+slit,depth,height]);
    translate([wall,-wall,-height]) #cube([slit,depth,height*3]);
    translate([wall+slit/2,0,height/2]) rotate([90,0,0]) cylinder(h=100,d=hole,center=true);
}