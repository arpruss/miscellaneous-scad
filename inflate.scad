use <eval.scad>;
use <triangulation.scad>;

function _find(needle,haystack) = let(f=search([needle], haystack)) f==[[]] ? undef : f[0];

function _outerEdges(points,triangles) = 
    let(edges=[for(t=triangles) for(i=[0:len(t)-1]) [t[i],t[(i+1)%len(t)]]])
    [for(e=edges) if (undef == _find([e[1],e[0]],edges)) [points[e[0]],points[e[1]]]];
        
function _distanceToEdge(p,edge) = 
    p == edge[0] || p == edge[1] ? 0 :
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

function _edgeTriangles0(points,edge,bottomData,topData,params) = 
    let(z=[for(v=edge) [for(data=[bottomData,topData]) data[_find(v,points)]]]) 
        z[0][0] == z[0][1] && z[1][0] == z[1][1] ? [] :
        let(triRight = [[edge[0][0],edge[0][1],z[0][1]],[edge[1][0],edge[1][1],z[1][1]],[edge[1][0],edge[1][1],z[1][0]]],
            triLeft = [[edge[0][0],edge[0][1],z[0][0]],[edge[0][0],edge[0][1],z[0][1]],[edge[1][0],edge[1][1],z[1][0]]])
        z[0][0] == z[0][1] ? [triRight] :
        z[1][0] == z[1][1] ? [triLeft] :
        [triLeft,triRight];
    
function _edgeTriangles(points,newPoints,outside,bottomData,topData) = [for(edge=outside) for(t=_edgeTriangles0(points,edge,bottomData,topData)) [for(v=t) _find(v,newPoints)]];
    
function _isNumericVector(v,pos=0) = 
    !is_list(v) || len(v) == 0 ? false :
    pos >= len(v) ? true :
    is_num(v[pos]) ? _isNumericVector(v,pos=pos+1) : false;

function _calculateData(fun,params,points,triangles,distances) =
    _isNumericVector(fun) ? fun :
    let(
        func=compileFunction(fun))
        [for(i=[0:1:len(points)-1]) 
        eval(func,concat(params,[["x", points[i][0]], ["y", points[i][1]], ["d",distances[i]]]))];

function inflateMesh(pointsAndFaces=undef,points=undef,triangles=undef,top="d",bottom="0",params=[],refineMaxEdge=undef) =    
    let(points = pointsAndFaces==undef ? points : pointsAndFaces[0],
    triangles = pointsAndFaces==undef ? triangles : pointsAndFaces[1],
    outside = _outerEdges(points, triangles),
    refined=refineMaxEdge==undef?[points,triangles]:refineMesh(points=points,triangles=triangles,maxEdge=refineMaxEdge),
    points2=refined[0],
    triangles2=refined[1],
    distances = [for(p=points2) _distanceToOutside(p,outside)],
    outside2=refineMaxEdge==undef?outside:_outerEdges(points2,triangles2),
    topData=_calculateData(top,params,points2,triangles2,distances),
    bottomData = _calculateData(bottom,params,points2,triangles2,distances),
    n = len(points),
    newPoints = [for (i=[0:1:len(points2)-1]) for(v=[bottomData,topData]) [points2[i][0],points2[i][1],v[i]]],
        topTriangles = [for (t=triangles2) _invertTriangle([for (index=t) index*2+1])],
        bottomTriangles = [for (t=triangles2) [for(index=t) index*2]],
        edgeTriangles = _edgeTriangles(points2,newPoints,outside2,bottomData,topData)
        ) 
        [newPoints,concat(topTriangles,bottomTriangles,edgeTriangles)];

module inflateMesh(pointsAndFaces=undef,points=undef,triangles=undef,top="d",bottom="0",params=[],refineMaxEdge=undef) {
    data = inflateMesh(pointsAndFaces=pointsAndFaces,points=points,triangles=triangles,top=top,bottom=bottom,params=params,refineMaxEdge=refineMaxEdge);
    polyhedron(points=data[0],faces=data[1]);
}
