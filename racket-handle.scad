use <bezier.scad>; // download from https://www.thingiverse.com/thing:2207518
use <pointhull.scad>;

//<params>
thickness = 5.34;

bezier_precision = -0.1;

size_handle = [135.45892,53.41172];
stroke_width_handle = 0.5;
color_handle = [0,0,0];
fillcolor_handle = [0.501960784,0.501960784,0.501960784];
// paths for handle
mainHalfWidth = 18.07213;
bevelStart = 110;
bezier_handle_1 = [/*N*/[135.70892,26.70571],/*CP*/OFFSET([-8.38066,-5.49776]),/*CP*/OFFSET([5.38096,0]),/*N*/[113.91335,mainHalfWidth],LINE(),LINE(),/*N*/[16.046969,mainHalfWidth],/*CP*/OFFSET([-7.713109,0]),/*CP*/OFFSET([0.000011,8.15919]),/*N*/[0.25,-0.00015],/*CP*/OFFSET([0.000011,-8.15919]),/*CP*/OFFSET([-7.713109,0]),/*N*/[16.046969,-mainHalfWidth],LINE(),LINE(),/*N*/[113.91335,-mainHalfWidth],/*CP*/OFFSET([5.38096,0]),/*CP*/OFFSET([-8.38066,5.49776]),/*N*/[135.70892,-26.70601],LINE(),LINE(),/*N*/[135.70892,26.70571]];
points_handle_1 = Bezier(bezier_handle_1,precision=bezier_precision);

$fn = 36;

intersection() {
    linear_extrude(height=thickness) {
        polygon(points_handle_1);
    }
    scale([1,1,thickness/mainHalfWidth])
    rotate([0,90,0])
    cylinder(r=mainHalfWidth,h=size_handle[0]);
}
