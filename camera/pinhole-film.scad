canInside = 91.66;
canOutside = 101.31;
thickness = 3.5;
insideThickness = 2;

bottomWidth = 18;
tolerance = 0.42;
insideHeight = 13;
outsideHeight = 10;

$fn = 128;

od = canOutside + 2 * tolerance + 2 * thickness;

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

linear_extrude(height=thickness) annulus(od,od-bottomWidth*2);
chamferedRing(od,canOutside + 2*tolerance,outsideHeight+thickness,true);
chamferedRing(canInside-2*tolerance,canInside-2*tolerance-2*insideThickness,insideHeight+thickness,false);