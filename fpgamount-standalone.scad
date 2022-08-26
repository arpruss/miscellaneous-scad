baseThickness = 2;
spacing = 5;
corner = 8;
undersideRimWidth = 10;
rimHeight = 7;

fpgaSizeX = 52;
fpgaSizeY = 72.64;
fpgaScrewSpacingX = 47.3;
fpgaScrewSpacingY = 67.3;


breadboardTolerance = 0.3;

smallBreadboardSizeX = 45.7;
smallBreadboardSizeY = 34.65;

bigBreadboardSizeX = 54.2;
bigBreadboardSizeY = 82;

bigBreadboardNubDiameter = 4;
bigBreadboardNubPositions = [ [0,13.9], [0,68], [4.5,0], [27.1,0], [49.7,0] ];

screwHoleSize = 2.6;
screwLength = 10;
screwPillarDiameter = 7;
fpgaHeightAboveBottom = 12;

module end_of_parameters_dummy() {}

//use <roundedsquare.scad>;
module roundedSquare(size=[10,10], radius=1, center=false, $fn=16) {
    size1 = (size+0==size) ? [size,size] : size;
    if (radius <= 0) {
        square(size1, center=center);
    }
    else {
        translate(center ? -size1/2 : [0,0])
        hull() {
            translate([radius,radius]) circle(r=radius);
            translate([size1[0]-radius,radius]) circle(r=radius);
            translate([size1[0]-radius,size1[1]-radius]) circle(r=radius);
            translate([radius,size1[1]-radius]) circle(r=radius);
        }
    }
}

module roundedOpenTopBox(size=[10,10,10], radius=2, wall=1, solid=false) {
    render(convexity=2)
    difference() {
        linear_extrude(height=size[2]) roundedSquare(size=[size[0],size[1]], radius=radius);
        if (!solid) {
            translate([0,0,wall])
            linear_extrude(height=size[2]-wall)
            translate([wall,wall]) roundedSquare(size=[size[0]-2*wall,size[1]-2*wall], radius=radius-wall);
        }
    }
}


module dummy() {}

nudge = 0.01;

smallBB = smallBreadboardSizeX > 0 && smallBreadboardSizeY > 0;

row1Height = max(fpgaSizeY, bigBreadboardSizeY+2*breadboardTolerance);
row2Height = smallBreadboardSizeY+2*breadboardTolerance;
col1Width = max(fpgaSizeX, smallBreadboardSizeX+2*breadboardTolerance);
col2Width = max(bigBreadboardSizeX+2*breadboardTolerance,smallBreadboardSizeX+2*breadboardTolerance);
width = col1Width+col2Width+3*spacing;
height = smallBB ? (row1Height+row2Height+3*spacing) : (row1Height+2*spacing);

col1X = spacing+0.5*col1Width;
col2X = 2*spacing+col1Width+0.5*col2Width;
row1Y = spacing+0.5*row1Height;
row2Y = row1Height+2*spacing+0.5*row2Height;

fpgaHoleXSize = fpgaSizeX-2*undersideRimWidth;
fpgaHoleYSize = fpgaSizeY-2*undersideRimWidth;

// cube centered in xy plane
module cCube(dimensions) {
    translate([-dimensions[0]/2,-dimensions[1]/2,0]) cube(dimensions);
}

module cutout(w,h) {
    translate([0,0,baseThickness]) cCube([w,h,rimHeight+nudge]);
    translate([0,0,-nudge]) cCube([w-2*undersideRimWidth,h-2*undersideRimWidth,baseThickness+2*nudge]);
}

module removers(x,y,width,height) {
    translate([x-width/2,y,baseThickness]) scale([0.9,1.25,1]) cylinder(d=spacing,h=rimHeight+nudge,$fn=36);
    translate([x+width/2,y,baseThickness]) scale([0.9,1.25,1])cylinder(d=spacing,h=rimHeight+nudge,$fn=36);
}

module screwPillar() {
    $fn = 24;
    render(convexity=2)
    difference() {
        cylinder(d=screwPillarDiameter,h=fpgaHeightAboveBottom);
        translate([0,0,fpgaHeightAboveBottom-screwLength])
        cylinder(d=screwHoleSize,h=screwLength+nudge);
    }
}

render(convexity=4)
difference() {
    linear_extrude(rimHeight+baseThickness) roundedSquare([width,height],radius=corner);
    translate([col1X,row1Y,0]) cutout(fpgaSizeX,fpgaSizeY);
    translate([col2X,row1Y,0]) cutout(bigBreadboardSizeX+2*breadboardTolerance,bigBreadboardSizeY+2*breadboardTolerance);
//    removers(col2X,row1Y,bigBreadboardSizeX+2*breadboardTolerance,bigBreadboardSizeY+2*breadboardTolerance);
    for (xy=bigBreadboardNubPositions)
        translate([col2X-(bigBreadboardSizeX+2*breadboardTolerance)/2+xy[0],row1Y-(bigBreadboardSizeY+2*breadboardTolerance)/2+xy[1],baseThickness]) cylinder(d=bigBreadboardNubDiameter,h=rimHeight+nudge,$fn=16);
    if (smallBB) {
 //       removers(col1X,row2Y,smallBreadboardSizeX+2*breadboardTolerance,smallBreadboardSizeY+2*breadboardTolerance);
//        removers(col2X,row2Y,smallBreadboardSizeX+2*breadboardTolerance,smallBreadboardSizeY+2*breadboardTolerance);
        translate([col1X,row2Y,0]) cutout(smallBreadboardSizeX+2*breadboardTolerance,smallBreadboardSizeY+2*breadboardTolerance);
        translate([col2X,row2Y,0]) cutout(smallBreadboardSizeX+2*breadboardTolerance,smallBreadboardSizeY+2*breadboardTolerance);
    }
}

for (i=[-1:2:1]) for(j=[-1:2:1])
    translate([col1X+i*0.5*fpgaScrewSpacingX,row1Y+j*0.5*fpgaScrewSpacingY,0]) screwPillar();
