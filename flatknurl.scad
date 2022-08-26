// guaranteed to cover a circle of specified size
module flatKnurlMould(depth=.5, toothAngle=120, areaDiameter=40, areaRadius=undef, diamondAngle=60) {
    d = areaRadius==undef ? areaDiameter : areaRadius;
    toothWidth = 2 * tan(toothAngle/2) * depth;
    teeth = ceil(d / toothWidth);
    module comb() {
        toothPoints = [ for(i=[0:2*teeth]) [i*toothWidth/2,-(i%2)*depth] ];
        polygon(concat(toothPoints,[ [toothWidth*teeth,depth], [0,depth] ]));
    }
    rotate([90,0,0]) {
        rotate([0,diamondAngle/2,0])
        translate([-d/2,0,-d/2])
        linear_extrude(height=d)
            comb();
        rotate([0,-diamondAngle/2,0])
        translate([-d/2,0,-d/2])
        linear_extrude(height=d)
            comb();
    }
}

flatKnurlMould();