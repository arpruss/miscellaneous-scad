// This file was processed by resolve-include.py [https://github.com/arpruss/miscellaneous-scad/blob/master/scripts/resolve-include.py] 
// to include  all the dependencies inside one file.


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


//BEGIN DEPENDENCY: use <triangulation.scad>;
function _furthestAwayFromPoint(points,poly,z,bestD=-1,bestPos=0,pos=0) =
    len(poly) <= pos ? bestPos :
    norm(points[poly[pos]]-z) > bestD ? _furthestAwayFromPoint(points,poly,z,bestD=norm(points[poly[pos]]-z),bestPos=pos,pos=pos+1) :
    _furthestAwayFromPoint(points,poly,z,bestD=bestD,bestPos=bestPos,pos=pos+1);

function _triangleArea(a,b,c) = norm(cross(b-a,c-a))/2;

function _furthestAwayFromLine(points,poly,z1,z2,bestArea=-1,bestPos=0,pos=0) =
    len(poly) <= pos ? bestPos :
    _triangleArea(z1,z2,points[poly[pos]]) > bestArea ? _furthestAwayFromLine(points,poly,z1,z2,bestArea=_triangleArea(z1,z2,points[poly[pos]]),bestPos=pos,pos=pos+1) :
    _furthestAwayFromLine(points,poly,z1,z2,bestArea=bestArea,bestPos=bestPos,pos=pos+1);

function normalize(v) = v/norm(v);

function _winding(points,poly,sum=0,pos=0) =
    pos >= len(poly) ? sum :
    _winding(points,poly,sum=sum+(points[poly[(pos+1)%len(poly)]][0]-points[poly[pos]][0])*(points[poly[(pos+1)%len(poly)]][1]+points[poly[pos]][1]),pos=pos+1);

function _isCCW(points,poly) =
_winding(points,poly) < 0;

function identifyPlane(points,poly) = let(i=_furthestAwayFromPoint(points,poly,points[poly[0]]),
           j=_furthestAwayFromLine(points,poly,points[poly[0]],points[poly[i]]),
           normal = cross(points[poly[i]]-points[poly[0]],points[poly[j]]-points[poly[0]]),
           a = points[poly[i]]-points[poly[0]],
           b = cross(normal,a),
           cs = [points[poly[0]],normalize(a),normalize(b),normalize(normal)])
           _isCCW(projectPoints(cs,points),poly) ? cs : [cs[0],-cs[1],cs[2],cs[3]];

function projectPoint(coordsys,p) = let(v=p-coordsys[0],
           vp=v-(v*coordsys[3])*coordsys[3]) [vp*coordsys[1],vp*coordsys[2]];

function projectPoints(coordsys,p) = [for(v=p) projectPoint(coordsys,v)];

function triangulate(points,poly=undef) =
    let(poly = poly==undef ? [for(i=[0:1:len(points)-1]) i] : poly)
    len(points[poly[0]]) == 2 ? triangulate2D(points,poly) : triangulate2D(projectPoints(identifyPlane(points,poly),points),poly);

function mod(a,b) = let(m=a%b) m < 0 ? m+b : m;

function _delPoint(v,i) = [for(j=[0:1:len(v)-1]) if(i!=j) v[j]];

function _isCCWTriangle(a,b,c) = cross(b-a,c-a) >= 0;

function _crosses(points,poly,a,b,ignore,pos=0) =
    pos >= len(poly) ? false :
    ignore != pos && ignore !=  mod(pos+1,len(poly)) && _isCross(points[poly[pos]],points[poly[mod(pos+1,len(poly))]],a,b) ? true : _crosses(points,poly,a,b,pos=pos+1);

function _isReflex(points,poly,i) =
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]]) cross(b-a,c-b) < 0;

function _checkEar2(points,poly,a,b,c,j) =
   let(p=points[poly[mod(j,len(poly))]],
       c1=cross(p-a,b-a))
       ! ( c1*cross(p-b,c-b) >0 && c1*cross(p-c,a-c)>0 );

