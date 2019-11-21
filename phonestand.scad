use <Bezier.scad>;

//<params>
additive = true;
includeSides = 2; //[0:0, 1:1, 2:2]
includeSupports = true;
tolerance = 0.15;
bottomSpacing = 10;
minWidth = 7;
lip = 12;
depth = 72;
height = 96;
thickness = 5.2;
supportHeight1 = 35;
supportHeight2 = 20;
supportSpacing = 48;
extraTroughs = 2;
troughDepth = 7;
//</params>

module dummy(){}

precision = 0.1;
extraDepth = extraTroughs?troughDepth:0;
fullDepth = depth+minWidth+extraDepth;

nudge = 0.001;

module side() {
    path = Bezier( 
        [[minWidth,minWidth],POLAR(minWidth/2,180),POLAR(minWidth/2,-90),[0,minWidth+lip/2],POLAR(minWidth/2,90), POLAR(minWidth/2,0), [0,minWidth+lip],POLAR(minWidth,180),POLAR(minWidth/2,90),[-minWidth,minWidth],SYMMETRIC(),POLAR(minWidth/2,180),[0,0],LINE(),LINE(),[depth+extraDepth,0],POLAR(minWidth,0),POLAR(minWidth/2,-90),[fullDepth,minWidth],LINE(),LINE(),[fullDepth,minWidth+height],POLAR(minWidth/3,90),POLAR(minWidth/3,0),[depth+minWidth/2,minWidth+height+minWidth/2],POLAR(minWidth/3,180),POLAR(minWidth/3,90),[depth,minWidth+height],POLAR(height/3,-90),POLAR(height/3,0),[bottomSpacing,minWidth]
    ],precision=-precision);
    
    function findTop(path,n=0,soFar=undef) =
        n>=len(path) ? soFar[0] :
        n==0 ? findTop(path,n=1,soFar=[0,path[0][1]]) :
        findTop(path,n=n+1,soFar=path[n][1]>=soFar[1] ? [n,path[n][1]] : soFar);
    
    function findY(path,y,n=0,closest=[0,-100000]) =
        n>=len(path) ? closest[0] :
        abs(path[n][1]-y)<abs(closest[1]-y) ? findY(path,y,n=n+1,closest=[n,path[n][1]]) :
        findY(path,y,n=n+1,closest=closest);

    difference() {
    polygon(path);
        translate([depth+extraDepth-thickness-2*tolerance,-nudge]) square([thickness+2*tolerance,supportHeight1/2+tolerance]);
        translate([depth*0.6,-nudge]) square([thickness+2*tolerance,supportHeight2/2+tolerance]);
        top = findTop(path);
        for(i=[0:1:extraTroughs-1]) {
            pos = path[findY(path,path[top][1]-minWidth-troughDepth-(troughDepth*2+minWidth/2)*i,n=top)];
            translate(pos) circle(r=troughDepth,$fn=32);
        }
    }
}

module support(supportHeight) {
    w = minWidth*2+supportSpacing+thickness*2+4*tolerance;
    difference() {
        square([w,supportHeight]);
        for (i=[0,1])
        translate([minWidth+i*(supportSpacing+thickness+2*tolerance),supportHeight/2+nudge-tolerance]) square([thickness+2*tolerance,supportHeight]);
        if (additive)
        translate([w/2,supportHeight/2]) circle(d=supportHeight-2*minWidth,$fn=32);
    }
}

module sides() {
    side();
    if (includeSides != 1)
    translate([2*fullDepth+10,0])
    mirror([1,0]) side();
}

module full()
{
    if (includeSides) translate([minWidth,includeSupports ? supportHeight1+10 : 0]) sides();
    if (includeSupports) {
        support(supportHeight1);
        translate(includeSides ? [supportSpacing+2*minWidth+thickness*2+tolerance*2+10,0] : [0,supportHeight1+10]) support(supportHeight2);
    }
}

if  (additive) 
    linear_extrude(height=thickness)  full();
else
    full();