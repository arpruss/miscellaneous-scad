use <Bezier.scad>;
use <triangulation.scad>;
use <inflate.scad>;

diameter = 30;

heart = Bezier([[0,0],POLAR(10,60),POLAR(10,-90),[20,35],SYMMETRIC(),POLAR(15,90),[0,30],REPEAT_MIRRORED([1,0])]);

refined = refineMesh(heart,triangulate(heart),maxEdge=2);

mesh=inflateMesh(refined,top=3);

newPoints = [for(v=mesh[0]) [(diameter/2+v[2])*cos(v[0]*360/(PI*diameter)),(diameter/2+v[2])*sin(v[0]*360/(PI*diameter)),v[1]]];
    
polyhedron(points=newPoints,faces=mesh[1]); 