function _checkEar(points,poly,a,b,c,i,j) =
    mod(j,len(poly))==mod(i-1,len(poly)) ? true :
    _isReflex(points,poly,mod(j,len(poly))) && ! _checkEar2(points,poly,a,b,c,j) ? false :
    _checkEar(points,poly,a,b,c,i,j+1);

function _isEar(points,poly,i) =
    _isReflex(points,poly,i) ? false :
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]],
        j=i+2)
        _checkEar(points,poly,a,b,c,i,i+2);

function _findEar(points,poly,pos=0) =
    assert(pos<len(poly))
    _isEar(points,poly,pos) ? pos : _findEar(points,poly,pos=pos+1);

function _cutEar(points,poly) =
    let(n=len(poly),
        i=_findEar(points,poly))
        _delPoint(poly,i);

function _getEar(points,poly) =
    let(n=len(poly),
        i=_findEar(points,poly))
        [poly[mod(i-1,n)],poly[i],poly[mod(i+1,n)]];

function triangulate2D(points,poly,soFar=[]) =
    len(poly) == 3 ? concat(soFar,[poly]) :
    triangulate2D(points,_cutEar(points,poly),soFar=concat(soFar,[_getEar(points,poly)]));

module showMesh(points,tt,width=1)
{
    for(t=tt) {
        for(i=[0:1:len(t)-1]) {
            hull() {
                translate(points[t[i]]) sphere(d=width);
                translate(points[t[(i+1)%len(t)]]) sphere(d=width);
            }
        }
    }
}

function _find(needle,haystack) = let(f=search([needle], haystack)) f==[[]] ? undef : f[0];

function _refineTriangle(triangle,maxEdge) =
    let(a = triangle[0],
        b = triangle[1],
        c = triangle[2],
        ab = norm(a-b),
        bc = norm(b-c),
        ca = norm(c-a))
        ab <= maxEdge && bc <= maxEdge && ca <= maxEdge ? [triangle] :
        ab > maxEdge && bc > maxEdge && ca > maxEdge ? [[a,(a+b)/2,(a+c)/2],[b,(b+c)/2,(a+b)/2],[c,(a+c)/2,(b+c)/2],[(a+c)/2,(a+b)/2,(b+c)/2]] :
    ab > maxEdge && bc > maxEdge ? [[b,(b+c)/2,(a+b)/2],[a,(a+b)/2,(b+c)/2],[c,a,(b+c)/2]] :
    bc > maxEdge && ca > maxEdge ? [[c,(c+a)/2,(b+c)/2],[b,(b+c)/2,(c+a)/2],[a,b,(c+a)/2]] :
    ca > maxEdge && ab > maxEdge ? [[a,(a+b)/2,(c+a)/2],[c,(c+a)/2,(a+b)/2],[b,c,(a+b)/2]] :
    ab > maxEdge ? [[a,(a+b)/2,c],[(a+b)/2,b,c]] :
    bc > maxEdge ? [[b,(b+c)/2,a],[(b+c)/2,c,a]] :
    /*ca > maxEdge */ [[c,(c+a)/2,b],[(c+a)/2,a,b]];

function _refineMesh1(triangles,maxEdge,pos=0,newTriangles=[]) =
    pos >= len(triangles) ? newTriangles :
    _refineMesh1(triangles,maxEdge,pos=pos+1,newTriangles=concat(newTriangles,_refineTriangle(triangles[pos],maxEdge)));

function _maxEdge(faces) = max([for(f=faces) for(i=[0:len(f)-1]) norm(f[(i+1)%len(f)]-f[i])]);

function _refineMeshN(triangles,maxEdge,n=0) =
    n <= 0 ? triangles : _refineMeshN(_refineMesh1(triangles,maxEdge),maxEdge,n=n-1);

function _newPointsAndFaces(pointsAndFaces,face,faceSoFar=[]) =
    let(pos=len(faceSoFar),
        points=pointsAndFaces[0],
        faces=pointsAndFaces[1]
    )
    pos >= len(face) ? [points,concat(faces,[faceSoFar])] :
    let(v=face[pos],
        i=_find(v,points)) i==undef ? _newPointsAndFaces([concat(points,[v]),faces],face,faceSoFar=concat(faceSoFar,[len(points)])) : _newPointsAndFaces(pointsAndFaces,face,faceSoFar=concat(faceSoFar,[i]));

