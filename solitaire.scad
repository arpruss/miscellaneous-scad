use <Bezier.scad>;

mode=1; //[0:triangle,1:plus]
output=1; //[0:pegs,1:board]
threeD = 0; //[0:no, 1:yes]
holeTolerance = 0.6;
holeDepth = 8;
pegHeight = 16;
pegDiameter = 8;
pegSpacing = 18;
boardHeight = 11.36;
boardScaleFactor = 1;

plusRounding = 10;
triangleRounding = 10;

module dummy() {}

$fn = 32;

function merge(list) = [for(p=list)for(q=p) q];

plus = boardScaleFactor*Bezier(PathToBezier([[1,0],[1,1.5/3.5],[1.5/3.5,1.5/3.5],REPEAT_MIRRORED([-1,1]),REPEAT_MIRRORED([1,0]),
    REPEAT_MIRRORED([0,1])],offset=plusRounding/100.));

plusPoints = 0.27 * [for(x=[-3:3]) let(n=abs(x)>1?1:3) for(y=[-n:n]) [x,y]];

function pathSize(path,coord=undef) =
    coord == undef ? max([for(i=[0:len(path[0])-1]) pathSize(path,coord=i)]) :
        max([for(p=path) p[coord]]) - min([for(p=path) p[coord]]);
            
function interp(a,b,n) =
    [for(i=[0:1:n-2])
        a*(1-i/(n-1))+b*i/(n-1)];

function makeTriangle(pointsPerLine=2) =
    merge([for(i=[0:2]) interp([cos(i*120-30),sin(i*120-30)],[cos((i+1)*120-30),sin((i+1)*120-30)],pointsPerLine)]);
            
triangle = boardScaleFactor*Bezier(PathToBezier(makeTriangle(),offset=triangleRounding/100.,closed=true));
    
trianglePoints = concat(2/3*makeTriangle(5),2/3*1/4*makeTriangle(2));
    
module board(base=triangle,points=trianglePoints,threeD=false) {
    multiplier = pegSpacing / min([for(i=[0:1:len(points)-1]) for(j=[0:1:i-1]) norm(points[i]-points[j])]);
        
    echo("Diameter", pathSize(multiplier*base));
    
    if (threeD) {
        if (holeDepth>=boardHeight) {
            linear_extrude(height=boardHeight) board(base=base,points=points);
        }
        else {
            linear_extrude(height=boardHeight-holeDepth+0.001) polygon(multiplier*base);
            translate([0,0,boardHeight-holeDepth]) linear_extrude(holeDepth) board(base=base,points=points);
        }
    }
    else
    difference() {
        polygon(multiplier*base);
        for (p=points) translate(multiplier*p) circle(d=pegDiameter+2*holeTolerance,$fn=32);    
    }
}

board = mode ? plus : triangle;
points = mode ? plusPoints : trianglePoints;

module peg() {
    if (threeD) {
        cylinder(d1=pegDiameter*.9, d2=pegDiameter, h=pegHeight/2+0.001);
        translate([0,0,pegHeight/2]) cylinder(d1=pegDiameter, d2=0.9*pegDiameter, h=pegHeight/2);
    }
    else
        circle(d=pegDiameter);
}

module pegs(n) {
    row = ceil(sqrt(n));
    for (y=[0:row-1]) 
        for (x=[0:row-1]) {
            if (x*row+y < n)
                translate((pegDiameter+3)*[x,y]) peg();
        }
}

if (output==0)
    pegs(len(points)-1);
else
    board(board,points,threeD=threeD);
