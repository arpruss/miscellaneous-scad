use <noun_1269.scad>;

pieceWidth = 25;
pieceHeight = 20;
inset = 2;
insetAngle = 55;
tolerance = 0.5;

module dummy() {}

$fn = 36;
nudge = 0.01;
ratio = tan(insetAngle);

module baseInset() {
    cylinder(d1=pieceWidth-inset*2-tolerance*2,d2=pieceWidth,h=inset*ratio+tolerance+nudge);
}

module fitInset() {
    translate([0,0,-ratio*inset])
cylinder(d1=pieceWidth-inset*2,d2=pieceWidth,h=ratio*inset+nudge);}

module piece(bottom=false) {
    render(convexity=2)
    difference() {
        union() {
            if (bottom) cylinder(d=pieceWidth,h=inset*ratio+tolerance+nudge); else baseInset();
            translate([0,0,inset*ratio+tolerance])
            cylinder(d=pieceWidth,h=pieceHeight-inset*ratio-tolerance+nudge);
        }
        translate([0,0,pieceHeight]) fitInset();
    }
}

module dome() {
    render(convexity=0) {
        baseInset();
        translate([0,0,ratio*inset+tolerance])
        intersection() {
            translate([-pieceWidth/2,-pieceWidth/2,0])
            cube(pieceWidth);
            sphere(d=pieceWidth);
        }
    }
}


module worker() {
    scale((pieceWidth-2*inset-2)/10) meeple();
}

piece();
//dome();
//worker();