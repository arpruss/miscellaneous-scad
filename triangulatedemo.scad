use <triangulation.scad>;

function ngon(n=10,r=20,center=[0,0]) = [for (i=[0:n-1]) center+r*[cos(360*i/n),sin(360*i/n)]];
function range(count,start=0) = [for(i=[start:1:start+count-1]) i];

outer = ngon(n=10,r=20);
outerPath = range(len(outer));
hole1 = ngon(n=10,r=7,center=[-10,0]);
hole1Path = range(len(hole1),start=len(outer));
hole2 = ngon(n=10,r=7,center=[10,0]);
hole2Path = range(len(hole2),start=len(outer)+len(hole1));
points = concat(outer,hole1,hole2);
tt = triangulate(points,outerPath,[hole1Path,hole2Path]);
showMesh(points,tt);
