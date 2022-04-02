use <roundedSquare.scad>;

//<params>

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

//</params>

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