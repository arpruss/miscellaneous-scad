width = 74.5;
height = 134.5;
phoneThickness = 16;
concreteThickness = 20;
wall = 1.25;
cornerRadius = 10;
topStickout = 16;
bottomCover = 15;
nudge = 0.001;

module oval(extra=0) {
    r = cornerRadius + extra;
    w = width + 2 * extra;
    h = height + 2 * extra;
    translate([-extra,-extra])
    hull() {
        for (x=[0,1])
            for (y=[0,1])
                translate([r+x*(w-2*r),r+y*(h-2*r)]) circle(r=r);
    }
}

linear_extrude(height=wall)
oval(extra=wall);
difference() {
    linear_extrude(height=concreteThickness+phoneThickness+wall) difference() {
        oval(extra=wall);
        oval();
    }
    translate([-wall-nudge,bottomCover,wall+concreteThickness])
    cube([width+4*wall, height-topStickout-bottomCover,phoneThickness+nudge]);
}
translate([0,0,concreteThickness+phoneThickness+wall-nudge])
linear_extrude(height=wall) {
    intersection() {
        oval(extra=wall);
        translate([-wall-nudge,-wall-nudge]) square([width + 2*wall + 2*nudge, bottomCover + wall]);
    }
}