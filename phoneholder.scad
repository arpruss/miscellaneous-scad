use <paths.scad>;

//<params>
b1 = 79.5;
b1a = 85.0;
b2 = 87;
h1a = 2;
rightNubFromBase = 5.6;
rightNubSlitThickness = 3.3;
rightNubSlitLength = 22.5;;
rightNubSlitDepth = 2.7;
leftNubFromBase = 7.4;
leftNubSlitThickness = 2.2;
leftNubSlitLength = 15;
leftNubSlitDepth = 1.5;
fromNubsToPhone = 3.5;
phoneWidth = 77.5;
snapHeight = 10.6;
snapInset = 1.5;
snapThickness = 1.5;
holderWidth = 26;
rounding = 0.8;
//</params>

module dummy() {}

nudge = 0.001;

rightPath = 
  [ [b1/2,0],
    [b1a/2,h1a],
    [b2/2,max(leftNubFromBase,rightNubFromBase)],
    [b2/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone],
    [phoneWidth/2+snapThickness,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeight*0.5],
    [phoneWidth/2+snapThickness,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeight+snapThickness+1.5],
    [phoneWidth/2-snapInset,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeight+snapThickness],
    [phoneWidth/2-snapInset,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeight],
    [phoneWidth/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeight],
    [phoneWidth/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone],
    [0, max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone]];
    
    
path = stitchPaths(rightPath,reverseArray(transformPath(mirrorMatrix([1,0]),rightPath)));

module mainHolder() {
    linear_extrude(height=holderWidth) 
offset(r=-rounding) offset(r=rounding) polygon(points=path);
}

module slit(nubFromBase,nubSlitThickness,nubSlitLength,nubSlitDepth) {
    translate([b2/2+nudge-nubSlitDepth,nubFromBase-nubSlitThickness/2,holderWidth/2-nubSlitLength/2])
    cube([nubSlitDepth+nudge,nubSlitThickness,nubSlitLength]);
}

render(convexity=2)
difference() {
    mainHolder();
    slit(rightNubFromBase,rightNubSlitThickness,rightNubSlitLength,rightNubSlitDepth);
    mirror([1,0,0]) slit(leftNubFromBase,leftNubSlitThickness,leftNubSlitLength,leftNubSlitDepth);
}

