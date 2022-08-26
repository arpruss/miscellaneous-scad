includeHeadband = 1; // [0:no, 1:yes]
stalkCount = 2;

headbandWidth = 123;
headbandHeightRatio = 1.1;
headbandStripWidth = 10;
headbandStripThickness = 2.5;
toothedRatio = .7;
toothSpacing = 3;
toothThickness = 1;
toothLength = 1;
toothWidthRatio = 0.5;
headbandBottomFlare = 1; // [0:no, 1:yes]

stalkHolderPosition = 0.25;
stalkThickness = 5;
stalkHolderBackingThickness = 1;
stalkHolderSize = 30;
stalkWidth = 4;
stalkSocketDiameter = 6;
stalkTolerance = 0.5;
stalkAngle = 75;

stalkBallDiameter = 20;
stalkLength = 126;
stalkBallFlat = 1; // [0:no, 1:yes]

spacing = 5; /* spacing between parts */

module dummy() {}

module end_of_parameters_dummy() {}

//use <bezier.scad>;
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
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);
function PointAlongBez4(p0, p1, p2, p3, u) = [for (i=[0:len(p0)-1])
	BEZ03(u)*p0[i]+BEZ13(u)*p1[i]+BEZ23(u)*p2[i]+BEZ33(u)*p3[i]];
// End public domain Bezier stuff

function SMOOTH_REL(x) = ["r",x];
function SMOOTH_ABS(x) = ["a",x];
function SYMMETRIC() = ["r",1];
function OFFSET(v) = ["o",v];
function SHARP() = OFFSET([0,0,0]);
function POLAR(r,angle) = OFFSET(r*[cos(angle),sin(angle)]);
function POINT_IS_SPECIAL(v) = (v[0]=="r" || v[0]=="a" || v[0]=="o");

// this does NOT handle offset type points; to handle those, use DecodeBezierOffsets()
function getControlPoint(cp,node,otherCP) = cp[0]=="r"?(node+cp[1]*(node-otherCP)):( cp[0]=="a"?node+cp[1]*(node-otherCP)/norm(node-otherCP):cp );

function onLine2(a,b,c,eps=1e-4) =
    norm(c-a) <= eps ? true
        : norm(b-a) <= eps ? false /* to be safe */
            : abs((c[1]-a[1])*(b[0]-a[0]) - (b[1]-a[1])*(c[0]-a[0])) <= eps * eps && norm(c-a) <= eps + norm(b-a);

function isStraight2(p1,c1,c2,p2,eps=1e-4) =
    len(p1) == 2 &&
    onLine2(p1,p2,c1,eps=eps) && onLine2(p2,p1,c2,eps=eps);

function Bezier2(p,index=0,precision=0.05,rightEndPoint=true) = let(nPoints=ceil(1/precision))
    isStraight2(p[index],p[index+1],p[index+2],p[index+3]) ? (rightEndPoint?[p[index+0],p[index+3]]:[p[index+0]] ) :
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
//   SHARP(): equivalent to OFFSET([0,0]); useful for straight lines
//   POLAR(r,angle): like OFFSET, except the offset is specified in polar coordinates

function DecodeBezierOffset(control,node) = control[0] == "o" ? node+control[1] : control;

// replace all OFFSET/SHARP/POLAR points with coordinates
function DecodeBezierOffsets(p) = [for (i=[0:len(p)-1]) i%3==0?p[i]:(i%3==1?DecodeBezierOffset(p[i],p[i-1]):DecodeBezierOffset(p[i],p[i+1]))];

function DecodeSpecialBezierPoints(p0) = let(p=DecodeBezierOffsets(p0)) [for (i=[0:len(p)-1]) i%3==0?p[i]:(i%3==1?getControlPoint(p[i],p[i-1],p[i-2]):getControlPoint(p[i],p[i+1],p[i+2]))];

function Distance2D(a,b) = sqrt((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));

function RemoveDuplicates(p,eps=0.00001) = let(safeEps = eps/len(p)) [for (i=[0:len(p)-1]) if(i==0 || i==len(p)-1 || Distance2D(p[i-1],p[i]) >= safeEps) p[i]];