function _toPointsAndFaces(faces,pointsAndFaces=[[],[]], pos=0) =
    pos >= len(faces) ? pointsAndFaces :
    _toPointsAndFaces(faces,_newPointsAndFaces(pointsAndFaces,faces[pos]),pos=pos+1);

function refineMesh(points=[],triangles=[],maxEdge=5) =
    let(tris = [for (t=triangles) [for (v=t) points[v]]],
        longestEdge = _maxEdge(tris),
        n = ceil(ln(longestEdge/maxEdge)/ln(2)),
        newTris = _refineMeshN(tris, maxEdge, n)) _toPointsAndFaces(newTris);


//END DEPENDENCY: use <triangulation.scad>;


//BEGIN DEPENDENCY: use <inflate.scad>;

//BEGIN DEPENDENCY: use <eval.scad>;
function _isRange(v) = !is_list(v) && !is_string(v) && v[0] != undef;

$careful = false;

function _substr(s, start=0, stop=undef, soFar = "") =
    start >= (stop==undef ? len(s) : stop) ? soFar :
        _substr(s, start=start+1, stop=stop, soFar=str(soFar, s[start]));

function _parseInt(s, start=0, stop=undef, accumulated=0) =
    let( stop = stop==undef ? len(s) : stop )
        start >= stop ? accumulated :
        s[start] == "+" ? _parseInt(s, start=start+1, stop=stop) :
        s[start] == "-" ? -_parseInt(s, start=start+1, stop=stop) :
        let (digit = search(s[start], "0123456789"))
            digit == [] ? 0 : _parseInt(s, start=start+1, stop=stop, accumulated=accumulated*10+digit[0]);

function _findNonDigit(s, start=0) =
    start >= len(s) || s[start]<"0" || s[start]>"9" ? start :
    _findNonDigit(s, start=start+1);

function _replaceChar(s,c1,c2,pos=0,soFar="") =
    pos >= len(s) ? soFar :
    _replaceChar(s,c1,c2,pos=pos+1,soFar=str(soFar, s[pos]==c1 ? c2 : s[pos]));

function _parseUnsignedFloat(s) =
    len(s) == 0 ? 0 :
        let(
            firstNonDigit = _findNonDigit(s),
            decimalPart = s[firstNonDigit]!="." ?
                [firstNonDigit,firstNonDigit] : [firstNonDigit+1, _findNonDigit(s, start=firstNonDigit+1)],
            intPart = _parseInt(s,start=0,stop=firstNonDigit),
            fractionPart = _parseInt(s,start=decimalPart[0],stop=decimalPart[1]),
            baseExp = s[decimalPart[1]]=="e" || s[decimalPart[1]]=="E" ? pow(10,_parseInt(s, start=decimalPart[1]+1)) : 1)
            (intPart+fractionPart*pow(10,-(decimalPart[1]-decimalPart[0])))*baseExp;

function _tail(v) = len(v)>=2 ? [for(i=[1:len(v)-1]) v[i]] : [];
function _isspace(c) = (" " == c || "\t" == c || "\r" == c || "\n" == c );
function _isdigit(c) = ("0" <= c && c <= "9" );
function _isalpha(c) = ("a" <= c && c <= "z") || ("A" <= c && c <= "Z");
function _isalpha_(c) = _isalpha(c)  || c=="_";
function _isalnum_(c) = _isalpha(c) || _isdigit(c) || c=="_";
function _flattenLists(ll) = [for(a=ll) for(b=a) b];

function _spaceSequence(s, start=0, count=0) =
    len(s)>start && _isspace(s[start]) ? _spaceSequence(s, start=start+1, count=count+1) : count;
function _digitSequence(s, start=0, count=0) =
    len(s)>start && _isdigit(s[start]) ? _digitSequence(s, start=start+1,count=count+1) : count;
