use <triangulation.scad>;
use <inflate.scad>;

sq = [ [0,0], [20,0], [20,20], [0,20] ];
triangulated = triangulate(sq);
refined = refineMesh(sq, triangulated, maxEdge=1);
inflateMesh(refined,top="2+4*d^0.25",bottom="-2*d^0.25");