function Bezier(p,precision=0.05,eps=0.00001) = let(q=DecodeSpecialBezierPoints(p), nodes=(len(p)-1)/3) RemoveDuplicates(flatten([for (i=[0:nodes-1]) Bezier2(q,index=i*3,precision=precision,rightEndPoint=(i==nodes-1))]),eps=eps);

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

//use <paths.scad>;
function sumTo(v,n) = n<=0 ? 0 : v[n-1]+sumTo(v,n-1);
function sum(v) = sumTo(v,len(v));
function interpolationData(v) = let(
    n=len(v)-1,
    d=[for (i=[0:n-1]) norm(v[i]-v[i+1])],
    sumD=[for (i=[0:n]) sumTo(d,i)],
    totalD=sumD[n])
        [d,sumD,v,totalD];
function totalLength(interp) = interp[3];
function interpolatePoints(a,b,t) = (1-t)*a+(t)*b;
function findSegmentByDistance(sumD,distance) = let(
    found = [for(i=[0:len(sumD)-1]) if(sumD[i]<=distance && distance<sumD[i+1]) i])
        len(found)>0 ? found[0] : -1;
function interpolateByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i=findSegmentByDistance(sumD,distance))
        i<0 ? (distance<totalD/2 ? v[0] : v[n]) :
            interpolatePoints(v[i],v[i+1],(distance-sumD[i])/d[i]);
function get2DNormalBetweenPoints(a,b) = let(
    v = (b-a)/norm(b-a))
        [v[1],-v[0]];
function getTangentByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i0=findSegmentByDistance(sumD,distance),
    i = i0 < 0 ? (distance<totalD/2 ? 0 : n-1) : i0)
        (v[i+1]-v[i])/norm(v[i+1]-v[i]);

function interpolateByParameter(interp,t) = interpolateByDistance(interp,t*totalLength(interp));
function singleInterpolateByDistance(v,distance) = interpolateByDistance(interpolationData(v),distance);
function singleInterpolateByParameter(v,t) = interpolateByParameter(interpolationData(v),t);
function measurePath(v) = totalLength(interpolationData(v));

function mirrorMatrix(normalVector) = let(v = normalVector/norm(normalVector)) len(v)<3 ? [[1-2*v[0]*v[0],-2*v[0]*v[1]],[-2*v[0]*v[1],1-2*v[1]*v[1]]] : [[1-2*v[0]*v[0],-2*v[0]*v[1],-2*v[0]*v[2]],[-2*v[0]*v[1],1-2*v[1]*v[1],-2*v[1]*v[2]],[-2*v[0]*v[2],-2*v[1]*v[2],1-2*v[2]*v[2]]];

function trimArray(a, n) = [for (i=[0:n-1]) a[i]];

function transformPoint(matrix,a) =
    let(n=len(a))
        len(matrix[0])==n+1 ?
            trimArray(matrix * concat(a,[1]), n)
            : matrix * a;

function transformPath(matrix,path) =
    [for (a=path) transformPoint(matrix,a)];

function reverseArray(array) = let(n=len(array)) [for (i=[0:n-1]) array[n-1-i]];

function stitchPaths(a,b) = let(na=len(a)) [for (i=[0:na+len(b)-2]) i<na? a[i] : b[i-na+1]-b[0]+a[na-1]];

//interp = interpolationData([[1,2],[2,3],[1,2]]);
//echo(singleInterpolateByParameter([[1,1],[2,2],[3,1]],0.75));
//echo(measurePath([[1,2],[2,3],[1,2]]));


nudge = 0.01;

headbandHeight = headbandWidth * headbandHeightRatio;

pointsRight = Bezier([
[0,headbandHeight], /*C*/POLAR(headbandWidth/4,0), /*C*/POLAR(headbandWidth/4,90), [headbandWidth/2,headbandHeight/2],
/*C*/SYMMETRIC(), /*C*/POLAR(headbandWidth/(headbandBottomFlare?6:4),headbandBottomFlare?90:60),[headbandWidth/4,0]]);

interp = interpolationData(pointsRight);
length = totalLength(interp);

module rightSide() {
    segmentLength = headbandStripWidth/3;
    segments = floor(length / segmentLength);