function _alnum_Sequence(s, start=0, count=0) =
    len(s)>start && _isalnum_(s[start]) ? _alnum_Sequence(s, start=start+1,count=count+1) : count;
function _identifierSequence(s, start=0, count=0) =
    len(s)>start && _isalpha_(s[start]) ? _alnum_Sequence(s, start=start+1, count=count+1) : count;
function _signedDigitSequence(s, start=0) =
    len(s) <= start ? 0 :
        (s[start] == "+" || s[start] == "-" ) ? 1+_digitSequence(s,start=start+1) : _digitSequence(s,start=start);
function _realStartingWithDecimal(s, start=0) =
    len(s)>start && s[start] == "." ?
        let(next = start+1+_digitSequence(s, start=start+1))
        (s[next] == "e" || s[next] == "E" ?
            next-start+1+_signedDigitSequence(s, start=next+1) : next-start)
        : 0;
function _realContinuation(s, start=0) =
    len(s) <= start ? 0 :
        let(c1=_realStartingWithDecimal(s, start=start))
        c1 > 0 ? c1 :
        s[start] == "e" || s[start] == "E" ?
            1+_signedDigitSequence(s, start=start+1) : 0;
function _positiveRealSequence(s, start=0) =
    len(s) <= start ? 0 :
        let(c1 = _realStartingWithDecimal(s, start=start))
            c1 > 0 ? c1 :
        let(c2 = _digitSequence(s, start=start))
            c2 > 0 ? c2 + _realContinuation(s, start=start+c2) : 0;

_multiSymbolOperators = [ "<=", ">=", "==", "&&", "||" ]; // must be in order of decreasing length

function _multiSymbolOperatorSequence(s, start=0) =
    (s[start]=="<" && s[start+1]=="=") ||
    (s[start]==">" && s[start+1]=="=") ||
    (s[start]=="=" && s[start+1]=="=") ||
    (s[start]=="!" && s[start+1]=="=") ||
    (s[start]=="&" && s[start+1]=="&") ||
    (s[start]=="|" && s[start+1]=="|") ? 2 : 0;

function _tokenize(s, start=0) =
    start >= len(s) ? [] :
    let(c1=_spaceSequence(s, start=start)) c1>0 ?
        concat([" "], _tokenize(s, start=start+c1)) :
    let(c2=_identifierSequence(s, start=start)) c2>0 ?
        concat([_substr(s, start=start, stop=start+c2)], _tokenize(s, start=start+c2)) :
    let(c3=_positiveRealSequence(s, start=start)) c3>0 ?
        concat([_substr(s, start=start, stop=start+c3)], _tokenize(s, start=start+c3)) :
    let(c4=_multiSymbolOperatorSequence(s, start=start)) c4>0 ?
        concat([_substr(s, start=start, stop=start+c4)], _tokenize(s, start=start+c4)) :
        concat([s[start]], _tokenize(s, start=start+1));


function _endParens(list,start=0,openCount=0,stop=undef) =
    let(stop = stop==undef ? len(list) : stop)
    start >= stop ? (openCount?undef:stop) :
    list[start][0] == ")" ?
            (openCount==1 ? start+1 : _endParens(list,start+1,stop=stop, openCount=openCount-1)) :
    _endParens(list,start+1,stop=stop, openCount=
        list[start][0] == "(" ?
            openCount+1 : openCount);

function _indexInTable(string, table, column=0) =
    let (s=search([string], table, index_col_num=column))
        s[0] == [] ? -1 : s[0][0];

_NAME = 0;
_ARITY = 1;
_PREC = 2;
_ASSOC_DIR = 3;
_ARGUMENTS_FROM_VECTOR = 4;
_OPERATOR = 5;
_EXTRA_DATA = 6;

function _func(op) = [ op, 1, -1, 1, true, op ];

