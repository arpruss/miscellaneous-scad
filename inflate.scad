use <triangulation.scad>;
use <eval.scad>;

//<params>
demoSides = 10;
demoRadius = 20;
demoTopFunction = "min(x^0.5,3)";
demoBottomFunction = "max(x^0.5,3)";
//</params>


//<skip>
poly = demoRadius*[for(i=[0:demoSides-1]) [cos(360*i/demoSides),sin(360*i/demoSides)]];
pointsAndFaces = refineMesh(points=poly,triangles=triangulate(poly),maxEdge=2);
inflated = inflateMesh(points=pointsAndFaces[0],triangles=pointsAndFaces[1],top=demoTopFunction,bottom=demoBottomFunction);
polyhedron(points=inflated[0],faces=inflated[1]);
//</skip>

function _find(needle,haystack) = let(f=search([needle], haystack)) f==[[]] ? undef : f[0];

function _outerEdges(points,triangles) = 
    let(edges=[for(t=triangles) for(i=[0:len(t)-1]) [t[i],t[(i+1)%len(t)]]])
    [for(e=edges) if (undef == _find([e[1],e[0]],edges)) [points[e[0]],points[e[1]]]];
        
function _distanceToEdge(p,edge) = 
    let(p1=p-edge[0],
        d1=min(norm(p1),norm(p-edge[1])),
        e = edge[1]-edge[0],
        eLen = norm(e))
        e == 0 ? d1 :
        let(e1 = e / eLen,
            x = e1*p1)
            x <= 0 || x >= eLen ? d1 : min(d1,norm(p-(edge[0]+x*e1)));
    
function _distanceToOutside(p,outside) = min([for(edge=outside) _distanceToEdge(p,edge)]);
    
function _invertTriangle(t) = [t[2],t[1],t[0]];

function inflateMesh(points=[],triangles=[],top="x",bottom="0",params=[]) =
    let(topc = compileFunction(top),
        bottomc = compileFunction(bottom),
        outside = _outerEdges(points, triangles),
        n = len(points),
        newPoints = [for (p=points) let(vars=concat(params,[["x",_distanceToOutside(p,outside)]])) for(fun=[bottomc,topc]) [p[0],p[1],eval(fun,vars)]],
        topTriangles = [for (t=triangles) _invertTriangle([for (index=t) index*2+1])],
        bottomTriangles = [for (t=triangles) [for(index=t) index*2]]) 
        [newPoints,concat(topTriangles,bottomTriangles)];
            
