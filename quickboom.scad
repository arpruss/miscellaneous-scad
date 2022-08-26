use <bezier.scad>; // download from https://www.thingiverse.com/thing:2207518
use <triangulation.scad>;
use <inflate.scad>;

resolution = 2;
bezier_precision = -1;

position_outline = [100.87089,154.007963449];
size_outline = [129.251311051,94.950406898];
stroke_width_outline = 0.1;
color_outline = [0,0,0];
fillcolor_outline = [0,0,0];
// paths for outline
bezier_outline = [/*N*/[0,-47.475203449],/*CP*/OFFSET([4.1126,0]),/*CP*/OFFSET([-11.87727,-8.81095]),/*N*/[24.6172,-36.835343449],/*CP*/OFFSET([16.96299,12.5837]),/*CP*/OFFSET([5.47775,-16.31867]),/*N*/[63.92673,38.003946551],/*CP*/OFFSET([-5.47775,16.31867]),/*CP*/OFFSET([4.56681,16.722718]),/*N*/[42.76006,31.200366551],/*CP*/OFFSET([-4.39248,-16.08434]),/*CP*/OFFSET([18.54448,0]),/*N*/[0,-24.184853449],/*CP*/OFFSET([-18.544477,0]),/*CP*/OFFSET([4.392478,-16.08434]),/*N*/[-42.76006,31.200366551],/*CP*/OFFSET([-4.56681,16.722718]),/*CP*/OFFSET([5.47775,16.31867]),/*N*/[-63.92673,38.003946551],/*CP*/OFFSET([-5.47775,-16.31867]),/*CP*/OFFSET([-16.96299,12.5837]),/*N*/[-24.6172,-36.835343449],/*CP*/OFFSET([11.87727,-8.81095]),/*CP*/OFFSET([-4.112603,0]),/*N*/[0,-47.475203449],LINE(),LINE(),/*N*/[0,-47.475203449]];
points_outline = Bezier(bezier_outline,precision=bezier_precision);

tt = triangulate(points_outline);
echo(len(tt));

profile = Bezier([[0,0],POLAR(4,90),POLAR(4,180),[8,8]]);

inflateMesh(points=points_outline,triangles=tt,top="interpolate(d,profile)",params=[["profile",profile]],refineMaxEdge=2);
 