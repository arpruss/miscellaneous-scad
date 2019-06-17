function _slice(list,start,end=undef) =
    let(end = end==undef?len(list):end)
    [for(i=[start:1:end-1]) list[i]];
        
function _delete(list,pos) =
    let(l=len(list))
    pos == 0 ? [for(i=[1:1:l-1]) list[i]] :
    pos >= l-1 ? [for(i=[0:1:pos-1]) list[i]] :
    concat([for(i=[0:1:pos-1]) list[i]],
        [for(i=[pos+1:1:l-1]) list[i]]);

function _areCollinear(a,b,c) = cross(b-a,c-a) == [0,0,0];
        
function _areCoplanar(a,b,c,d) = (d-a)*cross(b-a,c-a) == 0;
    
function _findNoncollinear(list,point1,point2,pos=0) = 
    pos >= len(list) ? undef :
    ! _areCollinear(point1,point2,list[pos]) ? pos :
    _findNoncollinear(list,point1,point2,pos=pos+1);
        
function _findNoncoplanar(list,point1,point2,point3,pos=0) =
   pos >= len(list) ? undef :
   ! _areCoplanar(point1,point2,point3,list[pos]) ? pos : 
        _findNoncoplanar(list,point1,point2,point3,pos=pos+1);
        
function _isBoundedBy(a,face,strict=false) =
    cross(face[1]-face[0],face[2]-face[0])*(a-face[0]);
        
function _makeTet(a,b,c,d) =
    _isBoundedBy(d,[a,b,c]) >= 0 ? 
        [[a,b,c],[b,a,d],[c,b,d],[a,c,d]] :
        [[c,b,a],[d,a,b],[d,b,c],[d,c,a]];

function _findTri(list) = 
    let(l2=_unique(list))
    assert(len(list)>=3)
    let(a=list[0],
        b=list[1],
        l3=_slice(list,2),
        ci=_findNoncollinear(l3,a,b),        
        c=assert(ci != undef) l3[ci],
        l4=_delete(l3,ci))
        [[a,b,c],l4];
        
function _findTet(list) =    
    let(ft=_findTri(list),
        tri=ft[0],
        l4=ft[1],
        di=assert(len(l4)>0) _findNoncoplanar(l4,tri[0],tri[1],tri[2]),
        d=assert(di != undef) l4[di],
        l5=_delete(l4,di))
        [_makeTet(tri[0],tri[1],tri[2],d),l5];
    
function _find(list,value) =
    let(m=search([value],list,1)[0]) 
    m==[] ? undef : m;
           
function _unique(list,soFar=[],pos=0) =
    pos >= len(list) ? soFar :
    _find(soFar,list[pos]) == undef ? _unique(list,soFar=concat(soFar,[list[pos]]),pos=pos+1) :
    _unique(list,soFar=soFar,pos=pos+1);
    
function _makePointsAndFaces(triangles) =
    let(points=_unique([for(t=triangles) for(v=t) v]))
        [points, [for(t=triangles) [for(v=t) _find(points,v)]]];

function _sameSide(p1,p2, a,b) = 
    let(cp1 = cross(b-a, p1-a),
        cp2 = cross(b-a, p2-a)) 
        cp1*cp2 >= 0;

function _insideTriangle(p, t) = 
    _sameSide(p,t[0],t[1],t[2]) &&
    _sameSide(p,t[1],t[0],t[2]) &&
    _sameSide(p,t[2],t[0],t[1]);
            
            
function _satisfiesConstraint(p, triangle) =
    let(c=_isBoundedBy(p, triangle))
    c > 0 || (c == 0 && _insideTriangle(p, triangle));
    
            
function _insidePoly(p, triangles, pos=0) = 
    pos >= len(triangles) ? true :
    !_satisfiesConstraint(p, triangles[pos]) ? false :
    _insidePoly(p, triangles, pos=pos+1);
        
function _haveEdge(triangles, e, pos=0) =
    pos >= len(triangles) ? false :
    e==[triangles[pos][0],triangles[pos][1]] ||
        e==[triangles[pos][1],triangles[pos][2]] ||
        e==[triangles[pos][2],triangles[pos][0]] ? true :
        _haveEdge(triangles, e, pos=pos+1);
        
function _outerEdges(triangles) =
        let(edges=[for(t=triangles) for(e=[[t[0],t[1]],
                [t[1],t[2]],
                [t[2],t[0]]]) e])
        [for(e=edges) if(undef == _find(edges,[e[1],e[0]])) e];
                
function _unlit(triangles, p) = [for(t=triangles) if(_isBoundedBy(p, t) >= 0) t];
        
function _addToHull(h, p) = 
    let(unlit = _unlit(h,p),
        edges = _outerEdges(unlit))
        concat(unlit, [for(e=edges) [e[1],e[0],p]]);

function _expandHull(h, points, pos=0) =
    pos >= len(points) ? h :
    !_insidePoly(points[pos],h) ?  _expandHull(_addToHull(h,points[pos]),points,pos=pos+1) :
    _expandHull(h, points, pos=pos+1);
            
function pointHull3D(points) =
    let(ft=_findTet(points))
        _expandHull(ft[0], ft[1]);
        
function _traceEdges(edgeStarts,edgeEnds,soFar=[]) =
    assert(soFar[len(soFar)-1] != undef)
    len(soFar)>1 && soFar[len(soFar)-1] == soFar[0] ? _slice(soFar,1) :
    _traceEdges(edgeStarts,edgeEnds,soFar=concat(soFar,[edgeEnds[_find(edgeStarts,soFar[len(soFar)-1])]]));
        
function _project(v) = [v[0],v[1]];
        
function pointHull2D(points) = 
    let(
        p3d = concat([[0,0,1]], [for(p=points) [p[0],p[1],0]]),
        h = pointHull3D(p3d),
        edgeStarts = [for(t=h) if(t[0][2]==1 || t[1][2]==1 || t[2][2]==1)
                t[0][2]==1 ? _project(t[1]) : 
                t[1][2]==1 ? _project(t[2]) :
                _project(t[0]) ],
        edgeEnds = [for(t=h) if(t[0][2]==1 || t[1][2]==1 || t[2][2]==1)
                t[0][2]==1 ? _project(t[2]) : 
                t[1][2]==1 ? _project(t[0]) :
                _project(t[1]) ])
        _traceEdges(edgeStarts,edgeEnds,soFar=[edgeStarts[0]]);
        
module pointHull(points) {
    if (len(points[0])==2) {
        polygon(pointHull2D(points));
    }
    else {
        paf = _makePointsAndFaces(pointHull3D(points));
        polyhedron(points=paf[0],faces=paf[1]);
    }
}

//<skip>            
points = [for(i=[0:99]) rands(0,100,3)];
pointHull(points);
//</skip>