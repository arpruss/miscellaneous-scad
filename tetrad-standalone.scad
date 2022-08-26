generate = 3; // [2:pieces, 1:board, 2:box, 3:demo]
wall = 1;
incut = 1;
rounding = 2;
numberOfSides1 = 6;
numberOfSides2 = 3;
bottomHeight = 15;
shortHeight = 16;
tallHeight = 28;
diameter = 15;
// if you make a solid base for the pieces, the hollow ones will feel more solid, but you might confuse them for the solid ones when you turn them upside down
solidBaseHeight = 0;

boardThickness = 2.5;
boardHoleDepth = 2;
boardPieceTolerance = 2;
boardHoleSpacing = 5;

boxTolerance = 0.2;
boxSliderWidth = 3.5;
boxSliderThickness = 1.5;
boxWall = 0.75;
boxBottomWall = 1;

module end_of_parameters_dummy() {}

//use <tubemesh.scad>;
// params = [sections,sectionCounts]

// written for tail-recursion
// _subtotals[i] = list[0] + ... + list[i-1]
function _subtotals(list,soFar=[]) =
        len(soFar) >= 1+len(list) ? soFar :
        _subtotals(list,
            let(n1=len(soFar))
            concat(soFar, n1>0 ? soFar[n1-1]+list[n1-1] : 0));

function _flatten(list) = [for (a=list) for(b=a) b];

function _reverseTriangle(t) = [t[2], t[1], t[0]];

// smallest angle in triangle
function _minAngle(p1,p2,p3) =
    let(a = p2-p1,
        b = p3-p1,
        c = p3-p2,
        v1 = a*b,
        v2 = -(c*a))
        v1 == 0 || v2 == 0 ? 0 :
        let( na = norm(a),
             a1 = acos(v1 / (na*norm(b))),
             a2 = acos(v2 / (na*norm(c))) )
        min(a1,a2,180-(a1+a2));

// triangulate square to maximize smallest angle
function _doSquare(points,i11,i21,i22,i12,optimize=true) =
    points[i11]==points[i12] ? [[i11,i21,i22]] :
    points[i21]==points[i22] ? [[i22,i12,i11]] :
    !optimize ? [[i11,i21,i22], [i22,i12,i11]] :
    let (m1 = min(_minAngle(points[i11],points[i21],points[i22]), _minAngle(points[i22],points[i12],points[i11])),
        m2 = min(_minAngle(points[i11],points[i21],points[i12]),
                _minAngle(points[i21],points[i22],points[i12])) )
        m2 <= m1 ? [[i11,i21,i22], [i22,i12,i11]] :
                  [[i11,i21,i12], [i21,i22,i12]];

/*
function _inTriangle(v1,t) = (v1==t[0] || v1==t[1] || v1==t[2]);

function _findTheDistinctVertex(t1,t2) =
    let(in = [for(i=[0:2]) _inTriangle(t1[i],t2)])
    ! in[0] && in[1] && in[2] ? 0 :
    ! in[1] && in[0] && in[2] ? 1 :
    ! in[2] && in[0] && in[1] ? 2 :
    undef;

// make vertex i come first
function _rotateTriangle(t,i) =
    [for (j=[0:2]) t[(j+i)%3]];

function _optimize2Triangles(points,t1,t2) =
    let(i1 = _findTheDistinctVertex(t1,t2))
    i1 == undef ? [t1,t2] :
    let(i2 = _findTheDistinctVertex(t2,t1))
    i2 == undef ? [t1,t2] :
    let(t1 = _rotateTriangle(t1,i1),
        t2 = _rotateTriangle(t2,i2))
    _doSquare(points,t1[1],t2[0],t2[1],t1[0],optimize=true);

// a greedy optimization for a strip of triangles most of which adjoin one another; written for tail-recursion
function _optimizeTriangles(points,triangles,position=0,optimize=true,iterations=4) =
        !optimize || position >= iterations*len(triangles) ? triangles :
            _optimizeTriangles(points,
                let(
                    n = len(triangles),
                    position1=position%n,
                    position2=(position+1)%n,
                    opt=_optimize2Triangles(points,triangles[position1],triangles[position2]))
                    [for (i=[0:len(triangles)-1])
                        i == position1 ? opt[0] :
                        i == position2 ? opt[1] :
                            triangles[i]],
                position=position+1);
*/

