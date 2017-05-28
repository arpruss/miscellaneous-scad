module roundedSquare(size=[10,10], radius=1, center=false, $fn=16) {
    if (radius <= 0) {
        square(size, center=center);
    }
    else {
        translate(center ? -size/2 : [0,0])
        hull() {
            translate([radius,radius]) circle(r=radius);
            translate([size[0]-radius,radius]) circle(r=radius);
            translate([size[0]-radius,size[1]-radius]) circle(r=radius);
            translate([radius,size[1]-radius]) circle(r=radius);
        }
    }
}

module roundedOpenTopBox(size=[10,10,10], radius=2, wall=1, solid=false) {
    render(convexity=2)
    difference() {
        linear_extrude(height=size[2]) roundedSquare(size=[size[0],size[1]], radius=radius);
        if (!solid) {
            translate([0,0,wall])
            linear_extrude(height=size[2]-wall) 
            translate([wall,wall]) roundedSquare(size=[size[0]-2*wall,size[1]-2*wall], radius=radius-wall);
        }
    }
}
