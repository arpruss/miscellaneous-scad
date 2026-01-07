sonyHeight = 30;
gotekHeight = 24.75;

extraHeight = sonyHeight-gotekHeight;
frontLip = 2.63;
width = 101.4;
depth = 10;
thickness = 9.8;
screwHead = 6;
screwHeadFromBottom = 3;
screwFromSide = 20;
screwHole = 3.1;

$fn = 32;
difference() {
    translate([-width/2,0,0]) cube([width,depth,extraHeight]);
    for (s=[1,-1]) translate([s*(width/2-screwFromSide),(frontLip+depth)/2]) {
        cylinder(h=extraHeight*3,d=screwHole,center=true);
        translate([0,0,screwHeadFromBottom]) cylinder(h=extraHeight*3,d=screwHead);
    }
}