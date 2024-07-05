use <paths.scad>;

//<params>
hexFlats = 11.4;
hexDepth = 5;
hexShaft = 6.6;
b1 = 79.5-.4;
b1a = 85.0-.5-.9;
b2 = 86.8-.5-.9;
b3 = 91-.5;
h1a = 2+.5;
hDelta = 4;
rightNubFromBase = 5.6;
rightNubSlitThickness = 3.3;
rightNubSlitLength = 22.5;;
rightNubSlitDepth = 2.7;
leftNubFromBase = 6.9;
leftNubSlitThickness = 2.2;
leftNubSlitLength = 15;
leftNubSlitDepth = 1.5;
fromNubsToPhone = 6.5;
phoneWidth = 83.8; // 80.2 real, 
phoneNarrowerWidth = 80;
phoneNarrowerWidthInset = 3.8;

snapHeight = 11;
snapInset = 1.25;
snapThickness = 1.5;
holderWidth = 38;

buttonSlotLength = 24.3;
buttonSlotThickness = 5;

rounding = 0.8;
//</params>

snapHeightAdj = snapHeight - phoneNarrowerWidthInset;

module dummy() {}

nudge = 0.001;

rightPath = 
  [ [b1/2,0],
    [b1a/2,h1a],
    [b2/2,max(leftNubFromBase,rightNubFromBase)],
    [b2/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone-hDelta],
    [b3/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone],
    [phoneWidth/2+snapThickness,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeightAdj*0.5],
    [phoneWidth/2+snapThickness,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeightAdj+snapThickness+1.5],
    [phoneWidth/2-snapInset,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeightAdj+snapThickness],
    [phoneWidth/2-snapInset,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeightAdj],
    [phoneWidth/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone+snapHeightAdj],
    [phoneWidth/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone],
    [phoneNarrowerWidth/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone-phoneNarrowerWidthInset],
    [0, max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone-phoneNarrowerWidthInset]
];
    
    
path = stitchPaths(rightPath,reverseArray(transformPath(mirrorMatrix([1,0]),rightPath)));

module mainHolder() {
    linear_extrude(height=holderWidth) 
offset(r=-rounding) offset(r=rounding) polygon(points=path);
}

module slit(nubFromBase,nubSlitThickness,nubSlitLength,nubSlitDepth) {
    translate([b2/2+nudge-nubSlitDepth,nubFromBase-nubSlitThickness/2,holderWidth/2-nubSlitLength/2])
    cube([nubSlitDepth+nudge,nubSlitThickness,nubSlitLength]);
}

module hexHole() {
    translate([0,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone-phoneNarrowerWidthInset+nudge,holderWidth/2])
    rotate([90,0,0]) {
        rotate([0,0,30])
        cylinder(d=hexFlats/cos(180/6),h=hexDepth,$fn=6);
        cylinder(d=hexShaft,h=50,$fn=32);
    }
}

render(convexity=2)
difference() {
    mainHolder();
    slit(rightNubFromBase,rightNubSlitThickness,rightNubSlitLength,rightNubSlitDepth);
    mirror([1,0,0]) slit(leftNubFromBase,leftNubSlitThickness,leftNubSlitLength,leftNubSlitDepth);
    translate([b1/2,max(leftNubFromBase,rightNubFromBase)+fromNubsToPhone,(holderWidth-buttonSlotLength)/2]) cube([15,buttonSlotThickness,buttonSlotLength]);
    if (hexFlats) {
        hexHole();
    }
}