_operators = [
    [ "[", 1, -1, 1, true, "[" ],
    [ "pow", 1, -1, 1, true, "^" ],
    [ "cross", 1, -1, 1, true, "cross" ],
    _func("sqrt"),
    _func("cos"),
    _func("sin"),
    _func("tan"),
    _func("acos"),
    _func("asin"),
    _func("atan"),
    _func("COS"),
    _func("SIN"),
    _func("TAN"),
    _func("ACOS"),
    _func("ASIN"),
    _func("ATAN"),
    _func("abs"),
    _func("ceil"),
    _func("exp"),
    _func("floor"),
    _func("ln"),
    _func("log"),
    _func("round"),
    _func("sign"),
    _func("norm"),
    [ "atan2", 1, -1, 1, true, "atan2" ],
    [ "ATAN2", 1, -1, 1, true, "ATAN2" ],
    [ "max", 1, -1, 1, true, "max" ],
    [ "min", 1, -1, 1, true, "min" ],
    [ "concat", 1, -1, 1, true, "concat" ],
    [ "#", 2, 0, -1, false, "#" ],
    [ "^", 2, 0, -1, false, "^" ],
    [ "#-",1, 0.5, 0, true, "-" ],
    [ "#+",1, 0.5, 0, true, "+" ],
    [ "*", 2, 1, 1, false, "*" ],
    [ "/", 2, 1, 1, false, "/" ],
    [ "%", 2, 1, 1, false, "%" ],
    [ "+", 2, 2, 1, true, "+" ],
    [ "-", 2, 2, 1, true, "-" ],
    [ "!=", 2, 3, 1, true, "!=" ],
    [ "==", 2, 3, 1, true, "==" ],
    [ "<=", 2, 3, 1, true, "<=" ],
    [ ">=", 2, 3, 1, true, ">=" ],
    [ "<", 2, 3, 1, true, "<" ],
    [ ">", 2, 3, 1, true, ">" ],
    [ "!", 1, 4, 1, true, "!" ],
    [ "&&", 2, 5, 1, true, "&&" ],
    [ "||", 2, 5, 1, true, "||" ],
    [ "?", 2, 10, -1, true, "?" ],
    [ ":", 2, 10, -1, true, ":" ],
    [ "=", 2, 30, 1, true, "=" ], // for let()
    [ "let", 1, 25, 1, true, "let" ],
    [ ",", 2, 100, 1, true, "," ]
   ];

_binary_or_unary = [ ["-", "#-"], ["+", "#+"], ["#", "["] ];

