lensDiameter = 60;
tolerance = 0.25;
thickness = 2;
capDepth = 10;
bumpDepth = 0.25;
bumpPosition = 6.5;

module annulus(d1,d2) {
    difference() {
        circle(d=max(d1,d2));
        circle(d=min(d1,d2));
    }
}

module chamferedRing(d1,d2,h,inside=false) {
    D = max(d1,d2);
    d = min(d1,d2);
    w = (D-d)/2;
    h1 = inside?h:h-w/2;
    h2 = inside?h-w/2:h;
    rotate_extrude() polygon([[d/2,0],[D/2,0],[D/2,h1],[(d+D)/4,h],[d/2,h2]]);
}

$fn = 128;

D = tolerance*2 + thickness*2 + lensDiameter;
cylinder(d=D,h=thickness);
chamferedRing(D,lensDiameter+2*tolerance,thickness+capDepth,inside=true);
for (a=[0,180]) rotate([0,0,a]) 
translate([-lensDiameter/2-tolerance,-0.5,bumpPosition+thickness]) cube([bumpDepth,1,2]);