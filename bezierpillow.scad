use <triangulation.scad>;
use <inflate.scad>;
use <Bezier.scad>;

sq = [ [0,0], [20,0], [20,20], [0,20] ];
triangulated = triangulate(sq);
refined = refineMesh(sq, triangulated, maxEdge=3);
topProfile=Bezier([[0,0],POLAR(5,90),POLAR(6,180),[8,8],LINE(),LINE(),[8,8]]);
inflateMesh(refined,top="interpolate(d,topProfile)",bottom="-2*d^0.25",params=[["topProfile",topProfile]]);
