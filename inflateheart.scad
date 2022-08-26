use <Bezier.scad>;
use <triangulation.scad>;
use <inflate.scad>;

heart = Bezier([[0,0],POLAR(10,60),POLAR(10,-90),[20,35],SYMMETRIC(),POLAR(15,90),[0,30],REPEAT_MIRRORED([1,0])]);

inflateMesh(refineMesh(heart,triangulate(heart),maxEdge=2),top="min(4,3*d^0.25)");