function _removeEmptyTriangles(points,triangles) =
    [for(t=triangles)
        if(true || points[t[0]] != points[t[1]] && points[t[1]] != points[t[2]] && points[t[2]] != points[t[0]]) t];

// n1 and n2 should be fairly small, so this doesn't need
// tail-recursion
// this assumes n1<=n2
function _tubeSegmentTriangles(points,index1,n1,index2,n2,i=0,soFar=[],optimize=true)
    = i>=n2 ? _removeEmptyTriangles(points,soFar) :
            let(i21=i,
                i22=(i+1)%n2,
                i11=floor((i21)*n1/n2+0.5)%n1,
                i12=floor((i22)*n1/n2+0.5)%n1,
                add = i11==i12 ? [[index1+i11,index2+i21,index2+i22]] :
                    _doSquare(points,index1+i11,index2+i21,index2+i22,index1+i12,optimize=optimize))
                _tubeSegmentTriangles(points,index1,n1,index2,n2,i=i+1,soFar=concat(soFar,add),optimize=optimize);

function _tubeSegmentFaces(points,index,n1,n2,optimize=true)
    = n1<n2 ? _tubeSegmentTriangles(points,index,n1,index+n1,n2,optimize=optimize) :
        [for (f=_tubeSegmentTriangles(points,index+n1,n2,index,n1,optimize=optimize)) _reverseTriangle(f)];

function _tubeMiddleFaces(points,counts,subtotals,optimize=true) = [ for (i=[1:len(counts)-1])
           for (face=_tubeSegmentFaces(points,subtotals[i-1],counts[i-1],counts[i],optimize=optimize)) face ];

function _endCaps(counts,subtotals,startCap=true,endCap=true) =
    let( n = len(counts),
         cap1 = counts[0]<=2 || !startCap ? undef : [for(i=[0:counts[0]-1]) i],
         cap2 = counts[n-1]<=2 || !endCap ? undef : [for(i=[counts[n-1]-1:-1:0]) subtotals[n-1]+i] )
       [for (c=[cap1,cap2]) if (c!=undef) c];

function _tubeFaces(sections,startCap=true,endCap=true,optimize=true) =
                let(
        counts = [for (s=sections) len(s)],
        points = _flatten(sections),
        subtotals = _subtotals(counts))
            concat(_tubeMiddleFaces(points,counts,subtotals,optimize=optimize),_endCaps(counts,subtotals,startCap=true,endCap=true));

function _removeDuplicates1(points,soFar=[[],[]]) =
        len(soFar[0]) >= len(points) ? soFar :
            _removeDuplicates1(points,
               let(
                mapSoFar=soFar[0],
                pointsSoFar=soFar[1],
                j=len(mapSoFar),
                k=search([points[j]], pointsSoFar)[0])
                k == []? [concat(mapSoFar,[len(pointsSoFar)]),
                            concat(pointsSoFar,[points[j]])] :
                           [concat(mapSoFar,[k]),pointsSoFar]);

function _removeDuplicates(points, faces) =
    let(fix=_removeDuplicates1(points),
        map=fix[0],
        newPoints=fix[1],
        newFaces=[for(f=faces) [for(v=f) map[v]]])
            [newPoints, newFaces];

function pointsAndFaces(sections,startCap=true,endCap=true,optimize=true) =
        let(
            points0=_flatten(sections),
            faces0=_tubeFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize))
        _removeDuplicates(points0,faces0);

function sectionZ(section,z) = [for(xy=section) [xy[0],xy[1],z]];

function shiftSection(section,delta) = [for(p=section) [for(i=[0:len(delta)-1]) (p[i]==undef?0:p[i])+delta[i]]];

module tubeMesh(sections,startCap=true,endCap=true,optimize=true) {
    pAndF = pointsAndFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize);
    polyhedron(points=pAndF[0],faces=pAndF[1]);
}

// increase number of points from len(section) to n
function _interpolateSection(section,n) =
        let(m=len(section))
        n == m ? section :
        n < m ? undef :
            [for(i=[0:m-1])
                let(cur=floor(i*n/m),
                    k=floor((i+1)*n/m)-cur,
                    i2=(i+1)%m)
                    for(j=[0:k-1])
                        let(t=j/k)
                            section[i]*(1-t)+section[i2]*t];

function arcPoints(r=10,d=undef,start=0,end=180,z=undef) =
            let(r=d==undef?r:d/2,
                n=getPointsAround(abs(end-start)))
                    r*[for(i=[0:n])
                        let(angle=start+i*(end-start)/n) [cos(angle),sin(angle)]];

