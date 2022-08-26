use <triangulation.scad>;
use <inflate.scad>;

square = [ [-20,-20], [20,-20], [20,20], [-20,20] ];
poly = [0,1,2,3];
circle = [for(i=[0:19]) 5*[cos(i/20*360),sin(i/20*360)]];
hole = [for(i=[0:19]) 4+i];    
points = concat(square,circle);
triangulated = triangulate(points,poly,holes=[hole]);
refined = refineMesh(points, triangulated, maxEdge=2);
inflateMesh(refined,top="2+4*d^0.25",bottom="-2*d^0.25");