// insert parentheses in some places to tweak the order of
// operations in those contexts
function _fixBrackets(pretok,start=0) =
    start >= len(pretok) ? [] :
    pretok[start] == "[" ?
        concat(["#", "("], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == "]" ?
        concat([")"], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == "?" ?
        concat([pretok[start],"("], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == ":" ?
        concat([")",pretok[start]], _fixBrackets(pretok,start=start+1)) :
        concat(pretok[start], _fixBrackets(pretok,start=start+1));

// disambiguate operators that can be unary or binary
function _fixUnaries(pretok) =
    [ for (i=[0:len(pretok)-1])
         let (
            a = pretok[i],
            j=_indexInTable(a, _binary_or_unary))
            (0 <= j && (i == 0 || pretok[i-1] == "(" ||
                0 <= _indexInTable(pretok[i-1], _operators)))? _binary_or_unary[j][1] : a ];

function _fixLet1(tok, start=0, stop=undef) =
    let (stop = stop==undef ? len(tok) : stop)
        start >= stop ? [] :
        tok[start][0] == "let"?
           let(endP=_endParens(tok,start=start+1,stop=stop,openCount=0)) concat([concat(tok[start], [_fixLet1(tok,start=start+2,stop=endP-1)])], _fixLet1(tok,start=endP,stop=stop)) :
        concat([tok[start]], _fixLet1(tok,start=start+1,stop=stop));

function _parsePass1(s) =
    let (pretok=_fixUnaries(_fixBrackets(_tokenize(s))))
    _fixLet1(
    [ for (i=[0:len(pretok)-1])
        let (a=pretok[i])
        if (a[0] != " ")
            let (j=_indexInTable(a, _operators))
                j >= 0 ? _operators[j] : [a] ] );

function _prec(op1, pos1, op2, pos2) =
    op1 != undef && op2 == undef ? false :
    op1 == undef && op2 != undef ? true :
    op1 == undef && op2 == undef ? true :
    op1[_ARITY] == 1 && pos1 > pos2 ? true :
    op2[_ARITY] == 1 && pos2 > pos1 ? false :
    op1[_PREC] < op2[_PREC] ? true :
        op2[_PREC] < op1[_PREC] ? false :
            op1[_ASSOC_DIR] * pos1 < op2[_ASSOC_DIR] * pos2;

function _parseLiteralOrVariable(s) =
        s == "PI" ? PI :
        s == "true" ? true :
        s == "false" ? false :
        //s == "undef" ? undef : // TODO: better fix for undef than this hackish one
        _isalpha_(s[0]) ? s :
        _parseUnsignedFloat(s);

function _isoperator(token) = _PREC<len(token);

function _getCandidatesForMainOperator(tok,start,stop) =
   start >= stop ? [] :
   tok[start][0] == "(" ?
        _getCandidatesForMainOperator(tok,_endParens(tok,start=start+1,stop=stop,openCount=1),stop)
        :
        _isoperator(tok[start]) ? concat([[tok[start],start]],_getCandidatesForMainOperator(tok,start+1,stop)) :
        _getCandidatesForMainOperator(tok,start+1,stop);

// Find the operator with least precedence
function _findMainOperatorPos(candidates,start=0) =
    len(candidates) <= start ? undef :
    let(rest=_findMainOperatorPos(candidates,start+1))
    _prec(candidates[rest][0], rest, candidates[start][0], start) ? start : rest;

function _firstOccurrence(c,opName,start=0) =
    start >= len(c) ? undef :
    c[start][0][0] == opName ? c[start] :
        _firstOccurrence(c,opName,start=start+1);

function _mainOperator(tok,start,stop) =
    let(c=_getCandidatesForMainOperator(tok,start,stop),
        pos=_findMainOperatorPos(c),
        m=c[pos])
        m[0][0] == "?" ?
            concat(m, [_firstOccurrence(c,":",start=pos+1)[1]])
            : m;

function _doLets(assignments, final, start=0) =
    start >= len(assignments) ? final :
    assignments[start][0] == "=" ? ["let", ["'", assignments[start][1]], assignments[start][2], _doLets(assignments, final, start=start+1)] : _doLets(assignments, final, start=start+1);

function _letOperator(a,b) =
    let(rawAssignments=_fixCommas(a),
        assignments=rawAssignments[0] == "[[" ?
            _tail(rawAssignments) : [a])
    _doLets(assignments, b);

/* This takes a fully tokenized vector, each element of which is either a line from the _operators table or a vector containing a single non-operator string, and parses it using general parenthesis and operator parsing. Comma expressions for building vectors will be parsed in the next pass. */
function _parseMain(tok,start=0,stop=undef) =
    let( stop= stop==undef ? len(tok) : stop )
        stop <= start ? [] :
        tok[start][0] == "(" && _endParens(tok,start=start+1,stop=stop,openCount=1)==stop ?
            _parseMain(tok,start=start+1,stop=stop-1) :
        let( lp = _mainOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] )
                op[_NAME] == "?" ?
                    [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), _parseMain(tok,start=pos+1,stop=lp[2]), _parseMain(tok,start=lp[2]+1,stop=stop) ] :
                op[_NAME] == "let" ?
                    _letOperator( _parseMain(op[_EXTRA_DATA]), _parseMain(tok,start=pos+1,stop=stop)) :
                let(rhs=_parseMain(tok,start=pos+1,stop=stop))
                op[_ARITY] == 2 ?
                    (start==pos ?
                    /* unary use of binary operator */
                    let(j=_indexInTable(op[_OPERATOR], _binary_or_unary)) [ _binary_or_unary[j][1],rhs] : [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), rhs])
                    : [ op[_OPERATOR], rhs ];


