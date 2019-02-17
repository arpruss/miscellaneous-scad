scaleFactor = 1;
squareSize = 15;
pieceTolerance = 0.3;
slitWidth = 1;
thickSlitWidth = 1.5;
slitDepth = 1;
boardThickness = 3;
pieceBaseHeight = 5;
insetRatio = .8;
pyramidHeight = 16;
pusherHeight = 8;
pusherWall = 0.75;
anchorTolerance = 0;
anchorPyramidHeight = 12;
anchorTaper = 0.8;
sideWall = 4;
rounding = .07;
boardEdgeWidth = 3;
boardEdgeThickness = 1;
pyramidTipRatio = 0.2;
item = 0; // [0:Board,1:Pyramid,2:Pusher,3:Anchor]

module dummy(){}

pieceSize = squareSize-pieceTolerance;
nudge = 0.01;

module rsquare(l) {
    r = l * rounding;
    hull() {
        for (x=[-1,1])
            for (y=[-1,1])
                translate([(l/2-r)*x,(l/2-r)*y]) circle(r=r,$fn=16);
    }
}

module pieceBase(h=pieceBaseHeight,w=pieceSize,taper=1.) {
    linear_extrude(height=h+nudge,scale=1/taper) scale(taper) rsquare(w);
}

module pyramid(h1=pieceBaseHeight,h2=pyramidHeight,pieceSize=pieceSize,taper=1) {
    pieceBase(h1,pieceSize,taper);
    translate([0,0,h1])
    linear_extrude(height=h2,scale=pyramidTipRatio)
        rsquare(pieceSize*insetRatio);
}

module pusher() {
    pieceBase();
    translate([0,0,pieceBaseHeight])
        linear_extrude(height=pusherHeight)
            difference() {
                rsquare(insetRatio*pieceSize);
                rsquare(insetRatio*pieceSize-pusherWall*2);
            }
}

module anchor() {
    outer = insetRatio*pieceSize-pusherWall*2-anchorTolerance*2;
    pyramid(pusherHeight,anchorPyramidHeight,outer,anchorTaper);
}

module boardBottom() {
    difference() {
        square([8*squareSize,2*sideWall+4*squareSize]);
        translate([-nudge,-nudge]) square([squareSize+nudge,squareSize+sideWall+nudge]);
        translate([6*squareSize,-nudge]) square([2*squareSize+nudge,squareSize+sideWall+nudge]);
        translate([-nudge,3*squareSize+sideWall]) square([2*squareSize+nudge,squareSize+sideWall+nudge]);
        translate([7*squareSize,3*squareSize+sideWall]) square([squareSize+nudge,squareSize+sideWall+nudge]);
    }
}

module sideWalls() {
    translate([squareSize,0]) square([5*squareSize,sideWall]);
    translate([2*squareSize,sideWall+4*squareSize]) square([5*squareSize,sideWall]);
}

module solidBoard() {
    linear_extrude(height=boardThickness) boardBottom();
    linear_extrude(height=boardThickness+pieceBaseHeight) sideWalls();
}

module hslit(x,y,w,slitWidth=slitWidth) {
    translate([x*squareSize,sideWall+y*squareSize-slitWidth/2,boardThickness-slitDepth]) cube([w*squareSize,slitWidth,slitDepth+nudge]);
}

module vslit(x,y,h,slitWidth=slitWidth) {
    translate([x*squareSize-slitWidth/2,sideWall+y*squareSize,boardThickness-slitDepth]) cube([slitWidth,h*squareSize,slitDepth+nudge]);
}

module board() {
   
    render(convexity=2)
    difference() {
        solidBoard();
        hslit(1,1,5);
        hslit(0,2,8);
        hslit(2,3,5);
        vslit(1,1,2);
        vslit(2,0,3);
        vslit(3,0,4);
        vslit(4,0,4,slitWidth=thickSlitWidth);
        vslit(5,0,4);
        vslit(6,1,3);
        vslit(7,1,2);        
    }
    translate([squareSize,nudge-boardEdgeWidth,0])
    cube([5*squareSize,boardEdgeWidth+nudge,boardEdgeThickness]);
    translate([2*squareSize,sideWall+4*squareSize+sideWall-nudge,0])
    cube([5*squareSize,boardEdgeWidth+nudge,boardEdgeThickness]);
}

if (item==0) board();
else if (item==1) pyramid();
else if (item==2) pusher();
else if (item==3) anchor();


