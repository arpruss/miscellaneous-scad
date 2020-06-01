use <triangulation.scad>;
use <inflate.scad>;

//<params>
demoSides = 10;
demoRadius = 20;
demoTopFunction = "2+min(d^0.5,3)*cos(x*10)";
    demoBottomFunction = "-min(d^0.5,3)";
//</params>

poly = demoRadius*[for(i=[0:demoSides-1]) [cos(360*i/demoSides),sin(360*i/demoSides)]];
pointsAndFaces = refineMesh(points=poly,triangles=triangulate(poly),maxEdge=2);
inflated = inflateMesh(points=pointsAndFaces[0],triangles=pointsAndFaces[1],top=demoTopFunction,bottom=demoBottomFunction);
polyhedron(points=inflated[0],faces=inflated[1]);
