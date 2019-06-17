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
    let(c = cross(face[1]-face[0],face[2]-face[0])*(a-face[0]))
    strict ? c > 0 : c >= 0;   
        
function _makeTet(a,b,c,d) =
    _isBoundedBy(d,[a,b,c]) ? 
        [[a,b,c],[b,a,d],[c,b,d],[a,c,d]] :
        [[c,b,a],[d,a,b],[d,b,c],[d,c,a]];
        
function _findTet(list) =
    let(l2=_unique(list))
    assert(len(list)>=4)
    let(a=list[0],
        b=list[1],
        l3=_slice(list,2),
        ci=_findNoncollinear(l3,a,b),        
        c=assert(ci != undef) l3[ci],
        l4=_delete(l3,ci),
        di=_findNoncoplanar(l4,a,b,c),
        d=assert(di != undef) l4[di],
        l5=_delete(l4,di))
        [_makeTet(a,b,c,d),l5];
    
function find(list,value) =
    let(m=search([value],list,1)[0]) 
    m==[] ? undef : m;
           
function _unique(list,soFar=[],pos=0) =
    pos >= len(list) ? soFar :
    find(soFar,list[pos]) == undef ? _unique(list,soFar=concat(soFar,[list[pos]]),pos=pos+1) :
    _unique(list,soFar=soFar,pos=pos+1);
    
function _makePointsAndFaces(triangles) =
    let(points=_unique([for(t=triangles) for(v=t) v]))
        [points, [for(t=triangles) [for(v=t) find(points,v)]]];
            
function _insidePoly(p, triangles, pos=0, strict=false) = 
    pos >= len(triangles) ? true :
    !_isBoundedBy(p, triangles[pos], strict) ? false :
    _insidePoly(p, triangles, pos=pos+1, strict=strict);
        
function _haveEdge(triangles, e, pos=0) =
    pos >= len(triangles) ? false :
    e==[triangles[pos][0],triangles[pos][1]] ||
        e==[triangles[pos][1],triangles[pos][2]] ||
        e==[triangles[pos][2],triangles[pos][0]] ? true :
        _haveEdge(triangles, e, pos=pos+1);
        
function _outerEdges(triangles, pos=0, soFar=[]) =
    pos >= len(triangles) ? soFar :
    _outerEdges(triangles, pos=pos+1, soFar=concat(soFar, 
        [for(e=[[triangles[pos][0],triangles[pos][1]],
                [triangles[pos][1],triangles[pos][2]],
                [triangles[pos][2],triangles[pos][0]]])
            if (!_haveEdge(triangles,[e[1],e[0]])) e]));
                
function _unlit(triangles, p) = [for(t=triangles) if(_isBoundedBy(p, t)) t];
        
function _addToHull(h, p) = 
    let(unlit = _unlit(h,p),
        edges = _outerEdges(unlit))
        concat(unlit, [for(e=edges) [e[1],e[0],p]]);

function _expandHull(h, points, pos=0) =
    pos >= len(points) ? h :
    !_insidePoly(points[pos],h) ?  _expandHull(_addToHull(h,points[pos]),points,pos=pos+1) :
_expandHull(h, points, pos=pos+1);
            
function _pointHull(points) =
    let(ft=_findTet(points))
        _expandHull(ft[0], ft[1]);
        
module pointHull(points) {
    ph = _pointHull(points);
    paf = _makePointsAndFaces(_pointHull(points));
    polyhedron(points=paf[0],faces=paf[1]);
}
            
//points = [for(i=[0:99]) rands(0,100,3)];
//pointHull(points);
