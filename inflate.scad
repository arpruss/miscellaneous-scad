use <eval.scad>;

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

function _edgeTriangles0(edge,bottomc,topc,params) =
    let(z=[for(v=edge) [for(fun=[bottomc,topc]) eval(fun,concat(params,[["x",v[0]],["y",v[1]],["d",0]]))]]) 
        z[0][0] == z[0][1] && z[1][0] == z[1][1] ? [] :
        let(triRight = [[edge[0][0],edge[0][1],z[0][1]],[edge[1][0],edge[1][1],z[1][1]],[edge[1][0],edge[1][1],z[1][0]]],
            triLeft = [[edge[0][0],edge[0][1],z[0][0]],[edge[0][0],edge[0][1],z[0][1]],[edge[1][0],edge[1][1],z[1][0]]])
        z[0][0] == z[0][1] ? [triRight] :
        z[1][0] == z[1][1] ? [triLeft] :
        [triLeft,triRight];
    
function _edgeTriangles(points,outside,bottomc,topc,params) = [for(edge=outside) for(t=_edgeTriangles0(edge,bottomc,topc,params)) [for(v=t) _find(v,points)]];

function inflateMesh(points=[],triangles=[],top="d",bottom="0",params=[]) =
    let(topc = compileFunction(top),
        bottomc = compileFunction(bottom),
        outside = _outerEdges(points, triangles),
        n = len(points),
        newPoints = [for (p=points) let(vars=concat(params,[["x", p[0]], ["y", p[1]], ["d",_distanceToOutside(p,outside)]])) for(fun=[bottomc,topc]) [p[0],p[1],eval(fun,vars)]],
        topTriangles = [for (t=triangles) _invertTriangle([for (index=t) index*2+1])],
        bottomTriangles = [for (t=triangles) [for(index=t) index*2]]) 
        [newPoints,concat(topTriangles,bottomTriangles,_edgeTriangles(newPoints,outside,bottomc,topc,params))];