// this upgrades sequences of binary commas to vectors
function _fixCommas(expression) =
    expression[0] == "," ?
        let(a=_fixCommas(expression[1]),
            b=_fixCommas(expression[2]))
            a[0] == "[[" ?
                concat(["[["],concat(_tail(a), [b])) :
                ["[[",a,b]
        :
    is_list(expression) ?
            (expression[1] == [] ? [expression[0]] :
            concat([expression[0]], [for (i=[1:1:len(expression)-1]) _fixCommas(expression[i])]) ) :
            expression;

// fix arguments from vectors
function _fixArguments(expression) =
    let(i=_indexInTable(expression[0], _operators, _OPERATOR))
            i >=0 && _operators[i][_ARGUMENTS_FROM_VECTOR] && expression[1][0] == "[[" ? concat([expression[0]], [for (i=[1:len(expression[1])-1]) _fixArguments(expression[1][i])]) :
/*            expression[0] == "?" ?
                concat([expression[0],expression[1]],[for (i=[1:len(expression[2])-1]) _fixArguments(expression[2][i])]) : */
            is_list(expression) && len(expression)>1 ?
                concat([expression[0]], [for (i=[1:len(expression)-1]) _fixArguments(expression[i])])
                    : expression;

function _optimizedLiteral(x) =
    is_num(x) || is_bool(x) || is_undef(x) ? x : ["'", x];

function _wellDefined(x) =
    is_undef(x) ? false :
    is_num(x) || is_bool(x) ? true :
    x[0] == "'" ? true :
    len(x)==1 ? x[0]!=undef :
    len([for (a=x) if(!_wellDefined(a)) true])==0;

function _optimize(expression) =
    let(x=eval(expression,$careful=true))
        _wellDefined(x) ? _optimizedLiteral(x) :
        expression[0] == "'" ? _optimizedLiteral(x) :
        ! is_string(expression) ?
            concat([expression[0]], [for(i=[1:len(expression)-1]) (i>1 || expression[0] != "let") ?  _optimize(expression[i]) : expression[i]]) :
        expression;

function compileFunction(expression,optimize=true) =
            is_list(expression) ? expression :
            is_num(expression) ? expression :
            let(unoptimized = _fixArguments(_fixCommas(_parseMain(_parsePass1(expression)))))
        optimize ? _optimize(unoptimized) : unoptimized;

function evaluateFunction(expression,variables) = eval(compileFunction(expression,optimize=false),variables);

function _let(v, var, value) = concat([var, value], v);

function _lookupVariable(var, table) =
    let (s=search([var], table, index_col_num=0))
        s[0] == [] ? undef : table[s[0][0]][1];

function _generate(var, range, expr, v) =
    [ for(i=range) eval(expr, _let(v, var, i)) ];

function _haveUndef(v,n=0) =
    n >= len(v) ? false :
    is_undef(v[n]) ? true :
    _haveUndef(v,n=n+1);

