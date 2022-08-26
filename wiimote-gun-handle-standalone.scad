// This file was processed by resolve-include.py [https://github.com/arpruss/miscellaneous-scad/blob/master/scripts/resolve-include.py] 
// to include  all the dependencies inside one file.

includeGrip = true;
tolerance = 0.18;
wallThicknesss = 2.5;
tabSize = 3.5;
gripLength = 39;
gripWidth = 17.53;
lip = 3;
// the following only apply if you do include the grip
gripHeight = 80;
gripAngle = 20;
gripBevel = 4;

// the following only apply if you don't include the grip
extrawallThicknesss = 3;
screwHoleDiameter = 4;
screwHoleInsetDepth = 3;
screwHoleInsetDiameter = 9;

module end_of_parameters_dummy() {}


//BEGIN DEPENDENCY: use <Bezier.scad>;
/*
Copyright (c) 2017 Alexander R. Pruss.

Licensed under any Creative Commons Attribution license you like or under the
following MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/


// Public domain Bezier stuff from www.thingiverse.com/thing:8443
function BEZ03(u) = pow(1-u, 3);
function BEZ13(u) = 3*u*pow(1-u,2);
function BEZ23(u) = 3*pow(u,2)*(1-u);
function BEZ33(u) = pow(u,3);
function PointAlongBez4(p0, p1, p2, p3, u) =
	BEZ03(u)*p0+BEZ13(u)*p1+BEZ23(u)*p2+BEZ33(u)*p3;
// End public domain Bezier stuff
function d2BEZ03(u) = 6*(1-u);
function d2BEZ13(u) = 18*u-12;
function d2BEZ23(u) = -18*u+6;
function d2BEZ33(u) = 6*u;

function worstCase2ndDerivative(p0, p1, p2, p3, u1, u2)
    = norm([
        for(i=[0:len(p0)-1])
            max([for(u=[u1,u2])
                d2BEZ03(u)*p0[i]+d2BEZ13(u)*p1[i]+
                d2BEZ23(u)*p2[i]+d2BEZ33(u)*p3[i]]) ]);

function neededIntervalLength(p0,p1,p2,p3,u1,u2,tolerance)
    = let(d2=worstCase2ndDerivative(p0,p1,p2,p3,u1,u2))
        d2==0 ? u2-u1+1 : sqrt(2*tolerance/d2);

function REPEAT_MIRRORED(v,angleStart=0,angleEnd=360) = ["m",v,angleStart,angleEnd];
function SMOOTH_REL(x) = ["r",x];
function SMOOTH_ABS(x) = ["a",x];
function SYMMETRIC() = ["r",1];
function OFFSET(v) = ["o",v];
function SHARP() = OFFSET([0,0,0]);
function LINE() = ["l",0];
function POLAR(r,angle) = OFFSET(r*[cos(angle),sin(angle)]);
//function POINT_IS_SPECIAL(v) = (v[0]=="r" || v[0]=="a" || v[0]=="o" || v[0]=="l");

// this does NOT handle offset type points; to handle those, use DecodeBezierOffsets()
function getControlPoint(cp,node,otherCP,otherNode,nextNode) =
    let(v=node-otherCP) (
    cp[0]=="r" ? node+cp[1]*v:
    cp[0]=="a" ? (
        norm(v)<1e-9 ? node+cp[1]*(node-otherNode)/norm(node-otherNode) : node+cp[1]*v/norm(v) ) :
        cp );

function onLine2(a,b,c,eps=1e-4) =
    norm(c-a) <= eps ? true
        : norm(b-a) <= eps ? false /* to be safe */
            : abs((c[1]-a[1])*(b[0]-a[0]) - (b[1]-a[1])*(c[0]-a[0])) <= eps * eps && norm(c-a) <= eps + norm(b-a);

function isStraight2(p1,c1,c2,p2,eps=1e-4) =
    len(p1) == 2 &&
    onLine2(p1,p2,c1,eps=eps) && onLine2(p2,p1,c2,eps=eps);

