numberOfDrawerCompartmentsHorizontally = 5;
numberOfDrawerCompartmentsInDepth = 2;

// You can subdivide the drawer into two types of compartments by setting the right side width ratio to something bigger than zero.
rightSideWidthRatio = 0;
rightSideNumberOfDrawerCompartmentsHorizontally = 3;
rightSideNumberOfDrawerCompartmentsInDepth = 2;

numberOfDrawersInChest = 7;

generate = 1; // [0:chest, 1:drawer]

// Thickness
outerWall = 0.75;
// Thickness of main drawer walls and dividers running forward and back
drawerWall=0.45;
// Thickness of divider walls running horizontally
dividerWall=0.45;
drawerWidth = 136;
drawerDepth = 70;
drawerHeight = 16;
roundedCornerRadius=3.5;

tolerance=0.75;

// Divider walls between full-depth compartments can have a cut in them to make it easier to put things in and take them out. Set cut height to zero to disable.
cutHeight = 13.5;
cutLengthAtTop = 16;
cutLengthAtBottom = 8;
cutSmoothingSize = 5;

handleSize = 20;
handleLip = 3;
// Set to zero to have a handle with no floor.
handleFloorThickness = 0;

slideWidth = 6;
slideThickness = 1;

// Three of the walls are made in a grid pattern to save plastic. If you want them solid, set the grid hole width to zero.
gridHoleWidth = 9;
gridStripWidth = 3;
gridAngle = 60;

numberOfRearCrossbars = 2; // [0:0, 1:1, 2:2]


module end_of_parameters_dummy() {}

//use <Bezier.scad>;
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

function REPEAT_MIRRORED(v) = ["m",v];
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

function DecodeSpecialBezierPoints(p0) =
    let(
        l = _correctLength(p0),
        doMirror = len(p0)>l && p0[l][0] == "m",
        p=DecodeBezierOffsets(p0),
        basePath = [for (i=[0:l-1]) i%3==0?p[i]:(i%3==1?getControlPoint(p[i],p[i-1],p[i-2]):getControlPoint(p[i],p[i+1],p[i+2]))])
        doMirror ? _mirrorPaths(basePath, p0, l) : basePath;

function Distance2D(a,b) = sqrt((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));

function RemoveDuplicates(p,eps=0.00001) = let(safeEps = eps/len(p)) [for (i=[0:len(p)-1]) if(i==0 || i==len(p)-1 || Distance2D(p[i-1],p[i]) >= safeEps) p[i]];

function Bezier(p,precision=0.05,eps=0.00001) = let(q=DecodeSpecialBezierPoints(p), nodes=(len(q)-1)/3) RemoveDuplicates(flatten([for (i=[0:nodes-1]) Bezier2(q,index=i*3,precision=precision,rightEndPoint=(i==nodes-1))]),eps=eps);

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



module dummy() {}
nudge = 0.01;

module compartment(width, drawerDepth, drawerHeight,drawerWall=drawerWall) {
    render(convexity=2)
    difference() {
        cube([width,drawerDepth,drawerHeight]);
        hull() {
            translate([drawerWall,drawerWall,roundedCornerRadius+drawerWall]) cube([width-2*drawerWall,drawerDepth-2*drawerWall,drawerHeight]);
            translate([0,drawerWall,roundedCornerRadius+drawerWall])
                rotate([-90,0,0]) {
                translate([drawerWall+roundedCornerRadius,0,0]) cylinder(h=drawerDepth-2*drawerWall,r=roundedCornerRadius,$fn=24);
                translate([width-drawerWall-roundedCornerRadius,0,0]) cylinder(h=drawerDepth-2*drawerWall,r=roundedCornerRadius,$fn=24);
                }
            }
    }
}

module drawerHull(drawerWidth,inset=0,drawerHeight=drawerHeight,roundOnLeft=true,roundOnRight=true) {

