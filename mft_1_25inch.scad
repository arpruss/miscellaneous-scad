$fa=4;
$fs=0.4;
wall = 1.5;
tolerance = 0.2;


r_outer = 26;
include <mft.scad>

// telescope mount outer diameter
r_telescope = (25.08+tolerance)/2+wall;
r_ring = r_telescope+1;



// ocular insert diameter
rt_outer = r_telescope;

// inner diameter, wall size substracted
rt_inner = r_telescope - wall;

// height of insert part
ht1 = 25;

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
[rt_outer, ht1-10],
[r_outer, ht1],
[rt_outer, ht1],
];

module overhang_helper()
{
  union()
  {
    for(i=[0:15:360])
    {
      rotate([0,0,i])
        rotate([90,0,0])
          translate([0,0,-0.2])
          linear_extrude(0.41)
            polygon(helper_points);
    }
  }
}

overhang_helper();

// finally, put together telescope part and mft part
union()
{
  rotate_extrude()
    polygon(telescope_points);

  translate([0,0,ht1])
    mft();

 
}

