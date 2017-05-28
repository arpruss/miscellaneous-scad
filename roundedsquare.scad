module roundedSquare(size=[10,10], radius=1, center=false) {
    translate(center ? -size/2 : [0,0])
    hull() {
        translate([radius,radius]) circle(r=radius);
        translate([size[0]-radius,radius]) circle(r=radius);
        translate([size[0]-radius,size[0]-radius]) circle(r=radius);
        translate([0,size[0]-radius]) circle(r=radius);
    }
}
