module roundedSquare(size=[10,10], radius=1, selection=undef, center=false, $fn=16) {
    size1 = !is_list(size) ? [size,size] : size;
    module corner(which) {
        if (selection==undef || is_num(search([which,],selection)[0]))
            circle(r=radius);
        else
            square(radius*2,center=true);
    }
    if (radius <= 0) {
        square(size1, center=center);
    }
    else {
        translate(center ? -size1/2 : [0,0])
        hull() {
            translate([radius,radius]) corner("frontLeft");
            translate([size1[0]-radius,radius]) corner("frontRight");
            translate([size1[0]-radius,size1[1]-radius]) corner("rearRight");
            translate([radius,size1[1]-radius]) corner("rearLeft");
        }
    }
}

module roundedSquareTrace(size=[10,10], radius=1, center=false, $fn=16) {
    
}

module roundedCube(size=[10,10,10], radius=1, center=false, $fn=16) {
    linear_extrude(height=size[2])
    roundedSquare(size=[size[0],size[1]], radius=radius, center=center);
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
