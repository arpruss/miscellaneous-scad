height = 47.05;
topDiameter = 107.21;
nearBottomDiameter = 91.4;
nearBottomHeight = 5.74;
lip = 4.22;
tolerance = 0.5;

module dummy() {}

nudge = 0.001;
$fn = 128;

slope = (topDiameter-nearBottomDiameter)/(height-nearBottomHeight)/2;

diff = 2*height*slope;
bottomDiameter = topDiameter - diff;

difference() {
    cylinder(d1=bottomDiameter + 2*diff + 2*lip, d2=topDiameter + 2*lip, h=height);
    translate([0,0,-nudge]) cylinder(d1=bottomDiameter + 2*tolerance, d2=topDiameter+2*tolerance, h=height+2*nudge);
}