function Bezier2(p,index=0,precision=0.05,rightEndPoint=true,optimize=true) = let(nPoints=
        max(1, precision < 0 ?
                    ceil(1/
                        neededIntervalLength(p[index],p[index+1],p[index+2],p[index+3],0,1,-precision))
                    : ceil(1/precision)) )
    optimize && isStraight2(p[index],p[index+1],p[index+2],p[index+3]) ? (rightEndPoint?[p[index+0],p[index+3]]:[p[index+0]] ) :
    [for (i=[0:nPoints-(rightEndPoint?0:1)]) PointAlongBez4(p[index+0],p[index+1],p[index+2],p[index+3],i/nPoints)];

function flatten(listOfLists) = [ for(list = listOfLists) for(item = list) item ];


// p is a list of points, in the format:
// [node1,control1,control2,node2,control3, control4,node3, ...]
// You can replace inner control points with:
//   SYMMETRIC: uses a reflection of the control point on the other side of the node
//   SMOOTH_REL(x): like SYMMETRIC, but the distance of the control point to the node is x times the distance of the other control point to the node
//   SMOOTH_ABS(x): like SYMMETRIC, but the distance of the control point to the node is exactly x
// You can also replace any control point with:
//   OFFSET(v): puts the control point at the corresponding node plus the vector v
//   SHARP(): equivalent to OFFSET([0,0])
//   LINE(): when used for both control points between two nodes, generates a straight line
//   POLAR(r,angle): like OFFSET, except the offset is specified in polar coordinates

function DecodeBezierOffset(control,node) = control[0] == "o" ? node+control[1] : control;

function _mirrorMatrix(normalVector) = let(v = normalVector/norm(normalVector)) len(v)<3 ? [[1-2*v[0]*v[0],-2*v[0]*v[1]],[-2*v[0]*v[1],1-2*v[1]*v[1]]] : [[1-2*v[0]*v[0],-2*v[0]*v[1],-2*v[0]*v[2]],[-2*v[0]*v[1],1-2*v[1]*v[1],-2*v[1]*v[2]],[-2*v[0]*v[2],-2*v[1]*v[2],1-2*v[2]*v[2]]];

function _correctLength(p,start=0) =
    start >= len(p) || p[start][0] == "m" ? 3*floor(start/3)+1 : _correctLength(p,start=start+1);

function _trimArray(a, n) = [for (i=[0:n-1]) a[i]];

function _transformPoint(matrix,a) =
    let(n=len(a))
        len(matrix[0])==n+1 ?
            _trimArray(matrix * concat(a,[1]), n)
            : matrix * a;

function _transformPath(matrix,path) =
    [for (a=path) _transformPoint(matrix,a)];

function _reverseArray(array) = let(n=len(array)) [for (i=[0:n-1]) array[n-1-i]];

function _stitchPaths(a,b) = let(na=len(a)) [for (i=[0:na+len(b)-2]) i<na? a[i] : b[i-na+1]-b[0]+a[na-1]];

// replace all OFFSET/SHARP/POLAR points with coordinates
function DecodeBezierOffsets(p) = [for (i=[0:_correctLength(p)-1]) i%3==0?p[i]:(i%3==1?DecodeBezierOffset(p[i],p[i-1]):DecodeBezierOffset(p[i],p[i+1]))];

function _mirrorPaths(basePath, control, start) =
    control[start][0] == "m" ? _mirrorPaths(_stitchPaths(basePath,_reverseArray(_transformPath(_mirrorMatrix( control[start][1] ),basePath))), control, start+1) : basePath;

function DecodeMirrored(path,start=0) =
    start >= len(path) ? path :
    path[start][0] == "m" ? _mirrorPaths([for(i=[0:1:start-1]) path[i]], path, start) :
        DecodeMirrored(path,start=start+1);

function DecodeLines(p) = [for (i=[0:len(p)-1])
    i%3==0 || p[i][0] != "l" ? p[i] :
    i%3 == 1 ? (p[i-1]*2+p[i+2])/3 :
    (p[i-2]+p[i+1]*2)/3 ];

