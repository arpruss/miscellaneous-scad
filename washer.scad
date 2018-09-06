r = 4.5;
id = 4;
h = 3;

$fn = 16;

difference() {
cylinder(h=h,r=r);
translate([0,0,-1])
cylinder(h=h+2,d=id);
}