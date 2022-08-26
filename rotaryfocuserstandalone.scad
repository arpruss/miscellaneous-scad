includeDrawTube = 1; //[1:yes, 0:no]
includeOuterTube = 1; //[1:yes, 0:no]
includeTubeAdapter = 1; //[1:yes, 0:no]
includeThread = 1; //[1:yes, 0:no]
crossSection = 0; //[1:yes, 0:no]
nominalDrawTubeDiameter = 31.75;
eyepieceTolerance = 0.75;
drawTubeLength = 60;
outerTubeLength = 20;
drawTubeWall = 2.5;
outerTubeWall = 2.5;
threadTolerance = 0.75;
threadPitch = 4;
threadAngle = 40;
collarHeight = 5;
collarWall = 1;
knurlSize = 2.5;
setScrewDiameter = 2.3;
flangeSize = 15;
flangeScrewHeadSize = 5;
flangeScrewDiameter = 3;
flangeOuterThickness = 2;
flangeHeight = 6;
screwDiameter = 3.5;
screwHeadDiameter = 8;
screwCountersink = 1;
screwCount = 3;
telescopeTubeDiameter = 150; // only needed if printing tube adapter

module end_of_parameters_dummy() {}

//use <threads.scad>;
//use <quickthread.scad>;
function _ringPoints(param) = len(param[0]);
function _ringValue(param,point) = param[0][point];
function _numTurns(param) = param[2];
function _numRings(param) = 1+_numTurns(param)*$fn;
function _radius(param) = param[1];
function _lead(param) = param[3];

extrNudge = 0.001;

function extrPoints(param) =
    let (n=_ringPoints(param),
        r=_radius(param),
        m=_numRings(param),
        l=_lead(param)
        )
        [ for (i=[0:m-1]) for (j=[0:n-1])
            let (z=i/$fn*l,
                angle=(i%$fn)/$fn*360,
                v=_ringValue(param,j))
            [ (r+v[0])*cos(angle), (r+v[0])*sin(angle),z+v[1]] ];

function mod(m,n) = let(mm = m%n) mm<0 ? n+mm : mm;

function extrPointIndex(param,ring,point) =
    let (n=_ringPoints(param))
        n*ring + mod(point,n);

function startFacePoints(param) =
    let (n=_ringPoints(param))
        [for (i=[0:n-1]) extrPointIndex(param,0,i)];

function endFacePoints(param) =
    let (m=_numRings(param), n=_ringPoints(param))
            [for (i=[n-1:-1:0]) extrPointIndex(param,m-1,i)];

function tubeFaces(param) =
    let (m=_numRings(param), n=_ringPoints(param))
            [for (i=[0:m-2]) for (j=[0:n-1]) for(tri=[0:1])
                tri==0 ?
                    [extrPointIndex(param,i,j),extrPointIndex(param,i+1,j),extrPointIndex(param,i,j+1)] :
                    [extrPointIndex(param,i,j+1), extrPointIndex(param,i+1,j),
            extrPointIndex(param,i+1,j+1)]];


function extrFaces(param) = concat([startFacePoints(param)],concat(tubeFaces(param),[endFacePoints(param)]));


module rawThread(profile, d=undef, h=10, lead=undef, $fn=72, adjustRadius=false, clip=true, includeCylinder=true) {
    radius = d/2;
    vSize = max([for(v1=profile) for(v2=profile) v2[1]-v1[1]]);
    vMin = min([for(v=profile) v[0]]);
    radiusAdjustment = adjustRadius ? vMin : 0;
    _lead = lead==undef ? vSize : lead;
    profileScale = vSize <= _lead-extrNudge ? 1 : (_lead-extrNudge)/vSize;
    adjProfile = [for(v=profile) [v[0]-radiusAdjustment,v[1]*profileScale]];
    adjRadius = radius + radiusAdjustment;
    hSize = 1+2*adjRadius + 2*max([for (v=adjProfile) v[0]]);
    numTurns = 2+ceil(h/_lead);
    param = [adjProfile, adjRadius, numTurns, _lead];
    render(convexity=10)
    union() {
        intersection() {
            if (clip)
                translate([-hSize/2,-hSize/2,0]) cube([hSize,hSize,h]);
            translate([0,0,-_lead]) polyhedron(faces=extrFaces(param),points=extrPoints(param));
        }
        if (includeCylinder)
            cylinder(r=adjRadius+extrNudge,$fn=$fn,h=h);
    }
}

function inch_to_mm(x) = x * 25.4;

// internal = female
module isoThread(d=undef, dInch=undef, pitch=1, tpi=undef, h=1, hInch=undef, lead=undef, leadInch=undef, angle=30, internal=false, $fn=72) {

    P = (tpi==undef) ? pitch : tpi;

    radius = dInch != undef ? inch_to_mm(dInch)/2 : d/2;
    height = hInch != undef ? inch_to_mm(hInch) : h;

    Dmaj = 2*radius;
    H = P * cos(angle);

    _lead = leadInch != undef ? inch_to_mm(leadInch) : lead != undef ? lead : P;

    externalExtra=0.03;
    internalExtra=0.057;
    profile = !internal ?
        [ [-H*externalExtra,(-3/8-externalExtra)*P],
          [(5/8)*H,-P/16],[(5/8)*H,P/16],
          [-H*externalExtra,(3/8+externalExtra)*pitch] ] :
        [ [0,-(3/8)*P],
        [(5/8)*H,-P/16],[(5/8+internalExtra)*H,0],
        [(5/8)*H,P/16],[0,(3/8)*P] ];
    Dmin = Dmaj-2*H/4;
    myFN=$fn;
    rawThread(profile,d=Dmin,h=height,lead=_lead,$fn=myFN,adjustRadius=true);
}

