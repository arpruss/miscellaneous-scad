use <paths.scad>;

//<params>
holderHeight = 38;

// If you have a Garmin Nuvi holder and want this to fit inside it, set this to true. Otherwise, set it to false and everything will look a bit better
fitIntoNuviHolder = 1; //[0:No, 1:Yes]
// If phoneWidth is above 85, it won't work well with the Nuvi holder mode
phoneWidth = 83.8; 
// This is a little bit less than the thickness of the phone, to take into account phone/case rounding
phoneThickness = 11;

// This has to be sufficiently thick to accommodate the Nuvi holder slits (if desired) and the hex bolt head (if desired). With all the current parameters, it is not recommended to make this less than 7
baseThickness = 13.4;

// set to zero if we don't need a slot on the right right side for buttons to fit inside
buttonSlotLength = 24.3;
buttonSlotThickness = 5;

// The phone is rounded, and hence narrower near the back
narrowerWidthInset = 3.8;
narrowingAmount = 1.9;

// This controls how far the nubs that keep the phone from falling out go
snapInset = 1.25;
// If this is larger, the snap is more durable, but harder to use
snapThickness = 1.5;
// If snapThickness is small, this should give some extra strength
strengtheningBumpOffset = 3.35;

// Round all the sharp edges
rounding = 0.8;

// set to zero to remove bolt hole
hexBoltDistanceAcrossFlats = 11.4;
// depth of bolt head inset (a little bigger than the bolt head thickness)
hexBoltDepthOfHeadInset = 5;
// shaft diameter
hexBoltShaftDiameter = 6.6;

// The following parameters are for fitting into my Nuvi GPS holder
Nuvi_b1 = 79.1;
Nuvi_b1a = 83.6;
Nuvi_b2 = 85.4;
Nuvi_h1a = 2.5;
Nuvi_hDelta = 4;
Nuvi_rightNubFromBase = 5.6;
Nuvi_rightNubSlitThickness = 3.3;
Nuvi_rightNubSlitLength = 22.5;;
Nuvi_rightNubSlitDepth = 2.7;
Nuvi_leftNubFromBase = 6.9;
Nuvi_leftNubSlitThickness = 2.2;
Nuvi_leftNubSlitLength = 15;
Nuvi_leftNubSlitDepth = 1.5;

// No-Nuvi parameters
b1_inset = 2.35;
b1a_inset = 0.1;
b2_offset = 0.8;
//</params>

module dummy() {}

b1 = fitIntoNuviHolder != 0 ? Nuvi_b1 : phoneWidth - 2 * b1_inset;
b1a = fitIntoNuviHolder != 0 ? Nuvi_b1a : phoneWidth - 2 * b1a_inset;
b2 = fitIntoNuviHolder != 0 ? Nuvi_b2 : phoneWidth + 2 * b2_offset;
h1a = Nuvi_h1a;
hDelta = Nuvi_hDelta;
rightNubFromBase = Nuvi_rightNubFromBase;
rightNubSlitThickness = Nuvi_rightNubSlitThickness;
rightNubSlitLength = Nuvi_rightNubSlitLength;
rightNubSlitDepth = Nuvi_rightNubSlitDepth;
leftNubFromBase = Nuvi_leftNubFromBase;
leftNubSlitThickness = Nuvi_leftNubSlitThickness;
leftNubSlitLength = Nuvi_leftNubSlitLength;
leftNubSlitDepth = Nuvi_leftNubSlitDepth;

b3 = phoneWidth + 2 * strengtheningBumpOffset;
narrowerWidth = phoneWidth - 2 * narrowingAmount;

phoneThicknessAdj = phoneThickness - narrowerWidthInset;
nubsFromBase = max(rightNubFromBase,leftNubFromBase);
fromNubsToPhone = baseThickness - nubsFromBase;

nudge = 0.001;

rightPath = 
  [ [b1/2,0],
    [b1a/2,h1a],
    [b2/2,nubsFromBase],
    [b2/2,baseThickness-hDelta],
    [b3/2,baseThickness],
    [phoneWidth/2+snapThickness,baseThickness+phoneThicknessAdj*0.5],
    [phoneWidth/2+snapThickness,baseThickness+phoneThicknessAdj+snapThickness+1.5],
    [phoneWidth/2-snapInset,baseThickness+phoneThicknessAdj+snapThickness],
    [phoneWidth/2-snapInset,baseThickness+phoneThicknessAdj],
    [phoneWidth/2,baseThickness+phoneThicknessAdj],
    [phoneWidth/2,baseThickness],
    [narrowerWidth/2,baseThickness-narrowerWidthInset],
    [0, baseThickness-narrowerWidthInset]
];
    
    
path = stitchPaths(rightPath,reverseArray(transformPath(mirrorMatrix([1,0]),rightPath)));

module mainHolder() {
    linear_extrude(height=holderHeight) 
offset(r=-rounding) offset(r=rounding) polygon(points=path);
}

module slit(nubFromBase,nubSlitThickness,nubSlitLength,nubSlitDepth) {
    translate([b2/2+nudge-nubSlitDepth,nubFromBase-nubSlitThickness/2,holderHeight/2-nubSlitLength/2])
    cube([nubSlitDepth+nudge+10,nubSlitThickness,nubSlitLength]);
}

module hexHole() {
    translate([0,baseThickness-narrowerWidthInset+nudge,holderHeight/2])
    rotate([90,0,0]) {
        rotate([0,0,30])
        cylinder(d=hexBoltDistanceAcrossFlats/cos(180/6),h=hexBoltDepthOfHeadInset,$fn=6);
        cylinder(d=hexBoltShaftDiameter,h=50,$fn=32);
    }
}

render(convexity=2)
difference() {
    mainHolder();
    if (fitIntoNuviHolder != 0) {
        slit(rightNubFromBase,rightNubSlitThickness,rightNubSlitLength,rightNubSlitDepth);
        mirror([1,0,0]) slit(leftNubFromBase,leftNubSlitThickness,leftNubSlitLength,leftNubSlitDepth);
    }
    if (buttonSlotLength) {
        translate([b1/2,baseThickness,(holderHeight-buttonSlotLength)/2]) cube([15,buttonSlotThickness,buttonSlotLength]);
    }
    if (hexBoltDistanceAcrossFlats) {
        hexHole();
    }
}

