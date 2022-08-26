// Copyright (c) 2020 otherthing 
// Based on https://www.thingiverse.com/thing:4349420
// CC-attribution

inch = 25.4;

tweak1 = 0.15;
tweak2 = 0.4;

// MD:  43.50
// MFT: 19.25
// diff 24.25


// heights of several stages...
h1 = 2.5; 		// base plate 
h2 = h1 + 1.2 - tweak1; 	//center ring over base plate 0.1205*inch;
h3 = h1 + 2.9 + tweak2; 	//lower end of snappers
h4 = h1 + 4.8;	//upper end of snappers
h4a = h4-0.6;


// outer disk diameter, must be big enough to host the snap hole
//r_outer = 26; //to be set by includer...

// sensor diag is 21.63 
// 
r_3 = 40.8/2; // outer dia of bayonett segments
r_2 = 38.2/2; // between bayonett and center ring
r_1 = 41.2/2; // center-ring dia balow bayonett

// overhang reducer for bayonett 
ang = 0.15; // lower val=more overhang

r_inner = r_2-1.6;
r_inner2 = r_2-0.8;


// basic adapter structure
points = [
[r_inner,0],
[r_outer,0],
[r_outer,h1],
[r_1,h1],
[r_1,h2],
[r_2,h2],
[r_2,h3-ang],
[r_3,h3+ang],
[r_3,h4-2*ang],
[r_2,h4],
[r_inner2,h4],
[r_inner2,h4a],
[r_inner,h4a],
for(i=[0:4])
 for (j=[0:1])
  [r_inner-j, h4a-i],

];


// radius of triangle to shape the bayonett segments
r_tri = 31;

// triangle
p_tri = [
[-r_tri,0],
[sin(30)*r_tri,sin(60)*r_tri],
[sin(30)*r_tri,-sin(60)*r_tri],
];

module triangle()
{
  linear_extrude(h4)
  polygon(p_tri);
}


// the mft connector
module mft()
{
  intersection()
  {
    difference()
    {
    rotate_extrude()
      polygon(points);
    
      //for (angle=[0,120,240]) rotate([0,0,angle])   
    translate([-1.15,-25,0])  
      cube([2.1,4,h1+1]);

    translate([-r_outer-1.5,0,0])  
      cylinder(r=3,h=h1+1);
    }
    union()
    {
      cylinder(r=r_2, h=h4);
        
      translate([-r_outer,-r_outer,0])
        cube([r_outer*2,r_outer*2,h3-0.01-ang]);

      triangle();
    }
  }
}

//mft(); // test