    module post(roundPost) {
       if (roundPost)
           cylinder(h=drawerHeight+nudge,r=roundedCornerRadius,$fn=24);
       else
           translate([-roundedCornerRadius,-roundedCornerRadius,0]) cube([roundedCornerRadius*2,roundedCornerRadius*2,drawerHeight+nudge]);
    }

        hull() {
            translate([inset+roundedCornerRadius,drawerDepth-roundedCornerRadius-inset])
            post(roundOnLeft);
    translate([drawerWidth-roundedCornerRadius-inset,drawerDepth-roundedCornerRadius-inset]) post(roundOnRight);
    translate([inset,inset,0]) cube([roundedCornerRadius,roundedCornerRadius,drawerHeight]);
    translate([drawerWidth-inset-roundedCornerRadius,inset,0]) cube([roundedCornerRadius,roundedCornerRadius,drawerHeight]);
        }
}

module baseDrawer(numberOfDrawerCompartmentsHorizontally, drawerWidth, roundOnLeft=true, roundOnRight=true, drawerWall=drawerWall) {
    compartmentWidth = (drawerWidth-drawerWall)/numberOfDrawerCompartmentsHorizontally+drawerWall;

    intersection() {
        union() {
            for (i=[0:numberOfDrawerCompartmentsHorizontally-1]) {
                translate([(compartmentWidth-drawerWall)*i,0,0])
                compartment(compartmentWidth,drawerDepth,drawerHeight, drawerWall=drawerWall);
            }
        }
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight);
    }
    render(convexity=2)
    difference() {
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight);
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight,inset=drawerWall,drawerHeight=drawerHeight+nudge);
    }
}

module cut() {
 //polygon([[-cutHeight,-cutLengthAtTop/2],[0,-cutLengthAtBottom/2],[0,cutLengthAtBottom/2],[-cutHeight,cutLengthAtTop/2]]);
    polygon(Bezier([ [-cutHeight,-cutLengthAtTop/2-cutSmoothingSize],OFFSET([0,cutSmoothingSize]), OFFSET([0,-cutSmoothingSize]),
    [nudge,-cutLengthAtBottom/2],
    OFFSET([0,0]),
    OFFSET([0,0]),
    [nudge,0], REPEAT_MIRRORED([0,1])
    ]));

}

module handle() {
    render(convexity=2)
    translate([drawerWidth/2,0,0])
    difference() {
        cylinder(d=handleSize,h=handleFloorThickness+handleLip);
        translate([0,0,handleFloorThickness-nudge]) cylinder(d=handleSize-handleLip*2,h=handleLip+2*nudge);
        translate([-handleSize/2,0,0]) cube([handleSize,handleSize,handleSize]);
    }
}

module drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, drawerWidth, roundOnLeft=true, roundOnRight=true, drawerWall=drawerWall) {

    compartmentWidth = (drawerWidth-drawerWall)/numberOfDrawerCompartmentsHorizontally+drawerWall;

    render(convexity=4)
    difference() {
        baseDrawer(numberOfDrawerCompartmentsHorizontally, drawerWidth, roundOnLeft=roundOnLeft, roundOnRight=roundOnRight, drawerWall=drawerWall);
        if (numberOfDrawerCompartmentsInDepth == 1)
        translate([compartmentWidth/2,drawerDepth/2,drawerHeight-cutHeight+nudge])
        rotate([0,90,0]) linear_extrude(height=drawerWidth-compartmentWidth) cut();
    }
    if (numberOfDrawerCompartmentsInDepth > 1) {
        for (i=[0:numberOfDrawerCompartmentsInDepth-2]) {
            translate([0,drawerWall+(drawerDepth-2*drawerWall)/numberOfDrawerCompartmentsInDepth*(1+i)-dividerWall/2,0])
            cube([drawerWidth,dividerWall,drawerHeight]);
        }
    }
}

chestWidth = drawerWidth+2*outerWall+2*tolerance;
drawerSpacing = drawerHeight+2*tolerance+slideThickness;
chestHeight = drawerSpacing*numberOfDrawersInChest+2*outerWall;
chestDepth = drawerDepth+tolerance+outerWall;

