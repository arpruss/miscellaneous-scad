use <Bezier.scad>;

holeTolerance = 0.2;
holeDepth = 8;
pegHeight = 16;
pegDiameter = 7;
boardHeight = 9;

plusSize = 50;
plusRounding = 5;
triangleSize = 50;
triangleRounding = 10;

function merge(list) = [for(p=list)for(q=p) q];

plus = Bezier(PathToBezier([plusSize*[1,0],plusSize*[1,1.5/3.5],plusSize*[1.5/3.5,1.5/3.5],REPEAT_MIRRORED([-1,1]),REPEAT_MIRRORED([1,0]),
    REPEAT_MIRRORED([0,1])],offset=plusRounding));

function interp(a,b,n) =
    [for(i=[0:1:n-2])
        a*(1-i/(n-1))+b*i/(n-1)];

function makeTriangle(pointsPerLine=2) =
    merge([for(i=[0:2]) interp([cos(i*120-30),sin(i*120-30)],[cos((i+1)*120-30),sin((i+1)*120-30)],pointsPerLine)]);
            
triangle = Bezier(PathToBezier(triangleSize*makeTriangle(),offset=triangleRounding,closed=true));

trianglePoints = triangleSize*concat(2/3*makeTriangle(5),2/3*1/4*makeTriangle(2));
    
module board(base=triangle,points=trianglePoints,threeD=false) {
    if (threeD) {
        if (holeDepth>=boardHeight) {
            linear_extrude(height=boardHeight) board(base=base,points=points);
        }
        else {
            linear_extrude(height=boardHeight-holeDepth+0.001) polygon(base);
            translate([0,0,boardHeight-holeDepth]) linear_extrude(holeDepth) board(base=base,points=points);
        }
    }
    else
    difference() {
        polygon(base);
        for (p=points) translate(p) circle(d=pegDiameter+2*holeTolerance,$fn=32);    
    }
}

plusPoints = plusSize*0.27 * [for(x=[-3:3]) let(n=abs(x)>1?1:3) for(y=[-n:n]) [x,y]];

board(plus, plusPoints, threeD=true);