    for(i=[0:segments-1]) {
        adjust = i < segments-1 ? 0 : (1/(2+sqrt(2)))* headbandStripWidth;
        a = interpolateByDistance(interp, i*segmentLength);
        b = interpolateByDistance(interp, (i+1)*segmentLength);
        hull() {
            translate(a) cylinder(d=headbandStripThickness,h=headbandStripWidth,$fn=16);
            translate([b[0],b[1],adjust]) cylinder(d=headbandStripThickness,h=headbandStripWidth-2*adjust,$fn=16);
        }
    }

    if (toothedRatio>0) {
        teeth = floor(length * toothedRatio / toothSpacing);
        for(i=[0:teeth-1]) {
            d = i * toothSpacing;
            tangent = getTangentByDistance(interp, d);
            normal = [tangent[1],-tangent[0]];
            a = interpolateByDistance(interp, d);
            hull() {
                translate(a) cylinder(h=toothWidthRatio*headbandStripWidth,d=toothThickness);
                translate(a+(toothLength+headbandStripThickness*0.5)*normal) cylinder(h=toothWidthRatio*headbandStripWidth,d=toothThickness);
            }
        }
    }

    if (stalkHolderSize>0) {
        stalkHolderStart = stalkHolderPosition * length - stalkHolderSize / 2;
        stalkHolderEnd = stalkHolderPosition * length + stalkHolderSize / 2;
        stalkHolderPoints0 = [for (d=[stalkHolderStart:1:stalkHolderEnd]) interpolateByDistance(interp,d)];
        a = interpolateByDistance(interp,stalkHolderStart);
        b = interpolateByDistance(interp,stalkHolderEnd);
        stalkHolderAngle = atan2(b[1]-a[1],b[0]-a[0]);
        c = (a+b)/2;
        r = norm(c-a);
        stalkHolderPoints1 = [for (angle=[0:10:180]) c+r*[cos(angle+stalkHolderAngle),sin(angle+stalkHolderAngle)]];
        stalkHolderPoints = concat(stalkHolderPoints0,stalkHolderPoints1);
        stalkHolderCenterPoint = interpolateByDistance(interp,(stalkHolderStart+stalkHolderEnd)/2);
        stalkHolderTangent = getTangentByDistance(interp,(stalkHolderStart+stalkHolderEnd)/2);
        stalkHolderNormal = [-stalkHolderTangent[1],stalkHolderTangent[0]];
        socketCenter = stalkHolderCenterPoint+(stalkTolerance+stalkSocketDiameter/2+headbandStripThickness/2)*stalkHolderNormal;
        linear_extrude(height=stalkThickness+stalkHolderBackingThickness)
        difference() {
            polygon(stalkHolderPoints);
            translate(socketCenter) circle(r=stalkTolerance+stalkSocketDiameter/2);
            translate(socketCenter) rotate([0,0,stalkAngle])    translate([0,-(stalkWidth/2+stalkTolerance)]) square([r,stalkWidth+stalkTolerance*2]);
        }
        linear_extrude(height=stalkHolderBackingThickness)
            polygon(stalkHolderPoints);
    }
}

module headband() {
    rightSide();
    mirror([1,0,0]) rightSide();
}

module stalk() {
    translate([-stalkWidth/2,0,0]) cube([stalkWidth,stalkLength,stalkThickness]);
    linear_extrude(height=stalkThickness)
    circle(d=stalkSocketDiameter);
    render(convexity=2)
    translate([0,stalkLength,0])
    if (stalkBallFlat) {
        linear_extrude(height=stalkThickness) circle(d=stalkBallDiameter);
    }
    else {
        intersection() {
            union() {
                translate([0,0,stalkThickness/2]) sphere(d=stalkBallDiameter);
                translate([0,stalkBallDiameter+spacing,-stalkThickness/2]) sphere(d=stalkBallDiameter);
            }
            translate([-stalkBallDiameter/2,-stalkBallDiameter/2,0]) cube([stalkBallDiameter,stalkBallDiameter*2+spacing,stalkBallDiameter]);
        }
    }
}

if (includeHeadband)
    headband();

x0 = includeHeadband ? headbandWidth/2 + stalkHolderSize/2 + spacing : 0;

if (stalkCount>0)
    for (i=[0:stalkCount-1])
        translate([x0+i*(stalkBallDiameter+spacing),0,0])
            stalk();
