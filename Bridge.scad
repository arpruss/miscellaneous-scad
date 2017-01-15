use <ribbon.scad>;  

tolerance = 0.25;
baseExtra = 20;
bridgeHeight = 66; // original supports: 62.21;
bridgeWidth = 40.73;
supportDepth = 23;
attachmentHeight = 9.8;
thickness = 1.5;

// Public domain Bezier stuff from www.thingiverse.com/thing:8443
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);
function PointAlongBez4(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]];
// End public domain Bezier stuff

function PointsAlongBez4(p0, p1, p2, p3, precision=0.05) = [for (u=[0:precision:1]) PointAlongBez4(p0, p1, p2, p3, u) ];
    
function trivialMerge(list) = len(list) == 0 ? [] : list[0];
    
function merge(list) = len(list) <= 1 ? trivialMerge(list) : merge([for (i=[1:len(list)-1]) (i==1 ? concat(list[0],list[1]) : list[i])]);
    
function reflectX(list) = [for (i=[0:len(list)-1]) let(j=len(list)-1-i) [-list[j][0],list[j][1]]];

leftPoints = merge( [ [[0,0],[-baseExtra-bridgeWidth/2,0]], 
    PointsAlongBez4([-baseExtra-bridgeWidth/2,0], [(-baseExtra*0-bridgeWidth/2), 0], [-bridgeWidth/2-thickness/2-tolerance, bridgeHeight*0.75], [-bridgeWidth/2-thickness/2-tolerance, bridgeHeight]),
    [[-bridgeWidth/2-thickness/2-tolerance, bridgeHeight+attachmentHeight], 
    [-bridgeWidth/2-thickness/2-tolerance, bridgeHeight-thickness/2]]] ); 
rightPoints = reflectX(leftPoints);
crossBeam1 = [[0,0], leftPoints[13], [0,bridgeHeight-thickness/2]];

linear_extrude(height=supportDepth) union() {
    ribbon(concat(leftPoints,rightPoints),thickness=thickness);
    ribbon(crossBeam1,thickness=thickness);
    ribbon(reflectX(crossBeam1),thickness=thickness);
}