id = 3;
od = 6.4;
h = 7.7;

$fn = 36;

linear_extrude(height=h) difference() { circle(d=od); circle(d=id); }