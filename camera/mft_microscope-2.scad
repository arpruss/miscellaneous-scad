// Copyright (c) 2020-21 otherthing and arpruss
// Based on https://www.thingiverse.com/thing:4349420
// CC-attribution

$fa=4;
$fs=0.4;
wall = 1.5;
tolerance = 1;
stopRingThickness = 0;
stopRingHeight = 2.2;
ribbed = false;

r_outer = 26-2;
include <mft.scad>

// telescope mount outer diameter
r_telescope = (25.08+tolerance)/2+wall;
r_ring = r_telescope+1;



// ocular insert diameter
rt_outer = r_telescope;

// inner diameter, wall size substracted
rt_inner = r_telescope - wall;

// height of insert part
ht1 = 25+2;

// additional height to grow to mft plate diameter
// add more here to reduce overhang
ht2 = ht1+3;
h_ring1 = ht1-2;
h_ring2 = ht1;

// shape of the telescope adapter part
telescope_points=[
[rt_inner, 0],
[rt_outer, 0],
[rt_outer, ht1],
[r_inner,  ht1],
[r_inner,  ht1+1],
[rt_inner, ht1+1],
];

helper_points=[
[rt_outer-.1, ht1-10],
[r_outer, ht1+.001],
[rt_outer-.1, ht1+.001],
];

module overhang_helper()
{
  union()
  {
    for(i=[0:10:360])
    {
      rotate([0,0,i])
        rotate([90,0,0])
          translate([0,0,-0.2])
          linear_extrude(0.7)
            polygon(helper_points);
    }
  }
}

if (ribbed) {
    overhang_helper();
}
else
translate([0,0,ht1-14+.01]) {
    difference() {
        cylinder(r1=rt_inner,r2=r_outer,h=14);
        cylinder(r=rt_inner,h=100,center=true);
    }
}

// finally, put together telescope part and mft part
union()
{
  rotate_extrude()
    polygon(telescope_points);

  translate([0,0,ht1])
    mft();

 
}

if (stopRingThickness>0) {
    sr = stopRingThickness+tolerance/2;
    translate([0,0,ht1-stopRingHeight+1])
    difference() {
        cylinder(h=stopRingHeight,r=rt_inner);
        translate([0,0,-.001])
        cylinder(h=stopRingThickness+0.001,r1=rt_inner,r2=rt_inner-sr);
        cylinder(h=stopRingHeight+0.001,r=rt_inner-sr);
    }
 
}