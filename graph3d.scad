use <eval.scad>;

//<params>
// specify function of x and y in standard OpenSCAD notation, plus you can use all-caps functions for radian-based trigonometry, and you can use the constants "pi" (or "PI") and "e"
z="20*COS(norm([x,y]))/(1+norm([x,y]))";
minX=-10;
maxX=10;
minY=-10;
maxY=10;
resolution=50;
style=1; // [0:flat bottom, 1:surface]
// zero for automatic
thickness=0; 
//</params>

graphFunction3D(z,minX,maxX,minY,maxY,surfaceThickness=style?thickness:undef,flatMinimumThickness=style?undef:thickness);

function makePointList(top, bottom)=
    let(
        width = len(bottom),
        height = len(bottom[0]))
        [for (x=[0:width-1]) for (y=[0:height-1]) for(z=[0:1]) [x,y,z?top[x][y]:bottom[x][y]]];
            
function pointIndex(v,gridHeight)=
      v[0]*gridHeight*2 + v[1]*2 + v[2];

function makeStrip(bottomLeft, lengthwiseDelta, transverseDelta, stripLength, gridHeight) =
        let(
        start = pointIndex(bottomLeft, gridHeight),
        dx = pointIndex(bottomLeft+lengthwiseDelta, gridHeight) - start,
        dy = pointIndex(bottomLeft+transverseDelta, gridHeight) - start 
        )
        [ for (i=[0:stripLength-1]) for (t=[0:1])
            let (
            v00 = start+dx*i,
            v10 = v00+dx,
            v01 = v00+dy,
            v11 = v00+dx+dy )
            t ? [v00,v01,v11] : [v00,v11,v10] ];

function concatLists(listOfLists)=
    [for (a=listOfLists) for (b=a) b];
        
function makeFaceList(width, height)=let(
    baseFaces=concatLists(
        [for(i=[0:width-2])
            makeStrip([i,0,0],[0,1,0],[1,0,0],height-1,height)]),
    surfaceFaces=concatLists(
        [for(i=[0:width-2])
            makeStrip([i,height-1,1],[0,-1,0],[1,0,0],height-1,height)]),
    leftFaces=makeStrip([0,height-1,0],[0,-1,0],[0,0,1],height-1,height),
    rightFaces=makeStrip([width-1,0,0],[0,1,0],[0,0,1],height-1,height),
    bottomFaces=makeStrip([0,0,0],[1,0,0],[0,0,1],width-1,height),
    topFaces=makeStrip([width-1,height-1,0],[-1,0,0],[0,0,1],width-1,height)) concat(baseFaces,surfaceFaces,leftFaces,rightFaces,bottomFaces,topFaces);

module graphArray3D(top, bottom=undef, thickness=undef, baseZ=undef) {
    width = len(top);
    height = len(top[0]);
    bottom0 = bottom!=undef ? bottom :
              thickness!=undef ? 
                [for(x=[0:width-1]) [for(y=[0:height-1]) top[x][y]-thickness]] : [for(x=[0:width-1]) [for(y=[0:height-1]) baseZ]];
    top1 = [for(x=[0:width-1]) [for(y=[0:height-1]) max(top[x][y],bottom0[x][y])]];
    bottom1 = [for(x=[0:width-1]) [for(y=[0:height-1]) min(top[x][y],bottom0[x][y])]];

    points = makePointList(top1, bottom1);
    faces = makeFaceList(width, height);
    polyhedron(points=points, faces=faces);
}

// surfaceThickness does a surface with a wavy top and
// and bottom.
// flatMinimumThickness does a surface with a flat bottom
// and specifies the minimum thickness.
module graphFunction3D(f,minX,maxX,minY,maxY,resolution=50,surfaceThickness=undef,flatMinimumThickness=undef,bottomFunction=undef) {
    dx = (maxX-minX)/resolution;
    dy = (maxY-minY)/resolution;
    size = max(maxX-minX,maxY-minY);
    fc = compileFunction(f);
    smallSize = size/50;
    e = exp(1);
    top=[for(i=[0:resolution]) [for(j=[0:resolution])
            eval(fc, [["x", minX+dx*i], ["y", minY+dy*j], ["pi", PI], ["PI", PI], ["e", e]])]];
    if (bottomFunction != undef) {
        bc = compileFunction(bottomFunction);
        bottom=[for(i=[0:resolution]) [for(j=[0:resolution])
                eval(bc, [["x", minX+dx*i], ["y", minY+dy*j], ["pi", PI], ["e", e]])]];
        graphArray3D(top, bottom);
    }
    else if (flatMinimumThickness != undef) {
        minZ = min([for(i=[0:resolution]) for(j=[0:resolution]) top[i][j]]);
        graphArray3D(top, baseZ=minZ-(flatMinimumThickness != 0 ? flatMinimumThickness : smallSize));
    }
    else {
        thickness = surfaceThickness!=undef && surfaceThickness!=0 ? surfaceThickness : smallSize;
        graphArray3D(top, thickness=thickness);
    }
}
