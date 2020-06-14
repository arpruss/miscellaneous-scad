use <pointhull.scad>;
use <triangulation.scad>;

points=[for(z=[-10,10]) for(angle=[0:360/5:360]) [20*cos(angle),20*sin(angle),z]];
ph = _makePointsAndFaces(pointHull(points));
m = sliceMesh(ph,slices=[-4,-2,2,4],normal=[1,1,1]);
showMesh(m[0],m[1]);
//polyhedron(m[0],m[1]);

//ph = pointHull(points);
//echo(ph);
//showMesh(ph[0],ph[1]);