distanceWallWartSticksOut=38;
powerbarHeight=36.5;
powerbarWidth=51;
wallWartWidth=55;
thickness=3.5;
innerCorner=6;
outerCorner=3;
cutOut=3;
thickness=3.5;

module end_of_parameters_dummy() {}

//use <roundedsquare.scad>;
module roundedSquare(size=[10,10], radius=1, center=false, $fn=16) {
    size1 = (size+0==size) ? [size,size] : size;
    if (radius <= 0) {
        square(size1, center=center);
    }
    else {
        translate(center ? -size1/2 : [0,0])
        hull() {
            translate([radius,radius]) circle(r=radius);
            translate([size1[0]-radius,radius]) circle(r=radius);
            translate([size1[0]-radius,size1[1]-radius]) circle(r=radius);
            translate([radius,size1[1]-radius]) circle(r=radius);
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


module dummy(){}

w =distanceWallWartSticksOut;
h =powerbarHeight;
l =wallWartWidth;
extra=powerbarWidth;

module main() {
    linear_extrude(height=l)
    render(convexity=2)
    difference() {
        roundedSquare([h+thickness,w],radius=outerCorner);
        translate([thickness,thickness])
        roundedSquare([h-2*thickness,w-2*thickness],radius=innerCorner);
        translate([h-thickness-1,w/2-cutOut/2]) square([thickness+2+thickness,cutOut]);
    }
    translate([h,-extra])
    cube([thickness,extra+2*outerCorner,l]);
    translate([0,-extra-thickness+0.01])
    cube([h+thickness,thickness,l]);
}

main();