function DecodeSpecialBezierPoints(p0) =
    let(
        l = _correctLength(p0),
        doMirror = len(p0)>l && p0[l][0] == "m",
        p1=DecodeLines(p0),
        p=DecodeBezierOffsets(p1),
        basePath = [for (i=[0:l-1]) i%3==0?p[i]:(i%3==1?getControlPoint(p[i],p[i-1],p[i-2],p[i-4],p[i+2]):getControlPoint(p[i],p[i+1],p[i+2],p[i+4],p[i-2]))])
        doMirror ? _mirrorPaths(basePath, p0, l) : basePath;

function Distance2D(a,b) = sqrt((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));

function RemoveDuplicates(p,eps=0.00001) = let(safeEps = eps/len(p)) [for (i=[0:len(p)-1]) if(i==0 || i==len(p)-1 || Distance2D(p[i-1],p[i]) >= safeEps) p[i]];

function Bezier(p,precision=0.05,eps=0.00001,optimize=true) = let(q=DecodeSpecialBezierPoints(p), nodes=(len(q)-1)/3) RemoveDuplicates(flatten([for (i=[0:nodes-1]) Bezier2(q,optimize=optimize,index=i*3,precision=precision,rightEndPoint=(i==nodes-1))]),eps=eps);

function GetSplineAngle(a,b,c) =
    a==c && b==a ? 0 :
    a==c ? let(ba=b-a) atan2(ba[1],ba[0]) :
    let(ca=c-a) atan2(ca[1],ca[0]);

/*    let(ba=norm(b-a),cb=norm(c-b))
        ba == 0 && cb == 0 ? 0 :
    let(v = ba == 0 ? c-b :
            cb == 0 ? b-a :
            (c-b)*norm(b-a)/norm(c-b)+(b-a))
    atan2(v[1],v[0]); */

// do a spline around b
function SplineAroundPoint(a,b,c,tension=0.5,includeLeftCP=true,includeRightCP=true) =
    includeLeftCP && includeRightCP ?
        [POLAR(tension*norm(a-b),GetSplineAngle(c,b,a)),b,POLAR(tension*norm(c-b),GetSplineAngle(a,b,c))] :
    includeLeftCP ?
        [POLAR(tension*norm(a-b),GetSplineAngle(c,b,a)),b] :
    includeRightCP ?
        [b,POLAR(tension*norm(c-b),GetSplineAngle(a,b,c))] :
        [b];

function mod(n,m) = let(q=n%m) q>=0 ? q : m+q;

function _unit(v) = norm(v)==0 ? [for(x=v) 0] : v/norm(v);

function _corner(p0,p1,p2,offset=2,tension=0.448084975506) =
    [p1-_unit(p1-p0)*offset,
    p1-_unit(p1-p0)*offset*(1-tension),
    p1-_unit(p1-p2)*offset*(1-tension),
    p1-_unit(p1-p2)*offset,
    LINE(),LINE()];

function _roundPathRaw(path,start,end,offset=2,tension=0.551915024494) =
    let(n=len(path),
        p2=_mirrorPaths(path))
        [for(p=[for(i=[start:1:end-1]) _corner(p2[mod(i-1,n)],p2[i],path[mod(i+1,n)],offset=offset,tension=tension)]) for(q=p) q];

function PathToBezier(path,offset=2,tension=0.551915024494,closed=false) =
    let(p1=DecodeMirrored(path),
        n=len(p1))
        offset==0 && tension==0 ?
        p1 :
        !closed ? concat([p1[0],LINE(),LINE()], _roundPathRaw(p1,1,n-1,offset=offset,tension=tension), [p1[n-1]]) :
        let(p2 = _roundPathRaw(p1,0,n,offset=offset,tension=tension),
            n2 = len(p2))
        [for(i=[0:1:n2-3]) p2[mod(i,n2)]];
function BezierSmoothPoints(points,tension=0.5,closed=false)
    = let (n=len(points))
        flatten(
        closed ? [ for (i=[0:n]) SplineAroundPoint(points[(n+i-1)%n],points[i%n],points[(i+1)%n],tension=tension,includeLeftCP=i>0,includeRightCP=i<n) ] :
        [ for (i=[0:n-1])
            SplineAroundPoint(
            i==0 ? 2*points[0]-points[1] : points[(n+i-1)%n],
            points[i],
            i==n-1 ? 2*points[n-1]-points[n-2] : points[(i+1)%n],tension=tension,includeLeftCP=i>0,includeRightCP=i<n-1  ) ]);

