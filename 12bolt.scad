use <threads.scad>;
use <beveledCube.scad>;

//<params>
length = 1;
shift = 2.5;
tolerance = 1; // in mm
bevelEdges = true;
bevel = 2;
//</params>

intersection(){
    translate([0,0,.25*25.4-2.5]) rotate([90,0,0]) 
    translate([0,0,9.9-bevel]) english_thread(diameter=0.5-tolerance/25.4, threads_per_inch=13, length=length+bevel/25.4);
    translate([-100,-100,0]) cube([200,200,200]);
}
translate([-20,-10,0]) beveledCube([40,10,10],bevelEdges=true, bevel=bevel);