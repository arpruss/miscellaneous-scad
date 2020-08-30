use <bezier.scad>; // download from https://www.thingiverse.com/thing:2207518
use <ribbon.scad>;

thickness = 2;
height = 10;

bezier_precision = -0.1;
xSquish = 0.95;
ySquish = 0.94;

position_svg_1 = [6.992222,264.529947];
size_svg_1 = [38.70946,29.405492];
stroke_width_svg_1 = 0.1;
color_svg_1 = [0,0,0];
fillcolor_svg_1 = undef;
// paths for svg_1
bezier_svg_1_1 = [/*N*/[19.35473,-14.702746],/*CP*/POLAR(0,0),/*CP*/POLAR(8.355186261,-36.77015373),/*N*/[3.969087-2,-7.506136],/*CP*/POLAR(8.569311825,143.229845719),/*CP*/POLAR(13.22916707,0),/*N*/[-19.35473,14.702746-2],REPEAT_MIRRORED([1,0])];
points_svg_1_1 = Bezier(bezier_svg_1_1,precision=bezier_precision);

module rounder() {
    translate([0,0,height/2])
    rotate([-90,0,0])
    linear_extrude(height=size_svg_1[1]+thickness*2)
    hull() {
        translate([-size_svg_1[0]+height/2,0]) circle(d=height,$fn=16);
        translate([size_svg_1[0]-height/2,0]) circle(d=height,$fn=16);
    }
}

scale([xSquish,ySquish,1])
intersection() {
translate([size_svg_1[0]/2,size_svg_1[1]/2+thickness/2,0]) linear_extrude(height=height) ribbon(points_svg_1_1,thickness=thickness);
    rounder();
}
