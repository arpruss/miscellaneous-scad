use <tubeMesh.scad>;

function roundedSquare(size=[10,10], radius=1, center=false, $fn=8) 
    = let(d=(center?[-size[0]/2,-size[1]/2]:[0,0])+[0,0])
      concat(
        arcPoints(r=radius, start=0, end=90, center=d+[size[0]-radius,size[1]-radius]),
        arcPoints(r=radius, start=90, end=180, center=d+[radius,size[1]-radius]),
        arcPoints(r=radius, start=180, end=270, center=d+[radius,radius]),
        arcPoints(r=radius, start=270, end=360, center=d+[size[0]-radius,radius])
        
        );

module followCurve(curve, section) {
    function rotateSectionPoint(xy1,xy2,p) = 
        let(angle=atan2(xy2[1]-xy1[1],xy2[0]-xy1[0])-90)           
            [xy1[0]+p[0]*cos(angle),xy1[1]+p[0]*sin(angle),p[1]];
    
    sections = [for (i=[0:len(curve)-1]) [for (p=section) rotateSectionPoint(curve[i],curve[(i+1)%len(curve)],p)]];
    tubeMesh(concat(sections,[sections[0]]), startCap=false, endCap=false);
}

module beveledRoundedSquareWalls(innerSize=[10,10],outerSize=undef,innerHeight=10,outerHeight=16,thickness=2,radius=1,center=false,$fn=8) {
    size=outerSize==undef?innerSize:outerSize-[2*thickness,2*thickness];
    delta=outerSize==undef || center?[0,0,0]:[thickness,thickness,0];
    r=outerSize==undef ? radius : radius-thickness;
    translate(delta) followCurve(roundedSquare(size=size,radius=r,center=center), [[0,0],[thickness,0],[thickness,outerHeight],[thickness,innerHeight]]);
}

beveledRoundedSquareWalls(outerSize=[20,20],radius=3,center=true);