function eval(c,v=[]) =
    is_string(c) ? _lookupVariable(c,v) :
    let(op=c[0]) (
    op == undef ? c :
    op == "'" ? c[1] :
    op == "&&" ? (!$careful ? eval(c[1],v)&&eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        !c1 ? false :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 && c2) ) :
    op == "||" ? (!$careful ? eval(c[1],v)||eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        c1 ? true :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 || c2) ) :
    op == "let" ? (!$careful ? eval(c[3],concat([[eval(c[1],v),eval(c[2],v)]], v)) :
            let(c1=eval(c[1],v),c2=eval(c[2],v))
                c1==undef || c2==undef ? undef :
                    eval(c[3],concat([[c1,c2]], v)) ) :
    op == "gen" ? _generate(eval(c[1],v),eval(c[2],v),c[3],v) :
    let(args = [for(i=[1:1:len(c)-1]) eval(c[i],v)])
        $careful && _haveUndef(args) ? undef :
    op == "+" ? (len(args)==1 ? args[0] : args[0]+args[1]) :
    op == "-" ? (len(args)==1 ? -args[0] : args[0]-args[1]) :
    op == "*" ? args[0]*args[1] :
    op == "/" ? args[0]/args[1] :
    op == "%" ? args[0]%args[1] :
    op == "sqrt" ? sqrt(args[0]) :
    op == "^" || op == "pow" ? pow(args[0],args[1]) :
    op == "cos" ? cos(args[0]) :
    op == "sin" ? sin(args[0]) :
    op == "tan" ? tan(args[0]) :
    op == "acos" ? acos(args[0]) :
    op == "asin" ? asin(args[0]) :
    op == "atan" ? atan(args[0]) :
    op == "atan2" ? atan2(args[0],args[1]) :
    op == "COS" ? cos(args[0]*180/PI) :
    op == "SIN" ? sin(args[0]*180/PI) :
    op == "TAN" ? tan(args[0]*180/PI) :
    op == "ACOS" ? acos(args[0])*PI/180 :
    op == "ASIN" ? asin(args[0])*PI/180 :
    op == "ATAN" ? atan(args[0])*PI/180 :
    op == "ATAN2" ? atan2(args[0],args[1])*PI/180 :
    op == "abs" ? abs(args[0]) :
    op == "ceil" ? ceil(args[0]) :
    op == "cross" ? cross(args[0],args[1]) :
    op == "exp" ? exp(args[0]) :
    op == "floor" ? floor(args[0]) :
    op == "ln" ? ln(args[0]) :
    op == "len" ? len(args[0]) :
    op == "log" ? log(args[0]) :
    op == "max" ? (len(args) == 1 ? max(args[0]) : max(args)) :
    op == "min" ? (len(args) == 1 ? min(args[1]) : min(args)) :
    op == "norm" ? norm(args[0]) :
    op == "rands" ? rands(args[0],args[1],args[2],args[3]) :
    op == "round" ? round(args[0]) :
    op == "sign" ? sign(args[0]) :
    op == "[" ? args :
    op == "#" ? args[0][args[1]] :
    op == "<" ? args[0]<args[1] :
    op == "<=" ? args[0]<=args[1] :
    op == ">=" ? args[0]>=args[1] :
    op == ">" ? args[0]>args[1] :
    op == "==" ? args[0]==args[1] :
    op == "!=" ? args[0]!=args[1] :
    op == "!" ? !args[0] :
    op == "?" ? (args[0]?args[1]:args[2]) :
    op == "concat" ? [for (a=args) for(v=a) v] :
    op == "range" ? (len(args)==2 ? [args[0]:args[1]] : [args[0]:args[1]:args[2]]) :
    undef
    );

// per 10,000 operations with "x^3*y-x*y^3"
// 24 sec compile
// 21 sec unoptimized compile
// 22 sec evaluateFunction()
// 0.7 sec eval

// pass1 10 seconds [tokenize: 4 seconds]
// parseMain 6
// fixCommas 0
// fixArguments 3
// optimize 3
/*
echo(compileFunction("x^(2*3)"));
fc = compileFunction("x^3*y-x*y^3",optimize=true);
echo(fc);
echo(eval(fc,[["x",1],["y",1]]));
z=[for(i=[0:9999]) compileFunction("x^3*y-x*y^3",optimize=false)];//fc,[ ["x",1],["y",2] ])];
*/

//z = [for(i=[1:10000]) compileFunction("x^3*y-x*y^3")];
// normal: 23

//function repeat(s, copies, soFar="") = copies <= 0 ? soFar : repeat(s, copies-1, soFar=str(soFar,s));

//END DEPENDENCY: use <eval.scad>;


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

module inflateMesh(pointsAndFaces=undef,points=undef,triangles=undef,top="d",bottom="0",params=[]) {
    data = inflateMesh(points=pointsAndFaces==undef?points:pointsAndFaces[0],triangles=pointsAndFaces==undef?triangles:pointsAndFaces[1],top=top,bottom=bottom,params=params);
    polyhedron(points=data[0],faces=data[1]);
}

//END DEPENDENCY: use <inflate.scad>;


heart = Bezier([[0,0],POLAR(10,60),POLAR(10,-90),[20,35],SYMMETRIC(),POLAR(15,90),[0,30],REPEAT_MIRRORED([1,0])]);

inflateMesh(refineMesh(heart,triangulate(heart),maxEdge=2),top="min(4,3*d^0.25)");
