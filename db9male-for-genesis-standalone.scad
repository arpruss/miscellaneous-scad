pins = 9;
stripsTolerance = 0.25;
socketWall = 1.5;
socketDepth = 7;
mountThickness = 1.75;
// the jack is the female part that fits inside the socket
jackHeight = 8.3;
jackWidthIncrementBeyondNominalPinSpacing = 3.12;
// official value for db9 is 10.7, but that's not so good for our thicker plastic wall
mountHeight = 12.5;
// official value for db9 is 3.04, but I like 3.75
mountEdgeDistanceBeyondScrews = 3.75;
// official distance for db9 is 4.04, but I like 5.3
screwDistanceFromJack = 5.3;
socketScrewHole = 3.05;

slantAngle = 10;
offset = 1.34;
rounding = 0.75;
stripsHeight = 2.51;
// this is what it should be
nominalPinSpacing = 2.76;
// this is what it is if you use 0.1" header
headerPinSpacing = 2.54;
stripsSpacerDepth = 2.77;
// this might be useful to put down an extra layer of plastic at the bottom to help the header pins stick in place
stripsExtraDepth = 0;
pinHoleDiameter = 0.4;

module end_of_parameters_dummy() {}


//BEGIN: use <bezier.scad>;
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


//END: use <bezier.scad>;


//BEGIN: use <roundedSquare.scad>;
module roundedSquare(size=[10,10], radius=1, center=false, $fn=16) {
    size1 = (size+0==size) ? [size,size] : size;
    if (radius <= 0) {
        square(size1, center=center);
    }
    else {
        translate(center ? -size1/2 : [0,0])
        hull() {
            translate([radius,radius]) circle(r=radius);
            translate([size1[0]-radius,radius]) circle(r=radius);
            translate([size1[0]-radius,size1[1]-radius]) circle(r=radius);
            translate([radius,size1[1]-radius]) circle(r=radius);
        }
    }
}

module roundedCube(size=[10,10,10], radius=1, center=false, $fn=16) {
    linear_extrude(height=size[2])
    roundedSquare(size=[size[0],size[1]], radius=radius, center=center);
}

module roundedOpenTopBox(size=[10,10,10], radius=2, wall=1, solid=false) {
    render(convexity=2)
    difference() {
        linear_extrude(height=size[2]) roundedSquare(size=[size[0],size[1]], radius=radius);
        if (!solid) {
            translate([0,0,wall])
            linear_extrude(height=size[2]-wall)
            translate([wall,wall]) roundedSquare(size=[size[0]-2*wall,size[1]-2*wall], radius=radius-wall);
        }
    }
}

//END: use <roundedSquare.scad>;



module dummy(){}

stripsDepth = stripsSpacerDepth + stripsExtraDepth;
pinsInRow2 = pins%2 ? (pins+1)/2 : pins/2;
pinsInRow1 = pins%2 ? (pins-1)/2 : pins/2;
jackWidth = pinsInRow2*nominalPinSpacing+jackWidthIncrementBeyondNominalPinSpacing;

pinSpacing = headerPinSpacing;
screwSpacing = jackWidth+ 2 * screwDistanceFromJack;

mountWidth = screwSpacing + 2*mountEdgeDistanceBeyondScrews;
height = jackHeight;
width2 = jackWidth;
width1 = width2-tan(slantAngle)*(height-2*offset);

stripsWidth2 = pinSpacing * pinsInRow2;
stripsWidth1 = pinSpacing * pinsInRow1;
nudge = 0.01;

function roundedTrapezoidPath(width1,width2,height) =
    let(path = [ [0,0], LINE(), LINE(),
         [width1/2-offset,0], SMOOTH_ABS(offset*rounding), SMOOTH_ABS(offset*rounding),
         [width1/2,offset], LINE(), LINE(),
         [width2/2,height-offset], SMOOTH_ABS(offset*rounding), SMOOTH_ABS(offset*rounding),
         [width2/2-offset,height], LINE(), LINE(), [0,height], REPEAT_MIRRORED([10,0])])
    Bezier(path);

module roundedTrapezoid(width1,width2,height) {
    translate([0,-height/2])
    polygon(roundedTrapezoidPath(width1,width2,height));
}

module innerInside() {
    w1 = stripsWidth1+2*stripsTolerance;
    w2 = stripsWidth2+2*stripsTolerance;
    h = stripsHeight+stripsTolerance;
    translate([-w1/2,-h]) roundedSquare([w1,h+nudge+0.5],radius=0.5);
    translate([-w2/2,0]) roundedSquare([w2,h+nudge],radius=0.5);
}

module outerSocket() {
    offset(r=socketWall) roundedTrapezoid(width1,width2,height);
}

function outerSocketHeight() =
    let(path=roundedTrapezoidPath(width1,width2,height))
    2*socketWall + max([for(p=path) p[1]])-min([for(p=path) p[1]]);

linear_extrude(height=mountThickness)
difference() {
    roundedSquare([mountWidth,mountHeight],center=true,radius=1);
    innerInside();
    for (i=[-1,1]) translate([i*(screwSpacing/2),0]) circle($fn=16,d=socketScrewHole);
}

function getMountHeight() = mountHeight;

linear_extrude(height=stripsDepth)
difference() {
    outerSocket();
    innerInside();
}

linear_extrude(height=stripsDepth+socketDepth)
difference() {
    outerSocket();
    roundedTrapezoid(width1,width2,height);
}

if (stripsExtraDepth>0)
    linear_extrude(height=stripsExtraDepth) difference() {
        outerSocket();
        for (i=[0,1]) {
            pins = [pinsInRow1,pinsInRow2][i];
            translate([-pins/2*headerPinSpacing+0.5*headerPinSpacing,stripsHeight*(i-0.5)]) {
                for(j=[0:pins-1]) {
                    translate([headerPinSpacing*j,0]) circle(d=pinHoleDiameter,$fn=18);
                }
            }
        }
    }
