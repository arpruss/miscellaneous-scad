$fn=50;

// http://dkprojects.net/openscad-threads/threads.scad
use <threads.scad>

// inner diameter of pipe
pipe_id=21.5;
// how deep attachment should sit in pipe
pipe_depth=40;
// flatten one side (no supports required)
flatten=true;

difference() {
   rotate([90,-45,0]) {
      metric_thread(diameter=18, pitch=5, length=22, internal=false, square=true, leadin=1);
      //taper out the last thread a little
      cylinder(d2=13, d1=16, h=5);
      translate([0,0,-4]) cylinder(d=max(23, pipe_id+2), h=4);
      translate([0,0,-(pipe_depth+4)]) cylinder(d=pipe_id, h=pipe_depth);
   }
   if (flatten)
      translate([0,0,-58]) cube(100, center=true);
}
