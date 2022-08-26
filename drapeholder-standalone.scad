// This file was processed by resolve-include.py [https://github.com/arpruss/miscellaneous-scad/blob/master/scripts/resolve-include.py] 
// to include  all the dependencies inside one file.


beamWidth = 16;
beamHeight = 21;
tolerance = 1.5;
depth = 7;
bottomFlange = 8;
sideFlange = 15;
screwHole = 4.75;
rounded = 5;
screwHead = 9;
screwInset = 3;


module end_of_parameters_dummy() {}


//BEGIN DEPENDENCY: use <roundedSquare.scad>;
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

//END DEPENDENCY: use <roundedSquare.scad>;



$fn = 64;

holeWidth = beamWidth + 2*tolerance;
holeHeight = beamHeight + 2*tolerance;

module flange(screwHole=screwHole) {
    difference() {
        translate([-sideFlange-holeWidth/2,-bottomFlange-holeWidth/2]) roundedSquare([sideFlange*2+holeWidth, bottomFlange+holeHeight], radius=rounded, $fn=64);
        hull() {
            circle(d=holeWidth);
            translate([-holeWidth/2,0]) square([holeWidth,holeHeight]);
        }
        for (s=[-1,1]) translate([s*(holeWidth/2+sideFlange/2),0]) circle(d=screwHole);
    }
}

linear_extrude(height=depth-screwInset+0.01) flange(screwHole=screwHole);
translate([0,0,depth-screwInset]) linear_extrude(height=screwInset) flange(screwHole=screwHead);