module BezierVisualize(p,precision=0.05,eps=0.00001,lineThickness=0.25,controlLineThickness=0.125,nodeSize=1) {
    $fn = 16;
    dim = len(p[0]);
    module point(size) {
        if (dim==2)
            circle(d=size);
        else
            sphere(d=size);
    }
    p1 = DecodeSpecialBezierPoints(p);
    l = Bezier(p1,precision=precision,eps=eps);
    for (i=[0:len(l)-2]) {
        hull() {
            translate(l[i]) point(lineThickness);
            translate(l[i+1]) point(lineThickness);
        }
    }
    for (i=[0:len(p1)-1]) {
        if (i%3 == 0) {
            color("black") translate(p1[i]) point(nodeSize);
        }
        else {
            node = i%3 == 1 ? i-1 : i+1;
            color("red") translate(p1[i]) point(nodeSize);
            color("red") hull() {
                translate(p1[node]) point(controlLineThickness);
                translate(p1[i]) point(controlLineThickness);
            }
        }
    }
}


//END DEPENDENCY: use <Bezier.scad>;


//BEGIN DEPENDENCY: use <pointhull.scad>;
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
    assert(len(l2)>=3)
    let(a=l2[0],
        b=l2[1],
        l3=_slice(l2,2),
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

function _traceEdges(edgeStarts,edgeEnds,soFar=undef) =
    soFar==undef ? _traceEdges(edgeStarts,edgeEnds,[edgeStarts[0]]) :
    assert(soFar[len(soFar)-1] != undef)
    len(soFar)>1 && soFar[len(soFar)-1] == soFar[0] ? _slice(soFar,1) :
    _traceEdges(edgeStarts,edgeEnds,soFar=concat(soFar,[edgeEnds[_find(edgeStarts,soFar[len(soFar)-1])]]));

function _project(v) = [v[0],v[1]];

function pointHull2D(points) =
    let(
        p3d = concat([[0,0,1]],
            [for(p=points) [p[0],p[1],0]]),
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

function pointHull(points) =
    len(points[0]) == 2 ? pointHull2D(points) :
        pointHull3D(points);

module pointHull(points) {
    if (len(points[0])==2) {
        polygon(pointHull2D(points));
    }
    else {
        paf = _makePointsAndFaces(pointHull3D(points));
        polyhedron(points=paf[0],faces=paf[1]);
    }
}

function extractPointsFromHull(h) =
    _unique(
        is_num(h[0][0]) ? h : [for(t=h) for(v=t) v] );

function _d22(a00,a01,a10,a11) = a00*a11-a01*a10;

function _determinant3x3(m) = m[0][0]*_d22(m[1][1],m[1][2],m[2][1],m[2][2])
    -m[0][1]*_d22(m[1][0],m[1][2],m[2][0],m[2][2])
    +m[0][2]*_d22(m[1][0],m[1][1],m[2][0],m[2][1]);

function _determinant2x2(m) = _d22(m[0][0],m[0][1],m[1][0],m[1][1]);

// Cramer's rule
// n.b. Determinant of matrix is the same as of its transpose
function _solve3(a,b,c) =
    let(det=_determinant3x3([a[0],b[0],c[0]]))
    det == 0 ? undef :
    let(rhs=[a[1],b[1],c[1]],
        col0=[a[0][0],b[0][0],c[0][0]],
        col1=[a[0][1],b[0][1],c[0][1]],
        col2=[a[0][2],b[0][2],c[0][2]])
    [_determinant3x3([rhs,col1,col2]),
    _determinant3x3([col0,rhs,col2]),
    _determinant3x3([col0,col1,rhs])]/det;

function _solve2(a,b) =
    let(det=_determinant2x2([a[0],b[0]]))
    det == 0 ? undef :
    let(rhs=[a[1],b[1]],
        col0=[a[0][0],b[0][0]],
        col1=[a[0][1],b[0][1]])
    [_determinant2x2([rhs,col1]),
    _determinant2x2([col0,rhs])]/det;

function _satisfies(p,constraint) =
    p*constraint[0] <= constraint[1];

function _linearConstraintExtrema(constraints,constraintsMarked=false) =
        let(c=_unique(constraints),
            n=len(c))
        len(c[0][0]) == 3 ?
        [
        for(i=[0:1:n-1]) for(j=[i+1:1:n-1]) for(k=[j+1:1:n-1]) let(p=_solve3(c[i],c[j],c[k])) if(p!=undef && _satisfiesAll(p,c,except1=i,except2=j,except3=k)) constraintsMarked?[p,[i,j,k]]:p
        ] :
        [
        for(i=[0:1:n-1]) for(j=[i+1:1:n-1]) let(p=_solve2(c[i],c[j])) if(p!=undef && _satisfiesAll(p,c,except1=i,except2=j)) constraintsMarked?[p,[i,j,-1]]:p
        ];

function _satisfiesAll(p,c,except1=undef,except2=undef,except3=undef,pos=0) =
        pos >= len(c) ? true :
        except1 == pos || except2 == pos || except3 == pos || _satisfies(p,c[pos]) ? _satisfiesAll(p,c,except1,except2,except3,pos=pos+1) :
        false;


module linearConstraintShape(constraints) {
    pointHull(_linearConstraintExtrema(constraints));
}

// 3D inly
function _onPlane(v,planeIndex,data,pos=0) =
    pos >= len(data) ? false :
    data[pos][0] == v && (data[pos][1][0] == planeIndex || data[pos][1][1] == planeIndex || data[pos][1][2] == planeIndex) ? true :
    _onPlane(v,planeIndex,data,pos=pos+1);

// 3D only
function _getFaceOnPlane(planeIndex,triangles,data) =
    let(trianglesOnPlane = [for(t=triangles) if (_onPlane(t[0],planeIndex,data) &&
        _onPlane(t[1],planeIndex,data) &&
        _onPlane(t[2],planeIndex,data)) t],
        outer = _outerEdges(trianglesOnPlane),
        edgeStarts = [for(e=outer) e[0]],
        edgeEnds = [for(e=outer) e[1]]
    ) len(outer) == 0 ? undef : echo("se",edgeStarts,edgeEnds) _traceEdges(edgeStarts,edgeEnds);

// 3D only, does not work if there are multiple planes defined by the same constraint
function linearConstraintPointsAndFaces(constraints) =
    let(data=_linearConstraintExtrema(constraints,constraintsMarked=true),
    extremePoints=[for(d=data) d[0]],

    triangles=pointHull(extremePoints),
    hullPoints=extractPointsFromHull(triangles),
    faces=[for (i=[0:len(constraints)-1]) [for(v=_getFaceOnPlane(i,triangles,data)) if(v != undef) _find(hullPoints,v)]]
    )
    [hullPoints,faces];

function hullPoints(points) =
    extractPointsFromHull(pointHull(points));

module dualHull(points) {
    p = hullPoints(points);
    constraints = [for(v=p) [v,v*v]];
    linearConstraintShape(constraints);
}


//END DEPENDENCY: use <pointhull.scad>;



module dummy() {}

$fn = 36;

nudge = 0.01;

wiiY = 30.8;
size_xsect_0 = [36.240508333,29.876988125];
size_xsect_1 = [size_xsect_0[0],wiiY];
// paths for xsect_1

points_xsect_1_1 = [ [-6.340977708,14.938494063],[-10.041222909,13.991003059],[-11.542611892,13.335288548],[-12.832843571,12.588143262],[-14.843830332,10.909206052],[-16.202173828,9.133482813],[-17.035864698,7.440264924],[-17.472893577,6.008843770],[-17.668927917,4.648557188],[-18.120254167,-5.506045312],[-18.120254167,-13.404016562],[-17.859895898,-14.081701709],[-17.287107708,-14.560520234],[-16.453961250,-14.938494063],[-0.157929792,-14.938494063],[16.454040625,-14.938494063],[17.287147396,-14.560520234],[17.859908301,-14.081701709],[18.120254167,-13.404016562],[18.120254167,-5.506045312],[17.668954375,4.648557188],[17.472919622,6.008843770],[17.035889761,7.440264924],[16.202196979,9.133482813],[14.843850330,10.909206052],[12.832858867,12.588143262],[11.542624159,13.335288548],[8.312682448,14.532875371],[6.340977708,14.938494063],[-6.340977708,14.938494063] ];

module xsect(delta=0) {
 render(convexity=4) {
    rotate(180)
    offset(r=delta)
    scale([1,wiiY/size_xsect_0[1]])
    polygon(points=points_xsect_1_1);
 }
}

module outline() {
    w  = size_xsect_1[0]+2*tolerance-2*tabSize;
    difference() {
        union() {
            xsect(delta=tolerance+wallThicknesss);
            w1 = gripWidth;
            if (!includeGrip) translate([-w1/2,-size_xsect_1[1]/2-extrawallThicknesss-tolerance-wallThicknesss]) square([w1,extrawallThicknesss+wallThicknesss+nudge]);
        }
        xsect(delta=tolerance);
        translate([-w/2,0]) square([w,size_xsect_1[1]+tolerance+wallThicknesss]);
    }
}

module screwHoles() {
    for (i=[0.25,0.75])
    translate([0,-size_xsect_1[1]/2-tolerance,i*gripLength])
    rotate([-90,0,0]) {
        translate([0,0,-100+nudge]) cylinder(d=screwHoleDiameter,h=100);
        translate([0,0,-screwHoleInsetDepth+2*nudge]) cylinder(d1=screwHoleDiameter,d2=screwHoleInsetDiameter,h=screwHoleInsetDepth);
    }
}

module gripless() {
    difference() {
        linear_extrude(height=gripLength)
        outline();
        screwHoles();
    }
}

gripOffset = gripHeight*tan(gripAngle);

gripOutlineSideView = let(dx = sin(gripAngle) * gripBevel,
    dy = cos(gripAngle) * gripBevel, h = size_xsect_1[1]+2*wallThicknesss+2*tolerance) Bezier(
    [[h*tan(gripAngle),h],LINE(),LINE(),[h*tan(gripAngle)+gripLength,h],LINE(),LINE(),[gripLength-gripOffset+dx,-gripHeight+dy],OFFSET([-dx,-dy]*0.5),OFFSET([gripBevel*0.5,0]),[gripLength-gripOffset-gripBevel,-gripHeight],LINE(),LINE(),[-gripOffset+gripBevel,-gripHeight],LINE(),LINE(),[-gripOffset+dx,-gripHeight+dy]]);

gripOutlineBottomView = Bezier([[-nudge,gripWidth/2],LINE(),LINE(),[-nudge,gripBevel],LINE(),LINE(),[gripBevel,0],LINE(),LINE(),[gripLength-gripBevel,0],SMOOTH_ABS(gripBevel*0.5),SMOOTH_ABS(gripBevel*0.5),[gripLength,gripBevel],LINE(),LINE(),[gripLength,gripWidth/2],REPEAT_MIRRORED([0,1])]);

function atXY(points2D,x,y) = [for (p=points2D) [p[0]+x,y,p[1]]];

module grip() {
    translate([0,0,-nudge])
    rotate([0,-90,0])
    rotate([0,0,gripAngle])
    intersection() {
        union() {
            pointHull(concat(atXY(gripOutlineBottomView,wallThicknesss/2*tan(gripAngle),wallThicknesss/2),atXY(gripOutlineBottomView,-gripOffset,-gripHeight)));
           translate([0,0,gripWidth/2]) rotate([0,90,0]) translate([0,size_xsect_1[1]/2-nudge+tolerance+wallThicknesss,0]) linear_extrude(height=gripLength+tan(gripAngle)*(2*tolerance+2*wallThicknesss+size_xsect_1[1])) outline();
        }
        linear_extrude(height=3*gripWidth+size_xsect_1[1]*3,center=true) polygon(gripOutlineSideView);
    }
}

module grippy() {
    grip();
}

if (!includeGrip)
    gripless();
else
    grip();

