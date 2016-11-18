xspacing = 3*1.4;
yspacing = 1.6;

outerwidth = 100;
outerheight = 50;
rim = 5;

netwidth = 0.5;
xsize = outerwidth;
ysize = outerheight;

for (i=[0:xsize/xspacing]) {
    translate([xspacing*i,0,0]) rotate([90,0,0]) linear_extrude(height=ysize) square([0.5,0.5],center=true);
}

for (i=[0:ysize/yspacing]) {
    translate([0,-yspacing*i,0]) rotate([0,90,0]) linear_extrude(height=xsize) square([0.5,0.5],center=true);
}
