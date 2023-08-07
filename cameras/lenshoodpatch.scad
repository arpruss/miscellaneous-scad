d1 = 72.5;
d2 = 72.65;
h1 = 6.06;
h2 = 6.37;
d3 = 81.55;
tolerance = 0.2;
wallBottom = 1;

module dummy() {}

ID1 = d1 + 2 * tolerance;
ID2 = d2 + 2 * tolerance;
ID3 = d3 + 2 * tolerance;

OD1 = ID1 + wallBottom * 2;
OD3 = ID3;

nudge = 0.01;

$fn = 72;

difference() {
    cylinder(d1=OD1,d2=OD3,h=h1+h2);
    translate([0,0,-nudge]) cylinder(d1=ID1,d2=ID2,h=h1+2*nudge);
    translate([0,0,h1-nudge]) cylinder(d1=ID2,d2=ID3,h=h2+2*nudge);
}