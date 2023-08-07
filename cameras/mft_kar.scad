// not by me, some other license, maybe see mft.scad

$fa=4;
$fs=0.4;

r_outer = 55/2;

include <mft.scad>

// difference of systems relative to base plate
// https://de.wikipedia.org/wiki/Auflagema%C3%9F
// M4/3  19.25
// Konika "K/AR" 40.50
h_adapt = 40.50-19.25-h1; // 26.21-1

innerTolerance = 0.15;
kamera_cent = 47.1/2+innerTolerance;
kamera_snap = 45/2;
kamera_outer = r_outer;
kamera_inner = kamera_outer - 1.6;
kamera_base = kamera_outer;

snapUpShift = .95+1.2;
pk_h1 = 2.5-snapUpShift;
pk_h2 = 4.3-snapUpShift;  // 

pk_h_foot = 2.5;

aa =  0;
a1 =  0;
a1d = 50;
a2 =  120;
a2d = 50;
a3 =  240;
a3d = 50;

// anti-reflexion ring  
pk_hr1 = 7;

// shape of the MD part
pk_points=[
[kamera_cent, 0],

// outer shape
[kamera_base, 0],
[kamera_base, pk_h_foot],
[kamera_outer, pk_h_foot],
[kamera_outer, h_adapt-1],
[r_outer, h_adapt],

// inner shape
[r_inner, h_adapt],
[kamera_inner, h_adapt-(kamera_inner-r_inner)/2],

[kamera_inner, pk_hr1],
[kamera_cent, pk_hr1],

//[kamera_cent, h_adapt-(kamera_cent-r_inner)/2],

];


pk_points_snap=[
[kamera_cent+.1, pk_h2],
[kamera_cent+.1, pk_h1+0.1],
[kamera_snap, pk_h1+0.7],
[kamera_snap, pk_h2],
];


module snap_shaper()
{
  translate([kamera_cent-2.5,0,pk_h1+1.5])
    rotate([0,0,45])
      cube([3,3,3],center=true);
}

module snapper(ang)
{
  rotate([1.5,0,0])
  difference()
  {
    rotate_extrude(angle=ang)
    polygon(pk_points_snap);

    snap_shaper();

    rotate([0,0,ang])
      snap_shaper();
  }
  
  rotate([0,0,ang-6]) translate([kamera_snap,0,pk_h1]) cube([pk_h_foot,pk_h_foot,5]);
}

as = 10;
module snappers()
{
  union()
  {
    rotate([0,0,a1+as])
      snapper(a1d);
    
    rotate([0,0,a2+as])
      snapper(a2d);
    
    rotate([0,0,a3+as])
      snapper(a3d);
  }
}

a_hole = 0;

module screw_hole()
{
    rotate([0,0,a_hole])
  translate([0,0,pk_h2+1.3])
      rotate([90,0,0])
        cylinder(r=1.3,h=30);
}

module screw_strenghener()
{
    rotate([0,0,a_hole])
  translate([0,-r_outer+0.5,pk_h2+1.3])
      rotate([90,0,0])
        cylinder(r=3,h=2.5);
}




module ar()
{
  difference()
  {
    union()
    {
      // basic shape
      rotate_extrude()
        polygon(pk_points);
      
      // the 3 snappers
      snappers();      
      //screw_strenghener();
    }
    //screw_hole();
  }
 
}
// finally, put together telescope part and mft part

/*
union()
{
  translate([0,0,h_adapt])
    mft();

  ar();
} */

module trimmedAR() {
    intersection() {
        rotate([180,0,0]) ar();
        cube([80,80,pk_hr1*2], center=true);
    }
}

function arHeight() = pk_hr1;
function arInnerDiameter() = 2*kamera_cent;
function arOuterDiameter() = 2*kamera_outer;

trimmedAR();

//snappers();