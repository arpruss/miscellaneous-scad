// Public domain Bezier stuff from www.thingiverse.com/thing:8443
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);
function PointAlongBez4(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]];
// End public domain Bezier stuff

function Bezier2(p,index=0,precision=0.05,rightEndPoint=true) = let(nPoints=ceil(1/precision)) [for (i=[0:nPoints-(rightEndPoint?0:1)]) PointAlongBez4(p[index+0],p[index+1]==undef?2*p[index+0]-p[index-1]:p[index+1],p[index+2]==undef?2*p[index+3]-p[index+4]:p[index+2],p[index+3],i/nPoints)];
    
function flatten(listOfLists) = [ for(list = listOfLists) for(item = list) item ];


// p is a list of points, in the format:
// [node1,control1,control2,node2, node3,control3, control4,node4, ...]
// You can replace inner control points with undef, which then uses a reflection of the control point on the other side of the node.

function Bezier(p,precision=0.05) = let(nodes=(len(p)-1)/3) flatten([for (i=[0:nodes-1]) Bezier2(p,index=i*3,precision=precision,rightEndPoint=(i==nodes-1))]);

//polygon(Bezier([[0,0],[5,0],[5,10],[10,10],undef,[15,0],[20,0]],precision=0.05));
