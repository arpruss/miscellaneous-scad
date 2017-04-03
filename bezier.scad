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
function PointAlongBez4(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]];
// End public domain Bezier stuff

function SMOOTH_REL(x) = ["r",x];
function SMOOTH_ABS(x) = ["a",x];
function SYMMETRIC() = ["r",1];
function OFFSET(v) = ["o",v];
function SHARP() = OFFSET([0,0]);
function POLAR(r,angle) = OFFSET(r*[cos(angle),sin(angle)]);
function POINT_IS_SPECIAL(v) = (v[0]=="r" || v[0]=="a" || v[0]=="o");

function normalize2D(v) = v / sqrt(v[0]*v[0]+v[1]*v[1]);

// this does NOT handle offset type points; to handle those, use DecodeBezierOffsets()
function getControlPoint(cp,node,otherCP) = cp[0]=="r"?(node+cp[1]*(node-otherCP)):( cp[0]=="a"?node+cp[1]*normalize2D(node-otherCP):cp );

function Bezier2(p,index=0,precision=0.05,rightEndPoint=true) = let(nPoints=ceil(1/precision)) [for (i=[0:nPoints-(rightEndPoint?0:1)]) PointAlongBez4(p[index+0],p[index+1],p[index+2],p[index+3],i/nPoints)];
    
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
    p1 = DecodeSpecialBezierPoints(p);
    l = Bezier(p1,precision=precision,eps=eps);
    for (i=[0:len(l)-2]) {
        hull() {
            translate(l[i]) circle(d=lineThickness);
            translate(l[i+1]) circle(d=lineThickness);
        }
    }
    for (i=[0:len(p1)-1]) {
        if (i%3 == 0) {
            color("black") translate(p1[i]) circle(d=nodeSize);
        }
        else {
            node = i%3 == 1 ? i-1 : i+1;
            color("red") translate(p1[i]) circle(d=nodeSize);
            color("red") hull() {
                translate(p1[node]) circle(d=controlLineThickness);
                translate(p1[i]) circle(d=controlLineThickness);
            }
        }
    }
}

//<skip>
translate([0,-15]) BezierVisualize([[0,0],/*C*/[5,0],/*C*/SYMMETRIC(),[10,10],/*C*/[15,10],/*C*/OFFSET([-5,0]),[20,0]]);
linear_extrude(height=5) {
polygon(Bezier([[0,0],/*C*/[5,0],/*C*/SYMMETRIC(),[10,10],/*C*/[15,10],/*C*/OFFSET([-5,0]),[20,0]],precision=0.05));
translate([0,15])
polygon(Bezier([[0,0],/*C*/[5,0],/*C*/SMOOTH_REL(2),[10,10],/*C*/[15,10],/*C*/POLAR(5,180),[20,0]],precision=0.05));
translate([0,30])
polygon(Bezier([[0,0],/*C*/[5,0],/*C*/SMOOTH_ABS(1.5),[10,10],/*C*/[15,10],/*C*/OFFSET([-5,0]),[20,0]],precision=0.05));
translate([0,45])
polygon(Bezier([[0,0],/*C*/[5,0],/*C*/SMOOTH_REL(-1),[10,10],/*C*/[15,10],/*C*/OFFSET([-5,0]),[20,0]],precision=0.05));
translate([0,60])
polygon(Bezier([[0,0],/*C*/[5,0],/*C*/SMOOTH_ABS(-1),[10,10],/*C*/[15,10],/*C*/OFFSET([-5,0]),[20,0]],precision=0.05));
translate([0,75])
polygon(Bezier([[0,0],/*C*/SHARP(),/*C*/SHARP(),[10,10],/*C*/SHARP(),/*C*/OFFSET([-5,0]),[20,0]],precision=0.05));
}
//</skip>
