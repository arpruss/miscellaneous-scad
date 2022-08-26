function sort(edge) = [min(edge),max(edge)];

function contains(value,array) = len([for (i=[0:len(array)-1]) if (array[i]==value) 1])>0;

function edgeInTriangle(edge,triangle) = sort(edge)==sort([triangle[0],triangle[1]]) || sort(edge)==sort([triangle[1],triangle[2]]) || sort(edge)==sort([triangle[0],triangle[2]]);

function edgeInTriangles(edge,triangles) = len([for (i=[0:len(triangles)-1]) if (edgeInTriangle(edge,triangles[i])) 1])>0;

function amp(n) = 1 / pow(2,n);

function r(n) = amp(n) * rands(-1,1,1)[0];
    
vertices = [[0.,0.,r(0)], [0.,1.,r(0)], [1., sqrt(3)/2,r(0)]];
triangles = [[0,1,2]];
echo(vertices);

len(for(i=[0:triangle]) for(j=[0:2]) if(t[0]<t[1]) 1);