function ngonPoints(n=4,r=10,d=undef,rotate=0,z=undef) =
            let(r=d==undef?r:d/2)
            z==undef ?
            r*[for(i=[0:n-1]) let(angle=i*360/n+rotate) [cos(angle),sin(angle)]] :
            [for(i=[0:n-1]) let(angle=i*360/n+rotate) [r*cos(angle),r*sin(angle),z]];

function starPoints(n=10,r1=5,r2=10,rotate=0,z=undef) =
          z==undef ?
            [for(i=[0:2*n-1]) let(angle=i*180/n+rotate) (i%2?r1:r2) * [cos(angle),sin(angle)]] :
            [for(i=[0:2*n-1]) let(angle=i*180/n+rotate, r=i%2?r1:r2) [r*cos(angle),r*sin(angle),z]];

function roundedSquarePoints(size=[10,10],radius=2,z=undef) =
    let(n=$fn?$fn:32,
        x=len(size)>=2 ? size[0] : size,
        y=len(size)>=2 ? size[1] : size,
        centers=[[x-radius,y-radius],[radius,y-radius],[radius,radius],[x-radius,radius]],
        section=[for(i=[0:n-1])
            let(center=centers[floor(i*4/n)],
                angle=360*i/n)
            center+radius*[cos(angle),sin(angle)]])
        z==undef ? section : sectionZ(section,z);

function getPointsAround(radius, angle=360) =
    max(3, $fn ? ceil($fn*angle/360) :
        max(floor(0.5+angle/$fa), floor(0.5+2*radius*PI*angle/360/$fs)));

// warning: no guarantee of perfect convexity
module mySphere(r=10,d=undef) {
    GA = 2.39996322972865332 * 180 / PI;
    radius = d==undef ? r : d/2;
    pointsAround = getPointsAround(radius);
    numSlices0 = (pointsAround + pointsAround % 2)/2;
    numSlices = numSlices0 + (numSlices0%2);
    sections = radius*[for(i=[0:numSlices])
                    i == 0 ? [[0,0,-1]] :
                    i == numSlices ? [[0,0,1]] :
                    let(
                        lat = (i-numSlices/2)/(numSlices/2)*90,
                        z1 = sin(lat),
                        r1 = cos(lat),
                        count = max(3,floor(0.5 + pointsAround * abs(r1))))
                        ngonPoints(count,r=r1,z=z1)];
    data = pointsAndFaces(sections,optimize=false);
    polyhedron(points=data[0], faces=data[1]);
}

module morphExtrude(section1,section2,height=undef,twist=0,numSlices=10,startCap=true,endCap=true,optimize=false) {
    n = max(len(section1),len(section2));

    section1interp = _interpolateSection(section1,n);
    section2interp = _interpolateSection(section2,n);
    sections = height == undef ?
                      [for(i=[0:numSlices])
                        let(t=i/numSlices)
                        (1-t)*section1interp+t*section2interp] :
                      [for(i=[0:numSlices])
                        let(t=i/numSlices,
                            theta = t*twist,
                            section=(1-t)*section1interp+t*section2interp)
                        [for(p=section) [p[0]*cos(theta)-p[1]*sin(theta),p[0]*sin(theta)+p[1]*cos(theta),height*t]]];

    tubeMesh(sections,startCap=startCap,endCap=endCap,optimize=false);
}

module cone(r=10,d=undef,height=10) {
    radius = d==undef ? r : d/2;
    pointsAround =
        $fn ? $fn :
        max(3, floor(0.5+360/$fa), floor(0.5+2*radius*PI/$fs));
    morphExtrude(ngonPoints(n=pointsAround,r=radius), [[0,0]], height=height,optimize=false);
}

module prism(base=[[0,0,0],[1,0,0],[0,1,0]], vertical=[0,0,1]) {
    morphExtrude(base,[for(v=base) v+vertical],numSlices=1);
}



module dummy() {}
nudge = 0.01;

sideCounts = [numberOfSides1,numberOfSides2];
colors = [ [0.25,0.25,0.25], [1,1,1] ];

function getBit(x,n) = floor(x / pow(2,n)) % 2;

// piece(hollow,tall) { outer; inner; }
module piece(hollow,tall) {
    height = tall ? tallHeight : shortHeight;

