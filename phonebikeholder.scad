use <paths.scad>;

//<params>
attachmentThickness = 2.5;
attachmentWidth = 18;
b1 = 79.5;
b1a = 85.0;
b2 = 87;
h1a = 1;
bumpHeight = 3;
extraThickness = 3; //3.5;
phoneWidth = 77.5;
snapHeight = 10.6;
snapInset = 1.5;
snapThickness = 1.5;
holderWidth = 52;
rounding = 0.8;
holeSize = 2.2;
holeSpacing = 60;
//</params>

module dummy() {}

nudge = 0.001;

rightPath = 
  [ [b1/2,0],
    [b1a/2,h1a],
    [b2/2,bumpHeight],
    [b2/2,bumpHeight+extraThickness],
    [phoneWidth/2+snapThickness,bumpHeight+extraThickness+snapHeight*0.5],
    [phoneWidth/2+snapThickness,bumpHeight+extraThickness+snapHeight+snapThickness+2],
    [phoneWidth/2-snapInset,bumpHeight+extraThickness+snapHeight+snapThickness],
    [phoneWidth/2-snapInset,bumpHeight+extraThickness+snapHeight],
    [phoneWidth/2,bumpHeight+extraThickness+snapHeight],
    [phoneWidth/2,bumpHeight+extraThickness],
    [0, bumpHeight+extraThickness]];
    
    
path = stitchPaths(rightPath,reverseArray(transformPath(mirrorMatrix([1,0]),rightPath)));

module mainHolder() {
    linear_extrude(height=holderWidth) 
offset(r=-rounding) offset(r=rounding) polygon(points=path);
}

module holes(extra=0) {
    for(i=[0:1]) translate(-[0,attachmentWidth/2+i*(holderWidth-attachmentWidth),0]) {
    translate([-holeSpacing/2,0,-50]) cylinder(d=holeSize+extra,h=100,$fn=16);
    translate([holeSpacing/2,0,-50]) cylinder(d=holeSize+extra,h=100,$fn=16);
    }
}

module attachment() {
    difference() {
       // hull()
    for(i=[0:1]) translate(-[0,attachmentWidth/2+i*(holderWidth-attachmentWidth),0]) 
        union()
        {
            translate([-holeSpacing/2,0,0]) cylinder(d=attachmentWidth, h=attachmentThickness);
            translate([holeSpacing/2,0,0]) cylinder(d=attachmentWidth, h=attachmentThickness);
        }
    holes(extra=1.5);
    }
}

render(convexity=2) {
    difference() {
        mainHolder();
        rotate([-90,0,0]) holes();
    }
//    translate([0,-10,0]) attachment();
}