module strips(width,drawerDepth) {
    n = floor(1+width/(gridStripWidth+gridHoleWidth));
    for (i=[0:n]) {
        translate([i*(gridStripWidth+gridHoleWidth),0,0]) square([gridStripWidth,drawerDepth]);
    }
}

module gridFace(width,drawerDepth) {
    stripLength = 1.5*(width+drawerDepth);
    intersection() {
        union() {
            rotate(-gridAngle/2) translate([-stripLength/2,-stripLength/2])
            strips(stripLength,stripLength);
            rotate(gridAngle/2) translate([-stripLength/2,-stripLength/2])
            strips(stripLength,stripLength);
        }
        square([width,drawerDepth]);
    }
    difference() {
        square([width,drawerDepth]);
        translate([gridStripWidth,gridStripWidth])
        square([width-gridStripWidth*2,drawerDepth-gridStripWidth*2]);
    }
}

module drawerSupport(bottom,top) {
    cube([slideWidth,chestDepth,slideThickness]);
    translate([chestWidth-slideWidth,0,0]) cube([slideWidth,chestDepth,slideThickness]);
    translate([0,chestDepth-slideWidth,0]) cube([chestWidth,slideWidth,slideThickness*2/3]);

    if (!bottom) {
        translate([0,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
        translate([chestWidth-outerWall,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
    }
}

module chest(numberOfDrawersInChest) {
    render(convexity=8) {
        linear_extrude(height=outerWall)
        gridFace(chestWidth,chestDepth);
        translate([0,0,chestHeight-outerWall]) cube([chestWidth,chestDepth,outerWall]);
        translate([outerWall,0,0]) rotate([0,-90,0])
        linear_extrude(height=outerWall)
        gridFace(chestHeight,chestDepth);
        translate([chestWidth,0,0]) rotate([0,-90,0])
        linear_extrude(height=outerWall)
        gridFace(chestHeight,chestDepth,outerWall);
        for (i=[0:numberOfDrawersInChest-1]) {
            translate([0,0,outerWall+i*drawerSpacing]) drawerSupport(i==0);
        }
        for (i=[1:numberOfDrawersInChest-1]) {
            translate([0,chestDepth-outerWall,outerWall+i*drawerSpacing-slideWidth/2+slideThickness/2]) cube([chestWidth,outerWall,slideWidth]);
        }
            translate([0,chestDepth-outerWall,0]) cube([chestWidth,outerWall,slideWidth/2]);
            translate([0,chestDepth-outerWall,chestHeight-slideWidth/2]) cube([chestWidth,outerWall,slideWidth/2]);
    }
    if (numberOfRearCrossbars > 0) {
        angle = atan2(chestHeight,chestWidth);
        translate([0,chestDepth,0])
        rotate([90,0,0])
        linear_extrude(height=outerWall)
        intersection() {
            union() {
                rotate(angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
                if (numberOfRearCrossbars > 1)
                translate([0,chestHeight])
                rotate(-angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
            }
            square([chestWidth,chestHeight]);
        }
    }
}

module fullDrawer() {
    handle();
    if (rightSideWidthRatio>0) {
        leftWidth = drawerWidth * (1-rightSideWidthRatio) + drawerWall/2;
        rightWidth = drawerWidth * rightSideWidthRatio + drawerWall/2;
        drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, leftWidth, roundOnRight=false);
        translate([leftWidth-drawerWall,0,0])
            drawer(rightSideNumberOfDrawerCompartmentsHorizontally, rightSideNumberOfDrawerCompartmentsInDepth, rightWidth, roundOnLeft=false);
    }
    else {
        drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, drawerWidth);
    }

    if (outerWall > drawerWall)
        drawer(1,1,drawerWidth,drawerWall=outerWall);
}

if (generate == 1) {
    fullDrawer();
}
else
    rotate([-90,0,0])
    chest(numberOfDrawersInChest);