    module solid(height, diameter) {
        mul = (diameter-2*incut)/diameter;
        linear_extrude(height=bottomHeight-2*incut+nudge) children();

        translate([0,0,bottomHeight-2*incut])
            linear_extrude(height=incut+nudge,scale=mul) children();

       translate([0,0,bottomHeight-incut])
            linear_extrude(height=incut+nudge,scale=1/mul) scale(mul) children();
        translate([0,0,bottomHeight])
            linear_extrude(height=height-bottomHeight) children();
    }

    if (hollow) {
        difference() {
            solid(height,diameter) children(0);
            translate([0,0,-nudge])
            solid(height+2*nudge,diameter-2*wall,incut) children(1);
        }
        if (solidBaseHeight) {
            intersection() {
                solid(height,diameter,0) children(0);
                cylinder(d=3*diameter,h=solidBaseHeight,$fn=4);
            }
        }
    }
    else {
        solid(height,diameter) children(0);
    }
}

module poly(diameter, inset, sides) {
    rounding1 = inset>0 ? rounding/2 : rounding;
    r = diameter/2 - rounding1-inset;
    hull() {
        for (i=[0:sides-1])
            translate(r*[cos(i/sides*360),sin(i/sides*360)]) circle(r=rounding1,$fn=24);
    }
}

s = boardHoleSpacing;
d = diameter + boardPieceTolerance*2;
r = d/2;
dx = d + s;

module pieces(demo=false) {
    for (i=[0:(demo ? 15 : 7)]) {
        translate([floor(i/4)*dx,(i%4)*dx,0])
        color(colors[getBit(i,3)])
        render(convexity=2)
            piece(getBit(i,1),getBit(i,2)) {
                sides = sideCounts[getBit(i,0)];
                poly(diameter,0,sides);
                poly(diameter,wall,sides);
            }
    }
}

module board() {
    $fn = 36;
    render(convexity=4)
    difference() {
        linear_extrude(height=boardThickness)
        hull() {
            circle(d=dx+s);
            translate([3*dx,0])
            circle(d=dx+s);
            translate([0,3*dx])
            circle(d=dx+s);
            translate([3*dx,3*dx])
            circle(d=dx+s);
        }
        translate([0,0,boardThickness-boardHoleDepth])
            linear_extrude(height=boardThickness)
                for(i=[0:3]) for(j=[0:3])
                    translate([i*dx,j*dx]) circle(d=d);
    }
}

boxSize = 3*dx+dx+s + 2 * boxTolerance;
boxHeight = boxBottomWall + diameter*cos(180/max(numberOfSides1,numberOfSides2)) + boardPieceTolerance + boxSliderWidth + boardThickness;

module box() {
    size = boxSize;
    height = boxHeight;
    ridgeSpacing = boxSliderWidth+boardThickness;

    corner=(dx+s)/2;
    outer = roundedSquarePoints(size+2*boxWall, radius=corner+boxWall);
    inner = shiftSection(roundedSquarePoints(size,radius=corner),[boxWall,boxWall]);
    ridge = shiftSection(roundedSquarePoints(size-2*boxSliderWidth,radius=corner-boxSliderWidth),
        [boxWall+boxSliderWidth,boxWall+boxSliderWidth]);
    render(convexity=2)
    difference() {
        linear_extrude(height=height) polygon(outer);
        tubeMesh(
            [
                sectionZ(inner,boxBottomWall),
                sectionZ(inner,height-ridgeSpacing-boxSliderWidth),
                sectionZ(ridge,height-ridgeSpacing),
                sectionZ(inner,height-ridgeSpacing),
                sectionZ(inner,height-boxSliderWidth),
                sectionZ(ridge,height) ]);
    translate([-nudge,size-corner+boxWall,height-ridgeSpacing]) cube([size+2*boxWall+2*nudge,boxWall+corner+nudge,ridgeSpacing]);
    }
}

module demo() {
    ridgeSpacing = boxSliderWidth+boardThickness;

    box();
    translate([boxWall+boxTolerance+(dx+s)/2,boxWall+boxTolerance+(dx+s)/2,boxHeight-ridgeSpacing]) {
        color("red")
        board();
        translate([0,0,boardThickness-boardHoleDepth]) pieces(demo=true);
    }
}

if (generate==1) board();
else if (generate==0) pieces();
else if (generate==3) {
    demo();
}
else if (generate==2) {
    box();
}