//rawThread([[0,0],[1.5,1.5],[0,3]], d=50, h=91, pitch=3);
//rawThread([[0,0],[0,3],[3,3],[3,0]], d=50, h=50, pitch=6, $fn=80);
difference() {
    isoThread(d=50,h=30,pitch=3,angle=40,internal=false,$fn=60);
    translate([0,0,-extrNudge]) isoThread(d=42,h=30+2*extrNudge,pitch=3,angle=40,internal=true,$fn=60);
}
//rawThread([[0,0],[1,0],[.5,.5],[1,1],[0,1]],r=20,h=10,lead=1.5);
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

function findCoordinateIntersection2(a,b,index,value) =
    a[index] == value ? a :
        b[index] == value ? b :
            let( t=(value-a[index]) / (b[index]-a[index]))
                (1-t)*a+t*b;

function findCoordinateIntersections(path,index,value) =
    [for (i=[0:len(path)-2]) if ((path[i][index]-value)*(path[i+1][index]-value) <= 0) findCoordinateIntersection2(path[i],path[i+1],index,value)];

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



module dummy() {}

nudge = 0.001;
drawTubeID = nominalDrawTubeDiameter + eyepieceTolerance;
drawTubeOD = drawTubeID + drawTubeWall * 2;
outerTubeID = drawTubeOD + 2*threadTolerance;
outerTubeOD = outerTubeID + outerTubeWall * 2;

module knurledCircle(d=10, knurlSize=knurlSize) {
    circumference = d * 3.141592653;
    n = ceil(circumference/knurlSize);
    for (i=[0:n-1]) {
        rotate(360/n*i) translate([d/2,0]) circle(d=circumference/n, $fn=12);
    }
    rotate(180/n) circle(d=d, $fn=n);
}

profile = [ [0,flangeHeight], OFFSET([0,-flangeHeight/2]),
        OFFSET([-flangeSize/2,0]), [flangeSize, flangeOuterThickness], SHARP(), SHARP(), [flangeSize,0], SHARP(), SHARP(), [0,0] ];
profilePath = Bezier(profile);
screwR = outerTubeOD/2 - nudge + flangeSize/2;
screwZ = findCoordinateIntersections(profilePath,0,flangeSize/2+screwHeadDiameter/2)[0][1];

module screws(countersink=true) {
    for (i=[0:screwCount-1]) {
        rotate([0,0,360*i/screwCount]) {
            translate([screwR,0,0]) {
                cylinder(h=max(flangeHeight,telescopeTubeDiameter),d=screwDiameter,$fn=12);
                if(countersink) translate([0,0,screwZ-screwCountersink]) cylinder(h=flangeHeight,d=screwHeadDiameter,$fn=12);
            }
        }
    }
}

module flange() {
    difference() {
        rotate_extrude() translate([outerTubeOD/2-nudge,0,0]) polygon(profilePath);
        screws(countersink=true);
    }
}

module drawTube(upright=false) {
    render(convexity=2)
    difference() {
        union() {
            if (includeThread)
                //metric_thread(drawTubeOD, threadPitch=threadPitch, length=drawTubeLength);
                isoThread(d=drawTubeOD,pitch=threadPitch,h=drawTubeLength,angle=threadAngle);
            else
                cylinder(d=drawTubeOD,h=drawTubeLength);
            translate([0,0, upright?drawTubeLength-collarHeight:0]) linear_extrude(height=collarHeight) knurledCircle(d=drawTubeOD+collarWall*2);
        }
        translate([0,0,-nudge]) cylinder(d=drawTubeID, h=drawTubeLength+2*nudge);
        translate([0,0,upright?drawTubeLength-collarHeight/2 : collarHeight/2])
        rotate([0,-90,0]) cylinder(d=setScrewDiameter,h=drawTubeOD+2*knurlSize, $fn=16);
    }
}

module outerTube() {
    render(convexity=2)
    difference() {
        cylinder(d=outerTubeOD, h=outerTubeLength);
        translate([0,0,-nudge]) if (includeThread)
//metric_thread(outerTubeID, threadPitch=threadPitch, length=outerTubeLength+2*nudge,internal=true);
        isoThread(d=outerTubeID, pitch=threadPitch, h=outerTubeLength+2*nudge,internal=true, angle=threadAngle);
            else cylinder(d=outerTubeID, h=outerTubeLength+2*nudge);
    }
    flange();
}

module tubeAdapter() {
    d = outerTubeOD+2*flangeSize-2*nudge;
    render(convexity=2)
    difference() {
        cylinder(d=d, h=telescopeTubeDiameter/2, $fn=72);
        translate([0,0,telescopeTubeDiameter/2+2]) rotate([0,90,0]) translate([0,0,-d]) cylinder(d=telescopeTubeDiameter, h=2*d, $fn=120);
        screws(countersink=false);
        cylinder(d=outerTubeID+threadPitch*(.25+cos(threadAngle)), h=telescopeTubeDiameter/2);
    }
}

module cut() {
    render(convexity=2)
    difference() {
        rotate([0,0,90]) children();
        translate([-outerTubeOD,0,-100]) cube([outerTubeOD*2,outerTubeOD*2,outerTubeLength+drawTubeLength+100]);
    }
}

if (crossSection) {
    color("red") cut() translate([0,0,-2*threadPitch])drawTube(upright=true);
    color("blue") cut() outerTube();
    color("green") cut() rotate([180,0,0]) tubeAdapter();
}
else {
    if (includeDrawTube) {
        drawTube();
    }

    if (includeOuterTube) {
        translate([outerTubeID+20+flangeSize,0,0]) outerTube();
    }

    if (includeTubeAdapter) {
        translate(-[outerTubeID+20+flangeSize,0,0]) tubeAdapter();
    }
}
